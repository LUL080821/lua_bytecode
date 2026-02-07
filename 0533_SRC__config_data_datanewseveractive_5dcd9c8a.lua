--The file is automatically generated, please do not modify it manually. From the data file:new_sever_active
local L_CompressMaxColumn = 2
local L_CompressData = {
572227083060325,156363690399,
--101,1,1,,50_1,创建1个宗派,,60001_1,,
1280965406393446,47383089570,
--102,1,2,,51_2,任命2个副宗主,,60002_1,,
1281034125886567,156384661924,
--103,1,3,,52_20,宗派成员到达20个,,60003_1,,
1281137205118056,156397244839,
--104,1,4,,52_30,宗派成员到达30个,,60004_1,,
1281240284349545,156363690410,
--105,1,5,,53_2,宗派等级到达2级,,60001_1,,
1281309003842666,156363690412,
--106,1,6,,53_3,宗派等级到达3级,,60001_1,,
1281377723238601,156363690414,
--201,2,1,,19_3,境界到达开光级,,60001_1,,
1281446442731722,47383089584,
--202,2,2,,19_4,境界到达灵虚级,,60002_1,,
1281515162224843,156384661938,
--203,2,3,,19_5,境界到达灵寂级,,60003_1,,
1281583881717964,156398555572,
--204,2,4,,19_6,境界到达结丹级,10,60004_1,,
1281652601211085,156363690422,
--205,2,5,,19_7,境界到达金丹级,,60001_1,,
1281721320704206,156363690424,
--206,2,6,,19_8,境界到达元婴级,,60001_1,,
572708119399725,156363690425,
--301,3,1,,54_1,完成普通结婚,,60001_1,,
1281824399854894,47383089595,
--302,3,2,,54_2,完成豪华结婚,,60002_1,,
1281893119348015,156384661949,
--303,3,3,,54_3,完成奢华结婚,,60003_1,,
1281961838841136,156398555583,
--304,3,4,,54_4,前10个完成奢华结婚,10,60004_1,,
1281387504095633,156363690433,
--401,4,1,6_0,19_3,联盟争霸中霸主的宗主,,60001_1,,
1281446442733970,47383089602,
--402,4,2,,19_4,联盟争霸中积分排名1领取,,60002_1,,
1281515162227091,156384661955,
--403,4,3,,19_5,联盟争霸中积分排名2-5领取,,60003_1,,
1281583881720212,156397244868,
--404,4,4,,19_6,联盟争霸中积分排名6-30领取,,60004_1,,
1281652601213333,156363690437,
--405,4,5,,19_7,联盟争霸中非霸主的宗派领取,,60001_1,,
1281721320706454,156363690438,
--406,4,6,,19_8,联盟争霸中霸主宗派成员领取,,60001_1,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[201]=7,[202]=8,[203]=9,[204]=10,[205]=11,[206]=12,[301]=13,[302]=14,[303]=15,
[304]=16,[401]=17,[402]=18,[403]=19,[404]=20,[405]=21,[406]=22,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Sort = 3,
   LimitTime = 7,
}
local L_NamesByString = {
   SpecialCondition = 4,
   Condition = 5,
   Des = 6,
   Item = 8,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Sort = 2,
   SpecialCondition = 3,
   Condition = 4,
   Des = 5,
   LimitTime = 6,
   Item = 7,
}
--local L_ColumnUseBitCount = {10,4,4,17,17,17,5,17,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,10,14,18,35,0,17,22,}
--local L_AndDataList = {511,7,7,65535,65535,65535,15,65535,}
local L_ColumnShiftAndList = {1,0,511,1,10,7,1,14,7,1,18,65535,1,35,65535,2,0,65535,2,17,15,2,22,65535,}
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
    Count = 22
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
