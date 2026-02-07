-- Author:
-- Date: 2020-07-04
-- File: FlySowardSystem.lua
-- Module: FlySowardSystem
-- Description: Sword Spirit system data processing, information out of
------------------------------------------------
-- Quote
local RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition;

local FlySowardSystem = {
    FlySowardDataDic = Dictionary:New(),
    FlySowardTypeDic = Dictionary:New(),
    CurUseModel = 0,
}

function FlySowardSystem:UnInitialize()
    self.FlySowardDataDic:Clear()
    self.FlySowardTypeDic:Clear()
end

-- Initialize configuration table data
function FlySowardSystem:InitCfgData()
    DataConfig.DataHuaxingFlySword:Foreach(function(k, v)
        local _data = {}
        _data.IsActive = false
        _data.Cfg = v
        self.FlySowardDataDic:Add(k, _data)
        if self.FlySowardTypeDic:ContainsKey(v.Type) then
            self.FlySowardTypeDic[v.Type].IDList:Add(k)
        else
            local _list = List:New()
            _list:Add(k)
            local _typeData = {}
            _typeData.IDList = _list
            _typeData.Level = 0
            _typeData.Grade = 0
            _typeData.Type = v.Type
            self.FlySowardTypeDic:Add(v.Type, _typeData)
        end
    end)
end

-- Get the data interface. The data list is not loaded during initialization. When using it, then load the table.
function FlySowardSystem:GetTypeDic()
    if self.FlySowardTypeDic:Count() <= 0 then
        self:InitCfgData()
    end
    return self.FlySowardTypeDic
end

-- Get the data interface. The data list is not loaded during initialization. When using it, then load the table.
function FlySowardSystem:GetDataDic()
    if self.FlySowardDataDic:Count() <= 0 then
        self:InitCfgData()
    end
    return self.FlySowardDataDic
end

-- Get the name according to the sword spirit type
function FlySowardSystem:GetActiveCfgByType(type)
    local _typeDic = self:GetTypeDic()
    if _typeDic:ContainsKey(type) then
        local _typeData = _typeDic[type]
        local _dataDic = self:GetDataDic()
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive or (i == 1 and not _data.IsActive) then
                    return _data.Cfg
                end
            end
        end
    end
    return nil
end

-- Judging by the sword spirit type
function FlySowardSystem:GetActiveByType(type)
    local _typeDic = self:GetTypeDic()
    if _typeDic:ContainsKey(type) then
        local _typeData = _typeDic[type]
        local _dataDic = self:GetDataDic()
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive then
                    return true
                end
            end
        end
    end
    return false
end

function FlySowardSystem:GetCanTrianByType(type)
    if not self:GetActiveByType(type) then
        return false
    end
    if type > 1 then
        local _result = false
        local _skCfg = DataConfig.DataHuaxingFlySwordSkill[type - 1]
        if _skCfg.Type == 1 then
            local _ar = Utils.SplitNumber(_skCfg.ActivePram, '_')
            if _ar[1] and _ar[2] then
                local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                if _typeDic then
                    _typeDic:ForeachCanBreak(function(k, v)
                        if k == _ar[1] then
                            _result = v.Grade >= _ar[2]
                            return true
                        end
                    end)
                end
            end
        elseif _skCfg.Type == 2 then
            local _ar = Utils.SplitNumber(_skCfg.ActivePram, '_')
            if _ar[1] and _ar[2] then
                local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                if _typeDic then
                    local _num = 0
                    _typeDic:Foreach(function(k, v)
                        if v.Grade >= _ar[2] then
                            _num = _num + 1
                        end
                    end)
                    _result = _num >= _ar[1]
                end
            end
        end
        return _result
    else
        return true
    end
end

-- Get the highest currently activated sword spirit type
function FlySowardSystem:GetHighSwordType()
    local _typeDic = self:GetTypeDic()
    local _type = 1
    local _index = 1
    _typeDic:ForeachCanBreak(function(k, v)
        local _typeData = v
        local _dataDic = self:GetDataDic()
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive or (i == 1 and not _data.IsActive and _index == 1) then
                    _type = k
                else
                    break
                end
            end
        end
        if _type < k then
            return true
        end
        _index = _index + 1
    end)
    return _type
end

-- Get the currently activated sword spirit list
function FlySowardSystem:GetActiveSwordIdList()
    local _typeDic = self:GetTypeDic()
    local list = List:New()
    _typeDic:ForeachCanBreak(function(k, v)
        local _typeData = v
        local _dataDic = self:GetDataDic()
        local id = 0
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive then
                    id = _typeData.IDList[i]
                else
                    break
                end
            end
        end
        if id > 0 then
            list:Add(id)
        end
    end)
    return list
end

-- Get the highest currently activated sword spirit type
function FlySowardSystem:GetActiveSwordCount()
    local _typeDic = self:GetTypeDic()
    local _index = 0
    _typeDic:ForeachCanBreak(function(k, v)
        local _typeData = v
        local _dataDic = self:GetDataDic()
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive then
                    _index = _index + 1
                    break
                end
                if not _data.IsActive and i == 1 then
                    break
                end
            end
        end
    end)
    return _index
end

-- Get the sword spirit type with red dots
function FlySowardSystem:GetHaveRedType()
    local _typeDic = self:GetTypeDic()
    local _type = 1
    _typeDic:ForeachCanBreak(function(k, v)
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpLv, k) then
            _type = k
            return true
        end
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpGrade, k) then
            _type = k
            return true
        end
    end)
    return _type
end

function FlySowardSystem:CheckRed()
    local _dataDic = self:GetDataDic()
    local _typeDic = self:GetTypeDic()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FlySwordSpriteUpLv)
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.FlySwordSpriteUpGrade)
    if _typeDic and _dataDic then
        _typeDic:Foreach(function(k, v)
            if self:GetCanTrianByType(k) then
                local _upCfg = DataConfig.DataHuaxingFlySwordLevelup[v.Level]
                if _upCfg and _upCfg.UpItem and _upCfg.UpItem ~= "" then
                    local _arr = Utils.SplitStr(_upCfg.UpItem, ';')
                    if _arr then
                        local _conditions = List:New();
                        -- Item Conditions
                        for i = 1, #_arr do
                            local _curItem = Utils.SplitNumber(_arr[i], '_')
                            _conditions:Add(RedPointItemCondition(_curItem[1], _curItem[2]))
                        end
                        -- Calling the Lua special conditional interface
                        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.FlySwordSpriteUpLv, k, _conditions)
                    end
                end
                _upCfg = DataConfig.DataHuaxingFlySwordAdvanced[v.Grade]
                if _upCfg and _upCfg.ActiveItem and _upCfg.ActiveItem ~= "" then
                    local _arr = Utils.SplitStr(_upCfg.ActiveItem, ';')
                    if _arr and v.Level >= _upCfg.Levelmax then
                        local _conditions = List:New();
                        -- Item Conditions
                        for i = 1, #_arr do
                            local _curItem = Utils.SplitNumber(_arr[i], '_')
                            _conditions:Add(RedPointItemCondition(_curItem[1], _curItem[2]))
                        end
                        -- Calling the Lua special conditional interface
                        GameCenter.RedPointSystem:LuaAddFuncCondition(FunctionStartIdCode.FlySwordSpriteUpGrade, k, _conditions)
                    end
                end
            end
        end)
    end
end

-- Initialization online
function FlySowardSystem:ResOnlineInitHuaxin(msg)
    if msg then
        self.CurUseModel = msg.curUseFlysword
        if msg.huaxinList then
            for i = 1, #msg.huaxinList do
                for j = 1, #msg.huaxinList[i].modelID do
                    local id = msg.huaxinList[i].modelID[j]
                    if self.FlySowardDataDic:Count() <= 0 then
                        self:InitCfgData()
                    end
                    if self.FlySowardDataDic:ContainsKey(id) then
                        self.FlySowardDataDic[id].IsActive = true
                    end
                end
                if self.FlySowardTypeDic:Count() <= 0 then
                    self:InitCfgData()
                end
                local _type = msg.huaxinList[i].type
                if _type and self.FlySowardTypeDic:ContainsKey(_type) then
                    self.FlySowardTypeDic[_type].Level = msg.huaxinList[i].starLevel
                    self.FlySowardTypeDic[_type].Grade = msg.huaxinList[i].steps
                end
            end
        end
    end
    self:CheckRed()
end

-- Activate Return
function FlySowardSystem:ResUseHuxinResult(msg)
    if msg then
        -- activation
        if msg.type == 1 then
            self.CurUseModel = msg.curUseFlysword
            if self.FlySowardDataDic:Count() <= 0 then
                self:InitCfgData()
            end
            if self.FlySowardDataDic:ContainsKey(self.CurUseModel) then
                self.FlySowardDataDic[self.CurUseModel].IsActive = true
            end
            self:CheckRed()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_ACTIVE_NEW)
            -- local _typeDic = self:GetTypeDic()
            -- _typeDic:ForeachCanBreak(function(k, v)
            --     if v.IDList:Contains(self.CurUseModel) then
            --         for i = 1, #v.IDList do
            --             if(v.IDList[i] == self.CurUseModel and i > 1) then
            --                 -- GameCenter.PushFixEvent(UIEventDefine.UINewSwordShowForm_OPEN, self.CurUseModel)
            --             end
            --         end
            --         return true
            --     end
            -- end)
        -- upgrade
        elseif msg.type == 2 then
            if self.FlySowardDataDic:Count() <= 0 then
                self:InitCfgData()
            end
            if self.FlySowardDataDic:ContainsKey(msg.curUseFlysword) then
                local _type = self.FlySowardDataDic[msg.curUseFlysword].Cfg.Type
                if self.FlySowardTypeDic:ContainsKey(_type) then
                    self.FlySowardTypeDic[_type].Level = self.FlySowardTypeDic[_type].Level + 1
                end
            end
            self:CheckRed()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_UPDATE)
        -- Switch
        elseif msg.type == 3 then
            self.CurUseModel = msg.curUseFlysword
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_CHANGEMODEL)
        -- Upgrade
        elseif msg.type == 4 then
            if self.FlySowardDataDic:Count() <= 0 then
                self:InitCfgData()
            end
            if self.FlySowardDataDic:ContainsKey(msg.curUseFlysword) then
                local _type = self.FlySowardDataDic[msg.curUseFlysword].Cfg.Type
                if self.FlySowardTypeDic:ContainsKey(_type) then
                    self.FlySowardTypeDic[_type].Grade = self.FlySowardTypeDic[_type].Grade + 1
                end
            end
            self:CheckRed()
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FLYSWORD_UPDATE)
        end
    end
end
return FlySowardSystem