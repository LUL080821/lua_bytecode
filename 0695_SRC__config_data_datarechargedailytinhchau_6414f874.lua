--The file is automatically generated, please do not modify it manually. From the data file:recharge_daily_tinhchau
local L_CompressMaxColumn = 1
local L_CompressData = {
93025511009637,
--101,1,17021_1_1_9,6307348_1,1,1,,
93025540609383,
--103,1,17006_1_1_9,6307348_1,1,1,,
92232307787112,
--104,1,17044_1_1_9,6307349_1,1,1,,
92232039349609,
--105,1,17045_1_1_9,6307350_1,1,1,,
}
local L_MainKeyDic = {
[101]=1,[103]=2,[104]=3,[105]=4,}
local L_NamesByNum = {
   ID = 1,
   Times = 2,
   ExchangeLimit = 5,
   IfEnd = 6,
}
local L_NamesByString = {
   Reward = 3,
   Need = 4,
}
local L_ColNameIndexs = {
   ID = 0,
   Times = 1,
   Reward = 2,
   Need = 3,
   ExchangeLimit = 4,
   IfEnd = 5,
}
--local L_ColumnUseBitCount = {8,2,17,17,2,2,}
--local L_ColumnList = {1,1,1,1,1,1,}
--local L_ShiftDataList = {0,8,10,27,44,46,}
--local L_AndDataList = {127,1,65535,65535,1,1,}
local L_ColumnShiftAndList = {1,0,127,1,8,1,1,10,65535,1,27,65535,1,44,1,1,46,1,}
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
