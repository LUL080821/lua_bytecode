local MSG_RankList = {
    RankInfo = {
       rank = 0,
       roleName = "",
       rankData = "",
       roleId = 0,
       career = 0,
       isOnline = false,
       level = 0,
       fightPower = 0,
       beWorshipedNum = nil,
       viplevel = nil,
       nameMark = nil,
       beWorship = nil,
       head = nil,
    },
    ImmortalEquipInfo = {
       suitKey = 0,
       immortalEquipIds = List:New(),
    },
    EquipWash = {
       id = 0,
       per = 0,
       value = 0,
       poolId = 0,
    },
    EquipInfo = {
       level = 0,
       equipID = 0,
       equipWashList = List:New(),
       gemIds = List:New(),
       jadeIds = List:New(),
       jinlianlevel = nil,
       suitId = nil,
       isBind = nil,
    },
    RankPlayerImageInfo = {
       roleId = 0,
       roleName = "",
       career = 0,
       level = 0,
       beWorshipedNum = 0,
       horseModel = nil,
       faBaoModel = nil,
       stateVip = nil,
       stifleFabaoId = nil,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

       beWorship = false,
       equipInfoList = List:New(),
       immortalEquipInfoList = List:New(),
       fightPetID = nil,
       soulId = nil,
       mental = nil,
       vipLvl = nil,
       guildName = nil,
    },
    AttrInfo = {
       id = 0,
       owenValue = 0,
       otherValue = 0,
    },
    ReqRankInfo = {
       rankKind = 0,
    },
    ReqRankPlayerImageInfo = {
       rankPlayerId = 0,
    },
    ReqWorship = {
       worshipPlayerId = 0,
    },
    ReqCompareAttr = {
       comparePlayerId = 0,
    },
    ReqHallFamePanel = {
    },
    ReqUniverseRankPanel = {
    },
    RankListState = {
       rankId = 0,
       state = 0,
    },
    ReqGetAllRankListState = {
    },
}
local L_StrDic = {
    [MSG_RankList.ReqRankInfo] = "MSG_RankList.ReqRankInfo",
    [MSG_RankList.ReqRankPlayerImageInfo] = "MSG_RankList.ReqRankPlayerImageInfo",
    [MSG_RankList.ReqWorship] = "MSG_RankList.ReqWorship",
    [MSG_RankList.ReqCompareAttr] = "MSG_RankList.ReqCompareAttr",
    [MSG_RankList.ReqHallFamePanel] = "MSG_RankList.ReqHallFamePanel",
    [MSG_RankList.ReqUniverseRankPanel] = "MSG_RankList.ReqUniverseRankPanel",
    [MSG_RankList.ReqGetAllRankListState] = "MSG_RankList.ReqGetAllRankListState",
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

return MSG_RankList

