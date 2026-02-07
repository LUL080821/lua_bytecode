local MSG_LuckyDraw = {}
local Network = GameCenter.Network

function MSG_LuckyDraw.RegisterMsg()
    Network.CreatRespond("MSG_LuckyDraw.ResLuckyDrawResult",function (msg)
        
        GameCenter.LuckyDrawWeekSystem:ResLuckyDrawResult(msg);
    end)

    Network.CreatRespond("MSG_LuckyDraw.ResGetLuckyDrawVolumeResult",function (msg)
        
        GameCenter.LuckyDrawWeekSystem:ResGetLuckyDrawVolumeResult(msg);
    end)

    Network.CreatRespond("MSG_LuckyDraw.ResChangeAwardIndexResult",function (msg)
        
        GameCenter.LuckyDrawWeekSystem:ResChangeAwardIndexResult(msg);
    end)

    Network.CreatRespond("MSG_LuckyDraw.ResDrawnRecord",function (msg)
        
        GameCenter.LuckyDrawWeekSystem:ResDrawnRecord(msg);
    end)


    Network.CreatRespond("MSG_LuckyDraw.ResOpenLuckyDrawPanelResult",function (msg)
        GameCenter.LuckyDrawWeekSystem:ResOpenLuckyDrawPanelResult(msg);
    end)


    Network.CreatRespond("MSG_LuckyDraw.ResLuckyDrawOnlineResult",function (msg)
        GameCenter.LuckyDrawWeekSystem:ResLuckyDrawOnlineResult(msg);
    end)

end
return MSG_LuckyDraw

