------------------------------------------------
-- author:
-- Date: 2019-07-18
-- File: TreasureHuntSystem.lua
-- Module: TreasureHuntSystem
-- Description: Treasure Hunt System
------------------------------------------------

local L_TreasureHuntData = require "Logic.TreasureHunt.TreasureHuntData"
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;

local TreasureHuntSystem =
{
    -- Default is treasure hunting pool
    TreasureType = TreasureEnum.Hunt,
    -- Item obtained by treasure hunt
    RewardItemList = nil,
    -- Result of treasure hunt reward (type,List<Item>)
    RewardItemDict = nil,
    -- The draw record of the entire server [treasureType, recordList]
    AllRecordDict = nil,
    SelfRecordDict = nil,
    -- Reward data for treasure hunting for opportunities
    TreasureRewardDict = nil,

    -- Save treasure hunt data
    TreasureHuntDataDict = nil,
    -- Immortal Soul Points
    XianpoPoint = 0,
    -- Immortal Soul Crystal
    XianpoHunJin = 0,
    -- The prop ID of the lottery
    ItemIdList = nil,

    -- Worry-free treasure house
    ReceiveRemainTime = 0,
    FuncRemainTime = 0,
    IsUpdateTime = false,
    IsCanGetItem = false,

    IsJumpAskBuy = {},

    AgainCallBack = nil,
    -- Treasure Hunt Free Time Stamp
    FreeTimeTickTable = nil,
    -- Treasure Hunt Timer
    FreeTimerTable = nil,
}

-- Lottery record
local L_RecordTypeEnum =
{
    -- Single player
    SelfRec = 0,
    -- 1 means all server players
    AllPlayerRec = 1,
}

function TreasureHuntSystem:Initialize()
    self.RewardItemList = List:New()
    self.RewardItemDict = Dictionary:New()
    self.TreasureHuntDataDict = Dictionary:New()
    self.AllRecordDict = Dictionary:New()
    self.SelfRecordDict = Dictionary:New()
    self.ItemIdList = List:New()
    self.IsUpdateTime = false
    self.IsCanGetItem = false
    self.FreeTimeTickTable = {}
    self.FreeTimerTable = {}
    self:InitCfg()
end

function TreasureHuntSystem:UnInitialize()
    self.RewardItemList:Clear()
    self.RewardItemDict:Clear()
    self.TreasureHuntDataDict:Clear()
    self.AllRecordDict:Clear()
    self.SelfRecordDict:Clear()
    self.ItemIdList:Clear();
end

function TreasureHuntSystem:InitCfg()
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TreasureFind, 1)
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TreasureZaoHua, 1)
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TreasureHongMeng, 1)
    GameCenter.RedPointSystem:RemoveFuncCondition(FunctionStartIdCode.TreasureShangGu, 1)

    DataConfig.DataTreasurePop:Foreach(
        function(k, _cfg)
            local _type = tonumber(_cfg.RewardType)
            local _data = L_TreasureHuntData:New(_cfg)
            if not self.TreasureHuntDataDict:ContainsKey(_type) then
                self.TreasureHuntDataDict:Add(_type, _data)
            end
            -- Save the prize ID of the lottery
            local _itemId = Utils.SplitNumber(_cfg.Item, '_')[1]
            self.ItemIdList:Add(_itemId)

            -- Number of props red dots
            local _useFuncID = nil
            if k == TreasureEnum.Hunt then
                -- Treasure hunting for opportunities
                _useFuncID = FunctionStartIdCode.TreasureFind
            elseif k == TreasureEnum.ZaoHua then
                -- Treasure hunt for fortune
                _useFuncID = FunctionStartIdCode.TreasureZaoHua
            elseif k == TreasureEnum.HongMeng then
                -- Hongmeng Treasure Hunt
                _useFuncID = FunctionStartIdCode.TreasureHongMeng
            elseif k == TreasureEnum.ShangGu then
                -- Ancient treasure hunt
                _useFuncID = FunctionStartIdCode.TreasureShangGu
            end
            if _useFuncID ~= nil then
                GameCenter.RedPointSystem:AddFuncCondition(_useFuncID, 1, RedPointItemCondition(_itemId, 10))
            end
        end
    )
end

-- Return to treasure hunt results
function TreasureHuntSystem:ResTreasureResult(msg)
    if msg ~= nil then
        -- Return to a single
        if msg.info ~= nil then
            local _info = msg.info
            self:SetWarehouseInfo(_info)
            self:CheckRewardItemRedPoint(_info.type)
            -- Props list
            local _itemsList = _info.simpleItems
            if _itemsList ~= nil then
                for _, _item in pairs(_itemsList) do
                    -- DataConfig.DataItemChangeReason TreasureHuntAddItem id 210
                    local _reason = 210
                    -- Display item acquisition effect
                    local _itemBase = CS.Thousandto.Code.Logic.ItemBase.CreateItemBase(_item.itemId)
                    GameCenter.GetNewItemSystem:AddShowItem(_reason, _itemBase, _item.itemId, _item.itemNum);
                end
            end
            -- Refreshing the treasure hunt data
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
        end
    end
end

-- Return to purchase information
function TreasureHuntSystem:ResBuyResult(msg)
    if msg ~= nil then
        -- Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
        self.TreasureType = tonumber(msg.type)
        -- Refreshing the treasure hunt data
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
    end
end

-- Return one-click extraction result
function TreasureHuntSystem:ResOnekeyExtractResult(msg)
    if msg ~= nil then
        -- Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
        local _type = tonumber(msg.type)
        self.TreasureType = _type
        -- Clear cached repository data
        if self.RewardItemDict:ContainsKey(_type) then
            self.RewardItemDict[_type]:Clear()
        end
        self:CheckRewardItemRedPoint(_type)
        self:SetWuyouRedPoint()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TREASURE_WAREHOUSE)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
    end
end

-- All lottery records returned
function TreasureHuntSystem:ResUpdateRecord(msg)
    if msg ~= nil then
        -- Treasure Hunt Record
        local _recordInfo = msg.record
        if _recordInfo ~= nil then
            -- 0 means a single player 1 means a full server
            local _type = tonumber(msg.type)
            self:SetRecordData(_recordInfo, _type)
            -- Refreshing the treasure hunt data
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
        end
    end
end

-- Return all warehouse information
function TreasureHuntSystem:ResAllWarehouseInfo(msg)
    if msg ~= nil then
        -- Warehouse prop list (List<warehouseInfo>)
        local _warehouseInfoList = msg.info
        if _warehouseInfoList ~= nil then
            for _, _info in pairs(_warehouseInfoList) do
                self:SetWarehouseInfo(_info)
                self:CheckRewardItemRedPoint(_info.type)
            end
        end
        -- Full server record list (List<treasureRecordInfo>)
        local _allRecordInfoList = msg.allRecordInfo
        if _allRecordInfoList ~= nil then
            for _, _recordInfo in pairs(_allRecordInfoList) do
                self:SetRecordData(_recordInfo, L_RecordTypeEnum.AllPlayerRec)
            end
        end
        -- Record the list yourself (List<treasureRecordInfo>)
        local _selfRecordInfoList = msg.selfRecordInfo
        if _selfRecordInfoList ~= nil then
            for _, _recordInfo in pairs(_selfRecordInfoList) do
                self:SetRecordData(_recordInfo, L_RecordTypeEnum.SelfRec)
            end
        end
        -- Refreshing the treasure hunt data
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TREASURE_WAREHOUSE)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
    end
end

-- Announce rewards
-- This message is not needed for the time being. The server sends a marionette to notify all players.
function TreasureHuntSystem:ResNoticeReward(msg)
    if msg ~= nil then
        -- --Props record list
        -- local _recordInfo = msg.info
        -- if _recordInfo ~= nil then
        --     local _itemId = tonumber(_recordInfo.itemId)
        --     local _itemNum = tonumber(_recordInfo.itemNum)
        --     local _bind = false
        --     if tonumber(_recordInfo.itemNum) == 1 then
        --         _bind = true
        --     end
        --     local _playerName = tostring(_recordInfo.playername)
        -- end
        -- --Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
        -- local _type = msg.type
        -- --Refresh the treasure hunt data
        -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
    end
end

-- Set up the data parsing the repository
function TreasureHuntSystem:SetWarehouseInfo(warehouseInfo)
    if warehouseInfo ~= nil then
        local _info = warehouseInfo
        -- Props list
        local _rewardItemList = _info.simpleItems
        -- Warehouse Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
        local _type = tonumber(_info.type)
        local _itemList = self.RewardItemDict[_type]
        if _itemList == nil then
            _itemList = List:New()
            self.RewardItemDict[_type] = _itemList
        end
        if _rewardItemList ~= nil then
            -- Item stacking algorithm
            local _countCacheTable = {}
            local _count = #_rewardItemList
            for i = 1, _count do
                local _mItem = _rewardItemList[i]
                if DataConfig.DataEquip[_mItem.itemId] == nil then
                    local _cacheIndex = _countCacheTable[_mItem.itemId]
                    if _cacheIndex ~= nil then
                        local _cacheItem = _itemList[_cacheIndex]
                        _cacheItem.itemNum = _cacheItem.itemNum + _mItem.itemNum
                    else
                        local _isFind = false
                        local _cacheCount = #_itemList
                        for j = 1, _cacheCount do
                            local _cacheItem = _itemList[j]
                            if _cacheItem.itemId == _mItem.itemId then
                                _countCacheTable[_mItem.itemId] = j
                                _cacheItem.itemNum = _cacheItem.itemNum + _mItem.itemNum
                                _isFind = true
                                break
                            end
                        end
                        if not _isFind then
                            _countCacheTable[_mItem.itemId] = _cacheCount + 1
                            _itemList:Add(_mItem)
                        end
                    end
                else
                    -- Equipment cannot be stacked
                    _itemList:Add(_mItem)
                end
            end
        end
        local _treData = self.TreasureHuntDataDict[_type]
        if _treData ~= nil then 
            -- Number of free times
            _treData.FreeCount = _info.freetimes
            -- Must win the remaining consumption times
            _treData.LeftCount = _info.mustTypeleftTimes
            -- The remaining times today
            _treData.TodayCount = tonumber(_info.todayLeftTimes)
        end
    end
end

-- Lottery record
-- @pram recordInfo raffle draw information
-- @pram recType 0 means a single player 1 means a full server
function TreasureHuntSystem:SetRecordData(recordInfo, recType)
    local _recordInfo = recordInfo
    if _recordInfo ~= nil then
        -- 0 means a single player 1 means a full server
        local _recordType = tonumber(recType)
        -- Warehouse Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
        local _treasureType = tonumber(_recordInfo.type)
        local _selfRecordList = List:New()
        local _allRecordList = List:New()
        local _specialItemIdDict = nil
        -- Update the lucky value of the entire server
        local _treData = self.TreasureHuntDataDict[_treasureType]
        if _treData ~= nil then
            if _recordType ~= L_RecordTypeEnum.SelfRec then
            -- The current lucky value of the server
                if _recordInfo.serverLuckCount ~= nil then
                    _treData.CurSreverZhuFuValue = _recordInfo.serverLuckCount
                else
                    _treData.CurSreverZhuFuValue = 0
                end
            end
            _specialItemIdDict = _treData.SpecialItemIdDict
        end
        local _treaName = ""
        if _treasureType == TreasureEnum.ZaoHua then
            _treaName = DataConfig.DataMessageString.Get("TreasureZaoHua")
        elseif _treasureType == TreasureEnum.HongMeng then
            _treaName = DataConfig.DataMessageString.Get("TreasureHongMong")
        elseif _treasureType == TreasureEnum.ShangGu then
            _treaName = DataConfig.DataMessageString.Get("TreasureShangGu")
        elseif _treasureType == TreasureEnum.Hunt then
            _treaName = DataConfig.DataMessageString.Get("TreasureHunt")
        elseif _treasureType == TreasureEnum.XJXunbao then
            _treaName = DataConfig.DataMessageString.Get("XJXunbao")
        elseif _treasureType == TreasureEnum.XJMibao then
            _treaName = DataConfig.DataMessageString.Get("XJMibao")
        elseif _treasureType == TreasureEnum.Wuyou then
            _treaName = DataConfig.DataMessageString.Get("C_TREASURE_NAME10")
        end
        -- Prop record list
        local _recList = _recordInfo.info
        if _recList ~= nil then
            for _, _record in pairs(_recList) do
                local _itemId = tonumber(_record.itemId)
                -- The name of the normal prop
                local _itemName = nil
                local _itemCfg = DataConfig.DataItem[_itemId]
                if _itemCfg ~= nil then
                    _itemName = _itemCfg.Name
                else
                    local _equipCfg = DataConfig.DataEquip[_itemId]
                    if _equipCfg ~= nil then
                        _itemName = _equipCfg.Name
                    else
                        local _immCfg = DataConfig.DataImmortalSoulAttribute[_itemId]
                        if _immCfg ~= nil then
                            _itemName = _immCfg.Name
                        end
                    end
                end
                local _isBig = false
                if _specialItemIdDict ~= nil and _specialItemIdDict[_itemId] ~= nil then
                    _isBig = true
                end
                local _playerName = tostring(_record.playername)
                local _msg = nil
                -- Your own record
                if _recordType == L_RecordTypeEnum.SelfRec then
                    if _isBig then
                        _msg = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_XJ_GoodLuckGetItems"), _treaName, _itemName)
                    else
                        _msg = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_XJ_GoodLuckGetItems2"), _treaName, _itemName)
                    end
                else
                    if _isBig then
                        _msg = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_XJ_PlayerGoodLuckGetItems"), _playerName, _treaName, _itemName)
                    else
                        _msg = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_XJ_PlayerGoodLuckGetItems2"), _playerName, _treaName, _itemName)
                    end
                end
                -- Add lottery records, the server has restricted it
                if _recordType == 0 then
                    _selfRecordList:Add(_msg)
                else
                    _allRecordList:Add(_msg)
                end
            end
        end
        -- Save the entire server or your own lottery records according to the type
        if _recordType == L_RecordTypeEnum.SelfRec then
            _selfRecordList = self:ReverseList(_selfRecordList)
            if self.SelfRecordDict:ContainsKey(_treasureType) then
                self.SelfRecordDict[_treasureType] = _selfRecordList
            else
                self.SelfRecordDict:Add(_treasureType, _selfRecordList)
            end
        else
            _allRecordList = self:ReverseList(_allRecordList)
            if self.AllRecordDict:ContainsKey(_treasureType) then
                self.AllRecordDict[_treasureType] = _allRecordList
            else
                self.AllRecordDict:Add(_treasureType, _allRecordList)
            end
        end
    end
end

-- Reverse order
function TreasureHuntSystem:ReverseList(targetList)
	local tmp = {}
	for i = 1, #targetList do
		local key = #targetList
		tmp[i] = table.remove(targetList)
	end
	return tmp
end

-- The immortal soul rewards
function TreasureHuntSystem:ResRewardResultPanle(msg)
    if msg ~= nil then
        -- The fairy soul
        if msg.type == TreasureEnum.Inscription then
            self.XianpoPoint = msg.ext1
            self.XianpoHunJin = msg.ext2
            GameCenter.PushFixEvent(UIEventDefine.UIGetNewXianpoForm_OPEN, msg.simpleItems)
        -- Treasure hunting
        elseif msg.type ~= 0 then
            self.TreasureRewardDict = Dictionary:New()
            local _items = msg.simpleItems
            GameCenter.PushFixEvent(UIEventDefine.UITreasureRewardForm_OPEN, {_items, self.AgainCallBack})
        end
    end
end

function TreasureHuntSystem:CheckRewardItemRedPoint(type)
    local _useFuncID = nil
    if type == TreasureEnum.Hunt then
        -- Treasure hunting for opportunities
        _useFuncID = FunctionStartIdCode.TreasureFind
    elseif type == TreasureEnum.ZaoHua then
        -- Treasure hunt for fortune
        _useFuncID = FunctionStartIdCode.TreasureZaoHua
    elseif type == TreasureEnum.HongMeng then
        -- Hongmeng Treasure Hunt
        _useFuncID = FunctionStartIdCode.TreasureHongMeng
    elseif type == TreasureEnum.ShangGu then
        -- Ancient treasure hunt
        _useFuncID = FunctionStartIdCode.TreasureShangGu
    end
    if _useFuncID == nil then
        return
    end
    GameCenter.RedPointSystem:RemoveFuncCondition(_useFuncID, 2)
    local list = self.RewardItemDict[type]
    GameCenter.RedPointSystem:AddFuncCondition(_useFuncID, 2, RedPointCustomCondition(list ~= nil and list:Count() > 0))
end

-- Check the number of free times red dots
function TreasureHuntSystem:CheckFreeRedPoint(type, tick)
    local _useFuncID = nil
    if type == TreasureEnum.Hunt then
        -- Treasure hunting for opportunities
        _useFuncID = FunctionStartIdCode.TreasureFind
    elseif type == TreasureEnum.ZaoHua then
        -- Treasure hunt for fortune
        _useFuncID = FunctionStartIdCode.TreasureZaoHua
    elseif type == TreasureEnum.HongMeng then
        -- Hongmeng Treasure Hunt
        _useFuncID = FunctionStartIdCode.TreasureHongMeng
    elseif type == TreasureEnum.ShangGu then
        -- Ancient treasure hunt
        _useFuncID = FunctionStartIdCode.TreasureShangGu
    end
    if _useFuncID == nil then
        return
    end
    
    GameCenter.RedPointSystem:RemoveFuncCondition(_useFuncID, 3)
    local _serverTime = GameCenter.HeartSystem.ServerTime
    if _serverTime >= tick then
        GameCenter.RedPointSystem:AddFuncCondition(_useFuncID, 3, RedPointCustomCondition(true))
        self.FreeTimerTable[type] = nil
    else
        self.FreeTimerTable[type] = tick - _serverTime
    end
end

function TreasureHuntSystem:SetWuyouRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.TreasureWuyou)
    local list = self.RewardItemDict[TreasureEnum.Wuyou]
    local _curData = self.TreasureHuntDataDict[TreasureEnum.Wuyou]
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TreasureWuyou, TreasureWuyouEnum.Bag, RedPointCustomCondition(list ~= nil and list:Count() > 0))
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TreasureWuyou, TreasureWuyouEnum.GetItem, RedPointCustomCondition(self.IsCanGetItem))
    if _curData then
        local _items = Utils.SplitStrByTableS(_curData.Times, {';', '_'})
        for i = 1, #_items do
            local _count   = tonumber(_items[i][1])
            local _itemId  = tonumber(_items[i][2])
            local _needNum = tonumber(_items[i][3])
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.TreasureWuyou, _count, RedPointItemCondition(_itemId, _needNum))
        end
    end
end

-- Open the Worry-free Treasure Library interface and return the message
function TreasureHuntSystem:ResOpenWuyouPanel(msg)
    self.IsCanGetItem = msg.getItem
    self.FuncRemainTime = msg.lastTime / 1000
    if msg.getItemTime then
        self.ReceiveRemainTime = msg.getItemTime / 1000
    else
        self.ReceiveRemainTime = 0
    end
    self.IsUpdateTime = true
    self:SetWuyouRedPoint()
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TreasureWuyou, self.FuncRemainTime > 0)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
end

-- Worry-free treasure house information issuance, including warehouses and records
function TreasureHuntSystem:ResWuyouAllInfo(msg)
    self:SetWarehouseInfo(msg.info)
    if msg.allRecordInfo then
        for i = 1, #msg.allRecordInfo do
            self:SetRecordData(msg.allRecordInfo[i], 1)
        end
    end
    if msg.selfRecordInfo then
        for i = 1, #msg.selfRecordInfo do
            self:SetRecordData(msg.selfRecordInfo[i], 0)
        end
    end
    self:SetWuyouRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_TREASURE_WAREHOUSE)
end

function TreasureHuntSystem:ResWuyouHuntResult(msg)
    local showList = List:New()
    if msg ~= nil then
        -- Return to a single
        if msg.simpleItems ~= nil then
            -- Props list
            local _rewardItemList = nil
            showList = msg.simpleItems
            if showList ~= nil then
                _rewardItemList = List:New(showList)
            end
            -- Warehouse Type 1. Treasure Hunt Prize Pool 2. Inscription Prize Pool 3. Equipment Prize Pool 4. Peak Prize Pool
            local _type = tonumber(TreasureEnum.Wuyou)
            if self.RewardItemDict:ContainsKey(_type) then
                if _rewardItemList ~= nil then
                    local _count = _rewardItemList:Count()
                    if _count ~= nil and _count > 0 then
                        for i = 1, _count do
                            self.RewardItemDict[_type]:Add(_rewardItemList[i])
                        end
                    end
                end
            else
                self.RewardItemDict:Add(_type, _rewardItemList)
            end
        end
    end
    self:SetWuyouRedPoint()
    -- Refreshing the treasure hunt data
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH, showList)
end

-- Result of treasure recycling
function TreasureHuntSystem:ResRecoveryResult(msg)
    if msg ~= nil then
        -- success
        if msg.result == 1 then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_RECOVERY_REFRESH)
            Utils.ShowPromptByEnum("Treasure_Recovery_Succ")
        else
            Utils.ShowPromptByEnum("Treasure_Recovery_Fail")
        end
    end
end

-- Receive items and return
function TreasureHuntSystem:ResGetItem(msg)
    if msg.success then
        self.IsCanGetItem = false
    end
    local _msg = ReqMsg.MSG_TreasureHuntWuyou.ReqOpenPanel:New()
    _msg:Send()
end

-- Updated treasure hunting free time
function TreasureHuntSystem:ResFreeTreasureTime(msg)
    self.FreeTimeTickTable[msg.type] = msg.tick
    self:CheckFreeRedPoint(msg.type, msg.tick)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TREASURE_FIND_REFRESH)
end

-- renew
function TreasureHuntSystem:Update(dt)
    if self.IsUpdateTime and self.ReceiveRemainTime > 0 then
        self.ReceiveRemainTime = self.ReceiveRemainTime - dt
    end
    if self.IsUpdateTime and self.FuncRemainTime > 0 then
        self.FuncRemainTime = self.FuncRemainTime - dt
    end
    if self.IsUpdateTime and self.FuncRemainTime <= 0 then
        self.IsUpdateTime = false
        GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.TreasureWuyou)
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TreasureWuyou, false)
    end

    for k, v in pairs(self.FreeTimerTable) do
        self.FreeTimerTable[k] = v - dt
        if v < 0 then
            self:CheckFreeRedPoint(k, self.FreeTimeTickTable[k])
            break
        end
    end
end

return TreasureHuntSystem
