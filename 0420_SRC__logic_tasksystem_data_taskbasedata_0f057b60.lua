------------------------------------------------
-- Author: Wang Sheng
-- Date: 2021-03-19
-- File: LuaTestTask.lua
-- Module: LuaTestTask
-- Description: Lua test task instance
------------------------------------------------
-- Quote
local L_RewardData = require "Logic.TaskSystem.Data.TaskRewardData"
local L_RecommendData = require "Logic.TaskSystem.Data.TaskRecommendData"
local TaskBaseData = {
    Id = 0,
    MapId = 0, -- //Task Target Map id
    AccessNpcID = 0, -- //NPC id of the task
    SubmitNpcID = 0, -- //NPC id of submitting the task
    SubType = 0, -- //Task Subtype
    IsAccess = false, -- //Whether the task is received
    IsTransPort = true, -- //Does it transmit? Default true;
    PreRecommendId = 0, -- //The previous recommended activity id
    IsShowRecommend = false, -- //Whether to display the recommended
    IsRecommendChange = false, -- //Recommended to change
    Name = nil, -- //Task Name
    Des = nil, -- //Task Description
    UiDes = nil, -- //Task description on ui
    TargetDes = nil, -- //Task Target Description
    TypName = nil, -- //Type Name
    PromptStr = nil,
    Type = TaskType.Default, -- //Task Master Type
    Behavior = TaskBeHaviorType.Default, -- //Task behavior
    Sort = TaskSort.Default,
    RewardList = List:New(), -- //Reward props
    ShowList = List:New(),
    RecommendList = List:New(),
    IconId = 0, -- //Task circle iconid
    IsIgnoLimit = false, -- Whether it is irrelevant to combat power limitations
    CanItemTeleport = nil, -- Can I use flying shoes
}
function TaskBaseData:New()
    local _m = Utils.DeepCopy(self)
    return Utils.DeepCopy(self);
end

function TaskBaseData:SetData(id, type, accessNpcID, submitNpcID, isAccess, beType, name, des, targetDes, reward, mapID,
    equipReward, showStr, isTransPort)
    id = id == nil and 0 or id
    type = type == nil and 0 or type
    accessNpcID = accessNpcID == nil and 0 or accessNpcID
    if isAccess == nil then
        isAccess = false
    end
    beType = beType == nil and 0 or beType
    name = name == nil and "" or name
    des = des == nil and "" or des
    targetDes = targetDes == nil and "" or targetDes
    reward = reward == nil and "" or reward
    mapID = mapID == nil and 0 or mapID
    equipReward = equipReward == nil and "" or equipReward
    showStr = showStr == nil and "" or showStr
    if isTransPort == nil then
        isTransPort = false
    end
    self.Id = id;
    self.Type = type;
    self.AccessNpcID = accessNpcID;
    self.SubmitNpcID = submitNpcID;
    self.IsAccess = isAccess;
    self.Behavior = beType;
    self.Name = name;
    self.Des = des;
    self.TargetDes = targetDes;
    self.MapId = mapID;
    self.IsTransPort = isTransPort;
    self:SetAwardData(reward);
    if equipReward ~= nil and equipReward ~= "" then
        self:SetEquipAwardData(equipReward);
    end
    if showStr ~= nil and showStr ~= "" then
        self:SetShowAwardData(showStr);
    end
end
function TaskBaseData:SetDataEx(data)
    data.Id = self.Id;
    data.Type = self.Type;
    data.AccessNpcID = self.AccessNpcID;
    data.SubmitNpcID = self.SubmitNpcID;
    data._isAccess = self.IsAccess;
    data.Behavior = self.Behavior;
    data.Name = self.Name;
    data.Des = self.Des;
    data.TargetDes = self.TargetDes;
end

function TaskBaseData:GetMapName()
    local _ret = nil
    if self.Type == TaskType.ZhanChang then
        local _cfg = DataConfig.DataCloneMap[self.MapId]
        if _cfg ~= nil then
            _ret = _cfg.TypeName;
        end
    else
        local _cfg = DataConfig.DataCloneMap[self.MapId]
        if _cfg ~= nil then
            _ret = _cfg.Name;
        end
    end
    return _ret;
end

-- Set task reward prop data
function TaskBaseData:SetAwardData(str)
    local _strs = Utils.SplitStr(str, ';')
    for i = 1, #_strs do
        local _params = Utils.SplitStr(_strs[i], '_');
        local _bind = 0;
        if #_params == 3 then
            _bind = tonumber(_params[3])
        end
        local _id = tonumber(_params[1]);
        local _num = tonumber(_params[2]);
        
        local _data = L_RewardData:New();
        _data.ID = _id;
        _data.Num = _num;
        _data.IsBind = _bind == 1 and true or false;
        self.RewardList:Add(_data);
    end
end
-- Set equipment reward data
function TaskBaseData:SetEquipAwardData(str)
    local _playerOcc = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc;
    local _list = Utils.SplitStr(str, ';')
    if _list ~= nil then
        for i = 1, #_list do
            local _params = Utils.SplitStr(_list[i], '_');
            if #_params == 3 then
                local _occ = tonumber(_params[1])
                if _playerOcc == _occ then
                    local _data = L_RewardData:New();
                    _data.ID = tonumber(_params[2]);
                    _data.Num = tonumber(_params[3]);
                    self.RewardList:Add(_data);
                end
            end
        end
    end
end
-- Add equipment to display
function TaskBaseData:SetShowAwardData(str)
    local _playerOcc = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc;
    local _occParams = Utils.SplitStr(str, ';')
    if _occParams ~= nil then
        for i = 1, #_occParams do
            local _infoParams = Utils.SplitStr(_occParams[i], '_');
            local _type = tonumber(_infoParams[1]);

            if _type == _playerOcc then
                local _data = L_RewardData:New();
                _data.ID = tonumber(_infoParams[2]);
                _data.Num = tonumber(_infoParams[3]);
                _data.ShowSize = tonumber(_infoParams[4]);
                _data.Name = _infoParams[5];
                self.ShowList:Add(_data);
                break
            end
        end
    end
end

function TaskBaseData:GetTargetId()
end

return TaskBaseData
