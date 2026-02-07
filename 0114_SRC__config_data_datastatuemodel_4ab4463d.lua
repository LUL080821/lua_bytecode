--The file is automatically generated, please do not modify it manually. From the data file:statue_model
local L_CompressMaxColumn = 3
local L_CompressData = {
338969679328215140,14296722599575653,28611038565488998,
--100,1,10111,100,136,75,101,0,0,6500,6501,6502,6503,6504,6505,,
392933710019723365,14296722713870437,28611038565488998,
--101,1,10112,100,127,87,101,0,-90,6500,6501,6502,6503,6504,6505,,
370415711883133030,14296722713870437,28611038565488998,
--102,1,10113,100,127,82,101,0,-90,6500,6501,6502,6503,6504,6505,,
410868943692529767,14296722646761573,28611038565488998,
--103,1,10114,100,118,91,101,0,90,6500,6501,6502,6503,6504,6505,,
392854545183309928,14296722646761573,28611038565488998,
--104,1,10115,100,118,87,101,0,90,6500,6501,6502,6503,6504,6505,,
410948108530253929,14296722713870437,28611038565488998,
--105,1,10116,100,127,91,101,0,-90,6500,6501,6502,6503,6504,6505,,
780480778511385476,14296722599576452,28611038565488998,
--900,2,33100,100,154,173,900,0,0,6500,6501,6502,6503,6504,6505,,
249056022481929093,14296722599576452,28611038565488998,
--901,2,33101,100,154,55,900,0,0,6500,6501,6502,6503,6504,6505,,
248994449831035782,14296722599576452,28611038565488998,
--902,2,33102,100,147,55,900,0,0,6500,6501,6502,6503,6504,6505,,
249143983412675463,14296722599576452,28611038565488998,
--903,2,33103,100,164,55,900,0,0,6500,6501,6502,6503,6504,6505,,
162484874957137680,14296722599639552,28611038565488998,
--10000,3,33100,100,40,36,64000,0,0,6500,6501,6502,6503,6504,6505,,
212068451323586321,14296722599639552,28611038565488998,
--10001,3,33101,100,45,47,64000,0,0,6500,6501,6502,6503,6504,6505,,
144391311610980114,14296722599639552,28611038565488998,
--10002,3,33102,100,31,32,64000,0,0,6500,6501,6502,6503,6504,6505,,
144567233471686419,14296722599639552,28611038565488998,
--10003,3,33103,100,51,32,64000,0,0,6500,6501,6502,6503,6504,6505,,
}
local L_MainKeyDic = {
[100]=1,[101]=2,[102]=3,[103]=4,[104]=5,[105]=6,[900]=7,[901]=8,[902]=9,[903]=10,[10000]=11,[10001]=12,[10002]=13,[10003]=14,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Npcid = 3,
   SizeScale = 4,
   X = 5,
   Y = 6,
   Mapid = 7,
   DirX = 8,
   DirY = 9,
   Model1 = 10,
   Model2 = 11,
   Model3 = 12,
   Model4 = 13,
   Model5 = 14,
   Model6 = 15,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Npcid = 2,
   SizeScale = 3,
   X = 4,
   Y = 5,
   Mapid = 6,
   DirX = 7,
   DirY = 8,
   Model1 = 9,
   Model2 = 10,
   Model3 = 11,
   Model4 = 12,
   Model5 = 13,
   Model6 = 14,
}
--local L_ColumnUseBitCount = {15,3,17,8,9,9,17,2,8,14,14,14,14,14,14,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,}
--local L_ShiftDataList = {0,15,18,35,43,52,0,17,19,27,41,0,14,28,42,}
--local L_AndDataList = {16383,3,65535,127,255,255,65535,1,127,8191,8191,8191,8191,8191,8191,}
local L_ColumnShiftAndList = {1,0,16383,1,15,3,1,18,65535,1,35,127,1,43,255,1,52,255,2,0,65535,2,17,1,2,19,127,2,27,8191,2,41,8191,3,0,8191,3,14,8191,3,28,8191,3,42,8191,}
local L_ColNum = 15;
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
    Count = 14
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
