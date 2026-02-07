------------------------------------------------
--author:
--Date: 2019-11-25
--File: UIWorldSupportConfirmPanel.lua
--Module: World Assistance Confirmation Panel
------------------------------------------------

local UIWorldSupportConfirmPanel = {
    Texture = nil, --Background image
    CanBtn = nil, --Close button
    OkBtn = nil, --OK button
    ItemID = 0,--Props ID
    ItemNum = 0,
}

--Open
function UIWorldSupportConfirmPanel:OnOpen(info)
    if info then
        self.Info = info
        self.Go:SetActive(true)
        self:LoadTextures()
        self:SetItem()
    end
end

--closure
function UIWorldSupportConfirmPanel:OnClose()
    self.Go:SetActive(false)
    self.CSForm:UnloadTexture(self.Texture)
end

function UIWorldSupportConfirmPanel:OnFirstShow(parent, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:RegUICallback()
    return _m
end

--Register events on the UI, such as click events, etc.
function UIWorldSupportConfirmPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.CanBtn, self.OnClickCanBtn, self)
    UIUtils.AddBtnEvent(self.OkBtn, self.OnClickOkBtn, self)
end

--Find components
function UIWorldSupportConfirmPanel:FindAllComponents()
    self.Texture = UIUtils.FindTex(self.Trans,"Texture")
    self.CanBtn = UIUtils.FindBtn(self.Trans,"Canel")
    self.OkBtn = UIUtils.FindBtn(self.Trans,"OK")
    self.GetItem = UILuaItem:New(UIUtils.FindTrans(self.Trans,"Item"))
    self.TipsLabel = UIUtils.FindLabel(self.Trans,"DescLabel")
end

--Close button
function UIWorldSupportConfirmPanel:OnClickCanBtn()
    self:OnClose()
end

--Set props
function UIWorldSupportConfirmPanel:SetItem()
    self.GetItem.IsShowTips = true
    if self.Info.SupportCfg then
        local _ar = Utils.SplitNumber(self.Info.SupportCfg.PicRes, '_')
        if #_ar >= 2 then
            self.ItemID = _ar[1]
            self.ItemNum = _ar[2]
        end
    end
    self.GetItem:InItWithCfgid(self.ItemID, self.ItemNum, false, false)
    local _mapName = ""
    local _bossLv = ""
    local _bossName = ""
    if self.Info.MonsterCfg then
        _bossLv = self.Info.MonsterCfg.Level
        if _bossLv < 0  then
            _bossLv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
        elseif _bossLv == 0 then
            _bossLv = GameCenter.OfflineOnHookSystem.CurWorldLevel
        end
        _bossName = self.Info.MonsterCfg.Name
    end
    if self.Info.CloneMapCfg then
        _mapName = self.Info.CloneMapCfg.TypeName
        UIUtils.SetTextByEnum(self.TipsLabel, "C_SUPPORT_TIPS", self.Info.RoleName, _mapName, _bossLv, _bossName)
    end
    if self.Info.TaskId then
        local _cfg = DataConfig.DataTaskConquer[self.Info.TaskId]
        if _cfg then
            UIUtils.SetTextByEnum(self.TipsLabel, "C_SUPPORT_TIPS2", self.Info.RoleName, _cfg.TaskName)
        end
    end
end

--OK button
function UIWorldSupportConfirmPanel:OnClickOkBtn()
    if self.Info.TaskId then
        GameCenter.TeamSystem:ReqApplyEnter(self.Info.TeamId)
    else
        GameCenter.WorldSupportSystem:ReqToWorldSupport(self.Info.SupportId)
    end
    self:OnClose()
end

--Loading texture
function UIWorldSupportConfirmPanel:LoadTextures()
    self.CSForm:LoadTexture(self.Texture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
end


return UIWorldSupportConfirmPanel
