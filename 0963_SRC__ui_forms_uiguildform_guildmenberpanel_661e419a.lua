------------------------------------------------
-- author:
-- Date: 2020-01-15
-- File: GuildMenberPanel.lua
-- Module: GuildMenberPanel
-- Description: Immortal Alliance member interface
------------------------------------------------
local UIMemberRankItem =  require "UI.Forms.UIGuildListForm.UIMemberRankItem"
local UIMemberListItem = require "UI.Forms.UIGuildListForm.UIMemberListItem"
local L_InterActive = require "UI.Forms.UIGuildForm.GuildInterActivePanel"
local L_ApplyPanel = require "UI.Forms.UIGuildForm.GuildApplyListPanel"
local L_Offical = require ("UI.Forms.UIGuildForm.GuildOfficalPanel")
local GuildMenberPanel = {
    Trans = nil,
    Go = nil,
    -- Number of people online
    OnLineNumLabel = nil,
    -- The entire slider
    ScrollView = nil,
    -- List of players who rank ten years later
    Grid = nil,
    GridTrans = nil,
    -- Main slider table
    Tabel = nil,
    -- First place component
    RankItem1 = nil,
    -- 2 to 4 components
    RankItem2 = nil,
    -- 5-10 components
    RankItem3 = nil,
    -- Other rankings
    ListGo = nil,
    -- Sort Type
    CurSortNum = 0,
    MemberList = List:New(),
    NormalMemberList = List:New(),
}

-- Create a new object
function GuildMenberPanel:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = parent
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    _m:FindAllComponents()
    _m.IsVisible = false
    return _m
end

function GuildMenberPanel:OnTryHide()
    if self.ApplyPanel.IsVisible then
        self.ApplyPanel:Close()
        return false
    end
    if self.OfficalPanel.IsVisible then
        self.OfficalPanel:Close()
        return false
    end
    if self.InterActivePanel.IsVisible then
        self.InterActivePanel:Close()
        return false
    end
    return true
end

-- Find controls
function GuildMenberPanel:FindAllComponents()
    self.OnLineNumLabel = UIUtils.FindLabel(self.Trans, "OnlineCount")
    self.RankMemGo = UIUtils.FindGo(self.Trans, "RankMember")
    self.Grid = UIUtils.FindGrid(self.Trans, "RankMember/ListScroll/Table/Grid")
    self.GridTrans = UIUtils.FindTrans(self.Trans, "RankMember/ListScroll/Table/Grid")
    self.Table = UIUtils.FindTable(self.Trans, "RankMember/ListScroll/Table")
    self.ScrollView = UIUtils.FindScrollView(self.Trans, "RankMember/ListScroll")
    for i = 0, self.GridTrans.childCount - 1 do
        self.ListGo = UIMemberListItem:OnFirstShow(self.GridTrans:GetChild(i))
        self.ListGo.CallBack = Utils.Handler(self.ListClick, self)
        self.MemberList:Add(self.ListGo)
    end
    self.NormalMemGo = UIUtils.FindGo(self.Trans, "NomalMember")
    self.NomalGrid = UIUtils.FindGrid(self.Trans, "NomalMember/ListScroll/Grid")
    self.NomalGridTrans = UIUtils.FindTrans(self.Trans, "NomalMember/ListScroll/Grid")
    self.NormalScrollView = UIUtils.FindScrollView(self.Trans, "NomalMember/ListScroll")
    for i = 0, self.NomalGridTrans.childCount - 1 do
        self.NormalListGo = UIMemberListItem:OnFirstShow(self.NomalGridTrans:GetChild(i))
        self.NormalListGo.CallBack = Utils.Handler(self.ListClick, self)
        self.NormalMemberList:Add(self.NormalListGo)
    end
    self.RankItem1 = UIMemberRankItem:OnFirstShow(UIUtils.FindTrans(self.Trans, "RankMember/ListScroll/Table/Rank1"), self.CSForm)
    self.RankItem2 = UIMemberRankItem:OnFirstShow(UIUtils.FindTrans(self.Trans, "RankMember/ListScroll/Table/Rank2"), self.CSForm)
    self.RankItem3 = UIMemberRankItem:OnFirstShow(UIUtils.FindTrans(self.Trans, "RankMember/ListScroll/Table/Rank3"), self.CSForm)
    self.RankItem1.CallBack = Utils.Handler(self.ListClick, self)
    self.RankItem2.CallBack = Utils.Handler(self.ListClick, self)
    self.RankItem3.CallBack = Utils.Handler(self.ListClick, self)

    local btn = UIUtils.FindBtn(self.Trans, "AutoCallBtn")
    self.AutoCallBtnGo = UIUtils.FindGo(self.Trans, "AutoCallBtn")
    UIUtils.AddBtnEvent(btn, self.OnAutoCallBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "ApplyListBtn")
    self.ApplyListBtnGo = UIUtils.FindGo(self.Trans, "ApplyListBtn")
    UIUtils.AddBtnEvent(btn, self.OnApplyListBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "ExitBtn")
    UIUtils.AddBtnEvent(btn, self.OnExitBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "NomalMember/List/StateLabel")
    self.StateSortGo = UIUtils.FindGo(self.Trans, "NomalMember/List/StateLabel/Sprite")
    UIUtils.AddBtnEvent(btn, self.OnStateSortBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "NomalMember/List/LeaderLabel")
    self.RankSortGo = UIUtils.FindGo(self.Trans, "NomalMember/List/LeaderLabel/Sprite")
    UIUtils.AddBtnEvent(btn, self.OnRankSortBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "NomalMember/List/NumLabel")
    self.ContributeSortGo = UIUtils.FindGo(self.Trans, "NomalMember/List/NumLabel/Sprite")
    UIUtils.AddBtnEvent(btn, self.OnContributeSortBtnClick, self)
    btn = UIUtils.FindBtn(self.Trans, "NomalMember/List/PowerLabel")
    self.FightPowerSortGo = UIUtils.FindGo(self.Trans, "NomalMember/List/PowerLabel/Sprite")
    UIUtils.AddBtnEvent(btn, self.OnFightPowerSortBtnClick, self)
    self.ApplyRedGo = UIUtils.FindGo(self.Trans, "ApplyListBtn/Red")
    self.InterActivePanel = L_InterActive:OnFirstShow(UIUtils.FindTrans(self.Trans, "InterActive"), self.CSForm)
    self.InterActivePanel.CallBack = Utils.Handler(self.OpenOfficalPanel, self)
    self.OfficalPanel = L_Offical:OnFirstShow(UIUtils.FindTrans(self.Trans, "Offical"), self.CSForm)
    self.ApplyPanel = L_ApplyPanel:OnFirstShow(UIUtils.FindTrans(self.Trans, "ApplyPanel"), self.CSForm)
end

function GuildMenberPanel:Open(func)
    self.AnimModule:PlayEnableAnimation()
    self.CurSortNum = 0
    self.OpenFunc = func
    self:OnUpdateForm()
    self:SetBtnShow()
    self.NormalScrollView:ResetPosition()
    self.ScrollView:ResetPosition()
    -- self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_bag_secon"))
    self.IsVisible = true
end

function GuildMenberPanel:Close()
    self.Go:SetActive(false)
    self.IsVisible = false
end

-- Summoning people with one click
function GuildMenberPanel:OnAutoCallBtnClick()
    GameCenter.Network.Send("MSG_Guild.ReqGuildJoinPlayer", {})
end
-- Application List
function GuildMenberPanel:OnApplyListBtnClick()
    self.ApplyPanel:Open()
end

-- Sort click
function GuildMenberPanel:OnStateSortBtnClick()
    if self.CurSortNum == 1 then
        self.CurSortNum = 0
    else
        self.CurSortNum = 1
    end
    self:OnUpdateForm()
    self.NormalScrollView:ResetPosition()
end
function GuildMenberPanel:OnRankSortBtnClick()
    if self.CurSortNum == 2 then
        self.CurSortNum = 0
    else
        self.CurSortNum = 2
    end
    self:OnUpdateForm()
    self.NormalScrollView:ResetPosition()
end
function GuildMenberPanel:OnContributeSortBtnClick()
    if self.CurSortNum == 3 then
        self.CurSortNum = 0
    else
        self.CurSortNum = 3
    end
    self:OnUpdateForm()
    self.NormalScrollView:ResetPosition()
end
function GuildMenberPanel:OnFightPowerSortBtnClick()
    if self.CurSortNum == 4 then
        self.CurSortNum = 0
    else
        self.CurSortNum = 4
    end
    self:OnUpdateForm()
    self.NormalScrollView:ResetPosition()
end

function GuildMenberPanel:ListClick(item)
    if item.PlayerData.roleId == GameCenter.GameSceneSystem:GetLocalPlayerID() then
        Utils.ShowPromptByEnum("C_GUILD_CLICKTIPS")
        return
    end
    if self.SelectListItem then
        self.SelectListItem:OnSetSelect(false)
    end
    self.SelectListItem = item
    self.InterActivePanel:Open()
    self.InterActivePanel:OnUpdateItem(item.PlayerData)
end
-- quit
function GuildMenberPanel:OnExitBtnClick()
    GameCenter.GuildSystem:ReqExitQuit()
end

-- Open the Appointment Panel
function GuildMenberPanel:OpenOfficalPanel(data)
    self.OfficalPanel:Open(data.roleId)
end

-- Load interface data
function GuildMenberPanel:OnUpdateForm()
    self.SelectListItem = nil
    self.ApplyRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabApplyList))
    UIUtils.SetTextByEnum(self.OnLineNumLabel, "C_GUILD_ONLINECOUNTTIPS", GameCenter.GuildSystem:OnGetOnLineNum())
    local _guildRank = GameCenter.GuildSystem.GuildInfo.RankNum
    if self.OpenFunc and self.OpenFunc == GuildSubEnum.Info_RankList then
        local info = List:New(GameCenter.GuildSystem:OnGetSortMemberListByEnum(4))
        if not GameCenter.GuildSystem.IsEnterRank then
            GameCenter.GuildSystem.IsEnterRank = true
            Utils.ShowMsgBoxAndBtn(nil, "C_MSSAGEBOX_OK", nil, "C_GUILD_RANKLISTTIPS")
        end
        self.NormalMemGo:SetActive(false)
        self.RankMemGo:SetActive(true)
        self.RankItem1.Go:SetActive(false)
        self.RankItem2.Go:SetActive(false)
        self.RankItem3.Go:SetActive(false)
        local _config = nil
        if #info > 0 then
            local _list = List:New()
            _list:Add(info[1])
            _config = DataConfig.DataGuildTitle[_guildRank * 100 + info[1].RankNum]
            self.RankItem1.Go:SetActive(true)
            self.RankItem1:OnUpdateItem(_list, _config)

        end
        if #info > 1 then
            local _list = List:New()
            for i = 2, #info do
                    _list:Add(info[i])
                    if _list:Count() == 3 then
                        break
                    end
            end
            if _list:Count() > 0 then
                _config = DataConfig.DataGuildTitle[_guildRank * 100 + info[2].RankNum]
                self.RankItem2.Go:SetActive(true)
                self.RankItem2:OnUpdateItem(_list, _config)
            end
        end
        if #info > 4 then
            local _list = List:New()
            for i = 5, #info do
                    _list:Add(info[i])
                    if _list:Count() == 6 then
                        break
                    end
            end
            if _list:Count() > 0 then
                _config = DataConfig.DataGuildTitle[_guildRank * 100 + info[5].RankNum]
                self.RankItem3.Go:SetActive(true)
                self.RankItem3:OnUpdateItem(_list, _config)
            end
        end

        for i = 1, #self.MemberList do
            self.MemberList[i].Go:SetActive(false)
        end
        if #info > 10 then
            local _list = List:New()
            for i = 11, #info do
                    _list:Add(info[i])
            end
            if _list:Count() > 0 then
                _list:Sort(function(a, b)
                    return a.RankNum < b.RankNum
                end)
                local _go = nil
                for i = 1, #_list do
                    if i > #self.MemberList then
                        _go = self.ListGo:Clone()
                        _go.CallBack = Utils.Handler(self.ListClick, self)
                        self.MemberList:Add(_go)
                    else
                        _go = self.MemberList[i]
                    end
                    if _go ~= nil then
                        _go.Go:SetActive(true)
                        _go:OnUpdateItem(_list[i], false)
                    end
                end
            end
            self.Grid.repositionNow = true
        end
        self.Table.repositionNow = true
    else
        self.NormalMemGo:SetActive(true)
        self.RankMemGo:SetActive(false)
        local _go = nil
        local info = List:New(GameCenter.GuildSystem:OnGetSortMemberListByEnum(self.CurSortNum))
        for i = 1, #info do
            if i > #self.NormalMemberList then
                _go = self.NormalListGo:Clone()
                _go.CallBack = Utils.Handler(self.ListClick, self)
                self.NormalMemberList:Add(_go)
            else
                _go = self.NormalMemberList[i]
            end
            if _go ~= nil then
                _go.Go:SetActive(true)
                _go:OnUpdateItem(info[i], false)
                _go.Trans.name = string.format( "%03d", i)
            end
        end
        for i = #info + 1, #self.NormalMemberList do
            self.NormalMemberList[i].Go:SetActive(false)
        end
        self.StateSortGo:SetActive(self.CurSortNum == 1)
        self.RankSortGo:SetActive(self.CurSortNum == 2)
        self.ContributeSortGo:SetActive(self.CurSortNum == 3)
        self.FightPowerSortGo:SetActive(self.CurSortNum == 4)
        self.NomalGrid.repositionNow = true
    end
end

function GuildMenberPanel:SetBtnShow()
    local _cfg = GameCenter.GuildSystem:OnGetGuildOfficial()
    if _cfg then
        self.ApplyListBtnGo:SetActive(_cfg.CanAgree == 1)
        self.AutoCallBtnGo:SetActive(_cfg.CanHan == 1)
    else
        self.ApplyListBtnGo:SetActive(false)
        self.AutoCallBtnGo:SetActive(false)
    end
    self.InterActivePanel:Close()
    self.ApplyPanel:Close()
end

-- Application list update
function GuildMenberPanel:UpdateApplyList()
    if self.ApplyPanel.Go.activeSelf then
        self.ApplyPanel:OnUpdateForm()
    end
    self.ApplyRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.GuildTabApplyList))
end

-- Modify settings
function GuildMenberPanel:UpdateSetInfo()
    if self.Go.activeSelf then
        self.ApplyPanel:SetCheckBox()
    end
end
return GuildMenberPanel
