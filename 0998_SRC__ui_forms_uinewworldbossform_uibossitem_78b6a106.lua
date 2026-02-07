------------------------------------------------
--==============================--
--author:
--Date: 2020-12-26 06:19:18
--File: UIBossItem.lua
--Module: UIBossItem
--Description: Boss information bar on the left side of the boss interface
--==============================--

local UIBossItem = {
    --The owner object of the current Item
    Owner = nil,
    --The GameObject associated with the current Item
    GO = nil,
    --Transform associated with the current Item
    Trans = nil,
    --The current Item uses a data object.
    Data = nil,
    --Subject number
    Stage = nil,
    --Boss name
    Name = nil,
    --Selected background bar
    SelectedGo = nil,
    --Level [Not used yet]
    --Level = nil,
    --Refresh countdown
    Time = nil,
    --avatar
    HeadIcon = nil,
    --Are you concerned
    LockGo = nil,
    --Click event
    SingleClick = nil,
    SelfBtn = nil,
    BossInfo = nil,
    CurSelectLayer = nil,
    ArtDemo = nil,
}

--New function
function UIBossItem:New(trans, owner)
    local _m = Utils.DeepCopy(self);
    _m.Owner = owner;
    _m.GO = trans.gameObject;
    _m.Trans = trans;
    --_m.ArtDemo = UIUtils.FindTex(trans,"ArtDemo")
    _m:FindAllComponent();
    return _m;
end

function UIBossItem:FindAllComponent()
    self.Stage = UIUtils.FindLabel(self.Trans, "Stage")
    self.Name = UIUtils.FindLabel(self.Trans, "Name")
    --self.Level = UIUtils.FindLabel(self.Trans, "Level")
    self.Time = UIUtils.FindLabel(self.Trans, "Time")
    self.SelectedGo = UIUtils.FindGo(self.Trans, "bg")
    self.HeadIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "HeadIcon"))
    self.LockGo = UIUtils.FindGo(self.Trans, "Lock")
    self.SelectedGo:SetActive(false)
    self.LockGo:SetActive(false)
    self.ArtDemo = UIUtils.FindTex(self.Trans, "ArtDemo")
    self.SelfBtn = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(self.SelfBtn, self.OnSelfClick, self)
end
function UIBossItem:Show()

end
--Set Active
function UIBossItem:SetActive(active)
    self.GO:SetActive(active);
end

--Innovative data
function UIBossItem:RefreshData(data)
    self.Data = data;
    if(self.Data ~= nil) then
        self.Owner.CSForm:LoadTexture(self.ArtDemo, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_art_demo"))
        self.HeadIcon:UpdateIcon(self.Data.BossHeadIcon)
        UIUtils.SetTextByEnum(self.Stage, "NEWWORLDBOSS_STAGE", self.Data.Stage)
        local _bossName = nil
        if self.Data.BossLv < 0 then
            local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayer().Level
            _bossName = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MONSTER_NAME_FORMAT"), _lpLevel,
            self.Data.BossName)
        elseif self.Data.BossLv == 0 then
            local _worldLv = GameCenter.OfflineOnHookSystem.CurWorldLevel
            _bossName = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MONSTER_NAME_FORMAT"), _worldLv,
            self.Data.BossName)
        else
            _bossName = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MONSTER_NAME_FORMAT"),
            self.Data.BossLv, self.Data.BossName)
        end
        UIUtils.SetTextByString(self.Name,  _bossName)
        --UIUtils.SetTextByString(self.Level, self.Data.BossLv)
        self.LockGo:SetActive(self.Data.IsFollow)
        self:SetSelected(false)
    else
        Debug.LogError("UIBossItem RefreshData The data is empty");
    end
end

function UIBossItem:SetUpdateTime(bossInfo, curSelectLayer)
    self.BossInfo = bossInfo
    self.CurSelectLayer = curSelectLayer
    if self.BossInfo ~= nil then
        local _check = self.SelectedGo.activeSelf
        local _refreshTime = GameCenter.BossSystem:GetRefreshTime(self.BossInfo)
        if curSelectLayer > 0 then
            if _refreshTime then
                if _refreshTime <= 0 then
                    UIUtils.SetTextByEnum(self.Time, "NEWWORLDBOSS_ALIVE")
                    if _check then
                        -- Select Green Not Dead
                        UIUtils.SetColorByString(self.Time, "#008561")
                    else
                        -- Not selected Green Not dead
                        UIUtils.SetColorByString(self.Time, "#008561")
                    end
                else
                    local d, h, m, s = Time.SplitTime(math.floor(_refreshTime))
                    UIUtils.SetTextByEnum(self.Time, "HHMMSS", h, m, s)
                    if _check then
                        -- Select Red Dead Countdown
                        UIUtils.SetColorByString(self.Time, "#9A1212")
                    else
                        -- Unchecked Red Dead Countdown
                        UIUtils.SetColorByString(self.Time, "#D23232")
                    end
                end
            end
        else
            if self.BossInfo.IsKilled then
                UIUtils.SetTextByEnum(self.Time, "C_ALREADY_KILL")
                if _check then
                    -- Select Red Dead Countdown
                    UIUtils.SetColorByString(self.Time, "#9A1212")
                else
                    -- Unchecked Red Dead Countdown
                    UIUtils.SetColorByString(self.Time, "#D23232")
                end
            else
                local _cloneCfg = DataConfig.DataCloneMap[self.BossInfo.BossCfg.CloneMap]
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _cloneCfg and _lp then
                    if _lp.Level >= _cloneCfg.MinLv then
                        UIUtils.SetTextByEnum(self.Time, "NEWWORLDBOSS_ALIVE")
                        --UIUtils.SetTextByEnum(self.Time, "C_YIKAIQI")
                        if _check then
                            UIUtils.SetColorByString(self.Time, "#008561")
                        else
                            UIUtils.SetColorByString(self.Time, "#008561")
                        end
                    else
                        UIUtils.SetTextByEnum(self.Time, "C_UI_LINGTI_OPENLV", _cloneCfg.MinLv)
                        if _check then
                            UIUtils.SetColorByString(self.Time, "#008561")
                        else
                            UIUtils.SetColorByString(self.Time, "#D23232")
                        end
                    end
                end
            end
        end
    end
end

-- CUSTOM - renew update time and show level
function UIBossItem:NewSetUpdateTime(bossInfo, curSelectLayer)
    self.BossInfo = bossInfo
    self.CurSelectLayer = curSelectLayer
    if self.BossInfo ~= nil then
        local _check = self.SelectedGo.activeSelf
        local _refreshTime = GameCenter.BossSystem:GetRefreshTime(self.BossInfo)
        if _refreshTime then
            if _refreshTime <= 0 then

                local _cloneCfg = DataConfig.DataCloneMap[self.BossInfo.BossCfg.CloneMap]
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                if _cloneCfg and _lp then
                    if _lp.Level >= _cloneCfg.MinLv then
                        UIUtils.SetTextByEnum(self.Time, "NEWWORLDBOSS_ALIVE")
                        if _check then
                            UIUtils.SetColorByString(self.Time, "#008561")
                        else
                            UIUtils.SetColorByString(self.Time, "#008561")
                        end
                    else
                        UIUtils.SetTextByEnum(self.Time, "C_UI_LINGTI_OPENLV", _cloneCfg.MinLv)
                        UIUtils.SetColorByString(self.Time, "#D23232")
                    end
                end
                
            else
                local d, h, m, s = Time.SplitTime(math.floor(_refreshTime))
                UIUtils.SetTextByEnum(self.Time, "HHMMSS", h, m, s)
                if _check then
                    -- Select Red Dead Countdown
                    UIUtils.SetColorByString(self.Time, "#9A1212")
                else
                    -- Unchecked Red Dead Countdown
                    UIUtils.SetColorByString(self.Time, "#D23232")
                end
            end
        end
    end
end
-- CUSTOM - renew update time and show level

function UIBossItem:SetSelected(isShow)
    self.SelectedGo:SetActive(isShow)
    if isShow then
        UIUtils.SetColorByString(self.Name, "#fffef5")
    else
        UIUtils.SetColorByString(self.Name, "#fffef5")
    end
end

function UIBossItem:SetFollow(isFollow)
    self.LockGo:SetActive(isFollow)
end

function UIBossItem:OnSelfClick()
    if self.SingleClick ~= nil then
        self.SingleClick(self)
    end
end

return UIBossItem;
