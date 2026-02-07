------------------------------------------------
-- Author:
-- Date: 2020-11-12
-- File: PlayerRoleInfo.lua
-- Module: PlayerRoleInfo
-- Description: Player character information
------------------------------------------------
local SlotUtils = CS.Thousandto.Core.Asset.SlotUtils
local SlotNameDefine = CS.Thousandto.Core.Asset.SlotNameDefine
local FSkinModelWrap = require("Logic.FGameObject.FSkinModelWrap")


local PlayerRoleInfo = {
        -- Role ID
        RoleId = 0,
        -- name
        Name = nil,
        -- Profession
        Career = 0,
        -- grade
        Level = 0,
        -- Realm level
        StateLevel = 0,
        -- Vip Level
        VipLevel = 0,
        -- Delete time
        DeleteTime = 0,
        -- Creation time
        CreateTime = 0,
        -- Combat power
        PowerValue= 0,
        -- Appearance information
        VisualInfo = nil,
        -- Skin of external light, temporary storage
        Skin = nil,
        -- Skin does not make a change callback
        OnSkinPartChangedHandler = nil,

}

--New 
function PlayerRoleInfo:New()
    local _m = Utils.DeepCopy(self)
    _m.OnSkinPartChangedHandler = Utils.Handler(_m.OnSkinPartChanged, _m, nil, true);
    return _m
end

function PlayerRoleInfo:FillFromServerMsg(msg)
    self.RoleId = msg.roleId;
    self.Name = msg.name;
    self.Career = msg.career;
    self.Level = msg.lv;
    self.StateLevel = msg.stateLv;
    self.DeleteTime = msg.deleteTime;
    self.CreateTime = msg.createTime;
    self.PowerValue = (msg.fight);
    self.VisualInfo = PlayerVisualInfo:New();
    self.VisualInfo:Parse(msg.facade, self.StateLevel);
end

function PlayerRoleInfo:FillFromLocalPlayer(lp)    
    self.RoleId = lp.ID;
    self.Name = lp.Name;
    self.Career = lp.IntOcc;
    self.Level = lp.Level;
    self.VisualInfo = PlayerVisualInfo:New();
    self.VisualInfo:Copy(lp.VisualInfo);
    self.StateLevel = lp.CurStateLevel;
    self.DeleteTime =-1;
    self.CreateTime = 0;
    self.PowerValue =lp.FightPower;
end

-- Refresh the skin model
function PlayerRoleInfo:RefreshSkinModel(skin)
    if skin == nil then        
        self.Skin = FSkinModelWrap:New(FSkinTypeCode.Player);
        self.Skin:SetOnSkinPartChangedHandler(self.OnSkinPartChangedHandler);       
        if self.VisualInfo ~= nil then
            RoleVEquipTool.RefreshPlayerSkinModel(self.Skin, self.Career, self.VisualInfo);
        else
            Debug.LogError("==== self.VisualInfo==nil Print PlayerRoleInfo ====")
            -- Debug.LogTable(self); 
        end         
    else
        self.Skin = skin;
    end
    return self.Skin;
end

-- Changes in the skin area
function PlayerRoleInfo:OnSkinPartChanged(x, y)    
    if (y == FSkinPartCode.GodWeaponHead or y == FSkinPartCode.Body) and self.Skin ~= nil then
        local body = self.Skin:GetSkinPart(FSkinPartCode.Body);
        if (body) then
            body.BrightWeapon = true;
            local weaponModelID = self.Skin:GetSkinPartCfgID(FSkinPartCode.GodWeaponHead);
            local scaleCfg = DataConfig.DataWeaponScale[weaponModelID];
            if (scaleCfg) then
                local reScale = Vector3(scaleCfg.ReceiveScale / 100, scaleCfg.ReceiveScale / 100, scaleCfg.ReceiveScale / 100);
                local brScale = Vector3(scaleCfg.BrightScale / 100, scaleCfg.BrightScale / 100, scaleCfg.BrightScale / 100);                    
                SlotUtils.SetSlotLocalScale(body.RealTransform, SlotNameDefine.RightWeapon, brScale);                        
                SlotUtils.SetSlotLocalScale(body.RealTransform, SlotNameDefine.RightWeaponReceive, reScale);
            else
                SlotUtils.SetSlotLocalScale(body.RealTransform, SlotNameDefine.RightWeapon, Vector3.one);                        
                SlotUtils.SetSlotLocalScale(body.RealTransform, SlotNameDefine.RightWeaponReceive, Vector3.one);
            end
        end
    end
end


return PlayerRoleInfo