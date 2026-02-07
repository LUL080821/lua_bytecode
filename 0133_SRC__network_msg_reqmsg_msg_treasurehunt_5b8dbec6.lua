local MSG_TreasureHunt = {
    simpleItemInfo = {
       itemId = 0,
       itemNum = 0,
       bind = 0,
       uid = 0,
    },
    itemRecordInfo = {
       itemId = 0,
       itemNum = 0,
       playername = "",
       bind = 0,
       type = 0,
    },
    treasureRecordInfo = {
       info = List:New(),
       type = 0,
       serverLuckCount = nil,
    },
    warehouseInfo = {
       simpleItems = List:New(),
       type = 0,
       mustTypeleftTimes = 0,
       freetimes = 0,
       todayLeftTimes = 0,
    },
    ReqTreasureHunt = {
       type = 0,
       times = 0,
    },
    ReqBuy = {
       type = 0,
       times = 0,
       num = 0,
    },
    ReqOnekeyExtract = {
       type = 0,
    },
    ReqOnekeyRecovery = {
    },
    ReqChooseRecovery = {
       itemId = 0,
       num = 0,
    },
}
local L_StrDic = {
    [MSG_TreasureHunt.ReqTreasureHunt] = "MSG_TreasureHunt.ReqTreasureHunt",
    [MSG_TreasureHunt.ReqBuy] = "MSG_TreasureHunt.ReqBuy",
    [MSG_TreasureHunt.ReqOnekeyExtract] = "MSG_TreasureHunt.ReqOnekeyExtract",
    [MSG_TreasureHunt.ReqOnekeyRecovery] = "MSG_TreasureHunt.ReqOnekeyRecovery",
    [MSG_TreasureHunt.ReqChooseRecovery] = "MSG_TreasureHunt.ReqChooseRecovery",
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

return MSG_TreasureHunt

