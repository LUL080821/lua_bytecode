
------------------------------------------------
-- Author:
-- Date: 2019-07-11
-- File: ServeCrazySystem.lua
-- Module: ServeCrazySystem
-- Description: Opening the server carnival system
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local CrazyData = require "Logic.ServeCrazy.ServeCrazyData"
local ServeCrazySystem = {
    MenuType = 0,
    -- Service opening time
    ServerOpenTime = 0,
    -- Refresh time
    ReFreshTime = 0,
    -- Function opening list
    DicFuncEnable = Dictionary:New(),
    -- Opening a server carnival data dictionary
    DicCrazyData = Dictionary:New(),
    -- Menu red dot display key: The corresponding menu Type value: Whether to display red dots
    DicMenuRedPointShow = Dictionary:New(),

    -- Boss first kill data
    ListFirstKillData = List:New(),
    --CacheKillData = List:New(),

    -- Red envelope message cache
    ListNotice = List:New(),
    -- Red envelope prompts whether the form is displayed
    IsShowNotice = false,
    IsShowFirstKillRedPoint = false,
    -- Did you click on the daily special offer
    IsClickShop = false,
    PreShow = false,
    RankTypeList = List:New(),

    -- Is the first kill function enabled?
    FirstKillIsOpen = true,
    -- Whether to enter the scene
    IsEnterScene = false,
}

function ServeCrazySystem:Initialize()
    self.DicCrazyData:Clear()
    self.DicMenuRedPointShow:Clear()
    -- Initialize configuration table data
    DataConfig.DataNewSeverRankrew:Foreach(function(k, v)
        local crazyData = nil
        local key = v.Type
        if self.DicCrazyData:ContainsKey(key) then
            crazyData = self.DicCrazyData[key]
            crazyData:AddData(v)
        else
            crazyData = CrazyData:New()
            crazyData:ParseCfg(v)
            self.DicCrazyData[key] = crazyData
        end
    end)

    self.DicMenuRedPointShow[0] = false
    self.PreShow = false
    self.DicCrazyData:Foreach(function(k, v)
        self.DicMenuRedPointShow[k] = false
    end)
    self.ReFreshTime = tonumber(DataConfig.DataGlobal[1551].Params)

    self.ListFirstKillData:Clear()
    DataConfig.DataBossFirstBlood:Foreach(function(k, v)
        local data = {Cfg = v, KillInfo = nil}
        self.ListFirstKillData:Add(data)
    end)

    self.RankTypeList:Clear()
    DataConfig.DataNewSeverRank:Foreach(function(k, v)
        self.RankTypeList:Add(v.Id)
    end)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnEnterScene, self)
    --
end

function ServeCrazySystem:UnInitialize()
    self.IsShowFirstKillRedPoint = false
    self.IsEnterScene = false
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnEnterScene, self)
end

function ServeCrazySystem:OnFuncUpdated(funcData, sender)
    if funcData.ID == FunctionStartIdCode.FirstKill then
        self.FirstKillIsOpen = funcData.IsVisible
    end
end

-- Get the currently selected carnival data
function ServeCrazySystem:GetCurCrazyData()
    if self.DicCrazyData:ContainsKey(self.MenuType) then
        return self.DicCrazyData[self.MenuType]
    end
    return nil
end

-- Get the carnival data corresponding to the incoming menu Type
function ServeCrazySystem:GetCrazyData(menuType) 
    if self.DicCrazyData:ContainsKey(menuType) then
        return self.DicCrazyData[menuType]
    end
    return nil
end

-- Get what day it is currently on
function ServeCrazySystem:GetCurOpenTime()
    local time = math.floor( GameCenter.HeartSystem.ServerTime - GameCenter.ServeCrazySystem.ServerOpenTime )
    -- What time is the day when the server is launched
    local hour, min, sec = TimeUtils.GetStampTimeHHMMSS(math.floor(GameCenter.ServeCrazySystem.ServerOpenTime))
    local curSeconds = hour * 3600 + min * 60 + sec
    time = time - (24 * 3600 - curSeconds)
    local openTime = 0
    if time < curSeconds then
        openTime = 1
    else
        openTime = math.floor( time/(24*3600) ) + 2
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CALCULATE_OPENSERVERTIME,openTime)
    return openTime
end

-- Obtain the first kill boss data according to the configuration
function ServeCrazySystem:GetBossDataById(id)
    for i = 1,#self.ListFirstKillData do
        local killData = self.ListFirstKillData[i]
        if killData.Cfg.ID == id then
            return killData
        end
    end
    return nil
end

function ServeCrazySystem:GetBossDataIndex(id)
    for i = 1,#self.ListFirstKillData do
        local killData = self.ListFirstKillData[i]
        if killData.Cfg.ID == id then
            return i
        end
    end
    return 1
end

function ServeCrazySystem:BossKillHaveAward()
    local isHave = false
    for i = 1, #self.ListFirstKillData do
        local data = self.ListFirstKillData[i]
        if data.KillInfo ~= nil then
            if data.KillInfo.state == 1 or data.KillInfo.redpacketState == 1 then
                if not isHave then
                    isHave = true
                    break
                end
            end
        end
    end
    return isHave
end

function ServeCrazySystem:BossKillHaveAwardById(cfgId)
    local isHave = false
    for i = 1, #self.ListFirstKillData do
        local data = self.ListFirstKillData[i]
        if data.KillInfo ~= nil and data.Cfg.ID == cfgId then
            if data.KillInfo.state == 1 or data.KillInfo.redpacketState == 1 then
                if not isHave then
                    isHave = true
                    break
                end
            end
        end
    end
    return isHave
end

function ServeCrazySystem:GetBossKillDefaultId()
    local id = -1
    for i = 1, #self.ListFirstKillData do
        local data = self.ListFirstKillData[i]
        if data.KillInfo ~= nil then
            if data.KillInfo.state == 1 or data.KillInfo.redpacketState == 1 then
                id = data.Cfg.ID
                break
            end
        end
    end
    if id == -1 then
        for i = 1, #self.ListFirstKillData do
            local data = self.ListFirstKillData[i]
            if data.KillInfo ~= nil then
                if data.KillInfo.reliveTime == 0 then
                    id = data.Cfg.ID
                    break
                end
            end
        end
    end
    if id == -1 then
        id = self.ListFirstKillData[1].Cfg.ID
    end
    return id
end

function ServeCrazySystem:IsRewardRedpacket(cfgId)
    for i = 1, #self.ListFirstKillData do
        local data = self.ListFirstKillData[i]
        if data.KillInfo ~= nil and data.Cfg.ID == cfgId then
            if data.KillInfo.redpacketState == 2 then
                return true
            end
        end
    end
    return false
end

function ServeCrazySystem:OnEnterScene(obj, sender)
    self.IsEnterScene = true
end

function ServeCrazySystem:Update(dt)
    -- Reduce call frequency
    -- if Time.GetFrameCount() % 10 ~= 0 then
    --     return
    -- end
    local isShow = false
    --self.DicMenuRedPointShow[0]
    for k, v in pairs(self.DicCrazyData) do
        local have = v:HaveReward()
        self.DicMenuRedPointShow[k] = have
        if not isShow and have then
            isShow = true
        end
    end
    local _isLucky = false
    if self.IsEnterScene then
        if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.LucyCard) then
            _isLucky = GameCenter.LuckyCardSystem:HaveRedPoint()
        end
    end
    isShow = isShow or _isLucky
    if not isShow then
        if self.FirstKillIsOpen then
            if self.IsShowFirstKillRedPoint then
                self.DicMenuRedPointShow[0] = true
                self.IsShowFirstKillRedPoint = false
            end
            isShow = self.DicMenuRedPointShow[0]
            if not isShow then
                -- Find out if there is a first kill reward but no reward
                for i = 1,#self.ListFirstKillData do
                    local _data = self.ListFirstKillData[i]
                    if _data ~= nil and _data.KillInfo ~= nil and (_data.KillInfo.state == 1 or _data.KillInfo.redpacketState == 1) then
                        isShow = true
                        break
                    end
                end
            end
        end
    end
    if self.PreShow ~= isShow then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.ServeCrazy,isShow)
        self.PreShow = isShow
    end

    -- Red envelope prompt form pop-up processing
    local canShowNotice = false
    if GameCenter.MapLogicSystem.MapCfg~= nil and GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.DuJieCopy then
        canShowNotice = true
    end
    if canShowNotice and not self.IsShowNotice and #self.ListNotice > 0 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIBossKillNoticeForm_OPEN,self.ListNotice[1])
        self.ListNotice:RemoveAt(1)
    end
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ServeCrazySystem:ReqOpenServerRevel()
	GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenServerRevel")
end

function ServeCrazySystem:ReqOpenSeverRevelReward(cfgId)
	GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenSeverRevelReward", {id = cfgId})
end

function ServeCrazySystem:ReqOpenSeverRevelPersonReward(cfgId)
	GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenSeverRevelPersonReward", {id = cfgId})
end

-- Request to open the boss first kill interface
function ServeCrazySystem:ReqOpenFirstKillPanel()
	GameCenter.Network.Send("MSG_OpenServerAc.ReqOpenFirstKillPanel")
end

-- Request the boss to win the prize
function ServeCrazySystem:ReqGetKillReward(cfgId)
	GameCenter.Network.Send("MSG_OpenServerAc.ReqGetKillReward", {id = cfgId})
end

-- Request boss's first kill red envelope to receive the prize
function ServeCrazySystem:ReqHongBaoReward(cfgId)
	GameCenter.Network.Send("MSG_OpenServerAc.ReqHongBaoReward", {id = cfgId})
end

-- Request a great discount product status
function ServeCrazySystem:ReqCheckDiscRechargeGoods(ids, t)
    GameCenter.Network.Send("MSG_Recharge.ReqCheckDiscRechargeGoods", {goodsId = ids, type = t})
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online push
function ServeCrazySystem:GS2U_ResOpenSeverRevelList(result)
    if result == nil  then
        return
    end
    self.ServerOpenTime = result.openTime / 1000
    if result.revels ~= nil then
        for i = 1, #result.revels do
            local key = result.revels[i].id
            local crazyData = self:GetCrazyData(key)
            if crazyData ~= nil then
                crazyData:ParaseMsg(result.revels[i])
            end
        end
    end
    self:GetCurOpenTime()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVECRAZYFORM_OPENRESULT)
end
-- Server refresh timed
function ServeCrazySystem:GS2U_ResOpenSeverRevelInfo(result)
    if result == nil  then
        return
    end
    local key = result.revel.id
    if self.DicCrazyData:ContainsKey(key) then
        local crazyData = self.DicCrazyData[key]
        crazyData:ParaseMsg(result.revel)
        -- Update the UI interface
        GameCenter.PushFixEvent(UIEventDefine.EID_EVENT_SERVECRAZYFORM_UPDATE)
    end
end
-- Return to receive the prize
function ServeCrazySystem:GS2U_ResOpenSeverRevelReward(result)
    if result == nil  then
        return
    end
    --local key = DataConfig.DataNewSeverRankrew[result.id]
    local cfg = DataConfig.DataNewSeverRankrew[result.id]
    if self.DicCrazyData:ContainsKey(cfg.Type) then
        local crazyData = self.DicCrazyData[cfg.Type]
        -- Settings have been collected
        crazyData.RewardState = 2
    end
    GameCenter.PushFixEvent(UIEventDefine.EID_EVENT_SERVECRAZYFORM_UPDATE)
end

-- Return to receive the prize in person
function ServeCrazySystem:GS2U_ResOpenSeverRevelPersonReward(result)
    if result == nil  then
        return  
    end
    local cfg = DataConfig.DataNewSeverRankrew[result.id]
    if self.DicCrazyData:ContainsKey(cfg.Type) then
        local crazyData = self.DicCrazyData[cfg.Type]
        -- SetRunTimeRewardState
        crazyData:SetRunTimeRewardState(result.id,2)
        local showList = List:New()
        local listItem = crazyData:GetRewardItems(result.id)
        local occ = 0
        local player = GameCenter.GameSceneSystem:GetLocalPlayer()

        if player then
            occ = player.IntOcc
        end
        local itemList = List:New()
        for i = 1, #listItem do
            if listItem[i].Occ == 9 or listItem[i].Occ == occ then
                itemList:Add(listItem[i])
            end
        end

        if itemList ~= nil then
            for i = 1,#itemList do
                local tab = {Id = itemList[i].Id ,Num = itemList[i].Num, IsBind = true}
                showList:Add(tab)
            end
        end
        -- Show award-winning interface
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN,showList)
    end
    --GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVECRAZYFORM_REWARD, result.id)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SERVECRAZYFORM_UPDATE)
end

-- Open the boss first kill UI request to return
function ServeCrazySystem:ResOpenFirstKillPanel(msg)
    if msg == nil then
        return
    end
    if msg.bossInfo ~= nil then
        for i = 1,#self.ListFirstKillData do
            local killData = self.ListFirstKillData[i]
            for m = 1, #msg.bossInfo do
                if killData.Cfg.ID == msg.bossInfo[m].cfgId then
                    killData.KillInfo = msg.bossInfo[m]
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FBOSSKILL_UPDATE, true)
end

function ServeCrazySystem:ResFirstKillBossInfo(msg)
    if msg == nil then
        return
    end
    for i = 1, #self.ListFirstKillData do
        local data = self.ListFirstKillData[i]
        for m = 1, #msg.bossInfo do
            if data.Cfg.ID == msg.bossInfo[m].cfgId then
                data.KillInfo.reliveTime = msg.bossInfo[m].reliveTime
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FBOSSKILL_UPDATE, false)
end

-- Boss' first killing individual returns
function ServeCrazySystem:ResGetKillReward(msg)
    if msg == nil then
        return
    end
    for i = 1,#self.ListFirstKillData do
        local killData = self.ListFirstKillData[i]
        if killData.Cfg.ID == msg.id then
            killData.KillInfo.state = 2
            break
        end
    end
    -- Update the first kill interface
    local isHave = self:BossKillHaveAwardById(msg.id)
    if not isHave then
        self.DicMenuRedPointShow[0] = false
    end
    local isReset = not isHave
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FBOSSKILL_UPDATE, isReset)
end

-- Receive the first kill red envelope for boss
function ServeCrazySystem:ResHongBaoReward(msg)
    if msg == nil then
        return
    end
    for i = 1,#self.ListFirstKillData do
        local killData = self.ListFirstKillData[i]
        if killData.Cfg.ID == msg.id then
            if killData.KillInfo ~= nil then
                killData.KillInfo.redpacketState = 2
            end
            break
        end
    end
    local isHave = self:BossKillHaveAwardById(msg.id)
    if not isHave then
        self.DicMenuRedPointShow[0] = false
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FBOSSKILL_HONGBAO_RESULT)
end

function ServeCrazySystem:ResFirstKillAdvice(msg)
    --GameCenter.PushFixEvent(UILuaEventDefine.UIBossKillNoticeForm_CLOSE)
    if msg == nil then
        return
    end
    self.ListNotice:Add(msg)
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FirstKill) then
        self.DicMenuRedPointShow[0] = true
        self.IsShowFirstKillRedPoint = true
    end
    --GameCenter.PushFixEvent(UILuaEventDefine.UIBossKillNoticeForm_OPEN,msg)
end

function ServeCrazySystem:ResFirstKillRedPoint(msg)
    -- if msg == nil then
    --     return
    -- end
    -- if self.ListFirstKillData == nil then
    --     return
    -- end
    -- local _isFind = false
    -- for i = 1, #self.CacheKillData do
    --     local _data = self.CacheKillData[i]
    --     if _data.Id == msg.cfgId then
    --         _data.State = msg.state
    --         _data.RedState = msg.redpacketState
    --         _isFind = true
    --     end
    -- end
    -- if not _isFind then
    --     self.CacheKillData:Add({Id = msg.cfgId, State = msg.state, RedState = msg.redpacketState})
    -- end
end

-- Return to the status of the discounted product
function ServeCrazySystem:ResCheckDiscRechargeGoods(msg)
    if msg == nil then
        return
    end
    if msg.check == nil then
        return
    end
    for i = 1, #msg.check do
        local info = msg.check[i]
        if info.state == 1 then
            -- Not enabled
            local _data = {Type = msg.type, State = 1}
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIMITSHOP_CHECK_RESULT, _data)
            break
        elseif info.state == 2 then
            -- Ended
            local _data = {Type = msg.type, State = 2}
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIMITSHOP_CHECK_RESULT, _data)
            break
        end
    end
end

return ServeCrazySystem