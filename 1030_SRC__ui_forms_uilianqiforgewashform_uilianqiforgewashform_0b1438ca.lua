-----------------------------------
-- author:
-- Date: 2019-06-15
-- File: UILianQiForgeWashForm.lua
-- Module: UILianQiForgeWashForm
-- Description: Equipment Refining Function Panel
-----------------------------------
local L_LeftItem = require("UI.Forms.UILianQiForgeWashForm.UILeftItem")
local L_AttrItem = require("UI.Forms.UILianQiForgeWashForm.UIAttrItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UILianQiForgeWashForm = {
    EquipScrollView      = nil,
    EquipGrid            = nil, -- Left equipment sliding GRID
    EquipItem            = nil, -- Left equipment control
    EquipDic             = Dictionary:New(), -- Left equipment list
    NoEquipTipsGo        = nil, -- Unequipped prompt gameobject
    RightTrsGo           = nil, -- Transform named "Right" on the right
    BgTableTexture       = nil,
    AttrCloneRoot        = nil, -- Attribute cloning node
    AttrCloneRootGrid    = nil, -- Properties cloning grid component on root node
    AttrCloneItem        = nil,
    AttrCloneItemList    = List:New(),
    BestAttrLab          = nil, -- Best attribute label
    TotalScoreLab        = nil, -- Total score label
    CostItem             = nil, -- Props consumption
    UseMoneyBtn          = nil, -- Use the Ingot Button
    WashBtn              = nil, -- Wash button
    WashRedPointGo       = nil, -- Wash button red dot gameobject
    WashBtnConfirm       = nil, -- Confirm wash button

    UseMoney             = false, -- Whether to check "Use Ingot"
    CurSelectEquipItemGo = nil, -- The currently selected left-hand equipment item
    LockMaxCount         = 2,
    LockIndexList        = List:New(), -- Locked entry list, switch the equipment on the left and clear it
    RightEquipItem       = nil,
    EquipItemTrans       = nil,
    EquipNameLabel       = nil,
    EquipStrengthLabel   = nil,
    BgTexture            = nil,
    BgHV                 = nil,
}

function UILianQiForgeWashForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiForgeWashForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiForgeWashForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.RefreshLeftEquipInfos)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_REFRESH_EQUIPFORGE, self.RefreshPanelInfos)
end

function UILianQiForgeWashForm:RegUICallback()
    UIUtils.AddBtnEvent(self.UseMoneyBtn, self.UseMoneyBtnOnClick, self)
    UIUtils.AddBtnEvent(self.HelpBtn, self.OnHelpBtnClick, self)
    UIUtils.AddBtnEvent(self.WashBtn, self.WashBtnOnClick, self)
    UIUtils.AddBtnEvent(self.WashBtnConfirm, self.WashBtnConfirmOnClick, self)
end

function UILianQiForgeWashForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiForgeWashForm:OnShowBefore()
    self.WashMoneyCostDic = Dictionary:New()
    -- Initialize the equipment and refine the ingot cost dictionary, key = the number of locks, value = the number of ingots required
    local _moneyList = Utils.SplitStrByTableS(DataConfig.DataGlobal[GlobalName.Clear_cost].Params)
    if _moneyList then
        for i = 1, #_moneyList do
            local _lockCount = tonumber(_moneyList[i][1])
            local _needMoneyNum = tonumber(_moneyList[i][3])
            if not self.WashMoneyCostDic:ContainsKey(_lockCount) then
                self.WashMoneyCostDic:Add(_lockCount, _needMoneyNum)
            end
        end
    end
    -- Attached initialization, the number of locks = 0, the number of ingots spent = 0
    self.WashMoneyCostDic:Add(0, 0)
end

function UILianQiForgeWashForm:OnShowAfter()
    self.CurSelectEquipItemGo = nil
    self:SetLeftEquipList(true)
    self:SetLeftEquipListRedPoint()

    self:LoadTexture(self.BgTableTexture, ImageTypeCode.UI, "tex_n_z_53_tb")
    self:LoadTexture(self.BgTexture, ImageTypeCode.UI, "tex_n_z_53")
    self:LoadTexture(self.BgHV, ImageTypeCode.UI, "tex_n_z_53_hv")
end

function UILianQiForgeWashForm:OnHideBefore()
end

function UILianQiForgeWashForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

function UILianQiForgeWashForm:RefreshLeftEquipInfos(obj, sender)
    self:SetLeftEquipList(false)
end

function UILianQiForgeWashForm:RefreshPanelInfos(obj, sender)
    local _curSelectPos = self.CurSelectEquipItemGo.Pos
    if obj == _curSelectPos then
        self:SetLeftEquipListRedPoint()
        self:SetRightAttrs(_curSelectPos)
        self:SetBestAttrAndScore(_curSelectPos)
        self:SetItemCostAndMoney()
        self:UpdateBtnWashRedPoint(_curSelectPos)
        self:UpdateBtnWashConfirm(_curSelectPos)
    end
end

-- Use the Ingot Button
function UILianQiForgeWashForm:UseMoneyBtnOnClick()
    -- If you do not use ingot locks at the moment (you need to use ingots after clicking), you need to make a judgment on the "locked quantity" at this time.
    if not self.UseMoney then
        local _lockCount = self.LockIndexList:Count()
        -- If the current lock number is 0, you cannot click (direct return) and give a prompt
        if _lockCount == 0 then
            Utils.ShowPromptByEnum("LIANQI_FORGE_WASH_NEEDLOCK")
            return
        end
    end
    self.UseMoney = not self.UseMoney
    self:SetItemCostAndMoney()
end
function UILianQiForgeWashForm:OnHelpBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, FunctionStartIdCode.LianQiForgeWash)
end
-- Wash button
function UILianQiForgeWashForm:WashBtnOnClick()
    if not self.CurSelectEquipItemGo then
        return
    end
    if self.LockIndexList:Count() == self.ActiveAttCount then
        Utils.ShowPromptByEnum("C_EQUIPWASH_LOCKERROR")
        return
    end
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _pos = self.CurSelectEquipItemGo.Pos
    local _washInfoList = _forgeSystem:GetWashInfoListByPos(_pos)
    if _washInfoList then
        local _bestIndexList = List:New()
        for i = 1, #_washInfoList do
            -- If the percentage of the attribute is greater than 90%
            if _washInfoList[i].Percent / 100 >= 90 then
                _bestIndexList:Add(_washInfoList[i].Index)
            end
        end
        local _allLocked = true
        -- Iterate through Indexes with a percentage of more than 90% of the properties to see if they are locked
        for i = 1, #_bestIndexList do
            if not self.LockIndexList:Contains(_bestIndexList[i]) then
                _allLocked = false
                break
            end
        end
        if _allLocked then
            self:ReqWashCurPos(_pos)
        else
            Utils.ShowMsgBoxAndBtn(function(x)
                if (x == MsgBoxResultCode.Button2) then
                    self:ReqWashCurPos(_pos)
                end
            end, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", "LIANQI_FORGE_WASH_REDTIPS")
        end
    end
end

function UILianQiForgeWashForm:ReqWashCurPos(pos)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _lockCount = self.LockIndexList:Count()
    if self.UseMoney then
        if self.WashMoneyCostDic:ContainsKey(_lockCount) then
            local _needMoney = self.WashMoneyCostDic[_lockCount]
            local _ignotNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(1) + GameCenter.ItemContianerSystem:GetItemCountFromCfgId(2)
            local _discount = GameCenter.LianQiForgeSystem:GetCurDisCount()
            local _realPrice = math.ceil(_needMoney * _discount / 10)
            if _ignotNum >= _realPrice then
                local _str = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_UI_WASH_CONFIRM1"), _realPrice)
                if _realPrice < _needMoney then
                    _str = _str .. UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_UI_EQUIPWASH_TIPS2"), _needMoney - _realPrice)
                end
                if not _forgeSystem.IsTipsWash then
                    GameCenter.MsgPromptSystem:ShowSelectMsgBox(
                            _str,
                            DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
                            DataConfig.DataMessageString.Get("C_MSGBOX_OK"), function(x)
                                if x == MsgBoxResultCode.Button2 then
                                    _forgeSystem:ReqEquipWash(pos, self.LockIndexList, false)
                                end
                            end,
                            function(x)
                                _forgeSystem.IsTipsWash = x == MsgBoxIsSelect.Selected
                            end,
                            DataConfig.DataMessageString.Get("RICHER_BEN_CI_DENG_LU_BU_ZAI_TI_SHI")
                    )
                else
                    _forgeSystem:ReqEquipWash(pos, self.LockIndexList, false)
                end
            else
                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(1)
            end
        end
    else
        if _forgeSystem.WashItemCostDic:ContainsKey(_lockCount) then
            local _needItemID = _forgeSystem.WashItemCostDic[_lockCount].ItemID
            local _needItemNum = _forgeSystem.WashItemCostDic[_lockCount].NeedNum
            local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_needItemID)
            local _itemCfg = DataConfig.DataItem[_needItemID]
            if _itemCfg then
                if _haveNum < _needItemNum then
                    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_needItemID)
                    Utils.ShowPromptByEnum("MATERIAL_NOT_ENOUGH", _itemCfg.Name)
                else
                    _forgeSystem:ReqEquipWash(pos, self.LockIndexList, true)
                end
            end
        end
    end
end

function UILianQiForgeWashForm:WashBtnConfirmOnClick()
    if not self.CurSelectEquipItemGo then
        return
    end
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _equip = self.CurSelectEquipItemGo.ItemData
    if _equip and _equip.DBID then
        _forgeSystem:ReqEquipWashReceive(_equip.DBID, _equip:GetPart())
    end
end

-- Click on the equipment on the left to update all information on the right
function UILianQiForgeWashForm:LeftEquipItemOnClick(go)
    local _pos = go.Pos
    if not _pos then
        return
    end

    local _equip = go.ItemData
    if not _equip then
        Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
        return
    end

    -- Prevent redundant UI updates if clicking the same item again
    if self.CurSelectEquipItemGo == go then
        return
    end
    -- Deselect the previous selected item (if any)
    if self.CurSelectEquipItemGo ~= go and self.CurSelectEquipItemGo ~= nil then
        self.CurSelectEquipItemGo:OnSetSelect(false)
    end
    -- NOTE(TL): clear WashPreview this Part

    -- Select the new item
    go:OnSetSelect(true)
    self.CurSelectEquipItemGo = go
    -- Clear locked attribute indexes (if list exists)
    self.LockIndexList:Clear()
    -- Reset temporary state
    self.UseMoney = false
    -- Update UI details on the right panel
    self:SetRightAttrs(_pos)
    self:SetBestAttrAndScore(_pos)
    self:SetItemCostAndMoney()
    -- Refresh the red point indicator on the Wash button
    self:UpdateBtnWashRedPoint(_pos)
    self:UpdateBtnWashConfirm(_pos)
end

function UILianQiForgeWashForm:LockBtnOnClick(go)
    local _index = go.CurIndex
    self:SetLock(_index, go)
    self:SetItemCostAndMoney()
end

function UILianQiForgeWashForm:FindAllComponents()
    local _myTrans = self.Trans

    self.EquipScrollView = UIUtils.FindScrollView(_myTrans, "Left/EquipRoot")
    self.EquipGrid = UIUtils.FindGrid(_myTrans, "Left/EquipRoot/Grid")
    local _gridTrans = UIUtils.FindTrans(_myTrans, "Left/EquipRoot/Grid")
    for i = 0, _gridTrans.childCount - 1 do
        self.EquipItem = L_LeftItem:OnFirstShow(_gridTrans:GetChild(i))
        self.EquipItem.CallBack = Utils.Handler(self.LeftEquipItemOnClick, self)
        self.EquipDic:Add(i, self.EquipItem)
    end
    self.NoEquipTipsGo = UIUtils.FindGo(_myTrans, "Left/NoEquipTips")
    self.BgTableTexture = UIUtils.FindTex(_myTrans, "Right/BgTableTexture")
    self.AttrCloneRoot = UIUtils.FindTrans(_myTrans, "Right/AttrCloneGrid")
    self.AttrCloneRootGrid = UIUtils.FindGrid(self.AttrCloneRoot)
    for i = 0, self.AttrCloneRoot.childCount - 1 do
        self.AttrCloneItem = L_AttrItem:OnFirstShow(self.AttrCloneRoot:GetChild(i))
        self.AttrCloneItem.CallBack = Utils.Handler(self.LockBtnOnClick, self)
        self.AttrCloneItemList:Add(self.AttrCloneItem)
    end
    self.BestAttrLab = UIUtils.FindLabel(_myTrans, "Right/BestAttr")
    self.BestAttrLockGo = UIUtils.FindGo(_myTrans, "Right/BestAttr/Lock")
    self.TotalScoreLab = UIUtils.FindLabel(_myTrans, "Right/TotalScore")
    self.CostItem = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Buttom/ItemCost"))
    self.UseMoneyBtn = UIUtils.FindBtn(_myTrans, "Buttom/UseMoney")
    self.UseMoneyText = UIUtils.FindLabel(_myTrans, "Buttom/UseMoney/MoneyCostText")
    self.UseMoneySelectGo = UIUtils.FindGo(_myTrans, "Buttom/UseMoney/selected")
    self.WashBtn = UIUtils.FindBtn(_myTrans, "Buttom/WashBtn")
    self.WashRedPointGo = UIUtils.FindGo(_myTrans, "Buttom/WashBtn/RedPoint")
    self.WashBtnConfirm = UIUtils.FindBtn(_myTrans, "Buttom/ConfirmWashBtn")
    self.UnWashTipsGo = UIUtils.FindGo(_myTrans, "Right/UnWash")
    self.BtnSpr = UIUtils.FindSpr(_myTrans, "Buttom/WashBtn")
    self.HelpBtn = UIUtils.FindBtn(_myTrans, "Right/Help")

    local _equipmentGroupSelect = UIUtils.FindTrans(_myTrans, "Right/EquipmentSellectGroup")
    self.EquipItemTrans = UIUtils.FindTrans(_equipmentGroupSelect, "UIEquipmentItem")
    self.EquipNameLabel = UIUtils.FindLabel(_equipmentGroupSelect, "NameEquip")
    self.EquipStrengthLabel = UIUtils.FindLabel(_equipmentGroupSelect, "Num")
    local _vfxTrs = UIUtils.FindTrans(self.EquipItemTrans, "MyUIVfxSkinCompoent")
    self.VfxSkinCompo = UIUtils.RequireUIVfxSkinCompoent(_vfxTrs)

    self.BgHV = UIUtils.FindTex(_equipmentGroupSelect, "BgHV")
    self.BgTexture = UIUtils.FindTex(_equipmentGroupSelect, "BgTexture")
    self.RightTrsGo = UIUtils.FindGo(_myTrans, "Right")
    self.EquipRightTrans = UIUtils.FindTrans(_myTrans, "Right")
    self.CSForm:AddAlphaPosAnimation(self.EquipRightTrans, 0, 1, 0, 50, 0.3, false, false)
    self.EquipButtomTrans = UIUtils.FindTrans(_myTrans, "Buttom")
    self.CSForm:AddAlphaPosAnimation(self.EquipButtomTrans, 0, 1, 0, -50, 0.3, false, false)
end

function UILianQiForgeWashForm:SetLeftEquipList(playAnim)
    local _animList = nil
    local _forgeSystem = GameCenter.LianQiForgeSystem
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    local _firstSelectableItem = nil
    for i = 0, EquipmentType.Count - 1 do
        local _item = nil
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
        local hasEquip = (_equip ~= nil)
        local isBasicSlot = (i <= EquipmentType.FingerRing)

        if isBasicSlot or hasEquip then
            if self.EquipDic:ContainsKey(i) then
                _item = self.EquipDic[i]
            else
                _item = self.EquipItem:Clone()
                _item.CallBack = Utils.Handler(self.LeftEquipItemOnClick, self)
                self.EquipDic:Add(i, _item)
            end
        end
        
        if _item then
            _item:SetInfo(i, _equip, { level = _forgeSystem:GetStrengthLvByPos(i) })
            _item:OnSetSelect(false)
            _item:SetRed(_forgeSystem:IsWashHaveRedPointByPos(i))
            if playAnim then
                _animList:Add(_item.Trans)
            end
            
            -- LẤY ITEM CÓ THỂ SELECT ĐẦU TIÊN
            if not _firstSelectableItem and _equip then
                _firstSelectableItem = _item
            end
        end
    end
    
    if _firstSelectableItem then
        self.NoEquipTipsGo:SetActive(false)
        self.RightTrsGo:SetActive(true)
        self:LeftEquipItemOnClick(_firstSelectableItem)
    else
        self.NoEquipTipsGo:SetActive(true)
        self.RightTrsGo:SetActive(false)
        self:UpdateBtnWashRedPoint(nil)
        self:UpdateBtnWashConfirm(nil)
    end
    
    if playAnim then
        self.EquipGrid:Reposition()
        self.EquipScrollView:ResetPosition()
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 30, 0.2, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
        end
        
        if self.RightTrsGo.activeSelf then
            self.AnimPlayer:AddTrans(self.EquipRightTrans, 0)
        end
        self.AnimPlayer:AddTrans(self.EquipButtomTrans, 0)
        self.AnimPlayer:Play()
    end
end

-- Set the red dot on the left list
function UILianQiForgeWashForm:SetLeftEquipListRedPoint()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    self.EquipDic:Foreach(function(k, v)
        if v.Go.activeSelf then
            v:SetRed(_forgeSystem:IsWashHaveRedPointByPos(k))
        end
    end)
end

-- Set the property list on the right
function UILianQiForgeWashForm:SetRightAttrs(part)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(part)
    self.UnWashTipsGo:SetActive(false)
    self.ActiveAttCount = 0

    --- ======== Set Equip Item ==========
    if not self.TargetEquipItem then
        self.TargetEquipItem = UILuaItem:New(self.EquipItemTrans)
    end
    self.TargetEquipItem.SingleClick = Utils.Handler(self.TargetEquipItemOnClick, self)
    if _equip ~= nil then
        self.TargetEquipItem:InitWithItemData(_equip)
    else
        self.TargetEquipItem:InitWithItemData()
    end
    local _equipPart = _equip:GetPart() or part
    local _equipName = _equip:GetName() or ""
    local _strengthLv = GameCenter.LianQiForgeSystem:GetStrengthLvByPos(_equipPart) or 0
    UIUtils.SetTextByString(self.EquipNameLabel, _equipName)
    UIUtils.SetTextFormat(self.EquipStrengthLabel, "+{0}", _strengthLv)
    GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.EquipStrengthLabel, _strengthLv)
    --- ==================================

    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _useNewRule = _forgeSystem:IsUseNewWashRule()
    if _useNewRule then
        do
            local _cfg = DataConfig.DataGlobal[GlobalName.Equip_washing_conditions] -- 1_3;2_3;3_4;4_5;5_6
            --- handle with new rule (new data)
            local quality = _equip:GetQuality()
            local _conditions = Utils.SplitStr(_cfg.Params, ';')
            for i = 1, #_conditions do
                local _cond = Utils.SplitNumber(_conditions[i], '_')
                self:SetWashAttrLine(i, _equip, nil, _cond)
                if quality < _cond[2] then
                    --self.UnWashTipsGo:SetActive(true)
                end
            end
        end
    end

    self.AttrCloneRootGrid.repositionNow = true
end

function UILianQiForgeWashForm:UpdateBtnWashRedPoint(part)
    local _btnWashTrans = self.WashBtn.transform
    local _haveRedPoint = GameCenter.LianQiForgeSystem:IsWashHaveRedPointByPos(part)
    if not self.WashRedPointGo then
        self.WashRedPointGo = UIUtils.FindGo(_btnWashTrans, "RedPoint")
    end
    self.WashRedPointGo:SetActive(_haveRedPoint)
end

function UILianQiForgeWashForm:UpdateBtnWashConfirm(part)
    local _btnWashConfirmTrans = self.WashBtnConfirm.transform
    local _forgeSystem = GameCenter.LianQiForgeSystem
    if _forgeSystem:HasPreviewWashInfos(part) then
        UIUtils.SetBtnState(_btnWashConfirmTrans, true)
    else
        UIUtils.SetBtnState(_btnWashConfirmTrans, false)
    end
end

function UILianQiForgeWashForm:TargetEquipItemOnClick(go)
    local _equipItem = go
    if _equipItem.ShowItemData ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(_equipItem.ShowItemData, go.RootGO, ItemTipsLocation.EquipDisplay)
    end
end

--- Sets up and displays a single washed attribute line in the UI. (use with old rule)
-- @param index number The attribute line index. (ex: 1,2,3,4)
-- @param equip table Equipment data
-- @param att table Attribute data (ex: 1_42_846) -- -- use with oldRule
-- @param ar any Additional argument (ex: {1,0}])
function UILianQiForgeWashForm:SetWashAttrLine(index, equip, att, ar)
    local item -- L_AttrItem (UIAttrItem)
    if index <= #self.AttrCloneItemList then
        item = self.AttrCloneItemList[index]
    else
        item = self.AttrCloneItem:Clone()
        item.CallBack = Utils.Handler(self.LockBtnOnClick, self)
        self.AttrCloneItemList:Add(item)
    end
    if item then
        item:SetInfo(index, equip, att, ar)
        local isRed = item.IsRedAttr
        local isLocked = self.LockIndexList:Contains(index)
        --if isRed and not isLocked then
        --    self.LockIndexList:Add(index)
        --end
        item:SetLockedState(isLocked)

        if item.IsActive then
            self.ActiveAttCount = self.ActiveAttCount + 1
        end
    end
    item.Go:SetActive(true)
end

function UILianQiForgeWashForm:SetBestAttrAndScore(pos)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _totalScore = _forgeSystem:GetWashScoreByPos(pos)
    local _bestAttrCfg = DataConfig.DataWashBest[_forgeSystem:GetBestAttrCfgID(pos)]
    if _bestAttrCfg then
        local _goalScore = _bestAttrCfg.Condition
        local _attrs = Utils.SplitStrByTableS(_bestAttrCfg.Attribute)
        local _attrID = tonumber(_attrs[1][1])
        local _attrValue = tonumber(_attrs[1][2])
        local _attrCfg = DataConfig.DataAttributeAdd[_attrID]
        if _attrCfg then
            local _txt = _attrCfg.ShowPercent == 0 and tostring(_attrValue) or string.format("%s%%", tostring(math.FormatNumber(_attrValue / 100)))
            UIUtils.SetTextByEnum(self.BestAttrLab, "LIANQI_FORGE_WASH_BESTATTR", _attrCfg.Name, _txt, _goalScore)
        end
        -- self.BestAttrLab.color = _totalScore < _goalScore and Color.gray or Color.green
        self.BestAttrLockGo:SetActive(_totalScore < _goalScore)
    end
    UIUtils.SetTextByNumber(self.TotalScoreLab, _totalScore)
end

function UILianQiForgeWashForm:SetItemCostAndMoney()
    local _lockCount = self.LockIndexList:Count()
    local _forgeSystem = GameCenter.LianQiForgeSystem
    if _lockCount == 0 then
        self.UseMoney = false
    end
    self.UseMoneySelectGo:SetActive(self.UseMoney)
    if _forgeSystem.WashItemCostDic:ContainsKey(_lockCount) then
        local _needMoneyNum = self.WashMoneyCostDic[_lockCount]
        UIUtils.SetTextByEnum(self.UseMoneyText, "C_UI_WASH_CONFIRM2", _needMoneyNum)
    else
        UIUtils.ClearText(self.UseMoneyText)
    end
    _lockCount = self.UseMoney and 0 or _lockCount
    if self.CostItem then
        if _forgeSystem.WashItemCostDic:ContainsKey(_lockCount) then
            local _needItemID = _forgeSystem.WashItemCostDic[_lockCount].ItemID
            local _needItemCount = _forgeSystem.WashItemCostDic[_lockCount].NeedNum
            self.CostItem:InItWithCfgid(_needItemID, _needItemCount, false, true)
            self.CostItem:BindBagNum()
        end
    end
end

-- Set whether to lock
function UILianQiForgeWashForm:SetLock(index, trans)
    local _equip = self.CurSelectEquipItemGo.ItemData
    if self.LockIndexList:Contains(index) then
        -- Cancel lock
        self.LockIndexList:Remove(index)
        trans:SetLockedState(false)
        trans:HandleSetLock(_equip, index, false)
    else
        -- Add lock
        if self.LockIndexList:Count() >= self.LockMaxCount then
            Utils.ShowPromptByEnum("LIANQI_FORGE_WASH_LOCKMAX", self.LockMaxCount)
            return
        end
        if self.LockIndexList:Count() == self.ActiveAttCount - 1 then
            Utils.ShowPromptByEnum("LIANQI_FORGE_WASH_CANTLOCKALL")
            return
        end
        self.LockIndexList:Add(index)
        trans:SetLockedState(true)
        trans:HandleSetLock(_equip, index, true)
    end
end

return UILianQiForgeWashForm
