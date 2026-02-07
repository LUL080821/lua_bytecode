------------------------------------------------
-- author:
-- Date: 2019-07-19
-- File: XianPoSyntheticData.lua
-- Module: XianPoSyntheticData
-- Description: Xianpo Synthesis Data Class
------------------------------------------------

local XianPoSyntheticData = {
    CfgId = 0,                      -- Immortal Soul Configuration Table ID
    Name = "",                      -- The name of the immortal soul
    typ = 0,                        -- Category ID
    typName = "",                   -- Category name
    NeedXianPoIdCountList = List:New(),        -- The id of the immortal soul required for synthesis => Quantity dictionary
    NeedItemId = 0,                                 -- The required prop id
    NeedItemNum = 0,                                -- Number of props required for synthesis
    SuccessPer = 0,                 -- Extremely proportional
    Limit = 0,                      -- Synthesis Limitations
}

function XianPoSyntheticData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function XianPoSyntheticData:SetAllData(data)
    self.CfgId = data.Id
    self.Name = data.TargetItems
    self.typ = data.Type
    self.typName = data.TypeName
    if data.Material1 ~= "" then
        local _xianPoList = Utils.SplitStrByTableS(data.Material1)
        for i=1,#_xianPoList do
            local _data = {Id = _xianPoList[i][1], NeedNum = _xianPoList[i][2]}
            self.NeedXianPoIdCountList:Add(_data)
        end
    end
    if data.Material2 ~= "" then
        local _itemList = Utils.SplitStrByTableS(data.Material2)
        self.NeedItemId = _itemList[1][1]
        self.NeedItemNum = _itemList[1][2]
        -- for i=1,#_itemList do
        --     if not self.NeedItemIdCountDic:ContainsKey(_itemList[i][1]) then
        --         self.NeedItemIdCountDic:Add(_itemList[i][1], _itemList[i][2])
        --     end
        -- end
    end
    self.SuccessPer = data.Probability
    local _cfg = DataConfig.DataImmortalSoulAttribute[self.CfgId]
    if _cfg ~= nil then
        local limit = Utils.SplitNumber(_cfg.ExchangeConditions, '_')
        self.Limit = limit[2]
    end
end

return XianPoSyntheticData