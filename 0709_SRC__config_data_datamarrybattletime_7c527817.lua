--The file is automatically generated, please do not modify it manually. From the data file:marry_battle_time
local L_CompressMaxColumn = 1
local L_CompressData = {
3055768534269953,
--1,0,1,6_0,6_1235,,
3055772285011044,
--100,1,0,6_1210,6_1235,,
3055841005291719,
--199,2,-1,6_1235,6_1240,,
3055909725030601,
--201,2,1,6_1240,6_1242,,
3055978445048010,
--202,2,2,6_1242,6_1244,,
3056047165065419,
--203,2,3,6_1244,6_1246,,
3056115885082828,
--204,2,4,6_1246,6_1248,,
3056184605100237,
--205,2,5,6_1248,6_1250,,
3056253325117646,
--206,2,6,6_1250,6_1252,,
3056322045135055,
--207,2,7,6_1252,6_1254,,
3056390765152464,
--208,2,8,6_1254,6_1256,,
3056459485169873,
--209,2,9,6_1256,6_1258,,
3056596925304107,
--299,3,-1,7_1210,7_1215,,
3056665645042989,
--301,3,1,7_1215,7_1217,,
3056803085061422,
--302,3,2,7_1220,7_1222,,
3056940525079855,
--303,3,3,7_1225,7_1227,,
3057077965098288,
--304,3,4,7_1230,7_1232,,
3057215405314447,
--399,4,-1,7_1235,7_1240,,
3057284125053329,
--401,4,1,7_1240,7_1242,,
3057421565071762,
--402,4,2,7_1245,7_1247,,
3057559005090195,
--403,4,3,7_1250,7_1252,,
3057696445108628,
--404,4,4,7_1255,7_1257,,
}
local L_MainKeyDic = {
[1]=1,[100]=2,[199]=3,[201]=4,[202]=5,[203]=6,[204]=7,[205]=8,[206]=9,[207]=10,[208]=11,[209]=12,[299]=13,[301]=14,[302]=15,
[303]=16,[304]=17,[399]=18,[401]=19,[402]=20,[403]=21,[404]=22,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Game = 3,
}
local L_NamesByString = {
   StartTime = 4,
   OverTime = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Game = 2,
   StartTime = 3,
   OverTime = 4,
}
--local L_ColumnUseBitCount = {10,4,5,17,17,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,10,14,19,36,}
--local L_AndDataList = {511,7,15,65535,65535,}
local L_ColumnShiftAndList = {1,0,511,1,10,7,1,14,15,1,19,65535,1,36,65535,}
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
