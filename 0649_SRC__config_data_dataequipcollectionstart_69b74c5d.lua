--The file is automatically generated, please do not modify it manually. From the data file:Equip_Collection_start
local L_CompressMaxColumn = 2
local L_CompressData = {
6237877254005861,17592320272603,
--101,1,5,60072_1,2_100,Ghi Chép Bạo Kích,,,,,
15171134351860838,17592320272603,
--102,1,15,60072_1,1_10;63_10,Ghi Chép Bạo Kích,,,,,
15170859474035815,17592320272603,
--103,1,25,60072_1,4_20;64_20,Ghi Chép Bạo Kích,,,,,
15170584596210792,17592320272603,
--104,1,35,60072_1,2_700;1_70;63_70,Ghi Chép Bạo Kích,,,,,
15170309718385769,17592320272603,
--105,1,45,60072_1,5_100;19_200,Ghi Chép Bạo Kích,,,,,
15170034840519786,17592320272603,
--106,1,50,60072_1,45_200;47_200;48_200;49_200,Ghi Chép Bạo Kích,,,,,
15169687053026503,970832193846126811,
--199,1,50,,19_1000;66_2000,Ghi Chép Bạo Kích,347,Bạo Kích Cổ Ngữ,Cổ ngữ ghi chép nhiều kinh nghiệm quý báu cho con cháu. #n#nSau khi thu thập đủ bộ sẽ kích hoạt: [00FF00]Tỉ lệ chí mạng +10%, Sát thương chí mạng +20%#n,,
15168935352002761,17592320296927,
--201,2,55,60073_1,2_1200;6_200,Ghi Chép Đề Kháng,,,,,
13984211573115082,17592320296927,
--202,2,60,60073_1,3_400;8_500,Ghi Chép Đề Kháng,,,,,
10621080381696203,17592320296927,
--203,2,65,60073_1,1_900;63_900;67_3000,Ghi Chép Đề Kháng,,,,,
9562250684188876,17592320296927,
--204,2,70,60073_1,6_400;4_200;64_200,Ghi Chép Đề Kháng,,,,,
9561975806322893,17592320296927,
--205,2,75,60073_1,2_2000;6_350;5_300;3_600,Ghi Chép Đề Kháng,,,,,
9561700928456910,17592320296927,
--206,2,80,60073_1,19_500;66_4500;67_4500,Ghi Chép Đề Kháng,,,,,
9561353117935915,611860899031582687,
--299,2,85,,50_500;52_500;53_500;54_500,Ghi Chép Đề Kháng,349,Đề Kháng Cổ Ngữ,Cổ ngữ Lạc Việt ghi chép nhiều phương pháp cường thân bảo vệ trước tự nhiên. #n#nSau khích hoạt có thể kháng  [00ff00]20% Tất cả sát thương nguyên tố[-],,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[199]=7,[201]=8,[202]=9,[203]=10,[204]=11,[205]=12,[206]=13,[299]=14,}
local L_NamesByNum = {
   Id = 1,
   Grade = 2,
   Level = 3,
   Icon = 7,
}
local L_NamesByString = {
   Needitem = 4,
   Attribute = 5,
   Name = 6,
   Skillname = 8,
   Des = 9,
}
local L_ColNameIndexs = {
   Id = 0,
   Grade = 1,
   Level = 2,
   Needitem = 3,
   Attribute = 4,
   Name = 5,
   Icon = 6,
   Skillname = 7,
   Des = 8,
}
--local L_ColumnUseBitCount = {10,3,8,17,17,17,10,17,17,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,10,13,21,38,0,17,27,44,}
--local L_AndDataList = {511,3,127,65535,65535,65535,511,65535,65535,}
local L_ColumnShiftAndList = {1,0,511,1,10,3,1,13,127,1,21,65535,1,38,65535,2,0,65535,2,17,511,2,27,65535,2,44,65535,}
local L_ColNum = 9;
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
    Count = 14
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
