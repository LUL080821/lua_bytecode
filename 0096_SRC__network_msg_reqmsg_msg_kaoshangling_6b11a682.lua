local MSG_KaoShangLing = {
    ReqOpenKaoShangLingPanel = {
       type = 0,
    },
    ReqKaoShangLingReward = {
       type = 0,
       isOneKey = 0,
       key = 0,
    },
    ReqKaoShangLingRefreshRank = {
       type = 0,
    },
    ReqBuySpecailKaoShangLing = {
       type = 0,
    },
    KaoShangLingInfo = {
       type = 0,
       rank = 0,
       commonRewardList = List:New(),
       specailRewardist = List:New(),
       scoreTotal = 0,
       scoreDay = 0,
       isBuySpecail = 0,
    },
}
local L_StrDic = {
    [MSG_KaoShangLing.ReqOpenKaoShangLingPanel] = "MSG_KaoShangLing.ReqOpenKaoShangLingPanel",
    [MSG_KaoShangLing.ReqKaoShangLingReward] = "MSG_KaoShangLing.ReqKaoShangLingReward",
    [MSG_KaoShangLing.ReqKaoShangLingRefreshRank] = "MSG_KaoShangLing.ReqKaoShangLingRefreshRank",
    [MSG_KaoShangLing.ReqBuySpecailKaoShangLing] = "MSG_KaoShangLing.ReqBuySpecailKaoShangLing",
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

return MSG_KaoShangLing

