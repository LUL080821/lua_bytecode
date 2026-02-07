--The file is automatically generated, please do not modify it manually. From the data file:xianmengzhengba
local L_CompressMaxColumn = 2
local L_CompressData = {
4374553351545804901,104857752497,
--101,加入仙盟,1,11_1,10001_5_1_9;12_2000_1_9,1,[010101]加入仙盟[-][158720]({0}/{1})[-],50000,,
4374462563478956134,2734686360514,
--102,在仙盟拍卖行上架一次商品,1,230_1,10001_5_1_9;3_500000_1_9,2,[010101]在仙盟拍卖行上架一次商品[-][158720]({0}/{1})[-],1304000,,
4374321822769372263,118069810627,
--103,完成五次仙盟任务,1,32_5,10001_5_1_9;2_50_1_9,3,[010101]完成五次仙盟任务[-][158720]({0}/{1})[-],56300,,
4374295343222247528,121635708660,
--104,参与一次仙盟首领击杀,1,142_1,10001_5_1_9;2_50_1_9,4,[010101]参与一次仙盟首领击杀[-][158720]({0}/{1})[-],58000,,
4374181076825295049,119538551921,
--201,参与仙盟战作为盟主摧毁上古意志,2,232_1,10004_5_1_9;2_200_1_9;30901_1_1_9,1,[010101]在仙盟战中以盟主身份获得天仙仙盟第一名[-][158720]({0}/{1})[-],57000,,
4374040342558162122,119538556754,
--202,参与仙盟战并成功摧毁上古意志,2,231_1,10004_3_1_9;2_100_1_9;11001_5_1_9,2,[010101]参与仙盟战并成功摧毁上古意志[-][158720]({0}/{1})[-],57000,,
4373857114958300363,119538556803,
--203,参与一次仙盟战,2,137_1,10004_2_1_9;2_50_1_9;16001_5_1_9,3,[010101]参与仙盟战[-][158720]({0}/{1})[-],57000,,
4373708975180497200,465778317745,
--304,8个部位穿戴圣装,3,236_8,81003_2_1_9;15_2000_1_9;2_50_1_9,1,[010101]8个部位穿戴圣装[-][158720]({0}/{1})[-],222100,,
4373618035738021169,465778317714,
--305,10个部位穿戴圣装,3,236_10,81003_4_1_9;15_4000_1_9;2_100_1_9,2,[010101]10个部位穿戴圣装[-][158720]({0}/{1})[-],222100,,
4373477370190361906,465988067475,
--306,圣装强化总等级达到10级,3,233_10,15_6000_1_9;16001_5_1_9;2_50_1_9,3,[010101]圣装强化总等级达到10级[-][158720]({0}/{1})[-],222200,,
4373336639144459571,465777720500,
--307,激活一个5阶金色以上斗心,3,234_5_6_1,83105_1_1_0;83106_1_1_1;16001_10_1_9;2_100_1_9,4,[010101]激活5阶金色以上斗心[-][158720]({0}/{1})[-],222100,,
4373195820051651892,466197782741,
--308,合成一个5阶以上圣装,3,235_5_1,16001_10_1_9;3_200000_1_9;2_50_1_9,5,[010101]合成一个5阶以上红色圣装[-][158720]({0}/{1})[-],222300,,
4372747125866725685,465778347142,
--309,圣装系统战力达到50000,3,131_50000,83105_1_1_0;83106_1_1_1;16001_10_1_9;2_50_1_9,6,[010101]圣装战力达到50000[-][158720]({0}/{1})[-],222100,,
4364306892359823670,465778347159,
--310,圣装系统战力达到210000,3,131_210000,83117_1_1_0;83118_1_1_1;16001_20_1_9;2_100_1_9,7,[010101]圣装战力达到210000[-][158720]({0}/{1})[-],222100,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[201]=5,[202]=6,[203]=7,[304]=8,[305]=9,[306]=10,[307]=11,[308]=12,[309]=13,[310]=14,}
local L_NamesByNum = {
   Id = 1,
   ActiveType = 3,
   Sort = 6,
   FunctionId = 8,
}
local L_NamesByString = {
   DesignDesc = 2,
   Value = 4,
   Reward = 5,
   Desc = 7,
}
local L_ColNameIndexs = {
   Id = 0,
   DesignDesc = 1,
   ActiveType = 2,
   Value = 3,
   Reward = 4,
   Sort = 5,
   Desc = 6,
   FunctionId = 7,
}
--local L_ColumnUseBitCount = {10,17,3,17,16,4,17,22,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,10,27,30,47,0,4,21,}
--local L_AndDataList = {511,65535,3,65535,32767,7,65535,2097151,}
local L_ColumnShiftAndList = {1,0,511,1,10,65535,1,27,3,1,30,65535,1,47,32767,2,0,7,2,4,65535,2,21,2097151,}
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
