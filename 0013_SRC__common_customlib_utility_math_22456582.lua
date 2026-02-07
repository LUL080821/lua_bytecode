------------------------------------------------
-- Author:
-- Date: 2019-05-06
-- File: Math.lua
-- Module: None
-- Description: Mathematics
------------------------------------------------

-- -------------------[Lua comes with]--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- math.maxinteger Maximum value 9223372036854775807
-- math.mininteger minimum value -9223372036854775808
-- math.huge infinity inf
-- math.tointeger to integer
-- math.pi Pi math.pi 3.1415926535898
-- math.abs Take the absolute value math.abs(-2012) 2012
-- math.ceil rounding up math.ceil(9.1) 10
-- math.floor rounds down math.floor(9.9) 9
-- math.max Take the maximum parameter value math.max(2,4,6,8) 8
-- math.min Take the minimum value of the parameter math.min(2,4,6,8) 2
-- math.sqrt open square math.sqrt(65536) 256.0
-- math.modf takes the integer and the fractional part of math.modf(20.12) 20 0.12
-- math.randomseed Set the random number seed math.randomseed(os.time())
-- math.random Takes the random number math.random(5,90) 5~90
-- math.rad Angle radian math.rad(180) 3.1415926535898
-- math.deg radian angle math.deg(math.pi) 180.0
-- math.exp e to the x power math.exp(4) 54.598150033144
-- math.log calculates the natural logarithm of x math.log(54.598150033144) 4.0
-- math.sin sine math.sin(math.rad(30)) 0.5
-- math.cos cosine math.cos(math.rad(60)) 0.5
-- math.tan tangent math.tan(math.rad(45)) 1.0
-- math.asin arcsini sine math.deg(math.asin(0.5)) 30.0
-- math.acos inverse cosine math.deg(math.acos(0.5)) 60.0
-- math.atan arctangent math.deg(math.atan(1)) 45.0
-- math.type Gets the type integer or float
-- math.fmod Take the modulus math.fmod(65535,2) 1
------------------------------------------------

local L_Floor = math.floor
local L_Abs = math.abs

-- Angle radian
math.Deg2Rad = math.pi / 180
-- Radius angle
math.Rad2Deg = 180 / math.pi
-- Mechanical minimum
math.Epsilon = 1.401298e-45

-- The p power of value
function math.Pow(value, p)
	return value^p;
end

-- Approximately (the first decimal place rounded)
function math.Round(num)
	return L_Floor(num + 0.5)
end

-- The function returns a symbol of a number indicating whether the number is positive, negative or zero
function math.Sign(num)
	if num > 0 then
		num = 1
	elseif num < 0 then
		num = -1
	else
		num = 0
	end
	return num
end

-- Limit the value of value between min and max. If the value is less than min, return min. If the value is greater than max, return max
function math.Clamp(num, min, max)
	if num < min then
		num = min
	elseif num > max then
		num = max
	end
	return num
end

local Clamp = math.Clamp

-- Linear interpolation
function math.Lerp(from, to, t)
	return from + (to - from) * Clamp(t, 0, 1)
end

-- Non-limited linear interpolation
function math.LerpUnclamped(a, b, t)
    return a + (b - a) * t;
end

-- repeat
function math.Repeat(t, length)
	return t - (L_Floor(t / length) * length)
end

-- Interpolation angle
function math.LerpAngle(a, b, t)
	local _num = math.Repeat(b - a, 360)

	if _num > 180 then
		_num = _num - 360
	end
	return a + _num * Clamp(t, 0, 1)
end

-- Move toward
function math.MoveTowards(current, target, maxDelta)
	if L_Abs(target - current) <= maxDelta then
		return target
	end
	return current + math.Sign(target - current) * maxDelta
end

-- Incremental angle
function math.DeltaAngle(current, target)
	local _num = math.Repeat(target - current, 360)

	if _num > 180 then
		_num = _num - 360
	end
	return _num
end

-- Moving angle
function math.MoveTowardsAngle(current, target, maxDelta)
	target = current + math.DeltaAngle(current, target)
	return math.MoveTowards(current, target, maxDelta)
end

-- approximate
function math.Approximately(a, b)
	return L_Abs(b - a) < math.max(1e-6 * math.max(L_Abs(a), L_Abs(b)), 1.121039e-44)
end

-- Inverse interpolation
function math.InverseLerp(from, to, value)
	if from < to then
		if value < from then
			return 0
		end
		if value > to then
			return 1
		end

		value = value - from
		value = value/(to - from)
		return value
	end
	if from <= to then
		return 0
	end
	if value < to then
		return 1
	end
	if value > from then
        return 0
	end
	return 1.0 - ((value - to) / (from - to))
end

-- Table Tennis
function math.PingPong(t, length)
    t = math.Repeat(t, length * 2)
    return length - L_Abs(t - length)
end

-- Is it a non-numeric value?
function math.IsNan(number)
	return not (number == number)
end

-- Gamma function
function math.Gamma(value, absmax, gamma)
	local _flag = false
    if value < 0 then
        _flag = true
    end
    local _num = L_Abs(value)
    if _num > absmax then
        return (not _flag) and _num or -_num
    end
    local _num2 = (_num / absmax )^ gamma * absmax
    return (not _flag) and _num2 or -_num2
end

-- Smooth damping
function math.SmoothDamp(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
	maxSpeed = maxSpeed or math.huge
	deltaTime = deltaTime or Time.deltaTime
    smoothTime = math.max(0.0001, smoothTime)
    local _num = 2 / smoothTime
    local _num2 = _num * deltaTime
    local _num3 = 1 / (1 + _num2 + 0.48 * _num2 * _num2 + 0.235 * _num2 * _num2 * _num2)
    local _num4 = current - target
    local _num5 = target
    local max = maxSpeed * smoothTime
    _num4 = Clamp(_num4, -max, max)
    target = current - _num4
    local _num7 = (currentVelocity + (_num * _num4)) * deltaTime
    currentVelocity = (currentVelocity - _num * _num7) * _num3
    local _num8 = target + (_num4 + _num7) * _num3
    if (_num5 > current) == (_num8 > _num5)  then
        _num8 = _num5
        currentVelocity = (_num8 - _num5) / deltaTime
    end
    return _num8,currentVelocity
end

-- Smooth damping angle
function math.SmoothDampAngle(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
	deltaTime = deltaTime or Time.deltaTime
	maxSpeed = maxSpeed or math.huge
	target = current + math.DeltaAngle(current, target)
    return math.SmoothDamp(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
end

-- Smooth interpolation
function math.SmoothStep(from, to, t)
    t = Clamp(t, 0, 1)
    t = -2 * t * t * t + 3 * t * t
    return to * t + from * (1 - t)
end

-- Horizontal angle
function math.HorizontalAngle(dir)
	return math.deg(math.atan(dir.x, dir.z))
end

-- Gamma to linear
function math.GammaToLinearSpaceExact(value)
    if value <= 0.04045 then
        return value / 12.92;
    elseif value < 1.0 then
        return math.Pow((value + 0.055)/1.055, 2.4);
    else
        return math.Pow(value, 2.2);
    end
end

-- Linear to Gamma
function math.LinearToGammaSpaceExact(value)
    if value <= 0.0 then
         return 0.0;
    elseif value <= 0.0031308 then
        return 12.92 * value;
    elseif value < 1.0 then
        return 1.055 * math.Pow(value, 0.4166667) - 0.055;
    else
       return math.Pow(value, 0.45454545);
    end
end

-- Convert a number to an integer or a decimal. For example, 72.0 returns 72; 72.5 returns 72.5 supports negative numbers
function math.FormatNumber(value)
    local t1, t2 = math.modf(value)
	if t2 == 0 then
		-- If the decimal part is equal to 0, the integer part is returned.
        return t1
	else
		-- If the decimal part is greater than 0, it will be returned directly
        return value
    end
end