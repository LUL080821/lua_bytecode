local MSG_Recycle = {}
local Network = GameCenter.Network

function MSG_Recycle.RegisterMsg()
    Network.CreatRespond("MSG_Recycle.ResRecycle",function (msg)
        if msg then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEEQUIPSMELTRESULT, msg.num)
        end
    end)


    Network.CreatRespond("MSG_Recycle.ResSetAuto",function (msg)
        if msg then
            GameCenter.EquipmentSystem.IsAutoSmelt = msg.isOpen;
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATEAUTOSMELTSTATE, msg.isOpen);
        end
    end)

end
return MSG_Recycle

