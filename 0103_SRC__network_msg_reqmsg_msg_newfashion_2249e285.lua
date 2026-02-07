local MSG_NewFashion = {
    NewFashion = {
       fashionID = 0,
       star = 0,
       type = 0,
    },
    NewFashionDoGiam = {
       fashionID = 0,
       star = 0,
       type = 0,
       line = 0,
    },
    TjData = {
       tjID = 0,
       star = 0,
    },
    ReqActiveFashion = {
       fashionID = 0,
    },
    ReqActiveFashionDoGiam = {
       fashionID = 0,
    },
    ReqSaveFashion = {
       wearIds = List:New(),
    },
    ReqFashionStar = {
       fashionID = 0,
    },
    ReqFashionStarDoGiam = {
       fashionID = 0,
    },
    ReqActiveTj = {
       tjID = 0,
    },
    ReqTjStar = {
       tjID = 0,
    },
}
local L_StrDic = {
    [MSG_NewFashion.ReqActiveFashion] = "MSG_NewFashion.ReqActiveFashion",
    [MSG_NewFashion.ReqActiveFashionDoGiam] = "MSG_NewFashion.ReqActiveFashionDoGiam",
    [MSG_NewFashion.ReqSaveFashion] = "MSG_NewFashion.ReqSaveFashion",
    [MSG_NewFashion.ReqFashionStar] = "MSG_NewFashion.ReqFashionStar",
    [MSG_NewFashion.ReqFashionStarDoGiam] = "MSG_NewFashion.ReqFashionStarDoGiam",
    [MSG_NewFashion.ReqActiveTj] = "MSG_NewFashion.ReqActiveTj",
    [MSG_NewFashion.ReqTjStar] = "MSG_NewFashion.ReqTjStar",
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

return MSG_NewFashion

