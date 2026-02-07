local MSG_FunctionTask = {}
local Network = GameCenter.Network

function MSG_FunctionTask.RegisterMsg()
    Network.CreatRespond("MSG_FunctionTask.ResAllFunctionTask",function (msg)
        --TODO
        GameCenter.TodayFuncSystem:ResAllFunctionTask(msg)
    end)

    Network.CreatRespond("MSG_FunctionTask.ResFunctionTaskUpdate",function (msg)
        --TODO
        GameCenter.TodayFuncSystem:ResFunctionTaskUpdate(msg)
    end)

end
return MSG_FunctionTask

