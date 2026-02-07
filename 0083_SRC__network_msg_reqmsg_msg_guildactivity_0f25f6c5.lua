local MSG_GuildActivity = {
    ReqOpenRankPanel = {
    },
    guildMenberRankInfo = {
       rank = 0,
       realm = 0,
       name = "",
       level = 0,
       fight = 0,
    },
    guildRankInfo = {
       guildId = 0,
       name = "",
       menberRank = List:New(),
       myRank = nil,
    },
    ReqOpenAllBossPanel = {
    },
    survival = {
       type = 0,
       num = 0,
    },
    monsterRemain = {
       guildId = 0,
       name = "",
       survival = List:New(),
    },
    detailFudiInfo = {
       type = 0,
       score = 0,
       resurgenceTime = List:New(),
       attentionList = List:New(),
    },
    ReqDayScoreReward = {
       id = 0,
    },
    monsterResurgenceTime = {
       monsterModelId = 0,
       resurgenceTime = 0,
       monsterType = 0,
       level = 0,
    },
    ReqAttentionMonster = {
       monsterModelId = 0,
       type = 0,
    },
    bossHarmInfo = {
       id = 0,
       name = "",
       damage = 0,
    },
    fightingBossInfo = {
       level = 0,
       configId = 0,
       hp = 0,
       type = 0,
    },
    ReqMyFightingBoss = {
    },
    harmRank = {
       top = 0,
       name = "",
       harm = 0,
    },
    ReqSnatchPanel = {
    },
    ReqPanelReady = {
    },
    GuardBlood = {
       modelId = 0,
       blood = 0,
    },
    GuildActiveBabyInfo = {
       name = "",
       score = 0,
    },
    GuildActiveBabyReward = {
       name = "",
       rewardExcelId = 0,
    },
    ReqGuildActiveBabyInfo = {
    },
    ReqFudiHelp = {
       cfgId = 0,
    },
    ReqFudiCanHelp = {
       cfgId = 0,
    },
    GuildLastBattleInfo = {
       rank = 0,
       id = 0,
       score = 0,
    },
    GuildLastBattleRoleInfo = {
       playerId = 0,
       name = "",
       career = nil,
       rank = nil,
       score = nil,
       facade = nil,
       fashion = List:New(),
    },
    ReqGuildLastBattleRoleKill = {
    },
}
local L_StrDic = {
    [MSG_GuildActivity.ReqOpenRankPanel] = "MSG_GuildActivity.ReqOpenRankPanel",
    [MSG_GuildActivity.ReqOpenAllBossPanel] = "MSG_GuildActivity.ReqOpenAllBossPanel",
    [MSG_GuildActivity.ReqDayScoreReward] = "MSG_GuildActivity.ReqDayScoreReward",
    [MSG_GuildActivity.ReqAttentionMonster] = "MSG_GuildActivity.ReqAttentionMonster",
    [MSG_GuildActivity.ReqMyFightingBoss] = "MSG_GuildActivity.ReqMyFightingBoss",
    [MSG_GuildActivity.ReqSnatchPanel] = "MSG_GuildActivity.ReqSnatchPanel",
    [MSG_GuildActivity.ReqPanelReady] = "MSG_GuildActivity.ReqPanelReady",
    [MSG_GuildActivity.ReqGuildActiveBabyInfo] = "MSG_GuildActivity.ReqGuildActiveBabyInfo",
    [MSG_GuildActivity.ReqFudiHelp] = "MSG_GuildActivity.ReqFudiHelp",
    [MSG_GuildActivity.ReqFudiCanHelp] = "MSG_GuildActivity.ReqFudiCanHelp",
    [MSG_GuildActivity.ReqGuildLastBattleRoleKill] = "MSG_GuildActivity.ReqGuildLastBattleRoleKill",
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

return MSG_GuildActivity

