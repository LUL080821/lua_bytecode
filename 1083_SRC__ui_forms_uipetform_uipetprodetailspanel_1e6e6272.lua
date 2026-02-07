--==============================--
--author:
--Date: 2019-06-25
--File: UIPetProDetailsPanel.lua
--Module: UIPetProDetailsPanel
--Description: Pet attribute details interface
--==============================--
local MyTweenUISlider = CS.Thousandto.Plugins.Common.MyTweenUISlider

local UIPetProDetailsPanel = {
    --transform
    Trans = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,
    --Animation module
    AnimModule = nil,

    ProScrollView = nil,
    --File: UIPetForm.lua
    ProGos = nil,
    --Attribute name s
    ProNames = nil,
    --Attribute value s
    ProValues = nil,
    --Next level attributes
    ProNextValues = nil,

    --Upgrade items
    LevelUPItems = nil,
    --Upgrade item check box
    LevelUPSelect = nil,
    --Full level
    MaxLevelGo = nil,
    SelectName = nil,
    --Upgrade button
    LevelUPBtn = nil,
    LevelUPSpr = nil,
    LevelUPRedpoint = nil,
    --One-click upgrade button
    OnKeyUPBtn = nil,
    OnKeyUPSpr = nil,
    OnKeyUPRedpoint = nil,
    --Experience progress bar
    ExpProgress = nil,
    --Current experience value
    ExpValue = nil,
    --Upgrade effect
    Effect = nil,

    --Props required for upgrade
    UseItems = nil,
    UseItemNames = nil,
    UseItemExps = nil,
    --The currently selected item
    CurSelectItemIndex = 0,
    --The level of the last updated
    FrontUpdateLevel = -1,
    --Experience from last update
    FrontUpdateExp = -1,
    AutoRemainTime = 0,
}

function UIPetProDetailsPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(trans)
    --Add an animation
    self.AnimModule:AddAlphaAnimation()

    self.ProScrollView = UIUtils.FindScrollView(trans, "UpSprite/Panel")
    self.ProGos = {}
    self.ProNames = {}
    self.ProValues = {}
    self.ProNextValues = {}
    for i = 1, 6 do
        self.ProGos[i] = UIUtils.FindGo(trans, string.format("UpSprite/Panel/Grid/%d", i))
        self.ProNames[i] = UIUtils.FindLabel(trans, string.format("UpSprite/Panel/Grid/%d/Label", i))
        self.ProValues[i] = UIUtils.FindLabel(trans, string.format("UpSprite/Panel/Grid/%d/ValueLabel", i))
        self.ProNextValues[i] = UIUtils.FindLabel(trans, string.format("UpSprite/Panel/Grid/%d/AddValueLabel", i))
    end
    self.LevelUPItems = {}
    for i = 1, 3 do
        self.LevelUPItems[i] = UILuaItem:New(UIUtils.FindTrans(trans, string.format("DownSprite/%d", i)))
    end
    self.LevelUPSelect = UIUtils.FindTrans(trans, "DownSprite/SelectImg")
    self.MaxLevelGo = UIUtils.FindGo(trans, "ManJi")
    self.SelectName = UIUtils.FindLabel(trans, "DownSprite/SelectLabel")
    self.LevelUPBtn = UIUtils.FindBtn(trans, "Bottom/Uplevel")
    UIUtils.AddBtnEvent(self.LevelUPBtn, self.OnLevelUPClick, self)
    self.OnKeyUPBtn = UIUtils.FindBtn(trans, "Bottom/OneKey")
    self.OnKeyUPBtnLabel = UIUtils.FindLabel(trans, "Bottom/OneKey/Label")
    UIUtils.AddBtnEvent(self.OnKeyUPBtn, self.OnOnkeyUPClick, self)
    self.ExpProgress = UIUtils.FindSlider(trans, "ExpPro")
    self.ExpValue = UIUtils.FindLabel(trans, "ExpPro/Label")
    self.LevelUPRedpoint = UIUtils.FindGo(trans, "Bottom/Uplevel/RedPoint")
    self.OnKeyUPRedpoint = UIUtils.FindGo(trans, "Bottom/OneKey/RedPoint")
    self.LevelUPBtnDisable = UIUtils.FindGo(trans, "Bottom/Uplevel/Disable")
    self.OnKeyUPBtnDisable = UIUtils.FindGo(trans, "Bottom/OneKey/Disable")
    self.LevelUPSpr = UIUtils.FindSpr(trans, "Bottom/Uplevel")
    self.OnKeyUPSpr = UIUtils.FindSpr(trans, "Bottom/OneKey")
    self.LevelUPSpr.spriteName = "n_a_01"
    self.OnKeyUPSpr.spriteName = "n_a_02"

    local _effectNode =  UIUtils.FindTrans(trans,"UIVfxSkin")
    self.Effect = UIUtils.RequireNatureVfxEffect(UIUtils.FindTrans(trans,"Effect"))
    self.Effect:Init()
    self.Effect.Node2 = _effectNode

    self.Trans.gameObject:SetActive(false)

    local _gCfg = DataConfig.DataGlobal[GlobalName.Pet_Levelup_Item_Num]
    if _gCfg ~= nil then
        self.UseItems = Utils.SplitStrByTableS(_gCfg.Params, {';','_'})
        self.UseItemNames = {}
        self.UseItemExps = {}
        for i = 1, #self.UseItems do
            local _itemCfg = DataConfig.DataItem[self.UseItems[i][1]]
            self.UseItemNames[i] = _itemCfg.Name
            self.UseItemExps[i] = self.UseItems[i][2]
        end
    end
    return self
end

function UIPetProDetailsPanel:Show()
    --Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    self.CurSelectItemIndex = 0
    self.FrontUpdateLevel = -1
    self.FrontUpdateExp = -1
    self:RefreshPanel(nil, nil)
end

function UIPetProDetailsPanel:Hide()
    --Play Close animation
    self.AnimModule:PlayDisableAnimation()
    self.AutoRemainTime = 0
end

--Play special effects
function UIPetProDetailsPanel:PlayVfx()
    if self.Effect then
        self.Effect:Play()
    end
end

--Refresh the page
function UIPetProDetailsPanel:RefreshPanel(obj, sender)
    local _showRedPoint = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.PetProDet)
    self.LevelUPRedpoint:SetActive(_showRedPoint)
    self.OnKeyUPRedpoint:SetActive(_showRedPoint)
    local _system = GameCenter.PetSystem
    if _system.CurLevelPros ~= nil then
        local _proCount = #_system.CurLevelPros
        for i = 1, 6 do
            if i <= _proCount then
                self.ProGos[i]:SetActive(true)
                local _attCfg = DataConfig.DataAttributeAdd[_system.CurLevelPros[i][1]]
                if _attCfg ~= nil then
                    UIUtils.SetTextByStringDefinesID(self.ProNames[i], _attCfg._Name)
                end
                UIUtils.SetTextByNumber(self.ProValues[i], _system.CurLevelPros[i][2])
                if _system.NextLevelPros ~= nil then
                    UIUtils.SetTextByNumber(self.ProNextValues[i], _system.NextLevelPros[i][2])
                else
                    UIUtils.SetTextByNumber(self.ProNextValues[i], _system.CurLevelPros[i][2])
                end
            else
                self.ProGos[i]:SetActive(false)
            end
        end
    end
    self.ProScrollView.repositionWaitFrameCount = 1

    if _system.NextLevelPros == nil then
        self.MaxLevelGo:SetActive(true)
        self.LevelUPBtn.isEnabled = false
        self.OnKeyUPBtn.isEnabled = false
        --self.LevelUPSpr.IsGray = true
        --self.OnKeyUPSpr.IsGray = true
        self.LevelUPSpr.spriteName = "none"
        self.OnKeyUPSpr.spriteName = "none"
        self.LevelUPBtnDisable:SetActive(true)
        self.OnKeyUPBtnDisable:SetActive(true)

    else
        self.MaxLevelGo:SetActive(false)
        self.LevelUPBtn.isEnabled = true
        self.OnKeyUPBtn.isEnabled = true
        --self.LevelUPSpr.IsGray = false
        --self.OnKeyUPSpr.IsGray = false
        self.LevelUPSpr.spriteName = "n_a_01"
        self.OnKeyUPSpr.spriteName = "n_a_02"
        self.LevelUPBtnDisable:SetActive(false)
        self.OnKeyUPBtnDisable:SetActive(false)
    end

    local _haveIndex = 0
    for i = 1, 3 do
        self.LevelUPItems[i]:InItWithCfgid(self.UseItems[i][1], 0, false, true)
        self.LevelUPItems[i].IsShowTips = false
        self.LevelUPItems[i].SingleClick = Utils.Handler(self.OnLevelItemClick, self)
        local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.UseItems[i][1])
        self.LevelUPItems[i]:OnSetNum(tostring(_haveCount))
        if _haveIndex <= 0 and _haveCount > 0 then
            _haveIndex = i
        end
        if self.CurSelectItemIndex == i and _haveCount <= 0 then
            self.CurSelectItemIndex = 0
        end
    end
    if _haveIndex <= 0 then
        _haveIndex = 1
    end
    if self.CurSelectItemIndex <= 0 then
        self.CurSelectItemIndex = _haveIndex
    end
    self.LevelUPSelect.localPosition =self.LevelUPItems[self.CurSelectItemIndex].RootTrans.localPosition
    UIUtils.SetTextByEnum(self.SelectName, "NATURE_USEITEM_TIPS", self.UseItemNames[self.CurSelectItemIndex],self.UseItemExps[self.CurSelectItemIndex])
    UIUtils.SetTextByEnum(self.ExpValue, "Progress", _system.CurExp, _system.CurLevelCfg.Exp)

    self.ExpProgress.value = _system.CurExp / _system.CurLevelCfg.Exp
    if self.FrontUpdateLevel ~= _system.CurLevel and self.FrontUpdateLevel >= 0 then
        self:PlayVfx()
    else
        if self.AutoRemainTime > 0 and self.FrontUpdateLevel >= 0 then
            self.AutoRemainTime = 0.075
        end
    end
    self.FrontUpdateLevel = _system.CurLevel
    self.FrontUpdateExp = _system.CurExp
    self:SetBtnShow()
end

function UIPetProDetailsPanel:SetBtnShow()
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_RUNE_STOP")
    else
        UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
    end
end

--Menu Selection
function UIPetProDetailsPanel:OnLevelItemClick(item)
    for i = 1, 3 do
        if self.LevelUPItems[i] == item then
            if self.CurSelectItemIndex == i and item.ShowItemData ~= nil then
                GameCenter.ItemTipsMgr:ShowTips(item.ShowItemData, item.RootGO, item.Location, item.IsShowGet, nil, true, item.ExtData)
            end
            self.CurSelectItemIndex = i
        end
    end
    self.LevelUPSelect.localPosition =self.LevelUPItems[self.CurSelectItemIndex].RootTrans.localPosition
    UIUtils.SetTextByEnum(self.SelectName, "NATURE_USEITEM_TIPS", self.UseItemNames[self.CurSelectItemIndex],self.UseItemExps[self.CurSelectItemIndex])
end

--Click the upgrade button
function UIPetProDetailsPanel:OnLevelUPClick()
    local id = tonumber(self.UseItems[self.CurSelectItemIndex][1])
    if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(id) > 0 then
        GameCenter.PetSystem:ReqLevelUP(id)
    else
        Utils.ShowPromptByEnum("ItemNotEnough")
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(id)
    end
end

--Click the upgrade button with one click
function UIPetProDetailsPanel:OnOnkeyUPClick()
    if GameCenter.PetSystem.NextLevelPros == nil then
        self.AutoRemainTime = 0
        UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
        return
    end
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        self.AutoRemainTime = 0
        UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
    else
        if self:SendOnkeMSG() then
            self.AutoRemainTime = 0.33
            UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_RUNE_STOP")
        else
            UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
        end
    end
end

function UIPetProDetailsPanel:SendOnkeMSG()
    local id = tonumber(self.UseItems[self.CurSelectItemIndex][1])
    if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(id) > 0 then
        GameCenter.PetSystem:ReqLevelUP(id)
        return true
    end
    for i = 1, #self.UseItems do
        if i ~= self.CurSelectItemIndex then
            id = tonumber(self.UseItems[i][1])
            if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(id) > 0 then
                GameCenter.PetSystem:ReqLevelUP(id)
                return true
            end
        end
    end
    Utils.ShowPromptByEnum("ItemNotEnough")
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(id)
    return false
end

--Update special effects
function UIPetProDetailsPanel:Update(dt)
    if self.Effect then
        self.Effect:Tick(dt)
    end
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        self.AutoRemainTime = self.AutoRemainTime - dt
        -- Debug.LogError(self.AutoRemainTime)
        if GameCenter.PetSystem.NextLevelPros == nil then
            UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
            self.AutoRemainTime = 0
            return
        end
        if self.AutoRemainTime <= 0 then
            if self:SendOnkeMSG() then
                self.AutoRemainTime = 0.33
            else
                UIUtils.SetTextByEnum(self.OnKeyUPBtnLabel, "C_UI_BTNLVAUTO")
            end
        end
    end
end

return UIPetProDetailsPanel
