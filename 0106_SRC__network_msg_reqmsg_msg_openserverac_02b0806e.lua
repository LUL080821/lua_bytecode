local MSG_OpenServerAc = {
    PersonalRevel = {
       id = 0,
       state = 0,
    },
    OpenServerRevel = {
       id = 0,
       rank = 0,
       curValue = 0,
       pList = List:New(),
    },
    ReqOpenSeverRevelReward = {
       id = 0,
    },
    ReqOpenServerRevel = {
    },
    ReqOpenSeverRevelPersonReward = {
       id = 0,
    },
    GrowUp = {
       id = 0,
       progress = 0,
       state = false,
    },
    ReqGrowUpPoint = {
       id = 0,
    },
    ReqGrowUpPointReward = {
       id = 0,
    },
    ReqGrowUpPur = {
    },
    OpenServerSpec = {
       id = 0,
       progress = 0,
       state = 0,
       remain = 0,
    },
    ReqOpenServerSpecAc = {
    },
    ReqOpenServerSpecReward = {
       id = 0,
    },
    ReqOpenServerSpecRed = {
    },
    ReqOpenServerSpecExchange = {
       type = 0,
    },
    ReqFreeDailyReward = {
    },
    killInfo = {
       cfgId = 0,
       killTime = 0,
       killers = List:New(),
       state = 0,
       redpacketState = 0,
       reliveTime = nil,
       level = nil,
       career = nil,
       roleId = 0,
       head = nil,
    },
    bossKillInfo = {
       cfgId = 0,
       reliveTime = 0,
    },
    ReqOpenFirstKillPanel = {
    },
    ReqGetKillReward = {
       id = 0,
    },
    ReqHongBaoReward = {
       id = 0,
    },
    cfgItem = {
       id = 0,
       pro = 0,
       isGet = false,
    },
    actInfo = {
       type = 0,
       startTime = 0,
       endTime = 0,
       items = List:New(),
    },
    ReqNewServerActPanel = {
    },
    ReqGetActReward = {
       type = 0,
       cfgId = 0,
    },
    luckyCardRewardGot = {
       cellId = 0,
       itemId = 0,
       num = 0,
       bind = false,
       occ = 0,
    },
    luckyCardRecord = {
       time = 0,
       playerName = "",
       itemId = 0,
       num = 0,
    },
    luckyCardTask = {
       id = 0,
       fenzi = 0,
       fenmu = 0,
       state = 0,
    },
    ReqLuckyOnce = {
       cellId = 0,
    },
    ReqGetLuckyTaskReawrd = {
       taskId = 0,
    },
    ReqGetLuckyLog = {
    },
    V4ApplyPlayer = {
       id = 0,
       occ = 0,
       level = 0,
       name = "",
       head = {
            fashionHead = nil,
            fashionFrame = nil,
            customHeadPath = nil,
            useCustomHead = nil,
        },

    },
    V4HelpPlayer = {
       player = {
            id = 0,
            occ = 0,
            level = 0,
            name = "",
            head = {
                fashionHead = nil,
                fashionFrame = nil,
                customHeadPath = nil,
                useCustomHead = nil,
            },

        },

       helpTime = 0,
       awardState = List:New(),
    },
    V4HelpRecord = {
       helper = nil,
       beHelper = nil,
    },
    ReqV4HelpInfo = {
    },
    ReqV4GetAward = {
       awardId = 0,
    },
    ReqV4HelpBeApply = {
    },
    ReqV4HelpOther = {
       playerId = 0,
    },
    V4Rebate = {
       id = 0,
       progress = 0,
       isComplete = false,
    },
    ReqV4RebateCompleteTask = {
       id = 0,
    },
    ReqV4RebateReward = {
       rewardState = 0,
    },
    ReqGetRebateBox = {
       day = 0,
    },
    XMZhengBa = {
       id = 0,
       progress = 0,
       isComplete = false,
    },
    ReqGetXMZBReward = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_OpenServerAc.ReqOpenSeverRevelReward] = "MSG_OpenServerAc.ReqOpenSeverRevelReward",
    [MSG_OpenServerAc.ReqOpenServerRevel] = "MSG_OpenServerAc.ReqOpenServerRevel",
    [MSG_OpenServerAc.ReqOpenSeverRevelPersonReward] = "MSG_OpenServerAc.ReqOpenSeverRevelPersonReward",
    [MSG_OpenServerAc.ReqGrowUpPoint] = "MSG_OpenServerAc.ReqGrowUpPoint",
    [MSG_OpenServerAc.ReqGrowUpPointReward] = "MSG_OpenServerAc.ReqGrowUpPointReward",
    [MSG_OpenServerAc.ReqGrowUpPur] = "MSG_OpenServerAc.ReqGrowUpPur",
    [MSG_OpenServerAc.ReqOpenServerSpecAc] = "MSG_OpenServerAc.ReqOpenServerSpecAc",
    [MSG_OpenServerAc.ReqOpenServerSpecReward] = "MSG_OpenServerAc.ReqOpenServerSpecReward",
    [MSG_OpenServerAc.ReqOpenServerSpecRed] = "MSG_OpenServerAc.ReqOpenServerSpecRed",
    [MSG_OpenServerAc.ReqOpenServerSpecExchange] = "MSG_OpenServerAc.ReqOpenServerSpecExchange",
    [MSG_OpenServerAc.ReqFreeDailyReward] = "MSG_OpenServerAc.ReqFreeDailyReward",
    [MSG_OpenServerAc.ReqOpenFirstKillPanel] = "MSG_OpenServerAc.ReqOpenFirstKillPanel",
    [MSG_OpenServerAc.ReqGetKillReward] = "MSG_OpenServerAc.ReqGetKillReward",
    [MSG_OpenServerAc.ReqHongBaoReward] = "MSG_OpenServerAc.ReqHongBaoReward",
    [MSG_OpenServerAc.ReqNewServerActPanel] = "MSG_OpenServerAc.ReqNewServerActPanel",
    [MSG_OpenServerAc.ReqGetActReward] = "MSG_OpenServerAc.ReqGetActReward",
    [MSG_OpenServerAc.ReqLuckyOnce] = "MSG_OpenServerAc.ReqLuckyOnce",
    [MSG_OpenServerAc.ReqGetLuckyTaskReawrd] = "MSG_OpenServerAc.ReqGetLuckyTaskReawrd",
    [MSG_OpenServerAc.ReqGetLuckyLog] = "MSG_OpenServerAc.ReqGetLuckyLog",
    [MSG_OpenServerAc.ReqV4HelpInfo] = "MSG_OpenServerAc.ReqV4HelpInfo",
    [MSG_OpenServerAc.ReqV4GetAward] = "MSG_OpenServerAc.ReqV4GetAward",
    [MSG_OpenServerAc.ReqV4HelpBeApply] = "MSG_OpenServerAc.ReqV4HelpBeApply",
    [MSG_OpenServerAc.ReqV4HelpOther] = "MSG_OpenServerAc.ReqV4HelpOther",
    [MSG_OpenServerAc.ReqV4RebateCompleteTask] = "MSG_OpenServerAc.ReqV4RebateCompleteTask",
    [MSG_OpenServerAc.ReqV4RebateReward] = "MSG_OpenServerAc.ReqV4RebateReward",
    [MSG_OpenServerAc.ReqGetRebateBox] = "MSG_OpenServerAc.ReqGetRebateBox",
    [MSG_OpenServerAc.ReqGetXMZBReward] = "MSG_OpenServerAc.ReqGetXMZBReward",
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

return MSG_OpenServerAc

