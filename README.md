# BG3 Physical Dice Mod

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![BG3](https://img.shields.io/badge/BG3-v4.69.95.620+-green)
![Script Extender](https://img.shields.io/badge/Script%20Extender-v29+-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

A Baldur's Gate 3 mod that lets you use **real physical d20 dice** in combat. Roll your dice IRL, input the result, and watch your character use that exact roll in-game!

## Table of Contents

- [Download](#download)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [MCM Interface (Recommended)](#method-1-mcm-interface-recommended)
  - [Console Commands](#method-2-console-commands-fallback)
- [How It Works](#how-it-works)
- [Development](#development)
- [Contributing](#contributing)
- [Support](#support)
- [Credits](#credits)
- [License](#license)
- [Version History](#version-history)

## Download

**Latest Release:** [v1.1.0](../../releases/latest)

Download `PhysicalDiceMod.pak` from the [Releases](../../releases) page.

## Quick Start

1. Install [BG3 Script Extender v29+](https://github.com/Norbyte/bg3se/releases) and [MCM](https://github.com/AtilioA/BG3-MCM)
2. Download and install `PhysicalDiceMod.pak` to your Mods folder
3. In-game: Press ESC → Mod Configuration Menu → Physical Dice Mod
4. During combat: Set slider to your physical d20 roll, press **F9** to apply
5. Make your attack - the game will use your exact roll!

## Features

### Core Functionality
- 🎲 Input your physical d20 roll results during combat
- 🎯 Exact roll matching using Min+Max boost system
- ⚡ Instant boost application during your turn
- 🔄 One-shot mode: boost applies for one action, then removes itself
- 👥 Supports all party members

### MCM Integration (v1.1.0)
- 🖱️ **In-game UI with slider control (1-20)**
- ⌨️ **Customizable hotkeys** (F9 to apply, F10 to clear)
- 🚀 **Quick roll buttons** for 1, 10, and 20
- ⬆️⬇️ **Increment/Decrement hotkeys** (+/- keys)
- 🤖 **Auto-apply option** for automatic roll application
- 📢 **On-screen notifications**

### Fallback Options
- 💻 Console command interface (works without MCM)
- ⚙️ Graceful degradation if MCM not installed

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

### Building from Source

**Requirements:**
- [LSLib](https://github.com/Norbyte/lslib) (Divine.exe tool)

**Build Process:**
1. Clone this repository
2. Modify the Lua files in `Mods/PhysicalDiceMod/ScriptExtender/Lua/`
3. Use Divine.exe to pack the mod folder into a .pak file:

```powershell
# Example pack command (adjust paths as needed)
Divine.exe -g bg3 -a create-package -s ".\Mods\PhysicalDiceMod" -d "PhysicalDiceMod.pak" -c lz4
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

## Contributing

Contributions are welcome! If you'd like to improve the mod:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

Having issues? Please [open an issue](../../issues) with:
- Your BG3 version
- Script Extender version
- MCM version (if applicable)
- Description of the problem
- Any error messages from the Script Extender console (F3)

## Credits

- **Script Extender**: [Norbyte](https://github.com/Norbyte/bg3se)
- **Boost System Discovery**: Serofix's BG3 Cheat Table
- **MCM Framework**: [AtilioA/BG3-MCM](https://github.com/AtilioA/BG3-MCM)

## License

MIT License - Free to use and modify. See [LICENSE](LICENSE) for details.

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
