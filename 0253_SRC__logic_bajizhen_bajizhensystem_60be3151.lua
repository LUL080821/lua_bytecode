------------------------------------------------
-- Author:
-- Date: 2019-09-23
-- File: BaJiZhenSystem.lua
-- Module: BaJiZhenSystem
-- Description: Level 8 array diagram system script
------------------------------------------------
-- Quote
local BaJiJuDianData = require "Logic.BaJiZhen.BaJiJuDianData"
local BaJiRankData = require "Logic.BaJiZhen.BaJiRankData"
local BaJiZhenSystem = {
    -- Server id of this server
    OwnServerId = 0,
    -- The server name
    OwnServerName = nil,
    -- The color Id assigned by this server
    CurServerColId = 0,
    -- The current entry point Id
    CurJuDianId = 0,
    -- Point data list
    ListJuDianData = List:New(),
    -- Progress of the Point
    ListJinDu = List:New(),
    -- Ranking data
    OwnFightRankData = nil,
    OwnSaiJiRankData = nil,
    ListFightRankData = List:New(),
    ListSaiJiRankData = List:New(),
    -- Colors corresponding to each server
    DicColorServer = Dictionary:New(),
    DicColorServerId = Dictionary:New(),
    -- Remaining time for copy
    LeftTime = -1,
    MatchLv = 0,
    MatchServerNum = 0,
    IsOpen = false,
    LineEffectTick = 0,

    ListFightRankReward = List:New(),
    ListSaiJiRankReward = List:New(),
}

local L_JinDuData = {
    Name = nil,
    Level = 0
}

function BaJiZhenSystem:Initialize()
    DataConfig.DataEightCity:Foreach(function(k, v)
        local juDianData = BaJiJuDianData:New(k)
        self.ListJuDianData:Add(juDianData)
    end)

    DataConfig.DataEightCityReward:Foreach(function(k, v)
        if v.Type == 1 then
            local rankInfo1 = BaJiRankData:New()
            local _msg = {
                name = DataConfig.DataMessageString.Get("C_STCZ_NOTOWNER"),
                integral = 0,
                colorCamp = 0,
                serverid = 0
            }
            rankInfo1:Parase(_msg, k, BaJiRankType.FightRank)
            self.ListFightRankReward:Add(rankInfo1)
        elseif v.Type == 2 then
            local rankInfo1 = BaJiRankData:New()
            local _msg = {
                name = DataConfig.DataMessageString.Get("C_STCZ_NOTOWNER"),
                integral = 0,
                colorCamp = 0,
                serverid = 0
            }
            rankInfo1:Parase(_msg, k - 100 , BaJiRankType.SaiJiRank)
            self.ListSaiJiRankReward:Add(rankInfo1)
        end
    end)

end

-- Get the base data through the base id
function BaJiZhenSystem:GetJuDianDataById(id)
    if id <= #self.ListJuDianData then
        return self.ListJuDianData[id]
    end
    return nil
end

-- Get the base data through the base cfgId
function BaJiZhenSystem:GetJuDianDataByCfgId(cfgId)
    for i = 1, #self.ListJuDianData do
        if self.ListJuDianData[i].CfgId == cfgId then
            return self.ListJuDianData[i]
        end
    end
end

-- Get progress data
function BaJiZhenSystem:GetJinDuList()
    return self.ListJinDu
end

-- Get progress data
function BaJiZhenSystem:GetJinDuDataByIndex(index)
    if index <= #self.ListJinDu then
        return self.ListJinDu[index].Name, self.ListJinDu[index].Level
    end
end

-- Set progress data
function BaJiZhenSystem:SetJinDuData(msg)
    if msg == nil then
        return
    end
    self.ListJinDu:Clear()
    local cfg = DataConfig.DataDaily[106]
    local key1 = 0
    local key2 = 0
    local level1 = 0
    local level2 = 0
    local list = nil
    local list_4 = nil
    local list_8 = nil
    if cfg ~= nil then
        list = Utils.SplitStr(cfg.CrossMatch, ';')
        list_4 = Utils.SplitStr(list[1], '_')
        list_8 = Utils.SplitStr(list[2], '_')
        key1 = tonumber(list_8[1])
        level1 = tonumber(list_8[2])
        key2 = tonumber(list_4[1])
        level2 = tonumber(list_4[2])
        local infos = msg.serverMatch_4
        local useLarge = true
        local valList = List:New()
        for i = 1, #infos do
            local _openDay = Time.GetOpenSeverDayByOpenTime(infos[i].openTime * 0.001)
            if _openDay < level2 then
                if useLarge then
                    useLarge = false
                end
            else
                valList:Add(i)
            end
            local sdata = GameCenter.ServerListSystem:FindServer(infos[i].serverid)
            if sdata ~= nil then
                local name = UIUtils.CSFormat("S{0}_{1}", sdata.ShowServerId, sdata.Name)
                local tab = {
                    Name = name,
                    Level = _openDay
                }
                self.ListJinDu:Add(tab)
            end
        end
        if not useLarge then
            if #valList < 4 then
                self.MatchServerNum = key2
                self.MatchLv = level2
            else
                self.MatchServerNum = key1
                self.MatchLv = level1
            end
        else
            if #valList >= 4 then
                self.ListJinDu:Clear()
                self.MatchServerNum = key1
                self.MatchLv = level1
                for i = 1, #msg.serverMatch_8 do
                    local sdata = GameCenter.ServerListSystem:FindServer(msg.serverMatch_8[i].serverid)
                    if sdata ~= nil then
                        local name = UIUtils.CSFormat("S{0}_{1}", sdata.ShowServerId, sdata.Name)
                        local tab = {
                            Name = name,
                            Level = Time.GetOpenSeverDayByOpenTime(msg.serverMatch_8[i].openTime * 0.001)--msg.serverMatch_8[i].serverWroldLv
                        }
                        self.ListJinDu:Add(tab)
                    end
                end
            else
                self.MatchServerNum = key2
                self.MatchLv = level2
            end
        end
        local visable = #valList >= 4
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.BaJiZhen, visable)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BAJIZHEN_OPEN_JINDU)
end

-- Get ranking data
function BaJiZhenSystem:GetRankDataListByType(rankType)
    if rankType == BaJiRankType.FightRank then
        return self.ListFightRankData
    elseif rankType == BaJiRankType.SaiJiRank then
        return self.ListSaiJiRankData
    end
end

-- Get ranking data
function BaJiZhenSystem:GetRankDataByIndex(index, rankType)
    local list = nil
    if rankType == BaJiRankType.FightRank then
        list = self.ListFightRankData
    elseif rankType == BaJiRankType.SaiJiRank then
        list = self.ListSaiJiRankData
    end
    if index <= #list then
        return list[index]
    end
end

function BaJiZhenSystem:GetOwnRankData(rankType)
    if rankType == BaJiRankType.FightRank then
        return self.OwnFightRankData
    elseif rankType == BaJiRankType.SaiJiRank then
        return self.OwnSaiJiRankData
    end
end

-- Get server name by color
function BaJiZhenSystem:GetServerNameByColor(color)
    if self.DicColorServer:ContainsKey(color) then
        return self.DicColorServer[color]
    end
    return nil
end

-- Enter the base copy
function BaJiZhenSystem:EnterJuDian(cfgId)
    self.CurJuDianId = cfgId
    self:ReqEnterEightCityMap(cfgId)
end

-- Return to your ranking
function BaJiZhenSystem:GetOwnFightRankData()
    return self.OwnFightRankData
end

-- Get color string
function BaJiZhenSystem:GetColorStr(color)
    local ret = nil
    if color == BaJiColor.Color_0 then
        ret = "#f0ee51"
    elseif color == BaJiColor.Color_1 then
        ret = "#b1ff48"
    elseif color == BaJiColor.Color_2 then
        ret = "#15bd32"
    elseif color == BaJiColor.Color_3 then
        ret = "#29f2e2"
    elseif color == BaJiColor.Color_4 then
        ret = "#ffa42a"
    elseif color == BaJiColor.Color_5 then
        ret = "#9c3dde"
    elseif color == BaJiColor.Color_6 then
        ret = "#dc3a28"
    elseif color == BaJiColor.Color_7 then
        ret = "#6976ff"
    end
    return ret
end

function BaJiZhenSystem:GetColorStrFormat(color)
    local ret = nil
    if color == BaJiColor.Color_0 then
        ret = "[f0ee51]{0}[-]"
    elseif color == BaJiColor.Color_1 then
        ret = "[b1ff48]{0}[-]"
    elseif color == BaJiColor.Color_2 then
        ret = "[15bd32]{0}[-]"
    elseif color == BaJiColor.Color_3 then
        ret = "[29f2e2]{0}[-]"
    elseif color == BaJiColor.Color_4 then
        ret = "[ffa42a]{0}[-]"
    elseif color == BaJiColor.Color_5 then
        ret = "[9c3dde]{0}[-]"
    elseif color == BaJiColor.Color_6 then
        ret = "[dc3a28]{0}[-]"
    elseif color == BaJiColor.Color_7 then
        ret = "[6976ff]{0}[-]"
    end
    return ret
end

function BaJiZhenSystem:GetFlagName(color)
    local ret = nil
    if color == BaJiColor.Color_0 then
        ret = "n_z_117_19"
    elseif color == BaJiColor.Color_1 then
        ret = "n_z_117_20"
    elseif color == BaJiColor.Color_2 then
        ret = "n_z_117_21"
    elseif color == BaJiColor.Color_3 then
        ret = "n_z_117_22"
    elseif color == BaJiColor.Color_4 then
        ret = "n_z_117_23"
    elseif color == BaJiColor.Color_5 then
        ret = "n_z_117_24"
    elseif color == BaJiColor.Color_6 then
        ret = "n_z_117_25"
    elseif color == BaJiColor.Color_7 then
        ret = "n_z_117_26"
    end
    return ret
end

---------------------------------------------msg-------------------------------------------------
-- Open the Bagua Formation page
function BaJiZhenSystem:ReqEightDiagramsPanel()
    GameCenter.Network.Send("MSG_EightDiagrams.ReqEightDiagramsPanel")
end

-- Return to open the Eight-Pole Array Diagram Interface
function BaJiZhenSystem:ResEightDiagramsPanel(result)
    if result == nil then
        return
    end
    self.IsOpen = result.isopen
    self.CurServerColId = result.selfCamp
    self.OwnServerId = result.selfSid
    local sdata = GameCenter.ServerListSystem:FindServer(result.selfSid)
    if sdata ~= nil then
        self.OwnServerName = UIUtils.CSFormat("S{0}_{1}", sdata.ShowServerId, sdata.Name)
    end
    if result.cityListInfo == nil then
        return
    end
    for i = 1, #result.cityListInfo do
        local juDianData = self:GetJuDianDataByCfgId(result.cityListInfo[i].cityID)
        juDianData:Parase(result.cityListInfo[i])
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_BAJIZHENTU_OPEN_RESULT)
end

-- Request to open the ranking interface
function BaJiZhenSystem:ReqRankPanel()
    GameCenter.Network.Send("MSG_EightDiagrams.ReqRankPanel")
end

-- Return to open ranking list
function BaJiZhenSystem:ResRankPanel(result)
    if result == nil then
        return
    end
    self.ListFightRankData:Clear()
    self.ListSaiJiRankData:Clear()
    if result.curRankInfoList ~= nil then
        for i = 1, #result.curRankInfoList do
            local rankInfo1 = BaJiRankData:New()
            rankInfo1:Parase(result.curRankInfoList[i], i, BaJiRankType.FightRank)
            self.ListFightRankData:Add(rankInfo1)
        end
    end
    if result.seasonRankInfoList ~= nil then
        for i = 1, #result.seasonRankInfoList do
            local rankInfo2 = BaJiRankData:New()
            rankInfo2:Parase(result.seasonRankInfoList[i], i, BaJiRankType.SaiJiRank)
            self.ListSaiJiRankData:Add(rankInfo2)
        end
    end
    if self.OwnFightRankData == nil then
        self.OwnFightRankData = BaJiRankData:New()
    end
    if result.selfCurRankInfo ~= nil then
        self.OwnFightRankData:Parase(result.selfCurRankInfo, result.selfCurRankInfo.rank, BaJiRankType.FightRank)
    else
        self.OwnFightRankData.Rank = -1
    end

    if self.OwnSaiJiRankData == nil then
        self.OwnSaiJiRankData = BaJiRankData:New()
    end
    if result.selfSeasonRankInfo ~= nil then
        self.OwnSaiJiRankData:Parase(result.selfSeasonRankInfo, result.selfSeasonRankInfo.rank, BaJiRankType.SaiJiRank)
    else
        self.OwnSaiJiRankData.Rank = -1
    end
    GameCenter.PushFixEvent(UIEventDefine.UIBaJiZhenRankForm_Open)
end

-- Request to enter the city
function BaJiZhenSystem:ReqEnterEightCityMap(id)
    GameCenter.Network.Send("MSG_EightDiagrams.ReqEnterEightCityMap", {
        cityID = id
    })
end

-- tick message
function BaJiZhenSystem:ReqTickMapInfo(id)
    GameCenter.Network.Send("MSG_EightDiagrams.ReqTickMapInfo", {
        cityID = id
    })
end

-- Return tick message
function BaJiZhenSystem:ResTickMapInfo(result)
    if result == nil then
        return
    end
    self.OwnServerId = GameCenter.ServerListSystem.LastEnterServer.ReallyServerId
    self.CurServerColId = result.selfCamp
    -- Update the base information
    local juDianData = self:GetJuDianDataByCfgId(result.curCityInfo.cityID)
    if juDianData ~= nil then
        juDianData:Parase(result.curCityInfo)
        self.CurJuDianId = result.curCityInfo.cityID
    end
    -- Update ranking information
    if result.curRankInfoList ~= nil then
        for i = 1, #self.ListFightRankData do
            self.ListFightRankData[i]:Clear()
        end
        for i = 1, #result.curRankInfoList do
            local rankInfo = nil
            if i > #self.ListFightRankData then
                rankInfo = BaJiRankData:New()
                self.ListFightRankData:Add(rankInfo)
            else
                rankInfo = self.ListFightRankData[i]
            end
            rankInfo:Parase(result.curRankInfoList[i], i, BaJiRankType.FightRank)
        end
    end
    self.ListFightRankData:Sort(function(a, b)
        return a.Rank < b.Rank
    end)
    if self.OwnFightRankData == nil then
        self.OwnFightRankData = BaJiRankData:New()
    end
    if result.selfRankInfo ~= nil then
        self.OwnFightRankData:Parase(result.selfRankInfo, result.selfRankInfo.rank, BaJiRankType.FightRank)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_BAJIZHENCOPY_INFO)
end

function BaJiZhenSystem:ResLastTime(result)
    if result == nil then
        return
    end
    self.LeftTime = result.seconds
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_BAJIZHENCOPY_TIME, result.seconds)
end
---------------------------------------------msg-------------------------------------------------

return BaJiZhenSystem
