--The file is automatically generated, please do not modify it manually. From the data file:invest
local L_CompressMaxColumn = 2
local L_CompressData = {
191284964435728,44538,
--10000,27,1,880_2,收回本金,,
191293969606516,1,
--10100,27,100,540_2,,,
191298474289062,44541,
--10150,27,150,820_2,2.5倍返利,,
191307273938904,1,
--10200,27,200,1090_2,,,
191311652792300,44544,
--10220,27,220,1200_2,5倍返利,,
191320326612992,1,
--10240,27,240,1310_2,,,
191324705466388,1,
--10260,27,260,1440_2,,,
191329084319784,44548,
--10280,27,280,1540_2,10倍返利,,
191337758140476,1,
--10300,27,300,1650_2,,,
191342136993872,1,
--10320,27,320,1760_2,,,
191346515847268,44552,
--10340,27,340,1870_2,15倍返利,,
191286426619424,44538,
--20000,2,350,880_2,收回本金,,
191355188039230,44554,
--20030,2,360,870_2,2.3倍返利,,
191363819916877,1,
--20045,2,370,890_2,,,
191368156827248,44544,
--20080,2,380,910_2,5倍返利,,
191372493737624,1,
--20120,2,390,940_2,,,
191376830648000,1,
--20160,2,400,960_2,,,
191381167558376,1,
--20200,2,410,990_2,,,
191385504468752,44548,
--20240,2,420,1010_2,10倍返利,,
191389841379128,1,
--20280,2,430,1030_2,,,
191394178289504,1,
--20320,2,440,1070_2,,,
191308320886664,44552,
--20360,2,450,1090_2,15倍返利,,
191398557142960,1,
--20400,2,460,1120_2,,,
191402894053336,1,
--20440,2,470,1140_2,,,
191407230963712,44566,
--20480,2,480,1180_2,20倍返利,,
}
local L_MainKeyDic = {
[10000]=1,[10100]=2,[10150]=3,[10200]=4,[10220]=5,[10240]=6,[10260]=7,[10280]=8,[10300]=9,[10320]=10,[10340]=11,[20000]=12,[20030]=13,[20045]=14,[20080]=15,
[20120]=16,[20160]=17,[20200]=18,[20240]=19,[20280]=20,[20320]=21,[20360]=22,[20400]=23,[20440]=24,[20480]=25,}
local L_NamesByNum = {
   ID = 1,
   Gear = 2,
   Level = 3,
}
local L_NamesByString = {
   Money = 4,
   ShowWord = 5,
}
local L_ColNameIndexs = {
   ID = 0,
   Gear = 1,
   Level = 2,
   Money = 3,
   ShowWord = 4,
}
--local L_ColumnUseBitCount = {16,6,10,17,17,}
--local L_ColumnList = {1,1,1,1,2,}
--local L_ShiftDataList = {0,16,22,32,0,}
--local L_AndDataList = {32767,31,511,65535,65535,}
local L_ColumnShiftAndList = {1,0,32767,1,16,31,1,22,511,1,32,65535,2,0,65535,}
local L_ColNum = 5;
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
    Count = 25
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
