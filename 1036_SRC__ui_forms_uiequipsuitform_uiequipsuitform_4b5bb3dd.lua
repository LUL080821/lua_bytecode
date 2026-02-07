--==============================--
-- author:
-- Date: 2019-06-11
-- File: UIEquipSuitForm.lua
-- Module: UIEquipSuitForm
-- Description: Set interface
--==============================--
local UIListMenu = require "UI.Components.UIListMenu.UIListMenu";
local UIEquipSuitItem = require "UI.Forms.UIEquipSuitForm.UIEquipSuitItem";
local Equipment = CS.Thousandto.Code.Logic.Equipment
local BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UIEquipSuitForm = {
    -- menu
    ListMenu = nil,
    -- Equipment sliding list
    EquipScroll = nil,
    -- Equipment item resources
    EquipItemRes = nil,
    -- Equipment item resource list
    EquipItemList = nil,
    -- Target equipment item
    TargetItem = nil,
    -- Need items
    NeedItems = nil,
    -- Need item lock
    NeedItemLocks = nil,
    -- Help Button
    HelpBtn = nil,
    -- Attributes go
    ProGo = nil,
    -- Set name
    SuitName = nil,
    -- Number of sets
    SuitCount = nil,
    -- Properties Sliding List
    PropScroll = nil,
    -- Forged Button
    DuanZaoBtn = nil,
    -- Forged red dots
    DuanZaoRedPoint = nil,
    -- Root on the right
    RightGo = nil,
    -- No equipment tips
    NoneEquopGo = nil,
    -- The currently selected suit level
    CurSelectLevel = 0,
    -- Currently selected equipment
    SelectItem = nil,
    -- Background picture
    BackTex = nil,
    -- CUSTOM - thêm biến EquipCount để check số lượng TB đang có ở tab
    CurEquipCount = 0
    -- CUSTOM - thêm biến EquipCount để check số lượng TB đang có ở tab
};

-- Register event functions and provide them to the CS side to call.
function UIEquipSuitForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIEquipSuitForm_Open, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIEquipSuitForm_Close, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_EQUIPSUIT_PAGE, self.OnUpdatePage);

end

-- The first display function is provided to the CS side to call.
function UIEquipSuitForm:OnFirstShow()
    self.CSForm:AddAlphaAnimation();

    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"));
    self.ListMenu:ClearSelectEvent();
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect, self));
    self.ListMenu:AddIcon(1, DataConfig.DataMessageString.Get("C_EQUIPSUIT_CHUANSHI"), FunctionStartIdCode.EquipSuitLevel1);
    self.ListMenu:AddIcon(2, DataConfig.DataMessageString.Get("C_EQUIPSUIT_DONGXU"), FunctionStartIdCode.EquipSuitLevel2);
    self.ListMenu:AddIcon(3, DataConfig.DataMessageString.Get("C_EQUIPSUIT_POTIAN"), FunctionStartIdCode.EquipSuitLevel3);

    self.EquipScroll = UIUtils.FindScrollView(self.Trans, "Left/ScrollView");
    self.EquipItemRes = UIUtils.FindGo(self.Trans, "Left/ScrollView/0");

    self.EquipItemList = List:New();
    local _itemParent = UIUtils.FindTrans(self.Trans, "Left/ScrollView");
    for i = 0, _itemParent.childCount - 1 do
        self.EquipItemList:Add(UIEquipSuitItem:New(_itemParent:GetChild(i).gameObject, self));
    end
    self.TargetItem = UILuaItem:New(UIUtils.FindTrans(self.Trans, "Right/BackTex/TargetEquip"));
    self.NeedItems = {};
    self.NeedItemLocks = {};
    for i = 1, 3 do
        self.NeedItems[i] = UILuaItem:New(UIUtils.FindTrans(self.Trans, string.format("Right/BackTex/Grid/%d", i)));
        self.NeedItemLocks[i] = UIUtils.FindGo(self.Trans, string.format("Right/BackTex/Grid/Lock%d", i));
    end
    self.HelpBtn = UIUtils.FindBtn(self.Trans, "Right/BackTex/HelpBtn");
    UIUtils.AddBtnEvent(self.HelpBtn, self.OnHelpBtnClick, self);
    self.ProGo = UIUtils.FindGo(self.Trans, "Right/Right/Prop");
    self.SuitName = UIUtils.FindLabel(self.Trans, "Right/Right/Prop/SuitName");
    self.SuitCount = UIUtils.FindLabel(self.Trans, "Right/Right/Prop/SuitCount");
    self.PropScroll = UIUtils.FindScrollView(self.Trans, "Right/Right/Prop/ProScoll");
    self.DuanZaoBtn = UIUtils.FindBtn(self.Trans, "Right/Right/Prop/DuanZaoBtn");
    self.DuanZaoBtnSpr = UIUtils.FindSpr(self.Trans, "Right/Right/Prop/DuanZaoBtn");
    self.DuanZaoBtnDisableSpr = UIUtils.FindSpr(self.Trans, "Right/Right/Prop/DuanZaoBtn/Disable");
    UIUtils.AddBtnEvent(self.DuanZaoBtn, self.OnDunZaoBtnClick, self);
    self.DuanZaoRedPoint = UIUtils.FindGo(self.Trans, "Right/Right/Prop/DuanZaoBtn/RedPoint");
    self.RightGo = UIUtils.FindGo(self.Trans, "Right");
    self.NoneEquopGo = UIUtils.FindGo(self.Trans, "Left/NoneEquip");
    self.BackTex = UIUtils.FindTex(self.Trans, "Right/BackTex");
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)

    self.RightTrans = UIUtils.FindTrans(self.Trans, "Right");
    self.CSForm:AddAlphaScaleAnimation(self.RightTrans, 0, 1, 1.05, 1.05, 1, 1, 0.3, false, false)
end

-- Displays the previous operation and provides it to the CS side to call.
function UIEquipSuitForm:OnShowBefore()
end

-- The displayed operation is provided to the CS side to call.
function UIEquipSuitForm:OnShowAfter()
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_30_3"));
    self.IsPlayAnim = true
end

-- Hide previous operations and provide them to the CS side to call.
function UIEquipSuitForm:OnHideBefore()
end

-- The hidden operation is provided to the CS side to call.
function UIEquipSuitForm:OnHideAfter()
end

function UIEquipSuitForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

-- Turn on the event
function UIEquipSuitForm:OnOpen(obj, sender)
    self.CSForm:Show(sender);
    if obj ~= nil then
        self.ListMenu:SetSelectById(tonumber(obj));
    else
        self.ListMenu:SetSelectByIndex(0);
    end
end

-- Close Event
function UIEquipSuitForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

-- Get equipment sorting value
local function GetEquipSortValue(equip)
    local _equipCfg = DataConfig.DataEquip[equip.CfgID];
    -- CUSTOM - khai báo lại thứ tự TB
    if _equipCfg.Part == EquipmentType.Helmet then --Mũ
        return 1;
    elseif _equipCfg.Part == EquipmentType.Necklace then --Dây Chuyền
        return 2;
    elseif _equipCfg.Part == EquipmentType.FingerRing then --Nhẫn
        return 3;
    elseif _equipCfg.Part == EquipmentType.Clothes then --Áo
        return 4;
    elseif _equipCfg.Part == EquipmentType.Sachet then --Ngọc Bội
        return 5;
    elseif _equipCfg.Part == EquipmentType.Pendant then --Túi Thơm
        return 6;
    elseif _equipCfg.Part == EquipmentType.LegGuard then --Quần
        return 7;
    elseif _equipCfg.Part == EquipmentType.Belt then --Bao Tay
        return 8;
    elseif _equipCfg.Part == EquipmentType.Shoe then --Giày
        return 9;
    end
    return 0;
    -- CUSTOM - khai báo lại thứ tự TB
end

-- Equipment sorting function
local function EquipSort(a, b)
    return GetEquipSortValue(a) < GetEquipSortValue(b);
end
-- Update the interface
function UIEquipSuitForm:OnUpdatePage(obj, sender)
    self:UpdateEquipList(self.CurSelectLevel);
    self:SetSelectEquip(self.SelectItem);
end

-- Menu selection
function UIEquipSuitForm:OnMenuSelect(id, select)
    if select then
        if id == 1 then
            self:SetSelectLevel(1);
        elseif id == 2 then
            self:SetSelectLevel(2);
        elseif id == 3 then
            self:SetSelectLevel(3);
        end
    else
    end
end

-- Setting up the selection equipment list
function UIEquipSuitForm:SetSelectLevel(level)
    self.CurSelectLevel = level;
    self:UpdateEquipList(level);
    self:SetSelectEquip(self.EquipItemList[1]);
end

-- Refresh the equipment list
function UIEquipSuitForm:UpdateEquipList(level)
    local _animList = nil
    local playAnim = self.IsPlayAnim
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    -- CUSTOM - sử dụng hàm mới lấy danh sách TB bằng level
    local _cshapList = GameCenter.EquipmentSystem:GetCurDressNormalEquipByLevel(self.CurSelectLevel);
    -- CUSTOM - sử dụng hàm mới lấy danh sách TB bằng level

    --local _ddressList = List:New(_cshapList);
    local _showList = List:New(_cshapList);
    local _equipCount = #_showList;

    -- CUSTOM - set thêm giá trị count cho global count CurEquipCount
    self.CurEquipCount = _equipCount;
    -- CUSTOM - set thêm giá trị count cho global count CurEquipCount

    if _equipCount > 0 then
        self.EquipScroll.gameObject:SetActive(true);
        self.NoneEquopGo:SetActive(false);
        -- local _showList = List:New();
        -- for i = 1, _equipCount do
        --     --local _equipCfg = DataConfig.DataEquip[_ddressList[i].CfgID];
        --     --local _minNeed = GameCenter.EquipmentSuitSystem:FindLowestNeed(_equipCfg.Part, level);
        --     --if _equipCfg.Grade >= _minNeed[3] then
        -- --The order is sufficient to be displayed in the list
        --      --   _showList:Add(_ddressList[i]);
        --     --end
        -- end

        _showList:Sort(EquipSort);
        local _startY = 129.0;
        for i = 1, _equipCount do
            local _itemUI = nil;
            if i <= #self.EquipItemList then
                _itemUI = self.EquipItemList[i];
            else
                _itemUI = UIEquipSuitItem:New(UnityUtils.Clone(self.EquipItemRes), self);
                self.EquipItemList:Add(_itemUI);
            end
            UnityUtils.SetLocalPosition(_itemUI.Trans, -13.0, _startY, 0.0);
            -- CUSTOM - luôn hiển thị vật phẩm thuộc level 1 cho mỗi tab
            -- _itemUI:SetInfo(_showList[i], self.CurSelectLevel);
            _itemUI:SetInfo(_showList[i], 1);
            -- CUSTOM - luôn hiển thị vật phẩm thuộc level 1 cho mỗi tab
            _startY = _startY - 105;

            if playAnim then
                _animList:Add(_itemUI.Trans)
            end
        end

        for i = _equipCount + 1, #self.EquipItemList do
            self.EquipItemList[i]:SetInfo(nil, 0);
        end
        self.EquipScroll:ResetPosition();
    else
        self.EquipScroll.gameObject:SetActive(false);
        self.NoneEquopGo:SetActive(true);
    end
    
    playAnim = _equipCount > 0
    
    if playAnim then
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 30, 0.2, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
        end
        self.AnimPlayer:AddTrans(self.RightTrans, 0)
        self.AnimPlayer:Play()
    end
end

-- Set the selected equipment
function UIEquipSuitForm:SetSelectEquip(itemUI)
    for i = 1, #self.EquipItemList do
        self.EquipItemList[i]:SetSelect(itemUI == self.EquipItemList[i]);
    end

    -- CUSTOM - check hiển thị Right nếu LeftScroll đang có TB
    -- self.SelectItem = itemUI;
    -- self:UpdateEquipInfo(itemUI);
    if self.CurEquipCount > 0 then
        self.SelectItem = itemUI;
        self:UpdateEquipInfo(itemUI);
    else
        self.RightGo:SetActive(false);
    end
    -- CUSTOM - check hiển thị Right nếu LeftScroll đang có TB
end

-- Refresh the equipment attribute interface
function UIEquipSuitForm:UpdateEquipInfo(itemUI)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if _lp == nil then
        return;
    end;

    if itemUI.EquipInst == nil then
        self.RightGo:SetActive(false);
    else
        local _equipCfg = DataConfig.DataEquip[itemUI.EquipInst.CfgID];
        self.RightGo:SetActive(true);
        self.TargetItem:InitWithItemData(itemUI.EquipInst, 1, false, false, ItemTipsLocation.Nomal);
        self.DuanZaoBtn.isEnabled = false;
        self.DuanZaoRedPoint:SetActive(false);
        
        self.DuanZaoBtnSpr.spriteName = ""
        self.DuanZaoBtnDisableSpr.gameObject:SetActive(true)
        local _resIndex = 0;
        if itemUI.ShowSuitCfg ~= nil then
            if itemUI.CanLevelUP then
                local _needItems = itemUI.ShowSuitCfg.NeedItems[_equipCfg.Part];

                -- CUSTOM - sắp xếp lại vị trí ô đá theo Bộ
                -- for i = 1, 3 do
                --     if i <= #_needItems then
                --         _resIndex = i;
                --         self.NeedItems[i].RootGO:SetActive(true);
                --         self.NeedItemLocks[i]:SetActive(false);
                --         self.NeedItems[i]:InItWithCfgid(_needItems[i][1], _needItems[i][2], false, true);
                --         self.NeedItems[i]:BindBagNum();
                --     end
                -- end
                if _equipCfg.Part == EquipmentType.Helmet or _equipCfg.Part == EquipmentType.Necklace or _equipCfg.Part == EquipmentType.FingerRing then
                        _resIndex = 1; -- ô thứ 1
                        self.NeedItems[_resIndex].RootGO:SetActive(true);
                        self.NeedItemLocks[_resIndex]:SetActive(false);
                        self.NeedItems[_resIndex]:InItWithCfgid(_needItems[1][1], _needItems[1][2], false, true); -- giá trị phải là 1 _needItems[1] vì chỉ có 1 loại đá
                        self.NeedItems[_resIndex]:BindBagNum();
                end
                if _equipCfg.Part == EquipmentType.Clothes or _equipCfg.Part == EquipmentType.Sachet or _equipCfg.Part == EquipmentType.Pendant then
                        _resIndex = 2; -- ô thứ 2
                        self.NeedItems[_resIndex].RootGO:SetActive(true);
                        self.NeedItemLocks[_resIndex]:SetActive(false);
                        self.NeedItems[_resIndex]:InItWithCfgid(_needItems[1][1], _needItems[1][2], false, true); -- giá trị phải là 1 _needItems[1] vì chỉ có 1 loại đá
                        self.NeedItems[_resIndex]:BindBagNum();
                end
                if _equipCfg.Part == EquipmentType.Belt or _equipCfg.Part == EquipmentType.LegGuard or _equipCfg.Part == EquipmentType.Shoe then
                        _resIndex = 3; -- ô thứ 3
                        self.NeedItems[_resIndex].RootGO:SetActive(true);
                        self.NeedItemLocks[_resIndex]:SetActive(false);
                        self.NeedItems[_resIndex]:InItWithCfgid(_needItems[1][1], _needItems[1][2], false, true); -- giá trị phải là 1 _needItems[1] vì chỉ có 1 loại đá
                        self.NeedItems[_resIndex]:BindBagNum();
                end
                -- CUSTOM - sắp xếp lại vị trí ô đá theo Bộ

                self.DuanZaoBtnDisableSpr.gameObject:SetActive(false)
                self.DuanZaoBtnSpr.spriteName = "n_a_01"
                self.DuanZaoBtn.isEnabled = true;
                if self.CurSelectLevel == 1 then
                    self.DuanZaoRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel1, _equipCfg.Part));
                elseif self.CurSelectLevel == 2 then
                    self.DuanZaoRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel2, _equipCfg.Part));
                elseif self.CurSelectLevel == 3 then
                    self.DuanZaoRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel3, _equipCfg.Part));
                end
            end

            -- Refresh set properties
            self.ProGo:SetActive(true);
            UIUtils.SetTextByString(self.SuitName, itemUI.ShowSuitCfg.Cfg.Prefix .. itemUI.ShowSuitCfg.Cfg.Name)
            UIUtils.ClearText(self.SuitCount)

            local _curSuitCfg = GameCenter.EquipmentSuitSystem:FindCfg(itemUI.EquipInst.SuitID);
            local _descList = List:New();
            local _activedList = List:New(itemUI.EquipInst.ActiveSuitNums);
            local _activeIdList = List:New(itemUI.EquipInst.ActiveSuitIds);
            -- CUSTOM - ẩn hiện thị dòng kích hoạt
            -- local _readList = {1, 2, 4, 6};
            local _readList = {1, 2, 3};
            -- CUSTOM - ẩn hiện thị dòng kích hoạt
            local _startY = 70.0;
            for i = 1, #_readList do
                if #_descList > 0 then
                    _descList:Add('\n');
                end

                local _needCount = _readList[i];
                local _proTrans = UIUtils.FindTrans(self.Trans, string.format( "Right/Right/Prop/ProScoll/%d", i));
                local _props = itemUI.ShowSuitCfg.Props[_needCount];
                if _props == nil then
                    _proTrans.gameObject:SetActive(false);
                else
                    _proTrans.gameObject:SetActive(true);
                    UnityUtils.SetLocalPositionY(_proTrans, _startY);

                    local _textColor = "fffef5";
                    local _activeIndex = _activedList:IndexOf(_needCount);
                    if _curSuitCfg ~= nil and _activeIndex > 0 and itemUI.ShowSuitCfg.ID == _activeIdList[_activeIndex] then
                        _textColor = "00e2a5";
                    end

                    local _grid = UIUtils.FindGrid(_proTrans, "Grid");
                    local _propCount = #_props;
                    local _height = 36;
                    for j = 1, 5 do
                        local _itemTrans = UIUtils.FindTrans(_proTrans, string.format( "Grid/%d", j));
                        if j <= _propCount then
                            _itemTrans.gameObject:SetActive(true);
                            _height = _height + 28;
                            local _name = UIUtils.FindLabel(_itemTrans, "Name");
                            local _value = UIUtils.FindLabel(_itemTrans, "Value");
                            UIUtils.SetTextFormat(_name, "[{0}]{1}[-]",  _textColor,  BattlePropTools.GetBattlePropName(_props[j][1]))
                            UIUtils.SetTextFormat(_value, "[{0}]+{1}[-]",  _textColor,  BattlePropTools.GetBattleValueText(_props[j][1],  _props[j][2]))
                        else
                            _itemTrans.gameObject:SetActive(false);
                        end
                    end
                    _grid:Reposition();
                    _startY = _startY - _height;
                end
            end
            self.PropScroll:ResetPosition();
        else
            self.ProGo:SetActive(false);
        end

        -- CUSTOM - sắp xếp lại vị trí ô đá theo Bộ
        -- for i = _resIndex + 1, 3 do
        --     self.NeedItems[i].RootGO:SetActive(false);
        --     self.NeedItemLocks[i]:SetActive(true);
        -- end
        if _resIndex == 1 then
            self.NeedItems[2].RootGO:SetActive(false);
            self.NeedItemLocks[2]:SetActive(true);

            self.NeedItems[3].RootGO:SetActive(false);
            self.NeedItemLocks[3]:SetActive(true);
        elseif _resIndex == 2 then
            self.NeedItems[1].RootGO:SetActive(false);
            self.NeedItemLocks[1]:SetActive(true);

            self.NeedItems[3].RootGO:SetActive(false);
            self.NeedItemLocks[3]:SetActive(true);
        elseif _resIndex == 3 then
            self.NeedItems[1].RootGO:SetActive(false);
            self.NeedItemLocks[1]:SetActive(true);

            self.NeedItems[2].RootGO:SetActive(false);
            self.NeedItemLocks[2]:SetActive(true);
        elseif _resIndex == 0 then
            self.NeedItems[1].RootGO:SetActive(false);
            self.NeedItemLocks[1]:SetActive(true);

            self.NeedItems[2].RootGO:SetActive(false);
            self.NeedItemLocks[2]:SetActive(true);

            self.NeedItems[3].RootGO:SetActive(false);
            self.NeedItemLocks[3]:SetActive(true);
        end
        -- CUSTOM - sắp xếp lại vị trí ô đá theo Bộ
    end
end

-- Click on the Help button
function UIEquipSuitForm:OnHelpBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, FunctionStartIdCode.EquipSuit);
end

-- Forging button click
function UIEquipSuitForm:OnDunZaoBtnClick()
    GameCenter.Network.Send("MSG_Equip.ReqEquipSuit", {eId = self.SelectItem.EquipInst.DBID, sid = self.SelectItem.ShowSuitCfg.ID});
end

return UIEquipSuitForm;
