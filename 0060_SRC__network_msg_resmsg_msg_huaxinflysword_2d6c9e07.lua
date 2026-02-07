local MSG_HuaxinFlySword = {}
local Network = GameCenter.Network

function MSG_HuaxinFlySword.RegisterMsg()
    Network.CreatRespond("MSG_HuaxinFlySword.ResOnlineInitHuaxin",function (msg)
        -- GameCenter.NatureSystem:ResOnlineInitHuaxin(msg)
        GameCenter.FlySowardSystem:ResOnlineInitHuaxin(msg)
    end)

    Network.CreatRespond("MSG_HuaxinFlySword.ResUseHuxinResult",function (msg)
        GameCenter.FlySowardSystem:ResUseHuxinResult(msg)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResSwordSoulPannel",function (msg)
        --TODO
        GameCenter.SwordMandateSystem:ResSwordSoulPannel(msg)
    end)

    Network.CreatRespond("MSG_HuaxinFlySword.ResGetHookReward",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVEMT_UPDATE_SWORDMANDATE_RESULT, msg)
    end)

    -- Information notification in the Sword Spirit copy
    Network.CreatRespond("MSG_HuaxinFlySword.ResSoulCopyChallengeInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    -- Sword Spirit Copy Settlement
    Network.CreatRespond("MSG_HuaxinFlySword.ResSoulCopyResult",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_HuaxinFlySword.ResSwordTomb",function (msg)
        GameCenter.FlySwordGraveSystem:ResSwordTomb(msg)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResQuickEarn",function (msg)
        GameCenter.SwordMandateSystem:ResQuickEarn(msg)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResSwordTombCopyInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResSwordTombResult",function (msg)
        --TODO
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResSwordTombChange",function (msg)
        GameCenter.FlySwordGraveSystem:ResSwordTombChange(msg.id, msg.state)
    end)


    Network.CreatRespond("MSG_HuaxinFlySword.ResSkipSoulCopyResult",function (msg)
        --TODO
        GameCenter.SwordMandateSystem:ResSkipSoulCopyResult(msg)
    end)

end
return MSG_HuaxinFlySword

