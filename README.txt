Raid Tank Marker - WoW Retail (12.1.5)

INSTALLATION
Copy the folder RaidTankMarker to:
World of Warcraft\_retail_\Interface\AddOns\RaidTankMarker\

Then restart WoW or use /reload.

BEHAVIOR
- Only works inside a raid.
- Requires exactly one player assigned the TANK role in raid group 1,
  and exactly one in raid group 2.
- Your group 1/3/5/7: display the raid target marker of group 1's tank.
- Your group 2/4/6/8: display the raid target marker of group 2's tank.
- If your assigned tank has no raid target marker, display nothing.
- The symbol is displayed beside the group label above your own player portrait.
- Does not change any actual raid markers.

COMMANDS
/rtm refresh  - refresh automatically
/rtm test     - display a star temporarily to check positioning

If group label is hidden by Blizzard's UI, a child marker may be hidden as well.
Tested through static source inspection only; in-game verification required.
