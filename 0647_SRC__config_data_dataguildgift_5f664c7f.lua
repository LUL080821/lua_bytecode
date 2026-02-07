--The file is automatically generated, please do not modify it manually. From the data file:guild_gift
local L_CompressMaxColumn = 2
local L_CompressData = {
416072286346853,12668951944773790,
--101,Rương Bộ Tộc - Sôi nổi,0,3099980,89_100,12_10_2000;60002_1_2000;10001_1_2000;16001_1_2000;3_1000_2000,0,300,1440,,
416072141966537,12668951944793612,
--201,Rương Bộ Tộc - Nhiệm vụ ngày,0,3099979,177_20,12_10_2000;60002_1_2000;10001_1_2000;16001_1_2000;3_1000_2000,0,300,1440,,
}
local L_MainKeyDic = {
[101]=1,[201]=2,}
local L_NamesByNum = {
   ID = 1,
   Type = 3,
   ShowItem = 4,
   RefreshType = 7,
   RefreshTimes = 8,
   InvalidTimes = 9,
}
local L_NamesByString = {
   Name = 2,
   VariableID = 5,
   Reward = 6,
}
local L_ColNameIndexs = {
   ID = 0,
   Name = 1,
   Type = 2,
   ShowItem = 3,
   VariableID = 4,
   Reward = 5,
   RefreshType = 6,
   RefreshTimes = 7,
   InvalidTimes = 8,
}
--local L_ColumnUseBitCount = {9,16,2,23,17,14,2,10,12,}
--local L_ColumnList = {1,1,1,1,2,2,2,2,2,}
--local L_ShiftDataList = {0,9,25,27,0,17,31,33,43,}
--local L_AndDataList = {255,32767,1,4194303,65535,8191,1,511,2047,}
local L_ColumnShiftAndList = {1,0,255,1,9,32767,1,25,1,1,27,4194303,2,0,65535,2,17,8191,2,31,1,2,33,511,2,43,2047,}
local L_ColNum = 9;
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
    Count = 2
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
