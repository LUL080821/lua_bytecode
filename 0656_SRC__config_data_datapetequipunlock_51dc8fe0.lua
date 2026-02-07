--The file is automatically generated, please do not modify it manually. From the data file:pet_equip_unlock
local L_CompressMaxColumn = 2
local L_CompressData = {
3620894258237679577,9724,
--10201,1,1_240,,201,1_240,,
3638908656747161562,9724,
--10202,1,1_240,,202,1_240,,
3656923055256643547,9724,
--10203,1,1_240,,203,1_240,,
3674937453766125532,9724,
--10204,1,1_240,,204,1_240,,
3620894293836975849,9724,
--20201,2,1_400,,201,1_240,,
3638908692346457834,9724,
--20202,2,1_400,,202,1_240,,
3656923090855939819,9724,
--20203,2,1_400,,203,1_240,,
3674937489365421804,9724,
--20204,2,1_400,,204,1_240,,
3627005323474531833,9724,
--30201,3,,1120_1,201,1_240,,
3645019721984013818,9724,
--30202,3,,1120_1,202,1_240,,
3663034120493495803,9724,
--30203,3,,1120_1,203,1_240,,
3681048519002977788,9724,
--30204,3,,1120_1,204,1_240,,
3620894303674998025,9724,
--40201,4,150_300,,201,1_240,,
3638908702184480010,9724,
--40202,4,150_300,,202,1_240,,
3656923100693961995,9724,
--40203,4,150_300,,203,1_240,,
3674937499203443980,9724,
--40204,4,150_300,,204,1_240,,
}
local L_MainKeyDic = {
[10201]=1,[10202]=2,[10203]=3,[10204]=4,[20201]=5,[20202]=6,[20203]=7,[20204]=8,[30201]=9,[30202]=10,[30203]=11,[30204]=12,[40201]=13,[40202]=14,[40203]=15,
[40204]=16,}
local L_NamesByNum = {
   Id = 1,
   Site = 2,
   PartId = 5,
}
local L_NamesByString = {
   SiteUnlock = 3,
   SiteUnlockItem = 4,
   PartUnlock = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Site = 1,
   SiteUnlock = 2,
   SiteUnlockItem = 3,
   PartId = 4,
   PartUnlock = 5,
}
--local L_ColumnUseBitCount = {17,4,16,17,9,15,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,17,21,37,54,0,}
--local L_AndDataList = {65535,7,32767,65535,255,16383,}
local L_ColumnShiftAndList = {1,0,65535,1,17,7,1,21,32767,1,37,65535,1,54,255,2,0,16383,}
local L_ColNum = 6;
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
    Count = 16
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
