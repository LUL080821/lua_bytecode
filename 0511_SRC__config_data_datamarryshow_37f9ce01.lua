--The file is automatically generated, please do not modify it manually. From the data file:marry_show
local L_CompressMaxColumn = 2
local L_CompressData = {
24719597590007825,2041000,
--1,1,1：和异性成为好友,tex_n_b_xianyuanjieshao1,50001_5_1_9;16101_5_1_9;1052_5_1_9,2041000,,
24719597590008610,2041000,
--2,2,2：和一位异性亲密度达到520,tex_n_b_xianyuanjieshao1,50001_5_1_9;16101_5_1_9;1052_5_1_9,2041000,,
24719597657117747,60700,
--3,3,3：发送或接收到金玉良缘或以上的求婚,tex_n_b_xianyuanjieshao3,50001_5_1_9;16101_5_1_9;1052_5_1_9,60700,,
24719597690672708,60100,
--4,4,4：成功缔结一次仙缘,tex_n_b_xianyuanjieshao4,50001_5_1_9;16101_5_1_9;1052_5_1_9,60100,,
24719597724227669,60100,
--5,5,5：成功预约一场婚礼,tex_n_b_xianyuanjieshao5,50001_5_1_9;16101_5_1_9;1052_5_1_9,60100,,
24719597757782630,60700,
--6,6,6：成功举办一场婚礼,tex_n_b_xianyuanjieshao6,50001_5_1_9;16101_5_1_9;1052_5_1_9,60700,,
24731315066100743,0,
--7,0,完成所有任务可领取绝版仙娃【仙儿】,,16005_1_1_9,,,
}
local L_MainKeyDic = {
[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,}
local L_NamesByNum = {
   Id = 1,
   Type = 2,
   OpenFunction = 6,
}
local L_NamesByString = {
   Desc = 3,
   Tex = 4,
   Reward = 5,
}
local L_ColNameIndexs = {
   Id = 0,
   Type = 1,
   Desc = 2,
   Tex = 3,
   Reward = 4,
   OpenFunction = 5,
}
--local L_ColumnUseBitCount = {4,4,16,16,16,22,}
--local L_ColumnList = {1,1,1,1,1,2,}
--local L_ShiftDataList = {0,4,8,24,40,0,}
--local L_AndDataList = {7,7,32767,32767,32767,2097151,}
local L_ColumnShiftAndList = {1,0,7,1,4,7,1,8,32767,1,24,32767,1,40,32767,2,0,2097151,}
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
    Count = 7
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
