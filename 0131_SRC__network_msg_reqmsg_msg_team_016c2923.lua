local MSG_Team = {
    TeamMember = {
       roleId = 0,
       name = "",
       level = 0,
       career = 0,
       power = 0,
       isLeader = false,
       isOnline = false,
       stateLv = 0,
       hpPro = nil,
       mapKey = nil,
       inchat = nil,
       isOfflineHungup = nil,
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
    Freedomer = {
       roleId = 0,
       name = "",
       level = 0,
       career = 0,
       power = 0,
       honey = 0,
       guildName = nil,
       moonandOver = nil,
       birthGroup = nil,
       head = nil,
    },
    TeamInfo = {
       teamId = 0,
       type = 0,
       members = List:New(),
       autoAccept = false,
    },
    ReqCreateTeam = {
       type = 0,
       autoAccept = false,
    },
    ReqAlterTeam = {
       teamId = 0,
       isNotice = false,
       type = 0,
    },
    ReqGetFreedomList = {
       type = 0,
    },
    ReqInvite = {
       roleid = 0,
    },
    ReqInviteRes = {
       teamdId = 0,
       roleId = 0,
       type = 0,
    },
    ReqGetApplyList = {
    },
    ReqApplyOpt = {
       id = 0,
       type = 0,
    },
    ReqGetWaitList = {
       type = 0,
    },
    ReqApplyEnter = {
       teamId = 0,
    },
    ReqTeamOpt = {
       targetId = 0,
       opt = 0,
    },
    ReqCallAllMember = {
    },
    ReqAgreeCall = {
       callId = 0,
    },
    ReqTransport2Leader = {
    },
    ReqCleanApplyList = {
    },
    ReqMatchAll = {
       type = 0,
       match = false,
    },
    ReqGetTeamInfo = {
    },
    ReqTeamLeaderOpenState = {
    },
}
local L_StrDic = {
    [MSG_Team.ReqCreateTeam] = "MSG_Team.ReqCreateTeam",
    [MSG_Team.ReqAlterTeam] = "MSG_Team.ReqAlterTeam",
    [MSG_Team.ReqGetFreedomList] = "MSG_Team.ReqGetFreedomList",
    [MSG_Team.ReqInvite] = "MSG_Team.ReqInvite",
    [MSG_Team.ReqInviteRes] = "MSG_Team.ReqInviteRes",
    [MSG_Team.ReqGetApplyList] = "MSG_Team.ReqGetApplyList",
    [MSG_Team.ReqApplyOpt] = "MSG_Team.ReqApplyOpt",
    [MSG_Team.ReqGetWaitList] = "MSG_Team.ReqGetWaitList",
    [MSG_Team.ReqApplyEnter] = "MSG_Team.ReqApplyEnter",
    [MSG_Team.ReqTeamOpt] = "MSG_Team.ReqTeamOpt",
    [MSG_Team.ReqCallAllMember] = "MSG_Team.ReqCallAllMember",
    [MSG_Team.ReqAgreeCall] = "MSG_Team.ReqAgreeCall",
    [MSG_Team.ReqTransport2Leader] = "MSG_Team.ReqTransport2Leader",
    [MSG_Team.ReqCleanApplyList] = "MSG_Team.ReqCleanApplyList",
    [MSG_Team.ReqMatchAll] = "MSG_Team.ReqMatchAll",
    [MSG_Team.ReqGetTeamInfo] = "MSG_Team.ReqGetTeamInfo",
    [MSG_Team.ReqTeamLeaderOpenState] = "MSG_Team.ReqTeamLeaderOpenState",
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

return MSG_Team

