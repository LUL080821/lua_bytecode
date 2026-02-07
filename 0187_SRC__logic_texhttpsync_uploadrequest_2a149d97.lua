------------------------------------------------
-- author:
-- Date: 2021-08-23
-- File: UploadRequest.lua
-- Module: UploadRequest
-- Description: Image upload request
------------------------------------------------

local UploadRequest = {
    Request = nil,
    Tex = nil,
    UpLoadType = nil,
    FinishCallback = nil,
    IsFinish = false,
    PicId = nil,
    ResultCode = 0,
}

function UploadRequest:New(request, tex, uploadType, finishCall)
    local _m = Utils.DeepCopy(self)
    _m.Request = request
    _m.Tex = tex
    _m.UpLoadType = uploadType
    _m.FinishCallback = finishCall
    return _m
end

function UploadRequest:OnStart()
    if self.Request ~= nil then
        self.IsFinish = false
        -- Send a request
        self.Request:Send()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPLOAD_HEAD_START, self)
    else
        self.ResultCode = -1
        self.IsFinish = true
    end
end

function UploadRequest:OnFinish(resultCode, picId)
    self.IsFinish = true
    self.ResultCode = resultCode
    self.PicId = picId
    if self.FinishCallback ~= nil then
        self.FinishCallback(self)
    end
    self.Request = nil
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPLOAD_HEAD_END, self)
    if resultCode ~= 0 then
        Utils.ShowPromptByEnum("C_UPLOAD_HEAD_FAILED", resultCode)
    end
end

return UploadRequest