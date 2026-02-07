-- author:
-- Date: 2021-02-24
-- File: UIMainCustomBtnPanel.lua
-- Module: UIMainCustomBtnPanel
-- Description: Home interface shortcut button paging
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local CSInput = CS.UnityEngine.Input
local L_XFHDFuncs = {
    FunctionStartIdCode.LimitDicretShop, -- Great discount
    FunctionStartIdCode.LimitDicretShop2, -- Great discount
    FunctionStartIdCode.NewServerActivity, -- New server activities
    FunctionStartIdCode.MarryWall, -- A good partner is born
    FunctionStartIdCode.FreeShop, -- Buy 0 yuan
}

local L_XFDHYYHDs = {
    YYHDLogicDefine.XianShiLeiChong,
    YYHDLogicDefine.JieRiJiZhi,
}

local UIMainCustomBtnPanel = {
    BtnList = List:New(),
    ResGo = nil,
    ShowCount = 0,

    -- Opening a server carnival
    KfkhBtn = nil,
    KfkhRedPoint = nil,
    KfkhEffect = nil,
    KfkhTime = nil,

    -- The road to growth
    CzzlBtn = nil,
    CzzlRedPoint = nil,
    CzzlEffect = nil,

    -- The Realm of Chaos
    TerritorialWarBtn = nil,
    TerritorialEffect = nil,

    -- Expeditions from all realms
    ZJYZBtn = nil,
    ZJYZEffect = nil,
    ZJYZRedPoint = nil,
    ZJYZTimeLabel = nil,
    ZJYZTipsGo = nil,
    -- Remote refresh status of all realms 0 has been refreshed, 1 refresh countdown
    ZJYZTimeType = -1,
    ZJYZTypeRemianTime = -1,

    -- Update polite content
    DownResProGo = nil,
    DownResProBtn = nil,
    DownResProLab = nil,
    DownResProSpr = nil,
    DownResTipsGo = nil,
    DownTipsCloseTimer = 0,
    DownResRedPoint = nil,
    -- Level of download start
    StartDownLevel = 18,

    -- The Immortal Alliance Blessed Land
    XmfdBtn = nil,
    XmfdRedPoint = nil,
    XmfdEffect = nil,
    XmfdRemainTime = nil,
    XmfdRemainTimeGo = nil,
    UpdateFdTime = false,
    XmfdFrontTime = -1,
    XmfdOpenTime = 0,

    -- New server activities
    XFHDBtn = nil,
    XFHDRedPoint = nil,
    XFHDEffect = nil,
    XFHDMenuTrans = nil,
    XFHDMenuBack = nil,
    XFHDMenuGrid = nil,
    XFHDMenuRes = nil,
    XFHDMenuList = nil,
    XFHDStartDay = 1,
    XFHDEndDay = 7,

    -- V4 assist
    V4HelpBtn = nil,
    V4HelpBtnRedPoint = nil,
    V4HelpBtnEffect = nil,

    -- The displayed list for sorting
    ShowList = List:New(),
}

function UIMainCustomBtnPanel:OnRegisterEvents()
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATECUSTONBTNS, self.UpdatePage, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnUpdateFunc, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST, self.OnRefreshHDList, self)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, self.OnRefreshSingleHD, self)
end

local L_UICustomBtn = nil
local L_XFHDMenuBtn = nil

function UIMainCustomBtnPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.ResGo = UIUtils.FindGo(trans, "Icon")
    self.BtnList:Clear()
    self.BtnList:Add(L_UICustomBtn:New(self.ResGo))

    self.KfkhBtn = UIUtils.FindBtn(trans, "KFKH")
    UIUtils.AddBtnEvent(self.KfkhBtn, self.OnKFKHClick, self)
    self.KfkhRedPoint = UIUtils.FindGo(trans,"KFKH/RedPoint")
    self.KfkhEffect = UIUtils.FindGo(trans,"KFKH/Effect")
    self.KfkhTime = UIUtils.FindLabel(trans,"KFKH/Time")
    self.KfkhEffect:SetActive(true)

    self.CzzlBtn = UIUtils.FindBtn(trans,"CZZL")
    UIUtils.AddBtnEvent(self.CzzlBtn, self.OnCZZLClick, self)
    self.CzzlRedPoint = UIUtils.FindGo(trans,"CZZL/RedPoint")
    self.CzzlEffect = UIUtils.FindGo(trans,"CZZL/Effect")
    self.CzzlEffect:SetActive(true)

    self.TerritorialWarBtn = UIUtils.FindBtn(trans,"TerritorialWar")
    UIUtils.AddBtnEvent(self.TerritorialWarBtn, self.OnTerritorialWarClick, self)
    self.TerritorialEffect = UIUtils.FindGo(trans, "TerritorialWar/Effect")
    self.TerritorialEffect:SetActive(true)

    self.DownResProGo = UIUtils.FindGo(trans, "DownResPro")
    self.DownResProGo:SetActive(false)
    self.DownResProBtn = UIUtils.FindBtn(trans, "DownResPro")
    UIUtils.AddBtnEvent(self.DownResProBtn, self.OnDownResProBtnClick, self)
    self.DownResProLab = UIUtils.FindLabel(trans, "DownResPro/ProLab")
    self.DownResProSpr = UIUtils.FindSpr(trans, "DownResPro/ProSpr")
    self.DownResTipsGo = UIUtils.FindGo(trans, "DownResPro/OpenTips")
    self.DownResRedPoint = UIUtils.FindGo(trans, "DownResPro/RedPoint")
    self.DownResTipsGo:SetActive(false)
    self.DownTipsCloseTimer = 5

    self.XmfdBtn = UIUtils.FindBtn(trans, "XMFD")
    UIUtils.AddBtnEvent(self.XmfdBtn, self.OnXMFDBtnClick, self)
    self.XmfdRedPoint = UIUtils.FindGo(trans, "XMFD/RedPoint")
    self.XmfdEffect = UIUtils.FindGo(trans, "XMFD/Effect")
    self.XmfdRemainTime = UIUtils.FindLabel(trans, "XMFD/Time")
    self.XmfdRemainTimeGo = self.XmfdRemainTime.gameObject

    -- Expeditions from all realms
    self.ZJYZBtn = UIUtils.FindBtn(trans, "ZJYZ")
    UIUtils.AddBtnEvent(self.ZJYZBtn, self.OnZJYZBtnClick, self)
    self.ZJYZRedPoint = UIUtils.FindGo(trans, "ZJYZ/RedPoint")
    self.ZJYZEffect = UIUtils.FindGo(trans, "ZJYZ/Effect")
    self.ZJYZTimeLabel = UIUtils.FindLabel(trans, "ZJYZ/Time")
    self.ZJYZTipsGo = UIUtils.FindGo(trans, "ZJYZ/OpenTips")
    self.ZJYZTipsGo:SetActive(false)
    self.ZJYZShowTips = false
    self.ZJYZEffect:SetActive(false)

    -- New server activities
    self.XFHDBtn = UIUtils.FindBtn(trans, "XFHD")
    UIUtils.AddBtnEvent(self.XFHDBtn, self.OnXFHDBtnClick, self)
    self.XFHDRedPoint = UIUtils.FindGo(trans, "XFHD/RedPoint")
    self.XFHDEffect = UIUtils.FindGo(trans, "XFHD/Effect")
    self.XFHDMenuTrans = UIUtils.FindTrans(trans, "XFHDMenu")
    self.XFHDMenuGo = UIUtils.FindGo(trans, "XFHDMenu")
    self.XFHDMenuTrans = UIUtils.FindTrans(trans, "XFHDMenu")
    self.XFHDMenuBack = UIUtils.FindSpr(trans, "XFHDMenu/Back")
    self.XFHDMenuGrid = UIUtils.FindGrid(trans, "XFHDMenu/Grid")
    self.XFHDMenuRes = nil
    local _parentTrans = self.XFHDMenuGrid.transform
    local _childCount = _parentTrans.childCount
    self.XFHDMenuList = List:New()
    for i = 1, _childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        local _menuBtn = L_XFHDMenuBtn:New(_childTrans, self)
        self.XFHDMenuList:Add(_menuBtn)
        if self.XFHDMenuRes == nil then
            self.XFHDMenuRes = _menuBtn.Go
        end
    end
    self.XFHDMenuGo:SetActive(false)
    self.ShowXFHDMenu = false

    self.StartDownLevel = 18
    local _gCfg = DataConfig.DataGlobal[GlobalName.Update_Start_Level]
    if _gCfg ~= nil then
        self.StartDownLevel = tonumber(_gCfg.Params)
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.new_sever_activity]
    if _gCfg ~= nil then
        local _gParams = Utils.SplitNumber(_gCfg.Params, '_')
        self.XFHDStartDay = _gParams[1]
        self.XFHDEndDay = _gParams[2]
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.new_sever_activity_ID]
    if _gCfg ~= nil then
        L_XFHDFuncs = Utils.SplitNumber(_gCfg.Params, '_')
    end
    _gCfg = DataConfig.DataGlobal[GlobalName.new_activity]
    if _gCfg ~= nil then
        L_XFDHYYHDs = Utils.SplitNumber(_gCfg.Params, '_')
    end

    self.V4HelpBtn = UIUtils.FindBtn(trans, "V4Help")
    UIUtils.AddBtnEvent(self.V4HelpBtn, self.OnV4HelpBtnClick, self)
    self.V4HelpBtnRedPoint = UIUtils.FindGo(trans, "V4Help/RedPoint")
    self.V4HelpBtnEffect = UIUtils.FindGo(trans, "V4Help/Effect")
    return self
end

function UIMainCustomBtnPanel:OnShowAfter()
    self.XFHDMenuGo:SetActive(false)
    self.ShowXFHDMenu = false
    self:UpdateXFHDList()
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ServeCrazy))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.GrowthWay))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.TerritorialWar))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FuDi))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.CrossFuDi))
    self:OnUpdateFunc(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.V4HelpBase))
    self:CheckFuDiRemainTime()
end

function UIMainCustomBtnPanel:OnHideBefore()
    for i = 1, #self.BtnList do
        self.BtnList[i]:DestoryVfx()
    end
end

function UIMainCustomBtnPanel:OnTryHide()
    if self.XFHDMenuGo.activeSelf then
        self.XFHDMenuGo:SetActive(false)
        self.ShowXFHDMenu = false
        return false
    end
    return true
end

function UIMainCustomBtnPanel:OnRefreshHDList(obj, sender)
    self.UpdateHDFrameCount = 10
end

function UIMainCustomBtnPanel:OnRefreshSingleHD(typeId, sender)
    local _logicId = typeId // 1000
    for i = 1, #L_XFDHYYHDs do
        if L_XFDHYYHDs[i] == _logicId then
            self.UpdateHDFrameCount = 10
            break
        end
    end
end

function UIMainCustomBtnPanel:UpdateXFHDList()
    local _index = 1
    local _showRedPoint = false
    local _showCount = 0
    local _serverDay = Time.GetOpenSeverDay()
    if _serverDay >= self.XFHDStartDay and _serverDay <= self.XFHDEndDay then
        for i = 1, #L_XFDHYYHDs do
            local _hdList = GameCenter.YYHDSystem:GetHDListByLogicId(L_XFDHYYHDs[i])
            for j = 1, #_hdList do
                local _btn = nil
                if _index <= #self.XFHDMenuList then
                    _btn = self.XFHDMenuList[_index]
                else
                    _btn = L_XFHDMenuBtn:New(UnityUtils.Clone(self.XFHDMenuRes).transform, self)
                    self.XFHDMenuList:Add(_btn)
                end
                if _btn:SetInfo(nil, _hdList[j]) then
                    _showCount = _showCount + 1
                end
                if _btn.ShowRedPoint then
                    _showRedPoint = true
                end
                _index = _index + 1
            end
        end
        for i = 1, #L_XFHDFuncs do
            local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(L_XFHDFuncs[i])
            if _funcInfo ~= nil then
                local _btn = nil
                if _index <= #self.XFHDMenuList then
                    _btn = self.XFHDMenuList[_index]
                else
                    _btn = L_XFHDMenuBtn:New(UnityUtils.Clone(self.XFHDMenuRes).transform, self)
                    self.XFHDMenuList:Add(_btn)
                end
                if _btn:SetInfo(_funcInfo, nil) then
                    _showCount = _showCount + 1
                end
                if _btn.ShowRedPoint then
                    _showRedPoint = true
                end
                _index = _index + 1
            end
        end
    end
    for i = _index, #self.XFHDMenuList do
        self.XFHDMenuList[i]:SetInfo(nil, nil)
    end
    if _showCount > 0 then
        self.XFHDRedPoint:SetActive(_showRedPoint)
        self.XFHDBtn.gameObject:SetActive(true)
        self.XFHDMenuBack.height = _showCount * 48 + 11
    else
        self.XFHDBtn.gameObject:SetActive(false)
    end
end

function UIMainCustomBtnPanel:CheckFuDiRemainTime()
    self.UpdateFdTime = false
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FuDi) then
        local _serverOpenTime = GameCenter.FuDiSystem.ServeOpenTime
        if _serverOpenTime > 0 then
            local _zoneTime = GameCenter.HeartSystem.ServerZoneOffset
            _serverOpenTime = _serverOpenTime + _zoneTime
            local _serverTime = GameCenter.HeartSystem.ServerZoneTime
            local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(_serverOpenTime))
            local _fudiOpenTime = _serverOpenTime - _hour * 3600 - _min * 60 - _sec + 86400
            if _fudiOpenTime > _serverTime then
                self.UpdateFdTime = true
                self.XmfdOpenTime = _fudiOpenTime
                self.XmfdFrontTime = -1
            end
        end
    end
    self.XmfdRemainTimeGo:SetActive(self.UpdateFdTime)
end

function UIMainCustomBtnPanel:Update(dt)
    if not self.IsVisible then
        return
    end
    for i = 1, #self.BtnList do
        self.BtnList[i]:Update(dt)
    end
    if self.ShowCount ~= #GameCenter.MainCustomBtnSystem.BtnList then
        self:UpdatePage(nil)
    end

    if self.UpdateHDFrameCount ~= nil then
        self.UpdateHDFrameCount = self.UpdateHDFrameCount - 1
        if self.UpdateHDFrameCount <= 0 then
            self:UpdateXFHDList()
            self:UpdatePage(nil)
            self.UpdateHDFrameCount = nil
        end
    end

    if self.ShowXFHDMenu and (Time.GetFrameCount() - self.XFHDMenuOpenFrame) > 10 and CSInput.GetMouseButtonUp(0) then
        self.XFHDMenuGo:SetActive(false)
        self.ShowXFHDMenu = false
    end

    self:UpdateZJYZTime()
    self:UpdateKFKHTime()
    
    if Time.GetFrameCount() % 10 == 0 then
        -- Update download
        self:UpdateDownloadInfo(dt);

        -- Updated the countdown to the Blessed Land
        if self.UpdateFdTime then
            local _serverTime = GameCenter.HeartSystem.ServerZoneTime
            local _iTime = math.floor(self.XmfdOpenTime - _serverTime)
            if _iTime < 0 then
                self.UpdateFdTime = false
                self.XmfdRemainTimeGo:SetActive(self.UpdateFdTime)
            elseif self.XmfdFrontTime ~= _iTime then
                local _hh = _iTime // 3600
                _iTime = _iTime - (_hh * 3600)
                local _mm = _iTime // 60
                local _sec = _iTime % 60
                if _hh > 0 then
                    UIUtils.SetTextByEnum(self.XmfdRemainTime, "C_XMFD_OPENTIME_H", _hh)
                else
                    UIUtils.SetTextByEnum(self.XmfdRemainTime, "C_XMFD_OPENTIME_MMSS", _mm, _sec)
                end
            end
        end
    end
end

function UIMainCustomBtnPanel:UpdatePage(obj, sender)
    self.ShowList:Clear()
    local _list = GameCenter.MainCustomBtnSystem.BtnList
    self.ShowCount = #_list
    for i = 1, self.ShowCount do
        local _btn = nil
        if i <= #self.BtnList then
            _btn = self.BtnList[i]
        else
            _btn = L_UICustomBtn:New(UnityUtils.Clone(self.ResGo))
            self.BtnList:Add(_btn)
        end
        _btn:SetInfo(_list[i])
        self.ShowList:Add(_btn.RootTrans)
    end
    for i = self.ShowCount + 1, #self.BtnList do
        self.BtnList[i]:SetInfo(nil)
    end
    if self.XFHDBtn.gameObject.activeSelf then
        self.ShowList:Add(self.XFHDBtn.transform)
    end
    if self.V4HelpBtn.gameObject.activeSelf then
        self.ShowList:Add(self.V4HelpBtn.transform)
    end
    if self.XmfdBtn.gameObject.activeSelf then
        self.ShowList:Add(self.XmfdBtn.transform)
    end
    if self.ZJYZBtn.gameObject.activeSelf then
        self.ShowList:Add(self.ZJYZBtn.transform)
    end
    if self.KfkhBtn.gameObject.activeSelf then
        self.ShowList:Add(self.KfkhBtn.transform)
    end
    if self.TerritorialWarBtn.gameObject.activeSelf then
        self.ShowList:Add(self.TerritorialWarBtn.transform)
    end
    if self.CzzlBtn.gameObject.activeSelf then
        self.ShowList:Add(self.CzzlBtn.transform)
    end
    if self.DownResProGo.activeSelf then
        self.ShowList:Add(self.DownResProGo.transform)
    end
    local _startX = 244
    for i = 1, #self.ShowList do
        UnityUtils.SetLocalPosition(self.ShowList[i], _startX, -209, 0)
        _startX = _startX - 83
    end
end
function UIMainCustomBtnPanel:UpdateDownloadInfo(dt)
    local _funcVisible = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.UpdateGift)
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _system = GameCenter.UpdateSystem
    local _downFinish = _system:IsBaseResDownloadFinish()
    if _funcVisible and _lpLevel >= self.StartDownLevel and (not _downFinish or not _system.IsGetedAward) then
        -- Not downloaded or rewarded yet
        if not _downFinish then
            -- Not finished downloading yet, display progress
            local _total = _system:GetBaseResTotalSize()
            local _downloaded = _system:GetTotalDownloadedSize()
            local _pro = 0
            if _total > 0 then
                _pro = _downloaded / _total
            end
            UIUtils.SetTextByPercent(self.DownResProLab, math.floor(_pro * 100))
            self.DownResProSpr.fillAmount = 1 - _pro

            if self.DownResRedPoint.activeSelf then
                self.DownResRedPoint:SetActive(false)
            end

            if self.DownTipsCloseTimer > 0 then
                self.DownTipsCloseTimer = self.DownTipsCloseTimer - dt * 5
            end
            if self.DownTipsCloseTimer > 0 ~= self.DownResTipsGo.activeSelf then
                self.DownResTipsGo:SetActive(self.DownTipsCloseTimer)
            end
        else
            self.DownResProSpr.fillAmount = 0
            -- Download completed
            if self.DownResTipsGo.activeSelf then
                self.DownResTipsGo:SetActive(false)
            end
         
            if not self.DownResRedPoint.activeSelf then
                self.DownResRedPoint:SetActive(true)
            end
            UIUtils.SetTextByEnum(self.DownResProLab, "C_XIAZAIJIANGLI")
        end
        if not self.DownResProGo.activeSelf then
            self.DownResProGo:SetActive(true)
            self:UpdatePage(nil)
        end
    else
        if self.DownResProGo.activeSelf then
            self.DownResProGo:SetActive(false)
            self:UpdatePage(nil)
        end
    end
end

function UIMainCustomBtnPanel:OnDownResProBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIUpdateGiftForm_OPEN)
end

function UIMainCustomBtnPanel:UpdateKFKHTime()
    if self.KFKHState == 0 then
        local _serverTime = GameCenter.HeartSystem.ServerZoneTime
        local _remainTime = self.KFKHRemainTime - (_serverTime - self.KFKHSyncTime)
        if _remainTime < 0 then
            self:RefreshKFKHTime()
        else
            local _iTime = math.floor(_remainTime)
            if _iTime ~= self.KFKHFrontTime then
                self.KFKHFrontTime = _iTime
                local _h = _iTime // 3600
                _iTime = _iTime - (_h * 3600)
                local _m = _iTime // 60
                local _s = _iTime - (_m * 60)
                UIUtils.SetTextByEnum(self.KfkhTime, "C_KFKH_JIESUAN_TIME", _h, _m, _s)
            end
        end
    elseif self.KFKHState == 1 then
        local _serverTime = GameCenter.HeartSystem.ServerZoneTime
        local _remainTime = self.KFKHRemainTime - (_serverTime - self.KFKHSyncTime)
        if _remainTime < 0 then
            self:RefreshKFKHTime()
        end
    end
end

function UIMainCustomBtnPanel:RefreshKFKHTime()
    local _openDay = Time.GetOpenSeverDay()
    self.KFKHState = nil -- Service opening carnival status 0 to settle, 1 settled
    self.KFKHRemainTime = nil
    self.KFKHSyncTime = GameCenter.HeartSystem.ServerZoneTime
    self.KFKHFrontTime = nil
    if self.KFKHDayList == nil then
        self.KFKHDayList = List:New()
        DataConfig.DataNewSeverRank:Foreach(function(k, v)
            self.KFKHDayList:Add(v.ServerEndTime)
        end)
    end
    local _targetDay = nil
    for i = 1, #self.KFKHDayList do
        if _openDay <= self.KFKHDayList[i] then
            _targetDay = self.KFKHDayList[i]
            break
        end
    end
    if _targetDay == nil then
        UIUtils.ClearText(self.KfkhTime)
        return
    end
    local _serverTime = math.floor(self.KFKHSyncTime)
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _todayStartTime = _serverTime - _hour * 3600 - _min * 60 - _sec
    local _endTime = _todayStartTime + 23 * 3600 + (_targetDay - _openDay) * 86400
    if _endTime >= _serverTime then
        self.KFKHState = 0 -- 0 to be settled
        self.KFKHRemainTime = _endTime - _serverTime
    else
        self.KFKHState = 1 -- 1 settled
        UIUtils.SetTextByEnum(self.KfkhTime, "C_KFKH_YIJIESUAN")
        self.KFKHRemainTime = _todayStartTime + 86400 - _serverTime
    end
end
    
function UIMainCustomBtnPanel:OnUpdateFunc(funcInfo, sender)
    if funcInfo == nil then
        return
    end
    local _funcId = funcInfo.ID
    if _funcId == FunctionStartIdCode.ServeCrazy then
        self.KfkhBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.KfkhRedPoint:SetActive(funcInfo.IsShowRedPoint)
        self:UpdatePage(nil)
        if funcInfo.IsVisible then
            self:RefreshKFKHTime()
        end
    elseif _funcId == FunctionStartIdCode.GrowthWay then
        self.CzzlBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.CzzlRedPoint:SetActive(funcInfo.IsShowRedPoint)
        self:UpdatePage(nil)
    elseif _funcId == FunctionStartIdCode.TerritorialWar then
        self.TerritorialWarBtn.gameObject:SetActive(funcInfo.IsVisible)
        self:UpdatePage(nil)
    elseif _funcId == FunctionStartIdCode.FuDi then
        self.XmfdBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.XmfdRedPoint:SetActive(funcInfo.IsShowRedPoint)
        self.XmfdEffect:SetActive(funcInfo.IsEffectShow)
        if funcInfo.CurUpdateType == 1 then
            self:CheckFuDiRemainTime()
        end
        self:UpdatePage(nil)
    elseif _funcId == FunctionStartIdCode.CrossFuDi then
        self.ZJYZBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.ZJYZRedPoint:SetActive(funcInfo.IsShowRedPoint)
        self:RefreshZJYZTime()
        self:UpdatePage(nil)
    elseif _funcId == FunctionStartIdCode.V4HelpBase then
        self.V4HelpBtn.gameObject:SetActive(funcInfo.IsVisible)
        self.V4HelpBtnRedPoint:SetActive(funcInfo.IsShowRedPoint)
        self.V4HelpBtnEffect:SetActive(funcInfo.IsEffectShow)
        self:UpdatePage(nil)
    end
    for i = 1, #L_XFHDFuncs do
        if L_XFHDFuncs[i] == _funcId then
            self:UpdateXFHDList()
            self:UpdatePage(nil)
            break
        end
    end
end

function UIMainCustomBtnPanel:UpdateZJYZTime()
    if self.ZJYZSyncTime ~= nil then
        local _serverTime = GameCenter.HeartSystem.ServerZoneTime
        if self.ZJYZTimeType == 0 then
            local _remainTime = self.ZJYZTypeRemianTime - (_serverTime - self.ZJYZSyncTime)
            if _remainTime < 0 then
                self:RefreshZJYZTime()
            end
        elseif self.ZJYZTimeType == 1 then
            local _remainTime = self.ZJYZTypeRemianTime - (_serverTime - self.ZJYZSyncTime)
            local _iTime = math.floor(_remainTime)
            if _iTime ~= self.ZJYZFrontTime then
                self.ZJYZFrontTime = _iTime
                local _h = _iTime // 3600
                _iTime = _iTime - (_h * 3600)
                local _m = _iTime // 60
                local _s = _iTime - (_m * 60)
                UIUtils.SetTextByEnum(self.ZJYZTimeLabel, "C_ZJYZ_MIAN_REMAIN_TIME", _h, _m, _s)
            end
            if _remainTime < 0 then
                self:RefreshZJYZTime()
            end
        end
    end
end

function UIMainCustomBtnPanel:RefreshZJYZTime()
    local _frontType = self.ZJYZTimeType
    self.ZJYZTimeType = -1
    self.ZJYZTypeRemianTime = -1
    self.ZJYZFrontTime = nil
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.CrossFuDi) then
        if self.ZJYZTimeTable == nil then
            self.ZJYZTimeTable = List:New()
            local _cfg = DataConfig.DataCrossFudiMain[201]
            if _cfg ~= nil then
                local _timeTable = Utils.SplitNumber(_cfg.RefreshTime, '_')
                for i = 1, #_timeTable do
                    self.ZJYZTimeTable:Add(_timeTable[i] * 60)
                end
            end
        end
        if #self.ZJYZTimeTable > 0 then
            local _serverTime = GameCenter.HeartSystem.ServerZoneTime
            self.ZJYZSyncTime = _serverTime
            _serverTime = math.floor(_serverTime)
            -- Get the current number of seconds
            local _h, _m, _s = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
            local _curSec = _h * 3600 + _m * 60 + _s
            local _nextTime = nil
            for i = 1, #self.ZJYZTimeTable do
                local _sec = self.ZJYZTimeTable[i]
                if _nextTime == nil and _curSec < _sec then
                    _nextTime = _sec - _curSec
                end
                if _curSec >= _sec and (_curSec - _sec) < 1800 then
                    -- Refreshed
                    self.ZJYZTimeType = 0
                    self.ZJYZTypeRemianTime = 1800 - (_curSec - _sec)
                    if _frontType ~= self.ZJYZTimeType then
                        self.ZJYZShowTips = true
                    end
                    self.ZJYZTipsGo:SetActive(self.ZJYZShowTips)
                    UIUtils.SetTextByEnum(self.ZJYZTimeLabel, "MAINBOSS_YISHUAXIN")
                    self.ZJYZEffect:SetActive(self.ZJYZShowTips)
                    break
                end
            end
            if self.ZJYZTimeType ~= 0 then
                self.ZJYZTimeType = 1
                self.ZJYZTipsGo:SetActive(false)
                self.ZJYZShowTips = false
                if _nextTime == nil then
                    self.ZJYZTypeRemianTime = self.ZJYZTimeTable[1] + (86400 - _curSec)
                else
                    self.ZJYZTypeRemianTime = _nextTime
                end
            end
        end
    end
end

function UIMainCustomBtnPanel:OnXMFDBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.FuDi)
    GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.FuDi, false)
    self.XmfdEffect:SetActive(false)
end

function UIMainCustomBtnPanel:OnZJYZBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.CrossFuDi)
    self.ZJYZEffect:SetActive(false)
    self.ZJYZTipsGo:SetActive(false)
    self.ZJYZShowTips = false
end

function UIMainCustomBtnPanel:OnV4HelpBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.V4HelpBase)
end

function UIMainCustomBtnPanel:OnXFHDBtnClick()
    self.ShowXFHDMenu = true
    self.XFHDMenuGo:SetActive(true)
    self.XFHDMenuOpenFrame = Time.GetFrameCount()
    local _pos = self.XFHDBtn.transform.localPosition
    UnityUtils.SetLocalPosition(self.XFHDMenuTrans, _pos.x, _pos.y, 0)
    self.XFHDMenuGrid:Reposition()
    self.XFHDEffect:SetActive(false)
end

function UIMainCustomBtnPanel:OnKFKHClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ServeCrazy)
    self.KfkhEffect:SetActive(false);
end

function UIMainCustomBtnPanel:OnCZZLClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GrowthWay)
    self.CzzlEffect:SetActive(false);
end

function UIMainCustomBtnPanel:OnTerritorialWarClick()
    GameCenter.BISystem:ReqClickEvent(BiIdCode.HDMJMainEnter)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TerritorialWar)
    self.TerritorialEffect:SetActive(false)
end

function UIMainCustomBtnPanel:GetFlyFuncTrans(id)
    if id == FunctionStartIdCode.ServeCrazy then
        return UIUtils.FindWid(self.Trans, "KFKH")
    elseif id == FunctionStartIdCode.GrowthWay then
        return UIUtils.FindWid(self.Trans, "CZZL")
    elseif id == FunctionStartIdCode.FuDi then
        return UIUtils.FindWid(self.Trans, "XMFD")
    end
    return nil
end

L_UICustomBtn = {
    RootTrans = nil,
    RemainTime = nil,
    Name = nil,
    FrontUpdateTime = 0;
    Icon = nil,
    Btn = nil,
    IconGo = nil,
    RedPointGo = nil,
    EffectGo = nil,
    TweenRot = nil,
    Data = nil,
}
function L_UICustomBtn:New(rootGo)
    local _m = Utils.DeepCopy(self)
    _m.IconGo = rootGo
    _m.RootTrans = rootGo.transform
    local _trans = _m.RootTrans
    _m.RemainTime = UIUtils.FindLabel(_trans, "Time")
    _m.Name = UIUtils.FindLabel(_trans, "Name")
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.Icon = UIUtils.RequireUIIcon(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.RedPointGo = UIUtils.FindGo(_trans, "RedPoint")
    _m.EffectGo = UIUtils.FindGo(_trans, "Effect")
    _m.TweenRot = UIUtils.FindTweenRotation(_trans, "Icon")
    _m.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "Vfx"))
    return _m
end
function L_UICustomBtn:SetInfo(data)
    self.Data = data
    if data ~= nil then
        self.Icon:UpdateIcon(data.IconID)
        self.RemainTime.gameObject:SetActive(data.UseRemainTime)
        self.RedPointGo:SetActive(data.ShowRedPoint)
        self.EffectGo:SetActive(data.ShowEffect)

        local csLabel = GosuSDK.GetLocalizedName(data.ShowText)

        UIUtils.SetTextByString(self.Name, csLabel)

        self.FrontUpdateTime = -1
        self.IconGo:SetActive(true)
        if data.TweenRot then
            self.TweenRot.enabled = true
        else
            self.TweenRot.enabled = false
            UnityUtils.SetLocalEulerAngles(self.RootTrans, 0, 0, 0)
        end
        if data.VfxId ~= nil then
            self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, data.VfxId, LayerUtils.GetAresUILayer())
        else
            self:DestoryVfx()
        end
    else
        self.IconGo:SetActive(false)
        self:DestoryVfx()
    end
end
function L_UICustomBtn:CheckActive()
    -- Debug.Log("CheckActive for button: " .. self.Data.ShowText)
    if self.Data ~= nil and self.Data.IsRemainTimeStart then
        local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
        if _serverTime == nil then
            self.IconGo:SetActive(false)
            return
        end
        -- Get the current number of seconds
        -- local _h, _m, _s = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        -- local _curSec = _h * 3600 + _m * 60 + _s
        local _remainTime = self.Data:GetRemainTime()
        -- local _diff = _remainTime - _curSec
        -- Debug.Log("Remain time: " .. _remainTime)
        local _remainTimeCfg = DataConfig.DataGlobal[GlobalName.Main_Custom_Btn_Remain_Time_Active] or {}
        local _remainTimeActive = tonumber(_remainTimeCfg.Params) or 0
        if _remainTime <= _remainTimeActive then
            self.IconGo:SetActive(true)
        else
            self.IconGo:SetActive(false)
        end
    else
        self.IconGo:SetActive(false)
    end
end
function L_UICustomBtn:Update(dt)
    if self.Data ~= nil and self.Data.UseRemainTime then
        if self.Data.IsRemainTimeStart then
            self:CheckActive()
        end

        local _curTime = math.floor(self.Data:GetRemainTime())
        if _curTime ~= self.FrontUpdateTime then
            self.FrontUpdateTime = _curTime
            local _hour = math.floor(_curTime / 3600)
            _curTime = _curTime - _hour * 3600;
            local _min = math.floor(_curTime / 60)
            _curTime = _curTime - _min * 60;
            if _hour > 0 then
                UIUtils.SetTextFormat(self.RemainTime, "{0:D2}:{1:D2}:{2:D2}{3}", _hour, _min, _curTime, self.Data.RemainTimeSuf)
            elseif _min > 0 then
                UIUtils.SetTextFormat(self.RemainTime, "{0:D2}:{1:D2}{2}", _min, _curTime, self.Data.RemainTimeSuf)
            else
                UIUtils.SetTextFormat(self.RemainTime, "{0:D2}{1}", _curTime, self.Data.RemainTimeSuf)
            end
        end
    end
end
function L_UICustomBtn:OnBtnClick()
    if self.Data ~= nil then
        self.Data.ClickTrans = self.RootTrans
        self.Data.ClickCallBack(self.Data)
    end
end

function L_UICustomBtn:DestoryVfx()
    if self.VfxSkin ~= nil then
        self.VfxSkin:OnDestory()
    end
end

L_XFHDMenuBtn = {
    Parent = nil,
    Trans = nil,
    Go = nil,
    Btn = nil,
    Name = nil,
    RedPoint = nil,
    FuncData = nil,
    HDData = nil,
    ShowRedPoint = false,
}

function L_XFHDMenuBtn:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    return _m
end

function L_XFHDMenuBtn:SetInfo(funcData, hdData)
    self.FuncData = funcData
    self.HDData = hdData
    local _isShow = false
    if self.FuncData == nil and self.HDData == nil then
        self.Go:SetActive(false)
        self.ShowRedPoint = false
    else
        if self.FuncData ~= nil then
            if self.FuncData.IsVisible then
                local _cfg = DataConfig.DataFunctionStart[funcData.ID]
                UIUtils.SetTextByStringDefinesID(self.Name, _cfg._FunctionName)
                self.ShowRedPoint = self.FuncData.IsShowRedPoint
                self.Go:SetActive(true)
                _isShow = true
            else
                self.Go:SetActive(false)
                self.ShowRedPoint = false
            end
        elseif self.HDData ~= nil then
            if self.HDData:IsActive() then
                UIUtils.SetTextByString(self.Name, self.HDData.Name)
                self.ShowRedPoint = self.HDData:IsShowRedPoint()
                self.Go:SetActive(true)
                _isShow = true
            else
                self.Go:SetActive(false)
                self.ShowRedPoint = false
            end
        end
        self.RedPoint:SetActive(self.ShowRedPoint)
    end
    return _isShow
end

function L_XFHDMenuBtn:OnClick()
    self.Parent.XFHDMenuGo:SetActive(false)
    self.Parent.ShowXFHDMenu = false
    if self.FuncData ~= nil then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(self.FuncData.ID)
    elseif self.HDData ~= nil then
        GameCenter.YYHDSystem:OpenHD(self.HDData.TypeId)
    end
end

return UIMainCustomBtnPanel