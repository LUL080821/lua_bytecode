local MSG_Mail = {
    paramStruct = {
       mark = 0,
       paramsValue = "",
    },
    MailSummaryInfo = {
       mailId = 0,
       receiveTime = 0,
       mailTitle = "",
       isRead = false,
       hasAttachment = false,
       isAttachReceived = nil,
       readTable = nil,
    },
    MailDetailInfo = {
       mailId = 0,
       sender = "",
       mailTitle = "",
       mailContent = "",
       hasAttachment = false,
       itemList = List:New(),
       isAttachReceived = nil,
       readTable = nil,
       paramlists = List:New(),
       equipListDetail = List:New(),
    },
    ReqReadMail = {
       mailId = 0,
    },
    ReqReceiveSingleMailAttach = {
       mailId = 0,
    },
    ReqOneClickReceiveMailAttach = {
       mailIdList = List:New(),
    },
    ReqOneClickDeleteMail = {
       mailIdList = List:New(),
    },
}
local L_StrDic = {
    [MSG_Mail.ReqReadMail] = "MSG_Mail.ReqReadMail",
    [MSG_Mail.ReqReceiveSingleMailAttach] = "MSG_Mail.ReqReceiveSingleMailAttach",
    [MSG_Mail.ReqOneClickReceiveMailAttach] = "MSG_Mail.ReqOneClickReceiveMailAttach",
    [MSG_Mail.ReqOneClickDeleteMail] = "MSG_Mail.ReqOneClickDeleteMail",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_Mail

