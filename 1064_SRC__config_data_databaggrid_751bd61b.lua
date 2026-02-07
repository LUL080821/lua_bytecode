--The file is automatically generated, please do not modify it manually. From the data file:bag_grid
local L_CompressMaxColumn = 1
local L_CompressData = {
717395743841,
--1121,1,121,3600,10,,
717395760226,
--1122,1,122,3600,10,,
717395776611,
--1123,1,123,3600,10,,
717395792996,
--1124,1,124,3600,10,,
717395809381,
--1125,1,125,3600,10,,
717395825766,
--1126,1,126,3600,10,,
717395842151,
--1127,1,127,3600,10,,
717395858536,
--1128,1,128,3600,10,,
717395874921,
--1129,1,129,3600,10,,
717395891306,
--1130,1,130,3600,10,,
717395907691,
--1131,1,131,3600,10,,
717395924076,
--1132,1,132,3600,10,,
717395940461,
--1133,1,133,3600,10,,
717395956846,
--1134,1,134,3600,10,,
717395973231,
--1135,1,135,3600,10,,
717395989616,
--1136,1,136,3600,10,,
717396006001,
--1137,1,137,3600,10,,
717396022386,
--1138,1,138,3600,10,,
717396038771,
--1139,1,139,3600,10,,
717396055156,
--1140,1,140,3600,10,,
717396071541,
--1141,1,141,3600,10,,
717396087926,
--1142,1,142,3600,10,,
717396104311,
--1143,1,143,3600,10,,
717396120696,
--1144,1,144,3600,10,,
717396137081,
--1145,1,145,3600,10,,
717396153466,
--1146,1,146,3600,10,,
717396169851,
--1147,1,147,3600,10,,
717396186236,
--1148,1,148,3600,10,,
717396202621,
--1149,1,149,3600,10,,
717396219006,
--1150,1,150,3600,10,,
717396235391,
--1151,1,151,3600,10,,
717396251776,
--1152,1,152,3600,10,,
717396268161,
--1153,1,153,3600,10,,
717396284546,
--1154,1,154,3600,10,,
717396300931,
--1155,1,155,3600,10,,
717396317316,
--1156,1,156,3600,10,,
717396333701,
--1157,1,157,3600,10,,
717396350086,
--1158,1,158,3600,10,,
717396366471,
--1159,1,159,3600,10,,
717396382856,
--1160,1,160,3600,10,,
717396399241,
--1161,1,161,3600,10,,
717396415626,
--1162,1,162,3600,10,,
717396432011,
--1163,1,163,3600,10,,
717396448396,
--1164,1,164,3600,10,,
717396464781,
--1165,1,165,3600,10,,
717396481166,
--1166,1,166,3600,10,,
717396497551,
--1167,1,167,3600,10,,
717396513936,
--1168,1,168,3600,10,,
717396530321,
--1169,1,169,3600,10,,
717396546706,
--1170,1,170,3600,10,,
717396563091,
--1171,1,171,3600,10,,
717396579476,
--1172,1,172,3600,10,,
717396595861,
--1173,1,173,3600,10,,
717396612246,
--1174,1,174,3600,10,,
717396628631,
--1175,1,175,3600,10,,
717396645016,
--1176,1,176,3600,10,,
717396661401,
--1177,1,177,3600,10,,
717396677786,
--1178,1,178,3600,10,,
717396694171,
--1179,1,179,3600,10,,
717396710556,
--1180,1,180,3600,10,,
}
local L_MainKeyDic = {
[1121]=1,[1122]=2,[1123]=3,[1124]=4,[1125]=5,[1126]=6,[1127]=7,[1128]=8,[1129]=9,[1130]=10,[1131]=11,[1132]=12,[1133]=13,[1134]=14,[1135]=15,
[1136]=16,[1137]=17,[1138]=18,[1139]=19,[1140]=20,[1141]=21,[1142]=22,[1143]=23,[1144]=24,[1145]=25,[1146]=26,[1147]=27,[1148]=28,[1149]=29,[1150]=30,
[1151]=31,[1152]=32,[1153]=33,[1154]=34,[1155]=35,[1156]=36,[1157]=37,[1158]=38,[1159]=39,[1160]=40,[1161]=41,[1162]=42,[1163]=43,[1164]=44,[1165]=45,
[1166]=46,[1167]=47,[1168]=48,[1169]=49,[1170]=50,[1171]=51,[1172]=52,[1173]=53,[1174]=54,[1175]=55,[1176]=56,[1177]=57,[1178]=58,[1179]=59,[1180]=60,
}
local L_NamesByNum = {
   BagGrid = 1,
   Bag = 2,
   Grid = 3,
   Time = 4,
   Cost = 5,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   BagGrid = 0,
   Bag = 1,
   Grid = 2,
   Time = 3,
   Cost = 4,
}
--local L_ColumnUseBitCount = {12,2,9,13,5,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,12,14,23,36,}
--local L_AndDataList = {2047,1,255,4095,15,}
local L_ColumnShiftAndList = {1,0,2047,1,12,1,1,14,255,1,23,4095,1,36,15,}
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
    Count = 60
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
