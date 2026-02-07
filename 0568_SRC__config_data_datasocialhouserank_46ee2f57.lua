--The file is automatically generated, please do not modify it manually. From the data file:social_house_rank
local L_CompressMaxColumn = 1
local L_CompressData = {
879632925652935269,
--101,1,1_1,10001_1;10002_2;10003_3,50001,,
879632925951165030,
--102,1,2_2,10001_1;10002_2;10003_2,50001,,
879632926219616871,
--103,1,3_3,10001_1;10002_2;10003_1,50001,,
879632926780453480,
--104,1,4_10,10001_1;10002_2,50001,,
879632927317332585,
--105,1,10_20,10001_1;10002_1,50001,,
879629327597875818,
--106,1,20_999,10001_1,50001,,
1055554786097095881,
--201,2,1_1,10001_1;10002_2;10003_3,60001,,
1055554786395325642,
--202,2,2_2,10001_1;10002_2;10003_2,60001,,
1055554786663777483,
--203,2,3_3,10001_1;10002_2;10003_1,60001,,
1055554787224614092,
--204,2,4_10,10001_1;10002_2,60001,,
1055554787761493197,
--205,2,10_20,10001_1;10002_1,60001,,
1055551188042036430,
--206,2,20_999,10001_1,60001,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[201]=7,[202]=8,[203]=9,[204]=10,[205]=11,[206]=12,}
local L_NamesByNum = {
   ID = 1,
   Turn = 2,
   Showreward = 5,
}
local L_NamesByString = {
   Rank = 3,
   Reward = 4,
}
local L_ColNameIndexs = {
   ID = 0,
   Turn = 1,
   Rank = 2,
   Reward = 3,
   Showreward = 4,
}
--local L_ColumnUseBitCount = {9,3,16,16,17,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,9,12,28,44,}
--local L_AndDataList = {255,3,32767,32767,65535,}
local L_ColumnShiftAndList = {1,0,255,1,9,3,1,12,32767,1,28,32767,1,44,65535,}
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
    Count = 12
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
