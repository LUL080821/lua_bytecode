local MSG_Friend = {}
local Network = GameCenter.Network

function MSG_Friend.RegisterMsg()
    Network.CreatRespond("MSG_Friend.ResFriendList",function (msg)
        GameCenter.FriendSystem:ResFriendList(msg)
    end)

    Network.CreatRespond("MSG_Friend.ResAddFriendSuccess",function (msg)
        GameCenter.FriendSystem:ResAddFriendSuccess(msg)
    end)

    Network.CreatRespond("MSG_Friend.ResDeleteRelationSuccess",function (msg)
        GameCenter.FriendSystem:ResDeleteRelationSuccess(msg)
    end)

    Network.CreatRespond("MSG_Friend.ResDimSelectList",function (msg)
        GameCenter.FriendSystem:ResDimSelectList(msg)
    end)

    Network.CreatRespond("MSG_Friend.ResIntimacyChange",function (msg)
        local _friend = GameCenter.FriendSystem:GetFriend(msg.roleId)
        if _friend ~= nil then 
            _friend.intimacy = msg.intimacy
        end
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_INTIMACY , msg.roleId , msg.intimacy)
    end)

    Network.CreatRespond("MSG_Friend.ResAddFriendApprovalToTarget",function (msg)
        GameCenter.FriendSystem:ResApproval(msg.sourcePlayer)
    end)


    Network.CreatRespond("MSG_Friend.ResAddFriendApprovalList",function (msg)
        local listInfo = List:New()
        if msg.approvalList then
            for i = 1, #msg.approvalList do
                listInfo:Add(msg.approvalList[i])
            end
        end
        GameCenter.FriendSystem:ResApprovalList(listInfo)
    end)

    Network.CreatRespond("MSG_Friend.ResAddFriendApproval",function (msg)
        local listInfo = List:New()
        if msg.approvalList then
            for i = 1, #msg.approvalList do
                listInfo:Add(msg.approvalList[i])
            end
        end
        GameCenter.FriendSystem:ResApprovalResult(listInfo , msg.type)
    end)


    Network.CreatRespond("MSG_Friend.ResFriendShipPointCommonInfo",function (msg)
        -- for i = 1, #GameCenter.FriendSystem.FriendList do
        --     if GameCenter.FriendSystem.FriendList[i].playerId == msg.friendInfo.playerId then
        --         GameCenter.FriendSystem.FriendList[i].isGiveFriendshipPoint = msg.friendInfo.isGiveFriendshipPoint
        --         GameCenter.FriendSystem.FriendList[i].isReceiveFriendshipPoint = msg.friendInfo.isReceiveFriendshipPoint
        --         GameCenter.FriendSystem.FriendList[i].isFriendshipPointAward = msg.friendInfo.isFriendshipPointAward
        --     end
        -- end
        GameCenter.FriendSystem:ReqGetRelationList(FriendType.Friend)
        local type = GameCenter.FriendSystem:GetQYDTypeByInfo(msg)
        local data = {msg, type}
        if msg.npcFriendInfo ~= nil then
            GameCenter.NPCFriendSystem.CurNPCShipBtnType = type
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_FRIENDSHIPPOINT , data)
    end)


    Network.CreatRespond("MSG_Friend.ResFriendShipInfo",function (msg)
        GameCenter.FriendSystem.FriendShip = msg.dayFriendShipPoint
        -- Determine the status of the gift point button of npc separately. If the list is empty, it will not be displayed.
        if msg.npcFriendInfoList ~= nil then
            local type = nil
            if not msg.npcFriendInfoList[1].isGiveFriendshipPoint and not msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Send
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and not msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.HadSend
            elseif not msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.ReSend
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Recvie
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Done
            end
            GameCenter.NPCFriendSystem.CurNPCShipBtnType = type
        end
    end)


    Network.CreatRespond("MSG_Friend.G2SReqAddFriendApproval",function (msg)
    end)


    Network.CreatRespond("MSG_Friend.S2GResAddFriendApproval",function (msg)
    end)

    Network.CreatRespond("MSG_Friend.S2GResAddFriendAnswer",function (msg)
    end)

    Network.CreatRespond("MSG_Friend.ResFriendNpcList",function (msg)
        if msg.npcFriendInfoList ~= nil and GameCenter.NPCFriendSystem.CurNPC == nil then
            GameCenter.NPCFriendSystem:ResFriendNpcList(msg.npcFriendInfoList[1].npcId)
            local type = nil
            if not msg.npcFriendInfoList[1].isGiveFriendshipPoint and not msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Send
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and not msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.HadSend
            elseif not msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.ReSend
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and not msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Recvie
            elseif msg.npcFriendInfoList[1].isGiveFriendshipPoint and msg.npcFriendInfoList[1].isReceiveFriendshipPoint and msg.npcFriendInfoList[1].isFriendshipPointAward then
                type = FriendShipType.Done
            end
            GameCenter.NPCFriendSystem.CurNPCShipBtnType = type
        end
    end)
    

    Network.CreatRespond("MSG_Friend.S2GResDeleteRelation",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.G2SReqAddFriendAnswer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.G2SReqGiveFriendShipPoint",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.S2GReqGiveFriendShipPoint",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.G2SReqAddRelation",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.S2GResAddRelation",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Friend.G2SReqDeleteRelation",function (msg)
        --TODO
    end)

end
return MSG_Friend

