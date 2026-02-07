------------------------------------------------
-- author:
-- Date: 2019-04-28
-- File: UITowerCopyPanel.lua
-- Module: UITowerCopyPanel
-- Description: Pagination of tower climbing copy
------------------------------------------------

-- //Module definition
local UITowerCopyPanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,

    -- Chapter name Label
    NameLabel = nil,
    -- Level Icons
    LevelIcons = nil,
    -- Drop grid
    DropGrid = nil,
    -- Drop items
    DropItems = nil,
    -- Chapter Rewards
    ZJGrid = nil,
    ZJItems = nil,
    -- Enter button
    EnterBtn = nil,
    RedPoint = nil,
    -- Demand Level
    NeedLevelGo = nil,
    NeedLevel = nil,
    -- Need combat power
    NeedPower = nil,
    MyPower = nil,
}

local L_UITowerCopyIcon = nil

function UITowerCopyPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    
    self.AnimModule = UIAnimationModule(self.Trans);
    self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.AnimModule:AddAlphaAnimation()

    self.NameLabel = UIUtils.FindLabel(self.Trans, "Top/Name")
    self.LevelIcons = {}
    for i = 1, 5 do
        self.LevelIcons[i] = L_UITowerCopyIcon:New(UIUtils.FindTrans(self.Trans, "Top/Grid/" .. i), rootForm, i)
    end
    self.DropGrid = UIUtils.FindGrid(self.Trans, "Down/Item0")
    self.DropItems = {}
    for i = 1, 3 do
        self.DropItems[i] = UILuaItem:New(UIUtils.FindTrans(self.Trans, string.format("Down/Item0/%d", i)))
    end
    self.ZJGrid = UIUtils.FindGrid(self.Trans, "Down/Item1")
    self.ZJItems = {}
    for i = 1, 4 do
        self.ZJItems[i] = UILuaItem:New(UIUtils.FindTrans(self.Trans, string.format("Down/Item1/%d", i)))
    end
    self.EnterBtn = UIUtils.FindBtn(self.Trans, "Down/EnterBtn")
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterBtnClick, self)
    self.RedPoint = UIUtils.FindGo(self.Trans, "Down/EnterBtn/RedPoint")
    self.NeedLevelGo = UIUtils.FindGo(self.Trans, "Down/NeedLevel")
    self.NeedLevel = UIUtils.FindLabel(self.Trans, "Down/NeedLevel/Value")
    self.NeedPower = UIUtils.FindLabel(self.Trans, "Down/NeedPower/Value")
    self.MyPower = UIUtils.FindLabel(self.Trans, "Down/MyPower/Value")

    self.Go:SetActive(false)
    return self
end

-- Open
function UITowerCopyPanel:Show()
    self.AnimModule:PlayEnableAnimation()
    self:RefreshPage()
end

-- closure
function UITowerCopyPanel:Hide()
    self.Go:SetActive(false)
end

-- Challenge button click
function UITowerCopyPanel:OnEnterBtnClick()
    local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy)
    if _towerData == nil then
        return
    end

    if _towerData.CurLevel < 1 then
        _towerData.CurLevel = 1
    end
    local _curCfg = DataConfig.DataChallengeReward[_towerData.CurLevel]
    if _curCfg == nil then
        Utils.ShowPromptByEnum("C_COPY_WANYAOJUAN_FINISH")
        return
    end

    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    if _curCfg.NeedLevel > _lpLevel then
        Utils.ShowPromptByEnum("RoleLevelNotMatch")
        return
    end
    
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp.FightPower < _curCfg.NeedFightPower then
        Utils.ShowMsgBox(function(x)
            if x == MsgBoxResultCode.Button2 then
                GameCenter.CopyMapSystem:ReqEnterCopyMap(_towerData.CopyID)
                GameCenter.BISystem:ReqClickEvent(BiIdCode.WYJWeakRechallenge)
            end
        end, "C_COPY_WANYAOJUAN_FIGHT_ASK", _curCfg.NeedFightPower)
    else
        GameCenter.CopyMapSystem:ReqEnterCopyMap(_towerData.CopyID)
        GameCenter.BISystem:ReqClickEvent(BiIdCode.WYJStrongRechallenge)
    end
end

-- Refresh the interface
function UITowerCopyPanel:RefreshPage()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    local _towerData = GameCenter.CopyMapSystem:FindCopyDataByType(CopyMapTypeEnum.TowerCopy)
    if _towerData == nil then
        return
    end
    if _towerData.CurLevel < 1 then
        _towerData.CurLevel = 1
    end
    local _curLevel = _towerData.CurLevel
    local _curCfg = DataConfig.DataChallengeReward[_curLevel]
    if _curCfg == nil then
        -- Full level
        _curCfg = DataConfig.DataChallengeReward[DataConfig.DataChallengeReward.Count]
        _curLevel = _curCfg.Num
    end

    local _powerEnough = false
    UIUtils.SetTextByNumber(self.NeedPower, _curCfg.NeedFightPower)
    UIUtils.SetTextByNumber(self.MyPower, _lp.FightPower)
    if _lp.FightPower < _curCfg.NeedFightPower then
        UIUtils.SetColor(self.NeedPower, 255/255,78/255,0/255,1)--màu khi không đủ lực chiến
    else
        UIUtils.SetColor(self.NeedPower, 255/255,78/255,0/255,1)--màu khi đủ lực chiến
        _powerEnough = true
    end
    
    local _startLevel = (_curLevel - 1) / 5 * 5 + 1
    local _resIndex = 1
    for i = _startLevel, _startLevel + 4 do
        local _cfg = DataConfig.DataChallengeReward[i]
        self.LevelIcons[_resIndex]:Refresh(_cfg, _towerData.CurLevel)
        _resIndex = _resIndex + 1
    end

    local _levelEnough = false
    if _curCfg.NeedLevel > _lp.Level then
        UIUtils.SetTextByString(self.NeedLevel, CommonUtils.GetLevelDesc(_curCfg.NeedLevel))
        self.NeedLevelGo:SetActive(true)
    else
        self.NeedLevelGo:SetActive(false)
        _levelEnough = true
    end
    UIUtils.SetTextByEnum(self.NameLabel, "C_COPY_WANYAOJUAN_LEVEL", _curCfg.Name)
    self.RedPoint:SetActive(_levelEnough and _powerEnough)

    local _curItems = Utils.SplitStrByTableS(_curCfg.NormalReward)
    for i = 1, #self.DropItems do
        if i <= #_curItems then
            self.DropItems[i]:InItWithCfgid(_curItems[i][1], _curItems[i][2], false, false)
            self.DropItems[i].RootGO:SetActive(true)
        else
            self.DropItems[i].RootGO:SetActive(false)
        end
    end
    self.DropGrid:Reposition()

    local _capCfg = _curCfg
    while(string.len(_capCfg.ChapterReward) <= 0) do
        _capCfg = DataConfig.DataChallengeReward[_capCfg.Num + 1]
    end
    if _capCfg ~= nil then
        _curItems = Utils.SplitStrByTableS(_capCfg.ChapterReward)
    else
        _curItems = {}
    end
    for i = 1, #self.ZJItems do
        if i <= #_curItems then
            self.ZJItems[i]:InItWithCfgid(_curItems[i][1], _curItems[i][2], false, false)
            self.ZJItems[i].RootGO:SetActive(true)
        else
            self.ZJItems[i].RootGO:SetActive(false)
        end
    end
    self.ZJGrid:Reposition()
end

-- Level avatar
L_UITowerCopyIcon = {
    -- Root UI
    RootForm = nil,
    -- Resource Pictures
    ResTex = nil,
    -- Is it done
    IsFinishGo = nil,
    -- name
    Name = nil,
    -- index
    Index = 0
}

function L_UITowerCopyIcon:New(trans, rootForm, index)
    local _result = Utils.DeepCopy(self)
    _result.RootForm = rootForm
    _result.Index = index
    _result.ResTex = UIUtils.FindTex(trans, "ResTex")
    _result.IsFinishGo = UIUtils.FindGo(trans, "Finish")
    _result.Name = UIUtils.FindLabel(trans, "Name")
    return _result
end

function L_UITowerCopyIcon:Refresh(levelCfg, curLevel)
    self.IsFinishGo:SetActive((curLevel > levelCfg.Num))
    self.RootForm.CSForm:LoadTexture(self.ResTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format("tex_n_b_fuben_%d", self.Index)))
    UIUtils.SetTextByEnum(self.Name, "C_COPY_WANYAOJUAN_LEVEL", levelCfg.LittleName)
end

return UITowerCopyPanel
