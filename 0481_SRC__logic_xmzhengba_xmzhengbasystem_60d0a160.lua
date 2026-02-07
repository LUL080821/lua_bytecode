
------------------------------------------------
-- Author:
-- Date: 2021-12-02
-- File: XMZhengBaSystem.lua
-- Module: XMZhengBaSystem
-- Description: Immortal Alliance Contest System
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;

local XMZhengBaSystem = {
    DataDict = nil, --Dictionary<id, Dictionary<id, L_XMZBData>>
    RealEndTime = nil,
    ActiveDays = 7,
}

-- Types of Immortal Alliance Battle
local L_XmType =
{
    -- Immortal Alliance Development
    Dev = 1,
    -- Immortal Alliance Battle
    Fight = 2,
    -- The Immortal Alliance Fight
    Compet = 3,
    -- Close time
    CloseTickTime = 0,
}

local L_XMZBData = nil

function XMZhengBaSystem:Initialize()
    self.DataDict = Dictionary:New()
    local _dict = Dictionary:New()
    local _list = List:New()
    -- Initialize configuration table data
    DataConfig.DataXianmengzhengba:Foreach(function(k, v)
        local _data = L_XMZBData:New()
        _data:SetData(v, nil)
        if self.DataDict:ContainsKey(v.ActiveType) then
            self.DataDict[v.ActiveType]:Add(v.Id, _data)
        else
            _dict = Dictionary:New()
            _dict[v.Id] = _data
            self.DataDict:Add(v.ActiveType, _dict)
        end
    end)
    local _xmzbLiDay = Utils.SplitNumber(DataConfig.DataGlobal[GlobalName.XMZB_Day_Count].Params, '_')
    self.ActiveDays = _xmzbLiDay[2]
end

function XMZhengBaSystem:UnInitialize()
end

function XMZhengBaSystem:Update(dt)

end

function XMZhengBaSystem:SetOpenServerTime(time)
    -- Check the opening status
    local _serverOpenTime = math.floor(math.floor(time / 1000) + GameCenter.HeartSystem.ServerZoneOffset)
    local _h, _m, _s = TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _openDayStart = _serverOpenTime - _h * 3600 - _m * 60 - _s
    self.CloseTickTime = _openDayStart + self.ActiveDays * 86400
end

-- Online push data
function XMZhengBaSystem:ResXMZhengBaInfo(msg)
    -- Immortal Alliance Battle Data List
    local _list = msg.xmzbList
    if _list ~= nil then
        local _dataCount = #_list
        for i = 1, _dataCount do
            local _id = _list[i].id
            if DataConfig.DataXianmengzhengba:IsContainKey(_id) then
                local _type = DataConfig.DataXianmengzhengba[_id].ActiveType
                self.DataDict[_type][_id]:SetData(nil, _list[i])
            end
        end
    end
    -- Event end time
    local _endTime = msg.endTime
    self:UpdateRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMZB_DATA_UPDATE)
end

-- Data returned from receiving the prize
function XMZhengBaSystem:ResGetXMZBReward(msg)
    local _data = msg.xmzb
    local _id = _data.id
    if DataConfig.DataXianmengzhengba:IsContainKey(_id) then
        local _type = DataConfig.DataXianmengzhengba[_id].ActiveType
        self.DataDict[_type][_id]:SetData(nil, _data)
    end
    -- Update data
    self:UpdateRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMZB_DATA_UPDATE)
end

function XMZhengBaSystem:UpdateRedPoint()
    local _hasRedPoint = {
        DevRed = false,
        FightRed = false,
        CompetRed = false,
    }
    local _dataDict = self.DataDict
    _dataDict:Foreach(
        function(_type, _dict)
            _dict:ForeachCanBreak(
                function(_id, _data)
                    local _varibiles = Utils.SplitNumber(_data.Cfg.Value, "_");
                    local _lastCount = #_varibiles
                    if L_XmType.Dev == _type and _data.ServerData.progress >= _varibiles[_lastCount] and not _data.ServerData.isComplete and not _hasRedPoint.DevRed then
                        _hasRedPoint.DevRed = true
                        return true
                    elseif L_XmType.Fight == _type and _data.ServerData.progress >= _varibiles[_lastCount] and not _data.ServerData.isComplete and not _hasRedPoint.FightRed then
                        _hasRedPoint.FightRed = true
                        return true
                    elseif L_XmType.Compet == _type and _data.ServerData.progress >= _varibiles[_lastCount] and not _data.ServerData.isComplete and not _hasRedPoint.CompetRed then
                        _hasRedPoint.CompetRed = true
                        return true
                    end
                end
            )
        end
    )
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.XMZhengBa, _hasRedPoint.DevRed or _hasRedPoint.FightRed or _hasRedPoint.CompetRed)
end

-- Get the remaining time
function XMZhengBaSystem:GetLeftTime()
    self.RealEndTime = self.CloseTickTime - GameCenter.HeartSystem.ServerZoneTime
    if self.RealEndTime < 0 then
        self.RealEndTime = 0
    end
    return self.RealEndTime
end

L_XMZBData = {
    Id = nil,
    -- Configuration table data
    Cfg = nil,
    -- Server data
    ServerData = nil,
}

function L_XMZBData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function L_XMZBData:SetData(cfg, sData)
    if cfg ~= nil then
        self.Id = cfg.Id
        self.Cfg = cfg
    end
    if sData then
        self.ServerData = sData
    end
end

return XMZhengBaSystem