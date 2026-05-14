# Changelog

## 1.4
- Removed trait session cache (`lastWrittenTraits`) and its reload reset hook — both introduced in 1.3 to work around a UE4SS limitation
- Traits are now always rewritten via `Empty()` + `Add()` on every save; the TSet read API (`Num`, `ForEach`, `Contains`) is non-functional for TSets embedded in FStructs regardless of access path, making read-before-write impossible without external state
- Salary and skills are unaffected — read-before-write remains in place for both, as scalar property reads on FStructs work reliably

## 1.3
- Renamed internal config table from `STAFF_CONFIG` to `CONFIG` for consistency with other mods
- Added `local P = "[EmpMod] "` prefix constant; `log()` now uses it instead of an inline string
- Added `debug(msg)` function controlled by `CONFIG.Debug` in `config.lua`
- Added `safe(label, fn, ...)` helper to replace raw `pcall` constructs throughout; hook registration now uses it
- Read-before-write on salary and skills — changes are only written when the current value differs from config
- Traits use a session cache for comparison as a workaround for the TSet read limitation (superseded in 1.4)
- Improved logging: changed fields and a summary line (`"1 staff updated | 1 unchanged"`) are always shown; `"unchanged"` detail lines and per-staff checking status are only shown when `Debug = true`

## 1.2
- Removed `alreadyApplied` flag — config is now applied on every save, fixing the issue where changes would not persist after reloading from the menu
- Removed debug keybinds (F4/F5/F6/F7) — these were development tools not intended for end users

## 1.1.2
- Fixed misleading log messages — changes are applied to RAM, not directly to the save file; save at the time clock to persist

## 1.1.1
- Fixed packaging for better compatibility

## 1.1
- Separated configuration into `config.lua` for easier editing
- Added default wildcard entry (`["*"]`) so the mod works out of the box without renaming anything
- Fixed potential syntax errors for users editing the config

## 1.0
- Initial release
