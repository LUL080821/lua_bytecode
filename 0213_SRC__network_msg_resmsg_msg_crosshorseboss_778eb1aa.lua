local MSG_CrossHorseBoss = {}
local Network = GameCenter.Network

function MSG_CrossHorseBoss.RegisterMsg()
    Network.CreatRespond("MSG_CrossHorseBoss.ResCrossHorseBossPanel",function (msg)
        GameCenter.MountBossSystem:ResCrossHorseBossPanel(msg)
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.G2PReqCrossHorseBossPanel",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.G2PReqFollowCrossHorseBoss",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.ResFollowCrossHorseBoss",function (msg)
        GameCenter.MountBossSystem:ResFollowCrossHorseBoss(msg)
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.ResCrossHorseBossRefreshTip",function (msg)
        GameCenter.MountBossSystem:ResCrossHorseBossRefreshTip(msg)
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.F2PReqCrossHorseBossDie",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.F2PCrossHorseBossCloneOpen",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossHorseBoss.P2GResCrossHorseBossRefreshTip",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossHorseBoss.G2FReqCancelAffiliation",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossHorseBoss.ResCancelAffiliationResult",function (msg)
        GameCenter.MountBossSystem:ResCancelAffiliationResult(msg)
    end)


    Network.CreatRespond("MSG_CrossHorseBoss.G2PReqEnterHorseBoss",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossHorseBoss.ResCrossHorseMapOverTime",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

    Network.CreatRespond("MSG_CrossHorseBoss.ResCrossBossDie",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg);
    end)

end
return MSG_CrossHorseBoss

