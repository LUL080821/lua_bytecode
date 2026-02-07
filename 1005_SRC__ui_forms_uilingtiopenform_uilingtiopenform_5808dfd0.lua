
--==============================--
-- author:
-- Date: 2020-05-25 19:24:52
-- File: UILingtiOpenForm.lua
-- Module: UILingtiOpenForm
-- Description: Spiritual Unsealed Form
--==============================--
local FightUtils = require ("Logic.Base.FightUtils.FightUtils")
local TabCmp = require "UI.Forms.UILingtiOpenForm.LingTiOpenTab"
local L_AllAttrPanel = require("UI.Forms.UILingTiForm.AllAttrPanel")
local L_StarVfxCom = require("UI.Components.UIStarVfxComponent")
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UILingtiOpenForm = {
}
local L_LockItem = {}

-- Register event functions and provide them to the CS side to call.
function UILingtiOpenForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UILingtiOpenForm_OPEN,self.OnOpen)
	self:RegisterEvent(UIEventDefine.UILingtiOpenForm_CLOSE,self.OnClose)
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LINGTIFORM_REFREASH,self.OnUpdateForm)
	self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFunctionUpdate)
end

function UILingtiOpenForm:OnFunctionUpdate(obj, sender)
	if obj.ID == FunctionStartIdCode.LingtiFanTai then
		self:SetForm()
	end
end

function UILingtiOpenForm:OnUpdateForm(object, sender)
	local _cfg = DataConfig.DataEquipCollectionStart[GameCenter.LingTiSystem.CurActiveLv]
	local _num = GameCenter.LingTiSystem.CurActiveLv % 100
	if _cfg and _cfg.Needitem and _cfg.Needitem ~= "" and self.UnlockCellList[_num] then
		if self.CurTabId == 1 then
			self.FlyVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 230, LayerUtils.GetAresUILayer())
		else
			self.FlyVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 228, LayerUtils.GetAresUILayer())
		end
		self.TweenPosition.enabled = true
		self.TweenPosition.to = self.UnlockCellList[_num].Trans.localPosition
		self.TweenPosition.duration = 0.6 - _num * 0.06
		self.TweenPosition:ResetToBeginning()
		self.TweenPosition:Play(true)
	else
		self:OnClose()
	end
end

-- The first display function is provided to the CS side to call.
function UILingtiOpenForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
    self.CSForm:AddNormalAnimation()
end
-- Find all components
function UILingtiOpenForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenu"))
    self.UIListMenu.IsHideIconByFunc = true
    self.CloseBtn = UIUtils.FindBtn(_myTrans,"CloseBtn")
    self.BgTexture = UIUtils.FindTex(_myTrans, "BgTexture")
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "UIMoneyForm"));
	self.BgTexture2 = UIUtils.FindTex(_myTrans, "BgTexture2")
	self.AllAttrPanel = L_AllAttrPanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Panel"), self.CSForm)
	self.UnlockFightLabel = UIUtils.FindLabel(_myTrans, "OpenTrans/FightPower/FightPoint")
	self.UnlockLvGo = UIUtils.FindGo(_myTrans, "OpenTrans/Level1")
	self.UnlockActiveCount = UIUtils.FindLabel(_myTrans, "OpenTrans/CurActiveCount")
	self.UnLockNeedItem = UILuaItem:New(UIUtils.FindTrans(_myTrans, "OpenTrans/Item"))
	self.UnlockNeedLv = UIUtils.FindLabel(_myTrans, "OpenTrans/LvCondition")
	self.UnlockBtnLabel = UIUtils.FindLabel(_myTrans, "OpenTrans/ActiveBtn/Label")
	self.UnlockBtnRed = UIUtils.FindGo(_myTrans, "OpenTrans/ActiveBtn/RedPoint")
	self.UnlockBtn = UIUtils.FindBtn(_myTrans, "OpenTrans/ActiveBtn")
	self.AttrBtn = UIUtils.FindBtn(_myTrans, "OpenTrans/AttrBtn")
	self.SkillNameLabel = UIUtils.FindLabel(_myTrans, "OpenTrans/SkillName")
	self.SkillDescLabel = UIUtils.FindLabel(_myTrans, "OpenTrans/SkillDesc")
	self.BookSpr = UIUtils.FindSpr(_myTrans, "OpenTrans/BookSpr")
	self.BookTween = UIUtils.FindTweenPosition(_myTrans, "OpenTrans/BookSpr")
	self.SkillIcon = UIUtils.FindSpr(_myTrans, "OpenTrans/SkillIcon")
	self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(_myTrans:Find("UIVfxSkinCompoent"))
	-- self.FlyVfx = L_StarVfxCom:OnFirstShow(UIUtils.FindTrans(_myTrans, "FlyVfx"))
	local _vfxTrans = UIUtils.FindTrans(_myTrans, "OpenTrans/Level1/FlyVfx")
    if _vfxTrans then
        self.FlyVfx = UIUtils.RequireUIVfxSkinCompoent(_vfxTrans)
        self.TweenPosition = UIUtils.FindTweenPosition(_vfxTrans, "Root")
        self.TweenPosition.enabled = false
        UIUtils.AddEventDelegate(self.TweenPosition.onFinished, self.OnTweenFinished, self)
    end
	self.UnlockCellList = List:New()
	for i = 1, self.UnlockLvGo.transform.childCount do
		local _path = UIUtils.CSFormat("OpenTrans/Level1/{0}", i)
		local _go = L_LockItem:New(UIUtils.FindTrans(_myTrans, _path))
		self.UnlockCellList:Add(_go)
	end
	self.ListTab = List:New()
	local index = GameCenter.LingTiSystem.UnLockDataDic:Count()
	local trans = self.Trans:Find("TableList")
	if index > 0 then
		for i = 1, index do
			local tab = nil
			local _trans = nil
			if i > trans.childCount then
				_trans = UnityUtils.Clone(self.TabTemp.gameObject).transform
			else
				if not self.TabTemp then
					self.TabTemp = trans:GetChild(i - 1)
					_trans = self.TabTemp
				else
					_trans = trans:GetChild(i - 1)
				end
			end
			tab = TabCmp:New(_trans, self)
			self.ListTab:Add(tab)
		end
	end
end

-- Callback function that binds UI components
function UILingtiOpenForm:RegUICallback()
	UIUtils.AddBtnEvent(self.UnlockBtn, self.OnUnlockBtnClick, self)
	UIUtils.AddBtnEvent(self.AttrBtn, self.OnAttrBtnClick, self)
	UIUtils.AddBtnEvent(self.CloseBtn, self.OnClose, self)
end

-- The displayed operation is provided to the CS side to call.
function UILingtiOpenForm:OnShowAfter()
	self.AllAttrPanel:Close()
	self:SetUnlockTabid()
	self:OnClickTab()
    self.UIListMenu:RemoveAll()
	self.UIListMenu:AddIcon(LianQiLingTiSubEnum.Unlock, nil, FunctionStartIdCode.LingtiFanTai)
	self.UIListMenu:SetSelectById(LianQiLingTiSubEnum.Unlock)
	GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
	self.MoenyForm:SetMoneyList(3, 12, 2, 1)
	self.CSForm:LoadTexture(self.BgTexture2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_guji2"))
	self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_guji"))
end

-- Hide previous operations and provide them to the CS side to call.
function UILingtiOpenForm:OnHideBefore()
	for i = 1, #self.UnlockCellList do
		self.UnlockCellList[i].VfxSkin:OnDestory()
	end
	if self.VfxSkin then
		self.VfxSkin:OnDestory()
	end
	if self.FlyVfx then
        self.FlyVfx:OnDestory()
    end
    self.UIListMenu:SetSelectByIndex(-1)
	self.TweenPosition.enabled = false
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UILingtiOpenForm:OnTryHide()
	if self.AllAttrPanel.IsVisible then
		self.AllAttrPanel:Close()
		return false
	end
	return true
end

function UILingtiOpenForm:SetUnlockTabid()
	local listData = GameCenter.LingTiSystem.UnLockDataDic
	local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	listData:ForeachCanBreak(function(k, v)
		if v[#v].IsActive then
			self.CurTabId = k
		end
		if lp.Level >= v[1].Cfg.Level and not v[#v].IsActive then
			self.CurTabId = k
			return true
		end
	end)
end

-- Set tab button data
function UILingtiOpenForm:SetTabCmps()
	local listData = nil
	local index = 1
	listData = GameCenter.LingTiSystem.UnLockDataDic
	listData:Foreach(function(k, v)
		local tab = nil
		local go = nil
		if index > #self.ListTab then
			go = UnityUtils.Clone(self.TabTemp.gameObject)
			tab = TabCmp:New(go.transform, self)
			self.ListTab:Add(tab)
		else
			tab = self.ListTab[index]
		end
		if tab then
			tab:SetCmp(k, v)
		end
		index = index + 1
	end)
end

function UILingtiOpenForm:SetForm(isUp)
	-- Setting up the tab component
	self:SetTabCmps()
	for i = 1,#self.ListTab do
		if self.ListTab[i].Index == self.CurTabId then
			self.ListTab[i]:SetSelect(true)
		else
			self.ListTab[i]:SetSelect(false)
		end
	end

	self.UnlockBtnRed:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LingtiFanTai))
	local listData = GameCenter.LingTiSystem:GetUnlockListByGrade(self.CurTabId)
	if listData then
		local _index = 1
		local _activeCount = 0
		local _needItem = nil
		for i = 1, #listData do
			if _index > #self.UnlockCellList then
				break
			end
			if listData[i].DicAttrData:Count() > 0 then
				local _isSelect = false
				if listData[i].IsActive then
					_activeCount = _activeCount + 1
				elseif not listData[i].IsActive and not _needItem then
					_needItem = Utils.SplitNumber(listData[i].Cfg.Needitem, '_')
					self.UnLockNeedItem:InItWithCfgid(_needItem[1], _needItem[2])
					self.UnLockNeedItem:BindBagNum()
					UIUtils.SetTextByEnum(self.UnlockNeedLv, "C_UI_LINGTI_EXTEM_LV", listData[i].Cfg.Level)
					_isSelect = true
				end
				if _index <= #self.UnlockCellList then
					self.UnlockCellList[_index]:SetCmp(listData[i], _isSelect, self.CurTabId)
				end
				_index = _index + 1
			end
		end
		if not listData[#listData].IsActive and not _needItem then
			_needItem = Utils.SplitNumber(listData[#listData].Cfg.Needitem, '_')
			if _needItem ~= nil and #_needItem > 0 then
				self.UnLockNeedItem:InItWithCfgid(_needItem[1], _needItem[2])
				self.UnLockNeedItem:BindBagNum()
			end
			UIUtils.SetTextByEnum(self.UnlockNeedLv, "C_UI_LINGTI_EXTEM_LV", listData[#listData].Cfg.Level)
		end
		self.UnLockNeedItem:SetActive(_needItem ~= nil and #_needItem > 0)
		self.UnlockNeedLv.gameObject:SetActive( not listData[#listData].IsActive)
		self.UnlockActiveCount.gameObject:SetActive(true)
		UIUtils.SetTextByNumber(self.UnlockFightLabel, FightUtils.GetPropetryPower(GameCenter.LingTiSystem.UnlockAttrDic))
		UIUtils.SetTextByProgress(self.UnlockActiveCount, _activeCount, _index - 1)
		self.UnlockLvGo:SetActive(true)
		local lastCfg = listData[#listData]
		if lastCfg.IsActive then
			UIUtils.SetTextByEnum(self.UnlockBtnLabel, "C_ACTIVEED")
			self.UnlockBtnRed:SetActive(false)
			self.BookSpr.IsGray = false
			self.BookTween.enabled = true
		else
			self.BookSpr.IsGray = true
			self.BookTween.enabled = false
			UIUtils.SetTextByEnum(self.UnlockBtnLabel, "C_UI_LINGTIOPEN_BTN1")
			if _activeCount == _index - 1 then
				UIUtils.SetTextByEnum(self.UnlockBtnLabel, "C_UI_LINGTIOPEN_BTN2")
			end
		end
		if lastCfg.Cfg then
			self.SkillIcon.spriteName = string.format("skill_%d", lastCfg.Cfg.Icon)
			UIUtils.SetTextByStringDefinesID(self.SkillNameLabel, lastCfg.Cfg._Skillname)
			UIUtils.SetTextByStringDefinesID(self.SkillDescLabel, lastCfg.Cfg._Des)
		end
	end
end

function UILingtiOpenForm:Update(dt)
	for i = 1, #self.UnlockCellList do
		self.UnlockCellList[i]:Update(dt)
	end
end

-- [Interface button callback begin]--
-- Flying animation playback is finished
function UILingtiOpenForm:OnTweenFinished()
	if self.FlyVfx then
        self.FlyVfx:OnDestory()
    end
	self.TweenPosition.enabled = false
	self:SetForm()
	self:OnUnlockBtnClick()
end

-- Click the tab button
function UILingtiOpenForm:OnClickTab()
	self:SetForm()
	if self.VfxSkin then
        self.VfxSkin:OnDestory()
    end
	if self.CurTabId == 1 then
		self.BookSpr.spriteName = "lt_book1"
		self.BgTexture.gameObject:SetActive(true)
		self.BgTexture2.gameObject:SetActive(false)
	else
		self.BookSpr.spriteName = "lt_book2"
		self.BgTexture2.gameObject:SetActive(true)
		self.BgTexture.gameObject:SetActive(false)
	end
end
function UILingtiOpenForm:OnAttrBtnClick()
	self.AllAttrPanel:Open(self.CurTabId, FunctionStartIdCode.LingtiFanTai)
end

-- Spiritual Unblocking Button
function UILingtiOpenForm:OnUnlockBtnClick()
	local listData = GameCenter.LingTiSystem:GetUnlockListByGrade(self.CurTabId)
	if listData then
		for i = 1, #listData do
			if not listData[i].IsActive then
				local _lp = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
				if _lp < listData[i].Cfg.Level then
					if i == 1 then
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG1", listData[i].Cfg.Level)
					elseif i == #listData then
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG2", listData[i].Cfg.Level)
					else
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG3", listData[i].Cfg.Level)
					end
					return
				end
				if not self.UnLockNeedItem.IsEnough and self.UnLockNeedItem.RootGO.activeSelf then
					if i == 1 then
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG4")
					elseif i == #listData then
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG5")
					else
						Utils.ShowPromptByEnum("C_UI_LINGTIOPEN_MSG6")
					end
					return
				end
				if i == #listData then
					if self.CurTabId == 1 then
						self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 214, LayerUtils.GetAresUILayer())
					else
						self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 217, LayerUtils.GetAresUILayer())
					end
				end
				GameCenter.LingTiSystem:ReqUpLevel(listData[i].Cfg.Id)
				break
			end
		end
	end
end
-- -[Interface button callback end]---

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function L_LockItem:New(trans)
    if trans == nil then
        return
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.SelectGO = UIUtils.FindGo(trans, "Select")
	_m.ActiveGo = UIUtils.FindGo(trans, "Active")
	_m.ActiveSpr = UIUtils.FindSpr(trans, "Active")
	_m.AttrLabel = UIUtils.FindLabel(trans, "AttrLabel")
	_m.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(trans:Find("UIVfxSkinCompoent"))
    return _m
end

function L_LockItem:Update(dt)
	if self.TimeCount and self.TimeCount > 0 then
		self.TimeCount = self.TimeCount - dt
		if self.TimeCount <= 0 then
			self.TimeCount = 0
			if self.VfxSkin then
				self.VfxSkin:OnDestory()
			end
			if self.Type == 1 then
				self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 212, LayerUtils.GetAresUILayer())
			else
				self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 215, LayerUtils.GetAresUILayer())
			end
		end
	end
end

-- Set up components
function L_LockItem:SetCmp(data, isSelect, selectTab)
	self.ActiveGo:SetActive(data.IsActive)
	self.SelectGO:SetActive(false)
	if self.VfxSkin then
        self.VfxSkin:OnDestory()
	end
	self.TimeCount = 0
	self.Type = selectTab
	if selectTab == 1 then
		-- self.ActiveSpr.spriteName = "zc-guangqiu"
		if data.IsActive and (not isSelect and not self.IsSelectState) then
			self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 212, LayerUtils.GetAresUILayer())
		end
		if data.IsActive and self.IsSelectState and not isSelect then
			self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 213, LayerUtils.GetAresUILayer())
			self.TimeCount = 0.3
		end
	else
		-- self.ActiveSpr.spriteName = "lt_kejihuohuang"
		if data.IsActive and not isSelect and not self.IsSelectState then
			self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 215, LayerUtils.GetAresUILayer())
		end
		if data.IsActive and self.IsSelectState and not isSelect then
			self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 216, LayerUtils.GetAresUILayer())
			self.TimeCount = 0.3
		end
	end
	self.IsSelectState = isSelect
	if isSelect then
		local _descList = List:New();
		data.DicAttrData:Foreach(function(k, v)
			if #_descList > 0 then
				_descList:Add('\n');
			end
			local _str = UIUtils.CSFormat("{0} +{1}", L_BattlePropTools.GetBattlePropName(k), L_BattlePropTools.GetBattleValueText(k, v))
			_descList:Add(_str)
		end)
		UIUtils.SetTextByString(self.AttrLabel,  table.concat(_descList))
	else
		UIUtils.ClearText(self.AttrLabel)
	end
end

function L_LockItem:SetSelect(b)
    self.SelectGO:SetActive(b)
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return UILingtiOpenForm;
