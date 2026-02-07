------------------------------------------------
-- author:
-- Date: 2021-03-05
-- File: RoleVEquipTool.lua
-- Module: RoleVEquipTool
-- Description: Character visual equipment tool -- corresponding CS.Thousandto.Code.Logic.RoleVEquipTool
------------------------------------------------
local FPlayerAnimRelation = CS.Thousandto.Code.Logic.FPlayerAnimRelation;

local RoleVEquipTool = {}
local self = RoleVEquipTool;
       
-- Get the body model ID of the protagonist's current equipment
function RoleVEquipTool.GetLPBodyModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        if(_lp.FashionBodyID > 0)then       
            return self.GetFashionBodyModelID(_lp.IntOcc, _lp.FashionBodyID);
        end
        return self.GetLingTiBodyID(_lp.IntOcc, _lp.LingTiDegree);
    end
    return 0;
end

-- Get the weapon model ID of the protagonist's current equipment
function RoleVEquipTool.GetLPWeaponModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        return self.GetFashionWeaponModelID(_lp.IntOcc, _lp.FashionWeaponID);
    end
    return 0;
end
-- Get the halo of the protagonist's current equipment
function RoleVEquipTool.GetLPHaloModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        return self.GetFashionHaloModelID(_lp.FashionHaloID);
    end
    return 0;
end

-- Obtain the magic array of the protagonist's current equipment
function RoleVEquipTool.GetLPMatrixModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        return self.GetFashionMatrixModelID(_lp.FashionMatrixID);
    end
    return 0;
end

-- Get the wing model ID of the protagonist's current equipment
function RoleVEquipTool.GetLPWingModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        return self.GetFashionModelID(_lp.IntOcc, _lp.WingID);
    end
    return 0;
end


-- Get the protagonist's current soul armor model
function RoleVEquipTool.GetLPSoulEquipModel()   
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        local _vi = GameCenter.PlayerVisualSystem:GetVisualInfo(_lp.ID);
        if _vi  then
            return _vi.SoulEquipID;    
        end
    end
    return 0;
end

-- Get the protagonist's current flying sword model
function RoleVEquipTool.GetLPFlySwordModel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if  _lp then   
        return self.GetFlySwordModelID(_lp.CurStateLevel);
    end
    return 0;
end

-- Get the model of an empty body
function RoleVEquipTool.GetNullBodyModel(occInt)

    if occInt == Occupation.XianJian then
        return 3099999;
    elseif occInt == Occupation.MoQiang then
        return 3199999
    elseif occInt == Occupation.DiZang then
        return 3299999
    elseif occInt == Occupation.LuoCha then
        return 3399999
    end
    return 0;
end
-- Obtain the body ID of the spirit body
function RoleVEquipTool.GetLingTiBodyID(occInt,  degree)

    local _cfg = DataConfig.DataEquipCollectionModel[occInt * 100 + degree];
    if _cfg then
        return _cfg.Model;
    else
        if occInt == Occupation.XianJian then
            return 10102000;
        elseif occInt == Occupation.MoQiang then
            return 10112000
        elseif occInt == Occupation.DiZang then
            return 10122000
        elseif occInt == Occupation.LuoCha then
            return 10112010
        end
    end
    return 0;
end

-- Obtain the fashion model ID, which is determined by the fashion configuration
function RoleVEquipTool.GetFashionModelID(occInt,  cfgId)
    local _cfg = DataConfig.DataFashionTotal[cfgId];
    if  _cfg then   
        local _cs = {';','_'}
        local _attrs = Utils.SplitStrByTableS(_cfg.Res,_cs)
        local _occint = occInt;
        for i=1,#_attrs do
            local _occRes = _attrs[i]
            if _occRes[1] == _occint then
                return _occRes[2]
            end
        end
    end
    return 0;
end

-- Get Fashion Wings Model ID
function RoleVEquipTool.GetFashionWingModelID(occInt,  cfgId)
    local _result = self.GetFashionModelID(occInt, cfgId);
    return _result;
end

-- Get Fashion Body Model ID
function RoleVEquipTool.GetFashionBodyModelID( occInt,  cfgId)
    local _result = self.GetFashionModelID(occInt, cfgId);
    if(_result <= 0)then   
        if occInt == Occupation.XianJian then
            _result = 10102000;
        elseif occInt == Occupation.MoQiang then
            _result = 10112000
        elseif occInt == Occupation.DiZang then
            _result = 10122000
        elseif occInt == Occupation.LuoCha then
            _result = 10112010
        end    
    end
    return _result;
end
-- Get the Weapon Model ID
function RoleVEquipTool.GetFashionWeaponModelID( occInt,  cfgId)
    local _result = self.GetFashionModelID(occInt, cfgId);
    if (_result <= 0)then   
        if occInt == Occupation.XianJian then
            _result = 10101000;
        elseif occInt == Occupation.MoQiang then
            _result = 10111000
        elseif occInt == Occupation.DiZang then
            _result = 10121000
        elseif occInt == Occupation.LuoCha then
            _result = 10112020
        end   
        
        _result = 0;
    end
    return _result;
end
-- Get the Fashion Halo Model ID
function RoleVEquipTool.GetFashionHaloModelID( cfgId)
    local _cfg = DataConfig.DataEquip[cfgId];
    if  _cfg then
        return _cfg.ModelId;
    end
    return 0;
end
-- Get the fashion array model ID
function RoleVEquipTool.GetFashionMatrixModelID( cfgId)
    local _cfg = DataConfig.DataEquip[cfgId];
    if  _cfg then
        return _cfg.ModelId;
    end
    return 0;
end
-- Get the Soul Armor Model ID
function RoleVEquipTool.GetSoulEquipModelID( cfgId)
    local _cfg = DataConfig.DataSoulArmorBreach[cfgId];
    if  _cfg then
        return _cfg.Model;
    end
    return 0;
end
-- Get the flying sword model ID
function RoleVEquipTool.GetFlySwordModelID( stateLevel)
    local _cfg = DataConfig.DataStatePower[stateLevel];
    if _cfg then   
        return _cfg.FlySwordModele;
    end
    return 0;
end

-- Refresh skin's model data
function RoleVEquipTool.RefreshPlayerSkinModel(skin, occInt, info, anims)    
    if anims == nil then
        anims = FPlayerAnimRelation.LoginAnims;
    end
    skin:SetSkinPartFromCfgID(FSkinPartCode.Body, info:GetBodyModelID(occInt), anims);
    skin:SetSkinPartFromCfgID(FSkinPartCode.GodWeaponHead, info:GetFashionWeaponModelID(occInt), anims);
    skin:SetSkinPartFromCfgID(FSkinPartCode.XianjiaHuan, info:GetFashionHaloModelID());
    skin:SetSkinPartFromCfgID(FSkinPartCode.XianjiaZhen, info:GetFashionMatrixModelID());
    skin:SetSkinPartFromCfgID(FSkinPartCode.Wing, info:GetFashionWingModelID(occInt));
end

-- Refresh player's model data
function RoleVEquipTool.RefreshPlayerModel(player,info)
    local _visualInfo = player.VisualInfo;
    local _occ = player.IntOcc
    player:EquipWithType(FSkinPartCode.Body, _visualInfo:GetBodyModelID(_occ));
    player:EquipWithType(FSkinPartCode.GodWeaponHead, _visualInfo:GetFashionWeaponModelID(_occ));
    player:EquipWithType(FSkinPartCode.XianjiaHuan, _visualInfo:GetFashionHaloModelID());
    player:EquipWithType(FSkinPartCode.XianjiaZhen, _visualInfo:GetFashionMatrixModelID());
    player:EquipWithType(FSkinPartCode.Wing, _visualInfo:GetFashionWingModelID(_occ));
end

return RoleVEquipTool