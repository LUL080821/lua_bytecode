local MSG_Vip = {
    ReqVip = {
    },
    ReqVipReward = {
    },
    ReqVipPurGift = {
       lv = 0,
    },
    ReqVipRechargeReward = {
       id = 0,
    },
    ReqVipFreeReward = {
    },
    ReqActiveVipPearl = {
       id = 0,
    },
    SpecialVipStateInfo = {
       isNotifyClient = false,
       isActivate = false,
    },
}
local L_StrDic = {
    [MSG_Vip.ReqVip] = "MSG_Vip.ReqVip",
    [MSG_Vip.ReqVipReward] = "MSG_Vip.ReqVipReward",
    [MSG_Vip.ReqVipPurGift] = "MSG_Vip.ReqVipPurGift",
    [MSG_Vip.ReqVipRechargeReward] = "MSG_Vip.ReqVipRechargeReward",
    [MSG_Vip.ReqVipFreeReward] = "MSG_Vip.ReqVipFreeReward",
    [MSG_Vip.ReqActiveVipPearl] = "MSG_Vip.ReqActiveVipPearl",
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

return MSG_Vip

