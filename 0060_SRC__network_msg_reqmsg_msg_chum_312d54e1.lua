local MSG_Chum = {
    Player = {
       roleID = 0,
       name = "",
       level = 0,
       vipLvl = 0,
       career = 0,
    },
    Member = {
       player = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       power = 0,
       exp = 0,
       online = false,
    },
    Chum = {
       id = 0,
       c1 = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       c2 = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       name = "",
       anno = "",
       lvl = 0,
       exp = 0,
       freeT = 0,
       num = 0,
       members = List:New(),
    },
    Rank = {
       c1 = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       c2 = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       name = "",
       lvl = 0,
    },
    Friend = {
       player = {
            roleID = 0,
            name = "",
            level = 0,
            vipLvl = 0,
            career = 0,
        },

       name = "",
       id = 0,
       createPName = "",
    },
    ReqChum = {
    },
    ReqRank = {
    },
    ReqFriend = {
    },
    ReqInvite = {
       roleID = 0,
    },
    ReqInviteConfirm = {
       inviteID = 0,
       agree = false,
    },
    ReqChangeName = {
       name = "",
    },
    ReqChangeAnno = {
       anno = "",
    },
    ReqKick = {
       tID = 0,
    },
    ReqExit = {
    },
    ReqCallSoul = {
    },
}
local L_StrDic = {
    [MSG_Chum.ReqChum] = "MSG_Chum.ReqChum",
    [MSG_Chum.ReqRank] = "MSG_Chum.ReqRank",
    [MSG_Chum.ReqFriend] = "MSG_Chum.ReqFriend",
    [MSG_Chum.ReqInvite] = "MSG_Chum.ReqInvite",
    [MSG_Chum.ReqInviteConfirm] = "MSG_Chum.ReqInviteConfirm",
    [MSG_Chum.ReqChangeName] = "MSG_Chum.ReqChangeName",
    [MSG_Chum.ReqChangeAnno] = "MSG_Chum.ReqChangeAnno",
    [MSG_Chum.ReqKick] = "MSG_Chum.ReqKick",
    [MSG_Chum.ReqExit] = "MSG_Chum.ReqExit",
    [MSG_Chum.ReqCallSoul] = "MSG_Chum.ReqCallSoul",
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

return MSG_Chum

