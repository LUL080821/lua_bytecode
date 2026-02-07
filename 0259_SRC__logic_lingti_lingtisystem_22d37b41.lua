
------------------------------------------------
-- Author:
-- Date: 2019-10-29
-- File: LingTiSystem.lua
-- Module: LingTiSystem
-- Description: Spiritual Body System Script
------------------------------------------------
-- Quote
local LingTiData = require "Logic.LingTi.LingTiData"
local L_LingtiUnlockData = require("Logic.LingTi.LingTiUnlockData")
local L_FightUtils = require ("Logic.Base.FightUtils.FightUtils")
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;
local RedPointLevelCondition = CS.Thousandto.Code.Logic.RedPointLevelCondition;
local RedPointEquipCondition = CS.Thousandto.Code.Logic.RedPointEquipCondition;
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local LingTiSystem = {
    -- key = occupation value = data
    DicData = Dictionary:New(),

    -- Is it unblocked?
    IsActiveLingti = false,
    CurActiveLv = 0,
    CurActiveStarNum = 0,
    MaxStarNum = 520,
    AllEquipStarNum = 0,
    UnLockDataDic = Dictionary:New(),

    -- Total attributes
    AllAtter = nil,
    IsSynthComfirm = true,
    TotalFightPower = 0,
}

-- initialization
function LingTiSystem:Initialize()
    DataConfig.DataEquipCollection:Foreach(function(k, v)
        local list = nil
        local data = LingTiData:New(v)
        if self.DicData:ContainsKey(v.Gender) then
            list = self.DicData[v.Gender]
            list:Add(data)
        else
            list = List:New()
            list:Add(data)
            self.DicData:Add(v.Gender,list)
        end
    end)
    local _gCfg = DataConfig.DataGlobal[GlobalName.Base_LingLi_Def_Min]
    if _gCfg ~= nil then
        self.BaseDefMin = tonumber(_gCfg.Params)
    end
    self:InitUnlockLvData()
    self.IsSynthComfirm = true
end

function LingTiSystem:UnInitialize()
end

-- Initialize the spirit unblock configuration data
function LingTiSystem:InitUnlockLvData()
    self.UnLockDataDic:Clear()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp then
        local _sex = _lp.IntOcc
        DataConfig.DataEquipCollectionStart:Foreach(function(k, v)
            local list = nil
            local data = L_LingtiUnlockData:New(v, _sex)
            if self.UnLockDataDic:ContainsKey(v.Grade) then
                list = self.UnLockDataDic[v.Grade]
                list:Add(data)
            else
                list = List:New()
                list:Add(data)
                self.UnLockDataDic:Add(v.Grade,list)
            end
        end)
    end
end

-- Update unblocking status
function LingTiSystem:UpdateUnlockState()
    self.IsActiveLingti = true
    if self.UnLockDataDic:Count() <= 0 then
        self:InitUnlockLvData()
    end
    if not self.UnlockAttrDic then
        self.UnlockAttrDic = Dictionary:New()
    else
        self.UnlockAttrDic:Clear()
    end
    self.UnLockDataDic:Foreach(function(k, v)
        for i = 1, #v do
            if v[i].Cfg.Id <= self.CurActiveLv then
                v[i].IsActive = true
            else
                self.IsActiveLingti = false
            end
            if v[i].IsActive then
                local _keys = v[i].DicAttrData:GetKeys()
                for ii = 1, #_keys do
                    local value = v[i].DicAttrData[_keys[ii]]
                    if self.UnlockAttrDic:ContainsKey(_keys[ii]) then
                        self.UnlockAttrDic[_keys[ii]] = self.UnlockAttrDic[_keys[ii]] + value
                    else
                        self.UnlockAttrDic:Add(_keys[ii], value)
                    end
                end
            end
        end
    end)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.LingtiFanTai);
    if not self.IsActiveLingti then
        self.UnLockDataDic:ForeachCanBreak(function(k, v)
            for i = 1, #v do
                if not v[i].IsActive then
                    local _conditions = List:New();
                    _conditions:Add(RedPointLevelCondition(v[i].Cfg.Level))
                    if v[i].Cfg.Needitem then
                        local _arr = Utils.SplitNumber(v[i].Cfg.Needitem, '_')
                        if #_arr >= 2 then
                            _conditions:Add(RedPointItemCondition(_arr[1], _arr[2]))
                        end
                    end
                    GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LingtiFanTai, k, _conditions);
                    return true
                end
            end
        end)
    end
end

-- Get the unblocked state of spirit body
function LingTiSystem:GetUnlockStateByGrade(grade)
    local _list = self.UnLockDataDic[grade]
    if _list then
        if self.CurActiveLv >= _list[1].Cfg.Id and self.CurActiveLv < _list[#_list].Cfg.Id then
            return LingtiUnlockState.WaitForFinish
        elseif self.CurActiveLv >= _list[#_list].Cfg.Id then
            return LingtiUnlockState.Finish
        else
            local _lpLv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
            if _lpLv >= _list[1].Cfg.Level then
                if self:GetUnlockStateByGrade(grade - 1) ~= LingtiUnlockState.Finish then
                    return LingtiUnlockState.LastLock
                else
                    return LingtiUnlockState.WaitForFinish
                end
            else
                return LingtiUnlockState.UnMet
            end
        end
    end
    return LingtiUnlockState.Finish
end

function LingTiSystem:GetUnlockListByGrade(grade)
    return self.UnLockDataDic[grade]
end

-- Set the total star rating and total combat power of spiritual equipment
function LingTiSystem:SetAllStar()
    self.AllEquipStarNum = 0
    local listData = self:GetLocalData()
    if listData == nil then
        return
    end
    for m = 1, #listData do
        for i = 1, #listData[m].ListEquipCel do
            self.AllEquipStarNum = self.AllEquipStarNum + listData[m].ListEquipCel[i].StarNum
        end
    end
    local _cfg = DataConfig.DataEquipCollectionStar[self.CurActiveStarNum + 1]
    if _cfg then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LingTiStar, self.AllEquipStarNum >= _cfg.StarNum)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LingTiStar, false)
    end
end

-- Obtain local player spirit data
function LingTiSystem:GetLocalData()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if lp ~= nil then
        local occ = lp.IntOcc
        if self.DicData:ContainsKey(occ) then
            return self.DicData[occ]
        end
    end
end

function LingTiSystem:SetEquipSynRedCnd()
    -- Determine whether the current state is reached
    local list = self:GetLocalData()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.LingTiSynth);
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if list then
        for m = 1, #list do
            local data = list[m]
            if lp.Level >= data.Cfg.Describe then
                -- First determine if there is replacement equipment
                for i = 1,#data.ListEquipCel do
                    -- Equipment synthetic red dots
                    self:AddEquipSynCondition(data.ListEquipCel[i].EquipId)
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_EQUIPSYNTH_RED_UPDATE)
end

function LingTiSystem:AddEquipSynCondition(dressEquip)
    local _equip = DataConfig.DataEquip[dressEquip]
    local cfg = DataConfig.DataEquipSynthesis[dressEquip]
    if cfg then
        local _conditions = List:New();
        if cfg.JoinItem and cfg.JoinItem ~= "" then
            local itemArr = Utils.SplitNumber(cfg.JoinItem, '_')
            if #itemArr >= 2 then
                local itemID = itemArr[1]
                local needNum = itemArr[2]
                local coinID = 0
                local price = 0
                if cfg.ItemPrice and cfg.ItemPrice ~= "" then
                    local coinArr = Utils.SplitNumber(cfg.ItemPrice, '_');
                    if (#coinArr >= 2) then
                        coinID = coinArr[1]
                        price = coinArr[2]
                    end
                end
                _conditions:Add(RedPointItemCondition(itemID, needNum, coinID, price))
            end
        end
        if cfg.JoinNumProbability and cfg.JoinNumProbability ~= "" then
            local partList = nil
            if cfg.JoinPart and cfg.JoinPart ~= "" then
                local parAr = Utils.SplitStr(cfg.JoinPart, '_')
                for i = 1, #parAr do
                    if parAr[i] then
                        if partList == nil then
                            partList = parAr[i]
                        else
                            partList = partList .. ";" .. parAr[i]
                        end
                    end
                end
            end
            local basePer = 0;
            local perAr = Utils.SplitNumber(cfg.JoinNumProbability, '_')
            if(#perAr > 0) then
                basePer = perAr[1]
            end
            local _count = math.ceil(10000 / basePer)
            _conditions:Add(RedPointEquipCondition(0, _count, 1, 6, 5, _equip.Grade, 5, cfg.Professional, 5, 1, 5, partList))
        else
            if cfg.JoinEquipID1 and cfg.JoinNum1 and cfg.JoinEquipID1 ~= "" and cfg.JoinNum1 ~= "" then
                local numArr = Utils.SplitNumber(cfg.JoinNum1, '_')
                if #numArr >= 2 then
                    local needEquipNum = numArr[2]
                    local equipIdArr = Utils.SplitNumber(cfg.JoinEquipID1, '_')
                    for jj = 1, #equipIdArr do
                        _conditions:Add(RedPointItemCondition(equipIdArr[jj], needEquipNum))
                    end
                end
            end
            if cfg.JoinEquipID2 and cfg.JoinNum2 and cfg.JoinEquipID2 ~= "" and cfg.JoinNum2 ~= "" then
                local numArr = Utils.SplitNumber(cfg.JoinNum2, '_')
                if #numArr >= 2 then
                    local needEquipNum = numArr[2]
                    local equipIdArr = Utils.SplitNumber(cfg.JoinEquipID2, '_')
                    for jj = 1, #equipIdArr do
                        _conditions:Add(RedPointItemCondition(equipIdArr[jj], needEquipNum))
                    end
                end
            end
        end
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LingTiSynth, _equip.Grade * 100 + _equip.Part, _conditions);
    end
end

function LingTiSystem:SetLingtiRedPointCondition()
    local list = self:GetLocalData()
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _equips = {}
    for m = 1, 8 do
        local equipList = List:New(GameCenter.EquipmentSystem:GetSelfEquipByPart(m - 1))
        _equips[m] = equipList
    end
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.LingTiMain)
    if list then
        for m = 1, #list do
            local data = list[m]
            -- First determine if there is replacement equipment
            for i = 1,#data.ListEquipCel do
                local equipList = _equips[i]
                if equipList ~= nil then
                    local occ = 0
                    if lp ~= nil then
                        occ = lp.IntOcc
                    end
                    local score = 0
                    local equipCfg = DataConfig.DataEquip[data.ListEquipCel[i].EquipId]
                    if equipCfg ~= nil then
                        score = equipCfg.Score
                    end
                    local _drg = data.Cfg.Grade
                    -- condition
                    local _conditions = List:New();
                    _conditions:Add(RedPointLevelCondition(data.Cfg.Describe))
                    _conditions:Add(RedPointEquipCondition(score, 1, 1, 6, 3, _drg, 5, occ, 5, 0, 3, tostring(i-1)))
                    GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.LingTiMain, _drg * 100 + i, _conditions);
                end
            end
        end
    end
end

function LingTiSystem:Update(dt)

end

-- Calculate the total attributes of spirit equipment
function LingTiSystem:CalculateAllAtter()
    self.AllAtter = Dictionary:New()
    local listData = self:GetLocalData()
    if listData == nil then
        return
    end

    for i = 1,#listData do
        local data = listData[i]
        if data.ListEquipCel ~= nil then
            for index = 1, #data.ListEquipCel do
                if data.ListEquipCel[index].EquipId ~= 0 then
                    local equipCfg = DataConfig.DataEquip[data.ListEquipCel[index].EquipId]
                    if equipCfg ~= nil then
                        local list = Utils.SplitStr(equipCfg.Attribute1, ';')
                        if list ~= nil then
                            for j = 1,#list do
                                local array = Utils.SplitNumber(list[j],'_')
                                if self.AllAtter:ContainsKey(array[1]) then
                                    self.AllAtter[array[1]] = self.AllAtter[array[1]] + array[2]
                                else
                                    self.AllAtter:Add(array[1], array[2])
                                end
                            end
                        end
                        if equipCfg.Attribute2 then
                            list = Utils.SplitStr(equipCfg.Attribute2, ';')
                            if list ~= nil then
                                for j = 1,#list do
                                    local array = Utils.SplitNumber(list[j],'_')
                                    if self.AllAtter:ContainsKey(array[1]) then
                                        self.AllAtter[array[1]] = self.AllAtter[array[1]] + array[2]
                                    else
                                        self.AllAtter:Add(array[1], array[2])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end
--------------------------msg----------------------------

-- Request equipment collection
function LingTiSystem:ReqCollectEquip(lId,eId,inherit)
    GameCenter.Network.Send("MSG_Spirit.ReqCollectEquip", {id = lId,equipId = eId, Inherit = inherit})
end

-- Request to activate the spirit
function LingTiSystem:ReqActiveSpirit(lId)
    GameCenter.Network.Send("MSG_Spirit.ReqActiveSpirit", {id = lId})
end

-- Yunyang request message
function LingTiSystem:ReqUpLevel(cId)
    GameCenter.Network.Send("MSG_Spirit.ReqUpLevel", {cfgId = cId})
end

-- Request to light up the spiritual star message
function LingTiSystem:ReqUpStar(starNum)
    if self.AllEquipStarNum >= starNum and GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LingTiStar) then
        GameCenter.Network.Send("MSG_Spirit.ReqUpStar", {starNum = starNum})
    else
        Utils.ShowPromptByEnum("C_TIPS_LINGTI_ERR1")
    end
end

-- Received spiritual data online
function LingTiSystem:ResSpiritInfo(result)
    if result == nil then
        return
    end
    local listData = self:GetLocalData()
    if listData == nil then
        return
    end
    if result.list ~= nil then
        for i = 1, #result.list do
            for m = 1, #listData do
                if listData[m].Cfg.Grade == result.list[i].id then
                    -- Analyze data
                    listData[m]:Parase(result.list[i])
                end
            end
        end
    end
    self.CurActiveLv = result.cfgId
    self.CurActiveStarNum = result.starNum
    -- Calculate the total star rating of spirit equipment
    self:SetAllStar()
    -- Calculate total properties
    -- self:CalculateAllAtter()
    self:UpdateUnlockState()
    self:SetLingtiRedPointCondition()
    self:SetEquipSynRedCnd()
end

-- Collect equipment and return
function LingTiSystem:ResCollectEquip(result)
    if result == nil then
        return
    end
    local listData = self:GetLocalData()
    if listData == nil then
        return
    end
    for i = 1,#listData do
        if listData[i].Cfg.Grade == result.id then
            listData[i]:SetCel(result.equipId)
            break
        end
    end
    self:SetAllStar()
    self:SetLingtiRedPointCondition()
    self:SetEquipSynRedCnd()
    -- Calculate total properties
    -- self:CalculateAllAtter()
    -- Notification interface update
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTIFORM_REFREASH)
end

-- Activate the spirit body to return
function LingTiSystem:ResActiveSpirit(result)
    if result == nil then
        return
    end
    local listData = self:GetLocalData()
    if listData == nil then
        return
    end
    for i = 1,#listData do
        if listData[i].Cfg.Grade == result.id then
            listData[i].IsActive = true
            break
        end
    end
    -- Notification interface update
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTIFORM_REFREASH)
end

-- Revitalize, unblock, activate return message
function LingTiSystem:ResUpLevel(result)
    self.CurActiveLv = result.cfgId
    self:UpdateUnlockState()
    -- Notification interface update
    if self.IsActiveLingti then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTI_LOCKUPDATE)
    else
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTIFORM_REFREASH)
    -- Get tips
    GameCenter.BlockingUpPromptSystem:AddNewFunction(2, self.CurActiveLv);
end

-- Light up the spiritual star and return the message
function LingTiSystem:ResUpStar(result)
    self.CurActiveStarNum = result.starNum
    local _cfg = DataConfig.DataEquipCollectionStar[self.CurActiveStarNum + 1]
    if _cfg then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LingTiStar, self.AllEquipStarNum >= _cfg.StarNum)
    else
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LingTiStar, false)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTI_STAR_UPDATE)
end

-- Combat power synchronization
function LingTiSystem:ResSyncFightPower(result)
    if result.fightPower then
        self.TotalFightPower = result.fightPower
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LINGTI_FIGHTPOWER_UPDATE)
end

return LingTiSystem
