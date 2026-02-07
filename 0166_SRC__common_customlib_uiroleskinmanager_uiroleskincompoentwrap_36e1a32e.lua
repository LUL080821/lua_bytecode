------------------------------------------------
-- Author: 
-- Date: 2021-03-06
-- File: UIRoleSkin.lua
-- Module: UIRoleSkin
-- Description: Skin information for form roles
------------------------------------------------

------------------------------------------------
-- Author: 
-- Date: 2020-02-20
-- File: UIRoleSkinCompoentWrap.lua
-- Module: UIRoleSkinCompoentWrap
-- Description: Sample Class
-- Note: In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value.
------------------------------------------------
-- Quote
local L_ParentCSType = CS.Thousandto.GameUI.Form.UIRoleSkinCompoent


-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local UIRoleSkinCompoentWrap = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- If you define a member, you must
}

-- #region //Fixed template for class inheritance

-- Constructor
function UIRoleSkinCompoentWrap:New(UICompoent)
    local _m = Utils.DeepCopy(self)   
    _m._SuperObj_ = UICompoent; 
    _m:_InitBindOverride_();
    _m:_InitContent_();    
    Utils.BuildInheritRel(_m);
    return _m
end

-- Methods to bind Override
function UIRoleSkinCompoentWrap:_InitBindOverride_()
    -- Redefinition of overloaded functions
    self._SuperObj_.OnDestroyDelegate = Utils.Handler(self.Free,self,nil,true)
end

-- initialization
function UIRoleSkinCompoentWrap:_InitContent_()         
    --todo
end

function UIRoleSkinCompoentWrap:GetCSObj()    
    return self._SuperObj_;
end

-- uninstall
function UIRoleSkinCompoentWrap:Free()
    self._SuperObj_.OnDestroyDelegate = nil;
    UIRoleSkinManager:Remove(self._SuperObj_);
    Utils.Destory(self);
end

--#endregion

-- Overload method 1
function UIRoleSkinCompoentWrap:RefreshPlayerSkinModel(occInt, visibleInfo, animList)      
    self._SuperObj_:SetEquip(FSkinPartCode.Body, visibleInfo:GetBodyModelID(occInt), animList);
    self._SuperObj_:SetEquip(FSkinPartCode.GodWeaponHead, visibleInfo:GetFashionWeaponModelID(occInt));
    self._SuperObj_:SetEquip(FSkinPartCode.XianjiaHuan, visibleInfo:GetFashionHaloModelID());
    self._SuperObj_:SetEquip(FSkinPartCode.Wing, visibleInfo:GetFashionWingModelID(occInt));
end

return UIRoleSkinCompoentWrap