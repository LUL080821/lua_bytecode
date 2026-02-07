------------------------------------------------
-- author:
-- Date: 2021-08-23
-- File: DownloadRequest.lua
-- Module: DownloadRequest
-- Description: Image download request
------------------------------------------------
local DownloadRequest = {
    Request = nil,
    PicId = nil,
    PicType = nil,
    BigOrSmal = nil,
    IsFinish = nil,
    FileName = nil,
    FilePath = nil,
    ResultCode = nil,
}

function DownloadRequest:New(request, picId, picType, bigOrSmal, filePath, fileName)
    local _m = Utils.DeepCopy(self)
    _m.Request = request
    _m.PicId = picId
    _m.PicType = picType
    _m.BigOrSmal = bigOrSmal
    _m.FilePath = filePath
    _m.FileName = fileName
    return _m
end

function DownloadRequest:OnStart()
    if self.Request ~= nil then
        self.IsFinish = false
        -- Send a request
        self.Request:Send()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DOWNLOAD_HEAD_START, self)
    else
        self.ResultCode = -1
        self.IsFinish = true
    end
end

function DownloadRequest:OnFinish(resultCode)
    self.ResultCode = resultCode
    self.IsFinish = true
    self.Request = nil
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_DOWNLOAD_HEAD_END, self)
end

return DownloadRequest