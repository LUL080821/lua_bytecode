local MSG_WorldHelp = {
    Player = {
       roleID = 0,
       name = "",
       level = 0,
       career = 0,
       head = nil,
    },
    WorldHelp = {
       id = 0,
       player = {
            roleID = 0,
            name = "",
            level = 0,
            career = 0,
            head = nil,
        },

       bossID = 0,
       helpNum = 0,
       mapId = 0,
       reqTime = 0,
    },
    GuildTaskHelp = {
       id = 0,
       player = {
            roleID = 0,
            name = "",
            level = 0,
            career = 0,
            head = nil,
        },

       taskId = 0,
       teamId = 0,
       helpNum = 0,
    },
    ReqWorldHelp = {
       bossCode = 0,
    },
    ReqWorldHelpList = {
    },
    ReqAtLastHelp = {
    },
    ReqThkHelp = {
       id = 0,
       words = "",
    },
    ReqCancelHelp = {
    },
    ReqJoinHelp = {
       id = 0,
    },
    ReqGuildTaskHelp = {
    },
    ReqDieCallHelp = {
    },
}
local L_StrDic = {
    [MSG_WorldHelp.ReqWorldHelp] = "MSG_WorldHelp.ReqWorldHelp",
    [MSG_WorldHelp.ReqWorldHelpList] = "MSG_WorldHelp.ReqWorldHelpList",
    [MSG_WorldHelp.ReqAtLastHelp] = "MSG_WorldHelp.ReqAtLastHelp",
    [MSG_WorldHelp.ReqThkHelp] = "MSG_WorldHelp.ReqThkHelp",
    [MSG_WorldHelp.ReqCancelHelp] = "MSG_WorldHelp.ReqCancelHelp",
    [MSG_WorldHelp.ReqJoinHelp] = "MSG_WorldHelp.ReqJoinHelp",
    [MSG_WorldHelp.ReqGuildTaskHelp] = "MSG_WorldHelp.ReqGuildTaskHelp",
    [MSG_WorldHelp.ReqDieCallHelp] = "MSG_WorldHelp.ReqDieCallHelp",
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

return MSG_WorldHelp

