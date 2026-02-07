local MSG_WorldBonfire = {}
local Network = GameCenter.Network

function MSG_WorldBonfire.RegisterMsg()
    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfirePanel",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResBonfireActivityInfo(msg)
    end)

    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfireMatchList",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResHQMatchList(msg)
    end)

    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfireReward",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResHQActivityReward(msg)
    end)

    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfireFinger",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResSingleResult(msg)
    end)

    Network.CreatRespond("MSG_WorldBonfire.G2FWorldBonfireAddWoodDecItem",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireEnter",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfireAllFinger",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResGameOver(msg)
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireMatch",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireFinger",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireAddWoodCheck",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireLeave",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2FWorldBonfireReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.F2PWorldBonfireAddWood",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.F2PWorldBonfirePanel",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.P2GWorldBonfireAddWoodCheckRes",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.P2GWorldBonfireReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldBonfire.P2FWorldBonfireAddWoodLv",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_WorldBonfire.ResWorldBonfireCancelMatch",function (msg)
        GameCenter.BonfireActivitySystem:GS2U_ResCancelMatch(msg)
    end)


    Network.CreatRespond("MSG_WorldBonfire.G2PWorldBonfireCalcelMatch",function (msg)
        --TODO
    end)

end
return MSG_WorldBonfire

