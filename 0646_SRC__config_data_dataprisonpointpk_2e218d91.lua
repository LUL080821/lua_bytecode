--The file is automatically generated, please do not modify it manually. From the data file:prison_point_pk
local L_CompressMaxColumn = 2
local L_CompressData = {
19792953712641,1,
--1,Bình thường,Không hiển thị,0,9,,0,,
217747995860946,6651,
--2,Có tội,Bị PK không tăng sát khí,10,99,n_skfire_25_spr,0,,
438036867424147,23018,
--3,Truy nã,Icon đỏ, tên đổi màu,100,199,n_skfire_50_spr,1,,
660567708769940,23015,
--4,Tội đồ,Ra khỏi thành chính bị NPC bắt,200,300,n_skfire_100_spr,1,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,}
local L_NamesByNum = {
   Id = 1,
   PointMin = 4,
   PointMax = 5,
   Notify = 7,
}
local L_NamesByString = {
   Name = 2,
   Desc = 3,
   Icon = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Desc = 2,
   PointMin = 3,
   PointMax = 4,
   Icon = 5,
   Notify = 6,
}
--local L_ColumnUseBitCount = {4,14,14,9,10,14,2,}
--local L_ColumnList = {1,1,1,1,1,2,2,}
--local L_ShiftDataList = {0,4,18,32,41,0,14,}
--local L_AndDataList = {7,8191,8191,255,511,8191,1,}
local L_ColumnShiftAndList = {1,0,7,1,4,8191,1,18,8191,1,32,255,1,41,511,2,0,8191,2,14,1,}
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
    Count = 4
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
