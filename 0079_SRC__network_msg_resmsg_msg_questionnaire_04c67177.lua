local MSG_Questionnaire = {}
local Network = GameCenter.Network

function MSG_Questionnaire.RegisterMsg()
    Network.CreatRespond("MSG_Questionnaire.ResPanelInfo",function (msg)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFRESH_QUESTION_NAIRE_DATA, msg)
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Question, msg.isOpen)
        GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.Question, msg.state == 0 or msg.state == 1)
    end)


    Network.CreatRespond("MSG_Questionnaire.G2PGetPanelInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Questionnaire.G2PSubmitAnswer",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Questionnaire.G2PGetReward",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Questionnaire.P2GOpenState",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Questionnaire.P2GGetRewardState",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Questionnaire.ResDownloadGetAward",function (msg)
        local _isGetDownloadAward = msg.isGetDownloadAward
        GameCenter.UpdateSystem:SetIsGetedAward(_isGetDownloadAward)
    end)

end
return MSG_Questionnaire

