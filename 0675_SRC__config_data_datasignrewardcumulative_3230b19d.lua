--The file is automatically generated, please do not modify it manually. From the data file:sign_rewardCumulative
local L_CompressMaxColumn = 1
local L_CompressData = {
161384432743,
--103,1,,3,10002_1_1,,
161388889195,
--107,1,,7,11002_2_1,,
161393280110,
--110,1,,10,16002_2_1,,
161397736562,
--114,1,,14,14002_3_1,,
161402389625,
--121,1,,21,16198_3_1,,
156676015234,
--130,1,2,30,19007_1_1,,
161384433867,
--203,2,,3,10002_1_1,,
161388890319,
--207,2,,7,11002_2_1,,
161393281234,
--210,2,,10,16002_2_1,,
161397737686,
--214,2,,14,14002_3_1,,
161402390749,
--221,2,,21,16198_3_1,,
156676024550,
--230,2,3,30,19007_1_1,,
161384434991,
--303,3,,3,10002_1_1,,
161388891443,
--307,3,,7,11002_2_1,,
161393282358,
--310,3,,10,16002_2_1,,
161397738810,
--314,3,,14,14002_3_1,,
161402391873,
--321,3,,21,16198_3_1,,
156676009290,
--330,3,1,30,19007_1_1,,
}
local L_MainKeyDic = {
[103]=1,[107]=2,[110]=3,[114]=4,[121]=5,[130]=6,[203]=7,[207]=8,[210]=9,[214]=10,[221]=11,[230]=12,[303]=13,[307]=14,[310]=15,
[314]=16,[321]=17,[330]=18,}
local L_NamesByNum = {
   Id = 1,
   Round = 2,
   NextRound = 3,
   Day = 4,
}
local L_NamesByString = {
   Award = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   Round = 1,
   NextRound = 2,
   Day = 3,
   Award = 4,
}
--local L_ColumnUseBitCount = {10,3,3,6,17,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,10,13,16,22,}
--local L_AndDataList = {511,3,3,31,65535,}
local L_ColumnShiftAndList = {1,0,511,1,10,3,1,13,3,1,16,31,1,22,65535,}
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
    Count = 18
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
