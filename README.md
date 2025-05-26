Trail to the West
A retro-style, Oregon Trail-inspired survival game built with Processing. Manage your pioneer party as you travel westward across a rugged 2000-mile journey. Make strategic decisions, survive random events, hunt for food, and strive to reach Oregon with your party alive.

🎮 Gameplay Overview
In Trail to the West, you:

- Lead a wagon party through key landmarks like Fort Kearny and Chimney Rock.
- Balance resources like food, medicine, and ammo.
- Respond to daily random events such as illness, river crossings, and traders.
- Play a pixel-art hunting mini-game to gather food.
- Navigate a menu system for travel, rest, hunting, trading, and checking inventory.
- Experience permadeath — if all party members die, the game ends.

🛠 Features

- Multiple Game States: Menu, Travel, Event, Hunt.
- Pixel Art Style: Classic aesthetics with support for custom background and sprite images.
- Party System: Track each member’s health and morale.
- Event Engine: Branching events with multiple outcomes.
- Animated Hunting Mini-Game: Time-limited hunting with animated deer sprites and shooting mechanics.

Folder Structure

- TrailToTheWest/
├── TrailToTheWest.pde     # Main game code
└── data/
    ├── background_menu.png
    ├── background_travel.png
    ├── background_event.png
    ├── background_hunt.png
    ├── parchment.png
    ├── border.png
    ├── deer.png
    ├── deer1.png
    └── deer2.png
All image assets must be placed in the data folder.

▶️ Getting Started
Prerequisites
Processing IDE: Download from https://processing.org/download

Installation & Launch

1. Clone or download this repository.
2. Open TrailToTheWest.pde in Processing.
3. Ensure all image files are in the /data folder.
4. Click the Run button in Processing.

🎨 Customization
You can customize the game visuals by replacing images in the data folder. Use the same filenames to avoid code changes.

🧠 Design Notes

- Events are randomly triggered based on a daily chance.
- Decisions can directly affect party health, morale, or resources.
- The game ends when all party members die or the final milestone (Oregon) is reached.


📄 License
This project is open-source and available under the MIT License.
