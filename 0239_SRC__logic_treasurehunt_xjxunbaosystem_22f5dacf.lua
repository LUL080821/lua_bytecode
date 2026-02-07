------------------------------------------------
-- author:
-- Date: 2020-02-26
-- File: XJXunbaoSystem.lua
-- Module: XJXunbaoSystem
-- Description: Fairy Armor Treasure Hunt System
------------------------------------------------

local L_TreasureHuntData = require "Logic.TreasureHunt.TreasureHuntData"
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition

local XJXunbaoSystem =
{
    XJXunbaoOpen = false,
    -- Default is fairy armor treasure hunt
    XJXunbaoType = TreasureEnum.XJXunbao,

    -- Data of configuration table required on the interface
    XJXunbaoDict = nil,
    -- Data from the warehouse
    RewardItemList = nil,
    -- Current rounds
    Round = 0,
    -- The maximum number of times a day
    AllNum = 0,
    -- The rest of this round
    ReaminTime = 0,
    -- Reward on the left side of the secret treasure
    LeftRewardDict = nil,
    -- Rewards on the right side of the secret treasure
    RightRewardDict = nil,
    -- Sorting of collected secret treasures [id, data]
    MbRewardDict = nil,
    -- Number of treasure hunts in this round
    HuntNum = 0,
    -- The remaining times
    XJHuntRemainNum = 0,
    -- The number of times the secret treasure has been drawn
    MIBaoHuntCount = 0,
    -- The number of times that can be extracted by secret treasures
    MibaoHaveHuntNum = 0,
    -- The maximum number of times that can be extracted in secret treasures
    MibaoHuntCountMax = 0,
    -- Number of times drawn per day
    DayHuntCount = 0,
    -- The data of the secret treasure lottery, on the left
    MiBaoChouJiangData = nil,
    --
    IsJumpAskBuy = false,
}

-- Lottery record
local L_RecordTypeEnum =
{
    -- Single player
    SelfRec = 0,
    -- 1 means all server players
    AllPlayerRec = 1,
}

function XJXunbaoSystem:Initialize()
    self.XJXunbaoDict = Dictionary:New()
    self.RewardItemList = List:New()
    self.LeftRewardDict = Dictionary:New()
    self.RightRewardDict = Dictionary:New()
    self.MbRewardDict = Dictionary:New()
    self.Round = 1
end

function XJXunbaoSystem:UnInitialize()
    self.XJXunbaoDict:Clear()
    self.RewardItemList:Clear()
    self.LeftRewardDict:Clear()
    self.RightRewardDict:Clear()
    self.MbRewardDict:Clear()
end

function XJXunbaoSystem:ParseCfg()
    self.AllNum = tonumber(Utils.SplitStr(DataConfig.DataGlobal[1778].Params, "_")[1])
    self.MibaoHuntCountMax = tonumber(DataConfig.DataGlobal[1784].Params)
    local _curWorldLevel = GameCenter.OfflineOnHookSystem:GetCurWorldLevel()
    DataConfig.DataTreasurePop:Foreach(
        function(_, _cfg)
            --local _type = tonumber(_cfg.RewardType)
            local _type = tonumber(_cfg.Id)
            -- The fairy armor treasure hunter has come in
            if TreasureEnum.XJXunbao == _cfg.RewardType then
                local _xjXunbaoCfgList = List:New()
                local _specItemCfg = nil
                DataConfig.DataTreasureHunt:Foreach(
                    function(_id, _xjCfg)
                        local _roundTemp = 1
                        if _xjCfg.RewardType == TreasureEnum.XJXunbao then
                            -- Save the data of the current round number
                            if self.Round == _xjCfg.Round then
                                -- Not a master reward
                                if _xjCfg.IsShow ~= 2 then
                                    local _levels = Utils.SplitStr( _xjCfg.WorldLevel, '_')
                                    local _minLv = tonumber(_levels[1])
                                    local _maxLv = tonumber(_levels[2])
                                    -- If the world level is within the configured level range, save the reward
                                    if _minLv <= _curWorldLevel and _maxLv >= _curWorldLevel then
                                        if _xjCfg.IsShow ~= -1 then
                                            _xjXunbaoCfgList:Add(_xjCfg)
                                        end
                                    end
                                else
                                    _specItemCfg = _xjCfg
                                end
                            end
                        end
                    end
                )
                -- Assembly data
                local _xjXunbaoData =
                {
                    FuncName = _cfg.RewardName,
                    Cfg = _cfg,
                    XJXunbaoCfgList = _xjXunbaoCfgList,
                    SpecItemCfg = _specItemCfg
                }
                if not self.XJXunbaoDict:ContainsKey(_type) then
                    self.XJXunbaoDict:Add(_type, _xjXunbaoData)
                else
                    self.XJXunbaoDict[_type] = _xjXunbaoData
                end
            -- Data of the Immortal Armor Secret Treasure
            elseif TreasureEnum.XJMibao == _cfg.RewardType then
                local _xjLeftCfgList = List:New()
                local _xjRightCfgList = List:New()
                DataConfig.DataTreasureXianjiaSecret:Foreach(
                    function(_id, _xjSecCfg)
                        -- Data of current rounds
                        if self.Round == _xjSecCfg.Round then
                            if _xjSecCfg.Type == 2 then
                                _xjLeftCfgList:Add(_xjSecCfg)
                            else
                                _xjRightCfgList:Add(_xjSecCfg)
                            end
                        end
                    end
                )
                -- Assembly data
                local _xjMibaoData =
                {
                    FuncName = _cfg.RewardName,
                    Cfg = _cfg,
                    LeftCfgList = _xjLeftCfgList,
                    RightCfgList = _xjRightCfgList,
                }
                if not self.XJXunbaoDict:ContainsKey(_type) then
                    self.XJXunbaoDict:Add(_type, _xjMibaoData)
                else
                    self.XJXunbaoDict[_type] = _xjMibaoData
                end
            end
        end
    )
end

-- Return to the results of the fairy armor treasure hunt
function XJXunbaoSystem:ResTreasureXijiaResult(msg)
    if msg then
        local _info = msg.info
        local _type = _info.type
        -- The remaining times today
        self.XJHuntRemainNum = _info.todayLeftTimes
        self.HuntNum = msg.xijiaHuntCount
        self.DayHuntCount = msg.dayHuntCount
        self:SetWarehouseInfo(_info)
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
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJXUNBAO_REFESH)
        self:SetRedPoint()
    end
end

-- Return to purchase information
function XJXunbaoSystem:ResBuyCountResult(msg)
    if msg then
        local _type = msg.type
        -- There is also a need to refresh the interface
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJXUNBAO_REFESH)
        self:SetRedPoint()
    end
end

-- Return one-click extraction result
function XJXunbaoSystem:ResExtractResult(msg)
    if msg then
        local _type = msg.type
        -- 0 One-click extraction does not mean a single extraction
        local _uid = msg.uid
        if _uid ~= 0 then
            for i=1, #self.RewardItemList do
                local _item = self.RewardItemList[i]
                if _item.uid == _uid then
                    self.RewardItemList:Remove(_item)
                    break
                end
            end
        else
            -- Clear it with one click
            self.RewardItemList:Clear()
        end
        -- Refresh the warehouse interface
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJCANGKU_REFESH)
        self:SetRedPoint()
    end
end

-- Return to all warehouse information --- Will be sent online
function XJXunbaoSystem:ResAllWarehouseXianjiaInfo(msg)
    self.HuntNum = msg.xijiaHuntCount
    -- The number of times the secret treasure has been drawn in this round
    self.MIBaoHuntCount = msg.mibaoHuntCount
    -- Warehouse prop list (List<warehouseInfo>)
    local _warehouseInfoList = msg.info
    if _warehouseInfoList ~= nil then
        for _, _info in pairs(_warehouseInfoList) do
            self:SetWarehouseInfo(_info)
        end
    end
    -- Full server record list (List<treasureRecordInfo>)
    local _allRecordInfoList = msg.allRecordInfo
    if _allRecordInfoList ~= nil then
        for _, _recordInfo in pairs(_allRecordInfoList) do
            GameCenter.TreasureHuntSystem:SetRecordData(_recordInfo, L_RecordTypeEnum.AllPlayerRec)
        end
    end
    -- Record the list yourself (List<treasureRecordInfo>)
    local _selfRecordInfoList = msg.selfRecordInfo
    if _selfRecordInfoList ~= nil then
        for _, _recordInfo in pairs(_selfRecordInfoList) do
            GameCenter.TreasureHuntSystem:SetRecordData(_recordInfo, L_RecordTypeEnum.SelfRec)
        end
    end
    self:ParseCfg()
    -- There is also a need to refresh the interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJXUNBAO_REFESH)
    self:SetRedPoint()
end

-- Reward results panel
function XJXunbaoSystem:ResRewardResultXianjiaPanle(msg)
    -- Activity Type
    local _type = msg.type
    -- Props list
    local _items = msg.simpleItems

    -- The Immortal Armor Secret Treasure needs to be handled separately
    if _type == TreasureEnum.XJMibao and msg.ext1 == 2 then
        self.MiBaoChouJiangData = _items
    else
        GameCenter.PushFixEvent(UIEventDefine.UITreasureRewardForm_OPEN, {_items})
    end
end

-- Return to the interface to open the Immortal Armor Treasure Hunt
function XJXunbaoSystem:ResOpenXianjiaHuntPanel(msg)
    if msg then
        -- The data of the configuration table is only parsed when the number of rounds changes
        if self.Round ~= msg.round then
            self.Round = msg.round
            self.XJXunbaoDict:Clear()
            self:ParseCfg()
        end
        self.XJXunbaoType = msg.type
        self.HuntNum = msg.huntTime
        self.DayHuntCount = msg.dayHuntCount
        self.ReaminTime = msg.lastTime / 1000
        self.MIBaoHuntCount = msg.mibaoHuntCount
        if self.XJXunbaoType == TreasureEnum.XJMibao then
            -- The number of times the secret treasure can be used in this round
            self.MibaoHaveHuntNum = math.floor(self.HuntNum / 200) - self.MIBaoHuntCount
            if self.MibaoHaveHuntNum > self.MibaoHuntCountMax then
                self.MibaoHaveHuntNum = self.MibaoHuntCountMax - self.MIBaoHuntCount
            end
            -- The one on the right
            local _rewardRightList = msg.reward_1
            for i = 1, #_rewardRightList do
                local _data = _rewardRightList[i]
                if not self.RightRewardDict:ContainsKey(_data.id) then
                    self.RightRewardDict:Add(_data.id, _data.isGet)
                else
                    self.RightRewardDict[_data.id] = _data.isGet
                end
            end
            -- The one on the left
            local _rewardLeftList = msg.reward_2
            for i = 1, #_rewardLeftList do
                local _data = _rewardLeftList[i]
                if not self.LeftRewardDict:ContainsKey(_data.id) then
                    self.LeftRewardDict:Add(_data.id, _data.isGet)
                else
                    self.LeftRewardDict[_data.id] = _data.isGet
                end
            end
            self.RightRewardDict:SortKey(function(a, b) return a < b end)
            self.LeftRewardDict:SortKey(function(a, b) return a < b end)
            self:SortIsGetMibao()
        end
        -- Refresh the treasure hunt and treasure interface
        if self.XJXunbaoType == TreasureEnum.XJXunbao then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJXUNBAO_REFESH)
        else
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJMIBAO_REFESH)
            self:SetRedPoint()
        end
    end
end

-- Sort the data on the right side of the treasure
function XJXunbaoSystem:SortIsGetMibao()
    self.MbRewardDict:Clear()
    -- Available
    local _canGetList = List:New()
    -- Haven't smoked yet
    local _unGetList = List:New()
    -- Received
    local _receivedList = List:New()
    local _mbCfgList = self.XJXunbaoDict[TreasureEnum.XJMibao].RightCfgList
    for i = 1, #_mbCfgList do
        local _data = _mbCfgList[i]
        -- false has received true draw or not
        local _isGet = self.RightRewardDict[_data.Id]
        local _canGet = GameCenter.XJXunbaoSystem.HuntNum >= _data.Time
        if _isGet then
            -- Draw to meet the criteria
            if _canGet then
                _canGetList:Add(_data)
            -- Haven't smoked yet
            else
                _unGetList:Add(_data)
            end
        else
            _receivedList:Add(_data)
        end
    end
    for i = 1, #_canGetList do
        local _data = _canGetList[i]
        self.MbRewardDict:Add(_data.Id, _data)
    end
    for i = 1, #_unGetList do
        local _data = _unGetList[i]
        self.MbRewardDict:Add(_data.Id, _data)
    end
    for i = 1, #_receivedList do
        local _data = _receivedList[i]
        self.MbRewardDict:Add(_data.Id, _data)
    end
end

-- Request a secret treasure to return
function XJXunbaoSystem:ResTreasureHuntMibaoResult(msg)
    -- 1 Receive 2 Free lottery
    local _type = msg.type
    -- Refresh the reward page
    local _rewardRightList = msg.reward_1
    -- 1 is the data on the right side of the treasure 2 is the data on the left
    if _type == 1 then
        for i = 1, #_rewardRightList do
            local _data = _rewardRightList[i]
            if not self.RightRewardDict:ContainsKey(_data.id) then
                self.RightRewardDict:Add(_data.id, _data.isGet)
            else
                self.RightRewardDict[_data.id] = _data.isGet
            end
        end
    else
        for i = 1, #_rewardRightList do
            local _data = _rewardRightList[i]
            if not self.LeftRewardDict:ContainsKey(_data.id) then
                self.LeftRewardDict:Add(_data.id, _data.isGet)
            else
                self.LeftRewardDict[_data.id] = _data.isGet
            end
        end
    end
    self.RightRewardDict:SortKey(function(a, b) return a < b end)
    self.LeftRewardDict:SortKey(function(a, b) return a < b end)
    self:SortIsGetMibao()
    -- Return to the single warehouse of Secret Treasure
    local _warehouseInfo = msg.info
    self:SetWarehouseInfo(_warehouseInfo)
    -- The number of times the secret treasure has been drawn in this round
    self.MIBaoHuntCount = msg.mibaoHuntCount
    -- Process data on turntable draws
    if _type == 2 then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJMIBAO_CHOUJIANG_REFESH, _rewardRightList)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XJMIBAO_REFESH)
    self:SetRedPoint()
end

-- Set up the data parsing the repository
function XJXunbaoSystem:SetWarehouseInfo(warehouseInfo)
    if warehouseInfo ~= nil then
        local _info = warehouseInfo
        -- Props list
        local _itemsList = _info.simpleItems
        if _itemsList ~= nil then
            for _, _item in pairs(_itemsList) do
                self.RewardItemList:Add(_item)
            end
        end
    end
end

-- Take out the warehouse of Xianjia Treasure Hunt (single)
function XJXunbaoSystem:ReqExtractByUID(uid)
    local _msg = ReqMsg.MSG_TreasureHuntXianjia.ReqExtract:New()
    _msg.type = TreasureEnum.XJXunbao
    _msg.uid = uid
    _msg:Send()
end

-- Set red dots
function XJXunbaoSystem:SetRedPoint()
    -- 1. The red dot of the fairy armor treasure hunt
    local _cfgData = self.XJXunbaoDict[TreasureEnum.XJXunbao].Cfg
    local _itemId = tonumber(Utils.SplitStr(_cfgData.Item, "_")[1])
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.XJXunbao)
    -- Determine whether there are still draws
    if self.DayHuntCount < self.AllNum then
        -- Only 10 keys show red dots
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.XJXunbao, 1, RedPointItemCondition(_itemId, 10))

        local _qydCfg = DataConfig.DataTreasurePop[8]
        local _qydItemId = nil
        local _qydItemCount = nil
        if _qydCfg ~= nil then
            local _qydTable = Utils.SplitNumber(_qydCfg.Times, '_')
            _qydItemId = _qydTable[2]
            _qydItemCount = _qydTable[3]
        end
        -- Friendship dots red dots
        if _qydItemId ~= nil then
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.XJXunbao, 1, RedPointItemCondition(_qydItemId, _qydItemCount))
        end
    end

    -- 2. The red dots in Xianjia warehouse, if there is something, it will show red dots.
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.XJCangku)
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.XJCangku, 1, RedPointCustomCondition(self.RewardItemList:Count() > 0))

    -- 3. The red dot of the secret treasure
    local _mibaoIsGet = false
    local _mibaoRewardListR = self.XJXunbaoDict[TreasureEnum.XJMibao].RightCfgList
    for i = 1, #_mibaoRewardListR do
        local _data = _mibaoRewardListR[i]
        local _time = _data.Time
        local _isGet = self.RightRewardDict[_data.Id]
        -- 1. true. False. It may be that the conditions have not been met.
        -- 2. The number of draws meets the requirements for the number of times in the configuration table
        if _isGet and self.HuntNum >= _time then
            _mibaoIsGet = true
            break
        end
    end
    -- If there are lottery times or rewards that can be claimed in the Secret Treasure interface, you need to display a red dot, and the maximum draw times are not reached.
    local _mibaoRedPoint = (self.MibaoHaveHuntNum > 0 and self.MIBaoHuntCount ~= self.MibaoHuntCountMax) or _mibaoIsGet
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.XJMibao)
    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.XJMibao, 1, RedPointCustomCondition(_mibaoRedPoint))
end

return XJXunbaoSystem
