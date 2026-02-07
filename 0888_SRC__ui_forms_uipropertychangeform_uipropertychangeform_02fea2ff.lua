------------------------------------------------
--author:
--Date: 2021-02-19
--File: UIPropertyChangeForm.lua
--Module: UIPropertyChangeForm
--Description: The representation interface when the attribute changes
------------------------------------------------

local BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools

--//Module definition
local UIPropertyChangeForm = {
    Res = nil,
    ResList = List:New(),
    UsedList = List:New(),
    NeedShowTexts = List:New(),
    AddTimer = 0,
    CurPosIndex = 0,
    LoadFormId = 0,
}

--Inherit the Form function
function UIPropertyChangeForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIPropertyChangeForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIPropertyChangeForm_CLOSE, self.OnClose)
end

local L_PropertyText = nil
local L_TextAnimState = nil

function UIPropertyChangeForm:OnFirstShow()
    local _trans = self.Trans
    self.Res = UIUtils.FindGo(_trans, "LeftTop/Root/Text")
    self.ResList:Clear()
    self.ResList:Add(L_PropertyText:New(self.Res))
    self.CSForm.UIRegion = UIFormRegion.NoticRegion
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
    self.LoadFormId = GameCenter.FormStateSystem:EventIDToFormID(UnityUtils.GetObjct2Int(UIEventDefine.UILOADINGFORM_OPEN))
end

function UIPropertyChangeForm:OnHideAfter()
    for i= 1, #self.UsedList do
        self.UsedList[i].RootGo:SetActive(false)
        self.ResList:Add(self.UsedList[i])
    end
    self.UsedList:Clear()
end


function UIPropertyChangeForm:OnShowAfter()
    self.CurPosIndex = 0
end

--Open event
function UIPropertyChangeForm:OnOpen(objs, sender)
    self.CSForm:Show(sender)
    if objs == nil or objs.Length < 2 then
        return
    end
    local _type = objs[0]
    local _value = objs[1]
    for i = 1, #self.NeedShowTexts do
        if self.NeedShowTexts[i].Type == _type then
            local _newValue = self.NeedShowTexts[i].Value + _value
            self.NeedShowTexts[i] = {Type = _type, Value = _newValue}
            return
        end
    end
    self.NeedShowTexts:Add({Type = _type, Value = _value})
end

--Close event
function UIPropertyChangeForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIPropertyChangeForm:Update()
    if GameCenter.FormStateSystem:FormIsOpen(self.LoadFormId) then
        self:OnClose(nil)
        return
    end
    self.AddTimer = self.AddTimer - Time.GetDeltaTime()
    local _needShowCount = #self.NeedShowTexts
    if _needShowCount > 0 and self.AddTimer <= 0 then
        if self.CurPosIndex >= 13 and #self.UsedList <= 5 then
            self.CurPosIndex = 0
        end
        if self.CurPosIndex < 13 then
            self.AddTimer = 0.1
            local _textData = self.NeedShowTexts[1]
            self.NeedShowTexts:RemoveAt(1)
            local _propText = nil
            local _resCount = #self.ResList
            if _resCount > 0 then
                _propText = self.ResList[_resCount]
                self.ResList:RemoveAt(_resCount)
            else
                _propText = L_PropertyText:New(UnityUtils.Clone(self.Res))
            end
            local _propName = BattlePropTools.GetBattlePropName(_textData.Type)
            local _propValueText = BattlePropTools.GetBattleValueText(_textData.Type, _textData.Value)
            _propText:SetInfo(string.format("+ %s %s", _propName, _propValueText), 0, self.CurPosIndex * -40)
            --_propText:SetInfo(string.format("+ %s %d", BattlePropTools.GetBattlePropName(_textData.Type), _textData.Value), 0, self.CurPosIndex * -40)
            self.UsedList:Add(_propText)
            self.CurPosIndex = self.CurPosIndex + 1
        end
    end

    for i = #self.UsedList, 1, -1 do
        self.UsedList[i]:Upodate()
        if self.UsedList[i]:IsFinish() then
            self.ResList:Add(self.UsedList[i])
            self.UsedList:RemoveAt(i)
        end
    end

    if _needShowCount <= 0 and #self.UsedList <= 0 then
        self:OnClose(nil, nil)
    end
end

L_TextAnimState = {
    MoveUP = 1,
    HoldOn = 2,
    Hide = 3,
    Finish = 4,
}

L_PropertyText = {
    RootGo = nil,
    RootTrans = nil,
    Text = nil,
    CurState = L_TextAnimState.Finish,
    StartPosX = 0,
    StartPosY = 0,
    TargetPosX = 0,
    TargetPosY = 0,
    StateTimer = 0,
}

function L_PropertyText:IsFinish()
    return self.CurState == L_TextAnimState.Finish
end

function L_PropertyText:New(go)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    _m.RootTrans = go.transform
    _m.Text = UIUtils.FindLabel(_m.RootTrans)
    return _m
end

function L_PropertyText:SetInfo(text, posX, posY)
    self.TargetPosX = posX
    self.TargetPosY = posY
    UIUtils.SetTextByString(self.Text, text)
    self:ChangeShate(L_TextAnimState.MoveUP)
end

function L_PropertyText:ChangeShate(state)
    self.CurState = state
    if state == L_TextAnimState.MoveUP then
        self.RootGo:SetActive(true)
        self.StartPosX = self.TargetPosX
        self.StartPosY = self.TargetPosY - 40
        UnityUtils.SetLocalPosition(self.RootTrans, self.StartPosX, self.StartPosY, 0)
        self.Text.alpha = 0.5
        self.StateTimer = 0
    elseif state == L_TextAnimState.HoldOn then
        self.StateTimer = 0
    elseif state == L_TextAnimState.Hide then
        self.RootGo:SetActive(true)
        self.StartPosX = self.TargetPosX + 300
        self.StartPosY = -50
        UnityUtils.SetLocalPosition(self.RootTrans, self.TargetPosX, self.TargetPosY, 0)
        self.Text.alpha = 1
        self.StateTimer = 0
    elseif state == L_TextAnimState.Finish then
        self.RootGo:SetActive(false)
    end
end

local L_MoveUpTime = 0.2
local L_HoldOnTime = 0.8
local L_HideTime = 0.2
function L_PropertyText:Upodate()
    if self.CurState == L_TextAnimState.MoveUP then
        self.StateTimer = self.StateTimer + Time.GetDeltaTime()
        if self.StateTimer < L_MoveUpTime then
            local _lerpValue = self.StateTimer / L_MoveUpTime
            UnityUtils.SetLocalPosition(self.RootTrans, math.Lerp(self.StartPosX, self.TargetPosX, _lerpValue), math.Lerp(self.StartPosY, self.TargetPosY, _lerpValue), 0)
            self.Text.alpha = math.Lerp(0.5, 1, _lerpValue)
        else
            UnityUtils.SetLocalPosition(self.RootTrans, self.TargetPosX, self.TargetPosY, 0)
            self.Text.alpha = 1
            self:ChangeShate(L_TextAnimState.HoldOn)
        end
    elseif self.CurState == L_TextAnimState.HoldOn then
        self.StateTimer = self.StateTimer + Time.GetDeltaTime()
        if self.StateTimer >= L_HoldOnTime then
            self:ChangeShate(L_TextAnimState.Hide)
        end
    elseif self.CurState == L_TextAnimState.Hide then
        self.StateTimer = self.StateTimer + Time.GetDeltaTime()
        if self.StateTimer < L_HideTime then
            local _lerpValue = self.StateTimer / L_HideTime
            UnityUtils.SetLocalPosition(self.RootTrans, math.Lerp(self.TargetPosX, self.StartPosX, _lerpValue), math.Lerp(self.TargetPosY, self.StartPosY, _lerpValue), 0)
            self.Text.alpha = math.Lerp(1, 0.3, _lerpValue)
        else
            self:ChangeShate(L_TextAnimState.Finish)
        end
    end
end

return UIPropertyChangeForm
