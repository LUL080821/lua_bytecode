local MSG_redpacket = {
    RedpacketInfo = {
       rpId = 0,
       maxValue = 0,
       curnum = 0,
       maxnum = 0,
       expiretime = 0,
       roleId = 0,
       roleName = "",
       head = nil,
       demo = "",
       mark = false,
       sent = false,
       itemType = 0,
       career = 0,
       configId = 0,
    },
    RedpacketgetroleInfo = {
       roleName = "",
       roleId = 0,
       rpvalue = 0,
       head = nil,
       career = 0,
    },
    Rpsendlog = {
       sendtime = 0,
       reason = 0,
       value = 0,
       roleId = 0,
       roleName = "",
       itemType = 0,
    },
    ReqRedpacketList = {
    },
    ReqGetRedPacketInfo = {
       rpId = 0,
    },
    ReqClickRedpacket = {
       rpId = 0,
    },
    ReqSendRedpacket = {
       maxValue = 0,
       maxNum = 0,
       notice = "",
       rpId = nil,
       itemType = nil,
    },
    ReqSendMineRechargeRedpacket = {
       rpId = 0,
       maxNum = 0,
    },
}
local L_StrDic = {
    [MSG_redpacket.ReqRedpacketList] = "MSG_redpacket.ReqRedpacketList",
    [MSG_redpacket.ReqGetRedPacketInfo] = "MSG_redpacket.ReqGetRedPacketInfo",
    [MSG_redpacket.ReqClickRedpacket] = "MSG_redpacket.ReqClickRedpacket",
    [MSG_redpacket.ReqSendRedpacket] = "MSG_redpacket.ReqSendRedpacket",
    [MSG_redpacket.ReqSendMineRechargeRedpacket] = "MSG_redpacket.ReqSendMineRechargeRedpacket",
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

return MSG_redpacket

