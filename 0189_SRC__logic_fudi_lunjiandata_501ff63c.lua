------------------------------------------------
-- Author:
-- Date: 2021-01-21
-- File: LunJianData.lua
-- Module: LunJianData
-- Description: Blessed Land Sword Data
------------------------------------------------
-- Quote
local LunJianData = {
    -- Reward display
    ShowItemList = nil,
    -- Blessed Land Ranking Rewards
    FuDiItemList = nil,
    -- Personal ranking rewards
    PersonItemList = nil,
    -- Settlement interface data
    ResultPlayerInfo = nil,
    ResultFuDiInfo = nil,
    ResultOwnInfo = nil,
    -- Copy data
    Copy_FuDiScoreList = List:New(),
    Copy_PersonRankList = List:New(),
    Copy_TitleInfo = nil
}

function LunJianData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Obtain display reward data
function LunJianData:GetShowItems()
    if self.ShowItemList == nil then
        self.ShowItemList = List:New()
        local _cfg = DataConfig.DataDaily[112]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.Reward, "_")
            if _list ~= nil then
                for i = 1, #_list do
                    local _data = {
                        Id = _list[i]
                    }
                    self.ShowItemList:Add(_data)
                end
            end
        end
    end
    return self.ShowItemList
end

-- Obtain reward data for blessed land rankings
function LunJianData:GetFuDiitems()
    if self.FuDiItemList == nil then
        self.FuDiItemList = List:New()
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        DataConfig.DataGuildBattleFinalReward:Foreach(function(k, v)
            if v.Type == 0 then
                local _rank = Utils.SplitNumber(v.Rank, '_')
                local _min = _rank[1]
                local _max = _rank[2]
                local _sort = _rank[2]
                local _itemList = List:New()
                local _list = Utils.SplitStr(v.Reward, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _value = Utils.SplitNumber(_list[i], '_')
                        if _value[1] == 9 or _value[1] == _occ then
                            _itemList:Add({
                                Id = _value[2],
                                Num = _value[3]
                            })
                        end
                    end
                end
                local _data = {
                    Min = _min,
                    Max = _max,
                    Sort = _sort,
                    Title = v.Des,
                    ItemList = _itemList
                }
                self.FuDiItemList:Add(_data)
            end
        end)
        self.FuDiItemList:Sort(function(a, b)
            return a.Sort < b.Sort
        end)
    end
    return self.FuDiItemList
end

-- Obtain personal ranking reward data
function LunJianData:GetPersonItems()
    if self.PersonItemList == nil then
        self.PersonItemList = List:New()
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        DataConfig.DataGuildBattleFinalReward:Foreach(function(k, v)
            if v.Type == 1 then
                local _rank = Utils.SplitNumber(v.Rank, '_')
                local _min = _rank[1]
                local _max = _rank[2]
                local _sort = _rank[2]
                local _itemList = List:New()
                local _list = Utils.SplitStr(v.Reward, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _value = Utils.SplitNumber(_list[i], '_')
                        if _value[1] == 9 or _value[1] == _occ then
                            _itemList:Add({
                                Id = _value[2],
                                Num = _value[3]
                            })
                        end
                    end
                end
                local _data = {
                    Min = _min,
                    Max = _max,
                    Sort = _sort,
                    Title = v.Des,
                    ItemList = _itemList
                }
                self.PersonItemList:Add(_data)
            end
        end)
        self.PersonItemList:Sort(function(a, b)
            return a.Sort < b.Sort
        end)
    end
    return self.PersonItemList
end

return LunJianData
