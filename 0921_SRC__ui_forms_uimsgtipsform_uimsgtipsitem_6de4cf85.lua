------------------------------------------------
-- author:
-- Date: 2019-03-25
-- File: MsgTipsItem.lua
-- Module: MsgTipsItem
-- Description: The experience gain prompt box and the Item class of the box to hit monsters in the lower right corner
------------------------------------------------

local ItemBase = CS.Thousandto.Code.Logic.ItemBase

local UIMsgTipsItem =
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

    -- Moving distance
    CN_FLOAT_DISTANCE = 100,
    -- Text display
    Desc = nil,
    IconDescribe = nil,
    IconTrans = nil,
    QualityTrans = nil,

    LifeTimer = 0,
    IsMoving = false,
    MoveDir = Vector3.zero,
    MoveTargetPos = Vector3.zero,
    ColorMsg = Color.white,
    -- Animation module
    AnimModule = nil,
    IsVisible = false
}

function UIMsgTipsItem:New(go, parent, transId)
    local _result = Utils.DeepCopy(self);
    _result.RootGo = go;
    _result.Trans = go.transform;
    _result.Parent = parent;
    _result.TransId = transId
    _result:OnFirstShow();
    return _result
end

function UIMsgTipsItem:OnFirstShow()
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()

    self.BaseWidget = UIUtils.FindWid(self.Trans)
    -- Control without Item
    self.Desc = UIUtils.FindLabel(self.Trans, "Tips")
    -- Text control with Item
    self.IconDescribe = UIUtils.FindLabel(self.Trans, "Icon/Tips")
    self.IconTrans = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    self.QualityTrans = UIUtils.FindTrans(self.Trans, "Icon/Quality")
    self.ColorMsg = self.Desc.color

    self.Trans.gameObject:SetActive(false)
    return self
end

function UIMsgTipsItem:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true
end

function UIMsgTipsItem:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

function UIMsgTipsItem:Update()
    if (self.IsMoving) then
        local tmpPos = self.Trans.localPosition
        tmpPos = tmpPos + self.MoveDir * Time.GetDeltaTime() * self.CN_FLOAT_DISTANCE
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

function UIMsgTipsItem:ShowItemMsg(itemBase, startPos)
    -- name
    local _itemName = nil
    local _qualityCode = 2
    local _item = nil
    -- Image Id
    local _iconId = nil
    if (itemBase ~= nil) then
        _item = DataConfig.DataEquip[itemBase.CfgID]
        if _item ~= nil then
            _qualityCode = _item.Quality
        else
            _item = DataConfig.DataItem[itemBase.CfgID]
            _qualityCode = _item.Color
        end
        
        _itemName = itemBase.Name
        _iconId = tonumber(itemBase.Icon)
        if _item == nil then
            return
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

function UIMsgTipsItem:ShowMsg(msg, startPos)
    self.IconTrans.gameObject:SetActive(false)
    self.Desc.gameObject:SetActive(true)
    UIUtils.SetTextByString(self.Desc, msg)
    self.Trans.localPosition = startPos
    self.IsMoving = false
    self.LifeTimer = 0
    self.BaseWidget.alpha = 0
    self:Show()
end

function UIMsgTipsItem:MoveTo(pos)
    if (self.Trans.localPosition ~= pos) then
        self.MoveTargetPos = pos
        self.MoveDir = (self.MoveTargetPos - self.Trans.localPosition).normalized
        self.IsMoving = true
    end
end

function UIMsgTipsItem:GetTransId()
    return self.TransId
end

return UIMsgTipsItem