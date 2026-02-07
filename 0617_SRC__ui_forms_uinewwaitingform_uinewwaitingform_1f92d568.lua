
--==============================--
--author:
--Date: 2020-01-16 00:00:00
--File: UINewWaitingForm.lua
--Module: UINewWaitingForm
--Description: New waiting form
--==============================--

local UINewWaitingForm = 
{
    --Description text component
    DescLabel = nil,
    --Components of background
    BackgroupGo = nil,
    --Countdown to the last update time
    LastUpdateIntTime = -1;
    --The current countdown time
    CurrentFloatTime = 0;

    --Tips' text description
    TipsText = nil,
}
--Define the ellipsis after the statement
local L_Ellipsis = {".","..","...","... .","... ..","... ..."}

--Register event function, provided to the CS side to call.
function UINewWaitingForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UI_WAITING_OPEN,self.OnUnLockOpen)
    self:RegisterEvent(UIEventDefine.UI_WAITING_LOCK_OPEN,self.OnLockOpen)
	self:RegisterEvent(UIEventDefine.UI_WAITING_CLOSE,self.OnClose)
end

function UINewWaitingForm:OnUnLockOpen(object,sender)    
    self.LastUpdateIntTime = -1;
    self.CurrentFloatTime = 0;
    self:OnOpen(object,sender);
    if self.BackgroupGo then    
        self.BackgroupGo:SetActive(false);
    end
end

function UINewWaitingForm:OnLockOpen(object,sender)   
    self.LastUpdateIntTime = -1;
    self.CurrentFloatTime = 0; 
    self:OnOpen(object,sender);
    if self.BackgroupGo then        
        self.BackgroupGo:SetActive(true);
    end
end
--The first display function is provided to the CS side to call.
function UINewWaitingForm:OnFirstShow()	
	self:FindAllComponents();
	self:RegUICallback();
end

--Binding UI components callback function
function UINewWaitingForm:RegUICallback()
end

--Show the previous operation and provide it to the CS side to call.
function UINewWaitingForm:OnShowBefore()    
    self.LastUpdateIntTime = -1;
    self.CurrentFloatTime = 0;
    self.CSForm.UIRegion = UIFormRegion.TopRegion;
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
end

--The operation after display is provided to the CS side to call.
function UINewWaitingForm:OnShowAfter()    
    self.TipsText = self:GetShowParam();
    if  self.TipsText == nil then
        self.TipsText = DataConfig.DataMessageString.Get("Watting_Form_Msg");
    end
    UIUtils.SetTextByString(self.DescLabel, self.TipsText)       
end

--Find all components
function UINewWaitingForm:FindAllComponents()
    local _myTrans = self.Trans;
    self.DescLabel = UIUtils.FindLabel(_myTrans,"Desc");
    self.BackgroupGo = UIUtils.FindGo(_myTrans,"Backgroup");
    self.BackgroupGo:SetActive(false);
end

function UINewWaitingForm:Update(dt)
    self.CurrentFloatTime = self.CurrentFloatTime + dt;
    if self.CurrentFloatTime > 6 then
        self.CurrentFloatTime = 0;
        if self.BackgroupGo and self.BackgroupGo.activeSelf then
            self.BackgroupGo:SetActive(false);
        end
    end
    local _intTime = math.floor(self.CurrentFloatTime);
    if self.LastUpdateIntTime ~= _intTime then
        self.LastUpdateIntTime  = _intTime;
        UIUtils.SetTextByString(self.DescLabel, self.TipsText .. L_Ellipsis[_intTime+1])
    end
end

--[Interface button callback begin]-
---[Interface button callback end]---

return UINewWaitingForm;
