local MSG_GuildCrossFud = {
    CrossFudCamp = {
       camp = 0,
       serverId = List:New(),
       score = nil,
    },
    CrossFudRole = {
       playerId = 0,
       name = nil,
       rank = nil,
       score = nil,
       kill = nil,
       damage = nil,
       career = nil,
       inFud = nil,
       camp = nil,
       facade = nil,
    },
    CrossFudBoss = {
       bossId = 0,
       hp = nil,
       isDie = nil,
       care = nil,
       time = nil,
    },
    CrossFudBox = {
       boxId = nil,
       isGet = false,
       isLock = nil,
    },
    CrossFudCity = {
       cityId = 0,
       camp = nil,
       state = 0,
       box = {
            boxId = nil,
            isGet = false,
            isLock = nil,
        },

       remainBoss = nil,
       enterRole = nil,
       remainDevilBoss = nil,
    },
    ReqAllCrossFudInfo = {
    },
    ReqCrossFudUnLockScoreBox = {
       boxId = 0,
    },
    ReqCrossFudScoreBoxOpen = {
       boxId = 0,
    },
    ReqCrossFudBoxOpen = {
       cityId = 0,
    },
    ReqCrossFudCityInfo = {
       city = 0,
       type = nil,
    },
    ReqCrossFudRank = {
       type = 0,
    },
    ReqCrossFudCareBoss = {
       type = 0,
       cityId = 0,
       bossId = 0,
    },
    ReqCrossFudEnter = {
       cityId = 0,
       type = nil,
    },
    ReqDevilBossList = {
    },
}
local L_StrDic = {
    [MSG_GuildCrossFud.ReqAllCrossFudInfo] = "MSG_GuildCrossFud.ReqAllCrossFudInfo",
    [MSG_GuildCrossFud.ReqCrossFudUnLockScoreBox] = "MSG_GuildCrossFud.ReqCrossFudUnLockScoreBox",
    [MSG_GuildCrossFud.ReqCrossFudScoreBoxOpen] = "MSG_GuildCrossFud.ReqCrossFudScoreBoxOpen",
    [MSG_GuildCrossFud.ReqCrossFudBoxOpen] = "MSG_GuildCrossFud.ReqCrossFudBoxOpen",
    [MSG_GuildCrossFud.ReqCrossFudCityInfo] = "MSG_GuildCrossFud.ReqCrossFudCityInfo",
    [MSG_GuildCrossFud.ReqCrossFudRank] = "MSG_GuildCrossFud.ReqCrossFudRank",
    [MSG_GuildCrossFud.ReqCrossFudCareBoss] = "MSG_GuildCrossFud.ReqCrossFudCareBoss",
    [MSG_GuildCrossFud.ReqCrossFudEnter] = "MSG_GuildCrossFud.ReqCrossFudEnter",
    [MSG_GuildCrossFud.ReqDevilBossList] = "MSG_GuildCrossFud.ReqDevilBossList",
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

return MSG_GuildCrossFud

