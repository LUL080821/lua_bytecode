--The file is automatically generated, please do not modify it manually. From the data file:Horse_equip_unlock
local L_CompressMaxColumn = 2
local L_CompressData = {
1340889588967485,654733803521,
--10301,1,通天轮,1_250,,301,1_250,,
1340889588967486,654733869057,
--10302,1,通天轮,1_250,,302,1_250,,
1340889588967487,654733934593,
--10303,1,通天轮,1_250,,303,1_250,,
1340889588967488,654734000129,
--10304,1,通天轮,1_250,,304,1_250,,
2304474093997901,654733820288,
--20301,2,彻地轮,1_480,1314_1,301,1_250,,
2304474093997902,654733885824,
--20302,2,彻地轮,1_480,1314_1,302,1_250,,
2304474093997903,654733951360,
--20303,2,彻地轮,1_480,1314_1,303,1_250,,
2304474093997904,654734016896,
--20304,2,彻地轮,1_480,1314_1,304,1_250,,
2304886417290845,654733820291,
--30301,3,踏海轮,1_540,1314_2,301,1_250,,
2304886417290846,654733885827,
--30302,3,踏海轮,1_540,1314_2,302,1_250,,
2304886417290847,654733951363,
--30303,3,踏海轮,1_540,1314_2,303,1_250,,
2304886417290848,654734016899,
--30304,3,踏海轮,1_540,1314_2,304,1_250,,
2305298740583789,654733820294,
--40301,4,御风轮,1_600,1314_3,301,1_250,,
2305298740583790,654733885830,
--40302,4,御风轮,1_600,1314_3,302,1_250,,
2305298740583791,654733951366,
--40303,4,御风轮,1_600,1314_3,303,1_250,,
2305298740583792,654734016902,
--40304,4,御风轮,1_600,1314_3,304,1_250,,
}
local L_MainKeyDic = {
[10301]=1,[10302]=2,[10303]=3,[10304]=4,[20301]=5,[20302]=6,[20303]=7,[20304]=8,[30301]=9,[30302]=10,[30303]=11,[30304]=12,[40301]=13,[40302]=14,[40303]=15,
[40304]=16,}
local L_NamesByNum = {
   Id = 1,
   Site = 2,
   PartId = 6,
}
local L_NamesByString = {
   Name = 3,
   SiteUnlock = 4,
   SiteUnlockItem = 5,
   PartUnlock = 7,
}
local L_ColNameIndexs = {
   Id = 0,
   Site = 1,
   Name = 2,
   SiteUnlock = 3,
   SiteUnlockItem = 4,
   PartId = 5,
   PartUnlock = 6,
}
--local L_ColumnUseBitCount = {17,4,16,16,16,10,15,}
--local L_ColumnList = {1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,17,21,37,0,16,26,}
--local L_AndDataList = {65535,7,32767,32767,32767,511,16383,}
local L_ColumnShiftAndList = {1,0,65535,1,17,7,1,21,32767,1,37,32767,2,0,32767,2,16,511,2,26,16383,}
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
    Count = 16
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
