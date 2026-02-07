--The file is automatically generated, please do not modify it manually. From the data file:guide_war_newbie
local L_CompressMaxColumn = 2
local L_CompressData = {
156252163752037,764458471260161,
--101,首次仙盟战,1,1,仙盟战,0,,,首次仙盟战,首次仙盟战由全服战斗力最高的12个仙盟获得资格，战力越高，评级越高,,
156253237495910,764492831260673,
--102,常规仙盟战,1,2,仙盟战,0,,,常规仙盟战,1.天仙，金仙，神仙的评级由上周仙盟战结果决定#n2.鬼仙的资格由其他仙盟中战力前3名获得,,
12023521814728905,764561551044054,
--201,灵门,2,1,战场说明,1,1,tex_n_b_xianmengzhan_2,灵门,1.共3座灵门，摧毁后才能攻击下一座灵门#n2.守方可以对已摧毁的灵门进行修复#n3.参与摧毁或者修复灵门的玩家将获得战场积分,,
21030722118905034,764575619657174,
--202,上古灵核,2,2,战场说明,1,2,tex_n_b_xianmengzhan_2,上古灵核,1.上古灵核在最内层的战场中#n2.摧毁后伤害最高的仙盟成为新的守方#n3.参与摧毁上古灵核的玩家将获得战场积分,,
30037922471699659,764613091306966,
--203,传送阵,2,3,战场说明,1,3,tex_n_b_xianmengzhan_2,传送阵,1.传送阵只能守方使用,,
39045122800184524,764647451307478,
--204,出生点,2,4,战场说明,1,4,tex_n_b_xianmengzhan_2,出生点,1.守方出生点在上古灵核旁边，攻方出生点在城外#n2.进入战场或死亡将出生在出生点,,
48052323128669389,764681811307990,
--205,神骑,2,5,战场说明,1,5,tex_n_b_xianmengzhan_2,神骑,1.攻城使位于地图右下方提供神骑服务#n2.防守使位于地图左上角#n3神骑只能攻击敌方神骑和建筑#n4.神骑状态下的玩家属性将会提高,,
3016494492908845,764716171308502,
--301,胜利条件,3,1,胜利条件,1,,tex_n_b_xianmengzhan_2,胜利条件,1.活动时间结束，守城方获胜#n2.没有守城方，按积分排名,,
}
local L_MainKeyDic = {
[101]=1,[102]=2,[201]=3,[202]=4,[203]=5,[204]=6,[205]=7,[301]=8,}
local L_NamesByNum = {
   Id = 1,
   Type = 3,
   Sort = 4,
   PicType = 6,
   PointType = 7,
}
local L_NamesByString = {
   Name = 2,
   TypeName = 5,
   Pic = 8,
   Title = 9,
   Context = 10,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Type = 2,
   Sort = 3,
   TypeName = 4,
   PicType = 5,
   PointType = 6,
   Pic = 7,
   Title = 8,
   Context = 9,
}
--local L_ColumnUseBitCount = {10,17,3,4,17,2,4,17,17,17,}
--local L_ColumnList = {1,1,1,1,1,1,1,2,2,2,}
--local L_ShiftDataList = {0,10,27,30,34,51,53,0,17,34,}
--local L_AndDataList = {511,65535,3,7,65535,1,7,65535,65535,65535,}
local L_ColumnShiftAndList = {1,0,511,1,10,65535,1,27,3,1,30,7,1,34,65535,1,51,1,1,53,7,2,0,65535,2,17,65535,2,34,65535,}
local L_ColNum = 10;
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
    Count = 8
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
