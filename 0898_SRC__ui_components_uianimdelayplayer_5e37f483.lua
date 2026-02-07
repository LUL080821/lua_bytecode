------------------------------------------------
-- Author: 
-- Date: 2021-04-14
-- File: UIAnimDelayPlayer.lua
-- Module: UIAnimDelayPlayer
-- Description: Animation Delay Player
------------------------------------------------

local UIAnimDelayPlayer = {
    AnimList = List:New(),
    Playing = false,
    AnimMoudle = nil,
}

function UIAnimDelayPlayer:New(animMoudle)
    local _m = Utils.DeepCopy(self)
    _m.Playing = false
    _m.AnimMoudle = animMoudle
    return _m
end

function UIAnimDelayPlayer:AddTrans(trans, delayTime)
    self.AnimList:Add({trans, delayTime})
end

function UIAnimDelayPlayer:Play()
    if #self.AnimList <= 0 then
        return
    end
    -- Is the animation turned on?
    if GameCenter.GameSetting:IsEnabled(GameSettingKeyCode.EnableUIAnimation) then
        self.Playing = true
        for i = 1, #self.AnimList do
            self.AnimList[i][1].gameObject:SetActive(false)
        end
    else
        self.Playing = false
        local _count = #self.AnimList
        for i = _count, 1, -1 do
            local _anim = self.AnimList[i]
            self.AnimMoudle:PlayShowAnimation(_anim[1])
        end
        self.AnimList:Clear()
    end
end

function UIAnimDelayPlayer:Stop()
    self.AnimList:Clear()
    self.Playing = false
end

function UIAnimDelayPlayer:Update(dt)
    if not self.Playing then
        return
    end
    local _count = #self.AnimList
    for i = _count, 1, -1 do
        local _anim = self.AnimList[i]
        _anim[2] = _anim[2] - dt
        if _anim[2] <= 0 then
            self.AnimMoudle:PlayShowAnimation(_anim[1])
            self.AnimList:RemoveAt(i)
            _count = _count - 1
        end
    end
    if _count <= 0 then
        self.Playing = false
    end
end

return UIAnimDelayPlayer