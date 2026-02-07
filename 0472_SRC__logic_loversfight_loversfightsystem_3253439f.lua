
------------------------------------------------
-- Author:
-- Date: 2021-07-15
-- File: LoversFightSystem.lua
-- Module: LoversFightSystem
-- Description: Fairy Couple Showdown System
------------------------------------------------
local L_TeamInfo = require "Logic.LoversFight.LoversTeamInfo"
local L_RankInfo = require "Logic.LoversFight.LoversRankInfo"
local L_GroupInfo = require "Logic.LoversFight.LoversGroupData"
local L_TopInfo = require "Logic.LoversFight.LoversTopData"
local L_TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition

local LoversFightSystem = {
    -- Examinations data
    FreeData = nil,
    -- Examinations Ranking
    FreeRankList = List:New(),
    -- List of the auditions
    FreeSelfRank = 0,
    -- Whether the auditions match automatically agrees
    FreeAuto = false,
    -- Group stage data
    GroupData = nil,
    -- championship
    TopData = nil,
    FansList = List:New(),
    -- Reward Dictionary
    RewardDic = nil,
    -- Xianlu Store Product Dictionary
    ShopsDic = nil,
    ShopPriceList = nil,
    -- Cache copy messages
    CacheCopyMsgList = List:New(),
    PreServerTime = 0,
    -- Current week
    CurWeek = 0,
    -- Initial seconds
    StartSec = 0,
    -- Whether the time was initialized
    IsInitTime = false,
    -- Main interface icon id
    MainIconID = nil,
    IsPiPeiWait = false,
    FightStep = 0,
    IsShowRule = false,
    Occ = nil,
    -- The first time I entered the game, I had a red spot
    IsShowRankRed = true,
    PreStep = 0,
}

function LoversFightSystem:Initialize()
    -- Add timer
    self.IsShowRule = false
    self.TimerID = GameCenter.TimerEventSystem:AddTimeStampDayEvent(10, 86400,
    true, nil, function(id, remainTime, param)
        self:InitWeekSec()
    end)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnEnterScene, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

function LoversFightSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.OnEnterScene, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
end

function LoversFightSystem:OnFuncUpdated(funcInfo, sender)
    if funcInfo.ID == FunctionStartIdCode.LoversFight then
        local _isVisible = funcInfo.IsVisible
        if _isVisible then
            if self.MainIconID == nil then
                self.MainIconID = GameCenter.MainCustomBtnSystem:AddBtn(2126, funcInfo.Text, nil,
                function(btn)
                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LoversFight)
                end, true, funcInfo.IsShowRedPoint, false, 0)
            end
            GameCenter.MainCustomBtnSystem:SetShowRedPoint(self.MainIconID, funcInfo.IsShowRedPoint)
        else
            if self.MainIconID ~= nil then
                GameCenter.MainCustomBtnSystem:RemoveBtn(self.MainIconID)
            end
            self.MainIconID = nil
        end
    end
end

function LoversFightSystem:OnEnterScene(obj, sender)
    self:InitWeekSec()
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LoversFight))
    local _freeData = self:GetFreeData()
    if _freeData ~= nil then
        self:CheckFreeRedPoint()
        if _freeData.IsMsgTishi then
            if _freeData:CheckMsgTpis(self.CurWeek, self.StartSec) then
                _freeData.IsTickTiShi = false
            end
        end
    end
    local _groupData = self:GetGroupData()
    if _groupData ~= nil and _groupData.IsReceiveJinJi then
        if _groupData.IsMsgTishi then
            if _groupData:CheckMsgTpis(self.CurWeek, self.StartSec) then
                _groupData.IsTickTiShi = false
            end
        end
        if GameCenter.MapLogicSystem.MapCfg ~= nil then
            if GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightFight and
            GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightWait then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversGroupFight, true)
            else
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversGroupFight, false)
            end
        end
    end
    local _topData = self:GetTopData()
    if _topData ~= nil and _topData.L_IsReceiveJinJi then
        if _topData.L_IsMsgTishi then
            if _topData:CheckMsgTpisL(self.CurWeek, self.StartSec) then
                _topData.L_IsTickTiShi = false
            end
        end
        if GameCenter.MapLogicSystem.MapCfg ~= nil then
            if GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightFight and
            GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightWait then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightL, true)
            else
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightL, false)
            end
        end
    end
    if _topData ~= nil and _topData.H_IsReceiveJinJi then
        if _topData.H_IsMsgTishi then
            if _topData:CheckMsgTpisH(self.CurWeek, self.StartSec) then
                _topData.H_IsTickTiShi = false
            end
        end
        if GameCenter.MapLogicSystem.MapCfg ~= nil then
            if GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightFight and
            GameCenter.MapLogicSystem.MapCfg.MapLogicType ~= MapLogicTypeDefine.LoversFightWait then
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightH, true)
            else
                GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightH, false)
            end
        end
    end

    if self.IsShowRankRed then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversRankRewards, true)
        self.IsShowRankRed = false
    end
    self:CheckShopRed()
end

function LoversFightSystem:InitWeekSec()
    local _serverTime = math.floor( GameCenter.HeartSystem.ServerZoneTime )
    self.CurWeek = L_TimeUtils.GetStampTimeWeeklyNotZone(_serverTime)
    if self.CurWeek == 0 then
        self.CurWeek = 7
    end
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSec = _hour * 3600 + _min * 60 + _sec
    self.StartSec = GameCenter.HeartSystem.ServerZoneTime - _curSec
    self.IsInitTime = true
end

function LoversFightSystem:GetRewardsDic()
    local _lpOcc = 0
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lpOcc = _lp.IntOcc
    end
    if self.RewardDic == nil then
        self.RewardDic = Dictionary:New()
        local function _Func(key, value)
            if value ~= nil then
                local _itemList = List:New()
                local _list = Utils.SplitStr(value.RewardItem, ';')
                if _list ~= nil then
                    for i = 1, #_list do
                        local _itemStr = Utils.SplitNumber(_list[i], '_')
                        local _id = _itemStr[1]
                        local _num = _itemStr[2]
                        local _bind = _itemStr[3] == 1
                        local _occ = _itemStr[4]
                        if _lpOcc == _occ or _occ == 9 then
                            local _item = {Id = _id, Num = _num, IsBind = _bind }
                            _itemList:Add(_item)
                        end
                    end
                end
                local _type = value.Type
                local _des = value.Des
                local _data = {Id = key, IsReward = false, Count = value.Parm ,Itemlist = _itemList , Des = _des}
                local _listData = self.RewardDic[_type]
                if _listData == nil then
                    _listData = List:New()
                    _listData:Add(_data)
                    self.RewardDic:Add(_type, _listData)
                else
                    _listData:Add(_data)
                end
            end
        end
        DataConfig.DataMarryBattleReward:Foreach(_Func)
    end
    return self.RewardDic
end

function LoversFightSystem:GetShopsDic()
    if self.ShopsDic == nil then
        self.ShopsDic = List:New()
        local function _Func(key, value)
            if value ~= nil and self:CheckOcc(value.Occ) then
                self.ShopsDic:Add(value)
            end
        end
        DataConfig.DataMarryBattleExchange:Foreach(_Func)
    end
    return self.ShopsDic
end

function LoversFightSystem:GetShopsPriceList()
    local _shopsPrics = self.ShopPriceList
    if _shopsPrics == nil then
        _shopsPrics = Dictionary:New()
        local _shop = self:GetShopsDic()
        -- The first list is filled in the currency type. The content starts from the second one.
        _shopsPrics:Add(1 , Utils.SplitNumber(_shop[1].Pay,'_')[1])
        for i = 1, _shop:Count() do
            local _Num = Utils.SplitNumber(_shop[i].Pay,'_')[2]
            _shopsPrics:Add(i + 1 , {Num = _Num , Id = _shop[i].Id})
        end
    end
    return _shopsPrics 
end

function LoversFightSystem:CheckOcc(occ)
    if self.Occ == nil then
        self.Occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    end
    local canUse = false
    local strs = Utils.SplitStr(occ,'_')
    for i = 1, #strs do
        if tonumber(strs[i]) == 9 then
            return true
        end
        if tonumber(strs[i]) == tonumber(self.Occ) then
            canUse = true
            return canUse
        end
    end
    return canUse
end

function LoversFightSystem:GetRewardsByType(t)
    local _ret = nil
    local _dic = self:GetRewardsDic()
    if _dic ~= nil then
        _ret = _dic[t]
    end
    return _ret
end

function LoversFightSystem:GetFreeReward(count)
    local _ret = nil
    local _list = self:GetRewardsByType(4)
    for i = 1, #_list do
        local _data = _list[i]
        if _data ~= nil and tonumber(_data.Count) == count then
            _ret = _data
        end
    end
    return _ret
end

function LoversFightSystem:GetFreeApplyTime()
    local _ret = nil
    local _cfg = DataConfig.DataMarryBattleTime[1]
    if _cfg ~= nil then
        local _list1 = Utils.SplitNumber(_cfg.StartTime, "_")
        local _list2 = Utils.SplitNumber(_cfg.OverTime, "_")
        _ret = {Start = _list1[2], End = _list2[2]}
    end
    return _ret
end

function LoversFightSystem:IsOutFreeApplyTime()
    local _ret = true
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
    local _curSeconds = _hour * 3600 + _min * 60 + _sec
    local _applyTime = self:GetFreeApplyTime()
    if _applyTime ~= nil then
        if _curSeconds >= _applyTime.Start * 60 and _curSeconds <= _applyTime.End * 60 then
            _ret = false
        end
    end
    return _ret
end

-- Get audition event time
function LoversFightSystem:GetFreeJoinTime()
    local _ret = nil
    local _cfg = DataConfig.DataMarryBattleTime[100]
    if _cfg ~= nil then
        local _list1 = Utils.SplitNumber(_cfg.StartTime, "_")
        local _list2 = Utils.SplitNumber(_cfg.OverTime, "_")
        _ret = {Start = _list1[2], End = _list2[2]}
    end
    return _ret
end

function LoversFightSystem:GroupFightIsOpen()
    local _ret = nil
    local _cfg = DataConfig.DataMarryBattleTime[100]
    local _serverTime = math.floor(GameCenter.HeartSystem.ServerZoneTime)
    if _cfg ~= nil then
        local _list1 = Utils.SplitNumber(_cfg.StartTime, "_")
        local _list2 = Utils.SplitNumber(_cfg.OverTime, "_")
        local _hour, _min, _sec = L_TimeUtils.GetStampTimeHHMMSSNotZone(_serverTime)
        local _curSeconds = _hour * 3600 + _min * 60 + _sec
        if _curSeconds >= _list2[2] * 60 then
            _ret = true
        end 
    end
    return _ret
end

function LoversFightSystem:GetCopyMsg()
    local _ret = nil
    if self.CacheCopyMsgList ~= nil and #self.CacheCopyMsgList > 0 then
        _ret = self.CacheCopyMsgList[1]
        GameCenter.MapLogicSystem.ActiveLogic:IsCheckWatch(_ret)
        self.CacheCopyMsgList:RemoveAt(1)
    end
    return _ret
end

function LoversFightSystem:Update(dt)
    if self.IsInitTime then
        local _curStep = self:GetFightStep()
        local _freeData = self:GetFreeData()
        if _freeData ~= nil then
            if _freeData.IsTickTiShi then
                if _freeData:CheckMsgTpis(self.CurWeek, self.StartSec) then
                    self:CheckFreeRedPoint()
                    _freeData.IsTickTiShi = false
                end
            end
        end
        local _groupData = self:GetGroupData()
        if _groupData ~= nil then
            if _groupData.IsReceiveJinJi and _groupData.IsTickTiShi then
                if _groupData:CheckMsgTpis(self.CurWeek, self.StartSec) then
                    _groupData.IsTickTiShi = false
                end
            end
            if self.PreStep ~= _curStep then
                if self.PreStep == 2 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversGroupFight, false)
                elseif self.PreStep == 1 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversGroupFight, true)
                end
            end
        end
        local _topData = self:GetTopData()
        if _topData ~= nil then
            if _topData.L_IsTickTiShi then
                if _topData:CheckMsgTpisL(self.CurWeek, self.StartSec) then
                    _topData.L_IsTickTiShi = false
                end
            end
            if self.PreStep ~= _curStep then
                if self.PreStep == 3 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightL, false)
                elseif self.PreStep == 2 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightL, true)
                end
            end
        end
        if _topData ~= nil then
            if _topData.H_IsTickTiShi then
                if _topData:CheckMsgTpisH(self.CurWeek, self.StartSec) then
                    _topData.H_IsTickTiShi = false
                end
            end
            if self.PreStep ~= _curStep then
                if self.PreStep == 4 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightH, false)
                elseif self.PreStep == 3 then
                    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversTopFightH, true)
                end
            end
        end
        self.PreStep = _curStep
    end
end

function LoversFightSystem:GetFreeData()
    if self.FreeData == nil then
        self.FreeData = L_TeamInfo:New()
    end
    return self.FreeData
end

function LoversFightSystem:GetGroupData()
    if self.GroupData == nil then
        self.GroupData = L_GroupInfo:New()
    end
    return self.GroupData
end

function LoversFightSystem:GetTopData()
    if self.TopData == nil then
        self.TopData = L_TopInfo:New()
    end
    return self.TopData
end

function LoversFightSystem:GetFightStep()
    local _ret = 0
    local _freeData = self:GetFreeData()
    if _freeData ~= nil then
        --self.CurWeek, self.StartSec
        if _freeData:CanJoin(self.CurWeek, self.StartSec) then
            _ret = 1
        end
    end
    local _groupData = self:GetGroupData()
    if _groupData ~= nil then
        if _groupData:CanJoin(self.CurWeek, self.StartSec) then
            _ret = 2
        end
    end
    local _topData = self:GetTopData()
    if _topData ~= nil then
        if _topData:CanJoinL(self.CurWeek, self.StartSec) then
            _ret = 3
        end
        if _topData:IsOverL(self.CurWeek, self.StartSec) then
            _ret = 5
        end
        if _topData:CanJoinH(self.CurWeek, self.StartSec) then
            _ret = 4
        end
        if _topData:IsOverH(self.CurWeek, self.StartSec) then
            _ret = 6
        end
    end
    return _ret
end

function LoversFightSystem:CheckFreeRedPoint()
    local _have = false
    if self.FreeData ~= nil then
        -- Determine whether you can register
        _have = (not self.FreeData.IsJoin and not self:IsOutFreeApplyTime())
        if not _have then
            -- Determine whether it can match
            if self.FreeData.IsJoin then
                if self.FreeData:CanJoin(self.CurWeek, self.StartSec) then
                    _have = true
                end
            else
                _have = false
            end
        end
        if not _have then
            -- Determine whether there is a treasure chest to collect
            local _list = self:GetRewardsByType(4)
            for i = 1, #_list do
                local _data = _list[i]
                if self.FreeData.FightCount >= tonumber(_data.Count) then
                    if not _data.IsReward then
                        _have = true
                        break
                    end
                end
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LoversFreeFight, _have)
end

-------------------------------------------------------req_msg-------------------------------------------------------
----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------
-- Request auditions information
function LoversFightSystem:ReqTrialsInfo()
    GameCenter.Network.Send("MSG_Couplefight.ReqTrialsInfo")
    Debug.LogError("Request audition registration data!")
end

-- Sign up
function LoversFightSystem:ReqApply(n)
    GameCenter.Network.Send("MSG_Couplefight.ReqApply", {
        name = n
    })
    Debug.LogError("Request to register!")
end

-- Registration confirmation
function LoversFightSystem:ReqApplyConfirm(b)
    GameCenter.Network.Send("MSG_Couplefight.ReqApplyConfirm", {
        confirm = b
    })
    Debug.LogError("Request registration confirmation!")
end

-- Request to start matching
function LoversFightSystem:ReqMatchStart()
    GameCenter.Network.Send("MSG_Couplefight.ReqMatchStart")
    Debug.LogError("Request a match!")
end

-- Request to stop matching
function LoversFightSystem:ReqMatchStop()
    GameCenter.Network.Send("MSG_Couplefight.ReqMatchStop")
    Debug.LogError("Request to stop matching!")
end

-- Match confirmation
function LoversFightSystem:ReqMatchConfirm(b)
    GameCenter.Network.Send("MSG_Couplefight.ReqMatchConfirm", {confirm = b})
    Debug.LogError("Request confirm the match!")
end

-- Request auditions rankings
function LoversFightSystem:ReqTrialsRank()
    GameCenter.Network.Send("MSG_Couplefight.ReqTrialsRank")
    Debug.LogError("Examination ranking request!")
end

-- Request a reward
function LoversFightSystem:ReqGetAward(cfgId)
    GameCenter.Network.Send("MSG_Couplefight.ReqGetAward", {id = cfgId})
    Debug.LogError("Request to receive the auditions treasure chest! ==="..cfgId)
end
----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

-- Request group match main interface information
function LoversFightSystem:ReqGroupsInfo()
    GameCenter.Network.Send("MSG_Couplefight.ReqGroupsInfo")
    Debug.LogError("Request group stage data!")
end

-- Request group stage ranking information
function LoversFightSystem:ReqGroupsRank()
    GameCenter.Network.Send("MSG_Couplefight.ReqGroupsRank")
    Debug.LogError("Request group stage ranking data!")
end

-- Request to enter the preparatory map
function LoversFightSystem:ReqGroupPrepareMapEnter()
    GameCenter.Network.Send("MSG_Couplefight.ReqGroupPrepareMapEnter")
    Debug.LogError("Request to enter the preparatory map!")
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

-- Request the main interface data of the championship game
function LoversFightSystem:ReqChampionInfo(t)
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionInfo", {type = t})
    Debug.LogError("Request the main interface data of the championship game!")
end

-- Request for betting interface data
function LoversFightSystem:ReqChampionGuessInfo(t, id)
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionGuessInfo", {type = t, fightId = id})
    Debug.LogError("Request for betting interface data! id ="..id)
    Debug.LogError("Request for betting interface data! type ="..t)
end

-- Request to participate in the betting
function LoversFightSystem:ReqChampionGuess(t, id, tId)
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionGuess", {type = t, fightId = id, teamId = tId})
end

-- Request a bet support rate update
function LoversFightSystem:ReqChampionGuessUpdate(t, id)
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionGuessUpdate", {type = t, fightId = id})
end

-- Request support team list
function LoversFightSystem:ReqChampionTeamList(t)
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionTeamList", {type = t})
    Debug.LogError("Request support team list!")
end

-- Request fan ranking
function LoversFightSystem:ReqChampionFansRankList()
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionFansRankList")
    Debug.LogError("Request fan ranking")
end

-- Request to enter the championship game to prepare a copy
function LoversFightSystem:ReqChampionEnter()
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionEnter")
    Debug.LogError("Request to enter the championship game to prepare for the map!")
end

-- Request to watch the battle
function LoversFightSystem:ReqChampionGuessWatching()
    GameCenter.Network.Send("MSG_Couplefight.ReqChampionGuessWatching")
    Debug.LogError("Request to watch the battle!")
end

-------------------------------------------------------res_msg-------------------------------------------------------
-- Return to the player's promotion notification
function LoversFightSystem:ResPromotionInfo(msg)
    if msg == nil then
        return
    end
    if msg.type == 2 then
        -- Group match
        local _groupData = self:GetGroupData()
        if _groupData ~= nil then
            _groupData.IsReceiveJinJi = true
            _groupData:CheckMsgTpis(self.CurWeek, self.StartSec)
        end
        Debug.LogError("Received news of promotion in the group stage!")
    elseif msg.type == 3 then
        -- Place list
        --IsReceiveJinJi
        local _topData = self:GetTopData()
        if _topData ~= nil then
            _topData.L_IsReceiveJinJi = true
            _topData:CheckMsgTpisL(self.CurWeek, self.StartSec)
        end
        Debug.LogError("Received news of promotion to the championship field list!")
    elseif msg.type == 4 then
        -- Sky List
        local _topData = self:GetTopData()
        if _topData ~= nil then
            _topData.H_IsReceiveJinJi = true
            _topData:CheckMsgTpisH(self.CurWeek, self.StartSec)
            Debug.LogError("Received news of promotion to the championship list!")
        end
    end
    self:CheckFreeRedPoint()
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------
-- Return to player auditions information
function LoversFightSystem:ResTrialsInfo(msg)
    Debug.LogError("Return to audition registration data!")
    if msg == nil then
        return
    end
    if self.FreeData == nil then
        self.FreeData = L_TeamInfo:New()
    end
    self.FreeData:ParseMsg(msg)
    -- Set up the reward list
    if msg.trials ~= nil and msg.trials.getAwards ~= nil then
        for i = 1, #msg.trials.getAwards do
            local _id = msg.trials.getAwards[i]
            local _freeRewards = self:GetRewardsByType(4)
            if _freeRewards ~= nil then
                for m = 1, #_freeRewards do
                    if _freeRewards[m].Id == _id  then
                        _freeRewards[m].IsReward = true
                    end
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_FIGHT_INFO)
end

-- Return to register
function LoversFightSystem:ResApply(msg)
    if self.FreeData ~= nil then
        if msg.success == 0 then
            self.FreeData.IsJoin = true
            self.FreeData:ParseTeam(msg.team)
            self.FreeData:ParaseTrials(msg.trials)
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_FIGHT_JOIN_RESULT, msg.success)
        elseif msg.success == 1 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_1"))
        elseif msg.success == 2 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_2"))
        elseif msg.success == 3 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_3"))
        elseif msg.success == 4 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_OUT_APPLY_TIME"))
        elseif msg.success == 5 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_5"))
        elseif msg.success == 6 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_6"))
        elseif msg.success == 7 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_7"))
        elseif msg.success == 8 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_11"))
        end
    end
    self:CheckFreeRedPoint()
    Debug.LogError("Return to the registration results! :::"..msg.success)
end

-- Return to confirm registration
function LoversFightSystem:ResApplyConfirm(msg)
    if msg == nil then
        return
    end
    local _str = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_CONFIORM"), msg.name)
	GameCenter.MsgPromptSystem:ShowMsgBox(_str, DataConfig.DataMessageString.Get("C_MSGBOX_NO"), DataConfig.DataMessageString.Get("C_MSGBOX_YES"), function(x)
		if x == MsgBoxResultCode.Button2 then
			GameCenter.LoversFightSystem:ReqApplyConfirm(true)
		else
			GameCenter.LoversFightSystem:ReqApplyConfirm(false)
		end
	end)
    --GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_FIGHT_JOIN_CONFIRM, msg.name)
    Debug.LogError("Registration confirmation returns!")
end

-- Return to start matching
function LoversFightSystem:ResMatchStart(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_PIPEI_START, msg)
    if msg.success then
        Debug.LogError("Return to start matching successfully!")
        self.IsPiPeiWait = true
        self.FightStep = 1
        -- Pop up the waiting interface
        GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightPiPeiWaitForm_OPEN)
    else
        if msg.reason == 7 then
            GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_LOVERSFIGHT_APPLY_TISHI_12"))
        end
        Debug.LogError("Return to start matching failed!")
        self.FightStep = 0
    end
    self:CheckFreeRedPoint()
end

-- Return to stop matching
function LoversFightSystem:ResMatchStop(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_PIPEI_STOP)
    Debug.LogError("Return to stop matching!")
    self.IsPiPeiWait = false
    self.FightStep = 0
    self:CheckFreeRedPoint()
end

-- Match successfully
function LoversFightSystem:ResMatchSuccess(msg)
    self.IsPiPeiWait = false
    self.FightStep = 2
    GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightPiPeiWaitForm_CLOSE)
	GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightPiPeiForm_OPEN)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_PIPEI_SUCCESS)
    Debug.LogError("Return to match successfully!")
    self:CheckFreeRedPoint()
end

-- Match confirmation
function LoversFightSystem:ResMatchConfirmNotice(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_PIPEI_CONFIRM, msg)
    Debug.LogError("Return to match confirmation!")
end

-- Return to the auditions rankings
function LoversFightSystem:ResTrialsRank(msg)
    Debug.LogError("Audition rankings return!")
    if msg == nil then
        return
    end
    self.FreeSelfRank = msg.selfRank
    self.FreeRankList:Clear()
    if msg.ranks ~= nil then
        for i = 1, #msg.ranks do
            local _rankMsg = msg.ranks[i]
            local _rankInfo = L_RankInfo:New()
            _rankInfo:ParseMsg(_rankMsg)
            self.FreeRankList:Add(_rankInfo)
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LVOERSFIGHT_FREE_RANK)
end

function LoversFightSystem:ResGetAward(msg)
    if msg == nil then
        return
    end
    local _list = self:GetRewardsByType(4)
    for i = 1, #_list do
        local _data = _list[i]
        if _data ~= nil and _data.Id == msg.id then
            _data.IsReward = true
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_FREE_REWARD)
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

-- Return to group stage information
function LoversFightSystem:ResGroupInfo(msg)
    Debug.LogError("Return to group stage data!")
    if msg == nil then
        return
    end
    if self.GroupData == nil then
        self.GroupData = L_GroupInfo:New()
    end
    self.GroupData:ParseMsg(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_GROUP_FIGHT_INFO)
end

-- Return to group ranking information
function LoversFightSystem:ResGroupRank(msg)
    if msg == nil then
        return
    end
    self.GroupData:ParseCurRankMsg(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_GROUP_FIGHT_RANK)
    Debug.LogError("Return to group ranking data!")
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

function LoversFightSystem:ResChampionInfo(msg)
    if self.TopData == nil then
        self.TopData = L_TopInfo:New()
    end
    self.TopData:ParseMsg(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_TOP_FIGHT_INFO)
    Debug.LogError("Return to the championship interface data!")
end

-- Return to the betting interface data
function LoversFightSystem:ResChampionGuessInfo(msg)
    self.TopData:ParseGuessMsg(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_TOP_PICK_INFO, false)
    Debug.LogError("Return to the individual team betting data!")
end

-- Return to the list of support teams
function LoversFightSystem:ResChampionTeamList(msg)
    if msg == nil then
        return
    end
    self.TopData:ParseGuessListMsg(msg.guess, msg.type)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_TOP_ALLPICK_INFO, true)
    Debug.LogError("Return to the list of support teams!")
end

-- Champions League Fan Ranking
function LoversFightSystem:ResChampionFansRankList(msg)
    if msg == nil then
        return
    end
    self.FansList:Clear()
    if msg.fans ~= nil then
        for i = 1, #msg.fans do
            self.FansList:Add(msg.fans[i])
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERS_TOP_RANK_INFO)
    Debug.LogError("Return to the championship fan ranking!")
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

function LoversFightSystem:ResEnterFightMap(msg)
    if msg == nil then
        return
    end
    self.CacheCopyMsgList:Add(msg)
    Debug.LogError("After entering the Xian Couple Duel, synchronize the data messages!")
end

function LoversFightSystem:ResFightResult(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightResultForm_OPEN, msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LOVERSFIGHT_FREE_RESULT)
    Debug.LogError("Auditions battle settlement news returns!")
end

----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------
function LoversFightSystem:ReqOpenCoupleShop()
    GameCenter.Network.Send("MSG_Couplefight.ReqOpenCoupleShop", {})
end

function LoversFightSystem:ReqBuyCoupleItem(id)
    GameCenter.Network.Send("MSG_Couplefight.ReqBuyCoupleItem", {id = id})
end

function LoversFightSystem:ResOnlieInitCoupleShop(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANLV_SHOP_REFRESH, msg)
end

function LoversFightSystem:ResBuyCoupleItemResult(msg)
    if msg.result == 1 then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_XIANLV_SHOP_REFRESH, msg)
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_SHOP_TIPS_RECHANGESUCESS"))
    else
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("GoodsSoldOut"))
    end
end

function LoversFightSystem:CheckShopRed()
    local _shopPriceList = self:GetShopsPriceList()
    if _shopPriceList then
        -- _shopPriceList The first one is the item ID so it is convenient to start from the second one
        for i = 2, _shopPriceList:Count() do
            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LoversShop, _shopPriceList[i].Id , {RedPointItemCondition(_shopPriceList[1] , _shopPriceList[i].Num)})
        end
    end
end


----------------------------------------------------------------------------------------------
-- |##############################################################################################################################################################################################################################################################
----------------------------------------------------------------------------------------------

return LoversFightSystem
