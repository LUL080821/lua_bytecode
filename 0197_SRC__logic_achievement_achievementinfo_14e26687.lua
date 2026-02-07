------------------------------------------------
-- Author:
-- Date: 2019-05-17
-- File: AchievementItem.lua
-- Module: AchievementItem
-- Description: Achievement Info
------------------------------------------------
local L_Tonumber = tonumber;
local L_SplitStr = Utils.SplitStr;
local L_DeepCopy = Utils.DeepCopy;

-- Achievement of Info
local  AchievementInfo = {
    -- Configure Id
    Id = nil,
    -- Achievement [Configuration table data, no modification]
    DataAchievementItem = nil,
    -- Achievement type [configuration table data, no modification]
    DataAchievementTypeItem = nil,
    -- Function Id
    FunctionId = nil,
    -- The quantity to be achieved
    Count = nil,
    -- Current status (AchievementState enumeration type)
    State = nil,
    -- Reward ItemId
    AwardItemId = nil,
    -- Number of reward Items
    AwardItemCount = nil,
    -- Is the reward Item bound?
    AwardItemBind = nil,
    -- schedule
    Progress = nil,
}

-- AchievementItem.__index = AchievementItem
local function InitData(self ,DataAchievementItem, DataAchievementTypeItem)
    self.Id = DataAchievementItem.Id;
    self.DataAchievementItem = DataAchievementItem;
    self.DataAchievementTypeItem = DataAchievementTypeItem;
    local _t = L_SplitStr(DataAchievementItem.Condition, "_");
    self.FunctionId = L_Tonumber(_t[1]);
    self.Count = L_Tonumber(_t[#_t]);
    local _award = L_SplitStr(DataAchievementItem.Item, "_");
    self.AwardItemId = L_Tonumber(_award[1]);
    self.AwardItemCount = L_Tonumber(_award[2]);
    self.AwardItemBind = L_Tonumber(_award[3]);
    self.State = AchievementStateEnum.None;
end

function AchievementInfo:New(id)
    -- local _data = setmetatable({},self)
    local _data = L_DeepCopy(self)
    local DataAchievement = DataConfig.DataAchievement;
    local DataAchievementType = DataConfig.DataAchievementType;
    local DataAchievementItem = DataAchievement[id]
    InitData(_data, DataAchievementItem, DataAchievementType[DataAchievementItem.BigType])
    return _data
end

function AchievementInfo:NewAll(DataTypeDic, DataIdDic)
    local DataAchievementType = DataConfig.DataAchievementType;
    DataConfig.DataAchievement:Foreach(function(_, v)
        -- local _data = setmetatable({},self)
        local _data = L_DeepCopy(self)
        InitData(_data, v, DataAchievementType[v.BigType]);
        if not DataTypeDic:ContainsKey(v.BigType) then
            DataTypeDic:Add(v.BigType,Dictionary:New());
        end
        local _DataTypeDicBigType = DataTypeDic[v.BigType];
        if not _DataTypeDicBigType:ContainsKey(_data.FunctionId) then
            _DataTypeDicBigType:Add(_data.FunctionId, List:New());
        end
        _DataTypeDicBigType[_data.FunctionId]:Add(_data);
        DataIdDic:Add(v.Id,_data);
    end)
    DataTypeDic:SortKey(function(a, b) return a < b end)
    -- DataTypeDic:Foreach(function(_, v)
    --     table.sort(v, function(a, b)
    --         return a.Count < b.Count;
    --     end)
    -- end)
end

return AchievementInfo