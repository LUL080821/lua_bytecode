
------------------------------------------------
-- Author: 
-- Date: 2021/03/26
-- File: UIShowSelectPlayerScript.lua
-- Module: UIShowSelectPlayerScript
-- Description: A script that displays a role selection
------------------------------------------------

local UIShowSelectPlayerScript = {
    Trans = nil,
    Go = nil,
}

function UIShowSelectPlayerScript:New(trans)
    if trans == nil then
        return
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject  
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
end

function UIShowSelectPlayerScript:OnTimelineProcessFrame(intParam,stringParam,current,duration)
    Debug.LogError("UIShowSelectPlayerScript:OnTimelineProcessFrame::" .. tostring(intParam) .. tostring(stringParam) .. tostring(current) .. tostring(duration));
end

function UIShowSelectPlayerScript:Free()
    LuaBehaviourManager:Remove(self);
end

return UIShowSelectPlayerScript
