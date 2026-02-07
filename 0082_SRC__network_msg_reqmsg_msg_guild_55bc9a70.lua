local MSG_Guild = {
    GuildInfo = {
       guildId = 0,
       name = "",
       lv = 0,
       notice = "",
       guildMoney = 0,
       icon = 0,
       isAutoJoin = false,
       limitLv = nil,
       fightLv = nil,
       members = List:New(),
       applys = List:New(),
       builds = List:New(),
       recruitCd = 0,
       rank = nil,
       titles = List:New(),
       rate = 0,
       maxNum = 0,
       power = nil,
    },
    GuildTitle = {
       rank = 0,
       roleId = 0,
    },
    GuildBaseInfo = {
       guildId = 0,
       name = "",
       lv = 0,
       memberNum = 0,
       isApply = false,
       limitLv = 0,
       limitfight = 0,
       fighting = 0,
       isAutoJoin = false,
       member = {
            roleId = 0,
            name = "",
            career = 0,
            lv = 0,
            vip = 0,
            allcontribute = 0,
            lastOffTime = 0,
            fighting = 0,
            position = 0,
            isProxy = false,
            head = nil,
        },

       rate = 0,
       maxNum = 0,
       notice = nil,
    },
    GuildMemberInfo = {
       roleId = 0,
       name = "",
       career = 0,
       lv = 0,
       vip = 0,
       allcontribute = 0,
       lastOffTime = 0,
       fighting = 0,
       position = 0,
       isProxy = false,
       head = nil,
    },
    GuildApplyInfo = {
       roleId = 0,
       name = "",
       lv = 0,
       fighting = 0,
       career = 0,
       head = nil,
    },
    GuildBuilding = {
       type = 0,
       level = 0,
    },
    GuildLogInfo = {
       type = 0,
       time = 0,
       str = List:New(),
    },
    GuildGift = {
       id = 0,
       gift = 0,
       sender = "",
       timeOut = 0,
       reward = List:New(),
    },
    GuildGiftHistory = {
       sender = "",
       gift = 0,
       time = 0,
    },
    ReqRecommendGuild = {
    },
    ReqCreateGuild = {
       name = "",
       icon = 0,
       notice = nil,
    },
    ReqJoinGuild = {
       ids = List:New(),
    },
    ReqDealApplyInfo = {
       roleId = List:New(),
       agree = false,
    },
    ReqChangeGuildName = {
       name = "",
    },
    ReqSetRank = {
       roleId = 0,
       rank = 0,
    },
    ReqChangeGuildSetting = {
       isAutoApply = false,
       lv = nil,
       icon = nil,
       notice = nil,
       fightPoint = nil,
    },
    ReqGuildLogList = {
    },
    ReqGuildInfo = {
    },
    ReqKickOutGuild = {
       roleId = 0,
    },
    ReqQuitGuild = {
    },
    ReqUpBuildingLevel = {
       type = 0,
    },
    ReqImpeach = {
    },
    ReqReceiveItem = {
    },
    ReqGuildJoinPlayer = {
    },
    ReqGuildBaseEnter = {
    },
    ReqGuildGiftOpen = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_Guild.ReqRecommendGuild] = "MSG_Guild.ReqRecommendGuild",
    [MSG_Guild.ReqCreateGuild] = "MSG_Guild.ReqCreateGuild",
    [MSG_Guild.ReqJoinGuild] = "MSG_Guild.ReqJoinGuild",
    [MSG_Guild.ReqDealApplyInfo] = "MSG_Guild.ReqDealApplyInfo",
    [MSG_Guild.ReqChangeGuildName] = "MSG_Guild.ReqChangeGuildName",
    [MSG_Guild.ReqSetRank] = "MSG_Guild.ReqSetRank",
    [MSG_Guild.ReqChangeGuildSetting] = "MSG_Guild.ReqChangeGuildSetting",
    [MSG_Guild.ReqGuildLogList] = "MSG_Guild.ReqGuildLogList",
    [MSG_Guild.ReqGuildInfo] = "MSG_Guild.ReqGuildInfo",
    [MSG_Guild.ReqKickOutGuild] = "MSG_Guild.ReqKickOutGuild",
    [MSG_Guild.ReqQuitGuild] = "MSG_Guild.ReqQuitGuild",
    [MSG_Guild.ReqUpBuildingLevel] = "MSG_Guild.ReqUpBuildingLevel",
    [MSG_Guild.ReqImpeach] = "MSG_Guild.ReqImpeach",
    [MSG_Guild.ReqReceiveItem] = "MSG_Guild.ReqReceiveItem",
    [MSG_Guild.ReqGuildJoinPlayer] = "MSG_Guild.ReqGuildJoinPlayer",
    [MSG_Guild.ReqGuildBaseEnter] = "MSG_Guild.ReqGuildBaseEnter",
    [MSG_Guild.ReqGuildGiftOpen] = "MSG_Guild.ReqGuildGiftOpen",
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

return MSG_Guild

