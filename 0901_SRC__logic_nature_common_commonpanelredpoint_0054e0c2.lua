------------------------------------------------
-- Author: 
-- Date: 2019-04-18
-- File: CommonPanelRedPoint.lua
-- Module: CommonPanelRedPoint
-- Description: Red dots inside the universal panel
------------------------------------------------
-- Quote

local RedData = require "Logic.Nature.Common.CommonPanelRedData"

local CommonPanelRedPoint = {
    ButtinInfoList = nil, -- Buttons in the interface, storage of CommonPanelRedData
}
CommonPanelRedPoint.__index = CommonPanelRedPoint

function CommonPanelRedPoint:New()
    local _M = Utils.DeepCopy(self)
    _M.ButtinInfoList = List:New()
    return _M
end

-- Add a button red dot data
function CommonPanelRedPoint:Add(functionid,trs,dataid,isgary)
    --local _Id = Utils.GetEnumNumber(tostring(functionid))
    local _info = RedData:New(functionid,trs,dataid,isgary)
    self.ButtinInfoList:Add(_info)
end

-- Initialize registration red dot change message
function CommonPanelRedPoint:Initialize()
    self.UpDateRedEvent = Utils.Handler(self.UpDateRed, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.UpDateRedEvent)
    for i = 1,#self.ButtinInfoList do
        local _info = self.ButtinInfoList[i]
        _info:RefreshInfo()
    end
end

-- Deinitialization registration red dot change message
function CommonPanelRedPoint:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.UpDateRedEvent)
end

-- Red dot detection
function CommonPanelRedPoint:UpDateRed(functioninfo,sender)
    for i = 1,#self.ButtinInfoList do
        local _info = self.ButtinInfoList[i]
        local type = _info.FunctionStartId
        if type == functioninfo.ID then
            _info:RefreshInfo()
        end
    end
end


return CommonPanelRedPoint