--The file is automatically generated, please do not modify it manually. From the data file:new_active_advantage
local L_CompressMaxColumn = 2
local L_CompressData = {
239694167611508,709185116961954698,
--116,完成续充,1,1,93_360,10003_1_1_9;16003_1_1_9;1017_50_1_0,1,完成续充{0}灵玉/{1}灵玉,2580000,,
110651875201136,338402307400326023,
--112,万妖卷层数达到10,1,1,35_10,1017_60_1_9;10001_5_1_9;3_100000_1_9,2,通关万妖卷第一章{0}/{1}层,1231100,,
241360614918769,44282948656487299,
--113,装备强化等级达到30,1,1,20_30,1017_120_1_9;10001_10_1_9;3_200000_1_9,3,强化总等级达到{0}/{1},161100,,
241343435047539,333152141055679359,
--115,穿戴6件5阶红1星以上品质的装备,1,1,15_5_7_1_6,1017_30_1_9;10001_2_1_9;3_60000_1_9,4,穿戴6件5阶红1以上品质的装备{0}/{1},1212000,,
191513224477301,55250577129266044,
--117,次日登录,1,1,7_2,1017_50_1_9;10001_3_1_9;3_80000_1_9,6,登录天数达到{0}/{1},201000,,
5464585427,117826575225,
--211,总任务进度,1,2,,2310471_1_1_9,1,完成所有任务领取【永久灵章】,,,
190796032044665,16492792236923766,
--121,低级婚礼,2,1,149_1_1,50001_1_1_9;1052_5_1_9;16101_5_1_9;3_50000_1_9,1,完成【永结同心】婚礼{0}/{1},60000,,
190813211912314,16492792230763379,
--122,中级婚礼,2,1,149_2_1,50001_6_1_9;1052_10_1_9;16101_10_1_9;3_100000_1_9,2,完成【金玉良缘】婚礼{0}/{1},60000,,
190826096812667,16492792224602992,
--123,高级婚礼,2,1,149_3_1,50001_24_1_9;1052_20_1_9;16101_20_1_9;3_200000_1_9,3,完成【神仙眷侣】婚礼{0}/{1},60000,,
5531694301,117803506542,
--221,总任务进度,2,2,,30309_1_1_9,1,完成三档婚礼可免费领取绝版称号,,,
}
local L_MainKeyDic = {
[116]=1,[112]=2,[113]=3,[115]=4,[117]=5,[211]=6,[121]=7,[122]=8,[123]=9,[221]=10,}
local L_NamesByNum = {
   Id = 1,
   ActiveType = 3,
   Type = 4,
   Sort = 7,
   FunctionId = 9,
}
local L_NamesByString = {
   DesignDesc = 2,
   Value = 5,
   Reward = 6,
   Desc = 8,
}
local L_ColNameIndexs = {
   Id = 0,
   DesignDesc = 1,
   ActiveType = 2,
   Type = 3,
   Value = 4,
   Reward = 5,
   Sort = 6,
   Desc = 7,
   FunctionId = 8,
}
--local L_ColumnUseBitCount = {9,17,3,3,17,17,4,17,23,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,9,26,29,32,0,17,21,38,}
--local L_AndDataList = {255,65535,3,3,65535,65535,7,65535,4194303,}
local L_ColumnShiftAndList = {1,0,255,1,9,65535,1,26,3,1,29,3,1,32,65535,2,0,65535,2,17,7,2,21,65535,2,38,4194303,}
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
    Count = 10
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
