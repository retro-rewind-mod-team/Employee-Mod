-- ============================================================
--  Retro Rewind - Employee Mod
--  Version: 1.4
--
--  Modifies staff traits, salary, and skills persistently
--  by writing directly into the SaveGame object before it
--  is written to disk. Fields that already match the config
--  are skipped — the save is only modified when needed.
--
--  HOW IT WORKS:
--  The game holds a USaveGame_VHS_C object in memory.
--  When the player saves (time clock), the game calls a series
--  of "Save Game Step" functions that copy live data into this
--  object before writing it to disk.
--  This mod hooks "Save Game Step - Ai Director" and writes
--  the configured values directly into the SaveGame object,
--  so they are natively stored in the .sav file.
--
--  USAGE:
--  Edit config.lua, load your save, then save the game
--  once via the time clock. Done - changes are now persistent.
-- ============================================================

local CONFIG = require("config")

-- ============================================================
-- INTERNAL
-- ============================================================
local P = "[EmpMod] "

local function log(msg)
    print(P .. msg .. "\n")
end

local function debug(msg)
    if CONFIG.Debug then
        log(msg)
    end
end

local function safe(label, fn, ...)
    local results = {pcall(fn, ...)}
    if not results[1] then
        log(label .. " FAILED: " .. tostring(results[2]))
        return nil
    end
    return table.unpack(results, 2)
end

-- ============================================================
-- CONSTANTS
-- ============================================================
local HIRE_STAFF_KEY = "HireStaff_3_C1D01305485CF593450381BC8B36A666"
local TRAIT_KEY      = "Gameplaytraits_29_044F073B4CAE1F7A9D4C7B9498790768"
local NAME_KEY       = "Name_3_8A98C9844ED44E799022148DD2FEB3FE"
local SALARY_KEY     = "Salaryperday_24_3EA43710410217A934721D8A9C95FC39"
local SKILL_CO       = "SkillCheckout_14_42B673714489E8C35671BCA911793494"
local SKILL_RT       = "SkillReturn_13_7FEF813241BE4F085D076EB3B3004D62"
local TRAIT_MIN      = 0
local TRAIT_MAX      = 8

local TRAIT_NAMES = {
    [0] = "Unused_0",             [1] = "Unused_1",
    [2] = "Strong Immune System", [3] = "Runner",
    [4] = "Thick-Skinned",        [5] = "Strong Bladder",
    [6] = "Energetic",            [7] = "Loyal",
    [8] = "Complaint Handler",
}

-- ============================================================
-- HELPERS
-- ============================================================
local function traitName(id)
    return TRAIT_NAMES[id] or ("Trait_" .. tostring(id))
end

local function getConfig(name)
    if CONFIG[name] then return CONFIG[name] end
    return CONFIG["*"]
end

local function getStaffName(staff)
    local name = "?"
    pcall(function() name = staff[NAME_KEY]:ToString() end)
    return name
end

-- ============================================================
-- CORE: Apply config to SaveGame FStaff struct
--
-- Traits are always rewritten via Empty() + Add() because the
-- TSet read API (Num, ForEach, Contains) is non-functional for
-- TSets embedded in FStructs in the SaveGame context — a known
-- UE4SS limitation confirmed across all reachable access paths
-- (SaveGame, AI_Director_C Staff Hired, AI Employee in World).
-- Empty() + Add() on a 7-element TSet once per save session
-- has no measurable cost, so read-before-write is not needed.
--
-- Salary and skills use read-before-write because scalar
-- property reads on FStructs work reliably.
--
-- Returns true if at least one field was changed.
-- ============================================================
local function applyToSaveGameStaff(staff, config, name)
    local anyChange = false

    -- TRAITS
    -- Always rewrite: TSet read API is non-functional in this context.
    if config.traits then
        local ts = staff[TRAIT_KEY]
        if ts then
            local wantedIds = {}
            for _, id in ipairs(config.traits) do
                if type(id) == "number" and id >= TRAIT_MIN and id <= TRAIT_MAX then
                    table.insert(wantedIds, id)
                end
            end

            pcall(function() ts:Empty() end)
            local names = {}
            for _, id in ipairs(wantedIds) do
                pcall(function() ts:Add(id) end)
                table.insert(names, traitName(id))
            end
            log("  " .. name .. " traits: {" .. table.concat(names, ", ") .. "}")
            anyChange = true
        end
    end

    -- SALARY
    if config.salary then
        local current = nil
        pcall(function() current = staff[SALARY_KEY] end)
        if current ~= config.salary then
            local ok, err = pcall(function() staff[SALARY_KEY] = config.salary end)
            log("  " .. name .. " salary: $" .. string.format("%.2f", config.salary / 100) ..
                " ok=" .. tostring(ok) .. (ok and "" or " | " .. tostring(err)))
            anyChange = true
        else
            debug("  " .. name .. " salary: unchanged")
        end
    end

    -- SKILL CHECKOUT (clamped to 0-99)
    if config.skillCheckout then
        local val = math.min(99, math.max(0, config.skillCheckout))
        local current = nil
        pcall(function() current = staff[SKILL_CO] end)
        if current ~= val then
            local ok = pcall(function() staff[SKILL_CO] = val end)
            log("  " .. name .. " skillCheckout: " .. val .. " ok=" .. tostring(ok))
            anyChange = true
        else
            debug("  " .. name .. " skillCheckout: unchanged")
        end
    end

    -- SKILL RETURN (clamped to 0-99)
    if config.skillReturn then
        local val = math.min(99, math.max(0, config.skillReturn))
        local current = nil
        pcall(function() current = staff[SKILL_RT] end)
        if current ~= val then
            local ok = pcall(function() staff[SKILL_RT] = val end)
            log("  " .. name .. " skillReturn: " .. val .. " ok=" .. tostring(ok))
            anyChange = true
        else
            debug("  " .. name .. " skillReturn: unchanged")
        end
    end

    return anyChange
end

-- ============================================================
-- CORE: Save Game Step - Ai Director hook
--
-- Fires just before the AiDirector data (including all staff)
-- is written into the SaveGame object. Fields that already
-- match the config are skipped so the save is not modified
-- unnecessarily (except traits — see applyToSaveGameStaff).
-- ============================================================
local function onAiDirectorSave(self)
    pcall(function()
        local gm        = self:get()
        local hireStaff = gm["Save Game VHS"]["AiDirector"][HIRE_STAFF_KEY]

        local totalChanged = 0
        local totalSkipped = 0

        hireStaff:ForEach(function(idx, elem)
            pcall(function()
                local staff  = elem:get()
                local name   = getStaffName(staff)
                local config = getConfig(name)

                if not config then
                    debug("No config entry for: " .. name .. " -- skipping")
                    return
                end

                debug("Checking: " .. name)
                local changed = applyToSaveGameStaff(staff, config, name)

                if changed then
                    totalChanged = totalChanged + 1
                else
                    totalSkipped = totalSkipped + 1
                end
            end)
        end)

        if totalChanged > 0 then
            log("Done -- " .. totalChanged .. " staff updated" ..
                (totalSkipped > 0 and " | " .. totalSkipped .. " unchanged" or ""))
        else
            debug("Done -- all staff already match config, save not modified")
        end
    end)
end

-- ============================================================
-- HOOK REGISTRATION
-- (Direct RegisterHook at startup fails because the Gamemode
--  Blueprint class is not yet loaded when the mod initialises.)
-- ============================================================
local hookRegistered = false

NotifyOnNewObject(
    "/Game/VideoStore/core/gamemode/Core_Gamemode.Core_Gamemode_C",
    function(obj)
        if hookRegistered then return end
        hookRegistered = true

        ExecuteWithDelay(500, function()
            local ok = safe("Save Game Step - Ai Director hook", function()
                RegisterHook(
                    "/Game/VideoStore/core/gamemode/Core_Gamemode.Core_Gamemode_C:Save Game Step - Ai Director",
                    onAiDirectorSave
                )
                return true
            end)
            if ok then
                log("Save hook active - config will be applied on next save")
            end
        end)
    end
)

-- ============================================================
log("Employee Mod loaded.")
log("Edit config.lua, load your save, then save once via the time clock.")
