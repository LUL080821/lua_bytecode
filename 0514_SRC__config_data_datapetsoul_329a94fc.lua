--The file is automatically generated, please do not modify it manually. From the data file:pet_soul
local L_CompressMaxColumn = 2
local L_CompressData = {
248691442164897,40203,
--1,10,210,16196,1_79;2_1880,神佑魂珠,,
249138119025826,40207,
--2,10,210,16197,1_83;3_58,狂暴魂珠,,
249584795886755,40210,
--3,10,210,16198,2_2506;3_58,噬骨魂珠,,
250031472747684,40213,
--4,10,210,16199,1_71;4_55,防护魂珠,,
250478149608613,40216,
--5,10,210,16200,2_1880;4_61,金刚魂珠,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,}
local L_NamesByNum = {
   Id = 1,
   Stage = 2,
   ConsumptionMax = 3,
   Consume = 4,
}
local L_NamesByString = {
   Attribute = 5,
   Name = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Stage = 1,
   ConsumptionMax = 2,
   Consume = 3,
   Attribute = 4,
   Name = 5,
}
--local L_ColumnUseBitCount = {4,5,9,15,16,17,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,4,9,18,33,0,}
--local L_AndDataList = {7,15,255,16383,32767,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,15,1,9,255,1,18,16383,1,33,32767,2,0,65535,}
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
    Count = 5
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
