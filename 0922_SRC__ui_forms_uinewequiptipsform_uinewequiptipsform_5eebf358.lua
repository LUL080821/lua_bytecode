------------------------------------------------
--author:
--Date: 2019-04-22
--File: UINewEquipTipsForm.lua
--Module: UINewEquipTipsForm
--Description: Equipment Tips
------------------------------------------------

local UIItemQuickGetFunc = require "UI.Forms.UIItemQuickGetForm.UIItemQuickGetFunc"
local UICompContainer = require("UI.Components.UICompContainer")
local DescAttrInfo = require("UI.Forms.UINewEquipTipsForm.DescAttrInfo")
local L_GemInlayInfo = require("UI.Forms.UINewEquipTipsForm.DescGemInlayInfo")
local UIAttComponent = require("UI.Forms.UINewEquipTipsForm.UIAttributeComponent")
local L_UIGemInlayComponent = require("UI.Forms.UINewEquipTipsForm.UIGemInlayComponent")
local ItemContianerSystem = CS.Thousandto.Code.Logic.ItemContianerSystem
local Equipment = CS.Thousandto.Code.Logic.Equipment
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UINewEquipTipsForm = {
    SpriteBlank= nil,
    -- Equipment name --Label
    EquipNameLabel           = nil,
    DressEquipNameLabel      = nil,
    -- Equipment icon --UIItem
    EquipIconItem            = nil,
    DressEquipIconItem       = nil,
    -- Equipment location --Label
    EquipType                = nil,
    DressEquipType           = nil,
    --Equipment combat power
    PowerLabel               = nil,
    DressPowerLabel          = nil,
    -- Career requirements
    EquipOccLabel            = nil,
    DressEquipOccLabel       = nil,
    -- Level requirements
    EquipLevelLabel          = nil,
    DressEquipLevelLabel     = nil,

    --Background Changes according to equipment quality
    QualityBack              = nil,
    QualityFront             = nil,
    DressQualityBack         = nil,
    DressQualityFront        = nil,

    --The prompt is already loaded, and it needs to be displayed when opening the equipment on your body
    DressTipsGo              = nil,

    -- ScrollView
    AttributeScrollView      = nil,
    -- Layout Control Table
    AttributeTable           = nil,
    DressAttTable            = nil,

    --Basic attributes
    BaseAttContainer         = nil,
    BaseAttGrid              = nil,
    DressBaseAttContainer    = nil,
    DressBaseAttGrid         = nil,

    --Special properties
    SpecialAttContainer      = nil,
    SpecialAttGrid           = nil,
    DressSpecialAttContainer = nil,
    DressSpecialAttGrid      = nil,

    --Gem Inlay
    DressGemInlayContainer   = nil,
    DressGemInlayGrid        = nil,

    --Compare interface basic information parent node
    DressBaseGo              = nil,
    --Save TIPS source
    FromObj                  = nil,

    --Operation button dictionary
    ButtonDic                = Dictionary:New(),
    ButtonTable              = nil,

    --Warehouse points
    DonateNumLabel           = nil,
    --Warehouse Points ICON
    CoinIcon                 = nil,

    -- Set comparison information
    SuitGo                   = nil,
    SuitName                 = nil,
    SuitPropDesc             = nil,
    DressSuitGo              = nil,
    DressSuitName            = nil,
    DressSuitProDesc         = nil,

    EquipmentData            = nil,
    DressEquipData           = nil,
    Location                 = ItemTipsLocation.Defult,

    --The maximum number of listed trading banks
    MarketMaxCount           = 8,

    VfxLoadWaitFrame         = 0,
    _identifyQualityCache = nil,
    hideTableButtonOtherPlayer = false -- thêm để kiểm tra lúc xem thiết bị của người khác
}
--Inherit the Form function
function UINewEquipTipsForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIEQUIPTIPSFORM_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIEQUIPTIPSFORM_CLOSE, self.OnClose)
end

function UINewEquipTipsForm:OnFirstShow()
    self:FindAllComponents()
    self.CSForm:AddNormalAnimation(0.3)
end

function UINewEquipTipsForm:OnHideBefore()
    self.Location = ItemTipsLocation.Defult
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_BACKFORM_ITEM_UNSELCT)
    self:RemoveCameraClickEvent()
    self.QualityVfx:OnDestory()
    self.DressQualityVfx:OnDestory()
    self.BackVfx:OnDestory()
    self.DressBackVfx:OnDestory()
end
function UINewEquipTipsForm:OnLoad()
end
function UINewEquipTipsForm:OnShowAfter()
    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.TopRegion
    self:AddCameraClickEvent()
    self.IsRePosition = false
    self:UpdateBtn()
    if self.EquipmentData ~= nil
            and (self.Location == ItemTipsLocation.Bag
            or self.Location == ItemTipsLocation.Defult
            or self.Location == ItemTipsLocation.OutGuildStore) then
        self.DressEquipData = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.EquipmentData.Part)
    end
    self:UpdateForm()
    self:OnSetPosition()
    self.VfxLoadWaitFrame = 2

    -- custom
    local opt = "1_60037_1_0_1_2;2_60037_1_0_1_2;1_60038_1_3_4_5;1_60039_1_6_7_8;1_60040_1_9_10_11_12;1_60041_1_0_1_2;1_60042_1_3_4_5;1_60043_1_6_7_8;1_60044_1_9_10_11_12"

    if(GameCenter.LianQiForgeSystem:AppraiseSetting()) then
        opt = GameCenter.LianQiForgeSystem:AppraiseSetting()
    end

    self.EquipSpecial = self:ParseSpecialOption(opt)

    --- xác định thỏa mãn để show nút
    local charmStatus = self:CheckCharmValidAll(self.EquipSpecial)

    -- Dựa vào charmStatus để hiển thị nút
    if charmStatus[1] and charmStatus[2] then
        self:SetVerifyButtonsVisible(true, false, true, "Both")
    elseif charmStatus[1] then
        self:SetVerifyButtonsVisible(true, false, true, "VerifyBtn")
    elseif charmStatus[2] then
        self:SetVerifyButtonsVisible(true, false, true, "AdvancedBtn")
    else
        self:SetVerifyButtonsVisible(false, false, false)
    end

    -- kiểm tra them
    if self.Location == ItemTipsLocation.Equip or self.Location == ItemTipsLocation.LingTi then
        if GameCenter.LianQiForgeSystem:HasAppraiseInfoByPart(self.EquipmentData.Part) then

            local btnApp = self.ButtonDic[EquipButtonType.Appraise]
            if btnApp then btnApp.gameObject:SetActive(false) end

            local btnAdv = self.ButtonDic[EquipButtonType.AdvancedAppraise]
            if btnAdv then btnAdv.gameObject:SetActive(false) end

        end
    end

    -- thực hiện check và ẩn hiện list nút
    self:EnableTableButton()


    print("==================self.EquipmentData.DBIDself.EquipmentData.DBIDself.EquipmentData.DBID===", self.EquipmentData.DBID)

end


function UINewEquipTipsForm:ParseIdentifyOpenQualities(cfgStr)
    local result = {}

    if not cfgStr or cfgStr == "" then
        return result
    end

    for part in string.gmatch(cfgStr, "[^;]+") do
        local k, v = string.match(part, "(%d+)%_(%d+)")
        local key = tonumber(k)
        local val = tonumber(v)

        if key and val and val >= 1 then
            table.insert(result, key)
        end
    end

    return result
end

function UINewEquipTipsForm:IsQualityCanIdentify(quality, cfgStr)
    if not quality then
        return false
    end

    local list = self:ParseIdentifyOpenQualities(cfgStr)

    for _, v in ipairs(list) do
        if v == quality then
            return true
        end
    end

    return false
end



--Register camera click event
function UINewEquipTipsForm:AddCameraClickEvent()
    LuaDelegateManager.Add(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end

--Delete the camera click event
function UINewEquipTipsForm:RemoveCameraClickEvent()
    LuaDelegateManager.Remove(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end

function UINewEquipTipsForm:OnUICameraEventListener(curObj)
    if curObj ~= nil then
        if not self:IsUIInMyUI(curObj) then
            self:OnClose()
        end
    end
end
function UINewEquipTipsForm:IsUIInMyUI(go)
    if go == nil then
        return false
    end
    if go == self.GO then
        return true
    end
    if (CS.Thousandto.Core.Base.UnityUtils.CheckChild(self.Trans, go.transform)) then
        return true
    end
    return false
end

function UINewEquipTipsForm:Update(dt)
    if self.IsRePosition then
        self.TimeCount = self.TimeCount + 1
        -- self.AttributeTable.repositionWaitFrameCount = 4
        -- self.DressAttTable.repositionWaitFrameCount = 4
        if self.TimeCount == 3 then
            self.AttributeTable.repositionNow = true
            self.DressAttTable.repositionNow = true
        elseif self.TimeCount == 5 then
            self.IsRePosition = false
            self.AttributeScrollView:ResetPosition()
            self.DressScroll:ResetPosition()
        end
    end

    if self.VfxLoadWaitFrame > 0 then
        self.VfxLoadWaitFrame = self.VfxLoadWaitFrame - 1
        if self.VfxLoadWaitFrame <= 0 then
            self:LoadVfx()
        end
    end
    self.AnimPlayer:Update(dt)
end

-- hàm thực hiện ẩn/ hiện list button
function UINewEquipTipsForm:EnableTableButton()
    -- local _myTrans = self.Trans
    -- local buttons = UIUtils.FindGo(_myTrans, "Right/Container/Bottom/MoreGrop/Table")
    -- if(buttons) then
    --     buttons:SetActive(not self.hideTableButtonOtherPlayer)
    -- end

    local _myTrans = self.Trans
    local buttons = UIUtils.FindGo(_myTrans, "Right/Container/Bottom/MoreGrop/Table")
    if not buttons then
        return
    end

    local isMyItem = self:IsMyItem()
    buttons:SetActive(isMyItem)
end


--Open event
function UINewEquipTipsForm:OnOpen(obj, sender)
    local itemSelect = obj
    if nil ~= itemSelect then
        if itemSelect.ShowGoods ~= nil then
            self.EquipmentData = itemSelect.ShowGoods
            self.Location = itemSelect.Locatioin
            self.FromObj = itemSelect.SelectObj
            self.isShowGetBtn = itemSelect.isShowGetBtn
            self.PreData = itemSelect

            -- Gosu bổ sung để check tham số call view vật phẩm của người chơi khác thì ẩn các nút chứ năng
            local ext = itemSelect.ExtData

            if ext then
                if ext.FromEquipRoot then
                    -- Debug.Log("[EquipTips] Opened from EquipRoot")
                    self.hideTableButtonOtherPlayer = true
                end
                if ext.From then
                    -- Debug.Log("[EquipTips] From =", ext.From)
                end
            else
                self.hideTableButtonOtherPlayer = false
            end

            -- End

            self.CSForm:Show(sender)
        else
            self:OnClose()
        end
    else
        self:OnClose()
    end
end

--Find all controls
function UINewEquipTipsForm:FindAllComponents()
    local _myTrans = self.Trans
    self.SpriteBlank = UIUtils.FindBtn(_myTrans, "Sprite")
    UIUtils.AddBtnEvent(self.SpriteBlank, self.OnCloseBtnClick, self)
    self.QualityVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Right/Container/TipsTop/UIVfxSkinCompoent"))
    self.DressQualityVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/TipsTop/DressUIVfxSkinCom"))
    self.BackVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Right/Container/UIVfxSkinCompoent"))
    self.DressBackVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/BackVfx"))
    self.PosTrans = UIUtils.FindTrans(_myTrans, "Right")
    self.GetPanelGo = UIUtils.FindGo(_myTrans, "Right/Container/GetForm")
    self.GetScrollView = UIUtils.FindScrollView(self.Trans, "Right/Container/GetForm/Scroll")
    self.GetGrid = UIUtils.FindGrid(self.Trans, "Right/Container/GetForm/Scroll/Grid")
    self.GetGridTrans = self.GetGrid.transform
    self.FuncItemRes = nil
    self.FuncItemList = List:New()
    for i = 0, self.GetGridTrans.childCount - 1 do
        local _go = self.GetGridTrans:GetChild(i).gameObject
        if self.FuncItemRes == nil then
            self.FuncItemRes = _go
        end
        self.FuncItemList:Add(UIItemQuickGetFunc:New(_go, self))
    end
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
    self.DressTipsGo = UIUtils.FindGo(_myTrans, "Right/Container/Bottom/Dress")
    self.EquipNameLabel = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/EquipName")
    self.DressEquipNameLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/Head/EquipName")

    -- [Gosu] thêm label cấp cường hóa
    self.StrengLevelLabel = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/Intensify")
    self.DressStrengLevelLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/Intensify")

    self.EquipIconItem = UILuaItem:New(_myTrans:Find("Right/Container/TipsTop/Item"))
    self.DressEquipIconItem = UILuaItem:New(_myTrans:Find("Right/Container/Comparison/TipsTop/Item"))
    self.EquipType = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/Head/EquipType")
    self.DressEquipType = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/EquipType")
    self.PowerLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Bottom/Power/Label")
    self.DressPowerLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/Bottom/Power/Label")
    self.StateVipLabel = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/Head/StateVip/Label")
    self.DressStateVipLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/StateVip/Label")
    self.ChangejobLabel = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/Head/ChangeJob/Label")
    self.DressChangejobLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/ChangeJob/Label")
    self.EquipDescLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Bottom/Desc")
    self.DressEquipDescLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/Bottom/Desc")
    self.EquipOccLabel = UIUtils.FindLabel(_myTrans, "Right/Container/TipsTop/Head/EquipOcc")
    self.DressEquipOccLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/TipsTop/EquipOcc")
    self.EquipLevelLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Bottom/EquipLevel")
    self.DressEquipLevelLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/Bottom/EquipLevel")
    self.AttributeScrollView = UIUtils.FindScrollView(_myTrans, "Right/Container/Middle/Panel")
    self.AttributeTable = UIUtils.FindTable(_myTrans, "Right/Container/Middle/Panel/Table")
    self.DressAttTable = UIUtils.FindTable(_myTrans, "Right/Container/Comparison/Panel/Table")
    self.BaseAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/1_ZAttribute")
    self.DressBaseAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/1_ZAttribute")
    self.SpecialAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/10_ZAttribute")
    self.SpecialAttTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/10_Title")
    self.GodAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/0_ZAttribute")
    self.GodAttTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/0_Title")
    self.AppraiseAttrGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/11_ZAttribute")
    self.AppraiseAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/11_Title")
    self.WashAttrGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/12_ZAttribute")
    self.WashAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/12_Title")
    self.GemInlayGrid = UIUtils.FindTable(_myTrans, "Right/Container/Middle/Panel/Table/2_ZAttribute")
    self.GemInlayTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/2_Title")
    self.GemRefineGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Middle/Panel/Table/3_ZAttribute")
    self.GemRefineTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/3_Title")
    self.JadeInlayGrid = UIUtils.FindTable(_myTrans, "Right/Container/Middle/Panel/Table/4_ZAttribute")
    self.JadeInlayTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/4_Title")
    self.DressSpecialAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/10_ZAttribute")
    self.DressSpecialAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/10_Title")
    self.DressGodAttGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/0_ZAttribute")
    self.DressGodAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/0_Title")
    self.DressAppraiseAttrGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/11_ZAttribute")
    self.DressAppraiseAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/11_Title")
    self.DressWashAttrGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/12_ZAttribute")
    self.DressWashAttrTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/12_Title")
    self.DressGemInlayGrid = UIUtils.FindTable(_myTrans, "Right/Container/Comparison/Panel/Table/2_ZAttribute")
    self.DressGemInlayTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/2_Title")
    self.DressGemRefineGrid = UIUtils.FindGrid(_myTrans, "Right/Container/Comparison/Panel/Table/3_ZAttribute")
    self.DressGemRefineTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/3_Title")
    self.DressJadeInlayGrid = UIUtils.FindTable(_myTrans, "Right/Container/Comparison/Panel/Table/4_ZAttribute")
    self.DressJadeInlayTitleGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/4_Title")
    self.DressBaseGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison")
    self.DressScroll = UIUtils.FindScrollView(_myTrans, "Right/Container/Comparison/Panel")
    self.QualityBack = UIUtils.FindSpr(_myTrans, "Right/Container/Backgroup/bg")
    self.DressQualityBack = UIUtils.FindSpr(_myTrans, "Right/Container/Comparison/Backgroup/bg")
    self.SuitGo = UIUtils.FindGo(_myTrans, "Right/Container/Middle/Panel/Table/5_SuitPro")
    self.SuitName = UIUtils.FindLabel(_myTrans, "Right/Container/Middle/Panel/Table/5_SuitPro/Name")
    self.SuitPropDesc = UIUtils.FindLabel(_myTrans, "Right/Container/Middle/Panel/Table/5_SuitPro/ProDesc")
    self.DressSuitGo = UIUtils.FindGo(_myTrans, "Right/Container/Comparison/Panel/Table/5_SuitPro")
    self.DressSuitName = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/Panel/Table/5_SuitPro/Name")
    self.DressSuitProDesc = UIUtils.FindLabel(_myTrans, "Right/Container/Comparison/Panel/Table/5_SuitPro/ProDesc")
    self.DonateNumLabel = UIUtils.FindLabel(_myTrans, "Right/Container/Bottom/DonateNum")
    self.ButtonTable = UIUtils.FindTable(_myTrans, "Right/Container/Bottom/MoreGrop/Table")
    self.CoinIcon = UIUtils.RequireUIIconBase(_myTrans:Find("Right/Container/Bottom/DonateNum/Icon"))
    self.CoinIcon:UpdateIcon(LuaItemBase.GetItemIcon(1))
    local _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/1_ZAttribute")
    local _cnt = _tmpTrans.childCount
    local _c = UICompContainer:New()
    self.BaseAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/1_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressBaseAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/10_ZAttribute")
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.SpecialAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/0_ZAttribute")
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.GodAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/10_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressSpecialAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/0_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressGodAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/11_ZAttribute")
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.AppraiseAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/11_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressAppraiseAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/12_ZAttribute")
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.WashAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/12_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressWashAttContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()

    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/2_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.GemInlayContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = L_UIGemInlayComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/2_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressGemInlayContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = L_UIGemInlayComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/3_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.GemRefineContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/3_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressGemRefineContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = UIAttComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Middle/Panel/Table/4_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.JadeInlayContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = L_UIGemInlayComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    _tmpTrans = UIUtils.FindTrans(_myTrans, "Right/Container/Comparison/Panel/Table/4_ZAttribute");
    _cnt = _tmpTrans.childCount
    _c = UICompContainer:New()
    self.DressJadeInlayContainer = _c
    for i = 0, _cnt - 1 do
        local _btn = L_UIGemInlayComponent:New(_tmpTrans:GetChild(i))
        _c:AddNewComponent(_btn)
    end
    _c:SetTemplate()
    -- local button = UIUtils.FindBtn(_myTrans, "Container")
    -- UIUtils.AddBtnEvent(button, self.OnClose, self)
    local button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/EquipBtn")
    UIUtils.AddBtnEvent(button, self.OnClickEquipBtn, self)
    self.ButtonDic:Add(EquipButtonType.Equiped, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/SellBtn")
    UIUtils.AddBtnEvent(button, self.OnClickSellBtn, self)
    self.ButtonDic:Add(EquipButtonType.Sell, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/MarketBtn")
    UIUtils.AddBtnEvent(button, self.OnClickMarketUpBtn, self)
    self.ButtonDic:Add(EquipButtonType.MarketUp, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/PutBtn")
    UIUtils.AddBtnEvent(button, self.OnClickPutBtn, self)
    self.ButtonDic:Add(EquipButtonType.PutStorage, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/QuChuBtn")
    UIUtils.AddBtnEvent(button, self.OnClickQuchuBtn, self)
    self.ButtonDic:Add(EquipButtonType.QuChu, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/DonateBtn")
    UIUtils.AddBtnEvent(button, self.OnClickDonateBtn, self)
    self.ButtonDic:Add(EquipButtonType.GuildStore, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/DestoryBtn")
    UIUtils.AddBtnEvent(button, self.OnClickDestoryBtn, self)
    self.ButtonDic:Add(EquipButtonType.Destory, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/SplitBtn")
    UIUtils.AddBtnEvent(button, self.OnClickSplitBtn, self)
    self.ButtonDic:Add(EquipButtonType.Split, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/GetBtn")
    UIUtils.AddBtnEvent(button, self.OnClickGetBtn, self)
    self.ButtonDic:Add(EquipButtonType.Get, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/SynthBtn")
    UIUtils.AddBtnEvent(button, self.OnClickSynthBtn, self)
    self.ButtonDic:Add(EquipButtonType.Synth, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/GodStarBtn")
    UIUtils.AddBtnEvent(button, self.OnClickGodStarBtn, self)
    self.ButtonDic:Add(EquipButtonType.GodStar, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/GodLvBtn")
    UIUtils.AddBtnEvent(button, self.OnClickGodLvUpBtn, self)
    self.ButtonDic:Add(EquipButtonType.GodLv, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/VerifyBtn")
    -- TODO(A.DUC): binding event
    UIUtils.AddBtnEvent(button, self.OnClickAppraisalBtn, self)
    self.ButtonDic:Add(EquipButtonType.Appraise, button)
    button = UIUtils.FindBtn(_myTrans, "Right/Container/Bottom/MoreGrop/Table/VerifyAdvancedBtn")
    -- TODO(A.DUC): binding event
    UIUtils.AddBtnEvent(button, self.OnClickAdvancedAppraisalBtn, self)
    self.ButtonDic:Add(EquipButtonType.AdvancedAppraise, button)

    local _glConfig = DataConfig.DataGlobal[GlobalName.Trade_maxitem]
    if _glConfig then
        self.MarketMaxCount = tonumber(_glConfig.Params)
    end



end

-- Custom 

function UINewEquipTipsForm:OnCloseBtnClick()
    self.CSForm:Hide()
end
--- Hiển thị nút khảm dựa theo trạng thái và loại nút mong muốn
-- @param canInlay  (bool) Có thể khảm không
-- @param hasInlaid (bool) Đã khảm rồi chưa
-- @param hasCharm  (bool) Có đủ bùa chưa
-- @param showType  (string|number) "VerifyBtn", "AdvancedBtn", "Both" hoặc 1/2/0 tương ứng
function UINewEquipTipsForm:SetVerifyButtonsVisible(canInlay, hasInlaid, hasCharm, showType)
    local verifyBtn = self.ButtonDic[EquipButtonType.Appraise]
    local advancedBtn = self.ButtonDic[EquipButtonType.AdvancedAppraise]

    -- reset: ẩn hết trước
    if verifyBtn then verifyBtn.gameObject:SetActive(false) end
    if advancedBtn then advancedBtn.gameObject:SetActive(false) end

    -- Nếu đã khảm hoặc không đủ điều kiện thì không hiển thị gì
    if hasInlaid or not canInlay or not hasCharm then
        return
    end

    -- Chuẩn hoá kiểu hiển thị
    local t = type(showType)
    local mode
    if t == "string" then
        showType = showType:lower()
        if showType == "verifybtn" then
            mode = 1
        elseif showType == "advancedbtn" then
            mode = 2
        else
            mode = 0 -- "both"
        end
    elseif t == "number" then
        mode = showType
    else
        mode = 0
    end

    -- Hiển thị theo mode
    if mode == 1 then
        if verifyBtn then verifyBtn.gameObject:SetActive(true) end
    elseif mode == 2 then
        if advancedBtn then advancedBtn.gameObject:SetActive(true) end
    else
        if verifyBtn then verifyBtn.gameObject:SetActive(true) end
        if advancedBtn then advancedBtn.gameObject:SetActive(true) end
    end
end


function UINewEquipTipsForm:ParseSpecialOption(optionStr)
    local result = {
        [1] = {}, -- loại 1: giám định thường
        [2] = {}, -- loại 2: giám định cao cấp
    }

    if not optionStr or optionStr == "" then
        return result
    end

    for part in string.gmatch(optionStr, "[^;]+") do
        -- tách toàn bộ thành bảng nhỏ
        local tokens = {}
        for token in string.gmatch(part, "[^_]+") do
            table.insert(tokens, token)
        end

        local t = tonumber(tokens[1])
        local id = tonumber(tokens[2])
        local num = tonumber(tokens[3])

        if t and id and num then
            local parts = {}
            for i = 4, #tokens do
                table.insert(parts, tonumber(tokens[i]))
            end

            table.insert(result[t], {
                id = id,
                count = num,
                parts = parts -- slot hợp lệ
            })
        end
    end

    -- print("[CharmDebug] Parsed special option:", Inspect(result))
    return result
end



--- Kiểm tra toàn bộ loại ngọc (1 & 2) xem user có bùa hợp lệ không
-- Nếu item đã có thuộc tính đặc biệt (đã giám định) thì ẩn toàn bộ nút
-- @param parsed: dữ liệu cấu hình ngọc khảm
-- @return table: { [1]=true/false, [2]=true/false, anyValid=false }
function UINewEquipTipsForm:CheckCharmValidAll(parsed)
    local result = {
        [1] = false,
        [2] = false,
        anyValid = false
    }

    -- Kiểm tra trạng thái đã giám định hoặc phẩm chất thấp
    local attDic = self.EquipmentData:GetSpecialAttribute()
    local attCount = attDic and attDic.Count or 0
    local quality = self.EquipmentData.ItemInfo and self.EquipmentData.ItemInfo.Quality or 0
    local part = self.EquipmentData.ItemInfo and self.EquipmentData.ItemInfo.Part or -1

    if attCount > 0 then
        -- print((" [CharmDebug] Item đã giám định (%d thuộc tính đặc biệt) → ẩn toàn bộ nút."):format(attCount))
        return result
    end

    -- if quality <= 3 then
    --     -- print((" [CharmDebug] Item phẩm chất thấp (Quality=%d ≤ 3) → không cho giám định."):format(quality))
    --     return result
    -- end

   local cfgStr = GameCenter.LianQiForgeSystem:AppraiseButtonSetting()

    if not self:IsQualityCanIdentify(quality, cfgStr) then
        -- print((" [CharmDebug] Quality=%d không nằm trong danh sách cho phép giám định"):format(quality))
        return result
    end
    local _dic = GameCenter.LianQiForgeBagSystem:GetAllAppraiseAttrDicByItemId(self.EquipmentData.DBID) -- lấy thử xem thử đã giám định chưa

    if _dic and _dic.Count and _dic:Count() > 0 then
        return result
    end

    -- print(("[CharmDebug] Kiểm tra giám định cho Part=%d..."):format(part))

    --  2️ Kiểm tra bùa hợp lệ theo loại và slot
    for gemType = 1, 2 do
        local list = parsed[gemType]
        if list and #list > 0 then
            for _, v in ipairs(list) do
                -- kiểm tra slot hợp lệ
                local canUse = false
                if v.parts and #v.parts > 0 then
                    for _, p in ipairs(v.parts) do
                        if p == part then
                            canUse = true
                            break
                        end
                    end
                end

                if canUse then
                    local have = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(v.id)
                    if have >= v.count then
                        result[gemType] = true
                        -- print(("[CharmDebug] Part=%d hợp lệ với bùa id=%d (cần=%d, có=%d) loại=%d"):format(part, v.id, v.count, have, gemType))
                        break
                    else
                        -- print(("[CharmDebug] Part=%d hợp lệ nhưng thiếu bùa id=%d (cần=%d, có=%d) loại=%d"):format( part, v.id, v.count, have, gemType))
                    end
                else
                    -- print(("[CharmDebug] Bỏ qua bùa id=%d vì part=%d không nằm trong %s"):format(v.id, part, table.concat(v.parts, ",")))
                end
            end
        end
    end

    result.anyValid = result[1] or result[2]
    return result
end


-- End custom

--Equipment Button
function UINewEquipTipsForm:OnClickEquipBtn()
    if self.Location == ItemTipsLocation.Market then
        if GameCenter.ShopAuctionSystem.MarketOwnInfoDic:Count() >= self.MarketMaxCount then
            Utils.ShowPromptByEnum("C_UI_TIPS_AUCTIONMAX", self.MarketMaxCount)
        else
            local _data = {}
            _data.Data = self.EquipmentData
            _data.PanelType = ShopAuctionPutType.PutIn
            GameCenter.PushFixEvent(UIEventDefine.UIShopAuctionShelvesForm_OPEN, _data)
        end
    else
        if self.EquipmentData.ContainerType == ContainerType.ITEM_LOCATION_EQUIP then
            GameCenter.NewEquipmentSystem:RequestEquipUnWear(self.EquipmentData.DBID)
        else
            GameCenter.NewEquipmentSystem:RequestEquipWear(self.EquipmentData)
        end
    end
    self:OnClose()
end
--Sale Button
function UINewEquipTipsForm:OnClickSellBtn()
    if self.EquipmentData.ItemInfo.Price1 and string.len(self.EquipmentData.ItemInfo.Price1) > 0 then
        GameCenter.PushFixEvent(UIEventDefine.UIEquipSellForm_Open, self.EquipmentData)
    else
        local list = List:New()
        list:Add(self.EquipmentData.DBID)
        if self.EquipmentData.ItemInfo.Confirm == 1 then
            self:RemoveCameraClickEvent()
            Utils.ShowMsgBoxAndBtn(function(x)
                if x == MsgBoxResultCode.Button2 then
                    GameCenter.NewEquipmentSystem:ReqEqipSell(list)
                end
            end, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", "C_UI_EQUIP_EQUIPTIPS_SELLCOMFIRM", Utils.GetQualityStrColor(self.EquipmentData.Quality), self.EquipmentData.Name)
        else
            GameCenter.NewEquipmentSystem:ReqEqipSell(list)
        end
    end
    self:OnClose()
end
--Set on the shelves/stand for sale button click
function UINewEquipTipsForm:OnClickMarketUpBtn()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.AuchtionSell, self.EquipmentData.DBID)
    self:OnClose()
end
--Put in and release button
function UINewEquipTipsForm:OnClickPutBtn()
    if self.Location == ItemTipsLocation.PutInStorage then
        ItemContianerSystem.RequestToStore(self.EquipmentData.Index)
    elseif self.Location == ItemTipsLocation.OutStorage then
        ItemContianerSystem.RequestToBag(self.EquipmentData.Index)
    else
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_UI_EQUIPSELECT_UPDATE, self.EquipmentData)
    end
    self:OnClose()
end
--Taoku Treasure House Take out
function UINewEquipTipsForm:OnClickQuchuBtn()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_APOCALYPASEQUCHU)
    self:OnClose()
end
--The guild warehouse donates equipment
function UINewEquipTipsForm:OnClickDonateBtn()
    local list = List:New()
    list:Add(self.EquipmentData.DBID)

    -- //Donate
    if self.Location == ItemTipsLocation.PutinGuildStore then
        GameCenter.GuildRepertorySystem:ReqSubmitEquip(list)
    elseif self.Location == ItemTipsLocation.OutGuildStore then
        GameCenter.GuildRepertorySystem:ReqChangeEquip(list)
    end
end
-- Guild Warehouse Destruction Button
function UINewEquipTipsForm:OnClickDestoryBtn()
    local list = List:New()
    list:Add(self.EquipmentData.DBID)
    GameCenter.GuildRepertorySystem:ReqDestroyEquip(list)
end

-- Equipment disassembly, mainly used for magical equipment
function UINewEquipTipsForm:OnClickSplitBtn()
    GameCenter.PushFixEvent(UILuaEventDefine.UIEquipSplitForm_OPEN, self.EquipmentData)
    self:OnClose()
end

--Access
function UINewEquipTipsForm:OnClickGetBtn()
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.EquipmentData.CfgID)
end

--synthesis
function UINewEquipTipsForm:OnClickSynthBtn()
    if self.EquipmentData.ContainerType == ContainerType.ITEM_LOCATION_EQUIP then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.EquipSynthSub, self.EquipmentData.DBID)
    else
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LingTiSynth, self.EquipmentData)
    end
    self:OnClose()
end

--Star promotion
function UINewEquipTipsForm:OnClickGodStarBtn()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GodEquipStar, self.EquipmentData.DBID)
    self:OnClose()
end

--Advanced
function UINewEquipTipsForm:OnClickGodLvUpBtn()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GodEquipUplv, self.EquipmentData.DBID)
    self:OnClose()
end

-- Appraisal Equipment
function UINewEquipTipsForm:OnClickAppraisalBtn()
    self:DoAppraisal(1)
    
end


-- Advanced Appraisal Equipment
function UINewEquipTipsForm:OnClickAdvancedAppraisalBtn()
    -- GameCenter.LianQiForgeSystem:ReqEquipAppraisal(self.EquipmentData.DBID, 2) -- giám định cao cấp
    self:DoAppraisal(2)
end


function UINewEquipTipsForm:DoAppraisal(type)
    -- if GameCenter.LianQiForgeSystem:HasAppraiseInfoByPart(self.EquipmentData.Part) then
    --    return
    -- end
    self:OnClose()
    GosuSDK.ShowMessageBox(
        GosuSDK.GetLangString("MOSAIC_COFIRM_TEXT"),
        DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
        function()
           GameCenter.LianQiForgeSystem:ReqEquipAppraisal(self.EquipmentData.DBID, type) -- giám định thường
        end
    )
end



-- //Update button
function UINewEquipTipsForm:UpdateBtn()
    local willShow = List:New()
    if self.Location == ItemTipsLocation.Bag then
        -- //Equipment
        local btnTrans = self:SetWillShowButton(EquipButtonType.Equiped, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_EQUIPTIPS_BTN_EQUIP")

        -- //For Sale
        self:SetWillShowButton(EquipButtonType.Sell, willShow)
        if not self.EquipmentData.IsBind and self.EquipmentData.ItemInfo.AuctionMaxPrice ~= 0 then
            self:SetWillShowButton(EquipButtonType.MarketUp, willShow);
        end

        -- //Disassemble
        if self.EquipmentData.ItemInfo.EquipDismantling == 1 then
            self:SetWillShowButton(EquipButtonType.Split, willShow)
        end
    elseif self.Location == ItemTipsLocation.Equip or self.Location == ItemTipsLocation.LingTi then
        -- //Open from the body
        -- Remove equipment from the body
        local btnTrans = self:SetWillShowButton(EquipButtonType.Equiped, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_EQUIPTIPS_BTN_UNEQUIP")

        -- //Appraisal
        -- TODO(A.DUC): handle show Appraise button
        if GameCenter.LianQiForgeSystem:HasAppraiseInfoByPart(self.EquipmentData.Part) then

        end

        -- //Equipment
        local _cfg = DataConfig.DataEquipSynthesis[self.EquipmentData.CfgID]
        if _cfg and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSynthSub) then
            self:SetWillShowButton(EquipButtonType.Synth, willShow)
        end
        if self.EquipmentData.Part >= EquipmentType.Bracelet and self.EquipmentData.Part <= EquipmentType.Badge then
            self:SetWillShowButton(EquipButtonType.GodLv, willShow)
            self:SetWillShowButton(EquipButtonType.GodStar, willShow)
        end
    elseif self.Location == ItemTipsLocation.OutStorage then
        --//Open from the warehouse
        -- //Extract from the warehouse
        local btnTrans = self:SetWillShowButton(EquipButtonType.PutStorage, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_ITEM_STORAGETOBAG")
    elseif self.Location == ItemTipsLocation.PutInStorage then
        --When the warehouse is opened, open from the backpack
        -- //Put it into the warehouse
        local btnTrans = self:SetWillShowButton(EquipButtonType.PutStorage, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_ITEM_BAGTOSTORAGE")
    elseif self.Location == ItemTipsLocation.OutSell then
        --//Open from the decomposition interface
        local btnTrans = self:SetWillShowButton(EquipButtonType.PutStorage, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_ITEM_STORAGETOBAG")
    elseif self.Location == ItemTipsLocation.PutInSell then
        --When the decomposition interface is opened, open from the backpack
        local btnTrans = self:SetWillShowButton(EquipButtonType.PutStorage, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_ITEM_BAGTOSTORAGE")
    elseif self.Location == ItemTipsLocation.EquipSelect then
        local btnTrans = self:SetWillShowButton(EquipButtonType.PutStorage, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_ITEM_BAGTOSTORAGE")
    elseif self.Location == ItemTipsLocation.Market then
        local btnTrans = self:SetWillShowButton(EquipButtonType.Equiped, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "UI_EQUIP_EQUIPSHANGJIA")
    elseif self.Location == ItemTipsLocation.TianQiBaoKu then
        self:SetWillShowButton(EquipButtonType.QuChu, willShow)
    elseif self.Location == ItemTipsLocation.PutinGuildStore then
        local btnTrans = self:SetWillShowButton(EquipButtonType.GuildStore, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_UI_EQUIP_EQUIPTIPS_DONATE")
    elseif self.Location == ItemTipsLocation.OutGuildStore then
        local btnTrans = self:SetWillShowButton(EquipButtonType.GuildStore, willShow)
        local label = UIUtils.FindLabel(btnTrans, "Name")
        UIUtils.SetTextByEnum(label, "C_UI_EQUIP_EQUIPTIPS_CHANGE")
    else
        if self.EquipmentData.ItemInfo.GetText ~= nil and string.len(self.EquipmentData.ItemInfo.GetText) > 0 then
            self:SetWillShowButton(EquipButtonType.Get, willShow)
        end
    end

    for k, v in pairs(self.ButtonDic) do
        v.gameObject:SetActive(false)
    end

    for idx = 1, willShow:Count() do
        willShow[idx].gameObject:SetActive(true)
    end
    self.ButtonTable.repositionNow = true
end

--Update the interface
function UINewEquipTipsForm:UpdateForm()
    if (self.EquipmentData ~= nil) then
        if self.EquipmentData.ItemInfo ~= nil then
            self:UpdateHeadInfo()
            self:UpdateAttribute()
            self:UpdateComparison()
            self:OnSetDonateNum()
            self:SetEquipDesc()
            self:UpdateGetForm()
        end
    end
    self.TimeCount = 0
    self.IsRePosition = true
end

-- /// Set warehouse points
function UINewEquipTipsForm:OnSetDonateNum()
    if self.EquipmentData.ItemInfo.WarehouseIntegral ~= 0 and
            (self.Location == ItemTipsLocation.PutinGuildStore or self.Location == ItemTipsLocation.OutGuildStore) then
        UIUtils.SetTextByNumber(self.DonateNumLabel, self.EquipmentData.ItemInfo.WarehouseIntegral)
    else
        UIUtils.ClearText(self.DonateNumLabel)
    end
end

function UINewEquipTipsForm:SetEquipDesc()
    if self.EquipmentData.ItemInfo.Describe ~= nil and self.EquipmentData.ItemInfo.Describe ~= "" then
        UIUtils.SetTextByString(self.EquipDescLabel, self.EquipmentData.ItemInfo.Describe)
        self.EquipDescLabel.gameObject:SetActive(true)
    else
        self.EquipDescLabel.gameObject:SetActive(false)
    end
    if self.DressEquipData and self.DressEquipData.ItemInfo and self.DressEquipData.ItemInfo.Describe ~= nil
            and self.DressEquipData.ItemInfo.Describe ~= "" then
        UIUtils.SetTextByString(self.DressEquipDescLabel, self.DressEquipData.ItemInfo.Describe)
        self.DressEquipDescLabel.gameObject:SetActive(true)
    else
        self.DressEquipDescLabel.gameObject:SetActive(false)
    end
end

--Sorting function
local function SortFunc(left, right)
    return left.SortValue > right.SortValue
end
function UINewEquipTipsForm:UpdateGetForm()
    local _getText = self.EquipmentData.ItemInfo.GetText
    if _getText ~= nil and string.len(_getText) > 0 and not self.DressBaseGo.activeSelf and self.isShowGetBtn then
        self.GetPanelGo:SetActive(true)

        local _getCfg = Utils.SplitStrBySeps(_getText, { ';', '_' })
        local _count = #_getCfg
        if _count <= 0 then
            self.GetPanelGo:SetActive(false)
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
            _usedUI:Refresh(tonumber(_getCfg[i][1]), _getCfg[i][3], tonumber(_getCfg[i][2]))
        end
        for i = _count + 1, #self.FuncItemList do
            self.FuncItemList[i].RootGo:SetActive(false)
        end
        self.FuncItemList:Sort(SortFunc)

        local _animList = List:New()
        for i = 1, #self.FuncItemList do
            local _item = self.FuncItemList[i]
            _item.RootGo.name = string.format("%2d", i)
            if _item.RootGo.activeSelf then
                _animList:Add(_item.RootTrans)
            end
        end
        self.GetGrid:Reposition()
        self.GetScrollView:ResetPosition()

        for i = 1, #_animList do
            local _trans = _animList[i]
            self.CSForm:RemoveTransAnimation(_trans)
            self.CSForm:AddAlphaPosAnimation(_trans, 0, 1, 0, 30, 0.3, false, false)
            self.AnimPlayer:AddTrans(_trans, (i - 1) * 0.1)
        end
        self.AnimPlayer:Play()
    else
        self.GetPanelGo:SetActive(false)
    end
end

-- //Update attribute information
function UINewEquipTipsForm:UpdateAttribute()
    self:SetRequireInfo()
    self:SetEquipAttributes()
    self:SetGemInlayAtt()
    self:SetGemRefineAtt()
    self:SetJadeInlayAtt()
    self:SetAppraiseAttr()
    self:SetWashAttr()
end

-- //Update the comparison interface
function UINewEquipTipsForm:UpdateComparison()
    if self.DressEquipData ~= nil and (self.Location == ItemTipsLocation.Bag or self.Location == ItemTipsLocation.Defult or self.Location == ItemTipsLocation.OutGuildStore) then
        self.DressBaseGo:SetActive(true)
    else
        self.DressBaseGo:SetActive(false)
    end
end

-- Update header information
function UINewEquipTipsForm:UpdateHeadInfo()
    self:SetEquipName()
    self:SetEquipIcon()
    self:SetEquipType()
    self:SetPowerValue()
    self:SetQualityBackSpr()
    if self.Location == ItemTipsLocation.Equip then
        self.DressTipsGo:SetActive(true)
    else
        self.DressTipsGo:SetActive(false)
    end
end

function UINewEquipTipsForm:LoadVfx()
    if self.EquipmentData and self.EquipmentData.Quality >= 6 then
        self.QualityVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 126 + self.EquipmentData.Quality, LayerUtils.GetUITopLayer());
        if self.EquipmentData.Quality == 8 then
            self.BackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 143, LayerUtils.GetUITopLayer());
        elseif self.EquipmentData.Quality == 9 then
            self.BackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 150, LayerUtils.GetUITopLayer());
        elseif self.EquipmentData.Quality == 10 then
            self.BackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 151, LayerUtils.GetUITopLayer());
        end
    end

    if self.DressEquipData ~= nil and (self.Location == ItemTipsLocation.Bag or self.Location == ItemTipsLocation.Defult or self.Location == ItemTipsLocation.OutGuildStore) then
        self.DressBaseGo:SetActive(true)
        if self.DressEquipData and self.DressEquipData.Quality >= 6 then
            self.DressQualityVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 126 + self.DressEquipData.Quality, LayerUtils.GetUITopLayer());
            if self.DressEquipData.Quality == 8 then
                self.DressBackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 143, LayerUtils.GetUITopLayer());
            elseif self.DressEquipData.Quality == 9 then
                self.DressBackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 150, LayerUtils.GetUITopLayer());
            elseif self.DressEquipData.Quality == 10 then
                self.DressBackVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 151, LayerUtils.GetUITopLayer());
            end
        end
    end
end

-- Set the equipment name
function UINewEquipTipsForm:SetEquipName()
    local _equipName = self.EquipmentData.Name
    if self.PreData.SuitData ~= nil then
        local _suitCfg = GameCenter.EquipmentSuitSystem:FindCfg(self.PreData.SuitData.SuitID);
        if _suitCfg ~= nil then
            _equipName = _suitCfg.Cfg.Prefix .. self.EquipmentData.Name
        end
    end
    UIUtils.SetTextFormat(self.EquipNameLabel, "[{0}]{1}[-]", Utils.GetQualityStrColor(self.EquipmentData.Quality), _equipName)
    if self.DressEquipData ~= nil then
        UIUtils.SetTextFormat(self.DressEquipNameLabel, "[{0}]{1}[-]", Utils.GetQualityStrColor(self.DressEquipData.Quality), self.DressEquipData.Name)
    end
end

-- Equipment icon
function UINewEquipTipsForm:SetEquipIcon()
    if self.DressEquipData ~= nil then
        self.DressEquipIconItem:InitWithItemData(self.DressEquipData, 0, false)
        self.DressEquipIconItem.IsShowTips = false
    end
    self.EquipIconItem:InitWithItemData(self.EquipmentData, 0, false)
    self.EquipIconItem.IsShowTips = false
end

-- type
function UINewEquipTipsForm:SetEquipType()
    local type = LuaItemBase.GetEquipNameWithType(self.EquipmentData.Part)
    UIUtils.SetTextFormat(self.EquipType, "{0}：", type)
    if self.DressEquipData ~= nil then
        if self.DressEquipData.ItemInfo ~= nil then
            type = LuaItemBase.GetEquipNameWithType(self.DressEquipData.Part)
            UIUtils.SetTextFormat(self.DressEquipType, "{0}：", type)
        end
    end
end

function UINewEquipTipsForm:SetPowerValue()
    UIUtils.SetTextByNumber(self.PowerLabel, self.EquipmentData.Power)
    if self.DressEquipData ~= nil then
        UIUtils.SetTextByNumber(self.DressPowerLabel, self.DressEquipData.Power)
    end
end
function UINewEquipTipsForm:SetQualityBackSpr()
    self.QualityBack.spriteName = Utils.GetQualityBackName(self.EquipmentData.Quality)
    if self.DressEquipData ~= nil then
        if self.DressEquipData.ItemInfo ~= nil then
            self.DressQualityBack.spriteName = Utils.GetQualityBackName(self.DressEquipData.Quality)
        end
    end
end
-- Setting requirements, including occupation and level
function UINewEquipTipsForm:SetRequireInfo()
    self:SetEquipLevel()
    self:SetEquipOcc()
    -- self:SetStateVip()
    self:SetChangejob()
end

-- //Equipment wear level
function UINewEquipTipsForm:SetEquipLevel()
    local levelStr = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_UI_EQUIPTIPS_LVLIMIT"), CommonUtils.GetLevelDesc(self.EquipmentData.ItemInfo.Level))
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        if lp.Level >= self.EquipmentData.ItemInfo.Level then
            UIUtils.SetTextByString(self.EquipLevelLabel, levelStr)
        else
            UIUtils.SetTextFormat(self.EquipLevelLabel, "[FF0000]{0}[-]", levelStr)
        end
    end

    if self.DressEquipData ~= nil then
        levelStr = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_UI_EQUIPTIPS_LVLIMIT"), CommonUtils.GetLevelDesc(self.DressEquipData.ItemInfo.Level))
        if lp ~= nil then
            if lp.Level >= self.DressEquipData.ItemInfo.Level then
                UIUtils.SetTextByString(self.DressEquipLevelLabel, levelStr)
            else
                UIUtils.SetTextFormat(self.DressEquipLevelLabel, "[FF0000]{0}[-]", levelStr)
            end
        end
    end
end

-- //Profession
function UINewEquipTipsForm:SetEquipOcc()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        if self.EquipmentData:CheackOcc(lp.IntOcc) then
            UIUtils.SetTextByString(self.EquipOccLabel, Equipment.GetOccNameWithOcc(self.EquipmentData.Occ))
        else
            UIUtils.SetTextFormat(self.EquipOccLabel, "[FF0000]{0}[-]", Equipment.GetOccNameWithOcc(self.EquipmentData.Occ))
        end

        if self.DressEquipData ~= nil then
            if self.DressEquipData:CheackOcc(lp.IntOcc) then
                UIUtils.SetTextByString(self.DressEquipOccLabel, Equipment.GetOccNameWithOcc(self.DressEquipData.Occ))
            else
                UIUtils.SetTextFormat(self.DressEquipOccLabel, "[FF0000]{0}[-]", Equipment.GetOccNameWithOcc(self.EquipmentData.Occ))
            end
        end
    end
end

--Set realm requirements
function UINewEquipTipsForm:SetChangejob()
    local _lpStateLv = 0
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp then
        _lpStateLv = _lp.ChangeJobLevel
    end
    local _needStateLv = self.EquipmentData.ItemInfo.Classlevel
    if _needStateLv > 0 then
        local _cfg = DataConfig.DataChangejob[_needStateLv]
        if _cfg then
            if _lpStateLv >= _needStateLv then
                UIUtils.SetTextByString(self.ChangejobLabel, _cfg.ChangejobName)
            else
                UIUtils.SetTextFormat(self.ChangejobLabel, "[FF0000]{0}[-]", _cfg.ChangejobName)
            end
        end
    else
        UIUtils.SetTextByEnum(self.ChangejobLabel, "C_TEXT_NULL")
    end

    if self.DressEquipData ~= nil then
        _needStateLv = self.DressEquipData.ItemInfo.Classlevel
        if _needStateLv > 0 then
            local _cfg = DataConfig.DataChangejob[_needStateLv]
            if _cfg then
                if _lpStateLv >= _needStateLv then
                    UIUtils.SetTextByString(self.DressChangejobLabel, _cfg.ChangejobName)
                else
                    UIUtils.SetTextFormat(self.DressChangejobLabel, "[FF0000]{0}[-]", _cfg.ChangejobName)
                end
            end
        else
            UIUtils.SetTextByEnum(self.DressChangejobLabel, "C_TEXT_NULL")
        end
    end
end

-- Set properties
function UINewEquipTipsForm:SetEquipAttributes()
    self:SetBaseEquipAtt()
    self:SetSpecialEquipAtt()
    self:SetGodEquipAtt()
    self:SetSuit()
    --self.SuitGo:SetActive(false)
    --self.DressSuitGo:SetActive(false)
end

-- [Gosu] hàm mới check item xem thử phải của mình không

function UINewEquipTipsForm:IsMyItem()
    if not self.EquipmentData then
        return false
    end

    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()

    
    if self.Location == ItemTipsLocation.Equip then
        return true
    end

  
    if self.Location == ItemTipsLocation.Bag then
        return true
    end


    if GameCenter.AuctionHouseSystem then
        local strengLevel =
            GameCenter.AuctionHouseSystem:GetItemStrengthLevel(self.EquipmentData.DBID)
        if strengLevel ~= nil then
            return false
        end
    end

   
    return false
end

function UINewEquipTipsForm:GetStrengthLevel()
    local itemId = self.EquipmentData.DBID

    -- 2️Bag
    -- local bagLevel = GameCenter.LianQiForgeBagSystem:GetItemStrengthLevel(itemId)
    -- if bagLevel ~= nil then
    --     return bagLevel
    -- end

    local _forgeSystem = GameCenter.LianQiForgeBagSystem
    local _starLv = 0
    if _forgeSystem.StrengthItemLevelDic:ContainsKey(itemId) then
        local _strengthInfo = _forgeSystem.StrengthItemLevelDic[itemId]
        _starLv = _strengthInfo.level
        return _starLv
    end


    -- 3️ Auction
    local auctionLevel = GameCenter.AuctionHouseSystem:GetItemStrengthLevel(itemId)
    if auctionLevel ~= nil then
        return auctionLevel
    end

    return 0
end



--Set basic properties
function UINewEquipTipsForm:SetBaseEquipAtt()
    -- --------------------------------
    -- ▼ Main Equipment Base Attribute
    -- --------------------------------
    local _dic = nil
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local strengLevel = self:GetStrengthLevel()


    if self.Location == ItemTipsLocation.Equip then
        _dic = GameCenter.LianQiForgeSystem:GetAllStrengthAttrDicByPart(self.EquipmentData.Part)

        local _starLvP = 0
        if _forgeSystem.StrengthPosLevelDic:ContainsKey(self.EquipmentData.Part) then
            local _strengthInfo = _forgeSystem.StrengthPosLevelDic[self.EquipmentData.Part]
            _starLvP = _strengthInfo.level
        end

        UIUtils.SetTextByString(self.StrengLevelLabel, "+" .. _starLvP)

    elseif self.Location == ItemTipsLocation.Bag then
        _dic = GameCenter.LianQiForgeBagSystem:GetAllStrengthAttrDicByItemId(self.EquipmentData.DBID)

        UIUtils.SetTextByString(self.StrengLevelLabel, "+" .. strengLevel)
    elseif self.Location == ItemTipsLocation.Market then 
        _dic = GameCenter.AuctionHouseSystem:GetAllStrengthAttrDicByItemId(self.EquipmentData.DBID)
        UIUtils.SetTextByString(self.StrengLevelLabel, "+" .. strengLevel) -- auction hiện tại
    elseif self.Location == ItemTipsLocation.Mail then  -- email
        -- Debug.Log("======================Emaillllllllllllllllllllllllllllllllllllllllllllllllllllllllll==", self.EquipmentData.DBID)
        _dic = GameCenter.MailSystem:GetAllStrengthAttrDicByItemId(self.EquipmentData.DBID)
    elseif self.Location == ItemTipsLocation.Defult  then  -- Defult
        Debug.Log("======================Defult =======================================================")
    end


    self.BaseAttContainer:EnQueueAll()
    local attDic = self.EquipmentData:GetBaseAttribute()

    local e = attDic:GetEnumerator()
    while e:MoveNext() do
        local attrID = e.Current.Key
        local baseValue = e.Current.Value
        local desAttrInfo

        if _dic and _dic:ContainsKey(attrID) then
            desAttrInfo = DescAttrInfo:New(attrID, baseValue, nil, nil, { bonus = _dic[attrID].Value })
        else
            desAttrInfo = DescAttrInfo:New(attrID, baseValue)
        end
        local ui = self.BaseAttContainer:DeQueue(desAttrInfo)
        local dicValue = _dic and _dic[attrID] and _dic[attrID].Value or 0
        ui:SetName(string.format("%03d", attrID))
        ui:SetActive(baseValue > 0 or dicValue > 0)
    end
    self.BaseAttContainer:RefreshAllUIData()

    -- --------------------------------
    -- ▼ Compare Equipment Base Attribute
    -- --------------------------------
    if self.DressEquipData and self.DressEquipData.ItemInfo then
        local _dressDic = GameCenter.LianQiForgeSystem:GetAllStrengthAttrDicByPart(self.DressEquipData.Part)

        -- show streng level
       
        local _starLv = 0

        if _forgeSystem
           and _forgeSystem.StrengthPosLevelDic
           and self.DressEquipData
           and self.DressEquipData.Part
           and _forgeSystem.StrengthPosLevelDic:ContainsKey(self.DressEquipData.Part)
        then
                local _strengthInfo = _forgeSystem.StrengthPosLevelDic[self.DressEquipData.Part]
                _starLv = _strengthInfo.level
        end

        UIUtils.SetTextByString(self.DressStrengLevelLabel, "+" .. _starLv)


        self.DressBaseAttContainer:EnQueueAll()
        local dressAttDic = self.DressEquipData:GetBaseAttribute()
        local e2 = dressAttDic:GetEnumerator()
        while e2:MoveNext() do
            local attrID = e2.Current.Key
            local baseValue = e2.Current.Value
            local desAttrInfo
            if _dressDic and _dressDic:ContainsKey(attrID) then
                desAttrInfo = DescAttrInfo:New(attrID, baseValue, nil, nil, { bonus = _dressDic[attrID].Value })
            else
                desAttrInfo = DescAttrInfo:New(attrID, baseValue)
            end
            local ui = self.DressBaseAttContainer:DeQueue(desAttrInfo)
            local dicValue = _dic and _dic[attrID] and _dic[attrID].Value or 0
            ui:SetName(string.format("%03d", attrID))
            ui:SetActive(baseValue > 0 or dicValue > 0)
        end
        self.DressBaseAttContainer:RefreshAllUIData()

    end
    self.BaseAttGrid.repositionNow = true
    self.DressBaseAttGrid.repositionNow = true
end

-- function UINewEquipTipsForm:SetSpecialEquipAtt()

    -- Tạm ẩn thuộc tính đặc biệt

    -- self.SpecialAttTitleGo:SetActive(false)
    -- self.DressSpecialAttrTitleGo:SetActive(false)

    -- local attDic = self.EquipmentData:GetSpecialAttribute()
    -- self.SpecialAttContainer:EnQueueAll()
    -- local e = attDic:GetEnumerator()
    -- while e:MoveNext() do
    --     local ui = self.SpecialAttContainer:DeQueue(DescAttrInfo:New(e.Current.Key, e.Current.Value))
    --     ui:SetName(string.format("%03d", e.Current.Key))
    -- end
    -- self.SpecialAttContainer:RefreshAllUIData()
    -- self.SpecialAttTitleGo:SetActive(attDic.Count > 0)

    -- self.DressSpecialAttContainer:EnQueueAll()
    -- if self.DressEquipData ~= nil then
    --     if self.DressEquipData.ItemInfo ~= nil then
    --         attDic = self.DressEquipData:GetSpecialAttribute()
    --         e = attDic:GetEnumerator()
    --         while e:MoveNext() do
    --             local ui = self.DressSpecialAttContainer:DeQueue(DescAttrInfo:New(e.Current.Key, e.Current.Value))
    --             ui:SetName(string.format("%03d", e.Current.Key))
    --         end
    --         self.DressSpecialAttContainer:RefreshAllUIData()
    --         self.DressSpecialAttrTitleGo:SetActive(attDic.Count > 0)
    --     end
    -- else
    --     self.DressSpecialAttrTitleGo:SetActive(false)
    -- end
    -- self.SpecialAttGrid.repositionNow = true
    -- self.DressSpecialAttGrid.repositionNow = true
-- end

-- Set equipment special attributes
function UINewEquipTipsForm:SetSpecialEquipAtt()
    -- ======================================================
    -- ▼ Main Equipment Special Attribute
    -- ======================================================
    local _dic = nil
    local _haveSpecial = false
    self.SpecialAttContainer:EnQueueAll()
    if self.EquipmentData ~= nil and self.EquipmentData.ItemInfo ~= nil then
        if self.Location == ItemTipsLocation.Equip then
            _dic = GameCenter.LianQiForgeSystem:GetAllSpecialAttrDicByPart(self.EquipmentData.Part)

        elseif self.Location == ItemTipsLocation.Bag then
            _dic = GameCenter.LianQiForgeBagSystem:GetAllSpecialAttrDicByItemId(self.EquipmentData.DBID)

        elseif self.Location == ItemTipsLocation.Market then 
            _dic = GameCenter.AuctionHouseSystem:GetAllSpecialAttrDicByItemId(self.EquipmentData.DBID) -- auction ở đây

        elseif self.Location == ItemTipsLocation.Mail then 
            _dic = GameCenter.MailSystem:GetAllSpecialAttrDicByItemId(self.EquipmentData.DBID) -- email ở đây
  
        end


        if _dic ~= nil then
            _dic:Foreach(function(k, v)
                _haveSpecial = true
                local ui = self.SpecialAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value))
                ui:SetName(string.format("%03d", k))
                ui:SetActive(true)
                GameCenter.LianQiForgeSystem:SetSpecialLabelColorByPercent(ui.ValueLabel, v.Percent)
            end)
        end
    end
    self.SpecialAttTitleGo:SetActive(_haveSpecial)

    -- ======================================================
    -- ▼ Compare Equipment Special Attribute
    -- ======================================================
    _haveSpecial = false
    self.DressSpecialAttContainer:EnQueueAll()
    if self.DressEquipData ~= nil and self.DressEquipData.ItemInfo ~= nil then
        local _dressDic = GameCenter.LianQiForgeSystem:GetAllSpecialAttrDicByPart(self.DressEquipData.Part)
        if _dressDic ~= nil then
            _dressDic:Foreach(function(k, v)
                _haveSpecial = true
                local ui = self.DressSpecialAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value))
                ui:SetName(string.format("%03d", k))
                ui:SetActive(true)
                GameCenter.LianQiForgeSystem:SetSpecialLabelColorByPercent(ui.ValueLabel, v.Percent)
            end)
        end
    end
    self.DressSpecialAttrTitleGo:SetActive(_haveSpecial)

    -- ======================================================
    -- ▼ Final UI Update
    -- ======================================================
    self.SpecialAttGrid.repositionNow = true
    self.DressSpecialAttGrid.repositionNow = true
end

--Set the attributes of the gods
function UINewEquipTipsForm:SetGodEquipAtt()
    local attDic = self.EquipmentData:GetGodAttribute()
    self.GodAttContainer:EnQueueAll()
    local e = attDic:GetEnumerator()
    while e:MoveNext() do
        local ui = self.GodAttContainer:DeQueue(DescAttrInfo:New(e.Current.Key, e.Current.Value))
        ui:SetName(string.format("%03d", e.Current.Key))
    end
    self.GodAttContainer:RefreshAllUIData()
    self.GodAttTitleGo:SetActive(attDic.Count > 0)

    self.DressGodAttContainer:EnQueueAll()
    if self.DressEquipData ~= nil then
        if self.DressEquipData.ItemInfo ~= nil then
            attDic = self.DressEquipData:GetGodAttribute()
            e = attDic:GetEnumerator()
            while e:MoveNext() do
                local ui = self.DressGodAttContainer:DeQueue(DescAttrInfo:New(e.Current.Key, e.Current.Value))
                ui:SetName(string.format("%03d", e.Current.Key))
            end
            self.DressGodAttContainer:RefreshAllUIData()
            self.DressGodAttrTitleGo:SetActive(attDic.Count > 0)
        end
    else
        self.DressGodAttrTitleGo:SetActive(false)
    end
    self.GodAttGrid.repositionNow = true
    self.DressGodAttGrid.repositionNow = true
end

-- Set equipment appraisal attributes
function UINewEquipTipsForm:SetAppraiseAttr()
    -- ======================================================
    -- ▼ Main Equipment Appraise Attribute
    -- ======================================================
    local _dic = nil
    local _haveAppraise = false
    self.AppraiseAttContainer:EnQueueAll()
    if self.EquipmentData ~= nil and self.EquipmentData.ItemInfo ~= nil then
        if self.Location == ItemTipsLocation.Equip then
            _dic = GameCenter.LianQiForgeSystem:GetAllAppraiseAttrDicByPart(self.EquipmentData.Part)

        elseif self.Location == ItemTipsLocation.Bag then
            _dic = GameCenter.LianQiForgeBagSystem:GetAllAppraiseAttrDicByItemId(self.EquipmentData.DBID)

        elseif self.Location == ItemTipsLocation.Market then 
            _dic = GameCenter.AuctionHouseSystem:GetAllAppraiseAttrDicByItemId(self.EquipmentData.DBID) -- auction ở đây

        elseif self.Location == ItemTipsLocation.Mail then 
            _dic = GameCenter.MailSystem:GetAllAppraiseAttrDicByItemId(self.EquipmentData.DBID) -- email ở đây
  
        end

        if _dic ~= nil then
            _dic:Foreach(function(k, v)
                _haveAppraise = true
                local ui = self.AppraiseAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value))
                ui:SetName(string.format("%03d", k))
                ui:SetActive(true)
                GameCenter.LianQiForgeSystem:SetAppraiseLabelColorByPercent(ui.ValueLabel, v.Percent / 100, v.SpecialType)
            end)
        end

        --✨ Nếu không có thuộc tính thì vẫn tạo 1 dòng text "Chưa giám định"
        if not _haveAppraise then
            local ui = self.AppraiseAttContainer:DeQueue({ ID = nil, Value = nil })
            -- ui:SetName("Chưa giám định")
            ui:SetActive(true)
            GameCenter.LianQiForgeSystem:SetAppraiseLabelColorByPercent(ui.ValueLabel)
            _haveAppraise = true
        end

        -- self.AppraiseAttrTitleGo:SetActive(_haveAppraise)
    end
    self.AppraiseAttrTitleGo:SetActive(_haveAppraise)

    -- ======================================================
    -- ▼ Compare Equipment Appraise Attribute
    -- ======================================================
    _haveAppraise = false
    self.DressAppraiseAttContainer:EnQueueAll()
    if self.DressEquipData ~= nil and self.DressEquipData.ItemInfo ~= nil then
        local _dressDic = GameCenter.LianQiForgeSystem:GetAllAppraiseAttrDicByPart(self.DressEquipData.Part)
        if _dressDic ~= nil then
            _dressDic:Foreach(function(k, v)
                _haveAppraise = true
                local ui = self.DressAppraiseAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value))
                ui:SetName(string.format("%03d", k))
                ui:SetActive(true)
                GameCenter.LianQiForgeSystem:SetAppraiseLabelColorByPercent(ui.ValueLabel, v.Percent / 100, v.SpecialType)
            end)
        end

        if not _haveAppraise then
            local ui = self.DressAppraiseAttContainer:DeQueue({ ID = nil, Value = nil })
            -- ui:SetName("Chưa giám định")
            ui:SetActive(true)
            _haveAppraise = true
        end

    end
    self.DressAppraiseAttrTitleGo:SetActive(_haveAppraise)

    -- ======================================================
    -- ▼ Final UI Update
    -- ======================================================
    self.AppraiseAttrGrid.repositionNow = true
    self.DressAppraiseAttrGrid.repositionNow = true
end

--Set equipment cleaning attributes
function UINewEquipTipsForm:SetWashAttr()
    -- ======================================================
    -- ▼ Main Equipment Wash Attribute
    -- ======================================================
    local _washFuncVisible = GameCenter.MainFunctionSystem:FunctionIsEnabled(FunctionStartIdCode.LianQiForgeWash)
    local _dic = nil
    local _haveWash = false
    self.WashAttContainer:EnQueueAll()
    if _washFuncVisible and self.EquipmentData ~= nil and self.EquipmentData.ItemInfo ~= nil then
        if self.Location == ItemTipsLocation.Equip then
            _dic = GameCenter.LianQiForgeSystem:GetAllWashAttrDicByPart(self.EquipmentData.Part)
            if _dic == nil or _dic:Count() == 0 then
                _dic = GameCenter.LianQiForgeSystem:GetEquipDefaultWashAttrs(self.EquipmentData.ItemInfo)
            end
        elseif self.Location == ItemTipsLocation.Bag then
            --or self.Location == ItemTipsLocation.PutInStorage then
            _dic = GameCenter.LianQiForgeBagSystem:GetAllWashAttrDicByItemId(self.EquipmentData.DBID)
        elseif self.Location == ItemTipsLocation.Market then 
            _dic = GameCenter.AuctionHouseSystem:GetAllWashAttrDicByItemId(self.EquipmentData.DBID) -- auction ở đây

        elseif self.Location == ItemTipsLocation.Mail then 
            _dic = GameCenter.MailSystem:GetAllWashAttrDicByItemId(self.EquipmentData.DBID) -- email ở đây
        end
    end

    if self.PreData and self.PreData.WashDic then
        _dic = self.PreData.WashDic
    end

    if _dic then
        _dic:Foreach(function(k, v)
            _haveWash = true
            local _ui = self.WashAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value, nil, 'NotWashAttr'))
            _ui:SetName(string.format("%03d", k))
            _ui:SetActive(true)
            GameCenter.LianQiForgeSystem:SetLabelColorByPercent(_ui.ValueLabel, v.Percent / 100)
        end)
    end
    self.WashAttrTitleGo:SetActive(_haveWash)

    -- ======================================================
    -- ▼ Dress Equipment Wash Attribute
    -- ======================================================
    _haveWash = false
    self.DressWashAttContainer:EnQueueAll()
    if _washFuncVisible and self.DressEquipData and self.DressEquipData.ItemInfo then
        local _dressDic = GameCenter.LianQiForgeSystem:GetAllWashAttrDicByPart(self.DressEquipData.Part)
        if _dressDic == nil or _dressDic:Count() == 0 then
            _dressDic = GameCenter.LianQiForgeSystem:GetEquipDefaultWashAttrs(self.DressEquipData.ItemInfo)
        end
        if _dressDic then
            _dressDic:Foreach(function(k, v)
                _haveWash = true
                local _ui = self.DressWashAttContainer:DeQueue(DescAttrInfo:New(v.AttrID, v.Value, nil, 'NotWashAttr'))
                _ui:SetName(string.format("%03d", k))
                _ui:SetActive(true)
                GameCenter.LianQiForgeSystem:SetLabelColorByPercent(_ui.ValueLabel, v.Percent / 100)
            end)
        end
    end
    self.DressWashAttrTitleGo:SetActive(_haveWash)

    -- ======================================================
    -- ▼ Final UI Update
    -- ======================================================
    self.WashAttrGrid.repositionNow = true
    self.DressWashAttrGrid.repositionNow = true
end


-- Hàm mới chỉ show đúng slot của vật phẩm:
-- Set gem inlay data
-- function UINewEquipTipsForm:SetGemInlayAtt()
--     self.GemInlayContainer:EnQueueAll()
--     local _haveGem = false

--     if self.EquipmentData ~= nil then
--         -- Lấy số slot được mở theo level
--         local level = self.EquipmentData.Quality or 1
--         local slotCount = GameCenter.LianQiGemSystem:GetSlotCountByLevel(level, 0)
--         -- print(string.format("🔹 [SetGemInlayAtt] Level=%d -> SlotCount=%d", level, slotCount))

--         if self.Location == ItemTipsLocation.Equip or self.PreData.GemInlayList then
--             local _attList = nil
--             if self.PreData.GemInlayList then
--                 _attList = self.PreData.GemInlayList
--             else
--                 local attDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic
--                 if attDic:ContainsKey(self.EquipmentData.Part) then
--                     _attList = attDic[self.EquipmentData.Part]
--                 end
--             end

--             print("_attList====================================================================", Inspect(_attList))

--             if _attList then
--                 -- Chỉ hiển thị đến slotCount
--                 for i = 1, math.min(#_attList, slotCount) do
--                     local _id = _attList[i]
--                     local data = L_GemInlayInfo:New(_id, 1, self.EquipmentData.Part, i)
--                     _haveGem = true
--                     local ui = self.GemInlayContainer:DeQueue(data)
--                     ui:SetName(string.format("%03d", i))
--                 end
--             end
--         else
--             -- Trường hợp hiển thị slot theo slotCount (bỏ điều kiện cấu hình cũ)
--             local slotCount = GameCenter.LianQiGemSystem:GetSlotCountByLevel(level, 0)
--             for i = 1, slotCount do
--                 local _id = 0  -- 0 = slot trống, chưa khảm
--                 local data = L_GemInlayInfo:New(_id, 1, self.EquipmentData.Part, i)
--                 _haveGem = true
--                 local ui = self.GemInlayContainer:DeQueue(data)
--                 ui:SetName(string.format("%03d", i))
--             end
--             print("_attList===================================================trong túi=================")


--         end

--         self.GemInlayContainer:RefreshAllUIData()
--     end

--     self.GemInlayTitleGo:SetActive(_haveGem)

--     -- Hiển thị phần trang bị đang mặc (DressEquipData)
--     if self.DressEquipData ~= nil and self.DressEquipData.ItemInfo ~= nil then
--         local attDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic
--         self.DressGemInlayContainer:EnQueueAll()
--         _haveGem = false

--         -- Lấy slot count riêng cho DressEquipData
--         local level = self.DressEquipData.Quality or 1
--         local slotCount = GameCenter.LianQiGemSystem:GetSlotCountByLevel(level, 0)
--         -- print(string.format("🔹 [SetGemInlayAtt:Dress] Level=%d -> SlotCount=%d", level, slotCount))

--         if attDic:ContainsKey(self.DressEquipData.Part) then
--             local _attList = attDic[self.DressEquipData.Part]
--             for i = 1, math.min(#_attList, slotCount) do
--                 local data = L_GemInlayInfo:New(_attList[i], 1, self.DressEquipData.Part, i)
--                 _haveGem = true
--                 local ui = self.DressGemInlayContainer:DeQueue(data)
--                 ui:SetName(string.format("%03d", i))
--             end
--         end
--         self.DressGemInlayTitleGo:SetActive(_haveGem)
--         self.DressGemInlayContainer:RefreshAllUIData()
--     end

--     self.DressGemInlayGrid.repositionNow = true
--     self.GemInlayGrid.repositionNow = true
-- end


-- Set gem inlay data (itemId ONLY, no part fallback)
function UINewEquipTipsForm:SetGemInlayAtt()
    self.GemInlayContainer:EnQueueAll()
    local _haveGem = false

    if not self.EquipmentData then
        return
    end

    local gemSys = GameCenter.LianQiGemSystem
    local level = self.EquipmentData.Quality or 1
    local slotCount = gemSys:GetSlotCountByLevel(level, 0)

    local part   = self.EquipmentData.Part
    local itemId = self.EquipmentData.DBID

    local _attList = nil

    -- ===== ONLY SOURCE: itemId =====
    if self.Location == ItemTipsLocation.Equip or self.PreData.GemInlayList then
        local attDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic
        if attDic:ContainsKey(self.EquipmentData.Part) then
            _attList = attDic[self.EquipmentData.Part]
        end
    elseif self.Location == ItemTipsLocation.Bag then
        if itemId and gemSys.GemInlayInfoByItemIdDic and gemSys.GemInlayInfoByItemIdDic:ContainsKey(itemId) then
            local info = gemSys.GemInlayInfoByItemIdDic[itemId]
            _attList = info and info.gemIds
        end

    elseif self.Location == ItemTipsLocation.Market then 
        local gemAucSys = GameCenter.AuctionHouseSystem
        -- auction ở đây
        if itemId and gemAucSys.GemInlayInfoByItemIdDic and gemAucSys.GemInlayInfoByItemIdDic:ContainsKey(itemId) then
            local info = gemAucSys.GemInlayInfoByItemIdDic[itemId]
            _attList = info and info.gemIds
        end

    elseif self.Location == ItemTipsLocation.Mail then 
        
         local gemAucSys = GameCenter.MailSystem
         -- email ở đây
        if itemId and gemAucSys.GemInlayInfoByItemIdDic and gemAucSys.GemInlayInfoByItemIdDic:ContainsKey(itemId) then
            local info = gemAucSys.GemInlayInfoByItemIdDic[itemId]
            _attList = info and info.gemIds
        end
    end


    -- ===== Render UI =====
    if _attList then
        for i = 1, math.min(#_attList, slotCount) do
            local gemId = _attList[i]



            if _attList and _attList[i] ~= nil then
                gemId = self:NormalizeGemId(_attList[i])
            end


            local data = L_GemInlayInfo:New(gemId, 1, part, i)

            _haveGem = true
            local ui = self.GemInlayContainer:DeQueue(data)
            ui:SetName(string.format("%03d", i))
        end
    else
        -- ❗ KHÔNG CÓ DATA → SLOT RỖNG
        for i = 1, slotCount do
            local data = L_GemInlayInfo:New(0, 1, part, i)
            _haveGem = true
            local ui = self.GemInlayContainer:DeQueue(data)
            ui:SetName(string.format("%03d", i))
        end
    end

    self.GemInlayContainer:RefreshAllUIData()
    self.GemInlayTitleGo:SetActive(_haveGem)

    -- ===== DressEquipData (vẫn dùng part là hợp lý) =====
    if self.DressEquipData ~= nil and self.DressEquipData.ItemInfo ~= nil then
        local attDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic

        -- Debug.Log("attDicattDicattDicattDic====attDicattDicattDic===", Inspect(self.DressEquipData.Quality))

        self.DressGemInlayContainer:EnQueueAll()
        _haveGem = false

        local level = self.DressEquipData.Quality or 1
        local slotCount = GameCenter.LianQiGemSystem:GetSlotCountByLevel(level, 0)

        if attDic:ContainsKey(self.DressEquipData.Part) then
            local _attList = attDic[self.DressEquipData.Part]
            for i = 1, math.min(#_attList, slotCount) do



                local gemId = 0

                if _attList and _attList[i] ~= nil then
                    gemId = self:NormalizeGemId(_attList[i])
                end

                -- Debug.Log("_attList=========================", Inspect(_attList))

                local data = L_GemInlayInfo:New(gemId, 1, self.DressEquipData.Part, i)
                _haveGem = true
                local ui = self.DressGemInlayContainer:DeQueue(data)
                ui:SetName(string.format("%03d", i))
            end
        end

        self.DressGemInlayTitleGo:SetActive(_haveGem)
        self.DressGemInlayContainer:RefreshAllUIData()
    end

   

    self.DressGemInlayGrid.repositionNow = true
    self.GemInlayGrid.repositionNow = true
end

-- gemId <= 0 → coi như slot mở, chưa khảm
function UINewEquipTipsForm:NormalizeGemId(gemId)
    if gemId == nil or gemId <= 0 then
        return 0
    end
    return gemId
end





function UINewEquipTipsForm:IsConditionTrue(data, condition)
    local _conditionList = Utils.SplitNumber(condition, "_")
    if _conditionList[1] == 1 and #_conditionList == 2 then
        --1 Level
        return GameCenter.GameSceneSystem:GetLocalPlayerLevel() >= _conditionList[2]
    elseif _conditionList[1] == 17 and #_conditionList == 3 then
        --17 Equipment Level
        local _equip = data
        if _equip then
            if _equip.Grade then
                return _equip.Grade >= _conditionList[3]
            end
        end
        return false
    elseif _conditionList[1] == 118 and #_conditionList == 3 then
        --118 Equipment quality
        local _equip = data
        if _equip then
            if _equip.Quality then
                return _equip.Quality >= _conditionList[3]
            end
        end
        return false
    elseif _conditionList[1] == 210 and #_conditionList == 2 then
        --1 Level
        return GameCenter.VipSystem:GetVipLevel() >= _conditionList[2]
    end
end

--Set the Xianyu inlay data
function UINewEquipTipsForm:SetJadeInlayAtt()

    -- Tạm ẩn khảm tiên ngọc

    self.JadeInlayTitleGo:SetActive(false)
    self.DressJadeInlayTitleGo:SetActive(false)

    -- self.JadeInlayContainer:EnQueueAll()
    -- local _haveGem = false
    -- local _funcOpen = GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.LianQiGemJade)
    -- if self.EquipmentData ~= nil then
    --     local _part = self.EquipmentData.Part
    --     local _attList = nil
    --     if self.PreData.JadeInlayList then
    --         _attList = self.PreData.JadeInlayList
    --     elseif self.Location == ItemTipsLocation.Equip and _funcOpen then
    --         local attDic = GameCenter.LianQiGemSystem.JadeInlayInfoByPosDic
    --         if attDic:ContainsKey(_part) then
    --             _attList = attDic[_part]
    --         end
    --     end
    --     if _attList then
    --         for i = 1, #_attList do
    --             local _id = _attList[i]
    --             local data = L_GemInlayInfo:New(_id, 2, _part, i)
    --             _haveGem = true
    --             local ui = self.JadeInlayContainer:DeQueue(data)
    --             ui:SetName(string.format("%03d", i))
    --         end
    --     end
    --     self.JadeInlayContainer:RefreshAllUIData()
    -- end
    -- self.JadeInlayTitleGo:SetActive(_haveGem)

    -- if self.DressEquipData ~= nil then
    --     if self.DressEquipData.ItemInfo ~= nil then
    --         self.DressJadeInlayContainer:EnQueueAll()
    --         _haveGem = false
    --         if _funcOpen then
    --             local attDic = GameCenter.LianQiGemSystem.JadeInlayInfoByPosDic
    --             if attDic:ContainsKey(self.DressEquipData.Part) then
    --                 local _attList = attDic[self.DressEquipData.Part]
    --                 for i = 1, #_attList do
    --                     local data = L_GemInlayInfo:New(_attList[i], 2, self.DressEquipData.Part, i)
    --                     _haveGem = true
    --                     local ui = self.DressJadeInlayContainer:DeQueue(data)
    --                     ui:SetName(string.format("%03d", i))
    --                 end
    --             end
    --         end
    --         self.DressJadeInlayTitleGo:SetActive(_haveGem)
    --         self.DressJadeInlayContainer:RefreshAllUIData()
    --     end
    -- end
    -- self.JadeInlayGrid.repositionNow = true
    -- self.DressJadeInlayGrid.repositionNow = true
end

--Set gem refining properties
function UINewEquipTipsForm:SetGemRefineAtt()
    self.GemRefineContainer:EnQueueAll()
    if self.Location == ItemTipsLocation.Equip or (self.PreData.GemRefinLv and self.PreData.GemRefinLv > 0) then
        if self.EquipmentData ~= nil then
            local _cfgData = nil
            local _haveGem = false
            local _part = self.EquipmentData.Part
            if self.PreData.GemRefinLv and self.PreData.GemRefinLv > 0 then
                local _cfgID = GameCenter.LianQiGemSystem:GetGemRefineCfgID(_part, self.PreData.GemRefinLv)
                _cfgData = DataConfig.DataGemRefining[_cfgID]
            else
                local attDic = GameCenter.LianQiGemSystem.GemRefineInfoByPosDic
                if attDic:ContainsKey(_part) then
                    local _levelTemp = attDic[_part]
                    local _cfgID = GameCenter.LianQiGemSystem:GetGemRefineCfgID(_part, _levelTemp.Level)
                    _cfgData = DataConfig.DataGemRefining[_cfgID]
                end
            end
            if _cfgData ~= nil then
                local _arr = Utils.SplitStr(_cfgData.Attribute, ";")
                for i = 1, #_arr do
                    _haveGem = true
                    local data = Utils.SplitStr(_arr[i], "_")
                    local ui = self.GemRefineContainer:DeQueue(DescAttrInfo:New(tonumber(data[1]), tonumber(data[2])))
                    ui:SetName(string.format("%03d", data[1]))
                end
            end
            self.GemRefineTitleGo:SetActive(_haveGem)
            self.GemRefineContainer:RefreshAllUIData()
        end
    else
        self.GemRefineTitleGo:SetActive(false)
    end
    if self.DressEquipData ~= nil then
        if self.DressEquipData.ItemInfo ~= nil then
            local attDic = GameCenter.LianQiGemSystem.GemRefineInfoByPosDic
            self.DressGemRefineContainer:EnQueueAll()
            local _haveGem = false
            local _part = self.DressEquipData.Part
            if attDic:ContainsKey(_part) then
                local _levelTemp = attDic[_part]
                local _cfgID = GameCenter.LianQiGemSystem:GetGemRefineCfgID(_part, _levelTemp.Level)
                local _cfgData = DataConfig.DataGemRefining[_cfgID]
                if _cfgData ~= nil then
                    local _arr = Utils.SplitStr(_cfgData.Attribute, ";")
                    for i = 1, #_arr do
                        _haveGem = true
                        local data = Utils.SplitStr(_arr[i], "_")
                        local ui = self.DressGemRefineContainer:DeQueue(DescAttrInfo:New(tonumber(data[1]), tonumber(data[2])))
                        ui:SetName(string.format("%03d", data[1]))
                    end
                end
            end
            self.DressGemRefineTitleGo:SetActive(_haveGem)
            self.DressGemRefineContainer:RefreshAllUIData()
        end
    end
    self.GemRefineGrid.repositionNow = true
    self.DressGemRefineGrid.repositionNow = true
end

function UINewEquipTipsForm:SetSuit()
    if self.EquipmentData ~= nil or self.PreData.SuitData ~= nil then
        local _suitCfg = nil
        if self.PreData.SuitData ~= nil then
            _suitCfg = GameCenter.EquipmentSuitSystem:FindCfg(self.PreData.SuitData.SuitID);
        else
            _suitCfg = GameCenter.EquipmentSuitSystem:FindCfg(self.EquipmentData.SuitID);
        end
        if _suitCfg ~= nil then
            self.SuitGo:SetActive(true)
            local _suitEquipCount = self.EquipmentData.CurSuitEquipCount;
            if self.PreData.SuitData ~= nil then
                _suitEquipCount = self.PreData.SuitData.CurSuitEquipCount
            end
            UIUtils.SetTextByEnum(self.SuitName, "C_UI_EQUIPTIPS_SUITATT", _suitEquipCount, #_suitCfg.NeedParts)

            local _descList = List:New();
            local _activedList = nil
            local _activeIdList = nil
            if self.PreData.SuitData ~= nil then
                _activedList = self.PreData.SuitData.ActiveSuitNums
                _activeIdList = self.PreData.SuitData.ActiveSuitIds
            else
                _activedList = List:New(self.EquipmentData.ActiveSuitNums);
                _activeIdList = List:New(self.EquipmentData.ActiveSuitIds);
            end

            -- CUSTOM - ẩn hiện thị dòng kích hoạt
            -- local _readList = {1, 2, 4, 6};
            local _readList = { 1, 2, 3 };
            -- CUSTOM - ẩn hiện thị dòng kích hoạt

            for i = 1, #_readList do
                local _needCount = _readList[i];
                local _textColor = "9D9D9D";
                local _activeIndex = _activedList:IndexOf(_needCount);
                local _showSuit = nil;
                if _activeIndex > 0 then
                    _textColor = "73ED6B";
                    _showSuit = GameCenter.EquipmentSuitSystem:FindCfg(_activeIdList[_activeIndex]);
                else
                    _showSuit = _suitCfg;
                end
                local _props = _showSuit.Props[_needCount];
                if _props ~= nil then
                    for j = 1, #_props do
                        local _countColor = _textColor
                        if j ~= 1 then
                            _countColor = _textColor .. "00"
                        end
                        _descList:Add(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_SUIT_TIPS"), _textColor, _countColor, _needCount, L_BattlePropTools.GetBattlePropName(_props[j][1]), L_BattlePropTools.GetBattleValueText(_props[j][1], _props[j][2])))
                    end
                end
            end
            UIUtils.SetTextByString(self.SuitPropDesc, table.concat(_descList))
        else
            local _equipCfg = DataConfig.DataEquip[self.EquipmentData.CfgID]
            _suitCfg = GameCenter.EquipmentSuitSystem:GetEquipSuitCfgData(_equipCfg, 1)
            if _suitCfg ~= nil then
                self.SuitGo:SetActive(true)
                UIUtils.SetTextByEnum(self.SuitName, "C_UI_EQUIPTIPS_SUITATT", 0, #_suitCfg.NeedParts)
                local _descList = List:New();
                -- CUSTOM - ẩn hiện thị dòng kích hoạt
                -- local _readList = {1, 2, 4, 6};
                local _readList = { 1, 2, 3 };
                -- CUSTOM - ẩn hiện thị dòng kích hoạt
                for i = 1, #_readList do
                    local _needCount = _readList[i];
                    local _textColor = "9D9D9D";
                    local _showSuit = _suitCfg;
                    local _props = _showSuit.Props[_needCount];
                    if _props ~= nil then
                        for j = 1, #_props do
                            local _countColor = "9D9D9D"
                            if j ~= 1 then
                                _countColor = "9D9D9D00"
                            end
                            _descList:Add(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_SUIT_TIPS"), _textColor, _countColor, _needCount, L_BattlePropTools.GetBattlePropName(_props[j][1]), L_BattlePropTools.GetBattleValueText(_props[j][1], _props[j][2])))
                        end
                    end
                end
                UIUtils.SetTextByString(self.SuitPropDesc, table.concat(_descList))
            else
                self.SuitGo:SetActive(false)
            end
        end
    end

    if self.DressEquipData ~= nil then
        local _suitCfg = GameCenter.EquipmentSuitSystem:FindCfg(self.DressEquipData.SuitID);
        if _suitCfg ~= nil then
            self.DressSuitGo:SetActive(true)
            local _suitEquipCount = self.DressEquipData.CurSuitEquipCount;
            UIUtils.SetTextByEnum(self.DressSuitName, "C_UI_EQUIPTIPS_SUITATT", _suitEquipCount, #_suitCfg.NeedParts)

            local _descList = List:New();
            local _activedList = List:New(self.DressEquipData.ActiveSuitNums);
            local _activeIdList = List:New(self.DressEquipData.ActiveSuitIds);
            -- CUSTOM - ẩn hiện thị dòng kích hoạt
            -- local _readList = {1, 2, 4, 6};
            local _readList = { 1, 2, 3 };
            -- CUSTOM - ẩn hiện thị dòng kích hoạt
            for i = 1, #_readList do
                local _needCount = _readList[i];
                local _textColor = "9D9D9D";
                local _activeIndex = _activedList:IndexOf(_needCount);
                local _showSuit = nil;
                if _activeIndex > 0 then
                    _textColor = "73ED6B";
                    _showSuit = GameCenter.EquipmentSuitSystem:FindCfg(_activeIdList[_activeIndex]);
                else
                    _showSuit = _suitCfg;
                end
                local _props = _showSuit.Props[_needCount];
                if _props ~= nil then
                    for j = 1, #_props do
                        local _countColor = _textColor
                        if j ~= 1 then
                            _countColor = _textColor .. "00"
                        end
                        _descList:Add(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_SUIT_TIPS"), _textColor, _countColor, _needCount, L_BattlePropTools.GetBattlePropName(_props[j][1]), L_BattlePropTools.GetBattleValueText(_props[j][1], _props[j][2])))
                    end
                end
            end
            UIUtils.SetTextByString(self.DressSuitProDesc, table.concat(_descList))
        else
            local _equipCfg = DataConfig.DataEquip[self.DressEquipData.CfgID]
            _suitCfg = GameCenter.EquipmentSuitSystem:GetEquipSuitCfgData(_equipCfg, 1)
            if _suitCfg ~= nil then
                self.DressSuitGo:SetActive(true)
                UIUtils.SetTextByEnum(self.DressSuitName, "C_UI_EQUIPTIPS_SUITATT", 0, #_suitCfg.NeedParts)
                local _descList = List:New();
                -- CUSTOM - ẩn hiện thị dòng kích hoạt
                -- local _readList = {1, 2, 4, 6};
                local _readList = { 1, 2, 3 };
                -- CUSTOM - ẩn hiện thị dòng kích hoạt
                for i = 1, #_readList do
                    local _needCount = _readList[i];
                    local _textColor = "9D9D9D";
                    local _showSuit = _suitCfg;
                    local _props = _showSuit.Props[_needCount];
                    if _props ~= nil then
                        for j = 1, #_props do
                            local _countColor = "9D9D9D"
                            if j ~= 1 then
                                _countColor = "9D9D9D00"
                            end
                            _descList:Add(UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_SUIT_TIPS"), _textColor, _countColor, _needCount, L_BattlePropTools.GetBattlePropName(_props[j][1]), L_BattlePropTools.GetBattleValueText(_props[j][1], _props[j][2])))
                        end
                    end
                end
                UIUtils.SetTextByString(self.DressSuitProDesc, table.concat(_descList))
            else
                self.DressSuitGo:SetActive(false)
            end
        end
    else
        -- CUSTOM - active = true để hiển thị tại tất cả trang bị
        -- self.DressSuitGo:SetActive(false)
        self.DressSuitGo:SetActive(true)
        -- CUSTOM - active = true để hiển thị tại tất cả trang bị
    end
end

function UINewEquipTipsForm:SetWillShowButton(type, list)
    local btnTrans = self.ButtonDic[type]
    if btnTrans == nil then
        Debug.LogError(type)
    end

    list:Add(btnTrans.transform)
    return btnTrans.transform
end

function UINewEquipTipsForm:OnSetPosition()
    if self.FromObj then
        local panel = UIUtils.FindPanel(self.Trans)
        local width = panel.root.manualWidth
        local hight = panel.root.manualHeight
        local scale = 1 / panel.root.transform.localScale.x
        local x = self.FromObj.transform.position.x * scale
        local y = (self.FromObj.transform.position.y - 2000) * scale
        if x > width / 2 - 500 then
            x = x - 500
        end
        -- Debug.LogError("-------", width)
        if x < width * -1 / 2 + 340 and self.DressBaseGo.activeSelf then
            x = x + 340
        end
        -- Debug.LogError("-------", x)
        UnityUtils.SetPosition(self.PosTrans, x / scale, 2000, 0)
    else
        UnityUtils.SetLocalPosition(self.PosTrans, 0, 0, 0)
    end
end
return UINewEquipTipsForm
