local MSG_Skill = {
    ReqUpCell = {
    },
    ReqUpSkillStar = {
       skillID = 0,
    },
    ReqActivateMeridian = {
       meridianID = 0,
    },
    ReqSaveFightSkill = {
       playedSkillStr = "",
    },
    ReqResetMeridianSkill = {
    },
    ReqSelectMentalType = {
       mentalType = 0,
    },
    ReqRestMentalType = {
    },
}
local L_StrDic = {
    [MSG_Skill.ReqUpCell] = "MSG_Skill.ReqUpCell",
    [MSG_Skill.ReqUpSkillStar] = "MSG_Skill.ReqUpSkillStar",
    [MSG_Skill.ReqActivateMeridian] = "MSG_Skill.ReqActivateMeridian",
    [MSG_Skill.ReqSaveFightSkill] = "MSG_Skill.ReqSaveFightSkill",
    [MSG_Skill.ReqResetMeridianSkill] = "MSG_Skill.ReqResetMeridianSkill",
    [MSG_Skill.ReqSelectMentalType] = "MSG_Skill.ReqSelectMentalType",
    [MSG_Skill.ReqRestMentalType] = "MSG_Skill.ReqRestMentalType",
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

return MSG_Skill

