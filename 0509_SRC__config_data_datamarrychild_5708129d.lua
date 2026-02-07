--The file is automatically generated, please do not modify it manually. From the data file:marry_child
local L_CompressMaxColumn = 3
local L_CompressData = {
6118384030159121,39891146931080925,44518,
--1,1,1,16004_1,105,755,月儿,6600001,220,35,16011_10;16012_20;16013_30;16014_40,,
6118809231924514,33135747490159844,44521,
--2,2,1,16005_1,201,756,仙儿,6600002,220,29,16021_10;16022_20;16023_30;16024_40,,
6119222085658931,33135747490287429,44524,
--3,3,1,16006_1,205,757,锦儿,6600003,220,29,16031_10;16032_20;16033_30;16034_40,,
6119647287424324,33135747490418553,44527,
--4,4,1,16007_1,301,758,雪儿,6600004,220,29,16041_10;16042_20;16043_30;16044_40,,
6120060141158741,33135747490549677,44530,
--5,5,1,16008_1,305,759,玉儿,6600005,220,29,16051_10;16052_20;16053_30;16054_40,,
6120485342924134,33135747490680801,44533,
--6,6,1,16009_1,401,760,灵儿,6600006,220,29,16061_10;16062_20;16063_30;16064_40,,
6120898196658551,33135747490811925,44536,
--7,7,1,16010_1,405,761,宝儿,6600007,220,29,16071_10;16072_20;16073_30;16074_40,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,}
local L_NamesByNum = {
   Id = 1,
   Sort = 2,
   Activation = 3,
   Condition = 5,
   Model = 8,
   UiScale = 9,
   UiModelHeight = 10,
}
local L_NamesByString = {
   ItemCondition = 4,
   Icon = 6,
   ChildName = 7,
   SkillId = 11,
}
local L_ColNameIndexs = {
   Id = 0,
   Sort = 1,
   Activation = 2,
   ItemCondition = 3,
   Condition = 4,
   Icon = 5,
   ChildName = 6,
   Model = 7,
   UiScale = 8,
   UiModelHeight = 9,
   SkillId = 10,
}
--local L_ColumnUseBitCount = {4,4,2,17,10,17,17,24,9,7,17,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,3,}
--local L_ShiftDataList = {0,4,8,10,27,37,0,17,41,50,0,}
--local L_AndDataList = {7,7,1,65535,511,65535,65535,8388607,255,63,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,7,1,8,1,1,10,65535,1,27,511,1,37,65535,2,0,65535,2,17,8388607,2,41,255,2,50,63,3,0,65535,}
local L_ColNum = 11;
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
    Count = 7
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
