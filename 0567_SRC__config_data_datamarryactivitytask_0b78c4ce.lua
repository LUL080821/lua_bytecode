--The file is automatically generated, please do not modify it manually. From the data file:marry_activity_task
local L_CompressMaxColumn = 3
local L_CompressData = {
95398382672229,73088386189143432,44425,
--101,1,[010101]永结同心[-],5,149_1_1,[010101]完成【永结同心】婚礼[-][752900]{0}/{1}[-],,60000,1,50001_5_1_9;12_888_1_9,,
95406972610918,73088386189143436,44425,
--102,1,[010101]金玉良缘[-],5,149_2_1,[010101]完成【金玉良缘】婚礼[-][752900]{0}/{1}[-],,60000,1,50001_5_1_9;12_888_1_9,,
95413415064935,73088386189143439,44425,
--103,1,[010101]神仙眷侣[-],5,149_3_1,[010101]完成【神仙眷侣】婚礼[-][752900]{0}/{1}[-],,60000,1,50001_5_1_9;12_888_1_9,,
66596331995496,107121707042647441,44425,
--104,1,[010101]萍水相逢[-],5,86_1,[010101]拥有[-][752900]{0}/{1}[-][010101]个好友[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95424152488297,107121707042647441,44425,
--105,1,[010101]合作无间[-],5,86_5,[010101]拥有[-][752900]{0}/{1}[-][010101]个好友[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95428447457642,107121707042647441,44425,
--106,1,[010101]亲朋挚友[-],5,86_10,[010101]拥有[-][752900]{0}/{1}[-][010101]个好友[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95432742426987,107121707042647448,44425,
--107,1,[010101]一面之缘[-],5,76_520,[010101]仙侣亲密度达到[-][752900]{0}/{1}[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95439184881004,107121707042647448,44425,
--108,1,[010101]泛泛之交[-],5,76_1314,[010101]仙侣亲密度达到[-][752900]{0}/{1}[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95443479850349,107121707042647448,44425,
--109,1,[010101]天作之合[-],5,76_3344,[010101]仙侣亲密度达到[-][752900]{0}/{1}[-],,2041000,1,50001_5_1_9;12_888_1_9,,
95447774819694,73103848071409055,44425,
--110,1,[010101]两情相悦[-],5,79_1,[010101]为TA购买[-][752900]{0}/{1}[-][010101]次爱情宝匣[-],,60900,1,50001_5_1_9;12_888_1_9,,
35788531597679,73110720019082657,44425,
--111,1,[010101]开枝散叶[-],5,80_1,[010101]激活[-][752900]{0}/{1}[-][010101]个仙娃[-],,61300,1,50001_5_1_9;12_888_1_9,,
95458512243056,73110720019082657,44425,
--112,1,[010101]金玉满堂[-],5,80_2,[010101]激活[-][752900]{0}/{1}[-][010101]个仙娃[-],,61300,1,50001_5_1_9;12_888_1_9,,
95462807212401,73110720019082657,44425,
--113,1,[010101]阖家欢乐[-],5,80_3,[010101]激活[-][752900]{0}/{1}[-][010101]个仙娃[-],,61300,1,50001_5_1_9;12_888_1_9,,
95467102181746,73107284045245864,44425,
--114,1,[010101]与君相知[-],5,209_30304_1,[010101]激活【与君相知】称号[-][752900]{0}/{1}[-],,61100,1,50001_5_1_9;12_888_1_9,,
95473544635763,73107284045245867,44425,
--115,1,[010101]鱼水之欢[-],5,209_30305_1,[010101]激活【鱼水之欢】称号[-][752900]{0}/{1}[-],,61100,1,50001_5_1_9;12_888_1_9,,
95479987089780,73107284045245870,44425,
--116,1,[010101]相濡以沫[-],5,209_30306_1,[010101]激活【相濡以沫】称号[-][752900]{0}/{1}[-],,61100,1,50001_5_1_9;12_888_1_9,,
2147484789,864691134282989569,44464,
--117,0,,,,,6600007_9_200_0_180_0_25_27,,12,16010_1_1_9,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[107]=7,[108]=8,[109]=9,[110]=10,[111]=11,[112]=12,[113]=13,[114]=14,[115]=15,
[116]=16,[117]=17,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   Sort = 4,
   RelationUI = 8,
   Rate = 9,
}
local L_NamesByString = {
   Name = 3,
   Condition = 5,
   Des = 6,
   Showmodel = 7,
   Reward = 10,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Name = 2,
   Sort = 3,
   Condition = 4,
   Des = 5,
   Showmodel = 6,
   RelationUI = 7,
   Rate = 8,
   Reward = 9,
}
--local L_ColumnUseBitCount = {8,2,17,4,17,17,17,22,5,17,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,3,}
--local L_ShiftDataList = {0,8,10,27,31,0,17,34,56,0,}
--local L_AndDataList = {127,1,65535,7,65535,65535,65535,2097151,15,65535,}
local L_ColumnShiftAndList = {1,0,127,1,8,1,1,10,65535,1,27,7,1,31,65535,2,0,65535,2,17,65535,2,34,2097151,2,56,15,3,0,65535,}
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
    Count = 17
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
