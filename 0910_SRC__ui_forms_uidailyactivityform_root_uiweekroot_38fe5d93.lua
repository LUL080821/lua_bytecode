------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIWeekRoot.lua
-- Module: UIWeekRoot
-- Description: Weekly Root
------------------------------------------------
local UIWeekItem = require "UI.Forms.UIDailyActivityForm.Item.UIWeeklItem"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils

local UIWeekRoot = {
    -- Owner
    Owner = nil,
    -- Trans
    Trans = nil,
    Go = nil,
    Item = nil,
    ListPanel = nil,
    TitleSelectTable = nil,
    BackSelectTable = nil,
    NormalTexs = nil,
    SelectTexs = nil,
    BackTrans = List:New(),
}

function UIWeekRoot:New(owner, trans)
    self.Owner = owner
    self.Trans = trans
    self.Go = trans.gameObject
    self:FindAllComponents()
    self:Close()
    return self
end

function UIWeekRoot:FindAllComponents()
    self.Item = UIUtils.FindTrans(self.Trans, "ListPanel/Grid/Item")
    self.ListPanel = UIUtils.FindTrans(self.Trans,"ListPanel/Grid")
    --1 - 7
    self.TitleSelectTable = {}
    self.BackSelectTable = {}
    self.NormalTexs = {}
    self.SelectTexs = {}
    self.BackTrans:Clear()
    for i = 1, 7 do
        self.TitleSelectTable[i] = UIUtils.FindGo(self.Trans, string.format("BiaoQianGrid/Bar_%d/Select", i))
        self.BackSelectTable[i] = UIUtils.FindGo(self.Trans, string.format("BiaoQianGrid/Bar_%d/Back/Select", i))
        self.NormalTexs[i] = UIUtils.FindTex(self.Trans, string.format("BiaoQianGrid/Bar_%d/Back/Normal", i))
        self.SelectTexs[i] = UIUtils.FindTex(self.Trans, string.format("BiaoQianGrid/Bar_%d/Back/Select", i))
        local _childTrans = UIUtils.FindTrans(self.Trans, string.format("BiaoQianGrid/Bar_%d/Back", i))
        self.Owner.CSForm:AddAlphaScaleAnimation(_childTrans, 0, 1, 0, 1, 1, 1, 0.2, false, false)
        self.BackTrans:Add(_childTrans)
    end
end

function UIWeekRoot:RegUICallback()
end

function UIWeekRoot:RefreshWeekActivity()
    local _index = 1
    local _temp = 0
    local _isWhile = true
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    -- Calculate the current week 1 - 7
    local _week = TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if _week == 0 then
        _week = 7
    end
    
    local _animList1 = List:New()
    self.Owner.AnimPlayer:Stop()
    local maxKey = 0

    local function  _forFunc(key, value)
        local _key = key
        if _key > maxKey then
            maxKey = _key
        end
    end
    DataConfig.DataActiveWeek:Foreach(_forFunc)
    while _isWhile do
        for i = 1, 7 do
            local _id = i * 100 + _index
            local _cfg = DataConfig.DataActiveWeek[_id]
            if _cfg == nil and _id > maxKey then
                _isWhile = false
                break
            end
            local _cfgId = _cfg ~= nil and _cfg.Id or -1
            local _item = nil
            if _temp < self.ListPanel.childCount then
                _item = UIWeekItem:New(self.ListPanel:GetChild(_temp), _cfgId)
            else
                _item = UIWeekItem:Clone(self.Item.gameObject, self.ListPanel, _cfgId)
            end
            _item:RefreshWeekly(_week)
            _temp = _temp + 1
            if _cfgId ~= -1 then
                _animList1:Add({_item.Trans, i - 1})
            end
        end
        _index = _index + 1
    end
    self:SetWeek(_week)
    UnityUtils.GridResetPosition(self.ListPanel)

    for i = 1, #_animList1 do
        local _trans = _animList1[i][1]
        local _weekTrans = _animList1[i][2]
        self.Owner.CSForm:RemoveTransAnimation(_trans)
        --self.Owner.CSForm:AddAlphaPosAnimation(_trans, 0, 1, 0, 50, 0.2, false, false)
        self.Owner.CSForm:AddAlphaScaleAnimation(_trans, 0, 1, 0, 1, 1, 1, 0.2, false, false)
        self.Owner.AnimPlayer:AddTrans(_trans, _weekTrans * 0.05)
    end
    for i = 1, #self.BackTrans do
        self.Owner.AnimPlayer:AddTrans(self.BackTrans[i], (i - 1) * 0.05)
    end
    self.Owner.AnimPlayer:Play()
end

function UIWeekRoot:LoadTex()
    for i = 1, 7 do
        self.Owner.CSForm:LoadTexture(self.NormalTexs[i], AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_46_1"))
        self.Owner.CSForm:LoadTexture(self.SelectTexs[i], AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_46_2"))
    end
end

function UIWeekRoot:SetWeek(week)
    for i = 1, 7 do
        self.TitleSelectTable[i]:SetActive(week == i)
        self.BackSelectTable[i]:SetActive(week == i)
    end
end

function UIWeekRoot:Show()
    self:LoadTex()
    self:RefreshWeekActivity()
    self.Go:SetActive(true)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Calendar, false)
end

function UIWeekRoot:Close()
    self.Go:SetActive(false)
end

return UIWeekRoot