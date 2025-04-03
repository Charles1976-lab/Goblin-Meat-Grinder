How to Play
Enter your character’s name when prompted.
Assign your rolled stats (Strength, Dexterity, Constitution) by choosing from a menu.
Combat begins automatically:
Each round, a new goblin spawns (e.g., goblin0.txt, goblin1.txt).
Initiative is rolled for you and all goblins.
Attacks resolve in initiative order: you swing a Longsword (1d8 + Str mod), goblins swing Clubs (1d4 + Str mod).
Goblins die at 0 HP (files are deleted); you die at 0 HP, ending with "You died."
Game Mechanics
Stats: Rolled as 3d6 (3–18 range).
Health Points (HP): Player = Constitution + 10; Goblin = 15 (from template).
Armor Class (AC): Player = 11 (leather armor) + Dex mod; Goblin = 12 (hide armor) + Dex mod.
Initiative: 1d20 + Dex modifier.
Attack: 1d20 + Str modifier vs. AC.
Damage: Player = 1d8 + Str mod; Goblin = 1d4 + Str mod.
Files Generated
charactersheet.txt: Stores your character’s stats, HP, AC, and weapon.
goblinX.txt: Temporary files for each goblin (e.g., goblin0.txt), deleted when HP ≤ 0.
Future Enhancements
Add multiple monster types (e.g., orc.txt, dragon.txt) with Challenge Rating selection.
Implement an escape mechanic or victory condition (currently none by design).
Track rounds survived as a high score.
Contributing
Feel free to fork, submit pull requests, or report issues via GitHub. Ideas for new features or bug fixes are welcome!

License
This project is licensed under the MIT License—see the  file for details.

Acknowledgments
Built with help from Grok (xAI) for iterative design and debugging.
Inspired by Dark Souls’ unforgiving gameplay.
