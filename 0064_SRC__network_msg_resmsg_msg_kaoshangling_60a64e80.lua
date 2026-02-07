local MSG_KaoShangLing = {}
local Network = GameCenter.Network

function MSG_KaoShangLing.RegisterMsg()
    Network.CreatRespond("MSG_KaoShangLing.ResOpenKaoShangLingPanel",function (msg)
        GameCenter.KaosOrderSystem:ResOpenKaoShangLingPanel(msg)
    end)

    Network.CreatRespond("MSG_KaoShangLing.ResKaoShangLingReward",function (msg)
        GameCenter.KaosOrderSystem:ResKaoShangLingReward(msg)
    end)

    Network.CreatRespond("MSG_KaoShangLing.ResKaoShangLingRefreshRank",function (msg)
        GameCenter.KaosOrderSystem:ResKaoShangLingRefreshRank(msg)
    end)

    Network.CreatRespond("MSG_KaoShangLing.ResBuySpecailKaoShangLing",function (msg)
        GameCenter.KaosOrderSystem:ResBuySpecailKaoShangLing(msg)
    end)

end
return MSG_KaoShangLing

