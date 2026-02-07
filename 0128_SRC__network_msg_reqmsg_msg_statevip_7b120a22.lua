local MSG_StateVip = {
    stateVip = {
       id = 0,
       progress = 0,
       status = false,
    },
    ReqGetReward = {
       id = 0,
    },
    ReqStateVip = {
    },
    ReqStateVipUp = {
    },
    ReqStateVipGift = {
       id = 0,
       cd = 0,
    },
    ReqDelStateVipGift = {
       id = 0,
    },
    ReqPurStateVipGift = {
       id = 0,
    },
    ReqOpenExpPanel = {
    },
    ReqGetExp = {
    },
}
local L_StrDic = {
    [MSG_StateVip.ReqGetReward] = "MSG_StateVip.ReqGetReward",
    [MSG_StateVip.ReqStateVip] = "MSG_StateVip.ReqStateVip",
    [MSG_StateVip.ReqStateVipUp] = "MSG_StateVip.ReqStateVipUp",
    [MSG_StateVip.ReqStateVipGift] = "MSG_StateVip.ReqStateVipGift",
    [MSG_StateVip.ReqDelStateVipGift] = "MSG_StateVip.ReqDelStateVipGift",
    [MSG_StateVip.ReqPurStateVipGift] = "MSG_StateVip.ReqPurStateVipGift",
    [MSG_StateVip.ReqOpenExpPanel] = "MSG_StateVip.ReqOpenExpPanel",
    [MSG_StateVip.ReqGetExp] = "MSG_StateVip.ReqGetExp",
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

return MSG_StateVip

