------------------------------------------------
-- Author:
-- Date: 2021-03-12
-- File: SoulPearl.lua
-- Module: SoulPearl
-- Description: Soul Seal Data Model
------------------------------------------------
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local L_ParentCSType = CS.Thousandto.Code.Logic.LuaItemBase
local SoulPearl = {
    -- CS parent class object
    _SuperObj_ = 0,
    -- Configuration table
    ItemInfo = nil,
    -- Basic attribute dictionary
    BaseAttrs = nil,
    -- Special attribute dictionary
    SpecialAttrs = nil,
    Power = 0,
    SlotId = 0,
}
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SoulPearl:Initialization(id)
    self.ItemInfo = DataConfig.DataEquip[id]
    return true;
end

function SoulPearl:UnInitialization()
    if self.BaseAttrs then
        self.BaseAttrs:Clear()
    end
end
function SoulPearl:GetItemType()
    return ItemType.SoulPearl;
end
function SoulPearl:GetName()
    local ret = "";
    if self.ItemInfo then
        ret = self.ItemInfo.Name;
    end
    return ret;
end
function SoulPearl:GetIcon()
    local ret = -1;
    if self.ItemInfo then
        ret = self.ItemInfo.Icon;
    end
    return ret;
end
function SoulPearl:GetEffect()
    local ret = -1;
    if self.ItemInfo then
        ret = self.ItemInfo.Effect;
    end
    return ret;
end
function SoulPearl:GetQuality()
    local ret = -1;
    if self.ItemInfo then
        ret = self.ItemInfo.Quality;
    end
    return ret;
end
function SoulPearl:GetStarNum()
    local ret = 0;
    if self.ItemInfo then
        ret = self.ItemInfo.DiamondNumber;
    end
    return ret;
end
function SoulPearl:GetOcc()
    local ret = "";
    if self.ItemInfo then
        ret = self.ItemInfo.Gender;
    end
    return ret;
end
function SoulPearl:GetPart()
    local ret = -1;
    if self.ItemInfo then
        ret = self.ItemInfo.Part;
    end
    return ret;
end
function SoulPearl:GetGrade()
    local ret = 0;
    if self.ItemInfo then
        ret = self.ItemInfo.Grade;
    end
    return ret;
end
function SoulPearl:GetPower()
    return self.Power;
end
function SoulPearl:CheckLevel(level)
    return self.ItemInfo.Level <= level;
end
function SoulPearl:CheackOcc(sex)
    if (string.find(self.Occ, "9") ~= nil) then
        return true;
    end
    local ret = false;
    if string.find(self.ItemInfo.Gender, tostring(sex)) ~= nil then
        ret = true;
    else
        ret = false;
    end
    return ret;
end

function SoulPearl:CheckClass()
    if (self.ItemInfo.Classlevel <= 0) then
        return true;
    else
        local p = GameCenter.GameSceneSystem:GetLocalPlayer();
        if p then
            if (p.ChangeJobLevel >= self.ItemInfo.Classlevel) then
                return true;
            else
                return false;
            end
        end
    end
    return false;
end
-- Check whether it can be put on the shelves
function SoulPearl:CanAuction()
    if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Auchtion) then
        return false;
    end
    if (self.IsBind) then
        return false;
    end
    if (self.ItemInfo.AuctionMaxPrice == 0) then
        return false;
    end
    return true;
end
-- Is it valid or not
function SoulPearl:IsValid()
    return self.ItemInfo ~= nil
end
function SoulPearl:CheckBetterThanDress()
    local dressEquip = GameCenter.SoulEquipSystem:GetDressPeralPowerByPart(self.Part)
    if(dressEquip > 0) then
        return self.Power > dressEquip;
    end
    return true;
end

-- Poor combat effectiveness of obtaining and wearing equipment
function SoulPearl:GetDressPowerDiff()
    local dressEquip = GameCenter.SoulEquipSystem:GetDressPeralPowerByPart(self.Part)
    if(dressEquip > 0) then
        return self.Power - dressEquip;
    end
    return self.Power;
end
-- --------------------------------------------------------------------------------------------------------------------------------
function SoulPearl:NewWithMsg(msg)
    local _m = Utils.DeepCopy(self)
    _m._SuperObj_ = L_ParentCSType.CreateByMsg(msg);
    _m:_InitBindOverride_();
    _m:_InitContent_();
    if msg then
        _m:Initialization(msg.itemModelId);
    end
    _m:SetAttribute();
    _m:SetSlotId()
    Utils.BuildInheritRel(_m);
    return _m
end
function SoulPearl:New(...)
    local _m = Utils.DeepCopy(self)
    _m._SuperObj_ = L_ParentCSType.Create(...);
    _m:_InitBindOverride_();
    _m:_InitContent_();    
    _m:Initialization(...);
    _m:SetAttribute();
    _m:SetSlotId()
    Utils.BuildInheritRel(_m);
    return _m
end
-- Methods to bind Override
function SoulPearl:_InitBindOverride_()
    -- Redefinition of overloaded functions
    -- Redefinition of overloaded functions
    self._SuperObj_.IsValidDelegate = Utils.Handler(self.IsValid, self, nil, true);
    self._SuperObj_.CanAuctionDelegate = Utils.Handler(self.CanAuction, self, nil, true);
    self._SuperObj_.CheckClassDelegate = Utils.Handler(self.CheckClass, self, nil, true);
    self._SuperObj_.CheckOccDelegate = Utils.Handler(self.CheackOcc, self, nil, true);
    self._SuperObj_.CheckLevelDelegate = Utils.Handler(self.CheckLevel, self, nil, true);
    self._SuperObj_.GetPowerDelegate = Utils.Handler(self.GetPower, self, nil, true);
    self._SuperObj_.GetGradeDelegate = Utils.Handler(self.GetGrade, self, nil, true);
    self._SuperObj_.GetPartDelegate = Utils.Handler(self.GetPart, self, nil, true);
    self._SuperObj_.GetOccDelegate = Utils.Handler(self.GetOcc, self, nil, true);
    self._SuperObj_.GetStarNumDelegate = Utils.Handler(self.GetStarNum, self, nil, true);
    self._SuperObj_.GetQualityDelegate = Utils.Handler(self.GetQuality, self, nil, true);
    self._SuperObj_.GetEffectDelegate = Utils.Handler(self.GetEffect, self, nil, true);
    self._SuperObj_.GetIconDelegate = Utils.Handler(self.GetIcon, self, nil, true);
    self._SuperObj_.GetNameDelegate = Utils.Handler(self.GetName, self, nil, true);
    self._SuperObj_.GetItemTypeDelegate = Utils.Handler(self.GetItemType, self, nil, true);
    self._SuperObj_.UnInitializationDelegate = Utils.Handler(self.UnInitialization, self, nil, true);
    self._SuperObj_.GetDressPowerDiffDelegate = Utils.Handler(self.GetDressPowerDiff, self, nil, true);
    self._SuperObj_.CheckBetterThanDressDelegate = Utils.Handler(self.CheckBetterThanDress, self, nil, true);
end
-- initialization
function SoulPearl:_InitContent_()
    -- Define temporary variables, user callbacks
end

function SoulPearl:GetCSObj()
    return self._SuperObj_;
end
-- Get the most basic attribute value of the equipment
function SoulPearl:GetBaseAttribute()
    if self.BaseAttrs then
        return self.BaseAttrs;
    end
    return Dictionary:New()
end

-- Get special attribute values for equipment
function SoulPearl:GetSpecialAttribute()
    if self.SpecialAttrs then
        return self.SpecialAttrs;
    end
    return Dictionary:New()
end

-- Calculate the attribute value of the current equipment
function SoulPearl:SetAttribute()
    if self.ItemInfo == nil then
        return;
    end
    if (LuaItemBase.EquipBaseAttDic == nil) then
        LuaItemBase.EquipBaseAttDic = Dictionary:New()
    end
    if(LuaItemBase.EquipBaseAttDic:ContainsKey(self.ItemInfo.Id)) then
        self.BaseAttrs = LuaItemBase.EquipBaseAttDic[self.ItemInfo.Id];
    else
        if self.BaseAttrs == nil then
            self.BaseAttrs = Dictionary:New()
        end
        self.BaseAttrs:Clear();
        local attrsArr = Utils.SplitStr(self.ItemInfo.Attribute1, ';')
        for i = 1, #attrsArr do
            local attrs = Utils.SplitNumber(attrsArr[i], '_')
            if #attrs == 2 then
                if not self.BaseAttrs:ContainsKey(attrs[1]) then
                    self.BaseAttrs:Add(attrs[1], attrs[2]);
                end
            end
        end
        -- Cache the attributes, and will not GC again next time you use them
        LuaItemBase.EquipBaseAttDic[self.ItemInfo.Id] = self.BaseAttrs;
    end

    if (LuaItemBase.EquipSpecialAttDic == nil) then
        LuaItemBase.EquipSpecialAttDic = Dictionary:New()
    end
    if (LuaItemBase.EquipSpecialAttDic:ContainsKey(self.ItemInfo.Id)) then
        self.SpecialAttrs = LuaItemBase.EquipSpecialAttDic[self.ItemInfo.Id];
    else
        if self.SpecialAttrs == nil then
            self.SpecialAttrs = Dictionary:New()
        end
        self.SpecialAttrs:Clear();
        local attrsArr = Utils.SplitStr(self.ItemInfo.Attribute2, ';')
        for i = 1, #attrsArr do
            local attrs = Utils.SplitNumber(attrsArr[i], '_')
            if #attrs == 2 then
                if not self.SpecialAttrs:ContainsKey(attrs[1]) then
                    self.SpecialAttrs:Add(attrs[1], attrs[2]);
                end
            end
        end
        -- Cache the attributes, and will not GC again next time you use them
        LuaItemBase.EquipSpecialAttDic[self.ItemInfo.Id] = self.SpecialAttrs;
    end
    self.Power = FightUtils.GetPropetryPower(self.BaseAttrs) + FightUtils.GetPropetryPower(self.SpecialAttrs);
end

function SoulPearl:SetSlotId()
    if self.SlotId == 0 and self.ItemInfo then
        DataConfig.DataSoulArmorSignetHole:ForeachCanBreak(function(k, v)
            if (v.EquipType == self.ItemInfo.Part) then
                self.SlotId = v.Hole;
                return true;
            end
        end)
    end
end
return SoulPearl