local MSG_Cangbaoge = {
    CangBaogeRecord = {
       time = 0,
       playerName = "",
       itemId = 0,
       num = 0,
    },
    CangbaogeExchangeData = {
       exchangeID = 0,
       exchangeNum = 0,
    },
    ReqOpenCangbaogePanel = {
    },
    ReqOpenRecordPanel = {
    },
    ReqCangbaogeLottery = {
    },
    ReqCangbaogeReward = {
       id = 0,
    },
    ReqOpenCangbaogeExchange = {
    },
    ReqCangbaogeExchange = {
       exchangeId = 0,
    },
}
local L_StrDic = {
    [MSG_Cangbaoge.ReqOpenCangbaogePanel] = "MSG_Cangbaoge.ReqOpenCangbaogePanel",
    [MSG_Cangbaoge.ReqOpenRecordPanel] = "MSG_Cangbaoge.ReqOpenRecordPanel",
    [MSG_Cangbaoge.ReqCangbaogeLottery] = "MSG_Cangbaoge.ReqCangbaogeLottery",
    [MSG_Cangbaoge.ReqCangbaogeReward] = "MSG_Cangbaoge.ReqCangbaogeReward",
    [MSG_Cangbaoge.ReqOpenCangbaogeExchange] = "MSG_Cangbaoge.ReqOpenCangbaogeExchange",
    [MSG_Cangbaoge.ReqCangbaogeExchange] = "MSG_Cangbaoge.ReqCangbaogeExchange",
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

return MSG_Cangbaoge

