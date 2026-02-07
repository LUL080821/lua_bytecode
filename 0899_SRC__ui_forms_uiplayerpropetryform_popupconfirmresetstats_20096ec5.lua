------------------------------------------------
--author:
--Date: 2025-12-02
--File: PopupConfirmResetStats.lua
--Module: UIPlayerPropetryForm
------------------------------------------------
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local PopupConfirmResetStats = {
    Trans       = nil,
    Go          = nil,
    CSForm      = nil,
    IsVisible   = false,

    ItemIdCfg   = nil,
    NeedItemNum = nil,
}

-- The first display function is provided to the CS side to call.
function PopupConfirmResetStats:OnFirstShow(parent, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m.AnimPlayer = L_UIAnimDelayPlayer:New(_m.CSForm.AnimModule)

    _m:FindAllComponents()
    _m:RegUICallback()
    return _m
end
-- Find all components
function PopupConfirmResetStats:FindAllComponents()
    local _myTrans = self.Trans;
    --self.BlankClose = UIUtils.FindBtn(_myTrans, "Sprite (1)")
    self.BtnClose = UIUtils.FindBtn(_myTrans, "CloseBtn")
    self.TitleLabel = UIUtils.FindLabel(_myTrans, "Title");

    self.LabelRefundTitle = UIUtils.FindLabel(_myTrans, "LabelPoint");
    self.LabelRefundValue = UIUtils.FindLabel(_myTrans, "NumPoint");
    self.LabelFreeCond = UIUtils.FindLabel(_myTrans, "LabelUnder30");
    self.LabelFreeResult = UIUtils.FindLabel(_myTrans, "CostUnder30");
    self.LabelCostCondition = UIUtils.FindLabel(_myTrans, "LabelUp30");
    self.LabelCostItem = UIUtils.FindLabel(_myTrans, "CostUp30");

    self.Item = UILuaItem:New(UIUtils.FindTrans(self.Trans, "Item"))
    self.Texture = UIUtils.FindTex(_myTrans, "Texture")

    self.BtnOk = UIUtils.FindBtn(_myTrans, "OK")
    self.BtnCancel = UIUtils.FindBtn(_myTrans, "Canel")
end

-- Callback function that binds UI components
function PopupConfirmResetStats:RegUICallback()
    UIUtils.AddBtnEvent(self.BtnOk, self.OnClickOkBtn, self)
    UIUtils.AddBtnEvent(self.BtnCancel, self.OnClose, self)
    UIUtils.AddBtnEvent(self.BtnClose, self.OnClose, self)
end

function PopupConfirmResetStats:OnClickCancelBtn()
end
function PopupConfirmResetStats:OnClickOkBtn()
    local _existItemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.ItemIdCfg)
    if _existItemCount >= self.NeedItemNum then
        local statSys = GameCenter.PlayerStatSystem
        local _, diffs = statSys:ResetAll()
        statSys:SendStatToServer(diffs)
    else
        Utils.ShowPromptByEnum("ItemNotEnough")
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.ItemIdCfg)
    end
    self:OnClose()
end

function PopupConfirmResetStats:OnOpen()
    self.Go:SetActive(true)
    self:RefreshUI()
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    self.IsVisible = true
end

function PopupConfirmResetStats:OnClose()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function PopupConfirmResetStats:Update(dt)
    if not self.IsVisible then
        return
    end
    self.AnimPlayer:Update(dt)
end

function PopupConfirmResetStats:RefreshUI()
    local statSys = GameCenter.PlayerStatSystem
    local _, refundPointPreview = statSys:GetResetAllResultPreview()
    local ok, condition = statSys:GetResetAllCondition()
    if ok then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp == nil then return end

        self.ItemIdCfg = condition.itemId
        self.NeedItemNum = _lp.Level >= condition.minLevel and condition.quantity or 0
        UIUtils.SetTextByString(self.LabelRefundValue, refundPointPreview.availableAfterReset)
        UIUtils.SetTextByEnum(self.LabelFreeCond, 'RESET_POINT_LEVEL_NOTICE', condition.minLevel)
        
        self.Item:InItWithCfgid(self.ItemIdCfg, self.NeedItemNum, false, true)
        self.Item:BindBagNum(self.NeedItemNum == 0)
        UIUtils.SetTextByEnum(self.LabelCostCondition, 'RESET_POINT_COST_NOTICE', condition.minLevel)
        UIUtils.SetTextByString(self.LabelCostItem, self.Item.ShowItemData.Name)

        --local _existItemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(condition.ItemID)
        --if _existItemCount >= needItem then
        --    UIUtils.SetBtnState(self.BtnOk.transform, true)
        --    --self.Item:OnSetNum(UIUtils.CSFormat("[00ff00]{0}/{1}[-]", _existItemCount, needItem))
        --else
        --    UIUtils.SetBtnState(self.BtnOk.transform, false)
        --    --self.Item:OnSetNum(UIUtils.CSFormat("[ff0000]{0}[-]/{1}", _existItemCount, needItem))
        --end
    end
end

return PopupConfirmResetStats;