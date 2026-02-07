local MSG_Friend = {
    CommonInfo = {
       playerId = 0,
       name = "",
       lv = 0,
       career = 0,
       isOnline = false,
       intimacy = nil,
       lastofftime = nil,
       viplevel = nil,
       hasMarry = nil,
       isGiveFriendshipPoint = nil,
       isReceiveFriendshipPoint = nil,
       isFriendshipPointAward = nil,
       serverId = nil,
       isFriend = nil,
       head = nil,
    },
    ReqGetRelationList = {
       type = 0,
    },
    ReqAddRelation = {
       targetPlayerId = 0,
       type = 0,
       targetServerId = nil,
       targetPlayerName = nil,
    },
    ReqDeleteRelation = {
       targetPlayerId = 0,
       type = 0,
    },
    ReqDimSelect = {
       name = "",
    },
    ReqReport = {
       roleId = 0,
       type = 0,
       content = "",
    },
    ApprovalPlayerInfo = {
       playerId = 0,
       name = nil,
       lv = nil,
       career = nil,
       serverId = nil,
       isShieldAddFriend = nil,
       head = nil,
    },
    ReqAddFriendApproval = {
       agreeList = List:New(),
       declineList = List:New(),
    },
    ReqGiveFriendShipPoint = {
       type = 0,
       friendPlayerId = 0,
       friendType = nil,
    },
    NpcFriendInfo = {
       npcId = nil,
       isGiveFriendshipPoint = nil,
       isReceiveFriendshipPoint = nil,
       isFriendshipPointAward = nil,
    },
    AddFriendApproval = {
       targetPlayerId = 0,
       targetServerId = 0,
       targetPlat = "",
       approvalPlayerId = 0,
       approvalServerId = 0,
       approvalPlat = "",
       leaveMessage = nil,
       chatResSC = nil,
       globalPlayerWorldInfo = nil,
    },
    AddFriendAnswer = {
       answerType = 0,
       approvalPlayerId = 0,
       approvalServerId = 0,
       approvalTargetPlat = "",
       leaveMessage = nil,
       chatResSC = nil,
       globalPlayerWorldInfo = nil,
    },
    ReqNpcFriendGiveShipPoint = {
       npcId = 0,
    },
}
local L_StrDic = {
    [MSG_Friend.ReqGetRelationList] = "MSG_Friend.ReqGetRelationList",
    [MSG_Friend.ReqAddRelation] = "MSG_Friend.ReqAddRelation",
    [MSG_Friend.ReqDeleteRelation] = "MSG_Friend.ReqDeleteRelation",
    [MSG_Friend.ReqDimSelect] = "MSG_Friend.ReqDimSelect",
    [MSG_Friend.ReqReport] = "MSG_Friend.ReqReport",
    [MSG_Friend.ReqAddFriendApproval] = "MSG_Friend.ReqAddFriendApproval",
    [MSG_Friend.ReqGiveFriendShipPoint] = "MSG_Friend.ReqGiveFriendShipPoint",
    [MSG_Friend.ReqNpcFriendGiveShipPoint] = "MSG_Friend.ReqNpcFriendGiveShipPoint",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_Friend

