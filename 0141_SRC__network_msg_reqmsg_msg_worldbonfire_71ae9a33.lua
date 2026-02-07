local MSG_WorldBonfire = {
    WorldBonfireMember = {
       name = "",
       stateLv = nil,
       remainWine = 0,
       roleId = 0,
       carrer = 0,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

       head = nil,
    },
    Finger = {
       roleId = 0,
       total = 0,
       type = 0,
       res = 0,
    },
    ReqWorldBonfireAddWood = {
    },
    ReqWorldBonfireMatch = {
    },
    ReqWorldBonfireReward = {
    },
    ReqWorldBonfireFinger = {
       total = 0,
       type = 0,
       teamId = 0,
    },
    ReqWorldBonfireLeave = {
       teamId = 0,
    },
    ReqWorldBonfireCancelMatch = {
    },
}
local L_StrDic = {
    [MSG_WorldBonfire.ReqWorldBonfireAddWood] = "MSG_WorldBonfire.ReqWorldBonfireAddWood",
    [MSG_WorldBonfire.ReqWorldBonfireMatch] = "MSG_WorldBonfire.ReqWorldBonfireMatch",
    [MSG_WorldBonfire.ReqWorldBonfireReward] = "MSG_WorldBonfire.ReqWorldBonfireReward",
    [MSG_WorldBonfire.ReqWorldBonfireFinger] = "MSG_WorldBonfire.ReqWorldBonfireFinger",
    [MSG_WorldBonfire.ReqWorldBonfireLeave] = "MSG_WorldBonfire.ReqWorldBonfireLeave",
    [MSG_WorldBonfire.ReqWorldBonfireCancelMatch] = "MSG_WorldBonfire.ReqWorldBonfireCancelMatch",
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

return MSG_WorldBonfire

