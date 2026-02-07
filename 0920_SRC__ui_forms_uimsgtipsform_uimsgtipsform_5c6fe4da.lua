------------------------------------------------
--author:
--Date: 2019-03-25
--File: MsgTipsForm.lua
--Module: MsgTipsForm
--Description: Experience gain prompt box and monster-killing item gain box in the lower right corner
------------------------------------------------

local UIMsgTipsItem = require("UI.Forms.UIMsgTipsForm.UIMsgTipsItem")

local UIMsgTipsForm = 
{
    --The object not used List<UIMsgTipsItem>
    UnUseList = List:New(),
    --A used object List<UIMsgTipsItem>
    UsedList = List:New(),
    --The next item can be displayed currently
    EnableShow = false,
    --Record the last time displayed
    FrontShowTime = 0,
    --The next interval between occurrence
    ShowIntervalTime = 0.3,
    --Moving target position List<Vector3>
    ItemTargetPos = List:New(),
    -- Starting position
    StartPos = Vector3(-174, -20, 0),
    --Message queue to be displayed List<MsgPromptInfo>
    MsgQueue = List:New(),
    --Displayed time
    LifeTime = 1,
}

function UIMsgTipsForm:Update()
    if ((Time.GetRealtimeSinceStartup() - self.FrontShowTime) >= self.ShowIntervalTime) then
        self.EnableShow = true
        --There is data in the cache, there are free display objects, and it is necessary to display them
        if (self.MsgQueue:Count() > 0 and self:CheckShowNew()) then
            self:SetInfo(self:DeQueue())
        end
    end
    for _, _item in pairs(self.UsedList) do
        if _item ~= nil then
            _item:Update()
        end
    end
end

function UIMsgTipsForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIMsgTipsForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, self.OnShowInfo)
    self:RegisterEvent(UIEventDefine.UIMsgTipsForm_CLOSE,self.OnClose)
end

function UIMsgTipsForm:OnShowBefore()
    self.EnableShow = true
end

function UIMsgTipsForm:OnShowAfter()
    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.TopRegion
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
end

function UIMsgTipsForm:OnHideAfter()
    for _, _item in pairs(self.UsedList) do
        self.UnUseList:Add(_item)
    end
    self.MsgQueue:Clear()
end

function UIMsgTipsForm:OnFirstShow()
    self.UnUseList:Clear()
    self.UsedList:Clear()
    local _msgTrans = UIUtils.FindTrans(self.Trans, "Msg")
    for i = 0, _msgTrans.childCount - 1 do
        local _tipsItemGo = _msgTrans:GetChild(i).gameObject
        local _tipsItem = UIMsgTipsItem:New(_tipsItemGo, self, i)
        self.UnUseList:Add(_tipsItem)
        self.ItemTargetPos:Add(_tipsItemGo.transform.localPosition)
    end
end

--Show information
function UIMsgTipsForm:OnShowInfo(obj, sender)
    if (obj ~= nil) then
        if (self.CSForm.IsVisible == false) then
            self.CSForm:Show(sender)
        end
        if (self:CheckShowNew()) then
            self:SetInfo(obj)
        else
            self:EnQueue(obj)
        end
    end
end

--When an Item becomes inactive, recycling is performed
function UIMsgTipsForm:OnItemDeactive(msgTipsItem)
    self.UsedList:Remove(msgTipsItem)
    self.UnUseList:Add(msgTipsItem)
end

function UIMsgTipsForm:SetInfo(msgPromptInfo)
    if (self.UnUseList:Count() > 0) then
        self.EnableShow = false
        self.FrontShowTime = Time.GetRealtimeSinceStartup()
        local _currentItem = self.UnUseList[1]
        self.UnUseList:Remove(_currentItem)
        for i = 1, self.UsedList:Count() do
            if self.UsedList:Count() >= 1 and self.UsedList[i] ~= nil then
                local _tempId = tonumber(self.UsedList[i]:GetTransId())
                local _curId = tonumber(_currentItem:GetTransId())
                if (_tempId == _curId) then
                    self.UsedList:Remove(self.UsedList[i])
                end
            end
        end
        self.UsedList:Add(_currentItem)
        if type(msgPromptInfo) == "string" then
            _currentItem:ShowMsg(msgPromptInfo, self.StartPos)
        else
            _currentItem:ShowItemMsg(msgPromptInfo, self.StartPos)
        end
        for i = 1, self.UsedList:Count() do
            self.UsedList[i]:MoveTo(self.ItemTargetPos[i]);
        end
    end
end

--Add information object
function UIMsgTipsForm:EnQueue(msgPromptInfo)
    self.MsgQueue:Add(msgPromptInfo)
end

--Get an information from the queue
function UIMsgTipsForm:DeQueue()
    local _result = nil
    if self.MsgQueue:Count() > 0 then
        _result = self.MsgQueue[1]
        self.MsgQueue:RemoveAt(1)
    end
    return _result
end

--Judge new information to be displayed
function UIMsgTipsForm:CheckShowNew()
    return self.UnUseList:Count() > 0 and self.EnableShow and self.UsedList:Count() <= self.ItemTargetPos:Count()
end

return UIMsgTipsForm