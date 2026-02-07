local MSG_ActivityRanklist = {}
local Network = GameCenter.Network

function MSG_ActivityRanklist.RegisterMsg()
    Network.CreatRespond("MSG_ActivityRanklist.ResActivityRankInfo",function (msg)
        --TODO
        GameCenter.PushFixEvent(UILuaEventDefine.UIRankAwardForm_OPEN, msg)
    end)


    Network.CreatRespond("MSG_ActivityRanklist.ResGetRankAward",function (msg)
        --TODO
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_RANKAWARD_GETRESULT, msg)
    end)


    Network.CreatRespond("MSG_ActivityRanklist.ResRankAwardAvailable",function (msg)
        --TODO
        GameCenter.RankAwardSystem:SetRedPoint(msg.rankKind, true)
    end)

end
return MSG_ActivityRanklist

