--作者： cy
--日期： 2019-04-26
--文件： UILianQiForgeStrengthForm.lua
--模块： UILianQiForgeStrengthForm
--描述： 炼器功能二级子面板：装备强化。上级面板为：锻造面板（UILianQiForgeForm）
------------------------------------------------
local L_UICheckBox = require "UI.Components.UICheckBox"
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_LeftItem = require("UI.Forms.UILianQiForgeStrengthForm.UILeftItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local UILianQiForgeStrengthForm = {
    --背包滑动块
    BagScroll            = nil,
    BagPanelScroll       = nil,
    --背包网格
    BagGrid              = nil,
    BagGridTrans         = nil,
    --背包格子
    BagItem              = nil,
    BagPanelItem         = nil,
    BagList              = List:New(),
    BagPanelList         = List:New(),
    EquipScrollView      = nil,
    EquipGrid            = nil, --左侧装备滑动GRID
    EquipItem            = nil, --左侧装备控件
    EquipDic             = Dictionary:New(), --左侧装备列表
    EquipIconsRootTrs    = nil, --左侧所有装备的Icon等
    EquipTextLabel       = nil, --右侧，最顶部的文字。装备名字+99
    AllLvAttTipsLabel    = nil, --全身强化总等级加成提示
    RightEquipItemTrs    = nil, --右侧装备Icon
    ProgressBar          = nil, --右侧进度条
    ProgressText         = nil, --右侧进度条数字
    AttributeGo          = nil, --右侧属性面板
    OldAttrTrs           = nil, --右侧属性：当前等级
    NewAttrTrs           = nil, --右侧属性：下一等级
    ItemCostItem         = nil, --道具消耗
    ItemCostList         = List:New(),
    ItemCostGrid         = nil,
    AllAttributePanel    = nil, --所有属性面板
    AllAttributeBtn      = nil, --显示所有属性按钮
    CloseAllAttributeBtn = nil, --关闭所有属性面板按钮
    AutoStrengthBtn      = nil, --一键强化按钮
    StrengthBtn          = nil, --强化按钮
    BgTexture            = nil, --texture
    CurSelectGo          = nil, --当前选中的左侧装备
    CurSelectPos         = 0, --当前选中的部位
    VfxID                = 9, --特效id
    VfxSkinCompo         = nil, --特效组件
    FlyItemGo            = nil, --飞行ICON
    FlyItemTween         = nil,
    --合成消耗装备
    MeterailEquipList    = List:New(),
    SelectEquipList      = List:New(),
    Max                  = 0,
    --背包父结点
    BagPanelGo           = nil,
    BackBtn              = nil,
    CurPer               = 0,
    listId               = List:New(),
    maxExpStrength       = 0,
    PutInBtn             = nil,
    PerLabel             = nil,
    CoinLabel            = nil,
    StoneList            = List:New(),
    FastBtn              = nil,
    Help                 = nil,
}

function UILianQiForgeStrengthForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiForgeStrengthForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiForgeStrengthForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ALLINFO, self.RefreshAllInfo)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.RefreshLeftEquipInfos)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_CHANGE_EQUIPMAXSTRENGTHLV, self.ChangeEquipMaxStrengthLv)
end

function UILianQiForgeStrengthForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UILianQiForgeStrengthForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UILianQiForgeStrengthForm:ChangeEquipMaxStrengthLv(obj, sender)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    --obj = 装备部位
    if obj[1] then
        local pos = obj[1]
        self:RefreshLeftEquipInfos()
        if _forgeSystem.StrengthPosLevelDic:ContainsKey(pos) then
            local _curPosNewStrengthInfo = _forgeSystem.StrengthPosLevelDic[pos]
            if _curPosNewStrengthInfo then
                local _curPosStrengthInfo = { level = _curPosNewStrengthInfo.level, exp = _curPosNewStrengthInfo.exp }
                if self.EquipDic:ContainsKey(pos) then
                    self.EquipDic[pos].StrInfo = _curPosStrengthInfo
                end
                self:RefreshRightInfos(pos, _curPosStrengthInfo)
            end
        end
    end
end

function UILianQiForgeStrengthForm:RefreshAllInfo(obj, sender)
    self:SetLeftItemRed()
    self:UpgradeLevel()
end

function UILianQiForgeStrengthForm:RegUICallback()
    UIUtils.AddBtnEvent(self.FastBtn, self.OnClickFastBtn, self)
    UIUtils.AddBtnEvent(self.StrengthBtn, self.OnClickStrengthBtn, self)
    UIUtils.AddBtnEvent(self.AutoStrengthBtn, self.OnClickAutoStrengthBtn, self)
    UIEventListener.Get(self.AllAttributeBtn.gameObject).onClick = Utils.Handler(self.OnClickAllAttributeBtn, self)
    UIUtils.AddBtnEvent(self.CloseAllAttributeBtn, self.OnClickCloseAllAttributeBtn, self)
    UIUtils.AddBtnEvent(self.BackBtn, self.OnBackClick, self)
    UIUtils.AddBtnEvent(self.PutInBtn, self.OnEquipPutin, self)
    self.CheckBox:SetOnClickFunc(Utils.Handler(self.OnClickCheckBox, self))
    UIEventListener.Get(self.DressBagBtn.gameObject).onClick = Utils.Handler(function()
        self:OnClickTab("Dress")
    end, self)
    UIEventListener.Get(self.BagBtn.gameObject).onClick = Utils.Handler(function()
        self:OnClickTab("Bag")
    end, self)
end

function UILianQiForgeStrengthForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiForgeStrengthForm:OnShowBefore()
    self.TotalLvNum = -1
end

function UILianQiForgeStrengthForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.BgTextureNext, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.AttrBgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_30_2"))
    self.CSForm:LoadTexture(self.BgBagPanel, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))

    self.BagBtn.isEnabled = false
    -- self:RefreshLeftEquipInfos(true)
    self:OpenBtnCheckPer()
    -- self:OnClickCheckBox(false)
    self:OnClickTab("Dress")
    self.BagPanelGo:SetActive(false)

    self.FlyPanel:SetActive(false)
    -- if self.EquipDic ~= nil then
    --     self:OnClickEquipItem(self.EquipDic[0])
    -- end
    if #self.EquipDic > 0 then
        local _count = 0
        local _clickGo = nil
        self.EquipDic:ForeachCanBreak(function(k, v)
            local _equip = v.ItemData
            if _equip then
                _clickGo = v
                _count = _count + 1
                return true
            end
        end)
        if _count == 0 then
            -- self:OnClickEquipItem(self.EquipDic[0])
            self:RefreshRightInfos(nil, nil)
        else
            self:OnClickEquipItem(_clickGo)
        end
    end
    self.AllAttributePanel.gameObject:SetActive(false)

    for i = 1, #self.MeterailEquipList do
        self.MeterailEquipList[i]:OnLock(false)
        self.MeterailEquipList[i].IsShowTips = false
    end

    for i = #self.SelectEquipList + 1, #self.MeterailEquipList do
        self.MeterailEquipList[i]:InitWithItemData(nil, 0)
    end
end

function UILianQiForgeStrengthForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

function UILianQiForgeStrengthForm:DestroyAllVfx()
    self.VfxSkinCompo:OnDestory()
end

function UILianQiForgeStrengthForm:OnHideBefore()
    self.CurSelectGo = nil
    self.CurSelectPos = 0
    self:DestroyAllVfx()
end

function UILianQiForgeStrengthForm:FindAllComponents()
    local _myTrans = self.Trans
    self.EquipIconsRootTrs = UIUtils.FindTrans(_myTrans, "Left/EquipIcons")
    self.EquipScrollView = UIUtils.FindScrollView(_myTrans, "Left/EquipRoot")
    self.EquipGrid = UIUtils.FindGrid(_myTrans, "Left/EquipRoot/Grid")
    local _gridTrans = UIUtils.FindTrans(_myTrans, "Left/EquipRoot/Grid")
    for i = 0, _gridTrans.childCount - 1 do
        self.EquipItem = L_LeftItem:OnFirstShow(_gridTrans:GetChild(i))
        self.EquipItem.CallBack = Utils.Handler(self.OnClickEquipItem, self)
        self.EquipDic:Add(i, self.EquipItem)
    end

    --------------------------------------
    ---
    self.FastBtn = UIUtils.FindBtn(_myTrans, "Right/Buttom/FastBtn")

    self.DressBagGo = UIUtils.FindGo(_myTrans, "Left/EquipRoot")
    self.DressBagBtn = UIUtils.FindBtn(_myTrans, "UIListMenu/Table/DressBag")
    self.BagGo = UIUtils.FindGo(_myTrans, "Left/BagContainer")
    self.BagTabGo = UIUtils.FindGo(_myTrans, "UIListMenu/Table/Bag")
    self.BagBtn = UIUtils.FindBtn(_myTrans, "UIListMenu/Table/Bag")
    self.DressBagGo:SetActive(false)
    self.BagGo:SetActive(false)
    self.BagTabGo:SetActive(false)

    self.BagGrid = UIUtils.FindGrid(_myTrans, "Left/BagContainer/Grid")
    self.BagGridGo = UIUtils.FindGo(_myTrans, "Left/BagContainer/Grid")
    self.BagGridTrans = UIUtils.FindTrans(_myTrans, "Left/BagContainer/Grid")
    for i = 0, self.BagGridTrans.childCount - 1 do
        self.BagItem = UILuaItem:New(self.BagGridTrans:GetChild(i))
        self.BagItem.IsShowTips = false
        -- self.BagItem.SingleClick = Utils.Handler(self.OnClickEquipItem, self)
        self.BagList:Add(self.BagItem)
    end
    self.BagScroll = UIUtils.FindScrollView(_myTrans, "Left/BagContainer")
    self.GetEquipBtn = UIUtils.FindBtn(_myTrans, "BagPanel/GetEquipBtn")
    self.PutInBtn = UIUtils.FindBtn(_myTrans, "BagPanel/Putin")
    self.BackBtn = UIUtils.FindBtn(_myTrans, "BagPanel/BgCollider")
    self.BagPanelGo = UIUtils.FindGo(_myTrans, "BagPanel")
    self.BgBagPanel = UIUtils.FindTex(_myTrans, "BagPanel/BgBagPanel")
    self.CSForm:AddTransNormalAnimation(self.BagPanelGo.transform, 50, 0.3)
    self.BagPanelGrid = UIUtils.FindGrid(_myTrans, "BagPanel/BagContainer/Grid")
    self.BagPanelGridGo = UIUtils.FindGo(_myTrans, "BagPanel/BagContainer/Grid")
    self.BagPanelGridTrans = UIUtils.FindTrans(_myTrans, "BagPanel/BagContainer/Grid")
    self.BagPanelScroll = UIUtils.FindScrollView(_myTrans, "BagPanel/BagContainer")
    for i = 0, self.BagPanelGridTrans.childCount - 1 do
        self.BagPanelItem = UILuaItem:New(self.BagPanelGridTrans:GetChild(i))
        self.BagPanelItem.IsShowTips = false
        self.BagPanelItem.SingleClick = Utils.Handler(self.OnEquipSelect, self)
        self.BagPanelList:Add(self.BagPanelItem)
    end

    --------------------------------------
    self.PerLabel = UIUtils.FindLabel(_myTrans, "Right/Buttom/NeckEquip/Per")
    self.CoinLabel = UIUtils.FindLabel(_myTrans, "Right/Buttom/NeckEquip/Coin/Num")

    self.CoinIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Right/Buttom/NeckEquip/Coin/CoinIcon"))
    -- self.CoinIcon:UpdateIcon(DataConfig.DataItem[ItemTypeCode.BindMoney].Icon)
    self.CoinQuality = UIUtils.FindSpr(_myTrans, "Right/Buttom/NeckEquip/Coin/Quality")
    -- self.CoinQuality.spriteName = Utils.GetQualitySpriteName(DataConfig.DataItem[ItemTypeCode.BindMoney].Color)
    self.CheckBox = L_UICheckBox:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/Buttom/CheckBoxTrans/CheckBox"))

    self.PerLabelInBag = UIUtils.FindLabel(_myTrans, "BagPanel/PerLabel")
    self.OverLabelInBag = UIUtils.FindLabel(_myTrans, "BagPanel/OverLabel")

    -- self.EquipTextLabel = UIUtils.FindLabel(_myTrans, "Right/EquipText")
    self.RightEquipItemTrs = UIUtils.FindTrans(_myTrans, "Right/Right/UIEquipmentItem")
    self.RightEquipItemNextTrs = UIUtils.FindTrans(_myTrans, "Right/Right/UIEquipmentItemNext")
    self.AttributeGo = UIUtils.FindGo(_myTrans, "Right/Right/Attribute")
    self.NoAttributeGo = UIUtils.FindGo(_myTrans, "Right/Right/NoAttr")
    self.AttrBgTexture = UIUtils.FindTex(_myTrans, "Right/Right/AttrBg")
    self.OldAttrTrs = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/Old")
    self.NewAttrTrs = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/New")
    self.ItemCostTrs = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemGrid")
    self.ItemCostGrid = UIUtils.FindGrid(_myTrans, "Right/Buttom/ItemGrid")
    for i = 0, self.ItemCostTrs.childCount - 1 do
        self.ItemCostItem = UILuaItem:New(self.ItemCostTrs:GetChild(i))
        self.ItemCostList:Add(self.ItemCostItem)
    end
    for i = 1, self.ItemCostTrs.childCount do
        local path = string.format("Right/Buttom/ItemGrid/%d", i)
        local e = UILuaItem:New(UIUtils.FindTrans(_myTrans, path))
        e.IsShowAddSpr = true
        self.MeterailEquipList:Add(e)
        e.SingleClick = Utils.Handler(self.OnMeteriEquipClick, self)
        e:SelectItem(false)
    end
    self.AllLvAttTipsLabel = UIUtils.FindLabel(_myTrans, "Right/Right/AllLvTips")
    self.AllAttributePanel = UIUtils.FindTrans(_myTrans, "Left/AllAttributePanel")
    self.CloseAllAttributeBtn = UIUtils.FindBtn(self.AllAttributePanel, "Back")
    self.AllAttributeBtn = UIUtils.FindTrans(_myTrans, "Right/Right/AllAttBtn")
    self.AutoStrengthBtn = UIUtils.FindBtn(_myTrans, "Right/Buttom/OneKeyStrengthBtn")
    self.AutoStrengthBtnRedGo = UIUtils.FindGo(_myTrans, "Right/Buttom/OneKeyStrengthBtn/RedPoint")
    self.StrengthBtn = UIUtils.FindBtn(_myTrans, "Right/Buttom/StrengthBtn")
    self.SelectStrengthBtnGo = UIUtils.FindGo(_myTrans, "Right/Buttom/StrengthBtn/Select")
    self.StrengthBtnRedGo = UIUtils.FindGo(_myTrans, "Right/Buttom/StrengthBtn/RedPoint")
    self.BgTexture = UIUtils.FindTex(_myTrans, "Right/Right/UIEquipmentItem/BgTexture")
    self.BgTextureNext = UIUtils.FindTex(_myTrans, "Right/Right/UIEquipmentItemNext/BgTexture")
    -- self.CurStrengLvLabel = UIUtils.FindLabel(_myTrans, "Right/Right/StrLv")
    -- self.CurStrengLvNextLabel = UIUtils.FindLabel(_myTrans, "Right/Right/StrLvNext")


    local _vfxTrs = UIUtils.FindTrans(self.RightEquipItemTrs, "MyUIVfxSkinCompoent")
    self.VfxSkinCompo = UIUtils.RequireUIVfxSkinCompoent(_vfxTrs)
    self.FlyPanel = UIUtils.FindGo(_myTrans, "Fly")
    self.FlyItemTrans = UIUtils.FindTrans(_myTrans, "Fly/FlyItem")
    self.FlyItem = UILuaItem:New(self.FlyItemTrans)
    self.FlyItemTween = UIUtils.FindTweenPosition(_myTrans, "Fly/FlyItem")
    UIUtils.AddEventDelegate(self.FlyItemTween.onFinished, self.OnFlyComplete, self)

    self.EquipRightTrans = UIUtils.FindTrans(_myTrans, "Right/Right")
    self.CSForm:AddAlphaScaleAnimation(self.EquipRightTrans, 0, 1, 1.2, 1.2, 1, 1, 0.3, true, false)
    self.EquipButtomTrans = UIUtils.FindTrans(_myTrans, "Right/Buttom")
    self.CSForm:AddAlphaPosAnimation(self.EquipButtomTrans, 0, 1, 0, -50, 0.3, false, false)
    self.Help = UIUtils.FindBtn(_myTrans, "Right/Help")
    UIUtils.AddBtnEvent(self.Help, self.OnClickBtnHelp, self)

end

function UILianQiForgeStrengthForm:OnClickBtnHelp()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, UnityUtils.GetObjct2Int(FunctionStartIdCode.LianQiForgeStrength))
end
----------------------------------------
function UILianQiForgeStrengthForm:OnClickFastBtn()
    self.SelectEquipList:Clear()
    local list = self:OnGetBagItemStrengthList()
    if list and list.Count > 0 then
        for i = 1, list.Count do
            if i <= #self.MeterailEquipList then
                self.SelectEquipList:Add(list[i - 1])
            else
                return
            end
            self:OnSetPerLabel()
            self:SetPerLabelInBag()
        end
    end

end

function UILianQiForgeStrengthForm:OpenBtnCheckPer()
    if self.CurPer >= 10 then
        self.SelectStrengthBtnGo:SetActive(true)
        self.StrengthBtn.isEnabled = true
    else
        self.SelectStrengthBtnGo:SetActive(false)
        self.StrengthBtn.isEnabled = false
    end
end

function UILianQiForgeStrengthForm:ChangeMoneyIcon(type)
    self.CoinIcon:UpdateIcon(DataConfig.DataItem[type].Icon)
    self.CoinQuality.spriteName = Utils.GetQualitySpriteName(DataConfig.DataItem[type].Color)
end

function UILianQiForgeStrengthForm:OnClickCheckBox(check)
    if check == false then
        self:ChangeMoneyIcon(ItemTypeCode.BindMoney)
    else
        self:ChangeMoneyIcon(ItemTypeCode.Lingshi)
    end
end

--点击材料装备
function UILianQiForgeStrengthForm:OnMeteriEquipClick(equip)
    self.CurPos = 0
    self.CurPos = tonumber(equip.RootTrans.name)
    if self.CurPos > 0 and self.CurPos <= self.ItemCostTrs.childCount then
        if (self.MeterailEquipList[self.CurPos].ShowItemData ~= nil and self.IsNeick) then
            GameCenter.ItemTipsMgr:ShowTips(self.MeterailEquipList[self.CurPos].ShowItemData, self.MeterailEquipList[self.CurPos].RootGO, ItemTipsLocation.Nomal)
            return
        elseif (self.MeterailEquipList[self.CurPos].ShowItemData ~= nil and not self.IsNeick) then
            if self.SelectEquipList:Contains(self.MeterailEquipList[self.CurPos].ShowItemData) then
                self.SelectEquipList:Remove(self.MeterailEquipList[self.CurPos].ShowItemData)
            end
            self:OnSetPerLabel()
            self:SetAutoBuyNum()
        elseif (self.MeterailEquipList[self.CurPos].ShowItemData == nil and not self.IsNeick) then
            self:OnUpdateBagPanelEquipList()
        end
    end


end

function UILianQiForgeStrengthForm:OnEquipPutin()
    if self.SelectEquipList ~= nil and #self.SelectEquipList > 0 then
        self:OnBackClick()
        self:SetAutoBuyNum()
    else
        Utils.ShowPromptByEnum("UI_EQUIP_SELECTEQUIP")
    end
end

function UILianQiForgeStrengthForm:OnClickTab(tabType)
    -- Ẩn cả 2 tab
    self.BagGo:SetActive(false)
    self.DressBagGo:SetActive(false)

    -- Mở tab được chọn
    if tabType == "Bag" then
        -- self.BagGo:SetActive(true)
        -- self:OnUpdateBagEquipList()
    elseif tabType == "Dress" then
        self.CurSelectGo = nil
        self.DressBagGo:SetActive(true)
        self:RefreshLeftEquipInfos(true)
        if #self.EquipDic > 0 then
            local _count = 0
            local _clickGo = nil
            self.EquipDic:ForeachCanBreak(function(k, v)
                local _equip = v.ItemData
                if _equip then
                    _clickGo = v
                    _count = _count + 1
                    return true
                end
            end)
            if _count == 0 then
                self.RightEquipItem = UILuaItem:New(self.RightEquipItemTrs)
                self.RightEquipItemNext = UILuaItem:New(self.RightEquipItemNextTrs)
                self.RightEquipItem:InitWithItemData()
                self.RightEquipItemNext:InitWithItemData()
            else
                self:OnClickEquipItem(_clickGo)
            end
        end
        -- self.EquipDic[0]:OnSetSelect(true)
    end
end

function UILianQiForgeStrengthForm:OnGetBagEquipmentList()
    local list = nil
    -- local _partList = List:New()
    -- if self.CurCfg.JoinPart and self.CurCfg.JoinPart ~= "" then
    --     _partList = Utils.SplitNumber(self.CurCfg.JoinPart, '_')
    -- end
    -- if not self.IsNeick then
    local _allEquip = GameCenter.EquipmentSystem:GetAllEquipByBag()
    --     list = GameCenter.EquipmentSystem:GetEquipCanSyn(_allEquip, self.CurCfg.Professional, self.CurSelect.ItemData.Grade, self.QualityList, self.StarList, _partList);
    -- end
    local list = _allEquip
    return list;
end

-- 获取可合成装备
function UILianQiForgeStrengthForm:OnGetBagItemStrengthList()
    -- local list = nil
    -- local _partList = List:New()
    -- if self.CurCfg.JoinPart and self.CurCfg.JoinPart ~= "" then
    --     _partList = Utils.SplitNumber(self.CurCfg.JoinPart, '_')
    -- end
    -- if not self.IsNeick then
    --     local _allEquip = GameCenter.EquipmentSystem:GetAllEquipByBag()
    --     list = GameCenter.EquipmentSystem:GetEquipCanSyn(_allEquip, self.CurCfg.Professional, self.CurSelect.ItemData.Grade, self.QualityList, self.StarList, _partList);
    -- end
    local list = GameCenter.ItemContianerSystem:GetItemListByCfgidList(self.listId)
    return list;
end

-- 刷新背包中装备
function UILianQiForgeStrengthForm:OnUpdateBagEquipList()
    local list = nil
    list = self:OnGetBagEquipmentList()
    if list and list.Count > 0 then
        self.BagGridGo:SetActive(true)
        self.CSForm:PlayShowAnimation(self.BagGo.transform)
        --self.BagGo:SetActive(true)
    else
        -- self:OnShowEquipQuickGetForm()
        return
    end
    -- self:SetPerLabelInBag()
    self.BagScroll:ResetPosition()
    local maxPerLine = self.BagGrid.maxPerLine
    local maxCount = math.ceil(self.BagScroll.panel.height / self.BagGrid.cellHeight)
    maxCount = maxCount * maxPerLine
    local fillCount = list.Count < maxCount and maxCount or list.Count
    fillCount = fillCount < #self.BagList and #self.BagList or fillCount
    for i = 0, fillCount - 1 do
        local trans = nil;
        local equip = nil;
        if list.Count > i then
            equip = list[i]
        end
        if #self.BagList <= i then
            -- 格子不够时，加载一排
            for index = i % maxPerLine, maxPerLine - 1 do
                trans = self.BagItem:Clone()
                trans.SingleClick = Utils.Handler(self.OnClickEquipItem, self)
                trans.IsShowTips = false
                self.BagList:Add(trans)
            end
        end
        trans = self.BagList[i + 1]
        self:OnFillCell(trans, equip)
    end
    for i = fillCount + 1, #self.BagList do
        self:OnFillCell(self.BagList[i], nil)
    end

    self.BagGrid.repositionNow = true
end

function UILianQiForgeStrengthForm:OnUpdateBagPanelEquipList()
    local list = nil
    list = self:OnGetBagItemStrengthList()
    -- if list and list.Count > 0 then
    --     
    --     --self.BagGo:SetActive(true)
    -- else
    --     -- self:OnShowEquipQuickGetForm()
    --     return
    -- end
    self.BagPanelGridGo:SetActive(true)
    self.CSForm:PlayShowAnimation(self.BagPanelGo.transform)

    self:SetPerLabelInBag()
    self.BagPanelScroll:ResetPosition()
    local maxPerLine = self.BagPanelGrid.maxPerLine
    local maxCount = math.ceil(self.BagPanelScroll.panel.height / self.BagPanelGrid.cellHeight)
    maxCount = maxCount * maxPerLine
    local fillCount = list.Count < maxCount and maxCount or list.Count
    fillCount = fillCount < #self.BagPanelList and #self.BagPanelList or fillCount
    for i = 0, fillCount - 1 do
        local trans = nil;
        local equip = nil;
        if list.Count > i then
            equip = list[i]
        end
        if #self.BagPanelList <= i then
            -- 格子不够时，加载一排
            for index = i % maxPerLine, maxPerLine - 1 do
                trans = self.BagPanelItem:Clone()
                trans.SingleClick = Utils.Handler(self.OnEquipSelect, self)
                trans.IsShowTips = false
                self.BagPanelList:Add(trans)
            end
        end
        trans = self.BagPanelList[i + 1]
        self:OnFillCell(trans, equip)
    end
    for i = fillCount + 1, #self.BagPanelList do
        self:OnFillCell(self.BagPanelList[i], nil)
    end

    self.BagPanelGrid.repositionNow = true
end
function UILianQiForgeStrengthForm:OnSetPerLabel()
    local index = 0;
    local per = 0
    local _effectNum = ""
    for i = 1, #self.SelectEquipList do
        _effectNum = self.SelectEquipList[i].ItemInfo.EffectNum
        if _effectNum ~= nil then
            local _arr = Utils.SplitNumber(_effectNum, '_')
            -- local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.SelectEquipList[i].CfgID)
            local _haveNum = self.SelectEquipList[i].Count
            local _basePer = 0
            _basePer = _arr[2] / self.maxExpStrength * 100 * _haveNum
            per = per + _basePer
            if i <= #self.MeterailEquipList then
                self.MeterailEquipList[i]:InitWithItemData(self.SelectEquipList[i])
            end
        end
        -- if self.SelectEquipList[i].CfgID == 60002 then
        --     _basePer = maxExpStrength
        -- end
    end
    for i = #self.SelectEquipList + 1, #self.MeterailEquipList do
        self.MeterailEquipList[i]:InitWithItemData(nil, 0)
    end
    -- if self.CurCfg ~= nil then
    --         self.LevelPerList = Utils.SplitNumber(self.CurCfg.JoinNumProbability, '_')
    --         self.QualityPerList = Utils.SplitNumber(self.CurCfg.QualityNumber, '_')
    --         self.StarPerList = Utils.SplitNumber(self.CurCfg.DiamondNumber, '_')
    --         self.NormalEquipGo:SetActive(#self.SelectEquipList >= #self.MeterailEquipList)
    --         UIUtils.SetTextFormat(self.EquipCountLabel, "X{0}", #self.SelectEquipList)
    --         for i = 1, #self.SelectEquipList do
    --             local _basePer = 0
    --             if self.SelectEquipList[i].Grade == self.CurSelect.ItemData.Grade then
    --                 _basePer = self.LevelPerList[1]
    --             elseif self.SelectEquipList[i].Grade > self.CurSelect.ItemData.Grade then
    --                 _basePer = self.LevelPerList[2]
    --             elseif self.SelectEquipList[i].Grade == self.CurSelect.ItemData.Grade - 1 then
    --                 _basePer = self.LevelPerList[3]
    --             elseif self.SelectEquipList[i].Grade <= self.CurSelect.ItemData.Grade - 2 then
    --                 _basePer = self.LevelPerList[4]
    --             end
    --             local _findIndex = 0
    --             for j = 1, #self.QualityList do
    --                 if self.SelectEquipList[i].Quality == self.QualityList[j] then
    --                     _findIndex = j
    --                 end
    --             end
    --             if self.QualityPerList[_findIndex] and _basePer then
    --                 _basePer = _basePer * self.QualityPerList[_findIndex] / 10000
    --             end
    --             _findIndex = 0
    --             for j = 1, #self.StarList do
    --                 if self.SelectEquipList[i].StarNum == self.StarList[j] then
    --                     _findIndex = j
    --                 end
    --             end
    --             if self.StarPerList[_findIndex] and _basePer then
    --                 _basePer = _basePer * self.StarPerList[_findIndex] / 10000
    --             end
    --             if not _basePer then
    --                 _basePer = 0
    --             end
    --             per = per + _basePer
    --             if i <= #self.MeterailEquipList then
    --                 self.MeterailEquipList[i]:InitWithItemData(self.SelectEquipList[i])
    --             end
    --         end
    --         for i =  #self.SelectEquipList + 1, #self.MeterailEquipList do
    --             self.MeterailEquipList[i]:InitWithItemData(nil, 0)
    --         end
    -- end
    self.CurPer = per
    if self.CurPer > 100 then
        UIUtils.SetTextByEnum(self.PerLabel, "Percent", 100)
        self:OpenBtnCheckPer()
        -- UIUtils.SetTextByEnum(self.NeckPerLabel, "Percent", 100)
    else
        local showPer = math.floor(per * 10 + 0.5) / 10
        UIUtils.SetTextByEnum(self.PerLabel, "Percent", showPer)
        self:OpenBtnCheckPer()
        -- UIUtils.SetTextByEnum(self.NeckPerLabel, "Percent", per / 100)
    end
end

function UILianQiForgeStrengthForm:SetAutoBuyNum()
    local _needNum = 0
    local _needPer = 0
    local _basePer = 0
    if self.LevelPerList and self.LevelPerList[1] then
        _basePer = self.LevelPerList[1]
    end
    if _basePer and _basePer > 0 and self.CurPer < 10000 then
        while (true) do
            _needNum = _needNum + 1
            _needPer = _needPer + _basePer
            if _needPer + self.CurPer >= 10000 then
                break
            end
        end
    end
    self.NeedCoin = 0
    if _needNum > 0 and not self.IsNeick then
        self.NeedCoin = _needNum * self:GetSingleEquipCost()
    end
    if self.NeedItemID and not self.MeterailItem.IsEnough then
        local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.NeedItemID)
        if haveNum < self.NeedItemNum then
            _needNum = self.NeedItemNum - haveNum
            local _itemCoin = _needNum * self.NeedItemPrice
            self.NeedCoin = self.NeedCoin + _itemCoin
        end
    end
    if self.NeedCoin > 0 then
        local _haveCoin = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.Lingshi)
        if _haveCoin < self.NeedCoin then
            UIUtils.SetTextByEnum(self.CoinTips, "C_UI_EQUIPSYNTH_AUTOEQUIP2", self.NeedCoin)
        else
            UIUtils.SetTextByEnum(self.CoinTips, "C_UI_EQUIPSYNTH_AUTOEQUIP3", self.NeedCoin)
        end
    else
        UIUtils.SetTextByEnum(self.CoinTips, "C_UI_EQUIPSYNTH_AUTOEQUIP3", self.NeedCoin)
    end
end

function UILianQiForgeStrengthForm:SetPerLabelInBag()
    if self.CurPer > 100 then
        UIUtils.SetTextByEnum(self.PerLabelInBag, "Percent", 100)
        local overPer = math.floor((self.CurPer - 100) * 10 + 0.5) / 10
        UIUtils.SetTextByEnum(self.OverLabelInBag, "C_EQUIPSYN_PEROVER_TIPS", overPer)
        self:OpenBtnCheckPer()
    else
        local showPer = math.floor(self.CurPer * 10 + 0.5) / 10
        UIUtils.SetTextByEnum(self.PerLabelInBag, "Percent", showPer)
        UIUtils.ClearText(self.OverLabelInBag)
        self:OpenBtnCheckPer()
    end
end

function UILianQiForgeStrengthForm:OnEquipSelect(item)
    if item.ShowItemData then
        if self.SelectEquipList:Contains(item.ShowItemData) then
            self.SelectEquipList:Remove(item.ShowItemData)
            item:SelectItem(false)
        else
            if #self.SelectEquipList < #self.MeterailEquipList then
                item:SelectItem(true)
                self.SelectEquipList:Add(item.ShowItemData)
            else
                Debug.Log("Đã đầy ô có thể bỏ đá vào")
            end
        end
        self:OnSetPerLabel()
        self:SetAutoBuyNum()
        self:SetPerLabelInBag()
    end
end

function UILianQiForgeStrengthForm:OnFillCell(trans, equip)
    trans:InitWithItemData(equip)
    trans:SelectItem(self.SelectEquipList:Contains(equip))
end


-- 装备列表背景点击
function UILianQiForgeStrengthForm:OnBackClick()
    self.CurPos = 0
    self.CSForm:PlayHideAnimation(self.BagPanelGo.transform)
    --self.BagGo:SetActive(false)
end

----------------------------------------







function UILianQiForgeStrengthForm:OnClickCloseAllAttributeBtn()
    self.AllAttributePanel.gameObject:SetActive(false)
end

function UILianQiForgeStrengthForm:OnClickAllAttributeBtn()
    -- self.AllAttributePanel.gameObject:SetActive(true)
    -- local _totalLv = GameCenter.LianQiForgeSystem:GetTotalStrengthLv()
    -- local _curLvLab = UIUtils.FindLabel(self.AllAttributePanel, "CurLevel")
    -- UIUtils.SetTextByNumber(_curLvLab, _totalLv)
    -- local _curCfg, _nextCfg = self:GetCurAndNextCfg(_totalLv)
    -- --当前已获得属性
    -- local _getLevelInfoTrs = UIUtils.FindTrans(self.AllAttributePanel, "GetLevelInfo")
    -- local _getTotalLvLab = UIUtils.FindLabel(_getLevelInfoTrs, "TotalLevel")
    -- if _curCfg.Id == 0 then
    --     _getLevelInfoTrs.gameObject:SetActive(false)
    -- else
    --     _getLevelInfoTrs.gameObject:SetActive(true)
    --     UIUtils.SetTextByNumber(_getTotalLvLab, _curCfg.Level)
    --     local _getAttrs = Utils.SplitStrByTableS(_curCfg.Value1, { ';', '_' })
    --     self:SetAllAttrText(true, 1, _getAttrs[1])
    --     self:SetAllAttrText(true, 2, _getAttrs[2])
    --     self:SetAllAttrText(true, 3, _getAttrs[3])
    --     self:SetAllAttrText(true, 4, _getAttrs[4])
    -- end
    -- local _nextLevelInfoTrs = UIUtils.FindTrans(self.AllAttributePanel, "NextLevelInfo")
    -- local _nextTotalLvLab = UIUtils.FindLabel(_nextLevelInfoTrs, "TotalLevel")
    -- if _nextCfg.Id == -1 then
    --     _nextLevelInfoTrs.gameObject:SetActive(false)
    -- else
    --     _nextLevelInfoTrs.gameObject:SetActive(true)
    --     UIUtils.SetTextByNumber(_nextTotalLvLab, _nextCfg.Level)
    --     local _nextAttrs = Utils.SplitStrByTableS(_nextCfg.Value1, { ';', '_' })
    --     self:SetAllAttrText(false, 1, _nextAttrs[1])
    --     self:SetAllAttrText(false, 2, _nextAttrs[2])
    --     self:SetAllAttrText(false, 3, _nextAttrs[3])
    --     self:SetAllAttrText(false, 4, _nextAttrs[4])
    -- end
    GameCenter.PushFixEvent(UILuaEventDefine.UILianQiStrengthAllAttrForm_OPEN)
end

function UILianQiForgeStrengthForm:GetCurAndNextCfg(totalLv)
    --该表id从1开始，因此可以用“#”取长度
    local _curCfg = nil
    local _nextCfg = nil
    local _cfgLength = DataConfig.DataEquipIntenClass.Count
    DataConfig.DataEquipIntenClass:ForeachCanBreak(function(k, v)
        v.Id = k
        --和前n-1个数据作对比（因为要和“当前条目”和“下一条目”的等级作对比）
        if k < _cfgLength then
            if totalLv >= v.Level and totalLv < DataConfig.DataEquipIntenClass[k + 1].Level then
                _curCfg = v
                _nextCfg = DataConfig.DataEquipIntenClass[k + 1]
                return true
            end
            if k == 1 and totalLv < v.Level then
                _curCfg = v
                _curCfg.Id = 0
                _nextCfg = v
                return true
            end
        else
            --如果到了最后一条数据还没return
            if not _curCfg and not _nextCfg then
                local _cfg = Utils.DeepCopy(v)
                --Id == -1表示已达最高级
                _cfg.Id = -1
                _curCfg = v
                _nextCfg = _cfg
            end
        end
    end)
    return _curCfg, _nextCfg--, Utils.DeepCopy(DataConfig.DataEquipIntenClass[1])
end

function UILianQiForgeStrengthForm:SetAllAttrText(isCurrent, index, attr)
    if isCurrent then
        local _getAttrLab = UIUtils.FindLabel(self.AllAttributePanel, string.format("GetLevelInfo/Attr%d", index))
        local _getAttrNameLab = UIUtils.FindLabel(self.AllAttributePanel, string.format("GetLevelInfo/Attr%d/Txt", index))
        if attr then
            _getAttrLab.gameObject:SetActive(true)
            local _attrCfg = DataConfig.DataAttributeAdd[attr[1]]
            local _txt = _attrCfg.ShowPercent == 0 and tostring(attr[2]) or string.format("%s%%", tostring(math.FormatNumber(attr[2] / 100)))
            UIUtils.SetTextByString(_getAttrLab, _txt)
            if _attrCfg then
                UIUtils.SetTextByString(_getAttrNameLab, _attrCfg.Name .. ":")
            end
        else
            _getAttrLab.gameObject:SetActive(false)
        end
    else
        local _nextAttrLab = UIUtils.FindLabel(self.AllAttributePanel, string.format("NextLevelInfo/Attr%d", index))
        local _nextAttrNameLab = UIUtils.FindLabel(self.AllAttributePanel, string.format("NextLevelInfo/Attr%d/Txt", index))
        if attr then
            _nextAttrLab.gameObject:SetActive(true)
            local _attrCfg = DataConfig.DataAttributeAdd[attr[1]]
            local _txt = _attrCfg.ShowPercent == 0 and tostring(attr[2]) or string.format("%s%%", tostring(math.FormatNumber(attr[2] / 100)))
            UIUtils.SetTextByString(_nextAttrLab, _txt)
            if _attrCfg then
                UIUtils.SetTextByString(_nextAttrNameLab, _attrCfg.Name .. ":")
            end
        else
            _nextAttrLab.gameObject:SetActive(false)
        end
    end
end

function UILianQiForgeStrengthForm:OnClickStrengthBtn()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurSelectPos)
    local _strenthInfo = self.EquipDic[self.CurSelectPos].StrInfo
    if _equip == nil then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
    else
        --部位的最高强化等级
        local _posIntenMaxLv = _forgeSystem.StrengthMaxLevel
        --当前装备的最高强化等级
        local _equipIntenMaxLv = _equip.ItemInfo.LevelMax
        self.StoneList = List:New()
        local _indexArr = 1
        if _strenthInfo.level < _equipIntenMaxLv then
            for i = 1, #self.listId do
                if self.listId[i] ~= nil then
                    local num = 0
                    for j = 1, #self.SelectEquipList do
                        if self.SelectEquipList[j].CfgID == self.listId[i] then
                            num = num + 1
                        end
                    end
                    if num ~= 0 then
                        local info = { index = _indexArr, itemId = self.listId[i], value = num }
                        self.StoneList:Add(info)
                        _indexArr = _indexArr + 1
                    end
                end
            end
            -- for i = 1, #self.ItemCostList do

            --     if not self.ItemCostList[i].IsEnough and self.ItemCostList[i].ShowItemData and self.ItemCostList[i].RootGO.activeSelf then
            --         GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.ItemCostList[i].ShowItemData.CfgID)
            --         return
            --     end

            -- local type = 1;
            -- local infos = List:New()
            -- for i = 1, #self.StoneList do
            --     local info = {item = 31231321, value = 1}
            --     infos:Add(info)
            -- end
            self.tempLevel = _strenthInfo.level
            _forgeSystem:ReqEquipStrengthUpLevel(self.CurSelectPos, self.StoneList)


        else
            if _strenthInfo.level < _posIntenMaxLv then
                --提示“已达装备最高强化等级”
                Utils.ShowPromptByEnum("LIANQI_FORGE_MAXEQUIPSTRENGTHLV")
            else
                --提示“已达部位最高强化等级”
                Utils.ShowPromptByEnum("LIANQI_FORGE_MAXPOSSTRENGTHLV")
            end
        end
    end
end

function UILianQiForgeStrengthForm:OnClickAutoStrengthBtn()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    self:OnClickEquipItem(self.EquipDic[_forgeSystem:GetAutoUpPos()])
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurSelectPos)
    local _strenthInfo = self.EquipDic[self.CurSelectPos].StrInfo
    if _equip == nil then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
    else
        --部位的最高强化等级
        local _posIntenMaxLv = _forgeSystem.StrengthMaxLevel
        --当前装备的最高强化等级
        local _equipIntenMaxLv = _equip.ItemInfo.LevelMax
        if _strenthInfo.level < _equipIntenMaxLv then
            for i = 1, #self.ItemCostList do
                if not self.ItemCostList[i].IsEnough and self.ItemCostList[i].ShowItemData and self.ItemCostList[i].RootGO.activeSelf then
                    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.ItemCostList[i].ShowItemData.CfgID)
                    return
                end
            end
            _forgeSystem:ReqEquipStrengthUpLevel(self.CurSelectPos)
        else
            if _strenthInfo.level < _posIntenMaxLv then
                --提示“已达装备最高强化等级”
                Utils.ShowPromptByEnum("LIANQI_FORGE_MAXEQUIPSTRENGTHLV")
            else
                --提示“已达部位最高强化等级”
                Utils.ShowPromptByEnum("LIANQI_FORGE_MAXPOSSTRENGTHLV")
            end
        end
    end
end

function UILianQiForgeStrengthForm:OnClickEquipItem(go)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _pos = go.Pos
    if go.ItemData == nil then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
        return ;
    end
    if self.CurSelectGo == go then
        do return end
    else
        local oldPos = self.CurSelectPos

        self.CurSelectPos = _pos
        self.CurSelectGo = go
        self.CurCfg = go.CurCfg
        
        --当前选中部位的更新
        if _forgeSystem.StrengthPosLevelDic:ContainsKey(_pos) then
            local _curPosNewStrengthInfo = _forgeSystem.StrengthPosLevelDic[_pos]
            local _curPosStrengthInfo = { level = _curPosNewStrengthInfo.level, exp = _curPosNewStrengthInfo.exp }
            if self.EquipDic:ContainsKey(_pos) then
                self.EquipDic[_pos].StrInfo = _curPosStrengthInfo
            end
            
            self:RefreshRightInfos(_pos, _curPosStrengthInfo)
            
            --if self.EquipDic[self.CurSelectPos] then
            --    self.EquipDic[self.CurSelectPos]:OnSetSelect(false)
            --end
            if oldPos and self.EquipDic[oldPos] then
                self.EquipDic[oldPos]:OnSetSelect(false)
            end
            if self.EquipDic[_pos] then
                self.EquipDic[_pos]:OnSetSelect(true)
            end
        end
    end
    --self.CurSelectPos = _pos
    --self.CurSelectGo = go
    --self.CurCfg = self.CurSelectGo.CurCfg
    self.FlyItem:InitWithItemData(self.CurSelectGo.ItemData)
    self.FlyItemTrans.position = self.CurSelectGo.Trans.position
    self.FlyItemTween.from = self.FlyItemTrans.localPosition
    self.FlyPanel:SetActive(true)
    self.FlyItemTween:ResetToBeginning()
    self.FlyItemTween:Play(true)
end

function UILianQiForgeStrengthForm:RightEquipItemOnClick(go)
    local _equipItem = go
    if _equipItem.ShowItemData ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(_equipItem.ShowItemData, go.RootGO, ItemTipsLocation.EquipDisplay)
    end
end

function UILianQiForgeStrengthForm:RefreshLeftEquipInfos(playAnim, sender)
    self:RefreshLeftEquipIcons(playAnim)
end

function UILianQiForgeStrengthForm:RefreshLeftEquipIcons(playAnim)
    local _animList = nil
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end
    for i = 0, EquipmentType.Count - 1 do
        local _item = nil
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)

        local hasEquip = (_equip ~= nil)
        local isBasicSlot = (i <= EquipmentType.FingerRing)
        -- if  _equip ~= nil then
        if isBasicSlot or hasEquip then
            local _forgeSystem = GameCenter.LianQiForgeSystem
            if self.EquipDic:ContainsKey(i) then
                _item = self.EquipDic[i]
            else
                _item = self.EquipItem:Clone()
                _item.CallBack = Utils.Handler(self.OnClickEquipItem, self)
                self.EquipDic:Add(i, _item)
            end
            if _item then
                local _starLv = 0
                local _strinfo = nil
                if _forgeSystem.StrengthPosLevelDic:ContainsKey(i) then
                    local _strengthInfo = _forgeSystem.StrengthPosLevelDic[i]
                    if _equip then
                        if _strengthInfo.level > _equip.ItemInfo.LevelMax then
                            _starLv = _equip.ItemInfo.LevelMax
                        else
                            _starLv = _strengthInfo.level
                        end
                    else
                        _starLv = _strengthInfo.level
                    end
                    _strinfo = { level = _starLv, exp = _strengthInfo.exp }
                end
                _item:SetInfo(i, _equip, _strinfo)
                _item:OnSetSelect(false)

                if playAnim then
                    _animList:Add(_item.Trans)
                end
            end
        end
    end

    if playAnim then
        self.EquipGrid:Reposition()
        self.EquipScrollView:ResetPosition()
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 30, 0.2, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
        end
        self.AnimPlayer:AddTrans(self.EquipRightTrans, 0)
        self.AnimPlayer:AddTrans(self.EquipButtomTrans, 0.2)
        self.AnimPlayer:Play()
    end
end

function UILianQiForgeStrengthForm:SetLeftStrengthLvByPos(pos, strenthInfo)
    if strenthInfo then
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        if self.EquipDic:ContainsKey(pos) then
            if _equip then
                if strenthInfo.level > _equip.ItemInfo.LevelMax then
                    self.EquipDic[pos]:SetStrengthLv(_equip.ItemInfo.LevelMax)
                else
                    self.EquipDic[pos]:SetStrengthLv(strenthInfo.level)
                end
            else
                self.EquipDic[pos]:SetStrengthLv(strenthInfo.level)
            end
        end
    end
end

--刷新各部位红点
function UILianQiForgeStrengthForm:SetLeftItemRed()
    self.EquipDic:Foreach(function(k, v)
        v:SetRed()
    end)
end

--根据强化信息，更新右侧各种属性、等级、进度条等内容
function UILianQiForgeStrengthForm:RefreshRightInfos(pos, strengthInfo)
    self.CurPer = 0
    self:OpenBtnCheckPer()
    UIUtils.SetTextByEnum(self.PerLabel, "Percent", 0)
    self.StrengthBtn.isEnabled = false
    self.FastBtn.isEnabled = true
    self.SelectEquipList:Clear()
    for i = 1, #self.MeterailEquipList do
        self.MeterailEquipList[i]:OnLock(false)
        self.MeterailEquipList[i].IsShowTips = false
        self.MeterailEquipList[i]:InitWithItemData(nil, 0)
    end
    self.StoneList:Clear()
    if strengthInfo then
        local _strengthInfo = { type = pos, level = strengthInfo.level, exp = strengthInfo.exp }
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(_strengthInfo.type)
        --如果当前部位强化等级 > 当前装备所能容纳的强化上限。做相应处理
        if _equip ~= nil and _strengthInfo.level >= _equip.ItemInfo.LevelMax then
            _strengthInfo.level = _equip.ItemInfo.LevelMax
            local _cfgID = self:GetCfgID(_strengthInfo.type, _strengthInfo.level)
            local _cfg = DataConfig.DataEquipIntenMain[_cfgID]
            _strengthInfo.exp = _cfg.ProficiencyMax
            for i = 1, #self.MeterailEquipList do
                self.MeterailEquipList[i]:OnLock(true)
                self.MeterailEquipList[i].IsShowTips = false
                self.MeterailEquipList[i]:InitWithItemData(nil, 0)
            end
            self.FastBtn.isEnabled = false
        end
        --装备信息
        UIUtils.SetTextByString(self.EquipTextLabel, _equip ~= nil and string.format("%s+%s", _equip.Name, _strengthInfo.level) or "")

        if not self.RightEquipItem then
            self.RightEquipItem = UILuaItem:New(self.RightEquipItemTrs)
            -------------
            self.RightEquipItemNext = UILuaItem:New(self.RightEquipItemNextTrs)
            -------------
        end
        --右侧的装备icon，禁用点击事件
        self.RightEquipItem.SingleClick = Utils.Handler(self.RightEquipItemOnClick, self)
        if _equip ~= nil then
            self.RightEquipItem:InitWithItemData(_equip)
            self.RightEquipItemNext:InitWithItemData(_equip)
        else
            self.RightEquipItem:InitWithItemData()
            self.RightEquipItemNext:InitWithItemData()
        end
        --属性
        self:SetAttributeInfo(_strengthInfo.type, _strengthInfo.level)
        local _cfgID = self:GetCfgID(_strengthInfo.type, _strengthInfo.level)
        local _cfg = DataConfig.DataEquipIntenMain[_cfgID]
        --消耗
        self.listId:Clear()
        if _cfg then
            local _itemArr = Utils.SplitStr(_cfg.Consume, ';')
            local _item = nil
            for i = 1, #_itemArr do
                local _singleArr = Utils.SplitNumber(_itemArr[i], '_')

                for j = 1, #_singleArr - 1 do
                    self.listId:Add(_singleArr[j])
                end
                self.maxExpStrength = _singleArr[#_singleArr]
            end
            
            local _arrCoin = Utils.SplitNumber(_cfg.ConsumeCoin, '_')
            local haveCoin = GameCenter.ItemContianerSystem:GetEconomyWithType(_arrCoin[1])
            self.CoinIcon:UpdateIcon(_arrCoin[1])
            local currencyCostAmount = _arrCoin[2]
            UIUtils.SetTextByNumber(self.CoinLabel, currencyCostAmount)
            if haveCoin >= currencyCostAmount then
                UIUtils.SetColorByString(self.CoinLabel, "#fffef5") -- Trắng
            else
                UIUtils.SetColorByString(self.CoinLabel, "#F11F1F") -- Đỏ
            end
            for i = #_itemArr + 1, #self.ItemCostList do
                self.ItemCostList[i].RootGO:SetActive(true)
            end
            self.ItemCostGrid.repositionNow = true
        end

        local _totalLv = GameCenter.LianQiForgeSystem:GetTotalStrengthLv()
        if not self.TotalLvNum or _totalLv ~= self.TotalLvNum then
            self.TotalLvNum = _totalLv
            local _curCfg = self:GetCurAndNextCfg(_totalLv)
            if _curCfg.Id == 0 then
                UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS", _totalLv)
            else
                local _getAttrs = Utils.SplitStrByTableS(_curCfg.Value, { ';', '_' })
                -- UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS1", _totalLv, tonumber(_getAttrs[1][2]) / 100)
                UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS", _totalLv)
            end
        end

        -- if _strengthInfo.level == _equip.ItemInfo.LevelMax then
        --     self.StrengthBtn.isEnabled = false
        -- end
    else
        --装备信息
        UIUtils.ClearText(self.EquipTextLabel)
        if not self.RightEquipItem then
            self.RightEquipItem = UILuaItem:New(self.RightEquipItemTrs)
            self.RightEquipItemNext = UILuaItem:New(self.RightEquipItemNextTrs)
        end
        --右侧的装备icon，禁用点击事件
        self.RightEquipItem.SingleClick = Utils.Handler(self.RightEquipItemOnClick, self)
        self.RightEquipItem:InitWithItemData()
        self.RightEquipItemNext.SingleClick = Utils.Handler(self.RightEquipItemOnClick, self)
        self.RightEquipItemNext:InitWithItemData()
        --属性
        self:SetAttributeInfo(-1)
        --消耗
        for i = 1, #self.ItemCostList do
            self.ItemCostList[i].RootGO:SetActive(true)
        end

        local _totalLv = GameCenter.LianQiForgeSystem:GetTotalStrengthLv()
        if not self.TotalLvNum or _totalLv ~= self.TotalLvNum then
            self.TotalLvNum = _totalLv
            local _curCfg = self:GetCurAndNextCfg(_totalLv)
            if _curCfg.Id == 0 then
                UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS", _totalLv)
            else
                local _getAttrs = Utils.SplitStrByTableS(_curCfg.Value, { ';', '_' })
                -- UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS1", _totalLv, tonumber(_getAttrs[1][2]) / 100)
                UIUtils.SetTextByEnum(self.AllLvAttTipsLabel, "C_UI_EQUIPSTRENGTH_TIPS", _totalLv)
            end
        end
    end
    self:RefreshBtnRed()
end

function UILianQiForgeStrengthForm:RefreshBtnRed(pos)
    --按钮红点
    local _moneyIsEnough = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.LianQiForgeStrength, pos)
    self.StrengthBtnRedGo:SetActive(_moneyIsEnough)
    self.AutoStrengthBtnRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiForgeStrength))
end

function UILianQiForgeStrengthForm:GetCfgID(pos, level)
    return (pos + 100) * 1000 + level
end

function UILianQiForgeStrengthForm:SetAttributeInfo(pos, level)
    self.AttributeGo:SetActive(pos >= 0)
    self.NoAttributeGo:SetActive(pos < 0)
    if pos >= 0 then
        self.AttributeGo:SetActive(true)
        --local _curLvCfgID = self:GetCfgID(pos, level)
        --local _curLvCfg = DataConfig.DataEquipIntenMain[_curLvCfgID]
        --self:SetAttrText(_curLvCfg, true)
        --if level + 1 <= GameCenter.LianQiForgeSystem.StrengthMaxLevel then
        --    local _nextLvCfgID = self:GetCfgID(pos, level + 1)
        --    local _nextLvCfg = DataConfig.DataEquipIntenMain[_nextLvCfgID]
        --    self:SetAttrText(_nextLvCfg, false)
        --else
        --    self:SetAttrText(_curLvCfg, false)
        --end

        self:SetAttrText2(level, true)
        if level + 1 <= GameCenter.LianQiForgeSystem.StrengthMaxLevel then
            self:SetAttrText2(level + 1, false)
        else
            self:SetAttrText2(level, false)
        end
    end
end

function UILianQiForgeStrengthForm:SetAttrText2(level, isOld)
    if not (self.CurSelectPos and self.CurSelectGo) then
        return
    end

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _pos = self.CurSelectPos
    local _sourceItemData = self.CurSelectGo.ItemData
    local attDic = _sourceItemData:GetBaseAttribute()
    local strengthAttrDic = _forgeSystem:GetAllStrengthAttrDicByPart(_pos, level)

    if isOld then
        local _oldLvLab = UIUtils.FindLabel(self.OldAttrTrs, "Level")
        local _oldAttr1Go = UIUtils.FindGo(self.OldAttrTrs, "Attr1")
        local _oldAttr1Lab = UIUtils.FindLabel(self.OldAttrTrs, "Attr1")
        local _oldAttr1NameLab = UIUtils.FindLabel(self.OldAttrTrs, "Attr1/Txt")
        local _oldAttr2Go = UIUtils.FindGo(self.OldAttrTrs, "Attr2")
        local _oldAttr2Lab = UIUtils.FindLabel(self.OldAttrTrs, "Attr2")
        local _oldAttr2NameLab = UIUtils.FindLabel(self.OldAttrTrs, "Attr2/Txt")
        local _oldAttr3Go = UIUtils.FindGo(self.OldAttrTrs, "Attr3")
        local _oldAttr3Lab = UIUtils.FindLabel(self.OldAttrTrs, "Attr3")
        local _oldAttr3NameLab = UIUtils.FindLabel(self.OldAttrTrs, "Attr3/Txt")

        UIUtils.SetTextFormat(_oldLvLab, "+{0}", level)
        _forgeSystem:SetLabelColorByStrengthLevel(_oldLvLab, level)

        _oldAttr1Go:SetActive(false)
        _oldAttr2Go:SetActive(false)
        _oldAttr3Go:SetActive(false)
        for index, attrID in pairs(attDic.Keys) do
            local _attrID, _attrValue = attrID, attDic[attrID]
            local _strengthValue = (strengthAttrDic[_attrID] and strengthAttrDic[_attrID].Value) or 0
            local formatValue = Utils.FormatAttributeValue(attrID, _strengthValue)

            if index == 0 then
                _oldAttr1Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_oldAttr1NameLab, _attrID)
                UIUtils.SetTextByString(_oldAttr1Lab, formatValue)
            elseif index == 1 then
                _oldAttr2Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_oldAttr2NameLab, _attrID)
                UIUtils.SetTextByString(_oldAttr2Lab, formatValue)
            elseif index == 2 then
                _oldAttr3Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_oldAttr3NameLab, _attrID)
                UIUtils.SetTextByString(_oldAttr3Lab, formatValue)
            end
        end
    else
        local _newLvLab = UIUtils.FindLabel(self.NewAttrTrs, "Level")
        local _newAttr1Go = UIUtils.FindGo(self.NewAttrTrs, "Attr1")
        local _newAttr1Lab = UIUtils.FindLabel(self.NewAttrTrs, "Attr1")
        local _newAttr1NameLab = UIUtils.FindLabel(self.NewAttrTrs, "Attr1/Txt")
        local _newAttr2Go = UIUtils.FindGo(self.NewAttrTrs, "Attr2")
        local _newAttr2Lab = UIUtils.FindLabel(self.NewAttrTrs, "Attr2")
        local _newAttr2NameLab = UIUtils.FindLabel(self.NewAttrTrs, "Attr2/Txt")
        local _newAttr3Go = UIUtils.FindGo(self.NewAttrTrs, "Attr3")
        local _newAttr3Lab = UIUtils.FindLabel(self.NewAttrTrs, "Attr3")
        local _newAttr3NameLab = UIUtils.FindLabel(self.NewAttrTrs, "Attr3/Txt")

        UIUtils.SetTextFormat(_newLvLab, "+{0}", level)
        _forgeSystem:SetLabelColorByStrengthLevel(_newLvLab, level)

        _newAttr1Go:SetActive(false)
        _newAttr2Go:SetActive(false)
        _newAttr3Go:SetActive(false)
        for index, attrID in pairs(attDic.Keys) do
            local _attrID, _attrValue = attrID, attDic[attrID]
            local _strengthValue = (strengthAttrDic[_attrID] and strengthAttrDic[_attrID].Value) or 0
            local formatValue = Utils.FormatAttributeValue(attrID, _strengthValue)
            if index == 0 then
                _newAttr1Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_newAttr1NameLab, _attrID)
                UIUtils.SetTextByString(_newAttr1Lab, formatValue)
            elseif index == 1 then
                _newAttr2Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_newAttr2NameLab, _attrID)
                UIUtils.SetTextByString(_newAttr2Lab, formatValue)
            elseif index == 2 then
                _newAttr3Go:SetActive(_attrValue > 0 or _strengthValue > 0)
                UIUtils.SetTextByPropName(_newAttr3NameLab, _attrID)
                UIUtils.SetTextByString(_newAttr3Lab, formatValue)
            end
        end
    end
end

--设置属性的text。cfg = 配置表（DataEquipIntenMain）， isOld = true表示左侧的当前等级text，isOld = false表示右侧的下一等级text
function UILianQiForgeStrengthForm:SetAttrText(cfg, isOld)
    if cfg then
        if isOld then
            local _oldLvLab = UIUtils.FindLabel(self.OldAttrTrs, "Level")
            UIUtils.SetTextFormat(_oldLvLab, "+{0}", cfg.Level)
            GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(_oldLvLab, cfg.Level)
            local _oldAttr1Lab = UIUtils.FindLabel(self.OldAttrTrs, "Attr1")
            local _oldAttr1NameLab = UIUtils.FindLabel(self.OldAttrTrs, "Attr1/Txt")
            local _oldAttr2Lab = UIUtils.FindLabel(self.OldAttrTrs, "Attr2")
            local _oldAttr2NameLab = UIUtils.FindLabel(self.OldAttrTrs, "Attr2/Txt")
            local _attr1 = Utils.SplitStrByTableS(cfg.Value, { ';', '_' })
            if _attr1[1] then
                _oldAttr1Lab.gameObject:SetActive(true)
                local _attrCfg = DataConfig.DataAttributeAdd[_attr1[1][1]]
                local _txt = _attrCfg.ShowPercent == 0 and tostring(_attr1[1][2]) or string.format("%s%%", tostring(math.FormatNumber(_attr1[1][2] / 100)))-- string.format( "%d%%", _attr1[1][2]//100)
                UIUtils.SetTextByString(_oldAttr1Lab, _txt)
                if _attrCfg ~= nil then
                    UIUtils.SetTextByString(_oldAttr1NameLab, _attrCfg.Name .. ":")
                end
            else
                _oldAttr1Lab.gameObject:SetActive(false)
            end

            if _attr1[2] then
                _oldAttr2Lab.gameObject:SetActive(true)
                local _attrCfg = DataConfig.DataAttributeAdd[_attr1[2][1]]
                local _txt = _attrCfg.ShowPercent == 0 and tostring(_attr1[2][2]) or string.format("%s%%", tostring(math.FormatNumber(_attr1[2][2] / 100)))-- string.format( "%d%%", _attr1[2][2]//100)
                UIUtils.SetTextByString(_oldAttr2Lab, _txt)
                if _attrCfg ~= nil then
                    UIUtils.SetTextByString(_oldAttr2NameLab, _attrCfg.Name .. ":")
                end
            else
                _oldAttr2Lab.gameObject:SetActive(false)
            end
        else
            local _newLvLab = UIUtils.FindLabel(self.NewAttrTrs, "Level")
            UIUtils.SetTextFormat(_newLvLab, "+{0}", cfg.Level)
            GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(_newLvLab, cfg.Level)
            local _newAttr1Lab = UIUtils.FindLabel(self.NewAttrTrs, "Attr1")
            local _newAttr1NameLab = UIUtils.FindLabel(self.NewAttrTrs, "Attr1/Txt")
            local _newAttr2Lab = UIUtils.FindLabel(self.NewAttrTrs, "Attr2")
            local _newAttr2NameLab = UIUtils.FindLabel(self.NewAttrTrs, "Attr2/Txt")
            local _attr2 = Utils.SplitStrByTableS(cfg.Value, { ';', '_' })
            if _attr2[1] then
                _newAttr1Lab.gameObject:SetActive(true)
                local _attrCfg = DataConfig.DataAttributeAdd[_attr2[1][1]]
                local _txt = _attrCfg.ShowPercent == 0 and tostring(_attr2[1][2]) or string.format("%s%%", tostring(math.FormatNumber(_attr2[1][2] / 100)))-- string.format( "%d%%", _attr2[1][2]//100)
                UIUtils.SetTextByString(_newAttr1Lab, _txt)
                if _attrCfg ~= nil then
                    UIUtils.SetTextByString(_newAttr1NameLab, _attrCfg.Name .. ":")
                end
            else
                _newAttr1Lab.gameObject:SetActive(false)
            end
            if _attr2[2] then
                _newAttr2Lab.gameObject:SetActive(true)
                local _attrCfg = DataConfig.DataAttributeAdd[_attr2[2][1]]
                local _txt = _attrCfg.ShowPercent == 0 and tostring(_attr2[2][2]) or string.format("%s%%", tostring(math.FormatNumber(_attr2[2][2] / 100)))-- string.format( "%d%%", _attr2[2][2]//100)
                UIUtils.SetTextByString(_newAttr2Lab, _txt)
                if _attrCfg ~= nil then
                    UIUtils.SetTextByString(_newAttr2NameLab, _attrCfg.Name .. ":")
                end
            else
                _newAttr2Lab.gameObject:SetActive(false)
            end
        end
    end
end

function UILianQiForgeStrengthForm:UpgradeLevel()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _curPosNewStrengthInfo = _forgeSystem.StrengthPosLevelDic[self.CurSelectPos]
    if _curPosNewStrengthInfo then
        local _curPosStrengthInfo = { level = _curPosNewStrengthInfo.level, exp = _curPosNewStrengthInfo.exp }
        if self.EquipDic:ContainsKey(self.CurSelectPos) then
            self.EquipDic[self.CurSelectPos].StrInfo = _curPosStrengthInfo
        end
    end
    local _strengthInfo = self.EquipDic[self.CurSelectPos].StrInfo
    self:SetLeftStrengthLvByPos(self.CurSelectPos, _strengthInfo)
    --右侧
    self:RefreshRightInfos(self.CurSelectPos, self.EquipDic[self.CurSelectPos].StrInfo)
    if self.tempLevel ~= _curPosNewStrengthInfo.level then
        self.VfxSkinCompo:OnDestory()
        self.VfxSkinCompo:OnCreateAndPlay(ModelTypeCode.UIVFX, 40, LayerUtils.GetAresUILayer())
    else
        self.VfxSkinCompo:OnDestory()
        self.VfxSkinCompo:OnCreateAndPlay(ModelTypeCode.UIVFX, 611, LayerUtils.GetAresUILayer())
    end
end

function UILianQiForgeStrengthForm:OnFlyComplete()
    self.FlyPanel:SetActive(false)
end

return UILianQiForgeStrengthForm
