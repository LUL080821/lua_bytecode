--The file is automatically generated, please do not modify it manually. From the data file:immortal_soul_core
local L_CompressMaxColumn = 2
local L_CompressData = {
382951769170497,765935903354406,
--1,轩辕之力,1857,技能激活增加战斗力：[FFC300]108516[-]#n激活技能可获属性：#n生命:248542 防御:4638,当前剑灵灵魄品质都为[FF0000]红色[-]可激活,7_7,7_0,,
382986131006082,766004622831146,
--2,东皇之力,1858,技能激活增加战斗力：[FFC300]108537[-]#n激活技能可获属性：#n攻击:9277 破甲:4638,当前剑灵所有灵魄品质都为[FF0000]红色[-]，且拥有至少[00FF00]3个[-]二星灵魄,7_7,7_0;3_2,,
382951773364931,766056162438701,
--3,龙渊之力,1859,技能激活增加战斗力：[FFC300]108516[-]#n激活技能可获属性：#n生命:248542 防御:4638,当前剑灵所有灵魄品质都为[FF0000]红色[-]，且拥有至少[00FF00]7个[-]二星灵魄,7_7,7_2,,
382986135200500,766107702046256,
--4,瑶姬之力,1860,技能激活增加战斗力：[FFC300]108537[-]#n激活技能可获属性：#n攻击:9277 破甲:4638,当前剑灵所有灵魄品质都为[FF0000]红色[-]，且拥有至少[00FF00]3个[-]三星灵魄,7_7,7_0;3_3,,
383072036643621,766176421522996,
--5,太阿之力,1861,技能激活增加战斗力：[FFC300]144688[-]#n激活技能可获属性：#n生命:331390 防御:6184,当前剑灵所有灵魄品质都为[FF0000]红色[-]，且拥有至少[00FF00]5个[-]三星灵魄,7_7,7_0;5_3,,
383106398479206,766245140999736,
--6,巨阙之力,1862,技能激活增加战斗力：[FFC300]144713[-]#n激活技能可获属性：#n攻击:12369 破甲:6184,当前剑灵所有灵魄品质都为[FF0000]红色[-]，且拥有至少[00FF00]7个[-]三星灵魄,7_7,7_3,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   ID = 1,
   Icon = 3,
}
local L_NamesByString = {
   Name = 2,
   NoactiveDes = 4,
   ActiveCondition = 5,
   Quality = 6,
   Star = 7,
}
local L_ColNameIndexs = {
   ID = 0,
   Name = 1,
   Icon = 2,
   NoactiveDes = 3,
   ActiveCondition = 4,
   Quality = 5,
   Star = 6,
}
--local L_ColumnUseBitCount = {4,17,12,17,17,17,17,}
--local L_ColumnList = {1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,4,21,33,0,17,34,}
--local L_AndDataList = {7,65535,2047,65535,65535,65535,65535,}
local L_ColumnShiftAndList = {1,0,7,1,4,65535,1,21,2047,1,33,65535,2,0,65535,2,17,65535,2,34,65535,}
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
