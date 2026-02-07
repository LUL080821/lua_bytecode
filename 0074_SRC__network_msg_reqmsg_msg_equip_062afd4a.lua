local MSG_Equip = {
    EquipWashInfo = {
       index = 0,
       per = 0,
       value = 0,
       poolId = 0,
    },
    EquipStrengthUpInfo = {
       index = 0,
       itemId = 0,
       value = 0,
    },
    EquipStrengthInfo = {
       type = 0,
       level = 0,
       exp = 0,
    },
    EquipPartInfo = {
       type = 0,
       washInfo = List:New(),
       strengthInfo = nil,
       gemInfo = nil,
       equip = nil,
       raisalInfo = List:New(),
       attrSpecial = List:New(),
    },
    CacheLog = {
       log = nil,
       name = nil,
       item = nil,
    },
    EquipCastInfo = {
       part = 0,
       id = 0,
    },
    EquipPartInfoBags = {
       itemId = 0,
       infos = List:New(),
    },
    ReqEquipWear = {
       equipId = 0,
       Inherit = false,
    },
    ReqEquipUnWear = {
       equipId = 0,
    },
    ReqEquipSell = {
       id = List:New(),
    },
    ReqEquipResolveSet = {
    },
    ReqAutoResolveSet = {
       qualitys = List:New(),
    },
    ReqEquipGodTried = {
       itemId = 0,
    },
    ReqOpenGodTried = {
    },
    ReqEquipSyn = {
       id = 0,
       equipIds = List:New(),
       isHaveItem = nil,
       isHaveAuction = nil,
       type = 0,
    },
    ReqEquipSuit = {
       eId = 0,
       sid = 0,
    },
    ReqEquipSuitStoneSyn = {
       sid = 0,
       isOneKey = false,
    },
    ReqEquipSynSplit = {
       eId = 0,
    },
    ReqSoulBeastEquipSyn = {
       part = 0,
       equipIds = List:New(),
    },
    ReqActivateCast = {
       part = 0,
    },
    ReqEquipCast = {
       part = 0,
    },
    ReqEquipStrengthUpLevel = {
       type = 0,
       upInfos = List:New(),
    },
    ReqEquipMoveLevel = {
       part = 0,
       upInfos = List:New(),
       equipId = 0,
    },
    ReqEquipSplitLevel = {
       part = 0,
       equipId = 0,
    },
    ReqEquipWash = {
       id = 0,
       indexs = List:New(),
       type = false,
    },
    ReqEquipWashReceive = {
       equipId = 0,
       type = 0,
    },
    ReqEquipAppRaisal = {
       equipId = 0,
       type = 0,
    },
    ReqShenpinEquipUp = {
       part = 0,
       type = 0,
    },
    gemPartInfo = {
       gemIds = List:New(),
       jadeIds = List:New(),
       level = 0,
       exp = 0,
    },
    gemRefine = {
       part = 0,
       level = 0,
       exp = 0,
    },
    ReqInlay = {
       type = 0,
       part = 0,
       gemIndex = 0,
       gemId = 0,
    },
    ReqQuickRefineGem = {
       part = 0,
       itemId = 0,
    },
    ReqAutoRefineGem = {
       part = 0,
    },
    ReqUpGradeGem = {
       part = 0,
       index = 0,
       type = 0,
    },
    ReqQuickRemoveGem = {
       type = 0,
       part = 0,
       index = 0,
    },
}
local L_StrDic = {
    [MSG_Equip.ReqEquipWear] = "MSG_Equip.ReqEquipWear",
    [MSG_Equip.ReqEquipUnWear] = "MSG_Equip.ReqEquipUnWear",
    [MSG_Equip.ReqEquipSell] = "MSG_Equip.ReqEquipSell",
    [MSG_Equip.ReqEquipResolveSet] = "MSG_Equip.ReqEquipResolveSet",
    [MSG_Equip.ReqAutoResolveSet] = "MSG_Equip.ReqAutoResolveSet",
    [MSG_Equip.ReqEquipGodTried] = "MSG_Equip.ReqEquipGodTried",
    [MSG_Equip.ReqOpenGodTried] = "MSG_Equip.ReqOpenGodTried",
    [MSG_Equip.ReqEquipSyn] = "MSG_Equip.ReqEquipSyn",
    [MSG_Equip.ReqEquipSuit] = "MSG_Equip.ReqEquipSuit",
    [MSG_Equip.ReqEquipSuitStoneSyn] = "MSG_Equip.ReqEquipSuitStoneSyn",
    [MSG_Equip.ReqEquipSynSplit] = "MSG_Equip.ReqEquipSynSplit",
    [MSG_Equip.ReqSoulBeastEquipSyn] = "MSG_Equip.ReqSoulBeastEquipSyn",
    [MSG_Equip.ReqActivateCast] = "MSG_Equip.ReqActivateCast",
    [MSG_Equip.ReqEquipCast] = "MSG_Equip.ReqEquipCast",
    [MSG_Equip.ReqEquipStrengthUpLevel] = "MSG_Equip.ReqEquipStrengthUpLevel",
    [MSG_Equip.ReqEquipMoveLevel] = "MSG_Equip.ReqEquipMoveLevel",
    [MSG_Equip.ReqEquipSplitLevel] = "MSG_Equip.ReqEquipSplitLevel",
    [MSG_Equip.ReqEquipWash] = "MSG_Equip.ReqEquipWash",
    [MSG_Equip.ReqEquipWashReceive] = "MSG_Equip.ReqEquipWashReceive",
    [MSG_Equip.ReqEquipAppRaisal] = "MSG_Equip.ReqEquipAppRaisal",
    [MSG_Equip.ReqShenpinEquipUp] = "MSG_Equip.ReqShenpinEquipUp",
    [MSG_Equip.ReqInlay] = "MSG_Equip.ReqInlay",
    [MSG_Equip.ReqQuickRefineGem] = "MSG_Equip.ReqQuickRefineGem",
    [MSG_Equip.ReqAutoRefineGem] = "MSG_Equip.ReqAutoRefineGem",
    [MSG_Equip.ReqUpGradeGem] = "MSG_Equip.ReqUpGradeGem",
    [MSG_Equip.ReqQuickRemoveGem] = "MSG_Equip.ReqQuickRemoveGem",
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

return MSG_Equip

