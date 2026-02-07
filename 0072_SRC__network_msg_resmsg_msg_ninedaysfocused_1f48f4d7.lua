local MSG_NineDaysFocused = {}
local Network = GameCenter.Network

function MSG_NineDaysFocused.RegisterMsg()
    Network.CreatRespond("MSG_NineDaysFocused.ResApplyNieDaysReuslt",function (msg)
        --TODO
        GameCenter.MapLogicSystem.OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_NineDaysFocused.ResOpenTasKPanelReuslt",function (msg)
        --TODO
        GameCenter.MapLogicSystem.OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_NineDaysFocused.ResBossHurtInfo",function (msg)
        --TODO
        GameCenter.MapLogicSystem.OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_NineDaysFocused.F2GSynchrodata",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_NineDaysFocused.ResRefreshTask",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_NineDaysFocused.F2GSynchrotask",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_NineDaysFocused.G2PReqApplyNieDaysFocused",function (msg)
        --TODO
    end)

end
return MSG_NineDaysFocused

