--The file is automatically generated, please do not modify it manually. From the data file:changejob
local L_CompressMaxColumn = 5
local L_CompressData = {
7148237977916358993,2650538803272493,27525132986515,1452912115873770,31689,
--1,Lạc Binh,29,30000100_30000101_30000102_30000103_30000104_30000105,,奖励装备,83135_83136_83137_83138,,,29_49,2001216_2001222;2101216_2101222;2001216_2001222;2101216_2101222,2_1000;4_100;64_100;3_50,210000099,110000106,2001211_1_1_0;2101211_1_1_1;2220005_1_1_2;2210108_1_1_3,,10,14,,
7148248338493161714,2650127934495519,27525132855443,1452909968390121,31689,
--2,Lạc Tướng,49,30000110_30000111_30000112_30000113_30000114_30000115,,奖励装备,83139_83140_83141_83142,,,49_69,2002326_2002332;2102326_2102332;2002326_2002332;2102326_2102332,2_1000;4_100;64_100;3_50,210000098,110000105,2002321_1_1_0;2102321_1_1_1;2230011_1_1_2;2230111_1_1_3,,10,14,,
7148248339608846547,2650127935544095,27525132855443,1452909968390120,31689,
--3,Lạc Vương,69,30000120_30000121_30000122_30000123_30000124_30000125,,奖励装备,83139_83140_83141_83142,,,69_79,2002326_2002332;2102326_2102332;2002326_2002332;2102326_2102332,2_1000;4_100;64_100;3_50,210000098,110000104,2002321_1_1_0;2102321_1_1_1;2230011_1_1_2;2230111_1_1_3,,10,14,,
7148248340166688916,3490154820238499,31762,1456192397146087,31689,
--4,Lạc Thần,79,30000130_30000131_30000132_30000133_30000134_30000135,,奖励装备,81110_81111_81110_81111,,,79_89,2000491_2000595;2002155_2002259;2000491_2000595;2002155_2002259,1_1091;2_29247;3_545;4_545,0,110000103,81083_1_1_0;81089_1_1_1;81083_1_1_2;81089_1_1_3,,10,14,,
7148248341261402261,3490154822335503,38349,1456192397146086,31689,
--5,Lạc Thần,89,30000140_30000141_30000142_30000143_30000144_30000145,,奖励装备,81087_81093_81087_81093,,,89_99,2000491_2000595;2002155_2002259;2000491_2000595;2002155_2002259,1_1559;2_41782;3_779;4_779,0,110000102,81083_1_1_0;81089_1_1_1;81083_1_1_2;81089_1_1_3,,10,14,,
7148248341819244694,3490154822335497,22655,1456192397146085,31689,
--6,Lạc Thần,99,30000150_30000151_30000152_30000153_30000154_30000155,,奖励装备,81088_81094_81088_81094,,,89_99,2000491_2000595;2002155_2002259;2000491_2000595;2002155_2002259,1_2495;2_66851;3_1247;4_1247,0,110000101,81083_1_1_0;81089_1_1_1;81083_1_1_2;81089_1_1_3,,10,14,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   Id = 1,
   ChangejobCondition = 3,
   WeaponChange = 13,
   ModelChange = 14,
   Notice = 17,
}
local L_NamesByString = {
   ChangejobName = 2,
   TaskGroup = 4,
   UnLockFunction = 5,
   FunctionName = 6,
   ShowItem = 7,
   FunctionName2 = 8,
   ShowItem2 = 9,
   LevelDescribe = 10,
   EquipDescribe = 11,
   ContributeDescribe = 12,
   ChangejobReward = 15,
   MainLittleName = 16,
   Chatchannel = 18,
}
local L_ColNameIndexs = {
   Id = 0,
   ChangejobName = 1,
   ChangejobCondition = 2,
   TaskGroup = 3,
   UnLockFunction = 4,
   FunctionName = 5,
   ShowItem = 6,
   FunctionName2 = 7,
   ShowItem2 = 8,
   LevelDescribe = 9,
   EquipDescribe = 10,
   ContributeDescribe = 11,
   WeaponChange = 12,
   ModelChange = 13,
   ChangejobReward = 14,
   MainLittleName = 15,
   Notice = 16,
   Chatchannel = 17,
}
--local L_ColumnUseBitCount = {4,17,8,16,2,17,16,2,2,16,17,17,29,28,17,2,5,16,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,2,3,3,4,4,4,4,5,}
--local L_ShiftDataList = {0,4,21,29,45,47,0,16,18,20,36,0,17,0,28,45,47,0,}
--local L_AndDataList = {7,65535,127,32767,1,65535,32767,1,1,32767,65535,65535,268435455,134217727,65535,1,15,32767,}
local L_ColumnShiftAndList = {1,0,7,1,4,65535,1,21,127,1,29,32767,1,45,1,1,47,65535,2,0,32767,2,16,1,2,18,1,2,20,32767,2,36,65535,3,0,65535,3,17,268435455,4,0,134217727,4,28,65535,4,45,1,4,47,15,5,0,32767,}
local L_ColNum = 18;
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
