--The file is automatically generated, please do not modify it manually. From the data file:HuaxingFlySword_Advanced
local L_CompressMaxColumn = 1
local L_CompressData = {
11792399647844544,
--0,1_0_60;2_0_1629;3_0_30;4_0_30,0,18002_10,10,,
23051468064893249,
--1,1_60_80;2_1629_2144;3_30_40;4_30_40,300,18002_20,20,,
45569535550368194,
--2,1_140_160;2_3773_4289;3_70_80;4_70_80,600,18002_30,40,,
68087603035843139,
--3,1_300_241;2_8062_6434;3_150_120;4_150_120,900,18002_40,60,,
90605670521318084,
--4,1_541_320;2_14496_8577;3_270_160;4_270_160,1200,18002_50,80,,
113123738006793029,
--5,1_861_400;2_23073_10722;3_430_200;4_430_200,1500,18002_60,100,,
135641805492267974,
--6,1_1261_480;2_33795_12867;3_630_240;4_630_240,1800,18002_70,120,,
158159872977742919,
--7,1_1741_561;2_46662_15011;3_870_281;4_870_281,2100,18002_80,140,,
180677940463217864,
--8,1_2302_640;2_61673_17155;3_1151_320;4_1151_320,2400,18002_90,160,,
203196007948692809,
--9,1_2942_720;2_78828_19300;3_1471_360;4_1471_360,2700,18002_100,180,,
225714075434167754,
--10,1_3662_801;2_98128_21445;3_1831_400;4_1831_400,3000,18002_110,200,,
248232142919642699,
--11,1_4463_880;2_119573_23588;3_2231_440;4_2231_440,3300,18002_120,220,,
270750210405117644,
--12,1_5343_961;2_143161_25734;3_2671_481;4_2671_481,3600,18002_130,240,,
293268277890592589,
--13,1_6304_1040;2_168895_27877;3_3152_520;4_3152_520,3900,18002_140,260,,
315786345376067534,
--14,1_7344_1121;2_196772_30022;3_3672_560;4_3672_560,4200,18002_150,280,,
338304412861542479,
--15,1_8465_1201;2_226794_32167;3_4232_601;4_4232_601,4500,18002_160,300,,
360822480347017424,
--16,1_9666_1280;2_258961_34310;3_4833_640;4_4833_640,4800,18002_170,320,,
383340547832492369,
--17,1_10946_1361;2_293271_36456;3_5473_680;4_5473_680,5100,18002_180,340,,
405858615317967314,
--18,1_12307_1441;2_329727_38599;3_6153_721;4_6153_721,5400,18002_190,360,,
428376682803442259,
--19,1_13748_1521;2_368326_40745;3_6874_760;4_6874_760,5700,18002_200,380,,
450360009680696020,
--20,1_15269_0;2_409071_0;3_7634_0;4_7634_0,6000,,400,,
}
local L_MainKeyDic = {
[0]=1,[1]=2,[2]=3,[3]=4,[4]=5,[5]=6,[6]=7,[7]=8,[8]=9,[9]=10,[10]=11,[11]=12,[12]=13,[13]=14,[14]=15,
[15]=16,[16]=17,[17]=18,[18]=19,[19]=20,[20]=21,}
local L_NamesByNum = {
   Id = 1,
   AttAllAdd = 3,
   Levelmax = 5,
}
local L_NamesByString = {
   RentAtt = 2,
   ActiveItem = 4,
}
local L_ColNameIndexs = {
   Id = 0,
   RentAtt = 1,
   AttAllAdd = 2,
   ActiveItem = 3,
   Levelmax = 4,
}
--local L_ColumnUseBitCount = {6,15,14,15,10,}
--local L_ColumnList = {1,1,1,1,1,}
--local L_ShiftDataList = {0,6,21,35,50,}
--local L_AndDataList = {31,16383,8191,16383,511,}
local L_ColumnShiftAndList = {1,0,31,1,6,16383,1,21,8191,1,35,16383,1,50,511,}
local L_ColNum = 5;
local L_UseDataK = setmetatable({ },{ __mode = 'k'});
local L_UseDataV = setmetatable({ },{ __mode = 'v'});
local L_UseDataRow = setmetatable({ },{ __mode = 'v'});
local L_IsCache = false;
local mt = {}
local function GetData(row, column)
    local startIndex = (column - 1) * 3
    local _compressData = L_CompressData[row]
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
    Count = 21
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
