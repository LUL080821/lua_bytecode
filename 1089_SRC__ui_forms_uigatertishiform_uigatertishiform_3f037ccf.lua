------------------------------------------------
-- Author: 
-- Date: 2021-02-24
-- File: UIGaterTishiForm.lua
-- Module: UIGaterTishiForm
-- Description: Collection interface
------------------------------------------------


local UIGaterTishiForm = {
    -- Return button
    BackBtn = nil,
    -- Show Icon
    IconBase = nil,
    -- Objects that can be collected
    CanCollectObj = nil,
    -- Prompt name
    Name = nil,
    
    -- Icon ID
    IconId = 967,
    --ID
    ID = 0,
    -- Players
    LocalPlayer = nil,
}

-- Register event functions and provide them to the CS side to call.
function UIGaterTishiForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIGaterTishiForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIGaterTishiForm_CLOSE, self.OnClose)
end

-- The first display function is provided to the CS side to call.
function UIGaterTishiForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
end

-- Operation after opening
function UIGaterTishiForm:OnShowAfter()
    self.LocalPlayer = GameCenter.GameSceneSystem:GetLocalPlayer()
    self.IconBase:UpdateIcon(self.IconId)
    local _enty = GameCenter.GameSceneSystem:FindCollect(self.ID)
    if _enty ~= nil then 
        UIUtils.SetTextByString(self.Name,_enty.PropMoudle.Cfg.CollectInfo)
    end
    GameCenter.GatherTishiSystem.IsOpen = true
end

function UIGaterTishiForm:OnHideBefore()
    GameCenter.GatherTishiSystem.IsOpen = false
end

-- Turn on the event
function UIGaterTishiForm:OnOpen(obj,sender)
    if obj ~=nil then
        self.ID = tonumber(obj)
    end
    self.CSForm:Show(sender)
end

-- Close Event
function UIGaterTishiForm:OnClose(obj,sender)
    self.CSForm:Hide()

end

-- Close button event
function UIGaterTishiForm:OnClickBack()
    if self.LocalPlayer ~= nil and self.ID ~= 0 then
        self.LocalPlayer:SetCurSelectedTargetId(self.ID)
        PlayerBT.Collect:Write(false)
        self:OnClose(nil)
    end
end

-- Find controls
function UIGaterTishiForm:FindAllComponents()
    local _trans = self.Trans
    self.BackBtn = UIUtils.FindBtn(_trans, "Buttom/Back")
    self.IconBase = UIUtils.RequireUIIconBase(_trans)
    self.Name = UIUtils.FindLabel(_trans,"Buttom/Label")
end

-- Add a binding event
function UIGaterTishiForm:RegUICallback()
    UIUtils.AddBtnEvent(self.BackBtn, self.OnClickBack, self)
end

-- Real-time detection and collection of items
function UIGaterTishiForm:Update()
    local _frameCount = Time.GetFrameCount()
    if _frameCount % 30 ~= 0 then
        return 
    end
     
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then 
        return 
    end
     
    local _enty = GameCenter.GameSceneSystem:FindCollect(self.ID)
    if _enty == nil then
        self:OnClose()
        return
    end
    local sprDis =  Vector2.SqrMagnitude(_enty.Position2d - _lp.Position2d)
    if sprDis > 16 then 
        self:OnClose()
    end
end

return UIGaterTishiForm