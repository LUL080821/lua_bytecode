--The file is automatically generated, please do not modify it manually. From the data file:Tips
local L_CompressMaxColumn = 1
local L_CompressData = {
211905,
--1,Chơi game không quá 180 phút mỗi ngày, chú ý giữ gìn sức khỏe!,,
1962882,
--2,Thế giới Lạc Thần Chiến Ca cho phép người chơi từ do giao dịch qua hệ thống chợ!,,
1962819,
--3,Boss Dã Ngoại sẽ xuất hiện ở các bản đồ luyện cấp, người chơi và đồng đội kết thúc sau cùng sẽ nhận thưởng.,,
1652836,
--4,Hoàn thành nhiệm vụ hằng ngày nhận điểm năng động có thể nhận được những phần thưởng hấp dẫn!,,
1962757,
--5,Nếu gặp khó khăn hãy liên hệ Lạc Nhi ở Facebook nhé!,,
1963302,
--6,Chơi game vui vẻ, văn hóa nhé các đồng tộc!,,
1654791,
--7,Lưu ý KHÍ sẽ cạn dần theo thời gian và nhận ít EXP hơn, nên hãy thu xếp các nhiệm vụ hợp lý!,,
684520,
--8,Lạc Thần Chiến Ca không chỉ là game, đó là Khúc Trường Ca Của Nguồn Cuội.,,
527305,
--9,Lòng người hiểm ác, cẩn thận khi giao dịch mua bán nhé!,,
403690,
--10,Phạm tội sẽ bị đày ra Đảo. Giảm giữ và cải tạo trong thời gian nhất định.,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,}
local L_NamesByNum = {
   Id = 1,
}
local L_NamesByString = {
   Tips = 2,
}
local L_ColNameIndexs = {
   Id = 0,
   Tips = 1,
}
--local L_ColumnUseBitCount = {5,17,}
--local L_ColumnList = {1,1,}
--local L_ShiftDataList = {0,5,}
--local L_AndDataList = {15,65535,}
local L_ColumnShiftAndList = {1,0,15,1,5,65535,}
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
    Count = 10
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
