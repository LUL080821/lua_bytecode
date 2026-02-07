------------------------------------------------
-- author:
-- Date: 2021-02-22
-- File: UIMainForm.lua
-- Module: UIMainForm
-- Description: Main interface
------------------------------------------------
local L_UIUtility = CS.Thousandto.Plugins.Common.UIUtility
local MainFunctionSystem = CS.Thousandto.Code.Logic.MainFunctionSystem

local UIMainForm = {
    -- Pagination list
    SubPanels           = nil,
    -- Pagination that needs to be updated
    NeedUpdatePanel     = nil,
    -- Main Menu
    MainMenuPanel       = nil,
    FrontClickTime      = 0,
    MenuBtn             = nil,
    MenuRedPoint        = nil,
    MenuOpen            = nil,
    MenuClose           = nil,
    MainMenuIsOpen      = false,
    -- Become stronger
    PromotionScrollView = nil,
    PromotionBtn = nil,
    Promotioninfo = nil,
    PromotionGrid = nil,
    PromotionFunctionList = List:New(),
    PromotionClone = nil,
    PromotionClose = nil,
    PromotionUIList = List:New(),
    PromotionShouChong = nil,
    PromotionZheKou = nil,
    PromotionZheKou2 = nil,
    PromotionTeQuan = nil,
    PromotionChengZhang = nil,
    PromotionDailyGift = nil,
    PromotionBack = nil,
    PromotionTipsGo = nil,
    -- Level Pack Tips
    BtnLevelGiftTips = nil,
    TxtLevelGiftTips = nil,
    GoVFXLevelGiftTips = nil,
    -- Hang up button
    StartGuaJiBtn = nil,
    EndGuaJiBtn = nil,
    -- Flying sword
    FlySwordSkillTips = nil,
    FlySwordTex = nil,
    FlySwordSkillTimer = 0,
    --wifi
    WifiAndTimePage = nil,
    --trans
    LeftTopTrans = nil,
    LeftButtomTrans = nil,
    TopTrans = nil,
    RightTopTrans = nil,
    RightTop2Trans = nil,
    RightTrans = nil,
    RightButtomTrans = nil,
    RightButtomTrans2 = nil,
    ButtomTrans = nil,
    -- The main interface hides the counter to determine whether it is hidden
    HideCounter = 0,
    -- New friend tips
    NoticNewFriend = nil,
    FriendShipNotic = nil,
    -- Welcome interface
    WeleComePanel = nil,

    -- Mission tips
    ChuanDaoTips = nil,
    ChuanDaoTipsTex = nil,
    ChuanDaoTipsLabel = nil,
    ChuanDaoTipsBtn = nil,
    ChuanDaoTipsIsShow = false,

    -- Today's Event Button
    TodayFuncBtn = nil,
    TodayFuncRedPoint = nil,
    TodayFuncEffect = nil,
    RightBottom3 = nil,
    Setting = nil,

    -- Prison detail
    RightSK = nil,
    PkCountLabel = 0,
    IdPrisonLabel = 0,
}

function UIMainForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIMainForm_OPEN, self.OnOpen, self)
    self:RegisterEvent(UIEventDefine.UIMainForm_CLOSE, self.OnClose, self)

    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnChangeMap, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ENTER_PRISON_MAP, self.OnEnterPrisonMap, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LEAVE_PRISON_MAP, self.OnLeavePrisonMap, self)
    -- Refresh the main interface paging status when entering the map
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_SUBPANELOPENSTATE, self.OnSubPanelStateRefresh, self)
    -- Open a page on the main interface
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_OPENSUBPANEL, self.OnOpenSubPanel, self)
    -- Close a page on the main interface
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_CLOSESUBPANEL, self.OnCloseSubPanel, self)
    -- Play animation
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION, self.OnPlayShowAnimation, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION, self.OnPlayHideAnimation, self)
    -- Show Boss skill release prompts
    self:RegisterEvent(LogicEventDefine.EID_EVENT_SHOWSKILLWARNING_EFFECT, self.OnShowSkillWarningEffect, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnUpdateFunc, self)
    -- menu
    self:RegisterEvent(LogicEventDefine.EID_EVENT_OPEN_MAINMENU, self.OnOpenMainMenu, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_CLOSE_MAINMENU, self.OnCloseMainMenu, self)
    -- Changed status
    self:RegisterEvent(LogicEventDefine.EID_EVENT_MANDATE_STATE_CHANGED, self.UpdateMandateState, self)
    -- Change of transformation state
    self:RegisterEvent(LogicEventDefine.EID_EVENT_CHANGE_SKILL_CHANGED, self.OnChangeModelEvent, self)
    -- Play the flying sword skills
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAY_FLYSWORD_SKILL, self.OnPlayFlySwordSkill, self)
    -- Level gift pack Tips status refresh
    self:RegisterEvent(LogicLuaEventDefine.EID_LEVELGIFTTIPS_REFRESH, self.OnLevelGiftTipsRefresh, self)
    -- The main interface displays a prompt to become stronger
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MAINFORM_SHOWBIANQIANG, self.OnShowBianQiangTips, self)
    -- Open the welcome interface
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_OPEN_WELECOME_PANEL, self.OnOpenWeleComePanel, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UNLOAD_WELECOME_RES, self.OnUnLoadWeleComeRes, self)
    -- Tips for new friends
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC , self.NewFriendNotic , self)
    -- Someone sends a friendship point
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_FRIENDSHIP , self.FriendShipNoticFun ,self)
    -- Main interface tryhide
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_MIANUI_TRY_HIDE , self.OnTryHide ,self)
    -- Refresh the preaching tips
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CHUANDAOTIPS , self.OnRefreshChuanDaoTips ,self)

    -- [Gosu]
    self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_GOSU_PK_POINT, self.UpdatePKPoint, self) -- nghe từ C#
end

local L_UIMainPromotion = nil

function UIMainForm:hideCutScene()
    if not AppConfig.IsShowCutScene then return end
    self.LeftTop:SetActive(false)
    self.LeftBottom:SetActive(false)
    self.Right:SetActive(false)
    self.Top:SetActive(false)
    self.Bottom:SetActive(false)
    self.Center:SetActive(false)
    -- self.RightTop:SetActive(false)
    self.RightTop2:SetActive(false)
    -- self.RightBottom:SetActive(false)
    self.RightBottom2:SetActive(false)

    self.RightTopTopMenu:SetActive(false)
    self.RightBottomStartGuaJiBtn:SetActive(false)
    self.RightBottomChuanDaoTips:SetActive(false)
    self.RightBottomFastPrompt:SetActive(false)
end

function UIMainForm:OnFirstShow()
    self.SubPanels = {}
    self.NeedUpdatePanel = List:New()
    for i = 1, MainFormSubPanel.Count do
        local _panel, _needupdate = self:CreateSubPanel(i)
        self.SubPanels[i] = _panel
        if _needupdate then
            self.NeedUpdatePanel:Add(_panel)
        end
    end
    self.MainMenuIsOpen = false

    local _trans = self.Trans

    self.LeftTop = UIUtils.FindGo(_trans, "LeftTop")
    self.LeftBottom = UIUtils.FindGo(_trans, "LeftBottom")
    self.Right = UIUtils.FindGo(_trans, "Right")
    self.Top = UIUtils.FindGo(_trans, "Top")
    self.Bottom = UIUtils.FindGo(_trans, "Bottom")
    self.Center = UIUtils.FindGo(_trans, "Center")
    self.RightTop = UIUtils.FindGo(_trans, "RightTop")
    self.RightTop2 = UIUtils.FindGo(_trans, "RightTop2")
    self.RightBottom = UIUtils.FindGo(_trans, "RightBottom")
    self.RightBottom2 = UIUtils.FindGo(_trans, "RightBottom2")

    self.RightTopTopMenu = UIUtils.FindGo(_trans, "RightTop/TopMenu")
    self.RightBottomStartGuaJiBtn = UIUtils.FindGo(_trans, "RightBottom/StartGuaJiBtn")
    self.RightBottomChuanDaoTips = UIUtils.FindGo(_trans, "RightBottom/ChuanDaoTips")
    self.RightBottomFastPrompt = UIUtils.FindGo(_trans, "RightBottom/FastPrompt")

    self.MainMenuPanel = require("UI.Forms.UIMainForm.UIMainMenuPanel")
    self.MainMenuPanel:OnFirstShow(UIUtils.FindTrans(_trans, "RightBottom2/MenuPanel"), self, self)

    self.MenuBtn = UIUtils.FindBtn(_trans, "RightBottom2/MenuBtn")
    self.MenuBtn.gameObject:SetActive(false)
    UIUtils.AddBtnEvent(self.MenuBtn, self.OnMenuBtnClick, self)
    self.MenuRedPoint = UIUtils.FindGo(_trans, "RightBottom2/MenuBtn/RedPoint")
    self.MenuOpen = UIUtils.FindGo(_trans, "RightBottom2/MenuBtn/Open")
    self.MenuClose = UIUtils.FindGo(_trans, "RightBottom2/MenuBtn/Close")

    self.PromotionBtn = UIUtils.FindBtn(_trans, "RightBottom2/Promotion/PromotionBtn")
    self.Promotioninfo = UIUtils.FindTrans(_trans, "RightBottom2/Promotion/Promotioninfo/Root")
    self.CSForm:AddTransNormalAnimation(self.Promotioninfo, 30, 0.3)
    self.PromotionGrid = UIUtils.FindGrid(_trans, "RightBottom2/Promotion/Promotioninfo/Root/Panel/PromotionGrid")
    self.PromotionClone = UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/Panel/PromotionGrid/PromotionClone")
    self.PromotionUIList:Clear()
    self.PromotionUIList:Add(L_UIMainPromotion:New(self.PromotionClone))
    self.PromotionClose = UIUtils.FindBtn(_trans, "RightBottom2/Promotion/Promotioninfo/Root/PromotionClose")
    self.PromotionScrollView = UIUtils.FindScrollView(_trans, "RightBottom2/Promotion/Promotioninfo/Root/Panel")
    self.PromotionShouChong = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/ShouChong"))
    self.PromotionZheKou = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/ZheKou"))
    self.PromotionZheKou2 = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/ZheKou2"))
    self.PromotionTeQuan = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/TeQuanKa"))
    self.PromotionChengZhang = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/ChengZhang"))
    self.PromotionDailyGift = L_UIMainPromotion:New(UIUtils.FindGo(_trans, "RightBottom2/Promotion/Promotioninfo/Root/DailyGift"))
    self.PromotionBack = UIUtils.FindSpr(_trans, "RightBottom2/Promotion/Promotioninfo/Root/Bg")
    UIUtils.AddBtnEvent(self.PromotionBtn, self.OnClickPromotionBtn, self)
    UIUtils.AddBtnEvent(self.PromotionClose, self.OnClickPromotionClose, self)
    self.PromotionTipsGo = UIUtils.FindGo(_trans, "RightBottom2/Promotion/PromotionBtn/Vfx")

    self.BtnLevelGiftTips = UIUtils.FindBtn(_trans, "RightBottom2/BtnLevelGiftTips")
    self.TxtLevelGiftTips = UIUtils.FindLabel(_trans, "RightBottom2/BtnLevelGiftTips/Name")
    self.GoVFXLevelGiftTips = UIUtils.FindGo(_trans, "RightBottom2/BtnLevelGiftTips/Effect")
    UIUtils.AddBtnEvent(self.BtnLevelGiftTips, self.OnBtnLevelGiftTipsClick, self)

    self.StartGuaJiBtn = UIUtils.FindBtn(_trans, "RightBottom/StartGuaJiBtn")
    UIUtils.AddBtnEvent(self.StartGuaJiBtn, self.OnGuaJiBtnClick, self)
    self.EndGuaJiBtn = UIUtils.FindBtn(_trans, "RightBottom/StopGuaJiBtn")
    UIUtils.AddBtnEvent(self.EndGuaJiBtn, self.OnGuaJiBtnClick, self)

    self.FlySwordSkillTips = UIUtils.FindGo(_trans, "FlySwordSkill")
    self.FlySwordTex = UIUtils.FindTex(_trans, "FlySwordSkill/Texture")

    self.WifiAndTimePage = require("UI.Forms.UIMainForm.UIMainWifiAndTimePanel")
    self.WifiAndTimePage:OnFirstShow(UIUtils.FindTrans(_trans, "LeftBottom/WifiAndTime"), self, self)

    self.WeleComePanel = require("UI.Forms.UIMainForm.UIMainWeleComePanel")
    self.WeleComePanel:OnFirstShow(UIUtils.FindTrans(_trans, "WeleComePanel"), self, self)

    self.LeftTopWid = UIUtils.FindWid(_trans, "LeftTop")
    self.LeftButtomWid = UIUtils.FindWid(_trans, "LeftBottom")

    self.LeftTopTrans = UIUtils.FindTrans(_trans, "LeftTop")
    self.CSForm:AddAlphaPosAnimation(self.LeftTopTrans, 0, 1, 0, 400, 0.5, false, false)
    self.LeftButtomTrans = UIUtils.FindTrans(_trans, "LeftBottom")
    self.CSForm:AddAlphaPosAnimation(self.LeftButtomTrans, 0, 1, 0, -100, 0.5, false, false)
    self.TopTrans = UIUtils.FindTrans(_trans, "Top")
    self.CSForm:AddAlphaPosAnimation(self.TopTrans, 0, 1, 0, 400, 0.5, false, false)
    self.RightTopTrans = UIUtils.FindTrans(_trans, "RightTop")
    self.CSForm:AddAlphaPosAnimation(self.RightTopTrans, 0, 1, 0, 300, 0.5, false, false)
    self.RightTop2Trans = UIUtils.FindTrans(_trans, "RightTop2")
    self.CSForm:AddAlphaPosAnimation(self.RightTop2Trans, 0, 1, 400, 0, 0.5, false, false)
    self.RightTrans = UIUtils.FindTrans(_trans, "Right")
    self.CSForm:AddAlphaPosAnimation(self.RightTrans, 0, 1, 0, 400, 0.5, false, false)
    self.RightButtomTrans = UIUtils.FindTrans(_trans, "RightBottom")
    self.CSForm:AddAlphaPosAnimation(self.RightButtomTrans, 0, 1, 400, 0, 0.5, false, false)
    self.RightButtomTrans2 = UIUtils.FindTrans(_trans, "RightBottom2")
    self.CSForm:AddAlphaPosAnimation(self.RightButtomTrans2, 0, 1, 400, 0, 0.5, false, false)
    self.ButtomTrans = UIUtils.FindTrans(_trans, "Bottom")
    self.CSForm:AddAlphaPosAnimation(self.ButtomTrans, 0, 1, 0, -400, 0.5, false, false)
    self.NoticNewFriend = UIUtils.FindGo(_trans, "Bottom/MiniChat/SheJiao/NoticNewF")
    self.FriendShipNotic = UIUtils.FindGo(_trans ,"Bottom/MiniChat/SheJiao/RedPointShip" )

    self.ChuanDaoTips = UIUtils.FindGo(_trans, "RightBottom/ChuanDaoTips")
    self.ChuanDaoTipsTex = UIUtils.FindTex(_trans, "RightBottom/ChuanDaoTips/Tex")
    self.ChuanDaoTipsLabel = UIUtils.FindLabel(_trans, "RightBottom/ChuanDaoTips/Tex/Level")
    self.ChuanDaoTipsBtn = UIUtils.FindBtn(_trans, "RightBottom/ChuanDaoTips/Tex")
    UIUtils.AddBtnEvent(self.ChuanDaoTipsBtn, self.OnChuanDaoTipsBtnClick, self)
    self.ChuanDaoTipsIsShow = false
    self.ChuanDaoTips:SetActive(false)

    self.TodayFuncBtn = UIUtils.FindBtn(_trans, "RightBottom/FastPrompt/TodayFun")
    UIUtils.AddBtnEvent(self.TodayFuncBtn, self.OnTodayFuncBtnClick, self)
    self.TodayFuncRedPoint = UIUtils.FindGo(_trans, "RightBottom/FastPrompt/TodayFun/RedPoint")
    self.TodayFuncEffect = UIUtils.FindGo(_trans, "RightBottom/FastPrompt/TodayFun/Effect")

    self.Setting = UIUtils.FindBtn(_trans, "RightBottom3/Setting")
    self.Setting.gameObject:SetActive(false)
    UIUtils.AddBtnEvent(self.Setting, self.OnSettingBtnClick, self)
    
    -- [Gosu]
    self.RightSK = UIUtils.FindGo(_trans, "RightSK")
    self.PkCountLabel = UIUtils.FindLabel(_trans, "RightSK/GroupSK/Back/SkillPointLabel")
    self.IdPrisonLabel = UIUtils.FindLabel(_trans, "RightSK/GroupSK/Back/IDSkillLabel")
end

-- Open the interface
function UIMainForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

-- [Gosu]
function UIMainForm:PrisonDetail(isShow)
    self.RightSK:SetActive(isShow)
end

function UIMainForm:UpdatePKPointIni()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()

    local prisonNameId = _lp.PrisonNameId or 0

    local prisonId = Utils.GetPrisonID(prisonNameId)

    if not _lp then
        return
    end
    local pk = _lp.PointSatKhi or 0

    if self.PkCountLabel then
        -- UIUtils.SetTextByNumber(self.PkCountLabel, pk)
        UIUtils.SetTextByEnum(self.PkCountLabel, "SK_POINT_MAIN", pk)
    end
    if self.IdPrisonLabel then
        -- Debug.Log("sprisonIdprisonIdprisonId,", Inspect(prisonId))
        -- UIUtils.SetTextByString(self.IdPrisonLabel, prisonId)
        UIUtils.SetTextByEnum(self.IdPrisonLabel, "PRISIONER_ID_MAIN", prisonId)
    end

end

-- Update PK Point

function UIMainForm:UpdatePKPoint(obj, sender)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if not lp then
        return
    end

    local pkPoint = lp.PointSatKhi or 0

    if self.PkCountLabel then
        -- UIUtils.SetTextByNumber(self.PkCountLabel, pkPoint)
        UIUtils.SetTextByEnum(self.PkCountLabel, "SK_POINT_MAIN", pkPoint)
    end
end


-- End Gosu

-- Close the interface
function UIMainForm:OnClose(obj, sender)
    for i = 1, MainFormSubPanel.Count do
        local _subPanel = self.SubPanels[i]
        if _subPanel ~= nil then
            _subPanel:Close()
        end
    end
    self.CSForm:Hide()
end
function UIMainForm:OnSettingBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIGameSettingForm_OPEN)
end
function UIMainForm:OnRefreshChuanDaoTips(obj, sender)
    local _showTips = false
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.ChuanDao) then
        local _point = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
        if _point > 0 then
            local _dSystem = GameCenter.DailyActivitySystem
            local _isActiveIsFull = _dSystem.CurrActive >= _dSystem.MaxActive
            if _isActiveIsFull then
                _showTips = true
            else
                _showTips = _point >= 150
            end
            if _showTips then
                local _cSystem = GameCenter.ChuanDaoSystem
                UIUtils.SetTextByEnum(self.ChuanDaoTipsLabel, "C_CHUANDAO_PREVIEW_LEVEL", CommonUtils.GetLevelDesc(math.floor(_cSystem.PreCalTarLevel)), math.floor(_cSystem.PreCalTarLevelPer * 100))
            end
        end
    end
    if self.ChuanDaoTipsIsShow ~= _showTips then
        self.ChuanDaoTipsIsShow = _showTips
        if _showTips then
            self.CSForm:LoadTexture(self.ChuanDaoTipsTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_icon_chuandao"))
        else
            self.CSForm:UnloadTexture(self.ChuanDaoTipsTex)
        end
        self.ChuanDaoTips:SetActive(_showTips)
    end
end

function UIMainForm:OnTodayFuncBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ToDayFunc)
end

function UIMainForm:OnChuanDaoTipsBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ChuanDao)
end

function UIMainForm:OnTryHide()
    if GameCenter.MapLogicSystem.ActiveLogic == nil then
        -- Not dealt with in worldstate
        return false
    end
    if self.WeleComePanel.IsVisible then
        self.WeleComePanel:OnStartBtnClick()
        return false
    end
    if not self.SubPanels[MainFormSubPanel.PlayerHead]:OnTryHide() then
        return false
    end
    if not self.SubPanels[MainFormSubPanel.TopMenu]:OnTryHide() then
        return false
    end
    if not self.SubPanels[MainFormSubPanel.CustomBtn]:OnTryHide() then
        return false
    end
    if not self.SubPanels[MainFormSubPanel.TaskAndTeam]:OnTryHide() then
        return false
    end
    if self.ShowPromotioninfo then
        self:OnClickPromotionClose()
        return false
    end
    local _curLan = FLanguage.Default
    local _isTw = false
    if _curLan ~= nil and _curLan ~= "" then
        _isTw = _curLan == "TW"
    end
    if _isTw then
        GameCenter.PushFixEvent(UILuaEventDefine.UIExitTipsForm_OPEN)
    else
        GameCenter.SDKSystem:ExitGame()
    end
    Debug.LogError("Exit the game!!" .. Time.GetFrameCount())
    return false
end

function UIMainForm:OnShowBefore()
end

function UIMainForm:OnShowAfter()
    self.CSForm.UIRegion = UIFormRegion.MainRegion
    MainFunctionSystem.MainFormIsCreated = true;
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        if _lp.IsChangeModel then
            self:OpenSubPanel(MainFormSubPanel.ChangeSkill)
            self:CloseSubPanel(MainFormSubPanel.Skill)
        else
            self:OpenSubPanel(MainFormSubPanel.Skill)
            self:CloseSubPanel(MainFormSubPanel.ChangeSkill)
        end
    end
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MainFuncRoot))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ToDayFunc))
    self:InitPromotionList()
    self:SetPromotion()
    self.FrontClickTime = 0
    self:UpdateMandateState(nil)
    self.HideCounter = 0
    self.CSForm:LoadTexture(self.FlySwordTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_jljx"))
    self.FlySwordSkillTips:SetActive(false)
    self.WifiAndTimePage:Open()
    MainFunctionSystem.IsShowingMainForm = true
    self.PromotionTipsGo:SetActive(false)
    self.CheckShowFrameCount = 30
    self:OnRefreshChuanDaoTips()

    
end

function UIMainForm:OnHideBefore()
end

function UIMainForm:OnHideAfter()
    MainFunctionSystem.MainFormIsCreated = false
end

-- Refresh the paging status
function UIMainForm:OnSubPanelStateRefresh(obj, sender)
    local _uiState = GameCenter.MapLogicSystem.MainUIState
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    for i = 1, MainFormSubPanel.Count do
        local _subPanel = self.SubPanels[i]
        if _subPanel ~= nil then
            local _isOpen = _uiState[i]
            if _isOpen then
                if i == MainFormSubPanel.Skill then
                    if not _lp.IsChangeModel then
                        _subPanel:Open()
                    end
                elseif i == MainFormSubPanel.ChangeSkill then
                    if _lp.IsChangeModel then
                        _subPanel:Open()
                    end
                else
                    _subPanel:Open()
                end
            else
                _subPanel:Close()
            end
        end
    end
    if GameCenter.MapLogicSwitch.IsCopyMap then
        self.CSForm:PlayHideAnimation(self.RightTopTrans)
    else
        self.CSForm:PlayShowAnimation(self.RightTopTrans)
    end
    self:OnCloseMainMenu(nil)
    self:InitPromotionList()
    self:SetPromotion()
    self:OnLevelGiftTipsRefresh(nil, nil)

    self:hideCutScene()

    -- [Gosu]
    self:UpdatePKPointIni()
end
-- Open a page
function UIMainForm:OnOpenSubPanel(subId, sender)
    if subId == nil or type(subId) ~= "number" then
        return
    end
    self:OpenSubPanel(subId)
end
-- Close a pagination
function UIMainForm:OnCloseSubPanel(subId, sender)
    if subId == nil or type(subId) ~= "number" then
        return
    end
    self:CloseSubPanel(subId)
end

-- Play animation
function UIMainForm:OnPlayShowAnimation(obj, sender)
    self.HideCounter = self.HideCounter - 1
    if self.HideCounter <= 0 then
        self.CSForm:PlayShowAnimation(self.LeftTopTrans)
        self.CSForm:PlayShowAnimation(self.LeftButtomTrans)
        self.CSForm:PlayShowAnimation(self.TopTrans)
        self.CSForm:PlayShowAnimation(self.RightTop2Trans)
        self.CSForm:PlayShowAnimation(self.RightTrans)
        if not self.MainMenuPanel.IsVisible then
            self.CSForm:PlayShowAnimation(self.RightButtomTrans)
        end
        self.CSForm:PlayShowAnimation(self.RightButtomTrans2)
        self.CSForm:PlayShowAnimation(self.ButtomTrans)

        if not GameCenter.MapLogicSwitch.IsCopyMap or self.MainMenuPanel.IsVisible then
            self.CSForm:PlayShowAnimation(self.RightTopTrans)
        end
        MainFunctionSystem.IsShowingMainForm = true
        self.CheckShowFrameCount = 30
        self.SubPanels[MainFormSubPanel.PlayerHead]:PlayZheKouAnim()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_MAINUISHOW_ANIM)
    end
    self:hideCutScene()
end
function UIMainForm:OnPlayHideAnimation(obj, sender)
    self.HideCounter = self.HideCounter + 1
    if self.HideCounter <= 1 then
        self.CSForm:PlayHideAnimation(self.LeftTopTrans, nil, false)
        self.CSForm:PlayHideAnimation(self.LeftButtomTrans, nil, false)
        self.CSForm:PlayHideAnimation(self.TopTrans, nil, false)
        self.CSForm:PlayHideAnimation(self.RightTop2Trans, nil, false)
        self.CSForm:PlayHideAnimation(self.RightTrans, nil, false)
        if not self.MainMenuPanel.IsVisible then
            self.CSForm:PlayHideAnimation(self.RightButtomTrans, nil, false)
        end
        self.CSForm:PlayHideAnimation(self.RightButtomTrans2, nil, false)
        self.CSForm:PlayHideAnimation(self.ButtomTrans, nil, false)

        if not GameCenter.MapLogicSwitch.IsCopyMap or self.MainMenuPanel.IsVisible then
            self.CSForm:PlayHideAnimation(self.RightTopTrans, nil, false)
        end
        MainFunctionSystem.IsShowingMainForm = false
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_MAINUIHIDE_ANIM)
    end
    self:hideCutScene()
end
-- Playing skills warning
function UIMainForm:OnShowSkillWarningEffect(obj, sender)
    -- The main menu does not display when it is opened
    if MainFunctionSystem.MainMenuIsShowed then
        return
    end
    local _text = obj[0]
    local _delayTime = obj[1]
    local _showTime = obj[2]
    local _warPanel = self.SubPanels[MainFormSubPanel.SkillWarning]
    if _warPanel ~= nil then
        _warPanel:OpenWarning(_text, _delayTime, _showTime)
    end
end

local function L_PromotionSort(left, right)
    return left.FunctionId < right.FunctionId
end
-- Update red dot enhancement
function UIMainForm:OnPromotionUpDate(funcInfo, funcId)
    local _ischange = false
    local _funcId = funcId
    local _cfg = DataConfig.DataFunctionStart[_funcId]
    if _cfg == nil then
        return
    end
    if _funcId == FunctionStartIdCode.BianQiang then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.LimitDicretShop then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.LimitDicretShop2 then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.FirstCharge then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.WelfareCard then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.WelfareInvestment then
        _ischange = true
    elseif _funcId == FunctionStartIdCode.WelfareDailyGift then
        _ischange = true
    elseif _cfg.Guide ~= 0 then
        if funcInfo.IsShowRedPoint then
            if not self.PromotionFunctionList:Contains(_cfg) then
                self.PromotionFunctionList:Add(_cfg)
                _ischange = true
            end
        else
            if self.PromotionFunctionList:Contains(_cfg) then
                self.PromotionFunctionList:Remove(_cfg)
                _ischange = true
            end
        end
    end
    if _ischange then
        self.PromotionFunctionList:Sort(L_PromotionSort)
        self:SetPromotion()
    end
end
function UIMainForm:OnClickPromotionBtn()
    self.CSForm:PlayShowAnimation(self.Promotioninfo)
    self.PromotionGrid:Reposition()
    self.PromotionScrollView.enabled = true
    self.PromotionScrollView:ResetPosition()
    self.PromotionScrollView.enabled = self.PromotionViewEnable
    self.PromotionTipsGo:SetActive(false)
    self.ShowPromotioninfo = true
end
function UIMainForm:OnClickPromotionClose()
    self.CSForm:PlayHideAnimation(self.Promotioninfo);
    self.ShowPromotioninfo = false
end
-- Improvement related
function UIMainForm:InitPromotionList()
    local _isChange = false
    self.PromotionFunctionList:Clear()
    local _func = function (k, v)
        if v.Guide ~= 0 and GameCenter.MainFunctionSystem:GetAlertFlag(k) then
            self.PromotionFunctionList:Add(v)
            _isChange = true
        end
    end
    DataConfig.DataFunctionStart:Foreach(_func)
    if _isChange then
        self.PromotionFunctionList:Sort(L_PromotionSort)
    end
end
function UIMainForm:SetPromotion()
    local _showShouChong = false
    local _showZheKou = false
    local _showZheKou2 = false
    local _showTeQuan = false
    local _showChengZhang = false
    local _showDailyGift = false
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _showShouChong = _lp.PropMoudle.CurRecharge <= 0
    end
    -- Privileges Card
    local _welfareCard = GameCenter.WelfareSystem.WelfareCard
    if _welfareCard ~= nil and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareCard) then
        if _welfareCard.OwnedCards == nil or _welfareCard.OwnedCards:Count() < 2 then
            _showTeQuan = true
        end
    end
    -- Growth funds pop up when no growth funds are purchased
    local grow = GameCenter.WelfareSystem.GrowthFund
    if grow ~= nil and not grow.IsBuy and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareInvestment) then
        _showChengZhang = true
    end
    _showZheKou = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.LimitDicretShop)
    _showZheKou2 = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.LimitDicretShop2)
    local _dailyGift = GameCenter.WelfareSystem.DailyGift
    if _dailyGift ~= nil and not _dailyGift.IsAllBuy and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareDailyGift) then
        _showDailyGift = true
    end
    local _funcCount = #self.PromotionFunctionList
    for i = 1, _funcCount do
        local _ui = nil
        if i <= #self.PromotionUIList then
            _ui = self.PromotionUIList[i]
        else
            _ui = L_UIMainPromotion:New(UnityUtils.Clone(self.PromotionClone))
            self.PromotionUIList:Add(_ui)
        end
        _ui:SetInfo(self.PromotionFunctionList[i], self)
    end
    for i = _funcCount + 1, #self.PromotionUIList do
        self.PromotionUIList[i]:SetInfo(nil, nil)
    end
    local _heightCount = 0
    if _funcCount > 3 then
        _heightCount = 3
        self.PromotionViewEnable = true
    else
        _heightCount = _funcCount
        self.PromotionViewEnable = false
    end
    local _hieght = _heightCount * 44 + 22
    if _showShouChong then
        -- Show first charge
        self.PromotionShouChong:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.FirstCharge], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionShouChong.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
        _showTeQuan = false
        _showChengZhang = false
        _showZheKou = false
        _showZheKou2 = false
        _showDailyGift = false
    else
        self.PromotionShouChong:SetInfo(nil, nil)
    end
    if _showTeQuan then
        -- Show privileged card
        self.PromotionTeQuan:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.WelfareCard], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionTeQuan.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
        _showChengZhang = false
        _showZheKou = false
        _showZheKou2 = false
        _showDailyGift = false
    else
        self.PromotionTeQuan:SetInfo(nil, nil)
    end
    if _showChengZhang then
        -- Show Growth Fund
        self.PromotionChengZhang:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.WelfareInvestment], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionChengZhang.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
        _showZheKou = false
        _showZheKou2 = false
        _showDailyGift = false
    else
        self.PromotionChengZhang:SetInfo(nil, nil)
    end
    if _showZheKou then
        -- Show great discounts
        self.PromotionZheKou:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.LimitDicretShop], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionZheKou.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
        _showZheKou2 = false
        _showDailyGift = false
    else
        self.PromotionZheKou:SetInfo(nil, nil)
    end
    if _showZheKou2 then
        -- Show great discount 2
        self.PromotionZheKou2:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.LimitDicretShop2], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionZheKou2.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
        _showDailyGift = false
    else
        self.PromotionZheKou2:SetInfo(nil, nil)
    end
    if _showDailyGift then
        -- Show daily gift pack
        self.PromotionDailyGift:SetInfo(DataConfig.DataFunctionStart[FunctionStartIdCode.WelfareDailyGift], self)
        _hieght = _hieght + 60
        UnityUtils.SetLocalPosition(self.PromotionDailyGift.RootTrans, 7, -193 + 44 * (3 - _heightCount), 0)
    else
        self.PromotionDailyGift:SetInfo(nil, nil)
    end

    self.PromotionBack.height = _hieght
    self.PromotionGrid.enabled = true
    self.PromotionGrid:Reposition()
    self.PromotionBtn.gameObject:SetActive(_funcCount > 0 and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.BianQiang))
    self.Promotioninfo.gameObject:SetActive(false)
end
function UIMainForm:OnOpenMainMenu(obj, sender)
    self.MainMenuIsOpen = true
    self.CSForm:PlayHideAnimation(self.RightButtomTrans, nil, false)
    self.MainMenuPanel:Open()
    self.MenuClose:SetActive(false)
    self.MenuOpen:SetActive(true)
    self:UpdateRedPoint()
    if GameCenter.MapLogicSwitch.IsCopyMap then
        self.CSForm:PlayShowAnimation(self.RightTopTrans)
        local _topMenu = self.SubPanels[MainFormSubPanel.TopMenu]
        _topMenu:ShowAfterUpdate(true)
    end
end
function UIMainForm:OnCloseMainMenu(obj, sender)
    self.MainMenuIsOpen = false
    self.CSForm:PlayShowAnimation(self.RightButtomTrans)
    self.MainMenuPanel:Close()
    self.MenuClose:SetActive(true)
    self.MenuOpen:SetActive(false)
    self:UpdateRedPoint()
    if GameCenter.MapLogicSwitch.IsCopyMap then
        self.CSForm:PlayHideAnimation(self.RightTopTrans)
        local _topMenu = self.SubPanels[MainFormSubPanel.TopMenu]
        _topMenu:CloseMenu()
    end
end
function UIMainForm:UpdateRedPoint()
    self.MenuRedPoint:SetActive(not self.MainMenuIsOpen and GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.MainFuncRoot))
end
function UIMainForm:OnUpdateFunc(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    if _funcId == FunctionStartIdCode.MainFuncRoot then
        self:UpdateRedPoint()
    elseif _funcId == FunctionStartIdCode.WelfareLevelGift then
        self:OnLevelGiftTipsRefresh(nil, nil)
    elseif _funcId == FunctionStartIdCode.ToDayFunc then
        self.TodayFuncBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.TodayFuncRedPoint:SetActive(funcInfo.IsShowRedPoint)
    end
    self:OnPromotionUpDate(funcInfo, _funcId)
end
function UIMainForm:OnMenuBtnClick()
    if GameCenter.GameSetting:IsEnabled(GameSettingKeyCode.EnableUIAnimation) then
        if Time.GetRealtimeSinceStartup() - self.FrontClickTime < 0.6 then
            return
        end
    end
    self.FrontClickTime = Time.GetRealtimeSinceStartup()
    if self.MainMenuPanel.IsVisible then
        self:OnCloseMainMenu(nil)
    else
        self:OnOpenMainMenu(nil)
    end
end
function UIMainForm:OnBtnLevelGiftTipsClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WelfareLevelGift)
end
function UIMainForm:OnGuaJiBtnClick()
    local _isFollow = false
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        _isFollow = GameCenter.MapLogicSystem.ActiveLogic.IsFollow
    end
    if _isFollow then
        Utils.ShowPromptByEnum("C_TIPS_COMMAND1")
        return
    end
    if GameCenter.MandateSystem:IsRunning() then
        GameCenter.MandateSystem:End()
    else
        GameCenter.MandateSystem:Start()
    end
end
function UIMainForm:OnChangeMap(obj, sender)
    local canMandate = GameCenter.MapLogicSwitch.CanMandate
    self.RightBottomStartGuaJiBtn:SetActive(canMandate)
end
function UIMainForm:OnEnterPrisonMap(obj, sender)
    self.Setting.gameObject:SetActive(true)
    self:PrisonDetail(true)
end
function UIMainForm:OnLeavePrisonMap(obj, sender)
    self.Setting.gameObject:SetActive(false)
    self:PrisonDetail(false)
end 
-- Update the hangup status
function UIMainForm:UpdateMandateState(obj, sender)
    local _running = GameCenter.MandateSystem:IsRunning()
    self.StartGuaJiBtn.gameObject:SetActive(not _running)
    self.EndGuaJiBtn.gameObject:SetActive(_running)
end
-- Update the transformation status
function UIMainForm:OnChangeModelEvent(obj, sender)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    if _lp.IsChangeModel then
        self:OpenSubPanel(MainFormSubPanel.ChangeSkill)
        self:CloseSubPanel(MainFormSubPanel.Skill)
    else
        self:OpenSubPanel(MainFormSubPanel.Skill)
        self:CloseSubPanel(MainFormSubPanel.ChangeSkill)
    end
end
function UIMainForm:OnPlayFlySwordSkill(obj, sender)
    self.CSForm:RemoveTransAnimation(self.FlySwordSkillTips.transform)
    self.CSForm:AddAlphaScaleAnimation(self.FlySwordSkillTips.transform, 0, 1, 0.5, 0.5, 1, 1, 0.1, false, false)
    self.CSForm:PlayShowAnimation(self.FlySwordSkillTips.transform)
    self.FlySwordSkillTimer = 2
end
function UIMainForm:OnLevelGiftTipsRefresh(obj, sender)
    local _level = GameCenter.WelfareSystem.LevelGift:GetGotoNextCount()
    local _info = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WelfareLevelGift)
    self.BtnLevelGiftTips.gameObject:SetActive(_level >= 0 and _info.IsVisible)
    if _level >= 0 then
        if _level == 0 then
            UIUtils.SetTextByEnum(self.TxtLevelGiftTips, "LevelGiftTips_CanGet")
        else
            UIUtils.SetTextByEnum(self.TxtLevelGiftTips, "LevelGiftTips_Condition", _level)
        end
    end
    self.GoVFXLevelGiftTips:SetActive(_level == 0);
end
function UIMainForm:NewFriendNotic(isShow)
    self.NoticNewFriend:SetActive(isShow)
end
function UIMainForm:FriendShipNoticFun()
    local isShow = GameCenter.FriendSystem:IsHaveShip()
    self.FriendShipNotic:SetActive(isShow)
end
function UIMainForm:OnShowBianQiangTips(obj, sender)
    if self.PromotionBtn.gameObject.activeSelf then
        GameCenter.BlockingUpPromptSystem:AddForceGuideByID(306, nil, false)
        --self.PromotionTipsGo:SetActive(true)
    else
        -- Haven't become stronger, open up daily life
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.DailyActivity)
    end
end

function UIMainForm:OnOpenWeleComePanel(obj, sender)
    self.WeleComePanel:Open()
end

function UIMainForm:OnUnLoadWeleComeRes(obj, sender)
    self.WeleComePanel:UnLoadPreLoadTex()
end

function UIMainForm:OpenSubPanel(panel)
    local _panel = self.SubPanels[panel]
    if _panel == nil then
        return
    end
    _panel:Open()
    if panel == MainFormSubPanel.Skill or panel == MainFormSubPanel.ChangeSkill then
        self:OnCloseMainMenu(nil)
    end
end
function UIMainForm:CloseSubPanel(panel)
    local _panel = self.SubPanels[panel]
    if _panel == nil then
        return
    end
    _panel:Close()
end

 local L_SubPanelPaths = {
    "RightTop/TopMenu",             -- Top Menu
    "LeftTop/PlayerHead",           -- Protagonist avatar
    "Top/TargetHead",               -- Target avatar
    "RightTop/NewMiniMap",          -- Mini map
    "LeftTop/TaskAndTeam",          -- Mission and teaming
    "Joystick",                     -- Rocker
    "Bottom/Exp",                   -- experience
    "Bottom/MiniChat",              -- Small chat box
    "RightBottom/Skill",            -- Skill
    "LeftTop/SelscePkMode",         -- Choose a camp
    "Center/FunctionFlyForm",       -- Function to enable the flight interface
    "Bottom/FastPrompt",            -- Quick reminder interface
    "Bottom/FastBtns",              -- Shortcut Button Interface
    "LeftBottom/Ping",              -- Ping
    "RightBottom2/CustomBtn",       -- Customize buttons
    "Bottom/SitDown",               -- Meditation
    "LeftTop/RemotePlayerHead",     -- Interact with remote players
    "RightBottom/ChangeSkill",      -- Transformation skills
    "RightBottom/FastPrompt/FlySwordGraveRoot",    -- Sword Tomb
    "Center/BossSkillWarning",      -- Skill release warning
    "Right/MenuBox",                -- Main RightMenuBox
}

-- Create subpaging
function UIMainForm:CreateSubPanel(subId)
    local _path = L_SubPanelPaths[subId]
    if _path == nil then
        return nil
    end
    local _subTrans = UIUtils.FindTrans(self.Trans, _path)
    local _result = nil
    local _needUpdate = false
    if subId == MainFormSubPanel.TopMenu then -- Top Menu
        _result = require("UI.Forms.UIMainForm.UIMainTopMenuPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.PlayerHead then -- Protagonist avatar
        _result = require("UI.Forms.UIMainForm.UIMainPlayerHeadPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.TargetHead then -- Target avatar
        _result = require("UI.Forms.UIMainForm.UIMainTargetHeadPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.MiniMap then -- Mini map
        _result = require("UI.Forms.UIMainForm.UIMainMiniMapPanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.TaskAndTeam then -- Mission and teaming
        _result = require("UI.Forms.UIMainForm.UIMainTaskAndTeamPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.Joystick then -- Rocker
        _result = require("UI.Forms.UIMainForm.UIMainJoystickPanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.Exp then -- experience
        _result = require("UI.Forms.UIMainForm.UIMainExpPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.MiniChat then -- Small chat box
        _result = L_UIUtility.RequireUIMainChat(_subTrans)
        _result:OnFirstShow(self.CSForm)
        _result.camera3DMode = 0
    elseif subId == MainFormSubPanel.Skill then -- Skill
        _result = require("UI.Forms.UIMainForm.UIMainSkillPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.SelectPkMode then -- Select PK mode
        _result = require("UI.Forms.UIMainForm.UIMainSelectPkModePanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.FunctionFly then -- New function enables flight interface
        _result = require("UI.Forms.UIMainForm.UIFunctionFlyPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.FastPrompt then -- Quick reminder interface
        _result = require("UI.Forms.UIMainForm.UIMainFastPromptPanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.FastBts then -- Quick operation button interface
        _result = require("UI.Forms.UIMainForm.UIMainFastBtnsPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.Ping then --ping
        _result = require("UI.Forms.UIMainForm.UIMainPingFuncPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.CustomBtn then -- Customize buttons
        _result = require("UI.Forms.UIMainForm.UIMainCustomBtnPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.SitDown then -- Meditation
        _result = require("UI.Forms.UIMainForm.UIMainSitDownPanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.RemotePlayerHead then -- Remote player avatar
        _result = require("UI.Forms.UIMainForm.UIRemotePlayerHead")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.ChangeSkill then -- Transformation skills
        _result = require("UI.Forms.UIMainForm.UIMainChangeSkillPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.FlySwordGrave then -- Sword Tomb
        _result = require("UI.Forms.UIMainForm.UIFlySwordShowPanel")
        _result:OnFirstShow(_subTrans, self, self)
    elseif subId == MainFormSubPanel.SkillWarning then -- Skill Warning
        _result = require("UI.Forms.UIMainForm.UIMainSkillWarningPanel")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    elseif subId == MainFormSubPanel.RightMenuBox then -- Main right menu
        _result = require("UI.Forms.UIMainForm.UIMainRightMenu")
        _result:OnFirstShow(_subTrans, self, self)
        _needUpdate = true
    end
    return _result, _needUpdate
end

function UIMainForm:Update(dt)
    for i = 1, #self.NeedUpdatePanel do
        self.NeedUpdatePanel[i]:Update(dt)
    end
    self.MainMenuPanel:Update(dt)
    self.WifiAndTimePage:Update(dt)
    self.WeleComePanel:Update(dt)

    if self.FlySwordSkillTimer > 0 then
        self.FlySwordSkillTimer = self.FlySwordSkillTimer - dt
        if self.FlySwordSkillTimer <= 0 then
            self.CSForm:RemoveTransAnimation(self.FlySwordSkillTips.transform);
            self.CSForm:AddAlphaScaleAnimation(self.FlySwordSkillTips.transform, 0, 1, 0.5, 0.5, 1, 1, 0.2, false, false);
            self.CSForm:PlayHideAnimation(self.FlySwordSkillTips.transform);
        end
    end

    if self.CheckShowFrameCount and self.CheckShowFrameCount > 0 then
        self.CheckShowFrameCount = self.CheckShowFrameCount - 1
        if self.CheckShowFrameCount <= 0 then
            if MainFunctionSystem.IsShowingMainForm then
                -- ui display exception repair
                if self.LeftTopWid.alpha <= 0.002 then
                    self.LeftTopWid.alpha = 1
                    self.CSForm.AnimModule:UpdateAnchor(self.LeftTopTrans)
                end
                if self.LeftButtomWid.alpha <= 0.002 then
                    self.LeftButtomWid.alpha = 1
                    self.CSForm.AnimModule:UpdateAnchor(self.LeftButtomTrans)
                end
            end
        end
    end
end

L_UIMainPromotion = {
    RootGo = nil,
    FunctionCfg = nil,
    TextLab = nil,
    Btn = nil,
    Parent = nil,
    RootTrans = nil,
}

function L_UIMainPromotion:New(go)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    _m.RootTrans = go.transform
    local _labelTrans = UIUtils.FindTrans(_m.RootTrans, "Label")
    if _labelTrans ~= nil then
        _m.TextLab = UIUtils.FindLabel(_labelTrans)
    end
    _m.Btn = UIUtils.FindBtn(_m.RootTrans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClickPromotionBtn, _m)
    return _m
end
function L_UIMainPromotion:SetInfo(cfg, parent)
    self.FunctionCfg = cfg
    self.Parent = parent
    if cfg == nil then
        self.RootGo:SetActive(false)
    else
        if self.TextLab ~= nil then
            UIUtils.SetTextByStringDefinesID(self.TextLab, cfg._FunctionName)
        end
        self.RootGo:SetActive(true)
    end
end

function L_UIMainPromotion:OnClickPromotionBtn()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(self.FunctionCfg.FunctionId)
    self.Parent:OnClickPromotionClose()
end

return UIMainForm