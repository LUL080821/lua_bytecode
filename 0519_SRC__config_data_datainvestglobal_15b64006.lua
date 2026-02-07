--The file is automatically generated, please do not modify it manually. From the data file:invest_Global
local L_CompressMaxColumn = 1
local L_CompressData = {
677440587421720250,
--270010,27,0,10,12_500_1,,
677441281327374020,
--270020,27,100,20,12_500_1,,
677441971877584590,
--270030,27,150,30,12_500_1,,
677442662427795160,
--270040,27,200,40,12_500_1,,
677443350964739810,
--270050,27,220,50,12_500_1,,
677444039501684460,
--270060,27,240,60,12_500_1,,
677444728038629110,
--270070,27,260,70,12_500_1,,
677445416575573760,
--270080,27,280,80,12_500_1,,
677446105112518410,
--270090,27,300,90,12_500_1,,
677446793649463060,
--270100,27,320,100,12_500_1,,
677447482186407710,
--270110,27,340,110,12_500_1,,
677440610883358290,
--20050,2,350,10,12_500_1,,
677441298749214340,
--20100,2,360,20,12_500_1,,
677441986615070390,
--20150,2,370,30,12_500_1,,
677442674480926440,
--20200,2,380,40,12_500_1,,
677443362346782490,
--20250,2,390,50,12_500_1,,
677444050548182860,
--20300,2,405,60,12_500_1,,
677444738749583230,
--20350,2,420,70,12_500_1,,
677445426950983600,
--20400,2,435,80,12_500_1,,
677446115152383970,
--20450,2,450,90,12_500_1,,
677446803353784340,
--20500,2,465,100,12_500_1,,
677447491555184710,
--20550,2,480,110,12_500_1,,
}
local L_MainKeyDic = {
[270010]=1,[270020]=2,[270030]=3,[270040]=4,[270050]=5,[270060]=6,[270070]=7,[270080]=8,[270090]=9,[270100]=10,[270110]=11,[20050]=12,[20100]=13,[20150]=14,[20200]=15,
[20250]=16,[20300]=17,[20350]=18,[20400]=19,[20450]=20,[20500]=21,[20550]=22,}
local L_NamesByNum = {
   ID = 1,
   Gear = 2,
   Level = 3,
   Times = 4,
}
local L_NamesByString = {
   Reward = 5,
}
local L_ColNameIndexs = {
   ID = 0,
   Gear = 1,
   Level = 2,
   Times = 3,
   Reward = 4,
}
--local L_ColumnUseBitCount = {20,6,10,8,17,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,20,26,36,44,}
--local L_AndDataList = {524287,31,511,127,65535,}
local L_ColumnShiftAndList = {1,0,524287,1,20,31,1,26,511,1,36,127,1,44,65535,}
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
    Count = 22
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
