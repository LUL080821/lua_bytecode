------------------------------------------------
-- Author: 
-- Date: 2021-03-30
-- File: AnimManager.lua
-- Module: AnimManager
-- Description: Action Manager
------------------------------------------------

local AnimManager = {

}

function AnimManager:GetTranslateAnimName(animObj, animName, modeType, selfBoneIndex, parentBoneIndex, inwWrapMode)
    local _result = animName
    local _wrapMode = inwWrapMode
    if modeType == ModelTypeCode.Player then
        local _mount = animObj.Parent
        if _mount ~= nil and _mount:CheckLoadFinishedAndValid() then -- This will be processed only after the model is loaded
            local _curAnims = _mount:GetCurrentPlayAnimNames()
            local _curAnim = nil
            if _curAnims.Count > 0 then
                _curAnim = _curAnims[0]
            end
            if _curAnim == nil or string.len(_curAnim) <= 0 then
                _curAnim = animName
            end
            -- Determine the currently selected action name based on the parent object's bone information
            if _curAnim == AnimClipNameDefine.NormalIdle or _curAnim == AnimClipNameDefine.FlyIdle then
                if parentBoneIndex == 0 then
                    _result = AnimClipNameDefine.RideIdle1
                elseif parentBoneIndex == 1 then
                    _result = AnimClipNameDefine.RideIdle2
                elseif parentBoneIndex == 2 then
                    _result = AnimClipNameDefine.RideIdle3
                elseif parentBoneIndex == 3 then
                    _result = AnimClipNameDefine.RideIdle4
                elseif parentBoneIndex == 4 then
                    _result = AnimClipNameDefine.RideIdle5
                elseif parentBoneIndex == 5 then
                    _result = AnimClipNameDefine.RideIdle6
                elseif parentBoneIndex == 6 then
                    _result = AnimClipNameDefine.RideIdle7
                elseif parentBoneIndex == 7 then
                    _result = AnimClipNameDefine.RideIdle8
                elseif parentBoneIndex == 8 then
                    _result = AnimClipNameDefine.RideIdle9
                elseif parentBoneIndex == 9 then
                    _result = AnimClipNameDefine.RideIdle10
                end
            elseif _curAnim == AnimClipNameDefine.NormalRun or _curAnim == AnimClipNameDefine.FlyRun then
                if parentBoneIndex == 0 then
                    _result = AnimClipNameDefine.RideRun1
                elseif parentBoneIndex == 1 then
                    _result = AnimClipNameDefine.RideRun2
                elseif parentBoneIndex == 2 then
                    _result = AnimClipNameDefine.RideRun3
                elseif parentBoneIndex == 3 then
                    _result = AnimClipNameDefine.RideRun4
                elseif parentBoneIndex == 4 then
                    _result = AnimClipNameDefine.RideRun5
                elseif parentBoneIndex == 5 then
                    _result = AnimClipNameDefine.RideRun6
                elseif parentBoneIndex == 6 then
                    _result = AnimClipNameDefine.RideRun7
                elseif parentBoneIndex == 7 then
                    _result = AnimClipNameDefine.RideRun8
                elseif parentBoneIndex == 8 then
                    _result = AnimClipNameDefine.RideRun9
                elseif parentBoneIndex == 9 then
                    _result = AnimClipNameDefine.RideRun10
                end
            end
        end
    elseif modeType == ModelTypeCode.Mount then
        if animName == AnimClipNameDefine.FightIdle then
            _result = AnimClipNameDefine.NormalIdle
        elseif animName == AnimClipNameDefine.FightRunFront then
            _result = AnimClipNameDefine.NormalRun
        end
    elseif modeType == ModelTypeCode.Wing then
        if animName == AnimClipNameDefine.NormalRun or
            animName == AnimClipNameDefine.FastRun or
            animName == AnimClipNameDefine.FightRunFront or
            animName == AnimClipNameDefine.FightRunBack or
            animName == AnimClipNameDefine.FightRunLeft or
            animName == AnimClipNameDefine.FightRunRight or
            animName == AnimClipNameDefine.SwimRun then
            _result = AnimClipNameDefine.NormalRun
        else
            _result = AnimClipNameDefine.NormalIdle
        end
    end
    -- Soul Armor
    -- mode = WrapMode.Loop;
    -- switch (animName)
    -- {
    --     case AnimClipNameDefine.NormalRun:
    --     case AnimClipNameDefine.FastRun:
    --     case AnimClipNameDefine.FightRunFront:
    --     case AnimClipNameDefine.FightRunBack:
    --     case AnimClipNameDefine.FightRunLeft:
    --     case AnimClipNameDefine.FightRunRight:
    --         return AnimClipNameDefine.NormalRun;
    -- }
    return _result, _wrapMode
end

return AnimManager