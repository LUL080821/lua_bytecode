------------------------------------------------
-- Author:
-- Date: 2020-10-16
-- File: JiZiDuiHuanData.lua
-- Module: JiZiDuiHuanData
-- Description: Word redemption data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")
local ItemData = require("Logic.YYHD.YYHDItemData")
local JiZiDuiHuanData = {
    ExChangeList = List:New()
}

function JiZiDuiHuanData:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
function JiZiDuiHuanData:ParseSelfCfgData(jsonTable)
    self.ExChangeList:Clear()
    for i = 1, #jsonTable do
        local _info = jsonTable[i]
        local _id = _info.id
        local _itemList = List:New()
        for m = 1, #_info.words do
            local _itemData = ItemData:New(_info.words[m])
            local _item = {
                Id = _itemData.ItemID,
                Num = _itemData.ItemCount,
                IsBind = _itemData.IsBind
            }
            _itemList:Add(_item)
        end
        local _finalItem = nil
        local _player = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _player ~= nil then
            local _occ = _player.Occ
            _occ = UnityUtils.GetObjct2Int(_occ)
            for m = 1, #_info.box do
                local _finalItemData = ItemData:New(_info.box[m])
                if _finalItemData.Occ == 9 or _finalItemData.Occ == _occ then
                    _finalItem = {
                        Id = _finalItemData.ItemID,
                        Num = _finalItemData.ItemCount,
                        IsBind = _finalItemData.IsBind
                    }
                end
            end
        end
        local _data = {
            Id = _id,
            ItemList = _itemList,
            FinalItem = _finalItem,
            Limit = _info.limit,
            LeftCount = 0,
            IsShowRedPoint = _info.isShowRedPoint == 1,
        }
        self.ExChangeList:Add(_data)
    end
end

-- Analyze the data of active players
function JiZiDuiHuanData:ParsePlayerData(jsonTable)
    for i = 1, #jsonTable do
        local _info = jsonTable[i]
        local _data = self:GetDataById(_info.id)
        _data.LeftCount = _data.Limit - _info.count
    end
end

-- Get data
function JiZiDuiHuanData:GetDataById(id)
    local _ret = nil
    if self.ExChangeList ~= nil then
        for i = 1, #self.ExChangeList do
            local _data = self.ExChangeList[i]
            if _data.Id == id then
                _ret = _data
                break
            end
        end
    end
    return _ret
end

-- Refresh data
function JiZiDuiHuanData:RefreshData()
    self:CheckRedPoint()
end

-- Check the red dots
function JiZiDuiHuanData:CheckRedPoint()
    self:RemoveRedPoint(nil)
    if self.ExChangeList ~= nil then
        for i = 1, #self.ExChangeList do
            local _list = List:New()
            local _data = self.ExChangeList[i]
            for m = 1, #_data.ItemList do
                local _tab = {_data.ItemList[m].Id, _data.ItemList[m].Num}
                _list:Add(_tab)
            end
            if _data.IsShowRedPoint then
                self:AddRedPoint(i, _list)
            end
        end
    end
end

-- Send a reward request
function JiZiDuiHuanData:ReqChouJiang(id)
    local _json = string.format("{\"id\":%d}", id)
    GameCenter.Network.Send("MSG_Activity.ReqActivityDeal", {
        type = self.TypeId,
        data = _json
    })
end

-- Processing operational activities return
function JiZiDuiHuanData:ResActivityDeal(jsonTable)
    local _data = self:GetDataById(jsonTable.id)
    _data.LeftCount = _data.Limit - jsonTable.count
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JIZIDUIHUAN_RESULT)
end

return JiZiDuiHuanData
