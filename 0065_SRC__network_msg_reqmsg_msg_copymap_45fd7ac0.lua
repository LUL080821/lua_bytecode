local MSG_copyMap = {
    cardItemInfo = {
       itemId = 0,
       num = 0,
       bind = false,
    },
    ReqCopyMapOut = {
    },
    ReqUpMorale = {
       type = 0,
    },
    ReqCloneFightInfo = {
       modelId = 0,
    },
    ReqVipBuyCount = {
       copyId = 0,
    },
    ReqOpenChallengePanel = {
    },
    ReqGoOnChallenge = {
    },
    ReqGotoNextChallenge = {
    },
    CampInfo = {
       camp = 0,
       count = 0,
       points = 0,
    },
    RankInfo = {
       camp = 0,
       name = "",
       lv = 0,
       fight = 0,
       points = 0,
    },
    ReqKillMonster = {
       monsterId = 0,
    },
    ReqOpenFairyCopyPanel = {
       copyId = 0,
    },
    ReqOpenManyCopyPanel = {
       copyId = 0,
    },
    ReqCopySetting = {
       copyId = 0,
       mergeCount = 0,
    },
    ReqRefreshNextMonster = {
    },
    BossStateInfo = {
       layer = 0,
       bossId = 0,
       isGetReward = nil,
       first = nil,
    },
    ReqOpenBossStatePanle = {
    },
    ReqBuyBossStateCount = {
    },
    ReqBossStateClearCd = {
    },
    ReqCallMonster = {
    },
    ReqFlashMonster = {
       num = 0,
    },
}
local L_StrDic = {
    [MSG_copyMap.ReqCopyMapOut] = "MSG_copyMap.ReqCopyMapOut",
    [MSG_copyMap.ReqUpMorale] = "MSG_copyMap.ReqUpMorale",
    [MSG_copyMap.ReqCloneFightInfo] = "MSG_copyMap.ReqCloneFightInfo",
    [MSG_copyMap.ReqVipBuyCount] = "MSG_copyMap.ReqVipBuyCount",
    [MSG_copyMap.ReqOpenChallengePanel] = "MSG_copyMap.ReqOpenChallengePanel",
    [MSG_copyMap.ReqGoOnChallenge] = "MSG_copyMap.ReqGoOnChallenge",
    [MSG_copyMap.ReqGotoNextChallenge] = "MSG_copyMap.ReqGotoNextChallenge",
    [MSG_copyMap.ReqKillMonster] = "MSG_copyMap.ReqKillMonster",
    [MSG_copyMap.ReqOpenFairyCopyPanel] = "MSG_copyMap.ReqOpenFairyCopyPanel",
    [MSG_copyMap.ReqOpenManyCopyPanel] = "MSG_copyMap.ReqOpenManyCopyPanel",
    [MSG_copyMap.ReqCopySetting] = "MSG_copyMap.ReqCopySetting",
    [MSG_copyMap.ReqRefreshNextMonster] = "MSG_copyMap.ReqRefreshNextMonster",
    [MSG_copyMap.ReqOpenBossStatePanle] = "MSG_copyMap.ReqOpenBossStatePanle",
    [MSG_copyMap.ReqBuyBossStateCount] = "MSG_copyMap.ReqBuyBossStateCount",
    [MSG_copyMap.ReqBossStateClearCd] = "MSG_copyMap.ReqBossStateClearCd",
    [MSG_copyMap.ReqCallMonster] = "MSG_copyMap.ReqCallMonster",
    [MSG_copyMap.ReqFlashMonster] = "MSG_copyMap.ReqFlashMonster",
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

return MSG_copyMap

