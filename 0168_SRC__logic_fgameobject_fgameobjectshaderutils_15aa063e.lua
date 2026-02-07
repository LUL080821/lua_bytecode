------------------------------------------------
-- Author: 
-- Date: 2021-05-21
-- File: FGameObjectShaderUtils.lua
-- Module: FGameObjectShaderUtils
-- Description: The logical code that needs to be replaced in the model
------------------------------------------------
-- Quote

local ShaderManager = CS.Thousandto.Core.Asset.ShaderManager

-- In the definition field in the class, the value cannot be assigned to nil, and it needs to be assigned to a value. The default can be 0
local FGameObjectShaderUtils = {}

-- Switch the Shader code, the return value is Shader type.
--sh:Shader
--modelType:ModelTypeCode
--imodelid:integer
function FGameObjectShaderUtils.ShaderSwitch(sh,modeltype,imodelid)
    Debug.Log("FGameObjectShaderUtils.ShaderSwitch:" .. tostring(modeltype) .. ":::" .. tostring(imodelid) );
    if modeltype == UnityUtils.GetObjct2Int(ModelTypeCode.Wing) then
        return FGameObjectShaderUtils.ProcessWing(sh,imodelid);
    elseif modeltype == UnityUtils.GetObjct2Int(ModelTypeCode.Object) then
        return FGameObjectShaderUtils.ProcessObject(sh,imodelid);
    elseif modeltype == UnityUtils.GetObjct2Int(ModelTypeCode.Player) then  
        return FGameObjectShaderUtils.ProcessPlayer(sh,imodelid);
    end
    return sh;
end

function FGameObjectShaderUtils.ProcessWing(sh,imodelid)
   local _sn = sh.name; 
   
   if imodelid % 100 < 50 then
       _sn = _sn + "_AlphaTest"
   end
   local _rgbSh = FGameObjectShaderUtils.ShaderUseRGB(_sn,imodelid);
   if _rgbSh then
      return _rgbSh;
   elseif sh.name ~= _sn then 
        -- If the two names are different, then use the new Shader
        local _si = ShaderManager.SharedInstance:GetShaderDefine(_sn);
        if _si then
            return _si.RealShader;
        end
   end
   return sh;
end

function FGameObjectShaderUtils.ProcessObject(sh,imodelid)
    if ShaderManager.IsEntityUseRGB and sh.name == "Ares/EntityState/Grown" then
        local _newSh = FGameObjectShaderUtils.ShaderUseRGB("Ares/EntityState/Grown");
        if _newSh then
            return _newSh;
        end
    end
    return sh;
end

function FGameObjectShaderUtils.ProcessPlayer(sh,imodelid)
    local _sn = sh.name; 
    if imodelid % 100 > 70 then
        _sn = _sn + "_AlphaBlend"
    end
    local _rgbSh = FGameObjectShaderUtils.ShaderUseRGB(_sn,imodelid);
    if _rgbSh then
       return _rgbSh;
    elseif sh.name ~= _sn then 
         -- If the two names are different, then use the new Shader
         local _si = ShaderManager.SharedInstance:GetShaderDefine(_sn);
         if _si then
             return _si.RealShader;
         end
    end
    return sh;
end

function FGameObjectShaderUtils.ShaderUseRGB(strShName,imodelid)
    if ShaderManager.IsEntityUseRGB then
        local _rgb = strShName + "_RGB";
        local _rgbSi = ShaderManager.SharedInstance.GetShaderDefine(_rgb);
        if _rgbSi then
            return _rgbSi.RealShader;
        end
    end
    return nil;
end

return FGameObjectShaderUtils