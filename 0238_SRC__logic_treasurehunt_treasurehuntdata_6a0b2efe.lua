------------------------------------------------
-- author:
-- Date: 2019-07-18
-- File: TreasureHuntData.lua
-- Module: TreasureHuntData
-- Description: Treasure Hunt Data Class
------------------------------------------------
local TreasureHuntData =
{
    ID = nil,
    -- Which activity
    RewardType = nil,
    -- Activity name
    RewardName = nil,
    -- Single spend
    MoneyCost = nil,
    -- id_num obtained after purchase
    Item = nil,
    -- Number of extraction times_prop id_number
    Times = nil,
    -- Number of gold coins purchased Currency type_num
    Gold = nil,
    -- Points obtained Currency Type_num
    Integral = nil,
    -- A prop in type must be won in the specific number of times
    Frequency = nil,
    -- Reward Dictionary (id, item)
    NormalItemDict = nil,
    SpecialItemDict = nil,
    ShowModel = nil,
    ModelPos = nil,
    SpecialItemIdDict = nil,

    -- Number of free times
    FreeCount = 0,
    -- Must win the remaining consumption times
    LeftCount = 0,
    -- The remaining times today
    TodayCount = 0,
    -- Cap each draw
    AllCount = 0,
    -- Only 10 data can be stored at most.
    MAX_DATA_COUNT = 10,
    -- Current server blessing value
    CurSreverZhuFuValue = 0,
    -- Maximum blessing value
    MaxSreverZhuFuValue = 0,
}

function TreasureHuntData:New(_cfg)
    local _m = Utils.DeepCopy(self)
    _m.NormalItemDict = Dictionary:New()
    _m.SpecialItemDict = Dictionary:New()
    _m.SpecialItemIdDict = {}
    _m:RefeshData(_cfg)
    return _m
end

function TreasureHuntData:RefeshData(_cfg)
    if _cfg ~= nil then
        -- Specific configuration of items
        self.RewardType = tonumber(_cfg.RewardType)
        self.RewardName = _cfg.RewardName
        self.MoneyCost = _cfg.MoneyCost
        self.Item = _cfg.Item
        self.FreeCount = _cfg.FreeTimes
        self.Times = _cfg.Times
        self.Gold = _cfg.Gold
        self.Integral = _cfg.Integral
        self.Frequency = _cfg.Frequency
        self.ShowModel = _cfg.ShowModel
        if _cfg.ModelPos ~= nil then
            self.ModelPos = Utils.SplitNumber(_cfg.ModelPos, "_")
        else
            self.ModelPos = {0, 0, 0}
        end
        self.MaxSreverZhuFuValue = _cfg.LuckLimit
        self.AllCount = tonumber(DataConfig.DataGlobal[1586].Params)
        local _count = 1
        DataConfig.DataTreasureHunt:Foreach(
            function(_, _huntCfg)
                local _huntType = tonumber(_huntCfg.RewardType)
                if _huntType == self.RewardType then
                    local _id = tonumber(_huntCfg.Id)
                    local _reward = tostring(_huntCfg.Reward)
                    local _type = tonumber(_huntCfg.Type)
                    -- Ordinary props If the IsShow field is less than 0, it cannot be displayed. You can only put 10 data at most.
                    if _type == 1 and tonumber(_huntCfg.IsShow) >= 0 then
                        if _huntType == 1 and _count <= self.MAX_DATA_COUNT then
                            self.NormalItemDict:Add(_id, _reward)
                            _count = _count + 1
                        else
                            self.NormalItemDict:Add(_id, _reward)
                        end
                    else
                        if _type == 2 then
                            local _rewardTable = Utils.SplitStrByTableS(_reward, {';', '_'})
                            for i = 1, #_rewardTable do
                                self.SpecialItemIdDict[_rewardTable[i][1]] = true
                            end
                            -- Best props, use the isShow field as key
                            if not self.SpecialItemDict:ContainsKey(_huntCfg.IsShow) then
                                self.SpecialItemDict:Add(_huntCfg.IsShow, _reward)
                            end
                        end
                    end
                end
            end
        )
        -- Order according to IsShow
        self.SpecialItemDict:SortKey(function(a, b) return a < b end)
    end
end

return TreasureHuntData