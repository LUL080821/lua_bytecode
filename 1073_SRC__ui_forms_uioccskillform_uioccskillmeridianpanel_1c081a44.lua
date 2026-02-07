--==============================--
--author:
--Date: 2020-11-27
--File: UIOccSkillMeridianPanel.lua
--Module: UIOccSkillMeridianPanel
--Description: Skill meridian interface
--==============================--
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_UIOccskillMerLevelUpPanel = require "UI.Forms.UIOccSkillForm.UIOccskillMerLevelUpPanel"

local L_TitleVfx = {
    [0*100 + 1] = 561,
    [0*100 + 2] = 562,
    [1*100 + 1] = 563,
    [1*100 + 2] = 564,
    [2*100 + 1] = 566,
    [2*100 + 2] = 565,
    [3*100 + 1] = 572,
    [3*100 + 2] = 571,
}

local UIOccSkillMeridianPanel = {
    --transform
    Trans = nil,
    Go = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,
    --Animation module
    AnimModule = nil,

    HaveValue = nil,
    HaveIcon = nil,
    TitleVfx = nil,
    ListMenu = nil,
    IconItems = nil,
    AddBtn = nil,
    -- Click CD on the task submission button
    SelectXinFaBtn = nil,
    LevelUpPanel = nil,
    NeedItemCfg = nil,
    TipsLabel = nil,

    JianTous = nil,
}

local L_IconItem = nil

function UIOccSkillMeridianPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    --Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)
    self.IsVisible = false

    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(trans, "UIListMenuTop"))
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.TitleVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "UIVfxSkinCompoent"))
    self.IconItems = {}
    for i = 1, 24 do
        self.IconItems[i] = L_IconItem:New(UIUtils.FindTrans(trans, string.format("Grid/%d", i)), self)
    end
    self.HaveValue = UIUtils.FindLabel(trans, "Have/Value")
    self.HaveIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Have/Icon"))
    self.SelectXinFaBtn = UIUtils.FindBtn(trans, "SelectXinFa")
    UIUtils.AddBtnEvent(self.SelectXinFaBtn, self.OnSelectXinFaBtnClick, self)
    self.AddBtn = UIUtils.FindBtn(trans, "Have/AddBtn")
    UIUtils.AddBtnEvent(self.AddBtn, self.OnAddBtnClick, self)
    self.LevelUpPanel = L_UIOccskillMerLevelUpPanel:OnFirstShow(UIUtils.FindTrans(trans, "LevelUPPanel"), self, rootForm)
    self.TipsLabel = UIUtils.FindLabel(trans, "Tips")
    self.JianTous = {}
    for i = 1, 2 do
        local _jianTouTrans = UIUtils.FindTrans(trans, string.format("JianTou%d", i))
        self.JianTous[i] = {}
        self.JianTous[i].RootGo = _jianTouTrans.gameObject
        self.JianTous[i].TopWidget = UIUtils.FindWid(_jianTouTrans, "Top")
        self.JianTous[i].TopValueWidget = UIUtils.FindWid(_jianTouTrans, "Top/Value")
        self.JianTous[i].CenterWidget = UIUtils.FindWid(_jianTouTrans, "Center")
        self.JianTous[i].CenterValueWidget = UIUtils.FindWid(_jianTouTrans, "Center/Value")
        self.JianTous[i].ButtomWidget = UIUtils.FindWid(_jianTouTrans, "Buttom")
        self.JianTous[i].ButtomValueWidget = UIUtils.FindWid(_jianTouTrans, "Buttom/Value")
    end
    return self
end

function UIOccSkillMeridianPanel:Show(param)
    --Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true
    self.SelectIcon = nil
    self.SelectType = nil
    self:RefreshPanel()
    self.LevelUpPanel.Go:SetActive(false)
end

function UIOccSkillMeridianPanel:Hide()
    --Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
    self.TitleVfx:OnDestory()
    self.LevelUpPanel:Hide()
end

function UIOccSkillMeridianPanel:OnTryHide()
    if self.LevelUpPanel.IsVisible then
        self.LevelUpPanel:Hide()
        return false
    end
    return true
end

function UIOccSkillMeridianPanel:RefreshPanel()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end
    self.ListMenu:RemoveAll()
    local _occ = _lp.Occ
    local _chanjeJobLevel = _lp.ChangeJobLevel
    local _curMerId = GameCenter.PlayerSkillSystem.CurSelectMerId
    local _idList = List:New()
    DataConfig.DataSkillMeridianPos:Foreach(function(k, v)
        if _occ ~= v.Occ then
            return
        end
        if _chanjeJobLevel < v.ChangeJob then
            return
        end
        if _curMerId ~= v.XinfaId then
            return
        end
   
        self.ListMenu:AddIcon(k, v.Name)
        local _showRed = GameCenter.PlayerSkillLuaSystem:MeridianTypeRedPoint(k)
        self.ListMenu:SetRedPoint(k, _showRed)
        _idList:Add({k, _showRed})
    end)

    local _normalType = nil
    if self.SelectType == nil then
        for i = #_idList, 1, -1 do
            local _idData = _idList[i]
            if _idData[2] == true then
                _normalType = _idData[1]
                break
            end
        end
        if _normalType == nil then
            _normalType = _idList[#_idList][1]
        end
    end

    if _normalType ~= nil then
        self.ListMenu:SetSelectById(_normalType)
    else
        self:RefreshDetail()
    end

    if self.LevelUpPanel.IsVisible and self.LevelUpPanel.SelectIcon ~= nil then
        self.LevelUpPanel:Show(self.LevelUpPanel.SelectIcon)
    end
end

function UIOccSkillMeridianPanel:OnMenuSelect(id, b)
    if b then
        self.SelectType = id
        self:RefreshDetail()
    end
end

function UIOccSkillMeridianPanel:RefreshDetail()
    local _posCfg = DataConfig.DataSkillMeridianPos[self.SelectType]
    if _posCfg == nil then
        return
    end
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return
    end

    UIUtils.SetTextByStringDefinesID(self.TipsLabel, _posCfg._Tips)
    local _occ = _lp.Occ
    local _vfxId = L_TitleVfx[_occ * 100 + _posCfg.XinfaId]
    if _vfxId ~= nil then
        self.TitleVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, _vfxId, LayerUtils.GetAresUILayer())
    end

    self.NeedItemCfg = nil
    local _cellTable = Utils.SplitNumber(_posCfg.UseGezi, "_")
    local _cellCount = #_cellTable
    for i = 1, #self.IconItems do
        if i <= _cellCount then
            local _id = _cellTable[i]
            local _activeId = GameCenter.PlayerSkillSystem:GetMeridianActvieID(_id)
            local _cfg = DataConfig.DataSkillMeridianNew[_activeId]
            local _actived = false
            if _cfg ~= nil then
                --Activated
                _actived = true
            else
                -- Not activated
                --key value (profession *1000000+ meridian *10000+ meridian id *100+ grade)
                _cfg = DataConfig.DataSkillMeridianNew[_occ * 1000000 + self.SelectType * 10000 + _id * 100 + 1]
                _actived = false
            end
            self.IconItems[i]:SetInfo(_cfg, _actived)
            if self.NeedItemCfg == nil and _cfg ~= nil then
                local _itemParams = Utils.SplitNumber(_cfg.NeedValue, "_")
                self.NeedItemCfg = DataConfig.DataItem[_itemParams[1]]
            end
        else
            self.IconItems[i]:SetInfo(nil)
        end
    end
    if self.NeedItemCfg ~= nil then
        local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.NeedItemCfg.Id)
        UIUtils.SetTextByNumber(self.HaveValue, _haveCount)
        self.HaveIcon:UpdateIcon(self.NeedItemCfg.Icon)
    end
    self:RrefreshJianTou(_posCfg.LayoutType)
end

function UIOccSkillMeridianPanel:RrefreshJianTou(type)
    local _useJianTou = nil
    for i = 1, #self.JianTous do
        if i == type then
            self.JianTous[i].RootGo:SetActive(true)
            _useJianTou = self.JianTous[i]
        else
            self.JianTous[i].RootGo:SetActive(false)
        end
    end
    if _useJianTou == nil then
        return
    end
    if type == 1 then
        local _centerTable = self:GetIconBorder(1, 8, 0)
        if (_centerTable[4] - 1) > 0 then
            _useJianTou.CenterValueWidget.width = (_centerTable[4] - 1) * 100
            _useJianTou.CenterValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.CenterValueWidget.gameObject:SetActive(false)
        end
        _useJianTou.CenterValueWidget.width = (_centerTable[4] - 1) * 100
        
        local _topTable = self:GetIconBorder(9, 16, 8)
        _useJianTou.TopWidget.width = (_topTable[2] - _topTable[1] + 1) * 100
        if (8 - _topTable[3]) < 8 then
            _useJianTou.TopValueWidget.width = (8 - _topTable[3]) * 100
            _useJianTou.TopValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.TopValueWidget.gameObject:SetActive(false)
        end

        local _buttomTable = self:GetIconBorder(17, 24, 16)
        _useJianTou.ButtomWidget.width = (_buttomTable[2] - _buttomTable[1] + 1) * 100
        if (8 - _buttomTable[3]) < 8 then
            _useJianTou.ButtomValueWidget.width = (8 - _buttomTable[3]) * 100
            _useJianTou.ButtomValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.ButtomValueWidget.gameObject:SetActive(false)
        end
    elseif type == 2 then
        local _centerTable = self:GetIconBorder(1, 8, 0)
        if (_centerTable[4] - 1) > 0 then
            _useJianTou.CenterValueWidget.width = (_centerTable[4] - 1) * 100
            _useJianTou.CenterValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.CenterValueWidget.gameObject:SetActive(false)
        end

        local _topTable = self:GetIconBorder(9, 16, 8)
        _useJianTou.TopWidget.width = (_topTable[2] - 1) * 100
        if (_topTable[4] - 1) > 0 then
            _useJianTou.TopValueWidget.width = (_topTable[4] - 1) * 100
            _useJianTou.TopValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.TopValueWidget.gameObject:SetActive(false)
        end

        local _buttomTable = self:GetIconBorder(17, 24, 16)
        _useJianTou.ButtomWidget.width = (_buttomTable[2] - 1) * 100
        if (_buttomTable[4] - 1) > 0 then
            _useJianTou.ButtomValueWidget.width = (_buttomTable[4] - 1) * 100
            _useJianTou.ButtomValueWidget.gameObject:SetActive(true)
        else
            _useJianTou.ButtomValueWidget.gameObject:SetActive(false)
        end
    end
end

function UIOccSkillMeridianPanel:GetIconBorder(min, max, offset)
    local _min = nil
    local _max = nil
    local _acMin = nil
    local _acMax = nil
    for i = min, max do
        if self.IconItems[i].Cfg ~= nil then
            if _min == nil then
                _min = i
            end
            if _max == nil or _max < i then
                _max = i
            end
            if self.IconItems[i].IsActive then
                if _acMin == nil then
                    _acMin = i
                end
                if _acMax == nil or _acMax < i then
                    _acMax = i
                end
            end
        end
    end
    if _acMin == nil then
        _acMin = offset
    end
    if _acMax == nil then
        _acMax = offset
    end
    return {_min - offset, _max - offset, _acMin - offset, _acMax - offset}
end

function UIOccSkillMeridianPanel:OnSelectXinFaBtnClick()
    -- GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.PlayerSkillXinFa)
    self.RootForm.XinFaPanel:OnResetBtnClick()
    self.RootForm:RefreshXinFaPanel()
end

function UIOccSkillMeridianPanel:OnAddBtnClick()
    --Add currency
    if self.NeedItemCfg ~= nil then
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.NeedItemCfg.Id)
    end
end

L_IconItem = {
    Parent = nil,
    Go = nil,
    Trans = nil,
    Btn = nil,
    Name = nil,
    Level = nil,
    Icon = nil,
    Cfg = nil,
    IsActive = false,
    PosX = 0,
    PosY = 0,
    LPosX = 0,
    LPosY = 0,
    RedPoint = nil,
    TagGo = nil,
    TagSpr = nil,
    TagText = nil,
}
function L_IconItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.PosX = trans.position.x
    _m.PosY = trans.position.y
    _m.LPosX = trans.localPosition.x
    _m.LPosY = trans.localPosition.y
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.Level = UIUtils.FindLabel(trans, "Level")
    _m.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Icon"))
    _m.RedPoint = UIUtils.FindGo(trans, "RedPoint")
    _m.TagGo = UIUtils.FindGo(trans, "Tag")
    _m.TagSpr = UIUtils.FindSpr(trans, "Tag")
    _m.TagText = UIUtils.FindLabel(trans, "Tag/Label")
    return _m
end
function L_IconItem:SetInfo(cfg, isActive)
    self.Cfg = cfg
    self.IsActive = isActive
    if cfg == nil then
        self.Go:SetActive(false)
    else
        self.Go:SetActive(true)
        UIUtils.SetTextByStringDefinesID(self.Name, cfg._Name)
        local _curLevel = 0
        if isActive then
            _curLevel = cfg.Level
        end
        UIUtils.SetTextByProgress(self.Level, _curLevel, cfg.MaxLevel)
        self.Icon:UpdateIcon(cfg.Icon)
        self.Icon.IsGray = not isActive
        self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PlayerSkillMeridian, cfg.MeridianId))
        if cfg.TagText == nil or string.len(cfg.TagText) <= 0 then
            self.TagGo:SetActive(false)
        else
            self.TagGo:SetActive(true)
            UIUtils.SetTextByStringDefinesID(self.TagText, cfg._TagText)
            if cfg.TagBack == 1 then
                self.TagSpr.spriteName = "n_biaoqian_2"
            elseif cfg.TagBack == 2 then
                self.TagSpr.spriteName = "n_biaoqian_2_1"
            else
                self.TagSpr.spriteName = "n_biaoqian_2_2"
            end
        end
    end
end
function L_IconItem:OnBtnClick()
    --Open the upgrade interface
    self.Parent.LevelUpPanel:Show(self)
end

return UIOccSkillMeridianPanel
