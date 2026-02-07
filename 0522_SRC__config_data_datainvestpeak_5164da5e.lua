--The file is automatically generated, please do not modify it manually. From the data file:investPeak
local L_CompressMaxColumn = 2
local L_CompressData = {
12242331403528302,44538,
--10350,3343,350,880_2,收回本金,,
12246732134393976,1,
--10360,3343,360,870_2,,,
12247284574562434,56142,
--10370,3343,370,890_2,2倍返利,,
12247562136823948,1,
--10380,3343,380,910_2,,,
12247839699085462,56141,
--10390,3343,390,940_2,4倍返利,,
12248117261346976,1,
--10400,3343,400,960_2,,,
12248394823608490,1,
--10410,3343,410,990_2,,,
12248672385870004,56140,
--10420,3343,420,1010_2,7倍返利,,
12248949948131518,1,
--10430,3343,430,1030_2,,,
12249227510393032,1,
--10440,3343,440,1070_2,,,
12243732636608722,56139,
--10450,3343,450,1090_2,11倍返利,,
12249507757009116,1,
--10460,3343,460,1120_2,,,
12249785319270630,1,
--10470,3343,470,1140_2,,,
12250062881532144,44552,
--10480,3343,480,1180_2,15倍返利,,
}
local L_MainKeyDic = {
[10350]=1,[10360]=2,[10370]=3,[10380]=4,[10390]=5,[10400]=6,[10410]=7,[10420]=8,[10430]=9,[10440]=10,[10450]=11,[10460]=12,[10470]=13,[10480]=14,}
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
--local L_ColumnUseBitCount = {15,13,10,17,17,}
--local L_ColumnList = {1,1,1,1,2,}
--local L_ShiftDataList = {0,15,28,38,0,}
--local L_AndDataList = {16383,4095,511,65535,65535,}
local L_ColumnShiftAndList = {1,0,16383,1,15,4095,1,28,511,1,38,65535,2,0,65535,}
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
