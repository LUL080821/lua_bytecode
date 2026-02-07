------------------------------------------------
-- Author: 
-- Date: 2020-08-08
-- File: YYHDSystem.lua
-- Module: YYHDSystem
-- Description: Operation activity system
------------------------------------------------
local CSDebug = CS.UnityEngine.Debug
local L_LuckCat = require("Logic.YYHD.LuckCat.LuckCatData")
local L_TuanGou = require("Logic.YYHD.TuanGou.TuanGouData")
local L_XianShiLeiChong = require("Logic.YYHD.XianShiLeiChong.XianShiLeiChongData")
local L_LimitTimeLogin = require("Logic.YYHD.LimitTimeLogin.LimitTimeLoginData")
local L_XianShiXiaoHao = require("Logic.YYHD.XianShiXiaoHao.XianShiXiaoHaoData")
local L_ActiveExchangeData = require("Logic.YYHD.ActiveExchange.ActiveExchangeData")
local L_XianGouLiBaoData = require("Logic.YYHD.XianGouLiBao.XianGouLiBaoData")
local L_DailyRechargeData = require("Logic.YYHD.DailyRecharge.DailyRechargeData")
local L_TianDiBaoKuData = require("Logic.YYHD.TianDiBaoKu.TianDiBaoKuData")
local L_JiWuDuiHuanData = require("Logic.YYHD.JiWuDuiHuan.JiWuDuiHuanData")
local L_JieRiTeHuiData = require("Logic.YYHD.JieRiTeHui.JieRiTeHuiData")
local L_XianShiLiBaoData = require("Logic.YYHD.XianShiLiBao.XianShiLiBaoData")
local L_QingDianTaskData = require("Logic.YYHD.YDqingDianTask.YDQingDianTaskData")
local L_LianXuLeiChongData = require("Logic.YYHD.LianXuLeiChong.LianXuLeiChongData")
local L_XianShiShangChengData = require("Logic.YYHD.XianShiShangCheng.XianShiShangChengData")
local L_JieRiXueYuanData = require("Logic.YYHD.JieRiXueYuan.JieRiXueYuanData")
local L_FBFenXiangData = require("Logic.YYHD.FBFenXiang.FBFenXiangData")
local L_JiZiDuiHuanData = require("Logic.YYHD.JiZiDuiHuan.JiZiDuiHuanData")
local L_JiFenPaiMingData = require("Logic.YYHD.JiFenPaiMing.JiFenPaiMingData")
local L_BossHappyData = require("Logic.YYHD.BossHappy.BossHappyData")
local L_LianXuLeiChongData2 = require("Logic.YYHD.LianXuLeiChong.LianXuLeiChongData2")
local L_XinChunZhuFuData = require("Logic.YYHD.XinChunZhuFu.XinChunZhuFuData")
local L_RollDiceData = require("Logic.YYHD.RollDice.RollDiceData")
local L_WaiGuanZhanShiData = require("Logic.YYHD.WaiGuanZhanShi.WaiGuanZhanShiData")
local L_OnlinePromptData = require("Logic.YYHD.OnlinePrompt.OnlinePromptData")
local L_JuBaoPenData = require("Logic.YYHD.JuBaoPen.JuBaoPenData")
local L_XingYunZaDanData = require("Logic.YYHD.XingYunZaDan.XingYunZaDanData")
local L_LuckCatBYData = require("Logic.YYHD.LuckCat.LuckCatBYData")
local L_FZTBData = require("Logic.YYHD.FangZeTabBao.FZTBData")


local YYHDSystem = {
    DataTable = {},
    CheckFrame = 0,
    -- When rolling dice to consume ingots, do you prompt for a second time?
    IsRollConfirm = true,
    -- The icon that has been displayed on the main interface
    MainShowIconTable = nil,
    -- Tag configuration
    TagCfg = nil,
}

function YYHDSystem:Initialize()
    self.MainShowIconTable = {}
    -- UI style:
    -- 1: Basics
    -- 2: Christmas
    -- 3: New Year's Day
    -- 4: Spring Festival
    -- 5: Valentine's Day
    -- 6: Water Splashing Festival
    -- Assign default values
    self.TagCfg = List:New()
    self.TagCfg:Add({Tag = 1, Name = "Limited time activities", Icon = 1753, Style = 1})
    self.TagCfg:Add({Tag = 2, Name = "Customized events", Icon = 1753, Style = 1})
    self.TagCfg:Add({Tag = 3, Name = "Christmas Events", Icon = 1753, Style = 2})
    self.TagCfg:Add({Tag = 4, Name = "New Year's Day Events", Icon = 1753, Style = 3})
    self.TagCfg:Add({Tag = 5, Name = "Spring Festival activities", Icon = 1753, Style = 4})
    self.TagCfg:Add({Tag = 6, Name = "Valentine's Day Events", Icon = 1753, Style = 5})
    self.TagCfg:Add({Tag = 7, Name = "Water-splashing festival activities", Icon = 1753, Style = 6})
    self.TagCfg:Add({Tag = 8, Name = "The lucky cat", Icon = 1118, Style = 1})
end

function YYHDSystem:UnInitialize()
    for k, v in pairs(self.MainShowIconTable) do
        GameCenter.MainCustomBtnSystem:RemoveBtn(v)
    end
    self.MainShowIconTable = nil
end

-- Refresh activity list data
function YYHDSystem:ResActivityList(msg)
    -- local info = 
    -- {
    --     type = 17001,
    --     actConfig = {
    --         beginTime = 123,
    --         endTime = 123000000000,
    --         minLv = 1,
    --         maxLv = 1000,
    --         tag = 1,
    --         name = "abcdef",
    --         isDelete = 0,
    --         sort = 0,
    --         custom = {
    --                     {
    --                         reward = { 
    --                             {
    --                                 ItemID = 0,
    --                                 ItemCount = 0,
    --                                 Occ = 0,
    --                                 IsBind = false,
    --                             }
    --                         }
    --                     ,
    --                     day = 1,
    --                     limitTimes = 123000000000,
    --                     price = 456,
    --                     currencyType = 1
    --                     }
    --                 },
    --     },
    --     actData = {
    --         day = 1,
    --         alreadyBuy = 10
    --     }
    -- }
    -- msg.actList = {info}
    -- local actData = {
    --     day = 1,
    --     alreadyBuy = 0
    -- }
    self.DataTable = {}
    if msg.actList ~= nil then
        local _count = #msg.actList
        for i = 1, _count do
            local _info = msg.actList[i]
            local _func = function()
                local _data = self:NewData(_info.type)
                if _data == nil then
                    Debug.LogError("Failed to parse the active data, the client did not define type =" .. _info.type)
                else
                    local _cfgTable = Json.decode(_info.actConfig)
                    -- Analyze basic configuration
                    _data:ParseBaseCfgData(_cfgTable)
                    -- Analyze your own configuration
                    local _dataTable = Json.decode(_cfgTable.custom)
                    _data:ParseSelfCfgData(_dataTable)
                    -- Analyze player data
                    local _playerTable = Json.decode(_info.actData)
                    _data:ParsePlayerData(_playerTable)
                    -- Refresh data
                    _data:RefreshData()
                    self.DataTable[_data.TypeId] = _data
                    -- Log
                    Debug.LogError("ResActivityList " .. _data.Name .. " open state = " .. tostring(_data:IsActive()))
                end
            end
            local _result, _error = xpcall(_func, debug.traceback)
            if not _result then
                CSDebug.LogError(_error)
            end
        end
    end
    -- Refresh activity list
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    self.CheckFrame = 0
end

-- Refresh individual activities
function YYHDSystem:ResActivityChange(msg)
    -- Debug.LogError("YYHDSystem:ResActivityChange")
    local _info = msg.act
    if _info == nil then
        return
    end
    local _func = function()
        local _data = self.DataTable[_info.type]
        if _data == nil then
            _data = self:NewData(_info.type)
            if _data == nil then
                Debug.LogError("Failed to parse the active data, the client did not define type =" .. _info.type)
                return
            end
            self.DataTable[_data.TypeId] = _data
        end
        if _info.actConfig ~= nil then
            -- Configuration data is updated
            local _cfgTable = Json.decode(_info.actConfig)
            -- Analyze basic configuration
            _data:ParseBaseCfgData(_cfgTable)
            -- Analyze your own configuration
            local _dataTable = Json.decode(_cfgTable.custom)
            _data:ParseSelfCfgData(_dataTable)

            -- Log
            Debug.LogError("ResActivityChange " .. _data.Name .. " open state = " .. tostring(_data:IsActive()))
        end
        if _info.actData ~= nil then
            -- Custom data has been updated
            local _playerTable = Json.decode(_info.actData)
            _data:ParsePlayerData(_playerTable)
        end
        -- Refresh data
        _data:RefreshData()
    end
    local _result, _error = xpcall(_func, debug.traceback)
    if not _result then
        -- An activity error is reported, delete the activity
        self.DataTable[_info.type] = nil
        CSDebug.LogError(_error)
    end
    -- Refresh activity list
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDLIST)
    -- Refresh an event
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_HDFORM, _info.type)
    self.CheckFrame = 0
end

-- renew
function YYHDSystem:Update()
    self.CheckFrame = self.CheckFrame - 1
    if self.CheckFrame > 0 then
        return
    end
    self.CheckFrame = 60
    if self.OpenTagTable == nil then
        self.OpenTagTable = Dictionary:New()
    end
    if self.RedPointTable == nil then
        self.RedPointTable = Dictionary:New()
    end
    self.OpenTagTable:Clear()
    self.RedPointTable:Clear()
    for _, v in pairs(self.DataTable) do
        if v.IsShowInList then
            local _frontActive = v.ActiveState
            if v:IsActive() then
                self.OpenTagTable[v.Tag] = true
                if v:IsShowRedPoint() then
                    self.RedPointTable[v.Tag] = true
                end
                if not _frontActive then
                    -- Log
                    Debug.LogError("YYHD " .. v.Name .. " has open")
                    -- The function is enabled, request data once
                    self:ReqPlayerData(v.TypeId)
                end
            end
        end
        if v.UpdateActive then
            v:UpdateActive()
        end
    end
    for i = 1, #self.TagCfg do
        local _tagCfg = self.TagCfg[i]
        self:RefreshMainIcon(_tagCfg, self.OpenTagTable[_tagCfg.Tag], self.RedPointTable[_tagCfg.Tag])
    end
end

-- Refresh the main interface icon
function YYHDSystem:RefreshMainIcon(cfg, isShow, showRedPoint)
    -- Debug.LogError("YYHDSystem:RefreshMainIcon")
    local _canNotUse = false
    local _mapCfg = GameCenter.MapLogicSystem.MapCfg
    if _mapCfg ~= nil and _mapCfg.MapType ~= 0 then
        _canNotUse = true
    end
    local _tagId = cfg.Tag
    local _iconId = self.MainShowIconTable[_tagId]
    if isShow and not _canNotUse then
        if _iconId == nil then
            _iconId = GameCenter.MainCustomBtnSystem:AddBtn(cfg.Icon, cfg.Name, _tagId,
            function(btn)
                self:DoOpenHDForm(btn.CustomData)
            end,
            false, showRedPoint, true, 321)
            self.MainShowIconTable[_tagId] = _iconId
        else
            GameCenter.MainCustomBtnSystem:SetShowRedPoint(_iconId, showRedPoint)
        end
    else
        if _iconId ~= nil then
            GameCenter.MainCustomBtnSystem:RemoveBtn(_iconId)
            self.MainShowIconTable[_tagId] = nil
        end
    end
end

-- Create activity data
function YYHDSystem:NewData(typeId)
    -- Debug.LogError("YYHDSystem:NewData typeId = " .. typeId)
    local _cfg = DataConfig.DataActivityYunying[typeId]
    if _cfg == nil then
        return nil
    end
    local _logicId = _cfg.LogicId
    if _logicId == YYHDLogicDefine.HuoYueDuiHuan then-- Active redemption
        return L_ActiveExchangeData:New(typeId)
    elseif _logicId == YYHDLogicDefine.MeiRiChonZhi then-- Daily recharge
        return L_DailyRechargeData:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianShiDenglu then-- Log in with gifts
        return L_LimitTimeLogin:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianGouLiBao then-- Purchase limited gift bag
        return L_XianGouLiBaoData:New(typeId)
    elseif _logicId == YYHDLogicDefine.TianDiBaoKu then-- The Treasure Library of Heavenly Emperor
        return L_TianDiBaoKuData:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianShiLeiChong then-- Accumulated recharge
        return L_XianShiLeiChong:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianShiXiaoHao then-- Limited time consumption
        return L_XianShiXiaoHao:New(typeId)
    elseif _logicId == YYHDLogicDefine.JiWuDuiHuan then-- Collection exchange
        return L_JiWuDuiHuanData:New(typeId)
    elseif _logicId == YYHDLogicDefine.TuanGou then-- Group Purchase
        return L_TuanGou:New(typeId)
    elseif _logicId == YYHDLogicDefine.ZhaoCaiMao then-- The lucky cat
        return L_LuckCat:New(typeId)
    elseif _logicId == YYHDLogicDefine.BossHappy then-- The leader carnival
        return L_BossHappyData:New(typeId)
    elseif _logicId == YYHDLogicDefine.QingDianTask then-- Celebration mission
        return L_QingDianTaskData:New(typeId)
    elseif _logicId == YYHDLogicDefine.JieRiJiZhi then-- Festival collection
        return L_JiZiDuiHuanData:New(typeId)
    elseif _logicId == YYHDLogicDefine.JieRiTeHui then-- Holiday special offer (direct purchase gift package)
        return L_JieRiTeHuiData:New(typeId)
    elseif _logicId == YYHDLogicDefine.LianXuLeiChong then-- Continuous filling
        return L_LianXuLeiChongData:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianShiShangCheng then-- Limited time mall
        return L_XianShiShangChengData:New(typeId)
    elseif _logicId == YYHDLogicDefine.XianShiLiBao then-- Limited time gift bag
        return L_XianShiLiBaoData:New(typeId)
    elseif _logicId == YYHDLogicDefine.JiFenPaiMing then-- Points ranking
        return L_JiFenPaiMingData:New(typeId)
    elseif _logicId == YYHDLogicDefine.JieRiXueYuan then-- Holiday Wishes
        return L_JieRiXueYuanData:New(typeId)
    elseif _logicId == YYHDLogicDefine.FBFenXiang then-- FB Share
        return L_FBFenXiangData:New(typeId)
    elseif _logicId == YYHDLogicDefine.LianXuLeiChong2 then-- Continuously accumulated 2 (purchase directly)
        return L_LianXuLeiChongData2:New(typeId)
    elseif _logicId == YYHDLogicDefine.XinNianZhuFu then-- New Year greetings
        return L_XinChunZhuFuData:New(typeId)
    elseif _logicId == YYHDLogicDefine.ZhiTouZi then-- dice
        return L_RollDiceData:New(typeId)
    elseif _logicId == YYHDLogicDefine.WaiGuanZhanShi then-- Appearance display
        return L_WaiGuanZhanShiData:New(typeId)
    elseif _logicId == YYHDLogicDefine.OnlinePrompt then-- Online tips
        return L_OnlinePromptData:New(typeId)
    elseif _logicId == YYHDLogicDefine.JuBaoPen then-- treasure bowl
        return L_JuBaoPenData:New(typeId)
    elseif _logicId == YYHDLogicDefine.XingYunZaDan then-- Lucky to smash eggs
        return L_XingYunZaDanData:New(typeId)
    elseif _logicId == YYHDLogicDefine.ZhaoCaiMaoBangDing then-- Tie jade to win fortune cat
        return L_LuckCatBYData:New(typeId)
    elseif _logicId == YYHDLogicDefine.FZTB then-- Fang Ze's treasure ​​seeking
        return L_FZTBData:New(typeId)
    end
    return nil
end

-- Request activity custom data. (Certain activities may be required)
function YYHDSystem:ReqPlayerData(reqTypeId)
    GameCenter.Network.Send("MSG_Activity.ReqActivity", {type = reqTypeId, })
end

-- Get the activity list based on the tag
function YYHDSystem:GetHDList(hdTag)
    local _result = List:New()
    for _, v in pairs(self.DataTable) do
        if v.Tag == hdTag and v.IsShowInList then
            _result:Add(v)
        end
    end
    -- Sort
    _result:Sort(function(a, b)
        return a.SortValue < b.SortValue
    end)
    return _result
end

-- Get activity data based on ID
function YYHDSystem:GetHDData(typeId)
    local _result = self.DataTable[typeId]
    return _result
end

-- Get activity data according to type
function YYHDSystem:GetHDListByLogicId(logicId)
    local _result = List:New()
    for _, v in pairs(self.DataTable) do
        if v.UseLogicId == logicId then
            _result:Add(v)
        end
    end
    return _result
end

-- Operation activity return
function YYHDSystem:ResActivityDeal(msg)
    local _hdData = self:GetHDData(msg.type)
    if _hdData == nil then
        return
    end
    local _jsonTable = Json.decode(msg.data)
    -- Each activity is handled by itself
    _hdData:ResActivityDeal(_jsonTable)
end

-- Tag library synchronization
function YYHDSystem:ResTagInfoList(msg)
    self.TagCfg:Clear()
    local _jsonTable = Json.decode(msg.tag)
    for i = 1, #_jsonTable do
        local _data = _jsonTable[i]
        self.TagCfg:Add({Tag = _data.id, Name = _data.name, Icon = tonumber(_data.icon), Style = _data.style})
    end
    -- Refresh the tag library and clear all main interface activities icon
    for k, v in pairs(self.MainShowIconTable) do
        GameCenter.MainCustomBtnSystem:RemoveBtn(v)
    end
    self.MainShowIconTable = {}
    -- Close all active interfaces
    GameCenter.PushFixEvent(UIEventDefine.UIYYHDBaseForm_CLOSE)
    GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDSDBaseForm_CLOSE)
    GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDYDBaseForm_CLOSE)
    GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDCJBaseForm_CLOSE)
    GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDQRJBaseForm_CLOSE)
    GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDPSJBaseForm_CLOSE)
end

-- Open an event
function YYHDSystem:OpenHD(hdId)
    local _hdData = self:GetHDData(hdId)
    if _hdData == nil then
        return
    end
    if not _hdData:IsActive() then
        return
    end
    if _hdData.IsShowInList then
        self:DoOpenHDForm(_hdData.Tag, hdId)
    elseif _hdData.OpenUI ~= nil then
        _hdData:OpenUI()
    end
end

-- Open the activity interface
function YYHDSystem:DoOpenHDForm(tagId, hdId)
    local _cfg = self.TagCfg[tagId]
    if _cfg == nil then
        return
    end
    -- UI style:
    -- 1: Basics
    -- 2: Christmas
    -- 3: New Year's Day
    -- 4: Spring Festival
    -- 5: Valentine's Day
    -- 6: Water Splashing Festival
    if _cfg.Style == 1 then
        GameCenter.PushFixEvent(UIEventDefine.UIYYHDBaseForm_OPEN, {_cfg, hdId})
    elseif _cfg.Style == 2 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDSDBaseForm_OPEN, {_cfg, hdId})
    elseif _cfg.Style == 3 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDYDBaseForm_OPEN, {_cfg, hdId})
    elseif _cfg.Style == 4 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDCJBaseForm_OPEN, {_cfg, hdId})
    elseif _cfg.Style == 5 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDQRJBaseForm_OPEN, {_cfg, hdId})
    elseif _cfg.Style == 6 then
        GameCenter.PushFixEvent(UILuaEventDefine.UIYYHDPSJBaseForm_OPEN, {_cfg, hdId})
    else
        GameCenter.PushFixEvent(UIEventDefine.UIYYHDBaseForm_OPEN, {_cfg, hdId})
    end
end

return YYHDSystem
