------------------------------------------------
-- Author:
-- Date: 2019-04-29
-- File: RankPlayerInfo.lua
-- Module: RankPlayerInfo
-- Description: Ranking player data category
------------------------------------------------
-- Quote
local RankPlayerInfo = {
    RoleId          = 0,
    Name            = nil,
    Career          = 0,
    -- Realm level
    StateLevel      = 0,
    Level           = 0,
    -- VIP level
    VipLv           = 0,
    -- The level of mind
    Mental          = 0,
    -- Number of worships
    BePraiseNum     = 0,
    -- Mount appearance
    HorseModel      = 0,
    -- Wings Appearance
    WingModel       = 0,
    -- Magic weapon appearance
    FaBaoModel      = 0,
    -- Pet Appearance
    PetModel        = 0,
    -- Soul Armor Appearance
    HunJiaModel     = 0,
    -- Appearance information
    VisInfo         = nil,
    -- Have you admired this player
    IsPraise        = false,
    -- List of ordinary equipment
    NormalEquipList = List:New(),
    -- Fairy Armor Equipment
    XianJiaEquipDic = Dictionary:New(),
}

function RankPlayerInfo:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

function RankPlayerInfo:Parase(info)
    self.RoleId = info.roleId
    self.Name = info.roleName
    self.StateLevel = info.stateVip
    self.Career = info.career
    self.Level = info.level
    self.VipLv = info.vipLvl
    self.Mental = info.mental
    self.BePraiseNum = info.beWorshipedNum
    self.HorseModel = info.horseModel
    self.FaBaoModel = info.faBaoModel
    self.PetModel = info.fightPetID
    self.HunJiaModel = info.soulId
    self.VisInfo = PlayerVisualInfo:New()
    self.VisInfo:ParseByLua(info.facade, self.StateLevel)
    self.IsPraise = info.beWorship
    self.NormalEquipList:Clear()
    if info.equipInfoList ~= nil then
        for i = 1, #info.equipInfoList do
            local equipId = info.equipInfoList[i].equipID
            local _washDic = nil
            local _gemList = info.equipInfoList[i].gemIds
            local _jadeList = info.equipInfoList[i].jadeIds
            local _refLv = 0
            if info.equipInfoList[i].jinlianlevel then
                _refLv = info.equipInfoList[i].jinlianlevel
            end
            if info.equipInfoList[i].equipWashList then
                _washDic = Dictionary:New()
                local _equipWashList = info.equipInfoList[i].equipWashList
                for index = 1, #_equipWashList do
                    local washLine = _equipWashList[index]

                    local _index = washLine.id or 0
                    local _poolId = washLine.poolId or 0
                    local _percent = washLine.per or 0
                    --local _data = { AttrID = 99, Value = 0, Percent = 0 }
                    local _poolInfo = Utils.ParsePoolAttribute(_poolId)
                    if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                        --- {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
                        local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (_percent / 10000) + _poolInfo.minVal)
                        local _data = { AttrID = _poolInfo.attrId, Value = _value, Percent = _percent }
                        if not _washDic:ContainsKey(_index) then
                            _washDic:Add(_index, _data)
                        end
                    else
                        if not _washDic:ContainsKey(_index) then
                            _washDic:Add(index, { AttrID = washLine.id, Value = washLine.value, Percent = washLine.per })
                        end
                    end
                    --_washDic:Add(_v.id, {Value = _v.value, Percent = _v.per})
                end
            end
            local _equipItem = nil
            if equipId ~= nil and equipId ~= 0 then
                _equipItem = LuaItemBase.CreateItemBase(equipId)
            end
            _equipItem.IsBind = info.equipInfoList[i].isBind == 1
            self.NormalEquipList:Add({ EquipItem = _equipItem, Id = equipId, Lv = info.equipInfoList[i].level, WashDic = _washDic, GemList = _gemList, JadeList = _jadeList, RefLv = _refLv, SuitID = info.equipInfoList[i].suitId })
        end
    end
    GameCenter.EquipmentSuitSystem:CalculateRankSuit(self.NormalEquipList)
    self.XianJiaEquipDic:Clear()
    if info.immortalEquipInfoList ~= nil then
        for i = 1, #info.immortalEquipInfoList do
            local equipInfo = info.immortalEquipInfoList[i]
            self.XianJiaEquipDic:Add(equipInfo.suitKey, equipInfo.immortalEquipIds)
        end
    end
end
return RankPlayerInfo