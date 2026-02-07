------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: Utils.lua
-- Module: Utils
-- Description: Define some common function functions
------------------------------------------------

local Vector3 = require("Common.CustomLib.Utility.Vector3")
local Vector4 = require("Common.CustomLib.Utility.Vector4")
local Quaternion = require("Common.CustomLib.Utility.Quaternion")
local Color = require("Common.CustomLib.Utility.Color")
local UIUtility = CS.Thousandto.Plugins.Common.UIUtility

local Utils = {}

local L_Rad2Deg = math.Rad2Deg;
local L_Deg2Rad = math.Deg2Rad;
local L_Clamp = math.Clamp;
local L_Acos = math.acos;
local L_Asin = math.asin;
local L_Sqrt = math.sqrt;
local L_Max = math.max;
local L_Min = math.min;
local L_Sin = math.sin;
local L_HalfDegToRad = 0.5 * L_Deg2Rad
local L_OverSqrt2 = 0.7071067811865475244008443621048490

-- Remove the lua script from require
function Utils.RemoveRequiredByName(preName)
    for key, _ in pairs(package.preload) do
        if string.find(tostring(key), preName) == 1 then
            package.preload[key] = nil
        end
    end
    for key, _ in pairs(package.loaded) do
        if string.find(tostring(key), preName) == 1 then
            package.loaded[key] = nil
        end
    end
end

-- Obj usually passes self, data is usually table
function Utils.Handler(func, obj, data, isNotPrintErr)
    if not func then
        if not isNotPrintErr then
            Debug.LogError("function is empty")
        end
        return nil
    end
    return function(...)
        if data then
            return func(obj, data, ...)
        else
            return func(obj, ...)
        end
    end
end

-- C# type to lua type
function Utils.CS2Lua(mt, csType)
    local _t = {};
    setmetatable(_t, { __index = function(t, k)
        local _value = mt[k];
        if _value then
            if csType == CSType.Enum then
                _value = UnityUtils.GetObjct2Int(_value)
            end
            rawset(t, k, _value);
        end
        return _value;
    end })
    return _t;
end

-- Get the data length of the table
function Utils.GetTableLens(tab)
    local _count = 0
    if type(tab) == "table" then
        for _, _ in pairs(tab) do
            _count = _count + 1
        end
    end
    return _count
end

-- Deep copy data
function Utils.DeepCopy(object)
    local _lookup_table = {}

    local function _copy(obj)
        -- If it is not a table, then return directly
        if type(obj) ~= "table" then
            return obj
        elseif _lookup_table[obj] then
            -- If it has been copied, then return.
            return _lookup_table[obj]
        end
        -- Create a new table and copy the past.
        local _new_table = {}
        _lookup_table[obj] = _new_table
        for index, value in pairs(obj) do
            _new_table[_copy(index)] = _copy(value)
        end
        local ret = setmetatable(_new_table, getmetatable(obj));
        -- The method_OnCopyAfter_ is called after a table is copied, which is used to handle certain tables that require special processing
        if ret._OnCopyAfter_ then ret:_OnCopyAfter_() end
        return ret;
    end
    return _copy(object)
end

-- Obtain string or specific value through enumeration
function Utils.GetEnumNumberAndString(str)
    local _num = {}
    local b = Utils.SplitStr(str, ':')
    _num[1] = b[1]
    _num[2] = tonumber(b[2])
    return _num
end

-- Get number by enumeration
function Utils.GetEnumNumber(str)
    return Utils.GetEnumNumberAndString(str)[2]
end

-- Obtain string by enumeration
function Utils.GetEnumString(str)
    return Utils.GetEnumNumberAndString(str)[1]
end

-- Cut string (when sep is nil, split according to space)
function Utils.SplitStr(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local _ret = List:New()
    -- code mới sửa merge data
    -- Kiểm tra kiểu dữ liệu trước khi xử lý
    if type(str) == "string" and str ~= "" then
        for v in string.gmatch(str, "([^" .. sep .. "]+)") do
            _ret:Add(v)
        end
    end

    -- code cũ
    -- for v in string.gmatch(str, "([^" .. sep .. "]+)") do
    --     _ret:Add(v)
    -- end
    return _ret
end

-- Cut numbers
function Utils.SplitNumber(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local _ret = List:New()
    for v in string.gmatch(str, "([^" .. sep .. "]+)") do
        _ret:Add(tonumber(v))
    end
    return _ret
end

-- Cut string
function Utils.SplitStrByTable(str, sepTable)
    local _ret = List:New()
    if type(sepTable) ~= "table" then
        Debug.LogError("sepTable is not a table")
        return _ret
    end
    _ret = Utils.SplitStr(str, sepTable[1])
    if #sepTable > 1 then
        for i = 2, #sepTable do
            local _temp = List:New()
            for j = 1, #_ret do
                local _temp2 = Utils.SplitStr(_ret[j], sepTable[i])
                for k = 1, #_temp2 do
                    _temp:Add(_temp2[k])
                end
            end
            _ret = _temp
        end
    end
    return _ret
end

-- Cut string Multi-dimensional array cutting is searched in reverse according to the string, and the string is a number. Easy to use. If you want to return a string, don't use this
function Utils.SplitStrByTableS(str, sep)
    -- Set default values
    sep = sep or { ';', '_' }
    if type(sep) ~= "table" then
        Debug.LogError("sepTable is not a table")
        return {}
    end
    if #sep == 0 then
        return {}
    end
    local _ret = {};
    if #sep == 1 then
        _ret[1] = Utils.SplitStr(str, sep[1])
        return _ret
    end
    local i = 0;
    local _insert = table.insert;
    for v in string.gmatch(str, "([^" .. sep[1] .. "]+)") do
        local curstr = v
        local retchild = {};
        for o = 1, #sep do
            local curtable = Utils.SplitStr(curstr, sep[o])
            curstr = curtable[1]
            for g = #curtable, 1, -1 do
                local strnum = tonumber(curtable[g]) and tonumber(curtable[g]) or nil
                if strnum ~= nil then
                    _insert(retchild, 1, strnum)
                end
            end
        end
        i = i + 1;
        _ret[i] = retchild;
    end
    return _ret;
end

-- String conversion list
function Utils.StringToList(str)
    local _length = string.len(str)
    local _list = List:New()
    for i = 1, _length do
        _list:Add(string.sub(str, i, i))
    end
    return _list
end

-- This function is a recursive function by definition cutting a string. Index is best not to pass
function Utils.SplitStrBySeps(str, sep, index)
    sep = sep or { ';', '_' }
    if type(sep) ~= "table" then
        Debug.LogError("sepTable is not a table")
        return str
    end

    index = index or 1;
    local _sepCount = #sep;
    if index > _sepCount then
        return str;
    end
    local _strTable = Utils.SplitStr(str, sep[index]);
    if (index + 1) > _sepCount then
        return _strTable;
    end

    local _result = {}
    for i = 1, #_strTable do
        _result[i] = Utils.SplitStrBySeps(_strTable[i], sep, index + 1);
    end
    return _result;
end

-- Replace everything in the string with rep, pattern is the string to be replaced
function Utils.ReplaceString(str, pattern, rep)
    local _strg = string.gmatch(str, pattern)
    for v in _strg do
        str = string.gsub(str, v, rep)
    end
    return str
end

-- Merge attribute tables and accumulate values of the same attribute type
function Utils.MergePropTable(...)
    local _paramTable = { ... };
    local _helpDic = Dictionary:New();
    local _result = {};
    for i = 1, #_paramTable do
        for j = 1, #_paramTable[i] do
            local _proType = _paramTable[i][j][1];
            if _helpDic:ContainsKey(_proType) then
                local _index = _helpDic[_proType];
                _result[_index][2] = _result[_index][2] + _paramTable[i][j][2];
            else
                local _index = #_result + 1;
                _helpDic:Add(_proType, _index);
                _result[_index] = {};
                _result[_index][1] = _proType;
                _result[_index][2] = _paramTable[i][j][2];
            end
        end
    end

    return _result;
end

-- Get the difference in attribute table
function Utils.DecPropTable(table1, table2)
    local _newTable = List:New()
    for i = 1, #table1 do
        local _type = table1[i][1]
        local _value = table1[i][2]
        for j = 1, #table2 do
            if table2[j][1] == _type then
                _value = _value - table2[j][2]
            end
        end
        _newTable:Add({ _type, _value })
    end
    return _newTable
end

-- To Table
function Utils.StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    local _f = load("return " .. str);
    return _f();
end

-- - Any value to string
function Utils.ToStringEx(value)
    if type(value) == 'table' then
        return Utils.TableToStr(value)
    elseif type(value) == 'string' then
        return "\'" .. value .. "\'"
    else
        return tostring(value)
    end
end

-- -Table converts string. If it is a Table, then there cannot be values and keys for reference types such as functions, threads, etc. in Table.
function Utils.TableToStr(t)
    if t == nil then return "" end
    local retstr = "{"

    local i = 1
    for key, value in pairs(t) do
        local signal = ","
        if i == 1 then
            signal = ""
        end

        if key == i then
            retstr = retstr .. signal .. Utils.ToStringEx(value)
        else
            if type(key) == 'number' or type(key) == 'string' then
                retstr = retstr .. signal .. '[' .. Utils.ToStringEx(key) .. "]=" .. Utils.ToStringEx(value)
            else
                if type(key) == 'userdata' then
                    retstr = retstr .. signal .. "*s" .. Utils.ToStringEx(getmetatable(key)) .. "*e" .. "=" .. Utils.ToStringEx(value)
                else
                    retstr = retstr .. signal .. key .. "=" .. Utils.ToStringEx(value)
                end
            end
        end
        i = i + 1
    end
    retstr = retstr .. "}"
    return retstr
end

-- Calculate the length of the UTF8 string, and calculate one character in each Chinese
function Utils.UTF8Len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- Calculate the length of the UTF8 string, and count 2 characters in each Chinese
function Utils.UTF8LenForCn(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = { 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        local _index = 1
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                _index = 2
                break
            end
            i = i - 1
        end
        cnt = cnt + _index
        left = left - 1
    end
    return cnt
end

-- Processing to get string length according to language
-- CH stands for Chinese simplified Chinese, TW stands for Chinese Traditional Chinese
function Utils.UTF8LenForLan(input, lan)
    if (lan == nil) or (lan == "") or (lan == "CH") or (lan == "TW") then
        return Utils.UTF8LenForCn(input);
    else
        return Utils.UTF8Len(input);
    end
end

function Utils.SafeAsin(sinValue)
    return L_Asin(L_Clamp(sinValue, -1, 1))
end

function Utils.SafeAcos(cosValue)
    return L_Acos(L_Clamp(cosValue, -1, 1))
end

-- [Find distance] vector2, vector3, vector4
function Utils.Distance(va, vb)
    return (va - vb):Magnitude()
end

-- v2 or v3 fixed maximum length
function Utils.ClampMagnitude(v, maxLength)
    if v:SqrMagnitude() > (maxLength * maxLength) then
        v:Normalize()
        v:Mul(maxLength)
    end
    return v
end

-- [Point-to-multiple]vector2, vector3, vector4, Quaternion
function Utils.Dot(lhs, rhs)
    --Vector4,Quaternion
    if lhs.w then
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.w * rhs.w
        --vector3
    elseif lhs.z then
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
        --vector2
    else
        return lhs.x * rhs.x + lhs.y * rhs.y;
    end
end

-- Fork multiplication of v3
function Utils.Cross(lhs, rhs)
    local _x = lhs.y * rhs.z - lhs.z * rhs.y
    local _y = lhs.z * rhs.x - lhs.x * rhs.z
    local _z = lhs.x * rhs.y - lhs.y * rhs.x
    return Vector3(_x, _y, _z)
end

-- Find the angle between two v2 or two v3 or two Quaternion
function Utils.Angle(lhs, rhs)
    --Quaternion
    if lhs.w then
        local _dot = Utils.Dot(lhs, rhs)
        if _dot < 0 then
            _dot = -_dot
        end
        return L_Acos(L_Min(_dot, 1)) * 2 * L_Rad2Deg
        --Vector2 or Vector3
    else
        return Utils.SafeAcos(Utils.Dot(lhs:Normalize(), rhs:Normalize())) * L_Rad2Deg;
    end
end

local function QuaternionLerp(from, to, t)
    local _q = Quaternion()
    if Utils.Dot(from, to) < 0 then
        _q.x = from.x + t * (-to.x - from.x)
        _q.y = from.y + t * (-to.y - from.y)
        _q.z = from.z + t * (-to.z - from.z)
        _q.w = from.w + t * (-to.w - from.w)
    else
        _q.x = from.x + (to.x - from.x) * t
        _q.y = from.y + (to.y - from.y) * t
        _q.z = from.z + (to.z - from.z) * t
        _q.w = from.w + (to.w - from.w) * t
    end
    _q:Normalize()
    return _q
end

-- [Interpolation] v2, v3, v4, Quaternion, Color
function Utils.Lerp(from, to, t)
    t = L_Clamp(t, 0, 1)
    return Utils.UnclampedLerp(from, to, t)
end

-- [Non-interval interpolation] v2, v3, v4, Quaternion, Color
function Utils.UnclampedLerp(from, to, t)
    if type(from) == "number" then
        return (to - from) * t
    else
        --Color
        if from.r then
            return Color(from.r + (to.r - from.r) * t, from.g + (to.g - from.g) * t, from.b + (to.b - from.b) * t, from.a + (to.a - from.a) * t);
            --v4,Quaternion
        elseif from.w then
            if from.SetIdentity then
                return QuaternionLerp(from, to, t);
            else
                return Vector4(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t, from.w + (to.w - from.w) * t);
            end
            --Vector3
        elseif from.z then
            return Vector3(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t);
            --Vector2
        else
            return Vector2(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t);
        end
    end
end

-- Vector3, Vector4 Move
function Utils.MoveTowards(current, target, maxDistanceDelta)
    local _delta = target - current
    local _sqrDelta = _delta:SqrMagnitude()
    local _sqrDistance = maxDistanceDelta * maxDistanceDelta

    if _sqrDelta > _sqrDistance then
        local magnitude = L_Sqrt(_sqrDelta)

        if magnitude > 1e-6 then
            _delta:Mul(maxDistanceDelta / magnitude)
            _delta:Add(current)
            return _delta
        else
            return current:Clone()
        end
    end
    return target:Clone()
end

-- Vector3, Vector4 projection
function Utils.Project(vector, onNormal)
    if vector.w then
        local _s = Utils.Dot(vector, onNormal) / Utils.Dot(onNormal, onNormal)
        return onNormal * _s
    else
        local num = onNormal:SqrMagnitude()
        if num < 1.175494e-38 then
            return Vector3(0, 0, 0)
        end
        local num2 = Utils.Dot(vector, onNormal)
        local _v = onNormal:Clone()
        _v:Mul(num2 / num)
        return _v
    end
end

-- Vector3 projection to the ground
function Utils.ProjectOnPlane(vector, planeNormal)
    local _v3 = Utils.Project(vector, planeNormal)
    _v3:Mul(-1)
    _v3:Add(vector)
    return _v3
end

-- Vector3 reflection
function Utils.Reflect(inDirection, inNormal)
    local _num = -2 * Utils.Dot(inNormal, inDirection)
    inNormal = inNormal * _num
    inNormal:Add(inDirection)
    return inNormal
end

-- Angle around the axis
function Utils.AngleAroundAxis (from, to, axis)
    from = from - Utils.Project(from, axis)
    to = to - Utils.Project(to, axis)
    local _angle = Utils.Angle(from, to)
    return _angle * (Utils.Dot(axis, Utils.Cross(from, to)) < 0 and -1 or 1)
end

-- [angle axis] Rotate angle around axis axis to create a Quaternion
function Utils.AngleAxis(angle, axis)
    local _normAxis = axis:Normalize()
    angle = angle * L_HalfDegToRad
    local _s = L_Sin(angle)

    local w = math.cos(angle)
    local _x = _normAxis.x * _s
    local _y = _normAxis.y * _s
    local _z = _normAxis.z * _s
    return Quaternion(_x, _y, _z, w)
end

local function OrthoNormalVector(vec)
    local res = Vector3()
    if math.abs(vec.z) > L_OverSqrt2 then
        local _a = vec.y * vec.y + vec.z * vec.z
        local _k = 1 / L_Sqrt(_a)
        res.x = 0
        res.y = -vec.z * _k
        res.z = vec.y * _k
    else
        local _a = vec.x * vec.x + vec.y * vec.y
        local _k = 1 / L_Sqrt(_a)
        res.x = -vec.y * _k
        res.y = vec.x * _k
        res.z = 0
    end
    return res
end

local function Vector3Slerp(from, to, t)
    local _omega, _sinom, _scale0, _scale1

    if t <= 0 then
        return from:Clone()
    elseif t >= 1 then
        return to:Clone()
    end

    local _v2 = to:Clone()
    local _v1 = from:Clone()
    local _len2 = to:Magnitude()
    local _len1 = from:Magnitude()
    _v2:Div(_len2)
    _v1:Div(_len1)

    local _len = (_len2 - _len1) * t + _len1
    local _cosom = Utils.Dot(_v1, _v2)

    if _cosom > 1 - 1e-6 then
        _scale0 = 1 - t
        _scale1 = t
    elseif _cosom < -1 + 1e-6 then
        local axis = OrthoNormalVector(from)
        local q = Utils.AngleAxis(180.0 * t, axis)
        local v = q:MulVec3(from)
        v:Mul(_len)
        return v
    else
        _omega = L_Acos(_cosom)
        _sinom = L_Sin(_omega)
        _scale0 = L_Sin((1 - t) * _omega) / _sinom
        _scale1 = L_Sin(t * _omega) / _sinom
    end

    _v1:Mul(_scale0)
    _v2:Mul(_scale1)
    _v2:Add(_v1)
    _v2:Mul(_len)
    return _v2
end

local function UnclampedSlerp(from, to, t)
    local _cosAngle = Utils.Dot(from, to)

    if _cosAngle < 0 then
        _cosAngle = -_cosAngle
        to = Quaternion(-to.x, -to.y, -to.z, -to.w)
    end

    local _t1, _t2
    if _cosAngle < 0.95 then
        local angle = L_Acos(_cosAngle)
        local sinAngle = L_Sin(angle)
        local invSinAngle = 1 / sinAngle
        _t1 = L_Sin((1 - t) * angle) * invSinAngle
        _t2 = L_Sin(t * angle) * invSinAngle
        return Quaternion(from.x * _t1 + to.x * _t2, from.y * _t1 + to.y * _t2, from.z * _t1 + to.z * _t2, from.w * _t1 + to.w * _t2)
    else
        return Utils.Lerp(from, to, t)
    end
end

function Utils.Slerp(from, to, t)
    t = L_Clamp(t, 0, 1)
    --Quaternion
    if from.w then
        return UnclampedSlerp(from, to, t)
        --vector3
    else
        return Vector3Slerp(from, to, t)
    end
end
-- Quaternion turn
local function QuaternionRotateTowards(from, to, maxDegreesDelta)
    local _angle = Utils.Angle(from, to)

    if _angle == 0 then
        return to
    end

    local _t = L_Min(1, maxDegreesDelta / _angle)
    return UnclampedSlerp(from, to, _t)
end

local function ClampedMove(lhs, rhs, clampedDelta)
    local _delta = rhs - lhs

    if _delta > 0 then
        return lhs + L_Min(_delta, clampedDelta)
    else
        return lhs - L_Min(-_delta, clampedDelta)
    end
end

-- Vector3 steering
local function Vector3RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta)
    local _len1 = current:Magnitude()
    local _len2 = target:Magnitude()

    if _len1 > 1e-6 and _len2 > 1e-6 then
        local _from = current / _len1
        local _to = target / _len2
        local _cosom = Utils.Dot(_from, _to)

        if _cosom > 1 - 1e-6 then
            return Utils.MoveTowards(current, target, maxMagnitudeDelta)
        elseif _cosom < -1 + 1e-6 then
            local _axis = OrthoNormalVector(_from)
            local _q = Utils.AngleAxis(maxRadiansDelta * L_Rad2Deg, _axis)
            local rotated = _q:MulVec3(_from)
            local _delta = ClampedMove(_len1, _len2, maxMagnitudeDelta)
            rotated:Mul(_delta)
            return rotated
        else
            local _angle = L_Acos(_cosom)
            local _axis = Utils.Cross(_from, _to)
            _axis:Normalize()
            local _q = Utils.AngleAxis(L_Min(maxRadiansDelta, _angle) * L_Rad2Deg, _axis)
            local rotated = _q:MulVec3(_from)
            local _delta = ClampedMove(_len1, _len2, maxMagnitudeDelta)
            rotated:Mul(_delta)
            return rotated
        end
    end

    return Utils.MoveTowards(current, target, maxMagnitudeDelta)
end

-- Turn
function Utils.RotateTowards(from, to, Delta, maxMagnitudeDelta)
    --Quaternion
    if from.w then
        return QuaternionRotateTowards(from, to, Delta)
        --vector3
    else
        return Vector3RotateTowards(from, to, Delta, maxMagnitudeDelta)
    end
end

-- Vector3 smooth damping
function Utils.SmoothDamp(current, target, currentVelocity, smoothTime)
    local _maxSpeed = math.huge
    local _deltaTime = Time.GetDeltaTime()
    smoothTime = math.max(0.0001, smoothTime)
    local _num = 2 / smoothTime
    local _num2 = _num * _deltaTime
    local _num3 = 1 / (1 + _num2 + 0.48 * _num2 * _num2 + 0.235 * _num2 * _num2 * _num2)
    local _vectorClone = target:Clone()
    local _maxLength = _maxSpeed * smoothTime
    local _vector = current - target
    Utils.ClampMagnitude(_vector, _maxLength)
    target = current - _vector
    local _vecTemp = (currentVelocity + (_vector * _num)) * _deltaTime
    currentVelocity = (currentVelocity - (_vecTemp * _num)) * _num3
    local _vecResult = target + (_vector + _vecTemp) * _num3

    if Utils.Dot(_vectorClone - current, _vecResult - _vectorClone) > 0 then
        _vecResult = _vectorClone
        currentVelocity:Set(0, 0, 0)
    end

    return _vecResult, currentVelocity
end

-- [Scaling]vector3, vector4
function Utils.Scale(lhs, rhs)
    if lhs.w then
        return Vector4(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z, lhs.w * rhs.w)
    else
        return Vector3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)

    end
end

-- [Find the small value] vector2, vector3, vector4
function Utils.Min(lhs, rhs)
    if lhs.w then
        return Vector4(L_Min(lhs.x, rhs.x), L_Min(lhs.y, rhs.y), L_Min(lhs.z, rhs.z), L_Min(lhs.w, rhs.w))
    elseif lhs.z then
        return Vector3(L_Min(lhs.x, rhs.x), L_Min(lhs.y, rhs.y), L_Min(lhs.z, rhs.z))
    else
        return Vector2(L_Min(lhs.x, rhs.x), L_Min(lhs.y, rhs.y))
    end
end

-- [Find a large value] vector2, vector3, vector4
function Utils.Max(lhs, rhs)
    if lhs.w then
        return Vector4(L_Max(lhs.x, rhs.x), L_Max(lhs.y, rhs.y), L_Max(lhs.z, rhs.z), L_Max(lhs.w, rhs.w))
    elseif lhs.z then
        return Vector3(L_Max(lhs.x, rhs.x), L_Max(lhs.y, rhs.y), L_Max(lhs.z, rhs.z))
    else
        return Vector2(L_Max(lhs.x, rhs.x), L_Max(lhs.y, rhs.y))
    end
end

-- HSV to RGB
function Utils.HSVToRGB(H, S, V, hdr)
    local _white = Color(1, 1, 1, 1)

    if S == 0 then
        _white.r = V
        _white.g = V
        _white.b = V
        return _white
    end

    if V == 0 then
        _white.r = 0
        _white.g = 0
        _white.b = 0
        return _white
    end

    _white.r = 0
    _white.g = 0
    _white.b = 0;
    local _num = S
    local _num2 = V
    local _f = H * 6;
    local _num4 = math.floor(_f)
    local _num5 = _f - _num4
    local _num6 = _num2 * (1 - _num)
    local _num7 = _num2 * (1 - (_num * _num5))
    local _num8 = _num2 * (1 - (_num * (1 - _num5)))
    local _num9 = _num4

    local _flag = _num9 + 1

    if _flag == 0 then
        _white.r = _num2
        _white.g = _num6
        _white.b = _num7
    elseif _flag == 1 then
        _white.r = _num2
        _white.g = _num8
        _white.b = _num6
    elseif _flag == 2 then
        _white.r = _num7
        _white.g = _num2
        _white.b = _num6
    elseif _flag == 3 then
        _white.r = _num6
        _white.g = _num2
        _white.b = _num8
    elseif _flag == 4 then
        _white.r = _num6
        _white.g = _num7
        _white.b = _num2
    elseif _flag == 5 then
        _white.r = _num8
        _white.g = _num6
        _white.b = _num2
    elseif _flag == 6 then
        _white.r = _num2
        _white.g = _num6
        _white.b = _num7
    elseif _flag == 7 then
        _white.r = _num2
        _white.g = _num8
        _white.b = _num6
    end

    if not hdr then
        _white.r = L_Clamp(_white.r, 0, 1)
        _white.g = L_Clamp(_white.g, 0, 1)
        _white.b = L_Clamp(_white.b, 0, 1)
    end

    return _white
end

-- Convert a value to a string with a specified number of digits. No more than 36 bits
function Utils.ToString(num, toBase)
    if toBase > 36 then
        return ""
    end
    local _str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local _temp = {}
    while (true) do
        local _index = math.floor(num % toBase)
        local _s = string.sub(_str, _index + 1, _index + 1)
        table.insert(_temp, string.sub(_str, _index + 1, _index + 1))
        num = num // toBase
        if num == 0 then
            local _targetStr = table.concat(_temp)
            return string.reverse(_targetStr)
        end
    end
end

-- Convert bit string to Num
function Utils.ConvertToNum(str, fromBase)
    if fromBase > 36 then
        return ""
    end
    return tonumber(str, fromBase)
end

-- Get the monster name
function Utils.GetMonsterName(mCfg)
    if mCfg == nil then
        return "";
    end
    return UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_MONSTER_NAME_FORMAT"), mCfg.Level, mCfg.Name);
    -- local _stateCfg = DataConfig.DataStatePower[mCfg.StateLevel];
    -- if _stateCfg ~= nil then
    --     return string.format("[%s]%s", _stateCfg.Name, mCfg.Name);
    -- end
    -- return mCfg.Name;
end

-- Is the cs object empty?
function Utils.IsNull(csObject)
    if csObject then
        return string.find(tostring(csObject), "null:");
    end
    return true;
end

-- Whether it is within the lock time t: module object, k: function object, [seconds: lock time, default 1 second]
function Utils.IsLockTime(t, k, seconds)
    if type(t) ~= "table" or not k then
        return false;
    end
    local _unlockTimeMap = t._UnlockTimeMap_
    if not _unlockTimeMap then
        _unlockTimeMap = {};
        t._UnlockTimeMap_ = _unlockTimeMap;
    end
    -- Current time
    local _curTime = Time.GetRealtimeSinceStartup();
    -- Last time recorded
    local _lastTime = _unlockTimeMap[k];
    if _lastTime then
        if _curTime - _lastTime < (seconds or 1) then
            return true;
        else
            _unlockTimeMap[k] = _curTime;
            return false;
        end
    else
        _unlockTimeMap[k] = _curTime;
        return false;
    end
end

-- Show prompt
function Utils.ShowPromptByEnum(enum, ...)
    local _id = DataConfig.DataMessageString.GetKey(enum);
    if _id then
        GameCenter.MsgPromptSystem:ShowPromptByMsgStrID(_id, ...)
    else
        Debug.LogError("The Enum does not exist in MessageString =", enum)
    end
end

-- Show msgbox, default two buttons, OK and Cancel
function Utils.ShowMsgBox(callBack, enum, ...)
    Utils.ShowMsgBoxAndBtn(callBack, "C_MSGBOX_CANCEL", "C_MSGBOX_OK", enum, ...)
end

-- Display msgbox, you can set the contents of two buttons
function Utils.ShowMsgBoxAndBtn(callBack, btn1Enum, btn2Enum, enum, ...)
    local _btn1Id = -1
    if btn1Enum ~= nil then
        _btn1Id = DataConfig.DataMessageString.GetKey(btn1Enum)
        if _btn1Id == nil then
            _btn1Id = -1
        end
    end
    local _btn2Id = -1
    if btn2Enum ~= nil then
        _btn2Id = DataConfig.DataMessageString.GetKey(btn2Enum)
        if _btn2Id == nil then
            _btn2Id = -1
        end
    end
    local _msgId = nil
    if enum ~= nil then
        _msgId = DataConfig.DataMessageString.GetKey(enum);
    end
    if _msgId == nil then
        return
    end
    GameCenter.MsgPromptSystem:ShowMsgBoxByMsgStrID(callBack, _btn1Id, _btn2Id, _msgId, ...)
end

-- Get Discounts
function Utils.GetDiscount(value)
    local _curLan = FLanguage.Default;
    if _curLan == LanguageConstDefine.TH or _curLan == LanguageConstDefine.EN
            or _curLan == LanguageConstDefine.KR or _curLan == LanguageConstDefine.VIE
            or _curLan == LanguageConstDefine.JP then
        return (10 - value) * 10
    end
    return value
end

-- Quality frame picture name
function Utils.GetQualitySpriteName(quality)
    if not quality then
        return ""
    end
    if quality == 1 then
        return "n_pinzhikuang_1";
    elseif quality == 2 then
        return "n_pinzhikuang_2";
    elseif quality == 3 then
        return "n_pinzhikuang_3";
    elseif quality == 4 then
        return "n_pinzhikuang_4";
    elseif quality == 5 then
        return "n_pinzhikuang_5";
    elseif quality == 6 then
        return "n_pinzhikuang_6";
    elseif quality == 7 then
        return "n_pinzhikuang_7";
    elseif quality == 8 then
        return "n_pinzhikuang_7";
    elseif quality == 9 then
        return "n_pinzhikuang_7";
    elseif quality == 10 then
        return "n_pinzhikuang_7";
    end
    return "";
end

-- Quality background picture name
function Utils.GetQualityBackName(quality)
    if not quality then
        return ""
    end
    if quality == 1 then
        return "n_pinzhidi_1";
    elseif quality == 2 then
        return "n_pinzhidi_2";
    elseif quality == 3 then
        -- Blue
        return "n_pinzhidi_3";
    elseif quality == 4 then
        -- Violet
        return "n_pinzhidi_4";
    elseif quality == 5 then
        -- Orange
        return "n_pinzhidi_5";
    elseif quality == 6 then
        -- Golden
        return "n_pinzhidi_6";
    elseif quality == 7 then
        -- Red
        return "n_pinzhidi_7";
    elseif quality == 8 then
        -- Pink
        return "n_pinzhidi_7";
    elseif quality == 9 then
        -- DarkGolden
        return "n_pinzhidi_7";
    elseif quality == 10 then
        -- Colorful
        return "n_pinzhidi_7";
    end
    return "";
end

function Utils.GetQualityStrColor(quality)
    if not quality then
        return ""
    end

    if quality == 1 then
        --White
        return "FFFFFF";
    elseif quality == 2 then
        -- Green
        return "1f7f1a";
    elseif quality == 3 then
        -- Blue
        return "77e1ff" -- "2e73ff";
    elseif quality == 4 then
        -- Violet
        return "f5a2ff" -- "a50ef3";
    elseif quality == 5 then
        -- Orange
        return "ffee63" -- "f68500";
    elseif quality == 6 then
        -- Golden
        return "ffee63" -- "ff9110";
    elseif quality == 7 then
        -- Red
        return "ff7777" -- "ff2a2a";
    elseif quality == 8 then
        -- Pink
        return "ffa8bc" -- "fe3cb3";
    elseif quality == 9 then
        -- DarkGolden
        return "ffb95f" -- "a66900";
    elseif quality == 10 then
        -- Colorful
        return "FFFFFF";
    end
    return "FFFFFF";
end
--[[function Utils.GetTargetColor(key, value, defaultColor)
    ---------------------------------------------------------
    -- Mock data
    ---------------------------------------------------------
    local ColorRangesData = {
        [ColorTargetType.Equip_Name]     = {
            ColorRange   = {
                { min = 0, max = 10, color = "#FFFFFF" }, -- Trắng
                { min = 10, max = 30, color = "#16B282" }, -- Lục
                { min = 30, max = 50, color = "#217FCE" }, -- Lam
                { min = 50, max = 70, color = "#A53DFF" }, -- Tím
                { min = 70, max = 90, color = "#FFCC00" }, -- Cam
                { min = 90, max = 100, color = "#FF4E00" }, -- Đỏ
            },
            DefaultColor = "#FFFFFF",
        },
        [ColorTargetType.Strength_Level] = {
            ColorRange   = {
                { min = 0, max = 1, color = "#FFFFFF" }, -- Trắng
                { min = 1, max = 5, color = "#000000" }, -- Đen
                { min = 6, max = 10, color = "#217FCE" }, -- Lam
                { min = 10, max = 15, color = "#A53DFF" }, -- Tím
            },
            DefaultColor = "#FFFFFF",
        },
        [ColorTargetType.Equip_Name]     = {
            ColorRange   = {
                { min = 1, max = 2, color = "#FFFFFF" }, --  Trắng
                { min = 2, max = 3, color = "#16B282" }, --  Lục
                { min = 3, max = 4, color = "#217FCE" }, --  Lam
                { min = 4, max = 5, color = "#A53DFF" }, --  Tím
                { min = 5, max = 6, color = "#FFCC00" }, --  Cam
                { min = 6, max = 8, color = "#FF4E00" }, --  Đỏ
            },
            DefaultColor = "#FFFFFF",
        },
    }

    ---------------------------------------------------------
    -- Handle data
    ---------------------------------------------------------
    -- Validate input
    if key == nil or value == nil then
        return defaultColor or "#FFFFFF"
    end

    local cfg = ColorRangesData[key]
    if not cfg or not cfg.ColorRange then
        return defaultColor or "#FFFFFF"
    end

    local ranges = cfg.ColorRange
    local fallback = cfg.DefaultColor or defaultColor or "#FFFFFF"
    local targetColor = fallback

    -- Parse ranges into ordered table
    for _, r in ipairs(ranges) do
        if value >= r.min and value < r.max then
            targetColor = r.color
            break
        end
    end

    -- Handle out-of-range values with fallback
    --   - Below first range → use first color
    --   - Above last range  → use last color
    if #ranges > 0 then
        if value < ranges[1].min then
            targetColor = ranges[1].color
        elseif value >= ranges[#ranges].max then
            targetColor = ranges[#ranges].color
        end
    end

    return targetColor
end]]
function Utils.GetTargetColor(key, value, defaultColor)
    ---------------------------------------------------------
    -- Mock data
    ---------------------------------------------------------
    local ColorRangesData = {
        [ColorTargetType.Wash_Attribute] = {
            ColorRange   = {
                ["00_30"]  = "#787878", -- Xám
                ["30_70"]  = "#217FCE", -- Lam
                ["70_90"]  = "#A53DFF", -- Tím
                ["90_100"] = "#FF4E00", -- Cam
            },
            DefaultColor = "FFFFFF",
        },
        [ColorTargetType.Strength_Level] = {
            ColorRange   = {
                ["00_06"] = "#000000", -- Đen
                ["06_11"] = "#FFD000", -- Vàng
                ["11_16"] = "#AC4135", -- Đỏ
            },
            DefaultColor = "FFFFFF",
        },
        [ColorTargetType.Equip_Name]     = {
            ColorRange   = {
                ["1_2"] = "#787878", -- Xám
                ["2_3"] = "#16B282", -- Lục
                ["3_4"] = "#217FCE", -- Lam
                ["4_5"] = "#A53DFF", -- Tím
                ["5_6"] = "#FF4E00", -- Cam
                ["7_8"] = "#F11F1F", -- Đỏ
            },
            DefaultColor = "FFFFFF",
        },
        [ColorTargetType.Appraise_Attribute] = {
            ColorRange   = {
                ["01_50"] = "#FFFFFF", -- Trắng
                ["50_80"] = "#16B282", -- Lục
                ["80_95"] = "#217FCE", -- Lam
                ["95_99"] = "#A53DFF", -- Tím
                ["99_100"] = "#FFD000", -- Vàng
            },
            DefaultColor = "787878",
        },
        [ColorTargetType.Appraise_Plus_Attribute] = {
            ColorRange   = {
                ["01_60"] = "#A53DFF", -- Tím
                ["61_100"] = "#FFD000", -- Vàng
            },
            DefaultColor = "787878",
        },
        [ColorTargetType.Special_Attribute] = {
            ColorRange   = {
                ["01_50"] = "#FFFFFF", -- Trắng
                ["50_80"] = "#16B282", -- Lục
                ["80_95"] = "#217FCE", -- Lam
                ["95_99"] = "#A53DFF", -- Tím
                ["99_100"] = "#FFD000", -- Vàng
            },
            DefaultColor = "FFFFFF",
        },
    }

    ---------------------------------------------------------
    -- Handle data
    ---------------------------------------------------------
    -- Validate input
    if key == nil or value == nil then
        return defaultColor or "#FFFFFF"
    end
    local cfg = ColorRangesData[key]
    if not cfg or not cfg.ColorRange then
        return defaultColor or "#FFFFFF"
    end
    local colorRanges = cfg.ColorRange
    local fallbackColor = cfg.DefaultColor or defaultColor or "#FFFFFF"

    -- Parse ranges into ordered table
    local parsedRanges = {}
    for rangeStr, color in pairs(colorRanges) do
        local data = Utils.SplitStr(rangeStr, "_")
        local minVal, maxVal = tonumber(data[1]), tonumber(data[2])
        if minVal and maxVal and color then
            table.insert(parsedRanges, { min = minVal, max = maxVal, color = color })
        end
    end
    table.sort(parsedRanges, function(a, b)
        return a.min < b.min
    end)

    -- Determine color based on percent range
    local targetColor = fallbackColor
    for _, r in ipairs(parsedRanges) do
        if value >= r.min and value < r.max then
            targetColor = r.color
            break
        end
    end

    -- Handle out-of-range values with fallback
    --   - Below first range → use first color
    --   - Above last range  → use last color
    if #parsedRanges > 0 then
        if value < parsedRanges[1].min then
            targetColor = parsedRanges[1].color
        elseif value >= parsedRanges[#parsedRanges].max then
            targetColor = parsedRanges[#parsedRanges].color
        end
    end

    return targetColor
end

function Utils.FormatAttributeValue(attrId, rawValue)
    local attrCfg = DataConfig.DataAttributeAdd[attrId]
    if not attrCfg then
        return tostring(rawValue)
    end
    
    if attrCfg.ShowPercent == 0 then
        return tostring(rawValue)
    end

    local percentValue = math.FormatNumber(rawValue / 100)
    return string.format("%s%%", percentValue)
end

function Utils.ParsePoolAttribute(poolId)
    if poolId == 0 then
        local info = {
            attrId       = 99,
            attrNameId   = 1, -- ""
            attrNameText = "N/A",
            minVal       = 0,
            maxVal       = 0,
            showPercent  = 0,
            specialType  = 0,
        }
        return info, 0
    end

    -- 1. Validate poolId & config
    local poolCfg = DataConfig.DataPoolSetting[poolId]
    if not poolCfg then
        return nil, "Invalid pool index"
    end

    -- 2. Parse Value format: "attrId_min_max"
    local parts = Utils.SplitStr(poolCfg.Value or "", "_")
    if #parts < 3 then
        return nil, "Invalid pool value format"
    end
    local attrId = tonumber(parts[1])
    local minVal = tonumber(parts[2])
    local maxVal = tonumber(parts[3])

    -- 3. Lookup Attribute config
    local attrCfg = DataConfig.DataAttributeAdd[attrId]
    if not attrCfg then
        return nil, "Missing attribute config"
    end

    local nameId = attrCfg._Name or 0
    local nameTxt = attrCfg.Name or "N/A"
    local showPercent = attrCfg.ShowPercent or 0
    -- 4. Construct result
    local info = {
        attrId       = attrId,
        attrNameId   = nameId, -- StringDefines ID (localization key)
        attrNameText = nameTxt, --  Localized display text
        minVal       = minVal,
        maxVal       = maxVal,
        showPercent  = showPercent,
        specialType  = tonumber(poolCfg.Special),
    }
    -- 5. Return result + pool type
    return info, poolCfg.Type
end

function Utils.GetEquipmentGroupByPart(part)
    for groupName, parts in pairs(EquipmentGroup) do
        for _, p in ipairs(parts) do
            if p == part then
                return groupName, parts
            end
        end
    end
    return nil, nil
end

---@param equipmentList -- List<Equipment> (Equipment.cs)
function Utils.FilterEquipmentByGroup(equipmentList, groupName)
    local filtered = List:New()
    local groupParts = EquipmentGroup[groupName]
    if not groupParts then
        return filtered -- invalid group name
    end

    for i = 0, equipmentList.Count - 1 do
        local equip = equipmentList[i]
        for _, part in ipairs(groupParts) do
            if equip.Part == part then
                filtered:Add(equip)
                break
            end
        end
    end

    return filtered
end

-- Establish an inheritance relationship of the table, where there must be an object_SuperObj_ in the table
-- This function is usually executed after all initialization is completed
function Utils.BuildInheritRel(tab)
    if tab ~= nil and tab._SuperObj_ ~= nil then
        setmetatable(tab, {
            __index    = function(table, key)
                local _value = table._SuperObj_[key];
                -- By
                if type(_value) == "function" then
                    rawset(table, key, function(t, ...)
                        return _value(table._SuperObj_, ...)
                    end
                    );
                    return table[key];
                end
                return _value;
            end,
            __newindex = function(table, key, value)
                table._SuperObj_[key] = value;
            end,
        });
    end
end

-- Delete a table
function Utils.Destory(tab)
    if tab ~= nil then
        setmetatable(tab, nil);
        for k, _ in pairs(tab) do
            tab[k] = nil;
        end
        tab = nil;
    end
end

-- "Inherit" a table
function Utils.Extend(parent, child)
    local _m = Utils.DeepCopy(child);
    parent.__index = parent
    setmetatable(_m, parent)
    return _m
end

function Utils.CheckOcc(gener, lpOcc)
    if gener and lpOcc and (string.find(gener, "9") ~= nil or string.find(gener, tostring(lpOcc)) ~= nil) then
        return true
    end
    return false
end

-- 0 Male 1 Female
function Utils.OccToSex(occ)
    if occ == Occupation.XianJian then
        return 0
    elseif occ == Occupation.MoQiang then
        return 1
    elseif occ == Occupation.DiZang then
        return 0
    elseif occ == Occupation.LuoCha then
        return 1
    end
    return 0
end

-- [Gosu] 2026/01/26
function Utils.GetPrisonID(state)
    if(state ~= nil and tonumber(state) > 0) then
        return state;
    else
        return DataConfig.DataMessageString.Get("NOT_GRANTED") or "----"
    end
end

return Utils
