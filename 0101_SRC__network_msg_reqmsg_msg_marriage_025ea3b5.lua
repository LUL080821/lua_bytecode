local MSG_Marriage = {
    MarryDeclaration = {
       roleId = 0,
       name = "",
       level = 0,
       vip = 0,
       career = 0,
       declarationId = 0,
       guildId = 0,
       friend = nil,
       head = nil,
       online = nil,
    },
    MarryRole = {
       id = 0,
       name = nil,
       career = nil,
       head = nil,
    },
    MarryClone = {
       remainTimes = 0,
       remainBuy = 0,
    },
    MarryBox = {
       role = 0,
       reward = 0,
       onceReward = 0,
       remainTime = 0,
    },
    MarryChild = {
       id = 0,
       name = nil,
       level = 0,
       exp = 0,
       isActive = false,
       battle = nil,
    },
    WeddingData = {
       timeStart = 0,
       marrayName = "",
       beMarrayName = "",
       marrayCareer = 0,
       beMarrayCareer = 0,
       marryId = 0,
       bemMarryId = 0,
       marryHead = nil,
       beMarryHead = nil,
    },
    WeddingMember = {
       roleId = 0,
       name = "",
    },
    ReqGetMarried = {
       type = 0,
       beMarrayId = 0,
       isNotice = false,
       notice = "",
    },
    ReqDealMarryPropose = {
       isAgree = false,
       marrayId = 0,
    },
    ReqSelectWedding = {
       timeStart = 0,
    },
    ReqMarryData = {
    },
    ReqDivorce = {
       type = 0,
    },
    ReqAffirmDivorce = {
       opt = nil,
    },
    ReqDemandInvit = {
       timeStart = 0,
    },
    ReqInvit = {
       roleId = 0,
       type = 0,
    },
    ReqAgreeInvit = {
       roleId = 0,
       isAgree = false,
    },
    ReqPurInvitNum = {
    },
    ReqMarryCopyBuy = {
       id = 0,
       num = 0,
    },
    ReqMarryUseItem = {
       id = 0,
    },
    ReqMarrySendItem = {
       index = 0,
       roleId = 0,
    },
    ReqMarrySendBulletScreen = {
       context = "",
    },
    ReqMarryBlessList = {
    },
    BlessData = {
       sendName = "",
       receiveName = "",
       itemID = 0,
       num = 0,
    },
    ReqRewardTitle = {
       id = 0,
    },
    ReqUpgradeMarryLock = {
       oneKey = 0,
       itemId = nil,
    },
    ReqBuyMarryBox = {
    },
    ReqCallBuyMarryBox = {
    },
    ReqMarryBoxReward = {
       type = nil,
    },
    ReqRefuseBuyMarryBox = {
    },
    ReqOpenMarryChild = {
       childId = 0,
    },
    ReqUpgradeMarryChild = {
       childId = 0,
       itemId = nil,
       oneKey = 0,
    },
    ReqMarryChildChangeName = {
       childId = 0,
       name = "",
    },
    ReqCallMarryCloneBuy = {
    },
    ReqMarryCloneBuy = {
    },
    ReqRefuseMarryCloneBuy = {
    },
    ReqSelectMarryCloneImg = {
       imgId = 0,
    },
    ReqMarryWallReward = {
    },
    ReqPushMarryDeclaration = {
       declarationId = 0,
    },
    ReqMarryWallDeclaration = {
    },
    ReqMarryAddFriend = {
       roleId = 0,
    },
    ReqMarryAddFriendOpt = {
       roleId = 0,
       opt = 0,
    },
    ReqChildCall = {
       childId = 0,
       opt = 0,
    },
    ReqMarryTask = {
    },
    ReqMarryTaskReward = {
       taskId = 0,
    },
    ReqMarryActivityShopBuy = {
       shopId = 0,
    },
    MarryActivityShopInfo = {
       shopId = 0,
       buyCount = 0,
    },
    ReqMarryActivityIntimacy = {
    },
    ReqMarryActivityIntimacyReward = {
       id = 0,
    },
    MarryActivityTaskData = {
       taskID = 0,
       progress = 0,
       state = false,
    },
    ReqGetMarryActivityTaskReward = {
       taskID = 0,
    },
    ReqMarryCopyBuyHot = {
    },
    ReqMarryCopySign = {
    },
    ReqMarryBless = {
       marryId = 0,
    },
}
local L_StrDic = {
    [MSG_Marriage.ReqGetMarried] = "MSG_Marriage.ReqGetMarried",
    [MSG_Marriage.ReqDealMarryPropose] = "MSG_Marriage.ReqDealMarryPropose",
    [MSG_Marriage.ReqSelectWedding] = "MSG_Marriage.ReqSelectWedding",
    [MSG_Marriage.ReqMarryData] = "MSG_Marriage.ReqMarryData",
    [MSG_Marriage.ReqDivorce] = "MSG_Marriage.ReqDivorce",
    [MSG_Marriage.ReqAffirmDivorce] = "MSG_Marriage.ReqAffirmDivorce",
    [MSG_Marriage.ReqDemandInvit] = "MSG_Marriage.ReqDemandInvit",
    [MSG_Marriage.ReqInvit] = "MSG_Marriage.ReqInvit",
    [MSG_Marriage.ReqAgreeInvit] = "MSG_Marriage.ReqAgreeInvit",
    [MSG_Marriage.ReqPurInvitNum] = "MSG_Marriage.ReqPurInvitNum",
    [MSG_Marriage.ReqMarryCopyBuy] = "MSG_Marriage.ReqMarryCopyBuy",
    [MSG_Marriage.ReqMarryUseItem] = "MSG_Marriage.ReqMarryUseItem",
    [MSG_Marriage.ReqMarrySendItem] = "MSG_Marriage.ReqMarrySendItem",
    [MSG_Marriage.ReqMarrySendBulletScreen] = "MSG_Marriage.ReqMarrySendBulletScreen",
    [MSG_Marriage.ReqMarryBlessList] = "MSG_Marriage.ReqMarryBlessList",
    [MSG_Marriage.ReqRewardTitle] = "MSG_Marriage.ReqRewardTitle",
    [MSG_Marriage.ReqUpgradeMarryLock] = "MSG_Marriage.ReqUpgradeMarryLock",
    [MSG_Marriage.ReqBuyMarryBox] = "MSG_Marriage.ReqBuyMarryBox",
    [MSG_Marriage.ReqCallBuyMarryBox] = "MSG_Marriage.ReqCallBuyMarryBox",
    [MSG_Marriage.ReqMarryBoxReward] = "MSG_Marriage.ReqMarryBoxReward",
    [MSG_Marriage.ReqRefuseBuyMarryBox] = "MSG_Marriage.ReqRefuseBuyMarryBox",
    [MSG_Marriage.ReqOpenMarryChild] = "MSG_Marriage.ReqOpenMarryChild",
    [MSG_Marriage.ReqUpgradeMarryChild] = "MSG_Marriage.ReqUpgradeMarryChild",
    [MSG_Marriage.ReqMarryChildChangeName] = "MSG_Marriage.ReqMarryChildChangeName",
    [MSG_Marriage.ReqCallMarryCloneBuy] = "MSG_Marriage.ReqCallMarryCloneBuy",
    [MSG_Marriage.ReqMarryCloneBuy] = "MSG_Marriage.ReqMarryCloneBuy",
    [MSG_Marriage.ReqRefuseMarryCloneBuy] = "MSG_Marriage.ReqRefuseMarryCloneBuy",
    [MSG_Marriage.ReqSelectMarryCloneImg] = "MSG_Marriage.ReqSelectMarryCloneImg",
    [MSG_Marriage.ReqMarryWallReward] = "MSG_Marriage.ReqMarryWallReward",
    [MSG_Marriage.ReqPushMarryDeclaration] = "MSG_Marriage.ReqPushMarryDeclaration",
    [MSG_Marriage.ReqMarryWallDeclaration] = "MSG_Marriage.ReqMarryWallDeclaration",
    [MSG_Marriage.ReqMarryAddFriend] = "MSG_Marriage.ReqMarryAddFriend",
    [MSG_Marriage.ReqMarryAddFriendOpt] = "MSG_Marriage.ReqMarryAddFriendOpt",
    [MSG_Marriage.ReqChildCall] = "MSG_Marriage.ReqChildCall",
    [MSG_Marriage.ReqMarryTask] = "MSG_Marriage.ReqMarryTask",
    [MSG_Marriage.ReqMarryTaskReward] = "MSG_Marriage.ReqMarryTaskReward",
    [MSG_Marriage.ReqMarryActivityShopBuy] = "MSG_Marriage.ReqMarryActivityShopBuy",
    [MSG_Marriage.ReqMarryActivityIntimacy] = "MSG_Marriage.ReqMarryActivityIntimacy",
    [MSG_Marriage.ReqMarryActivityIntimacyReward] = "MSG_Marriage.ReqMarryActivityIntimacyReward",
    [MSG_Marriage.ReqGetMarryActivityTaskReward] = "MSG_Marriage.ReqGetMarryActivityTaskReward",
    [MSG_Marriage.ReqMarryCopyBuyHot] = "MSG_Marriage.ReqMarryCopyBuyHot",
    [MSG_Marriage.ReqMarryCopySign] = "MSG_Marriage.ReqMarryCopySign",
    [MSG_Marriage.ReqMarryBless] = "MSG_Marriage.ReqMarryBless",
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

return MSG_Marriage

