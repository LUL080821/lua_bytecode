--The file is automatically generated, please do not modify it manually. From the data file:limit_mystery_shop
local L_CompressMaxColumn = 2
local L_CompressData = {
5095843171547361,521058423241,
--1,2003454_1_1_9;12_10000_1_9,银元宝1万+5阶粉色戒指,1_9999,-1_1,43200,30,,
5095843184130370,538238292425,
--2,1011_3_1_9;1034_1_1_9,活跃50点药剂+boss卷3张,1_9999,-1_1,43200,31,,
5095843171547363,521058423241,
--3,2003454_1_1_9;12_10000_1_9,银元宝1万+5阶粉色戒指,1_9999,-1_1,43200,30,,
5095843184130372,538238292425,
--4,1011_3_1_9;1034_1_1_9,活跃50点药剂+boss卷3张,1_9999,-1_1,43200,31,,
5095843171547365,521058423241,
--5,2003454_1_1_9;12_10000_1_9,银元宝1万+5阶粉色戒指,1_9999,-1_1,43200,30,,
5095843184130374,538238292425,
--6,1011_3_1_9;1034_1_1_9,活跃50点药剂+boss卷3张,1_9999,-1_1,43200,31,,
5095843171547367,521058423241,
--7,2003454_1_1_9;12_10000_1_9,银元宝1万+5阶粉色戒指,1_9999,-1_1,43200,30,,
5095843184130376,538238292425,
--8,1011_3_1_9;1034_1_1_9,活跃50点药剂+boss卷3张,1_9999,-1_1,43200,31,,
5095843171547369,521058423241,
--9,2003454_1_1_9;12_10000_1_9,银元宝1万+5阶粉色戒指,1_9999,-1_1,43200,30,,
5095843184130378,538238292425,
--10,1011_3_1_9;1034_1_1_9,活跃50点药剂+boss卷3张,1_9999,-1_1,43200,31,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,}
local L_NamesByNum = {
   Id = 1,
   Time = 6,
   Group = 7,
}
local L_NamesByString = {
   Reward = 2,
   Desc = 3,
   Condition = 4,
   Price = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   Reward = 1,
   Desc = 2,
   Condition = 3,
   Price = 4,
   Time = 5,
   Group = 6,
}
--local L_ColumnUseBitCount = {5,17,17,15,17,17,6,}
--local L_ColumnList = {1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,5,22,39,0,17,34,}
--local L_AndDataList = {15,65535,65535,16383,65535,65535,31,}
local L_ColumnShiftAndList = {1,0,15,1,5,65535,1,22,65535,1,39,16383,2,0,65535,2,17,65535,2,34,31,}
local L_ColNum = 7;
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
