
------------------------------------------------
-- Author:
-- Date: 2020-01-06
-- File: ResBackSystem.lua
-- Module: ResBackSystem
-- Description: Resource Retrieval System Class
------------------------------------------------
-- Quote
local ResBackSystem = {
    -- Is it possible to retrieve resources to pop up a secondary confirmation box?
    PResBackTiShi = true,
    -- Retrieve data
    -- {key: resource id value = {Cfg:config table id, CurNum = current number of retrieves, TCount, SpecialCount, PCoinId, NCoinId, Money, FreeMoney}}
    DicRes = Dictionary:New(),
    --key = id value = {Type,List{CfgId, Min, Max}}
    DicAll = Dictionary:New(),
    -- Active value can be retrieved today
    ActivePoint = 0,
}

-- Initialization ranking Cfg
function ResBackSystem:Initialize()
    self.DicAll:Clear()
    DataConfig.DataRetrieveRes:Foreach(function(k, v)
        local list = nil
        local data = {CfgId = v.Id, Min = v.MinLevel, Max = v.MaxLevel}
        if self.DicAll:ContainsKey(v.Type) then
            list = self.DicAll[v.Type]
            list:Add(data)
        else
            list = List:New()
            list:Add(data)
            self.DicAll:Add(v.Type,list)
        end
    end)
end

-- De-initialization
function ResBackSystem:UnInitialize()
    self.PResBackTiShi = true
end

function ResBackSystem:GetPReBackCostSing(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPerfect == nil or cfg.CostPerfect == "" then
            ret = 0
        else
            local list = Utils.SplitStr(cfg.CostPerfect,'_')
            local leftCount = data.TCount - data.CurNum
            ret = tonumber(list[2])
        end
    end
    return ret
end

-- Get perfect retrieval of consumed currency
function ResBackSystem:GetPReBackCost(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        local list = Utils.SplitStr(cfg.CostPerfect,'_')
        local leftCount = data.TCount - data.CurNum
        if data.Cfg.Type == 19 then
            local tab = self:GetScale()
            ret = tonumber(list[2]) * math.ceil( leftCount * tab.MaxScale )
        else
            ret = tonumber(list[2]) * leftCount
        end
    end
    return ret
end

-- Get perfect retrieval of consumed currency Id
function ResBackSystem:GetPReBackCoinId(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPerfect == nil or cfg.CostPerfect == "" then
            ret = 0
        else
            local list = Utils.SplitStr(cfg.CostPerfect,'_')
            ret = tonumber(list[1])
        end
    end
    return ret
end

function ResBackSystem:GetNReBackCostSing(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPart == nil or cfg.CostPart == "" then
            ret = 0
        else
            local list = Utils.SplitStr(cfg.CostPart,'_')
            local leftCount = data.TCount - data.CurNum
            ret = tonumber(list[2])
        end
    end
    return ret
end

-- Get some recovered money spent
function ResBackSystem:GetNReBackCost(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        local list = Utils.SplitStr(cfg.CostPart,'_')
        local leftCount = data.TCount - data.CurNum
        if cfg.Type == 19 then
            local tab = self:GetScale()
            ret = tonumber(list[2]) * math.ceil( leftCount * tab.MinScale )
        else
            ret = tonumber(list[2]) * leftCount
        end
    end
    return ret
end

function ResBackSystem:GetScale()
    local tab = nil
    local gCfg = DataConfig.DataGlobal[GlobalName.RetrieveRes_Activity_Scale]
    if gCfg ~= nil then
        local list = Utils.SplitStr(gCfg.Params,'_')
        if list ~= nil then
            tab = {MaxScale = tonumber(list[1]), MinScale = tonumber(list[2])}
        end
    end           
    return tab 
end

-- Get partial recovery of consumed currency Id
function ResBackSystem:GetNReBackCoinId(id)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPart == nil or cfg.CostPart == "" then
            ret = 0
        else
            local list = Utils.SplitStr(cfg.CostPart,'_')
            ret = tonumber(list[1])
        end
    end
    return ret
end

-- Is it perfect to retrieve
function ResBackSystem:HavePerfRes(id)
    local ret = true
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPerfect == "" then
            ret = false
        end
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if lp ~= nil then
            if lp.GuildID == 0 and cfg.Type == 20 then
                ret = false
            end
        end
    end
    return ret
end

-- Is it partially retrieved?
function ResBackSystem:HaveNormalRes(id)
    local ret = true
    local data = self.DicRes[id]
    if data ~= nil then
        local cfg = data.Cfg
        if cfg.CostPart == "" then
            ret = false
        end
        local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        if lp ~= nil then
            if lp.GuildID == 0 and cfg.Type == 20 then
                ret = false
            end
        end
        if data.TCount == data.CurNum then
            ret = false
        end
    end
    return ret
end

-- Get resource id through currency id
function ResBackSystem:GetCoinIconId(coinId)
    local cfg = DataConfig.DataItem[coinId]
    if cfg == nil then
        return 0
    end
    return cfg.Icon
end

-- Get the name of the resource
function ResBackSystem:GetName(id)
    local data = self.DicRes[id]
    if data ~= nil then
        -- local funcId = data.Cfg.OpenVariables
        -- if funcId == 0 then
        --     return DataConfig.DataMessageString.Get("ActiveValue")
        -- end
        -- local cfg = DataConfig.DataFunctionStart[funcId]
        if data.Cfg ~= nil then
            return data.Cfg.Name
        end
    end
end

function ResBackSystem:GetCfgId(type)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        if self.DicAll:ContainsKey(type) then
            local list = self.DicAll[type]
            if list ~= nil then 
                for i = 1,#list do
                    if lp.Level >= list[i].Min and lp.Level<= list[i].Max then
                        return list[i].CfgId
                    end
                end
            end
        end
    end
    return 0
end

function ResBackSystem:GetResType(cfgId)
    local cfg = DataConfig.DataRetrieveRes[cfgId]
    if cfg ~= nil then
        return cfg.Type
    end
    return 0
end

function ResBackSystem:GetNCost(id, num)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local singCost = self:GetNReBackCostSing(id)
        local leftCount = data.TCount - data.CurNum
        if data.Cfg.Type == 19 then
            local tab = self:GetScale()
            ret = singCost * math.ceil( leftCount * tab.MinScale )
        else
            local vipPowerCfg = DataConfig.DataVipPower[data.Cfg.VipPower]
            local goldList = nil
            if vipPowerCfg ~= nil then
                goldList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice,'_')
            end
            local totalBuyCount = GameCenter.VipSystem:GetCurVipPowerParam(data.Cfg.VipPower)
            if num <= (leftCount + data.VipCount) then
                if num <= leftCount then
                    ret = singCost * leftCount
                else
                    local otherCount = num - leftCount
                    local sum = 0
                    for i = 1, otherCount do
                        if i <= #goldList then
                            local vipCost = goldList[i] + singCost
                            sum = sum + vipCost
                        end
                    end
                    ret = singCost * leftCount + sum
                end
            end
        end
    end
    return ret
end

function ResBackSystem:GetN_OtherCost(id, num)
    local ret = 0
    local data = self.DicRes[id]
    if data == nil then
        return ret
    end
    local singCost = self:GetNReBackCostSing(id)
    local vipPowerCfg = DataConfig.DataVipPower[data.Cfg.VipPower]
    local goldList = nil
    if vipPowerCfg ~= nil then
        goldList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice,'_')
    end
    local totalBuyCount = GameCenter.VipSystem:GetCurVipPowerParam(data.Cfg.VipPower)
    if num <= data.VipCount then
        local sum = 0
        for i = 1, num do
            if i <= #goldList then
                local vipCost = goldList[i] + singCost
                sum = sum + vipCost
            end
        end
        ret = sum
    end
    return ret
end

function ResBackSystem:GetPCost(id, num)
    local ret = 0
    local data = self.DicRes[id]
    if data ~= nil then
        local singCost = self:GetPReBackCostSing(id)
        local leftCount = data.TCount - data.CurNum
        if data.Cfg.Type == 19 then
            local tab = self:GetScale()
            ret = singCost * math.ceil( leftCount * tab.MinScale )
        else
            local vipPowerCfg = DataConfig.DataVipPower[data.Cfg.VipPower]
            local goldList = nil
            if vipPowerCfg ~= nil then
                goldList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice,'_')
            end
            local totalBuyCount = GameCenter.VipSystem:GetCurVipPowerParam(data.Cfg.VipPower)
            if num <= (leftCount + data.VipCount) then
                if num <= leftCount then
                    ret = singCost * leftCount
                else
                    local otherCount = num - leftCount
                    local sum = 0
                    for i = 1, otherCount do
                        if i <= #goldList then
                            local vipCost = goldList[i] + singCost
                            sum = sum + vipCost
                        end
                    end
                    ret = singCost * leftCount + sum
                end
            end
        end
    end
    return ret
end

function ResBackSystem:GetP_OtherCost(id, num)
    local ret = 0
    local data = self.DicRes[id]
    if data == nil then
        return ret
    end
    local singCost = self:GetPReBackCostSing(id)
    local vipPowerCfg = DataConfig.DataVipPower[data.Cfg.VipPower]
    local goldList = nil
    if vipPowerCfg ~= nil then
        goldList = Utils.SplitNumber(vipPowerCfg.VipPowerPrice,'_')
    end
    local totalBuyCount = GameCenter.VipSystem:GetCurVipPowerParam(data.Cfg.VipPower)
    if num <= data.VipCount then
        local sum = 0
        for i = 1, num do
            if i <= #goldList then
                local vipCost = goldList[i] + singCost
                sum = sum + vipCost
            end
        end
        ret = sum
    end
    return ret
end

function ResBackSystem:GetResData(id)
    local ret = self.DicRes[id]
    return ret
end

function ResBackSystem:GetAllNCost(type)
    local ret = 0
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            local num = data.TCount - data.CurNum + data.VipCount
            local cost = 0
            if type == 1 then
                cost = self:GetNCost(key, num) - self:GetN_OtherCost(key, data.VipCount)
            else
                cost = self:GetNCost(key, num)
            end
            ret = ret + cost
        end
    end
    return ret
end

function ResBackSystem:GetNCostId()
    local ret = 0
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            if data.Cfg.CostPart ~= nil and data.Cfg.CostPart ~= "" then
                ret = self:GetNReBackCoinId(key)
                break
            end
        end
    end
    return ret
end

function ResBackSystem:GetPCostId()
    local ret = 0
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            if data.Cfg.CostPerfect ~= nil and data.Cfg.CostPerfect ~= "" then
                ret = self:GetPReBackCoinId(key)
                break
            end
        end
    end
    return ret
end

function ResBackSystem:GetAllPCost(type)
    local ret = 0
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            local num = data.TCount - data.CurNum + data.VipCount
            local cost = 0
            if type == 1 then
                cost = self:GetPCost(key, num) - self:GetP_OtherCost(key, data.VipCount)
            else
                cost = self:GetPCost(key, num)
            end
            ret = ret + cost
        end
    end
    return ret
end

function ResBackSystem:GetN_AllPoint(type)
    local ret = 0
    local playerOcc = 0
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp then
        playerOcc = lp.IntOcc
    end
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            if data.Cfg.Type ~= 19 then
                local _pointNum = 0
                -- Determine whether there are active points in the current reward props
                local listReward = nil
                listReward = Utils.SplitStr(data.Cfg.RewardPart,';')
                for i = 1, #listReward do 
                    local values = Utils.SplitNumber(listReward[i],'_')
                    local id = values[1]
                    local num = values[2]
                    local occ = tonumber(values[4])
                    if occ == playerOcc or occ == 9 then
                        if id == 21 then
                            local pointNum = 0
                            if type == 1 then
                                pointNum = num * (data.TCount - data.CurNum)
                            else
                                pointNum = num * (data.TCount - data.CurNum) + num * data.VipCount
                            end
                            ret = ret + pointNum
                        end
                    end
                end
            end
        end
    end
    return ret
end

function ResBackSystem:GetP_AllPoint(type)
    local ret = 0
    local playerOcc = 0
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp then
        playerOcc = lp.IntOcc
    end
    local keys = self.DicRes:GetKeys()
    if keys ~= nil then
        for i = 1, #keys do
            local key = keys[i]
            local data = self.DicRes[key]
            if data.Cfg.Type ~= 19 then
                local _pointNum = 0
                -- Determine whether there are active points in the current reward props
                local listReward = nil
                listReward = Utils.SplitStr(data.Cfg.RewardPerfect,';')
                for i = 1, #listReward do 
                    local values = Utils.SplitNumber(listReward[i],'_')
                    local id = values[1]
                    local num = values[2]
                    local occ = tonumber(values[4])
                    if occ == playerOcc or occ == 9 then
                        if id == 21 then
                            local pointNum = 0
                            if type == 1 then
                                pointNum = num * (data.TCount - data.CurNum)
                            else
                                pointNum = num * (data.TCount - data.CurNum) + num * data.VipCount
                            end
                            ret = ret + pointNum
                        end
                    end
                end
            end
        end
    end
    return ret
end

-- --------------------------------------------------------------------------------------------------------------------------------

-- Request to retrieve
function ResBackSystem:ReqRetrieveRes(id, backType, num)
    GameCenter.Network.Send("MSG_Welfare.ReqRetrieveRes", {type = id, rrType = backType, count = num})
end

function ResBackSystem:ReqOneKeyRetrieveRes(type, subType)
    GameCenter.Network.Send("MSG_Welfare.ReqOneKeyRetrieveRes", {rrType = type, baseTpe = subType})
end

function ResBackSystem:SyncRetrieveResList(msg)
    if msg == nil then
        return 
    end
    if msg.canFindActivePoint == nil then
        self.ActivePoint = 0
    else
        self.ActivePoint = msg.canFindActivePoint
    end
    self.DicRes:Clear()
    local freeKeys = List:New()
    if msg.lists ~= nil then
        for i = 1,#msg.lists do
            local cfgId = self:GetCfgId(msg.lists[i].type)
            if cfgId == 0 then
                break
            end
            if self.DicRes:ContainsKey(cfgId) then
                if msg.lists[i].remain == 0 and msg.lists[i].vipCount == 0 then
                    freeKeys:Add(cfgId)
                else
                    self.DicRes[cfgId].CurNum = self.DicRes[cfgId].TCount - msg.lists[i].remain
                    self.DicRes[cfgId].VipCount = msg.lists[i].vipCount
                end
            else
                local cfg = DataConfig.DataRetrieveRes[cfgId]
                local specialCount = 0
                if cfg.Type == 19 then
                    specialCount =   msg.lists[i].remain     
                end
                local curNum = cfg.Max - msg.lists[i].remain
                local tCount = cfg.Max
                local vipCount = msg.lists[i].vipCount
                local vipMaxCount = msg.lists[i].vipCountMax
                -- {key: resource id value = {Cfg:config table id, CurNum = current number of retrieves, TCount, PCoinId, NCoinId, Money, FreeMoney}}
                local data = {Cfg = cfg, CurNum = curNum, TCount = tCount, VipCount = vipCount, VipMaxCount = vipMaxCount,
                SpecialCount = specialCount,
                PCoinId = 0, NCoinId = 0, Money = 0, FreeMoney = 0}
                self.DicRes:Add(cfgId,data)
            end
        end
    end
    for i = 1,#freeKeys do
        self.DicRes:Remove(freeKeys[i])
    end
    if self.DicRes:Count() > 0 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ResBack,true)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ResBack,false)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RESBACKFORM_UPDATE)
end

function ResBackSystem:SyncRetrieveResOne(msg)
    if msg == nil then
        return 
    end
    if msg.canFindActivePoint == nil then
        self.ActivePoint = 0
    else
        self.ActivePoint = msg.canFindActivePoint
    end
    if msg.res ~= nil then
        local cfgId = self:GetCfgId(msg.res.type)
            if cfgId == 0 then
                return
            end
        if self.DicRes:ContainsKey(cfgId) then
            if msg.res.remain == 0 and msg.res.vipCount == 0 then
                self.DicRes:Remove(cfgId)
            else
                self.DicRes[cfgId].CurNum = self.DicRes[cfgId].TCount - msg.res.remain
                self.DicRes[cfgId].VipCount = msg.res.vipCount
            end
        else
            local key = -1
            local cfg = DataConfig.DataRetrieveRes[cfgId]
            local keys = self.DicRes:GetKeys()
            local isFind = false
            for i = 1,#keys do
                local resCfg = DataConfig.DataRetrieveRes[keys[i]]
                if resCfg.Type == cfg.Type then
                    isFind = true
                    key = keys[i]
                end
            end
            if isFind then
                self.DicRes:Remove(key)
            end
            if msg.res.remain ~= 0 then
                local tCount = cfg.Max
                local curNum = tCount - msg.res.remain
                local vipCount = msg.res.vipCount
                local maxVipCount = msg.res.vipCountMax
                -- {key: resource id value = {Cfg:config table id, CurNum = current number of retrieves, TCount, PCoinId, NCoinId, Money, FreeMoney}}
                local data = {Cfg = cfg, CurNum = curNum, TCount = tCount, VipCount = vipCount, MaxVipCount = maxVipCount,
                PCoinId = 0, NCoinId = 0, Money = 0, FreeMoney = 0}
                self.DicRes:Add(cfgId,data)
            end
        end
    end
    if self.DicRes:Count() > 0 then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ResBack,true)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ResBack,false)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RESBACKFORM_UPDATE)
end

return ResBackSystem
