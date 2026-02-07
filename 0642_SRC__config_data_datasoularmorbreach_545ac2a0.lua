--The file is automatically generated, please do not modify it manually. From the data file:SoulArmor_breach
local L_CompressMaxColumn = 3
local L_CompressData = {
3597035655659057,288269958905857374,2113539,
--1,3,真武魂甲,0,6700001,1374,83091_1;83092_1,3_590;4_590,31_100,400_0_20_0_45_60,,,,
3597036192532546,288357921178277215,66457321480,
--2,4,灵武魂甲,0,6700002,1375,83091_2;83092_2,3_1772;4_1772,31_100;32_100,300_0_20_0_45_120,10,14,,
3597036729406051,288445883450697056,66457321485,
--3,6,天武魂甲,0,6700003,1376,83091_3;83092_3,3_3544;4_3544,31_200;32_100,300_0_20_0_45_125,10,14,,
3597037400497268,288533845723116897,66457321485,
--4,7,天罡魂甲,4,6700004,1377,83091_6;83092_6,3_7089;4_7089,31_200;32_200,300_0_20_0_45_125,10,14,,
3597037970924677,288604215541052770,66457321485,
--5,8,天元魂甲,5,6700005,1378,83091_12;83092_12,3_14178;4_14178,31_300;32_200,300_0_20_0_45_125,10,14,,
3597038541352086,288674585358988643,66457321485,
--6,9,玄元魂甲,6,6700006,1379,83091_18;83092_18,3_24811;4_24811,31_300;32_300,300_0_20_0_45_125,10,14,,
3597039111779495,288744955176924516,66457321485,
--7,10,玄真魂甲,7,6700007,1380,83091_24;83092_24,3_38990;4_38990,31_400;32_300,300_0_20_0_45_125,10,14,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,}
local L_NamesByNum = {
   Id = 1,
   Quality = 2,
   Effect = 4,
   Model = 5,
   Icon = 6,
   Notice = 11,
}
local L_NamesByString = {
   Name = 3,
   Consume = 7,
   QualityValue = 8,
   ExtraValue = 9,
   MainTransfom = 10,
   Chatchannel = 12,
}
local L_ColNameIndexs = {
   Id = 0,
   Quality = 1,
   Name = 2,
   Effect = 3,
   Model = 4,
   Icon = 5,
   Consume = 6,
   QualityValue = 7,
   ExtraValue = 8,
   MainTransfom = 9,
   Notice = 10,
   Chatchannel = 11,
}
--local L_ColumnUseBitCount = {4,5,16,4,24,12,16,16,16,16,5,16,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,3,3,3,}
--local L_ShiftDataList = {0,4,9,25,29,0,12,28,44,0,16,21,}
--local L_AndDataList = {7,15,32767,7,8388607,2047,32767,32767,32767,32767,15,32767,}
local L_ColumnShiftAndList = {1,0,7,1,4,15,1,9,32767,1,25,7,1,29,8388607,2,0,2047,2,12,32767,2,28,32767,2,44,32767,3,0,32767,3,16,15,3,21,32767,}
local L_ColNum = 12;
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
    Count = 7
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
