local MSG_SoulArmor = {
    SoulArmorBallSlot = {
       slot = 0,
       level = 0,
       isOpen = false,
       ball = nil,
    },
    ReqSoulArmorBag = {
    },
    ReqSplitSoulArmorBall = {
       ballIds = List:New(),
    },
    ReqWearSoulArmorBall = {
       slotId = 0,
       ballId = 0,
    },
    ReqUnWearSoulArmorBall = {
       slotId = 0,
    },
    ReqUpSoulArmor = {
    },
    ReqUpSoulArmorQuality = {
    },
    ReqUpSoulArmorSkill = {
    },
    ReqOpenSoulArmorLottery = {
    },
    ReqSoulArmorLottery = {
       type = 0,
       count = 0,
       gold = nil,
    },
    ReqUpSoulArmorSlotLevel = {
       slotId = 0,
    },
    ReqChangeArmorSkill = {
       skillId = 0,
    },
    ReqSoulArmorMerge = {
       slotId = 0,
       equips = List:New(),
    },
}
local L_StrDic = {
    [MSG_SoulArmor.ReqSoulArmorBag] = "MSG_SoulArmor.ReqSoulArmorBag",
    [MSG_SoulArmor.ReqSplitSoulArmorBall] = "MSG_SoulArmor.ReqSplitSoulArmorBall",
    [MSG_SoulArmor.ReqWearSoulArmorBall] = "MSG_SoulArmor.ReqWearSoulArmorBall",
    [MSG_SoulArmor.ReqUnWearSoulArmorBall] = "MSG_SoulArmor.ReqUnWearSoulArmorBall",
    [MSG_SoulArmor.ReqUpSoulArmor] = "MSG_SoulArmor.ReqUpSoulArmor",
    [MSG_SoulArmor.ReqUpSoulArmorQuality] = "MSG_SoulArmor.ReqUpSoulArmorQuality",
    [MSG_SoulArmor.ReqUpSoulArmorSkill] = "MSG_SoulArmor.ReqUpSoulArmorSkill",
    [MSG_SoulArmor.ReqOpenSoulArmorLottery] = "MSG_SoulArmor.ReqOpenSoulArmorLottery",
    [MSG_SoulArmor.ReqSoulArmorLottery] = "MSG_SoulArmor.ReqSoulArmorLottery",
    [MSG_SoulArmor.ReqUpSoulArmorSlotLevel] = "MSG_SoulArmor.ReqUpSoulArmorSlotLevel",
    [MSG_SoulArmor.ReqChangeArmorSkill] = "MSG_SoulArmor.ReqChangeArmorSkill",
    [MSG_SoulArmor.ReqSoulArmorMerge] = "MSG_SoulArmor.ReqSoulArmorMerge",
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

return MSG_SoulArmor

