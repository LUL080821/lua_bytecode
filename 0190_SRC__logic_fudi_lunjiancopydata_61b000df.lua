------------------------------------------------
-- Author:
-- Date: 2021-01-22
-- File: LunJianCopyData.lua
-- Module: LunJianCopyData
-- Description: Blessed Sword Copy Data
------------------------------------------------
-- Quote
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local LunJianCopyData = {
    Time_1 = 0,
    Time_2 = 0,
    -- End time
    EndTime = 0,
    -- Prepare for the countdown
    ReadyTime = 0,
    -- Streak (number of losing streak) data
    ZhanJiData = nil,
    -- Broadcast data
    ShowTitleData = nil,
    -- Settlement data
    ResultData = nil,
    FuDiRankList = List:New(),
    PersonRankList = List:New()
}

function LunJianCopyData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function LunJianCopyData:SetReadyTime(t)
    self.ReadyTime = t / 1000 + GameCenter.HeartSystem.ServerTime
end

function LunJianCopyData:GetReadyTime()
    return self.ReadyTime - GameCenter.HeartSystem.ServerTime
end

-- Set up the ranking data of the blessed land
function LunJianCopyData:SetFuDiRank(data)
    if data == nil then
        return
    end
    local _isFind = false
    for i = 1, #self.FuDiRankList do
        local _rank = self.FuDiRankList[i]
        if data.id == _rank.Id then
            _rank.Rank = data.rank
            _rank.Score = data.score
            _isFind = true
            break
        end
    end
    if not _isFind then
        local _fuDiName = DataConfig.DataGuildTitle[data.id * 100 + 1].Name
        local _rank = {
            Id = data.id,
            Rank = data.rank,
            Name = _fuDiName,
            Score = data.score
        }
        self.FuDiRankList:Add(_rank)
    end
    self.FuDiRankList:Sort(function(a, b)
        return a.Rank < b.Rank
    end)
end

function LunJianCopyData:GetFuDiRank()
    return self.FuDiRankList
end

-- Set up personal ranking data
function LunJianCopyData:SetPersonRank(data)
    if data == nil then
        return
    end
    local _isFind = false
    for i = 1, #self.PersonRankList do
        local _rank = self.PersonRankList[i]
        if data.playerId == _rank.Id then
            _rank.Rank = data.rank
            _rank.Score = data.score
            _isFind = true
            break
        end
    end
    if not _isFind then
        local _rank = {
            Id = data.playerId,
            Rank = data.rank,
            Score = data.score,
            Name = data.name,
            -- Facade = data.facade,
            VisInfo = nil
        }
        self.PersonRankList:Sort(function(a, b)
            return a.Rank < b.Rank
        end)
        self.PersonRankList:Add(_rank)
    end
    self.PersonRankList:Sort(function(a, b)
        return a.Rank < b.Rank
    end)
end

function LunJianCopyData:GetPersonRank()
    return self.PersonRankList
end

-- Set record data
function LunJianCopyData:SetZhanJiData(msg)
    local _des = nil
    local _add = nil
    self.ZhanJiData = nil
    DataConfig.DataGuildBattleFinalAdd:ForeachCanBreak(function(k, v)
        if v.Type == msg.type and tonumber(v.Num) <= msg.kill then
            _des = v.Des
            _add = v.Addons
        end
    end)
    if _des ~= nil and _add ~= nil then
        self.ZhanJiData = {
            Type = msg.type,
            Count = msg.kill,
            Des = _des,
            Add = _add
        }
    end
end

-- Obtain record data
function LunJianCopyData:GetZhanJiData()
    return self.ZhanJiData
end

-- Setting up broadcast data
function LunJianCopyData:SetShowTitleData(msg)
    if msg == nil then
        return
    end
    local _type = 0
    local _count = msg.kill

    local _winName = msg.killer.name
    local _winOcc = msg.killer.career
    local _winHead = nil
    local _winFrame = nil
    if msg.killer.fashion ~= nil then
        for i = 1, #msg.killer.fashion do
            local _msgData = msg.killer.fashion[i]
            local _fashionData = GameCenter.NewFashionSystem:GetTotalData(_msgData.fashionID)
            if _msgData.type == 11 then
                _winHead = _fashionData:GetModelId(_winOcc)
            elseif _msgData.type == 12 then
                _winFrame = _fashionData:GetModelId(_winOcc)
            end
        end
    end

    local _failName = msg.beKill.name
    local _failOcc = msg.beKill.career
    local _failHead = nil
    local _failFrame = nil
    if msg.beKill.fashion ~= nil then
        for i = 1, #msg.beKill.fashion do
            local _msgData = msg.beKill.fashion[i]
            local _fashionData = GameCenter.NewFashionSystem:GetTotalData(_msgData.fashionID)
            if _msgData.type == 11 then
                _failHead = _fashionData:GetModelId(_winOcc)
            elseif _msgData.type == 12 then
                _failFrame = _fashionData:GetModelId(_winOcc)
            end
        end
    end

    local _res = -1
    _count = _count < 20 and _count or 20
    DataConfig.DataGuildBattleFinalAdd:ForeachCanBreak(function(k, v)
        if v.Type == _type and tonumber(v.Num) == _count then
            _res = v.SpecialTex
            return true
        end
    end)

    self.ShowTitleData = {
        WinName = _winName,
        WinHead = _winHead,
        WinFrame = _winFrame,
        WinOcc = _winOcc,

        FailName = _failName,
        FailOcc = _failOcc,
        FailHead = _failHead,
        FailFrame = _failFrame,
        Res = _res
    }
end

-- Get broadcast data
function LunJianCopyData:GetShowTitleData()
    return self.ShowTitleData
end

-- Setting settlement data
function LunJianCopyData:SetResultData(msg)
    -- Set the number one data
    local _title = msg._title
    local _facade = msg.first.facade
    local _name = msg.first.name
    local _occ = msg.first.career
    local _firstData = {
        Title = _title,
        Name = _name,
        Occ = _occ,
        VisInfo = nil
    }
    _firstData.VisInfo = PlayerVisualInfo:New()
    _firstData.VisInfo:ParseByLua(_facade, 0)
    local _fuDiItemList = List:New()
    if msg.fudReward ~= nil then
        for i = 1, #msg.fudReward do
            local _itemData = msg.fudReward[i]
            local _item = nil
            for m = 1, #_fuDiItemList do
                if _fuDiItemList[m].Id == _itemData.modelId then
                    _item = _fuDiItemList[m]
                    _item.Num = _item.Num + _itemData.count
                end
            end
            if _item == nil then
                _fuDiItemList:Add({
                    Id = _itemData.modelId,
                    Num = _itemData.count
                })
            end
        end
    end
    local _fuDiName = DataConfig.DataGuildTitle[msg.fud.id * 100 + 1].Name
    local _fuDiInfo = {
        Name = _fuDiName,
        Rank = msg.fud.rank,
        Score = msg.fud.score,
        ItemList = _fuDiItemList
    }

    local _personItemList = List:New()
    if msg.myReward ~= nil then
        for i = 1, #msg.myReward do
            local _itemData = msg.myReward[i]
            local _item = nil
            for m = 1, #_personItemList do
                if _personItemList[m].Id == _itemData.modelId then
                    _item = _personItemList[m]
                    _item.Num = _item.Num + _itemData.count
                end
            end
            if _item == nil then
                _personItemList:Add({
                    Id = _itemData.modelId,
                    Num = _itemData.count
                })
            end
        end
    end
    local _personInfo = {
        Rank = msg.my.rank,
        Score = msg.my.score,
        ItemList = _personItemList
    }
    self.ResultData = {
        FirstData = _firstData,
        FuDiInfo = _fuDiInfo,
        PersonInfo = _personInfo
    }
    GameCenter.PushFixEvent(UILuaEventDefine.UIFuDiResultForm_OPEN)
end

-- Get settlement data
function LunJianCopyData:GetResultData()
    return self.ResultData
end

-- Get the remaining time
function LunJianCopyData:GetLeftTime()
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime))
    if self.Time_1 == 0 then
        local _cfg = DataConfig.DataDaily[112]
        local _list = Utils.SplitNumber(_cfg.Time, '_')
        self.Time_1 = _list[2]
    end
    self.EndTime = self.Time_1 * 60 - (_hour * 3600 + _min * 60 + _sec)
    return self.EndTime
end

return LunJianCopyData
