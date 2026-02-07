------------------------------------------------
-- author:
-- Date: 2020-02-21
-- File: XMBossSystem.lua
-- Module: XMBossSystem
-- Description: Xianmeng Boss System
------------------------------------------------
local XMBossSystem = {
    BossID = -1,
    -- Number of times gold coins are encouraged
    HeartenCountGold = 0,
    -- Number of times of encouragement of ingots
    HeartenCountYB = 0,
    -- Coin consumption list
    CostGoldArr = List:New(),
    -- Ingot consumption list
    CostYBArr = List:New(),
    -- A percentage increase in single encouragement
    SingleHeartenAddValue = 0,
    -- Whether to detect small red dots
    IsCheckRedpoint = false,
    -- Panel information
    MsgPannelData = nil,
    -- Synchronous Immortal Alliance boss damage ranking
    MsgSyncDamageData = nil,
    -- Encourage data to return
    MsgInspireData = {ownMoneyNum=0,ownGoldNum=0,guildNum=0},
    -- Return to the end time of the boss opening in the map
    MsgOCTimeData = {openTime=0,closeTime=0},
    -- Immortal Alliance boss settlement
    MsgResultData = nil,
    -- Is it possible to find a way after teleporting to the map
    IsFindPath = false,
}

function XMBossSystem:Initialize()
    self.BossID = tonumber(Utils.SplitStr(DataConfig.DataGlobal[1770].Params,"_")[1]);

    local _strArr = Utils.SplitStr(DataConfig.DataGlobal[1766].Params,"_")
    self.HeartenCountGold = tonumber(_strArr[1] or 0)
    self.HeartenCountYB = tonumber(_strArr[2] or 0)
    local _costGoldArr = Utils.SplitStr(DataConfig.DataGlobal[1767].Params,"_")
    for i=1,#_costGoldArr do
        self.CostGoldArr:Add(_costGoldArr[i])
    end
    local _costYBArr = Utils.SplitStr(DataConfig.DataGlobal[1768].Params,"_")
    for i=1,#_costYBArr do
        self.CostYBArr:Add(_costYBArr[i])
    end
    self.SingleHeartenAddValue = tonumber(DataConfig.DataGlobal[1769].Params)/100
    self.MsgInspireData = {ownMoneyNum=0,ownGoldNum=0,guildNum=0};
    -- self.MsgResultData = {rank = 2,damage=666666,
    --     itemInfoList={
    --         {itemModelId=1001,num=1,isbind=false},{itemModelId=1002,num=2,isbind=false},
    --     },
    --     auctionList={
    --         {itemModelId=1,num=11,isbind=false},{itemModelId=3,num=12,isbind=false}
    --     }
    -- }
end

function XMBossSystem:UnInitialize()
    self.CostGoldArr:Clear()
    self.CostYBArr:Clear()
end

-- Refresh the red dots
function XMBossSystem:RefreshRepoint()
    -- GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.GuildBoss, GameCenter.HeartSystem.ServerTime >= self.MsgOCTimeData.openTime)
end

-- Is there a red dot
function XMBossSystem:IsRepoint()
    return GameCenter.HeartSystem.ServerTime >= self.MsgOCTimeData.openTime and GameCenter.HeartSystem.ServerTime < self.MsgOCTimeData.closeTime
end

-- renew
function XMBossSystem:Update()
    if self.MsgOCTimeData then 
        if self.IsCheckRedpoint then
            if GameCenter.HeartSystem.ServerTime >= self.MsgOCTimeData.openTime then
                self.IsCheckRedpoint = false
                self:RefreshRepoint()
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMBOSS_REFRSH)
            end
        end
    end
end

function XMBossSystem:Sort(list)
    if list ~= nil then
        table.sort(list, function(a, b)
            if a.damage == b.damage then
                return a.id > b.id 
            else
                return a.damage > b.damage
            end 
        end)
    end
end

-- Do you complete your encouragement
function XMBossSystem:IsCompleteHearten()
    if self.MsgInspireData then
        return not self.CostGoldArr[self.MsgInspireData.ownMoneyNum+1] and not self.CostYBArr[self.MsgInspireData.ownGoldNum+1];
    end
    return false;
end

-- ========================================================================
-- Boss damage data
-- message guildBossDamageInfo
-- {
-- 	required int64 id = 1;
-- 	required string name = 2;
-- 	required int64 damage = 3;
-- }

-- Request to open the Xianmeng boss panel
function XMBossSystem:ReqOpenGuildBossPannel()
    ReqMsg.MSG_GuildBoss.ReqOpenGuildBossPannel:New():Send();
end

-- Request for encouragement
function XMBossSystem:ReqGuildBossInspire(inspireType)
    local _msg = ReqMsg.MSG_GuildBoss.ReqGuildBossInspire:New();
    _msg.type = inspireType;
    _msg:Send();
end

-- Immortal Alliance boss panel return
-- repeated guildBossDamageInfo guildInfo = 1; //Xianlian damage ranking
-- repeated guildBossDamageInfo personInfo = 2; //Personal injury ranking
function XMBossSystem:ResGuildBossPannel(msg)
    self.MsgPannelData = msg;
    if self.MsgPannelData.guildInfo then
        self:Sort(self.MsgPannelData.guildInfo)
    end
    if self.MsgPannelData.personInfo then
        self:Sort(self.MsgPannelData.personInfo)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMBOSS_REFRSH)
end

-- Synchronous Immortal Alliance boss damage ranking
-- repeated guildBossDamageInfo guildInfo = 1; //Xianlian damage ranking
-- repeated guildBossDamageInfo personInfo = 2; //Personal injury ranking
function XMBossSystem:ResSyncGuildBossDamage(msg)
    self.MsgSyncDamageData = msg;
    if self.MsgSyncDamageData.guildInfo then
        self:Sort(self.MsgSyncDamageData.guildInfo)
    end
    if self.MsgSyncDamageData.personInfo then
        self:Sort(self.MsgSyncDamageData.personInfo)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMBOSSRANK_REFRSHRANK)
end

-- Encourage data to return
-- required int32 ownNum = 1; //Num of times you encourage yourself
-- required int32 guildNum = 2; //Number of times the Xianmeng encouragement
function XMBossSystem:ResGuildBossInspire(msg)
    self.MsgInspireData = msg;
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMBOSSHEARTEN_REFRSH)
end

-- Return to the end time of the boss opening in the map
-- required int32 openTime = 1; //Open time
-- required int32 closeTime = 2; //End time
function XMBossSystem:ResGuildBossOCTime(msg)
    self.MsgOCTimeData = msg;
    self.IsCheckRedpoint = GameCenter.HeartSystem.ServerTime < self.MsgOCTimeData.openTime
    self:RefreshRepoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XMBOSS_REFRSH)
end

-- Immortal Alliance boss settlement
-- required int32 rank = 1; // Ranking
-- required int64 damage = 2; //Total damage
-- repeated MSG_backpack.ItemInfo itemInfoList = 3; //Reward list
function XMBossSystem:ResGuildBossResult(msg)
    self.MsgResultData = msg;
    GameCenter.PushFixEvent(UILuaEventDefine.UIXMBossResultForm_OPEN)
    GameCenter.PushFixEvent(UILuaEventDefine.UIXmAuctionTipsForm_OPEN)
end

return XMBossSystem
