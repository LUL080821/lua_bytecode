--The file is automatically generated, please do not modify it manually. From the data file:immortal_soul_hunt
local L_CompressMaxColumn = 4
local L_CompressData = {
183439855401737,962286174526158,44921070290262731,56010,
--1,1,-1,1_0;2_5000;3_5000,3_5000;4_3500;6_1000;7_500,10,1_0;2_5000;3_5000,3_5000;4_3500;6_1000;7_500,41_42_43_44_45_46_47,23_36;24_40,25_150,30,3_10000,25_150,,
711205436734290,962286173870793,44921065961476359,56010,
--2,10,-1,1_0;2_5000;3_5000,3_5000;4_3500;6_1000;7_500,40,1_0;2_0;3_10000,3_0;4_0;6_9000;7_1000,41_42_43_44_45_46_47,23_360;24_400,25_1500,30,3_10000,25_150,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,}
local L_NamesByNum = {
   Id = 1,
   Times = 2,
   SpecialTimes = 3,
   SpecialTimes1 = 6,
   ExchangeRanking = 12,
}
local L_NamesByString = {
   TypeProbability = 4,
   QualityProbability = 5,
   SpecialTypeProbability = 7,
   SpecialQualityProbability = 8,
   AddTypeProbability = 9,
   Reward = 10,
   BasicAttributes = 11,
   Exp = 13,
   Type = 14,
}
local L_ColNameIndexs = {
   Id = 0,
   Times = 1,
   SpecialTimes = 2,
   TypeProbability = 3,
   QualityProbability = 4,
   SpecialTimes1 = 5,
   SpecialTypeProbability = 6,
   SpecialQualityProbability = 7,
   AddTypeProbability = 8,
   Reward = 9,
   BasicAttributes = 10,
   ExchangeRanking = 11,
   Exp = 12,
   Type = 13,
}
--local L_ColumnUseBitCount = {3,5,2,17,17,7,17,17,17,17,17,6,17,17,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,3,3,3,3,4,}
--local L_ShiftDataList = {0,3,8,10,27,44,0,17,34,0,17,34,40,0,}
--local L_AndDataList = {3,15,1,65535,65535,63,65535,65535,65535,65535,65535,31,65535,65535,}
local L_ColumnShiftAndList = {1,0,3,1,3,15,1,8,1,1,10,65535,1,27,65535,1,44,63,2,0,65535,2,17,65535,2,34,65535,3,0,65535,3,17,65535,3,34,31,3,40,65535,4,0,65535,}
local L_ColNum = 14;
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
