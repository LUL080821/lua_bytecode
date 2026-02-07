--The file is automatically generated, please do not modify it manually. From the data file:VipHelp
local L_CompressMaxColumn = 1
local L_CompressData = {
98952193,
--1,0,71023_1_1_1_9;2069_1_1_1_9;2_50_50_0_9,1,,
166060034,
--2,0,1_120_240_0_9;2069_1_1_1_9;2_50_50_0_9,2,,
233167875,
--3,0,1_120_240_0_9;10001_10_10_1_9;2_50_50_0_9,3,,
300275716,
--4,0,1_120_240_0_9;11001_10_10_1_9;2_50_50_0_9,4,,
367383557,
--5,0,1_120_240_0_9;16001_10_10_1_9;2_50_50_0_9,5,,
434491398,
--6,0,1_120_240_0_9;14001_10_10_1_9;2_50_50_0_9,6,,
501599239,
--7,0,1_120_240_0_9;81003_5_5_1_9;2_50_50_0_9,7,,
98945381,
--101,1,2_30_30_0_9;1003_1_1_1_9;3_200000_200000_0_9,1,,
166053222,
--102,1,2_30_30_0_9;10001_10_10_1_9;3_200000_200000_0_9,2,,
233161063,
--103,1,2_30_30_0_9;11001_10_10_1_9;3_200000_200000_0_9,3,,
300268904,
--104,1,2_30_30_0_9;16001_10_10_1_9;3_200000_200000_0_9,4,,
367376745,
--105,1,2_30_30_0_9;2210_1_1_1_9;3_200000_200000_0_9,5,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[101]=8,[102]=9,[103]=10,[104]=11,[105]=12,}
local L_NamesByNum = {
   Id = 1,
   HelpType = 2,
   Day = 4,
}
local L_NamesByString = {
   HelpReward = 3,
}
local L_ColNameIndexs = {
   Id = 0,
   HelpType = 1,
   HelpReward = 2,
   Day = 3,
}
--local L_ColumnUseBitCount = {8,2,16,4,}
--local L_ColumnList = {1,1,1,1,}
--local L_ShiftDataList = {0,8,10,26,}
--local L_AndDataList = {127,1,32767,7,}
local L_ColumnShiftAndList = {1,0,127,1,8,1,1,10,32767,1,26,7,}
local L_ColNum = 4;
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
    Count = 12
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
