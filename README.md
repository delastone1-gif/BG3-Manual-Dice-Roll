# BG3 Physical Dice Mod

![Version](https://img.shields.io/badge/version-1.2.1-blue)
![BG3](https://img.shields.io/badge/BG3-v4.69.95.620+-green)
![Script Extender](https://img.shields.io/badge/Script%20Extender-v29+-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

A Baldur's Gate 3 mod that lets you use **real physical dice** in combat - both **d20 attack rolls** and **damage rolls**! Roll your dice IRL, input the results, and watch your character use those exact values in-game!

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

**Latest Release:** [v1.2.1](../../releases/latest)

Download `PhysicalDiceMod.pak` from the [Releases](../../releases) page.

## Quick Start

1. Install [BG3 Script Extender v29+](https://github.com/Norbyte/bg3se/releases) and [MCM](https://github.com/AtilioA/BG3-MCM)
2. Download and install `PhysicalDiceMod.pak` to your Mods folder
3. In-game: Press ESC → Mod Configuration Menu → Physical Dice Mod
4. During combat:
   - **Attack Rolls:** Controls tab → Set slider to your d20 roll → Click Apply
   - **Damage Rolls:** Damage tab → Set slider to your damage total → Click Apply
5. Make your attack - the game will use your exact rolls!

## Features

### Core Functionality
- 🎲 Input your physical d20 roll results during combat
- 💥 **NEW in v1.2.0:** Input damage roll results (1-80 range)
- 🎯 Exact roll matching using Min+Max boost system
- ⚡ Instant boost application during your turn
- 🔄 One-shot mode: boost applies for one action, then removes itself
- 👥 Supports all party members
- 💾 Works correctly when loading saves mid-combat (fixed in v1.1.1)
- 🛡️ **Built-in anti-cheat:** Game enforces natural damage caps per spell/weapon

### MCM Integration
- 🖱️ **In-game UI with slider controls**
  - **Controls tab:** d20 rolls (1-20)
  - **Damage tab:** Damage rolls (1-80) - **NEW in v1.2.0**
- 🔘 **Apply buttons** - Click to apply your roll values
- 🚀 **Quick roll buttons**
  - Controls: 1, 10, 20 (critical fail, average, critical success)
  - Damage: 10, 40, 80 (low, average, high) - **NEW in v1.2.0**
- 🤖 **Auto-apply option** for automatic attack roll application
- 📢 **On-screen notifications**
- ⌨️ **Hotkey configuration available** (customizable in MCM settings)

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
4. (Optional) Customize hotkeys in Hotkeys section

**During Combat:**
1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. **Option A - Slider:** Set slider to 15, then **click the Apply button**
4. **Option B - Quick Roll:** Click the **"15" button** (or any 1-20 value buttons)
5. **Option C - Auto-Apply:** Enable "Auto-Apply on Your Turn", set value before your turn
6. Make your attack - the roll will be EXACTLY 15

**MCM Features:**
- Slider control (1-20) with Apply button
- Quick roll buttons for 1, 10, and 20 (click for instant application)
- Auto-apply option (automatically applies roll at turn start)
- On-screen notifications
- Hotkey configuration (can be customized in MCM)

### Method 2: Console Commands (Fallback)

If you don't have MCM installed:

1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. Press F3 to open console
4. Type: `!setroll 15`
5. Boost applies INSTANTLY
6. Make your attack - the roll will be EXACTLY 15

### Commands

**Attack Rolls:**
- `!setroll <1-20>` - Set your physical d20 roll
- `!r` - Apply current MCM slider value
- `!checkroll` - Check current boost status
- `!clearroll` - Clear attack boost

**Damage Rolls (NEW in v1.2.0):**
- `!setdamage <1-80>` - Set your physical damage roll
- `!cleardamage` - Clear damage boost

## How It Works

The mod uses BG3's `MinimumRollResult` and `MaximumRollResult` boost system to lock rolls to exact values:

**Attack Rolls (d20):**
```lua
MinimumRollResult(Attack,15) + MaximumRollResult(Attack,15) = Exactly 15
```

**Damage Rolls (NEW in v1.2.0):**
```lua
MinimumRollResult(Damage,35) + MaximumRollResult(Damage,35) = Exactly 35
```

**✅ Confirmed Working:**
- Attack rolls (d20)
- Damage rolls with built-in anti-cheat (game enforces spell/weapon max damage)

**❓ Theoretically Supported (not extensively tested):**
- Saving throws (boost applied, not confirmed)
- Skill checks (boost applied, not confirmed)
- Ability checks (boost applied, not confirmed)

**🛡️ Anti-Cheat Discovery:**
Even if you set damage to 80, the game enforces natural maximums:
- Fireball (8d6) caps at 48 damage
- Magic Missile (1d4+1) caps at 5 per missile
- Weapon attacks cap at weapon die + modifiers
This prevents cheating while still allowing you to match your physical dice rolls!

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

- **Only attack rolls have been tested and confirmed working**
  - Saving throws, skill checks, and ability checks have boost code but are unverified
- Damage rolls are not affected (only d20 rolls)
- Client-side attack rolls may have slight delays

## Future Plans

- [x] MCM (Mod Configuration Menu) integration (Completed in v1.1.0)
- [x] Clickable buttons for quick rolls (Completed in v1.1.0)
- [ ] Working hotkey support
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

### v1.2.1 (Current - Stable)
- **🔧 CRITICAL FIX: Boost Interference Bug Resolved**
- Implemented combined boost system - one atomic boost instead of two separate boosts
- Eliminates boost interference when setting attack roll followed by damage roll (or vice versa)
- No more timing issues or race conditions
- Attack and damage values tracked separately but applied as single boost
- Both boosts remain independent (can clear damage only without affecting attack)
- Verified working in all scenarios: attack only, damage only, both together
- Version identifier added to console output for easy verification
- **Recommended upgrade from v1.2.0** - all users should update immediately

### v1.2.0 (Beta - Superseded by v1.2.1)
- **🎉 MAJOR FEATURE: Damage Roll Support**
- Added damage roll input system (1-80 range)
- New "Damage" tab in MCM with slider and quick buttons (10, 40, 80)
- Console commands: `!setdamage`, `!cleardamage`
- Independent boost tracking for attack and damage rolls
- Both boosts can be active simultaneously
- Extended API: `SetDamage()`, `ClearDamage()`, updated `GetStatus()`
- **🛡️ Discovered built-in anti-cheat:** Game enforces natural damage caps per spell/weapon
- Perfect for weapon attacks (d20 + damage) and damage-only spells (Fireball, Acid Splash)
- Supports matching physical dice damage rolls to in-game results
- One-shot removal for both attack and damage boosts
- No cheating possible - damage cannot exceed spell/weapon maximums

### v1.1.1
- **Fixed critical mid-combat save load bug**
- Boosts now apply immediately after loading a save during combat
- Removed turn-based queuing system that caused issues with save/load
- Improved reliability of boost application regardless of turn state

### v1.1.0 (MCM Integration)
- **Added MCM (Mod Configuration Menu) integration**
- In-game UI with slider control (1-20)
- Clickable Apply button to apply roll values
- Quick roll buttons (1, 10, 20) with instant application
- Auto-apply option for automatic roll application
- On-screen notifications
- Hotkey configuration UI (for future implementation)
- Console commands still work as fallback
- Graceful degradation if MCM not installed

### v1.0.0 (Stable)
- Initial release
- Console command interface
- Exact roll locking with Min+Max boosts
- Instant application system
- One-shot mode
- Party member support
