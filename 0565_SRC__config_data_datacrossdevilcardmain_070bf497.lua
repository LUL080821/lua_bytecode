--The file is automatically generated, please do not modify it manually. From the data file:Cross_devil_card_Main
local L_CompressMaxColumn = 2
local L_CompressData = {
670214624903508929,16614332098,
--1,蓝,烦魔,1,tex_icon_fanmo,tex_n_mohun_touxiang_4,1730,,10,14,,
670214625306162306,16614332099,
--2,蓝,行魔,1,tex_icon_xingmo,tex_n_mohun_touxiang_4,1731,,10,14,,
670214625574597891,16614332097,
--3,蓝,病魔,1,tex_icon_bingmo,tex_n_mohun_touxiang_4,1729,,10,14,,
670214625843033476,16614332108,
--4,蓝,天子魔,1,tex_icon_tianzimo,tex_n_mohun_touxiang_4,1740,,10,14,,
670372955794257413,16614332100,
--5,紫,死魔,2,tex_icon_simo,tex_n_mohun_touxiang_3,1732,,10,14,,
670372956196910790,16614332103,
--6,紫,罪魔,2,tex_icon_zuimo,tex_n_mohun_touxiang_3,1735,,10,14,,
670372956465346375,16614332102,
--7,紫,阴魔,2,tex_icon_yinmo,tex_n_mohun_touxiang_3,1734,,10,14,,
670372956733781960,16614332101,
--8,紫,业魔,2,tex_icon_yemo,tex_n_mohun_touxiang_3,1733,,10,14,,
670531286685005897,16614332106,
--9,金,混沌,3,tex_icon_hundun,tex_n_mohun_touxiang_2,1738,,10,14,,
670531287087659274,16614332105,
--10,金,穷奇,3,tex_icon_qiongqi,tex_n_mohun_touxiang_2,1737,,10,14,,
670531287356094859,16614332107,
--11,金,梼杌,3,tex_icon_taowu,tex_n_mohun_touxiang_2,1739,,10,14,,
670531287489219724,16614332104,
--12,金,饕餮,3,tex_icon_taotie,tex_n_mohun_touxiang_2,1736,,10,14,,
670672025255492173,16614332110,
--13,红,蚩尤,4,tex_icon_chiyou,tex_n_mohun_touxiang_1,1742,,10,14,,
670672025658145550,16614332111,
--14,红,刑天,4,tex_icon_xingtian,tex_n_mohun_touxiang_1,1743,,10,14,,
670672025926581135,16614332112,
--15,红,烛阴,4,tex_icon_zhuyin,tex_n_mohun_touxiang_1,1744,,10,14,,
670672026195016720,16614332109,
--16,红,波旬,4,tex_icon_boxun,tex_n_mohun_touxiang_1,1741,,10,14,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,
[16]=16,}
local L_NamesByNum = {
   Id = 1,
   Camp = 3,
   TabIcon = 6,
   Notice = 8,
}
local L_NamesByString = {
   Name = 2,
   Icon = 4,
   IconFrame = 5,
   Condition = 7,
   Chatchannel = 9,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Camp = 2,
   Icon = 3,
   IconFrame = 4,
   TabIcon = 5,
   Condition = 6,
   Notice = 7,
   Chatchannel = 8,
}
--local L_ColumnUseBitCount = {6,17,4,17,17,12,2,5,16,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,2,}
--local L_ShiftDataList = {0,6,23,27,44,0,12,14,19,}
--local L_AndDataList = {31,65535,7,65535,65535,2047,1,15,32767,}
local L_ColumnShiftAndList = {1,0,31,1,6,65535,1,23,7,1,27,65535,1,44,65535,2,0,2047,2,12,1,2,14,15,2,19,32767,}
local L_ColNum = 9;
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
