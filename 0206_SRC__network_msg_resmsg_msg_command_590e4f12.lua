local MSG_Command = {}
local Network = GameCenter.Network

function MSG_Command.RegisterMsg()
    Network.CreatRespond("MSG_Command.ResCommandInfo",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Command.ResTargetPos",function (msg)
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)


    Network.CreatRespond("MSG_Command.G2PSynGuildBattleInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Command.ResCommandBulletScreen",function (msg)
        -- Barrage broadcast
        GameCenter.MapLogicSystem:OnMsgHandle(msg)
    end)

end
return MSG_Command

