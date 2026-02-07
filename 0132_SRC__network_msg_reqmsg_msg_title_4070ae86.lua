local MSG_Title = {
    title = {
       id = 0,
       remainTime = 0,
    },
    ReqActiveTitle = {
       id = 0,
    },
    ReqWearTitle = {
       id = 0,
    },
    ReqDownTitle = {
       id = 0,
    },
}
local L_StrDic = {
    [MSG_Title.ReqActiveTitle] = "MSG_Title.ReqActiveTitle",
    [MSG_Title.ReqWearTitle] = "MSG_Title.ReqWearTitle",
    [MSG_Title.ReqDownTitle] = "MSG_Title.ReqDownTitle",
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

return MSG_Title

