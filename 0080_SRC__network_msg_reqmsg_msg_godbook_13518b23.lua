local MSG_GodBook = {
    amuletInfo = {
       id = 0,
       status = false,
       list = List:New(),
    },
    conditionInfo = {
       id = 0,
       progress = 0,
       status = 0,
    },
    ReqActiveAmulet = {
       amuletId = 0,
    },
    ReqGetReward = {
       conditonId = 0,
    },
    ReqGodBookInfo = {
    },
}
local L_StrDic = {
    [MSG_GodBook.ReqActiveAmulet] = "MSG_GodBook.ReqActiveAmulet",
    [MSG_GodBook.ReqGetReward] = "MSG_GodBook.ReqGetReward",
    [MSG_GodBook.ReqGodBookInfo] = "MSG_GodBook.ReqGodBookInfo",
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

return MSG_GodBook

