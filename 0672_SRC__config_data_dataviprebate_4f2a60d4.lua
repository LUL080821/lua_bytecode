--The file is automatically generated, please do not modify it manually. From the data file:VipRebate
local L_CompressMaxColumn = 2
local L_CompressData = {
18851608277093,8658275556,
--101,[782b10]达到{0}级[-],1_175,1,0,1232100,1032,,
22726695100518,8658253456,
--102,[782b10]战力达到{0}[-],3_300000,1,0,1210000,1032,,
18842299836519,8875197264,
--103,[782b10]加入仙盟[-],11_1,1,0,50000,1058,,
21775628363880,8707433104,
--104,[782b10]参加{0}仙盟首领[-],142_1,1,0,58000,1038,,
25413353376873,8884745872,
--105,[782b10]击杀二层以上世界BOSS{0}次[-],87_1_5,1,0,1210000,1059,,
18873841066090,8774654968,
--106,[782b10]坐骑达到3阶[-],38_3,1,0,171000,1046,,
21807303734379,8867808656,
--107,[782b10]竞技场累计{0}次[-],40_10,1,0,1050000,1057,,
25101590661228,8741090836,
--108,[782b10]穿戴5阶红1星以上装备3件[-],55_5_7_1_3,1,0,161300,1042,,
28465452815104201,8658275556,
--201,[782b10]达到级{0}[-],1_210,2,101,1232100,1032,,
28750769055768778,8658253456,
--202,[782b10]战力达到{0}[-],3_500000,2,102,1210000,1032,,
42694179699915,8884748872,
--203,[782b10]击杀VIP首领{0}次[-],87_16_5,2,0,1213000,1059,,
38653288946892,8767326460,
--204,[782b10]通关万妖卷{0}层[-],35_15,2,0,1231100,1045,,
42694448137421,8741091636,
--205,[782b10]全身宝石等级达到{0}级[-],22_20,2,0,162100,1042,,
40846356449486,8774675068,
--206,[782b10]宠物等级达到30级[-],56_30,2,0,191100,1046,,
43012946876623,8741090636,
--207,[782b10]全身强化等级达到{0}[-],20_60,2,0,161100,1042,,
30156063967261904,8867808656,
--208,[782b10]竞技场累计{0}次[-],40_15,2,107,1050000,1057,,
56630556362420525,8658275556,
--301,[782b10]达到{0}级[-],1_250,3,201,1232100,1032,,
56918241814421806,8658253456,
--302,[782b10]战力达到{0}[-],3_1000000,3,202,1210000,1032,,
57200025002572079,8884748872,
--303,[782b10]击杀VIP首领{0}[-],87_16_15,3,203,1213000,1059,,
58740580432176,8877158264,
--304,[782b10]添加{0}个好友[-],86_5,3,0,2011000,1058,,
58607091406320945,8867808656,
--305,[782b10]竞技场累计{0}次[-],40_25,3,208,1050000,1057,,
57902356488498,8878017264,
--306,[782b10]世界频道发言{0}次[-],180_1,3,0,2870000,1058,,
58040749905147187,8774675068,
--307,[782b10]宠物等级达到50级[-],56_50,3,206,191100,1046,,
57762975493055796,8741091636,
--308,[782b10]全身宝石达到{0}级[-],22_50,3,205,162100,1042,,
85644725954951569,8885546872,
--401,[782b10]添加{0}个好友[-],86_10,4,304,2011000,1059,,
72550242486674,8682266280,
--402,[782b10]参加一次仙盟战[-],137_1,4,0,57000,1035,,
77179524215187,8809248400,
--403,[782b10]发起{0}次仙盟支援[-],100_3,4,0,1210000,1050,,
78194500610452,8741090836,
--404,[782b10]穿戴7阶5星以上装备3件[-],55_7_7_5_3,4,0,161300,1042,,
74576527535509,17843909216,
--405,[782b10]通关剑灵阁{0}次[-],150_50,4,0,1340000,2127,,
77917475227030,8884751872,
--406,[782b10]击杀套装BOSS{0}次[-],87_3_3,4,0,1216000,1059,,
72556903913879,8884806872,
--407,[782b10]击杀神兽首领BOSS{0}次[-],198_5,4,0,1271000,1059,,
85921481788732824,8867808656,
--408,[782b10]竞技场累计{0}次[-],40_35,4,305,1050000,1057,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[103]=3,[104]=4,[105]=5,[106]=6,[107]=7,[108]=8,[201]=9,[202]=10,[203]=11,[204]=12,[205]=13,[206]=14,[207]=15,
[208]=16,[301]=17,[302]=18,[303]=19,[304]=20,[305]=21,[306]=22,[307]=23,[308]=24,[401]=25,[402]=26,[403]=27,[404]=28,[405]=29,[406]=30,
[407]=31,[408]=32,}
local L_NamesByNum = {
   Id = 1,
   StageType = 4,
   TaskInherit = 5,
   FunctionID = 6,
   IconID = 7,
}
local L_NamesByString = {
   Taskdes = 2,
   VariableId = 3,
}
local L_ColNameIndexs = {
   Id = 0,
   Taskdes = 1,
   VariableId = 2,
   StageType = 3,
   TaskInherit = 4,
   FunctionID = 5,
   IconID = 6,
}
--local L_ColumnUseBitCount = {10,17,17,4,10,23,13,}
--local L_ColumnList = {1,1,1,1,1,2,2,}
--local L_ShiftDataList = {0,10,27,44,48,0,23,}
--local L_AndDataList = {511,65535,65535,7,511,4194303,4095,}
local L_ColumnShiftAndList = {1,0,511,1,10,65535,1,27,65535,1,44,7,1,48,511,2,0,4194303,2,23,4095,}
local L_ColNum = 7;
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
    Count = 32
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
