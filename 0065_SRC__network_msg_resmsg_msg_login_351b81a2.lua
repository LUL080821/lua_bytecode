local MSG_Login = {}
local Network = GameCenter.Network

function MSG_Login.RegisterMsg()
    Network.CreatRespond("MSG_Login.ResLoginFailed",function (msg)
        GameCenter.LoginSystem:GS2U_ResLoginFailed(msg);
    end)

    Network.CreatRespond("MSG_Login.ResLoginSuccess",function (msg)
        GameCenter.LoginSystem:OnGS2U_LoginSuccess(msg);
    end)

end
return MSG_Login

