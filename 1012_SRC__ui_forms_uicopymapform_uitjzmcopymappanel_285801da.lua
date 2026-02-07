------------------------------------------------
-- author:
-- Date: 2020-02-10
-- File: UITJZMCopyMapPanel.lua
-- Module: UITJZMCopyMapPanel
-- Description: The Gate of Heavenly Replica Interface
------------------------------------------------

local L_UICopyMapLevelSelect = require "UI.Forms.UICopyMapForm.UICopyMapLevelSelect"

-- //Module definition
local UITJZMCopyMapPanel = {
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
    -- Number of merges
    MergeCountBtn = nil,
    -- Merge requires a level
    MegreNeedLevel = nil,
    -- Current merge times
    MergeCount = nil,
    -- Merge selected nodes
    MegreSelectGo = nil,
    -- Red dots for purchases
    BuyRedPoint = nil,
    -- Enter the red dot
    EnterRedPoint = nil,

    -- Current number of copies
    CurCopyData = nil,
    -- Need item id
    NeddItemId = 0,
    -- Merge required player levels
    MegreNeedLevelValue = 0,

    SeleclPanel = nil,
    SelectLevel = 0,
}

function UITJZMCopyMapPanel:OnFirstShow(trans, parent, rootForm)
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
    self.BuyRedPoint = UIUtils.FindGo(self.Trans, "Down/RemainCount/AddBtn/RedPoint");
    self.EnterRedPoint = UIUtils.FindGo(self.Trans, "Down/EnterBtn/RedPoint");

    self.MergeCountBtn = UIUtils.FindBtn(self.Trans, "Down/MergeCount");
    -- UIUtils.AddBtnEvent(self.MergeCountBtn, self.MergeCountBtnClick, self);
    self.MergeCountBtn.gameObject:SetActive(false);
    self.MegreNeedLevel = UIUtils.FindLabel(self.Trans, "Down/MergeCount/NeedLevel");
    self.MergeCount = UIUtils.FindLabel(self.Trans, "Down/MergeCount/Count");
    self.MegreSelectGo = UIUtils.FindGo(self.Trans, "Down/MergeCount/Select");
    self.MegreNeedLevelValue = DataConfig.DataDaily[6].SweepLevel
    local _gCfg = DataConfig.DataGlobal[GlobalName.Wweep_Need_Item]
    if _gCfg ~= nil then
        self.NeddItemId = tonumber(_gCfg.Params)
    end
    self.SeleclPanel = L_UICopyMapLevelSelect:OnFirstShow(UIUtils.FindTrans(trans, "ScrollView"), self, rootForm)
    return self;
end

function UITJZMCopyMapPanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation();
    self.CurCopyData = GameCenter.CopyMapSystem:FindCopyData(GameCenter.CopyMapSystem.TJZMCopyID);
    self:RefreshPage(true);
end

function UITJZMCopyMapPanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false);
end

function UITJZMCopyMapPanel:RefreshDet(cfg)
    if self.CurCopyData == nil then
        return;
    end
    self.SelectLevel = cfg.CloneLevel
    self.BuyRedPoint:SetActive(self.CurCopyData.CanBuyCount > 0);
    self.EnterRedPoint:SetActive((self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) > 0);
    local _awardItems = Utils.SplitStrByTableS(cfg.ShowAward);
    local _awardItemCount = #_awardItems;
    for i = 1, 4 do
        if i <= _awardItemCount then
            self.Items[i].RootGO:SetActive(true);
            self.Items[i]:InItWithCfgid(_awardItems[i][1], _awardItems[i][2], false, false);
        else
            self.Items[i].RootGO:SetActive(false);
        end
    end
    local _allCount = self.CurCopyData.JionCount + self.CurCopyData.FreeCount + self.CurCopyData.VIPCount;
    local _remainCount = _allCount - self.CurCopyData.JionCount
    UIUtils.SetTextByEnum(self.RemainCount, "Progress", _remainCount, _allCount)
    self:RefreshMegreCount()
end

-- Refresh the interface
function UITJZMCopyMapPanel:RefreshPage(rePos)
    if self.CurCopyData == nil then
        return
    end
    self.SeleclPanel:RefreshPanel(self.CurCopyData.CopyID, rePos)
    --self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.CurCopyData.CopyCfg.PictureRes));
    self.RootForm.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_fb_tianjinzhimen"))
end

-- Click the increase number of button
function UITJZMCopyMapPanel:OnAddCountBtnClick()
    if self.CurCopyData == nil then
        return;
    end
    GameCenter.PushFixEvent(UIEventDefine.UICopyMapAddCountForm_OPEN, self.CurCopyData.CopyCfg.Id);
end

-- Enter button click
function UITJZMCopyMapPanel:OnEnterBtnClick()
    if self.CurCopyData == nil then
        return
    end

    if (self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) <= 0 and self.CurCopyData.CanBuyCount > 0 and self.CurCopyData.AutoBuy == false then
        -- If there are no challenges but the number of purchases available, and no automatic purchase is checked, the purchase interface will pop up
        GameCenter.PushFixEvent(UIEventDefine.UICopyMapAddCountForm_OPEN, self.CurCopyData.CopyCfg.Id);
    elseif (self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) <= 0 and self.CurCopyData.CanBuyCount <= 0 then
        -- There are no challenges, no purchases, and the pop-up level is not enough
        Utils.ShowPromptByEnum("CopyCount_Insufficient")
    else
        if self.CurCopyData.CurMergeCount >= 2 then
            local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.NeddItemId)
            if _haveCount < self.CurCopyData.CurMergeCount - 1 then
                -- --Popular item acquisition prompt
                -- Utils.ShowPromptByEnum("C_COPY_HEBING_ENTER_ERROR")
                -- GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.NeddItemId)
                local _needCount = self.CurCopyData.CurMergeCount - 1 - _haveCount
                self.RootForm.BuyItemPanel:Show(self.CurCopyData.CopyID, self.SelectLevel, _needCount, self.NeddItemId)
                return
            end
        end
        GameCenter.CopyMapSystem:ReqEnterCopyMap(self.CurCopyData.CopyID, self.SelectLevel);
        GameCenter.BISystem:ReqClickEvent(BiIdCode.TJZMChallenge);
    end
end

function UITJZMCopyMapPanel:RefreshMegreCount()
    local _allCount = self.CurCopyData.JionCount + self.CurCopyData.FreeCount + self.CurCopyData.VIPCount;
    local _remainCount = _allCount - self.CurCopyData.JionCount
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if _lpLevel < self.MegreNeedLevelValue then
        -- Insufficient level, cannot be merged
        self.MegreNeedLevel.gameObject:SetActive(true)
        self.MergeCount.gameObject:SetActive(false)
        self.MegreSelectGo:SetActive(false)
        UIUtils.SetTextByEnum(self.MegreNeedLevel, "C_COPY_HEBING_LEVEL", self.MegreNeedLevelValue)
    else
        -- Can be merged
        self.MegreNeedLevel.gameObject:SetActive(false)
        self.MergeCount.gameObject:SetActive(true)
        self.MegreSelectGo:SetActive(self.CurCopyData.CurMergeCount > 1)
        if self.CurCopyData.CurMergeCount > 1 then
            UIUtils.SetTextByEnum(self.MergeCount, "C_COPY_HEBING_CISHU", self.CurCopyData.CurMergeCount)
        else
            UIUtils.SetTextByEnum(self.MergeCount, "C_COPY_HEBING_CISHU", _remainCount)
        end
    end
end

-- Number of merges
function UITJZMCopyMapPanel:MergeCountBtnClick()
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if _lpLevel < self.MegreNeedLevelValue then
        Utils.ShowPromptByEnum("C_COPY_HEBING_LEVEL_ERROR")
        return
    end
    if self.CurCopyData.CurMergeCount > 1 then
        -- Uncheck
        GameCenter.CopyMapSystem:ReqSetMegreCount(self.CurCopyData.CopyID, 0)
    else
        -- Open the selection interface
        local _allCount = self.CurCopyData.JionCount + self.CurCopyData.FreeCount + self.CurCopyData.VIPCount;
        local _remainCount = _allCount - self.CurCopyData.JionCount
        if _remainCount < 2 then
            -- Not enough times to merge
            Utils.ShowPromptByEnum("C_COPY_HEBING_COUNT_ERROR")
            return
        end
        self.RootForm.MergePanel:Show(self.CurCopyData.CopyID, _remainCount, _allCount, self.NeddItemId, self.MegreNeedLevelValue)
    end
end

function UITJZMCopyMapPanel:Update(dt)
    self.SeleclPanel:Update(dt)
end

return UITJZMCopyMapPanel;
