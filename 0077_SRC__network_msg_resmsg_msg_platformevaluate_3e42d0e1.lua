local MSG_PlatformEvaluate = {}
local Network = GameCenter.Network

function MSG_PlatformEvaluate.RegisterMsg()
    Network.CreatRespond("MSG_PlatformEvaluate.ResEvaluateResult",function (msg)
        GameCenter.ShareAndLikeSystem:ResEvaluateResult(msg)
    end)


    Network.CreatRespond("MSG_PlatformEvaluate.ResEvaluateInfo",function (msg)
        GameCenter.ShareAndLikeSystem:ResEvaluateInfo(msg)
    end)

end
return MSG_PlatformEvaluate

