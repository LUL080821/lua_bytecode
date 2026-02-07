------------------------------------------------
-- Author:
-- Date: 2020-11-12
-- File: RandomNameMaker.lua
-- Module: RandomNameMaker
-- Description: Player character information
------------------------------------------------

local RandomNameMaker = {
    FirstNameList = nil,
    BoyNameList = nil,
    GirlNameList = nil,
}

-- Create an object
function RandomNameMaker:New()
    local _m = Utils.DeepCopy(self)
    _m.FirstNameList = List:New();
    _m.BoyNameList = List:New();
    _m.GirlNameList = List:New();
    return _m
end

-- initialization
function RandomNameMaker:Initialize()
    self.FirstNameList:Clear();
    self.BoyNameList:Clear();
    self.GirlNameList:Clear();
    math.randomseed(os.time());
    DataConfig.DataRandomName:Foreach(function (k,v)
        if v.QType == 1 then
            self.FirstNameList:Add(v.QValue);
        elseif v.QType == 2 then      
            self.BoyNameList:Add(v.QValue);
        elseif v.QType == 3 then
            self.GirlNameList:Add(v.QValue);
        end
    end)   
end

-- Random names
-- function RandomNameMaker:RandName(isBoy)
--     print("====================================================", FLanguage.Default)    
--     local _firstName = "";
--     local _lastName = "";
--     -- Here is a judgment, Thai and Vietnamese do not combine names
--     if (FLanguage.Default ~= FLanguage.TH) then
--         if (self.FirstNameList:Count() > 0) then    
--             local _fidx = math.random(1,self.FirstNameList:Count());
--             _firstName = self.FirstNameList[_fidx];
--         end
--     end

--     if (isBoy) then
--         if (self.BoyNameList:Count() > 0) then
--             local _bidx = math.random(1,self.BoyNameList:Count());
--             _lastName = self.BoyNameList[_bidx];
--         end
--     else
--         if (self.GirlNameList:Count() > 0) then
--             local _gidx = math.random(1,self.GirlNameList:Count());
--             _lastName = self.GirlNameList[_gidx];
--         end
--     end
--     return _firstName .. _lastName;
-- end

-- 随机名字 (luôn 3 từ)
function RandomNameMaker:RandName(isBoy)    
    local _firstName = ""
    local _lastName = ""

    -- random họ
    local firstWords = {}
    if (self.FirstNameList:Count() > 0) then    
        local _fidx = math.random(1, self.FirstNameList:Count())
        for w in self.FirstNameList[_fidx]:gmatch("%S+") do
            table.insert(firstWords, w)
        end
    end

    -- random tên
    local nameSource = nil
    if (isBoy and self.BoyNameList:Count() > 0) then
        nameSource = self.BoyNameList[math.random(1, self.BoyNameList:Count())]
    elseif (self.GirlNameList:Count() > 0) then
        nameSource = self.GirlNameList[math.random(1, self.GirlNameList:Count())]
    end

    local lastWords = {}
    if nameSource then
        for w in nameSource:gmatch("%S+") do
            table.insert(lastWords, w)
        end
    end

    -- đảm bảo tổng cộng 3 từ
    local resultWords = {}
    if #firstWords > 0 and #lastWords > 0 then
        -- số từ lấy từ họ (1 hoặc 2, nhưng không vượt quá #firstWords)
        local takeFirst = math.random(1, math.min(2, #firstWords))
        -- số từ lấy từ tên để đủ 3
        local takeLast = 3 - takeFirst
        if takeLast > #lastWords then
            takeLast = #lastWords
            takeFirst = 3 - takeLast
        end

        for i = 1, takeFirst do
            table.insert(resultWords, firstWords[i])
        end
        for i = 1, takeLast do
            table.insert(resultWords, lastWords[i])
        end
    end

    return table.concat(resultWords, " ")
end


return RandomNameMaker