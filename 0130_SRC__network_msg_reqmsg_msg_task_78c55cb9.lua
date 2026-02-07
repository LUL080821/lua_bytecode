local MSG_Task = {
    taskAttribute = {
       model = 0,
       num = 0,
       needNum = 0,
       mapId = 0,
       type = nil,
       xPos = nil,
       yPos = nil,
       talkId = nil,
       itemId = nil,
    },
    mainTaskInfo = {
       modelId = 0,
       useItems = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       overIDs = List:New(),
    },
    prisonTaskInfo = {
       modelId = 0,
       useItems = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       overIDs = List:New(),
    },
    guideTaskInfo = {
       modelId = 0,
       useItems = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

    },
    dailyTaskInfo = {
       modelId = 0,
       useItems = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isfull = false,
       oneKeyState = false,
       isReceive = false,
       star = 0,
       count = 0,
       maxCount = 0,
       taskState = nil,
    },
    dailyPrisonTaskInfo = {
       modelId = 0,
       useItems = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isfull = false,
       oneKeyState = false,
       isReceive = false,
       star = 0,
       count = 0,
       maxCount = 0,
       taskState = nil,
    },
    DailyTaskCountReward = {
       count = 0,
       isReward = false,
    },
    DailyPrisonTaskCountReward = {
       count = 0,
       isReward = false,
    },
    conquerTaskInfo = {
       modelId = 0,
       monsters = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
       count = 0,
       maxCount = 0,
    },
    branchTaskInfo = {
       modelId = 0,
       monsters = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
    },
    borderTaskInfo = {
       modelId = 0,
       target = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
    },
    battleFieldTaskInfo = {
       modelId = 0,
       target = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
       star = 0,
       index = 0,
    },
    genderTaskInfo = {
       modelId = 0,
       target = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
    },
    loopTaskInfo = {
       modelId = 0,
       target = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
    },
    escortTaskInfo = {
       modelId = 0,
       target = {
            model = 0,
            num = 0,
            needNum = 0,
            mapId = 0,
            type = nil,
            xPos = nil,
            yPos = nil,
            talkId = nil,
            itemId = nil,
        },

       isReceive = false,
    },
    ReqTaskFinish = {
       type = 0,
       modelId = 0,
       rewardPer = 0,
       taskId = nil,
       subType = nil,
    },
    ReqGiveUpTask = {
       type = 0,
       modelId = 0,
       taskId = 0,
    },
    ReqQuickFinish = {
       type = 0,
       overPer = nil,
       subType = nil,
       taskCount = nil,
    },
    ReqOneKeyOverTask = {
       type = 0,
       taskModelId = 0,
       subType = nil,
    },
    ReqDailyUpStar = {
       modelId = 0,
    },
    ReqDailyPrisonUpStar = {
       modelId = 0,
    },
    ReqReceiveTask = {
       taskId = 0,
       type = 0,
       subType = nil,
    },
    ReqCheckTaskIsFinish = {
       type = 0,
       taskId = 0,
    },
    ReqRefreshTask = {
       type = 0,
    },
    ReqChangeTaskState = {
       type = 0,
       modelId = 0,
    },
    ReqRefreshGuildTaskPool = {
       useGold = false,
    },
    ReqGetTarget = {
    },
    ReqChangeJob = {
    },
    ReqDailyTaskCountReward = {
       count = 0,
    },
    ReqDailyPrisonTaskCountReward = {
       count = 0,
    },
}
local L_StrDic = {
    [MSG_Task.ReqTaskFinish] = "MSG_Task.ReqTaskFinish",
    [MSG_Task.ReqGiveUpTask] = "MSG_Task.ReqGiveUpTask",
    [MSG_Task.ReqQuickFinish] = "MSG_Task.ReqQuickFinish",
    [MSG_Task.ReqOneKeyOverTask] = "MSG_Task.ReqOneKeyOverTask",
    [MSG_Task.ReqDailyUpStar] = "MSG_Task.ReqDailyUpStar",
    [MSG_Task.ReqDailyPrisonUpStar] = "MSG_Task.ReqDailyPrisonUpStar",
    [MSG_Task.ReqReceiveTask] = "MSG_Task.ReqReceiveTask",
    [MSG_Task.ReqCheckTaskIsFinish] = "MSG_Task.ReqCheckTaskIsFinish",
    [MSG_Task.ReqRefreshTask] = "MSG_Task.ReqRefreshTask",
    [MSG_Task.ReqChangeTaskState] = "MSG_Task.ReqChangeTaskState",
    [MSG_Task.ReqRefreshGuildTaskPool] = "MSG_Task.ReqRefreshGuildTaskPool",
    [MSG_Task.ReqGetTarget] = "MSG_Task.ReqGetTarget",
    [MSG_Task.ReqChangeJob] = "MSG_Task.ReqChangeJob",
    [MSG_Task.ReqDailyTaskCountReward] = "MSG_Task.ReqDailyTaskCountReward",
    [MSG_Task.ReqDailyPrisonTaskCountReward] = "MSG_Task.ReqDailyPrisonTaskCountReward",
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

return MSG_Task

