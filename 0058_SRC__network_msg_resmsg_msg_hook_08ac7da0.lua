local MSG_Hook = {}
local Network = GameCenter.Network

function MSG_Hook.RegisterMsg()
    Network.CreatRespond("MSG_Hook.ResHookSetInfo",function (msg)
        GameCenter.OfflineOnHookSystem:GS2U_ResHookSetInfo(msg)
    end)

    Network.CreatRespond("MSG_Hook.ResOfflineHookResult",function (msg)
        GameCenter.OfflineOnHookSystem:GS2U_ResOfflineHookResult(msg)
    end)

    -- The following three messages are processed on the C# side. Because it involves the role state machine, a new meditation state is added.
    Network.CreatRespond("MSG_Hook.ResStartSitDown",function (msg)
        --TODO
        GameCenter.SitDownSystem:ResStartSitDown(msg)
    end)

    Network.CreatRespond("MSG_Hook.ResSyncExpAdd",function (msg)
        --TODO
        GameCenter.SitDownSystem:ResSyncExpAdd(msg)
    end)

    Network.CreatRespond("MSG_Hook.ResEndSitDown",function (msg)
        --TODO
        GameCenter.SitDownSystem:ResEndSitDown(msg)
    end)


    Network.CreatRespond("MSG_Hook.ResExpRateChange",function (msg)
        --TODO
        GameCenter.OfflineOnHookSystem:GS2U_ResExpRateChange(msg)
    end)


    Network.CreatRespond("MSG_Hook.ResLeaderSitDown",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Hook.ResOfflineHookFindTime",function (msg)
        --TODO
        GameCenter.OfflineOnHookSystem:ResOfflineHookFindTime(msg)
    end)

end
return MSG_Hook

