------------------------------------------------
-- author:
-- Date: 2019-04-28
-- File: UIMsgPromptItem.lua
-- Module: UIMsgPromptItem
-- Description: The Item class of the top bar information prompt interface
------------------------------------------------
local ItemBase = CS.Thousandto.Code.Logic.ItemBase

local UIMsgPromptItem =
{
    -- Parent class
    Parent = nil,
    -- Current object GameObject
    RootGo = nil,
    -- Record which one is currently
    TransId = nil,
    -- Transfrom of the current object
    Trans = nil,
    BaseWidget = nil,
    -- Text display
    Desc = nil,
    IconTrans = nil,
    QualityTrans = nil,
    MoveTargetPos = Vector3.zero,
    MoveDir = Vector3.zero,
    ColorMsg = Color.white,
    IsMoving = false,
    LifeTimer = 0,
    MoveSpeed = 100,
    -- Animation module
    AnimModule = nil,
    IsVisible = false
}

function UIMsgPromptItem:New(go, parent, transId)
    local _result = Utils.DeepCopy(self);
    _result.RootGo = go;
    _result.Trans = go.transform;
    _result.Parent = parent;
    _result.TransId = transId
    _result:OnFirstShow();
    return _result
end

function UIMsgPromptItem:OnFirstShow()
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()

    self.BaseWidget = UIUtils.FindWid(self.Trans)
    -- Text control without Item
    self.Desc = UIUtils.FindLabel(self.Trans, "Describe")
    -- Text control with Item
    self.IconDescribe = UIUtils.FindLabel(self.Trans, "Icon/Tips")
    -- Item icon
    self.IconTrans = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    -- Item quality
    self.QualityTrans = UIUtils.FindTrans(self.Trans, "Icon/Quality")
    -- The color of text display
    self.ColorMsg = self.Desc.color
    self.Trans.gameObject:SetActive(false)
    return self
end

function UIMsgPromptItem:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true
end

function UIMsgPromptItem:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

function UIMsgPromptItem:Update()
    if (self.IsMoving) then
        local tmpPos = self.Trans.localPosition
        tmpPos = tmpPos + self.MoveDir * Time.GetDeltaTime() * self.MoveSpeed
        local newDir = (self.MoveTargetPos - tmpPos).normalized
        if (CS.UnityEngine.Vector3.Dot(newDir, self.MoveDir) <= 0) then
            self.Trans.localPosition = self.MoveTargetPos
            self.IsMoving = false
        else
            self.Trans.localPosition = tmpPos
        end
    end

    if self.IsVisible then
        self.LifeTimer = self.LifeTimer + Time.GetDeltaTime()
        if (self.LifeTimer >= self.Parent.LifeTime) then
            self:Hide()
            self.Parent:OnItemDeactive(self)
        end
    end
end

function UIMsgPromptItem:ShowItemMsg(itemBase, startPos)
    -- name
    local _itemName = nil
    local _qualityCode = 2
    -- Image Id
    local _iconId = nil
    if (itemBase ~= nil) then
        _qualityCode = itemBase.Quality
        _iconId = itemBase.Icon
        if itemBase.Count > 1 then
            _itemName = UIUtils.CSFormat("{0}X{1}", itemBase.Name, itemBase.Count)
        else
            _itemName = itemBase.Name
        end
        -- Refresh Icon
        self.IconTrans:UpdateIcon(_iconId)
        self.IconTrans.gameObject:SetActive(true)
        local _qualtyName = Utils.GetQualitySpriteName(_qualityCode)
        local _qualitySpr = UIUtils.FindSpr(self.QualityTrans)
        if (_qualitySpr ~= nil) then
            _qualitySpr.spriteName = _qualtyName
        end
    end
    self.Desc.gameObject:SetActive(false)
    -- Set color
    UIUtils.SetColorByQuality(self.IconDescribe, _qualityCode)
    -- Set content
    UIUtils.SetTextByString(self.IconDescribe, _itemName)
    -- Set the starting position of movement
    self.Trans.localPosition = startPos
    self.IsMoving = false
    self.LifeTimer = 0
    self.BaseWidget.alpha = 0
    self:Show()
end

function UIMsgPromptItem:ShowMsg(msg, startPos)
    self.IconTrans.gameObject:SetActive(false)
    self.Desc.gameObject:SetActive(true)
    -- Set the display content
    UIUtils.SetTextByString(self.Desc, msg)
    self.Desc.color = self.ColorMsg;
    -- Set the starting point of movement
    self.Trans.localPosition = startPos
    self.IsMoving = false
    self.LifeTimer = 0
    self.BaseWidget.alpha = 0
    self:Show()
end

function UIMsgPromptItem:MoveTo(pos)
    if (self.Trans.localPosition ~= pos) then
        self.MoveTargetPos = pos
        self.MoveDir = (self.MoveTargetPos - self.Trans.localPosition).normalized
        self.IsMoving = true
    end
end

return UIMsgPromptItem