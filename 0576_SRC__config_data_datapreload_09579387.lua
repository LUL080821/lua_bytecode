--The file is automatically generated, please do not modify it manually. From the data file:Preload
local L_CompressMaxColumn = 1
local L_CompressData = {
34146625,
--1,5,UINewPublicAtlas,0,,
34148674,
--2,5,UINewPublicAtlas_1,0,,
34150723,
--3,5,UINewPublicAtlas_2,0,,
34152772,
--4,5,UINewMenuiconAtlas,0,,
34154821,
--5,5,UILoginAtlas,0,,
34156934,
--6,6,UINewMainFont,0,,
34158983,
--7,6,UINewTitleFont,0,,
34161032,
--8,6,UINewButtonFont,0,,
34165321,
--9,9,UIHUDForm,0,,
34167370,
--10,9,UIGuideForm,0,,
34169099,
--11,4,tex_n_b_denglu,0,,
34171148,
--12,4,tex_logo2,0,,
34173581,
--13,10,snd_map_login,0,,
34175182,
--14,3,map037,0,,
34177295,
--15,4,tex_n_d_2,0,,
34179344,
--16,4,tex_n_d_3,0,,
34181457,
--17,5,UINewAnimationAtlas,0,,
34183506,
--18,5,UINewAnimationAtlas_1,0,,
34186003,
--19,12,snd_player_00,0,,
34188052,
--20,12,snd_player_01,0,,
60044245,
--21,15,UINpcTalkForm,0,,
60982230,
--22,15,UIWardrobeForm,0,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   AddFormRoot = 4,
}
local L_NamesByString = {
   Path = 3,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Path = 2,
   AddFormRoot = 3,
}
--local L_ColumnUseBitCount = {6,5,16,2,}
--local L_ColumnList = {1,1,1,1,}
--local L_ShiftDataList = {0,6,11,27,}
--local L_AndDataList = {31,15,32767,1,}
local L_ColumnShiftAndList = {1,0,31,1,6,15,1,11,32767,1,27,1,}
local L_ColNum = 4;
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
