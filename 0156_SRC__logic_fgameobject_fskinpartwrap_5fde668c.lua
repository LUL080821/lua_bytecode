
------------------------------------------------
-- Author: 
-- Date: 2020-02-20
-- File: FSkinPartWrap.lua
-- Module: FSkinPartWrap
-- Description: Sample Class
-- Note: In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value.
------------------------------------------------
-- Quote
local LuaFSkinPartBase = CS.Thousandto.Plugins.LuaType.LuaFSkinPartBase;
local FGameObjectSoulEquip = require("Logic.FGameObject.FGameObjectSoulEquip")

-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local FSkinPartWrap = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- If you define a member, you must
    _OnCreateFGameObjectHandler = nil;
}

-- #region //Fixed template for class inheritance

-- Constructor
function FSkinPartWrap:New(parent, code, onLoadFinishedCallBack, isHideModel)
    local _m = Utils.DeepCopy(self)
    _m._OnCreateFGameObjectHandler = Utils.Handler(self.OnCreateFGameObject, self, nil, true);
    _m._SuperObj_ = LuaFSkinPartBase.Create(parent, code, onLoadFinishedCallBack, isHideModel, _m._OnCreateFGameObjectHandler);
    _m:_InitBindOverride_();
    _m:_InitContent_();
    Utils.BuildInheritRel(_m);
    return _m
end

function FSkinPartWrap:GetCSObj()
    return self._SuperObj_;
end

-- Methods to bind Override
function FSkinPartWrap:_InitBindOverride_()
    -- Redefinition of overloaded functions
    self._SuperObj_.OnSwitchFGameObjectDelegate = Utils.Handler(self.OnSwitchFGameObject, self, nil, true);  
    --...  
end

-- initialization
function FSkinPartWrap:_InitContent_()         
    --todo
   
end

-- uninstall
function FSkinPartWrap:Free()    
    self._SuperObj_.OnSwitchFGameObjectDelegate = nil;
    LuaFSkinPartBase.Destroy(self._SuperObj_);
    _m._OnCreateFGameObjectHandler = nil;
    Utils.Destory(self);
end

--#endregion

-- #region //Overload the functions of the parent class

-- <summary>
-- Create a GameObject object
-- </summary>
-- <returns>FGameObjectModel</returns>
function FSkinPartWrap:OnCreateFGameObject(code)
    if code == FSkinPartCode.Reserved_1  then
        return FGameObjectSoulEquip:New():GetCSObj();
    end
    return nil;  
end


-- <summary>
-- Object switching processing
-- </summary>
-- <param name="fgameObject">FGameObjectModel</param>
-- <param name="modelType">ModelTypeCode</param>
-- <param name="modelID">int</param>
-- <param name="isShow">bool</param>
-- <returns>FGameObjectModel</returns>
function FSkinPartWrap:OnSwitchFGameObject( fgameObject,  modelType,  modelID, isShow)
    if (fgameObject ~= nil) and self.Code == FSkinPartCode.Wing then 
        return fgameObject:SwitchModel(modelType, modelID, isShow);       
    elseif (fgameObject ~= nil) and self.Code == FSkinPartCode.Reserved_1 then
        return fgameObject:SwitchModel(modelType, modelID, isShow)
    end   
end

--#endregion

return FSkinPartWrap