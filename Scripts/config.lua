-- ============================================================
--  Retro Rewind - Employee Mod
--  CONFIGURATION FILE
--
--  Edit this file to customize your staff.
--  Use the exact staff name as shown in-game.
--
--  Available traits:
--    2 = Strong Immune System    3 = Runner
--    4 = Thick-Skinned           5 = Strong Bladder
--    6 = Energetic               7 = Loyal
--    8 = Complaint Handler
--
--  salary        = daily wage in cents (6100 = $61.00)
--  skillCheckout = 0-99  (15=Slow, 40=Average, 74=Good, 99=Fast)
--  skillReturn   = 0-99  (same scale)
--
--  To configure both staff members individually, replace the
--  ["*"] wildcard with two named entries like this:
--
--  return {
--      ["Sarah"] = {
--          traits        = { 2, 3, 7 },
--          salary        = 6100,
--          skillCheckout = 99,
--          skillReturn   = 99,
--      },                        -- <-- comma between entries!
--      ["Anthony"] = {
--          traits        = { 3, 5, 7 },
--          salary        = 6400,
--          skillCheckout = 99,
--          skillReturn   = 99,
--      },                        -- <-- trailing comma is fine in Lua
--  }
--
--  NOTE: The game supports a maximum of 2 staff members.
-- ============================================================

return {

    -- Set to true to see per-field "unchanged" messages in the console.
    Debug = false,

    -- Default: applies to ALL staff members.
    -- Replace with named entries (see example above) for individual configuration.
    ["*"] = {
        traits        = { 2, 3, 4, 5, 6, 7, 8 },
        salary        = 4000,
        skillCheckout = 99,
        skillReturn   = 99,
    },

}