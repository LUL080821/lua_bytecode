--The file is automatically generated, please do not modify it manually. From the data file:week_welfare_reward
local L_CompressMaxColumn = 1
local L_CompressData = {
175922531590280321,
--1,0,1,16_10_1_9_0;50002_1_1_9_1;20004_1_1_9_1;21004_1_1_9_1;81012_1_1_0_300;81013_1_1_1_300,5000,10000,,
703689455100039442,
--2,1,2,1011_1_1_9_0;60011_3_1_9_0;12_2000_1_9_1;20003_1_1_9_1;21003_1_1_9_1,15000,40000,,
879611986632838435,
--3,2,2,20002_1_1_9_0;21002_1_1_9_0,20000,50000,,
8053121157556,
--4,3,3,12_1000_1_9_0;50001_1_1_9_0;10001_2_1_9_0,60000,0,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Num = 3,
   Probability = 5,
   LuckProbability = 6,
}
local L_NamesByString = {
   RewardPool = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Num = 2,
   RewardPool = 3,
   Probability = 4,
   LuckProbability = 5,
}
--local L_ColumnUseBitCount = {4,3,3,17,17,17,}
--local L_ColumnList = {1,1,1,1,1,1,}
--local L_ShiftDataList = {0,4,7,10,27,44,}
--local L_AndDataList = {7,3,3,65535,65535,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,3,1,7,3,1,10,65535,1,27,65535,1,44,65535,}
local L_ColNum = 6;
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
    Count = 4
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
