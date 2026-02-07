--The file is automatically generated, please do not modify it manually. From the data file:sdkplatform
local L_CompressMaxColumn = 2
local L_CompressData = {
2381736855709975629,1,
--1101,CNY,CN,¥,1,国内测试内网,,
2382159074617590961,14,
--1201,SGD,SG,S$,14,新加坡,,
2382581293525206293,7,
--1301,VND,VIE,₫,7,越南,,
2383003512432821625,11,
--1401,THB,TH,฿,11,泰国安卓,,
2383425731340436957,4,
--1501,KRW,KR,₩,4,韩国,,
2383847950248052289,3403,
--1601,TWD,TW,NT$,3403,台湾,,
2384129425224861250,3401,
--1602,MO,TW,MOP$,3401,澳门,,
2384410900201637443,3399,
--1603,HK,TW,HK$,3399,香港,,
2384833127699154597,15,
--1701,IDR,IN,Rp,15,印尼,,
2385255346606769929,5,
--1801,JPY,JP,￥,5,日本,,
2385677565514385261,166,
--1901,USD,EN,$,166,美国,,
2386099784422000593,0,
--2001,EUR,EU,€,,欧洲,,
2381720652945859369,1,
--9001,CNY,QQ,¥,1,QQ大厅,,
}
local L_MainKeyDic = {
[1101]=1,[1201]=2,[1301]=3,[1401]=4,[1501]=5,[1601]=6,[1602]=7,[1603]=8,[1701]=9,[1801]=10,[1901]=11,[2001]=12,[9001]=13,}
local L_NamesByNum = {
   Id = 1,
   Region = 5,
}
local L_NamesByString = {
   MoneyCode = 2,
   Chanel = 3,
   MoneySign = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   MoneyCode = 1,
   Chanel = 2,
   MoneySign = 3,
   Region = 4,
}
--local L_ColumnUseBitCount = {15,16,16,16,13,}
--local L_ColumnList = {1,1,1,1,2,}
--local L_ShiftDataList = {0,15,31,47,0,}
--local L_AndDataList = {16383,32767,32767,32767,4095,}
local L_ColumnShiftAndList = {1,0,16383,1,15,32767,1,31,32767,1,47,32767,2,0,4095,}
local L_ColNum = 5;
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
    Count = 13
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
