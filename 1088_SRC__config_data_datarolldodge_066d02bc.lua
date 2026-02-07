--The file is automatically generated, please do not modify it manually. From the data file:RollDodge
local L_CompressMaxColumn = 1
local L_CompressData = {
2199453079984001,
--1,700,5000,400,2000,,
2199453079984322,
--2,710,5000,400,2000,,
2199453079984643,
--3,720,5000,400,2000,,
2199453079984964,
--4,730,5000,400,2000,,
2199453079985285,
--5,740,5000,400,2000,,
2199453079985606,
--6,750,5000,400,2000,,
2199453079985927,
--7,760,5000,400,2000,,
2199453079986248,
--8,770,5000,400,2000,,
2199453079986569,
--9,780,5000,400,2000,,
2199453079987210,
--10,800,5000,400,2000,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,}
local L_NamesByNum = {
   Level = 1,
   MaxDis = 2,
   CdTime = 3,
   ExecuteTime = 4,
   SuperArmorTime = 5,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   Level = 0,
   MaxDis = 1,
   CdTime = 2,
   ExecuteTime = 3,
   SuperArmorTime = 4,
}
--local L_ColumnUseBitCount = {5,11,14,10,12,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,5,16,30,40,}
--local L_AndDataList = {15,1023,8191,511,2047,}
local L_ColumnShiftAndList = {1,0,15,1,5,1023,1,16,8191,1,30,511,1,40,2047,}
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
    Count = 10
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
