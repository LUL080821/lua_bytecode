------------------------------------------------
-- Author:
-- Date: 2021-02-22
-- File: GetNewItemSystem.lua
-- Module: GetNewItemSystem
-- Description: New item acquisition display system
------------------------------------------------

local GetNewItemSystem = {
    -- Item information to be displayed on the interface
    FormItemList = List:New(),
    FormItemDelayTime = -1,
    -- Display the cache of item information on the interface, and wait for the display to close and continue to display when it cannot be displayed this time.
    FormItemCache = List:New(),
    -- Equipment display queue
    NewEquipQueue = List:New(),
    ForceShowEquipTimer = 0,
    -- Offline experience props
    AddOnHookTimeItemID = {1031, 1004},
    AddOnHookTimeItemTime = {7200, 18000},
    -- Maximum offline experience time
    MaxOnHookTime = 0,
    -- Items displayed on the boss treasure chest
    BossBoxItemList = List:New(),
    -- Countdown to equipment display
    NewEquipTimer = 0,
    -- Ignored reason code
    IngoreResons = {},
    -- Pause pop-up prompt
    PauseGetNewItemTips = false,

    -- The red outfit currently displayed
    NeedShowRedEquip = nil,
    -- The ID you need to prompt for the first time you get the red outfit
    NeedTipsEquipIDlist = nil,
    -- The equipment ID that has been displayed
    ShowTipsEquipIDlist = nil,

    ItemTipsUIId = nil,
    EquipTipsUIId = nil,
    FirstEquipTipsUIId = nil,
}

function GetNewItemSystem:Initialize()
    local _gCfg = DataConfig.DataGlobal[GlobalName.OnHookMaxNum]
    if _gCfg ~= nil then
        self.MaxOnHookTime = tonumber(_gCfg.Params)
        self.MaxOnHookTime = self.MaxOnHookTime * 60
    end
    self.NeedTipsEquipIDlist = List:New()
    _gCfg = DataConfig.DataGlobal[GlobalName.Special_Red_Equip_title]
    if _gCfg ~= nil then
        local _ids = Utils.SplitNumber(_gCfg.Params, '_')
        for i = 1, #_ids do
            self.NeedTipsEquipIDlist:Add(_ids[i])
        end
    end
    self.PauseGetNewItemTips = false
    self.ItemTipsUIId = GameCenter.FormStateSystem:EventIDToFormID(UnityUtils.GetObjct2Int(UIEventDefine.UIITEMGET_TIPS_OPEN))
    self.EquipTipsUIId = GameCenter.FormStateSystem:EventIDToFormID(UnityUtils.GetObjct2Int(UIEventDefine.UIEQUIPGET_TIPS_OPEN))
    self.FirstEquipTipsUIId = GameCenter.FormStateSystem:EventIDToFormID(UnityUtils.GetObjct2Int(UIEventDefine.UIFirstGetEquipForm_OPEN))
end

function GetNewItemSystem:UnInitialize()
    self.FormItemList:Clear()
    self.FormItemCache:Clear()
    self.BossBoxItemList:Clear()
end

-- Add a reason code to ignore
function GetNewItemSystem:AddIngoreReson(reason)
    self.IngoreResons[reason] = true
end

-- Delete the ignored reason code
function GetNewItemSystem:RemoveIngoreReson(reason)
    self.IngoreResons[reason] = nil
end

-- Add display items
function GetNewItemSystem:AddShowItem(reason, itemInst, itemID, addCount)
    if self.IngoreResons[reason] ~= nil then
        return
    end
    local _reasonCfg = DataConfig.DataItemChangeReason[reason]
    if _reasonCfg == nil then

        if(reason == 2431) then
            _reasonCfg = { DropShow = 1, ShowPos = 0 } -- fallback cho remove gem vì chưa có cấu hình Lua data

        else
            return
        end

        -- return
    end

    local _itemCfg = DataConfig.DataItem[itemID]
    local _equipCfg = DataConfig.DataEquip[itemID]
    -- Determine whether the flying effect is displayed
    if _reasonCfg.DropShow ~= 0 and itemInst ~= nil and addCount > 0 then
        if (_itemCfg ~= nil and _itemCfg.FlyToBagType ~= 0) or (_equipCfg ~= nil and _equipCfg.FlyToBagType ~= 0) then
            local _flyInfo = {}
            _flyInfo.Reason = reason
            _flyInfo.ItemCfg = _itemCfg
            _flyInfo.EquipCfg = _equipCfg
            _flyInfo.Item = itemInst
            _flyInfo.ItemCount = addCount
            if reason == ItemChangeReasonName.DropByKillMonsterGet then
                -- If it is a monster kill, do a delay
                _flyInfo.DelayTime = 4
            else
                _flyInfo.DelayTime = 0
            end
            GameCenter.PushFixEvent(UIEventDefine.UIItemFlyToBagForm_OPEN, _flyInfo);
        end
    end

    local _itemInfo = {}
    _itemInfo.Reason = reason;
    _itemInfo.ReasonCfg = _reasonCfg;
    _itemInfo.Item = itemInst;
    _itemInfo.ItemCfg = _itemCfg;
    _itemInfo.EquipCfg = _equipCfg;
    _itemInfo.ItemCount = addCount;
    _itemInfo.ItemCfgID = itemID;
    self:ShowItemInfo(_itemInfo)
end

function GetNewItemSystem:ShowItemInfo(itemInfo)
    if itemInfo.ReasonCfg.ShowPos == ItemChangeShowPos.RightButtom then
        -- Lower right corner
        if itemInfo.Item ~= nil then
            GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, itemInfo.Item)
        else
            if itemInfo.EquipCfg ~= nil then
                GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, itemInfo.EquipCfg.Name)
            end
            if itemInfo.ItemCfg ~= nil then
                if itemInfo.ItemCount < 0 then
                    local _showText = string.format("%s - %d", itemInfo.ItemCfg.Name, -itemInfo.ItemCount)
                    GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, _showText)
                else
                    local _countText = CommonUtils.CovertToBigUnit(itemInfo.ItemCount, 0);
                    local _showNormal = true
                    if itemInfo.ItemCfg.Id == ItemTypeCode.Exp and (
                        itemInfo.Reason == ItemChangeReasonName.ExpCopyGet or
                        itemInfo.Reason == ItemChangeReasonName.LeaderPreachAddExpGet or
                        itemInfo.Reason == ItemChangeReasonName.WorldBonfireExpGet or
                        itemInfo.Reason == ItemChangeReasonName.HookMapGet 
                    ) then
                        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
                        if _lp ~= nil and _lp.PropMoudle.KillMonsterExpPercent > 0 then
                            _showNormal = false
                            local _showText = UIUtils.CSFormat("{0} {1}(+{2:F0}%)", itemInfo.ItemCfg.Name, _countText, _lp.PropMoudle.KillMonsterExpPercent / 100);
                            GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, _showText)
                        end
                    end
                    if _showNormal then
                        local _showText = string.format("%s %s", itemInfo.ItemCfg.Name, _countText)
                        GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, _showText)
                    end
                end
            end
        end
    elseif itemInfo.ReasonCfg.ShowPos == ItemChangeShowPos.Top then
        -- top
        if itemInfo.Item ~= nil then
            GameCenter.MsgPromptSystem:ShowPrompt(itemInfo.Item)
        else
            if itemInfo.EquipCfg ~= nil then
                GameCenter.MsgPromptSystem:ShowPrompt(itemInfo.EquipCfg.Name)
            end
            if itemInfo.ItemCfg ~= nil then
                if itemInfo.ItemCount > 0 then
                    local _showText = string.format("%s + %s", itemInfo.ItemCfg.Name, itemInfo.ItemCount)
                    GameCenter.MsgPromptSystem:ShowPrompt(_showText)
                elseif itemInfo.ItemCount < 0 then
                    local _showText = string.format("%s - &d", itemInfo.ItemCfg.Name, -itemInfo.ItemCount)
                    GameCenter.MsgPromptSystem:ShowPrompt(_showText)
                end
            end
        end
    elseif itemInfo.ReasonCfg.ShowPos == ItemChangeShowPos.CenterPop then
        -- Pop up in the middle
        if (#self.FormItemList > 0 and self.FormItemList[1].Reason ~= itemInfo.Reason) or #self.FormItemList >= 16 then
            -- There is currently displaying and not the same reason, put into the cache
            if not self.FormItemCache:Contains(itemInfo) then
                self.FormItemCache:Add(itemInfo)
            end
        else
            local _dieJia = false
            if itemInfo.Item == nil and itemInfo.ItemCfg ~= nil then
                for i = 1, #self.FormItemList do
                    -- Determine whether it can be displayed on top
                    local _tmp = self.FormItemList[i]
                    if _tmp.Item == nil and _tmp.ItemCfg ~= nil and _tmp.ItemCfg.Id == itemInfo.ItemCfg.Id then
                        _dieJia = true
                        _tmp.ItemCount = _tmp.ItemCount + itemInfo.ItemCount
                        break
                    end
                end
            end
            if not _dieJia then
                -- Need to display the data of the acquisition interface
                self.FormItemList:Add(itemInfo);
            end

            if itemInfo.Reason == ItemChangeReasonName.FestvialWishGet then
                GameCenter.PushFixEvent(UIEventDefine.UITHJRXYGetNewItemForm_OPEN)
            else
                GameCenter.PushFixEvent(UIEventDefine.UIGetNewItemForm_OPEN)
            end
        end
    elseif itemInfo.ReasonCfg.ShowPos == ItemChangeShowPos.BossBox then
        self.BossBoxItemList:Add(itemInfo)
        GameCenter.PushFixEvent(UIEventDefine.UIBossBoxResultForm_OPEN);
    end
end

function GetNewItemSystem:AddShowTips(item, reason, addCount)
    if addCount <= 0 then
        return
    end
    -- Determine whether it is a special item and display the treasure chest.
    self:CanShowSpecialBox(item, reason)

    -- Determine whether you need to turn on the red installation prompt
    if reason == ItemChangeReasonName.ProDrop or reason == ItemChangeReasonName.GM then
        local _cfgId = item.CfgID
        self:LoadShowTipsEquipIDlist()
        if self.ShowTipsEquipIDlist ~= nil then
            if self.NeedTipsEquipIDlist:Contains(_cfgId) and item.IsNew and not self.ShowTipsEquipIDlist:Contains(_cfgId) then
                self.NeedShowRedEquip = item
            end
        end
    end
  
    -- Use or equipment display
    local _canShowTips, isItem = self:CanShowNewTips(item)
    if _canShowTips then
        if isItem then
            local _cfgId = item.CfgID
            -- Determine whether there are repeated additions
            for i = 1, #self.NewEquipQueue do
                if self.NewEquipQueue[i].CfgID == _cfgId then
                    return
                end
            end
        end
        self.NewEquipQueue:Add(item)
    end
end

-- Tips to determine whether the equipment can be used for new equipment
function GetNewItemSystem:CanShowNewTips(item)
    if item == nil then
        return false
    end
    if item.Type == ItemType.HolyEquip then
        return false
        -- --Judge whether the item is still on the backpack
        -- item = GameCenter.HolyEquipSystem:GetEquipByDBID(item.DBID)
        -- if item == nil then
        --     return false
        -- end
        -- -- Can be equipped, and better than the one on the body
        -- if item:CheckCanEquip() and item:CheckBetterThanDress() then
        --     return true
        -- end
    elseif item.Type == ItemType.Equip then
        -- Determine whether the item is still on the backpack
        item = GameCenter.ItemContianerSystem:GetItemByUIDFormBag(item.DBID)
        if item == nil then
            return false
        end
        -- Can be equipped and better than
        if item:CheckCanEquip() and item:CheckBetterThanDress() then
            return true
        end
    elseif item.Type == ItemType.ImmortalEquip then
        -- Determine whether the item is still on the backpack
        item = GameCenter.ItemContianerSystem:GetItemByUIDFormImmortalBag(item.DBID)
        if item == nil then
            return false
        end

        -- Can be equipped and better than
        if item:CheckCanEquip() and item:CheckBetterThanDress() then
            return true
        end
    elseif item.Type == ItemType.UnrealEquip then
        return false
    else
        item = GameCenter.ItemContianerSystem:GetItemByUIDFormBag(item.DBID)
        if item == nil then
            return false
        end
        local _cfgId = item.CfgID
        local _count = item.Count
        -- Judgment of offline experience props
        for i = 1, #self.AddOnHookTimeItemID do
            if self.AddOnHookTimeItemID[i] == _cfgId and
                GameCenter.OfflineOnHookSystem.RemainOnHookTime + self.AddOnHookTimeItemTime[i] >= self.MaxOnHookTime then
                -- Offline experience reaches the upper limit, offline experience props are not displayed
                return false
            end
        end
        -- Determine whether the item can be used
        local _itemCfg = DataConfig.DataItem[_cfgId]
        if _itemCfg ~= nil and _itemCfg.IfUseInfo >= 1 and _count >= _itemCfg.IfUseInfo and not item:isTimeOut() and item:CheckLevel(GameCenter.GameSceneSystem:GetLocalPlayerLevel()) then
            return true, true
        end
    end
    return false
end

-- Determine whether it is a special item and display the treasure chest.
function GetNewItemSystem:CanShowSpecialBox(item, reason)
    if item == nil then
        return
    end
    local _cfg = DataConfig.DataFBOpenShow[item.CfgID]
    if _cfg == nil then
        return
    end
    local _reaSeanList = Utils.SplitNumber(_cfg.ChangeReason, '_')
    if _reaSeanList:Contains(reason) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIBaoXiangModelForm_OPEN, _cfg.Id)
    end
end

-- Show next item
function GetNewItemSystem:ShowNextEquip()
    while(#self.NewEquipQueue > 0) do
        local _item = self.NewEquipQueue[1]
        self.NewEquipQueue:RemoveAt(1)
        local _canShowTips, isItem = self:CanShowNewTips(_item)
        if _canShowTips then
            if isItem then
                GameCenter.PushFixEvent(UIEventDefine.UIITEMGET_TIPS_OPEN, _item);
            else
                GameCenter.PushFixEvent(UIEventDefine.UIEQUIPGET_TIPS_OPEN, _item);
            end
            self.ForceShowEquipTimer = 10
            break
        end
    end
end

-- Clean the item information displayed on the interface
function GetNewItemSystem:OnFormClose()
    self.FormItemList:Clear()
    self.FormItemDelayTime = 1
end

-- Clean up the boss treasure chest display
function GetNewItemSystem:ClearBossBoxResult()
    self.BossBoxItemList:Clear()
end

-- Load the red id that has been displayed
function GetNewItemSystem:LoadShowTipsEquipIDlist()
    if self.ShowTipsEquipIDlist ~= nil then
        return
    end
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    if _lpId <= 0 then
        return
    end
    self.ShowTipsEquipIDlist = List:New()
    local _setData = PlayerPrefs.GetString("FirstShowRedEquipIDlist" .. _lpId)
    if _setData ~= nil and string.len(_setData) > 0 then
        local _ids = Utils.SplitNumber(_setData, '_')
        for i = 1, #_ids do
            self.ShowTipsEquipIDlist:Add(_ids[i])
        end
    end
end
-- Save the red id that has been displayed
function GetNewItemSystem:SaveShowTipsEquipIDlist()
    if self.ShowTipsEquipIDlist == nil then
        return
    end
    local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    if _lpId <= 0 then
        return
    end
    local _saveText = ""
    local _count = #self.ShowTipsEquipIDlist
    for i = 1, _count do
        _saveText = _saveText .. self.ShowTipsEquipIDlist[i]
        if i < _count then
            _saveText = _saveText .. '_'
        end
    end
    PlayerPrefs.SetString("FirstShowRedEquipIDlist" .. _lpId, _saveText)
    PlayerPrefs.Save()
end

-- renew
function GetNewItemSystem:Update(dt)
    -- Determine whether the item has been suspended from pop-up
    if self.PauseGetNewItemTips then
        return
    end

    -- Update items displayed on the interface
    if self.FormItemDelayTime > 0 then
        self.FormItemDelayTime = self.FormItemDelayTime - dt
        if self.FormItemDelayTime <= 0 then
            local _count = #self.FormItemCache
            for i = 1, _count do
                if i > 16 then
                    break
                end
                local _item = self.FormItemCache[1]
                self.FormItemCache:RemoveAt(1)
                self:ShowItemInfo(_item)
            end
        end
    end
 
    -- Updated red outfit
    if self.NeedShowRedEquip then
        GameCenter.PushFixEvent(UIEventDefine.UIFirstGetEquipForm_OPEN, self.NeedShowRedEquip)
        self.ShowTipsEquipIDlist:Add(self.NeedShowRedEquip.CfgID)
        self:SaveShowTipsEquipIDlist()
        self.NeedShowRedEquip = nil
    end

    if not GameCenter.FormStateSystem:FormIsOpen(self.ItemTipsUIId) and not GameCenter.FormStateSystem:FormIsOpen(self.EquipTipsUIId) and not GameCenter.FormStateSystem:FormIsOpen(self.FirstEquipTipsUIId) then
        self.NewEquipTimer = self.NewEquipTimer - dt
        if self.NewEquipTimer <= 0 then
            self:ShowNextEquip()
        end
    else
        self.NewEquipTimer = 0.5
    end

    if #self.NewEquipQueue > 0 and self.ForceShowEquipTimer > 0 then
        self.ForceShowEquipTimer = self.ForceShowEquipTimer - dt
        if self.ForceShowEquipTimer <= 0 then
            self:ShowNextEquip()
        end
    end
end

return GetNewItemSystem