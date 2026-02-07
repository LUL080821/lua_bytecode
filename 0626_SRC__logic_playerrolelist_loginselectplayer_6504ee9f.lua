------------------------------------------------
-- Author:
-- Date: 2021-02-24
-- File: LoginSelectPlayer.lua
-- Module: LoginSelectPlayer
-- Description: Log in to the selected player
------------------------------------------------
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType


local LoginSelectPlayer = {
    -- Player ID
    PlayerID = nil,
    -- Player RoleInfo
    PlayerInfo = nil,
    -- Player's appearance display
    RoleSkin = nil,
    -- The player's parent node
    ParentTrans = nil,
}

function LoginSelectPlayer:New(playerInfo, parentTrans)
    local _m = Utils.DeepCopy(self)
    _m.PlayerID = playerInfo.RoleId;
    _m.PlayerInfo = playerInfo;
    _m.ParentTrans = parentTrans;
    return _m
end

function LoginSelectPlayer:IsShow()
    if self.RoleSkin then            
        return self.RoleSkin:IsActive();
    end
    return false;
end

function LoginSelectPlayer:ShowPlayer()
    self.RoleSkin = self.PlayerInfo:RefreshSkinModel(self.RoleSkin);
    self.RoleSkin:SetActive(true);
    self.RoleSkin:SetLayer(LayerUtils.RemotePlayer, true);
    self.RoleSkin:SetParent(self.ParentTrans);
    self.RoleSkin:SetLocalEulerAngles(Vector3.zero);
    self.RoleSkin:SetLocalPosition(Vector3.zero);
    self.RoleSkin:SetLocalScale(Vector3.one);
    self.RoleSkin:PlayAnim("login_idle", AnimationPartType.AllBody, WrapMode.Loop);
    self.RoleSkin:SetDefaultAnim("login_idle", AnimationPartType.AllBody);
    self.RoleSkin:SetBreastJiggly(true);
    self.RoleSkin:SetClothEnable(true);
end

-- Hide this character
function LoginSelectPlayer:HidePlayer()
    if self:IsShow() then
        self.RoleSkin:SetActive(false);
    end
end

-- Increase the rotation value
function LoginSelectPlayer:AddRotY(dtRotY)

    if (self.RoleSkin == nil or dtRotY == 0) then
        return;
    end

    local _curLocalEuler = self.RoleSkin:GetLocalEulerAngles();
    _curLocalEuler.y = _curLocalEuler.y + dtRotY;
    self.RoleSkin:SetLocalEulerAngles(_curLocalEuler);
end

-- Free up resources
function LoginSelectPlayer:Destroy()
    self.PlayerInfo = null;
    if (self.RoleSkin)then
        self.RoleSkin:Destroy();
        self.RoleSkin = nil;
    end
end

function LoginSelectPlayer:Update(dt)    
    if self:IsShow() then        
        self.RoleSkin:Update(dt);
    end
end

return LoginSelectPlayer;
