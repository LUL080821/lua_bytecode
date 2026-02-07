local MSG_Couplefight = {
    TeamInfo = {
       id = 0,
       name = "",
       roles = List:New(),
    },
    PlayerInfo = {
       id = 0,
       name = "",
       power = 0,
       facade = nil,
       occupation = 0,
       head = nil,
       level = 0,
    },
    FightPlayer = {
       id = 0,
       camp = 0,
    },
    RankAward = {
       rid = List:New(),
       rank = 0,
    },
    TrialsAward = {
       id = 0,
       awardId = List:New(),
    },
    ReqTrialsInfo = {
    },
    ReqApply = {
       name = "",
    },
    ReqApplyConfirm = {
       confirm = false,
    },
    ReqMatchStart = {
    },
    ReqMatchStop = {
    },
    ReqMatchConfirm = {
       confirm = false,
    },
    ReqGetAward = {
       id = 0,
    },
    ReqTrialsRank = {
    },
    TrialsInfo = {
       count = 0,
       rate = 0,
       rank = 0,
       score = 0,
       getAwards = List:New(),
    },
    TrialsRankInfo = {
       team = {
            id = 0,
            name = "",
            roles = List:New(),
        },

       trials = {
            count = 0,
            rate = 0,
            rank = 0,
            score = 0,
            getAwards = List:New(),
        },

    },
    ReqGroupsInfo = {
    },
    ReqGroupsRank = {
       groupId = 0,
    },
    ReqGroupPrepareMapEnter = {
    },
    Group = {
       id = 0,
       team = List:New(),
    },
    GroupTeam = {
       teamId = 0,
       rank = 0,
       score = 0,
       rate = 0,
    },
    ReqChampionInfo = {
       type = 0,
    },
    ReqChampionGuessInfo = {
       type = 0,
       fightId = 0,
    },
    ReqChampionGuess = {
       type = 0,
       fightId = 0,
       teamId = 0,
    },
    ReqChampionGuessUpdate = {
       type = 0,
       fightId = 0,
    },
    ReqChampionGuessWatching = {
       type = 0,
       fightId = 0,
    },
    ReqChampionTeamList = {
       type = 0,
    },
    ReqChampionFansRankList = {
    },
    ReqChampionEnter = {
    },
    ChampionRound = {
       groups = List:New(),
    },
    ChampionGroup = {
       t1 = nil,
       t2 = nil,
       id = 0,
    },
    ChampionTeam = {
       team = nil,
       number = 0,
       type = 0,
    },
    GuessInfo = {
       g1 = nil,
       g2 = nil,
       fightId = 0,
    },
    GuessTeamInfo = {
       rate = 0,
       gold = 0,
       winGold = 0,
       loseGold = 0,
       guess = false,
       teamId = 0,
    },
    FansInfo = {
       rank = 0,
       name = "",
       level = 0,
       power = 0,
       money = 0,
    },
    GuessResult = {
       rid = 0,
       win = false,
       itemType = 0,
       itemNum = 0,
    },
    ReqEnterCoupleEscort = {
       type = 0,
    },
    ReqCoupleEscortOver = {
    },
    EscortReward = {
       id = 0,
       num = 0,
    },
    CoupleShopData = {
       id = 0,
       count = 0,
    },
    ReqBuyCoupleItem = {
       id = 0,
    },
    ReqOpenCoupleShop = {
    },
}
local L_StrDic = {
    [MSG_Couplefight.ReqTrialsInfo] = "MSG_Couplefight.ReqTrialsInfo",
    [MSG_Couplefight.ReqApply] = "MSG_Couplefight.ReqApply",
    [MSG_Couplefight.ReqApplyConfirm] = "MSG_Couplefight.ReqApplyConfirm",
    [MSG_Couplefight.ReqMatchStart] = "MSG_Couplefight.ReqMatchStart",
    [MSG_Couplefight.ReqMatchStop] = "MSG_Couplefight.ReqMatchStop",
    [MSG_Couplefight.ReqMatchConfirm] = "MSG_Couplefight.ReqMatchConfirm",
    [MSG_Couplefight.ReqGetAward] = "MSG_Couplefight.ReqGetAward",
    [MSG_Couplefight.ReqTrialsRank] = "MSG_Couplefight.ReqTrialsRank",
    [MSG_Couplefight.ReqGroupsInfo] = "MSG_Couplefight.ReqGroupsInfo",
    [MSG_Couplefight.ReqGroupsRank] = "MSG_Couplefight.ReqGroupsRank",
    [MSG_Couplefight.ReqGroupPrepareMapEnter] = "MSG_Couplefight.ReqGroupPrepareMapEnter",
    [MSG_Couplefight.ReqChampionInfo] = "MSG_Couplefight.ReqChampionInfo",
    [MSG_Couplefight.ReqChampionGuessInfo] = "MSG_Couplefight.ReqChampionGuessInfo",
    [MSG_Couplefight.ReqChampionGuess] = "MSG_Couplefight.ReqChampionGuess",
    [MSG_Couplefight.ReqChampionGuessUpdate] = "MSG_Couplefight.ReqChampionGuessUpdate",
    [MSG_Couplefight.ReqChampionGuessWatching] = "MSG_Couplefight.ReqChampionGuessWatching",
    [MSG_Couplefight.ReqChampionTeamList] = "MSG_Couplefight.ReqChampionTeamList",
    [MSG_Couplefight.ReqChampionFansRankList] = "MSG_Couplefight.ReqChampionFansRankList",
    [MSG_Couplefight.ReqChampionEnter] = "MSG_Couplefight.ReqChampionEnter",
    [MSG_Couplefight.ReqEnterCoupleEscort] = "MSG_Couplefight.ReqEnterCoupleEscort",
    [MSG_Couplefight.ReqCoupleEscortOver] = "MSG_Couplefight.ReqCoupleEscortOver",
    [MSG_Couplefight.ReqBuyCoupleItem] = "MSG_Couplefight.ReqBuyCoupleItem",
    [MSG_Couplefight.ReqOpenCoupleShop] = "MSG_Couplefight.ReqOpenCoupleShop",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_Couplefight

