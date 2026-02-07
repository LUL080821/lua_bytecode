--The file is automatically generated, please do not modify it manually. From the data file:SoulArmor_awaken
local L_CompressMaxColumn = 2
local L_CompressData = {
1320784032768,110101,
--0,0,83094_1,1_0;2_0,,110101,,,
15550867492893729,110101,
--1,1,83094_1,1_1310;2_35111,29_100,110101,,,
15554166128443458,372245,
--2,2,83094_2,1_3276;2_87777,30_100,110101,1,,
15550867660669027,110201,
--3,3,83094_2,1_5897;2_157999,29_100,110201,,,
15554166229106820,110201,
--4,4,83094_2,1_9174;2_245777,30_100,110201,,,
15550867761337509,372345,
--5,5,83094_3,1_13105;2_351110,29_100,110201,1,,
15554166329775302,110301,
--6,6,83094_3,1_17692;2_473999,30_100,110301,,,
15550867828446439,110301,
--7,7,83094_3,1_22935;2_614444,29_100,110301,,,
15554166430442760,372445,
--8,8,83094_4,1_28832;2_772444,30_100,110301,1,,
15550867929113897,110401,
--9,9,83094_4,1_35385;2_947999,29_100,110401,,,
15554166497551690,110401,
--10,10,83094_4,1_42594;2_1141110,30_100,110401,,,
15550868029781355,372545,
--11,11,83094_5,1_50457;2_1351777,29_100,110401,1,,
15554166598219148,110501,
--12,12,83094_5,1_58976;2_1579999,30_100,110501,,,
15550868096890285,110501,
--13,13,83094_5,1_68150;2_1825776,29_100,110501,,,
15554166650832334,372645,
--14,14,,1_77980;2_2089110,30_100,110501,1,,
}
local L_MainKeyDic = {
[0]=1,[1]=2,[2]=3,[3]=4,[4]=5,[5]=6,[6]=7,[7]=8,[8]=9,[9]=10,[10]=11,[11]=12,[12]=13,[13]=14,[14]=15,
}
local L_NamesByNum = {
   Id = 1,
   Level = 2,
   Skill = 6,
   JudgeOpenSkill = 7,
}
local L_NamesByString = {
   Consume = 3,
   LevelValue = 4,
   ExtraValue = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   Level = 1,
   Consume = 2,
   LevelValue = 3,
   ExtraValue = 4,
   Skill = 5,
   JudgeOpenSkill = 6,
}
--local L_ColumnUseBitCount = {5,5,15,15,15,18,2,}
--local L_ColumnList = {1,1,1,1,1,2,2,}
--local L_ShiftDataList = {0,5,10,25,40,0,18,}
--local L_AndDataList = {15,15,16383,16383,16383,131071,1,}
local L_ColumnShiftAndList = {1,0,15,1,5,15,1,10,16383,1,25,16383,1,40,16383,2,0,131071,2,18,1,}
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
