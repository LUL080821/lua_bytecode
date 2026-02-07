------------------------------------------------
--author:
--Date: 2019-04-28
--File: UIMsgPromptForm.lua
--Module: UIMsgPromptForm
--Description: Top bar system message prompt box
------------------------------------------------
local UIMsgPromptItem = require("UI.Forms.UIMsgPromptForm.UIMsgPromptItem")
local MsgPromptSystem = CS.Thousandto.Code.Logic.MsgPromptSystem

local UIMsgPromptForm = 
{
    --No object used List<UIMsgPromptItem>
    UnUseList = List:New(),
    --A used object List<UIMsgPromptItem>
    UsedList = List:New(),
    --Can the next item be displayed currently
    EnableShow = false,
    --Message queue to be displayed List<MsgPromptInfo>
    MsgQueue = List:New(),
    FrontShowTime = 0,
    --The residence time is shorter
    ShowIntervalTime = 0.3,
    --Target position List<Vector3>
    ItemTargetPos = List:New(),
    --First position
    StartPos = Vector3(0, 110, 0),
    LifeTime = 2,
    --Record the last message displayed
    LastMsg = "",
    -- Under text message detection, interval time (how long will be displayed)
    TimeDistance = 1,
    --When there is data, you cannot close this interface
    CanClose = false,
}

function UIMsgPromptForm:Update()
    if(Time.GetRealtimeSinceStartup() - self.FrontShowTime >= self.ShowIntervalTime) then
        self.EnableShow = true
        --There is data in the cache, there are free display objects, and can be displayed
        if (self.MsgQueue:Count() > 0 and self:CheckShowNew()) then
            local _msgPromptInfo = self:DeQueue()
            local _intervalTime = Time.GetRealtimeSinceStartup() - _msgPromptInfo.RecTime
            if _msgPromptInfo.ItemBase ~= nil then
                self:SetInfo(_msgPromptInfo)
            else
                -- Under text message detection, the interval time is greater than 1 second before displaying
                if _intervalTime < self.TimeDistance or self.LastMsg ~= _msgPromptInfo.Msg then
                    self:SetInfo(_msgPromptInfo)
                end
            end
        end
    end
    for _, _item in pairs(self.UsedList) do
        if _item ~= nil then
            _item:Update()
        end
    end
end

function UIMsgPromptForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UISYSTEMINFO_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UISYSTEMINFO_SHOWINFO, self.OnShowInfo)
    self:RegisterEvent(UIEventDefine.UISYSTEMINFO_CLOSE, self.OnClose)
end

function UIMsgPromptForm:OnShowAfter()
    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.NoticRegion
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
end

function UIMsgPromptForm:OnShowBefore()
    self.EnableShow = true
end

function UIMsgPromptForm:OnHideBefore()
    --Don't let the outside turn off
	return self.CanClose
end

function UIMsgPromptForm:OnHideAfter()
    for _, _item in pairs(self.UsedList) do
        self.UnUseList:Add(_item)
    end
    self.MsgQueue:Clear()
end

function UIMsgPromptForm:OnFirstShow()
    self.UnUseList:Clear()
    self.UsedList:Clear()
    local _childCount = self.Trans.childCount - 1
    --The UI starts from 0, and the traversal starts from 0 here
    for i = 0, _childCount do
        local _transId = i
        local _path = string.format( "Info%s", i)
        local _promptItemGo = UIUtils.FindGo(self.Trans, _path)
        local _msgPromptItem = UIMsgPromptItem:New(_promptItemGo, self, tonumber(_transId))
        self.UnUseList:Add(_msgPromptItem)
        self.ItemTargetPos:Add(_promptItemGo.transform.localPosition)
    end
    GameCenter.PushFixEvent(UIEventDefine.UIMARQUEE_OPEN)
end

function UIMsgPromptForm:OnShowInfo(obj ,sender)
    if (obj ~= nil) then
        if (self.CSForm.IsVisible == false) then
            self.CSForm:Show(sender)
        end
        if (self:CheckShowNew()) then
            self.LifeTime = 2
            self:SetInfo(obj)
        else
            self:EnQueue(obj)
        end
    end
end

--When an Item becomes inactive, recycling is performed
function UIMsgPromptForm:OnItemDeactive(msgPromptItem)
    self.CanClose = true
    self.UsedList:Remove(msgPromptItem)
    self.UnUseList:Add(msgPromptItem)
end

function UIMsgPromptForm:SetInfo(msgPromptInfo)
    if (self.UnUseList:Count() > 0) then
        self.EnableShow = false
        self.FrontShowTime = Time.GetRealtimeSinceStartup()
        local _currentItem = self.UnUseList[1]
        self.UnUseList:Remove(_currentItem)
        for _, _usedItem in pairs(self.UsedList) do
            if _usedItem ~= nil and _currentItem ~= nil then
                local _usedId = tonumber(_usedItem.TransId)
                local _curId = tonumber(_currentItem.TransId)
                if (_usedId == _curId) then
                    self.UsedList:Remove(_usedItem);
                end
            end
        end
        self.UsedList:Add(_currentItem);
        if (msgPromptInfo.ItemBase ~= nil) then
            _currentItem:ShowItemMsg(msgPromptInfo.ItemBase, self.StartPos)
        else
            _currentItem:ShowMsg(msgPromptInfo.Msg, self.StartPos)
            self.LastMsg = msgPromptInfo.Msg
        end
        for i = 1, self.UsedList:Count() do
            self.UsedList[i]:MoveTo(self.ItemTargetPos[i])
        end
        self.CanClose = false
    end
end

--Add information object
function UIMsgPromptForm:EnQueue(msgPromptInfo)
    local _msg = msgPromptInfo
    _msg.RecTime = Time.GetRealtimeSinceStartup()
    self.MsgQueue:Add(_msg);
    -- When there is a lot of data in the queue, speed up the display speed
    if (self.MsgQueue:Count() >= 10) then
        self.LifeTime = 0.5
    elseif (self.MsgQueue:Count() >= 2) then
        self.LifeTime = 1.5
    else
        self.LifeTime = 2
    end
end

--Get an information from the queue
function UIMsgPromptForm:DeQueue()
    local _result = nil
    if self.MsgQueue:Count() > 0 then
        _result = self.MsgQueue[1]
        self.MsgQueue:RemoveAt(1)
    end
    if (self.MsgQueue:Count() >= 10) then
        self.LifeTime = 0.5
    elseif (self.MsgQueue:Count() >= 2) then
        self.LifeTime = 1.5
    else
        self.LifeTime = 2
    end
    return _result
end

--Judge new information to be displayed
function UIMsgPromptForm:CheckShowNew()
    return self.UnUseList:Count() > 0 and self.EnableShow and (self.UsedList:Count() <= self.ItemTargetPos:Count())
end

return UIMsgPromptForm