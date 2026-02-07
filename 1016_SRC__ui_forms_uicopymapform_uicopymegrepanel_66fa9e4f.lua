------------------------------------------------
-- author:
-- Date: 2020-12-25
-- File: UICopyMegrePanel.lua
-- Module: UICopyMegrePanel
-- Description: Copy merge settings interface
------------------------------------------------

-- //Module definition
local UICopyMegrePanel = {
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
    Item = nil,
    CloseBtn = nil,
    OkBtn = nil,
    CanelBtn = nil,
    AddBtn = nil,
    DecBtn = nil,
    RemainCount = nil,
    CurCount = nil,
    HelpBtn = nil,

    MaxCountValue = 0,
    RemainCountValue = 0,
    CurCountValue = 0,
    CostItemId = 0,

    HelpTrans = nil,
    LevelText = nil,
    HelpCLose = nil,
}

function UICopyMegrePanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans;
    self.Parent = parent;
    self.RootForm = rootForm;

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans);
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.Trans.gameObject:SetActive(false);

    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    self.Item = UILuaItem:New(UIUtils.FindTrans(trans, "UIItem"))
    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.OkBtn = UIUtils.FindBtn(trans, "OkBtn")
    UIUtils.AddBtnEvent(self.OkBtn, self.OnOkBtnClick, self)
    self.CanelBtn = UIUtils.FindBtn(trans, "NoBtn")
    UIUtils.AddBtnEvent(self.CanelBtn, self.OnCanelBtnClick, self)
    self.AddBtn = UIUtils.FindBtn(trans, "AddBtn")
    UIUtils.AddBtnEvent(self.AddBtn, self.OnAddCountBtnClick, self)
    self.DecBtn = UIUtils.FindBtn(trans, "DecBtn")
    UIUtils.AddBtnEvent(self.DecBtn, self.OnDecCountBtnClick, self)
    self.RemainCount = UIUtils.FindLabel(trans, "RemainCount")
    self.CurCount = UIUtils.FindLabel(trans, "CurCount")
    self.HelpBtn = UIUtils.FindBtn(trans, "HelpBtn")
    UIUtils.AddBtnEvent(self.HelpBtn, self.OnHelpBtnClick, self)
    self.HelpTrans = UIUtils.FindTrans(trans, "HelpPanel")
    self.HelpCLose = UIUtils.FindBtn(trans, "HelpPanel/Close")
    UIUtils.AddBtnEvent(self.HelpCLose, self.OnHelpCloseBtnClick, self)
    self.LevelText = UIUtils.FindLabel(trans, "HelpPanel/Level")
    self.AnimModule:AddTransNormalAnimation(self.HelpTrans, 30, 0.3)
    return self;
end

function UICopyMegrePanel:Show(copyId, remainCount, maxCount, itemId, needLevel)
    self.CurCopyID = copyId
    self.MaxCountValue = maxCount
    self.RemainCountValue = remainCount
    self.CurCountValue = remainCount
    self.CostItemId = itemId
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    UIUtils.SetTextByProgress(self.RemainCount, remainCount, maxCount)
    UIUtils.SetTextByNumber(self.CurCount, self.CurCountValue)
    self.Item:InItWithCfgid(self.CostItemId, self.CurCountValue - 1, false, true)
    self.Item:BindBagNum()
    self.HelpTrans.gameObject:SetActive(false)
    UIUtils.SetTextByEnum(self.LevelText, "C_COPY_HEBING_HELP", needLevel)
end

function UICopyMegrePanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation();
end

-- Click the Reduce the Number of Times button
function UICopyMegrePanel:OnDecCountBtnClick()
    if self.CurCountValue <= 2 then
        return
    end
    self.CurCountValue = self.CurCountValue - 1
    UIUtils.SetTextByNumber(self.CurCount, self.CurCountValue)
    self.Item:InItWithCfgid(self.CostItemId, self.CurCountValue - 1, false, true)
    self.Item:BindBagNum()
end

-- Click the increase number of button
function UICopyMegrePanel:OnAddCountBtnClick()
    if self.CurCountValue >= self.MaxCountValue then
        return
    end
    self.CurCountValue = self.CurCountValue + 1
    UIUtils.SetTextByNumber(self.CurCount, self.CurCountValue)
    self.Item:InItWithCfgid(self.CostItemId, self.CurCountValue - 1, false, true)
    self.Item:BindBagNum()
end

-- Click OK button
function UICopyMegrePanel:OnOkBtnClick()
    GameCenter.CopyMapSystem:ReqSetMegreCount(self.CurCopyID, self.CurCountValue)
    self:Hide()
end

-- Click the Cancel button
function UICopyMegrePanel:OnCanelBtnClick()
    self:Hide()
end

-- Click Close button
function UICopyMegrePanel:OnCloseBtnClick()
    self:Hide()
end

-- Click on the Help button
function UICopyMegrePanel:OnHelpBtnClick()
    self.AnimModule:PlayShowAnimation(self.HelpTrans)
end

function UICopyMegrePanel:OnHelpCloseBtnClick()
    self.AnimModule:PlayHideAnimation(self.HelpTrans)
end

return UICopyMegrePanel;
