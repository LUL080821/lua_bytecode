-- ==============================--
-- author:
-- Date: 2020-10-10
-- File: UIDailyActivityTipsForm.lua
-- Module: UIDailyActivityTipsForm
-- Description: Daily Activities Tips UI
-- ==============================--
local UIDailyActivityTipsForm = {
    RootTrans = nil,
    BackTex = nil,
    CloseBtn = nil,
    GoToBtn = nil,
    ScrollView = nil,
    Grid = nil,
    ItemRes = nil,
    ItemList = nil,
}

function UIDailyActivityTipsForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UIDailyActivityTipsForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UIDailyActivityTipsForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ACTIVITY_LIST, self.OnRefresh)
end

local L_ActivityItem = nil

function UIDailyActivityTipsForm:OnFirstShow()
    local _trans = self.Trans
    self.RootTrans = UIUtils.FindTrans(_trans, "Root")
    self.BackTex =  UIUtils.FindTex(_trans, "Root/Texture")
    self.CloseBtn = UIUtils.FindBtn(_trans, "Root/CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.GoToBtn = UIUtils.FindBtn(_trans, "Root/GoToBtn")
    UIUtils.AddBtnEvent(self.GoToBtn, self.OnGoToBtnClick, self)
    self.ScrollView = UIUtils.FindScrollView(_trans, "Root/ScrollView")
    self.Grid = UIUtils.FindGrid(_trans, "Root/ScrollView/Grid")
    self.ItemRes = nil
    self.ItemList = List:New()
    local _parentTrans = self.Grid.transform
    for i = 1, _parentTrans.childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        self.ItemList:Add(L_ActivityItem:New(_childTrans, self))
        if self.ItemRes == nil then
            self.ItemRes = _childTrans.gameObject
        end
    end
    self.CSForm:AddNormalAnimation(0.3)
end

function UIDailyActivityTipsForm:OnOpen(trans, sender)
    self.CSForm:Show(sender)
    if trans ~= nil then
        local _pos = trans.position
        UnityUtils.SetPosition(self.RootTrans, _pos.x, _pos.y, 0)
    end
end

function UIDailyActivityTipsForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIDailyActivityTipsForm:OnRefresh(obj, sender)
    local _showList = GameCenter.DailyActivityTipsSystem.ShowList
    local _index = 1
    for i = 1, #_showList do
        local _info = _showList[i]
        if _info.SortValue < 86400 * 10 then
            local _usedUI = nil
            if _index <= #self.ItemList then
                _usedUI = self.ItemList[_index]
            else
                _usedUI = L_ActivityItem:New(UnityUtils.Clone(self.ItemRes).transform, self)
                self.ItemList:Add(_usedUI)
            end
            _usedUI:SetInfo(_info)
            _index = _index + 1
        end
    end

    for i = _index, #self.ItemList do
        self.ItemList[i]:SetInfo(nil)
    end
    self.Grid:Reposition()
end

-- Displays the previous operation and provides it to the CS side to call.
function UIDailyActivityTipsForm:OnShowBefore()
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_2"))
end

function UIDailyActivityTipsForm:OnShowAfter()
    self:OnRefresh()
end

function UIDailyActivityTipsForm:OnHideAfter()
end

function UIDailyActivityTipsForm:Update(dt)
    for i = 1, #self.ItemList do
        self.ItemList[i]:Update(dt)
    end
end

function UIDailyActivityTipsForm:OnCloseBtnClick()
    self:OnClose()
end

function UIDailyActivityTipsForm:OnGoToBtnClick()
    self:OnClose()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Calendar)
end

L_ActivityItem = {
    Go = nil,
    Trans = nil,
    Name = nil,
    Time = nil,
    Icon = nil,
    Btn = nil,

    Data = nil,
    FrontUpdateTime = -1,
    Parent = nil,
}

function L_ActivityItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Parent = parent
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Time = UIUtils.FindLabel(trans, "Time")
    _m.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Icon"))
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    return _m
end

function L_ActivityItem:SetInfo(data)
    self.Data = data
    if data ~= nil then
        UIUtils.SetTextByStringDefinesID(self.Name, data.Cfg._TipsName)
        self.Icon:UpdateIcon(data.Cfg.Icon)
        self.FrontUpdateTime = -1
        self.Go:SetActive(true)
    else
        self.Go:SetActive(false)
    end
end

function L_ActivityItem:Update(dt)
    if self.Data ~= nil then
        local _iRemainTime = math.floor(self.Data.ShowRemainTime)
        if _iRemainTime ~= self.FrontUpdateTime then
            self.FrontUpdateTime = _iRemainTime
            local _h = _iRemainTime // 3600
            _iRemainTime = _iRemainTime % 3600
            local _m = _iRemainTime // 60
            _iRemainTime = _iRemainTime % 60
            local _formatStr = nil
            if self.Data.SortValue < 86400 then
                _formatStr = "C_HUODONG_JIESHU"
            else
                _formatStr = "C_HUODONG_KAISHI"
            end
            UIUtils.SetTextByEnum(self.Time, _formatStr, _h, _m, _iRemainTime)
        end
    end
end

function L_ActivityItem:OnClick()
    if self.Data ~= nil then
        if string.len(self.Data.Cfg.OpenUI) > 0 then
            local _funcId = 0
            local _funcParam = nil
            local _openUICfg = Utils.SplitStr(self.Data.Cfg.OpenUI, "_")
            _funcId = tonumber(_openUICfg[1])
            if #_openUICfg >= 2 then
                _funcParam = tonumber(_openUICfg[2])
            end
            if self.Data.SortValue < 86400 then
                -- Already enabled
                GameCenter.MainFunctionSystem:DoFunctionCallBack(_funcId, _funcParam)
            else
                -- Wait for start
                if self.Data.Cfg.Ready == 1 then
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(_funcId, _funcParam)
                else
                    Utils.ShowPromptByEnum("DailyActivityTips")
                end
            end
        end
    end
    self.Parent:OnClose()
end

return UIDailyActivityTipsForm
