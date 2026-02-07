local MSG_TreasureHuntXianjia = {
    ReqTreasureHuntXijia = {
       type = 0,
       times = 0,
    },
    ReqBuyCount = {
       type = 0,
       times = 0,
       num = 0,
    },
    ReqExtract = {
       type = 0,
       uid = 0,
    },
    MibaoData = {
       id = 0,
       isGet = false,
    },
    ReqOpenXianjiaHuntPanel = {
       type = 0,
    },
    ReqTreasureHuntMibao = {
       type = 0,
       id = nil,
    },
}
local L_StrDic = {
    [MSG_TreasureHuntXianjia.ReqTreasureHuntXijia] = "MSG_TreasureHuntXianjia.ReqTreasureHuntXijia",
    [MSG_TreasureHuntXianjia.ReqBuyCount] = "MSG_TreasureHuntXianjia.ReqBuyCount",
    [MSG_TreasureHuntXianjia.ReqExtract] = "MSG_TreasureHuntXianjia.ReqExtract",
    [MSG_TreasureHuntXianjia.ReqOpenXianjiaHuntPanel] = "MSG_TreasureHuntXianjia.ReqOpenXianjiaHuntPanel",
    [MSG_TreasureHuntXianjia.ReqTreasureHuntMibao] = "MSG_TreasureHuntXianjia.ReqTreasureHuntMibao",
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

return MSG_TreasureHuntXianjia

