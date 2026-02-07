--The file is automatically generated, please do not modify it manually. From the data file:Cross_devil_card_Camp
local L_CompressMaxColumn = 1
local L_CompressData = {
416964947953291921,
--1,蓝,魔兵,1745,1746,305_306_307_308,,,
416991340528374482,
--2,紫,魔将,1747,1748,309_310_311_312,,,
417017733103457027,
--3,金,魔尊,1749,1750,313_314_315_316,,,
417044125678539572,
--4,红,魔主,1751,1752,317_318_319_320,,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,}
local L_NamesByNum = {
   Id = 1,
   NormalIcon = 3,
   SelectIcon = 4,
}
local L_NamesByString = {
   Name = 2,
   PartsList = 5,
   Condition = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   NormalIcon = 2,
   SelectIcon = 3,
   PartsList = 4,
   Condition = 5,
}
--local L_ColumnUseBitCount = {4,15,12,12,15,2,}
--local L_ColumnList = {1,1,1,1,1,1,}
--local L_ShiftDataList = {0,4,19,31,43,58,}
--local L_AndDataList = {7,16383,2047,2047,16383,1,}
local L_ColumnShiftAndList = {1,0,7,1,4,16383,1,19,2047,1,31,2047,1,43,16383,1,58,1,}
local L_ColNum = 6;
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
    Count = 4
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
