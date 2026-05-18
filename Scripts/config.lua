-- ============================================================
--  Retro Rewind - Employee Mod
--  CONFIGURATION FILE
--
--  Edit this file to customize your staff.
--  Use the exact staff name as shown in-game.
--
--  Traits can be toggled individually below.
--
--  salary        = daily wage in cents (6100 = $61.00)
--  skillCheckout = 0-99  (15=Slow, 40=Average, 74=Good, 99=Fast)
--  skillReturn   = 0-99  (same scale)
--
--  Use "*" as name to apply settings to all staff.
--  To configure staff individually, add a second entry:
--
--  staff = {
--      { name = "Sarah",   salary = 6100, skillCheckout = 99, skillReturn = 99 },
--      { name = "Anthony", salary = 6400, skillCheckout = 99, skillReturn = 99 },
--  },
--
--  NOTE: The game supports a maximum of 2 staff members.
-- ============================================================

return {

    Debug = false,

    -- Trait toggles
    trait_strong_immune     = true,
    trait_runner            = true,
    trait_thick_skinned     = true,
    trait_strong_bladder    = true,
    trait_energetic         = true,
    trait_loyal             = true,
    trait_complaint_handler = true,

    -- Staff settings (max. 2 entries)
    staff = {
        { name = "*", salary = 4000, skillCheckout = 99, skillReturn = 99 },
    },

}
