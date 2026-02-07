
------------------------------------------------
-- Author: 
-- Date: 2020-02-20
-- File: FSkinModelWrap.lua
-- Module: FSkinModelWrap
-- Description: Sample Class
-- Note: In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value.
------------------------------------------------
-- Quote
local LuaFSkinModel = CS.Thousandto.Plugins.LuaType.LuaFSkinModel;
local FSkinPartCode = require("Logic.FGameObject.FSkinPartCode")
local FSkinPartWrap = require("Logic.FGameObject.FSkinPartWrap")

-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local FSkinModelWrap = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- If you define a member, you must
}

-- #region --Fixed template for class inheritance

-- Constructor
function FSkinModelWrap:New(...)
    local _m = Utils.DeepCopy(self)
    _m._SuperObj_ = LuaFSkinModel.Create(...);
    _m:_InitBindOverride_();
    _m:_InitContent_();
    Utils.BuildInheritRel(_m);
    return _m
end

function FSkinModelWrap:GetCSObj()
    return self._SuperObj_;
end

-- Methods to bind Override
function FSkinModelWrap:_InitBindOverride_()
    -- Redefinition of overloaded functions
    self._SuperObj_.OnSetPartHierarchyDelegate = Utils.Handler(self.OnSetPartHierarchy, self, nil, true); 
    self._SuperObj_.OnCreatePartInfoDelegate = Utils.Handler(self.OnCreatePartInfo, self, nil, true);    
    self._SuperObj_.OnDestoryAfterDelegate = Utils.Handler(self.OnDestoryAfter, self, nil, true);  
    --...  
end

-- initialization
function FSkinModelWrap:_InitContent_()         
    --todo
end

-- uninstall
function FSkinModelWrap:Free()
    self._SuperObj_.OnSetPartHierarchyDelegate = nil;
    self._SuperObj_.OnCreatePartInfoDelegate = nil;
    self._SuperObj_.OnDestoryAfterDelegate = nil;
    LuaFSkinModel.Destroy(self._SuperObj_);    
    Utils.Destory(self);
end

--#endregion

-- #region-- Overrider inherits parent class function
-- <summary>
-- C# object deletion
-- </summary>
-- <param name="skin">FSkinBase</param>
-- <param name="part">FSkinPartBase</param>
function FSkinModelWrap:OnDestoryAfter()
    self._SuperObj_.OnSetPartHierarchyDelegate = nil;
    self._SuperObj_.OnCreatePartInfoDelegate = nil;
    self._SuperObj_.OnDestoryAfterDelegate = nil;
    Utils.Destory(self);
end

-- <summary>
-- --Set the level of the location
-- </summary>
-- <param name="skin">FSkinBase</param>
-- <param name="part">FSkinPartBase</param>
function FSkinModelWrap:OnSetPartHierarchy(skin, part)
    if part.Code == FSkinPartCode.Body  then
         -- If the main body has a mount, then hang it on top of the mount. If there is no mount, then put it at the root node.
         if (not self:CreateRelation(skin, FSkinPartCode.Mount, FSkinPartCode.Body)) then     
             -- If there is no mount, select the special effect to hang it on the main body
             self:CreateRelation(skin, part.Code, FSkinPartCode.SelectedVfx);
             -- Special effects of seal display
             self:CreateRelation(skin, part.Code, FSkinPartCode.SealVfx);
         end
         -- arms
         self:CreateRelation(skin, part.Code, FSkinPartCode.GodWeaponBody);
         self:CreateRelation(skin, part.Code, FSkinPartCode.GodWeaponHead);
         -- wing
         self:CreateRelation(skin, part.Code, FSkinPartCode.Wing);
         -- Strengthen special effects
         self:CreateRelation(skin, part.Code, FSkinPartCode.StrengthenVfx);
         -- Overhead tips
         self:CreateRelation(skin, part.Code, FSkinPartCode.HeadPromptVfx);
         -- Special effects for job transfer
         self:CreateRelation(skin, part.Code, FSkinPartCode.TransVfx);
         -- Immortal Armor Array
         self:CreateRelation(skin, part.Code, FSkinPartCode.XianjiaZhen);
         -- Immortal Armor Halo
         self:CreateRelation(skin, part.Code, FSkinPartCode.XianjiaHuan);
    elseif part.Code == FSkinPartCode.Mount 
        then   
          -- Set the parent node of the mount and hang the object of the body on the mount
          skin.AddChild(part.FGameObject, part.ModelInfo.SlotName);
          self:CreateRelation(skin, part.Code, FSkinPartCode.Body);
          self:CreateRelation(skin, part.Code, FSkinPartCode.SelectedVfx);
          -- Special effects of seal display
          self:CreateRelation(skin, part.Code, FSkinPartCode.SealVfx);
    elseif part.Code == FSkinPartCode.GodWeaponHead 
        or part.Code == FSkinPartCode.GodWeaponBody 
        or part.Code == FSkinPartCode.Wing 
        then   
        -- Equip the weapon, if there is a body, hang it on the body, if there is no, hang it on the root node
        self:CreateRelation(skin, FSkinPartCode.Body, part.Code);

    elseif part.Code == FSkinPartCode.StrengthenVfx 
        or part.Code == FSkinPartCode.HeadPromptVfx 
        or part.Code == FSkinPartCode.TransVfx 
        or part.Code == FSkinPartCode.XianjiaZhen 
        or part.Code == FSkinPartCode.XianjiaHuan         
        then           
        -- Overhead effect, enhance the effect. If there is a body, hang it on the body. If there is no, hang it on the root node.
        self:CreateRelation(skin, FSkinPartCode.Body, part.Code);
    elseif part.Code == FSkinPartCode.SelectedVfx 
        or part.Code == FSkinPartCode.SealVfx
        then           
        -- If the main body has a mount, then hang it on top of the mount. If there is no mount, then put it at the root node.
        if ( not self:CreateRelation(skin, FSkinPartCode.Mount, part.Code, false)) then
            self:CreateRelation(skin, FSkinPartCode.Body, part.Code);
        end
    elseif part.Code == FSkinPartCode.GodWeaponVfx  
        then           
        -- If the main body has a mount, then hang it on top of the mount. If there is no mount, then put it at the root node.
        self:CreateRelation(skin, FSkinPartCode.GodWeaponHead, part.Code);
    end    
end

-- <summary>
-- Create PartInfo
-- </summary>
-- <param name="code">int</param>
-- <param name="callBack">MyAction<FSkinPartBase></param>
-- <returns></returns>
function FSkinModelWrap:OnCreatePartInfo(code, callBack)
    return FSkinPartWrap:New(self:GetCSObj(),code,callBack,false):GetCSObj();
end

--#endregion

return FSkinModelWrap