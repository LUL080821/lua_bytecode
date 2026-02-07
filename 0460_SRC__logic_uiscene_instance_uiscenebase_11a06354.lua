------------------------------------------------
-- author:
-- Date: 2021-06-11
-- File: UISceneBase.lua
-- Module: UISceneBase
-- Description: UISceneBase
------------------------------------------------
-- Quote
local UISceneBase = {
    Manager = nil,
    ModelId = -1,
    SceneIndex = 0,
    IsTop = false,
    IsLoadFinish = false,
    SceneType = UISceneDefine.Default,
    SceneCamera = nil,
    SceneObj = nil,
}

function UISceneBase:New(type, modelId, manager)
    local _m = Utils.DeepCopy(self)
    _m.ModelId = modelId
    _m.SceneType = type
    _m.Manager = manager
    return Utils.DeepCopy(_m);
end

function UISceneBase:LoadedCallBack(obj)
    if obj ~= nil then
        self.SceneObj = obj
        if  self.SceneObj ~= nil then
             self.SceneObj:SetLayer(LayerUtils.UIStory)
            if self.SceneObj.RealTransform ~= nil then
                 self.SceneObj.RealTransform.parent = self.Manager.SceneRoot;
                 self.SceneObj.RealTransform.localPosition = Vector3.zero;
                self.SceneCamera = self:GetCamera()
                if self.SceneCamera == nil then
                    self.SceneCamera =  UIUtils.FindCamera(self.SceneObj.RealTransform, "Camera")
                    if self.SceneCamera ~= nil then
                        self.SceneCamera.gameObject:SetActive(true)
                    end
                end
            end
        end
    end
    if self.OnLoadedCallBack ~= nil then
        self:OnLoadedCallBack(obj)
    end
end

function UISceneBase:GetCamera()
    local ret = nil
    if self.OnGetCamera ~= nil then
        ret = self:OnGetCamera()
    end
    return ret
end

function UISceneBase:Destory()
    if self.SceneCamera ~= nil then
        self.SceneCamera.gameObject:SetActive(false)
    end
    if self.SceneObj ~= nil then
         self.SceneObj:Destroy()
         self.SceneObj = nil
    end
    self.IsLoadFinish = false
    if self.OnDestory ~= nil then
        self:OnDestory()
    end
end

function UISceneBase:Update(dt)
    if self.OnUpdate ~= nil then
        self:OnUpdate(dt)
    end
end

return UISceneBase
