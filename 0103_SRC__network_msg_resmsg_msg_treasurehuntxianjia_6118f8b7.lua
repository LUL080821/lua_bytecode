local MSG_TreasureHuntXianjia = {}
local Network = GameCenter.Network

function MSG_TreasureHuntXianjia.RegisterMsg()
    Network.CreatRespond("MSG_TreasureHuntXianjia.ResTreasureXijiaResult",function (msg)
        GameCenter.XJXunbaoSystem:ResTreasureXijiaResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResBuyCountResult",function (msg)
        GameCenter.XJXunbaoSystem:ResBuyCountResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResExtractResult",function (msg)
        GameCenter.XJXunbaoSystem:ResExtractResult(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResAllWarehouseXianjiaInfo",function (msg)
        GameCenter.XJXunbaoSystem:ResAllWarehouseXianjiaInfo(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResRewardResultXianjiaPanle",function (msg)
        GameCenter.XJXunbaoSystem:ResRewardResultXianjiaPanle(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResOpenXianjiaHuntPanel",function (msg)
        GameCenter.XJXunbaoSystem:ResOpenXianjiaHuntPanel(msg)
    end)

    Network.CreatRespond("MSG_TreasureHuntXianjia.ResTreasureHuntMibaoResult",function (msg)
        GameCenter.XJXunbaoSystem:ResTreasureHuntMibaoResult(msg)
    end)

end
return MSG_TreasureHuntXianjia

