--The file is automatically generated, please do not modify it manually. From the data file:free_newshop
local L_CompressMaxColumn = 3
local L_CompressData = {
362976452785,11343272012,1659407,
--1,16_2500_1_9;70057_1_1_9;1362_1_1_0;1363_1_1_1;1362_1_1_2;1363_1_1_3;60089_1_1_9,1,终身V4,,6200093_0;6200095_1;6520019_2;6200121_3,200_51_-89_-4_58_188_0;150_51_-89_-4_28_154_1;130_50_-81_-85_21_144_2;220_51_-89_-4_19_273_3,,1_980,1,3,,
5775272943362306,180503049705545,1659414,
--2,1140_1_1_0;1141_1_1_1;1206_1_1_2;1207_1_1_3;;1142_1_1_0;1143_1_1_1;1208_1_1_2;1209_1_1_3;12_1280_1_9;50002_1_1_9;3_1000000_1_9,0,绝版时装,tex_n_w_quanefan_2,6200092_6200093_0;6200094_6200095_1;6510006_6520019_2;6200120_6200121_3,250_0_180_0_-40_53_0;250_0_180_0_-40_53_1;250_0_180_0_-40_53_2;250_0_180_0_-40_53_3,涨20000战力,1_1280,1,3,,
5777472000172419,180571770212891,2249246,
--3,17022_1_1_9;12_1980_1_9;16003_10_1_9;81005_5_1_9,0,可爱萌宠,tex_n_w_quanefan_3,6000022_9,400_0_180_0_-51_-74_9,涨30000战力,1_1980,2,4,,
5779396174881268,180640490607138,2839078,
--4,15025_1_1_9;12_2560_1_9;15114_1_1_9;60002_30_1_9,0,炫酷法宝,tex_n_w_quanefan_4,6100027_9,500_-6_180_0_-22_116_9,涨120000战力,1_2560,3,5,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,}
local L_NamesByNum = {
   Id = 1,
   Type = 3,
   OpenTime = 10,
   Time = 11,
}
local L_NamesByString = {
   Item = 2,
   Name = 4,
   TitleTex = 5,
   ModelId = 6,
   Pos = 7,
   Desc = 8,
   Price = 9,
}
local L_ColNameIndexs = {
   Id = 0,
   Item = 1,
   Type = 2,
   Name = 3,
   TitleTex = 4,
   ModelId = 5,
   Pos = 6,
   Desc = 7,
   Price = 8,
   OpenTime = 9,
   Time = 10,
}
--local L_ColumnUseBitCount = {4,16,2,16,16,17,16,16,16,3,4,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,3,3,3,}
--local L_ShiftDataList = {0,4,20,22,38,0,17,33,0,16,19,}
--local L_AndDataList = {7,32767,1,32767,32767,65535,32767,32767,32767,3,7,}
local L_ColumnShiftAndList = {1,0,7,1,4,32767,1,20,1,1,22,32767,1,38,32767,2,0,65535,2,17,32767,2,33,32767,3,0,32767,3,16,3,3,19,7,}
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
