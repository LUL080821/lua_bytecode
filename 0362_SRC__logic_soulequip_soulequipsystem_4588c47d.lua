------------------------------------------------
-- Author: 
-- Date: 2020-12-10
-- File: SoulEquipSystem.lua
-- Module: SoulEquipSystem
-- Description: Soul Armor
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_FightUtils = require ("Logic.Base.FightUtils.FightUtils")
local L_RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local L_RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition
local SoulEquipSystem = {
    -- Current tempering level
    CurStrengthLv = 0,
    -- Current Soul Armor ID
    CurID = 1,
    -- Current Awakening Level
    CurAwakeLv = 0,
    AwakeSkillList = List:New(),
    -- Level and experience of the God Seal Pavilion
    LotteryLv = 0,
    LotteryExp = 0,
    -- Inlay hole position information
    SlotDic = Dictionary:New(),
    -- Divine Seal Dictionary
    DressPeralDic = Dictionary:New(),
    -- Praying Spirit Consumption of Yuanbao Second Confirmation
    IsLotteryConfirm = true,
    -- List of materials required for Soul Seal Synthesis
    PeralSynNeedItemList = List:New(),
    -- The currently worn soul armor ID
    CurEquipID = 0,
}

function SoulEquipSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.RegFixEventHandle(LogicLuaEventDefine.EVENT_SOULEQUIPPERAL_BAGCHANGE, self.OnPearlBagChange, self)
end

function SoulEquipSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnItemChange, self)
    GameCenter.UnRegFixEventHandle(LogicLuaEventDefine.EVENT_SOULEQUIPPERAL_BAGCHANGE, self.OnPearlBagChange, self)
end

function SoulEquipSystem:Update()
    if self.PearlBagUpdate then
        self:SetInlyRed()
        self:SetPeralSynthRed()
        self.PearlBagUpdate = false
    end
    if self.IsCheckSynthPoint then
        self:SetPeralSynthRed()
        self.IsCheckSynthPoint = false
    end
end

-- Set the currently worn soul armor ID
function SoulEquipSystem:SetCurWearEquipID(id)
    if id then
        self.CurEquipID = id
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_BREAKLV_UPDATE)
    end
end

-- Obtain the power of wearing divine seal
function SoulEquipSystem:GetDressPeralPowerByPart(part)
    if self.DressPeralDic:ContainsKey(part) and self.DressPeralDic[part] then
        return self.DressPeralDic[part].Power
    end
    return 0
end

-- Get the Wearing Seal
function SoulEquipSystem:GetDressPeralByPart(part)
    if self.DressPeralDic:ContainsKey(part) and self.DressPeralDic[part] then
        return self.DressPeralDic[part]
    end
    return nil
end

-- Get the Soul Seal Enhancement Configuration Table ID
function SoulEquipSystem:GetPeralStrCfgID(slot, lv)
    return slot * 10000 + lv
end

-- Obtain the enhanced attributes of the divine seal
function SoulEquipSystem:GetPeralStrengAtt(part)
    local _dic = Dictionary:New()
    local function _forFunction(k, v)
        if v.HoleCfg then
            if v.HoleCfg.EquipType == part then
                if v.StrengLv > 0 then
                    local _cfg = DataConfig.DataSoulArmorSignetIntensify[self:GetPeralStrCfgID(k, v.StrengLv)]
                    if _cfg and _cfg.Value then
                        local _arr = Utils.SplitStrByTableS(_cfg.Value);
                        for i = 1, #_arr do
                            _dic:Add(_arr[i][1], _arr[i][2]);
                        end
                    end
                end
                return true
            end
        end
    end
    self.SlotDic:ForeachCanBreak(_forFunction)
    return _dic
end


-- Get the number of holes activated by the God Seal Set
function SoulEquipSystem:GetPeralSuitCount(partList, quality, star)
    local _num = 0
    if star == nil then
        star = 1
    end
    local function _forFunction(k, v)
        if partList:Contains(k) and v.IsOpen and v.PearlInfo and (v.PearlInfo.Quality > quality or (v.PearlInfo.Quality == quality and v.PearlInfo.StarNum >= star)) then
            _num = _num + 1
        end
    end
    if partList and quality then
        self.SlotDic:ForeachCanBreak(_forFunction)
    end
    return _num
end

-- Get the number of holes activated by the God Seal Set
function SoulEquipSystem:HavePearl()
    local _num = 0
    local function _forFunction(k, v)
        if v.IsOpen and v.PearlInfo then
            _num = _num + 1
            return true
        end
    end
    self.SlotDic:ForeachCanBreak(_forFunction)
    return _num > 0
end

function SoulEquipSystem:GetPeralSuitCfg(PearlInfo)
    local _cfg = nil
    if PearlInfo then
        DataConfig.DataSoulArmorSignetSuit:ForeachCanBreak(function(k, v)
            local _partList = Utils.SplitNumber(v.Part, '_')
            if _partList:Contains(PearlInfo.SlotId) and v.Quality == PearlInfo.Quality then
                _cfg = v
                return true
            end
        end)
    end
    return _cfg
end

-- Get all decomposed equipment
function SoulEquipSystem:GetAllPeralCanSplit()
    local _result = List:New()
    local _peralList = self:GetAllSoulPearl()
    for i = 1, #_peralList do
        local item = _peralList[i]
        if item then
            if self.DressPeralDic:ContainsKey(item.Part) and self.DressPeralDic[item.Part].Power >= item.Power then
                _result:Add(item)
            end
        end
    end
    return _result
end

-- Get the inlaid divine seal attributes (excluding enhancement and set attributes)
function SoulEquipSystem:GetAllPeralAttrDic()
    local _dic = Dictionary:New()
    local function _forFunction(k, v)
        if v.IsOpen and v.PearlInfo then
            local attDic = v.PearlInfo:GetBaseAttribute()
            attDic:Foreach(function(k, v)
                if _dic:ContainsKey(k) then
                    _dic[k] = _dic[k] + v
                else
                    _dic:Add(k, v)
                end
            end)
            attDic = v.PearlInfo:GetSpecialAttribute()
            attDic:Foreach(function(k, v)
                if _dic:ContainsKey(k) then
                    _dic[k] = _dic[k] + v
                else
                    _dic:Add(k, v)
                end
            end)
        end
    end
    self.SlotDic:ForeachCanBreak(_forFunction)
    return _dic
end

-- Get all activated set properties
function SoulEquipSystem:GetAllPeralSuitAttrDic()
    local _dic = Dictionary:New()
    DataConfig.DataSoulArmorSignetSuit:ForeachCanBreak(function(k, v)
        local _num = self:GetPeralSuitCount(Utils.SplitNumber(v.Part, '_'), v.Quality, v.Star)
        if v.ValueOf2 and v.ValueOf2 ~= "" and _num >= 2 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf2);
            for i = 1, #_arr do
                local _id = tonumber(_arr[i][1])
                local _value = tonumber(_arr[i][2])
                if _dic:ContainsKey(_id) then
                    _dic[_id] = _dic[_id] + _value
                else
                    _dic:Add(_id, _value)
                end
            end
		end
        if v.ValueOf3 and v.ValueOf3 ~= "" and _num >= 3 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf2);
            for i = 1, #_arr do
                local _id = tonumber(_arr[i][1])
                local _value = tonumber(_arr[i][2])
                if _dic:ContainsKey(_id) then
                    _dic[_id] = _dic[_id] + _value
                else
                    _dic:Add(_id, _value)
                end
            end
		end
        if v.ValueOf4 and v.ValueOf4 ~= "" and _num >= 4 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf2);
            for i = 1, #_arr do
                local _id = tonumber(_arr[i][1])
                local _value = tonumber(_arr[i][2])
                if _dic:ContainsKey(_id) then
                    _dic[_id] = _dic[_id] + _value
                else
                    _dic:Add(_id, _value)
                end
            end
		end
        if v.ValueOf6 and v.ValueOf6 ~= "" and _num >= 6 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf2);
            for i = 1, #_arr do
                local _id = tonumber(_arr[i][1])
                local _value = tonumber(_arr[i][2])
                if _dic:ContainsKey(_id) then
                    _dic[_id] = _dic[_id] + _value
                else
                    _dic:Add(_id, _value)
                end
            end
        end
    end)
    return _dic
end

-- Calculate the total combat power of the divine seal, including basic attributes, suits, and enhancements
function SoulEquipSystem:SetPearlFightPower()
    self.PearlFight = 0
    self.SlotDic:Foreach(function(k, v)
        if v.IsOpen and v.PearlInfo then
            self.PearlFight = self.PearlFight + v.PearlInfo.Power
            if v.StrengLv > 0 then
                local _cfg = DataConfig.DataSoulArmorSignetIntensify[self:GetPeralStrCfgID(k, v.StrengLv)]
                if _cfg and _cfg.Value then
                    local _arr = Utils.SplitStrByTableS(_cfg.Value);
                    local _power = L_FightUtils.GetPropetryPowerByList(_arr)
                    if _power then
                        self.PearlFight = self.PearlFight + _power
                    end
                end
            end
        end
    end)
    DataConfig.DataSoulArmorSignetSuit:ForeachCanBreak(function(k, v)
        local _num = self:GetPeralSuitCount(Utils.SplitNumber(v.Part, '_'), v.Quality, v.Star)
        if v.ValueOf2 and v.ValueOf2 ~= "" and _num >= 2 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf2);
            local _power = L_FightUtils.GetPropetryPowerByList(_arr)
            if _power then
                self.PearlFight = self.PearlFight + _power
            end
		end
        if v.ValueOf3 and v.ValueOf3 ~= "" and _num >= 3 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf3);
            local _power = L_FightUtils.GetPropetryPowerByList(_arr)
            if _power then
                self.PearlFight = self.PearlFight + _power
            end
		end
        if v.ValueOf4 and v.ValueOf4 ~= "" and _num >= 4 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf4);
            local _power = L_FightUtils.GetPropetryPowerByList(_arr)
            if _power then
                self.PearlFight = self.PearlFight + _power
            end
		end
        if v.ValueOf6 and v.ValueOf6 ~= "" and _num >= 6 then
            local _arr = Utils.SplitStrByTableS(v.ValueOf6);
            local _power = L_FightUtils.GetPropetryPowerByList(_arr)
            if _power then
                self.PearlFight = self.PearlFight + _power
            end
        end
        if _num < 2 then
            return true
        end
    end)
end

-- Automatically wear divine seal
function SoulEquipSystem:AutoWearPearl(info)
    if info and info.HoleCfg and info.IsOpen then
        local _pearlDic = self:GetHightSoulPearlDic()
        if _pearlDic:ContainsKey(info.HoleCfg.EquipType) then
            local _msg = ReqMsg.MSG_SoulArmor.ReqWearSoulArmorBall:New()
            _msg.slotId = info.SlotId
            _msg.ballId = _pearlDic[info.HoleCfg.EquipType].DBID
            _msg:Send()
        end
    end
end

-- Set up soul armor training red dots
function SoulEquipSystem:SetStrengthRed()
    -- Clear all conditions
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulEquipStrength);
    local _cfg = DataConfig.DataSoulArmorLevelUp[self.CurStrengthLv]
    local _next = DataConfig.DataSoulArmorLevelUp[self.CurStrengthLv + 1]
    if _cfg and _next and _cfg.Consume and _cfg.Consume ~= "" then
        local _ar = Utils.SplitStr(_cfg.Consume, ';')
        local _conditions = List:New();
        for i = 1, #_ar do
            local _sin = Utils.SplitNumber(_ar[i], '_')
            if _sin[1] and _sin[2] then
                _conditions:Add(L_RedPointItemCondition(_sin[1], _sin[2]));
            end
        end
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulEquipStrength, 0, _conditions);
    end
end

-- Set soul armor to break through the red dot
function SoulEquipSystem:SetBreachRed()
    -- Clear all conditions
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulEquipBreak);
    local _cfg = DataConfig.DataSoulArmorBreach[self.CurID]
    local _next = DataConfig.DataSoulArmorBreach[self.CurID + 1]
    if _cfg and _next and _cfg.Consume and _cfg.Consume ~= "" then
        local _ar = Utils.SplitStr(_cfg.Consume, ';')
        local _conditions = List:New();
        for i = 1, #_ar do
            local _sin = Utils.SplitNumber(_ar[i], '_')
            if _sin[1] and _sin[2] then
                _conditions:Add(L_RedPointItemCondition(_sin[1], _sin[2]));
            end
        end
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulEquipBreak, 0, _conditions);
    end
end

-- Set up the soul armor awakening red dot
function SoulEquipSystem:SetAweakenRed()
    -- Clear all conditions
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulEquipAweak);
    local _cfg = DataConfig.DataSoulArmorAwaken[self.CurAwakeLv]
    local _next = DataConfig.DataSoulArmorAwaken[self.CurAwakeLv + 1]
    if _cfg and _next and _cfg.Consume and _cfg.Consume ~= "" then
        local _ar = Utils.SplitStr(_cfg.Consume, ';')
        local _conditions = List:New();
        for i = 1, #_ar do
            local _sin = Utils.SplitNumber(_ar[i], '_')
            if _sin[1] and _sin[2] then
                _conditions:Add(L_RedPointItemCondition(_sin[1], _sin[2]));
            end
        end
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulEquipAweak, 0, _conditions);
    end
    -- Skill upgrade
    for i = 1, #self.AwakeSkillList do
        local _skCfg = DataConfig.DataSoulArmorAwakenSkill[self.AwakeSkillList[i]]
        if _skCfg and _skCfg.ConsumeSkill and _skCfg.ConsumeSkill ~= "" and _skCfg.NextSkill > 0 then
            local _ar = Utils.SplitStr(_skCfg.ConsumeSkill, ';')
            local _conditions = List:New();
            for ii = 1, #_ar do
                local _sin = Utils.SplitNumber(_ar[ii], '_')
                if _sin[1] and _sin[2] then
                    _conditions:Add(L_RedPointItemCondition(_sin[1], _sin[2]));
                end
            end
            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulEquipAweak, self.AwakeSkillList[i], _conditions);
        end
    end
end

-- Divine seal wears red dots
function SoulEquipSystem:SetInlyRed()
    local _pearlDic = nil
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulPearlWear)
    local function _forFunction(k, v)
        local _red = false
        if v.HoleCfg and v.IsOpen then
            if _pearlDic == nil then
                _pearlDic = self:GetHightSoulPearlDic()
            end
            if _pearlDic:ContainsKey(v.HoleCfg.EquipType) then
                local _power = 0
                if v.PearlInfo then
                    _power = v.PearlInfo.Power
                end
                if _pearlDic[v.HoleCfg.EquipType].Power > _power then
                    _red = true
                end
            end
        end
        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.SoulPearlWear, k, L_RedPointCustomCondition(_red))
    end
    self.SlotDic:Foreach(_forFunction)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_INLAY_UPDATE)
end

-- Divine Seal Strengthens Red Dot
function SoulEquipSystem:SetPeralStrengthRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulPearlStrength)
    local function _forFunction(k, v)
        if v.HoleCfg and v.IsOpen and v.PearlInfo then
            local id = self:GetPeralStrCfgID(k, v.StrengLv)
            local _cfg = DataConfig.DataSoulArmorSignetIntensify[id]
            local _next = DataConfig.DataSoulArmorSignetIntensify[id + 1]
            if _cfg and _next and _cfg.Consume and _cfg.Consume ~= "" then
                local _ar = Utils.SplitStr(_cfg.Consume, ';')
                local _conditions = List:New();
                for i = 1, #_ar do
                    local _sin = Utils.SplitNumber(_ar[i], '_')
                    if _sin[1] and _sin[2] then
                        _conditions:Add(L_RedPointItemCondition(_sin[1], _sin[2]));
                    end
                end
                GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulPearlStrength, k, _conditions);
            end
        end
    end
    self.SlotDic:Foreach(_forFunction)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_INLAY_UPDATE)
end

-- Divine Seal Lottery Red Dot
function SoulEquipSystem:SetLotteryRed()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulEquipLottery)
    local function _forFunction(k, v)
        if v and v.ConsumeItem then
            local _conditions = List:New();
            _conditions:Add(L_RedPointItemCondition(v.ConsumeItem, 1));
            GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.SoulEquipLottery, k, _conditions);
        end
    end
    DataConfig.DataSoulArmorSignetLotteryObject:Foreach(_forFunction)
end

-- Divine seal wear
function SoulEquipSystem:ReqWearSoulArmorBall(PearlInfo)
    local function _forFunction(k, v)
        if v.HoleCfg then
            if v.HoleCfg.EquipType == PearlInfo.Part then
                if not v.IsOpen then
                    GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_UI_SOULEQUIP_HOLECLOSE"))
                else
                    local _msg = ReqMsg.MSG_SoulArmor.ReqWearSoulArmorBall:New()
                    _msg.slotId = k
                    _msg.ballId = PearlInfo.DBID
                    _msg:Send()
                end
            end
        end
    end
    self.SlotDic:Foreach(_forFunction)
end

-- Set Soul Seal Synthesis Red Dots
function SoulEquipSystem:SetPeralSynthRed(allEquipList)
    local function _forFunction(k, v)
        if v.PearlInfo and v.IsOpen then
            local _cfg = DataConfig.DataSoulArmorEquipSynthesis[v.PearlInfo.CfgID]
            if _cfg then
                if not allEquipList then
                    allEquipList = self:GetAllSoulPearl()
                end
                local itemflag = true
                if _cfg.JoinItem and _cfg.JoinItem ~= "" then
                    local itemArr = Utils.SplitNumber(_cfg.JoinItem, '_')
                    if #itemArr >= 2 then
                        local itemID = itemArr[1]
                        local needNum = itemArr[2]
                        local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemID)
                        if haveNum < needNum then
                            itemflag = false;
                            if _cfg.ItemPrice and _cfg.ItemPrice ~= "" then
                                local coinArr = Utils.SplitNumber(_cfg.ItemPrice, '_');
                                if (#coinArr >= 2) then
                                    local coinID = coinArr[1]
                                    local price = coinArr[2]
                                    local haveCoinNum = GameCenter.ItemContianerSystem:GetEconomyWithType(coinID);
                                    if haveCoinNum >= price * (needNum - haveNum) then
                                        itemflag = true;
                                    end
                                    if not self.PeralSynNeedItemList:Contains(coinID) then
                                        self.PeralSynNeedItemList:Add(coinID)
                                    end
                                end
                            end
                        end
                        if not self.PeralSynNeedItemList:Contains(itemID) then
                            self.PeralSynNeedItemList:Add(itemID)
                        end
                    end
                end
                if itemflag then
                    local _quaList = Utils.SplitNumber(_cfg.Quality, '_')
                    local _starList = Utils.SplitNumber(_cfg.Diamond, '_')
                    local _partList = List:New()
                    local _equipList = List:New()
                    if _cfg.JoinPart and _cfg.JoinPart ~= "" then
                        _partList = Utils.SplitNumber(_cfg.JoinPart, '_')
                    end
                    if allEquipList then
                        for i = 1, #allEquipList do
                            if ((#_partList > 0 and _partList:Contains(allEquipList[i].Part)) or #_partList == 0) and allEquipList[i].Quality == 6 and allEquipList[i].StarNum == 1 and _starList:Contains(allEquipList[i].StarNum) and _quaList:Contains(allEquipList[i].Quality) then
                                _equipList:Add(allEquipList[i])
                            end
                        end
                    end
                    local _per = 0
                    for i = 1, #_equipList do
                        local _starIndex = 0
                        local _quaIndex = 0
                        for j = 1, #_starList do
                            if _starList[j] == _equipList[i].StarNum then
                                local _starPerList = Utils.SplitNumber(_cfg.DiamondNumber, '_')
                                if _starPerList[j] then
                                    _starIndex = _starPerList[j]
                                    break
                                end
                            end
                        end
                        for j = 1, #_quaList do
                            if _quaList[j] == _equipList[i].Quality then
                                local _quaPerList = Utils.SplitNumber(_cfg.QualityNumber, '_')
                                if _quaPerList[j] then
                                    _quaIndex = _quaPerList[j]
                                    break
                                end
                            end
                        end
                        _per = _per + _cfg.JoinNumProbability * _quaIndex * _starIndex / 100000000
                        if _per >= 10000 then
                            break
                        end
                    end
                    if _per >= 10000 then
                        GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.SoulPearlSynth, k, L_RedPointCustomCondition(true))
                    end
                end
            end
        end
    end
    self.PeralSynNeedItemList:Clear()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.SoulPearlSynth)
    self.SlotDic:Foreach(_forFunction)
end

-- Obtain the divine seal with the highest combat power in each part
function SoulEquipSystem:GetHightSoulPearlDic()
    local _cacheDic = Dictionary:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PEREAL);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            local equip = v
            if (_cacheDic:ContainsKey(equip.Part) and _cacheDic[equip.Part].Power < equip.Power) then
                _cacheDic[equip.Part] = equip;
            elseif not _cacheDic:ContainsKey(equip.Part) then
                _cacheDic:Add(equip.Part, equip);
            end
        end)
    end
    return _cacheDic;
end

-- Find all soul seals
function SoulEquipSystem:GetAllSoulPearl()
    local equipList = GameCenter.NewItemContianerSystem:GetItemListNOGC(LuaContainerType.ITEM_LOCATION_PEREAL)
    equipList:Sort(function(a, b)
        if (a.Power ~= b.Power) then
            return a.Power > b.Power
        else
            if (a.Quality ~= b.Quality) then
                return a.Quality > b.Quality
            else
                if (a.Part ~= b.Part) then
                    return a.Part < b.Part
                else
                    return a.CfgID < b.CfgID
                end
            end
        end
    end);
    return equipList;
end

-- Find the soul seal that can be synthesized
function SoulEquipSystem:GetSoulPearlCanSyn(quaList, starList, partList)
    local list = List:New()
    local bpModel = GameCenter.NewItemContianerSystem:GetBackpackModelByType(LuaContainerType.ITEM_LOCATION_PEREAL);
    if bpModel then
        bpModel.ItemsOfIndex:Foreach(function(k, v)
            if (v and quaList:Contains(v.Quality) and starList:Contains(v.StarNum)) then
                if (partList and #partList > 0) then
                    if (partList:Contains(v.Part)) then
                        list:Add(v);
                    end
                else
                    list:Add(v);
                end
            end
        end)
    end
    list:Sort(function(x, y)
        return x.Power > y.Power
    end);
    return list;
end

-- Soul Armor Level Information, Inlay Information, etc.
function SoulEquipSystem:ResSoulArmor(msg)
    self.CurStrengthLv = msg.level
    self.CurID = msg.qualityLevel
    self.CurAwakeLv = msg.skillLevel
    self.SlotDic:Clear()
    self.AwakeSkillList:Clear()
    if msg.slots then
        for i = 1, #msg.slots do
            local _tmp = {}
            _tmp.SlotId = msg.slots[i].slot
            if msg.slots[i].level then
                _tmp.StrengLv = msg.slots[i].level
            else
                _tmp.StrengLv = 0
            end
            _tmp.IsOpen = msg.slots[i].isOpen
            _tmp.HoleCfg = DataConfig.DataSoulArmorSignetHole[_tmp.SlotId]
            if msg.slots[i].ball then
                _tmp.PearlInfo = LuaItemBase.CreateItemBaseByMsg(msg.slots[i].ball)
                if _tmp.PearlInfo then
                    _tmp.PearlInfo.SlotId = _tmp.SlotId
                    if _tmp.HoleCfg then
                        if self.DressPeralDic:ContainsKey(_tmp.HoleCfg.EquipType) then
                            self.DressPeralDic[_tmp.HoleCfg.EquipType] = _tmp.PearlInfo
                        else
                            self.DressPeralDic:Add(_tmp.HoleCfg.EquipType, _tmp.PearlInfo)
                        end
                    end
                end
            end
            self.SlotDic:Add(_tmp.SlotId, _tmp)
        end
    end
    if msg.skillList then
        for i = 1, #msg.skillList do
            self.AwakeSkillList:Add(msg.skillList[i])
        end
    end
    self:SetPeralStrengthRed()
    self:SetStrengthRed()
    self:SetBreachRed()
    self:SetAweakenRed()
    self:SetLotteryRed()
    self:SetPearlFightPower()
    self.PearlBagUpdate = true
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_STRENGTHLV_UPDATE)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_BREAKLV_UPDATE)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_AWEAKLV_UPDATE)
end

-- Hole position information update
function SoulEquipSystem:ResUpdateSoulArmorBallSlot(msg)
    if msg.slot then
        local _tmp = {}
        _tmp.SlotId = msg.slot.slot
        _tmp.StrengLv = msg.slot.level
        _tmp.IsOpen = msg.slot.isOpen
        _tmp.HoleCfg = DataConfig.DataSoulArmorSignetHole[_tmp.SlotId]
        if msg.slot.ball then
            _tmp.PearlInfo = LuaItemBase.CreateItemBaseByMsg(msg.slot.ball)
            if _tmp.PearlInfo then
                _tmp.PearlInfo.SlotId = _tmp.SlotId
            end
        end
        if _tmp.HoleCfg then
            if self.DressPeralDic:ContainsKey(_tmp.HoleCfg.EquipType) then
                self.DressPeralDic[_tmp.HoleCfg.EquipType] = _tmp.PearlInfo
            else
                self.DressPeralDic:Add(_tmp.HoleCfg.EquipType, _tmp.PearlInfo)
            end
        end
        if self.SlotDic:ContainsKey(_tmp.SlotId) then
            self.SlotDic[_tmp.SlotId] = _tmp
        else
            self.SlotDic:Add(_tmp.SlotId, _tmp)
        end
    end
    self.PearlBagUpdate = true
    self:SetPeralStrengthRed()
    self:SetPearlFightPower()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_HOLEUPDATE, msg.slot.slot)
end

-- Update the tempering level
function SoulEquipSystem:ResUpdateSoulArmorLevel(msg)
    self.CurStrengthLv = msg.level
    self:SetStrengthRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_STRENGTHLV_UPDATE, true)
end

-- Update the breakthrough level
function SoulEquipSystem:ResSoulArmorQualityLevel(msg)
    self.CurID = msg.qualityLevel
    self:SetBreachRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_BREAKLV_UPDATE, true)
    -- local _cfg = DataConfig.DataSoulArmorBreach[self.CurID]
    -- if _cfg then
    --     local _ar = Utils.SplitNumber(_cfg.MainTransfom, '_')
    --     GameCenter.ModelViewSystem:ShowModel(ShowModelType.SoulEquip, _cfg.Model, _ar[1], _ar[6]/_ar[1], _cfg.Name)
    -- end
end

-- Update Awakening Level
function SoulEquipSystem:ResUpSoulArmorSkillLevel(msg)
    if msg.skillId and not self.AwakeSkillList:Contains(msg.skillId) then
        self.AwakeSkillList:Add(msg.skillId)
    end
    self.CurAwakeLv = msg.skillLevel
    self:SetAweakenRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_AWEAKLV_UPDATE, true)
end

-- Updated level experience of Shenyin Pavilion
function SoulEquipSystem:ResSoulArmorLottery(msg)
    if msg.exp > self.LotteryExp then
        Utils.ShowPromptByEnum("C_SOULEQUIP_LOTTERY_ADDEXP", msg.exp - self.LotteryExp)
    end
    self.LotteryLv = msg.level
    self.LotteryExp = msg.exp
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_LOTTERYLV_UPDATE)
end

-- Awakening skill upgrade return
function SoulEquipSystem:ResChangeSoulArmorSkill(msg)
    if self.AwakeSkillList:Contains(msg.oldId) then
        self.AwakeSkillList:Remove(msg.oldId)
    end
    self.AwakeSkillList:Add(msg.skillId)
    self.AwakeSkillList:Sort(function(a, b)
        return a < b
    end)
    self:SetAweakenRed()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULEQUIP_AWAKESKILL_LVUP, msg.skillId)
end

-- Backpack changes monitoring
function SoulEquipSystem:OnPearlBagChange(obj, sender)
    self.PearlBagUpdate = true
end

-- Item Changes
function SoulEquipSystem:OnItemChange(object, sender)
    if #self.PeralSynNeedItemList > 0 and self.PeralSynNeedItemList:Contains(object) then
        -- Determine whether red dots are displayed
        self.IsCheckSynthPoint = true
    end
end

-- Soul Seal Synthesis Results
function SoulEquipSystem:ResSoulArmorMerge(msg)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SOULPERARL_SYNTHRESULT, msg.result)
end
return SoulEquipSystem
