-- author:
-- Date: 2019-04-26
-- File: UILianQiForm.lua
-- Module: UILianQiForm
-- Description: Refining function main panel
------------------------------------------------

local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"

local UILianQiForm = {
    AnimModule = nil,
    UIListMenu = nil, -- List
    Form       = LianQiSubEnum.Begin, -- Pagination Type
    TabForm    = 1, -- Subpagination type
    CloseBtn   = nil, -- Close button
    BgTexture  = nil,
}

function UILianQiForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiForm_CLOSE, self.OnClose)
end

function UILianQiForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.Form = -1
    if obj then
        if type(obj) == "table" then
            if #obj >= 2 then
                self.Form = obj[1]
                self.TabForm = obj[2]
                self.TabSelectID = obj[3]
            end
        else
            self.Form = obj
        end
    end
    if self.Form == -1 then
        for i = LianQiSubEnum.Begin, LianQiSubEnum.Count do
            local _artFlag = nil
            if i == LianQiSubEnum.UpGrade then
                -- forging
                _artFlag = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiForgeUpgradeLianQiForge)
                if _artFlag then
                    self.Form = LianQiSubEnum.UpGrade
                end
            elseif i == LianQiSubEnum.Forge then
                -- gem
                _artFlag = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiForgeLianQiForgeLianQiGem)
                if _artFlag then
                    self.Form = LianQiSubEnum.Forge
                end
            elseif i == LianQiSubEnum.Gem then
                -- Set
                _artFlag = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiForgeLianQiGem)
                if _artFlag then
                    self.Form = LianQiSubEnum.Gem
                end
            elseif i == LianQiSubEnum.Suit then
                -- Set
                _artFlag = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.EquipSuit)
                if _artFlag then
                    self.Form = LianQiSubEnum.Suit
                end
            end
            if _artFlag then
                self.Form = i
                break
            end
        end
    end
    if self.Form == -1 then
        self.Form = LianQiSubEnum.Begin
    end
    self.UIListMenu:SetSelectById(self.Form)
    -- self.AnimModule:PlayEnableAnimation()
end

function UILianQiForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UILianQiForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
end

function UILianQiForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.CSForm:AddNormalAnimation()
end

function UILianQiForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UILianQiForm:OnShowAfter()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
end

function UILianQiForm:OnClickCloseBtn()
    self:OnClose(nil, nil)
end

function UILianQiForm:FindAllComponents()
    local _myTrans = self.Trans
    self.BgTexture = UIUtils.FindTex(_myTrans, "BgTexture")
    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "UIMoneyForm"));
    self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, _myTrans:Find("UIListMenu"))
    self.UIListMenu:AddIcon(LianQiSubEnum.UpGrade, "Cường Hóa", FunctionStartIdCode.LianQiForgeUpgrade)
    self.UIListMenu:AddIcon(LianQiSubEnum.Forge, DataConfig.DataMessageString.Get("LIANQI_FORGE"), FunctionStartIdCode.LianQiForge)
    self.UIListMenu:AddIcon(LianQiSubEnum.GodEquip, nil, FunctionStartIdCode.GodEquip)
    self.UIListMenu:AddIcon(LianQiSubEnum.Gem, DataConfig.DataMessageString.Get("LIANQI_GEM"), FunctionStartIdCode.LianQiGem)
    self.UIListMenu:AddIcon(LianQiSubEnum.Suit, DataConfig.DataMessageString.Get("C_EQUIP_SUIT"), FunctionStartIdCode.EquipSuit)
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.UIListMenu.IsHideIconByFunc = true
    self.CloseBtn = UIUtils.FindBtn(_myTrans, "CloseBtn")
    -- --Create an animation module
    -- self.AnimModule = UIAnimationModule(_myTrans)
    -- --Add an animation
    -- self.AnimModule:AddAlphaAnimation()
end

function UILianQiForm:OnMenuSelect(id, open)
    self.Form = id
    if open then
        self:OpenSubForm(id)
        self.TabForm = 1
    else
        self:CloseSubForm(id)
    end
end

function UILianQiForm:OpenSubForm(id)
    if id == LianQiSubEnum.Forge then
        -- forging
        self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeForm_OPEN, { self.TabForm, self.TabSelectID }, self.CSForm)
        self.TabSelectID = nil
    elseif id == LianQiSubEnum.Gem then
        -- gem
        self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jineng_t"))
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemForm_OPEN, self.TabForm, self.CSForm)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.GemLianQiEnter);
    elseif id == LianQiSubEnum.Suit then
        -- Set
        self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_jineng_t"))
        GameCenter.PushFixEvent(UIEventDefine.UIEquipSuitForm_Open, self.TabForm, self.CSForm)
    elseif id == LianQiSubEnum.GodEquip then
        self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        -- Divine outfit
        GameCenter.PushFixEvent(UILuaEventDefine.UIGodEquipForm_OPEN, self.TabForm, self.CSForm)
    elseif id == LianQiSubEnum.UpGrade then
        self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
        -- Forge upgrade
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeUpgradeForm_OPEN, { self.TabForm, self.TabSelectID }, self.CSForm)
        self.TabSelectID = nil
    end
end

function UILianQiForm:CloseSubForm(id)
    if id == LianQiSubEnum.Forge then
        -- forging
        GameCenter.PushFixEvent(UIEventDefine.UILianQiForgeForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiSubEnum.Gem then
        -- gem
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemForm_CLOSE, self.TabForm, self.CSForm)
    elseif id == LianQiSubEnum.Suit then
        -- Set
        GameCenter.PushFixEvent(UIEventDefine.UIEquipSuitForm_Close, self.TabForm, self.CSForm)
    elseif id == LianQiSubEnum.GodEquip then
        -- Divine outfit
        GameCenter.PushFixEvent(UILuaEventDefine.UIGodEquipForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiSubEnum.UpGrade then
        -- CH
        GameCenter.PushFixEvent(UILuaEventDefine.UILianQiForgeUpgradeForm_CLOSE, self.TabForm, self.CSForm)
    end
end

return UILianQiForm