local MSG_SoulAnimalForest = {
    forestBossInfo = {
       bossId = 0,
       refreshTime = 0,
       type = 0,
       num = 0,
       isFollowed = nil,
    },
    ReqSoulAnimalForestLocalPanel = {
       level = 0,
    },
    ReqSoulAnimalForestCrossPanel = {
       level = 0,
    },
    ReqFollowSoulAnimalForestCrossBoss = {
       bossId = 0,
       followValue = false,
    },
    crossBossInfo = {
       modelConfigId = 0,
       nextTime = 0,
       dieTime = 0,
       rebornTime = 0,
       bornTime = 0,
       dieNum = 0,
       maxNum = 0,
       fightRoomId = 0,
    },
    crossCloneBossInfo = {
       cloneModelId = 0,
       soulAnimalInfo = {
            modelConfigId = 0,
            nextTime = 0,
            dieTime = 0,
            rebornTime = 0,
            bornTime = 0,
            dieNum = 0,
            maxNum = 0,
            fightRoomId = 0,
        },

       cloneSoulXue = {
            modelConfigId = 0,
            nextTime = 0,
            dieTime = 0,
            rebornTime = 0,
            bornTime = 0,
            dieNum = 0,
            maxNum = 0,
            fightRoomId = 0,
        },

       cloneShouwei = nil,
       bossList = List:New(),
    },
    crossGroupBossInfo = {
       groupId = 0,
       cloneBossInfo = List:New(),
    },
    ReqCrossSoulAnimalForestBossKiller = {
       bossConfigId = 0,
    },
    soulAnimalForestBossKilledRecord = {
       killTime = 0,
       killer = "",
    },
}
local L_StrDic = {
    [MSG_SoulAnimalForest.ReqSoulAnimalForestLocalPanel] = "MSG_SoulAnimalForest.ReqSoulAnimalForestLocalPanel",
    [MSG_SoulAnimalForest.ReqSoulAnimalForestCrossPanel] = "MSG_SoulAnimalForest.ReqSoulAnimalForestCrossPanel",
    [MSG_SoulAnimalForest.ReqFollowSoulAnimalForestCrossBoss] = "MSG_SoulAnimalForest.ReqFollowSoulAnimalForestCrossBoss",
    [MSG_SoulAnimalForest.ReqCrossSoulAnimalForestBossKiller] = "MSG_SoulAnimalForest.ReqCrossSoulAnimalForestBossKiller",
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

return MSG_SoulAnimalForest

