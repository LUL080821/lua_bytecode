local MSG_TreasureHuntWuyou = {
    ReqOpenPanel = {
    },
    ReqGetItem = {
    },
    ReqHunt = {
       num = 0,
    },
    ReqExtract = {
       uid = 0,
    },
}
local L_StrDic = {
    [MSG_TreasureHuntWuyou.ReqOpenPanel] = "MSG_TreasureHuntWuyou.ReqOpenPanel",
    [MSG_TreasureHuntWuyou.ReqGetItem] = "MSG_TreasureHuntWuyou.ReqGetItem",
    [MSG_TreasureHuntWuyou.ReqHunt] = "MSG_TreasureHuntWuyou.ReqHunt",
    [MSG_TreasureHuntWuyou.ReqExtract] = "MSG_TreasureHuntWuyou.ReqExtract",
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

return MSG_TreasureHuntWuyou

