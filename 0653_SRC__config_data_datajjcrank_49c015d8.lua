--The file is automatically generated, please do not modify it manually. From the data file:JJCRank
local L_CompressMaxColumn = 3
local L_CompressData = {
2490281959409449249,350921047680404,67160,
--1,新手,1001,999999,20,1,20,150,200,300,1017_10;3_50000;9_100,1,,,
2756207268598511970,350953728055572,67153,
--2,青铜,801,1000,50,1,20,100,150,200,1017_10;3_100000;9_200,2_5,,,
2756206408975907235,350986406792340,85967,
--3,白银,501,800,50,1,20,50,50,100,1017_10;3_150000;9_300,6_20,,,
2756205120066288132,351037526312852,85970,
--4,黄金,301,500,50,1,20,30,30,75,1017_10;3_200000;9_400,21_100,,,
2756204260653398629,351088814098004,85973,
--5,白金,101,300,50,1,20,25,25,60,1017_10;3_250000;9_500,101_300,,,
3206563364292131526,351140185769236,85976,
--6,铂金,51,100,100,1,20,20,20,50,1017_20;3_300000;9_600,301_500,,,
3206563149480852263,351191725048468,85979,
--7,钻石,21,50,100,1,20,10,10,50,1017_30;3_350000;9_700,501_800,,,
3206563020610861960,351242929144153,85982,
--8,星耀,11,20,100,1,25,5,11,30,1017_40;3_400000;9_800,801_1000,,,
3206562977650703337,351294032216394,85985,
--9,皇冠,6,10,100,1,10,5,1,4,1017_50;3_450000;9_900,1001_2500,,,
3206562956167478346,351345521492298,85985,
--10,荣耀,2,5,100,1,10,5,1,1,1017_60;3_500000;9_1000,1001_2500,,,
3206562938985512075,351379948339530,85985,
--11,王者,1,1,100,1,10,5,1,5,1017_70;3_550000;9_1100,1001_2500,,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,}
local L_NamesByNum = {
   Id = 1,
   PosMix = 3,
   PosMax = 4,
   Enemy1 = 5,
   Enemy1r = 6,
   Enemy2 = 7,
   Enemy2r = 8,
   Enemy3 = 9,
   Enemy3r = 10,
}
local L_NamesByString = {
   Rankname = 2,
   FirstRewardItem = 11,
   Rank = 12,
   Reward = 13,
}
local L_ColNameIndexs = {
   Id = 0,
   Rankname = 1,
   PosMix = 2,
   PosMax = 3,
   Enemy1 = 4,
   Enemy1r = 5,
   Enemy2 = 6,
   Enemy2r = 7,
   Enemy3 = 8,
   Enemy3r = 9,
   FirstRewardItem = 10,
   Rank = 11,
   Reward = 12,
}
--local L_ColumnUseBitCount = {5,16,11,21,8,2,6,9,9,10,16,16,2,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,2,3,3,}
--local L_ShiftDataList = {0,5,21,32,53,61,0,6,15,24,34,0,16,}
--local L_AndDataList = {15,32767,1023,1048575,127,1,31,255,255,511,32767,32767,1,}
local L_ColumnShiftAndList = {1,0,15,1,5,32767,1,21,1023,1,32,1048575,1,53,127,1,61,1,2,0,31,2,6,255,2,15,255,2,24,511,2,34,32767,3,0,32767,3,16,1,}
local L_ColNum = 13;
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
    Count = 11
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
