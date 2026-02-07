------------------------------------------------
-- author:
-- Date: 2021-03-05
-- File: PlayerVisualInfo.lua
-- Module: PlayerVisualInfo
-- Description: Information displayed by the player
------------------------------------------------

local PlayerVisualInfo = {
    -- Body
    FashionBodyID = 0,
    -- arms
    FashionWeaponID = 0,
    -- Fashion Halo
    FashionHaloID = 0,
    -- Fashion array
    FashionMatrixID = 0,
    -- wing
    WingId = 0,
    -- Spiritual body
    LingTiDegree = 0,
    -- Realm level (UI-specific)
    StateLevel = 0,
    -- Soul Armor
    SoulEquipID = 0,

    -- The last refreshed frame
    LastRefreshFrame = 0,
}

-- Constructor
function PlayerVisualInfo:New(...)
    local _m = Utils.DeepCopy(self)  
    return _m
end

-- Constructed through protocol
-- <param name="info">MSG_Common.FacadeAttribute</param>
-- <param name="stateLevel">int</param>
function PlayerVisualInfo:Parse(info, stateLevel)
    if self.LastRefreshFrame == Time.GetFrameCount() then
        return;
    end
    self.LastRefreshFrame = Time.GetFrameCount();
    self.FashionBodyID = info.fashionBody;
    self.FashionWeaponID = info.fashionWeapon;
    self.FashionHaloID = info.fashionHalo;
    self.FashionMatrixID = info.fashionMatrix;
    self.WingId = info.wingId;
    self.LingTiDegree = info.spiritId;
    self.StateLevel = stateLevel;
    self.SoulEquipID = info.soulArmorId;
end

-- Constructed through the lua protocol
-- <param name="info">LuaTable</param>
-- <param name="stateLevel">int</param>
function PlayerVisualInfo:ParseByLua(info, stateLevel)
    self.LastRefreshFrame = Time.GetFrameCount();
    self.FashionBodyID = info.fashionBody;
    self.FashionWeaponID = info.fashionWeapon;
    self.FashionHaloID = info.fashionHalo;
    self.FashionMatrixID = info.fashionMatrix;
    self.WingId = info.wingId;
    self.LingTiDegree = info.spiritId;
    self.StateLevel = stateLevel;
    self.SoulEquipID = info.soulArmorId;
end

-- Constructed through another object
--<param name="info">PlayerVisualInfo</param>
function PlayerVisualInfo:Copy(info)
    self.FashionBodyID = info.FashionBodyID;
    self.FashionWeaponID = info.FashionWeaponID;
    self.FashionHaloID = info.FashionHaloID;
    self.FashionMatrixID = info.FashionMatrixID;
    self.WingId = info.WingId;
    self.LingTiDegree = info.LingTiDegree;
    self.StateLevel = info.StateLevel;
    self.SoulEquipID = info.SoulEquipID;
end

-- Get the body model ID
function PlayerVisualInfo:GetBodyModelID(intOcc)
    if self.FashionBodyID > 0 then
        return self:GetFashionBodyModelID(intOcc);
    else
        return self:GetLingTiBodyModelID(intOcc);
    end
end

-- Obtain the body ID of the spirit body
function PlayerVisualInfo:GetLingTiBodyModelID(intOcc)
    return RoleVEquipTool.GetLingTiBodyID(intOcc,self.LingTiDegree);
end
-- Obtain the fashion model ID, which is determined by the fashion configuration
function PlayerVisualInfo:GetFashionBodyModelID(intOcc)
    return RoleVEquipTool.GetFashionBodyModelID(intOcc,self.FashionBodyID);
end

-- Get the Weapon ID
function PlayerVisualInfo:GetFashionWeaponModelID(intOcc)
    return RoleVEquipTool.GetFashionWeaponModelID(intOcc,self.FashionWeaponID);
end
-- Get the Fashion Halo Model ID
function PlayerVisualInfo:GetFashionHaloModelID()
    return RoleVEquipTool.GetFashionHaloModelID(self.FashionHaloID);
end
-- Get the fashion array model ID
function PlayerVisualInfo:GetFashionMatrixModelID()
    return RoleVEquipTool.GetFashionMatrixModelID(self.FashionMatrixID);
end
-- Get the Soul Armor Model ID
function PlayerVisualInfo:GetSoulEquipModelID()
    return RoleVEquipTool.GetSoulEquipModelID(self.SoulEquipID);
end
-- Get the flying sword model ID
function PlayerVisualInfo:GetFlySwordModelID()
    return RoleVEquipTool.GetFlySwordModelID(self.StateLevel);
end
-- Get Fashion Wings Model ID
function PlayerVisualInfo:GetFashionWingModelID(intOcc)
    return RoleVEquipTool.GetFashionWingModelID(intOcc, self.WingId);
end


return PlayerVisualInfo