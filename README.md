# ESX Bunker Robbery

A script for FiveM that allows players to rob a bunker with their crew, featuring loot tables, guard NPCs, and team teleportation.

## Features

- Team-based bunker robbery system
- Configurable loot tables with random amounts
- Guard NPCs with weapons and combat behavior
- Dynamic target zones for loot and exit
- Progress bar for looting
- Crew selection menu
- Teleportation system for entering/exiting bunker

## Requirements

- [ESX Legacy](https://github.com/esx-framework/esx-legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Place `esx_bunker_robbery` in your `resources` directory
2. Add `ensure esx_bunker_robbery` to your server.cfg
3. Configure the script in `config.lua`

## Configuration

Edit `config.lua` to customize:

- Loot time duration
- Loot table items and amounts
- Bunker entry/exit locations
- Guard NPC models, weapons, and positions
- Interior teleport locations

## Usage

1. Approach the bunker entrance (defined in config)
2. Select "Vykrást bunker" (Rob bunker) from the target option
3. Choose your crew members from the menu
4. Confirm selection to start the robbery
5. Inside the bunker:
   - Loot marked containers
   - Defeat or avoid guards
   - Exit through the marked door when finished

## Loot System

The loot table supports:
- Static amounts (`amount = 1`)
- Random amounts (`amount = function() return math.random(1,3) end`)
- Money (`item = "money"`)
- Weapons (`item = "weapon_pistol"`)
- Items (`item = "gold_bar"`)

## Dependencies

This script requires:
- ESX Legacy framework
- ox_lib for UI elements
- ox_target for interaction zones

## Troubleshooting

If you encounter issues:
- Verify all dependencies are installed
- Check server console for errors
- Ensure your ESX version is up-to-date
- Verify all config coordinates are correct

## Credits

- Developed by koki26
- Uses ox_lib and ox_target by Overextended
- ESX Framework by ESX-Framework