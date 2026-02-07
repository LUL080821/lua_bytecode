local MSG_Recharge = {
    SubTypeTime = {
       subtype = 0,
       remiantime = 0,
    },
    ReqRechargeData = {
    },
    RechargeItem = {
       id = 0,
       count = 0,
    },
    ReqRecharge = {
       id = 0,
    },
    DiscountRechargeItem = {
       id = 0,
       count = 0,
       timeout = 0,
    },
    ReqDiscountRecharge = {
       type = nil,
    },
    ReqCheckGoodsIsCanbuy = {
       id = 0,
       moneyType = "",
    },
    ReqCheckRechargeMd5 = {
       md5 = "",
    },
    CheckDiscState = {
       goodsId = 0,
       state = 0,
    },
    ReqCheckDiscRechargeGoods = {
       goodsId = List:New(),
       type = nil,
    },
    ReqDiscRechargeBuyGoods = {
       goodsId = 0,
       count = 0,
    },
    ReqGetFreeDiscGoods = {
       type = nil,
    },
}
local L_StrDic = {
    [MSG_Recharge.ReqRechargeData] = "MSG_Recharge.ReqRechargeData",
    [MSG_Recharge.ReqRecharge] = "MSG_Recharge.ReqRecharge",
    [MSG_Recharge.ReqDiscountRecharge] = "MSG_Recharge.ReqDiscountRecharge",
    [MSG_Recharge.ReqCheckGoodsIsCanbuy] = "MSG_Recharge.ReqCheckGoodsIsCanbuy",
    [MSG_Recharge.ReqCheckRechargeMd5] = "MSG_Recharge.ReqCheckRechargeMd5",
    [MSG_Recharge.ReqCheckDiscRechargeGoods] = "MSG_Recharge.ReqCheckDiscRechargeGoods",
    [MSG_Recharge.ReqDiscRechargeBuyGoods] = "MSG_Recharge.ReqDiscRechargeBuyGoods",
    [MSG_Recharge.ReqGetFreeDiscGoods] = "MSG_Recharge.ReqGetFreeDiscGoods",
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

return MSG_Recharge

