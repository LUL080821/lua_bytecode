local MSG_Command = {
    CommandInfo = {
       roleId = 0,
       targetId = 0,
       num = 0,
       roleName = nil,
       roleCareer = nil,
       fightPower = nil,
       guildName = nil,
       facade = nil,
       head = nil,
    },
    GuildBattleInfo = {
       rank = 0,
       masterId = 0,
       secMasterId = List:New(),
    },
    ReqJoinCommand = {
    },
    ReqExitCommand = {
    },
    ReqFocusTarget = {
       targetId = 0,
    },
    ReqTargetPos = {
    },
    G2PSynGuildBattleInfo = {
       guildBattleInfos = List:New(),
    },
    ReqCommandBulletScreen = {
       context = "",
    },
}
local L_StrDic = {
    [MSG_Command.ReqJoinCommand] = "MSG_Command.ReqJoinCommand",
    [MSG_Command.ReqExitCommand] = "MSG_Command.ReqExitCommand",
    [MSG_Command.ReqFocusTarget] = "MSG_Command.ReqFocusTarget",
    [MSG_Command.ReqTargetPos] = "MSG_Command.ReqTargetPos",
    [MSG_Command.G2PSynGuildBattleInfo] = "MSG_Command.G2PSynGuildBattleInfo",
    [MSG_Command.ReqCommandBulletScreen] = "MSG_Command.ReqCommandBulletScreen",
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

return MSG_Command

