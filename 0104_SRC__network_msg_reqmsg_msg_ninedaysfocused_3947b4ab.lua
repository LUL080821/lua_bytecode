local MSG_NineDaysFocused = {
    CrossHero = {
       name = "",
       serverName = "",
       career = 0,
       degree = 0,
       lv = 0,
       fightPoint = 0,
       weaponId = 0,
       wingId = 0,
       equipMinStar = 0,
       fashionBodyId = 0,
       fashionWeaponId = 0,
       roleId = 0,
       stifleFabaoId = nil,
    },
    TaskData = {
       taskID = 0,
       alreadyStage = 0,
       targetStage = 0,
       isGet = false,
    },
    ReqApplyNieDaysFocused = {
    },
    ReqOpenTasKPanel = {
    },
    ReqGetTasKReward = {
       taskID = 0,
    },
    BossInfo = {
       uid = 0,
       campAhurtPer = 0,
       campBhurtPer = 0,
    },
}
local L_StrDic = {
    [MSG_NineDaysFocused.ReqApplyNieDaysFocused] = "MSG_NineDaysFocused.ReqApplyNieDaysFocused",
    [MSG_NineDaysFocused.ReqOpenTasKPanel] = "MSG_NineDaysFocused.ReqOpenTasKPanel",
    [MSG_NineDaysFocused.ReqGetTasKReward] = "MSG_NineDaysFocused.ReqGetTasKReward",
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

return MSG_NineDaysFocused

