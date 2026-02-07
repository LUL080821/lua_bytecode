--The file is automatically generated, please do not modify it manually. From the data file:recharge_daily_superreward
local L_CompressMaxColumn = 1
local L_CompressData = {
275738169701,
--101,1,15013_1_1_9,6,0,1,,
276526536038,
--102,1,19007_1_1_9,12,0,1,,
277348783463,
--103,1,15002_1_1_9,18,0,1,,
278959397224,
--104,1,24020_8_1_9,30,0,1,,
280570010985,
--105,1,24021_8_1_9,42,0,1,,
282985927018,
--106,1,15013_1_1_9,60,0,1,,
287012462955,
--107,1,24022_8_1_9,90,0,1,,
291038995820,
--108,1,24023_8_1_9,120,0,1,,
295065528685,
--109,1,19008_1_1_9,150,0,1,,
377205242222,
--110,1,10117_1_1_9,250,1,1,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[107]=7,[108]=8,[109]=9,[110]=10,}
local L_NamesByNum = {
   ID = 1,
   Times = 2,
   Need = 4,
   IfUltimatereward = 5,
   IfEnd = 6,
}
local L_NamesByString = {
   Reward = 3,
}
local L_ColNameIndexs = {
   ID = 0,
   Times = 1,
   Reward = 2,
   Need = 3,
   IfUltimatereward = 4,
   IfEnd = 5,
}
--local L_ColumnUseBitCount = {8,2,17,9,2,2,}
--local L_ColumnList = {1,1,1,1,1,1,}
--local L_ShiftDataList = {0,8,10,27,36,38,}
--local L_AndDataList = {127,1,65535,255,1,1,}
local L_ColumnShiftAndList = {1,0,127,1,8,1,1,10,65535,1,27,255,1,36,1,1,38,1,}
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
