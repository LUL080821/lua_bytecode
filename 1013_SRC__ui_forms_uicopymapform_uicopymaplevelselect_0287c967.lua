------------------------------------------------
-- author:
-- Date: 2020-02-10
-- File: UICopyMapLevelSelect.lua
-- Module: UICopyMapLevelSelect
-- Description: Copy level selection
------------------------------------------------

local UICopyMapLevelSelect = {
    Parent = nil,
    RootForm = nil,
    Go = nil,
    Trans = nil,

    Scroll = nil,
    Progress = nil,
    Grid = nil,
    ResGo = nil,
    ResList = nil,

    DelayValue = 0,
    DelayFrame = 0,
}

local L_ItemUI = nil
function UICopyMapLevelSelect:OnFirstShow(trans, parent, rootForm)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootForm = rootForm
    _m.Go = trans.gameObject
    _m.Trans = trans

    _m.Scroll = UIUtils.FindScrollView(trans)
    _m.Progress = _m.Scroll.verticalScrollBar
    _m.Grid = UIUtils.FindGrid(trans, "Grid")
    _m.ResGo = nil
    _m.ResList = List:New()
    local _parentTrans = _m.Grid.transform
    local _childCount = _parentTrans.childCount
    for i = 1, _childCount do
        local _childTrans = _parentTrans:GetChild(i - 1)
        if _m.ResGo == nil then
            _m.ResGo = _childTrans.gameObject
        end
        local _ui = L_ItemUI:New(_childTrans, _m)
        _m.ResList:Add(_ui)
    end
    return _m
end

function UICopyMapLevelSelect:RefreshPanel(copyId, rePos)
    local _index = 1
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _selectUI = nil
    local _selectIndex = 0
    local _isClone = false
    while(true) do
        local _cfgId = copyId * 100 + _index
        local _cfg = DataConfig.DataCloneLevel[_cfgId]
        if _cfg ~= nil then
            local _ui = nil
            if _index <= #self.ResList then
                _ui = self.ResList[_index]
            else
                _ui = L_ItemUI:New(UnityUtils.Clone(self.ResGo).transform, self)
                self.ResList:Add(_ui)
                _isClone = true
            end
            _ui:SetInfo(_cfg, _lpLevel)
            if _lpLevel >= _cfg.MinLv then
                _selectUI = _ui
                _selectIndex = _index
            end
            _index = _index + 1
        else
            break
        end
    end
    for i = _index, #self.ResList do
        self.ResList[i]:SetInfo(_cfg)
    end
    self.Grid:Reposition()
    self:SetSelect(_selectUI)

    if rePos then
        self.Scroll:ResetPosition()
        local _fashionCount = _index - 1
        local _allSize = _fashionCount * 86 + 14 - 478
        if _selectIndex > 1 then
            _selectIndex = _selectIndex - 1
        end
        local _curSize = (_selectIndex - 1) * 86 + 7

        self.DelayValue = _curSize / _allSize
        if _isClone then
            self.DelayFrame = 3
        else
            self.DelayFrame = 3
            self.Progress.value = self.DelayValue
        end
    end
end

function UICopyMapLevelSelect:SetSelect(ui)
    for i = 1, #self.ResList do
        self.ResList[i]:SetSelect(ui == self.ResList[i])
    end
    self.Parent:RefreshDet(ui.Cfg)
end

function UICopyMapLevelSelect:Update(dt)
    if self.DelayFrame > 0 then
        self.DelayFrame = self.DelayFrame - 1
        if self.DelayFrame <= 0 then
            self.Progress.value = self.DelayValue
        end
    end
end

L_ItemUI = {
    Go = nil,
    Trans = nil,
    Parent = nil,
    Cfg = nil,

    Btn = nil,
    Icon = nil,
    IconName = nil,
    Name = nil,
    NormalGo = nil,
    NormalTex = nil,
    SelectGo = nil,
    SelectTex = nil,
    OpenGo = nil,
    OpenLevel = nil,
}

function L_ItemUI:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Parent = parent
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Icon"))
    _m.IconName = UIUtils.FindLabel(trans, "Icon/Name")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.NormalGo = UIUtils.FindGo(trans, "Normal")
    _m.NormalTex = UIUtils.FindTex(trans, "Normal")
    _m.SelectGo = UIUtils.FindGo(trans, "Select")
    _m.SelectTex = UIUtils.FindTex(trans, "Select")
    _m.OpenGo = UIUtils.FindGo(trans, "Open")
    _m.OpenLevel = UIUtils.FindLabel(trans, "OpenLevel")
    return _m
end

function L_ItemUI:OnBtnClick()
    self.Parent:SetSelect(self)
end

function L_ItemUI:SetSelect(b)
    self.SelectGo:SetActive(b)
    self.NormalGo:SetActive(not b)
end

function L_ItemUI:SetInfo(cfg, lpLevel)
    self.Cfg = cfg
    if cfg ~= nil then
        self.Go:SetActive(true)
        self.Parent.RootForm.CSForm:LoadTexture(self.NormalTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_298"))
        self.Parent.RootForm.CSForm:LoadTexture(self.SelectTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_298_1"))

        self.Icon:UpdateIcon(cfg.LevelIcon)
        UIUtils.SetTextByStringDefinesID(self.IconName, cfg._CloneLevelDes)
        UIUtils.SetTextByStringDefinesID(self.Name, cfg._Describe)
        if cfg.MinLv <= lpLevel then
            self.OpenGo:SetActive(true)
            self.OpenLevel.gameObject:SetActive(false)
        else
            self.OpenGo:SetActive(false)
            self.OpenLevel.gameObject:SetActive(true)
            UIUtils.SetTextByEnum(self.OpenLevel, "SOUL_LEVEL_OPEN", CommonUtils.GetLevelDesc(cfg.MinLv))
        end
    else
        self.Go:SetActive(false)
    end
end

return UICopyMapLevelSelect