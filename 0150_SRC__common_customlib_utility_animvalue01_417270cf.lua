------------------------------------------------
-- Author: 
-- Date: 2020-12-19
-- File: AnimValue01.lua
-- Module: AnimValue01
-- Description: Data animation, during a time period, let this value change from 0 to 1
------------------------------------------------

local AnimValue01 = {
    
    -- Start time point
    StartTime = 0,
    -- Delay time
    Delay = 0,
    -- Play length
    Duration = 0,
    -- Whether to start
    Enabled = false,

    -- The elapsed time
    Elapse = 0,

    -- Current value [0,1]
    CurrValue = 0,

    -- Callback for data change
    OnHandler = nil,

    -- Speed data
    SpeedData = List:New(),
}

-- Create a new object
function AnimValue01:New()
    local _m = Utils.DeepCopy(self)
    _m.SpeedData = List:New();
    return _m
end

-- Start playing,
-- delay: indicates the delayed animation time
-- duration: indicates the time to play the animation
-- handler: Each frame is worth changing and returns through this callback. You can not pass it and actively get the current value. The parameter transmission needs to be encapsulated through Utils.Handler.
function AnimValue01:Start(delay,duration,handler)
    local _typeX = type(delay)
    if _typeX == "number" or _typeX ~= "nil" then
        self.Delay = delay;
    else
        self.Delay = 0;
    end

    _typeX = type(duration)
    if _typeX == "number" or _typeX ~= "nil" then
        self.Duration = duration;
    else
        self.Duration = 0;
    end
    self.StartTime = Time.GetRealtimeSinceStartup();
    self.CurrValue = 0;
    self.Enabled = true;
    self.OnHandler = handler;
end

-- Stop animation
function AnimValue01:Stop()    
    self.Delay = 0;
    self.Duration = 0;
    self.Enabled = false;
end

-- Get the current value
function AnimValue01:GetCurValue()
    return self.CurrValue;
end

-- Set the speed data of the animation, where the value is an array. For example: [1,1,1,2,3,4,5,10] means the speed is getting faster and faster, [10,8,4,2,1,1,1] means the speed is getting slower and slower
-- Algorithm description: According to the number of values in the array, divide the time into N equal segments. The larger the value, the faster the current equal segmentation time period.
function AnimValue01:SetSpeed(list)
    
    local _sum = 0;
    local _tmp = 0;
    -- Add valid data to speed data
    self.SpeedData:Clear();
    for i=1,#list do
        if list[i] > 0 then
            self.SpeedData:Add(list[i]);
        end
    end

    -- Calculate the total amount
    for i = 2,self.SpeedData:Count() do
        self.SpeedData[i] = self.SpeedData[i]+self.SpeedData[i-1];
    end

    -- Format data
    if self.SpeedData:Count() > 0 then
        _sum = self.SpeedData[self.SpeedData:Count()];
        for i = 1,#self.SpeedData do
            self.SpeedData[i] = self.SpeedData[i] / _sum;
        end
        -- The last one is set to 1
        self.SpeedData[self.SpeedData:Count()] = 1;
    else        
        self.SpeedData.Add(1);
    end
end

-- To update, an external driver needs to be called.
function AnimValue01:Update()
    if self.Enabled then
        if self.Duration > 0 then
            self.Elapse = Time.GetRealtimeSinceStartup() - self.StartTime;
            self.CurrValue = (self.Elapse - self.Delay)/self.Duration
            self.CurrValue = self:FixedValue(self.CurrValue)
        else
            self.CurrValue = 1;
        end
        -- Determine whether it is over
        if self.CurrValue >= 1 then
            self.CurrValue = 1;
            self.Enabled = false;
        end
        -- Callback processing
        if self.OnHandler then
            self.OnHandler(self.CurrValue,self.Enabled);
        end
    end
end

-- According to speed, correct the final data --Private function
function AnimValue01:FixedValue(val)
    if val < 0 then
        val = 0;
    end
    if val > 1 then
        val = 1;
    end
    -- The length of the speed data
    local _len = self.SpeedData:Count();
    if _len > 1 then        
        local _val= _len * val;
        -- Get index
        local idx = math.floor(_val);
        -- Get increments
        local _delta = _val - idx;
        -- Get the start data of the interpolated value
        local from = 0;
        if idx > 0 then
            from = self.SpeedData[idx];
        end
        -- Get end point data
        local to = 1
        if idx < _len then
           to = self.SpeedData[idx+1];
        end        
        val = (to - from) * _delta + from;
    end
    return val;
end
return AnimValue01