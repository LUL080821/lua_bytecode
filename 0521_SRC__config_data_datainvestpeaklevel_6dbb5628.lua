--The file is automatically generated, please do not modify it manually. From the data file:investPeak_Level
local L_CompressMaxColumn = 1
local L_CompressData = {
72173733031183,
--3343,1,880,1,投资[FF0000FF]880[-]灵玉，十五倍返利#n可领取[FF0000FF]14100[-]绑定元宝,,
72177253068048,
--3344,1,9999,0,投资[FF0000FF]128[-]元，十倍返利#n可领取[FF0000FF]14410[-]绑定元宝,,
72181548035345,
--3345,1,9999,0,投资[FF0000FF]188[-]元，十倍返利#n可领取[FF0000FF]6880[-]绑定元宝,,
}
local L_MainKeyDic = {
[3343]=1,[3344]=2,[3345]=3,}
local L_NamesByNum = {
   InvestLevel = 1,
   MoneyType = 2,
   Diamond = 3,
   IfOpen = 4,
}
local L_NamesByString = {
   Desc = 5,
}
local L_ColNameIndexs = {
   InvestLevel = 0,
   MoneyType = 1,
   Diamond = 2,
   IfOpen = 3,
   Desc = 4,
}
--local L_ColumnUseBitCount = {13,2,15,2,16,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,13,15,30,32,}
--local L_AndDataList = {4095,1,16383,1,32767,}
local L_ColumnShiftAndList = {1,0,4095,1,13,1,1,15,16383,1,30,1,1,32,32767,}
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
