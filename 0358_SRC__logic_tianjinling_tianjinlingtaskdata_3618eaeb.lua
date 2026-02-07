------------------------------------------------
-- author:
-- Date: 2020-11-07
-- File: TianJinLingTaskData.lua
-- Module: TianJinLingTaskData
-- Description: Day ban mission data
------------------------------------------------
-- Quote
local TianJinLingTaskData = {
    Cfg = nil,
    Count = 0,
    TCount = 0,
    Des = nil,
    IsAward = false,
    ItemList = nil
}

function TianJinLingTaskData:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    return _m
end

function TianJinLingTaskData:GetId()
    return self.Cfg.Id
end

function TianJinLingTaskData:GetDes()
    if self.Des == nil then
        self.Des = self.Cfg.Desc
    end
    return self.Des
end

function TianJinLingTaskData:GetItemDatas()
    if self.ItemList == nil then
        self.ItemList = List:New()
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if _lp ~= nil then
            local _playerOcc = _lp.IntOcc
            local _strs = Utils.SplitStr(self.Cfg.Reward, ';')
            for i = 1, #_strs do
                local _list = Utils.SplitNumber(_strs[i], '_')
                local _id = _list[1]
                local _num = _list[2]
                local _isBind = _list[3] == 1
                local _occ = _list[4]
                if _occ == _playerOcc or _occ == 9 then
                    local _data = {Id = _id, Num = _num, IsBind = _isBind}
                    self.ItemList:Add(_data)
                end
            end
        end
    end
    return self.ItemList
end

function TianJinLingTaskData:GetTCount()
    if self.TCount == 0 then
        local _list = Utils.SplitNumber(self.Cfg.Condition, '_')
        self.TCount = _list[#_list]
    end
    return self.TCount
end

function TianJinLingTaskData:GetState()
    local _state = 0
    if self.IsAward then
        -- Already received
        _state = 2
    else
        -- No collection
        if self.Count >= self:GetTCount() then
            _state = 0
        else
            _state = 1
        end
    end
    return _state
end

function TianJinLingTaskData:GetOpenUIId()
    return self.Cfg.OpenFunction
end

function TianJinLingTaskData:GetType()
    return self.Cfg.Type
end

return TianJinLingTaskData
