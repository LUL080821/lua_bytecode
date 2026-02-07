local MSG_Player = {}
local Network = GameCenter.Network

function MSG_Player.RegisterMsg()
    Network.CreatRespond("MSG_Player.ResPlayerOnLineAttribute", function(msg)
        -- TODO
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ONLINE_REFRESH_ATT)
    end)

    Network.CreatRespond("MSG_Player.ResPlayerAttributeChange", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPlayerBaseInfo", function(msg)
        -- TODO
        GameCenter.LuaCharacterSystem:ResPlayerBaseInfo(msg)
        GameCenter.PlayerVisualSystem:ResPlayerBaseInfo(msg);
        GameCenter.SoulEquipSystem:SetCurWearEquipID(msg.facade.soulArmorId)
    end)

    Network.CreatRespond("MSG_Player.ResChangeJobResult", function(msg)
    end)

    Network.CreatRespond("MSG_Player.ResAddHatred", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResDelHatred", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResLevelChange", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPracticeInfo", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPracticeSetDo", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPracticeGetResult", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResAccunonlinetime", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResUpdataExpRate", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResUpdataPkValue", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResUpdataPkStateResult", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResCleanHatred", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPlayerFightPointChange", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResLookOtherPlayerResult", function(msg)
        -- TODO
        GameCenter.PlayerVisualSystem:ResLookOtherPlayerResult(msg);
        GameCenter.PushFixEvent(UIEventDefine.UILookOterPlayerForm_OPEN, msg);
    end)

    Network.CreatRespond("MSG_Player.ResFightOrUnFight", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResMainUIGuideID", function(msg)
        -- TODO
    end)

    -- Number of days for players to log in
    Network.CreatRespond("MSG_Player.ResPlayerTodayData", function(msg)
        GameCenter.ShareAndLikeSystem:SetLoginDays(msg.accumOnlineDays);
    end)

    Network.CreatRespond("MSG_Player.ResChangeRoleNameResult", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResMaxHpChange", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResClientToChoiceBirthGroup", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResNotUpLevel", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResChangeJobTips", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPeakLevelPanel", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResChangeJobPanel", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResActiveFateStar", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPlayerGenderNotice", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResUpgradeBlood", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResOpenBloodPannel", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPlayerCareerChange", function(msg)

        if(msg.state == 0 and msg.roleId == LocalPlayerRoot.LocalPlayerID) then    

            GameCenter.MsgPromptSystem:ShowMsgBox(        
            DataConfig.DataMessageString:Get("C_CHANGEOCC_SUCCTIPS",GameCenter.PlayerRoleListSystem:GetOccName(msg.careerNo)), 
            DataConfig.DataMessageString:Get("C_MSGBOX_OK"),
            nil,
            function ()            
                GameCenter.GameSceneSystem:ReturnToLogin();
            end
            );
        end
    end)

    Network.CreatRespond("MSG_Player.ResSendGift", function(msg)
        GameCenter.PresentSystem:ResSendGift(msg)
    end)

    Network.CreatRespond("MSG_Player.ResGetGiftLog", function(msg)
        GameCenter.PresentSystem:ResGetGiftLog(msg)
    end)

    Network.CreatRespond("MSG_Player.ResNewGiftLog", function(msg)
        GameCenter.PresentSystem:ResNewGiftLog(msg)
    end)

    Network.CreatRespond("MSG_Player.ResReadGiftLog", function(msg)
        GameCenter.PresentSystem:ResReadGiftLog(msg)
    end)

    Network.CreatRespond("MSG_Player.ResOpenServerTime", function(msg)
        Time.ResOpenServerTime(msg.time)
        GameCenter.RobotChatSystem:SetOpenServerTime(msg.time)
        GameCenter.XmFightSystem:SetOpenServerTime(msg.time)
        GameCenter.TerritorialWarSystem:SetOpenServerTime(msg.time)
        GameCenter.FunctionNoticeSystem:SetServerOpenTime(msg.time)
        GameCenter.MarryDatingWallSystem:SetOpenServerTime(msg.time)
        GameCenter.FuDiSystem:SetServerOpenTime(msg.time)
        GameCenter.TopJjcSystem:SetOpenServerTime(msg.time)
        GameCenter.RankAwardSystem:SetOpenServerTime(msg.time)
        GameCenter.DailyActivityTipsSystem:SetOpenServerTime(msg.time)
        GameCenter.ZeroBuySystem:SetOpenServerTime(msg.time)
        GameCenter.TodayFuncSystem:SetOpenServerTime(msg.time)
        GameCenter.PrefectRomanceSystem:SetOpenServerTime(msg.time)
        GameCenter.NewServerActivitySystem:SetOpenServerTime(msg.time)
        GameCenter.XMZhengBaSystem:SetOpenServerTime(msg.time)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_OPENSERVERTIME_REFRESH);
    end)

    Network.CreatRespond("MSG_Player.SyncXiSuiData", function(msg)
        -- TODO
    end)

    Network.CreatRespond("MSG_Player.ResPlayerSummaryInfo", function(msg)
        GameCenter.PushFixEvent(UIEventDefine.UISocialTipsForm_OPEN, msg)
    end)

    Network.CreatRespond("MSG_Player.ResGenderClassChange", function(msg)
        -- TODO
    end)


    Network.CreatRespond("MSG_Player.G2SSynPlayerSocialInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Player.G2SReqPlayerSummaryInfo",function (msg)
        --TODO
    end)


    -- Network.CreatRespond("MSG_Player.ResPlayerSettingAutoHead",function (msg)
    --     --TODO
    -- end)


    Network.CreatRespond("MSG_Player.ResPlayerSettingCustomHeadResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Player.ResPlayerChangeState",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Player.ResActiveMainType", function(msg)
        GameCenter.PlayerStatSystem:LoadFromServer(msg);
    end)


    Network.CreatRespond("MSG_Player.ResPlayerChangePointKillPk",function (msg)
        --TODO

        -- Debug.Log("ResPlayerChangePointKillPkResPlayerChangePointKillPkResPlayerChangePointKillPk===", Inspect(msg))
        -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_PK_POINT, msg)
    end)


    Network.CreatRespond("MSG_Player.ResPlayerChangeTimeLimitExp",function (msg)
        --TODO
        -- Debug.Log("ResPlayerChangeTimeLimitExpResPlayerChangeTimeLimitExpResPlayerChangeTimeLimitExpResPlayerChangeTimeLimitExp===", Inspect(msg))
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_EXP_TIME, msg)
    end)

end
return MSG_Player

