--The file is automatically generated, please do not modify it manually. From the data file:recharge_daily
local L_CompressMaxColumn = 1
local L_CompressData = {
230614037038977,
--1,60,1,60,81081_1_1;1059_1_1;16002_1_1;18001_20_1;20001_1_1,,
230618583672195,
--3,300,1,300,81081_2_1;1059_1_1;16002_2_1;18001_40_1;60004_2_1,,
230623277110533,
--5,680,1,680,81081_3_1;1059_1_1;16002_3_1;18001_60_1;60004_2_1,,
230628201242631,
--7,1280,1,1280,81081_4_1;1059_1_1;16002_4_1;18001_80_1;60004_2_1,,
230631217039234,
--2,60,2,60,81005_1_1;1059_1_1;16002_1_1;18001_10_1;21001_1_1,,
230635658814852,
--4,300,2,200,81081_1_1;1021_1_1;16002_2_1;18001_20_1;21001_2_1,,
230640373224710,
--6,680,2,600,1021_1_1;1059_1_1;16002_3_1;18001_30_1;21001_3_1,,
230645297356808,
--8,1280,2,1200,81081_2_1;1021_1_1;16002_4_1;18001_40_1;21001_4_1,,
}
local L_MainKeyDic = {
[1]=1,[3]=2,[5]=3,[7]=4,[2]=5,[4]=6,[6]=7,[8]=8,}
local L_NamesByNum = {
   ID = 1,
   Position = 2,
   Type = 3,
   Money = 4,
}
local L_NamesByString = {
   Award = 5,
}
local L_ColNameIndexs = {
   ID = 0,
   Position = 1,
   Type = 2,
   Money = 3,
   Award = 4,
}
--local L_ColumnUseBitCount = {5,12,3,12,17,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,5,17,20,32,}
--local L_AndDataList = {15,2047,3,2047,65535,}
local L_ColumnShiftAndList = {1,0,15,1,5,2047,1,17,3,1,20,2047,1,32,65535,}
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
    Count = 8
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
