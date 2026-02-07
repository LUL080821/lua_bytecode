------------------------------------------------
--author:
--Date: 2019-11-25
--File: UIWorldSupportListItem.lua
--Set interface data
--Description: World BOSS damage ranking add-in
------------------------------------------------

local UIWorldSupportListItem = {
    Trans = nil,
    Go = nil,
    CallBack = nil,
}

function UIWorldSupportListItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllcompents()
    return _m
end

function UIWorldSupportListItem:Clone()
    return self:New(UnityUtils.Clone(self.Go).transform)
end

function UIWorldSupportListItem:FindAllcompents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Name")
    self.LevelLabel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(self.Trans, "Level"))
    self.PlayerHead = PlayerHead:New(UIUtils.FindTrans(self.Trans, "Head/PlayerHeadLua"))
    self.MapNameLabel = UIUtils.FindLabel(self.Trans, "MapNameLabel")
    self.CountLabel = UIUtils.FindLabel(self.Trans, "CountLabel")
    self.DescLabel = UIUtils.FindLabel(self.Trans, "DescLabel")
    self.Btn = UIUtils.FindBtn(self.Trans, "Btn")
    self.CareerSpr = UIUtils.FindSpr(self.Trans, "Career")
    UIUtils.AddBtnEvent(self.Btn, self.OnClickSupportBtn, self)
end

function UIWorldSupportListItem:OnClickSupportBtn()
    if self.CallBack then
        self.CallBack(self.Info)
    end
end

--Load product specific data
function UIWorldSupportListItem:UpdateItem(info)
    self.Info = info
    if self.Info then
        UIUtils.SetTextByString(self.NameLabel, info.RoleName)
        self.LevelLabel:SetLevel(info.Level, true)
        self.PlayerHead:SetHeadByMsg(info.RoleId, info.Career, info.Head)
        if info.Career == Occupation.XianJian then
            self.CareerSpr.spriteName = "Occupation_11"
        elseif info.Career == Occupation.MoQiang then
            self.CareerSpr.spriteName = "Occupation_13"
        elseif info.Career == Occupation.DiZang then
            self.CareerSpr.spriteName = "Occupation_15"
        elseif info.Career == Occupation.LuoCha then
            self.CareerSpr.spriteName = "Occupation_16"
        end
        if info.CloneMapCfg then
            UIUtils.SetTextByString(self.MapNameLabel, info.CloneMapCfg.TypeName)
        end
        if info.MonsterCfg then
            local _levelNum = info.MonsterCfg.Level
            if _levelNum < 0  then
                _levelNum = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
            elseif _levelNum == 0 then
                _levelNum = GameCenter.OfflineOnHookSystem.CurWorldLevel
            end
            UIUtils.SetTextByEnum(self.DescLabel, "C_SUPPORT_LV", _levelNum, info.MonsterCfg.Name)
            if info.SupportCfg then
                UIUtils.SetTextByEnum(self.CountLabel, "C_SUPPORT_NUM", info.SupportNum, info.SupportCfg.MaxTimes)
            end
        end
        if info.TaskId then
            UIUtils.SetTextByEnum(self.MapNameLabel, "C_GUILD_BUILDINGNAME4")
            UIUtils.SetTextByEnum(self.CountLabel, "C_SUPPORT_NUM", info.SupportNum, 1)
            local _cfg = DataConfig.DataTaskConquer[info.TaskId]
            if _cfg then
                local _cloneCfg = DataConfig.DataCloneMap[_cfg.Clonemap]
                if _cloneCfg then
                    UIUtils.SetTextByEnum(self.DescLabel, "C_SUPPORT_COPY", _cloneCfg.TypeName)
                end
            end
        end
    end
end
return UIWorldSupportListItem
