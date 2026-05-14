# Retro Rewind – Employee Mod

Permanently modify your staff's traits, salary, and skill levels.
Changes are written directly into your save file – no need to re-apply after loading.

---

## Requirements

- **UE4SS** must be installed first.
  Follow the installation instructions on the [UE4SS Nexus page](https://www.nexusmods.com/retrorewindvideostoresimulator/mods/52) before proceeding.

---

## Installation

1. Extract the zip file into your game folder:
   ```
   RetroRewind\Binaries\Win64\ue4SS\Mods
   ```
   The correct folder structure is already set up inside the zip — no further steps needed.

---

## Configuration

Open `config.lua` in a text editor and add entries for the staff members you want to modify.
Use the exact name as shown in-game.

### Example

```lua
return {
    ["Sarah"] = {
        traits        = { 2, 3, 7 },
        salary        = 6100,
        skillCheckout = 99,
        skillReturn   = 99,
    },
    ["Anthony"] = {
        traits        = { 3, 5, 7 },
        salary        = 5000,
        skillCheckout = 74,
        skillReturn   = 99,
    },
}
```

> **Do not edit `main.lua`** — all configuration belongs in `config.lua`.

---

## Available Options

### traits
A list of trait IDs to assign. The staff member will have exactly these traits.
Any existing traits are replaced.

| ID | Trait Name           |
|----|----------------------|
| 2  | Strong Immune System |
| 3  | Runner               |
| 4  | Thick-Skinned        |
| 5  | Strong Bladder       |
| 6  | Energetic            |
| 7  | Loyal                |
| 8  | Complaint Handler    |

> IDs 0 and 1 exist in the game's data but are unused and have no visible effect.

### salary
Daily wage in **cents** (not dollars).
Examples:
- `3900` = $39.00 / day
- `6100` = $61.00 / day

### skillCheckout / skillReturn
Skill level for the checkout counter and return station.

| Value | In-game label |
|-------|---------------|
| 15    | Slow          |
| 40    | Average       |
| 74    | Good          |
| 99    | Fast          |

Or use any integer between 0 and 99.
> **Important:** Never use 100 or higher – this causes an overflow in the game.

### Movement speed
Speed is calculated automatically by the game based on skills and traits.
You do not need to set it manually.
The **Runner** trait combined with high skills gives the fastest movement speed.

### Wildcard entry
Use `["*"]` to apply settings to all staff members who don't have their own entry:
```lua
["*"] = {
    traits = { 7 },   -- everyone gets Loyal
},
```

---

## How to Apply Changes

Edit `config.lua` and save the file, then launch the game and load your save.
Changes are applied automatically — there are two ways this happens:

**Option 1 – Play normally:**
Simply open and close your store. The mod applies your config automatically
when the day ends and the game saves.

**Option 2 – Time clock:**
Save the game manually using the time clock in-game, then return to the
main menu and reload your save. This is necessary because the time clock
save requires a fresh load to reflect the changes in-game.

> Once applied, your changes are stored natively in the save file and will
> persist even if you disable the mod.

---

## Uninstalling

Simply delete the `Employee Mod` folder from your `Mods` directory.
Any changes already written to your save file will remain, but no new changes will be applied.
To revert a staff member to their original values, you would need to restore a backup save.

> **Tip:** Always keep a backup of your save file before making changes.
> Your save files are located at:
> `%LOCALAPPDATA%\RetroRewind\Saved\SaveGames\`

---

## Changelog

**v1.2**
- Config is now applied on every save, fixing an issue where changes would not
  persist after reloading from the menu without a full game restart
- Removed development keybinds (F4/F5/F6/F7) — these were not intended for end users

**v1.1.2**
- Fixed an issue where the mod would not apply changes correctly after a menu reload

**v1.1**
- Initial public release

---

## Technical Notes (for curious modders)

This mod works by hooking into the `Save Game Step - Ai Director` function of the
game's `Core_Gamemode` Blueprint. This function is called just before the AiDirector
data (which includes all staff) is written into the `USaveGame_VHS_C` object in memory.
By modifying the data at this exact point, changes are written natively to the `.sav`
file without any external tools or save file editing.

The hook is registered via `NotifyOnNewObject` on the Gamemode class, because Blueprint
functions cannot be hooked directly at mod startup (the class is not yet loaded).
