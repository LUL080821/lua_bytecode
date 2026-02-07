local MSG_Community = {}
local Network = GameCenter.Network

function MSG_Community.RegisterMsg()
    Network.CreatRespond("MSG_Community.ResPlayerCommunityInfoSetting",function (msg)
        GameCenter.CommunityMsgSystem:ResPlayerCommunityInfoSetting(msg)
    end)

    Network.CreatRespond("MSG_Community.ResPlayerCommunityInfo",function (msg)
        GameCenter.CommunityMsgSystem:ResPlayerCommunityInfo(msg)
    end)

    Network.CreatRespond("MSG_Community.ResCommunityLeaveMessage",function (msg)
        GameCenter.CommunityMsgSystem:ResCommunityLeaveMessage(msg)
    end)

    Network.CreatRespond("MSG_Community.G2SReqPlayerCommunityInfoSetting",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqPlayerCommunityInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqCommunityLeaveMessage",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqAddCommunityLeaveMessage",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqDeleteCommunityLeaveMessage",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqFriendCircle",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.ResFriendCircleList",function (msg)
        -- All List
        if msg.type == 1 then
            GameCenter.CommunityMsgSystem:ResCommunityDynamicMessage(msg)
        -- Add a new one
        elseif msg.type == 2 then
            GameCenter.CommunityMsgSystem:ResCommunityDynamicMsgAdd(msg)
        -- Delete one
        elseif msg.type == 3 then
            GameCenter.CommunityMsgSystem:ResCommunityDynamicMsgDeleted(msg)
        -- Refresh comments
        elseif msg.type == 4 then
            GameCenter.CommunityMsgSystem:ResCommunityDynamicMsgPingLun(msg)
        end
    end)


    Network.CreatRespond("MSG_Community.G2SReqSendFriendCircle",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqDeleteFriendCircle",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Community.G2SReqCommentFriendCircle",function (msg)
        --TODO
    end)

end
return MSG_Community

