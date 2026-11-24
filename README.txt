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
/rtm test     - show own raid marker (simulated group label outside raids)

If group label is hidden by Blizzard's UI, a child marker may be hidden as well.
Tested through static source inspection only; in-game verification required.

SELFMARK (Midnight 12.x)
Off by default. Toggle with /rtm switch +selfmark and /rtm switch -selfmark.
Status: /rtm switch. When you are an unmarked tank in group 1 or 2
and both groups have exactly one assigned tank, a clickable button offers
the first unused marker among the raid members, with priority:
6 > 5 > 4 > 3 > 2 > 7 > 1 > 8.
Automatic marking is impossible in Midnight because SetRaidTarget is
protected. A hardware click triggers SecureActionButtonTemplate's
raidtarget/set-unmarked action and never overwrites your existing mark.
Enemy/other non-roster marker usage cannot be checked. If any roster
marker is secret, no suggestion is shown. Updates require out of combat.
