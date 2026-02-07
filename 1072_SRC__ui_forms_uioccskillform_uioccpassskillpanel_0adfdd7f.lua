--==============================--
--author:
--Date: 2020-01-01
--File: UIOccPassSkillPanel.lua
--Module: UIOccPassSkillPanel
--Description: Passive skill list
--==============================--
local NGUITools = CS.NGUITools

local UIOccPassSkillPanel = {
    --transform
    Trans = nil,
    Go = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,
    --Animation module
    AnimModule = nil,

    --Sliding list
    ScrollView = nil,
    --icon list
    SkillIconList = nil,
    SelectBgTex = nil,
    SelectIcon = nil,
    SelectLevel = nil,
    SelectName = nil,
    SelectDesc = nil,
    SelectOpenDesc = nil,
    GoToBtn = nil,
    AlreadyActive = nil,
    SelectSkillIcon = nil,

    IsVisible = false,

    CurTypeIndex = 0
}

local L_SkillIcon = nil

function UIOccPassSkillPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    --Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)

    local _typesDic = Dictionary:New()
    local function  _forFunc(key, value)
        local _cfg = value
        local _typeList = _typesDic[_cfg.Type]
        if _typeList == nil then
            _typeList = List:New()
            _typesDic:Add(_cfg.Type, _typeList)
        end
        _typeList:Add(_cfg)
    end
    DataConfig.DataOccPassiveShow:Foreach(_forFunc)

    self.SkillIconList = List:New()
    self.FirstIconByType = List:New()
    local _keys = _typesDic:GetKeys()
    local _count = #_keys
    self.ScrollView = UIUtils.FindScrollView(trans, "ScrollView")
    self.Table = UIUtils.FindTable(trans, "ScrollView/Table")
    local _typeRes = self.Table.transform:GetChild(1).gameObject
    local _infoRes = self.Table.transform:GetChild(2).gameObject

    self._typeObjList = List:New()
    self._infoObjList = List:New()
    self._typeObjList:Add(_typeRes)
    self._infoObjList:Add(_infoRes)
    -- TODO: Mở tạm 2 cái đầu for i = 2, count do
    for i = 2, 2 do
        local newType = NGUITools.AddChild(self.Table.gameObject, _typeRes)
        local newInfo = NGUITools.AddChild(self.Table.gameObject, _infoRes)

        self._typeObjList:Add(newType)
        self._infoObjList:Add(newInfo)
    end

    -- _infoObjList[2]:SetActive(true)
    -- self.Table:Reposition()


    local _startY = 196
    local _startX = 41
    for i = 1, 2 do
        local _typeTrans = self._typeObjList[i].transform
        local _cfgList = _typesDic[_keys[i]]
        local _cfgCount = #_cfgList
        local _grid = UIUtils.FindGrid(_typeTrans, "GridSkill")
        local _skillRes = _grid.transform:GetChild(0).gameObject
        local _skillObjList = List:New(NGUITools.AddChilds(_grid.gameObject, _skillRes, _cfgCount))
        for j = 1, _cfgCount do
            local icon = L_SkillIcon:New(_skillObjList[j], self, _cfgList[j])
            icon.TypeIndex = i

            self.SkillIconList:Add(icon)
            if #self._infoObjList > 2 then
                self._infoObjList[i]:SetActive(false)
            else
                self._infoObjList[i]:SetActive(true)
            end
            -- print("Check #self._infoObjList: ", #self._infoObjList)
            -- self:SetSelect(_skillObjList[1])

            if j == 1 then
                self.FirstIconByType:Add(icon)
            end
        end
        _grid:Reposition()


        -- local _typeName = UIUtils.FindLabel(_typeTrans, "Title")
        -- UIUtils.SetTextByStringDefinesID(_typeName, _cfgList[1]._TypeName)
        -- local _buttonTrans = UIUtils.FindTrans(_typeTrans, "Buttom")
        -- local _inforTrans = UIUtils.FindTrans(_typeTrans, "Infor")
        -- local _bgTex = UIUtils.FindTex(_typeTrans, "Infor/BgTex")
        -- self.RootForm:LoadTexture(_bgTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_99_1"))
       
        -- if i<=2 then
        --     rootForm:LoadTexture(_bgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format( "tex_n_d_99_%d", i )))
        -- end
        local _rowCount = _cfgCount / 6
        if _cfgCount % 6 == 0 then
            _rowCount = _rowCount - 1
        end
        --UnityUtils.SetLocalPosition(_buttonTrans, 14, -150 - 120 * _rowCount, 0)
        --UnityUtils.SetLocalPosition(_typeTrans, 112, _startY, 0)
        --_startY = _startY - (180 + 120 * _rowCount)
        -- UnityUtils.SetLocalPosition(_typeTrans, _startX, _startY, 0)
        -- _startX = 41 + 420 * i

         
    end

    -- self.SelectBgTex = UIUtils.FindSpr(trans, "BgTex")
    -- self.RootForm:LoadTexture(self.SelectBgTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_99_1"))
    -- self.SelectIcon = UIUtils.FindSpr(trans, "Icon")
    -- self.SelectLevel = UIUtils.FindLabel(trans, "Level")
    -- self.SelectName = UIUtils.FindLabel(trans, "Name")
    -- self.SelectDesc = UIUtils.FindLabel(trans, "Desc")
    -- self.SelectOpenDesc = UIUtils.FindLabel(trans, "GetDesc")
    -- self.GoToBtn = UIUtils.FindBtn(trans, "GoToBtn")
    -- UIUtils.AddBtnEvent(self.GoToBtn, self.OnGoToBtnClick, self)
    -- self.AlreadyActive = UIUtils.FindGo(trans, "AlreadyActive")
    return self
end

function UIOccPassSkillPanel:Show(skillCfg, showCfg)
    if not self.IsVisible then
        --Play the start-up picture
        self.AnimModule:PlayEnableAnimation()
        self.ScrollView.repositionWaitFrameCount = 1
    end
    for i = 1, #self.SkillIconList do
        self.SkillIconList[i]:UpdatePage()
    end
    if #self._infoObjList > 2 then
        if self.SelectSkillIcon ~= nil then
            self:SetSelect(self.SelectSkillIcon)
        else
            self:SetSelect(self.SkillIconList[1])
            self.CurTypeIndex = 1
        end
    else
        if self.FirstIconByType then
            for i=1, #self.FirstIconByType do
                self:SetSelect(self.FirstIconByType[i])
            end
        end
    end
    
    self.IsVisible = true
end

function UIOccPassSkillPanel:Hide()
    --Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
    self.SelectSkillIcon = nil
end

function UIOccPassSkillPanel:OnTryHide()
    return true
end

function UIOccPassSkillPanel:SetSelect(icon)
    if not icon then return end
    local typeIndex = icon.TypeIndex
    if not typeIndex then return end

    if #self._infoObjList <= 2 then
        local count = #self.SkillIconList or self.SkillIconList:Count()
        for i = 1, count do
            local other = self.SkillIconList[i]
            if other and other.TypeIndex == typeIndex then
                other:SetSelect(other == icon)
            end
        end
    else
        if self.CurTypeIndex ~= icon.TypeIndex then
            if self.CurTypeIndex ~= 0 then
                self._infoObjList[self.CurTypeIndex]:SetActive(false)
            end
            self._infoObjList[icon.TypeIndex]:SetActive(true)
        end

        for i = 1, #self.SkillIconList do
            self.SkillIconList[i]:SetSelect(icon == self.SkillIconList[i])
        end
    end

    

    

    self.Table:Reposition()
    self.CurTypeIndex = icon.TypeIndex
    self.SelectSkillIcon = icon
    local infoTrans = self._infoObjList[self.SelectSkillIcon.TypeIndex].transform
    local _TitleType = UIUtils.FindLabel(infoTrans, "TitleType")
    local _Icon = UIUtils.FindSpr(infoTrans, "Icon")
    local _Name = UIUtils.FindLabel(infoTrans, "Name")
    local _Level = UIUtils.FindLabel(infoTrans, "Level")
    local _Title = UIUtils.FindLabel(infoTrans, "Title")
    local _Desc = UIUtils.FindLabel(infoTrans, "Desc")
    local _GetDesc = UIUtils.FindLabel(infoTrans, "GetDesc")
    local _GoToBtn = UIUtils.FindBtn(infoTrans, "GoToBtn")
    UIUtils.AddBtnEvent(_GoToBtn, self.OnGoToBtnClick, self)
    local _AlreadyActive = UIUtils.FindGo(infoTrans, "AlreadyActive")
    local _bgTex = UIUtils.FindTex(infoTrans, "BgTex")
    local path = AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_99_1")
    self.RootForm.CSForm:LoadTexture(_bgTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_99_1"))
    -- self.CSForm:LoadTexture(_bgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_99_1" ))

    _Icon.spriteName = string.format("skill_%d", icon.ShowSkill.Icon)
    UIUtils.SetTextByStringDefinesID(_TitleType, icon.Cfg._TypeName)
    if icon.IsActive then
        _Level.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(_Level, "C_MAIN_NON_PLAYER_SHOW_LEVEL", icon.SkillLevel)
        _GoToBtn.gameObject:SetActive(false)
        _AlreadyActive:SetActive(true)
    else
        _Level.gameObject:SetActive(false)
        _GoToBtn.gameObject:SetActive(true)
        _AlreadyActive:SetActive(false)
    end
    UIUtils.SetTextByStringDefinesID(_Name, icon.ShowSkill._Name)
    UIUtils.SetTextByStringDefinesID(_Desc, icon.ShowSkill._Desc)
    UIUtils.SetTextByStringDefinesID(_GetDesc, icon.Cfg._GetDesc)
end

function UIOccPassSkillPanel:OnGoToBtnClick()
    if self.SelectSkillIcon ~= nil and self.SelectSkillIcon.Cfg.OpenFunc > 0 then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(self.SelectSkillIcon.Cfg.OpenFunc, self.SelectSkillIcon.Cfg.OpenParam)
    end
end

L_SkillIcon = {
    RootGo = nil,
    Trans = nil,
    Parent = nil,
    Btn = nil,
    SelectGo = nil,
    Icon = nil,
    Name = nil,
    Level = nil,

    Cfg = nil,
    Skills = nil,
    SkillLevel = 0,
    IsActive = false,
    ShowSkill = nil,

    TypeIndex = nil,
    IconIndex = nil,
}

function L_SkillIcon:New(go, parent, cfg)
    local _m = Utils.DeepCopy(self)
    local _trans = go.transform
    _m.RootGo = go
    _m.Trans = _trans
    _m.Parent = parent
    _m.Btn = UIUtils.FindBtn(_trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.SelectGo = UIUtils.FindGo(_trans, "Select")
    _m.Icon = UIUtils.FindSpr(_trans, "Icon")
    _m.Name = UIUtils.FindLabel(_trans, "Name")
    _m.Level = UIUtils.FindLabel(_trans, "Level")
    _m.Cfg = cfg
    _m.Skills = Utils.SplitNumber(cfg.IdList, '_')
    return _m
end

function L_SkillIcon:SetSelect(b)
    self.SelectGo:SetActive(b)
end

function L_SkillIcon:OnBtnClick()
    self.Parent:SetSelect(self)
end

function L_SkillIcon:UpdatePage()
    local _showSkillId = self.Skills[1]
    self.IsActive = false
    self.SkillLevel = 1
    for i = 1, #self.Skills do
        if GameCenter.PlayerSkillSystem:IsPassSkillActived(self.Skills[i]) then
            self.IsActive = true
            _showSkillId = self.Skills[i]
            self.SkillLevel = i
        end
    end

    self.ShowSkill = DataConfig.DataSkill[_showSkillId]
    if self.ShowSkill == nil then
        return
    end
    self.Icon.spriteName = string.format("skill_%d", self.ShowSkill.Icon)
    UIUtils.SetTextByStringDefinesID(self.Name, self.ShowSkill._Name)
    if self.IsActive then
        self.Icon.IsGray = false
        self.Level.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(self.Level, "C_MAIN_NON_PLAYER_SHOW_LEVEL", self.SkillLevel)
    else
        self.Icon.IsGray = true
        self.Level.gameObject:SetActive(false)
    end
end

return UIOccPassSkillPanel
