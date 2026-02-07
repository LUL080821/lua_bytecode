------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIDailyActivityForm.lua
-- Module: UIDailyActivityForm
-- Description: Daily Activities Form
------------------------------------------------
local UIDailyActivityForm = {
    -- menu
    ListMenu = nil,
    -- Close button
    CloseBtn = nil,
    -- Background stickers
    BgTex = nil,
    -- Special effects components
    VfxComp = nil,
    -- Special Effect Transform
    VfxTrans = nil,
    -- Frame animation index
    Index = 1,
    -- Countdown time
    TimeCount = 0,
    -- Frame animation
    FrameAnim = nil,
    -- Play frame animation
    PlayFrameAnim = false,
    -- Cache opens the daily interface. The parameters passed in
    CatchParams = nil,
    -- Sub-panel Root Container
    RootContainer = Dictionary:New(),
    -- The currently selected page
    CurrSelect = ActivityPanelTypeEnum.Daily
}

local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"
local UIWeekRoot = require "UI.Forms.UIDailyActivityForm.Root.UIWeekRoot"
local UIActiveRoot = require "UI.Forms.UIDailyActivityForm.Root.UIActiveRoot"
local UIActivityRoot = require "UI.Forms.UIDailyActivityForm.Root.UIActivityRoot"
local UILimitRoot = require "UI.Forms.UIDailyActivityForm.Root.UILimitRoot"
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

function UIDailyActivityForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIDailyActivityForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIDailyActivityForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_REFRESH_DAILYPANEL, self.RefreshPanelByMsg)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ACTIVEPANEL, self.RefreshActivePanel)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_REFRESH_ACTIVITYLIST, self.RefreshActivityList)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_DAILY_PLAYVFX, self.OnPlayVfx)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_DAILY_STOPVFX, self.OnStopVfx)
end

function UIDailyActivityForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIDailyActivityForm:OnShowBefore()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    GameCenter.DailyActivitySystem:ReqActivePanel()
    GameCenter.DailyActivitySystem:ReqCrossServerMatch()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
end

function UIDailyActivityForm:OnHideBefore()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self:OnStopVfx()
    self.CatchParams = nil
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UIDailyActivityForm:Update(dt)
    self.AnimPlayer:Update(dt)
    self.RootContainer[ActivityPanelTypeEnum.Daily]:Update(dt)
    self.RootContainer[ActivityPanelTypeEnum.Limit]:Update(dt)
    if self.PlayFrameAnim then
        self.TimeCount = self.TimeCount + Time.GetDeltaTime()
        if self.TimeCount > 0.04 then
            self.FrameAnim.spriteName = string.format("task_%02d", self.Index)
            self.Index = 1 + self.Index
            if self.Index > 17 then
                self.Index = 1
            end
            self.TimeCount = 0
        end
    end
end

function UIDailyActivityForm:OnOpen(obj, sender)

    self.CSForm:Show(sender)
    self:LoadBgTex()
    if obj then
        self.CatchParams = obj
    end
    self.CurrSelect = ActivityPanelTypeEnum.Daily
    self:RefreshPanel()
end

function UIDailyActivityForm:OnClose(obj, sender)
    self.CSForm:Hide()
    -- self.RootContainer[ActivityPanelTypeEnum.Push]:CheckPustActivityList()
end

function UIDailyActivityForm:OnTryHide()
    if not self.RootContainer[ActivityPanelTypeEnum.Active]:OnTryHide() then
        return false
    end
    return true
end
    

function UIDailyActivityForm:FindAllComponents()
    local _trans = self.CSForm.transform
    self.CloseBtn = UIUtils.FindBtn(_trans, "Top/CloseButton")
    self.BgTex = UIUtils.FindTex(_trans, "Center/Back/BG")
    self.CSForm:AddNormalAnimation()

    self.VfxTrans = UIUtils.FindTrans(_trans, "Center/UIVfxSkinCompoent")
    self.VfxComp = UIUtils.RequireUIVfxSkinCompoent(self.VfxTrans)
    self.VfxTrans.gameObject:SetActive(false)
    self.FrameAnim = UIUtils.FindSpr(_trans, "Center/UIVfxSkinCompoent/Vfx")

    local _weekRoot = UIUtils.FindTrans(_trans, "Center/WeekRoot")
    local _pushRoot = UIUtils.FindTrans(_trans, "Center/PushRoot")
    local _activeRoot = UIUtils.FindTrans(_trans, "Bottom/ActiveRoot")
    local _dailyRoot = UIUtils.FindTrans(_trans, "Center/DailyActivityRoot")
    self.BgDailyTex = UIUtils.FindTex(_trans, "Center/DailyActivityRoot/Back/BgTex")
    self.BgLimitTex = UIUtils.FindTex(_trans, "Center/LimitActivityRoot/Back/BgTex")
    local _limitRoot = UIUtils.FindTrans(_trans, "Center/LimitActivityRoot")
    self.RootContainer[ActivityPanelTypeEnum.Week] = UIWeekRoot:New(self, _weekRoot)
    -- self.RootContainer[ActivityPanelTypeEnum.Push] = UIPushRoot:New(self, _pushRoot)
    self.RootContainer[ActivityPanelTypeEnum.Active] = UIActiveRoot:New(self, _activeRoot)
    self.RootContainer[ActivityPanelTypeEnum.Daily] = UIActivityRoot:New(self, _dailyRoot)
    self.RootContainer[ActivityPanelTypeEnum.Limit] = UILimitRoot:New(self, _limitRoot)

    local _listMenu = UIUtils.FindTrans(_trans, "Right/UIListMenu")
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, _listMenu)
    self.ListMenu:AddIcon(ActivityPanelTypeEnum.Daily, DataConfig.DataMessageString.Get("C_FUBEN_RICHANG"),
        FunctionStartIdCode.DailyActivity, "jm_icon_richang", nil, "jm_icon_richanghuang")
    self.ListMenu:AddIcon(ActivityPanelTypeEnum.Limit, DataConfig.DataMessageString.Get("C_UI_SHOPMALL_TIMELIMITTYPE"),
        FunctionStartIdCode.LimitActivity, "jm_icon_xiangshi", nil, "jm_icon_xiangshihuang")
    self.ListMenu:AddIcon(ActivityPanelTypeEnum.Target, DataConfig.DataMessageString.Get("C_DAILY_MUBIAO"),
        FunctionStartIdCode.TargetTask, "jm_icon_zhouli", nil, "jm_icon_zhoulihuang")
        -- TODO: Mở lại sau
    -- self.ListMenu:AddIcon(ActivityPanelTypeEnum.Week, DataConfig.DataMessageString.Get("Calendar"),
    --     FunctionStartIdCode.Calendar, "jm_icon_zhouli", nil, "jm_icon_zhoulihuang")
    -- -- self.ListMenu:AddIcon(ActivityPanelTypeEnum.Push, "Push")
    -- self.ListMenu:AddIcon(ActivityPanelTypeEnum.ResGetBack, DataConfig.DataMessageString.Get("RESOURCE_RECOVERY"),
    --     FunctionStartIdCode.ResBack)
    -- self.ListMenu:AddIcon(ActivityPanelTypeEnum.CrossShow, DataConfig.DataMessageString.Get("CrossServerShow"),
    --     FunctionStartIdCode.CrossShow)

    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_trans, "UIMoneyForm"))
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    -- self.ListMenu:SetRedPoint(ActivityPanelTypeEnum.Week, false)
    -- self.ListMenu:SetRedPoint(ActivityPanelTypeEnum.Push, false)
end

function UIDailyActivityForm:LoadBgTex()
    self.CSForm:LoadTexture(self.BgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_2"))
    --self.CSForm:LoadTexture(self.BgDailyTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_109"))
    self.CSForm:LoadTexture(self.BgLimitTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_2"))
end

function UIDailyActivityForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClose, self)
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
end

function UIDailyActivityForm:OnClickCallBack(id, selected)
    if selected then
        if id == ActivityPanelTypeEnum.ResGetBack then
            self.RootContainer[ActivityPanelTypeEnum.Active]:Close()
            GameCenter.PushFixEvent(UIEventDefine.UIResBackForm_Open, nil, self.CSForm)
        elseif id == ActivityPanelTypeEnum.CrossShow then
            self.RootContainer[ActivityPanelTypeEnum.Active]:Close()
            GameCenter.DailyActivitySystem:ReqCrossServerMatch()
            GameCenter.PushFixEvent(UILuaEventDefine.UICrossServerMapForm_OPEN, nil, self.CSForm)
        elseif id == ActivityPanelTypeEnum.Target then
            self.RootContainer[ActivityPanelTypeEnum.Active]:Close()
            GameCenter.PushFixEvent(UIEventDefine.UITargetForm_OPEN, nil, self.CSForm)
        else
            self.RootContainer[id]:Show()
            if id == ActivityPanelTypeEnum.Daily then
                
                self.RootContainer[ActivityPanelTypeEnum.Active]:Show()
                self.RootContainer[ActivityPanelTypeEnum.Daily]:RefreshActivity(
                    GameCenter.DailyActivitySystem.DailyActivitylist, self.CatchParams, self.VfxTrans)
            elseif id == ActivityPanelTypeEnum.Limit then
                --ẩn độ sôi nổi ở hạn giò
                self.RootContainer[ActivityPanelTypeEnum.Active]:Close()
                self.RootContainer[ActivityPanelTypeEnum.Limit]:RefreshActivity(
                    GameCenter.DailyActivitySystem.LimitActivityList, self.CatchParams, self.VfxTrans)
            else
                self.RootContainer[ActivityPanelTypeEnum.Active]:Close()
            end
        end
        self.CurrSelect = id
    else
        if id == ActivityPanelTypeEnum.ResGetBack then
            GameCenter.PushFixEvent(UIEventDefine.UIResBackForm_Close)
        elseif id == ActivityPanelTypeEnum.CrossShow then
            GameCenter.PushFixEvent(UILuaEventDefine.UICrossServerMapForm_CLOSE)
        elseif id == ActivityPanelTypeEnum.Target then
            GameCenter.PushFixEvent(UIEventDefine.UITargetForm_CLOSE)
        else
            self.RootContainer[id]:Close()
        end
    end
    -- self.CatchParams = nil
end

-- Play special effects
function UIDailyActivityForm:OnPlayVfx()
    self.Index = 1
    self.PlayFrameAnim = true
    self.VfxTrans.gameObject:SetActive(true)
end

-- Stop the special effects
function UIDailyActivityForm:OnStopVfx()
    self.Index = 1
    self.PlayFrameAnim = false
    self.VfxTrans.gameObject:SetActive(false)
    if self.VfxTrans then
        self.VfxTrans.parent = UIUtils.FindTrans(self.CSForm.transform, "Center")
        UnityUtils.ResetTransform(self.VfxTrans)
    end
    self.CatchParams = nil
end

-- Create special effects
function UIDailyActivityForm:OnCreateVfx()
    if self.VfxComp then
        self.VfxComp:OnCreateVfx(ModelTypeCode.UIVFX, 004)
        self.VfxComp:OnSetInfo(LayerUtils.GetAresUILayer())
    end
end

-- Daily panel refresh
function UIDailyActivityForm:RefreshPanel(obj, sender)
    if self.CatchParams then
        if self.CatchParams < 0 then -- Target task interface
            self.CurrSelect = - self.CatchParams;
        elseif GameCenter.DailyActivitySystem:CheckDailyListContains(self.CatchParams) then
            self.CurrSelect = ActivityPanelTypeEnum.Daily
        elseif GameCenter.DailyActivitySystem:CheckLimitListContains(self.CatchParams) then
            self.CurrSelect = ActivityPanelTypeEnum.Limit
        end
    end
    -- local _dailyRed = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.DailyActivity, 1)
    -- local _limitRed = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.DailyActivity, 2)
    -- self.ListMenu:SetRedPoint(ActivityPanelTypeEnum.Daily, _dailyRed)
    -- self.ListMenu:SetRedPoint(ActivityPanelTypeEnum.Limit, _limitRed)
    self.ListMenu:SetSelectById(self.CurrSelect)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
end

-- Daily active value refresh
function UIDailyActivityForm:RefreshActivePanel(obj, sender)
    self.RootContainer[ActivityPanelTypeEnum.Active]:RefreshPanel()
end

-- Daily activities refresh
function UIDailyActivityForm:RefreshActivityList(obj, sennder)
    if obj and obj == ActivityTypeEnum.Limit then
        self.RootContainer[ActivityPanelTypeEnum.Limit]:RefreshActivity(GameCenter.DailyActivitySystem.LimitActivityList)
    end
end

-- Message refresh interface
function UIDailyActivityForm:RefreshPanelByMsg(obj, sennder)
    if self.CurrSelect == ActivityPanelTypeEnum.Daily then
        self.RootContainer[ActivityPanelTypeEnum.Daily]:RefreshActivity(
            GameCenter.DailyActivitySystem.DailyActivitylist, self.CatchParams, self.VfxTrans, true)
    elseif self.CurrSelect == ActivityPanelTypeEnum.Limit then
        self.RootContainer[ActivityPanelTypeEnum.Limit]:RefreshActivity(GameCenter.DailyActivitySystem.LimitActivityList)
    else
        self.ListMenu:SetSelectById(self.CurrSelect)
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
end

return UIDailyActivityForm
