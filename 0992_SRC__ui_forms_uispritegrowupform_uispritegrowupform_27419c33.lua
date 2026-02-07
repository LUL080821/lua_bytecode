
--==============================--
--author:
--Date: 2020-07-04 11:05:47
--File: UISpriteGrowUpForm.lua
--Module: UISpriteGrowUpForm
--Description: Sword Spirit Advanced, Upgrade, Basic Information Interface Logic
--==============================--

local WrapMode = CS.UnityEngine.WrapMode
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local L_BasePanel = require("UI.Forms.UISpriteGrowUpForm.UISpriteBasePanel")
local L_TrainPanel = require("UI.Forms.UISpriteGrowUpForm.UISpriteTrainPanel")

local UISpriteGrowUpForm = {
	--Model List
	ModelIconItem = nil,
	ModelIconList = List:New(),
	CurSelctModelID = 0,
	GridNode = nil,
	BaseNode = nil,
	ModelGo = nil,
	NameGo = nil,
	LevelGo = nil,
}
local L_ModelIcon = {}

--Register event function, provided to the CS side to call.
function UISpriteGrowUpForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UISpriteGrowUpForm_OPEN, self.OnOpen)
	self:RegisterEvent(UIEventDefine.UISpriteGrowUpForm_CLOSE, self.OnClose)
	self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_CHANGEMODEL, self.ChangeModel);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_ACTIVE_NEW, self.ActiveStateChange);
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_UPDATE, self.LvUpdate);
end

--The first display function is provided to the CS side to call.
function UISpriteGrowUpForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
    self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, false, false)
end
--Find all components
function UISpriteGrowUpForm:FindAllComponents()
	local _myTrans = self.Trans;
	-- self.ModelTexture = UIUtils.FindTex(_myTrans, "Texture")
	self.LevelLabel = UIUtils.FindLabel(_myTrans, "Level")
	self.NameLabel = UIUtils.FindLabel(_myTrans, "Name")
	self.ModelGrid = UIUtils.FindGrid(_myTrans, "Base/Left/Grid")
	self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_myTrans, "UIRoleSkinCompoent"))
	if self.ModelSkin then
        self.ModelSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player, AnimClipNameDefine.NormalIdle, 1, true)
		self.ModelSkin.EnableDrag = false
	end
	local _trans = self.ModelGrid.transform
	for i = 0, _trans.childCount - 1 do
		self.ModelIconItem = L_ModelIcon:New(_trans:GetChild(i))
		self.ModelIconItem.CallBack = Utils.Handler(self.OnClickModel, self)
		self.ModelIconList:Add(self.ModelIconItem)
	end
	self.IsFightingGo = UIUtils.FindGo(_myTrans, "Showed")
	self.BasePanel = L_BasePanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Base"), self)
	self.TrainPanel = L_TrainPanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Grow"), self)
	local _btn = UIUtils.FindBtn(_myTrans, "ForwordLvBtn")
	self.ForwordBtnGo = UIUtils.FindGo(_myTrans, "ForwordLvBtn")
	UIUtils.AddBtnEvent(_btn, self.OnForwordBtnClick, self)
	_btn = UIUtils.FindBtn(_myTrans, "NextLvBtn")
	self.NextBtnGo = UIUtils.FindGo(_myTrans, "NextLvBtn")
	UIUtils.AddBtnEvent(_btn, self.OnNextBtnClick, self)
    --The Battle Button
    self.ShowBtn = UIUtils.FindBtn(_myTrans, "ShowButton")
    self.ShowBtnGo = UIUtils.FindGo(_myTrans, "ShowButton")
    UIUtils.AddBtnEvent(self.ShowBtn, self.OnShowBtnClick, self)

	self.GridNode = UIUtils.FindGo(_myTrans, "Base/Left/Grid")
end

--Binding UI components callback function
function UISpriteGrowUpForm:RegUICallback()
end

--The operation after display is provided to the CS side to call.
function UISpriteGrowUpForm:OnShowAfter()
end

--Hide previous operations and provide them to the CS side to call.
function UISpriteGrowUpForm:OnHideBefore()
	self.CurSelectModelItem = nil
	if self.ModelSkin then
        self.ModelSkin:ResetSkin()
    end
    -- GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UISpriteGrowUpForm:Update(dt)
	if self.AnimationCount and self.AnimationCount >= 0 then
		self.AnimationCount = self.AnimationCount + dt
		if self.AnimationCount >= 8 then
			self.AnimationCount = 0
			self.ModelSkin:Play("show_idle", AnimationPartType.AllBody, WrapMode.Once, 1)
		end
	end
end

function UISpriteGrowUpForm:SetBaseVisable(b)
	self.GridNode:SetActive(b)
	if self.ModelGo == nil then
		self.ModelGo = self.ModelSkin.TransformInst.gameObject
	end
	if self.NameGo == nil then
		self.NameGo = self.NameLabel.gameObject
	end
	if self.LevelGo == nil then
		self.LevelGo = self.LevelLabel.gameObject
	end
	self.ModelGo:SetActive(b)
	self.NameGo:SetActive(b)
	self.LevelGo:SetActive(b)
	-- self.ModelTexture.gameObject:SetActive(b)
	if not b then
		self.TrainPanel:OnClose()
		self.BasePanel:OnClose()
	end
end

function UISpriteGrowUpForm:OnOpen(obj, sender)
	self.Type = obj[1]
	if self.Type and self.Type <= 0 then
		self.Type = nil
	end
	if obj[2] then
		self.CurSelectRightTable = obj[2]
	else
		self.CurSelectRightTable = FunctionStartIdCode.FlySwordSpriteBase
	end
	if obj[3] then
		self.CurSelectTrainTable = obj[3]
	else
		self.CurSelectTrainTable = FunctionStartIdCode.FlySwordSpriteUpLv
	end
	if self.Type == nil then
		self.Type = GameCenter.FlySowardSystem:GetHaveRedType()
	end
	self.CSForm:Show(sender)
	self:InitForm()
	-- self.CSForm:LoadTexture(self.ModelTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_4_4"))
	self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FlySwordSpriteUpLv))
end

--Function refresh
function UISpriteGrowUpForm:OnFuncUpdated(functioninfo, sender)
	local _funcID = functioninfo.ID
	if FunctionStartIdCode.FlySwordSpriteUpLv == _funcID or FunctionStartIdCode.FlySwordSpriteUpGrade == _funcID then
		self.TrainPanel:SetBtnRed()
	end
end

--Model switching
function UISpriteGrowUpForm:ChangeModel(obj, sender)
	if not self.CurSelectModelItem then
		return
	end
	self:UpdateModel()
end

--Activate Return
function UISpriteGrowUpForm:ActiveStateChange(obj, sender)
	local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(self.Type) then
		local _typeData = _typeDic[self.Type]
		self:UpdateModelIcon(_typeData.IDList)
		if self.CurSelectRightTable == FunctionStartIdCode.FlySwordSpriteBase then
			self.BasePanel:SetAttr(_typeData.IDList)
			self.BasePanel:SetSkill(_typeData.IDList)
		elseif self.CurSelectRightTable == FunctionStartIdCode.FlySwordSpriteTrain then
			self.TrainPanel.CurSelctModelID = self.CurSelctModelID
			self.TrainPanel:UpdateData(self.Type)
		end
	end
end

--Upgrade or upgrade
function UISpriteGrowUpForm:LvUpdate(obj, sender)
	local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(self.Type) then
		local _typeData = _typeDic[self.Type]
		UIUtils.SetTextByEnum(self.LevelLabel, "C_BLOOD_LEVEL", _typeData.Grade, _typeData.Level)
	end
	if self.CurSelectRightTable == FunctionStartIdCode.FlySwordSpriteTrain then
		self.TrainPanel:UpdateData()
	end
end
--Click the battle button to switch the model
function UISpriteGrowUpForm:OnShowBtnClick()
    GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
        type = 3,
        huaxinID = self.CurSelctModelID
    })
end

--[Interface button callback begin]-
--Model ICON display
function UISpriteGrowUpForm:OnClickModel(item)
	if self.CurSelectModelItem then
		self.CurSelectModelItem:OnSelect(false)
	end
	self.CurSelectModelItem = item
	self.CurSelectModelItem:OnSelect(true)
	self:UpdateModel()
end

function UISpriteGrowUpForm:OnForwordBtnClick()
	self.Type = self.Type - 1
	self:UpdateForm()
end

function UISpriteGrowUpForm:OnNextBtnClick()
	self.Type = self.Type + 1
	self:UpdateForm()
end
---[Interface button callback end]---

--Interface initialization
function UISpriteGrowUpForm:InitForm()
	if not self.Type then
		return
	end
	local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(self.Type) then
		local _typeData = _typeDic[self.Type]
		UIUtils.SetTextByEnum(self.LevelLabel, "C_BLOOD_LEVEL", _typeData.Grade, _typeData.Level)
		self:UpdateModelIcon(_typeData.IDList)
	end
	if self.CurSelectRightTable == FunctionStartIdCode.FlySwordSpriteBase then
		self.ForwordBtnGo:SetActive(self.Type > 1 and GameCenter.FlySowardSystem:GetActiveByType(self.Type - 1))
		self.NextBtnGo:SetActive(self.Type < 6 and GameCenter.FlySowardSystem:GetActiveByType(self.Type + 1))
		self.BasePanel:OnOpen(self.Type)
		self.TrainPanel:OnClose()
		self.CSForm:PlayShowAnimation(self.Trans)
	else
		self.ForwordBtnGo:SetActive(self.Type > 1 and GameCenter.FlySowardSystem:GetCanTrianByType(self.Type - 1))
		self.NextBtnGo:SetActive(self.Type < 6 and GameCenter.FlySowardSystem:GetCanTrianByType(self.Type + 1))
		self.BasePanel:OnClose()
		self.TrainPanel:OnOpen(self.Type, self.CurSelectTrainTable, self.CurSelctModelID)
		self.CSForm:PlayShowAnimation(self.Trans)
	end
end

function UISpriteGrowUpForm:UpdateForm()
	self.CurSelectModelItem = nil
	if self.CurSelectRightTable == FunctionStartIdCode.FlySwordSpriteBase then
		self.ForwordBtnGo:SetActive(self.Type > 1 and GameCenter.FlySowardSystem:GetActiveByType(self.Type - 1))
		self.NextBtnGo:SetActive(self.Type < 6 and GameCenter.FlySowardSystem:GetActiveByType(self.Type + 1))
	else
		self.ForwordBtnGo:SetActive(self.Type > 1 and GameCenter.FlySowardSystem:GetCanTrianByType(self.Type - 1))
		self.NextBtnGo:SetActive(self.Type < 6 and GameCenter.FlySowardSystem:GetCanTrianByType(self.Type + 1))
	end
	self:ActiveStateChange()
	local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(self.Type) then
		local _typeData = _typeDic[self.Type]
		UIUtils.SetTextByEnum(self.LevelLabel, "C_BLOOD_LEVEL", _typeData.Grade, _typeData.Level)
	end

end

--Update the model display and model name
function UISpriteGrowUpForm:UpdateModel()
	if not self.CurSelectModelItem then
		return
	end
	local _cfg = self.CurSelectModelItem.ModelData.Cfg
	self.CurSelctModelID = _cfg.Id
	self.ModelSkin:ResetSkin()
	self.ModelSkin:SetEquip(FSkinPartCode.Body, _cfg.Id)
	self.ModelSkin:SetLocalScale(_cfg.CameraSize)
	self.ModelSkin:SetSkinPos(Vector3(_cfg.ModelXPos /_cfg.CameraSize, _cfg.ModelYPos / _cfg.CameraSize, 0))
	UIUtils.SetTextByStringDefinesID(self.NameLabel, _cfg._Name)
	self.IsFightingGo:SetActive(GameCenter.FlySowardSystem.CurUseModel == _cfg.Id)
	self:SetBtnShow(_cfg.Id)
	if self.CurSelectModelItem.Index ~= 1 and self.CurSelectModelItem.Index ~= 2 then
		self.ModelSkin:Play("show_idle", AnimationPartType.AllBody, WrapMode.Once, 1)
		self.AnimationCount = 0
	else
		self.ModelSkin:Play("idle", AnimationPartType.AllBody, WrapMode.Once, 1)
		self.AnimationCount = -1
	end
	if self.BasePanel then
		self.BasePanel:UpdateDesc(_cfg)
	end
end

--Set whether the battle button is displayed
function UISpriteGrowUpForm:SetBtnShow(id)
    self.CurSelctModelID = id
    local isShow = false
    local _dataDic = GameCenter.FlySowardSystem:GetDataDic()
    if _dataDic and _dataDic:ContainsKey(id) then
        if _dataDic[id].IsActive and GameCenter.FlySowardSystem.CurUseModel ~= id then
            isShow = true
        end
    end
    self.ShowBtnGo:SetActive(isShow)
end

--LoadingModel List
function UISpriteGrowUpForm:UpdateModelIcon(modelList)
	if modelList then
		local _index = 1
		local _dataDic = GameCenter.FlySowardSystem:GetDataDic()
		local _canSelect = true
		if self.CurSelectModelItem then
			_canSelect = false
		end
		for i = 1, #modelList do
			if _dataDic and _dataDic:ContainsKey(modelList[i]) then
				local _item = nil
				if #self.ModelIconList >= _index then
					_item = self.ModelIconList[_index]
				else
					_item = self.ModelIconItem:Clone()
					_item.CallBack = Utils.Handler(self.OnClickModel, self)
					self.ModelIconList:Add(_item)
				end
				if _item then
					_item.RootGO:SetActive(true)
					_item:OnSelect(false)
					_item:UpdateData(_dataDic[modelList[i]], i)
					if _canSelect and (_index == 1 or _dataDic[modelList[i]].IsActive) then
						self.CurSelectModelItem = _item
					end
					if GameCenter.FlySowardSystem.CurUseModel == modelList[i] then
						self.CurSelectModelItem = _item
						_canSelect = false
					end
					_index = _index + 1
				end
			end
		end
		for i = _index, #self.ModelIconList do
			self.ModelIconList[i].RootGO:SetActive(false)
		end
		self.ModelGrid:Reposition()
	end
	if self.CurSelectModelItem then
		self:OnClickModel(self.CurSelectModelItem)
	end
end

---[Subclass ModelIcon ModelICon control begin] ---
function L_ModelIcon:New(trans)
	local _M = Utils.DeepCopy(self)
    _M.RootTrans = trans
	_M.RootGO = trans.gameObject
	_M:FindAllComponents()
	return _M
end

function L_ModelIcon:Clone()
	local _trans = UnityUtils.Clone(self.RootGO)
    return L_ModelIcon:New(_trans.transform)
end

function L_ModelIcon:FindAllComponents()
	-- self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.RootTrans, "Icon"))
	-- self.IconSpr = UIUtils.FindSpr(self.RootTrans, "Icon")
	self.DesLabel = UIUtils.FindLabel(self.RootTrans, "Desc")
	self.SelectGo = UIUtils.FindGo(self.RootTrans, "Select")
	self.Btn = UIUtils.FindBtn(self.RootTrans, "Back")
	self.ActiveBtn = UIUtils.FindBtn(self.RootTrans, "ActiveBtn")
	self.ActiveBtnNode = UIUtils.FindGo(self.RootTrans, "ActiveBtn")
	self.BackNode = UIUtils.FindGo(self.RootTrans, "Back")
	UIUtils.AddBtnEvent(self.Btn, self.OnClick, self)
	UIUtils.AddBtnEvent(self.ActiveBtn, self.OnActiveBtnClick, self)
end

function L_ModelIcon:OnClick()
	if self.ModelData.IsActive then
		if self.CallBack then
			self.CallBack(self)
		end
	else
		Utils.ShowPromptByEnum("C_UI_SPRITEHOME_MSG1")
	end
end

function L_ModelIcon:OnActiveBtnClick()
	if self.ModelData then
		GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
			type = 1,
			huaxinID = self.ModelData.Cfg.Id
		})
	end
end

function L_ModelIcon:OnSelect(isShow)
	if self.SelectGo then
		self.SelectGo:SetActive(isShow)
		self.BackNode:SetActive(not isShow)
	end
end

function L_ModelIcon:UpdateData(data, Index)
	self.ModelData = data
	self.Index = Index
	if data then
		-- self.Icon:UpdateIcon(data.Cfg.Icon)
		-- self.IconSpr.IsGray = not data.IsActive
		if data.IsActive then
			self.ActiveBtnNode:SetActive(false)
			self.DesLabel.gameObject:SetActive(true)
			UIUtils.SetTextByEnum(self.DesLabel, "C_UI_SPRITEHOME_ACTIVE")
		else
			local _activeShow = false
			if data.Cfg.Variable and data.Cfg.Variable ~= "" then
				local _ar = Utils.SplitNumber(data.Cfg.Variable, '_')
				if _ar[1] and _ar[2] and _ar[1] == FunctionVariableIdCode.PlayerLevel then
					local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
					if _lp then
						if _lp.Level >= _ar[2] then
							_activeShow = true
						end
					end
				elseif _ar[1] and _ar[2] and _ar[1] == FunctionVariableIdCode.PlayerPower then
					local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
					if _lp then
						if _lp.FightPower >= _ar[2] then
							_activeShow = true
						end
					end
				end
			end
			self.ActiveBtnNode:SetActive(_activeShow)
			if _activeShow then
				self.DesLabel.gameObject:SetActive(false)
			else
				self.DesLabel.gameObject:SetActive(true)
				UIUtils.SetTextByStringDefinesID(self.DesLabel, data.Cfg._ActiveDescribe)
			end
		end
	end
end
---[Subclass ModelIcon ModelICon control end] -----
return UISpriteGrowUpForm;
