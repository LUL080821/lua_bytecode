------------------------------------------------
-- Author:
-- Date: 2019-06-12
-- File: RoleTitleSystem.lua
-- Module: RoleTitleSystem
-- Description: Role Title System
------------------------------------------------
local TitleData = require "Logic.RoleTitle.TitleData"
local ItemContianerSystem = CS.Thousandto.Code.Logic.ItemContianerSystem

local RoleTitleSystem = {
    -- Current wearable title
    CurrWearTitle = nil,
    -- Title type data
    TitleTypeData = List:New(),
    -- List of titles owned
    CurrHaveTitleList = List:New(),
    -- Title data
    TitlesData = Dictionary:New(),
    -- initialize
    Initalized = false,
    -- Red dot
    RedPoint = false,
    -- New title obtained
    NewTitleDic = Dictionary:New(),
    -- Title id in the current display prompt
    ShowTitleId = 0
}

local L_TitleTypeData = {
    Type = nil,
    Name = nil,
    ShowRed = false
}

function RoleTitleSystem:Initialize()
    local _types = List:New()
    DataConfig.DataTitle:Foreach(function(k, v)
        if v.CanShow >= 1 then
            -- Blocking achievements
            if v.Type == 2 then
                return
            end
            if _types:Contains(v.Type) then
                self.TitlesData[v.Type]:Add(TitleData:New(v))
            else
                _types:Add(v.Type)
                self.TitlesData[v.Type] = List:New()
                self.TitlesData[v.Type]:Add(TitleData:New(v))
                local _data = Utils.DeepCopy(L_TitleTypeData)
                _data.Type = v.Type
                _data.Name = v.TypeName
                self.TitleTypeData:Add(_data)
            end
        end
    end)
    table.sort(self.TitleTypeData, function(a, b)
        return a.Type < b.Type
    end)
    for k, v in pairs(self.TitlesData) do
        table.sort(v, function(a, b)
            return a.Sort < b.Sort
        end)
    end

    -- GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.ItemChange, self)
end

function RoleTitleSystem:UnInitialize()
    self.TitlesData:Clear()
    self.TitleTypeData:Clear()
    self.CurrHaveTitleList:Clear()
    -- GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.ItemChange, self)
end

-- Sort
function RoleTitleSystem:SortData()
    for k, v in pairs(self.TitlesData) do
        table.sort(v, function(a, b)
            if a.Have == b.Have then
                return a.Sort < b.Sort
            else
                return a.Have == true
            end
        end)
    end
end

-- Update title data
function RoleTitleSystem:UpdateTitleData(t, info)
    for i = 1, #self.TitlesData[t] do
        if self.TitlesData[t][i].TitleID == info.id then
            self.TitlesData[t][i]:UpdateInfo(info)
        end
    end
end

-- Remove the possession status every time the title data is synchronized
function RoleTitleSystem:Remove()
    for k, v in pairs(self.TitlesData) do
        for i = 1, #v do
            v[i]:Remove()
        end
    end
end

-- Set wearable title
function RoleTitleSystem:SetCurrTitleInfo(info)
    local _cfg = DataConfig.DataTitle[info.id]
    if _cfg then
        self.CurrWearTitle = TitleData:New(_cfg)
        self.CurrWearTitle:UpdateInfo(info)
    end
end

-- The current wearable title id
function RoleTitleSystem:GetCurrTitleID()
    if self.CurrWearTitle then
        return self.CurrWearTitle.TitleID
    else
        return 0
    end
end

-- Refresh the display of character title in the scene
function RoleTitleSystem:RefreshPlayerTitleHUD()
    local _p = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _p then
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_HUD_UPDATE_HEADINFO, _p)
    end
end

-- Check whether the title item is automatically used
function RoleTitleSystem:CheckTitleItemUse(titleId)
    if not self.Initalized then
        return false
    end
    local _cfg = DataConfig.DataTitle[titleId]
    if _cfg then
        if _cfg.CanShow >= 1 and _cfg.Activation == 1 then
            if self.CurrHaveTitleList:Contains(titleId) then
                return false
            else
                return true
            end
        else
            return false
        end
    end
    return false
end

-- Use title items
function RoleTitleSystem:ItemChange(obj, sender)
    -- if obj  then
    --     local _items = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, obj)
    --     if _items.Count > 0 and _items[0].Type == ItemType.Title then
    --         self:SetRoleTitleRedPoint()
    --     end
    -- end
end

-- Get the title info
function RoleTitleSystem:GetTitleInfo(titleType, id)
    for i = 1, #self.TitlesData[titleType] do
        if self.TitlesData[titleType][i].TitleID == id then
            return self.TitlesData[titleType][i]
        end
    end
    return nil
end

-- Title red dot
function RoleTitleSystem:ShowRed()
    return self.RedPoint
end

-- Set the title red dot
function RoleTitleSystem:SetRoleTitleRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.RoleTitle)
    local _num = 0
    for i = 1, #self.TitleTypeData do
        local _red = self:CheckRedPoint(self.TitleTypeData[i].Type)
        self.TitleTypeData[i].ShowRed = _red
        if _red then
            _num = _num + 1
        end
    end
    self.RedPoint = _num > 0
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TITLE_REDPOINT)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.RoleTitle, self.RedPoint)
end

-- Detect red dots
function RoleTitleSystem:CheckRedPoint(t)
    local _num = 0
    for i = 1, self.TitlesData[t]:Count() do
        local _info = self.TitlesData[t][i]
        local _items = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, _info.TitleID)
        self.TitlesData[t][i].ShowRed = _items.Count > 0 and (not _info.Have) and _items[0].Type == ItemType.Title
        if self.TitlesData[t][i].ShowRed then
            _num = _num + 1
        end
    end
    return _num > 0
end

-----------------------msg----------------------
-- Request to activate the title
function RoleTitleSystem:ReqActiveTitle(id)
    local _req = {}
    _req.id = id
    GameCenter.Network.Send("MSG_Title.ReqActiveTitle", _req)
end

-- Wearing title
function RoleTitleSystem:ReqWearTitle(id)
    local _req = {}
    _req.id = id
    GameCenter.Network.Send("MSG_Title.ReqWearTitle", _req)
end

-- Remove the title
function RoleTitleSystem:ReqDownTitle(id)
    local _req = {}
    _req.id = id
    GameCenter.Network.Send("MSG_Title.ReqDownTitle", _req)
end

-- Get what needs to be hidden
function RoleTitleSystem:GetNeedHideTitleList()
    local _count = self.CurrHaveTitleList:Count();
    if _count > 0 then
        local _cfg = DataConfig.DataTitle;
        local _list = nil;
        for i = 1, _count do
            local _cfgItem = _cfg[self.CurrHaveTitleList[i]];
            if _cfgItem.CanShow > 1 then
                if not _list then
                    _list = List:New();
                end
                _list:Add(_cfgItem.CanShow);
            end
        end
        return _list;
    end
end

-- Have you received a new title?
function RoleTitleSystem:IsHaveGetNewByBigType(bigType)
    local _keys = self.NewTitleDic:GetKeys();
    if _keys and #_keys > 0 then
        for i = 1, #_keys do
            if self.NewTitleDic[_keys[i]].Type == bigType then
                return true;
            end
        end
    end
    return false;
end

-- Is it newly obtained the title?
function RoleTitleSystem:IsGetNewTitle(id)
    return self.NewTitleDic:ContainsKey(id);
end

-- Is it newly obtained the title?
function RoleTitleSystem:RemoveNewTitle(id)
    if self.NewTitleDic:ContainsKey(id) then
        self.NewTitleDic:Remove(id);
    end
end

-- Activate the title and return
function RoleTitleSystem:GS2U_ResActiveTitle(msg)
    if msg.info then
        local _cfg = DataConfig.DataTitle[msg.info.id]
        if _cfg and _cfg.CanShow >= 1 then
            self.ShowTitleId = msg.info.id
            self.NewTitleDic[msg.info.id] = _cfg
            if not self.CurrHaveTitleList:Contains(msg.info.id) then
                self.CurrHaveTitleList:Add(msg.info.id)
            end
            self:UpdateTitleData(_cfg.Type, msg.info)
            local _info = TitleData:New(_cfg)
            _info:UpdateInfo(msg.info)
            self:SetRoleTitleRedPoint()
            self:SortData()
            -- Temporarily blocked
            -- if self.CurrWearTitle then
            --     if self.CurrWearTitle.Level < _cfg.Quality then
            --         self:ReqWearTitle(msg.info.id)
            --     else
            --         if self.CurrWearTitle.TitleID ==  _info.TitleID then
            --             self.CurrWearTitle = _info
            --         end
            --         GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TITLE_REFRESH_TITLESTATE)
            --     end
            -- else
            --     self:ReqWearTitle(msg.info.id)
            -- end
            if _cfg.IsAutoWear == 1 then
                GameCenter.PushFixEvent(UILuaEventDefine.UITitleTipsForm_OPEN);
                GameCenter.PushFixEvent(UILuaEventDefine.UITitleTipsForm_Refresh);
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_TITLE_REFRESH_MARRIAGE_USE)
        end
    end
end

-- Wearing title return
function RoleTitleSystem:GS2U_ResWearTitle(msg)
    if msg.info and msg.info.id ~= 0 then
        self:SetCurrTitleInfo(msg.info)
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TITLE_REFRESH_TITLESTATE)
        Utils.ShowPromptByEnum("WearTitle", self.CurrWearTitle.TitleName)
    end
end

-- Remove the title and return
function RoleTitleSystem:GS2U_ResDownTitle(msg)
    if msg.id == self.CurrWearTitle.TitleID then
        Utils.ShowPromptByEnum("TakeOffTitle", self.CurrWearTitle.TitleName)
        self.CurrWearTitle = nil
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TITLE_REFRESH_TITLESTATE)
    end
end

-- Title data, sent online
function RoleTitleSystem:GS2U_ResTitleInfo(msg)
    if msg.wear then
        if msg.wear.id ~= 0 then
            self:SetCurrTitleInfo(msg.wear)
            self:RefreshPlayerTitleHUD()
        end
    end
    if msg.list then
        self:Remove()
        self.CurrHaveTitleList:Clear()
        for i = 1, #msg.list do
            self.CurrHaveTitleList:Add(msg.list[i].id)
            local _cfg = DataConfig.DataTitle[msg.list[i].id]
            if _cfg then
                self:UpdateTitleData(_cfg.Type, msg.list[i])
            end
        end
    else
        self:Remove()
        self.CurrHaveTitleList:Clear()
    end
    self:SortData()
    self.Initalized = true
    self:SetRoleTitleRedPoint()
    -- Remove title Refresh title list
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_TITLE_REFRESH_TITLESTATE)
end

return RoleTitleSystem
