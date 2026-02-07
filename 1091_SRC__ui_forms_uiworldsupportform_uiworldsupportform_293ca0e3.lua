
--==============================--
--author:
--Date: 2019-11-25 10:52:14
--File: UIWorldSupportForm.lua
--Module: UIWorldSupportForm
--File: UIWorldSupportListItem.lua
--==============================--
local L_ListItem = require("UI.Forms.UIWorldSupportForm.UIWorldSupportListItem")
local L_ConfirmPanel = require("UI.Forms.UIWorldSupportForm.UIWorldSupportConfirmPanel")
local UIWorldSupportForm = {
	SupportItem = nil,
	SupportList = List:New(),
	SupportGrid = nil,
	SupportScrollview = nil,
}

--Register event function, provided to the CS side to call.
function UIWorldSupportForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIWorldSupportForm_Open, self.OnOpen)
	self:RegisterEvent(UIEventDefine.UIWorldSupportForm_Close,self.OnClose)
	self:RegisterEvent(LogicLuaEventDefine.EID_EVTNT_WORLDSUPPORT_LISTUPDATE, self.SetFormData)
end

--The first display function is provided to the CS side to call.
function UIWorldSupportForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
    self.CSForm:AddNormalAnimation(0.3)
end

--The operation after display is provided to the CS side to call.
function UIWorldSupportForm:OnShowAfter()
	self.ConfirmPanel:OnClose()
	self:SetFormData()
	GameCenter.WorldSupportSystem:ReqOpenWorldSupportPannel()
    self.CSForm:LoadTexture(self.Texture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_2"))
end

--Hide previous operations and provide them to the CS side to call.
function UIWorldSupportForm:OnHideBefore()
end

--Find all components
function UIWorldSupportForm:FindAllComponents()
	local _myTrans = self.Trans;
	local _gridTrans = UIUtils.FindTrans(_myTrans, "Center/ListScroll/Grid")
	for i = 0, _gridTrans.childCount - 1 do
		self.SupportItem = L_ListItem:New(_gridTrans:GetChild(i))
		self.SupportItem.CallBack = Utils.Handler(self.OnClickSupportList, self)
		self.SupportList:Add(self.SupportItem)
	end
	self.CloseBtn = UIUtils.FindBtn(_myTrans, "CloseBtn")
	self.Texture = UIUtils.FindTex(_myTrans, "BG/BackTex")
	self.SupportGrid = UIUtils.FindGrid(_myTrans, "Center/ListScroll/Grid")
	self.SupportScrollview = UIUtils.FindScrollView(_myTrans, "Center/ListScroll")
	self.CoinIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Center/CoinIcon"))
	self.CangetCoinLabel = UIUtils.FindLabel(_myTrans, "Center/GetCoinLabel")
	self.ConfirmPanel = L_ConfirmPanel:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "Center/SupportComfirmGo"))
	self.CoinIcon:UpdateIcon(LuaItemBase.GetItemIcon(ItemTypeCode.Reputation))
end

--Binding UI components callback function
function UIWorldSupportForm:RegUICallback()
	UIUtils.AddBtnEvent(self.CloseBtn, self.OnClose, self)
end

--Set interface data
function UIWorldSupportForm:SetFormData(obj, sender)
	local _sys = GameCenter.WorldSupportSystem
	local _infoList = _sys.SupportInfoList
	local _item = nil
	for i = 1, #_infoList do
		if i <= #self.SupportList then
			_item = self.SupportList[i]
		else
			_item = self.SupportItem:Clone()
			_item.CallBack = Utils.Handler(self.OnClickSupportList, self)
			self.SupportList:Add(_item)
		end
		if _item then
			_item:UpdateItem(_infoList[i])
			_item.Go:SetActive(true)
		end
	end
	for i = #_infoList + 1, #self.SupportList do
		self.SupportList[i].Go:SetActive(false)
	end
	self.SupportGrid.repositionNow = true
	self.SupportScrollview:ResetPosition()
	if _sys.MaxReputation <= 0 then
		_sys:SetMaxReputation()
	end
	UIUtils.SetTextFormat(self.CangetCoinLabel, "{0}/{1}", _sys.CurReputation, _sys.MaxReputation)
end

--[Interface button callback begin]-
--Click on the list of help
function UIWorldSupportForm:OnClickSupportList(info)
	if info.RoleId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        Utils.ShowPromptByEnum("C_SUPPORT_NOSELF")
	else
		self.ConfirmPanel:OnOpen(info)
	end
end
---[Interface button callback end]---

return UIWorldSupportForm;
