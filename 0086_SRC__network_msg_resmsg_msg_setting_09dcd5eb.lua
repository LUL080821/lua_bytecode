local MSG_Setting = {}
local Network = GameCenter.Network

function MSG_Setting.RegisterMsg()
    Network.CreatRespond("MSG_Setting.ResSettingInfo",function (msg)
        local _list = msg.list;
        for i = 1, #_list do
            GameCenter.GameSetting:SetSetting(_list[i].type,_list[i].value and 1 or 0);
        end
    end)

    Network.CreatRespond("MSG_Setting.ResCommitFeedback",function (msg)
        GameCenter.FeedBackSystem:GS2U_ResCommitFeedback(msg);
        --TODO
    end)

    Network.CreatRespond("MSG_Setting.ResGMFeedback",function (msg)
        GameCenter.FeedBackSystem:GS2U_ResGMFeedback(msg);
    end)


    Network.CreatRespond("MSG_Setting.ResChangeServerNameSuccess",function (msg)
        GameCenter.ServerListSystem:GS2U_ResChangeServerNameSuccess(msg.serverId,msg.changeName);
    end)

end
return MSG_Setting

