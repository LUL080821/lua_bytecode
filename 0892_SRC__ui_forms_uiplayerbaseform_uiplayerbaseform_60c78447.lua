
--==============================--
-- Author: Chen Xihan
-- Date: 2020-10-31 14:58:50
-- File: UIPlayerBaseForm.lua
-- Module: UIPlayerBaseForm
-- Description: Player character base plate interface
--==============================--
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UIPlayerBaseForm = {
	BackGo = nil,
}

-- Register event function, provided to the CS side to call.
function UIPlayerBaseForm:OnRegisterEvents()
	self:RegisterEvent(UILuaEventDefine.UIPlayerBaseForm_OPEN, self.OnOpen);
    self:RegisterEvent(UILuaEventDefine.UIPlayerBaseForm_CLOSE, self.OnClose);
end

-- Load function, provided to the CS side to call.
function UIPlayerBaseForm:OnLoad()
end

function UIPlayerBaseForm:OnOpen(object,sender)
	if object then
		self.selectId = object;
	end
	self.CSForm:OnOpen(object,sender);
	self.ListMenu:SetSelectById(self.selectId or 0)
end

-- The first display function is provided to the CS side to call.
function UIPlayerBaseForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
end
--Player model
function UIPlayerBaseForm:FindAllComponents()
	local _myTrans = self.Trans;
	self.BtnLeave = UIUtils.FindBtn(_myTrans, "BtnClose");
	UIUtils.AddBtnEvent(self.BtnLeave, self.OnClickBtnLeaveCallBack, self);
	self.TxtTitle = UIUtils.FindLabel(_myTrans, "TxtTitle");
	self.TexBg = UIUtils.FindTex(_myTrans, "TexBg");
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "UIMoneyForm"))
	self.MoenyForm:SetMoneyList(3, 12, 2, 1)
	self.BackGo = UIUtils.FindGo(_myTrans, "BgPropetry");


	self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenuRight"))
	self.ListMenu:ClearSelectEvent()
	self.ListMenu:AddIcon(0, DataConfig.DataMessageString.Get("Property"), FunctionStartIdCode.Propetry)
	self.ListMenu:AddIcon(1, nil, FunctionStartIdCode.PlayerJingJie)
	self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
	self.CSForm:AddNormalAnimation()
	self.BackTrans = self.BackGo.transform
    self.CSForm:AddAlphaPosAnimation(self.BackTrans, 0, 1, 50, 0, 0.3, false, false)
end

function UIPlayerBaseForm:OnMenuSelect(id, sender)
    self.Form = id
    if sender then
        self:OpenSubForm(id)
    else
        self:CloseSubForm(id)
    end
end

function UIPlayerBaseForm:OpenSubForm(id)
    if id == 0 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerPropetryForm_OPEN, nil, self.CSForm)
		UIUtils.SetTextByEnum(self.TxtTitle, "Property")
		self.CSForm:PlayShowAnimation(self.BackTrans)
	elseif id == 1 then
		GameCenter.PushFixEvent(UIEventDefine.UIPlayerShiHaiForm_OPEN, nil, self.CSForm)
		UIUtils.SetTextByEnum(self.TxtTitle, "C_SHIHAI_NAME")
		self.BackGo:SetActive(false)
    end
end

function UIPlayerBaseForm:CloseSubForm(id)
    if id == 0 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerPropetryForm_CLOSE, nil, self.CSForm)
	elseif id == 1 then
		GameCenter.PushFixEvent(UIEventDefine.UIPlayerShiHaiForm_CLOSE, nil, self.CSForm)
    end
end

-- The callback function that binds the UI component
function UIPlayerBaseForm:RegUICallback()
end

-- Display the previous operation and provide it to the CS side to call.
function UIPlayerBaseForm:OnShowBefore()
	GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
	self.CSForm:LoadTexture(self.TexBg, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_1"))
end

-- The operation after display is provided to the CS side to call.
function UIPlayerBaseForm:OnShowAfter()
end

-- Hide previous operations and provide them to the CS side to call.
function UIPlayerBaseForm:OnHideBefore()
	GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

-- The hidden operation is provided to the CS side to call.
function UIPlayerBaseForm:OnHideAfter()
end

-- The operation of the uninstall event is provided to the CS side to call.
function UIPlayerBaseForm:OnUnRegisterEvents()
end

-- UnLoad operation, provided to the CS side to call.
function UIPlayerBaseForm:OnUnload()
end

-- The operation of form unloading, provided to the CS side to call.
function UIPlayerBaseForm:OnFormDestroy()
end


-- [Interface button callback begin]-
function UIPlayerBaseForm:OnClickBtnLeaveCallBack()
	self:OnClose()
end

---[Interface button callback end]---

return UIPlayerBaseForm;
