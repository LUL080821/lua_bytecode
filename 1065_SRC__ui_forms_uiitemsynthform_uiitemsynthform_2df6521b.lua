------------------------------------------------
-- author:
-- Date: 2019-05-31
-- File: UIItemSynthForm.lua
-- Module: UIItemSynthForm
-- Description: Item synthesis interface
------------------------------------------------
local L_PlayerBagItem = require("UI.Components.UIPlayerBagItem")
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local UIItemSynthForm = {
    -- Synthesize a button
    SynthOneBtn = nil,
    -- Compose all buttons
    SynthAllBtn = nil,
    -- One-click synthesis button
    SynthAutoBtn = nil,
    -- Increase currency
    AddCoinBtn = nil,
    -- TIPS shows how many in one, like three in one, five in one
    TipsLabel = nil,
    -- Single consumption
    SingleCostLabel = nil,
    -- All consumed
    AllCostLabel = nil,
    -- The amount of currency possessed
    HaveLabel = nil,
    -- background
    BackTexture = nil,
    Grid = nil,
    GridTrans = nil,
    ScrollView = nil,
    BagItem = nil,
    -- Material
    MaterialItemList = List:New(),
    -- result
    ResultItemList = List:New(),
    -- Select List
    SelectItemList = List:New(),
    -- Extra consumption icon
    IconList = List:New(),
    -- Additional currency consumed
    CoinType = ItemTypeCode.BindMoney,
    MaterialTable = nil,
    ResultTable = nil,
    -- Open the default selected item on the interface
    ItemData = nil,
    -- Save backpack lattice data
    BagItemList = List:New(),
    -- loại đá hiện tại đang được phép add
    CurrentPutCfgId = nil
}
-- --------------------------------------------------------------------------------------------------------------------------------
-- Message registration
function UIItemSynthForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIItemSynthForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIItemSynthForm_CLOSE,self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUT, self.OnItemPut)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUTOUT, self.OnItemPutOut)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_RESULT, self.OnUpdateBag)
end

function UIItemSynthForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()

    self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
end

function UIItemSynthForm:OnHideBefore()
    self.SelectItemList:Clear()
    self.BagItemList:Clear()
    self.ItemData = nil
    if self.VfxSkin then
        self.VfxSkin:OnDestory()
    end
    self.CurrentPutCfgId = nil
end

function UIItemSynthForm:OnShowAfter()
    self:OnUpdateBag()
    self.CSForm.FormType = CS.Thousandto.Plugins.Common.UIFormType.Hint
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_53"))
end

function UIItemSynthForm:Update(dt)
    for i = 1, #self.BagItemList do
        if self.BagItemList[i].ShowData then
            self.BagItemList[i]:Update()
        end
    end
end



--------------------------------------endregion

-- --------------------------------------------------------------------------------------------------------------------------------
-- Event trigger opening interface
function UIItemSynthForm:OnOpen(obj, sender)
    self.ItemData = obj
    if type(self.ItemData) == "number" then
        self.ItemData = nil
    end
    self.CSForm:Show(sender)
    self:TryFixResultNumByBagCount()
end

-- Select items from TIPS Put in
-- function UIItemSynthForm:OnItemPut(obj, sender)
--     local _item = obj
--     if _item == nil or _item.ItemInfo == nil then
--         return
--     end
--     local _bagItem = self:OnUpdateBagItem(_item)
--     if _bagItem == nil then
--         return
--     end
--     if #self.SelectItemList > 0 then
--         if _item.CfgID ~= self.SelectItemList[1].ShowData.CfgID then
--             for i = 1, #self.SelectItemList do
--                 self.SelectItemList[i]:SelectItem(false)
--             end
--             self.SelectItemList:Clear()
--         end
--     end
--     self.SelectItemList:Add(_bagItem)
--     self:OnUpdateMaterial()
--     self:TryFixResultNumByBagCount()
-- end

function UIItemSynthForm:ClearBagSelectUI()
    if not self.BagItemList then
        return
    end

    for i = 1, #self.BagItemList do
        local trans = self.BagItemList[i]
        if trans then
            trans:SelectItem(false)
        end
    end
end

function UIItemSynthForm:OnItemPut(obj, sender)
    local _item = obj
    if not _item or not _item.ItemInfo then
        return
    end

    -- Nếu đã có item trong slot
    if #self.SelectItemList > 0 then
        local first = self.SelectItemList[1].ShowData
        if first then
            local needClear = false

            -- bind/unbind khác nhau
            if first.IsBind ~= _item.IsBind then
                needClear = true
            end

            -- đá khác loại
            if first.CfgID ~= _item.CfgID then
                needClear = true
            end

            if needClear then
                -- clear logic + UI
                self.SelectItemList:Clear()
                self:ClearBagSelectUI()
            end
        end
    end

    --  BÂY GIỜ MỚI active item trong túi
    local _bagItem = self:OnUpdateBagItem(_item)
    if not _bagItem then
        return
    end

    self.SelectItemList:Add(_bagItem)
    self:OnUpdateMaterial()
    self:TryFixResultNumByBagCount()
end




-- Select items from TIPS Remove
function UIItemSynthForm:OnItemPutOut(obj, sender)
    local _item = obj
    if _item == nil or _item.ItemInfo == nil then
        return
    end
    local _bagItem = self:OnUpdateBagItem(_item)
    if _bagItem == nil then
        return
    end
    if #self.SelectItemList > 0 then
        for i = 1, #self.SelectItemList do
            if _item.DBID == self.SelectItemList[i].ShowData.DBID then
                self.SelectItemList[i]:SelectItem(false)
                self.SelectItemList:RemoveAt(i)
                break
            end
        end
    end
    self:OnUpdateMaterial()
end

-- Update backpack
function UIItemSynthForm:OnUpdateBag(obj, sender)
    if obj then
        if self.VfxSkin then
            self.VfxSkin:OnDestory()
        end
        self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 116, LayerUtils.GetAresUILayer());
    end
    self.SelectItemList:Clear()
    local _list = GameCenter.ItemContianerSystem:GetCanSynthItemList()
    local maxCount = math.ceil(self.ScrollView.panel.height / self.Grid.cellHeight)
    maxCount = maxCount * self.Grid.maxPerLine
    local fillCount = _list.Count < maxCount and maxCount or _list.Count
    fillCount = fillCount < self.GridTrans.childCount and self.GridTrans.childCount or fillCount
    for i = 0, fillCount - 1 do
        local trans = nil
        local item = nil
        if _list.Count > i then
            item = _list[i]
        end
        if self.GridTrans.childCount <= i then
            -- When the grid is not enough, load a row
            for index = i % self.Grid.maxPerLine, self.Grid.maxPerLine - 1 do
                UnityUtils.Clone(self.BagItem)
            end
        end
        if #self.BagItemList > i then
            trans = self.BagItemList[i + 1]
        else
            trans = L_PlayerBagItem:New(self.GridTrans:GetChild(i))
            --trans:OnSetCallBack(Utils.Handler(self.OnSingleClickItem, self), Utils.Handler(self.OnDoubleClickItem, self))
            trans:OnSetCallBack(Utils.Handler(self.OnSingleClickItem, self), nil)
            self.BagItemList:Add(trans)
        end
        self:OnFillCell(trans, item)
    end

    self.Grid.repositionNow = true
    self.ScrollView:ResetPosition()
    self:OnUpdateSelectInfo()
end
--------------------------------------endregion
------------------------------------------------------------------------------------------------------------------------- chỉnh sửa thêm hàm

function UIItemSynthForm:OnSynthMsgAutoAll(type)
    if #self.SelectItemList <= 0 then
        self:OnSynthMsg(type)
        return
    end

    local first = self.SelectItemList[1].ShowData
    if not first or not first.CfgID then
        self:OnSynthMsg(type)
        return
    end

    local cfgId = first.CfgID

    --  LẤY CẤU HÌNH TỪ DataConfig.DataItem (GIỐNG OnUpdateMaterial)

    local needCount = 5
    local cfgItem = DataConfig.DataItem[cfgId]
    if cfgItem ~= nil and cfgItem.HechenTarget then
        local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
        if #strArr == 2 then
            needCount = tonumber(strArr[2]) or needCount
        end
    end

    --  ĐẾM SỐ LƯỢNG TRONG TÚI THEO BIND / UNBIND
    local bindCount = 0
    local unBindCount = 0

    for i = 1, #self.BagItemList do
        local data = self.BagItemList[i].ShowData
        if data and data.CfgID == cfgId then
            if data.IsBind then
                bindCount = bindCount + data.Count
            else
                unBindCount = unBindCount + data.Count
            end
        end
    end

    --  SỐ LẦN SYNTH
    local bindTimes   = math.floor(bindCount / needCount)
    local unbindTimes = math.floor(unBindCount / needCount)

    local needBindTotal   = bindTimes * needCount
    local needUnBindTotal = unbindTimes * needCount

    if needBindTotal <= 0 and needUnBindTotal <= 0 then
        self:OnSynthMsg(type)
        return
    end

    -- clear selection cũ
    self.SelectItemList:Clear()

    local takenUnbind = 0
    local takenBind = 0

    for i = 1, #self.BagItemList do
        local item = self.BagItemList[i]
        local data = item.ShowData
        if data and data.CfgID == cfgId then
            if not data.IsBind and takenUnbind < needUnBindTotal then
                item:SelectItem(true)
                self.SelectItemList:Add(item)
                takenUnbind = takenUnbind + data.Count
            elseif data.IsBind and takenBind < needBindTotal then
                item:SelectItem(true)
                self.SelectItemList:Add(item)
                takenBind = takenBind + data.Count
            else
                item:SelectItem(false)
            end
        else
            item:SelectItem(false)
        end
    end

    --  GỬI REQUEST
    if #self.SelectItemList > 0 then
        self:OnSynthMsg(type)
    else
        Utils.ShowPromptByEnum("C_UI_ITEMSYNTH_NOMATERAIL1_TIPS")
    end
end




-- Hàm chỉnh sửa để đặt vào 1 item mà vẫn có thể nâng được

function UIItemSynthForm:OnSynthMsgCustom(type)
    -- phải có ít nhất 1 item đã đặt
    if #self.SelectItemList <= 0 then
        self:OnSynthMsg(type)
        return
    end

    local first = self.SelectItemList[1].ShowData
    if not first or not first.CfgID then
        self:OnSynthMsg(type)
        return
    end

    local cfgId = first.CfgID

    -- tìm số lượng cần từ CanSynthPieceList (giống logic auto cũ)
    -- local needCount = 5
    -- local canList = GameCenter.ItemContianerSystem:GetCanSynthPieceList()
    -- for i = 0, canList.Count - 1 do
    --     if canList[i].CfgID == cfgId then
    --         local cfgItem = canList[i].ItemInfo
    --         if cfgItem ~= nil then
    --             local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
    --             if #strArr == 2 then
    --                 needCount = tonumber(strArr[2]) or needCount
    --             end
    --         end
    --         break
    --     end
    -- end

    local needCount = 5
    local cfgItem = DataConfig.DataItem[cfgId]
    if cfgItem ~= nil and cfgItem.HechenTarget then
        local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
        if #strArr == 2 then
            needCount = tonumber(strArr[2]) or needCount
        end
    end




    local haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(cfgId)
    if haveCount < needCount then
        self:OnSynthMsg(type)
        return
    end

    -- clear selection cũ và auto select đủ item
    self.SelectItemList:Clear()
    local taken = 0
    for i = 1, #self.BagItemList do
        if taken >= needCount then break end
        local item = self.BagItemList[i]
        if item.ShowData and item.ShowData.CfgID == cfgId then
            item:SelectItem(true)
            self.SelectItemList:Add(item)
            taken = taken + 1
        else
            item:SelectItem(false)
        end
    end

    -- nếu không đủ sau khi quét (edge case)
    if #self.SelectItemList < needCount then
        self:OnSynthMsg(type)
        return
    end


    -- --  quan trọng nhất
    self:OnUpdateMaterial()

    -- gọi lại hàm cũ để gửi request (giữ nguyên hệ thống cũ)
    self:OnSynthMsg(type)
end


-- Tự động cập nhật số lượng result khi user chỉ bỏ ít item

function UIItemSynthForm:TryFixResultNumByBagCount()
    if #self.SelectItemList <= 0 then
        return
    end

    -- đếm số lượng bind / unbind đang được put
    local bindInPut = 0
    local unBindInPut = 0
    local cfgId = 0

    for i = 1, #self.SelectItemList do
        local data = self.SelectItemList[i].ShowData
        if data then
            cfgId = data.CfgID
            if data.IsBind then
                bindInPut = bindInPut + (data.Count or 1)
            else
                unBindInPut = unBindInPut + (data.Count or 1)
            end
        end
    end

    if cfgId == 0 then
        return
    end

    -- lấy config cần bao nhiêu viên để synth
    -- local needCount = 5
    -- local canList = GameCenter.ItemContianerSystem:GetCanSynthPieceList()



    -- for i = 0, canList.Count - 1 do
    --     if canList[i].CfgID == cfgId then
    --         local cfgItem = canList[i].ItemInfo
    --         if cfgItem then
    --             local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")

    --             if #strArr == 2 then
    --                 needCount = tonumber(strArr[2]) or needCount
    --             end
    --         end
    --         break
    --     end
    -- end


    local needCount = 5
    local cfgItem = DataConfig.DataItem[cfgId]
    if cfgItem ~= nil and cfgItem.HechenTarget then
        local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
        if #strArr == 2 then
            needCount = tonumber(strArr[2]) or needCount
        end
    end


    -- đếm riêng bind / unbind trong túi
    local bindInBag = 0
    local unBindInBag = 0

    for i = 1, #self.BagItemList do
        local item = self.BagItemList[i]
        if item and item.ShowData and item.ShowData.CfgID == cfgId then
            if item.ShowData.IsBind then
                bindInBag = bindInBag + (item.ShowData.Count or 1)
            else
                unBindInBag = unBindInBag + (item.ShowData.Count or 1)
            end
        end
    end

    -- nếu cả hai loại đều không đủ thì thôi khỏi set
    if bindInBag < needCount and unBindInBag < needCount then
        return
    end

    -- update UI số kết quả (không phá logic cũ)
    if unBindInPut > 0 and unBindInBag >= needCount then
        UIUtils.SetTextByNumber(self.TextResult1, 1)
    else
        UIUtils.SetTextByNumber(self.TextResult1, 0)
    end

    if bindInPut > 0 and bindInBag >= needCount then
        UIUtils.SetTextByNumber(self.TextResult2, 1)
    else
        UIUtils.SetTextByNumber(self.TextResult2, 0)
    end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Synthesize one
function UIItemSynthForm:OnClickSynthOneBtn()
    -- self:OnSynthMsg(0)
    self:OnSynthMsgCustom(0) -- hàm mới nè
end

-- Synthesize all
function UIItemSynthForm:OnClickSynthAllBtn()
    -- self:OnSynthMsg(1)
    self:OnSynthMsgAutoAll(1)
end

-- One-key synthesis
function UIItemSynthForm:OnClickSynthAutoBtn()
    local _dic = Dictionary:New()
    local _list = GameCenter.ItemContianerSystem:GetCanSynthPieceList()
    for i = 0, _list.Count - 1 do
        if _dic:ContainsKey(_list[i].CfgID) then
            local curCount = _dic[_list[i].CfgID]["Key"] + _list[i].Count
            local keyValue = {Key = curCount, Value = _dic[_list[i].CfgID]["Value"]}
            _dic[_list[i].CfgID] = keyValue
        else
            local targetNum = 0
            local cfgItem = _list[i].ItemInfo
            if cfgItem ~= nil then
                local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
                if #strArr == 2 then
                    targetNum = tonumber(strArr[2])
                end
            end
            if targetNum > 0 then
                local keyValue = {Key = _list[i].Count, Value = targetNum}
                _dic:Add(_list[i].CfgID, keyValue)
            end
        end
    end
    -- Iterate over and remove insufficient items
    local _realDic = Dictionary:New()
    for k, v in pairs(_dic) do
        if v["Key"] >= v["Value"] then
            _realDic:Add(k, v)
        end
    end

    if _realDic:Count() > 0 then
        for k, _ in pairs(_realDic) do
            self.SelectItemList:Clear()
            for i = 1, #self.BagItemList do
                local item = self.BagItemList[i]
                if item.ShowData ~= nil and item.ShowData.CfgID == k then
                    item:SelectItem(true)
                    self.SelectItemList:Add(item)
                else
                    item:SelectItem(false)
                end
            end
            self:OnSynthMsg(1)
        end
    else
        Utils.ShowPromptByEnum("C_UI_ITEMSYNTH_NOMATERAIL_TIPS")
    end
end

-- Increase currency
function UIItemSynthForm:OnClickAddCoinBtn()
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CoinType)
end

-- Click on the grid to display TIPS, it is possible to select, it is possible to unselect
function UIItemSynthForm:OnSingleClickItem(obj)
    local item = obj
    if item ~= nil and item.ShowData ~= nil then
        local isHabe = false
        for i = 1, #self.SelectItemList do
            if self.SelectItemList[i].ShowData.DBID == item.ShowData.DBID then
                isHabe = true
            end
        end
        if  not isHabe then
            GameCenter.ItemTipsMgr:ShowTips(item.ShowData, item.Go, ItemTipsLocation.Synth)
        else
            GameCenter.ItemTipsMgr:ShowTips(item.ShowData, item.Go, ItemTipsLocation.SynthPutOut)
        end
    end
end

-- Double-click the grid and select it directly
function UIItemSynthForm:OnDoubleClickItem(obj)
    local item = obj
    if item ~= nil and item.ShowData ~= nil and not item.IsSelect then
        item:SelectItem(true)
        if #self.SelectItemList > 0 then
            if item.ShowData.CfgID ~= self.SelectItemList[1].ShowData.CfgID then
                for i = 1, #self.SelectItemList do
                    self.SelectItemList[i]:SelectItem(false)
                end
                self.SelectItemList:Clear()
            end
        end
        self.SelectItemList:Add(item)
    elseif item ~= nil and item.ShowData ~= nil and item.IsSelect then
        for i = 1, #self.SelectItemList do
            if self.SelectItemList[i].ShowData.DBID == item.ShowData.DBID then
                self.SelectItemList[i]:SelectItem(false)
                self.SelectItemList:RemoveAt(i)
                break
            end
        end
    end
    self:OnUpdateMaterial()
end

-- Materials and items click
function UIItemSynthForm:OnClickMaterail(obj)
    if obj.ShowItemData ~= nil then
        local _count = #self.SelectItemList
        for i = _count, 1, -1 do
            if self.SelectItemList[i].ShowData.IsBind == obj.ShowItemData.IsBind then
                self.SelectItemList[i]:SelectItem(false)
                self.SelectItemList:RemoveAt(i)
            end
        end
        self:OnUpdateMaterial()
    end
end
--------------------------------------endregion

-- --------------------------------------------------------------------------------------------------------------------------------
-- Find interface controls
function UIItemSynthForm:FindAllComponents()
    local _myTrans = self.Trans
    self.SynthOneBtn = UIUtils.FindBtn(_myTrans, "Bottom/OneButton")
    self.SynthAutoBtn = UIUtils.FindBtn(_myTrans, "Bottom/QuickButton")
    self.SynthAllBtn = UIUtils.FindBtn(_myTrans, "Bottom/AllButton")
    self.AddCoinBtn = UIUtils.FindBtn(_myTrans, "Left/HaveLabel/Add")
    self.BackTexture = UIUtils.FindTex(_myTrans, "Texture")
    self.TipsLabel = UIUtils.FindLabel(_myTrans, "Left/TipsLabel")
    self.SingleCostLabel = UIUtils.FindLabel(_myTrans, "Left/SingleCostLabel")
    self.AllCostLabel = UIUtils.FindLabel(_myTrans, "Left/AllCostLabel")
    self.HaveLabel = UIUtils.FindLabel(_myTrans, "Left/HaveLabel")
    local _item = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Left/MetriTable/MetriItem1"))
    self.MaterialItemList:Add(_item)
    _item = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Left/MetriTable/MetriItem2"))
    self.MaterialItemList:Add(_item)
    _item = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Left/ResultTable/ResultItem1"))
    self.ResultItemList:Add(_item)

    self.TextResult1 = UIUtils.FindLabel(_myTrans, "Left/ResultTable/ResultItem1/Num")
    self.TextResult2 = UIUtils.FindLabel(_myTrans, "Left/ResultTable/ResultItem2/Num")

    _item = UILuaItem:New(UIUtils.FindTrans(_myTrans, "Left/ResultTable/ResultItem2"))
    self.ResultItemList:Add(_item)

    self.MaterialTable = UIUtils.FindTable(_myTrans, "Left/MetriTable")
    self.ResultTable = UIUtils.FindTable(_myTrans, "Left/ResultTable")

    local _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Left/SingleCostLabel/Icon"))
    _icon:UpdateIcon(LuaItemBase.GetItemIcon(self.CoinType))
    self.IconList:Add(_icon)
    _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Left/AllCostLabel/Icon"))
    _icon:UpdateIcon(LuaItemBase.GetItemIcon(self.CoinType))
    self.IconList:Add(_icon)
    _icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Left/HaveLabel/Icon"))
    _icon:UpdateIcon(LuaItemBase.GetItemIcon(self.CoinType))
    self.IconList:Add(_icon)

    self.Grid = UIUtils.FindGrid(_myTrans, "BagContainer/Grid")
    self.GridTrans = UIUtils.FindTrans(_myTrans, "BagContainer/Grid")
    self.ScrollView = UIUtils.FindScrollView(_myTrans, "BagContainer")
    self.BagItem = UIUtils.FindGo(_myTrans, "BagContainer/Grid/UIBagItem")
    self.BagTrans = UIUtils.FindTrans(_myTrans, "BagContainer")
    self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "UIVfxSkinCompoent"))

end

-- Register button click event
function UIItemSynthForm:RegUICallback()
    UIUtils.AddBtnEvent(self.SynthOneBtn, self.OnClickSynthOneBtn, self)
    UIUtils.AddBtnEvent(self.SynthAllBtn, self.OnClickSynthAllBtn, self)
    UIUtils.AddBtnEvent(self.SynthAutoBtn, self.OnClickSynthAutoBtn, self)
    UIUtils.AddBtnEvent(self.AddCoinBtn, self.OnClickAddCoinBtn, self)
end

-- Fill a backpack lattice
function UIItemSynthForm:OnFillCell(trans, item)
    trans.IsOpened = true
    trans:UpdateItem(item)
    if item ~= nil then
        trans:SelectItem(false)
        if self.ItemData ~=  nil then
            if self.ItemData.DBID == item.DBID and self.SelectItemList:Count() == 0 then
                self.SelectItemList:Add(trans)
            end
        end
    else
        trans:SelectItem(false)
    end

    if trans.ShowData ~= nil then
        for i = 1, #self.SelectItemList do
            if self.SelectItemList[i].ShowData.DBID == trans.ShowData.DBID then
                trans:SelectItem(true)
            end
        end
    end
end

-- Initialize the interface display
function UIItemSynthForm:OnInitForm(isInitItem)
    if isInitItem then
        self.MaterialItemList[1]:InItWithCfgid(0, 0)
        self.MaterialItemList[2]:InItWithCfgid(0, 0)
        self.ResultItemList[1]:InItWithCfgid(0, 0)
        self.ResultItemList[2]:InItWithCfgid(0, 0)
    end
    self.MaterialItemList[1].SingleClick = Utils.Handler(self.OnClickMaterail, self)
    self.MaterialItemList[2].SingleClick = Utils.Handler(self.OnClickMaterail, self)
    self.MaterialItemList[1].IsShowTips = false
    self.MaterialItemList[2].IsShowTips = false
    self.MaterialItemList[2].RootGO:SetActive(false)
    self.ResultItemList[2].RootGO:SetActive(false)
    UIUtils.ClearText(self.TipsLabel)
    UIUtils.SetTextByString(self.SingleCostLabel, "---")
    UIUtils.SetTextByString(self.AllCostLabel, "---")
    UIUtils.SetTextByNumber(self.HaveLabel, GameCenter.ItemContianerSystem:GetEconomyWithType(self.CoinType))
end

-- Synthetic message processing
function UIItemSynthForm:OnSynthMsg(type)
    if #self.SelectItemList > 0 then
        local _req = {}
        local _temp = {}
        local _temp1 = {}
        for i = 1, #self.SelectItemList do
            if self.SelectItemList[i].ShowData.IsBind then
                table.insert(_temp, self.SelectItemList[i].ShowData.DBID)
            else
                table.insert(_temp1, self.SelectItemList[i].ShowData.DBID)
            end
        end
        if #_temp > 0 or #_temp1 > 0 then
            _req.bindId = _temp

            _req.nonBindId = _temp1
            _req.type = type
            GameCenter.Network.Send("MSG_backpack.ReqCompound", _req)
        end
    else
        Utils.ShowPromptByEnum("C_UI_ITEMSYNTH_NOMATERAIL1_TIPS")
    end
end

-- Refresh the backpack according to the selected item, mainly refresh the selected status
function UIItemSynthForm:OnUpdateBagItem(item)
    if item == nil then
        return
    end
    for i = 1, #self.BagItemList do
        local trans =  self.BagItemList[i]
        if trans ~= nil and trans.ShowData ~= nil then
            if item.DBID == trans.ShowData.DBID then
                trans:SelectItem(true)
                return trans
            end
        end
    end
end

-- Update selected materials and results
function UIItemSynthForm:OnUpdateMaterial()
    self:OnInitForm(#self.SelectItemList == 0)
    if #self.SelectItemList > 0 then
        local targetNum = 0
        local cfgID = 0
        local coinType = self.CoinType
        local coinNum = 0
        local cfgItem = DataConfig.DataItem[self.SelectItemList[1].ShowData.CfgID]
        if cfgItem ~= nil then
            local strArr = Utils.SplitStr(cfgItem.HechenTarget, "_")
            if #strArr == 2 then
                targetNum = tonumber(strArr[2])
                cfgID = tonumber(strArr[1])
            end
            strArr = Utils.SplitStr(cfgItem.HechenMoney, "_")
            if #strArr == 2 then
                coinType = tonumber(strArr[1])
                coinNum = tonumber(strArr[2])
            end
        end

        UIUtils.SetTextByEnum(self.TipsLabel, "C_UI_ITEMSYNTH_JIHEYI", targetNum)
        UIUtils.SetTextByNumber(self.SingleCostLabel, coinNum)
        UIUtils.SetTextByNumber(self.HaveLabel, GameCenter.ItemContianerSystem:GetEconomyWithType(coinType))
        if coinType ~= ItemTypeCode.BindMoney then
            for i = 1, #self.IconList do
                self.IconList[i]:UpdateIcon(LuaItemBase.GetItemIcon(coinType))
            end
        end

        local isHaveTwo = false
        if self.SelectItemList:Count() > 1 then
            for i = 2, #self.SelectItemList do
                if self.SelectItemList[i].ShowData.IsBind ~= self.SelectItemList[1].ShowData.IsBind then
                    isHaveTwo = true
                    break
                end
            end
        end

        if isHaveTwo then
            local bindNum = 0
            local nonBindNum = 0
            for i = 1, #self.SelectItemList do
                if not self.SelectItemList[i].ShowData.IsBind then
                    nonBindNum = nonBindNum + self.SelectItemList[i].ShowData.Count
                    self.MaterialItemList[1]:InitWithItemData(self.SelectItemList[i].ShowData, nonBindNum, false);
                    self.MaterialItemList[1]:OnSetNum(tostring(nonBindNum));
                else
                    bindNum = bindNum + self.SelectItemList[i].ShowData.Count
                    self.MaterialItemList[2]:InitWithItemData(self.SelectItemList[i].ShowData, bindNum, true)
                    self.MaterialItemList[2]:OnSetNum(tostring(bindNum))
                end
            end
            self.MaterialItemList[2].RootGO:SetActive(true)

            local _unBindResultNum = math.floor(nonBindNum / targetNum)
            local _bindResultNum = math.floor((bindNum + nonBindNum - _unBindResultNum * targetNum) / targetNum)
            self.ResultItemList[1]:InItWithCfgid(cfgID, _unBindResultNum, false)
            self.ResultItemList[1]:OnSetNum(tostring(_unBindResultNum))
            self.ResultItemList[2]:InItWithCfgid(cfgID, _bindResultNum, true)
            self.ResultItemList[2]:OnSetNum(tostring(_bindResultNum))
            self.ResultItemList[2].RootGO:SetActive(true);

            local allNum = math.floor(nonBindNum / targetNum) + math.floor(bindNum / targetNum)
            UIUtils.SetTextByNumber(self.AllCostLabel, coinNum * allNum)
            if allNum <= 0 then
                UIUtils.SetTextByNumber(self.SingleCostLabel, 0)
            end
        else
            local num = 0;
            self.MaterialItemList[2].RootGO:SetActive(false)
            self.ResultItemList[2].RootGO:SetActive(false)
            for i = 1, #self.SelectItemList do
                num = num + self.SelectItemList[i].ShowData.Count
                self.MaterialItemList[1]:InitWithItemData(self.SelectItemList[i].ShowData, num, self.SelectItemList[i].ShowData.IsBind);
                self.MaterialItemList[1]:OnSetNum(tostring(num))
            end

            self.ResultItemList[1]:InItWithCfgid(cfgID, math.floor(num / targetNum), self.SelectItemList[1].ShowData.IsBind);
            self.ResultItemList[1]:OnSetNum(tostring(math.floor(num / targetNum)))
            local allNum = math.floor(num / targetNum)
            UIUtils.SetTextByNumber(self.AllCostLabel, coinNum * allNum)
            if allNum <= 0 then
                UIUtils.SetTextByNumber(self.SingleCostLabel, 0)
            end
        end
    end
    self.MaterialTable.repositionNow = true
    self.ResultTable.repositionNow = true
end

-- After the backpack is updated, refresh the selected data
function UIItemSynthForm:OnUpdateSelectInfo()
    self.SelectItemList:Clear()
    for i = 1, #self.BagItemList do
        local item = self.BagItemList[i]
        if item.ShowData ~= nil and item.IsSelect then
            self.SelectItemList:Add(item)
        end
    end
    self:OnUpdateMaterial()
end
--------------------------------------endregion
return UIItemSynthForm
