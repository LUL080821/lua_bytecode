--The file is automatically generated, please do not modify it manually. From the data file:wash_best
local L_CompressMaxColumn = 1
local L_CompressData = {
6691693302580200,
--1000,0,999999,35_0,1,,
6691693302582249,
--1001,1,999999,35_0,1,,
6691693302584298,
--1002,2,999999,35_0,1,,
6691693302586347,
--1003,3,999999,35_0,1,,
6691693302588396,
--1004,4,999999,35_0,1,,
6691693302590445,
--1005,5,999999,35_0,1,,
6691693302592494,
--1006,6,999999,35_0,1,,
6691693302594543,
--1007,7,999999,35_0,1,,
6691693302596592,
--1008,8,999999,35_0,1,,
6691693302598641,
--1009,9,999999,35_0,1,,
6691693302600690,
--1010,10,999999,35_0,1,,
6691693302602739,
--1011,11,999999,35_0,1,,
6691693302604788,
--1012,12,999999,35_0,1,,
}
local L_MainKeyDic = {
[1000]=1,[1001]=2,[1002]=3,[1003]=4,[1004]=5,[1005]=6,[1006]=7,[1007]=8,[1008]=9,[1009]=10,[1010]=11,[1011]=12,[1012]=13,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Condition = 3,
   LevelLimit = 5,
}
local L_NamesByString = {
   Attribute = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Condition = 2,
   Attribute = 3,
   LevelLimit = 4,
}
--local L_ColumnUseBitCount = {11,5,21,15,2,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,11,16,37,52,}
--local L_AndDataList = {1023,15,1048575,16383,1,}
local L_ColumnShiftAndList = {1,0,1023,1,11,15,1,16,1048575,1,37,16383,1,52,1,}
local L_ColNum = 5;
local L_UseDataK = setmetatable({ },{ __mode = 'k'});
local L_UseDataV = setmetatable({ },{ __mode = 'v'});
local L_UseDataRow = setmetatable({ },{ __mode = 'v'});
local L_IsCache = false;
local mt = {}
local function GetData(row, column)
    local startIndex = (column - 1) * 3
    local _compressData = L_CompressData[row]
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
    Count = 13
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
