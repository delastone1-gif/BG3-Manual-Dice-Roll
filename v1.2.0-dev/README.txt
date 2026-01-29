================================================================================
PHYSICAL DICE MOD - v1.1.0
================================================================================

A Baldur's Gate 3 mod that lets you use real physical d20 dice in combat.
Roll your dice IRL, input the result, and watch your character use that exact
roll in-game!

Created by: delastone1-gif
Version: 1.1.0
License: MIT

================================================================================
INSTALLATION
================================================================================

1. Install BG3 Script Extender v29+ from:
   https://github.com/Norbyte/bg3se/releases

2. (HIGHLY RECOMMENDED) Install Mod Configuration Menu (MCM) from:
   https://github.com/AtilioA/BG3-MCM
   or Nexus Mods

3. Download PhysicalDiceMod.pak

4. Place the .pak file in:
   %LocalAppData%\Larian Studios\Baldur's Gate 3\Mods\

   Full path example:
   C:\Users\YourName\AppData\Local\Larian Studios\Baldur's Gate 3\Mods\

5. Enable the mod in BG3 Mod Manager or modsettings.lsx

6. Launch the game with Script Extender

================================================================================
REQUIREMENTS
================================================================================

REQUIRED:
- Baldur's Gate 3 (v4.69.95.620 or later)
- BG3 Script Extender v29+

HIGHLY RECOMMENDED:
- Mod Configuration Menu (MCM)
  Without MCM, you can still use console commands, but the in-game UI
  provides the best experience.

================================================================================
FEATURES
================================================================================

CORE FUNCTIONALITY:
- Input your physical d20 roll results during combat
- Exact roll matching using Min+Max boost system
- Instant boost application during your turn
- One-shot mode: boost applies for one action, then removes itself
- Supports all party members

MCM INTEGRATION (v1.1.0):
- In-game UI with slider control (1-20)
- Clickable Apply button to apply your roll value
- Quick roll buttons for 1, 10, and 20 (instant application)
- Auto-apply option for automatic roll application
- On-screen notifications

FALLBACK OPTIONS:
- Console command interface (works without MCM)
- Graceful degradation if MCM not installed

================================================================================
USAGE - MCM INTERFACE (RECOMMENDED)
================================================================================

SETUP:
1. Press ESC in-game
2. Select "Mod Configuration Menu"
3. Find "Physical Dice Mod"

DURING COMBAT:
1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. OPTION A - Slider: Set slider to 15, then CLICK the Apply button
4. OPTION B - Quick Roll: CLICK the "1", "10", or "20" button
5. OPTION C - Auto-Apply: Enable "Auto-Apply on Your Turn", set value
   before your turn
6. Make your attack - the roll will be EXACTLY 15

NOTE: Hotkeys (F9/F10) are currently non-functional. Use the buttons!

================================================================================
USAGE - CONSOLE COMMANDS (FALLBACK)
================================================================================

If you don't have MCM installed:

1. Your turn starts
2. Roll your physical d20 (e.g., you roll a 15)
3. Press F3 to open console
4. Type: !setroll 15
5. Boost applies INSTANTLY
6. Make your attack - the roll will be EXACTLY 15

COMMANDS:
- !setroll <1-20>  - Set your physical dice roll
- !checkroll       - Check current boost status
- !clearroll       - Clear boost/queued value
- !r <1-20>        - Shorthand for !setroll

================================================================================
HOW IT WORKS
================================================================================

The mod uses BG3's MinimumRollResult and MaximumRollResult boost system
to lock dice rolls to exact values:

MinimumRollResult(Attack,15) + MaximumRollResult(Attack,15) = Exactly 15

CONFIRMED WORKING:
- Attack rolls (tested and verified)

THEORETICALLY SUPPORTED (NOT TESTED):
- Saving throws (boost applied, not confirmed)
- Skill checks (boost applied, not confirmed)
- Ability checks (boost applied, not confirmed)

================================================================================
KNOWN LIMITATIONS
================================================================================

- Only attack rolls have been tested and confirmed working
- Saving throws, skill checks, and ability checks have boost code but are
  unverified in actual gameplay
- Damage rolls are NOT affected (only d20 rolls)
- Hotkeys (F9/F10) do NOT work - use the clickable buttons instead
- Client-side attack rolls may have slight delays

================================================================================
TECHNICAL DETAILS
================================================================================

- Boost Application: Instant when command is used during your turn,
  queued otherwise
- Boost Removal: Automatic after first attack (one-shot mode) or at turn end
- Player Detection: Uses Osi.IsPartyMember() to identify party members
- Turn Tracking: Monitors TurnStarted and TurnEnded Osiris events

================================================================================
FUTURE PLANS
================================================================================

- [ ] Working hotkey support (F9/F10 currently non-functional)
- [ ] Damage roll support
- [ ] Roll history tracking
- [ ] ImGui UI (if BG3SE v30+ becomes standard)

================================================================================
RECOMMENDED MODS
================================================================================

- Mod Configuration Menu (MCM)
  https://github.com/AtilioA/BG3-MCM
  Essential for the best experience with this mod. Provides in-game UI
  with slider and buttons for easy roll input.

================================================================================
TROUBLESHOOTING
================================================================================

MOD DOESN'T APPEAR IN-GAME:
- Check file is at: %LocalAppData%\Larian Studios\Baldur's Gate 3\Mods\
- Check extension is .pak not .pak.pak
- Restart BG3 completely (close and relaunch)
- Verify Script Extender v29+ is installed and game launches with SE

ROLLS NOT WORKING:
- Make sure you're in combat
- Try using console command: !setroll 15
- Check Script Extender console (F3) for errors
- Verify it's YOUR turn (boost applies to current character only)

BUTTONS NOT CLICKABLE:
- Make sure MCM is installed (v1.39.0+)
- Check if MCM menu appears (ESC -> Mod Configuration Menu)
- Try console commands as fallback: !setroll <value>

================================================================================
SUPPORT
================================================================================

Having issues? Please report them at:
https://github.com/delastone1-gif/BG3-Manual-Dice-Roll/issues

Include:
- Your BG3 version
- Script Extender version
- MCM version (if applicable)
- Description of the problem
- Any error messages from the Script Extender console (F3)

================================================================================
CREDITS
================================================================================

Script Extender: Norbyte
  https://github.com/Norbyte/bg3se

Boost System Discovery: Serofix's BG3 Cheat Table

MCM Framework: AtilioA
  https://github.com/AtilioA/BG3-MCM

================================================================================
VERSION HISTORY
================================================================================

v1.1.0 (Current - MCM Integration)
- Added MCM (Mod Configuration Menu) integration
- In-game UI with slider control (1-20)
- Clickable Apply button to apply roll values
- Quick roll buttons (1, 10, 20) with instant application
- Auto-apply option for automatic roll application
- On-screen notifications
- Hotkey configuration UI (for future implementation)
- Console commands still work as fallback
- Graceful degradation if MCM not installed

v1.0.0 (Stable)
- Initial release
- Console command interface
- Exact roll locking with Min+Max boosts
- Instant application system
- One-shot mode
- Party member support

================================================================================
LICENSE
================================================================================

MIT License - Free to use and modify.

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

================================================================================
THANK YOU FOR USING PHYSICAL DICE MOD!
================================================================================

Enjoy bringing your tabletop dice into Baldur's Gate 3!

For more information, updates, and the latest version:
https://github.com/delastone1-gif/BG3-Manual-Dice-Roll
