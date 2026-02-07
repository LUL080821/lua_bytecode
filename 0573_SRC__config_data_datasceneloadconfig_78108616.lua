--The file is automatically generated, please do not modify it manually. From the data file:SceneLoadConfig
local L_CompressMaxColumn = 1
local L_CompressData = {
1067969,
--1,方泽城,map037,,
2688770,
--2,天芒鬼城一层,map009,,
2686147,
--3,天虞之山,map031,,
2686404,
--4,赤北沙海,map032,,
2690629,
--5,无极墟域1层,map007,,
2700742,
--6,仙盟任务副本,map035,,
2696903,
--7,仙盟驻地,map019,,
2686792,
--8,从极之渊,map014,,
2694473,
--9,竞技场,map001,,
2687114,
--10,玄剑峰,map021,,
2693963,
--11,心魔幻境,map023,,
2687436,
--12,不周天墟,map033,,
2693453,
--13,天禁之门,map012,,
2693710,
--14,凌云妖塔,map016,,
2700047,
--15,无极墟域无限层,map011,,
2692880,
--16,万妖卷,map005,,
2693137,
--17,大能遗府,map006,,
2695826,
--18,掌门传道,map029,,
2697299,
--19,天道秘境,map008,,
2848852,
--20,晶甲和域0层,map040,,
2848917,
--21,朱陵福地,map024,,
2694230,
--22,锁灵台,map017,,
2848983,
--23,仙盟战,map036,,
2688216,
--24,年兽封域1层,map034,,
2700505,
--25,混沌之境,map027,,
2692378,
--26,铁匠地图,map013,,
433243,
--27,Prison,map057,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=24,[25]=25,[26]=26,[27]=27,}
local L_NamesByNum = {
   Id = 1,
}
local L_NamesByString = {
   ResName = 2,
}
local L_ColNameIndexs = {
   Id = 0,
   ResName = 1,
}
--local L_ColumnUseBitCount = {6,17,}
--local L_ColumnList = {1,1,}
--local L_ShiftDataList = {0,6,}
--local L_AndDataList = {31,65535,}
local L_ColumnShiftAndList = {1,0,31,1,6,65535,}
local L_ColNum = 2;
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
    Count = 27
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
