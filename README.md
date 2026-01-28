# BG3 Physical Dice Mod

A Baldur's Gate 3 mod that allows players to use physical dice rolls during combat.

## Features

- Input your physical d20 roll results during combat
- Exact roll matching using Min+Max boost system
- **MCM (Mod Configuration Menu) integration with in-game UI**
- **Customizable hotkeys (F9/F10 by default)**
- **Auto-apply option for automatic roll application**
- Console command interface (still works as fallback)
- Instant boost application during your turn
- One-shot mode: boost applies for one action, then removes itself
- Supports all party members

## Requirements

- Baldur's Gate 3 (v4.69.95.620 or later)
- BG3 Script Extender v29+
- **[Mod Configuration Menu (MCM)](https://github.com/AtilioA/BG3-MCM) - Highly Recommended**
  - Not strictly required - console commands work without MCM
  - MCM provides the best user experience with in-game UI

## Installation

1. Install [BG3 Script Extender](https://github.com/Norbyte/bg3se/releases) v29+
2. **(Recommended)** Install [Mod Configuration Menu (MCM)](https://github.com/AtilioA/BG3-MCM)
   - Download from Nexus Mods or GitHub
   - Provides in-game UI for the mod
3. Download `PhysicalDiceMod.pak`
4. Place the PAK file in: `%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods\`
5. Enable the mod in BG3 Mod Manager or modsettings.lsx
6. Launch the game with Script Extender

## Usage

### Method 1: MCM Interface (Recommended)

**Setup:**
1. Press ESC in-game
2. Select "Mod Configuration Menu"
3. Find "Physical Dice Mod"
4. Customize your hotkeys if desired (default: F9 to apply, F10 to clear)

**During Combat:**
1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. **Option A:** Use the slider in MCM to set 15, then press F9
4. **Option B:** Enable "Auto-Apply on Your Turn" in MCM, set slider before your turn starts
5. Make your attack - the roll will be EXACTLY 15

**MCM Features:**
- Slider control (1-20)
- Quick buttons for critical fail (1), average (10), and critical success (20)
- Customizable hotkeys
- Auto-apply option
- Increment/Decrement hotkeys (=/- keys by default)
- On-screen notifications

### Method 2: Console Commands (Fallback)

If you don't have MCM installed:

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
│       │   ├── PhysicalDiceInput.lua # Main input system + UI integration
│       │   ├── BoostRollSystem.lua   # Boost helpers
│       │   ├── AutoTest.lua          # Testing system
│       │   ├── RollInterceptor.lua   # Roll monitoring
│       │   └── PhysicalDiceServer.lua# Event discovery
│       └── Client/
│           ├── PhysicalDiceClient.lua
│           ├── PhysicalDiceUI.lua    # ImGui interface
│           └── RollInterceptor.lua
```

### Building

Use the all-in-one pack command:

```powershell
New-Item -ItemType Directory -Path 'C:\Users\boris\Desktop\temp_pack\Mods' -Force | Out-Null; Copy-Item 'c:\Projects\BG3 Manual Dice Roll\Mods\PhysicalDiceMod' -Destination 'C:\Users\boris\Desktop\temp_pack\Mods\PhysicalDiceMod' -Recurse -Force; & 'C:\Users\boris\Downloads\LSLib\Packed\Tools\Divine.exe' -g bg3 -a create-package -s 'C:\Users\boris\Desktop\temp_pack' -d 'C:\Users\boris\AppData\Local\Larian Studios\Baldur''s Gate 3\Mods\PhysicalDiceMod.pak' -c lz4; Remove-Item 'C:\Users\boris\Desktop\temp_pack' -Recurse -Force
```

## Known Limitations

- Damage rolls are not affected (only d20 rolls)
- Client-side attack rolls may have slight delays

## Future Plans

- [x] MCM (Mod Configuration Menu) integration (Completed in v1.1.0)
- [x] Hotkey support (Completed in v1.1.0)
- [ ] Damage roll support
- [ ] Roll history tracking
- [ ] ImGui UI (if BG3SE v30+ becomes standard)

## Credits

- **Script Extender**: [Norbyte](https://github.com/Norbyte/bg3se)
- **Boost System Discovery**: Serofix's BG3 Cheat Table
- **MCM Framework**: [AtilioA/BG3-MCM](https://github.com/AtilioA/BG3-MCM)

## License

MIT License - Free to use and modify

## Version History

### v1.1.0 (Current - MCM Integration)
- **Added MCM (Mod Configuration Menu) integration**
- In-game UI with slider control (1-20)
- Customizable hotkeys (F9/F10 defaults)
- Auto-apply option for automatic roll application
- Quick roll buttons (1, 10, 20)
- Increment/Decrement hotkeys (=/-)
- On-screen notifications
- Console commands still work as fallback
- Graceful degradation if MCM not installed

### v1.0.0 (Stable)
- Initial release
- Console command interface
- Exact roll locking with Min+Max boosts
- Instant application system
- One-shot mode
- Party member support
