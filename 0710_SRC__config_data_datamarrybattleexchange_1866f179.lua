--The file is automatically generated, please do not modify it manually. From the data file:marry_battle_exchange
local L_CompressMaxColumn = 2
local L_CompressData = {
25692185033320961,1,
--1,10408,9,37_2000,1,1,,
25692185033679618,1,
--2,16012,9,37_2000,1,1,,
25692185033679683,1,
--3,16013,9,37_2000,1,1,,
25692016721599236,1,
--4,1132,0,37_1000,1,1,,
25692016734182213,1,
--5,1133,1,37_1000,1,1,,
25692016721599366,1,
--6,1134,0,37_1000,1,1,,
25692016734182343,1,
--7,1135,1,37_1000,1,1,,
25692016736283528,1,
--8,1198,2,37_1000,1,1,,
25692032022424521,1,
--9,1199,3,37_1000,1,1,,
25692016736283658,1,
--10,1200,2,37_1000,1,1,,
25692032022424651,1,
--11,1201,3,37_1000,1,1,,
25691942251746444,1,
--12,1362,0_2,37_800,1,1,,
25691942585193677,1,
--13,1363,1_3,37_800,1,1,,
22342660297676046,1,
--14,1364,9,37_500,1,1,,
22342660297676111,1,
--15,1365,9,37_500,1,1,,
25691772716824912,200,
--16,16101,9,37_10,1,200,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,}
local L_NamesByNum = {
   Id = 1,
   ItemID = 2,
   LimitType = 5,
   BuyNum = 6,
}
local L_NamesByString = {
   Occ = 3,
   Pay = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   ItemID = 1,
   Occ = 2,
   Pay = 3,
   LimitType = 4,
   BuyNum = 5,
}
--local L_ColumnUseBitCount = {6,15,16,17,2,9,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,6,21,37,54,0,}
--local L_AndDataList = {31,16383,32767,65535,1,255,}
local L_ColumnShiftAndList = {1,0,31,1,6,16383,1,21,32767,1,37,65535,1,54,1,2,0,255,}
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
    Count = 16
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
