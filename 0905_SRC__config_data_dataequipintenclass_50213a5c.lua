--The file is automatically generated, please do not modify it manually. From the data file:equip_inten_class
local L_CompressMaxColumn = 1
local L_CompressData = {
722837825,
--1,10,3_60;2_1400;64_35;4_35,,,
643998338,
--2,20,3_90;2_2100;64_52;4_52,,,
643990467,
--3,30,3_120;2_2800;64_70;4_70,,,
637715716,
--4,40,3_150;2_3500;64_88;4_88,,,
629548613,
--5,50,3_180;2_4200;64_105;4_105,,,
629532550,
--6,60,3_210;2_4900;64_123;4_123,,,
629524679,
--7,70,3_240;2_5600;64_140;4_140,,,
629516808,
--8,80,3_270;2_6300;64_158;4_158,,,
598182729,
--9,90,3_300;2_7000;64_175;4_175,,,
596700298,
--10,100,3_330;2_7700;64_193;4_193,,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,}
local L_NamesByNum = {
   Id = 1,
   Level = 2,
}
local L_NamesByString = {
   Value = 3,
   Value1 = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   Level = 1,
   Value = 2,
   Value1 = 3,
}
--local L_ColumnUseBitCount = {5,8,16,2,}
--local L_ColumnList = {1,1,1,1,}
--local L_ShiftDataList = {0,5,13,29,}
--local L_AndDataList = {15,127,32767,1,}
local L_ColumnShiftAndList = {1,0,15,1,5,127,1,13,32767,1,29,1,}
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
