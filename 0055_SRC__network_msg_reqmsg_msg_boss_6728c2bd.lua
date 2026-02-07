local MSG_Boss = {
    BossKilledRecord = {
       killTime = 0,
       killer = "",
    },
    BossInfo = {
       bossId = 0,
       refreshTime = 0,
       isFollowed = nil,
    },
    BossMapOlInfo = {
       mapModelId = 0,
       num = 0,
    },
    ReqOpenDreamBoss = {
       bossType = 0,
    },
    ReqAddWorldBossRankCount = {
       bossType = 0,
    },
    ReqBossKilledInfo = {
       bossId = 0,
       bossType = 0,
    },
    ReqFollowBoss = {
       bossId = 0,
       type = 0,
       bossType = 0,
    },
    harmRank = {
       top = 0,
       name = "",
       harm = 0,
    },
    ReqOpenPersonalBossPanel = {
    },
    ReqSuitGemBossPanel = {
       type = 0,
    },
    ReqMySelfBossRemainTime = {
    },
    mySelfBossCopyInfo = {
       monsterid = 0,
       time = 0,
       active = false,
    },
    mySelfBossCopyItemInfo = {
       auto = false,
       time = 0,
       doublenum = 0,
    },
    ReqMySelfBossAuto = {
       auto = false,
    },
    ReqMySelfBossUseItem = {
       itemid = 0,
       num = 0,
    },
    ReqNoobBossPannel = {
    },
    ReqCallBigR = {
    },
}
local L_StrDic = {
    [MSG_Boss.ReqOpenDreamBoss] = "MSG_Boss.ReqOpenDreamBoss",
    [MSG_Boss.ReqAddWorldBossRankCount] = "MSG_Boss.ReqAddWorldBossRankCount",
    [MSG_Boss.ReqBossKilledInfo] = "MSG_Boss.ReqBossKilledInfo",
    [MSG_Boss.ReqFollowBoss] = "MSG_Boss.ReqFollowBoss",
    [MSG_Boss.ReqOpenPersonalBossPanel] = "MSG_Boss.ReqOpenPersonalBossPanel",
    [MSG_Boss.ReqSuitGemBossPanel] = "MSG_Boss.ReqSuitGemBossPanel",
    [MSG_Boss.ReqMySelfBossRemainTime] = "MSG_Boss.ReqMySelfBossRemainTime",
    [MSG_Boss.ReqMySelfBossAuto] = "MSG_Boss.ReqMySelfBossAuto",
    [MSG_Boss.ReqMySelfBossUseItem] = "MSG_Boss.ReqMySelfBossUseItem",
    [MSG_Boss.ReqNoobBossPannel] = "MSG_Boss.ReqNoobBossPannel",
    [MSG_Boss.ReqCallBigR] = "MSG_Boss.ReqCallBigR",
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

return MSG_Boss

