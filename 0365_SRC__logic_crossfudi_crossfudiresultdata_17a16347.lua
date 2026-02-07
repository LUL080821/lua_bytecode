------------------------------------------------
-- Author:
-- Date: 2021-02-01
-- File: CrossFuDiResultData.lua
-- Module: CrossFuDiResultData
-- Description: Cross-server blessed land settlement data
------------------------------------------------
-- Quote
local CrossFuDiResultData = {
    FirstData = nil,
    RewardItem = nil,
}

function CrossFuDiResultData:New(id)
    local _m = Utils.DeepCopy(self)
    _m.Id = id
    return _m
end

function CrossFuDiResultData:SetFirstData(msg)
    if msg == nil then
        return
    end
    local _facade = msg.first.facade
    local _name = msg.first.name
    local _occ = msg.first.career
    local _firstData = {
        Name = _name,
        Occ = _occ,
        VisInfo = nil
    }
    _firstData.VisInfo = PlayerVisualInfo:New()
    _firstData.VisInfo:ParseByLua(_facade, 0)
    self.FirstData = _firstData
end

function CrossFuDiResultData:GetFirstData()
    return self.FirstData
end

-- Set reward props
function CrossFuDiResultData:SetFinalItemData(id)
    local _cfg = DataConfig.DataCrossFudiHoldReward[id]
    if _cfg == nil then
        return
    end
    local _isFind = false
    local _index = 3
    local _rankId = 999
    local _playerId = GameCenter.GameSceneSystem:GetLocalPlayerID()
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    -- Get the current lucky land's points ranking
    local _cityData = GameCenter.CrossFuDiSystem:GetEnterCityData()
    if _cityData ~= nil then
        local _rankList = _cityData:GetPersonScoreRankDatas()
        if _rankList ~= nil then
            for i = 1, #_rankList do
                local _rank = _rankList[i]
                if _playerId == _rank.PlayerId then
                    _isFind = true
                    _rankId = _rank.Rank
                    break
                end
            end
        end
    end
    local _list = Utils.SplitStr(_cfg.Rank, ';')
    if _isFind then
        for i = 1, #_list do
            local _values = Utils.SplitNumber(_list[i], '_')
            local _min = _values[1]
            local _max = _values[2]
            if _rankId >= _min and _rankId <= _max then
                _index = i
                break
            end
        end
    end
    if _occ == 0 then
        _list = Utils.SplitStr(_cfg.Reward0, ';')
    else
        _list = Utils.SplitStr(_cfg.Reward1, ';')
    end
    if _list ~= nil and _index <= #_list then
        local _itemStr = _list[_index]
        local _itemData = Utils.SplitNumber(_itemStr, '_')
        self.RewardItem = {Id = _itemData[1], Num = _itemData[2], true}
    end
end

-- Get reward props
function CrossFuDiResultData:GetFinalItemData()
    return self.RewardItem
end

return CrossFuDiResultData
