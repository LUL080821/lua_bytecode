local MSG_Marriage = {}
local Network = GameCenter.Network

function MSG_Marriage.RegisterMsg()
    Network.CreatRespond("MSG_Marriage.ResMarryPropose",function (msg)
        GameCenter.MarriageSystem:ResMarryPropose(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResDealMarryPropose",function (msg)
        GameCenter.MarriageSystem:ResDealMarryPropose(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResSelectWedding",function (msg)
        GameCenter.MarriageSystem:ResSelectWedding(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResMarryOnline",function (msg)
        GameCenter.MarriageSystem:ResMarryOnline(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResMarryData",function (msg)
        GameCenter.MarriageSystem:ResMarryData(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResUpdateWedding",function (msg)
        GameCenter.MarriageSystem:ResUpdateWedding(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResMarryCopyPlayViedo",function (msg)
        -- Play animation
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCopyEnter",function (msg)
        -- Enter the copy synchronization information
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCopyInfo",function (msg)
        -- Copy information synchronization
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarrySendBulletScreen",function (msg)
        -- Barrage broadcast
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryUseItemBroadcast",function (msg)
        -- Use item broadcast
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResDivorce",function (msg)
        GameCenter.MarriageSystem:ResDivorce(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResDivorceID",function (msg)
        GameCenter.MarriageSystem:ResDivorceID(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResDeleteDemandInvit",function (msg)
        GameCenter.MarriageSystem:ResDeleteDemandInvit(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResUpdateInvit",function (msg)
        GameCenter.MarriageSystem:ResUpdateInvit(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResDemandInvit",function (msg)
        GameCenter.MarriageSystem:ResDemandInvit(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResUpdateDemandInvit",function (msg)
        GameCenter.MarriageSystem:ResUpdateDemandInvit(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResPurInvitNum",function (msg)
        GameCenter.MarriageSystem:ResPurInvitNum(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryBlessList",function (msg)
        -- Return to the blessing list
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResUpgradeMarryLockInfo",function (msg)
        GameCenter.MarriageSystem:ResUpgradeMarryLockInfo(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryBox",function (msg)
        GameCenter.MarriageSystem:ResMarryBox(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResCallBuyMarryBox",function (msg)
        GameCenter.MarriageSystem:ResCallBuyMarryBox(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryChildInfo",function (msg)
        GameCenter.MarriageSystem:ResMarryChildInfo(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResCallMarryCloneBuy",function (msg)
        GameCenter.MarriageSystem:ResCallMarryCloneBuy(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryClone",function (msg)
        GameCenter.MarriageSystem:ResMarryClone(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCloneInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCloneSucInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResMarryCloneFailInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryWallRewardInfo",function (msg)
        GameCenter.MarryDatingWallSystem:ResMarryWallRewardInfo(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryWallInfo",function (msg)
        GameCenter.MarryDatingWallSystem:ResMarryWallInfo(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryAddFriendNotify",function (msg)
        GameCenter.MarryDatingWallSystem:ResMarryAddFriendNotify(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResWeddingStart",function (msg)
        GameCenter.MarriageSystem:ResWeddingStart(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCopyBossState",function (msg)
        -- Boss Death Status
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

    Network.CreatRespond("MSG_Marriage.ResMarryTask",function (msg)
        GameCenter.MarriageSystem:ResMarryTask(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryActivityShopBuy",function (msg)
        GameCenter.PrefectRomanceSystem:ResMarryActivityShopBuy(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryActivityIntimacy",function (msg)
        GameCenter.PrefectRomanceSystem:ResMarryActivityIntimacy(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResRefreshMarryActivityTask",function (msg)
        GameCenter.PrefectRomanceSystem:ResRefreshMarryActivityTask(msg)
    end)


    Network.CreatRespond("MSG_Marriage.ResMarryCopyBuyHot",function (msg)
        -- Popular gift package purchase status
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    -- Player marriage partner broadcast
    Network.CreatRespond("MSG_Marriage.ResMarryBroadcastName",function (msg)
        local _player = GameCenter.GameSceneSystem:FindPlayer(msg.playerId)
        if _player ~= nil then
            if msg.name == nil then
                _player:SetSpouseName("")
            else
                _player:SetSpouseName(msg.name)
            end
        end
    end)

    -- Marriage World Blessing Broadcast
    Network.CreatRespond("MSG_Marriage.ResMarryPosterShow",function (msg)
        GameCenter.MarriageSystem:ResMarryPosterShow(msg)
    end)

end
return MSG_Marriage

