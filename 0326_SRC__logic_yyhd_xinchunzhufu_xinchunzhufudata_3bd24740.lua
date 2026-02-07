------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: JiZiDuiHuanData.lua
-- Module: JiZiDuiHuanData
-- Description: Word redemption data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")
local ModelData = require("Logic.YYHD.YYHDModelData")

local XinChunZhuFuData = {
    -- What day of the event
    CurDay = 0,
    -- Number of servers
    ServerCount = 0,
    -- Number of additional currency
    CostNum = 0,
    -- Re-sign currency id
    CostId = 0,
    -- Check-in list {Day, ItemList, IsSign, IsReSign, CanSign, ModelId}
    SignList = List:New(),
    -- List of awards for the entire server {Id, Need, PreNeed, ItemList, IsReward}
    RewardList = List:New()
}

function XinChunZhuFuData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
function XinChunZhuFuData:ParseSelfCfgData(jsonTable)
    local _player = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _player ~= nil then
        local _occ = _player.Occ
        _occ = UnityUtils.GetObjct2Int(_occ)
        -- Sign-in data
        self.SignList:Clear()
        local _signList = jsonTable.daily
        if _signList ~= nil then
            for i = 1, #_signList do
                local _data = _signList[i]
                local _day = _data.day
                local _modelId = _data.modelId
                local _itemList = List:New()
                for m = 1, #_data.rewards do
                    local _itemData = ItemData:New(_data.rewards[m])
                    if _itemData.Occ == 9 or _itemData.Occ == _occ then
                        local _item = {
                            Id = _itemData.ItemID,
                            Num = _itemData.ItemCount,
                            IsBind = _itemData.IsBind
                        }
                        _itemList:Add(_item)
                    end
                end
                local _modelData = nil
                if _data.modelId ~= nil then
                    local _magicTable = Json.decode(_data.modelId)
                    _modelData = ModelData:New(_magicTable)
                end
                local _signData = {
                    Day = _day,
                    ItemList = _itemList,
                    IsSign = false,
                    IsReSign = false,
                    CanSign = false,
                    ModelId = _modelId,
                    ModelData = _modelData,
                }
                self.SignList:Add(_signData)
            end
        end
        -- All server award data
        self.RewardList:Clear()
        local _rewardList = jsonTable.total
        if _rewardList ~= nil then
            local _point = 0
            for i = 1, #_rewardList do
                local _data = _rewardList[i]
                local _id = _data.id
                local _need = _data.need
                local _preNeed = _point
                _point = _data.need
                local _itemList = List:New()
                for m = 1, #_data.rewards do
                    local _itemData = ItemData:New(_data.rewards[m])
                    if _itemData.Occ == 9 or _itemData.Occ == _occ then
                        local _item = {
                            Id = _itemData.ItemID,
                            Num = _itemData.ItemCount,
                            IsBind = _itemData.IsBind
                        }
                        _itemList:Add(_item)
                    end
                end
                local _reward = {
                    Id = _id,
                    Need = _need,
                    PreNeed = _preNeed,
                    ItemList = _itemList,
                    IsReward = false,
                }
                self.RewardList:Add(_reward)
            end
        end
        self.CostNum = jsonTable.buqianCost
        self.CostId = jsonTable.buqianid
    end
end

-- Analyze the data of active players
function XinChunZhuFuData:ParsePlayerData(jsonTable)
    if not self:IsActive() then
        return
    end
    local mask = 0
    self.ServerCount = jsonTable.serverCount
    self.CurDay = jsonTable.curDay
    for i = 1,#self.SignList do
        local data = self.SignList[i]
        mask = 1 << data.Day - 1
        if jsonTable.signBin & mask > 0 then
            data.IsSign = true
        else
            data.IsSign = false
            data.IsReSign = self.CurDay > data.Day
            data.CanSign = self.CurDay >= data.Day
        end
    end
    for i = 1,#self.RewardList do
        local data = self.RewardList[i]
        mask = 1 << data.Id - 1
        if jsonTable.serverBin & mask > 0 then
            data.IsReward = true
        else
            data.IsReward = false
        end
    end
end

-- Get data
function XinChunZhuFuData:GetDataById(id)
    local _ret = nil
    if self.SignList ~= nil then
        for i = 1, #self.SignList do
            local _data = self.SignList[i]
            if _data.Day == id then
                _ret = _data
                break
            end
        end
    end
    return _ret
end

-- Get the model id
function XinChunZhuFuData:GetModelIdByDay(day)
    local ret = 0
    if self.SignList ~= nil then
        for i = 1, #self.SignList do
            local data = self.SignList[i]
            if data.Day == day then
                ret = data.ModelId
                break
            end
        end
    end
    return ret
end

-- Refresh data
function XinChunZhuFuData:RefreshData()
    self:CheckRedPoint()
end

-- Check the red dots
function XinChunZhuFuData:CheckRedPoint()
    local _isShow = false
    self:RemoveRedPoint(nil)
    if self.SignList ~= nil then
        for i = 1, #self.SignList do
            local _data = self.SignList[i]
            if _data.CanSign  then
                _isShow = true
                break
            end
        end
    end
    if not _isShow then
        for i = 1,#self.RewardList do
            local _data = self.RewardList[i]
            if self.ServerCount >= _data.Need and not _data.IsReward then
                _isShow = true
                break
            end
        end
    end
    self:AddRedPoint(1, nil, nil, nil, _isShow, nil)
end

-- Send a reward request
function XinChunZhuFuData:ReqSign(id)
    local _json = string.format("{\"day\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {
        type = self.TypeId,
        data = _json
    })
end

function XinChunZhuFuData:ReqReward(id)
    local _json = string.format("{\"reward\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {
        type = self.TypeId,
        data = _json
    })
end

-- Processing operational activities return
function XinChunZhuFuData:ResActivityDeal(jsonTable)
    local mask = 0
    self.ServerCount = jsonTable.serverCount
    self.CurDay = jsonTable.curDay
    for i = 1,#self.SignList do
        local data = self.SignList[i]
        mask = 1 << data.Day - 1
        if jsonTable.signBin & mask > 0 then
            data.IsSign = true
            data.CanSign = false
            data.IsReSign = false
        else
            data.IsSign = false
            data.IsReSign = self.CurDay > data.Day
            data.CanSign = self.CurDay >= data.Day
        end
    end
    for i = 1,#self.RewardList do
        local data = self.RewardList[i]
        mask = 1 << data.Id - 1
        if jsonTable.serverBin & mask > 0 then
            data.IsReward = true
        else
            data.IsReward = false
        end
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XINCHUN_SIGN_RESULT)
end

return XinChunZhuFuData
