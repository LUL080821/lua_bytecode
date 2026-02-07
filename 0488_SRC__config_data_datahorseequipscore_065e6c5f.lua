--The file is automatically generated, please do not modify it manually. From the data file:Horse_equip_score
local L_CompressMaxColumn = 2
local L_CompressData = {
30397098461504489,8488660,
--1001,1,0,凡级,100052,,,,
30399321313649642,265829320405,
--1002,1,181800,兽级,100053,10,14,,
30401548124169195,265829320406,
--1003,1,393800,灵级,100054,10,14,,
30403793874592748,265829320407,
--1004,1,750300,地级,100055,10,14,,
30406108804817901,265829320408,
--1005,1,1634600,天级,100056,10,14,,
30408373298537454,265829320409,
--1006,1,2134100,仙级,100057,10,14,,
30410754472551407,265829320410,
--1007,1,3523800,圣级,100058,10,14,,
30397098461513681,8488667,
--2001,2,0,凡级,100059,,,,
30399329649838034,265829320412,
--2002,2,245400,兽级,100060,10,14,,
30401562148882387,265829320413,
--2003,2,500800,灵级,100061,10,14,,
30403828648003540,265829320414,
--2004,2,1015600,地级,100062,10,14,,
30406128439412693,265829320415,
--2005,2,1784400,天级,100063,10,14,,
30408427942463446,265829320416,
--2006,2,2551000,仙级,100064,10,14,,
30410802471126999,265829320417,
--2007,2,3890000,圣级,100065,10,14,,
30397098461522873,8488674,
--3001,3,0,凡级,100066,,,,
30399337986026426,265829320419,
--3002,3,309000,兽级,100067,10,14,,
30401576160488379,265829320420,
--3003,3,607700,灵级,100068,10,14,,
30403863421414332,265829320421,
--3004,3,1280900,地级,100069,10,14,,
30406148087114685,265829320422,
--3005,3,1934300,天级,100070,10,14,,
30408482586389438,265829320423,
--3006,3,2967900,仙级,100071,10,14,,
30410850456595391,265829320424,
--3007,3,4256100,圣级,100072,10,14,,
30397098461532065,8488681,
--4001,4,0,凡级,100073,,,,
30399349100941218,265829320426,
--4002,4,393800,兽级,100074,10,14,,
30401594851364771,265829320427,
--4003,4,750300,灵级,100075,10,14,,
30403909781589924,265829320428,
--4004,4,1634600,地级,100076,10,14,,
30406174275309477,265829320429,
--4005,4,2134100,天级,100077,10,14,,
30408555449323430,265829320430,
--4006,4,3523800,仙级,100078,10,14,,
30410908639465383,265829320431,
--4007,4,4700000,圣级,100079,10,14,,
}
local L_MainKeyDic = {
[1001]=1,[1002]=2,[1003]=3,[1004]=4,[1005]=5,[1006]=6,[1007]=7,[2001]=8,[2002]=9,[2003]=10,[2004]=11,[2005]=12,[2006]=13,[2007]=14,[3001]=15,
[3002]=16,[3003]=17,[3004]=18,[3005]=19,[3006]=20,[3007]=21,[4001]=22,[4002]=23,[4003]=24,[4004]=25,[4005]=26,[4006]=27,[4007]=28,}
local L_NamesByNum = {
   Id = 1,
   Site = 2,
   NeedScore = 3,
   VFX = 5,
   Notice = 6,
}
local L_NamesByString = {
   Name = 4,
   Chatchannel = 7,
}
local L_ColNameIndexs = {
   Id = 0,
   Site = 1,
   NeedScore = 2,
   Name = 3,
   VFX = 4,
   Notice = 5,
   Chatchannel = 6,
}
--local L_ColumnUseBitCount = {13,4,24,15,18,5,16,}
--local L_ColumnList = {1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,13,17,41,0,18,23,}
--local L_AndDataList = {4095,7,8388607,16383,131071,15,32767,}
local L_ColumnShiftAndList = {1,0,4095,1,13,7,1,17,8388607,1,41,16383,2,0,131071,2,18,15,2,23,32767,}
local L_ColNum = 7;
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
    Count = 28
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
