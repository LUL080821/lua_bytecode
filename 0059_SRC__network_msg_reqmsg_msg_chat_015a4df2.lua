local MSG_Chat = {
    paramStruct = {
       mark = 0,
       paramsValue = "",
    },
    LeaveMessage = {
       chater = 0,
       chatername = "",
       vipLv = 0,
       condition = "",
       time = 0,
       career = 0,
       moonandOver = nil,
       level = nil,
       iconState = nil,
       chatBgId = 0,
       receiverId = 0,
       channel = 0,
       chaterSid = nil,
       systemId = nil,
       head = nil,
    },
    ChatReqCS = {
       chattype = 0,
       chatchannel = 0,
       recRoleId = 0,
       condition = "",
       voiceLen = 0,
    },
    ChatGetContentCS = {
       key = "",
       chatchannel = 0,
    },
    ChatResInfo = {
       chattype = 0,
       chatchannel = 0,
       chater = 0,
       chatername = "",
       vipLv = 0,
       receiver = 0,
       receivername = "",
       receiverVipLv = 0,
       condition = "",
       occ = 0,
       chaterlevel = nil,
       receiverLevel = nil,
       chatBgId = 0,
       chaterSid = nil,
       systemId = nil,
       head = nil,
    },
    ReqAddChatRooM = {
       type = 0,
       typeId = 0,
       roomId = "",
    },
    ReqChatRoom = {
       type = 0,
    },
    ReqExitChatRoom = {
       type = 0,
       roomId = "",
    },
    ReqGetShareReward = {
       shareId = 0,
    },
    ReqRefuseShare = {
       shareId = 0,
    },
}
local L_StrDic = {
    [MSG_Chat.ChatReqCS] = "MSG_Chat.ChatReqCS",
    [MSG_Chat.ChatGetContentCS] = "MSG_Chat.ChatGetContentCS",
    [MSG_Chat.ReqAddChatRooM] = "MSG_Chat.ReqAddChatRooM",
    [MSG_Chat.ReqChatRoom] = "MSG_Chat.ReqChatRoom",
    [MSG_Chat.ReqExitChatRoom] = "MSG_Chat.ReqExitChatRoom",
    [MSG_Chat.ReqGetShareReward] = "MSG_Chat.ReqGetShareReward",
    [MSG_Chat.ReqRefuseShare] = "MSG_Chat.ReqRefuseShare",
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

return MSG_Chat

