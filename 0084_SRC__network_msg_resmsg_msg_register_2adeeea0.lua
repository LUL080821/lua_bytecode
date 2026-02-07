local MSG_Register = {}
local Network = GameCenter.Network
function MSG_Register.RegisterMsg()
    Network.CreatRespond("MSG_Register.ResLoginGameFailed",function (msg)
        GameCenter.LoginSystem:GS2U_ResLoginGameFailed(msg);
    end)

    Network.CreatRespond("MSG_Register.ResLoginGameSuccess",function (msg)
        GameCenter.LoginSystem:GS2U_ResLoginGameSuccess(msg);
        -- Set the server time zone
        GameCenter.HeartSystem:SetServerZoneOffset(msg.timezone);
    end)

    Network.CreatRespond("MSG_Register.ResPlayerMapInfo",function (msg)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UPDATE_RECORDER_STEP, { CS.Thousandto.Update.Recorder.StepType.SelectRole });        
        -- Start heartbeat message
        GameCenter.HeartSystem:EnabelHeartMsg(true);
        -- Only when you enter the main scene of the game are disconnected and reconnected
        GameCenter.ReconnectSystem:SetEnable(true);
        -- Hide login scene
        GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE);
        GameCenter.PushFixEvent(UIEventDefine.UICREATEPLAYERFORM_CLOSE,1);
        GameCenter.Network.StartThread();    

        GameCenter.GameSceneSystem:StartChangeToMap(msg.mapId, msg.lineId, Vector2(msg.x, msg.z));

        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);

        GameCenter.LoginSystem:PostChangeLoginData(msg.roleId);
        GameCenter.BISystem:ReqBiDevice();        
    end)

    Network.CreatRespond("MSG_Register.ResSubstitute",function (msg)
       -- If you are kicked off the line, you are not allowed to disconnect and reconnect.
        GameCenter.ReconnectSystem:SetEnable(false);
        Utils.ShowMsgBoxAndBtn(function ()
            GameCenter.Network.Disconnect();
            GameCenter.GameSceneSystem:ReturnToLogin();
        end,"C_MSGBOX_OK",nil,"C_MSG_REGISTER_MULTI_LOGIN");
    end)

    
    Network.CreatRespond("MSG_Register.ResQuit",function (msg)
        -- 1;--Exit normally
        -- -1;--The heartbeats fast
        -- -2;--The heartbeat stopped
        -- -3;--gm command to kick off the line
        -- -4;--socket disconnection and exit

        --GameCenter.GameCaseSystem.GetCurrentTickCase().ChangeToState(GameStateId.Login);
        -- Debug.LogError("quit:: " .. msg.reason);
        if msg.reason == 0 or msg.reason == 1 then            
            -- Log in normally, feedback directly
        elseif msg.reason == -1 or msg.reason == -2 or msg.reason == -3  then
            GameCenter.ReconnectSystem:SetEnable(false);
            Utils.ShowMsgBoxAndBtn(function ()                
                GameCenter.GameSceneSystem:ReturnToLogin();
            end,"C_MSGBOX_OK",nil,"C_NETWORK_LOST_CONNECTION");
        elseif msg.reason == -4 then
            -- The network is disconnected and not processed
        else
            -- Other errors that don't know the reason
            GameCenter.ReconnectSystem:SetEnable(false);
            Utils.ShowMsgBoxAndBtn(function ()                
                GameCenter.GameSceneSystem:ReturnToLogin();
            end,"C_MSGBOX_OK",nil,"C_NETWORK_DISCONNECT");    
        end
    end)


    Network.CreatRespond("MSG_Register.ResCreateRoleFailed",function (msg)
        GameCenter.PlayerRoleListSystem:GS2U_ResCreateRoleRet(msg);    
        -- Phát sự kiện để các listener khác có thể lắng nghe
        GosuSDK.GoSuDispatchEvent("ResCreateRoleError", msg)    
    end)

    Network.CreatRespond("MSG_Register.ResDeleteRoleSuccess",function (msg)
        GameCenter.PlayerRoleListSystem:GS2U_ResDeleteRoleSuccess(msg);
    end)

    Network.CreatRespond("MSG_Register.ResRegainRoleResult",function (msg)
        GameCenter.PlayerRoleListSystem:GS2U_ResRegainRoleResult(msg);
    end)

    Network.CreatRespond("MSG_Register.ResSelectCharacterFailed",function (msg)
        GameCenter.PlayerRoleListSystem:GS2U_ResSelectCharacterFailed(msg);
    end)

end
return MSG_Register

