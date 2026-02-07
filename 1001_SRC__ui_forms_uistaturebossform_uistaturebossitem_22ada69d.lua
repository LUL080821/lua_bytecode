------------------------------------------------
--author:
--Date: 2019-8-21
--File: UIStatureBossItem.lua
--Module: UIStatureBossItem
--Description: Realm Boss List Add-in
------------------------------------------------
local UIStatureBossItem = {
    Trans = nil,
    Go = nil,
    --boss icon
    Icon = nil,
    --name
    NameLabel = nil,
    --Standard
    LevelLabel = nil,
    --Select the picture
    SelectSprGo = nil,
    --Refresh time
    TimeLabel = nil,
    --button click
    CallBack = nil,
    --data
    BossData = nil,
}

--Create a new object
function UIStatureBossItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

--Find all controls
function UIStatureBossItem:FindAllComponents()
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "HeadIcon"))
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Name")
    self.TimeLabel = UIUtils.FindLabel(self.Trans, "Time")
    self.SelectSprGo = UIUtils.FindGo(self.Trans, "Select")
    self.RedGo = UIUtils.FindGo(self.Trans, "Red")
    local _btn = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(_btn, self.OnBtnClick, self)
end

--Clone an object
function UIStatureBossItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

--button click
function UIStatureBossItem:OnBtnClick()
    if self.CallBack then
        self.CallBack(self)
    end
end

--Set the interface content
function UIStatureBossItem:SetInfo(info)
    self.ItemData = info
    local _bossCfg = self.ItemData.BossCfg
    local _monsterCfg = DataConfig.DataMonster[_bossCfg.Monster]
    if _bossCfg and _monsterCfg then
        UIUtils.SetTextByString(self.NameLabel, Utils.GetMonsterName(_monsterCfg))
        UIUtils.SetColorByString(self.NameLabel,"#fffef5")
        self.Icon:UpdateIcon(_monsterCfg.Icon)
        self.RedGo:SetActive((not self.ItemData.IsFirstGet and self.ItemData.IsFirst)
        or (not self.ItemData.IsFirst and self.ItemData.Type == StatureBossState.Alive))
        self:SetRefreshState()
    end
end

--Set the selected status
function UIStatureBossItem:OnSetSelect(isSelct)
    if self.SelectSprGo then
        self.SelectSprGo:SetActive(isSelct)
    end
    if isSelct then
        UIUtils.SetColorByString(self.NameLabel,"#fffef5")
    else
        UIUtils.SetColorByString(self.NameLabel,"#fffef5")
    end
end

--Set the Boss status
function UIStatureBossItem:SetRefreshState()
    if self.ItemData.Type == StatureBossState.Alive then
        --Chaosable
        UIUtils.SetTextByEnum(self.TimeLabel, "PERSONBOSS_KETIAOZHAN")
    elseif self.ItemData.Type == StatureBossState.WaitOpen then
        --Performance to the previous level to open
        UIUtils.SetTextByEnum(self.TimeLabel, "Stature_Boss_LastFlower")
    else
        local _condition = Utils.SplitNumber(self.ItemData.BossCfg.StateLevel, "_")
        local _lv = CommonUtils.GetLevelDesc(_condition[2])
        --xx level is turned on
        UIUtils.SetTextByEnum(self.TimeLabel, "Stature_Boss_Someone_State_2", _lv)
    end
end

return UIStatureBossItem
