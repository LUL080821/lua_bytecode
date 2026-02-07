local MSG_zone = {
    cloneTeamInfo = {
       roleId = 0,
       carear = 0,
       serverId = 0,
       ready = false,
       leader = false,
       roleName = "",
       level = 0,
       power = nil,
       isRobot = nil,
       head = nil,
    },
    ReqEnterZone = {
       modelId = 0,
       param = nil,
    },
    ReqTeamAcceptEnterZone = {
       ready = false,
       modelId = 0,
    },
    ReqReadyZone = {
       teamId = nil,
       ready = false,
    },
    ReqCancelMatch = {
    },
    ReqSweepZone = {
       modelId = 0,
       resolve = nil,
       bossNum = nil,
       param = nil,
    },
    itemInfo = {
       modelId = 0,
       num = 0,
    },
}
local L_StrDic = {
    [MSG_zone.ReqEnterZone] = "MSG_zone.ReqEnterZone",
    [MSG_zone.ReqTeamAcceptEnterZone] = "MSG_zone.ReqTeamAcceptEnterZone",
    [MSG_zone.ReqReadyZone] = "MSG_zone.ReqReadyZone",
    [MSG_zone.ReqCancelMatch] = "MSG_zone.ReqCancelMatch",
    [MSG_zone.ReqSweepZone] = "MSG_zone.ReqSweepZone",
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

return MSG_zone

