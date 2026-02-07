--The file is automatically generated, please do not modify it manually. From the data file:EightCity
local L_CompressMaxColumn = 3
local L_CompressData = {
74773072084428833,964227514555199,63001,
--1,乾,1,83086_2,17001,72_53,2_8_9,0_7_15,63001,,
74777470130939778,964175974554431,63002,
--2,巽,1,83086_2,17002,72_53,1_3_10,0_1_8,63002,,
74781868177450787,964124434553663,63003,
--3,坎,1,83086_2,17003,72_53,2_4_10,1_2_9,63003,,
74786266223961796,964072894552895,63004,
--4,艮,1,83086_2,17004,72_53,3_5_11,2_3_10,63004,,
74790664270472805,964021354552127,63005,
--5,坤,1,83086_2,17005,72_53,4_6_11,3_4_11,63005,,
74795062316983814,963969814551359,63006,
--6,震,1,83086_2,17006,72_53,5_7_12,4_5_12,63006,,
74799460362058279,963935454550847,63007,
--7,雷,1,83086_2,17007,72_53,6_8_12,5_6_13,63007,,
74803858410005864,963895848917823,63008,
--8,兑,1,83086_2,17008,72_53,7_1_9,6_7_14,63008,,
74808255687549289,963849554549567,63009,
--9,青龙,2,83086_2;83087_1,17009,72_53,8_1_13,14_15_16,63009,,
74812653735470282,963798014548799,63010,
--10,朱雀,2,83086_2;83087_1,17010,72_53,2_3_13,8_9_17,63010,,
74817051780718859,963763654548287,63011,
--11,白虎,2,83086_2;83087_1,17011,72_53,4_5_13,10_11_18,63011,,
74821449827082444,963729294547775,63012,
--12,玄武,2,83086_2;83087_1,17012,72_53,6_7_13,12_13_19,63012,,
74825847510098925,963660574546751,63013,
--13,太极,3,83086_2;83087_1;83088_1,17013,72_53,9_10_11_12,16_17_18_19,63013,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,}
local L_NamesByNum = {
   Id = 1,
   Level = 3,
   BossID = 5,
   ModleID = 9,
}
local L_NamesByString = {
   Name = 2,
   Reward = 4,
   BossPos = 6,
   CanAttackCity = 7,
   CanAttackCityLine = 8,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Level = 2,
   Reward = 3,
   BossID = 4,
   BossPos = 5,
   CanAttackCity = 6,
   CanAttackCityLine = 7,
   ModleID = 8,
}
--local L_ColumnUseBitCount = {5,17,3,17,16,17,17,17,17,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,3,}
--local L_ShiftDataList = {0,5,22,25,42,0,17,34,0,}
--local L_AndDataList = {15,65535,3,65535,32767,65535,65535,65535,65535,}
local L_ColumnShiftAndList = {1,0,15,1,5,65535,1,22,3,1,25,65535,1,42,32767,2,0,65535,2,17,65535,2,34,65535,3,0,65535,}
local L_ColNum = 9;
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
    Count = 13
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
