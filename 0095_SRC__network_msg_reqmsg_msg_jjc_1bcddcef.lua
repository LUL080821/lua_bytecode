local MSG_JJC = {
    JJCobject = {
       roleID = 0,
       rank = 0,
       name = "",
       career = 0,
       level = 0,
       stateLv = 0,
       fightPower = 0,
       nameMark = nil,
       seckill = nil,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

    },
    Report = {
       time = 0,
       type = 0,
       name = "",
       rank = 0,
       lastRank = nil,
       tiaozhao = nil,
       nameMark = nil,
    },
    ReqOpenJJC = {
    },
    ReqChangeTarget = {
    },
    ReqChallenge = {
       targetID = 0,
       seckill = false,
    },
    ReqGetAward = {
    },
    ReqAddChance = {
    },
    ReqGetYesterdayRank = {
    },
    ReqGetReport = {
    },
    ReqJJCexit = {
    },
    ReqGetFirstReward = {
       excelId = nil,
    },
    ReqOneKeySweep = {
    },
}
local L_StrDic = {
    [MSG_JJC.ReqOpenJJC] = "MSG_JJC.ReqOpenJJC",
    [MSG_JJC.ReqChangeTarget] = "MSG_JJC.ReqChangeTarget",
    [MSG_JJC.ReqChallenge] = "MSG_JJC.ReqChallenge",
    [MSG_JJC.ReqGetAward] = "MSG_JJC.ReqGetAward",
    [MSG_JJC.ReqAddChance] = "MSG_JJC.ReqAddChance",
    [MSG_JJC.ReqGetYesterdayRank] = "MSG_JJC.ReqGetYesterdayRank",
    [MSG_JJC.ReqGetReport] = "MSG_JJC.ReqGetReport",
    [MSG_JJC.ReqJJCexit] = "MSG_JJC.ReqJJCexit",
    [MSG_JJC.ReqGetFirstReward] = "MSG_JJC.ReqGetFirstReward",
    [MSG_JJC.ReqOneKeySweep] = "MSG_JJC.ReqOneKeySweep",
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

return MSG_JJC

