------------------------------------------------
-- author:
-- Date: 2021-08-23
-- File: TexHttpSyncSystem.lua
-- Module: TexHttpSyncSystem
-- Description: Picture synchronization system
------------------------------------------------
local L_AppManager = CS.UnityEngine.Gonbest.MagicCube.AppManager
local L_HTTPRequest = CS.BestHTTP.HTTPRequest
local L_HTTPMethods = CS.BestHTTP.HTTPMethods
local L_Uri = CS.System.Uri
local L_TexSyncUtils = CS.Thousandto.Plugins.Common.TexSyncUtils
local L_BigHeadSize = 512
local L_QueryRequest = require "Logic.TexHttpSync.QueryRequest"
local L_UploadRequest = require "Logic.TexHttpSync.UploadRequest"
local L_DownloadRequest = require "Logic.TexHttpSync.DownloadRequest"
-- The protagonist once an hour, and the other players once an hour 12 hours
local L_LegalCheckTime = 12 * 60 * 60 
local L_LPLegalCheckTime = 1 * 60 * 60

local TexHttpSyncSystem = {
    -- Image synchronization server address
    TexSyncURL = nil,
    -- Image upload server address
    TexUploadURL = nil,
    -- Image detection server address
    TexCheckURL = nil,

    -- Upload file storage directory
    UpLoadPicPath = nil,
    -- Download file storage directory
    DownloadPicPath = nil,

    -- Upload queue
    UpLoadQue = List:New(),
    -- Current upload request
    CurUpLoadReq = nil,

    -- Query queue
    QueryQue = List:New(),
    -- Current query request
    CurQueReq = nil,
    -- Query records
    QueryRecord = Dictionary:New(),

    -- Download queue
    DownloadQue = List:New(),
    -- Current download request
    CurDownReq = nil,

    -- Legality detection record
    LegalQueryRecord = Dictionary:New(),
}

function TexHttpSyncSystem:IsValid()
    if self.TexSyncURL ~= nil and string.len(self.TexSyncURL) > 0 then
        return true
    end
    return false
end

function TexHttpSyncSystem:Update(dt)
    if Time.GetFrameCount() % 10 ~= 0 then
        return
    end
    -- Upload
    if self.CurUpLoadReq == nil and self.UpLoadQue:Count() > 0 then
        self.CurUpLoadReq = self.UpLoadQue[1]
        self.UpLoadQue:RemoveAt(1)
        self.CurUpLoadReq:OnStart()
    end
    if self.CurUpLoadReq ~= nil and self.CurUpLoadReq.IsFinish then
        self.CurUpLoadReq = nil
    end

    -- Query
    if self.CurQueReq == nil and self.QueryQue:Count() > 0 then
        self.CurQueReq = self.QueryQue[1]
        self.QueryQue:RemoveAt(1)
        self.CurQueReq:OnStart()
        self.QueryRecord[self.CurQueReq.QueryKey] = Time.GetRealtimeSinceStartup()
    end
    if self.CurQueReq ~= nil and self.CurQueReq.IsFinish then
        self.CurQueReq = nil
    end

    -- download
    if self.CurDownReq == nil and self.DownloadQue:Count() > 0 then
        self.CurDownReq = self.DownloadQue[1]
        self.DownloadQue:RemoveAt(1)
        self.CurDownReq:OnStart()
    end
    if self.CurDownReq ~= nil and self.CurDownReq.IsFinish then
        self.CurDownReq = nil
    end
end

-- initialization
function TexHttpSyncSystem:Initialize()
    self.TexSyncURL = L_AppManager.Instance:GetLocalVersionValue("TexSyncURL")

    if self.TexSyncURL == nil or string.len(self.TexSyncURL) <= 0 then
        Debug.LogError("The image synchronization address was not read")
    else
        Debug.LogError("Read the image synchronization address: " .. self.TexSyncURL)
        self.TexUploadURL = self.TexSyncURL .. "/PhotoCheckKits/photocheck/photodata/upload"
        self.TexCheckURL = self.TexSyncURL .. "/PhotoCheckKits/photocheck/photodata/query"
    end
    self.UpLoadPicPath = PathUtils.GetWritePath("/TexSync/Upload/")
    -- L_TexSyncUtils.CreateDirectory(self.UpLoadPicPath)
    self.DownloadPicPath = PathUtils.GetWritePath("/TexSync/Download/")
    -- L_TexSyncUtils.CreateDirectory(self.DownloadPicPath)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CLIP_IMG_CALLBACK, self.SelectHeadPicCallBack, self)
end

-- De-initialization
function TexHttpSyncSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CLIP_IMG_CALLBACK, self.SelectHeadPicCallBack, self)
end

-- Clear player query CD
function TexHttpSyncSystem:ClearLPQueringCD()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _picId = _lp.TexHeadPicID
    if _picId == nil or string.len(_picId) <= 0 then
        return
    end
    self.QueryRecord:Remove(_picId .. "_big")
    self.QueryRecord:Remove(_picId .. "_smal")
end

-- Is the avatar being uploaded?
function TexHttpSyncSystem:IsUpLoadingHead()
    if self.CurUpLoadReq ~= nil and not self.CurUpLoadReq.IsFinish and self.CurUpLoadReq.UpLoadType == TexHttpSyncType.HeadPic then
        -- Currently uploading avatar
        return true
    end
    for i = 1, #self.UpLoadQue do
        local _cur = self.UpLoadQue[i]
        if _cur.UpLoadType == TexHttpSyncType.HeadPic then
            -- Currently uploading avatar
            return true
        end
    end
    return false
end

-- Is it being queryed?
function TexHttpSyncSystem:IsQuering(picId, bigOrSmal)
    if self.CurQueReq ~= nil and not self.CurQueReq.IsFinish and self.CurQueReq.PicId == picId and self.CurQueReq.BigOrSmal == bigOrSmal then
        -- Querying
        return true
    end
    for i = 1, #self.QueryQue do
        local _cur = self.QueryQue[i]
        if not _cur.IsFinish and _cur.PicId == picId and _cur.BigOrSmal == bigOrSmal then
            -- Querying
            return true
        end
    end
    return false
end
-- Is it downloading?
function TexHttpSyncSystem:IsDownloading(picId, bigOrSmal)
    if self.CurDownReq ~= nil and self.CurDownReq.PicId == picId and self.CurDownReq.BigOrSmal == bigOrSmal then
        -- Downloading
        return true
    end
    for i = 1, #self.DownloadQue do
        local _cur = self.DownloadQue[i]
        if _cur.PicId == picId and _cur.BigOrSmal == bigOrSmal then
            -- Downloading
            return true
        end
    end
    return false
end

-- Request to select avatar
function TexHttpSyncSystem:ReqSelectAndUploadHead(type)
    if not self:IsValid() then
        return
    end
    if type == nil then
        type = 0
    end
    if self:IsUpLoadingHead() then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _filePath = self.UpLoadPicPath .. _lp.ID .. ".jpg"
    -- Delete the old file first
    if File.Exists(_filePath) then
        File.Delete(_filePath)
    end
    -- Call the interface to open the picture selection dialog box
    -- type = 0 Album type = 1 Camera
    GameCenter.SDKSystem:GetPhoto(type, _filePath, L_BigHeadSize, L_BigHeadSize)
end

-- Get uploaded directory avatar
function TexHttpSyncSystem:GetLPUploadHead()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return nil
    end
    local _picId = _lp.TexHeadPicID
    if _picId == nil or string.len(_picId) <= 0 then
        return nil
    end
    -- Determine whether the uploaded directory has this file
    local _upFilePath = self.UpLoadPicPath .. _picId .. ".jpg"
    if File.Exists(_upFilePath) then
        -- The file has been uploaded and can be loaded directly
        return _upFilePath
    end
    return nil
end

-- Request to get avatar
function TexHttpSyncSystem:ReqGetHeadPic(playerId, picId, bigOrSmal)
    if not self:IsValid() then
        return TexHttpSyncState.Error
    end
    if picId == nil or string.len(picId) <= 0 then
        return TexHttpSyncState.NotHaveTex, nil
    end
    local _key = "PlayerHeadPic_" .. playerId
    local _selfPicId = PlayerPrefs.GetString(_key, nil)
    if _selfPicId ~= nil and string.len(_selfPicId) > 0 and _selfPicId ~= picId then
        -- The old avatar id stored by the client does not match the new avatar id, delete the old file
        -- Delete old files
        local _upPath = self.UpLoadPicPath .. _selfPicId .. ".jpg"
        if File.Exists(_upPath) then
            -- Delete the upload directory file
            File.Delete(_upPath)
        end
        local _downPath = nil
        if bigOrSmal then
            _downPath = self.DownloadPicPath .. _selfPicId .. "_big.jpg"
        else
            _downPath = self.DownloadPicPath .. _selfPicId .. "_smal.jpg"
        end
        if File.Exists(_downPath) then
            -- Delete the download directory file
            File.Delete(_downPath)
        end
        PlayerPrefs.SetString(_key, picId)
    end
 
    local _downFilePath = nil
    if bigOrSmal then
        _downFilePath = self.DownloadPicPath .. picId .. "_big.jpg"
    else
        _downFilePath = self.DownloadPicPath .. picId .. "_smal.jpg"
    end
    local _isLocalPlayer = false
    -- The file is not local, determine whether it is being uploaded or downloaded
    if playerId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        _isLocalPlayer = true
    end
    -- The file is not local, determine whether it is being uploaded or downloaded
    if _isLocalPlayer then
        -- Determine whether the protagonist's avatar is being uploaded
        if self:IsUpLoadingHead() then
            return TexHttpSyncState.UpLoading, nil
        end
    end
    -- Determine whether it is inquiry
    if self:IsQuering(picId, bigOrSmal) then
        return TexHttpSyncState.Checking, nil
    end
    local _texInfo = GameCenter.TextureManager:GetTextureInfo(_downFilePath)
    if _texInfo ~= nil and _texInfo.Texture ~= nil then
        -- The file has been loaded into memory, and the file has existed directly
        return TexHttpSyncState.AlredayDownload, _downFilePath
    end
    -- Find query records
    local _queKey = nil
    if bigOrSmal then
        _queKey = picId .. "_big"
    else
        _queKey = picId .. "_smal"
    end
    if File.Exists(_downFilePath) then
        -- Determine whether testing is needed, once a day
        local _legalTime = self.LegalQueryRecord[_queKey]
        if _legalTime == nil then
            _legalTime = PlayerPrefs.GetInt("LegalTime_" .. _queKey, -1)
        end
        local _norSec = Time.GetNowSeconds()
        local _checkDisTime = L_LegalCheckTime
        if _isLocalPlayer then
            _checkDisTime = L_LPLegalCheckTime
        end
        if _legalTime <= 0 or (_norSec - _legalTime) > _checkDisTime then
            -- Save the detection record
            self.LegalQueryRecord[_queKey] = _norSec
            PlayerPrefs.SetInt("LegalTime_" .. _queKey, _norSec)
            -- Start testing
            -- Create a query
            local _uri = L_Uri(self.TexCheckURL)
            local _httpReq =  L_HTTPRequest(_uri, L_HTTPMethods.Post)
            _httpReq:AddField("photoId", picId)
            if bigOrSmal then
                _httpReq:AddField("type", "0")
            else
                _httpReq:AddField("type", "1")
            end
            local _queReq = L_QueryRequest:New(_httpReq, picId, TexHttpSyncType.HeadPic, bigOrSmal)
            _httpReq.Callback = function(originalRequest, response)
                self:OnLegalQueryRestlt(originalRequest, response, _queReq)
            end
            self.QueryQue:Add(_queReq)
            return TexHttpSyncState.Checking, nil
        else
            -- The file already exists and can be loaded directly
            return TexHttpSyncState.AlredayDownload, _downFilePath
        end
    end
    -- Determine whether it is downloading
    if self:IsDownloading(picId, bigOrSmal) then
        return TexHttpSyncState.Downloading, nil
    end
    local _canQuery = true
    local _forntQueTime = self.QueryRecord[_queKey]
    if _forntQueTime ~= nil and (Time.GetRealtimeSinceStartup() - _forntQueTime) < 300 then
        -- Allow 5 minutes to query
        _canQuery = false
    end
  
    if _canQuery then
        -- Create a query
        local _uri = L_Uri(self.TexCheckURL)
        local _httpReq =  L_HTTPRequest(_uri, L_HTTPMethods.Post)
        _httpReq:AddField("photoId", picId)
        if bigOrSmal then
            _httpReq:AddField("type", "0")
        else
            _httpReq:AddField("type", "1")
        end
        local _queReq = L_QueryRequest:New(_httpReq, picId, TexHttpSyncType.HeadPic, bigOrSmal)
        _httpReq.Callback = function(originalRequest, response)
            self:OnQueryRestlt(originalRequest, response, _queReq)
        end
        self.QueryQue:Add(_queReq)
    end
    return TexHttpSyncState.Checking, nil
end

-- Upload back
function TexHttpSyncSystem:OnUpLoadResult(originalRequest, response, requestData)
    local _errorCode = -999
    local _picId = nil
    while(true) do
        if response == nil then
            -- Upload failed
            _errorCode = 404
            Debug.LogError(originalRequest.Exception)
            break
        end
        local _text = response.DataAsText
        if _text == nil or string.len(_text) <= 0 then
            -- Upload failed
            _errorCode = 1
            Debug.LogError("Uploading file failed StatusCode =" .. response.StatusCode)
            break
        end
        local _resultJson = Json.decode(_text)
        if _resultJson == nil then
            -- Resolve upload failed
            _errorCode = 2
            Debug.LogError("Resolve upload failed DataAsText =" .. _text)
            break
        end
        -- Upload return: {"photoID":photoID}
        _picId = _resultJson.photoID
        if _picId == nil or string.len(_picId) <= 0 then
            -- The image id is empty
            _errorCode = 4
            Debug.LogError("Failed to parse the image id DataAsText =" .. _text)
            break
        end
        -- Upload successfully, save new file
        _picId = string.gsub(_picId, "\"", "")
        local _savePath = self.UpLoadPicPath .. _picId .. ".jpg"
        L_TexSyncUtils.SaveTex(requestData.Tex, _savePath)
        -- Save the image to texturemanager
        requestData.Tex.name = _picId .. ".jpg"
        -- Save to the picture manager
        GameCenter.TextureManager:SaveTexture(_savePath, requestData.Tex)
        _errorCode = 0
        Debug.LogError("Upload successfully" .. _picId)
        break
    end
    requestData:OnFinish(_errorCode, _picId)
end

-- Select avatar to return
function TexHttpSyncSystem:SelectHeadPicCallBack(filePath, sender)
    local _upRequest = nil
    while(true) do
        if filePath == nil or string.len(filePath) <= 0 then
            Debug.LogError("filePath == nil")
            break
        end
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then
            Debug.LogError("_lp == nil")
            break
        end
        if self.TexUploadURL == nil or string.len(self.TexUploadURL) <= 0 then
            Debug.LogError("self.TexUploadURL == nil")
            break
        end
        -- Read file binary data
        local _tex2d = L_TexSyncUtils.LoadTex(filePath, L_BigHeadSize, L_BigHeadSize)
        -- Delete source files
        File.Delete(filePath)
        -- Start uploading
        local _uri = L_Uri(self.TexUploadURL)
        local _httpReq = L_HTTPRequest(_uri, L_HTTPMethods.Post)
        -- Server id
        local _realServerID = 0
        local _item = GameCenter.ServerListSystem:FindServer(_lp.PropMoudle.ServerID)
        if _item then
            _realServerID = _item.ReallyServerId
        end
        _httpReq:AddField("desc1", tostring(_realServerID))
        -- Role id
        _httpReq:AddField("desc2", tostring(_lp.ID))
        -- Role name
        _httpReq:AddField("desc3", _lp.Name)
        -- Old avatar id
        if _lp.TexHeadPicID == nil then
            _httpReq:AddField("photoId", "")
        else
            _httpReq:AddField("photoId", _lp.TexHeadPicID)
        end
        -- Image binary data
        L_TexSyncUtils.AddTexToBinData(_httpReq, _tex2d, "photoData")
        -- Image extension
        _httpReq:AddField("extName", ".jpg")
        _upRequest = L_UploadRequest:New(_httpReq, _tex2d, TexHttpSyncType.HeadPic, function(request)
            if request.ResultCode == 0 then
                local isShow = true
                local newLp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if newLp ~= nil then
                    local _oldPicId = newLp.TexHeadPicID
                    if _oldPicId ~= nil and string.len(_oldPicId) > 0 then
                        -- Delete old files
                        local lpUpPath = self.UpLoadPicPath .. newLp.TexHeadPicID .. ".jpg"
                        if File.Exists(lpUpPath) then
                            -- Delete the upload directory file
                            File.Delete(lpUpPath)
                        end
                        local lpDownPath = self.DownloadPicPath .. newLp.TexHeadPicID .. ".jpg"
                        if File.Exists(lpDownPath) then
                            -- Delete the download directory file
                            File.Delete(lpDownPath)
                        end
                    end
                    -- Save new avatar id
                    newLp.TexHeadPicID = request.PicId
                    isShow = newLp.IsShowHeadPic
                end
                -- Send to the server to save
                GameCenter.Network.Send("MSG_Player.ReqPlayerSettingCustomHead", {customHeadPath = request.PicId, useCustomHead = isShow})
            end
        end)
        _httpReq.Callback = function(originalRequest, response)
            self:OnUpLoadResult(originalRequest, response, _upRequest)
        end
        break
    end
    if _upRequest ~= nil then
        -- Join the upload queue
        self.UpLoadQue:Add(_upRequest)
    end
end

 -- Legality query returns
 function TexHttpSyncSystem:OnLegalQueryRestlt(originalRequest, response, requestData)
    local _resultCode = -999
    while(true) do
        if response == nil then
            _resultCode = 1
            Debug.LogError(originalRequest.Exception)
            break
        end
        local _text = response.DataAsText
        if _text == nil or string.len(_text) <= 0 then
            -- Upload failed
            _resultCode = 2
            Debug.LogError("Query failed StatusCode =" .. response.StatusCode)
            break
        end
        local _resultJson = Json.decode(_text)
        if _resultJson == nil then
            -- Resolve upload failed
            _resultCode = 3
            Debug.LogError("Parsing query returns failed DataAsText =" .. _text)
            break
        end
        -- Upload return: {"photoID":photoID}
        local stateCode = tonumber(_resultJson.stateCode)
        if stateCode == nil then
            -- No id field
            _resultCode = 4
            Debug.LogError("The parsing query return code failed DataAsText =" .. _text)
            break
        end
        if stateCode == 0 then -- No data found
            _resultCode = 6
            Debug.LogError("The server has no data DataAsText =" .. _text)
            break
        elseif stateCode == 1 then -- The review failed
            _resultCode = 7
            Debug.LogError("Failed to review DataAsText =" .. _text)
            break
        elseif stateCode == 2 then -- Under review
            _resultCode = 8
            Debug.LogError("Under review DataAsText =" .. _text)
            break
        elseif stateCode == 3 then -- Can be downloaded
            Debug.LogError("The legality query is successful, you can download it")
            _resultCode = 0
            requestData:OnFinish(_resultCode)
            -- Send a download successful message
            local filePath = nil
            local fileName = nil
            if requestData.BigOrSmal then
                filePath = self.DownloadPicPath .. requestData.PicId .. "_big.jpg"
                fileName = requestData.PicId .. "_big.jpg"
            else
               filePath = self.DownloadPicPath .. requestData.PicId .. "_smal.jpg"
               fileName = requestData.PicId .. "_smal.jpg"
            end
            local _downReq = L_DownloadRequest:New(nil, requestData.PicId, TexHttpSyncType.HeadPic, requestData.BigOrSmal, filePath, fileName)
            _downReq:OnFinish(0)
        else
            _resultCode = 10
            Debug.LogError("Determine the query return code failed DataAsText =" .. _text)
        end
        break
    end
    if _resultCode ~= 0 then
        -- Check failed, delete local resources
        local _downPath = nil
        if requestData.BigOrSmal then
            _downPath = self.DownloadPicPath .. requestData.PicId .. "_big.jpg"
        else
            _downPath = self.DownloadPicPath .. requestData.PicId .. "_smal.jpg"
        end
        if File.Exists(_downPath) then
            -- Delete the download directory file
            File.Delete(_downPath)
        end
        requestData:OnFinish(_resultCode)
    end
end

 -- Query return
function TexHttpSyncSystem:OnQueryRestlt(originalRequest, response, requestData)
    local _resultCode = -999
    while(true) do
        if response == nil then
            _resultCode = 1
            Debug.LogError(originalRequest.Exception)
            break
        end
        local _text = response.DataAsText
        if _text == nil or string.len(_text) <= 0 then
            -- Upload failed
            _resultCode = 2
            Debug.LogError("Query failed StatusCode =" .. response.StatusCode)
            break
        end
        local _resultJson = Json.decode(_text)
        if _resultJson == nil then
            -- Resolve upload failed
            _resultCode = 3
            Debug.LogError("Parsing query returns failed DataAsText =" .. _text)
            break
        end
        -- Upload return: {"photoID":photoID}
        local stateCode = tonumber(_resultJson.stateCode)
        if stateCode == nil then
            -- No id field
            _resultCode = 4
            Debug.LogError("The parsing query return code failed DataAsText =" .. _text)
            break
        end
        if stateCode == 0 then -- No data found
            _resultCode = 6
            Debug.LogError("The server has no data DataAsText =" .. _text)
            break
        elseif stateCode == 1 then -- The review failed
            _resultCode = 7
            Debug.LogError("Failed to review DataAsText =" .. _text)
            break
        elseif stateCode == 2 then -- Under review
            _resultCode = 8
            Debug.LogError("Under review DataAsText =" .. _text)
            break
        elseif stateCode == 3 then -- Can be downloaded
            local _address = _resultJson.photoAbsolutePath
            if _address == nil or string.len(_address) <= 0 then
                _resultCode = 9
                Debug.LogError("Download address resolution failed DataAsText =" .. _text)
                break
            end
            _address = string.gsub(_address, "\"", "")
            -- Start download
            _resultCode = 0
            self:ReqDownload(_address, requestData.PicId, requestData.PicType, requestData.BigOrSmal)
            Debug.LogError("The query is successful, start downloading =" .. _address)
        else
            _resultCode = 10
            Debug.LogError("Determine the query return code failed DataAsText =" .. _text)
        end
        break
    end
    requestData:OnFinish(_resultCode)
end

 -- Start download
function TexHttpSyncSystem:ReqDownload(address, picId, picType, bigOrSmal)
     -- Create a query
     local _uri = L_Uri(address)
     local _httpReq = L_HTTPRequest(_uri, L_HTTPMethods.Get)
     local filePath = nil
     local fileName = nil
     if bigOrSmal then
         filePath = self.DownloadPicPath .. picId .. "_big.jpg"
         fileName = picId .. "_big.jpg"
     else
        filePath = self.DownloadPicPath .. picId .. "_smal.jpg"
        fileName = picId .. "_smal.jpg"
     end
     local _downReq = L_DownloadRequest:New(_httpReq, picId, TexHttpSyncType.HeadPic, bigOrSmal, filePath, fileName)
     _httpReq.Callback = function(originalRequest, response)
         self:OnDownLoadResult(originalRequest, response, _downReq)
     end
     self.DownloadQue:Add(_downReq)
end
 -- Download Return
function TexHttpSyncSystem:OnDownLoadResult(originalRequest, response, requestData)
    local _resultCode = -999
    while(true) do
        if response == nil then
            _resultCode = 1
            Debug.LogError(originalRequest.Exception)
            break
        end
        local _tex2d = L_TexSyncUtils.CovertToTex(response, requestData.FilePath)
        _tex2d.name = requestData.FileName
        -- Save to manager
        GameCenter.TextureManager:SaveTexture(requestData.FilePath, _tex2d)
        _resultCode = 0
        Debug.LogError("Download successfully" .. requestData.FilePath)
        break
    end
    requestData:OnFinish(_resultCode)
end

return TexHttpSyncSystem