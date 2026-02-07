local MSG_Title = {}
local Network = GameCenter.Network

function MSG_Title.RegisterMsg()
    Network.CreatRespond("MSG_Title.ResTitleInfo",function (msg)
        GameCenter.RoleTitleSystem:GS2U_ResTitleInfo(msg)
    end)

    Network.CreatRespond("MSG_Title.ResActiveTitleResult",function (msg)
        GameCenter.RoleTitleSystem:GS2U_ResActiveTitle(msg)
    end)

    Network.CreatRespond("MSG_Title.ResWearTitle",function (msg)
        GameCenter.RoleTitleSystem:GS2U_ResWearTitle(msg)
    end)

    Network.CreatRespond("MSG_Title.ResDownTitle",function (msg)
        GameCenter.RoleTitleSystem:GS2U_ResDownTitle(msg)
    end)

    Network.CreatRespond("MSG_Title.ResBroadWearTitle",function (msg)
        --TODO
    end)

end
return MSG_Title

