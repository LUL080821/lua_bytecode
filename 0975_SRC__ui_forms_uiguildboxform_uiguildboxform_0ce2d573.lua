
--==============================--
-- author:
-- Date: 2021-07-13 14:19:37
-- File: UIGuildBoxForm.lua
-- Module: UIGuildBoxForm
-- Description: Immortal Alliance Treasure Box Interface
--==============================--
local L_UIListMenu = require ("UI.Components.UIListMenu.UIListMenu")
local UIGuildBoxForm = {
}
local L_BoxItem = {
	CanUpdate = false,
	RemainTime = 0,
}
local L_LogItem = {}
-- Register event functions and provide them to the CS side to call.
function UIGuildBoxForm:OnRegisterEvents()
	self:RegisterEvent(UILuaEventDefine.UIGuildBoxForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UIGuildBoxForm_CLOSE, self.OnClose)
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILDBOXLIST_UPDATE, self.UpdateBoxList)
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILDBOXLOG_UPDATE, self.UpdateBoxLog)
end

-- The first display function is provided to the CS side to call.
function UIGuildBoxForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
    self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
end
-- Find all components
function UIGuildBoxForm:FindAllComponents()
	local _myTrans = self.Trans;
    self.ListMenu = L_UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenu"))
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.ListMenu.IsHideIconByFunc = true
	self.ListMenu:RemoveAll()
    self.ListMenu:AddIcon(GuildSubEnum.Box_Normal, nil, FunctionStartIdCode.GuildTabBoxNomal)
    self.ListMenu:AddIcon(GuildSubEnum.Box_Special, nil, FunctionStartIdCode.GuildTabBoxSpecial)
	-- self.LogLabel = UIUtils.FindLabel(_myTrans, "LogScroll/Label")
	self.LogScroll = UIUtils.FindScrollView(_myTrans, "LogScroll")
	self.BoxScroll = UIUtils.FindScrollView(_myTrans, "BoxScroll")
	local _gridTrans = UIUtils.FindTrans(_myTrans, "BoxScroll/Grid")
	if _gridTrans then
		self.BoxItemList = List:New()
		self.BoxGrid = UIUtils.FindGrid(_gridTrans)
		for i = 0, _gridTrans.childCount - 1 do
			self.BoxItem = L_BoxItem:New(_gridTrans:GetChild(i))
			self.BoxItemList:Add(self.BoxItem)
		end
	end
	_gridTrans = UIUtils.FindTrans(_myTrans, "LogScroll/Table")
	if _gridTrans then
		self.LogItemList = List:New()
		self.LogTable = UIUtils.FindTable(_gridTrans)
		for i = 0, _gridTrans.childCount - 1 do
			self.LogItem = L_LogItem:New(_gridTrans:GetChild(i))
			self.LogItemList:Add(self.LogItem)
		end
	end
	local _btn = UIUtils.FindBtn(_myTrans, "OneKeyBtn")
	UIUtils.AddBtnEvent(_btn, self.OnAutoGetBtnClick, self)
	_btn = UIUtils.FindBtn(_myTrans, "HelpBtn")
	UIUtils.AddBtnEvent(_btn, self.OnHelpBtnClick, self)
	self.AutoGetRedGo = UIUtils.FindGo(_myTrans, "OneKeyBtn/RedPoint")
	local _trans = UIUtils.FindTrans(_myTrans, "UIListMenu/Table")
	local _trans1 = _trans:GetChild(0)
	local _trans2 = _trans:GetChild(_trans.childCount - 1)
	self.Tex_0_1 = UIUtils.FindTex(_trans1)
	self.Tex_0_2 = UIUtils.FindTex(_trans1, "Select")
	self.Tex_1_1 = UIUtils.FindTex(_trans2)
	self.Tex_1_2 = UIUtils.FindTex(_trans2, "Select")
	self.NoBoxGo = UIUtils.FindGo(_myTrans, "NoBox")
	self.NoLogGo = UIUtils.FindGo(_myTrans, "NoLog")
end

-- Callback function that binds UI components
function UIGuildBoxForm:RegUICallback()
end

-- The displayed operation is provided to the CS side to call.
function UIGuildBoxForm:OnShowAfter()
	self.ListMenu:SetSelectById(GuildSubEnum.Box_Normal)
    self.CSForm:LoadTexture(self.Tex_0_1, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_307"))
    self.CSForm:LoadTexture(self.Tex_0_2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_307_1"))
    self.CSForm:LoadTexture(self.Tex_1_1, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_308"))
    self.CSForm:LoadTexture(self.Tex_1_2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_308_1"))
end

-- Hide previous operations and provide them to the CS side to call.
function UIGuildBoxForm:OnHideBefore()
end

function UIGuildBoxForm:UpdateBoxList(obj, sender)
	local _list = GameCenter.GuildSystem.BoxDataList
	local _index = 1
	for i = 1, #_list do
		if _list[i].Cfg and _list[i].Cfg.Type == self.CurBoxId then
			local _item = nil
			if _index > #self.BoxItemList then
				_item = self.BoxItem:Clone()
				self.BoxItemList:Add(_item)
			else
				_item = self.BoxItemList[_index]
			end
			if _item then
				_item:SetInfo(_list[i], _index)
				_item.Go:SetActive(true)
				_index = _index + 1
			end
		end
	end
	for i = _index, #self.BoxItemList do
		self.BoxItemList[i].Go:SetActive(false)
	end
	self.NoBoxGo:SetActive(_index == 1)
	self.BoxGrid.repositionNow = true
	if self.CurBoxId == GuildSubEnum.Box_Normal then
		self.AutoGetRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabBoxNomal))
	else
		self.AutoGetRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabBoxSpecial))
	end
end

function UIGuildBoxForm:UpdateBoxLog(obj, sender)
	local _list = GameCenter.GuildSystem.BoxLogList
	local _index = 1
	for i = 1, #_list do
		if _list[i].Cfg and _list[i].Cfg.Type == self.CurBoxId then
			local _item = nil
			if _index > #self.LogItemList then
				_item = self.LogItem:Clone()
				self.LogItemList:Add(_item)
			else
				_item = self.LogItemList[_index]
			end
			if _item then
				_item:SetInfo(_list[i])
				_item.Go:SetActive(true)
				_index = _index + 1
			end
		end
	end
	for i = _index, #self.LogItemList do
		self.LogItemList[i].Go:SetActive(false)
	end
	self.NoLogGo:SetActive(_index == 1)
	self.UpdateWait = 3
end

function UIGuildBoxForm:Update(dt)
	for i = 1, #self.BoxItemList do
		if self.BoxItemList[i].CanUpdate then
			self.BoxItemList[i]:SetRemianTimeLabel(dt)
		end
	end
	if self.UpdateWait and self.UpdateWait > 0 then
		self.UpdateWait = self.UpdateWait - 1
		if self.UpdateWait == 0 then
			self.LogTable.repositionNow = true
		end
	end
end

-- [Interface button callback begin]--
function UIGuildBoxForm:OnClickCallBack(id, select)
    if select then
		self.CurBoxId = id
		self:UpdateBoxList()
		self:UpdateBoxLog()
		self.BoxScroll.repositionWaitFrameCount = 3
		self.LogScroll:ResetPosition()
    else
        if id == GuildSubEnum.Box_Normal then
		elseif id == GuildSubEnum.Box_Special then
        end
    end
end

function UIGuildBoxForm:OnAutoGetBtnClick()
	local _find = false
	for i = 1, #self.BoxItemList do
		if self.BoxItemList[i].Go.activeSelf and self.BoxItemList[i].Info and self.BoxItemList[i].Info.reward == nil then
			self.BoxItemList[i]:OnSendBtnClick()
			_find = true
		end
	end
	if not _find then
		Utils.ShowPromptByEnum("C_GUILDBOX_GET_ERR")
	end
end

function UIGuildBoxForm:OnHelpBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, FunctionStartIdCode.GuildFuncTypeBox);
end
-- -[Interface button callback end]---

-- [Subclass, attribute list begin]--
function L_BoxItem:New(trans)
	local _m = Utils.DeepCopy(self)
    _m.Trans = trans
	_m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

function L_BoxItem:FindAllComponents()
	self.NameLabel      = UIUtils.FindLabel(self.Trans, "NameLabel")
	self.SenderLabel    = UIUtils.FindLabel(self.Trans, "SenderLabel")
	self.TimeLabel      = UIUtils.FindLabel(self.Trans, "TimeLabel")
    self.Item           = UILuaItem:New(UIUtils.FindTrans(self.Trans, "Item"))
	self.GetBtnGo       = UIUtils.FindGo(self.Trans, "Btn")
	self.GetOverGo      = UIUtils.FindGo(self.Trans, "GetOver")
	local _btn = UIUtils.FindBtn(self.Trans, "Btn")
	UIUtils.AddBtnEvent(_btn, self.OnSendBtnClick, self)
end

function L_BoxItem:Clone()
	return L_BoxItem:New(UnityUtils.Clone(self.Go).transform)
end

function L_BoxItem:OnSendBtnClick()
	if self.Info then
		local _msg = ReqMsg.MSG_Guild.ReqGuildGiftOpen:New()
		_msg.id = self.Info.id
		_msg:Send()
	end
end

-- Set interface content
function L_BoxItem:SetInfo(info, index)
	self.Info = info
	if info then
		local _cfg = info.Cfg
		if _cfg then
			UIUtils.SetTextByStringDefinesID(self.NameLabel, _cfg._Name)
			if info.reward then
				self.Trans.name = string.format( "%03d", index + 500)
				self.Item:InItWithCfgid(info.reward[1].modelId, info.reward[1].count)
			else
				self.Trans.name = string.format( "%03d", index)
				self.Item:InItWithCfgid(_cfg.ShowItem, 0)
			end
		end
		self.GetBtnGo:SetActive(info.reward == nil)
		self.GetOverGo:SetActive(info.reward ~= nil)
		UIUtils.SetTextByString(self.SenderLabel, info.sender)
		self.RemainTime = self.Info.RemainTime
		self:SetRemianTimeLabel()
		
	end
end

function L_BoxItem:SetRemianTimeLabel(dt)
	if dt then
		self.RemainTime = self.RemainTime - dt
	end
	local _num = math.floor(self.RemainTime)
	if _num ~= self.ShowTimeNum then
		self.ShowTimeNum = _num
		if _num > 0 then
			local d, h, m, s = Time.SplitTime(math.floor( _num ))
            UIUtils.SetTextByEnum(self.TimeLabel, "C_GUILDBOX_TIME", h, m, s)
		else
            UIUtils.SetTextByEnum(self.TimeLabel, "C_GUILDBOX_TIMEOVER")
		end
	end
	self.CanUpdate = self.RemainTime > 0
end
-- -[Subclass, attribute list end]---


-- [Subclass, attribute list begin]--
function L_LogItem:New(trans)
	local _m = Utils.DeepCopy(self)
    _m.Trans = trans
	_m.Go = trans.gameObject
    _m.DescLabel = UIUtils.FindLabel(trans, "Label")
    return _m
end

function L_LogItem:Clone()
	return L_LogItem:New(UnityUtils.Clone(self.Go).transform)
end

-- Set interface content
function L_LogItem:SetInfo(info)
	self.Info = info
	if info then
		local _cfg = info.Cfg
		if _cfg then
			local _time = Time.StampToDateTime(math.floor(info.time / 1000), "yyyy/MM/dd HH:mm:ss ")
			local name=_cfg.Name
			-- .." "{2}\n{0}Get {1}..."
			UIUtils.SetTextByEnum(self.DescLabel,"C_GUILDBOX_LOGDESC",info.sender .." ", " ".. name, _time)

		end

	end
end
-- -[Subclass, attribute list end]---
return UIGuildBoxForm;