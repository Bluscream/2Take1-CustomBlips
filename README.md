# 2Take1Menu CustomBlips LUA script ![GitHub last commit](https://img.shields.io/github/last-commit/Bluscream/2Take1-CustomBlips)

## What is CustomBlips?

CustomBlips is meant to be a 2t1 LUA replacement for mods like [CustomBlips.dll](https://www.gta5-mods.com/scripts/custom-blips) and [AddBlips.cs](https://www.gta5-mods.com/scripts/addblips) without the need of any ASI loader or ScriptHook, which makes it easier to manage and more stable.

## Features
- Creation and deletion of static blips stored in *.blips files in a format similar to CSV.
- Automatic creation and deletion of blips for entities (Currently only vehicles are supported)
- Button to clear all existing blips (Even ones not created by this script)

## Upcoming Features
- Auto enabling last selected lists on startup
- Reading more list formats (also read from GTAV dir instead of just 2t1)
- Menu-based list editing and management

## Known Issues
- Button `Clear all blips` does not clear all blips and some are coming back in online every second.

## Installation
1. Get the latest version of [Kek's Menu](https://github.com/kektram/Keks-menu#how-to-install)
2. Download the latest [main.zip](https://github.com/Bluscream/2Take1-CustomBlips/archive/refs/heads/main.zip)
3. Unpack it to your `%APPDATA%\PopstarDevs\2Take1Menu` folder
4. Verify that you have unpacked to the right location by checking wether the file `%APPDATA%\PopstarDevs\2Take1Menu\scripts\CustomBlips.lua` and the folder `%APPDATA%\PopstarDevs\2Take1Menu\cfg\blips\` exist

## Usage
- To toggle a static list, click on it in the `Script Features/Custom Blips` menu.
- To toggle a vehicle list, click on it in the `Script Features/Custom Blips/vehicles` menu.
- To clear all game blips, click on the `Script Features/Custom Blips/Clear all blips` button.
- To clear all custom blips and disable any entity blips, unload the script.

### If you found a bug, please report it at [issues/new](https://github.com/Bluscream/2Take1-CustomBlips/issues/new).

### If you want to contribute, feel free to open a [pull request](https://github.com/Bluscream/2Take1-CustomBlips/pulls/new).

## Credits
- Natives using kektram's wonderful library, real hero <3
- Most of the helper functions ©️ Github Copilot
- `Emergency Stations.blips` by [edo97@GTAV-Mods.com](https://www.gta5-mods.com/scripts/addblips)
- `Gas Stations.blips` by [edo97@GTAV-Mods.com](https://www.gta5-mods.com/scripts/addblips)
- `City Bus Stops.blips` by [WTLS@GTAV-Mods.com](https://www.gta5-mods.com/scripts/los-santos-bus-service-as-client-bus-transport-service-in-los-santos-player-as-passenger-openiv)
- `Long Distance Bus Stops.blips` by [WTLS@GTAV-Mods.com](https://www.gta5-mods.com/scripts/long-travel-bus-service)

If i forgot to mention you, just open an issue and i'll be happy to add you to this list :)