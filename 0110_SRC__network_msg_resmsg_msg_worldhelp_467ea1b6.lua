local MSG_WorldHelp = {}
local Network = GameCenter.Network

function MSG_WorldHelp.RegisterMsg()
    Network.CreatRespond("MSG_WorldHelp.ResWorldHelp",function (msg)
        GameCenter.WorldSupportSystem:ResOpenWorldSupportPannel(msg)
    end)

    Network.CreatRespond("MSG_WorldHelp.ResAtLastHelp",function (msg)
        GameCenter.WorldSupportSystem:ResAtLastHelp(msg)
    end)

    Network.CreatRespond("MSG_WorldHelp.ResThkHelp",function (msg)
        GameCenter.WorldSupportSystem:ResThankMessageInfo(msg)
    end)

    Network.CreatRespond("MSG_WorldHelp.SyncPrestige",function (msg)
        GameCenter.WorldSupportSystem:SyncPrestige(msg)
    end)

    Network.CreatRespond("MSG_WorldHelp.SyncHelpTarget",function (msg)
        GameCenter.WorldSupportSystem:ResWorldSupporting(msg)
    end)


    Network.CreatRespond("MSG_WorldHelp.SyncWorldHelp",function (msg)
        GameCenter.WorldSupportSystem:ResNewWorldSupportInfo(msg)
    end)


    Network.CreatRespond("MSG_WorldHelp.ResDieCallHelp",function (msg)
        GameCenter.WorldSupportSystem:ResDieCallHelp(msg)
    end)

end
return MSG_WorldHelp

