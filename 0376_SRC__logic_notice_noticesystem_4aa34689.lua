------------------------------------------------
-- Author:
-- Date: 2020-01-07
-- File: NoticeSystem.lua
-- Module: NoticeSystem
-- Description: Announcement prompt system
------------------------------------------------
local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils");
local SDKCacheData = CS.Thousandto.CoreSDK.SDKCacheData

local NoticeSystem=
{
    -- Login announcement
   NoticeType_Login = "login",
    -- Update maintenance announcement
    NoticeType_Updae = "update",
    -- Real-time announcement
    NoticeType_Now = "activity",

    -- Announcement version number, save locally, determine whether the version is different each time to determine whether the announcement content is displayed
    Prefer_Version = "NoticeVerstion",

    -- Whether it pops up automatically
    IsAutoPop = false,
    -- Announcement title
    Title = nil,
    -- Announcement content
    Content = nil,
    -- Current announcement type
    CurrentNoticeType = nil,

    -- Is data requested?
    Requesting = nil,
    -- Announcement url prefix
    NoticeUrl = nil,

    IsFirstLogin = true;
    -- Announcement corresponding type Dictionary<int, List<Notice>>
    NoticeDic = nil,
    -- Download announcement queue Queue<int>
    DownloadNoticeList = nil,

    -- The callback handle after the announcement list is downloaded
    OnNoticeDownloadFinishHandler = nil,  
    -- Announcement list download failed callback handle
    OnDownloadFailHandler = nil,
};

-- Announcement Type
local NoticeType =
{
    -- Announcements that open automatically are generally login maintenance announcements
    Update = 0,
    -- Manually click on the login announcement button
    Login = 1,
    -- Manually click on the event announcement button
    Action = 2,
}

function NoticeSystem:Initialize()
    self.OnNoticeDownloadFinishHandler = Utils.Handler(self.OnNoticeDownloadFinish,self,nil,true);
    self.OnDownloadFailHandler = Utils.Handler(self.OnDownloadFail,self,nil,true);
    self.NoticeDic = Dictionary:New()
    self.DownloadNoticeList = List:New()
end

function NoticeSystem:UnInitialize()
    self.OnNoticeDownloadFinishHandler = nil;
    self.OnDownloadFailHandler = nil;
    self.NoticeDic = nil
    self.DownloadNoticeList = nil
end

-- Get the announcement content
function NoticeSystem:GetNoticeByType(noticesType)
    if (self.NoticeDic:ContainsKey(noticesType)) then
        return self.NoticeDic[noticesType];
    end
    return nil;
end

-- Get the currently visible announcement
function NoticeSystem:GetCurrentNotice()
    return self:GetNoticeByType(self.CurrentNoticeType);
end

function NoticeSystem:OnNoticeDownloadFinish(wwwText)
    -- If www is not empty, it means downloaded through the url.
    if wwwText ~= nil and wwwText ~= "" then
        -- Close the waiting interface in advance
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
        local jsNode = Json.decode(wwwText)
        -- Status code; 1: Success, 16: Invalid request parameters 15: System internal exception
        local state = jsNode.state
        if (state ~= 1) then
            Debug.LogError("The content of the announcement data obtained is incorrect: state="..state);
            return
        end

        local _jsonData = jsNode.data
        if _jsonData ~= nil and _jsonData.notices ~= nil and #_jsonData.notices > 0 then
            local _type = _jsonData.notices[1].type
            if (_type == NoticeType.Login or _type == NoticeType.Update) then
                self:parseLoginOrUpdateNotice(_jsonData.notices, _type);
            else
                self:parseActivityNotice(_jsonData.notices, _type);
            end
        else
            Debug.LogError("The content of the announcement data obtained is incorrect: No announcement data is configured!");
        end

        self.Requesting = false;
    else
        Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK","C_LOGIN_DOWNLOAD_SERVER_LIST_FAIL");
    end
end

function NoticeSystem:OnDownloadFail(errCode, error)
    if (errCode <= 0 ) then
        
     else
                 
     end
end

-- Analysis login announcement
function NoticeSystem:parseLoginOrUpdateNotice(jsonData, noticeType)
    if (#jsonData > 0) then
        -- There are multiple login announcements, only the latest one is displayed
        local noticeData = jsonData[1];

        -- auto Int No Whether it pops up automatically 0: It doesn’t pop up automatically 1: It pops up automatically
        self.IsAutoPop = noticeData.auto == 1
        self.Title = noticeData.title
        self.Content = noticeData.content
        -- Save data
        self:saveNotice(noticeType, self.Title, self.Content);
        if (self.IsAutoPop) then
            -- Open ui
            self:OpenLoginNoticeUI(noticeType);
            -- Refresh ui data
            self:RefreshLoginNoticeUI();
        end
    end
    self.IsFirstLogin = false;
    return true;
end

-- Analysis of activity announcement
function NoticeSystem:parseActivityNotice(jsonData, noticeType)
    if (jsonData == nil) then
        return false;
    end

    if (self.NoticeDic:ContainsKey(noticeType)) then
        self.NoticeDic[noticeType]:Clear();
    end

    self.Title = nil
    self.Content = nil

    for i = 1, #jsonData do
        -- There are multiple login announcements, only the latest one is displayed
        local noticeData = jsonData[i];
        if (noticeData == nil) then return false end;

        if (noticeData.auto ~= nil) then
            -- auto Int No Whether it pops up automatically 0: It doesn’t pop up automatically 1: It pops up automatically
            self.IsAutoPop = tonumber(noticeData.auto) == 1;
        end
        self.Title = noticeData.title
        self.Content = noticeData.content

        if (self.Title == nil or self.Content == nil) then
            return false;
        end
        self:saveNotice(noticeType, self.Title, self.Content);
    end
    return true;
end

function NoticeSystem:GetNoticesURL()
    -- local _url = GameCenter.ServerListSystem.ServerUrlInfo:GetDefaultURL()
    -- if (SDKCacheData.AppID ~= nil and SDKCacheData.AppID ~= "") then
    --     self.NoticeUrl = string.format("%s/PlatformKits/queryNotice?chn_id=%s",_url,SDKCacheData.ChannelID)
    -- else
    --     self.NoticeUrl = string.format("%s/PlatformKits/queryNotice?chn_id=73",_url)
    -- end
    -- self.NoticeUrl = string.format("%s/PlatformKits/queryNotice?chn_id=%s",_url, channelID)

    local _url = GameCenter.ServerListSystem.ServerUrlInfo:GetNotifyURL()
    local channelID = CS.UnityEngine.Gonbest.MagicCube.AppManager.Instance:GetLocalVersionValue("ChannelID")


    -- self.NoticeUrl = string.format("%s?chn_id=%s",_url, channelID)
    -- kiểm tra nếu đã có "?" thì nối thêm bằng "&", ngược lại nối bằng "?"
    local sep = "?"
    if string.find(_url, "?", 1, true) then
        sep = "&"
    end

    self.NoticeUrl = string.format("%s%schn_id=%s", _url, sep, channelID)


    if L_UnityUtils.UNITY_EDITOR() then    
        Debug.LogError("NoticeUrl:"..self.NoticeUrl);
    end
    return self.NoticeUrl;
end

-- Start requesting announcement data
function NoticeSystem:ReqNoticeData(noticeType, serverID)
    local e_type = noticeType;
    self.CurrentNoticeType = noticeType;

    -- If you have finished downloading, don't download again
    if (e_type ~= NoticeType.Action and self.NoticeDic:ContainsKey(noticeType)) then
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
        self:RefreshLoginNoticeUI();
        -- Let the announcement be re-downloaded every time
        --return true;
    end

    self:addDownloadType(e_type);
    self:startDownload();
    return true;
end

-- Start downloading announcement
function NoticeSystem:startDownload()
    if (self.DownloadNoticeList:Count() <= 0) then
        -- UnityEngine.Debug.Log("No announcement queue to download");
        return;
    end

    if (self.Requesting) then
        return;
    end

    self.Requesting = true;
    LuaCoroutineUtils.WebRequestText(self:GetNoticesURL(), self.OnNoticeDownloadFinishHandler, self.OnDownloadFailHandler, nil);
end

-- Add download announcement type to queue
function NoticeSystem:addDownloadType(noticeType)
    if (not self.DownloadNoticeList:Contains(noticeType)) then
        self.DownloadNoticeList:Add(noticeType)
        --self.DownloadNoticeList:Enqueue(type);
    end
end

-- Is the announcement first displayed today
function NoticeSystem:totayFirstShowNotice()
    local date = PlayerPrefs.GetString("TotayFirstShowNotice");
    local totay = Time.StampToDateTime(os.time() ,"yyyy-MM-dd")
    if (date ~= totay) then
        PlayerPrefs.SetString("TotayFirstShowNotice", totay);
        return true;
    end
    return false;
end

-- Save announcement information into memory
function NoticeSystem:saveNotice(noticeType, title, content)
    if (self.NoticeDic:ContainsKey(noticeType)) then
        local notice = {Title = "", Content = ""};
        notice.Title = title;
        notice.Content = content;
        self.NoticeDic[noticeType].Add(notice);
    else
        local notice = {Title = "", Content = ""};
        notice.Title = title;
        notice.Content = content;
        local noticeList = List:New()
        noticeList:Add(notice);
        self.NoticeDic:Add(noticeType, noticeList);
    end
end

function NoticeSystem:RefreshLoginNoticeUI()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOGINNOTICE_REFRESH);
end

-- Open the announcement panel
function NoticeSystem:OpenLoginNoticeUI(noticeType)
    GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, noticeType);
end

-- Close the announcement panel
function NoticeSystem:CloseLoginNoticeUI()
    GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_CLOSE);
end

return NoticeSystem;
