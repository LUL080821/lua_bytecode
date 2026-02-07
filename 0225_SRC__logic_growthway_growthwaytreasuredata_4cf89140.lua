
------------------------------------------------
-- Author:
-- Date: 2019-07-15
-- File: GrowthWayTreasureData.lua
-- Module: GrowthWayTreasureData
-- Description: Reward data of the treasure chest of the road to growth
------------------------------------------------
-- Quote
local ItemData = require "Logic.ServeCrazy.ServeCrazyItemData"
local GrowthWayTreasureData = {
    CfgId = 0,
    -- Corresponding star
    StarNum = 0,
    IconId = 0,
    OpenIconId = 0,
    -- Whether to receive it
    IsReward = false,
    -- Is it a model or not
    IsModel = false,
    TexPath = nil,
    ListItem = List:New(),
}

-- Initialization ranking Cfg
function GrowthWayTreasureData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end
-- Analyze data
function GrowthWayTreasureData:Parase(cfg)
    if cfg == nil then
        return
    end
    self.CfgId = cfg.Id
    self.StarNum = cfg.Scroe
    self.IconId = cfg.LockPic
    self.OpenIconId = cfg.OpenPic
    self.IsReward = false
    self.TexPath = cfg.ShowTexture

    if cfg.IsModel == 1 then
        self.IsModel = true
    else
        self.IsModel = false
    end
    local player = GameCenter.GameSceneSystem:GetLocalPlayer()
    local playerOcc = 0
    if player then
        playerOcc = player.IntOcc
    end
    local list = Utils.SplitStr(cfg.Item,';')
    for i = 1,#list do
        local values = Utils.SplitStr(list[i],'_')
        local id = tonumber(values[1])
        local num = tonumber(values[2])
        local bind = tonumber(values[3])
        local occ = tonumber(values[4])
        if occ == 9 or occ == playerOcc then
            local item = {Id = id, Num = num, Bind = bind == 1}
            self.ListItem:Add(item)
        end
    end
end

-- Determine whether the treasure chest has been received
function GrowthWayTreasureData:SetReward(state, mask)
    if state & mask > 0 then
        self.IsReward = true
    else
        self.IsReward = false
    end
end

return GrowthWayTreasureData