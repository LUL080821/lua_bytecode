--The file is automatically generated, please do not modify it manually. From the data file:on_hook_c
local L_CompressMaxColumn = 1
local L_CompressData = {
27526760692673,
--1,经验药剂,1099,1,200,,
726160571400,
--8,升仙令加成,1098,1,5,,
3341805116618,
--10,神品手镯加成,2124,1,24,,
3341800922283,
--11,神品耳环加成,2123,1,24,,
5536511360102,
--6,法宝核心,1095,1,40,,
4601871429,
--5,世界等级,1097,0,,,
}
local L_MainKeyDic = {
[1]=1,[8]=2,[10]=3,[11]=4,[6]=5,[5]=6,}
local L_NamesByNum = {
   Id = 1,
   Picture = 3,
   Extend = 4,
   MaxProgress = 5,
}
local L_NamesByString = {
   Describe = 2,
}
local L_ColNameIndexs = {
   Id = 0,
   Describe = 1,
   Picture = 2,
   Extend = 3,
   MaxProgress = 4,
}
--local L_ColumnUseBitCount = {5,17,13,2,9,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,5,22,35,37,}
--local L_AndDataList = {15,65535,4095,1,255,}
local L_ColumnShiftAndList = {1,0,15,1,5,65535,1,22,4095,1,35,1,1,37,255,}
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
    Count = 6
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
