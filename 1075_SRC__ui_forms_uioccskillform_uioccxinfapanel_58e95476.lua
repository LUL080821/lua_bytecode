--==============================--
-- author:
-- Date: 2021-01-05
-- File: UIOccXinFaPanel.lua
-- Module: UIOccXinFaPanel
-- Description: The mental method selection interface
--==============================--

-- The number of times you reset the mind method for free, Fang Xinyu said to write it to death
local L_FreeRestCount = 2
local L_OccMerCfg = {{1,2}, {1,2}, {1,2}, {1,2}}
local L_XinFaNameCfg = {
    [0 * 1000 + 1] = 1,
    [0 * 1000 + 2] = 2,
    [1 * 1000 + 1] = 3,
    [1 * 1000 + 2] = 4,
    [2 * 1000 + 1] = 5,
    [2 * 1000 + 2] = 6,
    [3 * 1000 + 1] = 7,
    [3 * 1000 + 2] = 8,
}

local UIOccXinFaPanel = {
    --transform
    Trans = nil,
    -- Parent node
    Parent = nil,
    -- The form belongs to
    RootForm = nil,
    -- Animation module
    AnimModule = nil,

    LeftBtn = nil,
    LeftSpr = nil,
    LeftName = nil,

    RightBtn = nil,
    RightSpr = nil,
    RightName = nil,

    ResetBtn = nil,

    -- List of optional mental methods
    CurXinFaIds = nil,
    -- Reset the consumption of mind
    RestCostItemId = nil,
    RestCostItemName = nil,
    RestCostItemCount = nil,
    OccMerCfg = nil,
    LeftNameValue = nil,
    RightNameValue = nil,

    CheckMeridianPanel = nil,
}

local L_OccUI = nil
function UIOccXinFaPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Parent = parent
    self.RootForm = rootForm
    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()
    self.Trans.gameObject:SetActive(false)

    local _trans = self.Trans
    self.CloseBtn = UIUtils.FindBtn(_trans, "RightTop/CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.ChangeJobGo = UIUtils.FindGo(_trans, "ChangeJob")
    self.ResetGo = UIUtils.FindGo(_trans, "ResetBtn")
    self.ResetBtn = UIUtils.FindBtn(_trans, "ResetBtn")
    UIUtils.AddBtnEvent(self.ResetBtn, self.OnResetBtnClick, self)
    self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "UIVfxSkinCompoent"))
    local _gCfg = DataConfig.DataGlobal[GlobalName.Reset_meridian_Item]
    local _cfgTable = Utils.SplitNumber(_gCfg.Params, '_')
    local _itemCfg = DataConfig.DataItem[_cfgTable[1]]
    self.RestCostItemName = _itemCfg.Name
    self.RestCostItemId = _cfgTable[1]
    self.RestCostItemCount = _cfgTable[2]
    self.VfxLoadFinishHander = Utils.Handler(self.OnVfxLoadFinish, self)
    self.OccTable = {}
    for i = 1, Occupation.Count do
        self.OccTable[i] = L_OccUI:New(UIUtils.FindTrans(_trans, string.format("Occ%d", i)), L_OccMerCfg[i], self)
    end
    self.ResetTex = UIUtils.FindTex(_trans, "ResetBtn")
    self.ChanJobTex = UIUtils.FindTex(_trans, "ChangeJob")
    self.TexEffect = UIUtils.FindTex(_trans, "EffectLine/TexEffect")
    self.HeroTex = UIUtils.FindTex(_trans, "HeroTex")

    return self
end

function UIOccXinFaPanel:Show()
    self.RootForm.CSForm:LoadTexture(self.HeroTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_juese_xinfa_1"))
    for i = 1, Occupation.Count do
        for j = 1, 2 do
            local _normalTex = UIUtils.FindTex(self.OccTable[i].Trans, string.format("%d/NormalTex", j))
            self.RootForm.CSForm:LoadTexture(_normalTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_xinfa_1"))
            local _selectTex = UIUtils.FindTex(self.OccTable[i].Trans, string.format("%d/SelectTex", j))
            self.RootForm.CSForm:LoadTexture(_selectTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_xinfa_2"))
        end
    end
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
end

function UIOccXinFaPanel:Hide()
    -- Play Close animation
    self.AnimModule:PlayDisableAnimation()
end

-- Refresh the page
function UIOccXinFaPanel:RefreshPanel()


    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc + 1
    local _merTable = L_OccMerCfg[_occ]
    for i = 1, Occupation.Count do
        if _occ == i then
            self.CurOccTable = self.OccTable[i]
            self.OccTable[i].Go:SetActive(true)
        else
            self.OccTable[i].Go:SetActive(false)
        end
    end

    local _curSelectMerId = GameCenter.PlayerSkillSystem.CurSelectMerId
    if _curSelectMerId == _merTable[1] then
        self.CurOccTable:SetEnableSelect(false)
        self.CurOccTable:OnBtnClick(1)
        self.ChangeJobGo:SetActive(false)
        self.ResetGo:SetActive(true)
    elseif _curSelectMerId == _merTable[2] then
        self.CurOccTable:SetEnableSelect(false)
        self.CurOccTable:OnBtnClick(2)
        self.ChangeJobGo:SetActive(false)
        self.ResetGo:SetActive(true)
    else
        self.CurOccTable:SetEnableSelect(true)
        self.CurOccTable:OnBtnClick(1)
        self.ChangeJobGo:SetActive(true)
        self.ResetGo:SetActive(false)
    end
    
    if self.CheckMeridianPanel == false then
        -- self.RootForm.MeridianPanel:Show()
        self.RootForm:RefreshMeridianPanel()
    else
        self:Show()
    end
end

function UIOccXinFaPanel:OnLeftBtnClick()
    local _freeCount = L_FreeRestCount - GameCenter.PlayerSkillSystem.CurResetMerCount
    if _freeCount < 0 then
        _freeCount = 0
    end
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.Network.Send("MSG_Skill.ReqSelectMentalType", {mentalType = self.CurXinFaIds[1]})
        end
    end, "C_SELECT_XINFA_ASK", self.LeftNameValue, _freeCount)
end

function UIOccXinFaPanel:OnRightBtnClick()
    local _freeCount = L_FreeRestCount - GameCenter.PlayerSkillSystem.CurResetMerCount
    if _freeCount < 0 then
        _freeCount = 0
    end
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.Network.Send("MSG_Skill.ReqSelectMentalType", {mentalType = self.CurXinFaIds[2]})
        end
    end, "C_SELECT_XINFA_ASK", self.RightNameValue, _freeCount)
end

function UIOccXinFaPanel:OnResetBtnClick()
    local _freeCount = L_FreeRestCount - GameCenter.PlayerSkillSystem.CurResetMerCount
    if _freeCount < 0 then
        _freeCount = 0
    end
    if _freeCount > 0 then
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                GameCenter.Network.Send("MSG_Skill.ReqRestMentalType")
            end
        end, "C_FREE_RESET_XINFA_ASK", _freeCount)
    else
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.RestCostItemId)
                if _haveCount >= self.RestCostItemCount then
                    GameCenter.Network.Send("MSG_Skill.ReqRestMentalType")
                else
                    Utils.ShowPromptByEnum("ConsumeNotEnough", self.RestCostItemName)
                    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(1)
                end
            end
        end, "C_COST_RESET_XINFA_ASK", self.RestCostItemName, self.RestCostItemCount)
    end
end

------------------------------------------------
function UIOccXinFaPanel:OnCloseBtnClick()
    self:OnClose(nil)
end

--The special effects loading is completed
function UIOccXinFaPanel:OnVfxLoadFinish(objBase)
    if objBase ~= nil then
        self.CurOccTable:SetModel(objBase.RealTransform)
    end
end

L_OccUI = {
    Trans = nil,
    Go = nil,
    Parent = nil,
    SelectGos = nil,
    SelectBtns = nil,
    NotSelectGos = nil,
    SelectModelGos = nil,
    NotSelectModelGos = nil,
    Btns = nil,
    BtnGos = nil,

    SelectIndex = 0,
    CanSelectXinFa = false,

    NormalTex = nil,
    SelectTex = nil,
    SelectTexGos = nil,
}
function L_OccUI:New(trans, xinfaIdTable, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = trans.gameObject
    _m.Trans = trans
    _m.Parent = parent
    _m.SelectGos = {}
    _m.NotSelectGos = {}
    _m.SelectBtns = {}
    _m.Btns = {}
    _m.BtnGos = {}
    _m.NormalTex = {}
    _m.SelectTex = {}
    _m.SelectTexGos = {}
    for i = 1, 2 do
        _m.SelectGos[i] = UIUtils.FindGo(trans, string.format("%d/Select", i))
        _m.NotSelectGos[i] = UIUtils.FindGo(trans, string.format("%d/NotSelect", i))
        _m.SelectBtns[i] = UIUtils.FindBtn(trans, string.format("%d/Select", i))
        UIUtils.AddBtnEvent(_m.SelectBtns[i], _m.OnSelectBtnClick, _m, xinfaIdTable[i])
        _m.Btns[i] = UIUtils.FindBtn(trans, string.format("%d/Btn", i))
        UIUtils.AddBtnEvent(_m.Btns[i], _m.OnBtnClick, _m, i)
        _m.BtnGos[i] = UIUtils.FindGo(trans, string.format("%d/Btn", i))
        _m.SelectTexGos[i] = UIUtils.FindGo(trans, string.format("%d/SelectTex", i))
    end
    return _m
end

function L_OccUI:SetEnableSelect(b)
    self.CanSelectXinFa = b
    self.Parent.CheckMeridianPanel = self.CanSelectXinFa
end

function L_OccUI:SetModel(trans)
    if trans == nil then
        self.SelectModelGos = nil
        self.NotSelectModelGos = nil
    else
        self.SelectModelGos = {}
        self.NotSelectModelGos = {}
        for i = 1, 2 do
            self.SelectModelGos[i] = UIUtils.FindGo(trans, string.format("Active%d", i - 1))
            self.NotSelectModelGos[i] = UIUtils.FindGo(trans, string.format("NotActive%d", i - 1))
        end
        self:OnBtnClick(self.SelectIndex)
    end
end

function L_OccUI:OnSelectBtnClick(xinfaId)
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local _cfg = DataConfig.DataSkillMeridianPos[L_XinFaNameCfg[_occ * 1000 + xinfaId]]
    if _cfg == nil then
        return
    end
    local _freeCount = L_FreeRestCount - GameCenter.PlayerSkillSystem.CurResetMerCount
    if _freeCount < 0 then
        _freeCount = 0
    end
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.Network.Send("MSG_Skill.ReqSelectMentalType", {mentalType = xinfaId})
        end
    end, "C_SELECT_XINFA_ASK", _cfg.Name, _freeCount)
end

function L_OccUI:OnBtnClick(index)
    self.SelectIndex = index
    for i = 1, 2 do
        self.BtnGos[i]:SetActive(index ~= i and self.CanSelectXinFa)
        self.SelectGos[i]:SetActive(index == i and self.CanSelectXinFa)
        self.NotSelectGos[i]:SetActive(index ~= i and self.CanSelectXinFa)
        self.SelectTexGos[i]:SetActive(index == i and self.CanSelectXinFa)
        if self.SelectModelGos ~= nil then
            self.SelectModelGos[i]:SetActive(index == i)
        end
        if self.NotSelectModelGos ~= nil then
            self.NotSelectModelGos[i]:SetActive(index ~= i)
        end
    end
end

return UIOccXinFaPanel
