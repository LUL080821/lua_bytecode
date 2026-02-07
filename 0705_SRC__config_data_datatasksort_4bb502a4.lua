--The file is automatically generated, please do not modify it manually. From the data file:TaskSort
local L_CompressMaxColumn = 1
local L_CompressData = {
164800,
--0,30,10,Main,       //主线,,
984321,
--1,40,60,Daily,      //日常,,
659202,
--2,120,40,Guild,      //公会,,
823363,
--3,130,50,Branch,     //支线,,
1480324,
--4,180,90,BianJing,   //边境任务,,
32805,
--5,1,2,ZhuanZhi,   //转职任务,,
1152006,
--6,160,70,TanBao,     //探宝,,
1316167,
--7,170,80,JunXian,    //军衔,,
1644488,
--8,190,100,ZhanChang,  //战场任务,,
1808649,
--9,200,110,Prompt,     //提示性任务 9,,
971435,
--11,149,59,NewBranch = 11,   //新支线任务 11,,
3430988,
--12,210,209,HuSong,     //护送任务,,
}
local L_MainKeyDic = {
[0]=1,[1]=2,[2]=3,[3]=4,[4]=5,[5]=6,[6]=7,[7]=8,[8]=9,[9]=10,[11]=11,[12]=12,}
local L_NamesByNum = {
   TaskType = 1,
   NotFinishValue = 2,
   FinishValue = 3,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   TaskType = 0,
   NotFinishValue = 1,
   FinishValue = 2,
}
--local L_ColumnUseBitCount = {5,9,9,}
--local L_ColumnList = {1,1,1,}
--local L_ShiftDataList = {0,5,14,}
--local L_AndDataList = {15,255,255,}
local L_ColumnShiftAndList = {1,0,15,1,5,255,1,14,255,}
local L_ColNum = 3;
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
    Count = 12
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
