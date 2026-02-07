local MSG_Login = {
    ReqLogin = {
       accessToken = "",
       machineCode = "",
       platformUid = "",
       platformName = "",
       imei = "",
       mac = "",
       platformAccount = nil,
       cpdid = nil,
    },
    roleInfo = {
       roleId = 0,
       name = "",
       career = 0,
       lv = 0,
       fight = 0,
    },
    serverNumInfo = {
       serverId = 0,
       num = 0,
       roles = List:New(),
    },
    serverChangeName = {
       serverId = 0,
       changeName = "",
    },
}
local L_StrDic = {
    [MSG_Login.ReqLogin] = "MSG_Login.ReqLogin",
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

return MSG_Login

