------------------------------------------------
-- author:
-- Date: 2021-03-05
-- File: FSkinPartCode.lua
-- Module: FSkinPartCode
-- Description: Skin part code
------------------------------------------------

local FSkinPartCode = {
    Mount = 0,          -- Mount
    Body = 1,           -- Subject model
    GodWeaponHead = 2,  -- The head of the magic weapon is the sharp section
    GodWeaponBody = 3,  -- The body of the divine weapon is the section that is held in your hand
    GodWeaponVfx = 4,   -- Special effects of magic weapons
    Wing = 5,           -- wing
    Reserved_1 = 6,
    Reserved_2 = 7,
    Reserved_3 = 8,
    Reserved_4 = 9,
    LastModel = 10,

    -- All models above this support Shader changes,
    -- No modifications are made below
    StrengthenVfx = 11,  -- Strengthen special effects
    HeadPromptVfx = 12,  -- Overhead tips
    SelectedVfx = 13,    -- Selected effects
    SealVfx = 14,        -- Special effects of seal display
    TransVfx = 15,       -- Special effects for job transfer
    XianjiaHuan = 16,    -- Immortal Armor Halo
    XianjiaZhen = 17,    -- Immortal Armor Formation
    MaxCount = 30,
}

return FSkinPartCode