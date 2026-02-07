------------------------------------------------
--Author: xc
--Date: 2019-05-06
--File: UIMountGrowUpForm.lua
--Module: UIMountGrowUpForm
--Description: Creation Mount Panel
------------------------------------------------
--Quote
local CommonPanelRedPoint = require "Logic.Nature.Common.CommonPanelRedPoint"
local NatureSkillSet = require "Logic.Nature.NatureSkillSet"
local UIPlayerSkinCompoent = CS.Thousandto.GameUI.Form.UIPlayerSkinCompoent
local BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIEventListener = CS.UIEventListener
local NGUITools = CS.NGUITools
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local WrapMode = CS.UnityEngine.WrapMode
local TimeTicker = CS.Thousandto.Core.Base.TimeTicker
local MyTweenUISlider = CS.Thousandto.Plugins.Common.MyTweenUISlider
local L_DrugItem = require("UI.Forms.UIRealmStifleForm.UIRealmstifleDrugItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local L_StarVfxCom = require("UI.Components.UIStarVfxComponent")

local UIMountGrowUpForm = {
    RedPoint = nil, --Panboard red dot component
    UIListMenu = nil, --Pagination Component
    Form = -1, --Pagination Type

    TrainGo = nil, --The first page
    DrugGo = nil, --The second pagination
    OneKeyButton = nil, --In Paging 1, one-click upgrade button
    UpLevelButton = nil, --In Paging 1, Upgrade button
    FishionButton= nil, --Shape button
    ModelShowButton = nil, --Model exterior button
    SkillTrans = nil, --Skill node
    SkillsInfo = nil, --Skill component information
    PlayerSkin = nil, --Player model
    ModelName = nil, --Model name

    AttrGrid = nil, --Properties display node
    AttrClone = nil, --Attribute clone

    ItemGrid = nil, --Props display node
    ItemClone = nil, --Props clone
    ItemSelectTrs = nil, --Props Selection Box
    ItemSelectNameLab = nil, --The name is displayed after the prop is selected
    CurSelectItemId = 0, --Currently selected prop ID
    FightLab = nil, --Fighting power display

    Effect = nil, --Upgrade special effects

    CurShowModel = 0, --Current display model

    LeftModelButton = nil, --The model button that turns the page to the left
    RightModelButton = nil, --The model button that flips page to the right
    ShowModelButton = nil, --Switch button to display the model

    IsMaxGo = nil, --Full-level picture

    ProssSlider = nil, --Progress bar display
    ProssLab = nil , --Progress bar text

    DrugGrid = nil, --Eat fruit node
    DrugClone = nil, --Eat fruit clones
    DrugScrollView = nil, --Eat fruit sliding list
    IsInit = true, -- Whether to initialize

    BaseStarGrid = nil, --Basic Stars
    BaseStarClone = nil, --Basic star clone
    StageLab = nil, --Sort word
    ModelTexture = nil, --Model background map
    NatureType = NatureEnum.Mount, --type
    LevelVfxTrs = nil, --Upgrade special effects
    TimeTickerInfo = nil, --Time delay processing
    StarVfxTrs = nil, --Star special effects
    StarVfx = nil, --Star special effects
    StarVfxBeginTrs = nil, --The effect start position
    TweenTrans = nil, --Special Effects Mobile Animation Component
    ItemDicKeyGo = Dictionary:New(), --Storage props and gameobject
    UITween = nil, --Progress bar animation
    MountEquipBtn = nil,
    MountEquipRedPoint = nil,

    ------------------------------------------------
    ItemFashionList = List:New(),
    FashionBase = nil,
    LeftGrid = nil, --Left list node
    LeftClone = nil, --The left list clone
    EquipTrs = nil, --Show wearable icon
    ActiveButton = nil, --Activate button
    UpButton = nil, --Star Up button
    DicGo = Dictionary:New(), --model corresponds to the corresponding gameobject
    BlessSlider = nil, --Progress bar display
    BlessLab = nil, --The progress bar displays text
    FightFashionLab = nil, --Combat Power Text
    IsMaxLevelGo = nil, --Full level icon
    Skin = nil, --General model data
    FashionIdList = List:New(),
    ------------------------------------------------

}


function UIMountGrowUpForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIMountGrowUpForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIMountGrowUpForm_CLOSE,self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_INIT,self.UpDateWingInfo)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPLEVEL, self.UpDateWingUPLEVEL)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_FASHION_CHANGEMODEL,self.UpDateChangeModel)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPDATEDRUG, self.UpDateChangeDrug)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_MOUNT_UPDATEEQUIP,self.UpDateEatEquip)
    self:RegisterEvent(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE,self.UpDateItem)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION, self.SetFight)
	self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated);
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_WING_UPDATEFASHION,self.UpDateFashion)
    self:RegisterEvent(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.UpDateRedEvent)
    self:RegisterEvent(LogicLuaEventDefine.NATURE_EVENT_FASHION_CHANGEMODEL, self.UpDateChangeFashionModel)

end
--Open
function UIMountGrowUpForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.Form = -1;
	if obj then
		self.Form = obj;
    end
 
    if self.Form == -1 then
        self.Form = NatureSubEnum.BaseUpLevel
    end
	self.UIListMenu:SetSelectById(self.Form)   
end
--closure
function UIMountGrowUpForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

function UIMountGrowUpForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self:InitRedPoint()

    self.CSForm:AddAlphaPosAnimation(UIUtils.FindTrans(self.Trans, "Right"), 0, 1, 100, 0, 0.4, true, false)
    self.CSForm:AddAlphaPosAnimation(UIUtils.FindTrans(self.Trans, "Skill"), 0, 1, 0, -50, 0.3, true, false)
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIMountGrowUpForm:OnShowAfter()
    self:LoadTextures()
    self:LoadFashionTextures()
    if  GameCenter.NatureSystem.NatureMountData.Cfg == nil then
        return
    end
    self.RedPoint:Initialize()
    self.CurShowModel = GameCenter.NatureSystem.NatureMountData.super:GetCurShowModel()
    self:SetModel() --Refresh the model
    self:SetItem()
    self:RefreshLevelInfo()
    self:RefreshBaseLevelInfo()
    self:SetDrugInfo(0)
    self.StarVfx = UIUtils.RequireUIVfxSkinCompoent(self.StarVfxTrs)
    self.StarVfx:OnCreateAndPlay(ModelTypeCode.UIVFX,18,LayerUtils.GetAresUILayer())
    self.TweenTrans.gameObject:SetActive(false)
    self.IsInit = false
    ------------------------------------------------
    self.FashionBase = GameCenter.NatureSystem.NatureMountData.super
    
    if self.Skin then
        local type = FSkinTypeCode.Player
        if self.Form ~= NatureEnum.Wing and self.Form ~= NatureEnum.Mount then
            type = FSkinTypeCode.Custom
        end
        self.Skin:OnFirstShow(self.this, type,"show_idle")    
        self.Skin.SkinAnimationCullingType = AnimatorCullingMode.AlwaysAnimate
        self.Skin.EnableDrag = true
    end
    -- self:InitLeftList()
    ------------------------------------------------
end

function UIMountGrowUpForm:OnHideBefore()
    if self.PlayerSkin then
        self.PlayerSkin:ResetSkin()
    end
    if self.Effect then
        self.Effect:Destroy()
    end
    self.UIListMenu:SetSelectByIndex(-1)
    self.IsInit = true
    self.RedPoint:UnInitialize()
    if self.StarVfx then
        self.StarVfx:OnDestory()
    end
    self.AutoRemainTime = 0
    self.CSForm:UnloadTexture(self.ModelTexture)
    if self.Skin then
        self.Skin:ResetSkin()
    end

    self.Scrollview:ResetPosition()
end

--Refresh interface data
function UIMountGrowUpForm:RefreshLevelInfo()
    self.SkillsInfo:RefreshSkill(GameCenter.NatureSystem.NatureMountData.super.SkillList) --Refresh the skill display
    self:SetAttr() --Refresh attribute display
    self:SetModelButton()
    self:SetMaxLevel()
    self:SetSlider()
    self:SetFight()
    self:SetBtnShow()
end
function UIMountGrowUpForm:SetBtnShow()
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_RUNE_STOP")
    else
        UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
    end
end
--Refresh the basic attributes of the mount
function UIMountGrowUpForm:RefreshBaseLevelInfo()
    --self:SetBaseAttr()
    --self:SetBaseSlider()
end

--Find components
function UIMountGrowUpForm:FindAllComponents()
    local _myTrans = self.Trans
    self.UIListMenu =  UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "Right/UIListMenu"))
    self.UIListMenu.IsHideIconByFunc = true
    self.UIListMenu:AddIcon(NatureSubEnum.BaseUpLevel,DataConfig.DataMessageString.Get("NATURECULTIVATE"),FunctionStartIdCode.MountLevel)
    self.UIListMenu:AddIcon(NatureSubEnum.Drug,DataConfig.DataMessageString.Get("NATUREMOUNTTYPETWO"),FunctionStartIdCode.MountDrug)
    -- self.UIListMenu:AddIcon(NatureSubEnum.Fashionable,DataConfig.DataMessageString.Get("NATUREMOUNTTYPETHREE"),FunctionStartIdCode.MountFashion)
        self.UIListMenu:AddIcon(NatureSubEnum.Fashionable,DataConfig.DataMessageString.Get("NATUREMOUNTTYPETHREE"),FunctionStartIdCode.MountFashion)

    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    self.TrainGo = UIUtils.FindGo(_myTrans,"Right/Train")
    self.DrugGo = UIUtils.FindGo(_myTrans,"Right/Drug")
    self.TrainGo:SetActive(false)
    self.DrugGo:SetActive(false)
    self.OneKeyButton = UIUtils.FindBtn(_myTrans,"Right/Train/Bottom/OneKey")
    self.DisableOneKeyButton = UIUtils.FindBtn(_myTrans,"Right/Train/Bottom/OneKey/Disable")
    self.OneKeyBtnLabel = UIUtils.FindLabel(_myTrans,"Right/Train/Bottom/OneKey/Label")
    self.UpLevelButton = UIUtils.FindBtn(_myTrans,"Right/Train/Bottom/Uplevel")
    self.LeftBtnsGrid = UIUtils.FindGrid(_myTrans,"Left")
    self.FishionButton = UIUtils.FindBtn(_myTrans,"Left/HuanBtn")
    self.ModelShowButton = UIUtils.FindBtn(_myTrans,"Center/ModelShowBtn")
    self.AttrScroll = UIUtils.FindScrollView(_myTrans,"Right/Train/UpSprite/Panel")
    self.AttrGrid = UIUtils.FindGrid(_myTrans,"Right/Train/UpSprite/Panel/Grid")
    self.AttrClone = UIUtils.FindGo(_myTrans,"Right/Train/UpSprite/Panel/Grid/default")
    self.ItemGrid = UIUtils.FindGrid(_myTrans,"Right/Train/DownSprite/Goods")
    self.ItemClone = UIUtils.FindGo(_myTrans,"Right/Train/DownSprite/Goods/default")
    self.ItemSelectTrs = UIUtils.FindTrans(_myTrans,"Right/Train/DownSprite/SelectImg")
    self.ItemSelectNameLab = UIUtils.FindLabel(_myTrans,"Right/Train/DownSprite/SelectLabel")
    self.SkillTrans =  UIUtils.FindTrans(_myTrans,"Skill/ListPanel/Grid")
    self.SkillsInfo = NatureSkillSet:New(self.SkillTrans,self.NatureType)
    self.PlayerSkin = UIUtils.RequireUIRoleSkinCompoent( UIUtils.FindTrans(_myTrans,"Center/UIRoleSkinCompoent"));
    if self.PlayerSkin then
        self.PlayerSkin:OnFirstShow(self.this, FSkinTypeCode.Player,"show_idle")
        self.PlayerSkin.EnableDrag = true
    end
    local _effectNode =  UIUtils.FindTrans(_myTrans,"Center/UIVfxSkin")
    self.Effect = UIUtils.RequireNatureVfxEffect( UIUtils.FindTrans(_myTrans,"Right/Train/Effect"))
    self.Effect:Init()
    self.Effect.Node2 = _effectNode
    self.LeftModelButton = UIUtils.FindBtn(_myTrans,"Center/ModelButton/LeftModelButton")
    self.RightModelButton = UIUtils.FindBtn(_myTrans,"Center/ModelButton/RightModelButton")
    self.ShowModelButton = UIUtils.FindBtn(_myTrans,"Left/ShowButton")
    self.ShowEdGo = UIUtils.FindGo(_myTrans, "Left/Showed")
    self.ModelActiveDescLabel = UIUtils.FindLabel(_myTrans, "Center/ActiveDesc")
    self.IsMaxGo =  UIUtils.FindGo(_myTrans,"Right/Train/ManJi")
    self.ProssSlider = UIUtils.FindSlider(_myTrans,"Right/Train/Bless")
    self.ProssLab = UIUtils.FindLabel(_myTrans,"Right/Train/Bless/Label")
    self.ModelName = UIUtils.FindLabel(_myTrans,"Center/Name")
    self.FightLab = UIUtils.FindLabel(_myTrans,"Skill/Fight")
    self.BaseStarGrid = UIUtils.FindGrid(_myTrans,"Center/StarPanel/Grid")
    self.BaseStarClone = UIUtils.FindGo(_myTrans,"Center/StarPanel/Grid/Star")
    self.StageLab = UIUtils.FindLabel(_myTrans,"Center/Stage")
    self.ModelTexture= UIUtils.FindTex(_myTrans,"Center/Texture")
    self.LevelVfxTrs = UIUtils.FindTrans(_myTrans,"Center/UIVfxSkinCompoent")
    self.StarVfxTrs = UIUtils.FindTrans(_myTrans,"Right/Train/Vfx/UIVfxSkinCompoent")
    self.TweenTrans = UIUtils.FindTweenTransform(_myTrans,"Right/Train/Vfx")
    self.StarVfxBeginTrs = UIUtils.FindTrans(_myTrans,"Right/Train/VfxStar")

    self.DrugGrid = UIUtils.FindGrid(_myTrans,"Right/Drug/Panel/Grid")
    self.DrugScrollView = UIUtils.FindScrollView(_myTrans,"Right/Drug/Panel")
    local _gridTrans = UIUtils.FindTrans(_myTrans, "Right/Drug/Panel/Grid")
    self.DrugItemList = List:New()
    for i = 0, _gridTrans.childCount - 1 do
        self.DrugClone = L_DrugItem:New(_gridTrans:GetChild(i))
        self.DrugItemList:Add(self.DrugClone)
    end
    self.MountEquipBtn = UIUtils.FindBtn(_myTrans, "Left/SupportBtn")
    UIUtils.AddBtnEvent(self.MountEquipBtn, self.OnMountEquipBtnClick, self)
    self.MountEquipRedPoint = UIUtils.FindGo(_myTrans, "Left/SupportBtn/RedPoint")

    ------------------------------------------------
    self.FashionGo = UIUtils.FindGo(_myTrans,"Right/Fashion")
    self.LeftGrid = UIUtils.FindGrid(_myTrans,"Right/Fashion/Left/Panel/Grid")
    self.LeftClone = UIUtils.FindGo(_myTrans,"Right/Fashion/Left/Panel/Grid/default")
    self.EquipTrs = UIUtils.FindTrans(_myTrans,"Right/Fashion/Left/Equip")
    self.Scrollview = UIUtils.FindScrollView(_myTrans,"Right/Fashion/Left/Panel")
    self.FashionGo:SetActive(false)

    self.UpGo = UIUtils.FindGo(_myTrans,"Right/Fashion/Buttom/Up")
    self.DescLabel = UIUtils.FindLabel(_myTrans,"Right/Fashion/Buttom/DescLabel")
    self.AttrFashionGrid = UIUtils.FindGrid(_myTrans,"Right/Fashion/Buttom/Attr/Grid")
    self.AttrFashionClone = UIUtils.FindGo(_myTrans,"Right/Fashion/Buttom/Attr/Grid/default")

    self.ActiveButton = UIUtils.FindBtn(_myTrans,"Right/Fashion/Buttom/Up/ActiveButton")
    self.ActiveRed = UIUtils.FindGo(_myTrans,"Right/Fashion/Buttom/Up/ActiveButton/RedPoint")
    self.UpButton = UIUtils.FindBtn(_myTrans,"Right/Fashion/Buttom/Up/UpButton")
    self.DisableUpButton = UIUtils.FindBtn(_myTrans,"Right/Fashion/Buttom/Up/UpButton/Disable")
    self.UpRed = UIUtils.FindGo(_myTrans,"Right/Fashion/Buttom/Up/UpButton/RedPoint")
    self.ChangeModelButton = UIUtils.FindBtn(_myTrans,"Right/Fashion/Buttom/Up/ChangeModelButton")
    
    self.UpItem =  UILuaItem:New(UIUtils.FindTrans(_myTrans,"Right/Fashion/Buttom/Up/Item"))
    self.UpItem.IsShowTips = true

    self.BlessSlider = UIUtils.FindSlider(_myTrans,"Right/Fashion/Buttom/Up/Bless")
    self.BlessLab = UIUtils.FindLabel(_myTrans,"Right/Fashion/Buttom/Up/Bless/Label")
    self.FightFashionLab = UIUtils.FindLabel(_myTrans,"Right/Fashion/Buttom/Up/Fight")
    self.IsMaxLevelGo = UIUtils.FindGo(_myTrans,"Right/Fashion/Buttom/Up/ManJi")

    self.Skin = UIUtils.RequireUIRoleSkinCompoent( UIUtils.FindTrans(_myTrans,"Center/UIRoleSkinCompoent"));
    self.Skin:SetOnSkinPartChangedHandler(Utils.Handler(self.SkinLoadHandler, self))

    self.SkillIcon = UIUtils.FindSpr(_myTrans, "Right/Fashion/Buttom/Up/Skill/Icon")
    self.SkillNameLabel = UIUtils.FindLabel(_myTrans, "Right/Fashion/Buttom/Up/Skill/Name")
    self.SkillGo = UIUtils.FindGo(_myTrans, "Right/Fashion/Buttom/Up/Skill")
    self.StarFashionVfx = L_StarVfxCom:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/Fashion/UIVfxSkinCompoent"))

    ------------------------------------------------
end

--Loading texture
function UIMountGrowUpForm:LoadTextures()
    self.CSForm:LoadTexture(self.ModelTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine"))
end
--Register events on the UI, such as click events, etc.
function UIMountGrowUpForm:RegUICallback()
    UIUtils.AddBtnEvent(self.OneKeyButton, self.OnClickOneKey, self)
    UIUtils.AddBtnEvent(self.UpLevelButton, self.OnClickUpLevel, self)
    UIUtils.AddBtnEvent(self.FishionButton, self.OnClickFishion, self)
    UIUtils.AddBtnEvent(self.ModelShowButton, self.OnClickModelShow, self)
    UIUtils.AddBtnEvent(self.LeftModelButton, self.OnClickLeft, self)
    UIUtils.AddBtnEvent(self.RightModelButton, self.OnClickRight, self)
    UIUtils.AddBtnEvent(self.ShowModelButton, self.OnClickShowModel, self)

    ------------------------------------------------
    UIUtils.AddBtnEvent(self.ActiveButton, self.OnClickActiveBtn, self)
    UIUtils.AddBtnEvent(self.UpButton, self.OnClickUpBtn, self)
    UIUtils.AddBtnEvent(self.ChangeModelButton, self.OnClickChangeModelBtn, self)
    ------------------------------------------------
end

--Pagination selection
function UIMountGrowUpForm:OnMenuSelect(id, sender)
    self.Form = id
    if sender then
        if id == NatureSubEnum.BaseUpLevel then
            self.TrainGo:SetActive(true)
            self:SetModel()
            self:SetModelButton()
        elseif id == NatureSubEnum.Drug then
            self.DrugGo:SetActive(true)
            self.DrugGrid:Reposition()
            self.DrugScrollView:ResetPosition()
            self.AnimPlayer:Stop()
            for i = 1, #self.DrugItemList do
                local _trans = self.DrugItemList[i].Trans
                self.CSForm:RemoveTransAnimation(_trans)
                self.CSForm:AddAlphaPosAnimation(_trans, 0, 1, -50, 0, 0.2, false, false)
                self.AnimPlayer:AddTrans(_trans, (i - 1) * 0.1)
            end
            self.AnimPlayer:Play()
            self.AutoRemainTime = 0
            UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
        else
            self:InitLeftList()
            self.FashionGo:SetActive(true)
            self.LeftGrid:Reposition()
            self.Scrollview:ResetPosition()
            self.LeftModelButton.gameObject:SetActive(false)
            self.RightModelButton.gameObject:SetActive(false)

        end
    else
        if id == NatureSubEnum.BaseUpLevel then
            self.TrainGo:SetActive(false)
        elseif id == NatureSubEnum.Drug then
            self.DrugGo:SetActive(false)
        else 
            self.FashionGo:SetActive(false)
        end
    end
end

--Click on the left
function UIMountGrowUpForm:OnClickLeft()
    if self.Form == 1 or self.Form == 2 then
        local _lastmodel = GameCenter.NatureSystem.NatureMountData.super:GetLastModel(self.CurShowModel)
        if _lastmodel ~= 0 then
            self.CurShowModel = _lastmodel
            self:SetModel()
            self:SetModelButton()
        end
    else
        local _tempID = 0
        for i=1, #self.FashionIdList do
            if self.FashionIdList[i] == self.CurSelectModel then
                _tempID = self.FashionIdList[i-1]
                break 
            end
        end
        self:OnClickLeftBtn(self.DicGo[_tempID])
    end
    
end

--Click on the right
function UIMountGrowUpForm:OnClickRight()
    if self.Form == 1 or self.Form == 2 then
        local _lastmodel = GameCenter.NatureSystem.NatureMountData.super:GetNextModel(self.CurShowModel)
        if _lastmodel ~= 0 then
            self.CurShowModel = _lastmodel
            self:SetModel()
            self:SetModelButton()
        end
    else
        local _tempID = 0
        for i=1, #self.FashionIdList do
            if self.FashionIdList[i] == self.CurSelectModel then
                _tempID = self.FashionIdList[i+1]
                break
            end
        end
        self:OnClickLeftBtn(self.DicGo[_tempID])
    end
end

--Click to switch model
function UIMountGrowUpForm:OnClickShowModel()
    GameCenter.NatureSystem:ReqNatureModelSet(self.NatureType,self.CurShowModel)
end

-- One-click button event upgrade
function UIMountGrowUpForm:OnClickOneKey()
    if GameCenter.NatureSystem.NatureMountData:IsMaxLevel() then
        self.AutoRemainTime = 0
        UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
        return
    end
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        self.AutoRemainTime = 0
        UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
    else
        if self:SendUpLevel(true) then
            self.AutoRemainTime = 0.4
            UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_RUNE_STOP")
        else
            UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
        end
    end
end

--Button click event upgrade
function UIMountGrowUpForm:OnClickUpLevel()
    self:SendUpLevel(false)
end

--Carriage assist button click
function UIMountGrowUpForm:OnMountEquipBtnClick()
    GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipMainForm_OPEN)
end

function UIMountGrowUpForm:SendUpLevel(isonekey)
    if self.CurSelectItemId ~= 0 then
        local _needItem = true
        if isonekey then
            if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CurSelectItemId) > 0 then
                GameCenter.NatureSystem:ReqNatureUpLevel(self.NatureType, self.CurSelectItemId, false)
                _needItem = false
                return true
            end
            local list = GameCenter.NatureSystem.NatureMountData.super.ItemList
            for i=1,#list do
                if list[i].ItemID ~= self.CurSelectItemId then
                    local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(list[i].ItemID)
                    if _haveNum > 0 then
                        GameCenter.NatureSystem:ReqNatureUpLevel(self.NatureType, list[i].ItemID, false)
                        _needItem = false
                        return true
                    end
                end
            end
        else
            if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.CurSelectItemId) > 0 then
                GameCenter.NatureSystem:ReqNatureUpLevel(self.NatureType, self.CurSelectItemId, false)
                _needItem = false
            end
        end
        if _needItem then
            local _itemDb = DataConfig.DataItem[self.CurSelectItemId]
            Utils.ShowPromptByEnum("Item_Not_Enough", _itemDb.Name)
            GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CurSelectItemId)
        end
    else
        Debug.LogError("Select ItemId Is 0")
    end
    return false
end

--Fashion Button
function UIMountGrowUpForm:OnClickFishion()
    GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN,self.NatureType)
end

--Model exterior button
function UIMountGrowUpForm:OnClickModelShow()
    GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN,self.NatureType)
end

--Add red dots into RedPoint component
function UIMountGrowUpForm:InitRedPoint()
    self.RedPoint = CommonPanelRedPoint:New()
    self.RedPoint:Add(FunctionStartIdCode.MountLevel,self.OneKeyButton.transform,NatureSubEnum.Begin,false)
    self.RedPoint:Add(FunctionStartIdCode.MountLevel,self.UpLevelButton.transform,NatureSubEnum.Begin,false)
    self.RedPoint:Add(FunctionStartIdCode.MountFashion,self.FishionButton.transform,NatureSubEnum.Begin,false)
end

--Set the basic level accuracy bar
function UIMountGrowUpForm:SetBaseSlider()

end

--Clone the stars
function UIMountGrowUpForm:CloneStar(max,curstar)
    local _listobj = NGUITools.AddChilds(self.BaseStarGrid.gameObject,self.BaseStarClone,max)
    -- for i=1,max do
    --     local _spr = UIUtils.FindSpr(_listobj[i-1].transform)
    --     _spr.enabled = curstar >= i
    -- end
    for i = 1, max do
        local _spr = UIUtils.FindSpr(_listobj[i-1].transform)
        _spr.enabled = true
        if curstar >= i then
           _spr.spriteName = "n_z_5"
        else
            -- sao gray
            _spr.spriteName = "n_z_5_1" -- hoặc spriteName = "star_gray"
        end
    end
    if self.IsInit then
        self.BaseStarGrid:Reposition()
    end
    UIUtils.SetTextByEnum(self.StageLab, "MOUNT_GROWUP_LAYER", GameCenter.NatureSystem.NatureMountData.Cfg.Steps)
end

--Set basic properties display
function UIMountGrowUpForm:SetBaseAttr()

end

--Set the progress bar
function UIMountGrowUpForm:SetSlider()
    self.ProssSlider.value = GameCenter.NatureSystem.NatureMountData.super.CurExp / GameCenter.NatureSystem.NatureMountData.Cfg.Progress
    local _messagestr = nil
    _messagestr = UIUtils.CSFormat("{0}/{1}",GameCenter.NatureSystem.NatureMountData.super.CurExp,GameCenter.NatureSystem.NatureMountData.Cfg.Progress)
    UIUtils.SetTextByString(self.ProssLab, _messagestr)
    self:CloneStar(GameCenter.NatureSystem.NatureMountData:GetCurMaxStar(),GameCenter.NatureSystem.NatureMountData.Cfg.Star)
end

--Set whether it is full level
function UIMountGrowUpForm:SetMaxLevel()
    local _isMax = GameCenter.NatureSystem.NatureMountData:IsMaxLevel()
    self.IsMaxGo:SetActive(_isMax)
    -- NGUITools.SetButtonGrayAndNotOnClick(self.OneKeyButton.transform,_isMax)
    -- NGUITools.SetButtonGrayAndNotOnClick(self.UpLevelButton.transform,_isMax)
    self.UpLevelButton.gameObject:SetActive(not _isMax)
    self.DisableOneKeyButton.gameObject:SetActive(_isMax)
    self.DisableOneKeyButton.isEnabled = false
end

--Set the model wings
function UIMountGrowUpForm:SetModel()
    if self.CurShowModel ~= 0 then
        self.PlayerSkin:ResetSkin()
        self.PlayerSkin:SetEquip(FSkinPartCode.Mount,self.CurShowModel)
        self.PlayerSkin:SetLocalScale(GameCenter.NatureSystem.NatureMountData:Get3DUICamerSize(self.CurShowModel))
        -- self.PlayerSkin:SetSkinPos(Vector3(0, GameCenter.NatureSystem.NatureMountData:GetModelYPosition(self.CurShowModel),0))
        self.PlayerSkin:Play("show", AnimationPartType.AllBody, WrapMode.Once,1)
        UIUtils.SetTextByString(self.ModelName, GameCenter.NatureSystem.NatureMountData.super:GetModelsName(self.CurShowModel))
    else
        Debug.LogError("!!!!!!!!!!!Model ID is 0")
    end
end

--Set the model toggle button status
function UIMountGrowUpForm:SetModelButton()
    local _isleft = GameCenter.NatureSystem.NatureMountData.super:GetNotLeftButton(self.CurShowModel)
    local _isright = GameCenter.NatureSystem.NatureMountData.super:GetNotRightButton(self.CurShowModel)
    self.LeftModelButton.gameObject:SetActive(_isleft)
    self.RightModelButton.gameObject:SetActive(_isright)
    local _modlDta = GameCenter.NatureSystem.NatureMountData.super:GetModelData(self.CurShowModel)
    if _modlDta then
        self.ShowModelButton.gameObject:SetActive(self.CurShowModel ~= GameCenter.NatureSystem.NatureMountData.super.CurModel and _modlDta.IsActive)
        self.ShowEdGo:SetActive(self.CurShowModel == GameCenter.NatureSystem.NatureMountData.super.CurModel)
        if not _modlDta.IsActive then
            UIUtils.SetColorByString(self.StageLab, "#EC4848")
            UIUtils.SetTextByEnum(self.StageLab, "C_UI_MOUNTUP_ACTIVENUM", _modlDta.Stage)
        else
            UIUtils.SetColorByString(self.StageLab, "#DDE5FA")
            UIUtils.SetTextByEnum(self.StageLab, "MOUNT_GROWUP_LAYER", GameCenter.NatureSystem.NatureMountData.Cfg.Steps)
        end
    end
    --Set whether the assist button is displayed
    local _isShowMountEquip = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.MountEquip)
    -- self.MountEquipBtn.gameObject:SetActive(_isShowMountEquip)
    local _isShowingRedPoint = GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.MountEquip)
    self.MountEquipRedPoint:SetActive(_isShowingRedPoint)
    self.LeftBtnsGrid.repositionNow = true
end

--Set properties
function UIMountGrowUpForm:SetAttr()
    local _attrlist = GameCenter.NatureSystem.NatureMountData.super.AttrList
    local _listobj = NGUITools.AddChilds(self.AttrGrid.gameObject,self.AttrClone,#_attrlist)
    for i = 1,#_attrlist do
        local _go = _listobj[i-1]
        local _info = _attrlist[i]
        local _up =  UIUtils.FindGo(_go.transform,"Sprite")
        local _value = UIUtils.FindLabel(_go.transform,"ValueLabel")
        local _addvalue =UIUtils.FindLabel(_go.transform,"Sprite/AddValueLabel")
        local _nameLab = UIUtils.FindLabel(_go.transform,"Label")
        if _info.AddAttr == 0 then
            _up:SetActive(false)
        else
            _up:SetActive(true)
        end
        UIUtils.SetTextByString(_value, BattlePropTools.GetBattleValueText(_info.AttrID,_info.Attr))
        UIUtils.SetTextByString(_addvalue, BattlePropTools.GetBattleValueText(_info.AttrID,_info.AddAttr))
        UIUtils.SetTextByString(_nameLab, BattlePropTools.GetBattlePropName(_info.AttrID) .. "：")
    end
    if self.IsInit then
        self.AttrGrid:Reposition()
        self.AttrScroll.repositionWaitFrameCount = 2
    end
end

--Set fruit eating information
function UIMountGrowUpForm:SetDrugInfo(vfxitem)
    local _druglist = GameCenter.NatureSystem.NatureMountData.super.DrugList
    for i=1, #_druglist do
        local _item = nil
        if #self.DrugItemList >= i then
            _item = self.DrugItemList[i]
        else
            _item = self.DrugClone:Clone()
            self.DrugItemList:Add(_item)
        end
        if _item then
            _item:SetInfo(_druglist[i], vfxitem, NatureEnum.Mount)
        end
    end
    if #_druglist > 0 and self.IsInit then
        self.DrugGrid:Reposition()
        self.DrugScrollView:ResetPosition()
    end
end

--Set prop display
function UIMountGrowUpForm:SetItem()
    local _itemlist = GameCenter.NatureSystem.NatureMountData.super.ItemList
    local _listobj = NGUITools.AddChilds(self.ItemGrid.gameObject,self.ItemClone,#_itemlist)
    self.CurSelectItemId = 0
    for i=1,#_itemlist do
        local _go = _listobj[i-1]
        local _info = _itemlist[i]
        local _item = UILuaItem:New(_go.transform)
        local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_info.ItemID)
        _item:InItWithCfgid(_info.ItemID, 1,true, true)
        _item:BindBagNum("%s")
        _item.IsShowTips = false
        self.ItemDicKeyGo[_go] = _item
        UIEventListener.Get(_go).parameter = _info
        UIEventListener.Get(_go).onClick = Utils.Handler( self.OnClickItemBtn,self)
        if _haveNum ~= 0 and self.CurSelectItemId == 0 then
            self:OnClickItemBtn(_go)
            _item.IsShowTips = true
        end
    end
    if #_itemlist > 0 and self.CurSelectItemId == 0 then
        local _item = self.ItemDicKeyGo[_listobj[0]]
        _item.IsShowTips = true
        self:OnClickItemBtn(_listobj[0])
    end
    self.ItemGrid:Reposition()
    self.ItemSelectTrs.gameObject:SetActive(#_itemlist > 1)
end

--Select props
function UIMountGrowUpForm:OnClickItemBtn(go)
    local _iteminfo = UIEventListener.Get(go).parameter
    local _item = self.ItemDicKeyGo[go]
    if self.CurSelectItemId == _iteminfo.ItemID then
        _item.IsShowTips = true
        _item:OnBtnItemClick()
        _item.IsShowTips = false
    else
        if self.ItemSelectTrs.gameObject.activeSelf then
            _item.IsShowTips = false
        else
            _item.IsShowTips = true
        end
        self.ItemSelectTrs.parent = go.transform
        UnityUtils.SetLocalPosition(self.ItemSelectTrs, 0, 0, 0)
        UnityUtils.SetLocalScale(self.ItemSelectTrs, 1, 1, 1)
        self.CurSelectItemId = _iteminfo.ItemID
        UIUtils.SetTextByEnum(self.ItemSelectNameLab, "NATURE_USEITEM_TIPS", _item.ShowItemData.Name,_iteminfo.ItemExp)
    end
end

--Set combat power
function UIMountGrowUpForm:SetFight(obj, sender)
    local _fight = GameCenter.NatureSystem.NatureMountData.super.Fight
    -- _fight = _fight + GameCenter.NatureSystem.NatureMountData.super:GetFashionAttrFight()
    UIUtils.SetTextByNumber(self.FightLab, _fight)
end

--Play special effects
function UIMountGrowUpForm:PlayerVfx(isbasevfx)
    if isbasevfx then
    else
        if self.Effect then
            self.Effect:Play()
        end
    end
end

--Network messages come and refresh the panel
function UIMountGrowUpForm:UpDateWingInfo()
    self.CurShowModel = GameCenter.NatureSystem.NatureMountData.super:GetCurShowModel()
    self:SetModel() --Refresh the model
    self:SetItem()
    self:RefreshLevelInfo()
    self:SetDrugInfo(0)
end

--Get the stars that need to play special effects
function UIMountGrowUpForm:GetStarTrs(star)
    return self.BaseStarGrid.transform:GetChild(star)
end

--Network message upgrade
-- function UIMountGrowUpForm:UpDateWingUPLEVEL(oldlevel,sender)
--     local _oldconfig = DataConfig.DataNatureHorse[oldlevel]
--     local _curconfig = DataConfig.DataNatureHorse[GameCenter.NatureSystem.NatureMountData.super.Level]
--     if _oldconfig.Steps < _curconfig.Steps then
--         local _vfx = UIUtils.RequireUIVfxSkinCompoent(self.LevelVfxTrs)
--         _vfx:OnCreateAndPlay(ModelTypeCode.UIVFX,17,LayerUtils.GetAresUILayer())
--     end
--     if _oldconfig.Star <  _curconfig.Star then
--         local _startrs = self:GetStarTrs(_curconfig.Star - 1)
--         local _starboomVfxTrs = UIUtils.FindTrans(_startrs,"UIVfxSkinCompoent")
--         local _vfxstarBoom = UIUtils.RequireUIVfxSkinCompoent(_starboomVfxTrs)
--         _vfxstarBoom:OnCreateAndPlay(ModelTypeCode.UIVFX,16,LayerUtils.GetAresUILayer())
--         self:RefreshLevelInfo()
--         self:PlayerVfx(false)
--     else
--         self:RefreshLevelInfo()
--         if oldlevel < GameCenter.NatureSystem.NatureMountData.super.Level then
--             self:PlayerVfx(false)
--         else
--             if self.AutoRemainTime and self.AutoRemainTime > 0 then
--                 self.AutoRemainTime = 0.075
--             end
--         end
--     end
    
-- end
--Network message upgrade
function UIMountGrowUpForm:UpDateWingUPLEVEL(oldlevel,sender)
    local _oldconfig = DataConfig.DataNatureHorse[oldlevel]
    local _curconfig = DataConfig.DataNatureHorse[GameCenter.NatureSystem.NatureMountData.super.Level]
    if _oldconfig.Steps < _curconfig.Steps then
        local _vfx = UIUtils.RequireUIVfxSkinCompoent(self.LevelVfxTrs)
        _vfx:OnCreateAndPlay(ModelTypeCode.UIVFX,17,LayerUtils.GetAresUILayer())
    end
    if _oldconfig.Star <  _curconfig.Star then
        -- local _startrs = self:GetStarTrs(_curconfig.Star - 1)
        local _startrs = self:GetStarTrs(_curconfig.Star - 1)
        local _spr = UIUtils.FindSpr(_startrs)
        if _spr then
            _spr.enabled = false  -- tắt vàng trước để effect bật lại
        end
        local _starboomVfxTrs = UIUtils.FindTrans(_startrs,"UIVfxSkinCompoent")
        local _vfxstarBoom = UIUtils.RequireUIVfxSkinCompoent(_starboomVfxTrs)
        _vfxstarBoom:OnCreateAndPlay(ModelTypeCode.UIVFX,16,LayerUtils.GetAresUILayer())
        self:RefreshLevelInfo()
        self:PlayerVfx(false)
    else
        self:RefreshLevelInfo()
        if oldlevel < GameCenter.NatureSystem.NatureMountData.super.Level then
            self:PlayerVfx(false)
        else
            if self.AutoRemainTime and self.AutoRemainTime > 0 then
                self.AutoRemainTime = 0.075
            end
        end
    end
    if _spr then
        _spr.enabled = true
    end
end
--Network message switching model
function UIMountGrowUpForm:UpDateChangeModel(type)
    if type == self.NatureType  then
        self.CurShowModel = GameCenter.NatureSystem.NatureMountData.super:GetCurShowModel()
        self:SetModel() --Refresh the model
        self:SetModelButton()
    end
end

--Network message update fruit information
function UIMountGrowUpForm:UpDateChangeDrug(msg)
    self:SetFight()
    self:SetDrugInfo(msg.druginfo.fruitId)
end

--Function refresh
function UIMountGrowUpForm:OnFuncUpdated(functioninfo, sender)
	local _funcID = functioninfo.ID
	if FunctionStartIdCode.MountDrug == _funcID then
		self:SetDrugInfo(0)
    end
    if FunctionStartIdCode.MountEquip == _funcID then
        local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.MountEquip)
        local _red = _funcInfo.IsShowRedPoint
        local _r = functioninfo.IsShowRedPoint
        self.MountEquipRedPoint:SetActive(_funcInfo.IsShowRedPoint)
    end
end

--Update special effects
function UIMountGrowUpForm:Update(dt)
    self.AnimPlayer:Update(dt)
    if self.Effect then
        self.Effect:Tick(dt)
    end
    if self.TimeTickerInfo then
        self.TimeTickerInfo:Update(dt)
    end
    if self.AutoRemainTime and self.AutoRemainTime > 0 then
        self.AutoRemainTime = self.AutoRemainTime - dt
        if GameCenter.NatureSystem.NatureMountData:IsMaxLevel() then
            UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
            self.AutoRemainTime = 0
            return
        end
        if self.AutoRemainTime <= 0 then
            if self:SendUpLevel(true) then
                self.AutoRemainTime = 0.4
            else
                UIUtils.SetTextByEnum(self.OneKeyBtnLabel, "C_UI_BTNLVAUTO")
            end
        end
    end
end

--Get prop updates
function UIMountGrowUpForm:UpDateItem(item,sender)
    local _druglist = GameCenter.NatureSystem.NatureMountData.super.DrugList
    local have = _druglist:Find(function(code)
        return code.ItemId == item;
    end)
    if have then
        self:SetDrugInfo(0)
    end
end

--Update the food equipment information
function UIMountGrowUpForm:UpDateEatEquip(oldlevel,sender)
    self:RefreshBaseLevelInfo()
    self:SetFight()
    if oldlevel < GameCenter.NatureSystem.NatureMountData.Level then
        self:PlayerVfx(true)
    end
end

------------------------------------------------

--Switch model button
function UIMountGrowUpForm:OnClickChangeModelBtn()
    self.Form = 1
    GameCenter.NatureSystem:ReqNatureModelSet(self.Form,self.CurSelectModel)
end
--Activate button
function UIMountGrowUpForm:OnClickActiveBtn()
    self.Form = 1
    local _fashioninfo = self.FashionBase:GetFashionInfo(self.CurSelectModel)
    local _isshow = _fashioninfo:GetRed() and _fashioninfo.Level < _fashioninfo.MaxLevel
    if _isshow then
        if self.Form == NatureEnum.FlySword then
            GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
                type = 1,
                huaxinID = self.CurSelectModel
            })
        else
        GameCenter.NatureSystem:ReqNatureFashionUpLevel(self.Form,self.CurSelectModel)
        end
    else
        local _itemDb = DataConfig.DataItem[_fashioninfo.Item]
        Utils.ShowPromptByEnum("Item_Not_Enough", _itemDb.Name)
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_fashioninfo.Item)
    end
end

function UIMountGrowUpForm:OnClickUpBtn()
    self.Form = 1
    local _fashioninfo = self.FashionBase:GetFashionInfo(self.CurSelectModel)
    if _fashioninfo.Level >= _fashioninfo.MaxLevel then
        Utils.ShowPromptByEnum("C_UI_MONSTEREQUIPSYN_STARMAX")
        return
    end
    local _isshow = _fashioninfo:GetRed() and _fashioninfo.Level < _fashioninfo.MaxLevel
    if _isshow then
        GameCenter.NatureSystem:ReqNatureFashionUpLevel(self.Form,self.CurSelectModel)
    else
        local _itemDb = DataConfig.DataItem[_fashioninfo.Item]
        Utils.ShowPromptByEnum("Item_Not_Enough", _itemDb.Name)
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_fashioninfo.Item)
    end
end



function UIMountGrowUpForm:InitLeftList()
    if self.FashionBase.FishionList then
        self.FashionIdList:Clear()
        self.DicGo:Clear()
        self.ItemFashionList:Clear()
        -- self.AnimPlayer:Stop()
        local _fiList = List:New()
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        for i = 1, #self.FashionBase.FishionList do
            local _info = self.FashionBase.FishionList[i]
            if _info.Occ == nil or (_info.Occ and _lp and _lp.IntOcc == _info.Occ) then
                _fiList:Add(_info)
            end
        end
        local _animList = List:New()
        local _index = 1
        local _listobj = NGUITools.AddChilds(self.LeftGrid.gameObject,self.LeftClone,#_fiList)
        self:OnClickLeftBtn(_listobj[0])
        local _fashionCount = #_fiList
        for i = 1, _fashionCount do
            local _go = _listobj[i - 1]
            local _info = _fiList[i]
            local _icon = UIUtils.RequireUIIconBase(_go.transform:Find("Icon"))
            local _name = UIUtils.FindLabel(_go.transform,"Name")
            local _bgname = UIUtils.FindLabel(_go.transform,"bg/bgName")
            UIUtils.SetTextByString(_name, _info.Name)
            UIUtils.SetTextByString(_bgname, _info.Name)
            _icon:UpdateIcon(_info.Icon)
            self:SetLeftInfo(_go,_info)
            self.FashionIdList:Add(_info.ModelId)
            self.DicGo:Add(_info.ModelId,_go)
            self.ItemFashionList:Add(_info.Item)
            if _info.ModelId == self.FashionBase.CurModel and _info.IsActive then
                self:SetEquipInfo(_go)
            end
            UIEventListener.Get(_go).parameter = _info.ModelId
            UIEventListener.Get(_go).onClick = Utils.Handler(self.OnClickLeftBtn,self)
            -- local _uitoggle = UIUtils.FindToggle(_go.transform)
            if i == 1 or _info.ModelId == self.OpenId or (_info:GetRed() and self.OpenId == nil) then
                -- _uitoggle:Set(true)
                self:OnClickLeftBtn(_go)
                _index = i
            else
                -- _uitoggle:Set(false)
            end
            _animList:Add(_go.transform)
        end
        self.OpenId = nil
        self.LeftGrid:Reposition()
        self.Scrollview:ResetPosition()

        -- local _startIndex = 1
        -- if _index > 5 then
        --     local _allSize = _fashionCount * 91 - 488.5
        --     local _curSize = (_index - 1) * 91
        --     self.ScrollProgress.value = _curSize / _allSize
        --     if _fashionCount - _index <= 5 then
        --         _startIndex = _fashionCount - 5
        --     else
        --         _startIndex = _index
        --     end
        -- end

        -- for i = 1, #_animList do
        --     self.CSForm:RemoveTransAnimation(_animList[i])
        --     self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.2, false, false)
        --     if i >= _startIndex then
        --         -- self.AnimPlayer:AddTrans(_animList[i], (i - _startIndex) * 0.1)
        --     else
        --         -- self.AnimPlayer:AddTrans(_animList[i], 0)
        --     end
        -- end
        -- self.AnimPlayer:AddTrans(self.ButtomTrans, 0.1)
        -- self.AnimPlayer:Play()
    end
end

function UIMountGrowUpForm:SetLeftInfo(go,info)
    local _hit = UIUtils.FindGo(go.transform,"UpSprite")
    _hit:SetActive(info:GetRed())
    local _stargrid = UIUtils.FindGrid(go.transform,"Grid")
    local _stargo = UIUtils.FindGo(go.transform,"Grid/Star")
    local _active = UIUtils.FindGo(go.transform,"NotActive")
    local _equip = UIUtils.FindGo(go.transform,"Equip")
    _equip:SetActive(self.FashionBase.CurModel == self.CurSelectModel)
    -- _equip:SetActive(false)
    _stargrid.gameObject:SetActive(true)
    if true then
        self:CloneFashionStar(_stargrid,_stargo,info.MaxLevel,info.Level, info.ModelId)
        if not self.ActiveModelDic then
            self.ActiveModelDic =  Dictionary:New()
        end
        if self.ActiveModelDic then
            if self.ActiveModelDic:ContainsKey(info.ModelId) then
                self.ActiveModelDic[info.ModelId] = info.Level
            else
                self.ActiveModelDic:Add(info.ModelId, info.Level)
            end
        end
    end
end

function UIMountGrowUpForm:CloneFashionStar(grid,clone,num,level,id)
    local _listobj = NGUITools.AddChilds(grid.gameObject,clone,num)
    if self.ActiveModelDic and self.ActiveModelDic:ContainsKey(id) and self.ActiveModelDic[id] < level then
        self.StarFashionVfx:Play(16, UIUtils.FindGo(_listobj[level - 1].transform, "Bg"))
    else
        for i=1,num do
            local _spr = UIUtils.FindGo(_listobj[i-1].transform, "Bg")
            _spr:SetActive(level >= i)
        end
    end
    grid:Reposition()
end

function UIMountGrowUpForm:SetEquipInfo(go)
    -- self.EquipTrs.parent = go.transform
    -- UnityUtils.SetLocalScale(self.EquipTrs, 1, 1, 1)
    -- UnityUtils.SetLocalPosition(self.EquipTrs, 77, 20, 0)
    local _EquipTemp = UIUtils.FindGo(go.transform,"Equip")
    _EquipTemp:SetActive(true)
end

function UIMountGrowUpForm:OnClickLeftBtn(go)
    local _modelId = UIEventListener.Get(go).parameter
    if self.CurSelectModel ~= _modelId then
        self.CurSelectModel = _modelId
        for k, v in pairs(self.DicGo) do
            local _go = UIUtils.FindGo(v.transform,"bg")
            _go:SetActive(k == self.CurSelectModel)
        end
        local _info = self.FashionBase:GetFashionInfo(self.CurSelectModel)
        if _info then
            if _info.IsActive or (not _info.IsActive and not _info.IsServerActive) then
                self.UpGo:SetActive(true)
            else
                self.UpGo:SetActive(false)
            end
            -- if _info.Cfg.ActiveDescribe and _info.IsServerActive and not _info.IsActive then
            --     UIUtils.SetTextByString(self.DescLabel, _info.Cfg.ActiveDescribe)
            -- else
            --     UIUtils.ClearText(self.DescLabel)
            -- end
            self:SetAttrList(_info)
            self:SetButton(_info)
            self:SetModelChangeButton(_info.IsActive)
            self:SetItemInfo(_info)
            self:SetFashionSlider(_info)
            self:SetFashionModel(_info.ModelId)
            self:SetSkill(_info)
        end
    end
end

function UIMountGrowUpForm:SetAttrList(info)
    local _attrlist = info.AttrList
    local _listobj = NGUITools.AddChilds(self.AttrFashionGrid.gameObject,self.AttrFashionClone,#_attrlist)
    for i = 1,#_attrlist do
        local _go = _listobj[i-1]
        local _info = _attrlist[i]
        local _up =  UIUtils.FindGo(_go.transform,"Sprite")
        local _value = UIUtils.FindLabel(_go.transform,"ValueLabel")
        local _addvalue =UIUtils.FindLabel(_go.transform,"Sprite/AddValueLabel")
        local _nameLab = UIUtils.FindLabel(_go.transform,"Label")
        if info.IsActive then
            if _info.AddAttr == 0 then
                _up:SetActive(false)
            else
                _up:SetActive(true)
            end
            UIUtils.SetTextByString(_value, BattlePropTools.GetBattleValueText(_info.AttrID,_info.Attr))
            UIUtils.SetTextByString(_addvalue, BattlePropTools.GetBattleValueText(_info.AttrID,_info.AddAttr))
            UIUtils.SetTextByString(_nameLab, BattlePropTools.GetBattlePropName(_info.AttrID))
        else
            _up:SetActive(false)
            UIUtils.SetTextByString(_value, BattlePropTools.GetBattleValueText(_info.AttrID,_info.Attr))
            UIUtils.SetTextByString(_nameLab, BattlePropTools.GetBattlePropName(_info.AttrID))
        end
    end
    self.AttrFashionGrid:Reposition()
end

function UIMountGrowUpForm:SetButton(info)
    local _isshow = info.Level < info.MaxLevel
    -- NGUITools.SetButtonGrayAndNotOnClick(self.ActiveButton.transform,not _isshow)
    -- NGUITools.SetButtonGrayAndNotOnClick(self.UpButton.transform,not _isshow)
    self.DisableUpButton.gameObject:SetActive(not _isshow)
    self.DisableUpButton.isEnabled = false
    self.ActiveButton.gameObject:SetActive(not info.IsActive)
    self.UpButton.gameObject:SetActive(info.IsActive)
    self.ActiveRed:SetActive(info:GetRed())
    self.UpRed:SetActive(info:GetRed())
end

--Set the toggle model button
function UIMountGrowUpForm:SetModelChangeButton(isactive)
    -- self:UpDateInfo()
    self.ChangeModelButton.gameObject:SetActive(isactive and self.FashionBase.CurModel ~= self.CurSelectModel)
    for k, v in pairs(self.DicGo) do
        if k == self.FashionBase.CurModel and isactive then
            self:SetEquipInfo(v)
            return
        end
    end
end

--Set prop display
function UIMountGrowUpForm:SetItemInfo(info)
    if info.Level >= info.MaxLevel then
        self.UpItem:InItWithCfgid(info.Item, 0,true, true)
        self.UpItem:CanelBindBagNum()
    else
        self.UpItem:InItWithCfgid(info.Item, info.NeedItemNum,true, true)
        self.UpItem:BindBagNum()
    end
end

--Set the progress bar
function UIMountGrowUpForm:SetFashionSlider(info)
    local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(info.Item)
    if self.BlessSlider then
        self.BlessSlider.value = info.Level >= info.MaxLevel and 1 or _haveNum / info.NeedItemNum
    end
    UIUtils.SetTextByString(self.BlessLab, info.Level >= info.MaxLevel and "" or string.format("%d/%d",_haveNum,info.NeedItemNum))
    UIUtils.SetTextByNumber(self.FightFashionLab, info.Fight)
    self.IsMaxLevelGo:SetActive(info.Level >= info.MaxLevel)
end

--Set the model wings
function UIMountGrowUpForm:SetFashionModel(model)
    if model ~= 0 then
        self.Skin.EnableDrag = true
        self.Skin:ResetSkin()
        self.Skin:SetEquip(FSkinPartCode.Mount,model)
        local x, y, z = GameCenter.NatureSystem.NatureMountData:GetModelRotation(model)
        self.Skin:SetEulerAngles(x, y, z)
        self.Skin:ResetRot()
        self.Skin:SetLocalScale(GameCenter.NatureSystem.NatureMountData:Get3DUICamerSize(model))
        self.Skin:SetPos(0,0,0)
        self.Skin:SetSkinPos(Vector3(0, GameCenter.NatureSystem.NatureMountData:GetModelYPosition(model),0))
    else
        Debug.LogError("!!!!!!!!!!!Model ID is 0")
    end
end

function UIMountGrowUpForm:SetSkill(info)
    if info.Cfg.PassiveSkill and info.Cfg.PassiveSkill > 0 then
        self.SkillID = info.Cfg.PassiveSkill
    else
        self.SkillID = 0
    end
    self.SkillGo:SetActive(self.SkillID > 0)
    local _cfg = DataConfig.DataSkill[self.SkillID]
    if _cfg then
        self.SkillIcon.spriteName = UIUtils.CSFormat("skill_{0}", _cfg.Icon)
        UIUtils.SetTextByString(self.SkillNameLabel, _cfg.Name)
    end
end

--Return the transformation information function
function UIMountGrowUpForm:UpDateFashion(model)
    if self.CurSelectModel == model then
        local _info = self.FashionBase:GetFashionInfo(model)
        if _info then
            self:SetItemInfo(_info)
            self:SetModelChangeButton(_info.IsActive)
            self:SetAttrList(_info)
            self:SetButton(_info)
            self:SetFashionSlider(_info)
            self:SetSkill(_info)
            local _go = self.DicGo[model]
            if _go then
               self:SetLeftInfo(_go,_info)
            end
        end
    end
end

--Props Update
function UIMountGrowUpForm:UpDateRedEvent(item,sender)
    if self.ItemFashionList:Contains(item) then
        local _fashioninfo = self.FashionBase:GetFashionInfo(self.CurSelectModel)
        self:SetButton(_fashioninfo)
        self:SetItemInfo(_fashioninfo)
        for k, v in pairs(self.DicGo) do
            local _info = self.FashionBase:GetFashionInfo(k)
            self:SetLeftInfo(v,_info)
        end
    end
end

--Return to switch model
function UIMountGrowUpForm:UpDateChangeFashionModel(type)
     if type == self.Form then
        self:SetModelChangeButton(true)
        local _info = self.FashionBase:GetFashionInfo(self.CurSelectModel)
        if _info then
            self:SetButton(_info)
        end
     end
end

function UIMountGrowUpForm:LoadFashionTextures()
    -- self.CSForm:LoadTexture(self.BackTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_2"))
    self.CSForm:LoadTexture(self.ModelTexture,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine"))
end
------------------------------------------------

return UIMountGrowUpForm
