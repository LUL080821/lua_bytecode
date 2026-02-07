------------------------------------------------
-- author:
-- Date: 2021-06-11
-- File: UISceneManager.lua
-- Module: UISceneManager
-- Description: ui scene management
------------------------------------------------
-- Quote
local L_FashionScene = require "Logic.UIScene.Instance.FashionScene"
local L_SwordGraveScene = require "Logic.UIScene.Instance.SwordGraveScene"

local UISceneManager = {
    IsInit = false,
    SceneRoot = nil,
    -- ui scene management list
    SceneList = List:New(),
}

function UISceneManager:GetInstance()
    if not self.IsInit then
        local _root = GameCenter.UIFormManager:GetShadowRoot()
        if _root ~= nil then
            self.SceneRoot = UIUtils.FindTrans(_root, "Scene")
        end
        self.IsInit = true
    end
    return self
end

function UISceneManager:CreateUIScene(type, modelId, userData)
    local scene = nil
    if type == UISceneDefine.FasionScene then
        scene = L_FashionScene:New(UISceneDefine.FasionScene, modelId, self)
    elseif type == UISceneDefine.SwordGraveScene then
        scene = L_SwordGraveScene:New(UISceneDefine.SwordGraveScene, modelId, self)
    elseif type == UISceneDefine.SwordActive then
    end
    if scene ~= nil then
        self:AddScene(scene)
    end
    return scene
end
        
-- Added settings after adding scene top = true Other old scene top = false
function UISceneManager:AddScene(scene)
    scene.IsTop = true;
    scene.SceneIndex = #self.SceneList
    for i = 1, #self.SceneList do
        self.SceneList[i].IsTop = false
    end
    self.SceneList:Add(scene)
end

-- Remove scene
function UISceneManager:RemoveScene(type)
    local index = -1
    local isSetOtherTop = false
    for i = #self.SceneList, 1, -1 do
        local scene = self.SceneList[i]
        if scene.SceneType == type then
            isSetOtherTop = scene.IsTop
            if isSetOtherTop then
                index = scene.SceneIndex
                scene:Destory()
            end
            self.SceneList:RemoveAt(i)
        end
        if isSetOtherTop and scene.SceneIndex < index then
            scene.IsTop = true;
            break
        end
    end
end

-- Remove scene
function UISceneManager:RemoveScene(scene)
    if scene == nil then
        return
    end
    local isSetOtherTop = scene.IsTop
    for i = #self.SceneList, 1, -1 do
        if isSetOtherTop and self.SceneList[i].SceneIndex < scene.SceneIndex then
            scene.IsTop = true
            break
        end
    end
    scene:Destory()
    self.SceneList:Remove(scene)
end

function UISceneManager:Update(dt)
    for i = 1, #self.SceneList do
        if self.SceneList[i] ~= nil and self.SceneList[i].IsTop then
            self.SceneList[i]:Update(dt)
        end
    end
end

return UISceneManager
