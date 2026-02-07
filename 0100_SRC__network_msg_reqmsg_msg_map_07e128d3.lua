local MSG_Map = {
    ReqTransport = {
       transportId = 0,
    },
    ReqMoveTo = {
       curPos = {
            x = 0,
            y = 0,
        },

       posList = List:New(),
       mapId = 0,
    },
    ReqPetMoveTo = {
       curPos = {
            x = 0,
            y = 0,
        },

       posList = List:New(),
       mapId = 0,
    },
    ReqJump = {
       curX = 0,
       curY = 0,
       height = 0,
       startTarX = 0,
       startTarY = 0,
       endTarX = 0,
       endTarY = 0,
       stage = 0,
    },
    ReqStopMove = {
       pos = {
            x = 0,
            y = 0,
        },

       mapId = 0,
    },
    ReqPetStopMove = {
       pos = {
            x = 0,
            y = 0,
        },

       mapId = 0,
    },
    ReqDirMove = {
       curPos = {
            x = 0,
            y = 0,
        },

       dir = {
            x = 0,
            y = 0,
        },

       mapId = 0,
    },
    ReqGather = {
       id = 0,
    },
    ReqRelive = {
       type = 0,
       isUseGold = false,
    },
    ReqGetLines = {
    },
    ReqSelectLine = {
       line = 0,
    },
    ReqJumpDown = {
       tarX = 0,
       tarY = 0,
    },
    ReqJumpBlock = {
       target = {
            x = 0,
            y = 0,
        },

    },
    ReqPetJumpBlock = {
       target = {
            x = 0,
            y = 0,
        },

    },
    ReqFabaoJumpBlock = {
       target = {
            x = 0,
            y = 0,
        },

    },
    ReqGetMonsterPos = {
    },
    ReqTransportControl = {
       type = 0,
       mapID = 0,
       x = 0,
       y = 0,
       param = 0,
    },
    ReqCineMatic = {
       plotId = 0,
    },
    ReqSynPos = {
       x = 0,
       y = 0,
    },
    BlockDoor = {
       id = "",
       isopen = false,
    },
    RoleStatue = {
       id = 0,
       isUseDef = false,
       name = nil,
       career = nil,
       degree = nil,
       wingId = nil,
       clothesEquipId = nil,
       weaponsEquipId = nil,
       clothesStar = nil,
       weaponStar = nil,
       roleId = nil,
    },
    ReqGroundBuffStar = {
       gbid = 0,
    },
}
local L_StrDic = {
    [MSG_Map.ReqTransport] = "MSG_Map.ReqTransport",
    [MSG_Map.ReqMoveTo] = "MSG_Map.ReqMoveTo",
    [MSG_Map.ReqPetMoveTo] = "MSG_Map.ReqPetMoveTo",
    [MSG_Map.ReqJump] = "MSG_Map.ReqJump",
    [MSG_Map.ReqStopMove] = "MSG_Map.ReqStopMove",
    [MSG_Map.ReqPetStopMove] = "MSG_Map.ReqPetStopMove",
    [MSG_Map.ReqDirMove] = "MSG_Map.ReqDirMove",
    [MSG_Map.ReqGather] = "MSG_Map.ReqGather",
    [MSG_Map.ReqRelive] = "MSG_Map.ReqRelive",
    [MSG_Map.ReqGetLines] = "MSG_Map.ReqGetLines",
    [MSG_Map.ReqSelectLine] = "MSG_Map.ReqSelectLine",
    [MSG_Map.ReqJumpDown] = "MSG_Map.ReqJumpDown",
    [MSG_Map.ReqJumpBlock] = "MSG_Map.ReqJumpBlock",
    [MSG_Map.ReqPetJumpBlock] = "MSG_Map.ReqPetJumpBlock",
    [MSG_Map.ReqFabaoJumpBlock] = "MSG_Map.ReqFabaoJumpBlock",
    [MSG_Map.ReqGetMonsterPos] = "MSG_Map.ReqGetMonsterPos",
    [MSG_Map.ReqTransportControl] = "MSG_Map.ReqTransportControl",
    [MSG_Map.ReqCineMatic] = "MSG_Map.ReqCineMatic",
    [MSG_Map.ReqSynPos] = "MSG_Map.ReqSynPos",
    [MSG_Map.ReqGroundBuffStar] = "MSG_Map.ReqGroundBuffStar",
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

return MSG_Map

