local MSG_Task = {}
local Network = GameCenter.Network

function MSG_Task.RegisterMsg()
    Network.CreatRespond("MSG_Task.ResTaskList",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResTaskList(msg)
    end)

    Network.CreatRespond("MSG_Task.ResTaskFinish",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResTaskFinish(msg)
    end)

    Network.CreatRespond("MSG_Task.ResMainTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResMainTaskChange(msg)
    end)

    Network.CreatRespond("MSG_Task.ResDailyTaskChang",function (msg)
        GameCenter.TaskManagerMsg:GS2U_ResDailyTaskChang(msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResConquerTaskChang",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResGuildTaskChang(msg)
    end)

    Network.CreatRespond("MSG_Task.ResMainTaskOver",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResBranchTaskChang",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResBranchTaskChang(msg)
    end)

    Network.CreatRespond("MSG_Task.ResGenderTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResGenderTaskChange(msg)
    end)

    Network.CreatRespond("MSG_Task.ResTaskIsFinish",function (msg)
        --TODO
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_ISTASKFINISH, msg)
    end)

    Network.CreatRespond("MSG_Task.ResGuideTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResGuideTaskChange(msg)
    end)

    Network.CreatRespond("MSG_Task.ResBorderTaskChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResBattleFieldTaskChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResEscortTaskChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResTaskDelete",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResTaskDelete(msg)
    end)

    Network.CreatRespond("MSG_Task.ResBattleTaskNextFreshTime",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Task.ResLoopTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResLoopTaskChange(msg)
    end)

    Network.CreatRespond("MSG_Task.ResGuildTaskPool",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResGuildTaskPool(msg)
    end)


    Network.CreatRespond("MSG_Task.ResTargetInfo",function (msg)
        --TODO
        GameCenter.TargetSystem:ResTargetInfo(msg)
    end)


    Network.CreatRespond("MSG_Task.ResDailyTaskFinish",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:ResDailyTaskFinish(msg)
    end)


    Network.CreatRespond("MSG_Task.ResDailyTaskCountReward",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:ResDailyTaskCountReward(msg)
    end)


    Network.CreatRespond("MSG_Task.ResPrisonTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResPrisonTaskChange(msg)
    end)


    Network.CreatRespond("MSG_Task.ResDailyPrisonTaskChange",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:GS2U_ResDailyPrisonTaskChange(msg)
    end)


    Network.CreatRespond("MSG_Task.ResDailyPrisonTaskFinish",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:ResDailyPrisonTaskFinish(msg)
    end)


    Network.CreatRespond("MSG_Task.ResDailyPrisonTaskCountReward",function (msg)
        --TODO
        GameCenter.TaskManagerMsg:ResDailyPrisonTaskCountReward(msg)
    end)

end
return MSG_Task

