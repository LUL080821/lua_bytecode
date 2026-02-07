local MSG_WorldAnswer = {}
local Network = GameCenter.Network

function MSG_WorldAnswer.RegisterMsg()
    Network.CreatRespond("MSG_WorldAnswer.ResApplyAnswerResult",function (msg)
        --TODO
        GameCenter.WorldAnswerSystem:ResApplyAnswerResult(msg)
    end)

    Network.CreatRespond("MSG_WorldAnswer.ResSendQuestion",function (msg)
        --TODO
        GameCenter.WorldAnswerSystem:ResSendQuestion(msg)
    end)

    Network.CreatRespond("MSG_WorldAnswer.ResSendOtherPlayerSelect",function (msg)
        --TODO
        GameCenter.WorldAnswerSystem:ResSendOtherPlayerSelect(msg)
    end)

    Network.CreatRespond("MSG_WorldAnswer.ResWorldAnswerOver",function (msg)
        --TODO
        GameCenter.WorldAnswerSystem:ResWorldAnswerOver(msg)
    end)

    Network.CreatRespond("MSG_WorldAnswer.P2GResQuestionReward",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_WorldAnswer.P2GResWorldAnswerOver",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldAnswer.G2PReqApplyAnswer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldAnswer.G2PReqAnswerResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_WorldAnswer.G2PReqLeaveOutAnswer",function (msg)
        --TODO
    end)

end
return MSG_WorldAnswer

