------------------------------------------------
-- Author:
-- Date: 2020-11-12
-- File: PlayerRoleListSystem.lua
-- Module: PlayerRoleListSystem
-- Description: Player character list system
------------------------------------------------
local RandomNameMaker = require("Logic.PlayerRoleList.RandomNameMaker")
local PlayerRoleInfo =  require("Logic.PlayerRoleList.PlayerRoleInfo")
local ServerCharInfo = require("Logic.ServerList.ServerCharInfo");
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local LocalPlayerRoot = CS.Thousandto.Code.Logic.LocalPlayerRoot

local PlayerRoleListSystem = {
    -- Name maximum length and minimum length
    MaxNameLength = 28,
    MinNameLength = 2,

    -- Select role ID sent by the server
    SerSelectedRoleID = 0,
    -- Role List
    RoleList = List:New(),

    -- Current server list
    ServerID = -1,

    -- Delay deletion level
    DelayDeleteLevel = 100,

    -- Random name generator
    RandNameMaker = nil,

    -- Career opening list
    OccOpenList = nil,
}

-- initialization
function PlayerRoleListSystem:Initialize(clearLoginData)
    Debug.Log("PlayerRoleListSystem:Initialize:" .. tostring(clearLoginData));
    -- Re-associate events, because all registered events will be cleaned up in a cycle of reincarnation.
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS,self.GS2U_ResLoginGameSuccess,self);    
    -- Initialization after the player character list system is cleaned
    if clearLoginData then
        -- Maximum and minimum length of character name
        -- local _cfg = DataConfig.DataGlobal[47]
        -- if _cfg then
        --     local _val = _cfg.Params; 
        --     if _val then
        --         local _t = Utils.SplitNumber(_val,"_");
        --         print("=====================================================================yttttttttttttttttttttttttttt==")
        --         print(Inspect(_t))
        --         if _t:Count() >= 2 then
        --             self.MaxNameLength = _t[1];    
        --             self.MinNameLength = _t[2];    
        --         end    
        --     end
        -- end  

        -- Delay deletion level
        _cfg = DataConfig.DataGlobal[1810]
        if _cfg then
            local _val = _cfg.Params; 
            if _val then
                local _t = tonumber(_val);
                if _t > 0 then
                    self.DelayDeleteLevel = _t;
                end    
            end
        end        
    else
        -- The process after the player character list system is not cleaned
        self:RefreshFromLocalPlayer();
    end
end

-- Uninstall processing
function PlayerRoleListSystem:UnInitialize(clearLoginData)
    Debug.Log("PlayerRoleListSystem:UnInitialize:" .. tostring(clearLoginData));
    -- Re-associate events, because all registered events will be cleaned up in a cycle of reincarnation.
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_GAME_LOGIN_SUCCESS,self.GS2U_ResLoginGameSuccess,self);
    if clearLoginData then
        
    end
end

-- Get a random name
function PlayerRoleListSystem:GetRandomName(occ)
    if not self.RandNameMaker then
        self.RandNameMaker = RandomNameMaker:New();
        self.RandNameMaker:Initialize();
    end
    return self.RandNameMaker:RandName(Utils.OccToSex(occ) == 0)
end



-- Get the name of the profession
function PlayerRoleListSystem:GetOccName(occ)
    local _cfg = DataConfig.DataPlayerOccupation[occ];
    if _cfg then
        return _cfg.JobName;
    end
    return "";
end

-- Is the occupation effective?
function PlayerRoleListSystem:OccIsValid(occ)
    if not self.OccOpenList then
       local _cfg = DataConfig.DataGlobal[GlobalName.Open_Occupatio_List];
       Debug.LogError(_cfg.Params);
       self.OccOpenList = Utils.SplitNumber(_cfg.Params, '_');
    end
    --fix yy
    return true
    -- return self.OccOpenList:Contains(occ);
end

-- Get the server role list through the current role list
function PlayerRoleListSystem:GetServerCharList()
    local _result = List:New();
    for i = 1, self.RoleList:Count()do
        local _scInfo = ServerCharInfo:New();
        _scInfo.ID = self.RoleList[i].RoleId;
        _scInfo.Career = self.RoleList[i].Career;
        _scInfo.Level = self.RoleList[i].Level;
        _scInfo.Name = self.RoleList[i].Name;
        _scInfo.PowerValue = self.RoleList[i].PowerValue;
        _result:Add(_scInfo);
    end    
    return result;
end

-- Get the role ID in use
function PlayerRoleListSystem:GetUsedCharacter()
    if self.SerSelectedRoleID <= 0 then
        return AppPersistData.LastRoleID;
    else
        return self.SerSelectedRoleID;
    end
end
-- Determine whether to create a role
function PlayerRoleListSystem:CheckInCreateRole()
    if (self.RoleList:Count() > 0) then
        -- When there is no selected role, the number of roles created is still not enough
        if (self.SerSelectedRoleID == -1 and self.RoleList:Count() < 4) then
            return true;
        end
        return false;
    end
    return true;
end

-- Refreshing role information through local roles
function PlayerRoleListSystem:RefreshFromLocalPlayer()
    local _lp = LocalPlayerRoot.LocalPlayer;
    if _lp then
        self.SerSelectedRoleID = _lp.ID;
        GameCenter.LoginSystem.SerSelectedRoleID = _lp.ID;
        local _findRole = nil;
        for i = 1, self.RoleList:Count() do
            if self.RoleList[i].RoleId == self.SerSelectedRoleID then
                _findRole = self.RoleList[i];
                _findRole:FillFromLocalPlayer(_lp);
                break;
            end
        end                
        if not _findRole then
            _findRole = PlayerRoleInfo:New(lp);
            self.RoleList:Add(_findRole);
        end
    end
end

-- #region //Send network messages

-- Send a Create Role Message
function PlayerRoleListSystem:SendCreateRoleMsg(name, career, isRandom)

    local _req = ReqMsg.MSG_Register.ReqCreateCharacter:New();
    _req.playerName = name;
    _req.career = career or 0;
    _req.isRandom = isRandom or false;
    local _csDevice = GameCenter.BISystem:CreatDevictData();
    _req.device = {
        appId = _csDevice.appId,
        roleId = _csDevice.roleId,
        channelId = _csDevice.channelId,
        sourceId = _csDevice.sourceId,
        deviceId = _csDevice.deviceId,
        platform = _csDevice.platform,
        app_version = _csDevice.app_version,
        merchant = _csDevice.merchant,
        net_type = _csDevice.net_type,
        screen = _csDevice.screen,
        os = _csDevice.os,
        os_version = _csDevice.os_version,
        server_name = _csDevice.server_name,
        cpgameId = _csDevice.cpgameId,
        cpdid = _csDevice.cpdid,
        cpdevice_name = _csDevice.cpdevice_name,
        cpplatformId = _csDevice.cpplatformId,
        cpuserid = _csDevice.cpuserid,
        cpuserName = _csDevice.cpuserName,
        cpgameName = _csDevice.cpgameName,
        cpPlatformGname = _csDevice.cpPlatformGname,
    };
    _req:Send();
end

-- Delete roles
function PlayerRoleListSystem:SendDeleteRole(roleId)
    local _reqMsg = ReqMsg.MSG_Register.ReqDeleteRole:New()
    _reqMsg.roleId = roleId
    _reqMsg:Send()
end

-- Restore role
function PlayerRoleListSystem:SendRegainRole(roleId)
    local _reqMsg = ReqMsg.MSG_Register.ReqRegainRole:New()
    _reqMsg.roleId = roleId
    _reqMsg:Send()
end

--#endregion      
                  
-- #region //Network protocol callback

-- Deleting the role successfully
function PlayerRoleListSystem:GS2U_ResDeleteRoleSuccess(result)

    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if (result.res == 0) then
        -- Deleting the role successfully
        local _item = self.RoleList:Find(function (x)
            return x.RoleId == result.playerId;
        end);
        if _item then
            if (_item.Level >= self.DelayDeleteLevel) then
                _item.DeleteTime = TimeUtils.GetNow();            
            else            
                self.RoleList:Remove(_item);
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_DELPLAYER, result.playerId);    
    elseif result.res ==1 then
        -- Failed to delete a role
        Debug.Log("Failed to delete a role, return the reason code:" .. result.res);        
        Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_DELETE_FAIL_ROLE_IS_CHAIRMAN")        
    else
        -- Failed to delete a role
        Debug.Log("Failed to delete a role, return the reason code:" .. result.res);
        Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_DELETE_FAIL_ROLE_UNKNOW")     
    end
end

-- Recovery of role results
function PlayerRoleListSystem:GS2U_ResRegainRoleResult(result)
    if result.result == 0 then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CREATEPLAYER_RECOVERPLAYER, result.roleId);
        local _item = self.RoleList:Find(function (x)
            return x.RoleId == result.roleId;
        end);
        if _item then
            _item.DeleteTime = -1;
        end    
    else
        Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_REGISTER_REGAINROLE_FAIL");
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);    
end

-- Create role return
function PlayerRoleListSystem:GS2U_ResCreateRoleRet(result)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE); 
    if result.reason == 0  then
        -- Create role successfully
        Debug.Log("CreatePlayer success");    
        -- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.CreateRole });                    
        GameCenter.SDKSystem.CreateRoleTime = result.time;    
        GameCenter.SDKSystem.IsCreatePlayerFlag = true;    
        GameCenter.SDKSystem:SetLevelInfoWhileFirstEnterGame(1);
        GameCenter.SDKSystem:DealMessage(5);
        GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.CreatePlayerOK);
    else
        GameCenter.SDKSystem.IsCreatePlayerFlag = false; 
        -- Reason for failure (1-There is already a role 2-The name is too long 3-The name contains illegal characters 4-The name is duplicate 5-The parameter is incorrect)
        local _errstrList ={
            [1] = DataConfig.DataMessageString.Get("C_MSG_REGISTER_CREATEPLAYER_FAIL_EXIST"),
            [2] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_NAMELEN",self.MinNameLength,self.MaxNameLength),
            [3] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_INVALID"),
            [4] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_SIGNED"),
            [5] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_SYMBOL"),
            [6] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_SYMBOL"),
            [7] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_REG_MAX"),
            [8] = DataConfig.DataMessageString.Get("C_CREATEPLAYER_ERROR_REG_MAX"),        
        };
        local _errorStr = _errstrList[result.reason];

        if not _errorStr then
            _errorStr = DataConfig.DataMessageString.Get("C_MSG_REGISTER_CREATEPLAYER_FAIL_UNKNOWN");
        end
        -- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.CreateRole, result.reason, errorStr });
        Debug.LogError("CreatePlayer Failed!!::" .. tostring(result.reason) .."::".. tostring(_errorStr));
        GameCenter.MsgPromptSystem:ShowMsgBox(_errorStr, DataConfig.DataMessageString.Get("C_MSGBOX_OK"));
        -- GameCenter.UIFormManager:ShowUITop2DCamera(true);
        --Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", _errorStr)
    end
end

-- Failed to enter the game by selecting a character
function PlayerRoleListSystem:GS2U_ResSelectCharacterFailed(result)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PLAYER_FORBIDDEN, result.forbidTime);
end

-- Message processing for successful login game---called in LoginSystem.
function PlayerRoleListSystem:GS2U_ResLoginGameSuccess(result)
    Debug.Log("Login successfully!! selectedRoleID:" .. tostring(result.roleId));    
    self.SerSelectedRoleID = result.roleId;
    GameCenter.LoginSystem.SerSelectedRoleID = result.roleId;
    self.RoleList:Clear();
    if result.infoList then
        Debug.Log("charListCount:" .. tostring(#(result.infoList)));
        for index, value in ipairs(result.infoList) do
            local _pri = PlayerRoleInfo:New();            
            _pri:FillFromServerMsg(value);
            self.RoleList:Add(_pri);
        end
    end
end


--#endregion

return PlayerRoleListSystem