------------------------------------------------
-- Author: 
-- Date: 2019-08-28
-- File: RealmStifleSystem.lua
-- Module: RealmStifleSystem
-- Description: Spiritual Pressure System
------------------------------------------------
local RedPointCustomCondition = CS.Thousandto.Code.Logic.RedPointCustomCondition;
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;

local RealmStifleSystem = {
    -- Current level
    CurLevel = 0,
    -- Current Star Rating
    CurStar = 0,
    -- Current configuration
    CurCfg = nil,

    -- Are there any special conditions
    HaveCondition = false,
    -- Current Condition Current Value
    ConditionCurValue = 0,
    -- The maximum condition value is currently required
    ConditionMaxValue = 0,

    -- Current Spirit List
    OrganDic = Dictionary:New(),
    -- Artifact Spirits Upgrade Total Level
    TotalPromoteLv = 0,

    -- Material ID required for the evolution of the spirit
    OrganEvoNeedIdList = List:New(),

    -- Is it full level
    IsFullLevel = false,
};
function RealmStifleSystem:Initialize()
end

function RealmStifleSystem:UnInitialize()
end

function RealmStifleSystem:ReqOpenPanel()
    GameCenter.Network.Send("MSG_StateStifle.ReqOpenStateStiflePanle", {});
end

function RealmStifleSystem:ReqLevelUP(isOnkey)
    GameCenter.Network.Send("MSG_StateStifle.ReqUpLevel", {oneKey = isOnkey});
end

-- Request for promotion of the spirit of the tool
function RealmStifleSystem:ReqUpPromoteLevel(id)
    local _msg = ReqMsg.MSG_StateStifle.ReqUpPromoteLevel:New()
    _msg.id = id
    _msg:Send()
end

-- Requesting the Spirit of the Tool
function RealmStifleSystem:ReqUpEvolveLevel(id)
    local _msg = ReqMsg.MSG_StateStifle.ReqUpEvolveLevel:New()
    _msg.id = id
    _msg:Send()
end

-- Request to activate the power
function RealmStifleSystem:ReqActiveSoulSpirit(id)
    local _msg = ReqMsg.MSG_StateStifle.ReqActiveSoulSpirit:New()
    _msg.id = id
    _msg:Send()
end

function RealmStifleSystem:ResOpenPanel(msg)
    self.CurLevel = msg.level.level;
    self.CurStar = msg.level.star;
    self.CurCfg = DataConfig.DataStateStifle[self.CurLevel * 100 + self.CurStar];
    if msg.conditionValue ~= nil then
        self.HaveCondition = true;
        self.ConditionCurValue = msg.conditionValue[1].progress;
        self.ConditionMaxValue = msg.conditionValue[1].total;
        if msg.conditionReach then
            self.ConditionCurValue = self.ConditionMaxValue;
        end
    else
        self.HaveCondition = false;
    end

    -- Artifact data cache
    if msg.soulSpiritList then
        local _total = 0
        for i = 1, #msg.soulSpiritList do
            local _info = msg.soulSpiritList[i]
            local _tmp = {}
            _tmp.ActiveState = _info.state
            _tmp.PromoteLv = _info.promoteLv
            _tmp.PromoteValue = _info.promotePorgress
            _tmp.EvolutionLv = _info.evolveLv
            _tmp.Type = _info.id
            _tmp.EvoCfg = DataConfig.DataStateStifleAdd[_info.id * 100 + _info.evolveLv]
            _tmp.PromoteCfg = DataConfig.DataStateStifleAddLevel[_info.id * 100 + _info.promoteLv]
            _total = _total + _info.promoteLv
            if not self.OrganDic[_info.id] then
                self.OrganDic:Add(_info.id, _tmp)
            else
                self.OrganDic[_info.id] = _tmp
            end
        end
        self.TotalPromoteLv = _total
    end

    local _nextCfg = DataConfig.DataStateStifle[self.CurLevel * 100 + self.CurStar + 1];
    if _nextCfg == nil then
        _nextCfg = DataConfig.DataStateStifle[(self.CurLevel + 1) * 100 + 0];
    end

    if _nextCfg ~= nil then
        self.IsFullLevel = false;
    else
        self.IsFullLevel = true;
    end
    self:CheckRedPoint();
    self:SetOrganVisble();
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REALMSTIFLE_INFO);
end

-- Magic weapon upgrade back
function RealmStifleSystem:ResUpLevel(msg)
    self.CurLevel = msg.level.level;
    self.CurStar = msg.level.star;
    if msg.conditionValue ~= nil then
        self.HaveCondition = true;
        self.ConditionCurValue = msg.conditionValue[1].progress;
        self.ConditionMaxValue = msg.conditionValue[1].total;
        if msg.conditionReach then
            self.ConditionCurValue = self.ConditionMaxValue;
        end
    else
        self.HaveCondition = false;
    end
    self.CurCfg = DataConfig.DataStateStifle[self.CurLevel * 100 + self.CurStar];
    local _nextCfg = DataConfig.DataStateStifle[self.CurLevel * 100 + self.CurStar + 1];
    if _nextCfg == nil then
        _nextCfg = DataConfig.DataStateStifle[(self.CurLevel + 1) * 100 + 0];
    end

    if _nextCfg ~= nil then
        self.IsFullLevel = false;
    else
        self.IsFullLevel = true;
    end
    self:CheckRedPoint();
    if GameCenter.NatureSystem.NatureFaBaoData.super then
        GameCenter.NatureSystem.NatureFaBaoData.super.Fight = msg.fight
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REALMSTIFLE_INFO);
end

-- Promotion, evolution return
function RealmStifleSystem:ResSoulSpiritInfo(msg)
    if msg.soulSpiritList then
        local _info = msg.soulSpiritList
        local _tmp = {}
        _tmp.ActiveState = _info.state
        _tmp.PromoteLv = _info.promoteLv
        _tmp.PromoteValue = _info.promotePorgress
        _tmp.EvolutionLv = _info.evolveLv
        _tmp.Type = _info.id
        _tmp.EvoCfg = DataConfig.DataStateStifleAdd[_info.id * 100 + _info.evolveLv]
        _tmp.PromoteCfg = DataConfig.DataStateStifleAddLevel[_info.id * 100 + _info.promoteLv]
        self.TotalPromoteLv =  self.TotalPromoteLv + _info.promoteLv
        if not self.OrganDic[_info.id] then
            self.OrganDic:Add(_info.id, _tmp)
        else
            self.TotalPromoteLv =  self.TotalPromoteLv - self.OrganDic[_info.id].PromoteLv
            self.OrganDic[_info.id] = _tmp
        end
    end
    self:SetOrganVisble()
    if GameCenter.NatureSystem.NatureFaBaoData.super then
        GameCenter.NatureSystem.NatureFaBaoData.super.Fight = msg.fight
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REALMSTIFLE_INFO);
    GameCenter.OfflineOnHookSystem:ReqHookSetInfo()
end

function RealmStifleSystem:CheckRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FaBaoUpGrade);
    if self.IsFullLevel == false then
        local _itemParams = Utils.SplitStr(self.CurCfg.NeedItem, '_');

        local _conditions = List:New();
        _conditions:Add(RedPointItemCondition(tonumber(_itemParams[1]), tonumber(_itemParams[2])));

        if self.HaveCondition then
            _conditions:Add(RedPointCustomCondition(self.ConditionCurValue >= self.ConditionMaxValue));
        end
        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.FaBaoUpGrade, 0, _conditions);
    end
end

-- Set whether the tool spirit function is open
function RealmStifleSystem:SetOrganVisble()
    local _isOpen = false
    local _promoteRed = false
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FaBaoActive);
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FaBaoEvolution);
    self.OrganDic:Foreach(function(k, v)
        if v.ActiveState == 2 then
            _isOpen = true
            if v.EvoCfg and v.EvoCfg.IfMax ~= 1 then
                local _ar = Utils.SplitStr(v.EvoCfg.JinhuaNeedItem, ';')
                -- Item Conditions
                local _conditions = List:New();
                for i = 1, #_ar do
                    local _single = Utils.SplitNumber(_ar[i], '_')
                    if #_single >= 2 then
                        _conditions:Add(RedPointItemCondition(_single[1], _single[2]));
                    end
                end
                GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.FaBaoEvolution, k, _conditions);
            end
        else
            self:GetOrganCanActive(k)
        end
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FaBaoPromote, _promoteRed)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.FaBaoOrgan, _isOpen)
end

-- Is there a red dot for a certain weapon spirit to be promoted?
function RealmStifleSystem:GetOrganPromoteRedByType(type)
    if self.OrganDic[type] and self.OrganDic[type].ActiveState == 2 then
        if self.OrganDic[type].PromoteCfg and self.OrganDic[type].PromoteCfg.IfMax ~= 1 then
            local _ar = Utils.SplitNumber(self.OrganDic[type].PromoteCfg.NeedItem, '_')
            if self.OrganDic[type].PromoteValue >= _ar[#_ar] and self.CurLevel >= self.OrganDic[type].PromoteCfg.NeedLevel then
                return true
            end
        end
    end
    return false
end
-- Does a certain spirit have an evolutionary red dot
function RealmStifleSystem:GetOrganEvoRedByType(type)
    if self.OrganDic[type] and self.OrganDic[type].ActiveState == 2 then

    end
end

-- Is a certain spirit activateable
function RealmStifleSystem:GetOrganCanActive(type)
    if self.OrganDic[type] and self.OrganDic[type].ActiveState ~= 2 then
        if self.OrganDic[type].EvoCfg and self.CurLevel >= self.OrganDic[type].EvoCfg.NeedLevel then
            local _ar = Utils.SplitNumber(self.OrganDic[type].EvoCfg.NeedItem, '_')
            GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.FaBaoActive, type, RedPointItemCondition(_ar[1], _ar[2]))

        end
    end
end

function RealmStifleSystem:GetStifleCfgID()
    return self.CurLevel * 100 + self.CurStar;
end

-- Get the name of the spirit
function RealmStifleSystem:GetOrganName(type)
    local _str = ""
    if type == 1 then
        _str = DataConfig.DataMessageString.Get("ExpSpirit")
    elseif type == 2 then
        _str = DataConfig.DataMessageString.Get("FightSpirit")
    elseif type == 3 then
        _str = DataConfig.DataMessageString.Get("ChasedSpirit")
    end
    return _str
end

-- Get the current tool spirit configuration according to the type
function RealmStifleSystem:GetOrganDataByType(type)
    local _organData = self.OrganDic[type]
    return _organData
end
return RealmStifleSystem;
