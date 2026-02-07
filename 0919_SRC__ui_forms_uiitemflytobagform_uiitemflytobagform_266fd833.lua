------------------------------------------------
-- author:
-- Date: 2021-02-22
-- File: UIItemFlyToBagForm.lua
-- Module: UIItemFlyToBagForm
-- Description: The item gets the display interface for flying to the backpack
------------------------------------------------

local NORMAL_DELAY_TIME = 0.3
local SPECIAL_DELAY_TIME = 1.2
   -- curve
local L_NormalCurve = nil
local L_SpecialCurve = nil

-- //Module definition
local UIItemFlyToBagForm = {
    -- Default item list
    NormalList = nil,
    -- Special item list
    SpecialList = nil,
    -- Cache list of items
    NormalQueue = nil,
    SpecialQueue = nil,
    -- Delayed item list
    DelayItemList = nil,
    -- Timer
    NormalTimer = 0,
    SpecialTimer = 0,
}

-- Inheriting Form functions
function UIItemFlyToBagForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIItemFlyToBagForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIItemFlyToBagForm_CLOSE, self.OnClose)
end

local L_UINormalItem = nil
local L_UISpecialItem = nil

function UIItemFlyToBagForm:OnFirstShow()
    local _trans = self.Trans
   
    self.NormalList = List:New()
    local _parentTrans = UIUtils.FindTrans(_trans, "Target/NormalItems")
    for i = 1, _parentTrans.childCount do
        local item = L_UINormalItem:New(_parentTrans:GetChild(i - 1))
        self.NormalList:Add(item);
    end
    local _tweer = UIUtils.FindTweenAlpha(_parentTrans)
    L_NormalCurve = _tweer.animationCurve

    self.SpecialList = List:New()
    _parentTrans = UIUtils.FindTrans(_trans, "Target/SpecialItems")
    for i = 1, _parentTrans.childCount do
        local item = L_UISpecialItem:New(_parentTrans:GetChild(i - 1))
        self.SpecialList:Add(item);
    end
    _tweer = UIUtils.FindTweenAlpha(_parentTrans)
    L_SpecialCurve = _tweer.animationCurve

    self.NormalQueue = List:New()
    self.SpecialQueue = List:New()
    self.DelayItemList = List:New()
end

function UIItemFlyToBagForm:OnShowAfter()
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
    self.CSForm.UIRegion = UIFormRegion.NoticRegion
    self.NormalTimer = 0
    self.SpecialTimer = 0
end

function UIItemFlyToBagForm:OnHideBefore()
    for i = 1, #self.NormalList do
        self.NormalList[i]:Hide()
    end

    for i = 1, #self.SpecialList do
        self.SpecialList[i]:Hide()
    end
    self.DelayItemList:Clear()
    self.NormalQueue:Clear()
    self.SpecialQueue:Clear()
end

-- Turn on the event
function UIItemFlyToBagForm:OnOpen(info, sender)
    
    GameCenter.NewFashionSystem:UpdateTjRedPoint()

    self.CSForm:Show(sender)
    
    if info ~= nil and info.Item ~= nil then
        if info.DelayTime > 0 then
            self.DelayItemList:Add(info)
        else
            self:AddInfo(info)
        end
    end
end

-- Close Event
function UIItemFlyToBagForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIItemFlyToBagForm:AddInfo(info)
    local _itemCfg = info.ItemCfg
    local _equipCfg = info.EquipCfg
    if _equipCfg ~= nil then
        if _equipCfg.FlyToBagType == 1 then
            self.NormalQueue:Add(info)
        else
            self.SpecialQueue:Add(info)
        end
    end
    if _itemCfg ~= nil then
        if _itemCfg.FlyToBagType == 1 then
            self.NormalQueue:Add(info)
        else
            self.SpecialQueue:Add(info)
        end
    end
end

function UIItemFlyToBagForm:Update()
    local _dt = Time.GetDeltaTime()
    for i = 1, #self.NormalList do
        self.NormalList[i]:Update(_dt)
    end

    for i = 1, #self.SpecialList do
        self.SpecialList[i]:Update(_dt)
    end

    local _delayCount = #self.DelayItemList
    for i = _delayCount, 1, -1 do
        local _item = self.DelayItemList[i]
        _item.DelayTime = _item.DelayTime - _dt
        if _item.DelayTime <= 0 then
            self:AddInfo(self.DelayItemList[i])
            self.DelayItemList:RemoveAt(i)
        end
    end

    local _normalCount = #self.NormalQueue
    if _normalCount > 0 then
        self.NormalTimer = self.NormalTimer - _dt
        if self.NormalTimer <= 0 then
            for i = 1, #self.NormalList do
                if not self.NormalList[i].IsVisible then
                    local _info = self.NormalQueue[1]
                    self.NormalQueue:RemoveAt(1)
                    self.NormalList[i]:Show(_info)
                    self.NormalTimer = NORMAL_DELAY_TIME
                    break
                end
            end
        end
    end
  
    local _specCount = #self.SpecialQueue
    if _specCount > 0 then
        self.SpecialTimer = self.SpecialTimer - _dt
        if self.SpecialTimer <= 0 then
            for i = 1, #self.SpecialList do
                if not self.SpecialList[i].IsVisible then
                    local _info = self.SpecialQueue[1]
                    self.SpecialQueue:RemoveAt(1)
                    self.SpecialList[i]:Show(_info)
                    self.SpecialTimer = SPECIAL_DELAY_TIME
                    break;
                end
            end
        end
    end
end

-- Default item
local NormalStartPosX = -213
local NormalStartPosY = 94
local NormalEndPosX = 0
local NormalEndPosY = 0
local NormalStartScale = 0
local NormalHoldScale = 0.8
local NormalEndScale = 0
local NormalStartTime = 0.5
local NormalHoldTime = 0.7
local NormalEndTime = 0.1
L_UINormalItem = {
    Trans = nil,
    Go = nil,
    Item = nil,
    Timer = 0,
    IsVisible = false,
}

function L_UINormalItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Item = UILuaItem:New(trans)
    _m:Hide()
    return _m
end

function L_UINormalItem:Show(item)
    if item ~= nil then
        self.Item:InitWithItemData(item.Item, item.ItemCount)
        self.Item.isShowTips = false
        self.IsVisible = true
        self.Go:SetActive(true)
        self.Timer = 0
        UnityUtils.SetLocalPosition(self.Trans, NormalStartPosX, NormalStartPosY, 0)
        UnityUtils.SetLocalScale(self.Trans, NormalStartScale, NormalStartScale, NormalStartScale)
    end
end

function L_UINormalItem:Hide()
    self.IsVisible = false
    self.Go:SetActive(false)
end

function L_UINormalItem:Update(dt)
    if not self.IsVisible then
        return
    end
    self.Timer = self.Timer + dt
    if self.Timer <= NormalStartTime then
        local _scale = math.Lerp(NormalStartScale, NormalHoldScale, self.Timer / NormalStartTime)
        UnityUtils.SetLocalScale(self.Trans, _scale, _scale, _scale)
        UnityUtils.SetLocalPosition(self.Trans, NormalStartPosX, NormalStartPosY, 0)
    elseif self.Timer <= NormalStartTime + NormalHoldTime then
        UnityUtils.SetLocalScale(self.Trans, NormalHoldScale, NormalHoldScale, NormalHoldScale)
        local _lerpValue = L_NormalCurve:Evaluate((self.Timer - NormalStartTime) / NormalHoldTime)
        local _x = math.Lerp(NormalStartPosX, NormalEndPosX, _lerpValue)
        local _y = math.Lerp(NormalStartPosY, NormalEndPosY, _lerpValue)
        UnityUtils.SetLocalPosition(self.Trans, _x, _y, 0)
    elseif self.Timer <= NormalStartTime + NormalHoldTime + NormalEndTime then
        local _scale = math.Lerp(NormalHoldScale, NormalEndScale, (self.Timer - NormalStartTime - NormalHoldTime) / NormalEndTime)
        UnityUtils.SetLocalScale(self.Trans, _scale, _scale, _scale)
        UnityUtils.SetLocalPosition(self.Trans, NormalEndPosX, NormalEndPosY, 0)
    else
        self:Hide()
    end
end

-- Special item
local SpecStartPosX = -98
local SpecStartPosY = 131
local SpecEndPosX = 0
local SpecEndPosY = 0
local SpecStartScale = 0
local SpecHoldScale = 0.9
local SpecEndScale = 0
local SpecStartTime = 0.3
local SpecHoldTime = 1.5
L_UISpecialItem = {
    Trans = nil,
    Go = nil,
    Item = nil,
    Timer = 0,
    IsVisible = false,
}

function L_UISpecialItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Item = UILuaItem:New(trans)
    _m:Hide()
    return _m
end

function L_UISpecialItem:Show(item)
    if item ~= nil then
        self.Item:InitWithItemData(item.Item, item.ItemCount)
        self.Item.isShowTips = false
        self.IsVisible = true
        self.Go:SetActive(true)
        self.Timer = 0
        UnityUtils.SetLocalPosition(self.Trans, SpecStartPosX, SpecStartPosY, 0)
        UnityUtils.SetLocalScale(self.Trans, SpecStartScale, SpecStartScale, SpecStartScale)
    end
end

function L_UISpecialItem:Hide()
    self.IsVisible = false
    self.Go:SetActive(false)
end

function L_UISpecialItem:Update(dt)
    if not self.IsVisible then
        return
    end
    self.Timer = self.Timer + dt
    if self.Timer <= SpecStartTime then
        local _scale = math.Lerp(SpecStartScale, SpecHoldScale, self.Timer / SpecStartTime)
        UnityUtils.SetLocalScale(self.Trans, _scale, _scale, _scale)
        UnityUtils.SetLocalPosition(self.Trans, SpecStartPosX, SpecStartPosY, 0)
    elseif self.Timer <= SpecStartTime + SpecHoldTime then
        local _lerpValue = L_SpecialCurve:Evaluate((self.Timer - SpecStartTime) / SpecHoldTime)
        local _x = math.Lerp(SpecStartPosX, SpecEndPosX, _lerpValue)
        local _y = math.Lerp(SpecStartPosY, SpecEndPosY, _lerpValue)
        UnityUtils.SetLocalPosition(self.Trans, _x, _y, 0)
        local _scale = math.Lerp(SpecHoldScale, SpecEndScale, _lerpValue)
        UnityUtils.SetLocalScale(self.Trans, _scale, _scale, _scale)
    else
        self:Hide()
    end
end

return UIItemFlyToBagForm
