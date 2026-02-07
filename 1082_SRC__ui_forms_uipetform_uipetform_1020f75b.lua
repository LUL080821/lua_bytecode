
--==============================--
--author:
--Date: 2019-06-19 17:00:25
--File: UIPetForm.lua
--Module: UIPetForm
--Description: Pet system interface
--==============================--
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local UIPetProDetailsPanel = require "UI.Forms.UIPetForm.UIPetProDetailsPanel"
local UIPetProSoulPanel = require "UI.Forms.UIPetForm.UIPetProSoulPanel"
local UIPetHuaXingPanel = require "UI.Forms.UIPetForm.UIPetHuaXingPanel"
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UIPetForm = {
    --menu
    ListMenu = nil,
    --Details interface
    DetPanel = nil,
    --Soul-Reign Interface
    SoulPanel = nil,

    --Background picture
    BackTex = nil,
    --grade
    LevelLabel = nil,
    --Model skin
    ModelSkin = nil,
    ModelRoot = nil,
    --Combat Power
    FightPower = nil,
    --Skill scrollview
    ScrollView = nil,
    --Skill grid
    Grid = nil,
    --icon
    SkillIcons = nil,
    --name
    Name = nil,
    --Shape button
    HuaXingBtn = nil,
    HuaXingRedPoint = nil,

    --The currently selected page
    CurSelectPanel = 0,
    --The pet currently displayed
    CurShowPet = nil,
};

--Register event function, provided to the CS side to call.
function UIPetForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIPetForm_OPEN, self.OnOpen);
    self:RegisterEvent(UIEventDefine.UIPetForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM, self.OnRefreshPanel);
	self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated);
	self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION, self.OnFightUpdate);
end


local L_SkillIcon = nil
--The first display function is provided to the CS side to call.
function UIPetForm:OnFirstShow()
    local _myTrans = self.Trans
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "Right/UIListMenu"))
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self))
    self.ListMenu.IsHideIconByFunc = true
    self.ListMenu.IsUpdateRedByFuc = true
    self.ListMenu:AddIcon(1, DataConfig.DataMessageString.Get("C_JUESE_SHUXING"), FunctionStartIdCode.PetProDet)
    self.ListMenu:AddIcon(2, DataConfig.DataMessageString.Get("HunZhu"), FunctionStartIdCode.PetProSoul)
    --TODO: temp chưa thấy tên DataMessageString, dùng tạm
    self.ListMenu:AddIcon(NatureSubEnum.Fashionable, DataConfig.DataMessageString.Get("NATUREMOUNTTYPETHREE") , FunctionStartIdCode.PetLevel)

    self.DetPanel = UIPetProDetailsPanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/ProPanel"), self, self)
    self.SoulPanel = UIPetProSoulPanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/SoulPanel"), self, self)
    
    self.HuaXingPanel = UIPetHuaXingPanel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/HuaXingPanel"), self, self)


    self.LevelLabel = UIUtils.FindLabel(_myTrans, "Center/Level")
    self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_myTrans, "Center/UIRoleSkinCompoent"))
    self.ModelSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Pet, "show_idle")
    self.ModelRoot = UIUtils.FindTrans(_myTrans, "Center/UIRoleSkinCompoent/Box/ModelRoot")
    self.BackTex = UIUtils.FindTex(_myTrans, "Center/Texture")
    self.FightPower = UIUtils.FindLabel(_myTrans, "Skill/Fight/Label")

    self.ScrollView = UIUtils.FindScrollView(_myTrans, "Skill/ListPanel")
    self.Grid = UIUtils.FindGrid(_myTrans, "Skill/ListPanel/Grid")
    self.SkillIcons = {}
    for i = 1, 4 do
        self.SkillIcons[i] = L_SkillIcon:New(UIUtils.FindTrans(_myTrans, string.format("Skill/ListPanel/Grid/%d", i)), i == 1)
    end
    self.Name = UIUtils.FindLabel(_myTrans, "Center/Name")
    self.HuaXingBtn = UIUtils.FindBtn(_myTrans, "Center/HuanBtn")
    UIUtils.AddBtnEvent(self.HuaXingBtn, self.OnHuaXingBtnClick, self)
    self.HuaXingRedPoint = UIUtils.FindGo(_myTrans, "Center/HuanBtn/RedPoint")
    self.PetEquipBtn = UIUtils.FindBtn(_myTrans, "Center/SupportBtn")
    UIUtils.AddBtnEvent(self.PetEquipBtn, self.OnPetEquipBtnClick, self)
    self.PetEquipRedPoint = UIUtils.FindGo(_myTrans, "Center/SupportBtn/RedPoint")

    self.CSForm:AddAlphaPosAnimation(UIUtils.FindTrans(self.Trans, "Right"), 0, 1, 100, 0, 0.4, true, false)
    self.CSForm:AddAlphaPosAnimation(UIUtils.FindTrans(self.Trans, "Skill"), 0, 1, 0, -50, 0.3, true, false)
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)

    ----------------------------------
    
    ----------------------------------
end

function UIPetForm:GetShowPetId()
    local _result = GameCenter.PetSystem.CurFightPet
    local _petDic = GameCenter.PetSystem.CurActivePets
    if _result <= 0 and _petDic:Count() > 0 then
        local _keys = _petDic:GetKeys()
        _result = _petDic[_keys[1]].ID
    end
    return _result
end

--The operation after display is provided to the CS side to call.
function UIPetForm:OnShowAfter()
    local _curPetCfg = DataConfig.DataPet[self:GetShowPetId()]
    if _curPetCfg ~= nil then
        self.CurShowPet = _curPetCfg.Id
        self.ModelSkin:ResetSkin()
        self.ModelSkin:ResetRot()
        self.ModelSkin:SetLocalScale(_curPetCfg.UiScale)
        self.ModelSkin:SetEquip(FSkinPartCode.Body, _curPetCfg.Model)
        self.ModelSkin:Play("show", 0, 1, 1)
        UnityUtils.SetLocalPositionY(self.ModelRoot, _curPetCfg.UiModelHeight)
    end
    --ẩn trợ uy
    --self.PetEquipBtn.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.PetEquip))
    self.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine"))
end

--Hide previous operations and provide them to the CS side to call.
function UIPetForm:OnHideBefore()
    self.ListMenu:SetSelectByIndex(-1)
    self.ModelSkin:ResetSkin()
end

--The hidden operation is provided to the CS side to call.
function UIPetForm:OnHideAfter()
end

--Refresh the interface
function UIPetForm:OnFormActive(isActive)
    if isActive then
        local _curPetCfg = DataConfig.DataPet[self:GetShowPetId()]
        if _curPetCfg ~= nil then
            self.CurShowPet = _curPetCfg.Id
            self.ModelSkin:ResetSkin()
            self.ModelSkin:ResetRot()
            self.ModelSkin:SetLocalScale(_curPetCfg.UiScale)
            self.ModelSkin:SetEquip(FSkinPartCode.Body, _curPetCfg.Model)
            self.ModelSkin:Play("show", 0, 1, 1)
            UnityUtils.SetLocalPositionY(self.ModelRoot, _curPetCfg.UiModelHeight)
        end
            

        --ẩn trợ uy
        --self.PetEquipBtn.gameObject:SetActive(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.PetEquip))
        self:RefreshPanel(nil, nil)
    end
end

--Open event
function UIPetForm:Update(dt)
    self.AnimPlayer:Update(dt)
    if self.CurSelectPanel == 1 then
        self.DetPanel:Update(dt)
    end
end

--Menu Selection
function UIPetForm:OnMenuSelect(id, select)
    if select then
        self.CurSelectPanel = id
        if id == 1 then
            self.DetPanel:Show()
            self:OnFormActive(true)
        elseif id == 2 then
            self.SoulPanel:Show()
        else 
            self.HuaXingPanel:Show()
        end
    else
        if id == 1 then
            self.DetPanel:Hide()
        elseif id == 2 then
            self.SoulPanel:Hide()
        else
            self.HuaXingPanel:Hide()
        end
    end
end

--Refresh the interface
function UIPetForm:RefreshPanel(obj, sender)
    local _system = GameCenter.PetSystem

    UIUtils.SetTextByEnum(self.LevelLabel, "C_MAIN_NON_PLAYER_SHOW_LEVEL", _system.CurLevel)
    local _curPetCfg = DataConfig.DataPet[self:GetShowPetId()]
    if _curPetCfg ~= nil then
        self.SkillIcons[1]:SetSkill(DataConfig.DataSkill[_curPetCfg.PetSkill])
        local _petInst = _system:FindActivePetInfo(_curPetCfg.Id)
        if _petInst ~= nil then
            local _activeLevels = _petInst.SkillActiveLevels;
            local _skillCount = #_activeLevels;
            for i = 2, #self.SkillIcons do
                if (i - 1) <= _skillCount then
                    self.SkillIcons[i]:SetSkill(DataConfig.DataSkill[_activeLevels[i - 1][1]], _petInst.CurLevel >= _activeLevels[i - 1][3]);
                else
                    self.SkillIcons[i]:SetSkill(nil, nil);
                end
            end
        end
        self.Grid:Reposition()
        self.ScrollView.repositionWaitFrameCount = 1
        UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  L_ItemBase.GetQualityString(_curPetCfg.Quality),  _curPetCfg.Name)
        UIUtils.SetColorByQuality(self.Name, _curPetCfg.Quality)
    end
    self:OnFightUpdate()
    self.HuaXingRedPoint:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.PetLevel))
    self.PetEquipRedPoint:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.PetEquip))

    if self.CurSelectPanel == 1 then
        self.DetPanel:RefreshPanel(nil, nil)
    elseif self.CurSelectPanel == 2 then
        self.SoulPanel:RefreshPanel(obj, nil)
    else 
        self.HuaXingPanel:RefreshPanel(obj, nil)
    end
end

function UIPetForm:OnFightUpdate(obj, sender)
    UIUtils.SetTextByNumber(self.FightPower, GameCenter.NatureSystem.NaturePetData.super.Fight)
end

--Open event
function UIPetForm:OnOpen(obj, sender)
    self.CSForm:Show(sender);
    if obj ~= nil then
        self.ListMenu:SetSelectById(obj);
    else
        self.ListMenu:SetSelectByIndex(1)
    end
    self:RefreshPanel(obj, sender)
end

--Close event
function UIPetForm:OnClose(obj, sender)
    self.CSForm:Hide();
end

--Refresh event
function UIPetForm:OnRefreshPanel(obj, sender)
    self:RefreshPanel(obj, sender)
end

--Function refresh
function UIPetForm:OnFuncUpdated(functioninfo, sender)
	local _funcID = functioninfo.ID
	if FunctionStartIdCode.PetEquip == _funcID then
		self.PetEquipRedPoint:SetActive(functioninfo.IsShowRedPoint)
    end
    if FunctionStartIdCode.PetProSoul == _funcID then
		self.SoulPanel:RefreshPanel(0)
	end
end

--Click the shape button
function UIPetForm:OnHuaXingBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.PetLevel)
end

--Pet assist button click
function UIPetForm:OnPetEquipBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIPetEquipMainForm_OPEN)
end

--Pet Skills icon
L_SkillIcon = {
    --transform
    Trans = nil,
    --gameobject
    GO = nil,
    --Button
    Btn = nil,
    --icon
    Icon = nil,
    --Go not activated
    NotActiveGo = nil,
    --Skill configuration
    SkillCfg = nil,
}

function L_SkillIcon:New(trans, atkSkill)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.GO = trans.gameObject
    _m.Btn = UIUtils.FindBtn(_m.Trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Icon = UIUtils.FindSpr(_m.Trans, "Icon")
    _m.NotActiveGo = UIUtils.FindGo(_m.Trans, "NotActive")
    return _m
end

function L_SkillIcon:SetSkill(skillCfg, unLock)
    self.SkillCfg = skillCfg
    if skillCfg ~= nil then
        self.GO:SetActive(true)
        self.Icon.spriteName = string.format("skill_%d", skillCfg.Icon)
        self.NotActiveGo:SetActive(not unLock)
    else
        self.GO:SetActive(false)
    end
end

function L_SkillIcon:OnBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIPetSkillTips_OPEN, self.SkillCfg.Id)
end

return UIPetForm;
