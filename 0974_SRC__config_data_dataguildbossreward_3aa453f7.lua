--The file is automatically generated, please do not modify it manually. From the data file:guildBoss_Reward
local L_CompressMaxColumn = 2
local L_CompressData = {
781115715967329,46807488431413452,
--1,1_189,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715967554,46807488431413452,
--2,190_239,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715967651,46807488431413452,
--3,240_299,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715967748,46807488431413452,
--4,300_359,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715967845,46807488431413452,
--5,360_399,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715967942,46807488431413452,
--6,400_469,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968039,46807488431413452,
--7,470_549,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968136,46807488431413452,
--8,550_629,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968233,46807488431413452,
--9,630_709,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968330,46807488431413452,
--10,710_749,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968427,46807488431413452,
--11,750_799,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
781115715968524,46807488431413452,
--12,800_850,1_1;2_3;4_200,100050_111039_111040,1_1_11_125;2_3_11_100;4_200_11_100,60002_1;60020_1;60021_1,5,17044_60021_2000211_2001221_2002131,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,}
local L_NamesByNum = {
   ID = 1,
}
local L_NamesByString = {
   WorldLevel = 2,
   Rank = 3,
   GuildAuctionReward = 4,
   PersonalReward = 5,
   MonsterReward = 6,
   RewardShow = 7,
   PaipinShow = 8,
}
local L_ColNameIndexs = {
   ID = 0,
   WorldLevel = 1,
   Rank = 2,
   GuildAuctionReward = 3,
   PersonalReward = 4,
   MonsterReward = 5,
   RewardShow = 6,
   PaipinShow = 7,
}
--local L_ColumnUseBitCount = {5,15,15,16,16,15,12,14,}
--local L_ColumnList = {1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,5,20,35,0,16,31,43,}
--local L_AndDataList = {15,16383,16383,32767,32767,16383,2047,8191,}
local L_ColumnShiftAndList = {1,0,15,1,5,16383,1,20,16383,1,35,32767,2,0,32767,2,16,16383,2,31,2047,2,43,8191,}
local L_ColNum = 8;
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
