--The file is automatically generated, please do not modify it manually. From the data file:immortal_soul_synthesis
local L_CompressMaxColumn = 2
local L_CompressData = {
159834624755776937,171803455557111,
--6307241,长生,1,红色双属性,6307141_1;6307141_1;6307141_1,24_4500,10000,,
159834624822885802,171803455557113,
--6307242,金刚,1,红色双属性,6307142_1;6307142_1;6307142_1,24_4500,10000,,
159834624889994667,171803455557114,
--6307243,杀戮,1,红色双属性,6307143_1;6307143_1;6307143_1,24_4500,10000,,
159834624957103532,171803455557115,
--6307244,粉碎,1,红色双属性,6307144_1;6307144_1;6307144_1,24_4500,10000,,
159834625024212397,171803455557116,
--6307245,毁灭,1,红色双属性,6307145_1;6307145_1;6307145_1,24_4500,10000,,
159834625091321262,171803455557117,
--6307246,圣元,1,红色双属性,6307146_1;6307146_1;6307146_1,24_4500,10000,,
159834625158430127,171803455557118,
--6307247,灵巧,1,红色双属性,6307147_1;6307147_1;6307147_1,24_4500,10000,,
159874757399952909,171803456736768,
--6307341,真.长生,2,红色三属性,6307241_1;6307241_1;6307241_1,24_7500,10000,,
159874757483838990,171803456736770,
--6307342,真.金刚,2,红色三属性,6307242_1;6307242_1;6307242_1,24_7500,10000,,
159874757567725071,171803456736771,
--6307343,真.杀戮,2,红色三属性,6307243_1;6307243_1;6307243_1,24_7500,10000,,
159874757651611152,171803456736772,
--6307344,真.粉碎,2,红色三属性,6307244_1;6307244_1;6307244_1,24_7500,10000,,
159874757735497233,171803456736773,
--6307345,真.毁灭,2,红色三属性,6307245_1;6307245_1;6307245_1,24_7500,10000,,
159874757836160530,171803456736774,
--6307346,真.圣元,2,红色三属性,6307246_1;6307246_1;6307246_1,24_7500,10000,,
159874757936823827,171803456736775,
--6307347,真.灵巧,2,红色三属性,6307247_1;6307247_1;6307247_1,24_7500,10000,,
}
local L_MainKeyDic = {
[6307241]=1,[6307242]=2,[6307243]=3,[6307244]=4,[6307245]=5,[6307246]=6,[6307247]=7,[6307341]=8,[6307342]=9,[6307343]=10,[6307344]=11,[6307345]=12,[6307346]=13,[6307347]=14,}
local L_NamesByNum = {
   Id = 1,
   Type = 3,
   Probability = 7,
}
local L_NamesByString = {
   TargetItems = 2,
   TypeName = 4,
   Material1 = 5,
   Material2 = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   TargetItems = 1,
   Type = 2,
   TypeName = 3,
   Material1 = 4,
   Material2 = 5,
   Probability = 6,
}
--local L_ColumnUseBitCount = {24,15,3,17,17,17,15,}
--local L_ColumnList = {1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,24,39,42,0,17,34,}
--local L_AndDataList = {8388607,16383,3,65535,65535,65535,16383,}
local L_ColumnShiftAndList = {1,0,8388607,1,24,16383,1,39,3,1,42,65535,2,0,65535,2,17,65535,2,34,16383,}
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
