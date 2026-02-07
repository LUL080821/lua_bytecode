------------------------------------------------
-- Author: 
-- Date: 2019-06-11
-- File: EquipmentSuitSystem.lua
-- Module: EquipmentSuitSystem
-- Description: Set of system code
------------------------------------------------

local EquipmentSuitData = require "Logic.EquipmentSuit.EquipmentSuitData";
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;

local EquipmentSuitSystem = {
    -- Is it necessary to detect red dots
    IsCheckRedPoint = false,
    -- Configuration data
    CfgTable = Dictionary:New(),
    -- Minimum requirements for set forging for each part
    LowestNeedCfgs = Dictionary:New(),
};

-- load
function EquipmentSuitSystem:Initialize()
    self.IsCheckRedPoint = false;
    self.CfgTable:Clear();
    self.LowestNeedCfgs:Clear();

    -- CUSTOM - thay đổi tổng TB từ Nhẫn qua Túi Thơm
    local _equipTypeCount = EquipmentType.Pendant;
    -- CUSTOM - thay đổi tổng TB từ Nhẫn qua Túi Thơm
    -- Note that this traversal is not traversal in table order
    DataConfig.DataEquipSuit:Foreach(function(k, v)
        local _suitData = EquipmentSuitData:New(v);
        self.CfgTable:Add(k, _suitData);

        for i = 0, _equipTypeCount do
            if _suitData.NeedParts:Contains(i) then
                local _partDic = nil;
                if self.LowestNeedCfgs:ContainsKey(i) then
                    _partDic = self.LowestNeedCfgs[i];
                else
                    _partDic = Dictionary:New();
                    self.LowestNeedCfgs:Add(i, _partDic);
                end
                local _minQua = _suitData.NeedQuality;
                local _minStar = _suitData.NeedDiamondsCount;
                local _minDegree = _suitData.NeedEquipDegrees[1];
                if _partDic:ContainsKey(_suitData.Cfg.Level) then
                    local _curData = _partDic[_suitData.Cfg.Level];
                    if _minQua > _curData[1] then
                        _minQua = _curData[1];
                    end
                    if _minStar > _curData[2] then
                        _minStar = _curData[2];
                    end

                    if _minDegree > _curData[3] then
                        _minDegree = _curData[3];
                    end
                end
                _partDic[_suitData.Cfg.Level] = {_minQua, _minStar, _minDegree};
            end
        end
    end);

    -- Register equipment bar refresh event
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_EQUIPMENTFORM_ITEM_UPDATE, self.OnEquipBagUpdate, self);
end

-- uninstall
function EquipmentSuitSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_EQUIPMENTFORM_ITEM_UPDATE, self.OnEquipBagUpdate, self);
end

-- Find configuration
function EquipmentSuitSystem:FindCfg(suitId)
    return self.CfgTable:Get(suitId);
end

-- renew
function EquipmentSuitSystem:Update(dt)
    if self.IsCheckRedPoint == true then
        self:CheckRedPoint();
    end
    self.IsCheckRedPoint = false;
end

-- Get set configuration
function EquipmentSuitSystem:GetEquipSuitCfgData(equipCfg, suitLevel)
    if equipCfg == nil then
        return nil;
    end
    local _result = nil;
    for k,v in pairs(self.CfgTable) do
        -- Judgment level
        if v.Cfg.Level == suitLevel then
            -- Judgment order
            -- CUSTOM - bỏ qua đk check Bậc
            -- if v.NeedEquipDegrees:Contains(equipCfg.Grade) then
            -- CUSTOM - bỏ qua đk check Bậc
                -- Judge quality
                if equipCfg.Quality >= v.NeedQuality then
                    -- Determine the number of diamonds
                    if equipCfg.DiamondNumber >= v.NeedDiamondsCount then
                        -- Judge career
                        if v:CheckOcc(equipCfg.Gender) then
                            -- Judgment location
                            if v.NeedParts:Contains(equipCfg.Part) then
                                _result = v;
                                break;
                            end
                        end
                    end
                end
            -- CUSTOM - bỏ qua đk check Bậc
            -- end
            -- CUSTOM - bỏ qua đk check Bậc
        end
    end
    return _result;
end

-- Get a list of sets for a piece of equipment
function EquipmentSuitSystem:GetEquipSuitCfgList(equipCfg)
    if equipCfg == nil then
        return nil;
    end
    local _result = List:New();
    for k,v in pairs(self.CfgTable) do
        -- Judgment order
        -- CUSTOM - bỏ qua đk check Bậc
        -- if v.NeedEquipDegrees:Contains(equipCfg.Grade) then
        -- CUSTOM - bỏ qua đk check Bậc
            -- Judge quality
            if equipCfg.Quality >= v.NeedQuality then
                -- Determine the number of diamonds
                if equipCfg.DiamondNumber >= v.NeedDiamondsCount then
                    -- Judge career
                    if v:CheckOcc(equipCfg.Gender) then
                        -- Judgment location
                        if v.NeedParts:Contains(equipCfg.Part) then
                            _result:Add(v);
                        end
                    end
                end
            end
        -- CUSTOM - bỏ qua đk check Bậc
        -- end
        -- CUSTOM - bỏ qua đk check Bậc
    end
    _result:Sort(function(a, b)
            return a.Cfg.Level < b.Cfg.Level;
        end);
    return _result;
end

-- Obtain the minimum requirement for a certain equipment component at a certain level
function EquipmentSuitSystem:FindLowestNeed(part, level)
    return self.LowestNeedCfgs[part][level];
end

-- Get a set that only meets the order of a certain equipment
function EquipmentSuitSystem:GetSuitByGrade(equipCfg, suitLevel)
    if equipCfg == nil then
        return nil;
    end
    local _result = nil;
    for k,v in pairs(self.CfgTable) do
        -- Judgment level
        if v.Cfg.Level == suitLevel then
            if v.NeedParts:Contains(equipCfg.Part) then
                -- Judgment order
                -- CUSTOM - bỏ qua đk check Bậc
                -- if v.NeedEquipDegrees:Contains(equipCfg.Grade) then
                -- CUSTOM - bỏ qua đk check Bậc
                    if v:CheckOcc(equipCfg.Gender) then
                        _result = v;
                    end
                -- CUSTOM - bỏ qua đk check Bậc
                -- end
                -- CUSTOM - bỏ qua đk check Bậc
            end
        end
    end
    return _result;
end

-- Detect red dots
function EquipmentSuitSystem:CheckRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.EquipSuitLevel1);
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.EquipSuitLevel2);
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.EquipSuitLevel3);
    local _cshapList = GameCenter.EquipmentSystem:GetCurDressNormalEquip();
    local _ddressList = List:New(_cshapList);
    local _equipCount = #_ddressList;
    for i = 1, _equipCount do
        local _equip = _ddressList[i];
        local _equipCfg = DataConfig.DataEquip[_equip.CfgID];
        if _equipCfg ~= nil then
            local _curSuitCfg = self:FindCfg(_equip.SuitID);
            local _nextSuitCfg = nil;
            if _curSuitCfg ~= nil then
                _nextSuitCfg = self:GetEquipSuitCfgData(_equipCfg, _curSuitCfg.Cfg.Level + 1);
            else
                _nextSuitCfg = self:GetEquipSuitCfgData(_equipCfg, 1);
            end
    
            if _nextSuitCfg ~= nil then
                local _needItems = _nextSuitCfg.NeedItems:Get(_equipCfg.Part);
                if _needItems ~= nil then
                    -- Item Conditions
                    local _conditions = List:New();
                    for j = 1, #_needItems do
                        _conditions:Add(RedPointItemCondition(_needItems[j][1], _needItems[j][2]));
                    end
                    -- Calling the Lua special conditional interface
                    if _nextSuitCfg.Cfg.Level == 1 then
                        -- CUSTOM -- fix lại logic hiển thị RedPoint cho 3 nút tabs
                        --GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel1, _equipCfg.Part, _conditions);
                        if _equipCfg.Part == EquipmentType.Helmet or _equipCfg.Part == EquipmentType.Necklace or _equipCfg.Part == EquipmentType.FingerRing then
                            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel1, _equipCfg.Part, _conditions);
                        end
                        if _equipCfg.Part == EquipmentType.Clothes or _equipCfg.Part == EquipmentType.Sachet or _equipCfg.Part == EquipmentType.Pendant then
                            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel2, _equipCfg.Part, _conditions);
                        end
                        if _equipCfg.Part == EquipmentType.Belt or _equipCfg.Part == EquipmentType.LegGuard or _equipCfg.Part == EquipmentType.Shoe then
                            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel3, _equipCfg.Part, _conditions);
                        end
                        -- CUSTOM -- fix lại logic hiển thị RedPoint cho 3 nút tabs
                    elseif _nextSuitCfg.Cfg.Level == 2 then
                        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel2, _equipCfg.Part, _conditions);
                    elseif _nextSuitCfg.Cfg.Level == 3 then
                        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.EquipSuitLevel3, _equipCfg.Part, _conditions);
                    end
                end
            end
        end
    end
    -- Refresh the interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_EQUIPSUIT_PAGE);
end

-- Calculation ranking set
function EquipmentSuitSystem:CalculateRankSuit(rankEquipList)
    local rankEquipList = rankEquipList;
    local _equipCount = #rankEquipList;
    -- Current set data, Dictionary<part, List<>>
    local _equipSuitTable = Dictionary:New();
    for i = 1, _equipCount do
        local _equip = rankEquipList[i];
        _equip.SuitData = {}
        -- Clear out the number of set activations
        _equip.SuitData.ActiveSuitNums = List:New()
        _equip.SuitData.ActiveSuitIds = List:New()
        _equip.SuitData.SuitID = _equip.SuitID
        local _equipCfg = DataConfig.DataEquip[_equip.Id];
        local _suitCfg = self:FindCfg(_equip.SuitID);
        if _suitCfg ~= nil then
            local _suitTable = _equipSuitTable:Get(_suitCfg.Cfg.NeedParts);
            if _suitTable == nil then
                _suitTable = List:New();
                _equipSuitTable:Add(_suitCfg.Cfg.NeedParts, _suitTable);
            end
            _suitTable:Add({equip = _equip, equipCfg = _equipCfg, suitCfg = _suitCfg});
        else
            _equip.SuitData.CurSuitEquipCount = 0;
            _equip.SuitData.CurLevelSuitEquipCount = 0;
        end
    end
    local _sortFunc1 = function(a, b)
        return a.equipCfg.Grade > b.equipCfg.Grade;
    end;
    for sk, sv in pairs(_equipSuitTable) do
        local _count = #sv;
        local _levelEquipCount = Dictionary:New();
        for i = 1, _count do
            local _curLevel = sv[i].suitCfg.Cfg.Level;
            local _curCount = _levelEquipCount[_curLevel];
            if _curCount == nil then
                _curCount = 1;
            else
                _curCount = _curCount + 1;
            end
            _levelEquipCount[_curLevel] = _curCount;
        end
        local _levelTable = {};
        for i = 1, _count do
            local _curLevel = sv[i].suitCfg.Cfg.Level;
            sv[i].equip.SuitData.CurSuitEquipCount = _count;
            sv[i].equip.SuitData.CurLevelSuitEquipCount = _levelEquipCount[_curLevel];
            for j = _curLevel, 1, -1 do
                local _levelList = _levelTable[j];
                if _levelList == nil then
                    _levelList = List:New();
                    _levelTable[j] = _levelList;
                end
                _levelList:Add(sv[i]);
            end
        end
        local _find1 = false;
        local _find2 = false;
        -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
        local _find3 = false;
        -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
        local _find4 = false;
        local _find6 = false;
        local _activeGrades = {};
        for i = #_levelTable, 1, -1 do
            _levelTable[i]:Sort(_sortFunc1);
            local _levels = _levelTable[i];
            local _levelCount = #_levelTable[i];
            if _find1 == false and _levelCount >= 1 then
                _find1 = true;
                _levels[1].equip.SuitData.ActiveSuitNums:Add(1);
                _levels[1].equip.SuitData.ActiveSuitIds:Add(_levels[1].suitCfg.ID);
                _activeGrades[1] = {_levels[1].equipCfg.Grade, _levels[1].suitCfg};
            end
            if _find2 == false and _levelCount >= 2 then
                _find2 = true;
                local _activeLevel = 65535;
                for j = 1, 2 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end

                local _activeSuit = self:GetEquipSuitCfgData(_levels[2].equipCfg, _activeLevel);
                for j = 1, 2 do
                    _levels[j].equip.SuitData.ActiveSuitNums:Add(2);
                    _levels[j].equip.SuitData.ActiveSuitIds:Add(_activeSuit.ID);
                end
                _activeGrades[2] = {_levels[2].equipCfg.Grade, _activeSuit};
            end

            -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
            if _find3 == false and _levelCount >= 3 then
                _find3 = true;
                local _activeLevel = 65535;
                for j = 1, 3 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end

                local _activeSuit = self:GetEquipSuitCfgData(_levels[3].equipCfg, _activeLevel);
                for j = 1, 3 do
                    _levels[j].equip.SuitData.ActiveSuitNums:Add(3);
                    _levels[j].equip.SuitData.ActiveSuitIds:Add(_activeSuit.ID);
                end
                _activeGrades[3] = {_levels[3].equipCfg.Grade, _activeSuit};
            end
            -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
            
            if _find4 == false and _levelCount >= 4 then
                _find4 = true;
                local _activeLevel = 65535;
                for j = 1, 4 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end
                local _activeSuit = self:GetEquipSuitCfgData(_levels[4].equipCfg, _activeLevel);
                if _activeSuit ~= nil then
                    for j = 1, 4 do
                        _levels[j].equip.SuitData.ActiveSuitNums:Add(4);
                        _levels[j].equip.SuitData.ActiveSuitIds:Add(_activeSuit.ID);
                    end
                    _activeGrades[4] = {_levels[4].equipCfg.Grade, _activeSuit};
                end
            end
            if _find6 == false and _levelCount >= 6 then
                _find6 = true;
                local _activeLevel = 65535;
                for j = 1, 6 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end
                local _activeSuit = self:GetEquipSuitCfgData(_levels[6].equipCfg, _activeLevel);
                if _activeSuit ~= nil then
                    for j = 1, 6 do
                        _levels[j].equip.SuitData.ActiveSuitNums:Add(6);
                        _levels[j].equip.SuitData.ActiveSuitIds:Add(_activeSuit.ID);
                    end
                    _activeGrades[6] = {_levels[6].equipCfg.Grade, _activeSuit};
                end
            end
        end
        for num, v in pairs(_activeGrades) do
            for i = 1, _count do
                if sv[i].equipCfg.Grade == v[1] and sv[i].suitCfg.Cfg.Level >= v[2].Cfg.Level then
                    sv[i].equip.SuitData.ActiveSuitNums:Add(num);
                    sv[i].equip.SuitData.ActiveSuitIds:Add(v[2].ID);
                end
            end
        end
    end
end

-- Equipment bar refresh event
function EquipmentSuitSystem:OnEquipBagUpdate(obj, sender)
    local _cshapList = GameCenter.EquipmentSystem:GetCurDressNormalEquip();
    local _ddressList = List:New(_cshapList);
    local _equipCount = #_ddressList;
    -- Current set data, Dictionary<part, List<>>
    local _equipSuitTable = Dictionary:New();
    for i = 1, _equipCount do
        local _equip = _ddressList[i];
        -- Clear out the number of set activations
        _equip:ClearSuitActiveNum();
        local _equipCfg = DataConfig.DataEquip[_equip.CfgID];
        local _suitCfg = self:FindCfg(_equip.SuitID);
        if _suitCfg ~= nil then
            local _suitTable = _equipSuitTable:Get(_suitCfg.Cfg.NeedParts);
            if _suitTable == nil then
                _suitTable = List:New();
                _equipSuitTable:Add(_suitCfg.Cfg.NeedParts, _suitTable);
            end
            _suitTable:Add({equip = _equip, equipCfg = _equipCfg, suitCfg = _suitCfg});
        else
            _equip.CurSuitEquipCount = 0;
            _equip.CurLevelSuitEquipCount = 0;
        end
    end

    local _sortFunc1 = function(a, b)
        return a.equipCfg.Grade > b.equipCfg.Grade;
    end;
    for sk, sv in pairs(_equipSuitTable) do
        local _count = #sv;
        local _levelEquipCount = Dictionary:New();
        for i = 1, _count do
            local _curLevel = sv[i].suitCfg.Cfg.Level;
            local _curCount = _levelEquipCount[_curLevel];
            if _curCount == nil then
                _curCount = 1;
            else
                _curCount = _curCount + 1;
            end
            _levelEquipCount[_curLevel] = _curCount;
        end

        local _levelTable = {};
        for i = 1, _count do
            local _curLevel = sv[i].suitCfg.Cfg.Level;
            sv[i].equip.CurSuitEquipCount = _count;
            sv[i].equip.CurLevelSuitEquipCount = _levelEquipCount[_curLevel];
            for j = _curLevel, 1, -1 do
                local _levelList = _levelTable[j];
                if _levelList == nil then
                    _levelList = List:New();
                    _levelTable[j] = _levelList;
                end
                _levelList:Add(sv[i]);
            end
        end

        local _find1 = false;
        local _find2 = false;
        -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
        local _find3 = false;
        -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
        local _find4 = false;
        local _find6 = false;
        local _activeGrades = {};
        for i = #_levelTable, 1, -1 do
            _levelTable[i]:Sort(_sortFunc1);

            local _levels = _levelTable[i];
            local _levelCount = #_levelTable[i];
            if _find1 == false and _levelCount >= 1 then
                _find1 = true;
                _levels[1].equip:AddSuitActiveNum(1, _levels[1].suitCfg.ID);
                _activeGrades[1] = {_levels[1].equipCfg.Grade, _levels[1].suitCfg};
            end

            if _find2 == false and _levelCount >= 2 then
                _find2 = true;
                local _activeLevel = 65535;
                for j = 1, 2 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end

                local _activeSuit = self:GetEquipSuitCfgData(_levels[2].equipCfg, _activeLevel);
                for j = 1, 2 do
                    _levels[j].equip:AddSuitActiveNum(2, _activeSuit.ID);
                end
                _activeGrades[2] = {_levels[2].equipCfg.Grade, _activeSuit};
            end

            -- CUSTOM - thêm thuộc tính kích hoạt 3 TB
            if _find3 == false and _levelCount >= 3 then
                _find3 = true;
                local _activeLevel = 65535;
                for j = 1, 3 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end

                local _activeSuit = self:GetEquipSuitCfgData(_levels[3].equipCfg, _activeLevel);
                for j = 1, 3 do
                    _levels[j].equip:AddSuitActiveNum(3, _activeSuit.ID);
                end
                _activeGrades[3] = {_levels[3].equipCfg.Grade, _activeSuit};
            end
            -- CUSTOM - thêm thuộc tính kích hoạt 3 TB

            if _find4 == false and _levelCount >= 4 then
                _find4 = true;
                local _activeLevel = 65535;
                for j = 1, 4 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end
                local _activeSuit = self:GetEquipSuitCfgData(_levels[4].equipCfg, _activeLevel);
                if _activeSuit ~= nil then
                    for j = 1, 4 do
                        _levels[j].equip:AddSuitActiveNum(4, _activeSuit.ID);
                    end
                    _activeGrades[4] = {_levels[4].equipCfg.Grade, _activeSuit};
                end
            end

            if _find6 == false and _levelCount >= 6 then
                _find6 = true;
                local _activeLevel = 65535;
                for j = 1, 6 do
                    if _levels[j].suitCfg.Cfg.Level < _activeLevel then
                        _activeLevel = _levels[j].suitCfg.Cfg.Level;
                    end
                end
                local _activeSuit = self:GetEquipSuitCfgData(_levels[6].equipCfg, _activeLevel);
                if _activeSuit ~= nil then
                    for j = 1, 6 do
                        _levels[j].equip:AddSuitActiveNum(6, _activeSuit.ID);
                    end
                    _activeGrades[6] = {_levels[6].equipCfg.Grade, _activeSuit};
                end
            end
        end

        for num, v in pairs(_activeGrades) do
            for i = 1, _count do
                if sv[i].equipCfg.Grade == v[1] and sv[i].suitCfg.Cfg.Level >= v[2].Cfg.Level then
                    sv[i].equip:AddSuitActiveNum(num, v[2].ID);
                end
            end
        end
    end
    self.IsCheckRedPoint = true;
end

-- Forging suit returns
function EquipmentSuitSystem:ResEquipSuit(result)
    if result.state == 0 then
        self:OnEquipBagUpdate(nil, nil);
    end
end

return EquipmentSuitSystem;