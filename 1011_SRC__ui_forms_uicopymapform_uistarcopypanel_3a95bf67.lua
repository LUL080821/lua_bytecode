------------------------------------------------
-- author:
-- Date: 2020-02-10
-- File: UIStarCopyPanel.lua
-- Module: UIStarCopyPanel
-- Description: Da Neng's Relics Copy Interface
------------------------------------------------

-- //Module definition
local UIStarCopyPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,

    -- Background picture
    BackTex = nil,
    -- Reward list
    Items = nil,
    -- Number of remaining times
    RemainCount = nil,
    -- Increase the number of times
    AddCountBtn = nil,
    -- Enter button
    EnterBtn = nil,
    -- Automatic purchase
    AutoBuy = nil,
    -- Number of merges
    MergeCount = nil,
    -- Red dots for purchases
    BuyRedPoint = nil,
    -- Enter the red dot
    EnterRedPoint = nil,

    -- Current number of copies
    CurCopyData = nil,
}

function UIStarCopyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans;
    self.Go = trans.gameObject
    self.Parent = parent;
    self.RootForm = rootForm;

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans);
    -- Add an animation
    self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false);

    self.BackTex = UIUtils.FindTex(self.Trans, "BackTex");
    self.Items = {};
    for i = 1, 4 do
        self.Items[i] = UILuaItem:New(UIUtils.FindTrans(self.Trans, string.format("Center/%d", i)));
    end
    self.RemainCount = UIUtils.FindLabel(self.Trans, "Down/RemainCount/Count");
    self.AddCountBtn = UIUtils.FindBtn(self.Trans, "Down/RemainCount/AddBtn");
    UIUtils.AddBtnEvent(self.AddCountBtn, self.OnAddCountBtnClick, self);
    self.EnterBtn = UIUtils.FindBtn(self.Trans, "Down/EnterBtn");
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterBtnClick, self);
    self.AutoBuy = UIUtils.FindToggle(self.Trans, "Down/AutoBuy");
    UIUtils.AddOnChangeEvent(self.AutoBuy, self.OnAutoBuyChanged, self);
    self.MergeCount = UIUtils.FindToggle(self.Trans, "Down/MergeCount");
    UIUtils.AddOnChangeEvent(self.MergeCount, self.OnMegreChanged, self);
    self.BuyRedPoint = UIUtils.FindGo(self.Trans, "Down/RemainCount/AddBtn/RedPoint");
    self.EnterRedPoint = UIUtils.FindGo(self.Trans, "Down/EnterBtn/RedPoint");
    return self;
end

function UIStarCopyPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation();
    self.CurCopyData = GameCenter.CopyMapSystem:FindCopyData(GameCenter.CopyMapSystem.DNYFCopyID);
    self:RefreshPage();
end

function UIStarCopyPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false);
end

-- Refresh the interface
function UIStarCopyPanel:RefreshPage()
    if self.CurCopyData == nil then
        return;
    end

    self.BuyRedPoint:SetActive(self.CurCopyData.CanBuyCount > 0);
    self.EnterRedPoint:SetActive((self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) > 0);
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.CurCopyData.CopyCfg.PictureRes));
    
    -- Find configurations based on player level
    local _showCfg = nil
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _func = function (key, cfg)
        if _lpLevel >= cfg.MinLv and _lpLevel <= cfg.MaxLv then
            _showCfg = cfg
            return true
        end
    end
    DataConfig.DataCloneDaneng:ForeachCanBreak(_func)

    if _showCfg ~= nil then
        local _awardItems= Utils.SplitStrByTableS(_showCfg.ParticipationAward);
        local _awardItemCount = #_awardItems;
        for i = 1, 4 do
            if i <= _awardItemCount then
                self.Items[i].RootGO:SetActive(true);
                self.Items[i]:InItWithCfgid(_awardItems[i][1], _awardItems[i][2], false, false);
            else
                self.Items[i].RootGO:SetActive(false);
            end
        end
    end

    local _allCount = self.CurCopyData.JionCount + self.CurCopyData.FreeCount + self.CurCopyData.VIPCount;
    UIUtils.SetTextByEnum(self.RemainCount, "Progress", _allCount - self.CurCopyData.JionCount, _allCount)
    self.MergeCount.value = self.CurCopyData.MergeCount;
    self.AutoBuy.value = self.CurCopyData.AutoBuy;

    local _powerId = GameCenter.VipSystem:GetMegrePowerIDByCopyMap(self.CurCopyData.CopyID)
    if GameCenter.VipSystem:IsHavePrivilegeID(_powerId) then
        self.MergeCount.gameObject:SetActive(true)
        self.AutoBuy.gameObject:SetActive(true)
    else
        self.MergeCount.gameObject:SetActive(false)
        self.AutoBuy.gameObject:SetActive(false)
    end
end

-- Increase the number of times Annie clicks
function UIStarCopyPanel:OnAddCountBtnClick()
    if self.CurCopyData == nil then
        return;
    end
    GameCenter.PushFixEvent(UIEventDefine.UICopyMapAddCountForm_OPEN, self.CurCopyData.CopyCfg.Id);
end

-- Enter button click
function UIStarCopyPanel:OnEnterBtnClick()
    if self.CurCopyData == nil then
        return;
    end

    if (self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) <= 0 and self.CurCopyData.CanBuyCount > 0 and self.CurCopyData.AutoBuy == false then
        -- If there are no challenges but the number of purchases available, and no automatic purchase is checked, the purchase interface will pop up
        GameCenter.PushFixEvent(UIEventDefine.UICopyMapAddCountForm_OPEN, self.CurCopyData.CopyCfg.Id);
    elseif (self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) <= 0 and self.CurCopyData.CanBuyCount <= 0 then
        -- There are no challenges, no purchases, and the pop-up level is not enough
        Utils.ShowPromptByEnum("CopyCount_Insufficient")
    else
        GameCenter.CopyMapSystem:ReqEnterCopyMap(self.CurCopyData.CopyID);
    end
end

-- Number of merges
function UIStarCopyPanel:OnMegreChanged()
    -- if self.CurCopyData == nil then
    --     return;
    -- end

    -- if self.CurCopyData.MergeCount ~= self.MergeCount.value then
    --     GameCenter.CopyMapSystem:ReqSetMegreCount(self.CurCopyData.CopyID, self.MergeCount.value);
    -- end
end

-- Automatic purchase
function UIStarCopyPanel:OnAutoBuyChanged()
    -- if self.CurCopyData == nil then
    --     return;
    -- end

    -- if self.CurCopyData.AutoBuy ~= self.AutoBuy.value then
    --     GameCenter.CopyMapSystem:ReqSetAutoBuy(self.CurCopyData.CopyID, self.AutoBuy.value);
    -- end
end

return UIStarCopyPanel;
