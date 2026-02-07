------------------------------------------------
-- Author:
-- Date: 2021-02-25
-- File: ServerUrlInfo.lua
-- Module: ServerUrlInfo
-- Description: Get information from the server address
------------------------------------------------
local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils");
local SDKCacheData = CS.Thousandto.CoreSDK.SDKCacheData;

local ServerUrlInfo = {
    -- serverlist address, SDK returns
    ServerListURL = nil,
    -- The address of the login server
    LoginServerUrl = nil,
}

-- Constructor
function ServerUrlInfo:New()
    local _m = Utils.DeepCopy(self);
    return _m;
end

function ServerUrlInfo:GetDefaultURL()
    local _url = CS.Thousandto.Code.Center.GameCenter.GameServerListUrl
    if(_url == nil or _url == "") then
        print("GetDefaultURL: GameCenter:GetGameServerListUrl() is nil")
        _url = CS.UnityEngine.Gonbest.MagicCube.AppManager.Instance:GetLocalVersionValue("ServerKitURL");
        _url = _url + "/PlatformKits/queryServerList";
    end
    if L_UnityUtils.UNITY_EDITOR() then
        Debug.Log("GetDefaultURL:" .. _url);
    end
    if not _url then
        -- _url = "http://182.151.35.7:9090"; 
        --_url = "http://s33.oneteam.vn:8080/PlatformKits/queryServerList"; 
        _url = "https://gmt6100.oneteam.vn/api/queryServerList"
    end
    return _url;
end

function ServerUrlInfo:GetNotifyURL()
    local _url = CS.Thousandto.Code.Center.GameCenter.GameNotifyURL
    -- if L_UnityUtils.UNITY_EDITOR() then    
    --     _url = "http://s33.oneteam.vn:8080/PlatformKits/queryNotice"; 
    -- end
    if(_url == nil or _url == "") then
        --_url = "http://s33.oneteam.vn:8080/PlatformKits/queryNotice"; 
        _url = "https://gmt6100.oneteam.vn/api/queryNotice"
    end

    if (TESTING_MODE) then 
        _url = "https://gmt6100.oneteam.vn/api/queryNotice"
    end
    
    local lan = FLanguage.Default;
    if (FLanguage.Default == nil or FLanguage.Default == "") then
        lan = "en";
    end
    lan = string.lower(lan);

    -- _url = _url .. "?l=".. lan

    -- thêm param l=
    if string.find(_url, "?", 1, true) then
        _url = _url .. "&l=" .. lan
    else
        _url = _url .. "?l=" .. lan
    end

    if (SUBMIT_MODE) then 
        if string.find(_url, "?", 1, true) then
            _url = _url .. "&type=sm"
        else
            _url = _url .. "?type=sm"
        end
    end
 
    if L_UnityUtils.UNITY_EDITOR() then
        print("GetNotifyURL:" .. _url);
    end

    return _url;
end

function ServerUrlInfo:GetSceneID()
    local _sceneID = CS.UnityEngine.Gonbest.MagicCube.AppManager.Instance:GetLocalVersionValue("platform_fid");
    if L_UnityUtils.UNITY_EDITOR() then
        Debug.Log("GetSceneID:" .. _sceneID);
    end
    if not _sceneID then
        _sceneID = "qx"; 
    end
    return _sceneID;
end

-- Get the address of the login server list
-- function ServerUrlInfo:GetLoginServerURL()    
--     if (SDKCacheData.AppID == nil or SDKCacheData.AppID =="") then
--         self.LoginServerUrl = string.format("%s/api/app/list.do?app_id=16", SDKCacheData.DefaultURL);     
--     else
-- --Domain name Application number
--         self.LoginServerUrl = string.format("%s/api/app/list.do?app_id=%s", GameCenter.SDKSystem.SDKImplement:GetServerUrl(), SDKCacheData.AppID);
--     end
--     return self.LoginServerUrl;
-- end


-- Get the address of the game server list
-- function ServerUrlInfo:GetServerListURL()
    -- if (SDKCacheData.AppID == nil or SDKCacheData.AppID =="") or (SDKCacheData.ChannelID == nil or SDKCacheData.ChannelID =="") then
    --     self.ServerListURL = string.format("%s/api/svr/list.do?app_id=16&chn_id=10&sec_id=%s", SDKCacheData.DefaultURL,self:GetSceneID());  
    -- else
    -- --Domain name Application number Channel number
    --     self.ServerListURL = string.format("%s/api/svr/list.do?app_id=%s&chn_id=%s&user_id=%s&sec_id=%s&client_version=%s",
    --     GameCenter.SDKSystem.SDKImplement:GetServerUrl(),
    --     SDKCacheData.AppID,
    --     SDKCacheData.ChannelID,
    --     SDKCacheData.PlatformUID,
    --     self:GetSceneID(), 
    --     AppPersistData.AppVersion);
    -- end
     
    -- return self.ServerListURL;
-- end


-- Get the address of the game server list
function ServerUrlInfo:GetServerListNewURL()
    -- if (SDKCacheData.AppID == nil or SDKCacheData.AppID =="") or (SDKCacheData.ChannelID == nil or SDKCacheData.ChannelID =="") then
        -- self.ServerListURL = string.format("%s/PlatformKits/queryServerList?chn_id=10&sec_id=%s", self:GetDefaultURL(),self:GetSceneID());  
    -- else
    -- --Domain name Application number Channel number
    --     self.ServerListURL = string.format("%s/PlatformKits/queryServerList?chn_id=%s&user_id=%s&sec_id=%s&client_version=%s",
    --     self:GetDefaultURL(),        
    --     SDKCacheData.ChannelID,
    --     SDKCacheData.PlatformUID,
    --     self:GetSceneID(), 
    --     AppPersistData.AppVersion);
    -- end
    local channelID = CS.Thousandto.Code.Center.GameCenter.GameChannelId;
    if(channelID == nil or channelID == "") then
        channelID = CS.UnityEngine.Gonbest.MagicCube.AppManager.Instance:GetLocalVersionValue("ChannelID")
    end

    self.ServerListURL = string.format("%s?chn_id=%s", self:GetDefaultURL(),channelID);
    if L_UnityUtils.UNITY_EDITOR() then
        -- self.ServerListURL = "http://s33.oneteam.vn:8080/PlatformKits/queryServerList?chn_id=10"
        -- self.ServerListURL = "https://gmt9871.oneteam.vn/api/queryServerList?chn_id=0" --- live
        self.ServerListURL = "https://gmt6100.oneteam.vn/api/queryServerList?chn_id=0"
    end
    if (TESTING_MODE) then 
        -- self.ServerListURL = "http://s33.oneteam.vn:8080/PlatformKits/queryServerList?chn_id=10"
        self.ServerListURL = "https://gmt6100.oneteam.vn/api/queryServerList?chn_id=0"
    end
    if (SUBMIT_MODE) then 
        self.ServerListURL = "https://gmt6100.oneteam.vn/api/queryServerList?chn_id=0"
        self.ServerListURL = self.ServerListURL .. "&type=sm"
    end
    if (LOCAL_TESTER) then 
        self.ServerListURL = "https://gmt6100.oneteam.vn/api/queryServerList?chn_id=0"
        self.ServerListURL = self.ServerListURL .. "&type=local"
    end
    local lan = FLanguage.Default;
    if (FLanguage.Default == nil or FLanguage.Default == "") then
        lan = "en";
    end
    lan = string.lower(lan);

    self.ServerListURL = self.ServerListURL .. "&l=".. lan

    if L_UnityUtils.UNITY_EDITOR() then
        print("ServerListURL:"..self.ServerListURL);
    end
    return self.ServerListURL;
end


return ServerUrlInfo;