--The file is automatically generated, please do not modify it manually. From the data file:Hall_Fame
local L_CompressMaxColumn = 1
local L_CompressData = {
160087537352753,
--1,3,tex_zp_1,1_3_70001_30001;4_10_70002_14991;11_30_70003_7492,,
160091832320114,
--2,7,tex_zp_1,1_3_70011_45018;4_10_70012_22509;11_30_70013_11246,,
160096127287539,
--3,15,tex_zp_1,1_3_70021_67527;4_10_70022_33754;11_30_70023_16864,,
160100422255076,
--4,30,tex_zp_1,1_3_70031_101281;4_10_70032_50637;11_30_70033_25318,,
160104717227733,
--5,365,tex_zp_1,1_3_70041_151944;4_10_70042_75963;11_30_70043_37969,,
160109012205174,
--6,999,tex_zp_1,1_3_70051_227907;4_10_70052_113950;11_30_70053_56966,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   Id = 1,
   Time = 2,
}
local L_NamesByString = {
   PicRes = 3,
   Rank = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   Time = 1,
   PicRes = 2,
   Rank = 3,
}
--local L_ColumnUseBitCount = {4,11,17,17,}
--local L_ColumnList = {1,1,1,1,}
--local L_ShiftDataList = {0,4,15,32,}
--local L_AndDataList = {7,1023,65535,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,1023,1,15,65535,1,32,65535,}
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
    Count = 6
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
