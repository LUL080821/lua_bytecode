local MSG_Team = {}
local Network = GameCenter.Network

function MSG_Team.RegisterMsg()

    Network.CreatRespond("MSG_Team.ResTeamInfo",function (msg)
        --TODO
        GameCenter.PlayerVisualSystem:ResTeamInfo(msg)
        GameCenter.TeamSystem:ResTeamInfo(msg)
    end)


    Network.CreatRespond("MSG_Team.ResUpdateTeamMemberInfo",function (msg)
        --TODO
        GameCenter.PlayerVisualSystem:ResUpdateTeamMemberInfo(msg);
        GameCenter.TeamSystem:ResUpdateTeamMemberInfo(msg)
    end)


    Network.CreatRespond("MSG_Team.ResFreedomList",function (msg)
        --TODO
        GameCenter.TeamSystem:ResFreedomList(msg)
    end)


    Network.CreatRespond("MSG_Team.ResInviteInfo",function (msg)
        --TODO
        GameCenter.TeamSystem:ResInviteInfo(msg)
    end)


    Network.CreatRespond("MSG_Team.ResApplyList",function (msg)
        --TODO
        GameCenter.TeamSystem:ResApplyList(msg)
    end)


    Network.CreatRespond("MSG_Team.ResAddApplyer",function (msg)
        --TODO
        GameCenter.TeamSystem:ResAddApplyer(msg)
    end)


    Network.CreatRespond("MSG_Team.ResWaitList",function (msg)
        --TODO
        GameCenter.TeamSystem:ResWaitList(msg)
    end)


    Network.CreatRespond("MSG_Team.ResDeleteTeamMember",function (msg)
        --TODO
        GameCenter.TeamSystem:ResDeleteTeamMember(msg)
    end)


    Network.CreatRespond("MSG_Team.ResCallAllMemberRes",function (msg)
        --TODO
        GameCenter.TeamSystem:ResCallAllMemberRes(msg)
    end)


    Network.CreatRespond("MSG_Team.ResMatchAll",function (msg)
        --TODO
        GameCenter.TeamSystem:ResMatchAll(msg)
    end)


    Network.CreatRespond("MSG_Team.ResUpdateHPAndMapKey",function (msg)
        --TODO
        GameCenter.TeamSystem:ResUpdateHPAndMapKey(msg)
    end)


    Network.CreatRespond("MSG_Team.ResTeamLeaderOpenState",function (msg)
        --TODO
        GameCenter.TeamSystem:ResTeamLeaderOpenState(msg)
    end)


    Network.CreatRespond("MSG_Team.ResBecomeLeader",function (msg)
        --TODO
        GameCenter.TeamSystem:ResBecomeLeader(msg)
    end)

end
return MSG_Team

