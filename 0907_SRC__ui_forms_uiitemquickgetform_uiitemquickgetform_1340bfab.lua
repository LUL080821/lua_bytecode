------------------------------------------------
-- author:
-- Date: 2019-5-30
-- File: UIItemQuickGetForm.lua
-- Module: UIItemQuickGetForm
-- Description: Quick item acquisition interface
------------------------------------------------

local UIItemQuickGetFunc = require "UI.Forms.UIItemQuickGetForm.UIItemQuickGetFunc"
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils");
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

-- //Module definition
local UIItemQuickGetForm = {
    -- Close button
    CloseBtn = nil,
    -- Item name
    ItemName = nil,
    -- Item icon
    ItemIcon = nil,
    -- Item quality
    ItemQuality = nil,
    -- Sliding list
    ScrollView = nil,
    --grid
    Grid = nil,
    GridTrans = nil,
    -- Background picture
    BackTex = nil,
    -- Functional Resources
    FuncItemRes = nil,
    -- Functional resource list
    FuncItemList = nil,
    -- Functional description of items
    TipsLabel = nil,
    TipsLabelGo = nil,

    GodBtn = nil,
}

-- Inheriting Form functions
function UIItemQuickGetForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIItemQuickGetForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIItemQuickGetForm_CLOSE,self.OnClose)
end

function UIItemQuickGetForm:OnFirstShow()
    self.CSForm:AddNormalAnimation(0.3)
    self.CSForm.UIRegion = UIFormRegion.TopRegion

    self.CloseBtn = UIUtils.FindBtn(self.Trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.ItemName = UIUtils.FindLabel(self.Trans, "Back/Name")
    self.ItemQuality = UIUtils.FindSpr(self.Trans, "Back/Quality")
    self.ItemIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Back/Quality/Icon"))
    self.ScrollView = UIUtils.FindScrollView(self.Trans, "Back/Scroll")
    self.Grid = UIUtils.FindGrid(self.Trans, "Back/Scroll/Grid")
    self.GridTrans = self.Grid.transform
    self.BackTex = UIUtils.FindTex(self.Trans, "Back")
    self.TipsLabel = UIUtils.FindLabel(self.Trans, "TipsLabel")
    self.TipsLabelGo = UIUtils.FindGo(self.Trans, "TipsLabel")

    self.FuncItemRes = nil
    self.FuncItemList = List:New()
    for i = 0, self.GridTrans.childCount - 1 do
        local _go = self.GridTrans:GetChild(i).gameObject
        if self.FuncItemRes == nil then
            self.FuncItemRes = _go
        end
        self.FuncItemList:Add(UIItemQuickGetFunc:New(_go, self))
    end
    self.GodBtn = UIUtils.FindBtn(self.Trans, "GMGet")
    UIUtils.AddBtnEvent(self.GodBtn, self.OnGodBtnClick, self)
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIItemQuickGetForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_266"))
    self.GodBtn.gameObject:SetActive(L_UnityUtils.UNITY_EDITOR())
end

function UIItemQuickGetForm:OnHideBefore()
end

-- Turn on the event
function UIItemQuickGetForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.ItemId = tonumber(obj)
    self:RefreshPageInfo(self.ItemId)
end

-- Close Event
function UIItemQuickGetForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Close button
function UIItemQuickGetForm:OnCloseBtnClick()
    self:OnClose(nil, nil)
end

function UIItemQuickGetForm:OnGodBtnClick()
    local _num = nil
    if self.ItemId < 100 then
        _num = 5000000
    end
    local req ={}
    req.chattype = 0
    req.recRoleId = 0
    if _num == nil then
        req.condition = string.format("&additem %d", self.ItemId)
    else
        req.condition = string.format("&additem %d %d", self.ItemId, _num)
    end
    req.chatchannel = 8;
    req.voiceLen = 0;
    req.test = 111;
    GameCenter.Network.Send("MSG_Chat.ChatReqCS",req);
end

-- Sort functions
local function SortFunc(left, right)
    return left.SortValue > right.SortValue
end

-- Refresh the interface
function UIItemQuickGetForm:RefreshPageInfo(id)
    local _icon = 0
    local _getText = nil
    local _quality = 0
    local _nameId = 0
    local _itemConfig = DataConfig.DataItem[id]
    local _equipConfig = DataConfig.DataEquip[id]
    if _itemConfig ~= nil then
        _icon = _itemConfig.Icon
        _getText = _itemConfig.GetText
        _quality = _itemConfig.Color
        _nameId = _itemConfig._Name
    elseif _equipConfig ~= nil then
        _icon = _equipConfig.Icon
        _getText = _equipConfig.GetText
        _quality = _equipConfig.Quality
        _nameId = _equipConfig._Name
    else
        self:OnClose(nil, nil)
        return
    end
    if _getText == nil or string.len(_getText) <= 0 then
        self:OnClose(nil, nil)
        return
    end

    self.ItemIcon:UpdateIcon(_icon)
    UIUtils.SetTextByStringDefinesID(self.ItemName, _nameId)
    UIUtils.SetColorByQuality(self.ItemName, _quality)
    self.ItemQuality.spriteName = Utils.GetQualitySpriteName(_quality)
    local _tipsStr = GameCenter.ItemQuickGetSystem.TipsStr
    self.TipsLabelGo:SetActive(_tipsStr ~= nil)
    if _tipsStr then
        UIUtils.SetTextByString(self.TipsLabel, _tipsStr)
        GameCenter.ItemQuickGetSystem.TipsStr = nil
    end
    local _getCfg = Utils.SplitStrBySeps(_getText, {';','_'})
    local _count = #_getCfg
    if _count <= 0 then
        self:OnClose(nil, nil)
        return
    end

    for i = 1, _count do
        local _usedUI = nil
        if i <= #self.FuncItemList then
            _usedUI = self.FuncItemList[i]
        else
            _usedUI = UIItemQuickGetFunc:New(UnityUtils.Clone(self.FuncItemRes.gameObject), self)
            self.FuncItemList:Add(_usedUI)
        end

        _usedUI.RootGo:SetActive(true)
        _usedUI:Refresh(tonumber(_getCfg[i][1]), _getCfg[i][3], tonumber(_getCfg[i][2]), id, _getCfg[i][4], _getCfg[i][5])
    end
    for i = _count + 1, #self.FuncItemList do
        self.FuncItemList[i].RootGo:SetActive(false)
    end
    self.FuncItemList:Sort(SortFunc)

    local _animList = List:New()
    for i = 1, #self.FuncItemList do
        local _item = self.FuncItemList[i]
        _item.RootGo.name = string.format( "%2d", i)
        if _item.RootGo.activeSelf then
            _animList:Add(_item.RootTrans)
        end
    end
    self.Grid:Reposition()
    self.ScrollView:ResetPosition()

    for i = 1, #_animList do
        local _trans = _animList[i]
        self.CSForm:RemoveTransAnimation(_trans)
        self.CSForm:AddAlphaPosAnimation(_trans, 0, 1, 0, 30, 0.3, false, false)
        self.AnimPlayer:AddTrans(_trans, (i - 1) * 0.1)
    end
    self.AnimPlayer:Play()

    -- self.CSForm:RemoveChildTransAnimation(self.GridTrans)
    -- self.CSForm:AddChildAlphaPosAnimation(self.GridTrans, 0, 1, 50, 0, 0.2, 0.1, false, false)
    -- self.CSForm:PlayChildShowAnimation(self.GridTrans)
end

function UIItemQuickGetForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

return UIItemQuickGetForm