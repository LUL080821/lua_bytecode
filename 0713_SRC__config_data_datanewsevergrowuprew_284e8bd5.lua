--The file is automatically generated, please do not modify it manually. From the data file:new_sever_growuprew
local L_CompressMaxColumn = 2
local L_CompressData = {
90072620752974337,4865261569,
--1,800,1010_1_1_9,18,320,,tex_n_cz_left_top5,0,,
90101895250599362,4865261569,
--2,1500,17004_1_1_9,870,320,,tex_n_cz_left_top5,0,,
90144226448538883,4865822978,
--3,2000,60078_1_1_9,2102,320,cd_zhenxi,tex_n_cz_left_top2,0,,
90144054650649476,4865822978,
--4,3000,60079_1_1_9,2097,320,cd_zhenxi,tex_n_cz_left_top2,0,,
90076022368974981,4866216194,
--5,5000,19007_1_1_9,117,320,cd_zhenxi,tex_n_cz_left_top3,0,,
90082963036681606,22046310401,
--6,7000,15006_1_1_9,319,320,,tex_n_cz_left_top4,1,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,}
local L_NamesByNum = {
   Id = 1,
   Scroe = 2,
   LockPic = 4,
   OpenPic = 5,
   IsModel = 8,
}
local L_NamesByString = {
   Item = 3,
   ShowWord = 6,
   ShowTexture = 7,
}
local L_ColNameIndexs = {
   Id = 0,
   Scroe = 1,
   Item = 2,
   LockPic = 3,
   OpenPic = 4,
   ShowWord = 5,
   ShowTexture = 6,
   IsModel = 7,
}
--local L_ColumnUseBitCount = {4,14,17,13,10,17,17,2,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,4,18,35,48,0,17,34,}
--local L_AndDataList = {7,8191,65535,4095,511,65535,65535,1,}
local L_ColumnShiftAndList = {1,0,7,1,4,8191,1,18,65535,1,35,4095,1,48,511,2,0,65535,2,17,65535,2,34,1,}
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
