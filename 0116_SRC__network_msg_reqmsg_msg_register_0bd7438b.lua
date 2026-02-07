local MSG_Register = {
    RoleBaseInfo = {
       roleId = 0,
       name = "",
       career = 0,
       lv = 0,
       stateLv = 0,
       deleteTime = 0,
       createTime = nil,
       fight = 0,
       facade = {
            fashionBody = nil,
            fashionWeapon = nil,
            fashionHalo = nil,
            fashionMatrix = nil,
            wingId = nil,
            spiritId = nil,
            soulArmorId = nil,
        },

    },
    ReqLoginGame = {
       userId = 0,
       accessToken = "",
       machineCode = "",
       platformName = "",
       sign = "",
       time = 0,
       serverId = 0,
       funcelUUid = "",
       languageType = nil,
       platUserName = nil,
       os = nil,
       roleId = 0,
       isWhite = false,
       isCertify = false,
       isChangeRole = nil,
       extension = List:New(),
    },
    ReqCreateCharacter = {
       playerName = "",
       career = 0,
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

       isRandom = nil,
    },
    ReqSelectCharacter = {
       playerId = 0,
    },
    ReqLoadFinish = {
       type = 0,
       width = 0,
       height = 0,
    },
    ReqQuit = {
    },
    ReqDeleteRole = {
       roleId = 0,
    },
    ReqRegainRole = {
       roleId = 0,
    },
    ReqNoticeCertifySuccess = {
    },
}
local L_StrDic = {
    [MSG_Register.ReqLoginGame] = "MSG_Register.ReqLoginGame",
    [MSG_Register.ReqCreateCharacter] = "MSG_Register.ReqCreateCharacter",
    [MSG_Register.ReqSelectCharacter] = "MSG_Register.ReqSelectCharacter",
    [MSG_Register.ReqLoadFinish] = "MSG_Register.ReqLoadFinish",
    [MSG_Register.ReqQuit] = "MSG_Register.ReqQuit",
    [MSG_Register.ReqDeleteRole] = "MSG_Register.ReqDeleteRole",
    [MSG_Register.ReqRegainRole] = "MSG_Register.ReqRegainRole",
    [MSG_Register.ReqNoticeCertifySuccess] = "MSG_Register.ReqNoticeCertifySuccess",
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

return MSG_Register

