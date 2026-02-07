local MSG_CrossRank = {}
local Network = GameCenter.Network

function MSG_CrossRank.RegisterMsg()
    Network.CreatRespond("MSG_CrossRank.ResCrossRankInfo",function (msg)
        --TODO
        GameCenter.RankSystem:ResCrossRankInfo(msg)
    end)


    Network.CreatRespond("MSG_CrossRank.ReqG2PCrossRankInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossRank.ReqG2PSyncCrossRankInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_CrossRank.P2GCrossWorldLv",function (msg)
        --TODO
    end)

end
return MSG_CrossRank

