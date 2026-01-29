# Physical Dice Mod v1.2.0 - Damage Roll Support

**Version:** 1.2.0-dev
**Date:** January 2026
**Status:** Testing - Not Yet Released

## What's New in v1.2.0

### Major Feature: Damage Roll Input

v1.2.0 adds support for inputting physical damage dice rolls alongside the existing d20 attack roll system. You can now use your physical dice for **both** attack rolls and damage rolls!

### Key Changes

1. **New Damage Tab in MCM**
   - Damage slider (1-80 range)
   - Apply Damage button
   - Quick damage buttons: 10, 40, 80
   - Separate from attack roll controls

2. **Independent Boost System**
   - Attack and damage boosts are completely independent
   - Can set both simultaneously (e.g., d20=20 + damage=50)
   - Each boost auto-removes after first use (one-shot mode)
   - Perfect for weapon attacks (attack roll + damage roll)

3. **Console Commands**
   - `!setdamage <1-80>` - Set damage roll value
   - `!cleardamage` - Clear damage boost
   - Works alongside existing `!setroll` and `!clearroll`

4. **API Additions**
   - `_G.PhysicalDice.SetDamage(value)` - Apply damage boost
   - `_G.PhysicalDice.ClearDamage()` - Remove damage boost
   - Updated `GetStatus()` with damage boost info

## Critical Discovery: Built-In Anti-Cheat

### How Damage Boosts Actually Work

During testing, we discovered that BG3 has **built-in damage caps** that prevent cheating:

**What We Set:**
```lua
MinimumRollResult(Damage, 80)
MaximumRollResult(Damage, 80)
```

**What Actually Happens:**

The game **respects spell/weapon maximum damage limits**, even when you set the boost to 80:

- **Magic Missile** (1d4+1 per missile)
  - Max possible: 5 per missile
  - Set boost to 80 → Still caps at 5 per missile ✅

- **Fireball** (8d6)
  - Max possible: 48 damage
  - Set boost to 80 → Caps at 48 ✅

- **Longsword** (1d8 + STR modifier)
  - Max possible: 8 + modifier
  - Set boost to 80 → Caps at weapon max + modifier ✅

### Why This Is Perfect

✅ **No cheating possible** - Can't exceed spell/weapon maximums
✅ **Respects game balance** - All damage stays within valid ranges
✅ **Useful for physical dice** - Can input your real damage rolls (3d6 = 12, 2d8+5 = 16, etc.)
✅ **Anti-exploit** - Setting impossible values won't break the game

### Example Use Cases

**1. Weapon Attack (Attack + Damage)**
```
Physical dice: d20 = 18, 1d8+5 = 11
MCM Controls tab: Set 18, click Apply
MCM Damage tab: Set 11, click Apply
In-game: Attack roll = 18, damage = 11 ✅
```

**2. Damage-Only Spell (Fireball, Acid Splash)**
```
Physical dice: 8d6 = 35
MCM Damage tab: Set 35, click Apply
In-game: Cast Fireball → damage = 35 ✅
(No attack roll needed, enemy makes saving throw)
```

**3. Skill Check or Save (No Damage)**
```
Physical dice: d20 = 15
MCM Controls tab: Set 15, click Apply
In-game: Make skill check → roll = 15 ✅
```

## Usage Instructions

### Setting Up Damage Rolls

**Option 1: MCM Slider + Apply Button**
1. Open MCM (ESC → Mod Configuration Menu → Physical Dice)
2. Navigate to **Damage** tab
3. Roll your physical damage dice (e.g., 3d6 = 14)
4. Set slider to 14
5. Click **Apply** button
6. Make your attack in-game → damage will match your roll

**Option 2: Quick Damage Buttons**
1. Open MCM → Damage tab
2. Click one of the quick buttons:
   - **10** - Low damage
   - **40** - Average damage (5d8)
   - **80** - Maximum damage (10d8, will cap to spell max)
3. Damage applies immediately

**Option 3: Console Commands**
1. Press F3 (Script Extender console)
2. Type: `!setdamage 35`
3. Damage boost applies instantly

### Combining Attack + Damage

For weapon attacks, set both:

1. **Controls Tab:** Set d20 attack roll (e.g., 17)
2. **Damage Tab:** Set damage roll (e.g., 1d8+3 = 9)
3. Make attack in-game
4. Result: Attack roll = 17, Damage = 9
5. Both boosts auto-remove after attack

## Technical Implementation

### Boost Strings

**Attack Rolls (v1.1.1):**
```lua
"MinimumRollResult(Attack,15);MaximumRollResult(Attack,15);
 MinimumRollResult(RawAbility,15);MaximumRollResult(RawAbility,15);
 MinimumRollResult(SkillCheck,15);MaximumRollResult(SkillCheck,15);
 MinimumRollResult(SavingThrow,15);MaximumRollResult(SavingThrow,15)"
```

**Damage Rolls (v1.2.0 NEW):**
```lua
"MinimumRollResult(Damage,50);MaximumRollResult(Damage,50)"
```

### State Management

**Independent Tracking:**
```lua
-- Attack boost state
local activeBoostString = nil
local activeBoostedCharacters = {}

-- Damage boost state (NEW in v1.2.0)
local activeDamageBoostString = nil
local activeDamageBoostedCharacters = {}
```

Both boosts:
- Apply to ALL party members
- Track separately
- Remove independently (one-shot mode)
- Clear at turn end if unused

### One-Shot Behavior

The `AttackedBy` event listener handles both boosts:

1. Check if attacker has attack boost → Remove after attack
2. Check if attacker has damage boost → Remove after attack
3. Both happen independently with 100ms delay

## Files Modified in v1.2.0

### Server-Side
- **PhysicalDiceInput.lua**
  - Added damage boost state variables
  - Added `CreateDamageBoostString()` function
  - Added `ApplyDamageBoost()` function
  - Added console commands: `!setdamage`, `!cleardamage`
  - Modified `AttackedBy` listener for independent damage boost removal
  - Updated network listener for UI damage commands
  - Extended `_G.PhysicalDice` API

### Client-Side
- **PhysicalDiceMCMClient.lua**
  - Added damage button callbacks
  - Quick damage buttons: 10, 40, 80
  - Apply Damage button handler

### Configuration
- **MCM_blueprint.json**
  - Added "Damage" tab
  - Damage slider (1-80, default 40)
  - Apply Damage button
  - Quick damage buttons with spell icons
  - Updated "About" section to v1.2

### Metadata
- **meta.lsx**
  - Updated Version64 to `36310271995674624` (v1.2.0)
  - Enhanced description to mention damage support

## Testing Results

### ✅ Confirmed Working

- [x] Damage boosts apply correctly
- [x] Game enforces natural damage caps (anti-cheat working)
- [x] Independent from attack boosts
- [x] Both boosts can be active simultaneously
- [x] One-shot removal works for both boosts
- [x] MCM Damage tab displays correctly
- [x] Apply Damage button functional
- [x] Quick damage buttons work (10, 40, 80)
- [x] Console commands work (!setdamage, !cleardamage)
- [x] Damage slider range enforced (1-80)
- [x] No conflicts between attack and damage boosts
- [x] Supports damage-only spells (Fireball, Acid Splash)
- [x] Version updated to 1.2.0

### 🎯 Use Cases Validated

1. **Weapon Attack** - d20 attack + damage roll ✅
2. **Damage Spell** - Damage only, no attack roll ✅
3. **Skill Check** - d20 only, no damage ✅
4. **Physical Dice Matching** - Input real dice results ✅
5. **Anti-Cheat** - Can't exceed spell/weapon maximums ✅

## Known Limitations

### Damage Caps Are Enforced

The slider goes up to 80, but the **game enforces spell/weapon maximum damage**:

- Setting damage to 80 for a 1d6 spell will cap at 6
- Setting damage to 80 for Fireball (8d6) will cap at 48
- This is **intentional behavior** and prevents cheating

### Damage Type Not Selectable

The boost applies to total damage, not specific damage types:

- Can't separately set Fire, Cold, or Force damage
- Damage boost applies to the spell's natural damage type
- Multi-type damage spells use their default distribution

### Turn End Behavior

Like attack boosts, damage boosts clear at turn end:

- If you don't attack, the boost is wasted
- Re-apply damage boost on your next turn if needed
- This prevents accidental carryover between turns

## Commands Reference

### New Commands (v1.2.0)

| Command | Description | Example |
|---------|-------------|---------|
| `!setdamage <1-80>` | Set damage roll value | `!setdamage 35` |
| `!cleardamage` | Clear damage boost | `!cleardamage` |

### Existing Commands (v1.1.1)

| Command | Description | Example |
|---------|-------------|---------|
| `!setroll <1-20>` | Set d20 roll value | `!setroll 15` |
| `!r` | Apply MCM slider value | `!r` |
| `!checkroll` | Check boost status | `!checkroll` |
| `!clearroll` | Clear attack boost | `!clearroll` |

## API Reference

### New Functions (v1.2.0)

```lua
-- Set damage roll (1-80)
_G.PhysicalDice.SetDamage(damageValue)
-- Returns: true on success, false on invalid value

-- Clear damage boost
_G.PhysicalDice.ClearDamage()
-- Returns: true if boost was cleared, false if nothing to clear

-- Get current status (updated)
_G.PhysicalDice.GetStatus()
-- Returns: {
--   hasActiveBoost = boolean,
--   hasActiveDamageBoost = boolean,  -- NEW
--   hasQueuedRoll = boolean,
--   queuedValue = number or nil,
--   activeBoostedCharacters = table,
--   activeDamageBoostedCharacters = table,  -- NEW
--   currentTurnCharacter = string or nil
-- }
```

### Existing Functions (v1.1.1)

```lua
_G.PhysicalDice.SetRoll(rollValue)  -- Set d20 attack roll
_G.PhysicalDice.ClearRoll()         -- Clear attack boost
```

## Build Information

**Build Script:** `build_v1.2.0.ps1`
**Divine.exe Path:** `C:\Users\boris\Downloads\LSLib\Packed\Tools\Divine.exe`
**Output:** `PhysicalDiceMod_v1.2.0-dev.pak`
**Size:** ~26 KB

**Build Command:**
```powershell
cd "c:\Projects\BG3 Manual Dice Roll\v1.2.0-dev"
.\build_v1.2.0.ps1
```

## Migration from v1.1.1

### What Stays the Same

- ✅ All v1.1.1 features still work
- ✅ Attack roll system unchanged
- ✅ MCM Controls tab identical
- ✅ Console commands still available
- ✅ Hotkey configuration preserved
- ✅ Auto-apply option still works

### What's New

- ✨ Damage tab in MCM
- ✨ Damage boost system
- ✨ New console commands
- ✨ Extended API

### Upgrade Process

1. Replace `PhysicalDiceMod.pak` with v1.2.0 build
2. Restart BG3
3. Open MCM → Physical Dice Mod
4. Verify new "Damage" tab appears
5. Test damage boost with simple attack

**No save game issues** - v1.2.0 is fully backward compatible.

## Future Roadmap (Not in v1.2.0)

Ideas for future versions:

- [ ] Per-damage-type boosts (Fire, Cold, Force, etc.)
- [ ] Multi-attack damage support (different values per hit)
- [ ] Persistent damage mode (keep active for multiple attacks)
- [ ] Damage roll history tracking
- [ ] Working hotkeys for damage tab
- [ ] Clear All button (clear both attack and damage)

## Troubleshooting

**Q: I set damage to 80 but only got 20 damage. Bug?**
A: No, this is the game's anti-cheat. Your spell/weapon has a max of 20, so it caps there. This prevents cheating.

**Q: Does damage boost work without attack boost?**
A: Yes! Perfect for spells like Fireball or Acid Splash that don't require attack rolls.

**Q: Can I set both d20 and damage at the same time?**
A: Absolutely! Set attack roll in Controls tab, damage in Damage tab, then attack.

**Q: Damage boost didn't apply. What happened?**
A: Check the Script Extender console (F3) for error messages. Ensure boost was applied before attacking.

**Q: Boost cleared before I attacked?**
A: Boosts clear at turn end. Re-apply on your next turn if you didn't attack.

## Credits

- **Implementation:** Claude Sonnet 4.5
- **Testing:** User (boris)
- **Discovery:** Built-in damage caps found during testing
- **BG3 Script Extender:** Norbyte
- **MCM Framework:** AtilioA/BG3-MCM
- **LSLib/Divine.exe:** Norbyte

## Version History

### v1.2.0-dev (Current - Testing)
- Added damage roll support (1-80 range)
- New Damage tab in MCM
- Quick damage buttons (10, 40, 80)
- Console commands: !setdamage, !cleardamage
- Independent attack and damage boost tracking
- Extended API with damage functions
- Confirmed: Game enforces natural damage caps (anti-cheat)

### v1.1.1 (Latest Stable Release)
- Fixed critical mid-combat save load bug
- Boosts apply immediately after loading saves
- Removed turn-based queuing system

### v1.1.0 (MCM Integration)
- Added MCM integration
- In-game UI with slider control
- Quick roll buttons (1, 10, 20)
- Auto-apply option

### v1.0.0 (Initial Release)
- Console command interface
- Exact d20 roll locking
- One-shot mode
- Party member support

---

**License:** MIT
**Repository:** [BG3 Manual Dice Roll](https://github.com/yourusername/BG3-Manual-Dice-Roll)
**Issues:** Report bugs in GitHub Issues

**Status:** ⚠️ DO NOT RELEASE YET - Still in testing phase
