local MSG_BI = {
    Device = {
       appId = 0,
       roleId = 0,
       channelId = "",
       sourceId = "",
       deviceId = "",
       platform = 0,
       app_version = "",
       merchant = "",
       net_type = "",
       screen = nil,
       os = nil,
       os_version = nil,
       server_name = nil,
       cpgameId = nil,
       cpdid = nil,
       cpdevice_name = nil,
       cpplatformId = nil,
       cpuserid = nil,
       cpuserName = nil,
       cpgameName = nil,
       cpPlatformGname = nil,
    },
    ReqBiDevice = {
       device = {
            appId = 0,
            roleId = 0,
            channelId = "",
            sourceId = "",
            deviceId = "",
            platform = 0,
            app_version = "",
            merchant = "",
            net_type = "",
            screen = nil,
            os = nil,
            os_version = nil,
            server_name = nil,
            cpgameId = nil,
            cpdid = nil,
            cpdevice_name = nil,
            cpplatformId = nil,
            cpuserid = nil,
            cpuserName = nil,
            cpgameName = nil,
            cpPlatformGname = nil,
        },

    },
    ValMap = {
       key = "",
       value = "",
    },
    ReqBi = {
       roleId = 0,
       biName = "",
       valMaps = List:New(),
    },
    UIData = {
       id = 0,
       time = 0,
    },
    ReqUiBi = {
       roleId = 0,
       uiData = List:New(),
    },
}
local L_StrDic = {
    [MSG_BI.ReqBiDevice] = "MSG_BI.ReqBiDevice",
    [MSG_BI.ReqBi] = "MSG_BI.ReqBi",
    [MSG_BI.ReqUiBi] = "MSG_BI.ReqUiBi",
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

return MSG_BI

