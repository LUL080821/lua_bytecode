--The file is automatically generated, please do not modify it manually. From the data file:AuctionMenu
local L_CompressMaxColumn = 1
local L_CompressData = {
211110394371521,
--1,Tất cả,,-1,-1,,-1,,
211108381104258,
--2,Trang bị nam,,0,0,,-1,,
214580870551555,
--3,Mũ,2,0,0,0,-1,,
214593755453316,
--4,Vũ khí,2,0,0,1,-1,,
214595902615557,
--5,Áo,2,0,0,2,-1,,
230248910925766,
--6,Dây chuyền,2,0,0,3,-1,,
214587312680839,
--7,Bao tay,2,0,0,4,-1,,
214583017713480,
--8,Khố,2,0,0,5,-1,,
237576125132553,
--9,Giày,2,0,0,6,-1,,
237526733008586,
--10,Nhẫn,2,0,0,7,-1,,
243438755491467,
--11,Ngọc bội,2,0,0,11,-1,,
246236926684748,
--12,Túi thơm,2,0,0,12,-1,,
211108917653005,
--13,Trang bị nữ,,0,1,,-1,,
214581453559822,
--14,Mũ,13,0,1,0,-1,,
214594338461583,
--15,Vũ khí,13,0,1,1,-1,,
214596485623824,
--16,Áo,13,0,1,2,-1,,
230249493934033,
--17,Dây chuyền,13,0,1,3,-1,,
214587895689106,
--18,Bao tay,13,0,1,4,-1,,
214583600721747,
--19,Khố,13,0,1,5,-1,,
237576708140820,
--20,Giày,13,0,1,6,-1,,
237527316016853,
--21,Nhẫn,13,0,1,7,-1,,
243439338499734,
--22,Ngọc bội,13,0,1,11,-1,,
246237509693015,
--23,Túi thơm,13,0,1,12,-1,,
211109051870680,
--24,Đồ giám,,1,1,,-1,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=24,}
local L_NamesByNum = {
   Id = 1,
   ParentId = 3,
   EquipOrItem = 4,
   EquipOcc = 5,
   ItemTradeType = 7,
}
local L_NamesByString = {
   Name = 2,
   EquipPart = 6,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   ParentId = 2,
   EquipOrItem = 3,
   EquipOcc = 4,
   EquipPart = 5,
   ItemTradeType = 6,
}
--local L_ColumnUseBitCount = {6,16,5,2,2,15,2,}
--local L_ColumnList = {1,1,1,1,1,1,1,}
--local L_ShiftDataList = {0,6,22,27,29,31,46,}
--local L_AndDataList = {31,32767,15,1,1,16383,1,}
local L_ColumnShiftAndList = {1,0,31,1,6,32767,1,22,15,1,27,1,1,29,1,1,31,16383,1,46,1,}
local L_ColNum = 7;
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
    Count = 24
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
