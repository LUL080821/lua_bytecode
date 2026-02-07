local MSG_CrossFight = {}
local Network = GameCenter.Network

function MSG_CrossFight.RegisterMsg()

    Network.CreatRespond("MSG_CrossFight.P2GResFightStart",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.F2PFightRoomState",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.P2GOutFightRoom",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.ResOutFightRoom",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FOnEnterMapAgain",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FSynPlayerInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.F2GSynPlayerInfoResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FEnterCloneMap",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.F2GEnterCloneMapRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2PCheckCrossInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.P2GCheckCrossInfoRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FSynPowerAttAndFace",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.F2GPlayerOutCrossWorldMap",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FNoticeSynRoleInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.P2FCreateCityMap",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2FSynRobotInfoToHelpBattle",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.F2GSynRoleFVInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.G2PReqOutFightRoom",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossFight.P2FCloseMap",function (msg)
        --TODO
    end)

end
return MSG_CrossFight

