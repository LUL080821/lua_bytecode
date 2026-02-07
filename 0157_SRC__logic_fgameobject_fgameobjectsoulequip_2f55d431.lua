------------------------------------------------
-- Author: 
-- Date: 2021-03-08
-- File: FGameObjectSoulEquip.lua
-- Module: FGameObjectSoulEquip
-- Description: Soul Armor Model
-- Note: In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value.
------------------------------------------------
-- Quote
local LuaFGameObjectAnim = CS.Thousandto.Plugins.LuaType.LuaFGameObjectAnim;
local ShaderManager = CS.Thousandto.Core.Asset.ShaderManager
local WrapMode = CS.UnityEngine.WrapMode
local SlotNameDefine = CS.Thousandto.Core.Asset.SlotNameDefine


-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local FGameObjectSoulEquip = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- If you define a member, you must
}

-- #region --Fixed template for class inheritance

-- Constructor
function FGameObjectSoulEquip:New(...)
    local _m = Utils.DeepCopy(self)
    _m._SuperObj_ = LuaFGameObjectAnim.Create(...);
    _m:_InitBindOverride_();
    _m:_InitContent_();
    Utils.BuildInheritRel(_m);
    return _m
end


-- Methods to bind Override
function FGameObjectSoulEquip:_InitBindOverride_()
    -- Redefinition of overloaded functions
    self._SuperObj_.OnSwitchShaderDelegate = Utils.Handler(self.OnSwitchShader, self, nil, true); 
    self._SuperObj_.OnGetBoneIndexDelegate = Utils.Handler(self.OnGetBoneIndex, self, nil, true);   
    self._SuperObj_.OnTranslateAnimNameDelegate = Utils.Handler(self.OnTranslateAnimName, self, nil, true);   
    self._SuperObj_.OnCheckAnimEnablePlayDelegate = Utils.Handler(self.OnCheckAnimEnablePlay, self, nil, true);   
    self._SuperObj_.OnMountToParentDelegate = Utils.Handler(self.OnMountToParent, self, nil, true);   
    self._SuperObj_.OnUnMountFromParentDelegate = Utils.Handler(self.OnUnMountFromParent, self, nil, true);   
    self._SuperObj_.OnDestoryAfterDelegate = Utils.Handler(self.OnDestoryAfter, self, nil, true);  
    --...  
end

-- initialization
function FGameObjectSoulEquip:_InitContent_()         
    --todo
end

-- uninstall
function FGameObjectSoulEquip:Free()
    LuaFGameObjectAnim.Destroy(self._SuperObj_);
    Utils.Destory(self);
end

function FGameObjectSoulEquip:GetCSObj()    
    return self._SuperObj_;
end
--#endregion

-- #region-- Overrider inherits parent class function

-- <summary>
-- C# object deletion
-- </summary>
-- <param name="skin">FSkinBase</param>
-- <param name="part">FSkinPartBase</param>
function FGameObjectSoulEquip:OnDestoryAfter()
    Utils.Destory(self);
end
                           
--/ <summary>
-- / Get bone index
--/ </summary>
--/ <param name="modelType">ModelTypeCode</param>
--/ <param name="modelID">int</param>
--/ <returns></returns>
function FGameObjectSoulEquip:OnGetBoneIndex( modelType, modelID)

    if (modelType == UnityUtils.GetObjct2Int(ModelTypeCode.Mount))then    
        return modelID / 100;
    end
    return modelID;
end


--/ <summary>
-- / Action conversion
--/ </summary>
--/ <param name="animName">string</param>
--/ <param name="mode">WrapMode</param>
--/ <returns>string</returns>
function FGameObjectSoulEquip:OnTranslateAnimName(animName,mode)    
    if animName == AnimClipNameDefine.NormalRun 
        or animName == AnimClipNameDefine.FastRun 
        or animName == AnimClipNameDefine.FightRunFront 
        or animName == AnimClipNameDefine.FightRunBack 
        or animName == AnimClipNameDefine.FightRunLeft 
        or animName == AnimClipNameDefine.FightRunRight         
    then
        return AnimClipNameDefine.NormalRun,WrapMode.Loop;
    end
    return AnimClipNameDefine.NormalIdle,WrapMode.Loop;
end

--/ <summary>
-- / Determine whether the action is playing
--/ </summary>
--/ <param name="animName">string</param>
--/ <returns>bool</returns>
function FGameObjectSoulEquip:OnCheckAnimEnablePlay(animName)

    local _lpi = self.LastPlayInfo;
    if (_lpi ~= nil and _lpi.WrapMode == WrapMode.Loop)then
    
        return _lpi.Name ~= animName;
    end
    return true;
end

--/ <summary>
-- / Hang in to parent class
--/ </summary>
--/ <param name="parent">FGameObject</param>
--/ <returns>bool</returns>
function FGameObjectSoulEquip:OnMountToParent(parent)

    if (parent ~= nil and parent.RealTransform ~= nil and self.RealTransform ~= nil) then
        -- First set the object to the root directory
        self:SetParent(parent.RootTransform, false);
        local wing = self.RealTransform;
        if (wing ~= nil) then
            -- Special treatment for wings here
            local slot_Wing = parent:FindTransform(SlotNameDefine.Wing, true);
            wing.parent = slot_Wing;
            UnityUtils.ResetTransform(wing);
            wing.localPosition = Vector3(0, -0.1, 0);
            self.RealGameObject:SetActive(false);
            self.RealGameObject:SetActive(true);        
            
            if (parent.LastPlayInfo ~= nil ) then
                parent.LastPlayInfo.WrapMode = WrapMode.Loop;
                self:PlayAnim(parent.LastPlayInfo, false);
            end
        end
        return true;
    end
    return false;
end

function FGameObjectSoulEquip:OnUnMountFromParent(parent)
    self:RealComeBackToRoot();
    return true;
end
--#endregion

return FGameObjectSoulEquip