--The file is automatically generated, please do not modify it manually. From the data file:week_welfare
local L_CompressMaxColumn = 2
local L_CompressData = {
387196319749553961,22503,
--1,12_200,2100000,当天活跃值达到200,,26_1_1_9,,
387209854676287298,22503,
--2,161_1,2750000,充值任意金额,,26_1_1_9,,
387217314359197523,22503,
--3,7_1,201000,每日登录,,26_1_1_9,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,}
local L_NamesByNum = {
   Id = 1,
   FunctionId = 3,
}
local L_NamesByString = {
   Condition = 2,
   Desc = 4,
   Notice = 5,
   Reward = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Condition = 1,
   FunctionId = 2,
   Desc = 3,
   Notice = 4,
   Reward = 5,
}
--local L_ColumnUseBitCount = {3,16,23,16,2,16,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,3,19,42,58,0,}
--local L_AndDataList = {3,32767,4194303,32767,1,32767,}
local L_ColumnShiftAndList = {1,0,3,1,3,32767,1,19,4194303,1,42,32767,1,58,1,2,0,32767,}
local L_ColNum = 6;
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
