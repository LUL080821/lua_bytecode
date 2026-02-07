local MSG_Fight = {
    SkillBaseInfo = {
       userID = 0,
       skillID = 0,
       serial = 0,
       dirX = 0,
       dirY = 0,
    },
    ReqUseSkill = {
       info = {
            userID = 0,
            skillID = 0,
            serial = 0,
            dirX = 0,
            dirY = 0,
        },

       curTargetId = 0,
       usePosX = 0,
       usePosY = 0,
    },
    ReqPlayLockTrajectory = {
       info = {
            userID = 0,
            skillID = 0,
            serial = 0,
            dirX = 0,
            dirY = 0,
        },

       eventID = 0,
       targetList = List:New(),
    },
    ReqPlaySkillObject = {
       info = {
            userID = 0,
            skillID = 0,
            serial = 0,
            dirX = 0,
            dirY = 0,
        },

       eventID = 0,
       posX = 0,
       posY = 0,
    },
    ReqPlayHit = {
       info = {
            userID = 0,
            skillID = 0,
            serial = 0,
            dirX = 0,
            dirY = 0,
        },

       eventID = 0,
       targetList = List:New(),
    },
    ReqPlaySelfMove = {
       info = {
            userID = 0,
            skillID = 0,
            serial = 0,
            dirX = 0,
            dirY = 0,
        },

       eventID = 0,
       curPosX = 0,
       curPosY = 0,
       tarPosX = 0,
       tarPosY = 0,
    },
    HitEffectInfo = {
       targetID = 0,
       posx = 0,
       posy = 0,
       effect = 0,
       damageHp = 0,
       isDead = false,
       damageWaken = nil,
    },
    ReqRollMove = {
       moveToX = 0,
       moveToY = 0,
       selfX = nil,
       selfY = nil,
    },
    ReqChangeAttackDir = {
       dirX = 0,
       dirY = 0,
    },
    GuideSkillTarget = {
       targetID = 0,
       posx = 0,
       posy = 0,
    },
    ReqFlyPetCloneAttack = {
       skillId = 0,
       targets = List:New(),
    },
    flyPetCloneAttackInfo = {
       targetID = 0,
       posx = 0,
       posy = 0,
       damageHp = 0,
       isDead = false,
    },
}
local L_StrDic = {
    [MSG_Fight.ReqUseSkill] = "MSG_Fight.ReqUseSkill",
    [MSG_Fight.ReqPlayLockTrajectory] = "MSG_Fight.ReqPlayLockTrajectory",
    [MSG_Fight.ReqPlaySkillObject] = "MSG_Fight.ReqPlaySkillObject",
    [MSG_Fight.ReqPlayHit] = "MSG_Fight.ReqPlayHit",
    [MSG_Fight.ReqPlaySelfMove] = "MSG_Fight.ReqPlaySelfMove",
    [MSG_Fight.ReqRollMove] = "MSG_Fight.ReqRollMove",
    [MSG_Fight.ReqChangeAttackDir] = "MSG_Fight.ReqChangeAttackDir",
    [MSG_Fight.ReqFlyPetCloneAttack] = "MSG_Fight.ReqFlyPetCloneAttack",
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

return MSG_Fight

