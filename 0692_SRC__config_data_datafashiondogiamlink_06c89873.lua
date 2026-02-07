--The file is automatically generated, please do not modify it manually. From the data file:fashion_dogiam_link
local L_CompressMaxColumn = 2
local L_CompressData = {
1602735556262609409,2246908287752567885,
--200000001,Ma Quỷ,0_3001;1_3002;2_3003;3_3004;4_3005,1,1_100000031;2_100000032;3_100000033;4_100000034;5_100000035,2_5_20;3_3_15;5_19_800,1_10293;2_275762;3_5146,1_5293;2_145762;3_2546,,
1589224756306756098,2231989886348524533,
--200000002,Yêu Tinh,0_3006;1_3007;2_3008;3_3009;4_3010,1,1_100000036;2_100000037;3_100000038;4_100000039;5_100000040,2_2_600;3_65_200;67_15_300,63_10293;2_275762;3_5146,63_5293;2_145762;3_2546,,
}
local L_MainKeyDic = {
[200000001]=1,[200000002]=2,}
local L_NamesByNum = {
   Id = 1,
   Quality = 4,
}
local L_NamesByString = {
   Name = 2,
   Icon = 3,
   NeedFashionId = 5,
   RentAtt = 6,
   ActivationAtt = 7,
   StarAtt = 8,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Icon = 2,
   Quality = 3,
   NeedFashionId = 4,
   RentAtt = 5,
   ActivationAtt = 6,
   StarAtt = 7,
}
--local L_ColumnUseBitCount = {29,16,15,2,16,14,16,16,}
--local L_ColumnList = {1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,29,45,60,0,16,30,46,}
--local L_AndDataList = {268435455,32767,16383,1,32767,8191,32767,32767,}
local L_ColumnShiftAndList = {1,0,268435455,1,29,32767,1,45,16383,1,60,1,2,0,32767,2,16,8191,2,30,32767,2,46,32767,}
local L_ColNum = 8;
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
    Count = 2
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
