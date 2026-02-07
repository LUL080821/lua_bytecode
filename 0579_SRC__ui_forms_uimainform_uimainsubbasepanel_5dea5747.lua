------------------------------------------------
-- author:
-- Date: 2021-02-25
-- File: UIMainSubBasePanel.lua
-- Module: UIMainSubBasePanel
-- Description: Main interface pagination base class
------------------------------------------------
local UIMainSubBasePanel = {
    -- Current transform
    Trans = nil,
    -- Current gameobject
    Go = nil,
    -- father
    Parent = nil,
    -- Root interface
    RootForm = nil,
    
    -- Animation module
    AnimModule = nil,
    IsVisible = false,

    -- Event list
    EventHanders = List:New(),
}
function UIMainSubBasePanel.New()
    return Utils.DeepCopy(UIMainSubBasePanel)
end

function UIMainSubBasePanel:BaseFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    self.Go:SetActive(false)
    self.IsVisible = false
    -- Create an animation module
    self.AnimModule = UIAnimationModule(trans)
    rootForm.CSForm.AnimModule:AddChild(self.AnimModule)
end

function UIMainSubBasePanel:Open()
    if self.OnShowBefore ~= nil then
        self:OnShowBefore()
    end
    self.Go:SetActive(true)
    self.IsVisible = true
    self:RegisterEvents()
    self.AnimModule:PlayEnableAnimation(Utils.Handler(self.DoShowAnimFinish, self))
    if self.OnShowAfter ~= nil then
        self:OnShowAfter()
    end
end

function UIMainSubBasePanel:Close()
    if not self.IsVisible then
        return
    end
    if self.OnHideBefore ~= nil then
        self:OnHideBefore()
    end
    self.IsVisible = false
    self:UnRegisterEvents()
    self.AnimModule:PlayDisableAnimation(Utils.Handler(self.DoHideAnimFinish, self))
end

function UIMainSubBasePanel:DoShowAnimFinish()
    if self.OnShowAnimFinish ~= nil then
        self:OnShowAnimFinish()
    end
end

function UIMainSubBasePanel:DoHideAnimFinish()
    self.Go:SetActive(false)
    if self.OnHideAfter ~= nil then
        self:OnHideAfter()
    end
end

-- Register Events
function UIMainSubBasePanel:RegisterEvent(id, func, caller)
    if id == nil or func == nil then
        return
    end
    if caller == nil then
        caller = self
    end
    for i = 1, #self.EventHanders do
        local _event = self.EventHanders[i]
        if _event.EventID == id and _event.Func == func and _event.Caller == caller then
            -- Repeat addition
            return
        end
    end
    self.EventHanders:Add({EventID = id, Func = func, Caller = caller})
end
function UIMainSubBasePanel:RegisterEvents()
    self.EventHanders:Clear()
    if self.OnRegisterEvents ~= nil then
        self:OnRegisterEvents()
    end
    for i = 1, #self.EventHanders do
        local _event = self.EventHanders[i]
        GameCenter.RegFixEventHandle(_event.EventID, _event.Func, _event.Caller)
    end
end
function UIMainSubBasePanel:UnRegisterEvents()
    for i = 1, #self.EventHanders do
        local _event = self.EventHanders[i]
        GameCenter.UnRegFixEventHandle(_event.EventID, _event.Func, _event.Caller)
    end
end

return UIMainSubBasePanel