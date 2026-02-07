--The file is automatically generated, please do not modify it manually. From the data file:FBOpenShow
local L_CompressMaxColumn = 3
local L_CompressData = {
934585026657860351,1930065055055872,7362445313,
--15103,灵魄·经验,1,,6800001,,293,200_0_150_0_0_100,,4101_4603,,
934585026658024192,1930065088610304,7362445313,
--15104,玉魄·经验,1,,6800001,,294,200_0_150_0_0_100,,4101_4603,,
934585026657860353,1930065122164736,7362445313,
--15105,灵魄·经验,1,,6800001,,295,200_0_150_0_0_100,,4101_4603,,
934585026658220802,1930065793253376,7362445313,
--15106,灵魄·战斗,1,,6800001,,315,200_0_150_0_0_100,,4101_4603,,
934585026658351875,1930065826807808,7362445313,
--15107,玉魄·战斗,1,,6800001,,316,200_0_150_0_0_100,,4101_4603,,
934585026658220804,1930065860362240,7362445313,
--15108,灵魄·战斗,1,,6800001,,317,200_0_150_0_0_100,,4101_4603,,
934585026658548485,1930065222828032,7362445313,
--15109,灵魄·追击,1,,6800001,,298,200_0_150_0_0_100,,4101_4603,,
934585026658679558,1930065256382464,7362445313,
--15110,玉魄·追击,1,,6800001,,299,200_0_150_0_0_100,,4101_4603,,
934585026658548487,1930065692590080,7362445313,
--15111,灵魄·追击,1,,6800001,,312,200_0_150_0_0_100,,4101_4603,,
934585057248885402,1930055229707298,7362501481,
--15002,婀娜魅影碎片,0,2,6800001,6100002,,200_0_150_0_0_100,800_0_0_0_0_60,4101_4603,,
934585057248819867,1930055229707299,7362501481,
--15003,清风如意碎片,0,2,6800001,6100003,,200_0_150_0_0_100,800_0_0_0_0_60,4101_4603,,
934585057248787100,1930055229707300,7362501478,
--15004,聚魂灯碎片,0,2,6800001,6100004,,200_0_150_0_0_100,800_0_0_0_0_150,4101_4603,,
934585057248721565,1930055229707301,7362501478,
--15005,紫金葫芦碎片,0,2,6800001,6100005,,200_0_150_0_0_100,800_0_0_0_0_150,4101_4603,,
934585057248688798,1930055229707302,7362501475,
--15006,八荒游龙碎片,0,2,6800001,6100006,,200_0_150_0_0_100,800_0_0_0_0_-100,4101_4603,,
934585057248623263,1930055229707303,7362501473,
--15007,七彩琉璃塔碎片,0,2,6800001,6100007,,200_0_150_0_0_100,800_0_0_0_0_100,4101_4603,,
934585057248557728,1930055229707304,7362501478,
--15008,流萤宝扇碎片,0,2,6800001,6100008,,200_0_150_0_0_100,800_0_0_0_0_150,4101_4603,,
934585039218551554,1930055232707398,7362501471,
--11010,碧空,0,1,6800001,9100102,,200_0_150_0_0_100,300_0_0_0_0_220,4101_4603,,
934585039218649859,1930055232707399,7362501471,
--11011,迦楼罗,0,1,6800001,9100103,,200_0_150_0_0_100,300_0_0_0_0_220,4101_4603,,
934585039218748164,1930055232707400,7362501471,
--11012,花间影,0,1,6800001,9100104,,200_0_150_0_0_100,300_0_0_0_0_220,4101_4603,,
934585039218846469,1930055232707401,7362501470,
--11013,毕方之翼,0,1,6800001,9100105,,200_0_150_0_0_100,200_0_0_0_0_220,4101_4603,,
934585039218944774,1930055232707402,7362501470,
--11014,寒幽千刃,0,1,6800001,9100106,,200_0_150_0_0_100,200_0_0_0_0_220,4101_4603,,
934585039219043079,1930055232707403,7362501470,
--11015,冰魄银华,0,1,6800001,9100107,,200_0_150_0_0_100,200_0_0_0_0_220,4101_4603,,
}
local L_MainKeyDic = {
[15103]=1,[15104]=2,[15105]=3,[15106]=4,[15107]=5,[15108]=6,[15109]=7,[15110]=8,[15111]=9,[15002]=10,[15003]=11,[15004]=12,[15005]=13,[15006]=14,[15007]=15,
[15008]=16,[11010]=17,[11011]=18,[11012]=19,[11013]=20,[11014]=21,[11015]=22,}
local L_NamesByNum = {
   Id = 1,
   Type = 3,
   ModelType = 4,
   ModelPath = 5,
   ItemModelPath = 6,
   ShowIcon = 7,
}
local L_NamesByString = {
   Name = 2,
   ModelShow = 8,
   ItemModelShow = 9,
   ChangeReason = 10,
}
local L_ColNameIndexs = {
   Id = 0,
   Name = 1,
   Type = 2,
   ModelType = 3,
   ModelPath = 4,
   ItemModelPath = 5,
   ShowIcon = 6,
   ModelShow = 7,
   ItemModelShow = 8,
   ChangeReason = 9,
}
--local L_ColumnUseBitCount = {15,17,2,3,24,25,10,17,17,17,}
--local L_ColumnList = {1,1,1,1,1,2,2,2,3,3,}
--local L_ShiftDataList = {0,15,32,34,37,0,25,35,0,17,}
--local L_AndDataList = {16383,65535,1,3,8388607,16777215,511,65535,65535,65535,}
local L_ColumnShiftAndList = {1,0,16383,1,15,65535,1,32,1,1,34,3,1,37,8388607,2,0,16777215,2,25,511,2,35,65535,3,0,65535,3,17,65535,}
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
    Count = 22
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
