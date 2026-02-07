------------------------------------------------
-- author:
-- Date: 2020-01-15
-- File: GuildInfoPanel.lua
-- Module: GuildInfoPanel
-- Description: Xianmeng Basic Information Interface
------------------------------------------------
local L_WordFilter = CS.Thousandto.Code.Logic.WordFilter
local L_UIGuildBannerItem = require("UI.Components.UIGuildBannerItem");
local GuildInfoPanel = {
    Trans = nil,
    Go = nil,
    -- Gang name
    GuildNameLabel = nil,
    -- Gang leader's name
    LeaderNameLabel = nil,
    -- Gang Level
    GuildLvLabel = nil,
    -- Number of gang members
    GuildNumLabel = nil,
    -- Gang battle power
    GuildPowerLabel = nil,
    -- Gang Funds
    GuildMoneyLabel = nil,
    -- Gang Declaration
    GuildNoticeLabel = nil,
    -- Immortal Alliance ID
    GuildIdLabel = nil,
    -- Competition Level
    CompeteLvLabel = nil,
    -- Maintenance funds
    DailyCostLabel = nil,
    -- Announcement modification panel
    ChangeNoticePanelGo = nil,
    -- Log Panel
    LogPanelGo = nil,
    -- Log List
    LogList = List:New(),

    -- Animation module
    AnimModule = nil,

    HelpBtn = nil,
}

-- Create a new object
function GuildInfoPanel:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = parent
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    _m:FindAllComponents()
    _m.Go:SetActive(false)
    _m.IsVisible = false
    return _m
end

-- Find controls
function GuildInfoPanel:FindAllComponents()
    local trans = self.Trans
    self.GuildLvLabel          = UIUtils.FindLabel(trans, "Center/GuildLv")
    self.GuildIdLabel          = UIUtils.FindLabel(trans, "Center/GuildID")
    self.CompeteLvLabel        = UIUtils.FindLabel(trans, "Center/CompeteLv")
    self.GuildNameLabel        = UIUtils.FindLabel(trans, "Center/GuildName")
    self.LeaderNameLabel       = UIUtils.FindLabel(trans, "Center/LeaderName")
    self.GuildNumLabel         = UIUtils.FindLabel(trans, "Center/GuildNum")
    self.GuildPowerLabel       = UIUtils.FindLabel(trans, "Center/GuildFight")
    self.GuildMoneyLabel       = UIUtils.FindLabel(trans, "Center/GuildMoney")
    self.GuildMoneyTipsLabel   = UIUtils.FindLabel(trans, "MoneyTipsPanel/Container/GuildMoney")
    self.GuildNoticeLabel      = UIUtils.FindLabel(trans, "Center/Declaration")
    self.DailyCostLabel        = UIUtils.FindLabel(trans, "Center/DailyCost")
    self.DailyCostTipsLabel    = UIUtils.FindLabel(trans, "MoneyTipsPanel/Container/CostMoney")
    self.EnterSceneBtnGo       = UIUtils.FindGo(trans, "Bottom/EnterSceneBtn")
    self.ChangeNoticeGo        = UIUtils.FindGo(trans, "Center/ChangeNoticeBtn")
    self.ChangeNoticePanelGo   = UIUtils.FindGo(trans, "ChangeNoticePanel")
    self.ApplyLeaderPanelGo    = UIUtils.FindGo(trans, "ApplyLeaderPanel")
    self.MoneyTipsPanelGo      = UIUtils.FindGo(trans, "MoneyTipsPanel")
    self.CostTipsPanelGo       = UIUtils.FindGo(trans, "CostTipsPanel")
    self.LogPanelGo            = UIUtils.FindGo(trans, "LogPanel")
    self.ReceiveRedGo          = UIUtils.FindGo(trans, "Bottom/ReceiveBtn/Red")
    self.ChangeNoticeTexture   = UIUtils.FindTex(trans, "ChangeNoticePanel/Texture")
    self.ReceiveBtnSpr         = UIUtils.FindSpr(trans, "Bottom/ReceiveBtn")
    self.NoticeInput           = UIUtils.FindInput(trans, "ChangeNoticePanel/NameInput")
    self.Texture               = UIUtils.FindTex(trans, "Texture")
    self.SelectIcon            = L_UIGuildBannerItem:New(UIUtils.FindTrans(trans, "Center/IconTrans"), self.CSForm)

    self.LogTabel = UIUtils.FindTable(trans, "LogPanel/Scroll/Table")
    self.LogScroll = UIUtils.FindScrollView(trans, "LogPanel/Scroll")
    self.LogPanelTexture   = UIUtils.FindTex(trans, "LogPanel/Texture")

    local _table = UIUtils.FindTrans(trans, "LogPanel/Scroll/Table")
    if _table then
        for i = 0, _table.childCount - 1 do
            self.LogItem = UIUtils.FindLabel(_table:GetChild(i))
            self.LogList:Add(self.LogItem)
        end
    end

    local _global = DataConfig.DataGlobal[GlobalName.GuildMoneyIcon]
    if _global ~= nil then
        local _num = tonumber(_global.Params)
        local _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Center/GuildMoney/Icon"))
        _icon:UpdateIcon(_num)
        _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Center/DailyCost/Icon"))
        _icon:UpdateIcon(_num)
    end

    local btn = UIUtils.FindBtn(trans, "Bottom/EnterSceneBtn")
    UIUtils.AddBtnEvent(btn, self.EnterSceneBtnClick, self)
    btn = UIUtils.FindBtn(trans, "Center/ApplyLeaderBtn")
    self.ApplyLeaderBtnGo = UIUtils.FindGo(trans, "Center/ApplyLeaderBtn")
    UIUtils.AddBtnEvent(btn, self.ApplyLeaderBtnClick, self)
    btn = UIUtils.FindBtn(trans, "Center/ChangeNoticeBtn")
    UIUtils.AddBtnEvent(btn, self.ChangeNoticeBtnClick, self)
    btn = UIUtils.FindBtn(trans, "Bottom/ReceiveBtn")
    UIUtils.AddBtnEvent(btn, self.ReceiveBtnCLick, self)
    btn = UIUtils.FindBtn(trans, "Bottom/GuildLogBtn")
    UIUtils.AddBtnEvent(btn, self.GuildLogBtnClick, self)

    btn = UIUtils.FindBtn(trans, "ChangeNoticePanel/CancelBtn")
    UIUtils.AddBtnEvent(btn, self.CloseNotice, self)
    btn = UIUtils.FindBtn(trans, "ChangeNoticePanel/CloseBtn")
    UIUtils.AddBtnEvent(btn, self.CloseNotice, self)
    btn = UIUtils.FindBtn(trans, "ChangeNoticePanel/Back")
    UIUtils.AddBtnEvent(btn, self.CloseNotice, self)

    btn = UIUtils.FindBtn(trans, "ChangeNoticePanel/AgreeBtn")
    UIUtils.AddBtnEvent(btn, self.SaveNoticeBtnClick, self)
    btn = UIUtils.FindBtn(trans, "ApplyLeaderPanel/CloseBtn")
    UIUtils.AddBtnEvent(btn, self.CloseApplyLeaderPanel, self)
    btn = UIUtils.FindBtn(trans, "ApplyLeaderPanel/Back")
    UIUtils.AddBtnEvent(btn, self.CloseApplyLeaderPanel, self)
    btn = UIUtils.FindBtn(trans, "ApplyLeaderPanel/ApplyBtn")
    UIUtils.AddBtnEvent(btn, self.ApplyLeaderMsgClick, self)
    btn = UIUtils.FindBtn(trans, "MoneyTipsPanel/Back")
    UIUtils.AddBtnEvent(btn, self.CloseMoneyTipsPanel, self)
    btn = UIUtils.FindBtn(trans, "Center/GuildMoney/Tips")
    UIUtils.AddBtnEvent(btn, self.OpenMoneyTipsPanel, self)
    btn = UIUtils.FindBtn(trans, "CostTipsPanel/Back")
    UIUtils.AddBtnEvent(btn, self.CloseCostTipsPanel, self)
    btn = UIUtils.FindBtn(trans, "Center/DailyCost/Tips")
    UIUtils.AddBtnEvent(btn, self.OpenCostTipsPanel, self)
    btn = UIUtils.FindBtn(trans, "LogPanel/CloseBtn")
    UIUtils.AddBtnEvent(btn, self.CloseLogPanel, self)
    btn = UIUtils.FindBtn(trans, "LogPanel/Back")
    UIUtils.AddBtnEvent(btn, self.CloseLogPanel, self)

    self.AnimModule:AddTransNormalAnimation(self.ChangeNoticePanelGo.transform, 50, 0.3)
    self.AnimModule:AddTransNormalAnimation(self.LogPanelGo.transform, 50, 0.3)
    self.AnimModule:AddTransNormalAnimation(self.MoneyTipsPanelGo.transform, 50, 0.3)
    self.AnimModule:AddTransNormalAnimation(self.CostTipsPanelGo.transform, 50, 0.3)

    --- Note(TL): hidden show Guild Guide panel
    self.HelpBtn = UIUtils.FindBtn(trans, "HelpBtn")
    UIUtils.AddBtnEvent(self.HelpBtn, self.OnHelpBtnClick, self)
    self.HelpBtn.gameObject:SetActive(false)
end

function GuildInfoPanel:OnTryHide()
    if self.ChangeNoticePanelGoShow then
        self:CloseNotice()
        return false
    end
    if self.ApplyLeaderPanelGoShow then
        self:CloseApplyLeaderPanel()
        return false
    end
    if self.MoneyTipsPanelGoShow then
        self:CloseMoneyTipsPanel()
        return false
    end
    if self.CostTipsPanelGoShow then
        self:CloseCostTipsPanel()
        return false
    end
    if self.LogPanelGoShow then
        self:CloseLogPanel()
        return false
    end
    return true
end

function GuildInfoPanel:Open()
    self.AnimModule:PlayEnableAnimation()
    self:OnUpdateForm()
    self.ChangeNoticePanelGo:SetActive(false)
    self.ChangeNoticePanelGoShow = false
    self.ApplyLeaderPanelGo:SetActive(false)
    self.ApplyLeaderPanelGoShow = false
    self.LogPanelGo:SetActive(false)
    self.LogPanelGoShow = false
    self.MoneyTipsPanelGo:SetActive(false)
    self.MoneyTipsPanelGoShow = false
    self.CostTipsPanelGo:SetActive(false)
    self.CostTipsPanelGoShow = false
    self:CloseApplyLeaderPanel()
    self:CloseCostTipsPanel()
    self:CloseMoneyTipsPanel()
    self:CloseLogPanel()
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_b_xianmeng_3"))

    --- Note(TL): hidden show Guild Guide panel
    --local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    --local _key = string.format("IsGuildGuide%d", _lpId)
    --if not PlayerPrefs.HasKey(_key) then
    --    PlayerPrefs.SetInt(_key, 1)
    --    self:OnHelpBtnClick()
    --end
	self.IsVisible = true
end

function GuildInfoPanel:Close()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function GuildInfoPanel:SetWageCount()
    local _canGetOff = GameCenter.GuildSystem.CanGetOfflineExpTime
    self.ReceiveRedGo:SetActive(_canGetOff)
    --self.ReceiveBtnSpr.IsGray = not _canGetOff
end

function GuildInfoPanel:OnHelpBtnClick()
    GameCenter.PushFixEvent(UILuaEventDefine.UIGuildGuideForm_OPEN)
end

-- Load interface data
function GuildInfoPanel:OnUpdateForm()
    local _info = GameCenter.GuildSystem.GuildInfo
    UIUtils.SetTextByString(self.GuildNameLabel, _info.name)
    UIUtils.SetTextByString(self.LeaderNameLabel, _info.leaderName)
    UIUtils.SetTextByEnum(self.GuildLvLabel, "UI_GUILED_LEVELNUM", _info.lv)
    UIUtils.SetTextByNumber(self.GuildPowerLabel, _info.fighting)
    UIUtils.SetTextByBigNumber(self.GuildIdLabel, _info.guildId)
    local _rankCfg = DataConfig.DataGuildWarRank[_info.Rate]
    if _rankCfg then
        UIUtils.SetTextByStringDefinesID(self.CompeteLvLabel, _rankCfg._Name)
    else
        UIUtils.SetTextByEnum(self.CompeteLvLabel, "C_TEXT_NULL")
    end
    local _num = math.modf(_info.icon % 100 / 10)
    if _num == 0 then
        _num = 1
    end
    self.SelectIcon:SetIcon(_info.icon, true)
    UIUtils.SetTextByString(self.GuildNoticeLabel, _info.notice)
    self:SetWageCount()
    local _guildConfig = DataConfig.DataGuildUp[10000 + _info.lv]
    if _guildConfig ~= nil then
        UIUtils.SetTextByEnum(self.GuildNumLabel, "Progress", _info.memberNum, _info.MaxNum)
        UIUtils.SetTextByNumber(self.DailyCostLabel, _guildConfig.MaintenanceFund)
        UIUtils.SetTextByNumber(self.DailyCostTipsLabel, _guildConfig.MaintenanceFund)
        local _meiney = _info.guildMoney - _guildConfig.MaintenanceFund
        if _meiney < 0 then
            _meiney = 0
        end
        UIUtils.SetTextByNumber(self.GuildMoneyLabel, _meiney)
        UIUtils.SetTextByNumber(self.GuildMoneyTipsLabel, _info.guildMoney)
    end
    local g = GameCenter.GuildSystem:OnGetGuildOfficial()
    if g ~= nil then
        -- self.EnterSceneBtnGo:SetActive(true)
        self.ChangeNoticeGo:SetActive(g.CanNotice == 1)
        self.ApplyLeaderBtnGo:SetActive(not GameCenter.GuildSystem:IsChairman())
    else
        -- self.EnterSceneBtnGo:SetActive(false)
        self.ChangeNoticeGo:SetActive(false)
        self.ApplyLeaderBtnGo:SetActive(false)
    end
    _guildConfig = DataConfig.DataGlobal[GlobalName.GuildNoticeMaxLength_G]
    if _guildConfig then
        self.MaxNoticeLen = tonumber(_guildConfig.Params)
    end
end

function GuildInfoPanel:SetBackSprColor(color, sprite)
    if (color == 1) then
        UIUtils.SetColorByString(sprite, "#C6493B")
    elseif (color == 2) then
        UIUtils.SetColorByString(sprite, "#E88129")
    elseif (color == 3) then
        UIUtils.SetColorByString(sprite, "#E7417A")
    elseif (color == 4) then
        UIUtils.SetColorByString(sprite, "#38C555")
    elseif (color == 5) then
        UIUtils.SetColorByString(sprite, "#23AAC8")
    elseif (color == 6) then
        UIUtils.SetColorByString(sprite, "#7B38F1")
    end
 end
 function GuildInfoPanel:SetSprColor(color, sprite)
    if (color == 1) then
        UIUtils.SetColorByString(sprite, "#FF4F4F")
    elseif (color == 2) then
        UIUtils.SetColorByString(sprite, "#FEBB3E")
    elseif (color == 3) then
        UIUtils.SetColorByString(sprite, "#FF7BB0")
    elseif (color == 4) then
        UIUtils.SetColorByString(sprite, "#57DB70")
    elseif (color == 5) then
        UIUtils.SetColorByString(sprite, "#5ED4F0")
    elseif (color == 6) then
        UIUtils.SetColorByString(sprite, "#AA70FF")
    end
 end

function GuildInfoPanel:SetNotice()
    UIUtils.SetTextByString(self.GuildNoticeLabel, GameCenter.GuildSystem.GuildInfo.notice)
end

-- Setting up a log list
function GuildInfoPanel:SetLogList()
    local _list = GameCenter.GuildSystem.GuildLogList
    local _label = nil
    for i = 1, #_list do
        local _info = _list[i]
        if i > #self.LogList then
            _label = UIUtils.FindLabel(UnityUtils.Clone(self.LogItem.gameObject).transform)
            self.LogList:Add(_label)
        else
            _label = self.LogList[i]
        end
        if _label then
            if _info.formate then
                UIUtils.SetTextByString(_label, Time.StampToDateTime(_info.Time, "yyyy-MM-dd HH:mm:ss ") .. _info.formate);
            else
                UIUtils.SetTextByString(_label, Time.StampToDateTime(_info.Time, "yyyy-MM-dd HH:mm:ss ") .. DataConfig.DataMessageString.Get("C_GUILD_INFOERROR"));
            end
        end
    end
    for i = #_list + 1, #self.LogList do
        UIUtils.ClearText(self.LogList[i])
    end
    self.LogTabel.repositionNow = true
end

-- Enter the sect scene button to click
function GuildInfoPanel:EnterSceneBtnClick()
    Utils.ShowMsgBox(function (code)
        if (code == MsgBoxResultCode.Button2) then 
            GameCenter.Network.Send("MSG_Guild.ReqGuildBaseEnter", {})
        end
    end, "C_GUILD_ENTERBASE_CONFIRM")
end

-- Click on the payroll button
function GuildInfoPanel:ReceiveBtnCLick()
    GameCenter.Network.Send("MSG_Guild.ReqReceiveItem", {})
    if not GameCenter.GuildSystem.CanGetOfflineExpTime then
        Utils.ShowPromptByEnum("C_GUILD_INFOTODAY")
    end
end

-- Click on the Xianmeng Log button
function GuildInfoPanel:GuildLogBtnClick()
    self.AnimModule:PlayShowAnimation(self.LogPanelGo.transform)
    self:SetLogList()
    self.LogScroll:ResetPosition()
    GameCenter.Network.Send("MSG_Guild.ReqGuildLogList", {})
    self.LogPanelGoShow = true
    self.CSForm:LoadTexture(self.LogPanelTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_3_1"))
end

-- Click on the Apply Leader button
function GuildInfoPanel:ApplyLeaderBtnClick()
    self.ApplyLeaderPanelGo:SetActive(true)
    self.ApplyLeaderPanelGoShow = true
end

-- Modify the announcement
function GuildInfoPanel:ChangeNoticeBtnClick()
    self.AnimModule:PlayShowAnimation(self.ChangeNoticePanelGo.transform)
    self.ChangeNoticePanelGoShow = true
    self.CSForm:LoadTexture(self.ChangeNoticeTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_3_1"))
    local strUnicode = UIUtils.ConvertKhmerLegacyToUnicodeString(GameCenter.GuildSystem.GuildInfo.notice)
    self.NoticeInput.value = strUnicode
end

-- Save the announcement modification panel
function GuildInfoPanel:SaveNoticeBtnClick()
    local _str = self.NoticeInput.value
    local _len = Utils.UTF8LenForLan(_str,FLanguage.Default);
    if _len > 0 then
        if _len <= self.MaxNoticeLen then
            if L_WordFilter.IsContainsSensitiveWord(_str) then
                -- Contains sensitive words
                Utils.ShowPromptByEnum("Marry_DanMu_PingBiZi")
            else
                local _strKhmer = UIUtils.ConvertKhmerUnicodeToLegacyString(_str)
                GameCenter.GuildSystem:ReqChangeNotice(_strKhmer)
            end
        else
            Utils.ShowPromptByEnum("C_GUILD_NOTICENUMLIMIT", self.MaxNoticeLen)
        end
    else
        Utils.ShowPromptByEnum("C_UI_CREATEGUILD_NOTICENULL")
    end
    self:CloseNotice()
end

-- Close the Announcement Modification Panel
function GuildInfoPanel:CloseNotice()
    self.AnimModule:PlayHideAnimation(self.ChangeNoticePanelGo.transform)
    self.ChangeNoticePanelGoShow = false
end

-- Close the application leader interface
function GuildInfoPanel:CloseApplyLeaderPanel()
    self.ApplyLeaderPanelGo:SetActive(false)
    self.ApplyLeaderPanelGoShow = false
end

-- Click the button on the application leader interface to send the application leader message
function GuildInfoPanel:ApplyLeaderMsgClick()
    self:CloseApplyLeaderPanel()
    GameCenter.Network.Send("MSG_Guild.ReqImpeach", {})
end

function GuildInfoPanel:OpenMoneyTipsPanel()
    self.AnimModule:PlayShowAnimation(self.MoneyTipsPanelGo.transform)
    self.MoneyTipsPanelGoShow = true
end
function GuildInfoPanel:CloseMoneyTipsPanel()
    self.AnimModule:PlayHideAnimation(self.MoneyTipsPanelGo.transform)
    self.MoneyTipsPanelGoShow = false
end
function GuildInfoPanel:OpenCostTipsPanel()
    self.AnimModule:PlayShowAnimation(self.CostTipsPanelGo.transform)
    self.CostTipsPanelGoShow = true
end
function GuildInfoPanel:CloseCostTipsPanel()
    self.AnimModule:PlayHideAnimation(self.CostTipsPanelGo.transform)
    self.CostTipsPanelGoShow = false
end
function GuildInfoPanel:CloseLogPanel()
    self.AnimModule:PlayHideAnimation(self.LogPanelGo.transform)
    self.LogPanelGoShow = false
end
return GuildInfoPanel
