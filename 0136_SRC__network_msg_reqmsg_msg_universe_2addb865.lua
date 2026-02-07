local MSG_Universe = {
    UniverseMonsterInfo = {
       modelId = 0,
       type = 0,
       refreshTime = nil,
       care = nil,
    },
    ReqUniverseWarPanel = {
    },
    ReqCareMonster = {
       modelId = 0,
       type = 0,
    },
    DamageInfo = {
       rank = 0,
       name = "",
       damage = 0,
    },
    DamageRank = {
       damageList = List:New(),
       myDamage = {
            rank = 0,
            name = "",
            damage = 0,
        },

    },
    ReqDamageRank = {
       monsterId = 0,
    },
}
local L_StrDic = {
    [MSG_Universe.ReqUniverseWarPanel] = "MSG_Universe.ReqUniverseWarPanel",
    [MSG_Universe.ReqCareMonster] = "MSG_Universe.ReqCareMonster",
    [MSG_Universe.ReqDamageRank] = "MSG_Universe.ReqDamageRank",
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

return MSG_Universe

