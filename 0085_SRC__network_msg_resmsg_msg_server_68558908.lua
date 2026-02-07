local MSG_Server = {}
local Network = GameCenter.Network

function MSG_Server.RegisterMsg()

    Network.CreatRespond("MSG_Server.P2GResRegister",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.F2GResRegister",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.P2GResFightServerList",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.P2GResFightServer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.G2PReqRegister",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.G2FReqRegister",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.G2PReqFightServerList",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.G2PReqFightServer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.S2PRegisterServer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.P2SRegisterCallback",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.G2SRegisterServer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Server.S2GRegisterCallback",function (msg)
        --TODO
    end)

end
return MSG_Server

