--The file is automatically generated, please do not modify it manually. From the data file:new_sever_luckcard
local L_CompressMaxColumn = 2
local L_CompressData = {
293868144422106881,88648136426857947,
--1,达成首充,129_1,120,1044,首充,完成首充{0}/{1},1,1,2580000,,
290241955076847410,7043757802956020,
--2,购买畅游周卡,95_4_1,600,1031,特权卡,购买畅游月卡{0}/{1},1,1,205000,,
294543794323666787,7043757803054324,
--3,购买尊享月卡,95_5_1,1760,1046,特权卡,购买至尊月卡{0}/{1},1,1,205000,,
291701556769011604,6975038326416625,
--4,购买成长基金,130_27_1,1360,1036,成长基金,购买成长基金{0}/{1},1,1,203000,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,}
local L_NamesByNum = {
   Id = 1,
   Reward = 4,
   ShowIcon = 5,
   IsDouble = 8,
   IsRecommend = 9,
   JumpFunction = 10,
}
local L_NamesByString = {
   Desc = 2,
   Condition = 3,
   ShowName = 6,
   Name = 7,
}
local L_ColNameIndexs = {
   Id = 0,
   Desc = 1,
   Condition = 2,
   Reward = 3,
   ShowIcon = 4,
   ShowName = 5,
   Name = 6,
   IsDouble = 7,
   IsRecommend = 8,
   JumpFunction = 9,
}
--local L_ColumnUseBitCount = {4,16,16,12,12,15,16,2,2,23,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,2,}
--local L_ShiftDataList = {0,4,20,36,48,0,15,31,33,35,}
--local L_AndDataList = {7,32767,32767,2047,2047,16383,32767,1,1,4194303,}
local L_ColumnShiftAndList = {1,0,7,1,4,32767,1,20,32767,1,36,2047,1,48,2047,2,0,16383,2,15,32767,2,31,1,2,33,1,2,35,4194303,}
local L_ColNum = 10;
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
