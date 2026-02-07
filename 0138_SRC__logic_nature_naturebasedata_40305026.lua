-- Author: 
-- Date: 2019-04-17
-- File: NatureBaseData.lua
-- Module: NatureBaseData
-- Description: Creation Panel General Data Parent Class
------------------------------------------------
-- Quote
local BaseAttrData = require "Logic.Nature.NatureBaseAttrData"
local BaseItemData = require "Logic.Nature.NatureBaseItemData"
local BaseDrugData = require "Logic.Nature.NatureBaseDrugData"
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;
local ItemMsgCondition = CS.Thousandto.Code.Logic.ItemMsgCondition;
local FightUtils = require "Logic.Base.FightUtils.FightUtils"

local NatureBaseData = {
    NatureType = 0, -- type
    Level = 0, -- Level is also configuration table ID
    CurExp = 0, -- Current experience
    CurModel = 0, -- Current model ID
    SkillList = List:New(),   -- Skill list, store NatureSkillModelData
    AllSkillList = List:New(),   -- All skills list, storage configuration table information
    ModelList = List:New(), -- Model list, NatureBaseModelData
    AttrList =List:New(), -- List of properties, store NatureBaseAttrData
    ItemList = List:New(),-- Props list, store NatureBaseItemData
    DrugList = List:New(), -- List of medications, store NatureBaseDrugData
    FishionList = List:New(), -- Transformation data storage NatureFashionData
    Fight = 0, -- Current combat power
}

NatureBaseData.__index = NatureBaseData

function NatureBaseData:New( naturetype )
    local _M = Utils.DeepCopy(self)
    _M.NatureType = naturetype
    return _M
end

-- Update data function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- Calculate basic attribute combat power
function NatureBaseData:GetAttrFight()
    local attr = Dictionary:New()
    for i=1,#self.AttrList do
        attr:Add(self.AttrList[i].AttrID,self.AttrList[i].Attr);
    end
    return FightUtils.GetPropetryPower(attr)
end

-- Calculate the fighting power of the fruit eating attribute
function NatureBaseData:GetDurgAttrFight()
    local attr = Dictionary:New()
    local attrDrug = Dictionary:New()
    for i=1,#self.DrugList do
        local bastattr = self.DrugList[i].AttrList
        for j=1,#bastattr do
            attr:Add(bastattr[j].AttrID,bastattr[j].Attr);
        end
        for j=1,#self.AttrList do
            if self.DrugList[i].PeiyangAtt[1] == self.AttrList[i].AttrID then
                attrDrug:Add(self.AttrList[i].AttrID,self.AttrList[i].Attr * (self.DrugList[i].PeiyangAtt[2] /100))
            end
        end
    end
    return FightUtils.GetPropetryPower(attr) + FightUtils.GetPropetryPower(attrDrug)
end

-- Calculate the transformation force
function NatureBaseData:GetFashionAttrFight()
    local fight = 0
    for i=1,#self.FishionList do
        if self.FishionList[i].IsActive then
            fight = fight + self.FishionList[i].Fight
        end
    end
    return fight
end

-- Resolve properties
function NatureBaseData:AnalysisAttr(str)
    self.AttrList:Clear()
    if str then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(str,_cs)
        for i=1,#_attr do        
            local _data = BaseAttrData:New(_attr[i][1],_attr[i][2],_attr[i][3])
            self.AttrList:Add(_data)
        end
    end
end

-- Analyze the values in props and ITEM tables
function NatureBaseData:AnalysisItem(str)
    self.ItemList:Clear()
    if str then
        local _attr = Utils.SplitStr(str,'_')
        for i=1,#_attr do
            local _itemid = tonumber(_attr[i])
            local _itemInfo = DataConfig.DataItem[_itemid]
            if _itemInfo then
                local _value = Utils.SplitStr(_itemInfo.EffectNum,'_')
                if _value[2] then
                    local _data = BaseItemData:New(_itemid,tonumber(_value[2]))
                    self.ItemList:Add(_data)
                end
            end
        end
    end
end

-- Analyze the values in props and ITEM tables
function NatureBaseData:AddMagicItem(itemid)
    self.ItemList:Clear()
    local _data = BaseItemData:New(tonumber(itemid),0)
    self.ItemList:Add(_data)
end


-- Analyze props and quantity
function NatureBaseData:AnalysisItemAndNum(str)
    self.ItemList:Clear()
    if str then
        local _cs = {';','_'}
        local _attr = Utils.SplitStrByTableS(str,_cs)
        for i=1,#_attr do
            local _itemid = _attr[i]
            local _data = BaseItemData:New(_itemid[1],_itemid[2])
            self.ItemList:Add(_data)
        end
    end
end

-- Analyze the data of eating pills
function NatureBaseData:AnalysisOtherItemCfg(type,info)
    GameCenter.NatureSystem:InitConfig()
        if GameCenter.NatureSystem.NatureDrugDir:ContainsKey(type) then
            local _druglist = GameCenter.NatureSystem.NatureDrugDir[type]
            if _druglist then
                 self.DrugList:Clear()
                 local _count = #_druglist
                 for i=1,_count do 
                        local _eatnum = 0
                        local _level = 0
                        local _pos = 0
                        if info.fruitInfo then                         
                            for j=1,#info.fruitInfo do
                                if info.fruitInfo[j].fruitId == _druglist[i].ItemId  then
                                    _eatnum = info.fruitInfo[j].eatnum
                                    _level= info.fruitInfo[j].level
                                    _pos = _druglist[i].Position
                                    break
                                end
                            end
                        end
                        if _pos ~= 0 then
                            local _id = type * 1000 + _pos * 100 + _level
                            local _dataConfig = DataConfig.DataNatureAtt[_id]
                            local _total = self:GetTotalEatNum(type * 1000 + _pos * 100, _level)
                            local _data = BaseDrugData:New(_dataConfig,_eatnum, _total)
                            self.DrugList:Add(_data)
                        else
                            local _data = BaseDrugData:New(_druglist[i],0)
                            self.DrugList:Add(_data)
                        end
                 end
            end
        end
end

function NatureBaseData:GetTotalEatNum(firstID, level)
    local _eatnum = 0
    if level > 0 then
        for i = 1, level do
            local _id = firstID + i - 1
            local _dataConfig = DataConfig.DataNatureAtt[_id]
            if _dataConfig then
                _eatnum = _eatnum + _dataConfig.LeveLimit
            end
        end
    end
    return _eatnum
end

-- Network message, setting deformation information
function NatureBaseData:UpDataFashionInfos(info)
    if info then
        for i=1,#info do
            local _config = nil;
            if self.NatureType == NatureEnum.Mount then -- Mount data
                _config = DataConfig.DataHuaxingHorse[info[i].id]
            elseif self.NatureType == NatureEnum.Wing then -- Wings data
                _config = DataConfig.DataHuaxingWing[info[i].id]
            elseif self.NatureType == NatureEnum.Talisman then -- Magic tool data
                _config = DataConfig.DataHuaxingTalisman[info[i].id]
            elseif self.NatureType == NatureEnum.Magic then -- Array data
                _config = DataConfig.DataHuaxingMagic[info[i].id]
            elseif self.NatureType == NatureEnum.Weapon then -- Divine Soldier Data
                _config = DataConfig.DataHuaxingWeapon[info[i].id]
            elseif self.NatureType == NatureEnum.FaBao then -- Magic weapon data
                _config = DataConfig.DataHuaxingfabao[info[i].id]
            elseif self.NatureType == NatureEnum.FlySword then -- Magic weapon data
                _config = DataConfig.DataHuaxingFlySword[info[i].modelID]
            end
            self:UpDataFashion(info[i],_config)
        end
    end
end

-- Set up individual transformation data
function NatureBaseData:UpDataFashion(info, config)
    local _fashion = self.FishionList:Find(function(code)
        if info.id then
            return info.id == code.ModelId
        else
            return info.modelID == code.ModelId
        end
    end)
    if _fashion then
        if info.fight and info.fight > 0 then
            self.Fight = info.fight
        end
        _fashion.IsActive = true
        if info.level then
            _fashion.Level = info.level
        end
        if info.starLevel then
            _fashion.Level = info.starLevel
        end
        -- _fashion:SetFight()
        if config then
            _fashion:UpDateAttrData(config)
        end
    end
end

-- Update skill settings
function NatureBaseData:UpDateSkill(skill)
    if skill then
        for i=1,#skill do
            self:SetSkillActive(skill[i])
        end
    end
end

-- Set skill activation
function NatureBaseData:SetSkillActive(skill)
    local _skillinfo = self.SkillList:Find(function(code)
        if code.SkillInfo then
            return skill.SkillType == code.SkillType
        end
        return nil
    end)
    if _skillinfo then
        _skillinfo.IsActive = true
        _skillinfo.SkillLevel = skill.Level
        _skillinfo.SkillInfo = DataConfig.DataSkill[skill.SkillType * 100 + skill.Level]
        _skillinfo.NeedLevel = self:GetSkillNeedlv(skill.SkillType,skill.Level)
    end
end

-- Get the order or level that needs to be upgraded by adding a large skill type to a level or level that needs to be upgraded
function NatureBaseData:GetSkillNeedlv(skilltype,level)
    local _cs = {'_'}
    for i=1,#self.AllSkillList do
        local _skill = Utils.SplitStrByTable(self.AllSkillList[i].Skill,_cs)
        if tonumber(_skill[1]) == skilltype and tonumber(_skill[2]) > level then
            if self.NatureType == NatureEnum.Mount then
                return self.AllSkillList[i].Steps
            else
                return self.AllSkillList[i].Id
            end
        end
    end
    return -1
end

-- Update model settings
function NatureBaseData:UpDateModel(models)
    if models then
        for i=1,#models do
            self:SetModelActive(models[i])
        end
    end
end

-- Set up model activation
function NatureBaseData:SetModelActive(modelid)
    local _modelList = self.ModelList:Find(function(code)
        local _model = code.Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and code.ModelIdList then
                _model = code.ModelIdList[_lp.IntOcc + 1]
            end
        end
        return modelid == _model
    end)
    if _modelList then
        _modelList.IsActive = true
    end
end

-- Update the information on eating fruits
function NatureBaseData:UpDateDrug(info)
    for i=1,#self.DrugList do
        if self.DrugList[i].ItemId == info.fruitId then
            self.DrugList[i].EatNum = info.eatnum
            if info.level > self.DrugList[i].Level  then
                local _id = self.NatureType * 1000 + self.DrugList[i].Position * 100 + info.level
                local _dataConfig = DataConfig.DataNatureAtt[_id]
                local _total = self:GetTotalEatNum(self.NatureType * 1000 + self.DrugList[i].Position * 100, info.level)
                self.DrugList[i].Total = _total
                self.DrugList[i]:UpDateAttrData(_dataConfig)
            else
                self.DrugList[i]:UpDateAttr()
            end
            break
        end
    end
end

-- Analysis of taking medicine and assignment
function NatureBaseData:Parase(type,info)
    if info then
        self.Level = info.curLevel
        self.CurExp = info.curExp
        self.CurModel = info.modelId
        self.Fight = info.fight
        self:AnalysisOtherItemCfg(type,info)
    end
end

-- - Function function!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- Obtain the activated model ID
function NatureBaseData:GetModelsList()
    -- local _list = List:New()
    -- for i=1,#self.ModelList do
    --     if self.ModelList[i].IsActive then
    --         _list:Add(self.ModelList[i])
    --     end
    -- end
    local _list = self.ModelList
    return _list
end

-- Get the name of the model
function NatureBaseData:GetModelsName(modelid)
    for i=1, #self.ModelList do
        local _model = self.ModelList[i].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and self.ModelList[i].ModelIdList then
                _model = self.ModelList[i].ModelIdList[_lp.IntOcc + 1]
            end
        end
        if _model == modelid then
            return self.ModelList[i].Name
        end
    end
    local _fashion = self:GetFashionInfo(modelid)
    if _fashion then
        return _fashion.Name
    end
    return ""
end

function NatureBaseData:GetFirstModelID()
    if self.ModelList and self.ModelList[1] then
        local _model = self.ModelList[1].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and self.ModelList[1].ModelIdList then
                _model = self.ModelList[1].ModelIdList[_lp.IntOcc + 1]
            end
        end
        return _model
    end
    return 0
end

-- Get the scaling of the model
function NatureBaseData:GetCameraSize(modelid)
    for i=1,#self.ModelList do
        local _model = self.ModelList[i].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and self.ModelList[i].ModelIdList then
                _model = self.ModelList[i].ModelIdList[_lp.IntOcc + 1]
            end
        end
        if _model == modelid then
            return self.ModelList[i].CameraSize
        end
    end
    return 160
end

-- Get the currently displayed model, if the basic appearance is not set, the default display is maximum
function NatureBaseData:GetCurShowModel()
    local _list = self:GetModelsList()
    local _activeModel = nil
    if _list:Count() > 0 then
        local _model = 0
        for i=1, _list:Count() do
            _model = _list[i].Modelid
            if _model == 0 or _model == nil then
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _lp and _list[i].ModelIdList then
                    _model = _list[i].ModelIdList[_lp.IntOcc + 1]
                end
            end
            if _list[i].IsActive then
                _activeModel = _model
            end
            if _model == self.CurModel then
                return self.CurModel
            end
        end
        if _activeModel then
            return _activeModel
        end
        return _model
    end
    return self.CurModel
end

-- Get whether you can click the left toggle button through the model ID
function NatureBaseData:GetNotLeftButton(modelid)
    local _list = self:GetModelsList()
    if _list:Count() > 0 then
        local _model = _list[1].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and _list[1].ModelIdList then
                _model = _list[1].ModelIdList[_lp.IntOcc + 1]
            end
        end
        return _model ~= modelid
    end
    return false
end

-- Obtain the previous model ID through the model ID
function NatureBaseData:GetLastModel(modelid)
    local _list = self:GetModelsList()
    local _index = 0;
    if _list:Count() > 0 then
        local _model = 0
        for i=1,_list:Count() do
            _model = _list[i].Modelid
            if _model == 0 or _model == nil then
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _lp and _list[i].ModelIdList then
                    _model = _list[i].ModelIdList[_lp.IntOcc + 1]
                end
            end
            if modelid == _model then
                _index = i-1
            end
        end
        _model = _list[_index].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and _list[_index].ModelIdList then
                _model = _list[_index].ModelIdList[_lp.IntOcc + 1]
            end
        end
        return _model
    end
    return 0
end

-- Obtain the next model ID through the model ID
function NatureBaseData:GetNextModel(modelid)
    local _list = self:GetModelsList()
    local _index = 0;
    if _list:Count() > 0 then
        local _model = 0
        for i=1,_list:Count() do
            _model = _list[i].Modelid
            if _model == 0 or _model == nil then
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _lp and _list[i].ModelIdList then
                    _model = _list[i].ModelIdList[_lp.IntOcc + 1]
                end
            end
            if modelid == _model then
                _index = i + 1
            end
        end
        _model = _list[_index].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and _list[_index].ModelIdList then
                _model = _list[_index].ModelIdList[_lp.IntOcc + 1]
            end
        end
        return _model
    end
    return 0
end

-- Get whether you can click the toggle button on the right through the model ID
function NatureBaseData:GetNotRightButton(modelid)
    local _list = self:GetModelsList()
    if _list:Count() > 0 then
        local _model = _list[#_list].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and _list[#_list].ModelIdList then
                _model = _list[#_list].ModelIdList[_lp.IntOcc + 1]
            end
        end
        return _model~= modelid
    end
    return false
end

-- Whether the model is activated
function NatureBaseData:GetModelData(modelid)
    for i=1, #self.ModelList do
        local _model = self.ModelList[i].Modelid
        if _model == 0 or _model == nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp and self.ModelList[i].ModelIdList then
                _model = self.ModelList[i].ModelIdList[_lp.IntOcc + 1]
            end
        end
        if _model == modelid then
            return self.ModelList[i]
        end
    end
    return nil
end

-- Obtain transform data through ID
function NatureBaseData:GetFashionInfo(id)
    local _info = self.FishionList:Find(function(code)
        return code.ModelId == id
    end)
    if _info then
        return _info
    end
    return nil
end

-- Red dot function!!!!!!!!!!!!!!!!!!

-- Update level red dot
function NatureBaseData:UpDateLevelHit(functionid,ismax,needItemExp, msg)
    local _ismax = self.Level >= ismax
    local _count = #self.ItemList
    self.NeedItemExp = needItemExp
    GameCenter.ItemContianerSystem:ClearItemMsgCondition(functionid)
    if not _ismax then
        local _items = {}
        for i = 1,_count do
            _items[i] = self.ItemList[i].ItemID
        end
        GameCenter.ItemContianerSystem:AddItemMsgCondition(msg, _items, functionid)
        self:UpdateLvRed(functionid)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(functionid, false)
    end
end

function NatureBaseData:UpdateLvRed(functionid)
    if self.NeedItemExp and self.NeedItemExp > 0 then
        local _exp = 0
        for i = 1, #self.ItemList do
            local _itemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.ItemList[i].ItemID)
            _exp = _exp + _itemCount * self.ItemList[i].ItemExp
            if _exp >= self.NeedItemExp then
                break
            end
        end
        GameCenter.MainFunctionSystem:SetAlertFlag(functionid, _exp >= self.NeedItemExp)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(functionid, false)
    end
end

-- Updated red dots of fruit
function NatureBaseData:UpDateDrugHit(functionid)
    local _count = #self.DrugList
    GameCenter.RedPointSystem:CleraFuncCondition(functionid)
    for i = 1,_count do
        local _ismax = self.DrugList[i].Level >= GameCenter.NatureSystem:GetDrugItemMax(self.NatureType,self.DrugList[i].ItemId)
        if not _ismax then
            GameCenter.RedPointSystem:AddFuncCondition(functionid, i, RedPointItemCondition(self.DrugList[i].ItemId, 1))
        end
    end
end

-- Update the red dots of wings
function NatureBaseData:UpDateFashionHit(functionid)
    local _count = #self.FishionList
    GameCenter.RedPointSystem:CleraFuncCondition(functionid)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    for i = 1,_count do
        local _ismax = self.FishionList[i].Level >= self.FishionList[i].MaxLevel
        self.FishionList[i]:UpDateNeedItem()
        if _lp and self.FishionList[i].Occ and self.FishionList[i].Occ ~= _lp.IntOcc then
            _ismax = true
        end
        if not _ismax and ((self.FishionList[i].IsActive and self.FishionList[i].IsServerActive) or not self.FishionList[i].IsServerActive) then
            GameCenter.RedPointSystem:AddFuncCondition(functionid, i, RedPointItemCondition(self.FishionList[i].Item, self.FishionList[i].NeedItemNum))
        end
    end
end

return NatureBaseData