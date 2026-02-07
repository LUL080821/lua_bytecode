------------------------------------------------
-- author:
-- Date: 2021-11-1
-- File: UICopyMapAutoBuyPanel.lua
-- Module: UICopyMapAutoBuyPanel
-- Description: Automatic copy purchase sweeping volume interface
------------------------------------------------

-- //Module definition
local UICopyMapAutoBuyPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- Current copy
    CurCopyID = nil,

    -- Background picture
    BackTex = nil,
    CloseBtn = nil,
    CanelBtn = nil,
    EnterBtn = nil,
    BuyEnterBtn = nil,
    NeedLabel = nil,
    CostLabel = nil,

    NeedCount = nil,
    NeedItemId = nil,
    ShopCfg = nil,
}

function UICopyMapAutoBuyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans;
    self.Parent = parent;
    self.RootForm = rootForm;

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans);
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.Trans.gameObject:SetActive(false);

    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.CanelBtn = UIUtils.FindBtn(trans, "NoBtn")
    UIUtils.AddBtnEvent(self.CanelBtn, self.OnCanelBtnClick, self)
    self.EnterBtn = UIUtils.FindBtn(trans, "EnterBtn")
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterBtnClick, self)
    self.BuyEnterBtn = UIUtils.FindBtn(trans, "BuyBtn")
    UIUtils.AddBtnEvent(self.BuyEnterBtn, self.OnBuyEnterBtnClick, self)
    self.NeedLabel = UIUtils.FindLabel(trans, "Need")
    self.CostLabel = UIUtils.FindLabel(trans, "Cost")
    self.ShopCfg = Utils.SplitNumber(DataConfig.DataGlobal[GlobalName.CopySweepBuyItemCfg].Params, '_')
    self.AnimModule:AddTransNormalAnimation(self.HelpTrans, 30, 0.3)
    self.IsVisible = false
    return self;
end

function UICopyMapAutoBuyPanel:Show(copyId, level, needCount, itemId)
    self.CurCopyID = copyId
    self.CurSelectLevel = level
    self.NeedCount = needCount
    self.NeedItemId = itemId
    if not self.IsVisible then
        -- Play the start-up picture
        self.AnimModule:PlayEnableAnimation()
        self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    end
    self.IsVisible = true
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnBagItemChanged, self)
    self.IsSendBuyMsg = false
    UIUtils.SetTextByEnum(self.NeedLabel, "C_COPYBUYITEM_NEED", needCount)
    UIUtils.SetTextByEnum(self.CostLabel, "C_COPYBUYITEM_COST", self.NeedCount * self.ShopCfg[3])
end

function UICopyMapAutoBuyPanel:Hide()
    if not self.IsVisible then
        return
    end
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnBagItemChanged, self)
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation();
    self.IsVisible = false
end

-- Single entry
function UICopyMapAutoBuyPanel:OnEnterBtnClick()
    -- Cancel the merger first
    GameCenter.CopyMapSystem:ReqSetMegreCount(self.CurCopyID, 0)
    -- Enter the copy again
    GameCenter.CopyMapSystem:ReqEnterCopyMap(self.CurCopyID, self.CurSelectLevel)
    self:Hide()
end

-- Buy and enter
function UICopyMapAutoBuyPanel:OnBuyEnterBtnClick()
    local _costValue = self.NeedCount * self.ShopCfg[3]
    -- Judge price
    local _bindGold = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(2)
    if _bindGold >= _costValue then
        -- Send a purchase message directly
        self.IsSendBuyMsg = true
        GameCenter.Network.Send("MSG_Shop.ReqBuyItem", {sellId = self.ShopCfg[1], num = self.NeedCount})
        return
    end
    local _gold = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(1)
    if _gold >= _costValue then
        -- Send a purchase message directly
        self.IsSendBuyMsg = true
        GameCenter.Network.Send("MSG_Shop.ReqBuyItem", {sellId = self.ShopCfg[2], num = self.NeedCount})
        return
    end
    -- Insufficient currency
    Utils.ShowPromptByEnum("Item_Not_Enough", DataConfig.DataItem[1].Name)
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(1)
end

function UICopyMapAutoBuyPanel:OnBagItemChanged(obj, sender)
    if not self.IsSendBuyMsg then
        return
    end
    local itemBase = obj
    if itemBase ~= nil and itemBase.CfgID == self.NeedItemId then
        local _curCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.NeedItemId)
        if _curCount >= self.NeedCount then
            -- Send an incoming copy message
            GameCenter.CopyMapSystem:ReqEnterCopyMap(self.CurCopyID, self.CurSelectLevel)
            self:Hide()
        end
    end
end

-- Click the Cancel button
function UICopyMapAutoBuyPanel:OnCanelBtnClick()
    self:Hide()
end

-- Click Close button
function UICopyMapAutoBuyPanel:OnCloseBtnClick()
    self:Hide()
end

return UICopyMapAutoBuyPanel
