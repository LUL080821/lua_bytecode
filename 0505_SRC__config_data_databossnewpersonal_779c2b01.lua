--The file is automatically generated, please do not modify it manually. From the data file:bossnew_Personal
local L_CompressMaxColumn = 1
local L_CompressData = {
}
local L_MainKeyDic = {
}
local L_NamesByNum = {
   Monsterid = 1,
   EnterLevel = 2,
   Layer = 3,
   Power = 4,
   IfSpecial = 5,
   Size = 6,
   ReviveTime = 8,
   CloneID = 9,
   Mapsid = 10,
}
local L_NamesByString = {
   Drop = 7,
   Pos = 11,
}
local L_ColNameIndexs = {
   Monsterid = 0,
   EnterLevel = 1,
   Layer = 2,
   Power = 3,
   IfSpecial = 4,
   Size = 5,
   Drop = 6,
   ReviveTime = 7,
   CloneID = 8,
   Mapsid = 9,
   Pos = 10,
}
--local L_ColumnUseBitCount = {2,2,2,2,2,2,2,2,2,2,2,}
--local L_ColumnList = {1,1,1,1,1,1,1,1,1,1,1,}
--local L_ShiftDataList = {0,2,4,6,8,10,12,14,16,18,20,}
--local L_AndDataList = {1,1,1,1,1,1,1,1,1,1,1,}
local L_ColumnShiftAndList = {1,0,1,1,2,1,1,4,1,1,6,1,1,8,1,1,10,1,1,12,1,1,14,1,1,16,1,1,18,1,1,20,1,}
local L_ColNum = 11;
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
    Count = 0
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
