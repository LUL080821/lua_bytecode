
------------------------------------------------
-- author:
-- Date: 2020-11-09
-- File: TianJinLingTaskData.lua
-- Module: TianJinLingTaskData
-- Description: Day ban mission data
------------------------------------------------
-- Quote
local TianJinLingLvData = {
    Cfg = nil,
    PrePoint = 0,
    Point = 0,
    CoinId = 0,
    -- Have you received a free reward
    IsAwardFree = false,
    -- Have you received a paid reward
    IsAwardPay = false,
}

function TianJinLingLvData:New(cfg)
    local _m = Utils.DeepCopy(self)
    _m.Cfg = cfg
    return _m
end

function TianJinLingLvData:GetId()
    return self.Cfg.Id
end

function TianJinLingLvData:GetLv()
    return self.Cfg.Level
end

function TianJinLingLvData:GetPoint()
    if self.Point == 0 then
        local list = Utils.SplitNumber(self.Cfg.Exp, '_')
        self.CoinId = list[1]
        self.Point = list[2]
    end
    return self.Point
end

function TianJinLingLvData:GetCoinId()
    if self.CoinId == 0 then
        local list = Utils.SplitNumber(self.Cfg.Exp, '_')
        self.CoinId = list[1]
        self.Point = list[2]
    end
    return self.CoinId
end

function TianJinLingLvData:GetModelParam()
    local _ret = nil
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return _ret
    end
    local _playerOcc = _lp.IntOcc
    local _list = Utils.SplitStr(self.Cfg.ShowModel, ';')
    for i = 1, #_list do
        local _str = _list[i]
        local _values = Utils.SplitNumber(_str, '_')
        local _id = _values[1]
        local _scale = _values[2]
        local _x = _values[3]
        local _y = _values[4]
        local _rotx = _values[5]
        local _roty = _values[6]
        local _rotz = _values[7]
        local _occ = _values[8]
        if _occ == _playerOcc or _occ == 9 then
            _ret = {ModelId = _id, Scale = _scale, X = _x, Y = _y, Rot = Vector3(_rotx, _roty, _rotz)}
        end
    end
    return _ret
end

function TianJinLingLvData:GetFreeItems()
    local _itemList = List:New()
    local _ret = nil
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return _ret
    end
    local _playerOcc = _lp.IntOcc
    local _list = Utils.SplitStr(self.Cfg.FreeReward, ';')
    for i = 1, #_list do
        local _str = _list[i]
        local _values = Utils.SplitNumber(_str, '_')
        local _id = _values[1]
        local _num = _values[2]
        local _isBind = _values[3] == 1
        local _occ = _values[4]
        if _occ == _playerOcc or _occ == 9 then
            _itemList:Add({Id = _id, Num = _num, IsBind = _isBind})
        end
    end
    return _itemList
end

function TianJinLingLvData:GetPayItems()
    local _itemList = List:New()
    local _ret = nil
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return _ret
    end
    local _playerOcc = _lp.IntOcc
    local _list = Utils.SplitStr(self.Cfg.PayReward, ';')
    for i = 1, #_list do
        local _str = _list[i]
        local _values = Utils.SplitNumber(_str, '_')
        local _id = _values[1]
        local _num = _values[2]
        local _isBind = _values[3] == 1
        local _occ = _values[4]
        if _occ == _playerOcc or _occ == 9 then
            _itemList:Add({Id = _id, Num = _num, IsBind = _isBind})
        end
    end
    return _itemList
end

function TianJinLingLvData:GetViewId()
    local _ret = 0
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return _ret
    end
    local _playerOcc = _lp.IntOcc
    local _list = Utils.SplitStr(self.Cfg.ShowItem, ';')
    for i = 1, #_list do
        local _str = _list[i]
        local _values = Utils.SplitNumber(_str, '_')
        local _occ = _values[2]
        local _id = _values[1]
        if _occ == _playerOcc or _occ == 9 then
            _ret = _id
        end
    end
    return _ret
end

return TianJinLingLvData