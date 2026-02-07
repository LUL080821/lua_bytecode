------------------------------------------------
-- author:
-- Date: 2021-02-26
-- File: UIMainPlayerHeadPanel.lua
-- Module: UIMainPlayerHeadPanel
-- Description: Player avatar pagination on the main interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local CSUIUtility = CS.Thousandto.Plugins.Common.UIUtility
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local L_HpStartPosX = -116.6
local L_HpStartPosY = -85.8
local L_HpEndPosX = 56
local L_HpEndPosY = -23
local L_LingQiStartPosX = -110
local L_LingQiStartPosY = -93.6
local L_LingQiEndPosX = 52.2
local L_LingQiEndPosY = -34.6

local UIMainPlayerHeadPanel = {
    HeadIcon = nil,
    FightLabel = nil,
    LevelLabel = nil,
    HpTrans = nil,
    HeadBtn = nil,
    RedPointGo = nil,
    ExpButton = nil,
    ExpRedPointGo = nil,
    ExpLabel = nil,
    LingQiTrans = nil,
    TweenScale = nil,
    FightPowerTimer = 0,
    BackSprite = nil,
    BuffBtn = nil,
    BuffCount = nil,
    BuffPanel = nil,
    VipBtn = nil,
    VipRedPoint = nil,
    VipLevel = nil,
    FreeVipBtn = nil,
    VipTipsTime = nil,
    VipTipsFrontUpdateTime = -1,
    UpdateFreeVipTime = false,
    VipTipsMaxTime = 15 * 60,
    VipTipsSyncTimer = 0,
    FuncList = List:New(),
    FuncListSort = List:New(),
    FuncGrid1 = nil,
    FuncGrid2 = nil,
    EighteenBtn = nil,

    ZheKouBtn = nil,
    ZheKouSkin = nil,
    ZheKouRedPoint = nil,

    ZheKouBtn2 = nil,
    ZheKouSkin2 = nil,
    ZheKouRedPoint2 = nil,

    CJPreviewGo = nil,
    CJPreviewBtn = nil,
    CJPreviewName = nil,
    CJPreviewRedPoint = nil,
    CJPreviewEffect = nil,
    CJPreviewTips = nil,
    CJPreviewTipsValue = nil,
    ButtonList = {},
    AllFuncList = {},

    PKPointCount = nil, -- điểm sát khí
    LKIcon = nil, -- icon linh khí
    ExpBtn = nil,
    PKBtn = nil,
    OpenSKpanel = nil,
    OpenLKTips = nil,
    ExpCloseBtn = nil,
    PKCloseBtn = nil,
    ExpDesLabel = nil,
    LKLabel = nil,
}

function UIMainPlayerHeadPanel:OnRegisterEvents()
    -- Changes in basic attributes
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnBaseProChanged, self)
    -- Change of combat attributes
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BATTLE_ATTR_CHANGED, self.OnBattleProChanged, self)
    -- Fighting power change event
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FIGHT_POWER_CHANGED, self.OnFightPowerChanged, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SHOWFIGHTPOWERCHANGE_EFFECT, self.OnShowFightPowerChangedEffect, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_BUFF_COUNT_CHANGED, self.OnBuffCountChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_OPEN, self.OnTopMenuChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ON_TOPMENU_CLOSE, self.OnTopMenuChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_FREEVIP_GETSTATE_CHANGED, self.OnFreeVIPChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_NEWFASHION_CHANGE, self.OnFashionChanged, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_CJ_PREVIEW, self.UpdateCJPreview, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ONLINE_REFRESH_ATT, self.OnOnlineRefreshAtt, self)

	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_UPDATE,self.UpdateVIP)
	self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_BUY_RESULT,self.OnBuyVIPResult) 

    -- [Gosu] Sát khí
    -- self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_PK_POINT,self.UpdatePKPoint) -- nghe từ Lua
    self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_GOSU_PK_POINT, self.UpdatePKPoint, self) -- nghe từ C#
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_EXP_TIME,self.UpdateExpIcon)


end

local L_LeftTopFuncIcon = nil
function UIMainPlayerHeadPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.HeadIcon = PlayerHead:New(UIUtils.FindTrans(trans, "Head"))
    self.HeadBtn = UIUtils.FindBtn(trans, "Head")
    self.FightLabel = UIUtils.FindLabel(trans, "Fight/FightValue")
    self.LevelLabel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(trans, "Level"))
    self.HpTrans = UIUtils.FindTrans(trans, "ScrollView/HPSpr")
    self.RedPointGo = UIUtils.FindGo(trans, "RedPoint")
    self.ExpButton = UIUtils.FindBtn(trans, "Exp")
    self.ExpLabel = UIUtils.FindLabel(trans, "Exp/Value")
    self.ExpRedPointGo = UIUtils.FindGo(trans, "Exp/RedPoint")
    self.LingQiTrans = UIUtils.FindTrans(trans, "ScrollView/LingLiSpr")
    UIUtils.AddBtnEvent(self.ExpButton, self.OnExpButtonClick, self)
    self.TweenScale = UIUtils.FindTweenScale(trans, "Fight")
    UIUtils.AddBtnEvent(self.HeadBtn, self.OnHeadBtnClick, self)
    self.BackSprite = UIUtils.FindSpr(trans, "Back")
    self.BuffBtn = UIUtils.FindBtn(trans, "BuffIcon")
    UIUtils.AddBtnEvent(self.BuffBtn, self.OnBuffIconClick, self)
    self.BuffCount = UIUtils.FindLabel(trans, "BuffIcon/Label")
    self.BuffPanel = require "UI.Forms.UIMainForm.UIMainLPBuffPanel"
    self.BuffPanel:OnFirstShow(UIUtils.FindTrans(trans, "BuffPanel"), self, rootForm)

    -- [Gosu] -- pk

    self.PKPointCount = UIUtils.FindLabel(trans, "SKIcon/Label")
    self.LKIcon = UIUtils.FindTrans(trans, "LKIcon/Icon")

    self.LKLabel = UIUtils.FindLabel(trans, "LKIcon/Label")

    --- Button
    self.PKBtn = UIUtils.FindBtn(trans, "SKIcon")
    UIUtils.AddBtnEvent(self.PKBtn, self.PKBtnClick, self) -- hiện gameobject OpenSKpanel là con của LKIcon

    self.ExpBtn = UIUtils.FindBtn(trans, "LKIcon")
    UIUtils.AddBtnEvent(self.ExpBtn, self.ExpBtnClick, self) -- hiện gameobject OpenLKTips là con của LKIcon

    -- Panel con
    self.OpenSKpanel = UIUtils.FindGo(trans, "SKIcon/OpenSKpanel")
    self.OpenLKTips = UIUtils.FindGo(trans, "LKIcon/OpenLKTips")

    self.ExpDesLabel = UIUtils.FindLabel(trans, "LKIcon/OpenLKTips/LKDesLabel")

    self.PKCloseBtn = UIUtils.FindBtn(trans, "SKIcon/OpenSKpanel/CloseBtn")
    UIUtils.AddBtnEvent(self.PKCloseBtn, self.OnPKCloseBtnClick, self)

    self.ExpCloseBtn = UIUtils.FindBtn(trans, "LKIcon/OpenLKTips/CloseBtn")
    UIUtils.AddBtnEvent(self.ExpCloseBtn, self.OnExpCloseBtnClick, self)
    -- End Gosu

    self.VipBtn = UIUtils.FindBtn(trans, "Grid/VIP")
    UIUtils.AddBtnEvent(self.VipBtn, self.OnVIPBtnClick, self)
    self.VipRedPoint = UIUtils.FindGo(trans, "Grid/VIP/RedPoint")
    self.VipLevel = UIUtils.FindLabel(trans, "Grid/VIP/Value")
    self.VipBtn.gameObject.name = "0000"
    self.FreeVipBtn = UIUtils.FindBtn(trans, "Grid/FreeVIP")
    UIUtils.AddBtnEvent(self.FreeVipBtn, self.OnFreeVIPBtnClick, self)
    self.VipTipsTime = UIUtils.FindLabel(trans, "Grid/FreeVIP/Time")
    self.FreeVipBtn.gameObject.name = "0001"
    self.FreeVipBtn.gameObject:SetActive(false)

    local _gCfg = DataConfig.DataGlobal[GlobalName.Free_VIP_Level_Up_Time]
    if _gCfg ~= nil then
        local _numberTable = Utils.SplitNumber(_gCfg.Params, '_')
        self.VipTipsMaxTime = _numberTable[1] * 60
    end
    self.FuncGrid1 = UIUtils.FindTrans(trans, "Grid/Line1")
    self.FuncGrid2 = UIUtils.FindTrans(trans, "Grid/Line2")
    local res = UIUtils.FindGo(trans, "Grid/Res")
    local _leftTopFuncs = GameCenter.MainFunctionSystem:GetFunctionList(4)
    local _funcCount = _leftTopFuncs.Count
    self.FuncList:Clear()
    self.FuncListSort:Clear()
    for i = 1, _funcCount do
        local _icon = nil
        if i == 1 then
            _icon = L_LeftTopFuncIcon:New(res.transform, _leftTopFuncs[i - 1])
        else
            _icon = L_LeftTopFuncIcon:New(UnityUtils.Clone(res).transform, _leftTopFuncs[i - 1])
        end
        -- Debug.Log("------------>" .. _leftTopFuncs[i-1].Cfg.FunctionSortNum )
        -- Debug.Log("------------> name " .. _leftTopFuncs[i-1].Cfg.FunctionName )
        -- Debug.Log("------------> ID " .. _leftTopFuncs[i-1].ID )
        self.ButtonList[_leftTopFuncs[i-1].Cfg.FunctionSortNum ] = _icon.RootTrans
        self.AllFuncList[ _leftTopFuncs[i-1].Cfg.FunctionSortNum ] = _leftTopFuncs[i - 1].ID
        self.FuncListSort:Add(_leftTopFuncs[i-1].Cfg.FunctionSortNum)
        self.FuncList:Add(_icon)
    end
    self.EighteenBtn = UIUtils.FindBtn(trans, "18Btn")
    UIUtils.AddBtnEvent(self.EighteenBtn, self.OnEighteenBtnClick, self)

    local _vipInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Vip)
    self.ButtonList[_vipInfo.Cfg.FunctionSortNum ] = self.VipBtn.transform;
    self.FuncListSort:Add(_vipInfo.Cfg.FunctionSortNum)
    self.AllFuncList[ _vipInfo.Cfg.FunctionSortNum ] = _vipInfo.ID
    -- Debug.Log("======> _vipInfo pos0 = ".. _vipInfo.Cfg.FunctionSortNum )

    self.ZheKouBtn = UIUtils.FindBtn(trans, "Grid/ZheKou")
    UIUtils.AddBtnEvent(self.ZheKouBtn, self.OnZheKouBtnClick, self)
    self.ZheKouSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(trans, "Grid/ZheKou/UIRoleSkinCompoent"))
    self.ZheKouSkin:OnFirstShow(self.RootForm.CSForm, FSkinTypeCode.Custom, AnimClipNameDefine.NormalIdle, 1, true)
    self.ZheKouSkin.EnableDrag = false
    self.ZheKouRedPoint = UIUtils.FindGo(trans, "Grid/ZheKou/RedPoint")
    local _zkFunInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitDicretShop)
    --self.ZheKouBtn.gameObject.name = UIUtils.CSFormat("Func{0:D4}", _zkFunInfo.SortNum)
    self.ButtonList[_zkFunInfo.Cfg.FunctionSortNum ] = self.ZheKouBtn.transform;
    self.FuncListSort:Add(_zkFunInfo.Cfg.FunctionSortNum)
    self.AllFuncList[ _zkFunInfo.Cfg.FunctionSortNum ] = _zkFunInfo.ID
    -- Debug.Log("======> _zkFunInfo pos0 = ".. _zkFunInfo.Cfg.FunctionSortNum )

    self.ZheKouBtn2 = UIUtils.FindBtn(trans, "Grid/ZheKou2")
    UIUtils.AddBtnEvent(self.ZheKouBtn2, self.OnZheKouBtnClick2, self)
    self.ZheKouSkin2 = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(trans, "Grid/ZheKou2/UIRoleSkinCompoent"))
    self.ZheKouSkin2:OnFirstShow(self.RootForm.CSForm, FSkinTypeCode.Custom, AnimClipNameDefine.NormalIdle, 1, true)
    self.ZheKouSkin2.EnableDrag = false
    self.ZheKouRedPoint2 = UIUtils.FindGo(trans, "Grid/ZheKou2/RedPoint")
    local _zkFunInfo2 = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitDicretShop2)
    --self.ZheKouBtn2.gameObject.name = UIUtils.CSFormat("Func{0:D4}", _zkFunInfo2.SortNum)
    self.ButtonList[_zkFunInfo2.Cfg.FunctionSortNum ] = self.ZheKouBtn2.transform;
    self.FuncListSort:Add(_zkFunInfo2.Cfg.FunctionSortNum)
    self.AllFuncList[ _zkFunInfo2.Cfg.FunctionSortNum ] = _zkFunInfo2.ID
    -- Debug.Log("======> _zkFunInfo2 pos0 = ".. _zkFunInfo2.Cfg.FunctionSortNum )

    self.CJPreviewBtn = UIUtils.FindBtn(trans, "Grid/CJPreview")
    UIUtils.AddBtnEvent(self.CJPreviewBtn, self.OnCJPreviewBtnClick, self)
    self.CJPreviewGo = self.CJPreviewBtn.gameObject
    self.CJPreviewName = UIUtils.FindLabel(trans, "Grid/CJPreview/Name1")
    self.CJPreviewRedPoint = UIUtils.FindGo(trans, "Grid/CJPreview/RedPoint")
    self.CJPreviewEffect = UIUtils.FindGo(trans, "Grid/CJPreview/Effect")
    self.CJPreviewTips = UIUtils.FindGo(trans, "Grid/CJPreview/Tips")
    self.CJPreviewTipsValue = UIUtils.FindLabel(trans, "Grid/CJPreview/Tips/Label")
    local _cjInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ChangeJob)
    --self.CJPreviewGo.name = UIUtils.CSFormat("Func{0:D4}", _cjInfo.SortNum)
    --self.ButtonList[_cjInfo.Cfg.FunctionSortNum ] = self.CJPreviewBtn.transform;
    --self.FuncListSort:Add(_cjInfo.Cfg.FunctionSortNum)
    --self.AllFuncList[ _cjInfo.Cfg.FunctionSortNum ] = _cjInfo.ID

    -- if(self.PKCloseBtn) then
    --     self.PKCloseBtn:SetActive(false)
    -- end


    self.FuncListSort:Sort()
    self:UpdatePos()


end

function UIMainPlayerHeadPanel:UpdatePos()

    local line = 0
    local pos = 0
    local FuncLine = nil
    local x = 0
    local curBtn = nil
    local Count = #self.FuncListSort
    local index1 = 0
    local index2 = 0

    local func = nil
    self.VipBtn.gameObject:SetActive(false)
    for i = 1, Count do
        pos = self.FuncListSort[i]
        func = GameCenter.MainFunctionSystem:GetFunctionInfo(self.AllFuncList[pos])
       
        if func.IsVisible then
            curBtn =self.ButtonList[ pos ]
            line = pos // 10
            if func.ID == FunctionStartIdCode.Vip then
                self.VipBtn.gameObject:SetActive(true)
            end
            if( line == 0 ) then
                x = index1 % 10
                index1 = index1 + 1                
                FuncLine = self.FuncGrid1
                -- Debug.Log("line "..line.." pos "..pos.." id "..func.ID.." sortNum "..func.SortNum);
            else
                x = index2 % 10
                index2 = index2 + 1
                FuncLine = self.FuncGrid2
                -- Debug.Log("line "..line.." pos "..pos.." id "..func.ID.." sortNum "..func.SortNum);
                
            end

            curBtn.transform.parent = FuncLine.transform            
            startX = 35 + x * 75

            UnityUtils.SetLocalPosition(curBtn.transform, startX, 35, 0)
        end
    end 

    -- Realm preview is always on the rightmost of the first line
    self.CJPreviewGo.transform.parent = self.FuncGrid1.transform
    x = index1 % 10
    startX = 35 + x * 75

    UnityUtils.SetLocalPosition(self.CJPreviewGo.transform, startX, 35, 0)

end

-- After display
function UIMainPlayerHeadPanel:OnShowAfter()
    self.IsLoadZheKouModel = false
    self.IsLoadZheKouModel2 = false
    self:RefreshPage()
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Player))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.OnHookSettingForm))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Vip))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.Eighteen))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitDicretShop))
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitDicretShop2))
    self.TweenScale:ResetToBeginning()
    UnityUtils.SetLocalScale(self.TweenScale.transform, 1, 1, 1)
    self.TweenScale.enabled = false
    self:OnBuffCountChanged(nil, nil)
    self.VipTipsSyncTimer = 60
    for i = 1, #self.FuncList do
        local _func = self.FuncList[i]
        _func:UpdateInfo(_func.FuncId == FunctionStartIdCode.FreeShopVIP)
    end
    self:OnTopMenuChanged(nil, nil)
    self:OnFreeVIPChanged(nil, nil)
    --self.FuncGrid.repositionNow = true

    local spr = self.VipBtn.transform:GetComponent("UISprite")
    spr.IsGray = GameCenter.VipSystem.BaoZhuState == 0
    
    local label = self.VipLevel.transform:GetComponent("UILabel")
    label.IsGray = GameCenter.VipSystem.BaoZhuState == 0    
    self:UpdatePos()    

    self:UpdatePKPointIni()
end

function UIMainPlayerHeadPanel:OnHideBefore()
    self.IsLoadZheKouModel = false
    self.IsLoadZheKouModel2 = false
    self.UpdateFreeVipTime = false
    self.ZheKouSkin:ResetSkin()
    self.ZheKouSkin2:ResetSkin()
end

function UIMainPlayerHeadPanel:OnTryHide()

    if self.BuffPanel.IsVisible then
        self.BuffPanel:Close()
        return false
    end
    return true
end
 
function UIMainPlayerHeadPanel:OnFuncUpdated(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    local _cfg = DataConfig.DataFunctionStart[_funcId]
    if _funcId == FunctionStartIdCode.Player then
        self.RedPointGo:SetActive(funcInfo.IsShowRedPoint)
    elseif _funcId == FunctionStartIdCode.OnHookSettingForm then
        self.ExpRedPointGo:SetActive(funcInfo.IsShowRedPoint)
    elseif _funcId == FunctionStartIdCode.Vip then
        self.VipRedPoint:SetActive(funcInfo.IsShowRedPoint)
    elseif _funcId == FunctionStartIdCode.Eighteen then
        self.EighteenBtn.gameObject:SetActive(funcInfo.IsVisible)
    elseif _funcId == FunctionStartIdCode.LimitDicretShop then
        -- Great discount
        self.ZheKouBtn.gameObject:SetActive(funcInfo.IsVisible)
        if funcInfo.IsVisible then
            if not self.IsLoadZheKouModel then
                self.ZheKouSkin:SetEquip(FSkinPartCode.Body, 6800002)
            end
            self.IsLoadZheKouModel = true
        else
            if self.IsLoadZheKouModel then
                self.ZheKouSkin:ResetSkin()
            end
            self.IsLoadZheKouModel = false
            self.ZheKouModelTimer = 0
        end
        --self.FuncGrid.repositionNow = true
        self.ZheKouRedPoint:SetActive(funcInfo.IsShowRedPoint)
    elseif _funcId == FunctionStartIdCode.LimitDicretShop2 then
        -- Great discount
        self.ZheKouBtn2.gameObject:SetActive(funcInfo.IsVisible)
        if funcInfo.IsVisible then
            if not self.IsLoadZheKouModel2 then
                self.ZheKouSkin2:SetEquip(FSkinPartCode.Body, 6800002)
            end
            self.IsLoadZheKouModel2 = true
        else
            if self.IsLoadZheKouModel2 then
                self.ZheKouSkin2:ResetSkin()
            end
            self.IsLoadZheKouModel2 = false
            self.ZheKouModelTimer2 = 0
        end
        --self.FuncGrid.repositionNow = true
        self.ZheKouRedPoint2:SetActive(funcInfo.IsShowRedPoint)
    elseif _cfg.FunctionPosType == 4 then
        for i = 1, #self.FuncList do
            local _func = self.FuncList[i]
            if _funcId == _func.Cfg.FunctionId then
                _func:UpdateInfo(_funcId == FunctionStartIdCode.FreeShopVIP)
            end
        end
        --self.FuncGrid.repositionNow = true
    end
    self:UpdatePos()
end
function UIMainPlayerHeadPanel:OnExpButtonClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.OnHookSettingForm)
end
function UIMainPlayerHeadPanel:OnHeadBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Player)
end
function UIMainPlayerHeadPanel:OnBuffIconClick()
    self.BuffPanel:Open()
end
function UIMainPlayerHeadPanel:OnVIPBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Vip)
end
function UIMainPlayerHeadPanel:OnFreeVIPBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIFreeVIPForm_OPEN)
end
function UIMainPlayerHeadPanel:OnEighteenBtnClick()
    Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_VIE_EIGHTEEN_TIPS")
end
function UIMainPlayerHeadPanel:OnCJPreviewBtnClick()
    local _system = GameCenter.ChangeJobSystem
    if _system.PreviewFuncID == nil then
        self.CJPreviewGo:SetActive(false)
        return
    end
    self.CJPreviewTips:SetActive(false)
    self.CJPreviewRedPoint:SetActive(false)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(_system.PreviewFuncID, _system.PreviewFuncParam)
end
function UIMainPlayerHeadPanel:OnZheKouBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LimitDicretShop)
end
function UIMainPlayerHeadPanel:OnZheKouBtnClick2()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LimitDicretShop2)
end
function UIMainPlayerHeadPanel:RefreshPage()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.HeadIcon:SetLocalPlayer()
    UIUtils.SetTextByNumber(self.FightLabel, _lp.FightPower)
    self.LevelLabel:SetLevel(_lp.Level, false)
    UIUtils.SetTextByEnum(self.ExpLabel, "C_EXP_ADD_PER", math.floor(_lp.PropMoudle.KillMonsterExpPercent / 100))
    UIUtils.SetTextByNumber(self.VipLevel, _lp.VipLevel)
    self:OnBuffCountChanged(nil)
    self:UpdateCJPreview(_lp.Level)
end

function UIMainPlayerHeadPanel:OnFashionChanged(obj, sender)
    self.HeadIcon:SetLocalPlayer()
end

function UIMainPlayerHeadPanel:UpdateCJPreview(level)
    if level == nil then
        level =  GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    end
    local _system = GameCenter.ChangeJobSystem
    if _system.PreviewJobID ~= nil and level >= _system.PreviewNeedLevel then
        UIUtils.SetTextByString(self.CJPreviewTipsValue, _system.PreviewTips)
        self.CJPreviewGo:SetActive(true)
        if _system.PreviewFuncID == FunctionStartIdCode.PreviewXinFa then
            UIUtils.SetTextByEnum(self.CJPreviewName, "C_ZHUANZHI_YULAN")
        else
            UIUtils.SetTextByEnum(self.CJPreviewName, "C_JINGJIE_YULAN")
        end
        if self.CurShowCJId ~= _system.PreviewJobID then
            self.CJPreviewTips:SetActive(true)
            self.CJPreviewRedPoint:SetActive(true)
            self.CurShowCJId = _system.PreviewJobID
        end
    else
        self.CurShowCJId = nil
        self.CJPreviewGo:SetActive(false)
    end
    --self.FuncGrid.repositionNow = true
    self:UpdatePos()
end

-- Free VIP status
function UIMainPlayerHeadPanel:OnFreeVIPChanged(obj, sender)
    local _isGetAward = GameCenter.VipSystem.IsGetFreeVipExp
    if _isGetAward then
        self.FreeVipBtn.gameObject:SetActive(false)
        self.UpdateFreeVipTime = false
    else
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            local _onLineTime = _lp.PropMoudle.AllOnLineTime
            if _onLineTime >= self.VipTipsMaxTime then
                --self.FreeVipBtn.gameObject:SetActive(true)
                self.UpdateFreeVipTime = false
                UIUtils.SetTextByEnum(self.VipTipsTime, "VIPLEVEL_KELINGQU")
            else
                --self.FreeVipBtn.gameObject:SetActive(true)
                self.VipTipsFrontUpdateTime = -1
                self.UpdateFreeVipTime = true
            end
        else
            self.FreeVipBtn.gameObject:SetActive(false)
            self.UpdateFreeVipTime = false
        end
    end
    --self.FuncGrid.repositionNow = true
    self:UpdatePos()
end
-- The top menu is on or off
function UIMainPlayerHeadPanel:OnTopMenuChanged(obj, sender)
    local _topMenu = self.Parent.SubPanels[MainFormSubPanel.TopMenu]
    -- if _topMenu.CurState == MainTopMenuState.Hide or _topMenu.CurState == MainTopMenuState.Hiding then
    --     self.VipBtn.gameObject:SetActive(true)
    --     self.FuncGrid.gameObject:SetActive(true)
    --     self.FuncGrid.repositionNow = true
    -- else
    --     self.VipBtn.gameObject:SetActive(false)
    --     self.FuncGrid.gameObject:SetActive(false)
    -- end
    self:UpdatePos()
end
-- Show combat power change effect
function UIMainPlayerHeadPanel:OnShowFightPowerChangedEffect(obj, sender)
    self.TweenScale:ResetToBeginning()
    self.TweenScale:PlayForward()
    self.FightPowerTimer = 0.3
end
-- Show combat power change effect
function UIMainPlayerHeadPanel:OnBuffCountChanged(obj, sender)
    local _buffList = GameCenter.BuffSystem.LpBuffList
    local _buffCount = _buffList.Count
    local _showCount = 0
    for i = 1, _buffCount do
        local _buff = _buffList[i - 1]
        local _cfg = DataConfig.DataBuff[_buff.DataID]
        if _cfg ~= nil and _cfg.IfShow == 0 then
            _showCount = _showCount + 1
        end
    end
    UIUtils.SetTextByNumber(self.BuffCount, _showCount)
end
function UIMainPlayerHeadPanel:OnBaseProChanged(pro, sender)
    if pro.CurrentChangeBasePropType == L_RoleBaseAttribute.Level then
        self.LevelLabel:SetLevel(pro.Level, false)
        self:UpdateCJPreview(pro.Level)
    elseif pro.CurrentChangeBasePropType == L_RoleBaseAttribute.VipLevel then
        UIUtils.SetTextByNumber(self.VipLevel, pro.VipLevel)
    end
end
function UIMainPlayerHeadPanel:OnBattleProChanged(pro, sender)
    if pro.CurrentChangeBattlePropType == AllBattleProp.KillMonsterExpPercent then
        UIUtils.SetTextByEnum(self.ExpLabel, "C_EXP_ADD_PER", math.floor(pro.KillMonsterExpPercent / 100))
    end
end
function UIMainPlayerHeadPanel:OnOnlineRefreshAtt()
    self.OnLineRefreshExp = true
end
function UIMainPlayerHeadPanel:OnFightPowerChanged(power, sender)
    UIUtils.SetTextByNumber(self.FightLabel, power)
end
function UIMainPlayerHeadPanel:PlayZheKouAnim()
    self.ZheKouModelTimer = 2.5
end
function UIMainPlayerHeadPanel:PlayZheKouAnim2()
    self.ZheKouModelTimer2 = 2.5
end
function UIMainPlayerHeadPanel:Update(dt)
    if self.OnLineRefreshExp then
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            self.OnLineRefreshExp = false
            UIUtils.SetTextByEnum(self.ExpLabel, "C_EXP_ADD_PER", math.floor(_lp.PropMoudle.KillMonsterExpPercent / 100))
        end
    end
    self.BuffPanel:Update(dt)
    if self.IsLoadZheKouModel then
        self.ZheKouModelTimer = self.ZheKouModelTimer + dt
        if self.ZheKouModelTimer >= 3 then
            self.ZheKouModelTimer = 0
            self.ZheKouSkin:Play("close", 0, 1, 1)
        end
    end
    if self.IsLoadZheKouModel2 then
        self.ZheKouModelTimer2 = self.ZheKouModelTimer2 + dt
        if self.ZheKouModelTimer2 >= 3 then
            self.ZheKouModelTimer2 = 0
            self.ZheKouSkin2:Play("close", 0, 1, 1)
        end
    end
    if self.FightPowerTimer > 0 then
        self.FightPowerTimer = self.FightPowerTimer - dt
        if self.FightPowerTimer <= 0 then
            self.TweenScale:ResetToBeginning()
            UnityUtils.SetLocalScale(self.TweenScale.transform, 1, 1, 1)
            self.TweenScale.enabled = false
        end
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        local _lerpValue = _lp.HpPercent
        local _x = math.Lerp(L_HpStartPosX, L_HpEndPosX, _lerpValue)
        local _y = math.Lerp(L_HpStartPosY, L_HpEndPosY, _lerpValue)
        UnityUtils.SetLocalPosition(self.HpTrans, _x, _y, 0)
        _lerpValue = _lp.LingLiPercent
        _x = math.Lerp(L_LingQiStartPosX, L_LingQiEndPosX, _lerpValue)
        _y = math.Lerp(L_LingQiStartPosY, L_LingQiEndPosY, _lerpValue)
        UnityUtils.SetLocalPosition(self.LingQiTrans, _x, _y, 0)
        if _lp.VipLevel <= 0 then
            -- Request online time every 60 seconds to fix the problem of incorrect online time
            if self.VipTipsSyncTimer > 0 then
                self.VipTipsSyncTimer = self.VipTipsSyncTimer - dt
                if self.VipTipsSyncTimer <= 0 then
                    -- Request to accumulate online time
                    GameCenter.Network.Send("MSG_Player.ReqGetAccunonlinetime")
                    self.VipTipsSyncTimer = 60
                end
            end
        end
        if self.UpdateFreeVipTime then
            local _onLineTime = _lp.PropMoudle.AllOnLineTime
            if _onLineTime >= 0 and _onLineTime < self.VipTipsMaxTime then
                local _showTime = math.floor(self.VipTipsMaxTime - _onLineTime)
                if _showTime ~= self.VipTipsFrontUpdateTime then
                    self.VipTipsFrontUpdateTime = _showTime
                    UIUtils.SetTextMMSS(self.VipTipsTime, _showTime)
                end
            else
                self:OnFreeVIPChanged(nil, nil)
                -- Countdown ends, open the collection interface
                GameCenter.VipSystem:TryAutoOpenFreeVipForm()
            end
        end
    end
end

function UIMainPlayerHeadPanel:UpdateVIP(obj, sender)
    local spr = self.VipBtn.transform:GetComponent("UISprite")
    spr.IsGray = GameCenter.VipSystem.BaoZhuState == 0
    
    local label = self.VipLevel.transform:GetComponent("UILabel")
    label.IsGray = GameCenter.VipSystem.BaoZhuState == 0    
end

-- VIP award and purchase return
function UIMainPlayerHeadPanel:OnBuyVIPResult(obj,sender)
    local spr = self.VipBtn.transform:GetComponent("UISprite")
    spr.IsGray = GameCenter.VipSystem.BaoZhuState == 0
    
    local label = self.VipLevel.transform:GetComponent("UILabel")
    label.IsGray = GameCenter.VipSystem.BaoZhuState == 0     
end    

------------------------------------------------------------------------------------- [Gosu]
LinhKhiState = {
    None = 0,    
    Has  = 1,    
}

function UIMainPlayerHeadPanel:OnPKCloseBtnClick()
    self.OpenSKpanel:SetActive(false)
end

function UIMainPlayerHeadPanel:OnExpCloseBtnClick()
    self.OpenLKTips:SetActive(false)
end

function UIMainPlayerHeadPanel:PKBtnClick()

    -- toggle
    local active = self.OpenSKpanel.activeSelf
    self.OpenSKpanel:SetActive(not active)

    -- nếu mở SK thì tắt LK
    if not active then
        self.OpenLKTips:SetActive(false)
    end
end

function UIMainPlayerHeadPanel:ExpBtnClick()
    local active = self.OpenLKTips.activeSelf
    self.OpenLKTips:SetActive(not active)

    -- nếu mở LK thì tắt SK
    if not active then
        self.OpenSKpanel:SetActive(false)
    end
end


local LinhKhiIconMap = {
    [LinhKhiState.Has] = "n_a_61",--linh khi yeu
    [LinhKhiState.None]  = "n_a_61_green", --linh khi manh
}

function UIMainPlayerHeadPanel:UpdateLinhKhiIcon(state)
    local icon = LinhKhiIconMap[state]
    if icon then
        UIUtils.SetUISprite(self.LKIcon, icon)
    end
end

function UIMainPlayerHeadPanel:UpdateLinhKhiDesc(point)
    if tonumber(point) > 0 then
        UIUtils.SetTextByEnum(self.ExpDesLabel, "LK_TIME", point)
        UIUtils.SetTextByString(self.LKLabel, DataConfig.DataMessageString.Get("LK_PERCENT"))
    else
        UIUtils.SetTextByEnum(self.ExpDesLabel, "LK_TIMEOUT")
        UIUtils.SetTextByString(self.LKLabel, DataConfig.DataMessageString.Get("LK_UNPERCENT"))
    end
end


function UIMainPlayerHeadPanel:UpdatePKPointIni()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if not _lp then
        return
    end
    local pk = _lp.PointSatKhi or 0

    if self.PKPointCount then
        UIUtils.SetTextByNumber(self.PKPointCount, pk)
    end

    -- Linh khí
    local lk = _lp.PointLinhKhi or 0
    local state = (lk > 0) and LinhKhiState.None or LinhKhiState.Has
    self:UpdateLinhKhiIcon(state)
    self:UpdateLinhKhiDesc(lk)
    -- Debug.Log("===player.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhi===", _lp.PointLinhKhi)

end

function UIMainPlayerHeadPanel:UpdateExpIcon(obj,sender)

    -- local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if not obj then
        return
    end
    -- if not _lp then
    --     return
    -- end

    local expPoint = obj.timeLimitExp or 0
    -- _lp.PropMoudle.PointLinhKhi = expPoint


    local state = (expPoint > 0) and LinhKhiState.None or LinhKhiState.Has
    self:UpdateLinhKhiIcon(state)
    self:UpdateLinhKhiDesc(expPoint)
    -- Debug.Log("===UpdateExpIcon===player.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhiplayer.PointLinhKhi===", expPoint)
 
end


-- Update PK Point

function UIMainPlayerHeadPanel:UpdatePKPoint(obj, sender)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if not lp then
        return
    end

    local pkPoint = lp.PointSatKhi or 0

    if self.PKPointCount then
        UIUtils.SetTextByNumber(self.PKPointCount, pkPoint)
    end
end


------------------------------------------------------------------------------------- [Gosu]

L_LeftTopFuncIcon = {
    RootGo = nil,
    RootTrans = nil,
    Btn = nil,
    RedPoint = nil,
    IconSpr = nil,
    TweenAnim = nil,
    Name = nil,
    EffectGo = nil,
    LittleName = nil,
    LittleNameGo = nil,
    Func = nil,
    FuncId = 0,
    Cfg = nil,
}
function L_LeftTopFuncIcon:New(trans, func)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = trans.gameObject
    _m.RootTrans = trans
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClcik, _m)
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    _m.IconSpr = UIUtils.FindSpr(trans, "Icon")
    _m.TweenAnim = UIUtils.FindTweenRotation(trans, "Icon")
    _m.Name = UIUtils.FindLabel(trans, "Name1")
    _m.EffectGo = UIUtils.FindGo(trans, "Effect")
    _m.Func = func
    _m.RootGo.name = UIUtils.CSFormat("Func{0:D4}", func.SortNum)
    _m.IconSpr.spriteName = func.Cfg.MainIcon
    _m.FuncId = func.ID
    _m.Cfg = DataConfig.DataFunctionStart[_m.FuncId]
    UIUtils.SetTextByStringDefinesID(_m.Name, _m.Cfg._FunctionName)
    _m.LittleName = UIUtils.FindLabel(trans, "LittleName")
    _m.LittleNameGo = _m.LittleName.gameObject
    return _m
end
function L_LeftTopFuncIcon:UpdateInfo(doAnim)
    if doAnim then
        self.TweenAnim.enabled = true
    else
        self.TweenAnim.enabled = false
        UnityUtils.SetLocalEulerAngles(self.TweenAnim.transform, 0, 0, 0)
    end
    self.RootGo:SetActive(self.Func.IsVisible)
    self.RedPoint:SetActive(self.Func.IsShowRedPoint)
    if self.FuncId == FunctionStartIdCode.ChangeJob then
        self.EffectGo:SetActive(true)
    else
        self.EffectGo:SetActive(self.Func.IsEffectShow or (self.Func.IsEffectByAlert and self.Func.IsShowRedPoint))
    end
    local _littleName = self.Func.LittleName
    if _littleName == nil or string.len(_littleName) <= 0 then
        self.LittleNameGo:SetActive(false)
    else
        self.LittleNameGo:SetActive(false)
        UIUtils.SetTextByString(self.LittleName, _littleName)
        self.LittleNameGo:SetActive(true)
    end
end
function L_LeftTopFuncIcon:OnBtnClcik()
    if self.FuncId == FunctionStartIdCode.ThaiShareGroup then
        self.Func:OnClickHandler(self.RootTrans)
    else
        self.Func:OnClickHandler(nil)
    end
    if self.FuncId == FunctionStartIdCode.ChangeJob then
        self.EffectGo:SetActive(true)
    end
end

return UIMainPlayerHeadPanel