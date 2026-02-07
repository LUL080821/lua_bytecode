--作者： cy
--日期： 2019-04-26
--文件： UILianQiForgeStrengthSplitForm.lua
--模块： UILianQiForgeStrengthSplitForm
--描述： 炼器功能二级子面板：装备强化。上级面板为：锻造面板（UILianQiForgeForm）
------------------------------------------------
local L_UICheckBox = require "UI.Components.UICheckBox"
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_LeftItem = require("UI.Forms.UILianQiForgeStrengthSplitForm.UILeftItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local UILianQiForgeStrengthSplitForm = {
    EquipScrollView = nil,
    EquipGrid = nil,                    --左侧装备滑动GRID
    EquipItem = nil,                    --左侧装备控件
    EquipDic = Dictionary:New(),        --左侧装备列表
    RightEquipItemTrs = nil,            --右侧装备Icon
    AttributeGo = nil,                 --右侧属性面板
    OldAttrTrs = nil,                   --右侧属性：当前等级
    Arrow1AttrTrs = nil,                   --右侧属性：当前等级
    NewAttrTrs = nil,                   --右侧属性：下一等级
    ItemCostItem = nil,                 --道具消耗
    ItemCostList = List:New(),
    ItemCostGrid = nil,
    AllAttributePanel = nil,            --所有属性面板
    -- CUSTOM - thêm nút tách CH
    SplitBtn = nil,                     --Tách Cường Hoá TB
    -- CUSTOM - thêm nút tách CH
    BgTexture = nil,                    --texture
    CurSelectGo = nil,                  --当前选中的左侧装备
    CurSelectPos = 0,                   --当前选中的部位
    VfxID = 9,                          --特效id
    VfxSkinCompo = nil,                 --特效组件
    FlyItemGo = nil,                    --飞行ICON
    FlyItemTween = nil,
    MeterailEquipList = List:New(),
    SelectEquipList = List:New(),
    Max = 0,
    BagPanelGo = nil,
    BackBtn = nil,
    CurPer = 0,
    listId = List:New(),
    maxExpStrength = 0,
    PutInBtn = nil,
    PerLabel = nil,
    CoinLabel = nil,
    StoneList = List:New(),
    Help = nil,
}

function UILianQiForgeStrengthSplitForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeStrengthSplitForm_OPEN,self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UILianQiForgeStrengthSplitForm_CLOSE,self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_ALLINFO,self.RefreshAllInfo)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_WEAREQUIPSUC,self.RefreshLeftEquipInfos)
end

function UILianQiForgeStrengthSplitForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UILianQiForgeStrengthSplitForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

function UILianQiForgeStrengthSplitForm:RefreshAllInfo(obj, sender)
    self:SetLeftItemRed()
    self:UpgradeLevel()
end

function UILianQiForgeStrengthSplitForm:RegUICallback()
    -- CUSTOM - thêm nút tách CH
    UIUtils.AddBtnEvent(self.SplitBtn, self.OnClickSplitBtn, self)
    -- CUSTOM - thêm nút tách CH
end

function UILianQiForgeStrengthSplitForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiForgeStrengthSplitForm:OnShowBefore()
    self.TotalLvNum = -1
end

function UILianQiForgeStrengthSplitForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.BgTextureNext, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
    self.CSForm:LoadTexture(self.AttrBgTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_30_2"))
    self.CSForm:LoadTexture(self.BgBagPanel, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3"))
    
    self.BagBtn.isEnabled = false
    self:OnClickTab("Dress")
    self.BagPanelGo:SetActive(false)
    self.FlyPanel:SetActive(false)
    self.AllAttributePanel.gameObject:SetActive(false)

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
            self:RefreshRightInfos(nil, nil)
        else
            self:OnClickEquipItem(_clickGo)
        end
    end

end

function UILianQiForgeStrengthSplitForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

function UILianQiForgeStrengthSplitForm:DestroyAllVfx()
    self.VfxSkinCompo:OnDestory()
end

function UILianQiForgeStrengthSplitForm:OnHideBefore()
    self.CurSelectGo = nil
    self.CurSelectPos = 0
    self:DestroyAllVfx()
end

function UILianQiForgeStrengthSplitForm:FindAllComponents()
    local _myTrans = self.Trans
    self.EquipScrollView = UIUtils.FindScrollView(_myTrans, "Left/EquipRoot")
    self.EquipGrid = UIUtils.FindGrid(_myTrans, "Left/EquipRoot/Grid")
    local _gridTrans = UIUtils.FindTrans(_myTrans, "Left/EquipRoot/Grid")
    for i = 0, _gridTrans.childCount - 1 do
        self.EquipItem = L_LeftItem:OnFirstShow(_gridTrans:GetChild(i))
        self.EquipItem.CallBack = Utils.Handler(self.OnClickEquipItem, self)
        self.EquipDic:Add(i, self.EquipItem)
    end
    --------------------------------------
    self.DressBagGo = UIUtils.FindGo(_myTrans, "Left/EquipRoot")
    self.DressBagBtn = UIUtils.FindBtn(_myTrans,"UIListMenu/Table/DressBag")
    self.DressBagRedGo = UIUtils.FindGo(_myTrans,"UIListMenu/Table/DressBag/RedPoint")
    self.DressBagRedGo.gameObject:SetActive(false)
    self.BagGo = UIUtils.FindGo(_myTrans, "Left/BagContainer")
    self.BagBtn = UIUtils.FindBtn(_myTrans, "UIListMenu/Table/Bag")
    self.BagBtn.gameObject:SetActive(false)
    self.DressBagGo:SetActive(false)
    self.BagGo:SetActive(false)

    self.BagGridGo = UIUtils.FindGo(_myTrans, "Left/BagContainer/Grid")
    self.BagPanelGo = UIUtils.FindGo(_myTrans, "BagPanel")
    self.BgBagPanel = UIUtils.FindTex(_myTrans, "BagPanel/BgBagPanel")
    self.CSForm:AddTransNormalAnimation(self.BagPanelGo.transform, 50, 0.3)
    self.BagPanelGrid = UIUtils.FindGrid(_myTrans, "BagPanel/BagContainer/Grid")
    self.BagPanelGridGo = UIUtils.FindGo(_myTrans, "BagPanel/BagContainer/Grid")
    self.BagPanelGridTrans = UIUtils.FindTrans(_myTrans, "BagPanel/BagContainer/Grid")
    
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
    self.Help = UIUtils.FindBtn(_myTrans, "Right/Help")
     UIUtils.AddBtnEvent(self.Help, self.OnClickBtnHelp, self)
    self.RightEquipItemTrs = UIUtils.FindTrans(_myTrans, "Right/Right/UIEquipmentItem")
    self.RightEquipItemNextTrs = UIUtils.FindTrans(_myTrans, "Right/Right/UIEquipmentItemNext")
    self.AttributeGo = UIUtils.FindGo(_myTrans, "Right/Right/Attribute")
    self.NoAttributeGo = UIUtils.FindGo(_myTrans, "Right/Right/NoAttr")
    self.AttrBgTexture = UIUtils.FindTex(_myTrans, "Right/Right/AttrBg")
    self.OldAttrTrs = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/Old")
    self.OldLabel = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/Old/Level")
    self.Arrow1AttrTrs = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/Arrow1")
    self.NewAttrTrs = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/New")
    self.NewLabel = UIUtils.FindTrans(_myTrans, "Right/Right/Attribute/New/Level")
    self.ItemCostTrs = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemGrid")
    -- CUSTOM - ẩn 15 ô đá + ô tiền
    self.ItemCostTrs.gameObject:SetActive(false)
    self.Coin = UIUtils.FindTrans(_myTrans, "Right/Buttom/NeckEquip/Coin")
    self.Coin.gameObject:SetActive(false)
    -- CUSTOM - ẩn 15 ô đá + ô tiền

    -- CUSTOM - thêm 3 ô đá
    self.CostItem_1 = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_1"))
    self.CostItem_1_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_1/Num")
    self.CostItem_2 = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_2"))
    self.CostItem_2_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_2/Num")
    self.CostItem_3 = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_3"))
    self.CostItem_3_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_3/Num")
    self.CostItem_4= UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_4"))
    self.CostItem_4_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_4/Num")
    self.CostItem_5= UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_5"))
    self.CostItem_5_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_5/Num")
    self.CostItem_6= UILuaItem:New(UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_6"))
    self.CostItem_6_Num = UIUtils.FindTrans(_myTrans, "Right/Buttom/ItemCost_6/Num")
    -- CUSTOM - thêm 3 ô đá

    self.ItemCostGrid = UIUtils.FindGrid(_myTrans, "Right/Buttom/ItemGrid")
    for i = 0, self.ItemCostTrs.childCount - 1 do
        self.ItemCostItem = UILuaItem:New(self.ItemCostTrs:GetChild(i))
        self.ItemCostList:Add(self.ItemCostItem)
    end
    for i = 1, self.ItemCostTrs.childCount do
        local path = string.format("Right/Buttom/ItemGrid/%d", i)
        local e = UILuaItem:New(UIUtils.FindTrans(_myTrans, path))
        e.IsShowAddSpr = false
        self.MeterailEquipList:Add(e)
        -- e.SingleClick = Utils.Handler(self.OnMeteriEquipClick, self)
        e:SelectItem(false)
    end
    self.AllAttributePanel = UIUtils.FindTrans(_myTrans, "Left/AllAttributePanel")
    self.AutoStrengthBtnRedGo = UIUtils.FindGo(_myTrans, "Right/Buttom/OneKeyStrengthBtn/RedPoint")
    -- thêm nút tách CH
    self.SplitBtn = UIUtils.FindBtn(_myTrans, "Right/Buttom/SplitBtn")
    self.SelectSplitBtnGo = UIUtils.FindGo(_myTrans, "Right/Buttom/SplitBtn/Select")
    self.SplitBtnRedGo = UIUtils.FindGo(_myTrans, "Right/Buttom/SplitBtn/RedPoint")
    -- thêm nút tách CH
    self.BgTexture = UIUtils.FindTex(_myTrans, "Right/Right/UIEquipmentItem/BgTexture")
    self.BgTextureNext = UIUtils.FindTex(_myTrans, "Right/Right/UIEquipmentItemNext/BgTexture")
    self.CurStrengLvLabel = UIUtils.FindLabel(_myTrans, "Right/Right/StrLv")
    self.CurStrengLvNextLabel = UIUtils.FindLabel(_myTrans, "Right/Right/StrLvNext")
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
end

function UILianQiForgeStrengthSplitForm:OnClickBtnHelp()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, UnityUtils.GetObjct2Int(FunctionStartIdCode.LianQiForgeStrengthSplit))
end
-- CUSTOM - thêm hàm xử lý hiển thị 3 ô đá
function UILianQiForgeStrengthSplitForm:SetItemCost(stoneArr)
    if self.CostItem_1 then
        self.CostItem_1:InItWithCfgid(60002, 0, false, true)
        self.CostItem_1:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    if self.CostItem_2 then
        self.CostItem_2:InItWithCfgid(60020, 0, false, true)
        self.CostItem_2:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    if self.CostItem_3 then
        self.CostItem_3:InItWithCfgid(60021, 0, false, true)
        self.CostItem_3:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    if self.CostItem_4 then
        self.CostItem_4:InItWithCfgid(60022, 0, false, true)
        self.CostItem_4:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    if self.CostItem_5 then
        self.CostItem_5:InItWithCfgid(60098, 0, false, true)
        self.CostItem_5:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    if self.CostItem_6 then
        self.CostItem_6:InItWithCfgid(60099, 0, false, true)
        self.CostItem_6:OnSetNum("[F37B11]" .. 0 .. "[-]")
    end
    
    if stoneArr then
        for id, count in pairs(stoneArr) do
            if self.CostItem_1 and id == "60002" then
                self.CostItem_1:InItWithCfgid(id, 0, false, true)
                self.CostItem_1:OnSetNum("[00FF00]" .. count .. "[-]")
            end
            if self.CostItem_2 and id == "60020" then
                self.CostItem_2:InItWithCfgid(id, 0, false, true)
                self.CostItem_2:OnSetNum("[00FF00]" .. count .. "[-]")
            end
            if self.CostItem_3 and id == "60021" then
                self.CostItem_3:InItWithCfgid(id, 0, false, true)
                self.CostItem_3:OnSetNum("[00FF00]" .. count .. "[-]")
            end
            if self.CostItem_4 and id == "60022" then
                self.CostItem_4:InItWithCfgid(id, 0, false, true)
                self.CostItem_4:OnSetNum("[00FF00]" .. count .. "[-]")
            end
            if self.CostItem_5 and id == "60098" then
                self.CostItem_5:InItWithCfgid(id, 0, false, true)
                self.CostItem_5:OnSetNum("[00FF00]" .. count .. "[-]")
            end
            if self.CostItem_6 and id == "60099" then
                self.CostItem_6:InItWithCfgid(id, 0, false, true)
                self.CostItem_6:OnSetNum("[00FF00]" .. count .. "[-]")
            end
        end
    end
end
-- CUSTOM - thêm hàm xử lý hiển thị 3 ô đá

-- CUSTOM - thêm sự kiện tách CH
function UILianQiForgeStrengthSplitForm:OnClickSplitBtn()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurSelectPos)
    local _strenthInfo = self.EquipDic[self.CurSelectPos].StrInfo
    if _equip == nil then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
    else
        _forgeSystem:ReqEquipSplitLevel(self.CurSelectPos)
    end
end
-- CUSTOM - thêm sự kiện tách CH

function UILianQiForgeStrengthSplitForm:SetLeftItemRed()
    local countRed = 0;
    self.EquipDic:Foreach(function(k, v)
        v:SetRedForEquipSplit()
        if v.StrInfo ~= nil and v.StrInfo.level > 0 then
            countRed = countRed + 1;
        end
    end)
    self.DressBagRedGo.gameObject:SetActive(countRed > 0)
end

function UILianQiForgeStrengthSplitForm:SetLeftStrengthLvByPos(pos, strenthInfo)
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

function UILianQiForgeStrengthSplitForm:RefreshRightInfos(pos, strengthInfo)
    self.CurPer = 0
    self.SplitBtn.isEnabled = false
    self.SelectEquipList:Clear()
    for i =  1, #self.MeterailEquipList do
        self.MeterailEquipList[i]:InitWithItemData(nil, 0)
    end
    self.StoneList:Clear()

    if strengthInfo then
        local _strengthInfo = {type = pos, level = strengthInfo.level, exp = strengthInfo.exp}
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(_strengthInfo.type)
        --如果当前部位强化等级 > 当前装备所能容纳的强化上限。做相应处理
        if _equip ~= nil and _strengthInfo.level >= _equip.ItemInfo.LevelMax then
            _strengthInfo.level = _equip.ItemInfo.LevelMax
            local _cfgID = self:GetCfgID(_strengthInfo.type, _strengthInfo.level)
            local _cfg = DataConfig.DataEquipIntenMain[_cfgID]
            _strengthInfo.exp = _cfg.ProficiencyMax
            for i = 1, #self.MeterailEquipList do
                self.MeterailEquipList[i]:OnLock(true) 
                self.MeterailEquipList[i].IsShowTips = true
                self.MeterailEquipList[i]:InitWithItemData(nil, 0)
            end
        end
        --装备信息
        UIUtils.SetTextByEnum(self.CurStrengLvLabel, "C_UI_STRENGTHLV", _strengthInfo.level)

        ----------------
        UIUtils.SetTextByEnum(self.CurStrengLvNextLabel, "C_UI_STRENGTHLV", _strengthInfo.level + 1)
        ----------------

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
        if _cfg then
            local _itemArr = Utils.SplitStr(_cfg.Consume, ';')
            local _item = nil
            for i = 1, #_itemArr do
                local _singleArr = Utils.SplitNumber(_itemArr[i], '_')
                
                for j = 1, 3 do
                    self.listId:Add(_singleArr[j])
                end
                self.maxExpStrength = _singleArr[4]
            end

            local _arrCoin = Utils.SplitNumber(_cfg.ConsumeCoin, '_')
            UIUtils.SetTextByNumber(self.CoinLabel, _arrCoin[2])

            for i = #_itemArr + 1, #self.ItemCostList do
                self.ItemCostList[i].RootGO:SetActive(true)
            end
            self.ItemCostGrid.repositionNow = true
        end
    else
        UIUtils.SetTextByEnum(self.CurStrengLvLabel, "C_UI_STRENGTHLV", 0)
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
        -- self:SetAttributeInfo(-1)
        --消耗
        for i = 1, #self.ItemCostList do
            self.ItemCostList[i].RootGO:SetActive(true)
        end
    end
    self:RefreshBtnRed()
end

function UILianQiForgeStrengthSplitForm:RefreshBtnRed(pos)
    --按钮红点
    local _moneyIsEnough = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.LianQiForgeStrength, pos)
    self.SplitBtnRedGo:SetActive(_moneyIsEnough)
end

function UILianQiForgeStrengthSplitForm:SetAttributeInfo(pos, level)
    self.AttributeGo:SetActive(pos >= 0)
    self.NoAttributeGo:SetActive(pos < 0)
    -- if pos >= 0 then
        self.AttributeGo:SetActive(true)
        local _curLvCfgID = self:GetCfgID(pos, level)
        local _curLvCfg = DataConfig.DataEquipIntenMain[_curLvCfgID]
        self:SetAttrText(_curLvCfg, true)

        local _nextLvCfgID = self:GetCfgID(pos, 0)
        local _nextLvCfg = DataConfig.DataEquipIntenMain[_nextLvCfgID]
        self:SetAttrText(_nextLvCfg, false)
    -- end
end

function UILianQiForgeStrengthSplitForm:SetAttrText(cfg, isOld)
    if cfg then
        if isOld then
            local _oldLvLab = UIUtils.FindLabel(self.OldAttrTrs, "Level")
            UIUtils.SetTextFormat(_oldLvLab, "+{0}", cfg.Level)
            GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(_oldLvLab, cfg.Level)
            UIUtils.FindLabel(self.OldAttrTrs, "Attr1").gameObject:SetActive(false)
            UIUtils.FindLabel(self.OldAttrTrs, "Attr2").gameObject:SetActive(false)
        else
            local _newLvLab = UIUtils.FindLabel(self.NewAttrTrs, "Level")
            UIUtils.SetTextFormat(_newLvLab, "+{0}", cfg.Level)
            GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(_newLvLab, cfg.Level)
            UIUtils.FindLabel(self.NewAttrTrs, "Attr1").gameObject:SetActive(false)
            UIUtils.FindLabel(self.NewAttrTrs, "Attr2").gameObject:SetActive(false)
        end
    end
end

function UILianQiForgeStrengthSplitForm:OnClickEquipItem(go)
    self.RightEquipItemTrs.gameObject:SetActive(true)
    self.RightEquipItemNextTrs.gameObject:SetActive(true)
    self.OldAttrTrs.gameObject:SetActive(true)
    self.Arrow1AttrTrs.gameObject:SetActive(true)
    self.NewAttrTrs.gameObject:SetActive(true)

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _pos = go.Pos
    if go.ItemData == nil then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
        return;
    end
    if self.CurSelectGo == go then
        do return end
    else
        --当前选中部位的更新
        if _forgeSystem.StrengthPosLevelDic:ContainsKey(_pos) then
            local _curPosNewStrengthInfo = _forgeSystem.StrengthPosLevelDic[_pos]
            local _curPosStrengthInfo = {level = _curPosNewStrengthInfo.level, exp = _curPosNewStrengthInfo.exp}

            -- local _cfgID = self:GetCfgSplitID(_pos, _curPosStrengthInfo.level) -- dùng lại code sau khi AT
            local _cfgID = self:GetCfgID(_pos, _curPosStrengthInfo.level)
            local _cfg = DataConfig.DataEquipIntenMain[_cfgID]

            -- CUSTOM - xử lý hiển thị đá trả về ở đây
                self.MeterailEquipList = List:New()

                -- dựa theo mốc levelStr để lấy max exp của mốc hiện tại làm 100% điểm
                local _maxExp = _cfg.Consume:match("([^_]+)$")

                -- sau khi có 100% sẽ tính toán để lấy 90% điểm
                local _returnExp = _maxExp * 0.9

                -- lấy tất cả đá và điểm của mỗi viên
                local result_table = {}
                local data_part = _cfg.Consume:match("(.+)_[^_]+$")

                if data_part then
                    for stoneId in data_part:gmatch("([^" .. "_" .. "]+)") do
                        local stoneCfg = DataConfig.DataItem[tonumber(stoneId)]
                        result_table[stoneId] = stoneCfg.EffectNum:match("([^_]+)$")
                    end
                end

                -- lấy 90% điểm để tính số lượng đá trả về
                local stone_need_result = {}
                local remaining_exp = _returnExp

                -- Chuyển đổi và Sắp xếp Bảng theo Điểm Giảm Dần
                local sortable_list = {}
                for id, exp in pairs(result_table) do
                    table.insert(sortable_list, {id = id, exp = exp})
                end

                table.sort(sortable_list, function(a, b)
                    return tonumber(a.exp) > tonumber(b.exp)
                end)

                -- Duyệt và Tính toán
                for _, item in ipairs(sortable_list) do
                    local stone_id = item.id
                    local stone_exp = item.exp
                    -- Nếu điểm của đá lớn hơn số điểm còn lại, bỏ qua
                    if remaining_exp < tonumber(stone_exp) then
                        goto continue_loop
                    end
                    -- Tính số lượng tối đa có thể lấy
                    local count = math.floor(remaining_exp / stone_exp)                    
                    -- Số điểm cần dùng
                    local total_cost = count * stone_exp                    
                    -- Cập nhật kết quả và điểm còn lại
                    stone_need_result[stone_id] = count
                    remaining_exp = remaining_exp - total_cost
                    -- Nếu điểm còn lại là 0, dừng vòng lặp
                    if remaining_exp == 0 then
                        break
                    end
                    
                    ::continue_loop::
                end

                local totalSlot = 0
                if _curPosNewStrengthInfo.level > 0 then
                    print("UTEST=========KẾT QUẢ TRẢ VỀ: _pos = " .. _pos)
                    print("Số điểm tổng trả về: " .. _returnExp)
                    print("Số điểm còn dư: " .. remaining_exp)
                    for id, count in pairs(stone_need_result) do
                        print(string.format("ID %d: %d viên", id, count))
                        totalSlot = totalSlot + count
                    end
                    print("=========UTEST")
                    self:SetItemCost(stone_need_result)

                    UIUtils.SetTextByEnum(self.PerLabel, "Percent", 100)
                else
                    self:SetItemCost()
                    UIUtils.SetTextByEnum(self.PerLabel, "Percent", 0)
                end
                -- chia đá vào từng ô


            -- CUSTOM - xử lý hiển thị đá trả về ở đây

            if self.EquipDic:ContainsKey(_pos) then
                self.EquipDic[_pos].StrInfo = _curPosStrengthInfo
            end
            self:RefreshRightInfos(_pos, _curPosStrengthInfo)
            if self.EquipDic[self.CurSelectPos] then
                self.EquipDic[self.CurSelectPos]:OnSetSelect(false)
            end
            if self.EquipDic[_pos] then
                self.EquipDic[_pos]:OnSetSelect(true)
            end

            -- CUSTOM - check ẩn hiện nút tách TB
            self.SplitBtn.isEnabled = _curPosNewStrengthInfo.level > 0;
            self.SplitBtnRedGo:SetActive(_curPosNewStrengthInfo.level > 0)
            -- CUSTOM - check ẩn hiện nút tách TB            
        end
    end
    self.CurSelectPos = _pos
    self.CurSelectGo = go
    self.CurCfg = self.CurSelectGo.CurCfg
    self.FlyItem:InitWithItemData(self.CurSelectGo.ItemData)
    self.FlyItemTrans.position = self.CurSelectGo.Trans.position
    self.FlyItemTween.from = self.FlyItemTrans.localPosition
    self.FlyPanel:SetActive(true)
    self.FlyItemTween:ResetToBeginning()
    self.FlyItemTween:Play(true)
end

function UILianQiForgeStrengthSplitForm:OnClickTab(tabType)
    -- Ẩn cả 2 tab
    self.BagGo:SetActive(false)
    self.DressBagGo:SetActive(false)

    -- Mở tab được chọn
    if tabType == "Bag" then
        -- self.BagGo:SetActive(true)
    elseif tabType == "Dress" then
        self.CurSelectGo = nil
        self.DressBagGo:SetActive(true)
        self:RefreshLeftEquipInfos(true)
        self:SetLeftItemRed()
    end
end

function UILianQiForgeStrengthSplitForm:RefreshLeftEquipInfos(playAnim, sender)
    self:RefreshLeftEquipIcons(playAnim)
    self:SetItemCost()
end

function UILianQiForgeStrengthSplitForm:RefreshLeftEquipIcons(playAnim)
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
                    _strinfo = {level = _starLv, exp = _strengthInfo.exp}
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

function UILianQiForgeStrengthSplitForm:GetCfgSplitID(pos, level)
    if level > 0 then
        return (pos + 100) * 1000 + (level - 1)
    else
        return (pos + 100) * 1000 + level
    end
end

function UILianQiForgeStrengthSplitForm:GetCfgID(pos, level)
    return (pos + 100) * 1000 + level
end

function UILianQiForgeStrengthSplitForm:GetCurAndNextCfg(totalLv)
    local _curCfg = nil
    local _nextCfg = nil
    local _cfgLength = DataConfig.DataEquipIntenClass.Count
    DataConfig.DataEquipIntenClass:ForeachCanBreak(function(k, v)
        v.Id = k
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
            if not _curCfg and not _nextCfg then
                local _cfg = Utils.DeepCopy(v)
                _cfg.Id = -1
                _curCfg = v
                _nextCfg = _cfg
            end
        end
    end)
    return _curCfg, _nextCfg
end

function UILianQiForgeStrengthSplitForm:RightEquipItemOnClick(go)
    local _equipItem = go
    if _equipItem.ShowItemData ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(_equipItem.ShowItemData, go.RootGO, ItemTipsLocation.EquipDisplay)
    end
end

function UILianQiForgeStrengthSplitForm:OnFlyComplete()
    self.FlyPanel:SetActive(false)
end

function UILianQiForgeStrengthSplitForm:OnEquipSelect(item)
    if item.ShowItemData then
        if self.SelectEquipList:Contains(item.ShowItemData) then
            self.SelectEquipList:Remove(item.ShowItemData)
            item:SelectItem(false)
        else
            item:SelectItem(true)
            self.SelectEquipList:Add(item.ShowItemData)
        end
        self:OnSetPerLabel()
        self:SetAutoBuyNum()
        self:SetPerLabelInBag()
    end
end

function UILianQiForgeStrengthSplitForm:UpgradeLevel()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _curPosNewStrengthInfo = _forgeSystem.StrengthPosLevelDic[self.CurSelectPos]
    if _curPosNewStrengthInfo then
        local _curPosStrengthInfo = {level = _curPosNewStrengthInfo.level, exp = _curPosNewStrengthInfo.exp}
        if self.EquipDic:ContainsKey(self.CurSelectPos) then
            self.EquipDic[self.CurSelectPos].StrInfo = _curPosStrengthInfo
        end
    end
    local _strengthInfo = self.EquipDic[self.CurSelectPos].StrInfo
    self:SetLeftStrengthLvByPos(self.CurSelectPos, _strengthInfo)
    self:RefreshRightInfos(self.CurSelectPos, self.EquipDic[self.CurSelectPos].StrInfo)
    if self.tempLevel ~= _curPosNewStrengthInfo.level then
        self.VfxSkinCompo:OnDestory()
        self.VfxSkinCompo:OnCreateAndPlay(ModelTypeCode.UIVFX, 613, LayerUtils.GetAresUILayer())
    end
    self:SetLeftItemRed()
    self:SetItemCost()
end

return UILianQiForgeStrengthSplitForm
