--The file is automatically generated, please do not modify it manually. From the data file:Treasure_Pop
local L_CompressMaxColumn = 5
local L_CompressData = {
991075168037584929,967814097198095,24563473421,703698890952852472,900,
--1,1,机缘寻宝,1_20,60011_1,0,1_60011_1;10_60011_10;50_60011_45,3_20000,6_1,101_149,2_500,,9103002_250_148_100_50_100_-90_0_0;9103102_180_25_70_-40_-153_-23_0_1;9103202_160_0_100_-51_-95_-36_0_2;9103301_180_25_70_-40_-153_-23_0_3,0_9_0,666,20000,900,,
3296776915153593410,967663514606599,24562293764,131073,0,
--2,2,仙魄寻宝,1_150,60010_1,1,1_60010_1;10_60010_10;50_60010_50,60009_25,5_40,201_274,2_10;3_1333;4_200,,,,,,,,
990828374787574883,967560434605057,24563473406,703698890951017107,900,
--3,3,造化寻宝,1_40,60012_1,0,1_60012_1;10_60012_10;50_60012_45,3_30000,6_2,301_342,2_500,,9103003_250_148_100_50_100_-90_0_0;9103103_180_25_70_-40_-153_-23_0_1;9103203_160_0_100_-51_-95_-36_0_2;9103302_180_25_70_-40_-153_-23_0_3,0_70_0,666,20000,900,,
990705544091619460,967560433687546,24560720888,703698883569647617,900,
--4,4,鸿蒙寻宝,1_50,60013_1,0,1_60013_1;10_60013_10;50_60013_45,3_40000,6_2,401_424,2_1000,,,,666,20000,900,,
990605961785201829,375009564875764,24560720882,703698883569647617,900,
--5,5,上古寻宝,1_60,60014_1,0,1_60014_1;10_60014_10;50_60014_45,3_50000,6_3,501_524,2_1000,,,,666,20000,900,,
990529622231213254,24559672304,967243815115758,131073,0,
--6,6,仙甲寻宝,1_50,60015_1,0,1_60015_1;10_60015_10;50_60015_50,3_100000,,60001_61552,,2_1_10;2_21_30;2_41_50;2_66_75;2_91_100;2_121_130;2_151_160;2_191_200;2_231_240,,,,,,,
17592330218727,17180000257,17180056556,131073,0,
--7,7,仙甲秘宝,,,0,,,,7001_7104,,,,,,,,,
17592377912520,24559672298,967243815115758,131073,0,
--8,6,仙甲寻宝(情义点）,,,0,1_31_100,3_100000,,60001_61552,,2_1_10;2_21_30;2_41_50;2_66_75;2_91_100;2_121_130;2_151_160;2_191_200;2_231_240,,,,,,,
17592330180938,17180056553,967140735900648,131073,0,
--10,10,无忧宝库,,,,1_1371_1;10_1371_10,,,80001_80013,,2_1_30;2_61_120;2_181_210,,,,,,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[10]=9,}
local L_NamesByNum = {
   Id = 1,
   RewardType = 2,
   FreeTimes = 6,
   LuckLimit = 15,
   LuckLimitMult = 16,
   LuckLimitTimes = 17,
}
local L_NamesByString = {
   RewardName = 3,
   MoneyCost = 4,
   Item = 5,
   Times = 7,
   Gold = 8,
   Integral = 9,
   Section = 10,
   Frequency = 11,
   GuaranteesReward = 12,
   ShowModel = 13,
   ModelPos = 14,
}
local L_ColNameIndexs = {
   Id = 0,
   RewardType = 1,
   RewardName = 2,
   MoneyCost = 3,
   Item = 4,
   FreeTimes = 5,
   Times = 6,
   Gold = 7,
   Integral = 8,
   Section = 9,
   Frequency = 10,
   GuaranteesReward = 11,
   ShowModel = 12,
   ModelPos = 13,
   LuckLimit = 14,
   LuckLimitMult = 15,
   LuckLimitTimes = 16,
}
--local L_ColumnUseBitCount = {5,5,17,17,17,2,17,17,17,17,17,17,17,17,11,16,11,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,3,3,3,4,4,4,4,5,}
--local L_ShiftDataList = {0,5,10,27,44,61,0,17,34,0,17,34,0,17,34,45,0,}
--local L_AndDataList = {15,15,65535,65535,65535,1,65535,65535,65535,65535,65535,65535,65535,65535,1023,32767,1023,}
local L_ColumnShiftAndList = {1,0,15,1,5,15,1,10,65535,1,27,65535,1,44,65535,1,61,1,2,0,65535,2,17,65535,2,34,65535,3,0,65535,3,17,65535,3,34,65535,4,0,65535,4,17,65535,4,34,1023,4,45,32767,5,0,1023,}
local L_ColNum = 17;
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
    Count = 9
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
