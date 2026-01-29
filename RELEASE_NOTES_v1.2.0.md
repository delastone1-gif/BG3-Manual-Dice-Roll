# Physical Dice Mod v1.2.0 - Release Notes

**Release Date:** January 29, 2026
**Build:** PhysicalDiceMod.pak (26.54 KB)

## 🎉 Major Feature: Damage Roll Support

v1.2.0 introduces a game-changing feature - **damage roll input**! Now you can use your physical dice for both attack rolls AND damage rolls.

## What's New

### Damage Roll System

**New Damage Tab in MCM:**
- Damage slider (1-80 range)
- Apply Damage button
- Quick damage buttons: 10, 40, 80

**Console Commands:**
- `!setdamage <1-80>` - Set damage value
- `!cleardamage` - Clear damage boost

**API Extensions:**
- `_G.PhysicalDice.SetDamage(value)` - Apply damage boost
- `_G.PhysicalDice.ClearDamage()` - Remove damage boost
- Updated `GetStatus()` with damage boost information

### Independent Boost System

Attack and damage boosts are completely independent:
- Set d20 attack roll: 20
- Set damage roll: 50
- Both active simultaneously
- Each removes after first use (one-shot mode)

### Critical Discovery: Built-In Anti-Cheat

During testing, we discovered BG3 has **built-in damage caps** that prevent cheating:

**Examples:**
- Set damage to 80 for **Fireball** (8d6) → Caps at 48 (max 8d6)
- Set damage to 80 for **Magic Missile** (1d4+1) → Caps at 5 per missile
- Set damage to 80 for **Longsword** (1d8+5) → Caps at weapon max + modifier

**This is perfect behavior:**
- ✅ No cheating possible
- ✅ Respects game balance
- ✅ Useful for matching physical dice rolls
- ✅ Anti-exploit protection

## Use Cases

### 1. Weapon Attack (Attack + Damage)
```
Physical dice: d20 = 18, 1d8+5 = 11
MCM Controls tab: Set 18, click Apply
MCM Damage tab: Set 11, click Apply
In-game: Attack roll = 18, damage = 11 ✅
```

### 2. Damage-Only Spell (Fireball, Acid Splash)
```
Physical dice: 8d6 = 35
MCM Damage tab: Set 35, click Apply
In-game: Cast Fireball → damage = 35 ✅
(No attack roll needed, enemy makes saving throw)
```

### 3. Skill Check or Save (No Damage)
```
Physical dice: d20 = 15
MCM Controls tab: Set 15, click Apply
In-game: Make skill check → roll = 15 ✅
```

## Technical Details

### Boost Implementation

**Attack Boosts (existing):**
```lua
MinimumRollResult(Attack, 15) + MaximumRollResult(Attack, 15) = Exactly 15
```

**Damage Boosts (NEW):**
```lua
MinimumRollResult(Damage, 50) + MaximumRollResult(Damage, 50) = Exactly 50
```

### State Management

Independent tracking:
```lua
-- Attack boost state
local activeBoostString = nil
local activeBoostedCharacters = {}

-- Damage boost state (NEW)
local activeDamageBoostString = nil
local activeDamageBoostedCharacters = {}
```

### One-Shot Removal

The `AttackedBy` event listener handles both boosts independently:
- Attack boost removes after first attack
- Damage boost removes after first damage roll
- Both happen with 100ms delay
- Turn end clears unused boosts

## Breaking Changes

**None!** v1.2.0 is fully backward compatible with v1.1.1.

All existing features work exactly the same:
- Attack roll system unchanged
- MCM Controls tab identical
- Console commands still available
- Hotkey configuration preserved
- Auto-apply option unchanged

## Upgrade Instructions

1. Replace existing `PhysicalDiceMod.pak` with v1.2.0
2. Restart BG3
3. Open MCM → Physical Dice Mod
4. New "Damage" tab should appear
5. Test with a simple attack

No save game issues - fully compatible with existing saves.

## File Changes

### Modified Files
- **PhysicalDiceInput.lua** - Added damage boost system
- **PhysicalDiceMCMClient.lua** - Added damage button callbacks
- **MCM_blueprint.json** - Added Damage tab
- **meta.lsx** - Updated to v1.2.0

### New Features
- Damage boost state variables
- `CreateDamageBoostString()` function
- `ApplyDamageBoost()` function
- Console commands: `!setdamage`, `!cleardamage`
- Network listener for damage commands
- Extended API with damage functions

## Testing Results

### Confirmed Working ✅

- Damage boosts apply correctly
- Game enforces natural damage caps (anti-cheat)
- Independent from attack boosts
- Both boosts active simultaneously
- One-shot removal works
- MCM Damage tab displays correctly
- Apply Damage button functional
- Quick damage buttons work (10, 40, 80)
- Console commands work
- Damage slider range enforced (1-80)
- No conflicts between attack and damage boosts
- Supports damage-only spells (Fireball, Acid Splash)

### Use Cases Validated ✅

1. Weapon Attack - d20 + damage ✅
2. Damage Spell - Damage only ✅
3. Skill Check - d20 only ✅
4. Physical Dice Matching ✅
5. Anti-Cheat - Can't exceed maximums ✅

## Known Limitations

### Damage Caps Enforced

The slider goes to 80, but the game enforces spell/weapon maximums:
- Setting damage to 80 for 1d6 spell → Caps at 6
- Setting damage to 80 for Fireball (8d6) → Caps at 48
- This is **intentional** and prevents cheating

### Damage Type Not Selectable

Boost applies to total damage, not specific types:
- Can't separately set Fire, Cold, Force damage
- Damage boost uses spell's natural type
- Multi-type damage uses default distribution

### Turn End Behavior

Like attack boosts, damage boosts clear at turn end:
- If you don't attack, boost is wasted
- Re-apply on next turn if needed
- Prevents accidental carryover

## Commands Reference

### New Commands (v1.2.0)

| Command | Description | Example |
|---------|-------------|---------|
| `!setdamage <1-80>` | Set damage roll value | `!setdamage 35` |
| `!cleardamage` | Clear damage boost | `!cleardamage` |

### Existing Commands

| Command | Description | Example |
|---------|-------------|---------|
| `!setroll <1-20>` | Set d20 roll value | `!setroll 15` |
| `!r` | Apply MCM slider value | `!r` |
| `!checkroll` | Check boost status | `!checkroll` |
| `!clearroll` | Clear attack boost | `!clearroll` |

## Installation

1. **Backup your current mod** (optional but recommended)
2. Download `PhysicalDiceMod.pak` from releases
3. Replace existing file in: `%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods\`
4. Restart BG3
5. Test in MCM

## Troubleshooting

**Q: I set damage to 80 but only got 20. Bug?**
A: No, this is the game's anti-cheat. Your spell/weapon max is 20, so it caps there.

**Q: Does damage boost work without attack boost?**
A: Yes! Perfect for spells like Fireball that don't require attack rolls.

**Q: Can I set both d20 and damage simultaneously?**
A: Absolutely! Set attack in Controls tab, damage in Damage tab, then attack.

**Q: Damage boost didn't apply. What happened?**
A: Check Script Extender console (F3) for errors. Ensure boost applied before attacking.

**Q: Boost cleared before I attacked?**
A: Boosts clear at turn end. Re-apply on your next turn if you didn't attack.

## Credits

- **Implementation:** Claude Sonnet 4.5
- **Testing & Discovery:** boris (user)
- **BG3 Script Extender:** Norbyte
- **MCM Framework:** AtilioA/BG3-MCM
- **LSLib/Divine.exe:** Norbyte

## Migration from v1.1.1

### What Stays the Same ✅
- All v1.1.1 features
- Attack roll system
- MCM Controls tab
- Console commands
- Hotkeys
- Auto-apply

### What's New ✨
- Damage tab in MCM
- Damage boost system
- New console commands
- Extended API

## Future Roadmap

Ideas for future versions:
- Per-damage-type boosts (Fire, Cold, Force)
- Multi-attack damage support
- Persistent damage mode
- Damage roll history
- Working hotkeys for damage tab
- Clear All button

## Support

- **Issues:** [GitHub Issues](../../issues)
- **Documentation:** [README.md](README.md)
- **Detailed Guide:** [README_v1.2.0.md](v1.2.0-dev/README_v1.2.0.md)

## License

MIT License - Free to use and modify. See [LICENSE](LICENSE) for details.

---

**Enjoy using physical dice for both attacks AND damage in BG3!** 🎲⚔️💥
