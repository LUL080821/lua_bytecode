--The file is automatically generated, please do not modify it manually. From the data file:PlayerOccupation
local L_CompressMaxColumn = 4
local L_CompressData = {
8944045570512552,6597290530107703182,559110464373988,16273,
--0,1,Lạc Kiếm,1,玄剑之道，源自900年前被万妖覆灭的玄剑宗。时至今日，仍被诸多修仙者奉为正统。,远程、控制,剑修一脉，源自于900年前名动天下的剑仙——纯阳子，以自身灵气化为万千飞剑，一念之间便能诛敌于千里之外。,head_0,200,3000100,2000100,25,,idle,0_15000_2,,
8947893889521281,6817192924383297429,559111194282884,16279,
--1,0,Hồng Viêm,0,天英一脉，信奉以力证道。神枪在手，一切生死逆境，皆视为无物。,近战、爆发,枪修一脉，传承自远古天道武神，御敌时以灵气灌注枪中，一击便有穿云裂石，万魔辟易之势。,head_1,216,3100100,2100100,112,,idle,0_14000_2,,
8951192449570410,7037095030895820697,559112041632292,16273,
--2,1,Lạc Vệ,0,地藏之力，源于天授。天禁异动，轮回再启，这股沉寂千万年的力量亦随之重临世间。,近战、输出,地藏之力，源于天授。天禁异动，轮回再启，这股沉寂千万年的力量亦随之重临世间。,head_2,165,3200100,2200100,213,,idle,0_15000_2,,
8953558401930819,7256997420876094224,559112897370308,16273,
--3,0,Hồng Ảnh,0,罗刹是极恶，罗刹亦是极善。她只是为了遵守一个诺言，万千轮回，亦难忘却。,远程、输出,罗刹是极恶，罗刹亦是极善。她只是为了遵守一个诺言，万千轮回，亦难忘却。,head_3,180,3300100,2300100,315,,idle,0_15000_2,,
}
local L_MainKeyDic = {
[0]=1,[1]=2,[2]=3,[3]=4,}
local L_NamesByNum = {
   Id = 1,
   Sex = 2,
   AtkType = 4,
   ModelHeight = 9,
   ModelID = 10,
   WeaponID = 11,
   SkillVfxID = 12,
}
local L_NamesByString = {
   JobName = 3,
   Introduction = 5,
   Special = 6,
   Desc = 7,
   HeadIcon = 8,
   PlayAnimName = 13,
   IdleAnimName = 14,
   BlurArgs = 15,
}
local L_ColNameIndexs = {
   Id = 0,
   Sex = 1,
   JobName = 2,
   AtkType = 3,
   Introduction = 4,
   Special = 5,
   Desc = 6,
   HeadIcon = 7,
   ModelHeight = 8,
   ModelID = 9,
   WeaponID = 10,
   SkillVfxID = 11,
   PlayAnimName = 12,
   IdleAnimName = 13,
   BlurArgs = 14,
}
--local L_ColumnUseBitCount = {3,2,15,2,17,15,17,15,9,23,23,10,2,15,15,}
--local L_ColumnList = {1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,}
--local L_ShiftDataList = {0,3,5,20,22,39,0,17,32,41,0,23,33,35,0,}
--local L_AndDataList = {3,1,16383,1,65535,16383,65535,16383,255,4194303,4194303,511,1,16383,16383,}
local L_ColumnShiftAndList = {1,0,3,1,3,1,1,5,16383,1,20,1,1,22,65535,1,39,16383,2,0,65535,2,17,16383,2,32,255,2,41,4194303,3,0,4194303,3,23,511,3,33,1,3,35,16383,4,0,16383,}
local L_ColNum = 15;
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
