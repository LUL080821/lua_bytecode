local MSG_Community = {
    ReqPlayerCommunityInfoSetting = {
       settingType = 0,
       playerCommunityInfoSettingInfo = nil,
    },
    PlayerCommunityInfoSettingInfo = {
       decorate = nil,
       pendan = nil,
       sign = nil,
       brith = nil,
       isNotFriendLeaveMsg = nil,
    },
    ReqPlayerCommunityInfo = {
       roleId = 0,
    },
    PlayerCommunityInfo = {
       roleId = 0,
       roleName = "",
       roleLv = 0,
       career = 0,
       fightpower = 0,
       guildName = nil,
       serverId = nil,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

       stateLv = nil,
       playerCommunityInfoSettingInfo = nil,
       head = nil,
    },
    CommunityLeaveMessageInfo = {
       leaveMessageId = 0,
       chatername = "",
       condition = "",
       time = 0,
       level = nil,
       chaterSid = nil,
       career = nil,
       roleId = nil,
       head = nil,
    },
    ReqCommunityLeaveMessage = {
       roleId = 0,
    },
    ReqAddCommunityLeaveMessage = {
       roleId = 0,
       condition = "",
    },
    ReqDeleteCommunityLeaveMessage = {
       roleId = 0,
       leaveMessageId = 0,
    },
    ReqFriendCircle = {
       roleId = 0,
    },
    FriendCircleLeaveMessageInfo = {
       chatername = "",
       condition = nil,
    },
    FriendCircleInfo = {
       friendCircleId = 0,
       condition = nil,
       friendCircleLeaveMessageInfo = List:New(),
    },
    ReqSendFriendCircle = {
       roleId = 0,
       condition = "",
    },
    ReqDeleteFriendCircle = {
       friendCircleId = 0,
    },
    ReqCommentFriendCircle = {
       targetRoleId = 0,
       friendCircleId = 0,
       commentCondition = "",
    },
}
local L_StrDic = {
    [MSG_Community.ReqPlayerCommunityInfoSetting] = "MSG_Community.ReqPlayerCommunityInfoSetting",
    [MSG_Community.ReqPlayerCommunityInfo] = "MSG_Community.ReqPlayerCommunityInfo",
    [MSG_Community.ReqCommunityLeaveMessage] = "MSG_Community.ReqCommunityLeaveMessage",
    [MSG_Community.ReqAddCommunityLeaveMessage] = "MSG_Community.ReqAddCommunityLeaveMessage",
    [MSG_Community.ReqDeleteCommunityLeaveMessage] = "MSG_Community.ReqDeleteCommunityLeaveMessage",
    [MSG_Community.ReqFriendCircle] = "MSG_Community.ReqFriendCircle",
    [MSG_Community.ReqSendFriendCircle] = "MSG_Community.ReqSendFriendCircle",
    [MSG_Community.ReqDeleteFriendCircle] = "MSG_Community.ReqDeleteFriendCircle",
    [MSG_Community.ReqCommentFriendCircle] = "MSG_Community.ReqCommentFriendCircle",
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

return MSG_Community

