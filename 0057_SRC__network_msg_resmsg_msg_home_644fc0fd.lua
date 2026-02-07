local MSG_Home = {}
local Network = GameCenter.Network

function MSG_Home.RegisterMsg()
    Network.CreatRespond("MSG_Home.ResHomeInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOUSE_INFO_RESULT, msg)
    end)

    Network.CreatRespond("MSG_Home.ResHomeVisitorNote",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOME_VISITORNOTE_UPDATE, msg.visitor)
    end)

    Network.CreatRespond("MSG_Home.ResHomeVisitorGiftList",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_HOME_GIFTLIST, msg.gift)
    end)

    Network.CreatRespond("MSG_Home.ResHomeTrimRank",function (msg)
        GameCenter.DecorateSystem:ResHomeTrimRank(msg)
    end)

    Network.CreatRespond("MSG_Home.ResHomeTrimMatchScore",function (msg)
        GameCenter.DecorateSystem:ResHomeTrimMatchScore(msg)
    end)

    Network.CreatRespond("MSG_Home.ResRandomHomeTrimTarget",function (msg)
        GameCenter.DecorateSystem:ResRandomHomeTrimTarget(msg)
    end)

    Network.CreatRespond("MSG_Home.G2SHomeInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SAuthHomePem",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SEnterHome",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SHomeVisitorNote",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SHomeVisitorGiftList",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SSendVisitorGift",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SHomeTrimRank",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SHomeTrimMatchScore",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SRandomHomeTrimTarget",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Home.G2SHomeTrimVote",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.ResHomeDecorate",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Home.ResHomeLevelUp",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Home.G2SHomeDecorate",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.G2SHomeLevelUp",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.S2GEnterHome",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.F2SHomePlayerInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.ResHomeFurnitureUpdate",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Home.ResHomeTupInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    -- Network.CreatRespond("MSG_Home.G2SGetTupReward",function (msg)
    --     --TODO
    -- end)


    -- Network.CreatRespond("MSG_Home.ResTaskList",function (msg)
    --     --TODO
    -- end)


    Network.CreatRespond("MSG_Home.ResTaskUpdate",function (msg)
        --TODO
        GameCenter.HomeTaskSystem:ResTaskUpdate(msg)
    end)


    Network.CreatRespond("MSG_Home.S2GActionTask",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.ResHomeTaskList",function (msg)
        --TODO
        GameCenter.HomeTaskSystem:ResHomeTaskList(msg)
    end)


    Network.CreatRespond("MSG_Home.ResHomeShopGoods",function (msg)
        GameCenter.ShopSystem:ResHomeShopGoods(msg)
    end)


    Network.CreatRespond("MSG_Home.ResUpdateHomeShopGoods",function (msg)
        --TODO
        GameCenter.ShopSystem:ResUpdateHomeShopGoods(msg)
    end)


    Network.CreatRespond("MSG_Home.S2GHomeInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.G2SHomeAddFurniture",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.S2FHomeSceneChange",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Home.G2SUpdatePlayerInfo",function (msg)
        --TODO
    end)

end
return MSG_Home

