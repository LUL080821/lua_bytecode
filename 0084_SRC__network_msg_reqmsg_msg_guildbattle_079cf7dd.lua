local MSG_GuildBattle = {
    GuildBattleRate = {
       guildName = "",
       type = 0,
       flag = 0,
    },
    GuildBattleCamp = {
       guildName = "",
       icon = 0,
    },
    GuildBattleItem = {
       id = 0,
       num = 0,
    },
    GuildBattleGather = {
       monsterId = 0,
       time = 0,
    },
    GuildBattleMember = {
       name = "",
       career = 0,
       record = 0,
       killNum = 0,
       destroyNum = 0,
       repairNum = 0,
       breakNum = 0,
    },
    GuildBattleRecord = {
       guildName = "",
       guildScore = 0,
       res = false,
       members = List:New(),
       icon = 0,
    },
    GuildBattleMemberRecord = {
       roelId = 0,
       name = "",
       title = 0,
       career = 0,
       record = 0,
       killRank = 0,
       isBast = false,
       isAttCity = false,
       head = nil,
    },
    ReqGuildBattleRateList = {
    },
    ReqGuildBattleRecordList = {
    },
    ReqGuildBattleRecordWin = {
    },
    ReqGuildBattleRecordReward = {
       id = 0,
    },
    ReqGuildBattleBack = {
    },
    ReqGuildBattleLike = {
       roleId = 0,
       type = 0,
    },
    ReqGuildBattleResult = {
    },
    ReqGuildBattleStat = {
    },
    ReqGuildBattleCall = {
    },
    BattleEvent = {
       modelId = 0,
       start = 0,
    },
    ReqSendBulletScreen = {
       context = "",
       type = 0,
    },
}
local L_StrDic = {
    [MSG_GuildBattle.ReqGuildBattleRateList] = "MSG_GuildBattle.ReqGuildBattleRateList",
    [MSG_GuildBattle.ReqGuildBattleRecordList] = "MSG_GuildBattle.ReqGuildBattleRecordList",
    [MSG_GuildBattle.ReqGuildBattleRecordWin] = "MSG_GuildBattle.ReqGuildBattleRecordWin",
    [MSG_GuildBattle.ReqGuildBattleRecordReward] = "MSG_GuildBattle.ReqGuildBattleRecordReward",
    [MSG_GuildBattle.ReqGuildBattleBack] = "MSG_GuildBattle.ReqGuildBattleBack",
    [MSG_GuildBattle.ReqGuildBattleLike] = "MSG_GuildBattle.ReqGuildBattleLike",
    [MSG_GuildBattle.ReqGuildBattleResult] = "MSG_GuildBattle.ReqGuildBattleResult",
    [MSG_GuildBattle.ReqGuildBattleStat] = "MSG_GuildBattle.ReqGuildBattleStat",
    [MSG_GuildBattle.ReqGuildBattleCall] = "MSG_GuildBattle.ReqGuildBattleCall",
    [MSG_GuildBattle.ReqSendBulletScreen] = "MSG_GuildBattle.ReqSendBulletScreen",
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

return MSG_GuildBattle

