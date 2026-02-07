------------------------------------------------
-- Author: 
-- Date: 2021-06-15
-- File: DecorateSystem.lua
-- Module: DecorateSystem
-- Description: Home improvement competition system
------------------------------------------------

-- //Module definition
local DecorateSystem =
{
    RankCfgDict = nil,
    -- Ranking data
    RankDataDict = nil,
    -- Random vote count remaining
    RandomScore = 0,
    -- Remaining vote count
    Score = 0,
}

-- //Member function definition
-- initialization
function DecorateSystem:Initialize()
    self.RankCfgDict = Dictionary:New()
    self.RankDataDict = Dictionary:New()
    local _nowTime = CS.System.DateTime.Now
    local _curDay = _nowTime.Day
    DataConfig.DataSocialHouseRank:Foreach(
        function(_id, _cfg)
            local _turn = _cfg.Turn
            if _turn == 1 and _curDay < 15 then
                self.RankCfgDict:Add(_id ,_cfg)
            else
                self.RankCfgDict:Add(_id ,_cfg)
            end
        end
    )
end

-- De-initialization
function DecorateSystem:UnInitialize()
    self.RankCfgDict:Clear()
    self.RankDataDict:Clear()
end

-- Home Decoration Competition Ranking
function DecorateSystem:ResHomeTrimRank(msg)
    -- Ranking
    local _rankList = List:New()
    if msg.rank ~= nil then
        for i = 0, #msg.rank do
            _rankList:Add(msg.rank[i])
        end
    end
    _rankList:Sort(
        function(x, y)
            return x.score > y.score
        end
    )
    for _rank = 1,#_rankList do
        local _rankRole = _rankList[_rank]
        local _rankData = {
            Rank = _rank,
            RankSData = _rankRole,
            CfgData = nil,
        }
        self.RankCfgDict:ForeachCanBreak(
            function(_id, _cfg)
                local _ranks = Utils.SplitNumber(_cfg.Rank, '_')
                if _rank >= _ranks[1] and _rank <= _ranks[2] then
                    _rankData.CfgData = _cfg
                    return true
                end
            end
        )
        self.RankDataDict[_rank] = _rankData
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DECORATE_MAIN_DATA)
end

-- Return to the voting data of the home improvement contest
function DecorateSystem:ResHomeTrimMatchScore(msg)
    -- Random vote count
    self.RandomScore = msg.randomScore
    -- Normal vote count
    self.Score = msg.score
    -- Request random data again
    local _msg = ReqMsg.MSG_Home.ReqRandomHomeTrimTarget:New()
    _msg:Send()
end

-- Return to the voting object
function DecorateSystem:ResRandomHomeTrimTarget(msg)
    local _homeList = msg.homeList
    if _homeList ~= nil then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DECORATE_RANDOM_VOTE, _homeList)
    end
end

return DecorateSystem
