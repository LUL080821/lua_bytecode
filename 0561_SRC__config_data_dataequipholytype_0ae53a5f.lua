--The file is automatically generated, please do not modify it manually. From the data file:Equip_holy_type
local L_CompressMaxColumn = 4
local L_CompressData = {
2523547411026374905,55059607910,245023135883,56371449091225484,
--1,真火圣装,1,101_102_103_104_105_106_107_108_109_110_111,560,6,110000011,6,210000011,8,7,110000012,210000012,,
2523547455869517858,89419346346,281530357901,56371449628096398,
--2,天雷圣装,9999,112_113_114_115_116_117_118_119_120_121_122,560,10,110000013,10,210000013,12,8,110000014,210000014,,
2523547524589252883,123779084782,283677841551,56371450164967312,
--3,玄冰圣装,9999,123_124_125_126_127_128_129_130_131_132_133,560,14,110000015,14,210000015,16,8,110000016,210000016,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,}
local L_NamesByNum = {
   Id = 1,
   OpenFunction = 3,
   MaxLevel = 5,
   HunNeedDegree = 6,
   HunFashionId = 7,
   PoNeedDegree = 8,
   PoFashionId = 9,
   AwakenDegree = 10,
   AwakenQuality = 11,
   AwakenHunFashionId = 12,
   AwakenPoFashionId = 13,
}
local L_NamesByString = {
   Name = 2,
   PartsList = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   OpenFunction = 2,
   PartsList = 3,
   MaxLevel = 4,
   HunNeedDegree = 5,
   HunFashionId = 6,
   PoNeedDegree = 7,
   PoFashionId = 8,
   AwakenDegree = 9,
   AwakenQuality = 10,
   AwakenHunFashionId = 11,
   AwakenPoFashionId = 12,
}
--local L_ColumnUseBitCount = {3,17,15,17,11,5,28,5,29,6,5,28,29,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,3,3,3,4,4,}
--local L_ShiftDataList = {0,3,20,35,52,0,5,33,0,29,35,0,28,}
--local L_AndDataList = {3,65535,16383,65535,1023,15,134217727,15,268435455,31,15,134217727,268435455,}
local L_ColumnShiftAndList = {1,0,3,1,3,65535,1,20,16383,1,35,65535,1,52,1023,2,0,15,2,5,134217727,2,33,15,3,0,268435455,3,29,31,3,35,15,4,0,134217727,4,28,268435455,}
local L_ColNum = 13;
local L_UseDataK = setmetatable({ },{ __mode = 'k'});
local L_UseDataV = setmetatable({ },{ __mode = 'v'});
local L_UseDataRow = setmetatable({ },{ __mode = 'v'});
local L_IsCache = false;
local mt = {}
local function GetData(row, column)
    local startIndex = (column - 1) * 3
    local _compressData = L_CompressData[(row - 1)*L_CompressMaxColumn+L_ColumnShiftAndList[startIndex + 1]]
    local _tempData = _compressData >> L_ColumnShiftAndList[startIndex + 2]
    local _data = _tempData & L_ColumnShiftAndList[startIndex + 3]
    local _andSign = L_ColumnShiftAndList[startIndex + 3] + 1
    local _isMinus = (_andSign & _tempData) == _andSign
    return _isMinus and -_data or _data;
end

mt.__index = function (t,key)
    local _key = L_UseDataK[t];
    local _row = L_MainKeyDic[_key];
    local _column = L_NamesByNum[key];
    if _column ~= nil then
        if L_IsCache then
            local _data = L_UseDataRow[_row * L_ColNum + _column]
            if not _data then
                _data = GetData(_row, _column)
                L_UseDataRow[_row * L_ColNum + _column] = _data
            end
            return _data
        else
            return GetData(_row, _column)
        end
    end
    _column = L_NamesByString[key]
    if _column ~= nil then
        return StringDefines[GetData(_row, _column)]
    end
    if string.find(key, '_') then
        local _newKey = string.gsub(key, '_', '')
        _column = L_NamesByString[_newKey]
        if _column ~= nil then
           return GetData(_row, _column)
        end
    end
    if key ~= '_OnCopyAfter_' then
        return
    end
end

local M = {
    _CompressData_ = L_CompressData,
    _ColumnShiftAndList_ = L_ColumnShiftAndList,
    _CompressMaxColumn_ = L_CompressMaxColumn,
    _ColumnNameIndexs_ = L_ColNameIndexs,
    Count = 3
}

function M:Foreach(func)
    for i=1,M.Count do
        local _key = GetData(i, 1)
        func(_key, M[_key])
    end
end

function M:ForeachCanBreak(func)
    for i = 1,M.Count do
        local _key = GetData(i, 1)
        if func(_key, M[_key]) then
            break
        end
    end
end

function M:GetByIndex(index)
    return M[GetData(index, 1)];
end

function M:IsContainKey(key)
    return not(not L_MainKeyDic[key]);
end

function M:SetIsCache(isCh)
    L_IsCache = isCh;
end

setmetatable(M, {__index = function(t, key)
    if not L_MainKeyDic[key] then
        return;
    end
    local _t = L_UseDataV[key];
    if not _t then
        _t = setmetatable({}, mt);
        L_UseDataV[key] = _t;
        L_UseDataK[_t] = key;
    end
    return _t
end})

return M
