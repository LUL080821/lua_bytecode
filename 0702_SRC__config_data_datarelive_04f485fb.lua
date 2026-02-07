--The file is automatically generated, please do not modify it manually. From the data file:relive
local L_CompressMaxColumn = 2
local L_CompressData = {
544219332641,16384,
--1,1,0,,0_1,0,0,,0,0,,
38674722,16384,
--2,1,2,5000,,,,,,0,,
38674563,16384,
--3,0,1,5000,,,,,,0,,
544219332644,21384,
--4,1,0,,0_1,0,5000,,,0,,
544229572901,32212520473480,
--5,1,2,10000,0_1,0,5000,5000_60000,60000,0,,
54502637830,16384,
--6,0,2,10000,1,0,,,,0,,
33554439,16384,
--7,0,0,0,,0,0,,0,0,,
544229572904,16384,
--8,1,2,10000,0_1,0,0,,,0,,
5497612641517865,16384,
--9,1,2,10000,1,5000,0,,,0,,
544229572906,70368744194048,
--10,1,2,10000,0_1,0,0,,,1,,
3299079112900907,16384,
--11,1,2,10000,0_1,3000,0,,0,0,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,}
local L_NamesByNum = {
   ReliveId = 1,
   ShowKillerName = 2,
   AutoReliveType = 3,
   AutoReliveTime = 4,
   SafeReliveTime = 6,
   SituReliveTime = 7,
   SituReliveRecoveryTime = 9,
   IsSeekHelp = 10,
}
local L_NamesByString = {
   ButtonType = 5,
   SituReliveAddTime = 8,
}
local L_ColNameIndexs = {
   ReliveId = 0,
   ShowKillerName = 1,
   AutoReliveType = 2,
   AutoReliveTime = 3,
   ButtonType = 4,
   SafeReliveTime = 5,
   SituReliveTime = 6,
   SituReliveAddTime = 7,
   SituReliveRecoveryTime = 8,
   IsSeekHelp = 9,
}
--local L_ColumnUseBitCount = {5,2,3,15,15,14,14,15,17,2,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,5,7,10,25,40,0,14,29,46,}
--local L_AndDataList = {15,1,3,16383,16383,8191,8191,16383,65535,1,}
local L_ColumnShiftAndList = {1,0,15,1,5,1,1,7,3,1,10,16383,1,25,16383,1,40,8191,2,0,8191,2,14,16383,2,29,65535,2,46,1,}
local L_ColNum = 10;
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
    Count = 11
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
