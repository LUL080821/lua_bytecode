
------------------------------------------------
-- author:
-- Date: 2020-03-19
-- File: TerriCelebrityData.lua
-- Module: TerriCelebrityData
-- Description: Hall of Fame Data
------------------------------------------------
-- Quote
local TerriCelebrityData = {
    Cfg = nil,
    --rank , name, point, uid
    ListRank = List:New(),
    ListTitleData = List:New(),
}

function TerriCelebrityData:New(cfg)
    local _m = Utils.DeepCopy(self)
    return _m
end

function TerriCelebrityData:Parase(cfg)
    if cfg == nil then
        return
    end
    self.Cfg = cfg

    local list = Utils.SplitStr(cfg.Rank,';')
    if list == nil then
        return
    end
    for i = 1,#list do
        local subList = Utils.SplitStr(list[i],'_')
        if subList ~= nil then
            local min = tonumber(subList[1])
            local max = tonumber(subList[2])
            local id = tonumber(subList[3])
            local fightPoint = tonumber(subList[5])
            local titleData = self:GetTitleData(id, min,max, fightPoint)
            self.ListTitleData:Add(titleData)
        end
    end
end

-- parse message data
function TerriCelebrityData:ParaseMsg(msg)
    self.ListRank:Clear()
    if msg.rankInfoList ~= nil then
        for i = 1,#msg.rankInfoList do
            local info = msg.rankInfoList[i]
            local tab = {rank = info.rank ,name = info.roleName, point = tonumber(info.rankData), uid = info.roleId, career = info.career}
            self.ListRank:Add(tab)
        end
    end
    self.ListRank:Sort(function(a, b)
        return a.rank < b.rank
     end )
end

-- Obtain title data
function TerriCelebrityData:GetTitleData(id, min,max, fightPower)
    local cfg = DataConfig.DataTitle[id]
    if cfg ~= nil then
        local minRank = min
        local maxRank = max
        local tab = {min = minRank ,max = maxRank, texId = cfg.Textrue, power = fightPower}
        return tab
    end
    return nil
end

return TerriCelebrityData