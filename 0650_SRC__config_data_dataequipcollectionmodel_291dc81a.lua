--The file is automatically generated, please do not modify it manually. From the data file:EquipCollectionModel
local L_CompressMaxColumn = 1
local L_CompressData = {
2586112001,
--1,10102000,,
2586112002,
--2,10102000,,
2586112003,
--3,10102000,,
2586112004,
--4,10102000,,
2586112005,
--5,10102000,,
2586112006,
--6,10102000,,
2586112007,
--7,10102000,,
2586112008,
--8,10102000,,
2586112009,
--9,10102000,,
2586112010,
--10,10102000,,
2586112011,
--11,10102000,,
2586112012,
--12,10102000,,
2586112013,
--13,10102000,,
2586112014,
--14,10102000,,
2586112015,
--15,10102000,,
2586112016,
--16,10102000,,
2588672101,
--101,10112000,,
2588672102,
--102,10112000,,
2588672103,
--103,10112000,,
2588672104,
--104,10112000,,
2588672105,
--105,10112000,,
2588672106,
--106,10112000,,
2588672107,
--107,10112000,,
2588672108,
--108,10112000,,
2588672109,
--109,10112000,,
2588672110,
--110,10112000,,
2588672111,
--111,10112000,,
2588672112,
--112,10112000,,
2588672113,
--113,10112000,,
2588672114,
--114,10112000,,
2588672115,
--115,10112000,,
2588672116,
--116,10112000,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,[101]=17,[102]=18,[103]=19,[104]=20,[105]=21,[106]=22,[107]=23,[108]=24,[109]=25,[110]=26,[111]=27,[112]=28,[113]=29,[114]=30,
[115]=31,[116]=32,}
local L_NamesByNum = {
   Id = 1,
   Model = 2,
}
local L_NamesByString = {
}
local L_ColNameIndexs = {
   Id = 0,
   Model = 1,
}
--local L_ColumnUseBitCount = {8,25,}
--local L_ColumnList = {1,1,}
--local L_ShiftDataList = {0,8,}
--local L_AndDataList = {127,16777215,}
local L_ColumnShiftAndList = {1,0,127,1,8,16777215,}
local L_ColNum = 2;
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
