
------------------------------------------------
-- author:
-- Date: 2019-12-16
-- File: VipBaseData.lua
-- Module: VipBaseData
-- Description: vip data
------------------------------------------------
-- Quote
local VipBaseData = {
    -- Have you purchased a VIP gift package?
    Cfg = nil,
    IsBuy = false,
    -- Privileged list
    ListPrivilege = List:New(),
    NewListPrivilege = List:New(),
    -- Gift bag
    ListLiBao = List:New(),
    -- Daily gift pack
    ListDayLiBao = List:New(),
    -- Privileged parameters
    DicPowerParam = Dictionary:New(),
}
function VipBaseData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end

-- Analyze data
function VipBaseData:ParseCfg(cfg)
    self.Cfg = cfg
    -- Setting the level gift package
    self.ListLiBao:Clear()
    local player = GameCenter.GameSceneSystem:GetLocalPlayer()
    local playerOcc = 0
    if player then
        playerOcc = player.IntOcc
    end
    local list = Utils.SplitStr(cfg.VipReward,';')
    for i = 1,#list do
        local values = Utils.SplitStr(list[i],'_')
        local id = tonumber(values[1])
        local num = tonumber(values[2])
        local bind = tonumber(values[3])
        local occ = tonumber(values[4])
        if occ == 9 or occ == playerOcc then
            local item = {Id = id, Num = num, Bind = bind == 1}
            self.ListLiBao:Add(item)
        end
    end

    -- Set up daily gift packs
    self.ListDayLiBao:Clear()
    list = nil
    list = Utils.SplitStr(cfg.VipRewardPer,';')
    for i = 1,#list do
        local values = Utils.SplitStr(list[i],'_')
        local id = tonumber(values[1])
        local num = tonumber(values[2])
        local bind = tonumber(values[3])
        local occ = tonumber(values[4])
        if occ == 9 or occ == playerOcc then
            local item = {Id = id, Num = num, Bind = bind == 1}
            self.ListDayLiBao:Add(item)
        end
    end
    
    -- Set privileged parameters
    self.DicPowerParam:Clear()
    list = nil
    list = Utils.SplitStr(cfg.VipPowerPra,';')
    if list ~= nil then
        for i = 1,#list do
            local values = Utils.SplitStr(list[i],'_')
            local id = tonumber(values[1])
            local param = tonumber(values[3])
            if not self.DicPowerParam:ContainsKey(id) then
                self.DicPowerParam:Add(id,param)
            end
        end
    end
    -- Set Privileges
    self.ListPrivilege:Clear()
    list = nil
    list = Utils.SplitStr(cfg.VipPowerId,'_')
    if list ~= nil then
        for i = 1,#list do
            local powerId = tonumber(list[i])
            local powerCfg = DataConfig.DataVipPower[powerId]
            if powerCfg ~= nil then
                local param = -1
                if self.DicPowerParam:ContainsKey(powerId) then
                    param = self.DicPowerParam[powerId]
                end
                local des = nil
                if param ~= -1 then
                    des = UIUtils.CSFormat( powerCfg.PowerDescribe,param )
                else
                    des = powerCfg.PowerDescribe
                end
                local icon = powerCfg.IsSpecialPower
                local tab = {PowerId = powerId, Des = des, Icon = icon}
                self.ListPrivilege:Add(tab)
            end
        end
    end
    self.NewListPrivilege:Clear()
    list = nil
    list = Utils.SplitStr(cfg.ShowNewPower,'_')
    if list ~= nil then
        for i = 1,#list do
            local powerId = tonumber(list[i])
            self.NewListPrivilege:Add(powerId)
        end
    end
end

function VipBaseData:GetPowerParam(id)
    if self.DicPowerParam:ContainsKey(id) then
        return self.DicPowerParam[id]
    end
    return 0
end

function VipBaseData:HavePrivilege(id)
    for i = 1, #self.ListPrivilege do
        if self.ListPrivilege[i].PowerId == id then
            return true
        end
    end
    return false
end

function VipBaseData:ParaseMsg()
end
return VipBaseData