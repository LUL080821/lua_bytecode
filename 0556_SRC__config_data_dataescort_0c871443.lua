--The file is automatically generated, please do not modify it manually. From the data file:Escort
local L_CompressMaxColumn = 3
local L_CompressData = {
7657333329428464689,226718333691301097,1483766836,
--1,Xe lúa Lạc Dân,n_car_escort_1,1,69,1700,4001001,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700001_105_89;1700002_191_91;1700003_244_102;1700004_310_153;1700005_288_197,3_20000_0_9,1500,,50,n_b_escort_1,100_180_0_0_0,50000,1_1,,
7657333329426367522,136646341177445610,1483766834,
--2,Xe lúa Đông Sơn,n_car_escort_2,1,69,1700,4001002,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700006_105_89;1700007_191_91;1700008_244_102;1700009_310_153;1700010_288_197,3_40000_0_9,1500,,30,n_b_escort_2,100_180_0_0_0,30000,1_1,,
7657333329424270355,91610344945683691,1483766832,
--3,Xe lúa Cổ Loa,n_car_escort_3,1,69,1700,4001003,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700011_105_89;1700012_191_91;1700013_244_102;1700014_310_153;1700015_288_197,3_60000_0_9,1500,,20,n_b_escort_3,100_180_0_0_0,20000,1_1,,
7662371429145887796,226718333691301097,1483766836,
--4,Xe lúa Lạc Dân,n_car_escort_1,99,99,1701,4001001,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700001_105_89;1700002_191_91;1700003_244_102;1700004_310_153;1700005_288_197,3_20000_0_9,1500,,50,n_b_escort_1,100_180_0_0_0,50000,1_1,,
7662371429143790629,136646341177445610,1483766834,
--5,Xe lúa Đông Sơn,n_car_escort_2,99,99,1701,4001002,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700006_105_89;1700007_191_91;1700008_244_102;1700009_310_153;1700010_288_197,3_40000_0_9,1500,,30,n_b_escort_2,100_180_0_0_0,30000,1_1,,
7662371429141693462,91610344945683691,1483766832,
--6,Xe lúa Cổ Loa,n_car_escort_3,99,99,1701,4001003,63_119;89_91;111_96;133_96;163_99;191_100;234_98;284_105;296_139;308_165;283_198;271_238,1700011_105_89;1700012_191_91;1700013_244_102;1700014_310_153;1700015_288_197,3_60000_0_9,1500,,20,n_b_escort_3,100_180_0_0_0,20000,1_1,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   Id = 1,
   LevelMin = 4,
   LevelMax = 5,
   CloneID = 6,
   MonsterId = 7,
   EscortTime = 9,
   ShowValue = 11,
}
local L_NamesByString = {
   Name = 2,
   Icon = 3,
   RewardID = 8,
   UseItem = 10,
   ChooseBackground = 12,
   ModelPosition = 13,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Icon = 2,
   LevelMin = 3,
   LevelMax = 4,
   CloneID = 5,
   MonsterId = 6,
   RewardID = 7,
   EscortTime = 8,
   UseItem = 9,
   ShowValue = 10,
   ChooseBackground = 11,
   ModelPosition = 12,
}
--local L_ColumnUseBitCount = {4,16,16,8,8,12,23,15,12,2,7,16,16,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,2,3,3,}
--local L_ShiftDataList = {0,4,20,36,44,52,0,23,38,50,52,0,16,}
--local L_AndDataList = {7,32767,32767,127,127,2047,4194303,16383,2047,1,63,32767,32767,}
local L_ColumnShiftAndList = {1,0,7,1,4,32767,1,20,32767,1,36,127,1,44,127,1,52,2047,2,0,4194303,2,23,16383,2,38,2047,2,50,1,2,52,63,3,0,32767,3,16,32767,}
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
