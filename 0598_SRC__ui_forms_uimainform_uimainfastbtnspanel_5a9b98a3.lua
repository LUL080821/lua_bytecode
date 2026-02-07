-- author:
-- Date: 2021-02-24
-- File: UIMainFastBtnsPanel.lua
-- Module: UIMainFastBtnsPanel
-- Description: Home interface shortcut button paging
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_EntityStateID = CS.Thousandto.Core.Asset.EntityStateID

local UIMainFastBtnsPanel = {
    -- Quick launch button
    AuctionBtn = nil,
    AuctionRedPoint = nil,
    -- Mount Button
    MunBtn = nil,
    UpMountGo = nil,
    DownMountGo = nil,
    -- Mail Button
    MailBtn = nil,
    MailTips = nil,
    MailNum = nil,
    -- Support button
    SupportBtn = nil,
    SupportRed = nil,
    -- Limited time store button
    LimitShopBtn = nil,
    -- Mysterious Store Button
    SmIcons = nil,
    SmGrid = nil,
    -- Gift button
    PresentBtn = nil,
    -- Marriage Button
    MarryBtn = nil,
    -- Treasure Box Button
    BXBtn = nil,
    BXNum = nil,

    Grid = nil,
    TimeCount = 0,
    CameraMode3D = false,
}

function UIMainFastBtnsPanel:OnRegisterEvents()
    -- Auction house
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_REDPOINT_UPDATED, self.OnUpdateAuction, self)
    -- Feature updates
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnUpdateFunc, self)
    -- Change of riding status
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UPDATMOUNTRIDE_STATE, self.UpdateMountState, self)
    -- Email prompts
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MAIL_MAILNUM_PROMPT, self.UpdateMailNumPrompt, self)
    -- World Support Tips
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_WORLDSUPPORT_ALERT, self.UpdateSupportShow, self)
    -- Refresh limited time button
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LIMITSHOP_REFRSH, self.RefrshLimitShopState, self)
    -- Get new limited-time products
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NEWLIMITSHOP_REFRESH, self.OnNewLimitShopRefresh, self)
    -- Update the Mysterious Store
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MYSTERYSHOP_UPDATE_MAIN_ICON, self.OnSMShopMainIconUpdated, self)
    -- Exit the Immortal Alliance
    self:RegisterEvent(LogicEventDefine.EID_EVENT_GUILD_LEAVE, self.OnGuildExit, self)
    -- Immortal Alliance data changes
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE, self.GuildInfoUpdate, self)
    -- Gift update
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SENDGIFT_LOG_UPDATE, self.OnUpdatePresentState, self)
    -- Show Guest Button
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MAIN_SHOW_BINGKE, self.OnShowBingKeBtn, self)
    -- Limited time email tips
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MAILEXISTITEMS, self.OnShowMailTips, self)
    -- The number of guild treasure chests is updated
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GUILDBOXLIST_UPDATE, self.OnUpdateGuildBXCount, self)
end

local L_SMShopIcon = nil

function UIMainFastBtnsPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.AuctionBtn = UIUtils.FindBtn(trans, "Grid/Auction")
    self.AuctionRedPoint = UIUtils.FindGo(trans, "Grid/Auction/RedPoint")
    UIUtils.AddBtnEvent(self.AuctionBtn, self.OnAuctionBtnClick, self)
    self.Grid = UIUtils.FindGrid(trans, "Grid")
    self.MounBtn = UIUtils.FindBtn(trans, "ZuoQi")
    UIUtils.AddBtnEvent(self.MounBtn, self.OnMountBtnClick, self)
    self.UpMountGo = UIUtils.FindGo(trans, "ZuoQi/UP")
    self.DownMountGo = UIUtils.FindGo(trans, "ZuoQi/Down")
    self.MailBtn = UIUtils.FindBtn(trans, "Mail")
    self.MailBtn.gameObject:SetActive(false)
    self.MailTips = UIUtils.FindGo(trans, "Mail/Tips")
    self.MailTips:SetActive(false)
    self.MailNum = UIUtils.FindLabel(trans, "Mail/Count")
    self.SupportBtn = UIUtils.FindBtn(trans, "Grid/Support")
    self.SupportRed = UIUtils.FindGo(trans, "Grid/Support/Sprite")
    self.LimitShopBtn = UIUtils.FindBtn(trans, "Grid/LimitShop")
    self.BXBtn = UIUtils.FindBtn(trans, "Grid/GuildBX")
    UIUtils.AddBtnEvent(self.BXBtn, self.OnBXBtnClick, self)
    self.BXNum = UIUtils.FindLabel(trans, "Grid/GuildBX/Count")
    UIUtils.AddBtnEvent(self.MailBtn, self.MailBtnOnClick, self)
    UIUtils.AddBtnEvent(self.SupportBtn, self.SupportBtnClick, self)
    UIUtils.AddBtnEvent(self.LimitShopBtn, self.LimitShopCallBtnClick, self)
    self.AnimModule:AddAlphaPosAnimation(nil, 0, 1, 0, -250, 0.5, true, true)
    self.TimeCount = 0
    self.SmGrid = UIUtils.FindGrid(trans, "SMGrid")
    self.SmIcons = {}
    for i = 1, 4 do
        self.SmIcons[i] = L_SMShopIcon:New(UIUtils.FindTrans(trans, string.format("SMGrid/SMShop%d", i -1)))
    end
    self.HuSongGo = UIUtils.FindGo(trans, "SMGrid/HuSong")
    self.HuSongBtn = UIUtils.FindBtn(trans, "SMGrid/HuSong")
    UIUtils.AddBtnEvent(self.HuSongBtn, self.OnHuSongBtnClick, self)
    self.HuSongTime = UIUtils.FindLabel(trans, "SMGrid/HuSong/Time")
    self.PresentBtn = UIUtils.FindBtn(trans, "Presented")
    UIUtils.AddBtnEvent(self.PresentBtn, self.OnPresentBtnClick, self)
    self.MarryBtn = UIUtils.FindBtn(trans, "Grid/Marry")
    UIUtils.AddBtnEvent(self.MarryBtn, self.OnMarryBtnClick, self)
    self.MarryBtn.gameObject:SetActive(false)

    self.HunYanGo = UIUtils.FindGo(trans, "SMGrid/HunYan")
    self.HunYanBtn = UIUtils.FindBtn(trans, "SMGrid/HunYan")
    UIUtils.AddBtnEvent(self.HunYanBtn, self.OnHunYanBtnClick, self)
    self.HunYanTime = UIUtils.FindLabel(trans, "SMGrid/HunYan/Time")

    self.HongBaoGo = UIUtils.FindGo(trans, "SMGrid/RedPackage")
    self.HongBaoBtn = UIUtils.FindBtn(trans, "SMGrid/RedPackage")
    UIUtils.AddBtnEvent(self.HongBaoBtn, self.OnHongBaoBtnClick, self)

    self.ExpFindGo = UIUtils.FindGo(trans, "SMGrid/ExpFind")
    self.ExpFindBtn = UIUtils.FindBtn(trans, "SMGrid/ExpFind")
    UIUtils.AddBtnEvent(self.ExpFindBtn, self.OnExpFindBtnClick, self)
    return self
end

function UIMainFastBtnsPanel:OnShowAfter()
    self:UpdateMountState(nil)
    self:UpdateMailNumPrompt(nil)
    self:OnUpdatePresentState(nil)
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WorldSupport))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Intimate))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Auchtion))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.GuildTabRedPackage))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.OfflineFind))
    self.SupportRed:SetActive(false)
    self.LimitShopBtn.gameObject:SetActive(GameCenter.LimitShopSystem:IsShowEnter())
    self:OnNewLimitShopRefresh(nil)
    self:OnSMShopMainIconUpdated(nil)
    self:OnUpdateGuildBXCount(nil, nil)
    self.HuSongGo:SetActive(false)
    self.ShowHuSong = false
    self.HunYanGo:SetActive(false)
    self.FrontHunYanState = -1
end

function UIMainFastBtnsPanel:OnHideBefore()
end

function UIMainFastBtnsPanel:OnHunYanBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.MarryBanquet)
end

function UIMainFastBtnsPanel:OnHongBaoBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTabRedPackage)
end

function UIMainFastBtnsPanel:OnExpFindBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.OfflineFind)
end

function UIMainFastBtnsPanel:OnHuSongBtnClick()
	GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongFlashForm_OPEN)
end

function UIMainFastBtnsPanel:OnAuctionBtnClick()
    GameCenter.AuctionHouseSystem.AuctionRedPoint = false
    self.AuctionRedPoint:SetActive(false)
    GameCenter.PushFixEvent(UIEventDefine.UIGetAuctionItemTIps_OPEN)
end
function UIMainFastBtnsPanel:OnUpdateAuction(obj, sender)
    self.AuctionRedPoint:SetActive(GameCenter.AuctionHouseSystem.AuctionRedPoint)
end
function UIMainFastBtnsPanel:OnUpdateFunc(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    if _funcId == FunctionStartIdCode.Auchtion then
        self.AuctionBtn.gameObject:SetActive(funcInfo.IsVisible)
    elseif _funcId == FunctionStartIdCode.WorldSupport then
        self.SupportBtn.gameObject:SetActive(funcInfo.IsVisible and GameCenter.GuildSystem:HasJoinedGuild())
    elseif _funcId == FunctionStartIdCode.GuildTabRedPackage then
        self.HongBaoGo:SetActive(funcInfo.IsVisible and funcInfo.IsShowRedPoint and GameCenter.GuildSystem:HasJoinedGuild())
        self.SmGrid.repositionNow = true
    elseif _funcId == FunctionStartIdCode.OfflineFind then
        self.ExpFindGo:SetActive(funcInfo.IsVisible)
        self.SmGrid.repositionNow = true
    end
    self.Grid.repositionNow = true
end
-- Update mount status
function UIMainFastBtnsPanel:UpdateMountState(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if GameCenter.MapLogicSwitch.CanRide and GameCenter.NatureSystem:HasMountId() then
        self.MounBtn.gameObject:SetActive(true)
        if _lp.IsOnMount then
            self.UpMountGo:SetActive(false)
            self.DownMountGo:SetActive(true)
        else
            self.UpMountGo:SetActive(true)
            self.DownMountGo:SetActive(false)
        end
    else
        self.MounBtn.gameObject:SetActive(false)
    end
    self.Grid.repositionNow = true
end
-- Mount button click
function UIMainFastBtnsPanel:OnMountBtnClick()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if not _lp.IsOnMount then
        if _lp:CanUpMount() then
            _lp:MountUP()
            if _lp:IsXState(L_EntityStateID.ChuanDaoSitDown) then
                _lp:Action_Idle()
            end
        else
            Utils.ShowPromptByEnum("C_CUR_STATE_CANNOTMOUNT")
        end
    else
        _lp:MountDown(true)
    end
end
-- Update email
function UIMainFastBtnsPanel:UpdateMailNumPrompt(obj, sender)
    -- local _num = GameCenter.MailSystem:GetMailNumPrompt()
    -- self.MailBtn.gameObject:SetActive(_num > 0)
    -- if _num > 0 then
    --     UIUtils.SetTextByNumber(self.MailNum, _num)
    -- end
    -- self.Grid.repositionNow = true
end
-- Show Guest Button
function UIMainFastBtnsPanel:OnShowBingKeBtn(obj, sender)
    self.MarryBtn.gameObject:SetActive(true)
    self.Grid.repositionNow = true
end
-- Show email prompts
function UIMainFastBtnsPanel:OnShowMailTips(obj, sender)
    self.MailTips:SetActive(true)
end
-- Boss treasure chest display
function UIMainFastBtnsPanel:OnUpdateGuildBXCount(obj, sender)
    local _curCount = GameCenter.GuildSystem.BoxNum
    local _func = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.GuildFuncTypeBox)
    if _curCount > 0 and _func and _func.IsVisible then
        UIUtils.SetTextByNumber(self.BXNum, _curCount)
        self.BXBtn.gameObject:SetActive(true)
    else
        self.BXBtn.gameObject:SetActive(false)
    end
    self.Grid.repositionNow = true
end
-- Treasure box button click
function UIMainFastBtnsPanel:OnBXBtnClick(obj, sender)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildFuncTypeBox)
end
-- Show gift status
function UIMainFastBtnsPanel:OnUpdatePresentState(obj, sender)
    local _num = GameCenter.PresentSystem:GetNotReadPresentCount()
    self.PresentBtn.gameObject:SetActive(_num > 0)
end
-- Display support button
function UIMainFastBtnsPanel:UpdateSupportShow(obj, sender)
    self.SupportRed:SetActive(true)
end
-- Guild Information Update
function UIMainFastBtnsPanel:GuildInfoUpdate(obj, sender)
    self.SupportBtn.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WorldSupport) and GameCenter.GuildSystem:HasJoinedGuild())
end
-- Click on the email button
function UIMainFastBtnsPanel:MailBtnOnClick()
    self.MailTips:SetActive(false)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Mail)
end
-- Support button click
function UIMainFastBtnsPanel:SupportBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportForm_Open)
    self.SupportRed:SetActive(false)
    GameCenter.WorldSupportSystem:SetXmSupportRedState(false)
end
-- Refresh Limited Time Store Button
function UIMainFastBtnsPanel:RefrshLimitShopState(obj, sender)
    self.LimitShopBtn.gameObject:SetActive(obj)
    self:OnNewLimitShopRefresh(nil)
end
-- Limited time store button click
function UIMainFastBtnsPanel:LimitShopCallBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, 16)
    GameCenter.PushFixEvent(UILuaEventDefine.UILimitShopTipsForm_CLOSE)
    GameCenter.LimitShopSystem:HideNewShopTips()
end
-- Free button click
function UIMainFastBtnsPanel:OnPresentBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIGetPresentTipsForm_OPEN)
end
-- Marriage button click
function UIMainFastBtnsPanel:OnMarryBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.MarryInvite)
    self.MarryBtn.gameObject:SetActive(false)
    self.Grid.repositionNow = true
end
-- Limited time store button refresh
function UIMainFastBtnsPanel:OnNewLimitShopRefresh(obj, sender)
    if GameCenter.LimitShopSystem:IsExistNewShop() then
        GameCenter.LimitShopSystem:HideNewShopTips();
        GameCenter.PushFixEvent(UILuaEventDefine.UILimitShopTipsForm_OPEN, self.LimitShopBtn.transform)
    end
end
-- Mysterious store button refresh
function UIMainFastBtnsPanel:OnSMShopMainIconUpdated(obj, sender)
    local _iconList = GameCenter.MainLimitIconSystem.IconList
    local _count = #_iconList
    for i = 1, 4 do
        if i <= _count then
            self.SmIcons[i]:SetInfo(_iconList[i])
        else
            self.SmIcons[i]:SetInfo(nil)
        end
    end
    self.SmGrid.repositionNow = true
end

-- Guild Exit Event
function UIMainFastBtnsPanel:OnGuildExit(obj, sender)
    self.SupportBtn.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WorldSupport) and GameCenter.GuildSystem:HasJoinedGuild())
end

function UIMainFastBtnsPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.TimeCount < 1 then
        self.TimeCount = self.TimeCount + dt
    else
        self.TimeCount = 0
        local _state = GameCenter.WorldSupportSystem.RedPoint
        if _state ~= self.SupportRed.activeSelf then
            self.SupportRed:SetActive(_state)
        end
    end
    local _refresh = false
    local _serverTime = GameCenter.HeartSystem.ServerZoneTime
    for i = 1, #self.SmIcons do
        if self.SmIcons[i]:Update(_serverTime) then
            _refresh = true
        end
    end
    if _refresh then
        GameCenter.MainLimitIconSystem.IsRefresh = true
    end
    local _hdRmTime = GameCenter.HuSongSystem.ReMainTime
    if _hdRmTime > 0 then
        if not self.ShowHuSong then
            self.HuSongGo:SetActive(true)
            self.FrontHuSongTime = -1
            self.SmGrid.repositionNow = true
        end
        self.ShowHuSong = true
        local _iTime = math.floor(_hdRmTime)
        if self.FrontHuSongTime ~= _iTime then
            self.FrontHuSongTime = _iTime
            UIUtils.SetTextHHMMSS(self.HuSongTime, _iTime)
        end
    else
        if self.ShowHuSong then
            self.HuSongGo:SetActive(false)
            self.SmGrid.repositionNow = true
        end
        self.ShowHuSong = false
    end

    local _curHunYanState = GameCenter.MarriageSystem.CurHunYanState
    if _curHunYanState ~= self.FrontHunYanState then
        self.FrontHunYanState = _curHunYanState
        self.FrontHunYanTime = -1
        if _curHunYanState == 1 then
            self.HunYanGo:SetActive(true)
        elseif _curHunYanState == 2 then
            self.HunYanGo:SetActive(true)
        else
            self.HunYanGo:SetActive(false)
        end
        self.SmGrid.repositionNow = true
    end
    local _hyEnum = nil
    if _curHunYanState == 1 then
        _hyEnum = "C_HUNYAN_OPENTIME"
    elseif _curHunYanState == 2 then
        _hyEnum = "C_HUNYAN_CLOSETIME"
    end
    local _iTime = math.floor(GameCenter.MarriageSystem.CurHunYanRemainTime)
    if _hyEnum ~= nil and self.FrontHunYanTime ~= _iTime then
        self.FrontHunYanTime = _iTime
        UIUtils.SetTextByEnum(self.HunYanTime ,_hyEnum, _iTime // 60, _iTime % 60)
    end
end

L_SMShopIcon = {
    RootGo = nil,
    RootTrans = nil,
    Btn = nil,
    Name = nil,
    RemainTime = nil,
    Icon = nil,

    FrontUpdateTime = -1,
    IconInfo = nil,
}

function L_SMShopIcon:New(rootTrans)
    local _m = Utils.DeepCopy(self)
    _m.RootTrans = rootTrans
    _m.RootGo = rootTrans.gameObject
    _m.Name = UIUtils.FindLabel(rootTrans, "Name")
    _m.RemainTime = UIUtils.FindLabel(rootTrans, "Time")
    _m.Icon = UIUtils.FindSpr(rootTrans)
    _m.Btn = UIUtils.FindBtn(rootTrans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    return _m
end

function L_SMShopIcon:SetInfo(iconInfo)
    self.IconInfo = iconInfo
    if iconInfo ~= nil then
        self.Icon.spriteName = iconInfo.IconName
        UIUtils.SetTextByString(self.Name, iconInfo.Name)
        self.Btn.normalSprite = iconInfo.IconName
        self.Btn.hoverSprite = iconInfo.IconName
        self.Btn.disabledSprite = iconInfo.IconName
        self.Btn.pressedSprite = iconInfo.IconName
        self.FrontUpdateTime = -1
        self.RootGo:SetActive(true);
    else
        self.RootGo:SetActive(false);
    end
end
function L_SMShopIcon:Update(serverTime)
    if self.IconInfo == nil then
        return false
    end
    local _remainTime = self.IconInfo.EndTimeStamp - serverTime;
    if _remainTime < 0 then
        self.IconInfo = nil
        self.RootGo:SetActive(false)
        return true
    else
        _remainTime = math.floor(_remainTime)
        if _remainTime ~= self.FrontUpdateTime then
            self.FrontUpdateTime = _remainTime
            UIUtils.SetTextHHMMSS(self.RemainTime, self.FrontUpdateTime)
        end
        return false;
    end
end
function L_SMShopIcon:OnClick()
    if self.IconInfo ~= nil then
        self.IconInfo.ClickCallBack(self.IconInfo.Params)
    end
end

return UIMainFastBtnsPanel