--The file is automatically generated, please do not modify it manually. From the data file:HuaxingFlySword_skill
local L_CompressMaxColumn = 2
local L_CompressData = {
29413127872170113,53503,
--1,剑灵·恢复,90019,1,1_4,[00ff00]轩辕剑灵[-]培养至[00ff00]4阶[-]可以激活,,
22235034929973410,53504,
--2,剑灵·攻击,90020,2,2_7,[00ff00]任意2个剑灵[-]都培养到[00ff00]7阶[-]可以激活,,
29414845859612867,53506,
--3,剑灵·暴击,90021,2,3_10,[00ff00]任意3个剑灵[-]都培养到[00ff00]10阶[-]可以激活,,
8584598071658724,53507,
--4,剑灵·破甲,90022,2,4_12,[00ff00]任意4个剑灵[-]都培养到[00ff00]12阶[-]可以激活,,
29416495127578885,53509,
--5,剑灵·灵攻,90023,2,5_15,[00ff00]任意5个剑灵[-]都培养到[00ff00]15阶[-]可以激活,,
8718188734957862,53510,
--6,剑灵·豁免,90024,2,6_18,[00ff00]任意6个剑灵[-]都培养到[00ff00]18阶[-]可以激活,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   Id = 1,
   PassiveSkill = 3,
   Type = 4,
}
local L_NamesByString = {
   Name = 2,
   ActivePram = 5,
   Des = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   PassiveSkill = 2,
   Type = 3,
   ActivePram = 4,
   Des = 5,
}
--local L_ColumnUseBitCount = {4,14,18,3,17,17,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,4,18,36,39,0,}
--local L_AndDataList = {7,8191,131071,3,65535,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,8191,1,18,131071,1,36,3,1,39,65535,2,0,65535,}
local L_ColNum = 6;
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
    Count = 6
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
