#!/bin/bash

CHAR_SHEET="charactersheet.txt"
BASE_GOBLIN="goblin.txt"
MODIFIER_FILE="modifier.txt"

# Check if required files exist
if [ ! -f "$CHAR_SHEET" ]; then
    touch "$CHAR_SHEET"
fi
if [ ! -f "$BASE_GOBLIN" ]; then
    echo "Error: $BASE_GOBLIN not found! Please create the base goblin template."
    exit 1
fi
if [ ! -f "$MODIFIER_FILE" ]; then
    echo "Error: $MODIFIER_FILE not found! Please create the modifier table."
    exit 1
fi

# Function to get modifier from modifier.txt based on stat value
get_modifier() {
    local stat="$1"
    local mod_line=$(grep -E "^$stat-|^[0-9]+-$stat|^$stat$" "$MODIFIER_FILE")
    if [ -n "$mod_line" ]; then
        echo "$mod_line" | cut -d ':' -f 2
    else
        echo "0"
    fi
}

# Function to spawn a new goblin instance
spawn_goblin() {
    local i=0
    while [ -f "goblin$i.txt" ]; do
        i=$((i + 1))
    done
    local goblin_file="goblin$i.txt"  # Local scope

    cp "$BASE_GOBLIN" "$goblin_file"
    sed -i "s/Name: Goblin/Name: Goblin $i/" "$goblin_file"

    # Calculate goblin AC (hide armor base 12 + Dex modifier)
    goblin_dex=$(grep "Dexterity" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ')
    goblin_dex_mod=$(get_modifier "$goblin_dex")
    goblin_ac=$((12 + goblin_dex_mod))
    echo "Armor Class: $goblin_ac" >> "$goblin_file"

    # Add goblin weapon
    echo "Weapon: Club (1d4)" >> "$goblin_file"

    echo "Spawned $goblin_file"
    echo "$goblin_file"  # Explicitly return the filename
}

# Function to update HP in a file
update_hp() {
    local file="$1"
    local new_hp="$2"
    sed -i "s/Health Points: .*/Health Points: $new_hp/" "$file"
    if [ "$new_hp" -le 0 ] && [ "$file" != "$CHAR_SHEET" ]; then
        rm "$file"
        echo "$file has been defeated and removed!"
    fi
}

# Ask for player name
echo "What is your name?"
read name

# Roll 3d6 stats and store in an array
echo "Rolling your stats (3d6 style)..."
declare -a stats
for i in {0..2}; do
    roll1=$(( (RANDOM % 6) + 1 ))
    roll2=$(( (RANDOM % 6) + 1 ))
    roll3=$(( (RANDOM % 6) + 1 ))
    total=$(( roll1 + roll2 + roll3 ))
    stats[$i]=$total
done
echo "Your rolled stats are: ${stats[0]}, ${stats[1]}, ${stats[2]}"

# Initialize player variables
strength=""
dexterity=""
constitution=""
available_stats=("${stats[@]}")

# Assign Strength and Dexterity using a case-driven menu
for stat in "Strength" "Dexterity"; do
    selected=""
    while [ -z "$selected" ]; do
        echo -e "\nAssign a value to $stat. Available stats: ${available_stats[*]}"
        echo "Choose a number:"
        echo "1) ${available_stats[0]}"
        echo "2) ${available_stats[1]}"
        if [ ${#available_stats[@]} -eq 3 ]; then
            echo "3) ${available_stats[2]}"
        fi
        read choice

        case $choice in
            1)
                if [ -n "${available_stats[0]}" ]; then
                    selected=${available_stats[0]}
                    available_stats=("${available_stats[@]:1}")
                else
                    echo "Invalid choice! Try again."
                fi
                ;;
            2)
                if [ -n "${available_stats[1]}" ]; then
                    selected=${available_stats[1]}
                    available_stats=($(echo "${available_stats[@]}" | sed "s/${available_stats[1]}//" | tr -s ' '))
                else
                    echo "Invalid choice! Try again."
                fi
                ;;
            3)
                if [ ${#available_stats[@]} -eq 3 ] && [ -n "${available_stats[2]}" ]; then
                    selected=${available_stats[2]}
                    available_stats=("${available_stats[@]:0:2}")
                else
                    echo "Invalid choice! Try again."
                fi
                ;;
            *)
                echo "Invalid choice! Please select 1, 2, or 3."
                ;;
        esac
    done

    case $stat in
        "Strength")
            strength=$selected
            echo "Strength set to $strength"
            ;;
        "Dexterity")
            dexterity=$selected
            echo "Dexterity set to $dexterity"
            ;;
    esac
done

# Automatically assign the remaining stat to Constitution
constitution=${available_stats[0]}
echo -e "\nConstitution automatically set to: $constitution"

# Calculate Player Health Points (HP = Constitution + 10)
hp=$((constitution + 10))

# Calculate Player Armor Class (leather armor base 11 + Dex modifier)
dex_mod=$(get_modifier "$dexterity")
str_mod=$(get_modifier "$strength")
ac=$((11 + dex_mod))

# Store player data in the character sheet
echo "Name: $name" > "$CHAR_SHEET"
echo "Strength: $strength" >> "$CHAR_SHEET"
echo "Dexterity: $dexterity (+$dex_mod)" >> "$CHAR_SHEET"
echo "Constitution: $constitution" >> "$CHAR_SHEET"
echo "Health Points: $hp" >> "$CHAR_SHEET"
echo "Armor Class: $ac" >> "$CHAR_SHEET"
echo "Weapon: Longsword (1d8)" >> "$CHAR_SHEET"

# Print Character Sheet
echo "Name: $name"
echo "Strength: $strength (+$str_mod)"
echo "Dexterity: $dexterity (+dex_mod)"
echo "Constitution: $constitution (+con_mod)"
echo "HP: $hp"
echo "Armor Class: $ac"
echo "Weapon: Longsword (1d8)"

# Combat setup
round=1
declare -a goblins

##echo -e "\nCombat begins!"

# Main combat loop (runs until player HP <= 0)
##while [ "$hp" -gt 0 ]; do
##    echo -e "\nRound $round begins!"
##
    # Spawn a new goblin each round
    new_goblin=$(spawn_goblin)
    goblins+=("$new_goblin")

echo "## Number of goblins: $new_goblin ##"

##    # Roll initiative for player
##    player_init=$(( (RANDOM % 20) + 1 + dex_mod ))
##    echo "$name rolls initiative: $player_init"
##
##   # Roll initiative for each goblin and store with filename
##  declare -A initiatives
##initiatives["$CHAR_SHEET"]=$player_init
##for goblin_file in "${goblins[@]}"; do
##    if [ -f "$goblin_file" ]; then;
##        goblin_dex=$(grep "Dexterity" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ')
##        goblin_dex_mod=$(get_modifier "$goblin_dex")
##        goblin_init=$(( (RANDOM % 20) + 1 + goblin_dex_mod ))
##        echo "$(grep "Name" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ') rolls initiative: $goblin_init"
##        initiatives["$goblin_file"]=$goblin_init
##    else
##        echo "Warning: $goblin_file not found!"  # Debug output
##    fi
##done
##
### Sort combatants by initiative (highest to lowest)
##sorted_combatants=($(for file in "${!initiatives[@]}"; do echo "${initiatives[$file]} $file"; done | sort -nr | cut -d ' ' -f 2))
##
### Resolve combat in initiative order
##for combatant in "${sorted_combatants[@]}"; do
##    if [ "$hp" -le 0 ]; then
##        break  # Player is dead, stop combat
##  fi
##
##    if [ "$combatant" = "$CHAR_SHEET" ]; then
##        # Player's turn
##        for goblin_file in "${goblins[@]}"; do
##            if [ -f "$goblin_file" ]; then
##                goblin_ac=$(grep "Armor Class" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ')
##                goblin_hp=$(grep "Health Points" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ')
##                  goblin_name=$(grep "Name" "$goblin_file" | cut -d ':' -f 2 | tr -d ' ')
##
##                  to_hit=$(( (RANDOM % 20) + 1 + str_mod ))
##                  if [ "$to_hit" -ge "$goblin_ac" ]; then
##                      dmg=$(( (RANDOM % 8) + 1 + str_mod ))
##                      goblin_hp=$((goblin_hp - dmg))
##                      echo "$name hits $goblin_name for $dmg damage!"
##                      update_hp "$goblin_file" "$goblin_hp"
##                  else
##                      echo "$name misses $goblin_name."
##                  fi
##              fi
##          done
##      else
##            # Goblin's turn
##          if [ -f "$combatant" ]; then
##              goblin_name=$(grep "Name" "$combatant" | cut -d ':' -f 2 | tr -d ' ')
##              goblin_str=$(grep "Strength" "$combatant" | cut -d ':' -f 2 | tr -d ' ')
##              goblin_str_mod=$(get_modifier "$goblin_str")
##              goblin_hp=$(grep "Health Points" "$combatant" | cut -d ':' -f 2 | tr -d ' ')
##
##              to_hit=$(( (RANDOM % 20) + 1 + goblin_str_mod ))
##              if [ "$to_hit" -ge "$ac" ]; then
##                  dmg=$(( (RANDOM % 4) + 1 + goblin_str_mod ))
##                  hp=$((hp - dmg))
##                  update_hp "$CHAR_SHEET" "$hp"
##                  echo "The $goblin_name strikes for $dmg damage. You have $hp HP remaining."
##              else
##                  echo "The $goblin_name misses."
##              fi
##          fi
##      fi
##  done
##
##    # Check if all goblins are dead
##  all_dead=true
##  for goblin_file in "${goblins[@]}"; do
##      if [ -f "$goblin_file" ]; then
##          all_dead=false
##          break
##      fi
##  done
##
##  # Remove dead goblins from the array
##  temp_goblins=()
##  for goblin_file in "${goblins[@]}"; do
##      if [ -f "$goblin_file" ]; then
##          temp_goblins+=("$goblin_file")
##      fi
##  done
##  goblins=("${temp_goblins[@]}")

##  if [ "$all_dead" = true ]; then
##      echo "All goblins are defeated! Combat ends."
##      exit 0
##  fi

##  round=$((round + 1))
##done

# Player is dead
##echo -e "\nYou died"
