--The file is automatically generated, please do not modify it manually. From the data file:sevenday_login
local L_CompressMaxColumn = 3
local L_CompressData = {
223244301176465,1457851517220337242,169723612,
--1,1001_1_1_9;3_100000_1_9;1017_50_1_9,1_珍稀,1,6200100_0;6200102_1;6510027_2;6200124_3,大吉大利·衣,0_155_0_0;0_160_0_1;0_155_0_2;0_160_0_3,-50_-15_0,220,3,三日送时装,,
1187928328179442,1457851517220337242,169723100,
--2,1010_1_1_9;2069_1_1_9;3_200000_1_9;1017_50_1_9,2_直升,1_2,6200100_0;6200102_1;6510027_2;6200124_3,大吉大利·衣,0_155_0_0;0_160_0_1;0_155_0_2;0_160_0_3,-50_-15_0,220,2,三日送时装,,
223244320050979,1457851517220337242,169722588,
--3,1148_1_1_0;1149_1_1_1;1214_1_1_2;1215_1_1_3;60002_2_1_9;3_300000_1_9;1017_50_1_9,1_绝版,1,6200100_0;6200102_1;6510027_2;6200124_3,大吉大利·衣,0_155_0_0;0_160_0_1;0_155_0_2;0_160_0_3,-50_-15_0,220,1,三日送时装,,
223244301176644,1458555215401530966,169814236,
--4,81065_1_1_0;81066_1_1_1;81065_1_1_2;81066_1_1_3;60002_4_1_9;3_400000_1_9;1017_50_1_9,1_珍稀,1,6200101_0;6200103_1;6520021_2;6200125_3,大吉大利·武,-50_93_69_0;-40_90_90_1;-36_93_68_2;-36_93_-179_3,-80_183_0,220,4,七日送武器,,
223244301176741,1458555215401530966,169813724,
--5,3007101_1_1_9;1011_3_1_9;3_400000_1_9;1017_50_1_9,1_珍稀,1,6200101_0;6200103_1;6520021_2;6200125_3,大吉大利·武,-50_93_69_0;-40_90_90_1;-36_93_68_2;-36_93_-179_3,-80_183_0,220,3,七日送武器,,
1187884877287382,1458555215401530966,169813212,
--6,20002_4_1_9;21002_4_1_9;9_1000_1_9;1017_50_1_9,,1_2,6200101_0;6200103_1;6520021_2;6200125_3,大吉大利·武,-50_93_69_0;-40_90_90_1;-36_93_68_2;-36_93_-179_3,-80_183_0,220,2,七日送武器,,
223244320554247,1458555215401530966,169812700,
--7,1150_1_1_0;1151_1_1_1;1216_1_1_2;1217_1_1_3;1011_5_1_9;3_400000_1_9;1017_100_1_9,1_绝版,1,6200101_0;6200103_1;6520021_2;6200125_3,大吉大利·武,-50_93_69_0;-40_90_90_1;-36_93_68_2;-36_93_-179_3,-80_183_0,220,1,七日送武器,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,}
local L_NamesByNum = {
   Day = 1,
   ModelScale = 9,
   RewardDay = 10,
}
local L_NamesByString = {
   Award = 2,
   ShowItemDesc = 3,
   ShowEffect = 4,
   ModelId = 5,
   ModelName = 6,
   ModelRotate = 7,
   ModelPos = 8,
   PanelWord = 11,
}
local L_ColNameIndexs = {
   Day = 0,
   Award = 1,
   ShowItemDesc = 2,
   ShowEffect = 3,
   ModelId = 4,
   ModelName = 5,
   ModelRotate = 6,
   ModelPos = 7,
   ModelScale = 8,
   RewardDay = 9,
   PanelWord = 10,
}
--local L_ColumnUseBitCount = {4,17,16,15,15,15,16,16,9,4,16,}
--local L_ColumnList = {1,1,1,1,2,2,2,2,3,3,3,}
--local L_ShiftDataList = {0,4,21,37,0,15,30,46,0,9,13,}
--local L_AndDataList = {7,65535,32767,16383,16383,16383,32767,32767,255,7,32767,}
local L_ColumnShiftAndList = {1,0,7,1,4,65535,1,21,32767,1,37,16383,2,0,16383,2,15,16383,2,30,32767,2,46,32767,3,0,255,3,9,7,3,13,32767,}
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
