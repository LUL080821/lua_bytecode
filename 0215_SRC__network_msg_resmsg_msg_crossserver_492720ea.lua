local MSG_CrossServer = {}
local Network = GameCenter.Network

function MSG_CrossServer.RegisterMsg()

    Network.CreatRespond("MSG_CrossServer.G2FReqCrossUseItem",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GResCrossUseItem",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GResCrossDropCoin",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GResCrossDropItem",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FReqCrossDropItemString",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PReqChatMess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GResChatMess",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FSynPlayerOut",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GFightEnd",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GCloneClose",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2PCloneRewardNotGet",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GCloneEnterAddOne",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FReqHeart",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GResHeart",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2F_UpMorale",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FRelive",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FGMdeal",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GNoticeEvent",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GTaskAction",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GReliveRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GResourceFindChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2FReqCloneFightInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GPlayerStateChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2PPlayerOutFightRoom",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2G_UpMoraleRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GTaskRresh",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GSendReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GDropData",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GSendMailReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GShituTaskChange0",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GCloneCDRecordAdd",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PPlayerCareerChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PSynPlayerName",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PGMCMD",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GGMCMDResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PConnectHeart",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GConnectHeartRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PServerNameChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PServerOpentimeChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PServerWorldLvChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GAddExp",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GBossRefreshTip",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2PBossRefreshTip",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PDailyData",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GDailyData",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GFirstKillInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.G2PReqFirstKillBossRefreshTime",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2PMakeBossRefresh",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.P2GSendMailReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossServer.F2GSendPersonalNotice",function (msg)
        --TODO
    end)

end
return MSG_CrossServer

