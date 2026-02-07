
--==============================--
-- author:
-- Date: 2020-12-24
-- File: UILoadingForm.lua
-- Module: UILoadingForm
-- Description: Processing of Loading form
--==============================--

local UILoadingForm = {
	-- Progress controls
	ProgressBar = nil,
	ProgressValueLabel = nil,
	TipsLabel = nil,
	-- background
	BGSutureTexture = nil,

	-- Current actual progress
	CurrentProgressValue = nil,
	-- Progress queue, progress needs to grow along the progress queue, and cannot jump to the last value at once
	ProgressValueList = nil,
	-- Current smooth animation progress value
	AnimProgressValue = nil,

	-- Prompt to show the elapsed time
	TipsElapseTime = 0,
}

-- Register event functions and provide them to the CS side to call.
function UILoadingForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UILOADINGFORM_OPEN, self.OnOpen);
	self:RegisterEvent(UIEventDefine.UILOADINGFORM_CLOSE, self.OnClose);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_PROGRESS, self.OnProgressChange);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_PROGRESS_TEXT, self.OnProgressTextChange);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UILOADINGFORM_SHOW_TIPS, self.OnTipsChange);
end


-- The first display function is provided to the CS side to call.
function UILoadingForm:OnFirstShow()	
	self:FindAllComponents();	
end

-- Find all components
function UILoadingForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.ProgressBar = UIUtils.FindProgressBar(_myTrans,"ProgressBar/Progress");
	self.ProgressValueLabel = UIUtils.FindLabel(_myTrans,"ProgressBar/RrogressValue");
	self.TipsLabel = UIUtils.FindLabel(_myTrans,"Buttom/Tips");
	self.BGSutureTexture = UIUtils.FindSutureTex(_myTrans,"NewBG");

	-- Whether to display LoadingBar
	local _barGo = UIUtils.FindGo(_myTrans,"ProgressBar");
	_barGo:SetActive(AppPersistData.IsShowLoadingBar);	


	self.ProgressBar.value = 0;	
	UIUtils.ClearText(self.ProgressValueLabel);

	self.ProgressValueList = Queue:New();
	self.FormType = UIFormType.Hint;
	self.UIRegion = UIFormRegion.TopRegion;

	-- Vietnam needs to display reminder nodes, mainly reminder and 18+ processing
	local _otherPanelGo = UIUtils.FindGo(_myTrans,"OtherPanel");
	if _otherPanelGo then
		_otherPanelGo:SetActive(FLanguage.EnabledSelectLans():ContainsKey(FLanguage.VIE));
	end
end

-- Displays the previous operation and provides it to the CS side to call.
function UILoadingForm:OnShowBefore()	
	local _ltex = GameCenter.LoadingTextureManager:GetLoadingTexture();
	self.BGSutureTexture:SetTexture(_ltex.Left, _ltex.Right);
	self.ProgressBar.value = 0;
	UIUtils.ClearText(self.ProgressValueLabel);
	self.CurrentProgressValue = 0;	
	self.ProgressValueList:Clear();
	CS.UnityEngine.Application.backgroundLoadingPriority = CS.UnityEngine.ThreadPriority.High;
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp.ShowFightPower = false
        _lp.ShowPropChange = false
    end
end

-- The displayed operation is provided to the CS side to call.
function UILoadingForm:OnShowAfter()	
	self.CurrentProgressValue = 0;
	self.AnimProgressValue = 0;
	math.randomseed(os.time());
	self.TipsElapseTime = 0;
	self:RandomRefreshTips();
	-- Debug.Log("GameCenter.LoginSystem.MapLogic.CurrentState :" ..  tostring(GameCenter.LoginSystem.MapLogic.CurrentState));

	if GameCenter.LoginSystem.MapLogic.CurrentState ~= LoginMapStateCode.CreatePlayerOK
	 and GameCenter.LoginSystem.MapLogic.CurrentState ~= LoginMapStateCode.WaitCreateRoleLeavelEffect
	 then
		GameCenter.LoginSystem.MapLogic.NeedCallLoadShow = false;
		GameCenter.LoadingSystem:SetShowing(true);	
	 else
		GameCenter.LoginSystem.MapLogic.NeedCallLoadShow = true;
	end
end


-- The hidden operation is provided to the CS side to call.
function UILoadingForm:OnHideAfter()	
	GameCenter.LoadingSystem:SetShowing(false);
	GameCenter.LoadingTextureManager:RefreshNewTexture();
	CS.UnityEngine.Application.backgroundLoadingPriority = CS.UnityEngine.ThreadPriority.Low;
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp.ShowFightPower = true
        _lp.ShowPropChange = true
    end
end

function UILoadingForm:OnTryHide()
	return false
end

-- Update processing
function UILoadingForm:Update(dt)
	if self.AnimProgressValue < 1.0 then
		if (self.ProgressValueList:Count() > 0) then		
			self.CurrentProgressValue = self.ProgressValueList:Peek();
			if (self.AnimProgressValue < self.CurrentProgressValue) then			
				self.AnimProgressValue = self.AnimProgressValue + 0.05;
				UIUtils.SetTextFormat(self.ProgressValueLabel,"{0}%",self.AnimProgressValue * 100);
				self.ProgressBar.value = self.AnimProgressValue;			
			else			
				self.AnimProgressValue = self.CurrentProgressValue;
				self.ProgressValueList:Dequeue();
			end
		end
		if self.AnimProgressValue >= 1.0 then
			self.CurrentProgressValue = 0;
			self.ProgressValueList:Clear();
		end
	end	
	self.TipsElapseTime = self.TipsElapseTime + dt;
	if self.TipsElapseTime >= 3 then
		self.TipsElapseTime = 0;
		self:RandomRefreshTips();
	end
end

function UILoadingForm:OnProgressChange(obj,sender)
	self.ProgressValueList:Enqueue(obj);	
end

function UILoadingForm:OnProgressTextChange(obj,sender)	
	UIUtils.SetTextByString(self.ProgressValueLabel,obj);
end

function UILoadingForm:OnTipsChange(obj,sender)	
	UIUtils.SetTextByString(self.TipsLabel,obj);
end

function UILoadingForm:RandomRefreshTips()	
	-- Set up random prompts
	local _itemCount = DataConfig.DataTips.Count;
	if _itemCount > 0 then 
		local _random = math.random(1, _itemCount);
		local _cfgData = DataConfig.DataTips[_random];
		if _cfgData then						
			UIUtils.SetTextByString(self.TipsLabel,_cfgData.Tips);
		end
	end	
end



return UILoadingForm;