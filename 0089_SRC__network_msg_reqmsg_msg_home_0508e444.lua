local MSG_Home = {
    Vector3 = {
       x = nil,
       y = nil,
       z = nil,
    },
    Furniture = {
       modelId = 0,
       count = 0,
    },
    FurnitureCell = {
       id = nil,
       modelId = nil,
       pos = nil,
       dir = nil,
    },
    HomeRole = {
       id = 0,
       name = "",
       career = 0,
       level = 0,
       serverId = 0,
       sign = nil,
       score = nil,
       head = nil,
    },
    HomeVisitor = {
       role = {
            id = 0,
            name = "",
            career = 0,
            level = 0,
            serverId = 0,
            sign = nil,
            score = nil,
            head = nil,
        },

       time = 0,
       gift = nil,
       energy = nil,
    },
    VisitorGift = {
       id = 0,
       max = 0,
       use = 0,
    },
    HomeInfo = {
       owner = {
            id = 0,
            name = "",
            career = 0,
            level = 0,
            serverId = 0,
            sign = nil,
            score = nil,
            head = nil,
        },

       level = 0,
       tupLevel = nil,
       tupExp = nil,
       tupReward = nil,
       tupRewardExp = nil,
       store = List:New(),
       cells = List:New(),
    },
    TaskInfo = {
       id = 0,
       process = 0,
       state = 0,
    },
    HomeGoods = {
       goodsId = 0,
       remain = 0,
    },
    ReqHomeInfo = {
       roleId = 0,
    },
    ReqAuthHomePem = {
       authUnFriendEnter = false,
       authUnFriendOpt = false,
       helper = nil,
    },
    ReqEnterHome = {
       roleId = 0,
    },
    ReqHomeVisitorNote = {
       roleId = 0,
    },
    ReqHomeVisitorGiftList = {
       roleId = 0,
    },
    ReqSendVisitorGift = {
       roleId = 0,
       giftId = 0,
    },
    ReqHomeTrimRank = {
    },
    ReqHomeTrimMatchScore = {
    },
    ReqRandomHomeTrimTarget = {
    },
    ReqHomeTrimVote = {
       type = 0,
       roleId = nil,
    },
    ReqHomeDecorate = {
       type = 0,
       targetId = 0,
       id = nil,
       modelId = nil,
       dir = nil,
       x = nil,
       y = nil,
       z = nil,
    },
    ReqHomeLevelUp = {
       curLevel = 0,
    },
    ReqGetTupReward = {
    },
    ReqTaskList = {
    },
    ReqTaskReward = {
       id = 0,
    },
    ReqHomeShop = {
    },
    ReqHomeBuy = {
       goods = 0,
       count = 0,
    },
}
local L_StrDic = {
    [MSG_Home.ReqHomeInfo] = "MSG_Home.ReqHomeInfo",
    [MSG_Home.ReqAuthHomePem] = "MSG_Home.ReqAuthHomePem",
    [MSG_Home.ReqEnterHome] = "MSG_Home.ReqEnterHome",
    [MSG_Home.ReqHomeVisitorNote] = "MSG_Home.ReqHomeVisitorNote",
    [MSG_Home.ReqHomeVisitorGiftList] = "MSG_Home.ReqHomeVisitorGiftList",
    [MSG_Home.ReqSendVisitorGift] = "MSG_Home.ReqSendVisitorGift",
    [MSG_Home.ReqHomeTrimRank] = "MSG_Home.ReqHomeTrimRank",
    [MSG_Home.ReqHomeTrimMatchScore] = "MSG_Home.ReqHomeTrimMatchScore",
    [MSG_Home.ReqRandomHomeTrimTarget] = "MSG_Home.ReqRandomHomeTrimTarget",
    [MSG_Home.ReqHomeTrimVote] = "MSG_Home.ReqHomeTrimVote",
    [MSG_Home.ReqHomeDecorate] = "MSG_Home.ReqHomeDecorate",
    [MSG_Home.ReqHomeLevelUp] = "MSG_Home.ReqHomeLevelUp",
    [MSG_Home.ReqGetTupReward] = "MSG_Home.ReqGetTupReward",
    [MSG_Home.ReqTaskList] = "MSG_Home.ReqTaskList",
    [MSG_Home.ReqTaskReward] = "MSG_Home.ReqTaskReward",
    [MSG_Home.ReqHomeShop] = "MSG_Home.ReqHomeShop",
    [MSG_Home.ReqHomeBuy] = "MSG_Home.ReqHomeBuy",
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

return MSG_Home

