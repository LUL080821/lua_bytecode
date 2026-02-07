-- author:
-- Date: 2019-05-09
-- File: UILianQiGemForm.lua
-- Module: UILianQiGemForm
-- Description: First-level pagination of refining functions: Gem panel
------------------------------------------------
local L_UIEquipmentItem = require("UI.Components.UIEquipmentItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local UILianQiGemForm = {
    UIListMenu = nil,-- List
    Form = LianQiGemSubEnum.Begin, -- Pagination Type
    LeftEquipItemClone = nil,-- The left side is equipped with clone
    LeftCloneRoot = nil,-- The left side is equipped with the root node
    CurSelectPos = 0,-- The currently selected part
    CurSelectSubForm = LianQiGemSubEnum.Inlay,      -- Current page
    CurSelectGo = nil,-- Gameobject is currently selected
    EquipItemByPosDic = Dictionary:New(),-- The automatic equipment component list on the left, key = position, value = UIEquipmentItem component
    AnimTransList = nil,
}

local L_LeftItem = {}

local NGUITools = CS.NGUITools

function UILianQiGemForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiGemForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiGemForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GEMINLAYINFO, self.RefreshGemInlayInfo)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REMOVE_GEM, self.RefreshGemRemove) -- lắng nghe sự kiện gỡ ngọc thành công
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_JADEINLAYINFO, self.RefreshJadeInlayInfo)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GEMREFINEINFO, self.RefreshRefineInfo)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, self.SelectPos)
end

function UILianQiGemForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj and obj <= LianQiGemSubEnum.Count then
        self.Form = obj
    end
    self.UIListMenu:SetSelectById(self.Form)
end

function UILianQiGemForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

function UILianQiGemForm:RegUICallback()
    
end

function UILianQiGemForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiGemForm:OnShowAfter()
end

function UILianQiGemForm:OnHideBefore()
    self.UIListMenu:SetSelectByIndex(-1)
end

function UILianQiGemForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

function UILianQiGemForm:OnClickCloseBtn()
    self:OnClose(nil, nil)
end

function UILianQiGemForm:SelectPos(obj, sender)
    if self.EquipItemByPosDic:ContainsKey(obj) then
        local _go = self.EquipItemByPosDic[obj]
        self:LeftItemOnClick(_go)
    end
end

function UILianQiGemForm:RefreshGemInlayInfo(obj, sender)
    local _gemSystem = GameCenter.LianQiGemSystem

    if #obj >= 3 then
        local _pos = obj[1]
        local _index = obj[2]
        local _newGemID = obj[3]
        if self.CurSelectSubForm == LianQiGemSubEnum.Inlay then
            if self.EquipItemByPosDic:ContainsKey(_pos) then
                local _go = self.EquipItemByPosDic[_pos]
                local _newGemItemCfg = DataConfig.DataItem[_newGemID]
                if _newGemItemCfg and _go then
                    _go.StoneIconList[_index]:UpdateIcon(_newGemItemCfg.Icon)
                else
                    _go.StoneIconList[_index]:UpdateIcon(0)
                end
            end
        end
    end
    for i=0, EquipmentType.Count - 1 do
        if self.EquipItemByPosDic:ContainsKey(i) then
            self.EquipItemByPosDic[i].RedPointGo:SetActive(_gemSystem:IsGemPosHaveRedPoint(i))
        end
    end
end

-- Cập nhật lại icon ngọc sidebar khi remove ngọc

function UILianQiGemForm:RefreshGemRemove(obj, sender)
    local _gemSystem = GameCenter.LianQiGemSystem

    local pos = obj[1]

    if(obj[2] == -1) then --- remove all
        

        -- print(" RemoveGem done, refresh pos =", pos)

        local _go = self.EquipItemByPosDic[pos]
        if not _go then
            -- print(" Không tìm thấy EquipItemByPosDic cho pos", pos)
            return
        end

        -- lấy thông tin trang bị để biết số slot
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        local level = _equip and _equip.ItemInfo.Quality or 1
        local slotCount = _gemSystem:GetSlotCountByLevel(level, pos)

        -- reset toàn bộ gem của item này về 0
        local _newGemIDList = {}
        for k = 1, slotCount do
            _newGemIDList[k] = 0
        end

        -- cập nhật lại hệ thống
        _gemSystem.GemInlayInfoByPosDic[pos] = _newGemIDList

        -- refresh lại hiển thị icon
        _go:UpdateStoneHide(_newGemIDList, slotCount)

        -- print(" Sidebar đã clear toàn bộ icon gem cho pos =", pos)

    else
        -- remove 1 slot
        local slotIndex = obj[2] + 1  -- index tăng 1 trong lua

        local _go = self.EquipItemByPosDic[pos]
        if not _go then
            -- print("Không tìm thấy EquipItemByPosDic cho pos", pos)
            return
        end

        -- lấy danh sách hiện tại
        local gemList = _gemSystem.GemInlayInfoByPosDic[pos]
        if not gemList then return end

        -- gỡ ngọc ở vị trí slotIndex
        gemList[slotIndex] = 0

        -- cập nhật lại hệ thống
        _gemSystem.GemInlayInfoByPosDic[pos] = gemList

        -- refresh lại hiển thị icon (ẩn icon slot đó)
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        local level = _equip and _equip.ItemInfo.Quality or 1
        local slotCount = _gemSystem:GetSlotCountByLevel(level, pos)
        _go:UpdateStoneHide(gemList, slotCount)

        -- print(("🧱 Đã remove slot %d ở pos %d"):format(slotIndex, pos))

        -- print("==============================_gemSystem.GemInlayInfoByPosDic_gemSystem.GemInlayInfoByPosDic_gemSystem.GemInlayInfoByPosDic==", Inspect(_gemSystem.GemInlayInfoByPosDic))

    end

    
end



function UILianQiGemForm:RefreshRefineInfo(obj, sender)
    local _gemSystem = GameCenter.LianQiGemSystem
    if self.EquipItemByPosDic:ContainsKey(obj) then
        local _go = self.EquipItemByPosDic[obj]
        if _go then
            local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(obj)
            if _equip then
                if _gemSystem.GemRefineInfoByPosDic:ContainsKey(obj) then
                    local _refineInfo = _gemSystem.GemRefineInfoByPosDic[obj]
                    UIUtils.SetTextFormat(_go.NameLabel, "{0}+{1}",  _equip.Name,  _refineInfo.Level)
                else
                    UIUtils.SetTextFormat(_go.NameLabel, "{0}+{1}",  _equip.Name,  0)
                end
            else
                UIUtils.ClearText(_go.NameLabel)
            end
            self:LeftItemOnClick(_go)
        end
    end
    for i=0, EquipmentType.Count - 1 do
        if self.EquipItemByPosDic:ContainsKey(i) then
            self.EquipItemByPosDic[i].RedPointGo:SetActive(_gemSystem:IsGemRefinePosHaveRedPoint(i))
        end
    end
end

function UILianQiGemForm:RefreshJadeInlayInfo(obj, sender)
    local _gemSystem = GameCenter.LianQiGemSystem
    if #obj >= 3 then
        local _pos = obj[1]
        local _index = obj[2]
        local _newJadeID = obj[3]
        if self.CurSelectSubForm == LianQiGemSubEnum.Jade then
            if self.EquipItemByPosDic:ContainsKey(_pos) then
                local _go = self.EquipItemByPosDic[_pos]
                local _newJadeItemCfg = DataConfig.DataItem[_newJadeID]
                if _newJadeItemCfg and _go then
                    _go.StoneIconList[_index]:UpdateIcon(_newJadeItemCfg.Icon)
                else
                    _go.StoneIconList[_index]:UpdateIcon(0)
                end
            end
        end
    end
    for i=0, EquipmentType.Count - 1 do
        if self.EquipItemByPosDic:ContainsKey(i) then
            local _go = self.EquipItemByPosDic[i]
            _go.RedPointGo:SetActive(_gemSystem:IsJadePosHaveRedPoint(i))
        end
    end
end

function UILianQiGemForm:LeftItemOnClick(go)
    if self.CurSelectGo == go then
        do return end
    else
        if self.CurSelectGo ~= nil then
            self.CurSelectGo:OnSetSelect(false)
        end
        go:OnSetSelect(true)
        self.CurSelectPos = go.Pos
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESHRIGHTINFOS, self.CurSelectPos)
        self.CurSelectGo = go
    end
end

function UILianQiGemForm:FindAllComponents()
    local _myTrans = self.Trans
    self.Scroll = UIUtils.FindScrollView(_myTrans, "LeftList")
    self.LeftGrid = UIUtils.FindGrid(_myTrans, "LeftList/Grid")
    self.LeftCloneRoot = UIUtils.FindTrans(_myTrans, "LeftList/Grid")
    local _count = self.LeftCloneRoot.childCount
    self.AnimTransList = List:New()
    for i = 0, EquipmentType.Count - 1 do
        local _go = nil
        if i < _count then
            self.LeftEquipItem = L_LeftItem:OnFirstShow(self.LeftCloneRoot:GetChild(i))
            _go =self.LeftEquipItem
        else
            _go = self.LeftEquipItem:Clone()
        end
        if _go then
            _go.SingleClick = Utils.Handler(self.LeftItemOnClick, self)
            _go.Go:SetActive(true)
            _go:UpdateItem(i)
            _go:OnSetSelect(false)
            if not self.EquipItemByPosDic:ContainsKey(i) then
                self.EquipItemByPosDic:Add(i, _go)
            else
                self.EquipItemByPosDic[i] = _go
            end
            self.AnimTransList:Add(_go.Trans)
        end
    end
    self.UIListMenu = UIUtils.RequireUIListMenu(_myTrans:Find("UIListMenu"))
    self.UIListMenu:OnFirstShow(self.CSForm)
    self.UIListMenu:AddIcon(LianQiGemSubEnum.Inlay, DataConfig.DataMessageString.Get("LIANQI_GEM_INLAY"), FunctionStartIdCode.LianQiGemInlay)
    -- TODO: Mở lại sau
    -- self.UIListMenu:AddIcon(LianQiGemSubEnum.Refine, DataConfig.DataMessageString.Get("LIANQI_GEM_REFINE"), FunctionStartIdCode.LianQiGemRefine)
    -- self.UIListMenu:AddIcon(LianQiGemSubEnum.Jade, DataConfig.DataMessageString.Get("LIANQI_GEM_JADEINLAY"), FunctionStartIdCode.LianQiGemJade)
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    self.UIListMenu.IsHideIconByFunc = true
    self:InitLeftList()
end

function UILianQiGemForm:InitLeftList()
    self.LeftGrid:Reposition()
    self.Scroll:ResetPosition()
end

function UILianQiGemForm:OnMenuSelect(id, open)
    self.Form = id
    if open then
        self:OpenSubForm(id)
        self:InitLeftList()
        for i = 1, #self.AnimTransList do
            local _trans = self.AnimTransList[i]
            if _trans.gameObject.activeSelf then
                self.CSForm:RemoveTransAnimation(_trans)
                self.CSForm:AddAlphaPosAnimation(_trans, 0, 1, 0, 30, 0.2, false, false)
                self.AnimPlayer:AddTrans(_trans, (i - 1) * 0.05)
            end
        end
        self.AnimPlayer:Play()
    else
        self:CloseSubForm(id)
    end
end

function UILianQiGemForm:OpenSubForm(id)
    if id == LianQiGemSubEnum.Inlay then
        -- Gem inlay
        if self.EquipItemByPosDic:ContainsKey(0) then
            self:LeftItemOnClick(self.EquipItemByPosDic[0])
        end
        self:SetGemInlayList()
        self.CurSelectSubForm = LianQiGemSubEnum.Inlay
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemInlayForm_OPEN, self.CurSelectPos, self.CSForm)
        self.Scroll:ResetPosition()
    elseif id == LianQiGemSubEnum.Refine then
        -- Gem Refining
        if self.EquipItemByPosDic:ContainsKey(0) then
            self:LeftItemOnClick(self.EquipItemByPosDic[0])
        end
        self:SetGemRefineList()
        self.CurSelectSubForm = LianQiGemSubEnum.Refine
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemRefineForm_OPEN, self.CurSelectPos, self.CSForm)
        self.Scroll:ResetPosition()
    elseif id == LianQiGemSubEnum.Jade then
        -- Fairy Jade Inlay
        if self.EquipItemByPosDic:ContainsKey(0) then
            self:LeftItemOnClick(self.EquipItemByPosDic[0])
        end
        self:SetGemJadeList()
        self.CurSelectSubForm = LianQiGemSubEnum.Jade
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemJadeForm_OPEN, self.CurSelectPos, self.CSForm)
        self.Scroll:ResetPosition()
    end
end

function UILianQiGemForm:CloseSubForm(id)
    if id == LianQiGemSubEnum.Inlay then
        -- Gem inlay
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemInlayForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiGemSubEnum.Refine then
        -- Gem Refining
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemRefineForm_CLOSE, nil, self.CSForm)
    elseif id == LianQiGemSubEnum.Jade then
        -- Fairy Jade Inlay
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemJadeForm_CLOSE, nil, self.CSForm)
    end
end


function UILianQiGemForm:SetGemInlayList()
    local _gemSystem = GameCenter.LianQiGemSystem

    for i=0, EquipmentType.Count - 1 do
        local _go = self.EquipItemByPosDic[i]
        if _go then
            _go:UpdateItem(i)
            local _gemInlayInfoDic = _gemSystem.GemInlayInfoByPosDic
            if _gemInlayInfoDic and _gemInlayInfoDic:ContainsKey(i) then
                local _gemIDList = _gemInlayInfoDic[i]

                -- lấy level + slotCount
                local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
                local level = _equip and _equip.ItemInfo.Quality or 1
                local slotCount = _gemSystem:GetSlotCountByLevel(level, i)

                local _newGemIDList = {}
                for k = 1, slotCount do
                    _newGemIDList[k] = _gemIDList[k] or 0
                end

                _go:UpdateStoneHide(_newGemIDList, slotCount)
            end

            _go.RedPointGo:SetActive(_gemSystem:IsGemPosHaveRedPoint(i))
        end
    end
end

--[Gosu custom]
function L_LeftItem:UpdateStoneHide(_gemIDList, slotCount)
    for j = 1, #self.StoneIconList do
        local icon = self.StoneIconList[j]
        local parentGo = icon.transform.parent.gameObject  -- lấy node "StoneX"

        if j <= slotCount then
            parentGo:SetActive(true)  -- hiện nguyên slot
            if _gemIDList[j] and _gemIDList[j] > 0 then
                local _itemCfg = DataConfig.DataItem[_gemIDList[j]]
                icon:UpdateIcon(_itemCfg and _itemCfg.Icon or 0)
            else
                icon:UpdateIcon(0) -- slot mở nhưng chưa khảm
            end
        else
            parentGo:SetActive(false)  -- ẩn hẳn slot thừa
        end
    end
end



--code cũ
-- function UILianQiGemForm:SetGemInlayList()
--     local _gemSystem = GameCenter.LianQiGemSystem
--     for i=0, EquipmentType.Count - 1 do
--         local _go = self.EquipItemByPosDic[i]
--         if _go then
--             _go:UpdateItem(i)
--             local _gemInlayInfoDic = _gemSystem.GemInlayInfoByPosDic
--             if _gemInlayInfoDic then
--                 if _gemInlayInfoDic:ContainsKey(i) then
--                     local _gemIDList = _gemInlayInfoDic[i]
--                     _go:UpdateStone(_gemIDList)
--                 end
--             end
--             _go.RedPointGo:SetActive(_gemSystem:IsGemPosHaveRedPoint(i))
--         end
--     end
-- end

function UILianQiGemForm:SetGemRefineList()
    local _gemSystem = GameCenter.LianQiGemSystem
    self:SetGemInlayList()
    for i=0, EquipmentType.Count - 1 do
        local _go = self.EquipItemByPosDic[i]
        if _go then
            local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
            if _equip then
                if _gemSystem.GemRefineInfoByPosDic:ContainsKey(i) then
                    local _refineInfo = _gemSystem.GemRefineInfoByPosDic[i]
                    UIUtils.SetTextFormat(_go.NameLabel, "{0}+{1}",  _equip.Name,  _refineInfo.Level)
                else
                    UIUtils.SetTextFormat(_go.NameLabel, "{0}+{1}",  _equip.Name,  0)
                end
            else
                UIUtils.ClearText(_go.NameLabel)
            end
            _go.RedPointGo:SetActive(_gemSystem:IsGemRefinePosHaveRedPoint(i))
        end
    end
end

function UILianQiGemForm:SetGemJadeList()
    local _gemSystem = GameCenter.LianQiGemSystem
    for i=0, EquipmentType.Count - 1 do
        local _go = self.EquipItemByPosDic[i]
        if _go then
            _go:UpdateItem(i)
            local _jadeInlayInfoDic = _gemSystem.JadeInlayInfoByPosDic
            if _jadeInlayInfoDic then
                if _jadeInlayInfoDic:ContainsKey(i) then
                    local _gemIDList = _jadeInlayInfoDic[i]
                    _go:UpdateStone(_gemIDList)
                end
            end
            _go.RedPointGo:SetActive(_gemSystem:IsJadePosHaveRedPoint(i))
        end
    end
end

function L_LeftItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

function L_LeftItem:Clone()
    local _trans = UnityUtils.Clone(self.Go)
    return L_LeftItem:OnFirstShow(_trans.transform)
end

function L_LeftItem:FindAllComponents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "EquipName")
    self.EquipItem = L_UIEquipmentItem:New(UIUtils.FindTrans(self.Trans, "UIEquipmentItem"))
    self.EquipItem.SingleClick = nil
    self.EquipedGo = UIUtils.FindGo(self.Trans, "Equiped")
    self.SelectGo = UIUtils.FindGo(self.Trans, "SelectBg")
    self.RedPointGo = UIUtils.FindGo(self.Trans, "RedPoint")
    self.StoneIconList = List:New()
    local _stoneTrans = UIUtils.FindTrans(self.Trans, "Stones")
    for i = 0, _stoneTrans.childCount - 1 do
        local _str = string.format( "Stone%d/Icon", i + 1 )
        local _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_stoneTrans, _str))
        self.StoneIconList:Add(_icon)
    end
    self.Btn = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(self.Btn, self.OnClick, self)
end

function L_LeftItem:OnClick()
    if self.SingleClick then
        self.SingleClick(self)
    end
end

function L_LeftItem:UpdateItem(index)
    self.Pos = index
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(index)
    local _starLv = 0
    if _equip ~= nil then
        self.EquipItem:UpdateEquipment(_equip, index, _starLv)
        self.EquipedGo:SetActive(true)
    else
        self.EquipItem:UpdateEquipmentByType(index, _starLv)
        self.EquipedGo:SetActive(false)
    end
    UIUtils.SetTextByString(self.NameLabel, _equip and _equip.Name or "")
    self.Go:SetActive(_equip or index <= EquipmentType.FingerRing)
end

function L_LeftItem:UpdateStone(_gemIDList)
    for j = 1, #self.StoneIconList do
        if _gemIDList[j] and _gemIDList[j] > 0 then
            local _itemCfg = DataConfig.DataItem[_gemIDList[j]]
            if _itemCfg then
                self.StoneIconList[j]:UpdateIcon(_itemCfg.Icon)
            else
                self.StoneIconList[j]:UpdateIcon(0)
            end
        else
            self.StoneIconList[j]:UpdateIcon(0)
        end
    end
end

function L_LeftItem:OnSetSelect(isSelect)
    self.SelectGo:SetActive(isSelect)
    if isSelect then
        UIUtils.SetColorByString(self.NameLabel, "#202027")
    else
        UIUtils.SetColorByString(self.NameLabel, "#202027")
    end
end
return UILianQiGemForm
