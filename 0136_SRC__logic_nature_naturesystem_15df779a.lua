-- Author: 
-- Date: 2019-04-17
-- File: NatureSystem.lua
-- Module: NatureSystem
-- Description: General data for Creation Panel
------------------------------------------------
-- Quote

local WingsData = require "Logic.Nature.NatureWingsData"
local WeaponData = require "Logic.Nature.NatureWeaponData"
local MountData = require "Logic.Nature.NatureMountData"
local L_FabaoData = require "Logic.Nature.NatureFabaoData"
local L_FlySwordData = require "Logic.Nature.NatureFlySwordData"
local L_PetData = require "Logic.Nature.NaturePetData"

local NatureSystem = {
    NatureDrugDir = nil,-- All data of the drug configuration table k is the system type
    NatureDrugItemMax = nil,-- How many items are upgraded to each system?
    NatureWingsData = nil, -- Wings data
    NatureWeaponData = nil ,-- Divine Soldier Data
    NatureMountData = nil ,-- Mount data
    NatureFaBaoData = nil, -- Magic weapon data
    NatureFlySwordData = nil, -- Flying sword
    NaturePetData = nil, -- pet
}


function NatureSystem:Initialize()
    self.NatureDrugDir = Dictionary:New()
    self.NatureDrugItemMax = Dictionary:New()
    self.NatureWingsData = WingsData:New()
    self.NatureWingsData:Initialize()
    self.NatureMountData = MountData:New()
    self.NatureMountData:Initialize()
    self.NatureFaBaoData = L_FabaoData:New()
    self.NatureFaBaoData:Initialize()
    self.NatureFlySwordData = L_FlySwordData:New()
    self.NatureFlySwordData:Initialize()
    self.NaturePetData = L_PetData:New()
    self.NaturePetData:Initialize()
    self.NatureWeaponData = WeaponData:New()
    self.NatureWeaponData:Initialize()
end

function NatureSystem:UnInitialize()
    self.NatureWingsData:UnInitialize()
    self.NatureWingsData = nil
    if self.NatureWeaponData then
        self.NatureWeaponData:UnInitialize()
        self.NatureWeaponData = nil
    end
    self.NatureMountData:UnInitialize()
    self.NatureMountData = nil
    self.NatureFaBaoData:UnInitialize()
    self.NatureFaBaoData = nil
    self.NatureFlySwordData:UnInitialize()
    self.NatureFlySwordData = nil
    self.NaturePetData:UnInitialize()
    self.NaturePetData = nil
end

-- Initialize the configuration table
function NatureSystem:InitConfig()
    -- Initialize the information on eating fruits
    if self.NatureDrugDir == nil then
        self.NatureDrugDir = Dictionary:New()
    end
    if #self.NatureDrugDir > 0 then
        return
    end
    DataConfig.DataNatureAtt:Foreach(function(k, v)
        if not self.NatureDrugDir:ContainsKey(v.Type) then
            if v.Level == 0 then          
                local _list = List:New()
                _list:Add(v)
                self.NatureDrugDir:Add(v.Type, _list)
            end
        else
            if v.Level == 0 then       
                self.NatureDrugDir[v.Type]:Add(v)
            end
        end
        if not self.NatureDrugItemMax:ContainsKey(v.Type) then
            local _dic = Dictionary:New()
            _dic:Add(v.ItemId,v.Level)
            self.NatureDrugItemMax:Add(v.Type,_dic)
        else
            if self.NatureDrugItemMax[v.Type]:ContainsKey(v.ItemId) then
                if self.NatureDrugItemMax[v.Type][v.ItemId] < v.Level  then
                    self.NatureDrugItemMax[v.Type][v.ItemId] = v.Level
                end
            else
                self.NatureDrugItemMax[v.Type]:Add(v.ItemId,v.Level)
            end
        end
    end)
    for k, v in pairs(self.NatureDrugDir) do
        v:Sort(
                function(a,b)
                    return tonumber(a.Position) < tonumber(b.Position)
                end
            )
    end
end 

-- Get the maximum level of a single medicine by type and prop ID
function NatureSystem:GetDrugItemMax(type,item)
    local _maxlv = 0
    self:InitConfig()
    if self.NatureDrugItemMax:ContainsKey(type) then
        if self.NatureDrugItemMax[type]:ContainsKey(item) then
            _maxlv = self.NatureDrugItemMax[type][item]
        end
    end
    return _maxlv
end

-- Accept the return to the creation panel information
function NatureSystem:ResNatureInfo(msg)
    if msg.natureType == NatureEnum.Mount then -- Mount data
        self.NatureMountData:InitWingInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_INIT)
    elseif msg.natureType == NatureEnum.Wing then -- Wings data
        self.NatureWingsData:InitWingInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_INIT)
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        self.NatureWeaponData:InitWingInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WEAPON_INIT)
    elseif msg.natureType == NatureEnum.FaBao then -- Magic weapon data
        self.NatureFaBaoData:InitWingInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WEAPON_INIT)
    elseif msg.natureType == NatureEnum.Pet then
        self.NaturePetData:InitWingInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM)
    end
end

function NatureSystem:ResOnlineInitHuaxin(msg)
    self.NatureFlySwordData:InitWingInfo(msg)
end
function NatureSystem:ResUseHuxinResult(msg)
    self.NatureFlySwordData:UpDateFashionInfo(msg)
end

-- Return to upgrade using items
function NatureSystem:ResNatureUpLevel(msg)
    if msg.natureType == NatureEnum.Mount then -- Mount data
        local _oldlevel = self.NatureMountData.super.Level
        self.NatureMountData:UpDateUpLevel(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPLEVEL,_oldlevel)
    elseif msg.natureType ==NatureEnum.Wing then -- Wings data
        local _oldlevel = self.NatureWingsData.super.Level
        self.NatureWingsData:UpDateUpLevel(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPLEVEL,_oldlevel)
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        local _oldlevel = self.NatureWeaponData.super.Level
        self.NatureWeaponData:UpDateUpLevel(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WEAPON_UPLEVEL,_oldlevel)
    end
end

-- Change of combat power
function NatureSystem:ResPowerChange(msg)
    if msg.natureType == NatureEnum.Mount then -- Mount data
        self.NatureMountData.super.Fight = msg.fight
    elseif msg.natureType ==NatureEnum.Wing then -- Wings data
        self.NatureWingsData.super.Fight = msg.fight
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        self.NatureWeaponData.super.Fight = msg.fight
    elseif msg.natureType == NatureEnum.Pet then -- Divine Soldier Data
        self.NaturePetData.super.Fight = msg.fight
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION)
end

-- Return to set the model
function NatureSystem:ResNatureModelSet(msg)
    if msg.natureType == NatureEnum.Mount then -- Mount data
        self.NatureMountData:UpDateModelId(msg.modelId)
    elseif msg.natureType == NatureEnum.Wing then -- Wings data
        self.NatureWingsData:UpDateModelId(msg.modelId)
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        self.NatureWeaponData:UpDateModelId(msg.modelId)
    elseif msg.natureType == NatureEnum.FaBao then -- Magic weapon data
        self.NatureFaBaoData:UpDateModelId(msg.modelId)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_FASHION_CHANGEMODEL,msg.natureType)
end

-- Return to set the model for task follow
function NatureSystem:ResNatureTaskModelSet(msg)
    -- Debug.LogTable(msg, "NatureSystem:ResNatureTaskModelSet")
    -- if msg.natureType == NatureTaskEnum.TaskFollow then -- Monster follow player
    --     -- self.LuaCharacterSystem:RefreshTaskTransNPC(GameCenter.LuaPlayer.ID, GameCenter.LuaPlayer.IntOcc, nil, msg.modelId, true)
    -- elseif msg.natureType == NatureTaskEnum.TaskEquipPlayer then -- Equipment follow player
    --     -- self.LuaCharacterSystem:RefreshTaskTransEquipPlayer(GameCenter.LuaPlayer.ID, GameCenter.LuaPlayer.IntOcc, nil, msg.modelId, true)
    -- end
    -- GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_TASK_FASHION_CHANGEMODEL,msg.natureType)
end

-- Return to the information about eating fruits
function NatureSystem:ResNatureDrug(msg)
    if msg.natureType == NatureEnum.Mount then -- Mount data
        self.NatureMountData:UpDateGrugInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPDATEDRUG, msg)
    elseif msg.natureType == NatureEnum.Wing then -- Wings data
        self.NatureWingsData:UpDateGrugInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEDRUG, msg)
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        self.NatureWeaponData:UpDateGrugInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WEAPON_UPDATEDRUG, msg)
    elseif msg.natureType == NatureEnum.FaBao then -- magic weapon
        self.NatureFaBaoData:UpDateGrugInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NATURE_EVENT_FABAO_UPDATEDRUG, msg.druginfo.fruitId)
    elseif msg.natureType == NatureEnum.Pet then -- magic weapon
        self.NaturePetData:UpDateGrugInfo(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM, msg.druginfo.fruitId)
    end
end

-- Return the transformation upgrade result
function NatureSystem:ResNatureFashionUpLevel(msg)
    local _fashion = nil
    local _config = nil
    local showType = 0
    local fashionBase = nil
    local scale = 180
    local posY = 0
    local name = ""
    if msg.natureType == NatureEnum.Mount then -- Mount data

        self.NatureMountData:UpDateFashionInfo(msg.info)
        _fashion = self.NatureMountData.super.FishionList:Find(function(code)
            return msg.info.id == code.ModelId
        end)
        _config = DataConfig.DataHuaxingHorse[msg.info.id]
        showType = ShowModelType.Mount
        fashionBase = self.NatureMountData.super
        scale = self.NatureMountData:Get3DUICamerSize(msg.info.id)
        posY = self.NatureMountData:GetShowModelYPosition(msg.info.id)
        if _config then
            name = _config.Name
        end
    elseif msg.natureType == NatureEnum.Wing then -- Wings data
        self.NatureWingsData:UpDateFashionInfo(msg.info)
        _fashion = self.NatureWingsData.super.FishionList:Find(function(code)
            return msg.info.id == code.ModelId
        end)
        _config = DataConfig.DataHuaxingWing[msg.info.id]
        showType = ShowModelType.Wing
        fashionBase = self.NatureWingsData.super
        scale = self.NatureWingsData:Get3DUICamerSize(msg.info.id)
        name = _config.Name
        -- posY = self.NatureWingsData:GetShowModelYPosition(msg.info.id)
    elseif msg.natureType == NatureEnum.Talisman then -- Magic tool data
    elseif msg.natureType == NatureEnum.Magic then -- Array data
    elseif msg.natureType == NatureEnum.Weapon then -- Divine Soldier Data
        self.NatureWeaponData:UpDateFashionInfo(msg.info)
        _fashion = self.NatureWeaponData.super.FishionList:Find(function(code)
            return msg.info.id == code.ModelId
        end)
        _config = DataConfig.DataHuaxingWeapon[msg.info.id]
    elseif msg.natureType == NatureEnum.FaBao then -- Magic weapon data
        self.NatureFaBaoData:UpDateFashionInfo(msg.info)
        _fashion = self.NatureFaBaoData.super.FishionList:Find(function(code)
            return msg.info.id == code.ModelId
        end)
        _config = DataConfig.DataHuaxingfabao[msg.info.id]
        showType = ShowModelType.FaBao
        fashionBase = self.NatureFaBaoData.super
        scale = self.NatureFaBaoData:Get3DUICamerSize(msg.info.id)
        posY = self.NatureFaBaoData:GetShowModelYPosition(msg.info.id)
        name = _config.Name
    end
    if _fashion and _fashion.IsActive and _fashion.Level > 0 then
        Utils.ShowPromptByEnum("LevelUpSucced",_config.Name)
    else
        Utils.ShowPromptByEnum("ActivateSucced", _config.Name)
        -- if msg.info.id ~= 6100001 then
            --GameCenter.PushFixEvent(UIEventDefine.UIModelViewForm_OPEN, {msg.info.id, msg.natureType})
        --local info = fashionBase:GetFashionInfo(msg.info.id)
        --GameCenter.ModelViewSystem:ShowModel(showType,info.ModelId,scale,posY, name)
        -- end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION,msg.info.id)
end

-- Mount returns result
function NatureSystem:ResNatureMountBaseLevel(msg)
    local _oldlevel = self.NatureMountData.BaseCfg.Id
    self.NatureMountData:UpDateBaseAttr(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPDATEEQUIP ,_oldlevel)
end

-- Send an upgrade message
function NatureSystem:ReqNatureUpLevel(type,itemid,isonekey)
    GameCenter.Network.Send("MSG_Nature.ReqNatureUpLevel",{
        natureType = type,
        itemid = itemid,
        isOneKeyUp = isonekey
    })
end

-- Send message setting model
function NatureSystem:ReqNatureModelSet(type,model)
    if type == NatureEnum.FlySword then
        GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
            type = 3,
            huaxinID = model
        })
    else
        GameCenter.Network.Send("MSG_Nature.ReqNatureModelSet",{
            natureType = type,
            modelId = model
        })
    end
end

-- ReqNatureTaskModelSet
function NatureSystem:ReqNatureTaskModelSet(type,taskModelId)
    GameCenter.Network.Send("MSG_Nature.ReqNatureTaskModelSet",{
        natureType = type,
        taskModelId = tostring(taskModelId)
    })
end

-- Send message request basic data
function NatureSystem:ReqNatureInfo(type)
    GameCenter.Network.Send("MSG_Nature.ReqNatureInfo",{
        natureType = type,
    })
    
end

-- Send fruit eating information
function NatureSystem:ReqNatureDrug(type,item)
    GameCenter.Network.Send("MSG_Nature.ReqNatureDrug",{
        natureType = type,
        itemid = item
    })
end

-- Request for transformation upgrade activation
function NatureSystem:ReqNatureFashionUpLevel(type,modelid)
    if type == NatureEnum.FlySword then
        GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
            type = 2,
            huaxinID = modelid
        })
    else
        GameCenter.Network.Send("MSG_Nature.ReqNatureFashionUpLevel",{
            natureType = type,
            id = modelid
        })
    end
end

-- Eat equipment
function NatureSystem:ReqNatureMountBaseLevel(onlyinfo,iteminfo)
    GameCenter.Network.Send("MSG_Nature.ReqNatureMountBaseLevel",{
        itemOnlyInfo = onlyinfo,
        itemModelInfo = iteminfo
    })
end

-- Determine whether there is a mount model set
function NatureSystem:HasMountId()
    if self.NatureMountData.super.CurModel ~= 0 then
        return true
    end
    return false
end

-- Get the currently worn mount ID
function NatureSystem:GetMountId()
    return self.NatureMountData.super.CurModel
end

-- Obtain the current wear wing ID
function NatureSystem:GetCurModelId()
    return self.NatureWingsData.super.CurModel
end

return NatureSystem
