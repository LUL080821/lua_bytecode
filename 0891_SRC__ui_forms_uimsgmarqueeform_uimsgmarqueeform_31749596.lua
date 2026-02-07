------------------------------------------------
-- author:
-- Date: 2019-06-19
-- File: UIMsgMarqueeForm.lua
-- Module: UIMsgMarqueeForm
-- Description: Horse Racing Light
------------------------------------------------

local UIMsgMarqueeForm =
{
    Panel = nil,
    -- Panel for shearing
    ClipPanel = nil,
    -- Label for displaying information
    InformationText = nil,
    -- Play position animation TweenPosition
    TweenPostion = nil,
    -- Currently playing information MsgMarqueeInfo
    CurInfo = nil,
    -- Information Queue List<MsgMarqueeInfo>
    MsgQueue = List:New(),
    -- Small speaker special effects UIVfxSkinCompoent
    Vfx = nil,
    -- Special effects location
    VfxPos = nil,
    -- The previous display time of the system announcement record
    SysTipsShowTime = 0,
    -- The system announcement interval is currently 5 minutes
    SysShowIntervalTime = 300,
    IsSysMarquee = false,
    Color = Color.white,
    -- The start time of the tween animation
    TweenStartTime = 0,
}

function UIMsgMarqueeForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIMARQUEE_OPEN, self.OnShowFirst);
    self:RegisterEvent(UIEventDefine.UIMARQUEE_SHOWINFO, self.OnShowInfo);
    self:RegisterEvent(UIEventDefine.UIMARQUEE_CLOSE, self.OnClose);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MSG_MARQUEE_CLEAR, self.OnClearInfo);
end

function UIMsgMarqueeForm:OnShowAfter()
    if self.TweenPostion ~= nil then
        self.TweenPostion.enabled = true;
    end
    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.TopRegion
end

function UIMsgMarqueeForm:OnHideBefore()
    return self.MsgQueue:Count() == 0;
end

function UIMsgMarqueeForm:OnFirstShow()
    self.Panel = UIUtils.FindWid(self.Trans, "Offset")
    self.ClipPanel = UIUtils.FindPanel(self.Trans, "Offset/Panel")
    self.VfxPos = UIUtils.FindTrans(self.Trans, "Offset/BackGround/VfxPos")
    self.InformationText = UIUtils.FindLabel(self.Trans, "Offset/Panel/Describe")
    self.Color = self.InformationText.color;
    self.TweenPostion = UIUtils.FindTweenPosition(self.Trans, "Offset/Panel/Describe")

    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.MiddleRegion
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
end

function UIMsgMarqueeForm:Update()
    if (self.MsgQueue:Count() > 0) then
        -- Speed up the playback when there are extra messages
        if (self.TweenPostion ~= nil and self.TweenPostion.enabled) then
            self.TweenPostion.duration = (self.InformationText.width + self.ClipPanel.width) / (self.CurInfo.Speed + 90);
        end
    end

    -- Turn off the marquee when the time is over
    if Time.GetRealtimeSinceStartup() - self.TweenStartTime >= self.TweenPostion.duration and self.Panel.alpha > 0 then
        self.TweenStartTime = Time.GetRealtimeSinceStartup()
        self.InformationText.enabled = false;
        if self.CurInfo ~= nil then
            self.CurInfo.Times = self.CurInfo.Times - 1
            if self.CurInfo.Times > 0 then
                self:SetInfo(self.CurInfo);
            else
                if (not self:SetInfo(self:DeQueue())) then
                    self.Panel.alpha = 0;
                    self.TweenPostion:ResetToBeginning();
                end
            end
        end
    end

    -- The following prompts are displayed every 5 minutes
    if (Time.GetRealtimeSinceStartup() - self.SysTipsShowTime >= self.SysShowIntervalTime) then
        if (self.MsgQueue:Count() > 0) then
            self.SysTipsShowTime = Time.GetRealtimeSinceStartup();
            return;
        end
        -- Set up random prompts
        self:SetRandomTipsShow()
    end
end

function UIMsgMarqueeForm:OnShowFirst(obj, sender)
    -- Set up random prompts
    self:SetRandomTipsShow()
end

-- Set up random prompts
function UIMsgMarqueeForm:SetRandomTipsShow()
    local _itemCount = DataConfig.DataTips.Count
    if (_itemCount > 0) then
        local _random = math.random(1, _itemCount);
        local _tipsData = DataConfig.DataTips[_random]
        if _tipsData ~= nil then
            self.IsSysMarquee = true;
            if _tipsData.Tips ~= nil then
                GameCenter.MsgPromptSystem:ShowMarquee(_tipsData.Tips);
            end
        end
    end
end

-- Clean up information
function UIMsgMarqueeForm:OnClearInfo(obj, sender)
    if self.CSForm.IsVisible then
        self.MsgQueue:Clear();
        self.CSForm:Hide();
    end
end

-- Display information
function UIMsgMarqueeForm:OnShowInfo(obj, sender)
    if (obj ~= nil) then
        if (self.CSForm.IsVisible == false) then
            self.CSForm:Show(sender)
        end
        if (self.CurInfo == nil) then
            self:SetInfo(obj);
        else
            local _selfPriority = UnityUtils.GetObjct2Int(self.CurInfo.Priority)
            local _objPriority = UnityUtils.GetObjct2Int(obj.Priority)
            if (_selfPriority < _objPriority) then
                self.MsgQueue:Insert(0, self.CurInfo);
                self:SetInfo(obj);
            else
                self:EnQueue(obj);
            end
        end
    end
end

function UIMsgMarqueeForm:SetInfo(msgMarqueeInfo)
    self.CurInfo = msgMarqueeInfo;
    if self.CurInfo ~= nil then
        self.TweenStartTime = Time.GetRealtimeSinceStartup();
        if self.IsSysMarquee then
            self.SysTipsShowTime = Time.GetRealtimeSinceStartup();
        end
        self:SetInformation();
        self:SetTweenPosition();
        return true;
    end
    return false;
end

function UIMsgMarqueeForm:SetInformation()
    if (self.IsSysMarquee) then
        self.IsSysMarquee = false;
        UIUtils.SetYellow(self.InformationText);
    else
        self.InformationText.color = self.Color;
        UIEventListener.Get(self.InformationText.gameObject).onClick = Utils.Handler(self.OnLabelClick, self)
        -- Dynamically set the click area size
        local _trans = self.InformationText.transform
        -- if self.InformationBoxCollider ~= nil then
        --     self.InformationBoxCollider.size = Vector3(self.InformationText.width, self.InformationText.height);
        -- end
    end
    -- Replace newline characters
    local _showText = string.gsub(self.CurInfo.Msg, "\n", "")
    UIUtils.SetTextByString(self.InformationText, _showText)
end

-- Click the tips to jump to the corresponding function interface
function UIMsgMarqueeForm:OnLabelClick(go)
    local _label = UIUtils.FindLabel(go.transform)
    if _label ~= nil then
        local _url = _label:GetUrlAtPosition(CS.UICamera.lastHit.point);
        if _url ~= nil then
            local _args = Utils.SplitStr(_url,'_')
            if #_args > 1 then
                local _functionId = tonumber(_args[1])
                local _argParam = tonumber(_args[2])
                GameCenter.MainFunctionSystem:DoFunctionCallBack(_functionId, _argParam);
            else
                local _functionId = tonumber(_url)
                GameCenter.MainFunctionSystem:DoFunctionCallBack(_functionId, nil);
            end
        end
    end
end

function UIMsgMarqueeForm:SetTweenPosition()
    local _panelW = self.ClipPanel.width;
    local _textW = self.InformationText.width;
    self.TweenPostion:ResetToBeginning();
    self.TweenPostion.from = Vector3(_panelW / 2, 0, 0);
    self.TweenPostion.to = Vector3(-(_textW + _panelW / 2), 0, 0);
    self.TweenPostion.duration = (_textW + _panelW) / self.CurInfo.Speed ;
    self.TweenPostion:PlayForward();
    self.InformationText.enabled = true;
    self.Panel.alpha = 1;
end

-- Add information object
function UIMsgMarqueeForm:EnQueue(msgMarqueeInfo)
    self.MsgQueue:Add(msgMarqueeInfo)
end

-- Get an information from the queue
function UIMsgMarqueeForm:DeQueue()
    local _result = nil
    if self.MsgQueue:Count() > 0 then
        _result = self.MsgQueue[1]
        self.MsgQueue:RemoveAt(1)
    end
    return _result
end

return UIMsgMarqueeForm