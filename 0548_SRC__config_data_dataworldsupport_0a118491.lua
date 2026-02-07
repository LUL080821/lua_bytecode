--The file is automatically generated, please do not modify it manually. From the data file:World_Support
local L_CompressMaxColumn = 2
local L_CompressData = {
10585903835800001,2839726429808,
--1,1_250,9_100_1500,1030_5,81011_1,81011_1_3,5,10,,
10585903836260146,2839726429808,
--2,251_450,9_100_1500,1030_5,81011_1,81011_1_3,5,10,,
10585903836260179,2839726429808,
--3,451_600,9_100_1500,1030_5,81011_1,81011_1_3,5,10,,
10585903836260212,2839726429808,
--4,601_700,9_100_1500,1030_5,81011_1,81011_1_3,5,10,,
10585903836260229,2839726429808,
--5,701_800,9_100_1500,1030_5,81011_1,81011_1_3,5,10,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,}
local L_NamesByNum = {
   Id = 1,
   MaxTimes = 7,
   ColdTimes = 8,
}
local L_NamesByString = {
   LevelRank = 2,
   PicRes = 3,
   STitleRank = 4,
   STitleItem = 5,
   STitleFight = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   LevelRank = 1,
   PicRes = 2,
   STitleRank = 3,
   STitleItem = 4,
   STitleFight = 5,
   MaxTimes = 6,
   ColdTimes = 7,
}
--local L_ColumnUseBitCount = {4,17,17,17,17,17,4,5,}
--local L_ColumnList = {1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,4,21,38,0,17,34,38,}
--local L_AndDataList = {7,65535,65535,65535,65535,65535,7,15,}
local L_ColumnShiftAndList = {1,0,7,1,4,65535,1,21,65535,1,38,65535,2,0,65535,2,17,65535,2,34,7,2,38,15,}
local L_ColNum = 8;
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
    Count = 5
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
