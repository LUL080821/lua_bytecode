--The file is automatically generated, please do not modify it manually. From the data file:investPeak_Global
local L_CompressMaxColumn = 2
local L_CompressData = {
5629723912575482,38508,
--33430010,3343,0,10,12_500_1,,
11314199028177412,38508,
--33430020,3343,100,20,12_500_1,,
16971186353085062,38508,
--33430150,3343,150,30,12_500_1,,
22628173677992632,38508,
--33430200,3343,200,40,12_500_1,,
28268668328483562,38508,
--33430250,3343,220,50,12_500_1,,
33909162978974492,38508,
--33430300,3343,240,60,12_500_1,,
39549657629465422,38508,
--33430350,3343,260,70,12_500_1,,
45190152279956352,38508,
--33430400,3343,280,80,12_500_1,,
50830646930447282,38508,
--33430450,3343,300,90,12_500_1,,
56471141580938212,38508,
--33430500,3343,320,100,12_500_1,,
62111636231429142,38508,
--33430550,3343,340,110,12_500_1,,
}
local L_MainKeyDic = {
[33430010]=1,[33430020]=2,[33430150]=3,[33430200]=4,[33430250]=5,[33430300]=6,[33430350]=7,[33430400]=8,[33430450]=9,[33430500]=10,[33430550]=11,}
local L_NamesByNum = {
   ID = 1,
   Gear = 2,
   Level = 3,
   Times = 4,
}
local L_NamesByString = {
   Reward = 5,
}
local L_ColNameIndexs = {
   ID = 0,
   Gear = 1,
   Level = 2,
   Times = 3,
   Reward = 4,
}
--local L_ColumnUseBitCount = {26,13,10,8,17,}
--local L_ColumnList = {1,1,1,1,2,}
--local L_ShiftDataList = {0,26,39,49,0,}
--local L_AndDataList = {33554431,4095,511,127,65535,}
local L_ColumnShiftAndList = {1,0,33554431,1,26,4095,1,39,511,1,49,127,2,0,65535,}
local L_ColNum = 5;
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
