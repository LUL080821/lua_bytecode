local MSG_Mail = {}
local Network = GameCenter.Network

function MSG_Mail.RegisterMsg()
    Network.CreatRespond("MSG_Mail.ResReadMail",function (msg)
        GameCenter.MailSystem:ResReadMail(msg)
    end)

    Network.CreatRespond("MSG_Mail.ResReceiveSingleMailAttach",function (msg)
        GameCenter.MailSystem:ResReceiveSingleMailAttach(msg)
    end)

    Network.CreatRespond("MSG_Mail.ResMailInfoList",function (msg)
        GameCenter.MailSystem:ResMailInfoList(msg)
    end)

    Network.CreatRespond("MSG_Mail.ResNewMail",function (msg)
        GameCenter.MailSystem:ResNewMail(msg)
    end)

end
return MSG_Mail

