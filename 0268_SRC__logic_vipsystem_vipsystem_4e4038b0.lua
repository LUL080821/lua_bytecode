
------------------------------------------------
-- author:
-- Date: 2019-12-16
-- File: VipSystem.lua
-- Module: VipSystem
-- Description: VIP system
------------------------------------------------
-- Quote
local BaseData = require "Logic.VipSystem.VipBaseData"
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local VipSystem = {
    -- Previous VIP level
    PrevLevel = -1,
    -- Maximum VIP level
    MaxVip = 0,
    -- Minimum VIP level
    MinVip = 0,
    -- VIP level before upgrading
    PreLevel = 0,
    -- Have you received today's gift package?
    IsRewardDaily = false,
    
    DicVipData = nil,


    -- Whether to display the accumulated recharge red dots
    IsShowRechargeRedPoint = false,
    -- Cumulative recharge amount
    CurRecharge = 0,
    -- Cumulative recharge data {Cfg, State: 0 Can be collected 1 Cannot be collected 2 Already received}
    ListRechargeData = List:New(),
    -- Cultivation and bodybuilding data {Cfg, IsShow, IsShowBtn, State}
    ListDuanTiData = List:New(),

    -- Have you received free VIP experience
    IsGetFreeVipExp = nil,
    -- Free VIP open task id
    FreeVIPTaskList = List:New(),
    -- Orb status
    BaoZhuState = -1,
    BaoZhuLeftTime = 0,
}

function VipSystem:Initialize()
    -- Initialize cumulative recharge data and cultivating body forging data
    self.ListRechargeData:Clear()
    self.ListDuanTiData:Clear()
    DataConfig.DataVIPTrueRecharge:Foreach(function(k, v)
        if v.Type == 1 then
            local data = {Cfg = v, State = 1}
            self.ListRechargeData:Add(data)
        elseif v.Type == 2 then
            local data = {Cfg = v, IsShow = false, State = 1}
            self.ListDuanTiData:Add(data)
        end
    end)
    self.TimerEventId = GameCenter.TimerEventSystem:AddTimeStampDayEvent(2, 2,
    true, nil, function(id, remainTime, param)
        -- Cross the sky
        self.IsRewardDaily = false
        self:CheckRedPoint()
    end)
    local _gCfg = DataConfig.DataGlobal[GlobalName.FreeVIP_AutoOpen_Task]
    if _gCfg ~= nil then
        local _ids = Utils.SplitNumber(_gCfg.Params, '_')
        if _ids ~= nil and #_ids > 0 then
            for i = 1, #_ids do
                self.FreeVIPTaskList:Add(_ids[i])
            end
        end
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
end

function VipSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.CoinChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_TASKFINISH, self.OnTaskFinish, self)
end

function VipSystem:GetVipDic()
    if self.DicVipData == nil then
        local index = 0
        self.DicVipData = Dictionary:New()
        DataConfig.DataVip:Foreach(function(k, v)
            if index == 0 then
                self.MinVip = k
            end
            local data = BaseData:New(v)
            data:ParseCfg(v)
            self.DicVipData:Add(k,data)
            index = index + 1
            self.MaxVip = k
        end)
    end
    return self.DicVipData
end

-- Get the player's vip level
function VipSystem:GetVipLevel()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        return lp.VipLevel
    end
    return 0
end

-- Get the player's VIP experience
function VipSystem:GetVipExp()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        return lp.VipExp
    end
    return 0
end

function VipSystem:GetVipData(lv)
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(lv) then
        return _dic[lv]
    end
    return nil
end

-- Get the experience required to upgrade the incoming VIP level
function VipSystem:GetLvExp(lv)
    if lv<self.MaxVip then
        local cfg = DataConfig.DataVip[lv+1]
        if cfg ~= nil  then
            return cfg.VipLevelUp
        end
    end
    return 0
end

-- Get a level gift package
function VipSystem:GetLvItems(lv)
    local _dic = self:GetVipDic()
    local data = _dic[lv]
    if data ~= nil then
        return data.ListLiBao
    end
    return nil
end

-- Get daily gift packs
function VipSystem:GetDailyItems(lv)
    local _dic = self:GetVipDic()
    local data = _dic[lv]
    if data ~= nil then
        return data.ListDayLiBao
    end
    return nil
end

-- Get resource id through currency id
function VipSystem:GetCoinIconId(coinId)
    local cfg = DataConfig.DataItem[coinId]
    if cfg == nil then
        return 0
    end
    return cfg.Icon
end

-- Get the original price
function VipSystem:GetOriginPriceTab(lv)
    local ret = nil
    local _dic = self:GetVipDic()
    local data = _dic[lv]
    if data ~= nil then
        local list = Utils.SplitStr(data.Cfg.VipRewardPriceOriginal,'_')
        ret = {ItemId = tonumber(list[1]), Price = tonumber(list[2])}
    end
    return ret
end

-- Get the current price
function VipSystem:GetCurPriceTab(lv)
    local ret = nil
    local _dic = self:GetVipDic()
    local data = _dic[lv]
    if data ~= nil then
        local list = Utils.SplitStr(data.Cfg.VipRewardPriceNow,'_')
        ret = {ItemId = tonumber(list[1]), Price = tonumber(list[2])}
    end
    return ret
end

function VipSystem:GetVipLevel()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        -- Set up VIP experience
        return lp.VipLevel
    end
    return 0
end

-- Get VIP privileged parameters
function VipSystem:GetCurVipPowerParam(id)
    local lv = self:GetVipLevel()
    if lv == 0 then
        return 0
    end
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(lv) then
        local data = _dic[lv]
        return data:GetPowerParam(id)
    end
    return 0
end

-- Get the next level VIP privilege parameters
function VipSystem:GetVipPowerParamByLv(lv,id)
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(lv) then
        local data = _dic[lv]
        return data:GetPowerParam(id)
    end
    return 0
end

-- Get VIP privilege description
function VipSystem:GetCurVipPowerDes(id)
    local des = ""
    local poweId = 0
    local lv = self:GetVipLevel()
    if lv == 0 then
        return des
    end
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(lv) then
        local data = _dic[lv]
        if data:HavePrivilege(id) then
            local param = data:GetPowerParam(id)
            local powerCfg = DataConfig.DataVipPower[id]
            if powerCfg ~= nil then
                des = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_VIP_chuandao_show_word"),param )
            end
        end
    end
    return des
end

function VipSystem:GetVipPowerDes(lv,id)
    local des = ""
    local poweId = 0
    if lv == 0 then
        return des
    end
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(lv) then
        local data = _dic[lv]
        if data:HavePrivilege(id) then
            local param = data:GetPowerParam(id)
            local powerCfg = DataConfig.DataVipPower[id]
            if powerCfg ~= nil then
                des = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_VIP_chuandao_show_word"), param )
            end
        end
    end
    return des
end

-- Does VIP have a privilege?
function VipSystem:IsHavePrivilegeID(id)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp == nil then
        return false
    end
    local _curBaseData = self:GetVipData(lp.VipLevel)
    if _curBaseData == nil then
        return false
    end
    return _curBaseData:HavePrivilege(id)
end

-- Get the privileged ID based on the copy ID
function VipSystem:GetPowerIDByCopyMap(copyId)
    if copyId == 5201 then
        -- The Gate of Heaven
         return 22
    elseif copyId == 6001 then
        -- Lingyun Demon Tower
         return 13
    elseif copyId == 6002 then
        -- Inner Demon Environment
        return 14
    elseif copyId == 6003 then
        -- Soul Locking Platform
        return 15
    else
        return -1
    end
end

-- Get the number of merges permission id based on the copy id
function VipSystem:GetMegrePowerIDByCopyMap(copyId)
    if copyId == 6001 then
        -- Lingyun Demon Tower
         return 33
    elseif copyId == 6002 then
        -- Inner Demon Environment
        return 32
    elseif copyId == 6003 then
        -- Soul Locking Platform
        return 31
    else
        return -1
    end
end

-- Get the privileged ID based on the boss copy ID
function VipSystem:GetPowerIDByBossId(bossId)
    -- World Boss
    if bossId == MapLogicTypeDefine.WorldBossCopy then
        return 16
    -- Boss set
    elseif bossId == MapLogicTypeDefine.SuitGemCopy then
        return 17
    -- Gem Boss
    elseif bossId == MapLogicTypeDefine.SuitGemCopy then
        return 18
    -- Realm Boss
    elseif bossId == MapLogicTypeDefine.StatureBossCopy then
        return 20
    else
        return - 1
    end
end

-- Get increased privileges after upgrading
function VipSystem:GetAddPrivilege()
    local privilegeList = List:New()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        local cfg = DataConfig.DataVip[lp.VipLevel]
        if cfg ~= nil then
            local list = Utils.SplitStr(cfg.VipUpPower,';')
            if list ~= nil then
                for i = 1,#list do
                    local values = Utils.SplitStr(list[i],'_')
                    if values ~= nil then
                        local id = tonumber(values[1])
                        local param = tonumber(values[2])
                        local powerCfg = DataConfig.DataVipPower[id]
                        if powerCfg ~= nil then
                            local des = nil
                            if param ~= 0 then
                                des = UIUtils.CSFormat( powerCfg.VipLevelUpDescribe,param )
                            else
                                des = powerCfg.VipLevelUpDescribe
                            end
                            privilegeList:Add(des)
                        end
                    end
                end
            end
        end
    end
    return privilegeList
end

-- Get the configuration table id that the Shenshu Forging Body has been received
function VipSystem:GetCurTrueVipCfgId()
    local id = 0
    for i = 1,#self.ListDuanTiData do
        if self.ListDuanTiData[i].State == 2 then
            id = self.ListDuanTiData[i].Cfg.Id
        end
    end
    return id
end


function VipSystem:Update(dt)
    if not self.IsGetFreeVipExp and self.WaitAutoOpenFreeVip and self:CanAutoOpenFreeVip() then
        GameCenter.PushFixEvent(UIEventDefine.UIFreeVIPForm_OPEN)
        self.WaitAutoOpenFreeVip = false
    end
end

function VipSystem:CoinChange(obj, sender)
    if obj > 0 and  obj == ItemTypeCode.VipExp then
        local exp = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.VipExp)
        self:ResVipExpChange(exp)
    end
end

function VipSystem:OnTaskFinish(obj, sender)
    if self.IsGetFreeVipExp == false and self.FreeVIPTaskList:Contains(obj) then
        self:TryAutoOpenFreeVipForm()
    end
end

-- Try opening the free VIP interface and then open it when it is available
function VipSystem:TryAutoOpenFreeVipForm()
    self.WaitAutoOpenFreeVip = true
end

-- Can I automatically open the free VIP interface? It can be opened in the wild picture non-boot mode
function VipSystem:CanAutoOpenFreeVip()
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg == nil then
        return false
    end
    if _mapCfg.Type == 5 or _mapCfg.Type == 2 then
        return false
    end
    if GameCenter.BlockingUpPromptSystem:IsRunning() then
        return false
    end
    return true
end

-- VIP experience changes
function VipSystem:ResVipExpChange(exp)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        -- Set up VIP experience
        local prevLv = 0
        local curLv = 0
        DataConfig.DataVip:Foreach(function(k, v)
            if lp.VipExp >= v.VipLevelUp then
                prevLv = k
            end
            if exp >= v.VipLevelUp then
                curLv = k
            end
        end)
        -- Check whether it is upgraded
        if prevLv < curLv then
            -- The player's VIP level has changed. The vip upgrade interface pops up
            lp.VipLevel = curLv
            GameCenter.PushFixEvent(UILuaEventDefine.UIVipLvForm_CLOSE)
            GameCenter.PushFixEvent(UILuaEventDefine.UIVipLvForm_OPEN)
            -- [GosuTracking] Call update event vip

            GosuSDK.TrackingEvent("vipUp", curLv)
            -- local data = {
            --     event = GosuSDK.Events.GOSU_VIP,
            --     data = {
            --         accountId = GosuSDK.GetLocalValue("account"),
            --         vipLevel = curLv
            --     }
            -- }


           
            -- GosuSDK.CallCSharpMethod("GTrackingFunction", "vipUp", GosuSDK.GetLocalValue("saveRoleId"), GosuSDK.GetLocalValue("saveEnterServerId"), math.tointeger(curLv))
        end
        lp.VipExp = exp
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_UPDATE)
    end
end

-- Check VIP red dots
function VipSystem:CheckRedPoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Vip, not self.IsRewardDaily and self:GetVipLevel() > 0 and self.BaoZhuState ~= 0)
end

-- Get the remaining time for displaying jewelry
function VipSystem:GetZhuBaoLeftTime()
    local _ret = 0
    _ret = self.BaoZhuLeftTime - GameCenter.HeartSystem.ServerTime
    return _ret
end

-- Whether the bead is open, including limited-time and non-limited time beads
function VipSystem:BaoZhuIsOpen()
    return self.BaoZhuState ~= 0
end
-------------------------msg-----------------------

-- Request vip
function VipSystem:ReqVip()
    GameCenter.Network.Send("MSG_Vip.ReqVip")
end

-- Request VIP to receive the award
function VipSystem:ReqVipReward()
    self.PreLevel = self:GetVipLevel()
    GameCenter.Network.Send("MSG_Vip.ReqVipReward")
end

-- Request to purchase a gift package
function VipSystem:ReqVipPurGift(vipLv)
    GameCenter.Network.Send("MSG_Vip.ReqVipPurGift", {lv = vipLv})
end

-- Request a recharge reward
function VipSystem:ReqVipRechargeReward(rewardId)
    GameCenter.Network.Send("MSG_Vip.ReqVipRechargeReward", {id = rewardId})
end

-- Request to activate orb
function VipSystem:ReqActiveVipPearl(t)
    GameCenter.Network.Send("MSG_Vip.ReqActiveVipPearl", {id = t})
end

-- Log in red dot
function VipSystem:ResVipRed(result)
    if result  == nil then
        return
    end
    local _oldGet = self.IsGetFreeVipExp
    self.IsGetFreeVipExp = result.isGetFreeAward
    self.IsRewardDaily = not result.isRed
    if _oldGet ~= self.IsGetFreeVipExp then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FREEVIP_GETSTATE_CHANGED)
    end
    self:CheckRedPoint()
end

-- Level list information
function VipSystem:ResVip(result)
    if result  == nil then
        return
    end
    self.IsRewardDaily = result.isGet
    local mask = 1
    local _dic = self:GetVipDic()
    local listKey = _dic:GetKeys()
    for i = 1,#listKey do
        mask = 1<<listKey[i]-1
        if result.hasGet & mask > 0 then
            _dic[listKey[i]].IsBuy = true
        else
            _dic[listKey[i]].IsBuy = false
        end
    end
    -- Set VIP level
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        -- Set up VIP experience
        self.CurLevel = lp.VipLevel
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_UPDATE)
end

-- Daily gift pack returns
function VipSystem:ResVipReward(result)
    if result  == nil then
        return
    end
    -- Daily gift packages are successfully purchased
    self.IsRewardDaily = true
    local level = self:GetVipLevel()
    local data = self:GetVipData(level)
    if data ~= nil then
        local itemList = List:New()
        for i = 1,#data.ListDayLiBao do
            local item = {Id = data.ListDayLiBao[i].Id, Num = data.ListDayLiBao[i].Num, IsBind = data.ListDayLiBao[i].Bind }
            itemList:Add(item)
        end
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, itemList)
    end
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_BUY_RESULT)
end

-- Return to purchase a level gift package
function VipSystem:ResVipPurGift(result)
    if result  == nil then
        return
    end
    -- Level gift package purchased successfully
    local _dic = self:GetVipDic()
    if _dic:ContainsKey(result.lv) then
        local data = _dic[result.lv]
        data.IsBuy = true
        local itemList = List:New()
        for i = 1,#data.ListLiBao do
            local item = {Id = data.ListLiBao[i].Id, Num = data.ListLiBao[i].Num, IsBind = data.ListLiBao[i].Bind }
            itemList:Add(item)
        end
        GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, itemList)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPFORM_BUY_RESULT)
end

-- Cumulative recharge amount
function VipSystem:ResVipRechageMoney(result)
    if result  == nil then
        return
    end
    local showRdPoint = false
    self.CurRecharge = result.money
    GameCenter.PaySystem:ResVipRechageMoney(self.CurRecharge)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp.PropMoudle.CurRecharge = self.CurRecharge
    end
    local _addGet = true
    for i = 1,#self.ListRechargeData do
        -- Set whether the state can be collected first
        if self.CurRecharge>= self.ListRechargeData[i].Cfg.RechargeLimit then
            -- Determine whether you have received it
            if self.ListRechargeData[i].State ~= 2 then
                self.ListRechargeData[i].State = 0
            end
        else
            self.ListRechargeData[i].State = 1
        end
        if not showRdPoint and self.ListRechargeData[i].State == 0 then
            showRdPoint = true
        end

        if self.ListRechargeData[i].State ~= 2 then
            -- As long as there is a non-received function, turn off the charging function
            _addGet = false
        end

        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipRecharge, not _addGet)
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipRecharge,showRdPoint)
    end

    local isShow = false
    local showRewardId = -1
    local haveRedPoint = false
    for i = 1,#self.ListDuanTiData do
        -- Set whether the state can be collected first
        if self.CurRecharge>= self.ListDuanTiData[i].Cfg.RechargeLimit then
            -- Status is set to receivable
            if self.ListDuanTiData[i].State ~= 2 then
                self.ListDuanTiData[i].State = 0
            end
        else
            self.ListDuanTiData[i].State = 1
        end
        if self.ListDuanTiData[i].State == 2 or self.ListDuanTiData[i].State == 0 then
            if self.ListDuanTiData[i].State == 0 then
                if showRewardId == -1 then
                    self.ListDuanTiData[i].IsShow = true
                    self.ListDuanTiData[i].IsShowBtn = true
                    showRewardId = i
                else
                    if not isShow then
                        self.ListDuanTiData[i].IsShowBtn = false
                        self.ListDuanTiData[i].IsShow = true
                        isShow = true
                    end
                end
            else
                self.ListDuanTiData[i].IsShow = true
            end
        else
            if not isShow then
                self.ListDuanTiData[i].IsShow = true
                isShow = true
            else
                self.ListDuanTiData[i].IsShow = false
            end
        end
        if not haveRedPoint then
            if self.ListDuanTiData[i].State == 0 then
                haveRedPoint = true
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipLianTi,haveRedPoint)
    -- Update the interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPRECHARGE_UPDATE)
    -- Synchronize Zhou Changhong dots
    GameCenter.ZhouChangSystem:UpdateRedPoint()
end

-- A cumulative recharge list has been received (including the cultivation god. Note that the cultivation god needs to be collected in the previous way before it can be collected in the next way)
function VipSystem:ResVipRechageRewardList(result)
    if result  == nil then
        return
    end
    local mask = 0
    local showRdPoint = false
    local _addGet = true
    for i = 1,#self.ListRechargeData do
        -- Set whether the state can be collected first
        if self.CurRecharge>= self.ListRechargeData[i].Cfg.RechargeLimit then
            -- Status is set to receivable
            self.ListRechargeData[i].State = 0
        else
            self.ListRechargeData[i].State = 1
        end
        -- Set whether to receive it through the server message
        mask = 1<<self.ListRechargeData[i].Cfg.Id-1
        if result.hasGet & mask > 0 then
            self.ListRechargeData[i].State = 2
        end
        if not showRdPoint and self.ListRechargeData[i].State == 0 then
            showRdPoint = true
        end

        if self.ListRechargeData[i].State ~= 2 then
            -- As long as there is a non-received function, turn off the charging function
            _addGet = false
        end
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipRecharge, not _addGet)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipRecharge,showRdPoint)


    local isShow = false
    local showRewardId = -1
    local haveRedPoint = false
    for i = 1,#self.ListDuanTiData do
        -- Set whether the state can be collected first
        if self.CurRecharge>= self.ListDuanTiData[i].Cfg.RechargeLimit then
            -- Status is set to receivable
            self.ListDuanTiData[i].State = 0
        else
            self.ListDuanTiData[i].State = 1
        end
        -- Set whether to receive it through the server message
        mask = 1<<self.ListDuanTiData[i].Cfg.Id-1
        if result.hasGet & mask > 0 then
            self.ListDuanTiData[i].State = 2
        end
        -- If received
        if self.ListDuanTiData[i].State == 2 or self.ListDuanTiData[i].State == 0 then
            if self.ListDuanTiData[i].State == 0 then
                if showRewardId == -1 then
                    self.ListDuanTiData[i].IsShow = true
                    self.ListDuanTiData[i].IsShowBtn = true
                    showRewardId = i
                else
                    if not isShow then
                        self.ListDuanTiData[i].IsShowBtn = false
                        self.ListDuanTiData[i].IsShow = true
                        isShow = true
                    else
                        self.ListDuanTiData[i].IsShow = false
                    end
                end
            else
                self.ListDuanTiData[i].IsShow = true
            end
        else
            if not isShow then
                self.ListDuanTiData[i].IsShow = true
                isShow = true
            else
                self.ListDuanTiData[i].IsShow = false
            end
        end
        if not haveRedPoint then
            if self.ListDuanTiData[i].State == 0 then
                haveRedPoint = true
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipLianTi,haveRedPoint)
end

-- Recharge accumulative return
function VipSystem:ResVipRechargeReward(result)
    if result  == nil then
        return
    end
    local _addGet = true
    local showRdPoint = false
    for i = 1,#self.ListRechargeData do
        if self.ListRechargeData[i].Cfg.Id == result.id then
            self.ListRechargeData[i].State = 2
        end
        if not showRdPoint and self.ListRechargeData[i].State == 0 then
            showRdPoint = true
        end

        if self.ListRechargeData[i].State ~= 2 then
            -- As long as there is a non-received function, turn off the charging function
            _addGet = false
        end
    end
    if _addGet and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.VipRecharge) then
        Utils.ShowMsgBoxAndBtn(function(code)
            GameCenter.PushFixEvent(UIEventDefine.UIVipRechargeForm_Close)
        end, "VIPSYSTEM_TISHI_2", "VIPSYSTEM_TISHI_1")
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipRecharge, not _addGet)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipRecharge,showRdPoint)
     local isShow = false
     local showRewardId = -1
     local haveRedPoint = false
     for i = 1,#self.ListDuanTiData do
         if self.ListDuanTiData[i].Cfg.Id == result.id then
             self.ListDuanTiData[i].State = 2
         end
         -- If received
         if self.ListDuanTiData[i].State == 2 or self.ListDuanTiData[i].State == 0 then
            if self.ListDuanTiData[i].State == 0 then
                if showRewardId == -1 then
                    self.ListDuanTiData[i].IsShowBtn = true
                    showRewardId = i
                end
            end
             self.ListDuanTiData[i].IsShow = true
         else
             if not isShow then
                 self.ListDuanTiData[i].IsShowBtn = false
                 self.ListDuanTiData[i].IsShow = true
                 isShow = true
             else
                 self.ListDuanTiData[i].IsShow = false
             end
         end
         if not haveRedPoint then
            if self.ListDuanTiData[i].State == 0 then
                haveRedPoint = true
            end
        end
     end

     GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.VipLianTi,haveRedPoint)
    -- Send message update interface
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_VIPRECHARGE_UPDATE)
end

function VipSystem:ResSpecialVipStateInfo(msg)
    if msg == nil then
        return
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationZunGui, false)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationNormal, false)
    local _isTiShi = false
    local _isShowFunc = false
    local _normal = msg.normalVip
    local _high = msg.highVip
    if _high ~= nil then
        if _high.isActivate then
            if not _high.isNotifyClient then
                -- Popup prompt
                _isTiShi = true
                GameCenter.PushFixEvent(UILuaEventDefine.UIVipInvationForm_OPEN, 2)
            end
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationZunGui, true)
            _isShowFunc = true
        else
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationZunGui, false)
        end
    end
    if not _isTiShi then
        if _normal.isActivate then
            if not _normal.isNotifyClient then
                -- Popup prompt
                _isTiShi = true
                GameCenter.PushFixEvent(UILuaEventDefine.UIVipInvationForm_OPEN, 1)
            end
            if not _isShowFunc then
                GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationNormal, true)
            end
        else
            GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.VipInvationNormal, false)
        end
    end
end

function VipSystem:ResVipPearlInfo(msg)
    if msg == nil then
        return msg
    end
    self.BaoZhuState = msg.state
    self.BaoZhuLeftTime = msg.deadLine
    if msg.isActive then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.Vip)
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("VIP_Powe_Sucs_Notice"))
    end
end

return VipSystem
