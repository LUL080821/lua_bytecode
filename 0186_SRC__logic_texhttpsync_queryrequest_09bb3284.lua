------------------------------------------------
-- author:
-- Date: 2021-08-23
-- File: QueryRequest.lua
-- Module: QueryRequest
-- Description: Image query request
------------------------------------------------
local QueryRequest = {
    Request = nil,
    PicId = nil,
    PicType = nil,
    BigOrSmal = nil,
    IsFinish = false,
    QueryKey = nil,
    ResultCode = nil,
}

function QueryRequest:New(request, picId, picType, bigOrSmal)
    local _m = Utils.DeepCopy(self)
    _m.Request = request
    _m.PicId = picId
    _m.PicType = picType
    _m.BigOrSmal = bigOrSmal
    if bigOrSmal then
        _m.QueryKey = string.format("%s_big", picId)
    else
        _m.QueryKey = string.format("%s_smal", picId)
    end
    return _m
end

function QueryRequest:OnStart()
    if self.Request ~= nil then
        self.IsFinish = false
        -- Send a request
        self.Request:Send()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHECK_HEAD_START, self)
    else
        self.ResultCode = -1
        self.IsFinish = true
    end
end

function QueryRequest:OnFinish(resultCode)
    self.IsFinish = true
    self.Request = nil
    self.ResultCode = resultCode
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHECK_HEAD_END, self)
end

return QueryRequest