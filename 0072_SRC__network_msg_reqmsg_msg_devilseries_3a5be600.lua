local MSG_DevilSeries = {
    ReqFollowDeviBoss = {
       cloneId = 0,
       followValue = false,
    },
    FollowData = {
       headName = "",
       endTime = 0,
       mapId = 0,
       career = 0,
       roleId = 0,
       head = nil,
    },
    DeviBossState = {
       cloneId = 0,
       followValue = false,
       followDataList = List:New(),
    },
    ReqOpenDeviBossPanel = {
    },
    ReqCreateDeviBossMap = {
       cloneId = 0,
    },
    ReqEnterDeviBossMap = {
       mapId = 0,
    },
    DeviBossIntegral = {
       name = "",
       intergral = 0,
       rank = 0,
    },
    ReqSynDeviBossIntegral = {
    },
    DevilCardCamp = {
       campId = 0,
       card = List:New(),
       active = false,
    },
    DevilCard = {
       id = 0,
       part = List:New(),
       level = 0,
       rank = 0,
       active = false,
       breakLv = 0,
       fightPoint = 0,
    },
    DevilEquipPart = {
       id = 0,
       equip = nil,
    },
    ReqDevilEquipWear = {
       equipId = 0,
       campId = 0,
       cardId = 0,
       cellId = 0,
    },
    ReqDevilCardBreak = {
       campId = 0,
       cardId = 0,
       equipId = List:New(),
    },
    ReqDevilCardUp = {
       campId = 0,
       cardId = 0,
       type = 0,
    },
    ReqDevilEquipSynthesis = {
       itemId = 0,
       equips = List:New(),
    },
    ReqDevilHunt = {
       huntType = 0,
       consecutiveType = 0,
    },
    ReqDevilHuntPanel = {
    },
}
local L_StrDic = {
    [MSG_DevilSeries.ReqFollowDeviBoss] = "MSG_DevilSeries.ReqFollowDeviBoss",
    [MSG_DevilSeries.ReqOpenDeviBossPanel] = "MSG_DevilSeries.ReqOpenDeviBossPanel",
    [MSG_DevilSeries.ReqCreateDeviBossMap] = "MSG_DevilSeries.ReqCreateDeviBossMap",
    [MSG_DevilSeries.ReqEnterDeviBossMap] = "MSG_DevilSeries.ReqEnterDeviBossMap",
    [MSG_DevilSeries.ReqSynDeviBossIntegral] = "MSG_DevilSeries.ReqSynDeviBossIntegral",
    [MSG_DevilSeries.ReqDevilEquipWear] = "MSG_DevilSeries.ReqDevilEquipWear",
    [MSG_DevilSeries.ReqDevilCardBreak] = "MSG_DevilSeries.ReqDevilCardBreak",
    [MSG_DevilSeries.ReqDevilCardUp] = "MSG_DevilSeries.ReqDevilCardUp",
    [MSG_DevilSeries.ReqDevilEquipSynthesis] = "MSG_DevilSeries.ReqDevilEquipSynthesis",
    [MSG_DevilSeries.ReqDevilHunt] = "MSG_DevilSeries.ReqDevilHunt",
    [MSG_DevilSeries.ReqDevilHuntPanel] = "MSG_DevilSeries.ReqDevilHuntPanel",
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

return MSG_DevilSeries

