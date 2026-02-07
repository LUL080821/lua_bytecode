------------------------------------------------
-- author:
-- Date: 2019-07-11
-- File: UICopyManyPanel.lua
-- Module: UICopyManyPanel
-- Description: Multiplayer copy pagination
------------------------------------------------

local UIListMenu = require "UI.Components.UIListMenu.UIListMenu";
local L_UICopyMapLevelSelect = require "UI.Forms.UICopyMapForm.UICopyMapLevelSelect"

-- //Module definition
local UICopyManyPanel = {
    -- Current transform
    Trans = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- List Menu
    ListMenu = nil,

    -- Background picture
    BackTex = nil,
    -- Reward list
    Items = nil,
    -- Demon copy description
    XinMoCopyDesc = nil,
    -- Description of the Five Elements Copy
    WuXingCopyDesc = nil,
    -- Number of remaining times
    RemainCount = nil,
    -- Increase the number of times
    AddCountBtn = nil,
    -- Enter button
    EnterBtn = nil,
    -- Teaming button
    TeamBtn = nil,
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

    -- Current number of replicas
    CurCopyData = nil,
    -- The currently selected page
    CurSelectID = 0,

    -- Need item id
    NeddItemId = 0,
    -- Merge required player levels
    MegreNeedLevelValue = 0,

    SeleclPanel = nil,
    SelectLevel = 0,
}

function UICopyManyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans;
    self.Parent = parent;
    self.RootForm = rootForm;

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans);
    -- Add an animation
    self.AnimModule:AddAlphaAnimation();
    self.Trans.gameObject:SetActive(false);

    self.ListMenu = UIListMenu:OnFirstShow(self.Parent.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"));
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self));
    self.ListMenu:AddIcon(UIManyCopyPanelEnum.XinMoPanel, DataConfig.DataMessageString.Get("C_COPYNAME_XINMOHUANJING"), FunctionStartIdCode.XinMoCopyMap);
    --self.ListMenu:AddIcon(UIManyCopyPanelEnum.WuXingPanel, DataConfig.DataMessageString.Get("C_COPYNAME_SUOLINGTAI"), FunctionStartIdCode.WuXingCopyMap);

    self.DescTrans = UIUtils.FindTrans(self.Trans, "DescPanel");
    self.AnimModule:AddAlphaScaleAnimation(self.DescTrans, 0, 1, 1.05, 1.05, 1, 1, 0.3, false, false)
    self.BackTex = UIUtils.FindTex(self.Trans, "DescPanel/Center/Back/BackTex");
    self.Items = {};
    for i = 1, 4 do
        self.Items[i] = UILuaItem:New(UIUtils.FindTrans(self.Trans, string.format("DescPanel/Center/%d", i)));
    end
    self.XinMoCopyDesc = UIUtils.FindGo(self.Trans, "DescPanel/Center/XinMoDesc");
    self.WuXingCopyDesc = UIUtils.FindGo(self.Trans, "DescPanel/Center/WuXingDesc");
    self.RemainCount = UIUtils.FindLabel(self.Trans, "DescPanel/Down/RemainCount/Count");
    self.AddCountBtn = UIUtils.FindBtn(self.Trans, "DescPanel/Down/RemainCount/AddBtn");
    UIUtils.AddBtnEvent(self.AddCountBtn, self.OnAddCountBtnClick, self);
    self.EnterBtn = UIUtils.FindBtn(self.Trans, "DescPanel/Down/EnterBtn");
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterBtnClick, self);
    self.TeamBtn = UIUtils.FindBtn(self.Trans, "DescPanel/Down/TeamBtn");
    UIUtils.AddBtnEvent(self.TeamBtn, self.OnTeamBtnClick, self);
    self.BuyRedPoint = UIUtils.FindGo(self.Trans, "DescPanel/Down/RemainCount/AddBtn/RedPoint");
    self.EnterRedPoint = UIUtils.FindGo(self.Trans, "DescPanel/Down/EnterBtn/RedPoint");

    self.MergeCountBtn = UIUtils.FindBtn(self.Trans, "DescPanel/Down/MergeCount");
    -- UIUtils.AddBtnEvent(self.MergeCountBtn, self.MergeCountBtnClick, self);
    self.MergeCountBtn.gameObject:SetActive(false);
    self.MegreNeedLevel = UIUtils.FindLabel(self.Trans, "DescPanel/Down/MergeCount/NeedLevel");
    self.MergeCount = UIUtils.FindLabel(self.Trans, "DescPanel/Down/MergeCount/Count");
    self.MegreSelectGo = UIUtils.FindGo(self.Trans, "DescPanel/Down/MergeCount/Select");
    local _gCfg = DataConfig.DataGlobal[GlobalName.Wweep_Need_Item]
    if _gCfg ~= nil then
        self.NeddItemId = tonumber(_gCfg.Params)
    end

    self.SeleclPanel = L_UICopyMapLevelSelect:OnFirstShow(UIUtils.FindTrans(trans, "DescPanel/ScrollView"), self, rootForm)
    return self;
end

function UICopyManyPanel:Show(childId)
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation();
    if childId ~= nil then
        self.ListMenu:SetSelectById(childId);
    else
        self.ListMenu:SetSelectById(UIManyCopyPanelEnum.XinMoPanel);
    end
end

function UICopyManyPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation();
end

function UICopyManyPanel:OnMenuSelect(id, select)
    if select then
        self.CurSelectID = id;
        if id == UIManyCopyPanelEnum.XinMoPanel then
            self.CurCopyData = GameCenter.CopyMapSystem:FindCopyData(GameCenter.CopyMapSystem.XinMoCopyID);
        elseif id == UIManyCopyPanelEnum.WuXingPanel then
            self.CurCopyData = GameCenter.CopyMapSystem:FindCopyData(GameCenter.CopyMapSystem.WuXingCopyID);
        else
            self.CurCopyData = nil;
        end
        if self.CurCopyData ~= nil then
            --GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(self.CurCopyData.CopyID);
            self:RefreshPaghe(true);
            self.AnimModule:PlayShowAnimation(self.DescTrans)
        end
    end
end

function UICopyManyPanel:RefreshDet(cfg)
    if self.CurCopyData == nil then
        return;
    end
    self.SelectLevel = cfg.CloneLevel
    self.MegreNeedLevelValue = DataConfig.DataDaily[self.CurCopyData.CopyCfg.Dailyid].SweepLevel
    self.BuyRedPoint:SetActive(self.CurCopyData.CanBuyCount > 0);
    self.EnterRedPoint:SetActive((self.CurCopyData.FreeCount + self.CurCopyData.VIPCount) > 0);
    self.XinMoCopyDesc:SetActive(self.CurSelectID == UIManyCopyPanelEnum.XinMoPanel);
    self.WuXingCopyDesc:SetActive(self.CurSelectID == UIManyCopyPanelEnum.WuXingPanel);
    local _awardItems = Utils.SplitStrByTableS(cfg.ShowAward)
    if _awardItems ~= nil then
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
    self:RefreshMegreCount()
end

-- Refresh the interface
function UICopyManyPanel:RefreshPaghe(rePos)
    if self.CurCopyData == nil then
        return;
    end
    self.SeleclPanel:RefreshPanel(self.CurCopyData.CopyID, rePos)
    --self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, self.CurCopyData.CopyCfg.PictureRes));
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_4_2"));
end

-- Increase the number of times Annie clicks
function UICopyManyPanel:OnAddCountBtnClick()
    if self.CurCopyData == nil then
        return;
    end
    GameCenter.PushFixEvent(UIEventDefine.UICopyMapAddCountForm_OPEN, self.CurCopyData.CopyCfg.Id);
end

-- Enter button click
function UICopyManyPanel:OnEnterBtnClick()
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
    end

    if GameCenter.TeamSystem:IsTeamExist() then
        if #GameCenter.TeamSystem.MyTeamInfo.MemberList == 1 then
            if self.CurCopyData.CopyID == 6002 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJTeamSingeChallenge);
            elseif self.CurCopyData.CopyID == 6003 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTTeamSingeChallenge);
            end
        else
            if self.CurCopyData.CopyID == 6002 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJTeamManyChallenge);
            elseif self.CurCopyData.CopyID == 6003 then
                GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTTeamManyChallenge);
            end
        end
    else
        if self.CurCopyData.CopyID == 6002 then
            GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJSingeChallenge);
        elseif self.CurCopyData.CopyID == 6003 then
            GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTSingeChallenge);
        end
    end
end

-- Team Button
function UICopyManyPanel:OnTeamBtnClick()
    if self.CurCopyData == nil then
        return;
    end
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TeamMatch, self.CurCopyData.CopyID);
    -- if self.CurSelectID == UIManyCopyPanelEnum.XinMoPanel then
    --     GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJCreatTeam);
    -- elseif self.CurSelectID == UIManyCopyPanelEnum.WuXingPanel then
    --     GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTCreatTeam);
    -- end
end


function UICopyManyPanel:RefreshMegreCount()
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
function UICopyManyPanel:MergeCountBtnClick()
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

function UICopyManyPanel:Update(dt)
    self.SeleclPanel:Update(dt)
end

return UICopyManyPanel;
