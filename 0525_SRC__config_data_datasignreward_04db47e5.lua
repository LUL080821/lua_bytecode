--The file is automatically generated, please do not modify it manually. From the data file:sign_reward
local L_CompressMaxColumn = 1
local L_CompressData = {
759471014081,
--1,3,100000,1,0,0,0,,
549839700098,
--2,2,40,1,0,0,0,,
1207813527946307,
--3,10001,2,1,5,2,2,,
549758551300,
--4,10004,1,1,0,0,0,,
550804390661,
--5,12,500,1,0,0,0,,
1208023238312134,
--6,3,100000,1,5,2,2,,
549839700103,
--7,2,40,1,0,0,0,,
1805947853520456,
--8,11001,2,1,5,3,3,,
549758551369,
--9,10005,1,1,0,0,0,,
550804390666,
--10,12,500,1,0,0,0,,
1806157563822283,
--11,3,100000,1,5,3,3,,
549839700108,
--12,2,40,1,0,0,0,,
2404082178966605,
--13,10001,2,1,5,4,4,,
549758551438,
--14,10006,1,1,0,0,0,,
550804390671,
--15,12,500,1,0,0,0,,
2404291889332432,
--16,3,100000,1,5,4,4,,
549839700113,
--17,2,40,1,0,0,0,,
2404082179030610,
--18,11001,2,1,5,4,4,,
549758551507,
--19,10007,1,1,0,0,0,,
550804390676,
--20,12,500,1,0,0,0,,
2404291889332437,
--21,3,100000,1,5,4,4,,
549839700118,
--22,2,40,1,0,0,0,,
2404082178966615,
--23,10001,2,1,5,4,4,,
549758947608,
--24,16196,1,1,0,0,0,,
550804390681,
--25,12,500,1,0,0,0,,
2404291889332442,
--26,3,100000,1,5,4,4,,
549839700123,
--27,2,40,1,0,0,0,,
3002216504540764,
--28,11001,2,1,5,5,5,,
549758947677,
--29,16197,1,1,0,0,0,,
550804390686,
--30,12,500,1,0,0,0,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=24,[25]=25,[26]=26,[27]=27,[28]=28,[29]=29,[30]=30,
}
local L_NamesByNum = {
   Day = 1,
   ItemId = 2,
   ItemNum = 3,
   IsBind = 4,
   RealmType = 5,
   Realmpara = 6,
   RealRatio = 7,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   Day = 0,
   ItemId = 1,
   ItemNum = 2,
   IsBind = 3,
   RealmType = 4,
   Realmpara = 5,
   RealRatio = 6,
}
--local L_ColumnUseBitCount = {6,15,18,2,4,4,4,}
--local L_ColumnList = {1,1,1,1,1,1,1,}
--local L_ShiftDataList = {0,6,21,39,41,45,49,}
--local L_AndDataList = {31,16383,131071,1,7,7,7,}
local L_ColumnShiftAndList = {1,0,31,1,6,16383,1,21,131071,1,39,1,1,41,7,1,45,7,1,49,7,}
local L_ColNum = 7;
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
    Count = 30
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
