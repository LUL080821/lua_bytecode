------------------------------------------------
-- Author:
-- Date: 2021-02-24
-- File: MonsterSoulSystem.lua
-- Module: MonsterSoulSystem
-- Description: Divine beast system, including Divine beast backpack, Divine beast equipment processing, combat assistance data
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local L_MonsterData = require("Logic.MonsterSoul.MonsterSoulMonsterData")
local MonsterSoulSystem = {
    -- Equipment in the backpack
    EquipInBagList = List:New(),
    -- Reinforcement materials
    MaterialList = List:New(),
    -- List of the beasts
    MonsterDataList = List:New(),
    -- Equipment for the corresponding wear of the divine beast
    MonsterRelativeEquipDict = Dictionary:New(),
    -- Red dots in the list of divine beasts
    HeadPanelRedPointDict = Dictionary:New(),
    -- Whether to detect red dots
    IsCheckRedPoint = false,
    -- Red dots on the backpack button
    HasBagRedPoint = false,
    -- Maximum number of assist positions
    MaxSlotCount = 0,
    -- Default number of assist positions
    DefaultSlotCount = 0,
    -- Conditions for opening the assist position
    SlotConditionList = nil,
}

-- initialization
function MonsterSoulSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnPlayerLvChange, self)
end

-- uninstall
function MonsterSoulSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnPlayerLvChange, self)
end

-- Item Changes
function MonsterSoulSystem:OnItemChange(object, sender)
    if self.CurAddSlotNeedItem and object == self.CurAddSlotNeedItem then
        self.IsCheckRedPoint = true
    end
end

function MonsterSoulSystem:OnPlayerLvChange(obj, sendr)
	self.IsCheckRedPoint = true
end

function MonsterSoulSystem:GetMaxSlotCount()
    if self.MaxSlotCount == 0 then
        self.MaxSlotCount = self:GetDefaultSlotCount()
    end
    return self.MaxSlotCount
end

function MonsterSoulSystem:GetDefaultSlotCount()
    if self.DefaultSlotCount == 0 then
        local cfg = DataConfig.DataGlobal[GlobalName.BossOld2_PossessionNum]
        if cfg then
            self.DefaultSlotCount = tonumber(cfg.Params)
        end
    end
    return self.DefaultSlotCount
end

function MonsterSoulSystem:GetSlotConditionList()
    if self.SlotConditionList == nil then
        self.SlotConditionList = List:New()
        local cfg = DataConfig.DataGlobal[GlobalName.BossOld2_PossessionOtherItem]
        if cfg then
            local strArray = Utils.SplitStr(cfg.Params, ';')
            for i = 1, #strArray do
                local conditionArray = Utils.SplitNumber(strArray[i], '_')
                local condition = {};
                condition.Level = conditionArray[1]
                condition.ItemID = conditionArray[2]
                condition.ItemCount = conditionArray[3]
                self.SlotConditionList:Add(condition)
            end
        end
    end
    return self.SlotConditionList
end

function MonsterSoulSystem:Update(dt)
    if self.IsCheckRedPoint then
        self:CheckRedPoint();
        self.IsCheckRedPoint = false;
    end
end

-- Number of beast souls in the battle
function MonsterSoulSystem:GetFightingSoulCount()
    local fightingCount = 0;
    for i = 1, #self.MonsterDataList do
        if self.MonsterDataList[i].Fighting then
            fightingCount = fightingCount + 1;
        end
    end
    return fightingCount;
end

function MonsterSoulSystem:CheckRedPoint()
    local hasRedPoint = self:CheckRedPointCanEquip();
    if not hasRedPoint then
        hasRedPoint = self:HasSoulCanAssistFight();
    end
    if not hasRedPoint then
        hasRedPoint = self:HasAddSlotRed();
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MonsterEquipSynth, self:HasSynthRedPoint());
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MonsterAF, hasRedPoint);
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.MonsterEquipStrength, self:HasStrengthRedPoint());

    -- Notify all interfaces to handle red dots
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_CHECK_REDPOINT);
end

-- Is there any increase in the red spots for assisting the poor
function MonsterSoulSystem:HasAddSlotRed()
    local _hasAddSlotCount = self:GetMaxSlotCount() - self:GetDefaultSlotCount()
    local _list = self:GetSlotConditionList()
    local _count = #_list
    local _nextCondition = nil
    if _hasAddSlotCount < _count then
        _nextCondition = _list[_hasAddSlotCount + 1]
    else
        return false
    end
    local _red = false
    local _level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _existItemCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_nextCondition.ItemID)
    if _existItemCount >= _nextCondition.ItemCount and _level >= _nextCondition.Level then
        _red = true
    end
    self.CurAddSlotNeedItem = _nextCondition.ItemID
    return _red
end

-- The corresponding red dot of the beast soul (equipped and replaced)
function MonsterSoulSystem:CheckRedPointCanEquip()
    self.HeadPanelRedPointDict:Clear();
    self.HasBagRedPoint = false;

    local fightingNum = self:GetFightingSoulCount();
    local counter = 0;

    -- Replaceable equipment, it must be a beast soul in full wear to compare
    for i = #self.MonsterDataList, 1, -1 do
        if counter < self:GetMaxSlotCount() and self:HasFullEquip(self.MonsterDataList[i]) then
            local hasBetterEquip = self:HasBetterEquip(self.MonsterDataList[i]);
            if not self.HeadPanelRedPointDict:ContainsKey(self.MonsterDataList[i].CfgId) then
                if hasBetterEquip then
                    self.HeadPanelRedPointDict:Add(self.MonsterDataList[i].CfgId, hasBetterEquip);
                    counter = counter + 1
                    self.HasBagRedPoint = true;
                end
            end
        end
    end

    if fightingNum < self:GetMaxSlotCount() then
        -- Can play
        for i = #self.MonsterDataList, 1, -1 do
            if counter < self:GetMaxSlotCount() then
                local canAssist = self:CanAssistFight(self.MonsterDataList[i])
                if not self.HeadPanelRedPointDict:ContainsKey(self.MonsterDataList[i].CfgId) then
                    if canAssist then
                        self.HeadPanelRedPointDict:Add(self.MonsterDataList[i].CfgId, canAssist);
                        counter = counter + 1;
                    end
                end
            end
        end

        -- Wearable equipment
        for i = #self.MonsterDataList, 1, -1 do
            if counter < self:GetMaxSlotCount() and not self:HasFullEquip(self.MonsterDataList[i]) then
                if self:CanFullEquip(self.MonsterDataList[i]) then
                    if not self.HeadPanelRedPointDict:ContainsKey(self.MonsterDataList[i].CfgId) then
                        self.HeadPanelRedPointDict:Add(self.MonsterDataList[i].CfgId, true);
                        counter = counter + 1;
                    end
                end
            end
        end
    end

    return counter > 0;
end

-- Is there any magical beast to help fight
function MonsterSoulSystem:HasSoulCanAssistFight()
    for i = 1, #self.MonsterDataList do
        if self:CanAssistFight(self.MonsterDataList[i]) then
            return true;
        end
    end
    return false;
end

function MonsterSoulSystem:CanFullEquip(data)
    if self:HasFullEquip(data) then
        return false;
    end

    local canEquipArray = data:GetEquipedLoation()
    for i = 1, #self.EquipInBagList do
        local location = self.EquipInBagList[i].Part;
        local hasLocated = data:IsLocated(self.EquipInBagList[i].Part)
        if (hasLocated) then
            canEquipArray[location] = true;
        else
            local equipLimit = data.PartQualityLimit[location];
            local starLimit = data.PartStarLimit[location];
            if self.EquipInBagList[i].Quality >= equipLimit and self.EquipInBagList[i].StarNum >= starLimit then
                canEquipArray[location] = true;
            end
        end
    end
    if #canEquipArray < MonsterSoulEquipType.Count then
        return false
    end
    for i = 1, #canEquipArray do
        if not canEquipArray[i] then
            return false
        end
    end
    return true;
end

-- Can this beast help fight
function MonsterSoulSystem:CanAssistFight(data)
    local fightingCount = self:GetFightingSoulCount();
    if (fightingCount >= self:GetMaxSlotCount()) then
        return false;
    end
    return data.Fighting == false and self:HasFullEquip(data)
end

-- Change the equipment of the divine beast to wear
function MonsterSoulSystem:HasFullEquip(data)
    local list = data:GetEquipList()
    return list and #list == MonsterSoulEquipType.Count;
end

-- Better equipment in the backpack
function MonsterSoulSystem:HasBetterEquip(data)
    -- First of all, you have to wear it well to judge that you have better equipment and go out to fight
    if not self:HasFullEquip(data) and not data.Fighting then
        return false;
    end
    for i = 1, #self.EquipInBagList do
        local compare = self:CompareFightPower(self.EquipInBagList[i], data);
        if (compare > 0) then
            return true;
        end
    end
    return false;
end

-- Is there any reinforced red dots
function MonsterSoulSystem:HasStrengthRedPoint()
    if self:GetFightingSoulCount() < self:GetMaxSlotCount() then
        return false;
    end
    local _red = false
    for i = 1, #self.EquipInBagList do
        if self.EquipInBagList[i].Quality <= 6 then
            _red = true
            break
        end
    end
    return _red or #self.MaterialList > 0
end

-- Is there any synthetic red dots
function MonsterSoulSystem:HasSynthRedPoint()
    local dic = Dictionary:New()
    for i = 1, #self.EquipInBagList do
        local equip = self.EquipInBagList[i];
        if equip.Config.IfBan == 0 then
            local key = equip.Quality * 10 + equip.StarNum;
            if (dic:ContainsKey(key)) then
                dic[key]:Add(equip);
            else
                local list = List:New()
                list:Add(equip);
                dic:Add(key, list);
            end
            if (#dic[key] >= 3) then
                return true;
            end
        end
    end
    return false;
end

-- Item filtering for backpack interface
function MonsterSoulSystem:GetItemsBySort(quality, starNum)
    local sorted = List:New()
    for i = 1, #self.EquipInBagList do
        if ((quality == -1 or self.EquipInBagList[i].Quality == quality) and (starNum == -1 or self.EquipInBagList[i].StarNum == starNum)) then
            sorted:Add(self.EquipInBagList[i]);
        end
    end

    for i = 1, #self.MaterialList do
        if quality == -1 or self.MaterialList[i].Quality == quality then
            sorted:Add(self.MaterialList[i]);
        end
    end
    return sorted;
end

-- Get equipment for a part of the equipment
function MonsterSoulSystem:FindEquipByPart(soul, part)
    if soul then
        local equiplist = soul:GetEquipList()
        if equiplist then
            for i = 1, #equiplist do
                if (equiplist[i].Part == part) then
                    return equiplist[i];
                end
            end
        end
    end
    return nil;
end

-- Enhanced interface item filtering
function MonsterSoulSystem:GetStrenthItemBySort(quality)
    local sortedList = List:New()
    for i = 1, #self.MaterialList do
        if self.MaterialList[i].Quality <= quality or quality == -1 then
            sortedList:Add(self.MaterialList[i]);
        end
    end
    sortedList:Sort(function(a, b)
        return a.Quality< b.Quality
    end);

    local sortedEquipList = List:New()
    for  i = 1, #self.EquipInBagList do
        if self.EquipInBagList[i].Config.Quality <= quality or quality == -1 then
            sortedEquipList:Add(self.EquipInBagList[i]);
        end
    end
    sortedEquipList:Sort(function(a, b)
        if a.Quality == b.Quality then
            if a.StarNum == b.StarNum then
                if a.Part == b.Part then
                    return a.Score > b.Score
                else
                    return a.Part < b.Part
                end
            else
                return a.StarNum > b.StarNum
            end
        else
            return a.Quality > b.Quality
        end
    end);

    sortedList:AddRange(sortedEquipList);
    return sortedList;
end

-- Obtain all equipment for all the battle beast souls
function MonsterSoulSystem:GetEquipListFromFightingMonster()
    local retList = List:New()
    for i = 1, #self.MonsterDataList do
        if self.MonsterDataList[i].Fighting then
            if self.MonsterDataList[i]:GetEquipList() then
                retList:AddRange(self.MonsterDataList[i]:GetEquipList());
            end
        end
    end
    retList:Sort(function(a, b)
        if a.MonsterId == b.MonsterId then
            return a.Part < b.Part
        else
            return a.MonsterId > b.MonsterId
        end
    end);
    return retList;
end

-- Wear equipment
function MonsterSoulSystem:WearEquip(soulId, data)
    if self.MonsterRelativeEquipDict:ContainsKey(soulId) then
        self.MonsterRelativeEquipDict[soulId]:Add(data);
    else
        local list = List:New()
        list:Add(data);
        self.MonsterRelativeEquipDict:Add(soulId, list);
    end

    return self:GetMonsterSoul(soulId);
end

-- Take off the equipment
function MonsterSoulSystem:UndressEquip(soulId, data)
    if self.MonsterRelativeEquipDict:ContainsKey(soulId) then
        local list = self.MonsterRelativeEquipDict[soulId];
        for i = 1, #list do
            if (list[i].DBID == data.DBID) then
                list.RemoveAt(i);
                break;
            end
        end
    end

    return self:GetMonsterSoul(soulId);
end

function MonsterSoulSystem:GetMonsterSoul(soulId)
    for i = 1, #self.MonsterDataList do
        if (self.MonsterDataList[i].CfgId == soulId) then
            return self.MonsterDataList[i];
        end
    end
    return nil;
end

function MonsterSoulSystem:GetSoulEquipData(configId)
    for i = 1, #self.EquipInBagList do
        if self.EquipInBagList[i].DBID == configId then
            return self.EquipInBagList[i];
        end
    end

    for i = 1, #self.MaterialList do
        if self.MaterialList[i].DBID == configId then
            return self.MaterialList[i];
        end
    end
    return nil;
end

function MonsterSoulSystem:CompareFightPower(equip, soul)
    -- Set signs for increasing combat power and decreasing
    local showPowerTag = 0;
    if soul then
        -- Only when the equipment conditions are met can the comparison be compared. The first is the quality limit and star limit
        if (soul.PartQualityLimit[equip.Part] <= equip.Quality and soul.PartStarLimit[equip.Part] <= equip.StarNum) then
            -- The default is to improve combat power
            showPowerTag = 1;
            local equiplist = soul:GetEquipList()
            if equiplist then
                for i = 1,  #equiplist do
                    if (equiplist[i].Part == equip.Part) then
                        if equiplist[i].Quality > equip.Quality then
                            showPowerTag = -1
                        elseif equiplist[i].Quality == equip.Quality then
                            if equiplist[i].StarNum > equip.StarNum then
                                showPowerTag = -1
                            elseif equiplist[i].StarNum == equip.StarNum then
                                local equipedFightScore = equiplist[i].Score;
                                local inbagFightScore = equip.Score;
                                -- The equipment inside the backpack is worse
                                if (equipedFightScore > inbagFightScore) then
                                    showPowerTag = -1;
                                elseif (equipedFightScore == inbagFightScore) then
                                    showPowerTag = 0;
                                end
                            end
                        end
                        break;
                    end
                end
            end
        end
    end
    return showPowerTag;
end

-- New items need to be sorted and inserted
function MonsterSoulSystem:AddNewEquip(data)
    self.EquipInBagList:Add(data);
    self.EquipInBagList:Sort(function(a, b)
        if a.Quality == b.Quality then
            if a.StarNum == b.StarNum then
                if a.Part == b.Part then
                    return a.Score > b.Score
                else
                    return a.Part < b.Part
                end
            else
                return a.StarNum > b.StarNum
            end
        else
            return a.Quality > b.Quality
        end
    end)
end

function MonsterSoulSystem:CreateEquipDataWithSoulid(msg, soulID)
    if not soulID then
        soulID = 0
    end
    local data = LuaItemBase.CreateItemBase(msg.itemModelId);
    data.CfgID = msg.itemModelId;
    data.DBID = msg.itemId;
    data.Level = msg.level;
    data.Exp = msg.curExp;
    data.MonsterId = soulID;

    return data;
end

function MonsterSoulSystem:CreateEquipData(msg)
    local data = LuaItemBase.CreateItemBase(msg.itemModelId);
    data.CfgID = msg.itemModelId;
    data.DBID = msg.itemId;
    data.Level = 0;
    data.Exp = 0;
    data.MonsterId = 0;
    data.IsMaterial = true;
    data.Count = msg.num;
    if (data.ItemInfo) then
        local arr = Utils.SplitNumber(data.ItemInfo.EffectNum, '_')
        if (#arr >= 2) then
            data.Exp = arr[2]
        end
    end
    return data;
end
function MonsterSoulSystem:CreateEquipDataWithCfgid(cfgID)
    local data = LuaItemBase.CreateItemBase(cfgID);
    data.CfgID = cfgID;
    data.DBID = 0;
    data.Level = 0;
    data.Exp = 0;
    data.MonsterId = 0;
    data.IsMaterial = true;
    if (data.ItemInfo) then
        local arr = Utils.SplitNumber(data.ItemInfo.EffectNum, '_')
        if (#arr >= 2) then
            data.Exp = arr[2]
        end
    end
    return data;
end

function MonsterSoulSystem:CreateMonsterSoulData(msg)
    local data = L_MonsterData:New(msg.soulId)
    data.Fighting = msg.fight;
    data.DBID = msg.soulId;
    if (msg.equips) then
        for i = 1, #msg.equips do
            local equip = self:CreateEquipDataWithSoulid(msg.equips[i], msg.soulId);
            -- Others are associated with the corresponding beast soul
            if self.MonsterRelativeEquipDict:ContainsKey(equip.MonsterId) then
                self.MonsterRelativeEquipDict[equip.MonsterId]:Add(equip);
            else
                local dataList = List:New()
                dataList:Add(equip);
                self.MonsterRelativeEquipDict:Add(equip.MonsterId, dataList);
            end
        end
    end
    return data;
end

function MonsterSoulSystem:GetMonsterDataFromId(monsterSoulId)
    for i = 1, #self.MonsterDataList do
        if self.MonsterDataList[i].CfgId == monsterSoulId then
            return self.MonsterDataList[i]
        end
    end
    return nil;
end

-- Find equipment that can be used for synthesis, find it from your backpack
function MonsterSoulSystem:GetListCanSyn(quality, starNum, oldList)
    local sorted = List:New()
    for i = 1, #self.EquipInBagList do
        if ((self.EquipInBagList[i].Quality == quality) and (self.EquipInBagList[i].StarNum == starNum) and not oldList:Contains(self.EquipInBagList[i].DBID)) then
            sorted:Add(self.EquipInBagList[i]);
        end
    end
    return sorted;
end

function MonsterSoulSystem:GetQuaStr(quality)
    if quality == 1 then
        return DataConfig.DataMessageString.Get("C_QUALITY_1")
    elseif quality == 2 then
        return DataConfig.DataMessageString.Get("C_QUALITY_2")
    elseif quality == 3 then
        return DataConfig.DataMessageString.Get("C_QUALITY_3")
    elseif quality == 4 then
        return DataConfig.DataMessageString.Get("C_QUALITY_4")
    elseif quality == 5 then
        return DataConfig.DataMessageString.Get("C_QUALITY_5")
    elseif quality == 6 then
        return DataConfig.DataMessageString.Get("C_QUALITY_6")
    elseif quality == 7 then
        return DataConfig.DataMessageString.Get("C_QUALITY_7")
    elseif quality == 8 then
        return DataConfig.DataMessageString.Get("C_QUALITY_8")
    elseif quality == 9 then
        return DataConfig.DataMessageString.Get("C_COLOR_DARKGOLD")
    elseif quality == 10 then
        return DataConfig.DataMessageString.Get("C_COLOR_HUANCAI")
    end
end

-- Wearing equipment
function MonsterSoulSystem:ReqWearEquip(data, monster)
    if not monster then
        return
    end
    if (monster.PartStarLimit[data.Part] > data.StarNum) then
        Utils.ShowPromptByEnum("C_MONSTEREQUIP_EQUIPPART", monster.PartStarLimit[data.Part])
        return
    end
    if (monster.PartQualityLimit[data.Part] > data.Quality) then
        Utils.ShowPromptByEnum("Need_More_High_Soul_Beast_Equip", self.GetQuaStr(monster.PartQualityLimit[data.Part]))
        return
    end
    local lsit = List:New()
    lsit:Add(data.DBID)
    local req = ReqMsg.MSG_SoulBeast.ReqSoulBeastEquipWear:New();
    req.equipIds = lsit
    req.soulBeastId = monster.CfgId;
    req:Send();
end

-- Wear with one click
function MonsterSoulSystem:AutoWearEquip(data)
    local req = ReqMsg.MSG_SoulBeast.ReqSoulBeastEquipWear:New();
    req.soulBeastId = data.CfgId;
    local _betterEquip = List:New()
    for  i = 1, #self.EquipInBagList do
        local compare = self:CompareFightPower(self.EquipInBagList[i], data);
        if (compare > 0) then
            _betterEquip:Add(self.EquipInBagList[i]);
        end
    end
    for i = MonsterSoulEquipType.Head, MonsterSoulEquipType.Count do
        local power = 0;
        local index = -1;
        for j = 1, #_betterEquip do
            if (_betterEquip[j].Score > power and _betterEquip[j].Part == i) then
                power = _betterEquip[j].Score;
                index = j;
            end
        end
        if (index >= 0) then
            req.equipIds:Add(_betterEquip[index].DBID);
        end
    end
    if (#req.equipIds > 0) then
        req:Send();
    end
    return #_betterEquip > 0;
end

-- Uninstall the equipment
function MonsterSoulSystem:ReqUndressEquip(data, monster)
    local req = ReqMsg.MSG_SoulBeast.ReqSoulBeastEquipDown:New();
    if data then
        req.soulBeastId = data.MonsterId;
        req.equipIds:Add(data.DBID);
    end
    if monster then
        req.soulBeastId = monster.CfgId;
        for i = 1, #monster:GetEquipList() do
            req.equipIds:Add(monster:GetEquipList()[i].DBID);
        end
    end
    req:Send();
end

-- strengthen
function MonsterSoulSystem:ReqMonsterEquipLevelUp(targetDBID, costEquips, isDouble)
    local req = ReqMsg.MSG_SoulBeast.ReqSoulBeastEquipUp:New();
    req.fixEquipId = targetDBID;
    req.needDouble = isDouble;
    req:Send();
end

-- Request to go to war, recall
function MonsterSoulSystem:ReqFight(soulId)
    local req = ReqMsg.MSG_SoulBeast.ReqSoulBeastFight:New();
    req.soulId = soulId;
    req:Send();
end

-- Request to expand the assist position
function MonsterSoulSystem:ReqNewSlot()
    local req = ReqMsg.MSG_SoulBeast.ReqAddGrid:New();
    req.Send();
end

-- Return to the backpack soul beast equipment list and send it online
function MonsterSoulSystem:GS2U_ResSoulBeastEquipList(result)
    self.EquipInBagList:Clear();
    self.MaterialList:Clear();

    self.MaxSlotCount = self:GetDefaultSlotCount();
    if result.equips then
        for i = 1, #result.equips do
            local data = self:CreateEquipDataWithSoulid(result.equips[i], 0)
            if data then
                self.EquipInBagList:Add(data);
            end
        end
    end

    self.EquipInBagList:Sort(function(a, b)
        if a.Quality == b.Quality then
            if a.StarNum == b.StarNum then
                if a.Part == b.Part then
                    return a.Score > b.Score
                else
                    return a.Part < b.Part
                end
            else
                return a.StarNum > b.StarNum
            end
        else
            return a.Quality > b.Quality
        end
    end);

    if result.items then
        for i = 1, #result.items do
            local data = self:CreateEquipData(result.items[i]);
            self.MaterialList:Add(data);
        end
    end

    self.MaterialList:Sort(function(a, b)
        return a.Quality > b.Quality
    end);
    self.IsCheckRedPoint = true;
end

-- Return to the basic information of the soul beast and send it online
function MonsterSoulSystem:GS2U_ResSoulBeastBaseInfo(result)
    self.MonsterRelativeEquipDict:Clear();
    self.MonsterDataList:Clear();
    if result.beasts then
        for i = 1, #result.beasts do
            local data = self:CreateMonsterSoulData(result.beasts[i]);
            self.MonsterDataList:Add(data);
        end
    end
    self.IsCheckRedPoint = true;
end

-- Soul Beast Information Change Notice
function MonsterSoulSystem:GS2U_ResSoulBeastChange( result)
    for i = 1, #self.MonsterDataList do
        if (self.MonsterDataList[i].CfgId == result.beast.soulId) then
            self.MonsterDataList[i].Fighting = result.beast.fight;
            if (self.MonsterRelativeEquipDict:ContainsKey(result.beast.soulId)) then
                self.MonsterRelativeEquipDict[result.beast.soulId]:Clear();
            end
            if result.beast.equips then
                for j = 1, #result.beast.equips do
                    local equip = self:CreateEquipDataWithSoulid(result.beast.equips[j], result.beast.soulId);
                    -- Others are associated with the corresponding beast soul
                    if (self.MonsterRelativeEquipDict:ContainsKey(equip.MonsterId)) then
                        self.MonsterRelativeEquipDict[equip.MonsterId]:Add(equip);
                    else
                        local dataList = List:New()
                        dataList:Add(equip);
                        self.MonsterRelativeEquipDict:Add(equip.MonsterId, dataList);
                    end
                end
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_SELECT_SOUL, self.MonsterDataList[i]);
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_FIGHTING_STATUS_CHANGE);
    self.IsCheckRedPoint = true;
end

-- Response to requesting the upgrade of the soul beast equipment
function MonsterSoulSystem:GS2U_ResSoulBeastEquipUp(result)
    if (self.MonsterRelativeEquipDict:ContainsKey(result.soulId)) then
        local equipList = self.MonsterRelativeEquipDict[result.soulId];
        if (equipList) then
            for i = 1, #equipList do
                if (equipList[i].DBID == result.equip.itemId) then
                    equipList[i].Level = result.equip.level;
                    equipList[i].Exp = result.equip.curExp;
                end
            end
        end
        -- Notification upgrade completed
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_STRENGTHEN_FINISH);
        self.IsCheckRedPoint = true;
    end
end

-- Beast soul equipment increased
function MonsterSoulSystem:GS2U_ResSoulBeastEquipAdd(result)
    if result.equips then
        for i = 1, #result.equips do
            local data = self:CreateEquipDataWithSoulid(result.equips[i], 0)
            -- If there is no corresponding beast soul, it is a backpack
            if (data.MonsterId == 0) then
                self:AddNewEquip(data);
                GameCenter.GetNewItemSystem:AddShowItem(result.reason, data, data.CfgID, 1)
            else
                -- Others are associated with the corresponding beast soul
                if (self.MonsterRelativeEquipDict:ContainsKey(data.MonsterId)) then
                    self.MonsterRelativeEquipDict[data.MonsterId]:Add(data);
                else
                    local dataList = List:New()
                    dataList:Add(data);
                    self.MonsterRelativeEquipDict:Add(data.MonsterId, dataList);
                end
                -- Display items in the lower right corner to get the scroll bar
                GameCenter.PushFixEvent(UIEventDefine.UIMSGTIPS_SHOWINFO, L_ItemBase.CreateItemBase(data.CfgID));
            end
        end
    end

    -- Notify the equipment to increase
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_EQUIP_ADD);
    self.IsCheckRedPoint = true;
end

-- Add reinforcement materials
function MonsterSoulSystem:GS2U_ResSoulBeastItemAdd(result)
    if result.items then
        for i = 1, #result.items do
            local data = self:CreateEquipData(result.items[i]);
            GameCenter.GetNewItemSystem:AddShowItem(result.reason, data, data.CfgID, data.Count)
            self.MaterialList:Add(data);
        end
    end
    -- Notify the equipment to increase
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_MATERIAL_ADD);
    self.IsCheckRedPoint = true;
end

function MonsterSoulSystem:GS2U_ResSoulBeastGridNum(result)
    self.MaxSlotCount = result.num;
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_ADD_SLOT);
    self.IsCheckRedPoint = true;
end

function MonsterSoulSystem:GS2U_ResDeleteSoulBeast(result)
    -- After the equipment is upgraded, you need to delete some things in the backpack
    if result.deleteEquipIds then
        for i = 1, #result.deleteEquipIds do
            -- Removed from backpack
            for j = 1, #self.EquipInBagList do
                if (self.EquipInBagList[j].DBID == result.deleteEquipIds[i]) then
                    self.EquipInBagList:RemoveAt(j)
                    break;
                end
            end

            -- Remove from the material list
            for j = 1, #self.MaterialList do
                if (self.MaterialList[j].DBID == result.deleteEquipIds[i]) then
                    self.MaterialList:RemoveAt(j);
                    break;
                end
            end
        end
    end

    -- Notify the equipment to increase
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONSTERSOUL_EQUIP_ADD);
    self.IsCheckRedPoint = true;
end

function MonsterSoulSystem:ResSoulBeastItemUpdate(result)
    if result.items then
        for i = 1, #result.items do
            -- Find from the list of materials
            for j = 1, #self.MaterialList do
                if (self.MaterialList[j].DBID == result.items[i].itemId) then
                    local addCount = result.items[i].num - self.MaterialList[j].Count;
                    self.MaterialList[j].Count = result.items[i].num;
                    GameCenter.GetNewItemSystem:AddShowItem(result.reason, self.MaterialList[j], self.MaterialList[j].CfgID, addCount)
                    break;
                end
            end
        end
    end
end

-- Part equipment name
function MonsterSoulSystem:EquipTypeToStr(type)
    if type == MonsterSoulEquipType.Head then
        return DataConfig.DataMessageString.Get("C_EQUIP_NAME_HELMET")
    elseif type == MonsterSoulEquipType.Necklet then
        return DataConfig.DataMessageString.Get("C_MONSTERSOUL_XIANGQUAN")
    elseif type == MonsterSoulEquipType.Cloth then
        return DataConfig.DataMessageString.Get("C_MONSTERSOUL_KAIJIA")
    elseif type == MonsterSoulEquipType.Weapon then
        return DataConfig.DataMessageString.Get("C_MONSTERSOUL_LIZHUA")
    elseif type == MonsterSoulEquipType.Wing then
        return DataConfig.DataMessageString.Get("C_MONSTERSOUL_YUYI")
    end
    return "";
end

function MonsterSoulSystem:CheckBetterThanDress(equip, monster)
    local ret = false;
    if(equip and monster and monster.PartStarLimit[equip.Part] <= equip.StarNum and monster.PartQualityLimit[equip.Part] <= equip.Quality) then
        local dressEquip = monster:GetEquipByPart(equip.Part);
        if dressEquip then
            if equip.Quality > dressEquip.Quality then
                ret = true
            else
                if equip.StarNum > dressEquip.StarNum then
                    ret = true
                else
                    ret = dressEquip.Score < equip.Score;
                end
            end
        else
            ret = true;
        end
    end

    return ret;
end
return MonsterSoulSystem