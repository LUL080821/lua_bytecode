------------------------------------------------
-- Author:
-- Date: 2021-02-24
-- File: MonsterSoulMonsterData.lua
-- Module: MonsterSoulMonsterData
-- Description: Divine Beast Data Class
------------------------------------------------
local L_FightUtils = require ("Logic.Base.FightUtils.FightUtils")
local CSFightUtils = CS.Thousandto.Code.Logic.FightPowerHelper
local MonsterSoulMonsterData = {
    CfgId = 0,
    DBID = 0,
    -- Is it in the battle
    Fighting = false,
    -- Divine Beast Attribute
    BaseAttr = Dictionary:New(),
    -- Divine beast configuration data
    Config = nil,
    -- name
    Name = nil,
    IconId = 0,
    -- Part quality limitations
    PartQualityLimit = Dictionary:New(),
    -- Part star rating restrictions
    PartStarLimit = Dictionary:New(),
}

function MonsterSoulMonsterData:New(id)
    local _M = Utils.DeepCopy(self)
    _M.CfgId = id
    _M.Config = DataConfig.DataSoulBeasts[id]
    if _M.Config then
        _M.Name = _M.Config.Name;
        _M.IconId = _M.Config.Icon;
        local arr = Utils.SplitStr(_M.Config.Attribute, ';')
        for i = 1, #arr do
            local _att = Utils.SplitNumber(arr[i], '_')
            _M.BaseAttr:Add(_att[1], _att[2])
        end
        arr = Utils.SplitStr(_M.Config.NeedEquip, ';')
        for i = 1, #arr do
            local _att = Utils.SplitNumber(arr[i], '_')
            if #_att >= 3 then
                _M.PartQualityLimit:Add(_att[1], _att[2])
                _M.PartStarLimit:Add(_att[1], _att[3])
            end
        end
    end
    return _M
end

-- Whether to activate status
function MonsterSoulMonsterData:GetActivation()
    local allWearedEquip = GameCenter.MonsterSoulSystem.MonsterRelativeEquipDict;
    if(allWearedEquip:ContainsKey(self.CfgId)) then
        -- Completely equipped
        return #allWearedEquip[self.CfgId] == MonsterSoulEquipType.Count
    end
    return false
end

-- The combined combat power of basic attributes and equipment attributes
function MonsterSoulMonsterData:GetScore()
    local baseScore = L_FightUtils.GetPropetryPower(self.BaseAttr);
    local equipScore = 0;
    local equipedList = self:GetEquipList();

    if equipedList then
        for i = 1, #equipedList do
            equipScore = equipScore + CSFightUtils.GetPropetryPower(equipedList[i].BaseAttr);
            local levelAttr = equipedList[i]:GetAddUpAttrByLevel(equipedList[i].Level);
            if(levelAttr) then
                equipScore = equipScore + CSFightUtils.GetPropetryPower(levelAttr);
            end
        end
    end
    -- Debug.LogError(baseScore)
    return baseScore + equipScore
end

-- Equipment List
function MonsterSoulMonsterData:GetEquipList()
    local allWearedEquip = GameCenter.MonsterSoulSystem.MonsterRelativeEquipDict;
    if(allWearedEquip:ContainsKey(self.CfgId)) then
        return allWearedEquip[self.CfgId]
    end
    return List:New()
end

function MonsterSoulMonsterData:GetAllEquipAttrDict()
    local _equipList = self:GetEquipList()
    if _equipList == nil then
        return nil
    end
    local dict = Dictionary:New()
    for i = 1, #_equipList do
        local attrDict = _equipList[i]:GetAttrsForFightPower();
        local itor = attrDict:GetEnumerator();
        while(itor:MoveNext()) do
            if (dict:ContainsKey(itor.Current.Key)) then
                dict[itor.Current.Key] = dict[itor.Current.Key] + itor.Current.Value.AttrValue
            else
                dict:Add(itor.Current.Key, itor.Current.Value.AttrValue);
            end
        end
    end
    return dict
end

function MonsterSoulMonsterData:IsLocated(location)
    self.EquipList = self:GetEquipList()
    if self.EquipList == nil then
        return false;
    end
    for i = 1, #self.EquipList do
        if (self.EquipList[i].Part == location) then
            return true;
        end
    end
    return false;
end

function MonsterSoulMonsterData:GetEquipedLoation()
    local locations = List:New()
    self.EquipList = self:GetEquipList()
    if self.EquipList then
        for i = 1, #self.EquipList do
            if self.EquipList[i].DBID ~= 0 then
                locations[self.EquipList[i].Part] = true;
            end
        end
    end

    return locations;
end


function MonsterSoulMonsterData:GetEquipByPart(part)
    self.EquipList = self:GetEquipList()
    if self.EquipList then
        for i = 1, #self.EquipList do
            if (self.EquipList[i].Part == part) then
                return self.EquipList[i];
            end
        end
    end
    return nil;
end
return MonsterSoulMonsterData