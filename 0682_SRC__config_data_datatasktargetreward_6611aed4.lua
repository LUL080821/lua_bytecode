--The file is automatically generated, please do not modify it manually. From the data file:task_target_reward
local L_CompressMaxColumn = 1
local L_CompressData = {
17974476419457,
--1,12,10001_1_1_0;9_100_1_9;12_2000_1_9,0,一阶段,,
17976623899394,
--2,24,10002_1_1_9;9_200_1_9;12_2000_1_9,0,二阶段,,
17978760807843,
--3,45,10003_1_1_9;9_200_1_9;12_2000_1_9,0,三阶段,,
17980949173668,
--4,45,2_200_1_9;9_200_1_9;12_2000_1_9,0,四阶段,,
17983055771045,
--5,45,16001_1_1_9;9_200_1_9;12_2000_1_9,0,五阶段,,
17985203254694,
--6,45,16001_1_1_9;9_200_1_9;12_2000_1_9,0,六阶段,,
17987350734247,
--7,45,16002_1_1_9;9_200_1_9;12_2000_1_9,0,七阶段,,
17988465366440,
--8,45,2_200_1_9;9_200_1_9;12_2000_1_9,0,八阶段,,
17990571959721,
--9,45,16002_1_1_9;9_200_1_9;12_2000_1_9,0,九阶段,,
17991686591914,
--10,45,2_200_1_9;9_200_1_9;12_2000_1_9,0,十阶段,,
17993793177003,
--11,45,16003_1_1_9;9_200_1_9;12_2000_1_9,0,十一阶段,,
17994907817388,
--12,45,2_200_1_9;9_200_1_9;12_2000_1_9,0,十二阶段,,
17997014402477,
--13,45,16003_1_1_9;9_200_1_9;12_2000_1_9,0,十三阶段,,
17998129042862,
--14,45,2_200_1_9;9_200_1_9;12_2000_1_9,0,十四阶段,,
18000504063407,
--15,45,16003_1_1_9;9_200_1_9;12_2000_1_9,1,十五阶段,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
}
local L_NamesByNum = {
   Id = 1,
   NeedNum = 2,
   IfLoop = 4,
}
local L_NamesByString = {
   Reward = 3,
   Stage = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   NeedNum = 1,
   Reward = 2,
   IfLoop = 3,
   Stage = 4,
}
--local L_ColumnUseBitCount = {5,7,16,2,16,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,5,12,28,30,}
--local L_AndDataList = {15,63,32767,1,32767,}
local L_ColumnShiftAndList = {1,0,15,1,5,63,1,12,32767,1,28,1,1,30,32767,}
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
    Count = 15
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
