# BG3 Physical Dice Mod

A Baldur's Gate 3 mod that allows players to use physical dice rolls during combat.

## Features

- Input your physical d20 roll results during combat
- Exact roll matching using Min+Max boost system
- Console command interface
- Instant boost application during your turn
- One-shot mode: boost applies for one action, then removes itself
- Supports all party members

## Requirements

- Baldur's Gate 3 (v4.69.95.620 or later)
- BG3 Script Extender v29+

## Installation

1. Install BG3 Script Extender from [Norbyte's releases](https://github.com/Norbyte/bg3se/releases)
2. Download `PhysicalDiceMod_STABLE_v1.0.pak`
3. Place the PAK file in: `%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods\`
4. Enable the mod in BG3 Mod Manager or modsettings.lsx

## Usage

During combat:

1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. Press F3 to open console
4. Type: `!setroll 15`
5. Boost applies INSTANTLY
6. Make your attack - the roll will be EXACTLY 15

### Commands

- `!setroll <1-20>` - Set your physical dice roll
- `!checkroll` - Check current boost status
- `!clearroll` - Clear boost/queued value

## How It Works

The mod uses BG3's `MinimumRollResult` and `MaximumRollResult` boost system to lock dice rolls to exact values:

```lua
MinimumRollResult(Attack,15) + MaximumRollResult(Attack,15) = Exactly 15
```

This works for:
- Attack rolls
- Saving throws
- Skill checks
- Ability checks

## Technical Details

- **Boost Application**: Instant when command is used during your turn, queued otherwise
- **Boost Removal**: Automatic after first attack (one-shot mode) or at turn end
- **Player Detection**: Uses `Osi.IsPartyMember()` to identify party members
- **Turn Tracking**: Monitors `TurnStarted` and `TurnEnded` Osiris events

## Development

### Project Structure

```
Mods/PhysicalDiceMod/
├── meta.lsx                          # Mod metadata
├── ScriptExtender/
│   ├── Config.json                   # SE configuration
│   └── Lua/
│       ├── BootstrapServer.lua       # Server entry point
│       ├── BootstrapClient.lua       # Client entry point
│       ├── Server/
│       │   ├── PhysicalDiceInput.lua # Main input system
│       │   ├── BoostRollSystem.lua   # Boost helpers
│       │   ├── AutoTest.lua          # Testing system
│       │   ├── RollInterceptor.lua   # Roll monitoring
│       │   └── PhysicalDiceServer.lua# Event discovery
│       └── Client/
│           ├── PhysicalDiceClient.lua
│           └── RollInterceptor.lua
```

### Building

Use the all-in-one pack command:

```powershell
New-Item -ItemType Directory -Path 'C:\Users\boris\Desktop\temp_pack\Mods' -Force | Out-Null; Copy-Item 'c:\Projects\DAIMI FEEDBACK FORM\Mods\PhysicalDiceMod' -Destination 'C:\Users\boris\Desktop\temp_pack\Mods\PhysicalDiceMod' -Recurse -Force; & 'C:\Users\boris\Downloads\LSLib\Packed\Tools\Divine.exe' -g bg3 -a create-package -s 'C:\Users\boris\Desktop\temp_pack' -d 'C:\Users\boris\AppData\Local\Larian Studios\Baldur''s Gate 3\Mods\PhysicalDiceMod.pak' -c lz4; Remove-Item 'C:\Users\boris\Desktop\temp_pack' -Recurse -Force
```

## Known Limitations

- Damage rolls are not affected (only d20 rolls)
- Client-side attack rolls may have slight delays
- Requires console access (F3) for input

## Future Plans

- [ ] MCM (Mod Configuration Menu) integration for UI
- [ ] Damage roll support
- [ ] Hotkey for quick roll input
- [ ] Roll history tracking

## Credits

- **Script Extender**: [Norbyte](https://github.com/Norbyte/bg3se)
- **Boost System Discovery**: Serofix's BG3 Cheat Table

## License

MIT License - Free to use and modify

## Version History

### v1.0.0 (Current - Stable)
- Initial release
- Console command interface
- Exact roll locking with Min+Max boosts
- Instant application system
- One-shot mode
- Party member support
