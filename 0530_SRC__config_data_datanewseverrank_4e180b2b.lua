--The file is automatically generated, please do not modify it manually. From the data file:new_sever_rank
local L_CompressMaxColumn = 7
local L_CompressData = {
5192976395932873345,583933948695580708,1153463959604452,1147969305351840,20287793578319072,5788002216576600,56086,
--1,0,101,2,2,250,100_50,修炼狂人,tex_firstrecharge3,tex_n_b_juese17,经验试炼,1037,1232100,掌门传道,1049,2660000,鸿蒙悟道,1044,204000,全服排名活动结束后通过邮件发放,1_2_3,1,10101,10101,10,0_14,,
5193961558350869384,586748475124387876,1148355322497476,9629608,8844626312036352,5788002216674905,56086,
--8,0,103,3,1,250,100_50,一骑当先,tex_firstrecharge3,tex_n_b_juese17,天禁之门,1042,1231300,绑玉商城,1044,1241000,,,,全服排名活动结束后通过邮件发放,7_8_9,2,10501,10101,10,0_14,,
5194524508304323844,587883257023598628,1136105144643696,8412708,20293291136253952,5788053756519122,56086,
--4,0,106,4,1,250,100_50,炼器宗师,tex_firstrecharge3,tex_n_b_juese17,灵玉商城,1044,1241200,装备熔炼,1033,24100,,,,全服排名活动结束后通过邮件发放,10_11_12,3,10701,10201,10,0_14,,
5195650408211200645,582242848272453668,1134770535106912,1148355323736176,20297689184006056,5788088116512341,56086,
--5,0,117,5,1,250,100_50,御宠天尊,tex_firstrecharge3,tex_n_b_juese17,天道秘境,1034,2460000,天芒鬼城,1032,2470000,绑玉商城,1044,1241000,全服排名活动结束后通过邮件发放,13_14_15,4,10901,10301,10,0_14,,
5196776308118075654,579998556061601828,1147971341181584,10938608,20338371112992768,5788401651549779,56086,
--6,0,114,6,1,250,100_50,五光十色,tex_firstrecharge3,tex_n_b_juese17,仙盟首领,1030,58000,机缘寻宝,1044,2550000,,,,全服排名活动结束后通过邮件发放,16_17_18,5,11101,10401,10,0_14,,
5207190882256401159,580001493819232292,1147971342333584,10938608,20342219403689984,5788015104765990,56086,
--7,0,102,7,1,250,100_50,器化融神,tex_firstrecharge3,tex_n_b_juese17,首领,1030,1210000,机缘寻宝,1044,2550000,,,,全服排名活动结束后通过邮件发放,19_20_21,6,11301,10501,10,0_14,,
}
local L_MainKeyDic = {
[1]=1,[8]=2,[4]=3,[5]=4,[6]=5,[7]=6,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Parm = 3,
   ServerEndTime = 4,
   Time = 5,
   RewRank = 6,
   Icon1 = 12,
   Path1 = 13,
   Icon2 = 15,
   Path2 = 16,
   Icon3 = 18,
   Path3 = 19,
   Notice = 25,
}
local L_NamesByString = {
   ShowFakeRanke = 7,
   Showname = 8,
   DesTexture = 9,
   ShowTexture = 10,
   Iconname1 = 11,
   Iconname2 = 14,
   Iconname3 = 17,
   Des = 20,
   OpenLimitShop = 21,
   OpenLimitShop2 = 22,
   LimitShopCondition = 23,
   LimitShopCondition2 = 24,
   Chatchannel = 26,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Parm = 2,
   ServerEndTime = 3,
   Time = 4,
   RewRank = 5,
   ShowFakeRanke = 6,
   Showname = 7,
   DesTexture = 8,
   ShowTexture = 9,
   Iconname1 = 10,
   Icon1 = 11,
   Path1 = 12,
   Iconname2 = 13,
   Icon2 = 14,
   Path2 = 15,
   Iconname3 = 16,
   Icon3 = 17,
   Path3 = 18,
   Des = 19,
   OpenLimitShop = 20,
   OpenLimitShop2 = 21,
   LimitShopCondition = 22,
   LimitShopCondition2 = 23,
   Notice = 24,
   Chatchannel = 25,
}
--local L_ColumnUseBitCount = {5,2,8,4,3,9,16,17,17,17,15,12,23,17,12,23,17,12,22,17,17,15,17,17,5,17,}
--local L_ColumnList = {1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,7,}
--local L_ShiftDataList = {0,5,7,15,19,22,31,47,0,17,34,49,0,23,40,0,23,40,0,22,39,0,15,32,49,0,}
--local L_AndDataList = {15,1,127,7,3,255,32767,65535,65535,65535,16383,2047,4194303,65535,2047,4194303,65535,2047,2097151,65535,65535,16383,65535,65535,15,65535,}
local L_ColumnShiftAndList = {1,0,15,1,5,1,1,7,127,1,15,7,1,19,3,1,22,255,1,31,32767,1,47,65535,2,0,65535,2,17,65535,2,34,16383,2,49,2047,3,0,4194303,3,23,65535,3,40,2047,4,0,4194303,4,23,65535,4,40,2047,5,0,2097151,5,22,65535,5,39,65535,6,0,16383,6,15,65535,6,32,65535,6,49,15,7,0,65535,}
local L_ColNum = 26;
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
