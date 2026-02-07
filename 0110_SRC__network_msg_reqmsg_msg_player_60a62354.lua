local MSG_Player = {
    Attribute = {
       type = 0,
       value = 0,
    },
    GlobalPlayerWorldInfo = {
       userId = 0,
       roleid = 0,
       rolename = "",
       career = 0,
       level = 0,
       plat = "",
       createTime = 0,
       csid = 0,
       lastOffTime = 0,
       horseId = 0,
       wingId = 0,
       fightPower = 0,
       guildId = 0,
       fashionHeadId = 0,
       fashionHeadFrameId = 0,
       fashionBodyId = 0,
       fashionWeaponId = 0,
       fashionHalo = 0,
       fashionMatrix = 0,
       sex = 0,
       stateVip = 0,
       shiHaiLevel = 0,
       playerVip = 0,
       spiritId = 0,
       soulArmorId = 0,
       serverId = nil,
       customHeadPath = nil,
       useCustomHead = nil,
       guildName = nil,
    },
    ReqChangeJob = {
    },
    ReqGetAccunonlinetime = {
    },
    ReqUpdataPkState = {
       pkState = 0,
    },
    ReqLookOtherPlayer = {
       otherPlayerId = 0,
    },
    ReqUpdateMainUIGuideID = {
       gid = 0,
    },
    ReqMainUIGuideID = {
    },
    ReqChangeRoleName = {
       newName = "",
    },
    ReqCourageList = {
    },
    FateStar = {
       id = 0,
       gender = 0,
    },
    CharMainType = {
       id = 0,
       point = 0,
    },
    ReqPeakLevelPanel = {
    },
    ReqChangeJobPanel = {
       gender = 0,
    },
    ReqActiveFateStar = {
       id = 0,
    },
    ReqActiveMainType = {
       roleId = 0,
       pools = List:New(),
    },
    ReqUpgradeBlood = {
    },
    ReqOpenBloodPannel = {
    },
    ReqPlayerCareerChange = {
       careerNo = 0,
       eqiupNos = List:New(),
    },
    Gift = {
       giftId = 0,
       giftNumber = 0,
    },
    ReqSendGift = {
       type = 0,
       roleId = 0,
       force = false,
       gifts = List:New(),
    },
    GiftLog = {
       id = 0,
       type = 0,
       sender = "",
       receiver = "",
       itemId = 0,
       num = 0,
       time = 0,
       readStatus = 0,
    },
    ReqGetGiftLog = {
       type = 0,
    },
    ReqReadGiftLog = {
       ids = List:New(),
    },
    ReqXiSui = {
       free = false,
    },
    SyncXiSuiData = {
       roleID = 0,
       xsLvl = 0,
    },
    ReqPlayerSummaryInfo = {
       roleId = 0,
    },
    G2SSynPlayerSocialInfo = {
       globalPlayerWorldInfo = {
            userId = 0,
            roleid = 0,
            rolename = "",
            career = 0,
            level = 0,
            plat = "",
            createTime = 0,
            csid = 0,
            lastOffTime = 0,
            horseId = 0,
            wingId = 0,
            fightPower = 0,
            guildId = 0,
            fashionHeadId = 0,
            fashionHeadFrameId = 0,
            fashionBodyId = 0,
            fashionWeaponId = 0,
            fashionHalo = 0,
            fashionMatrix = 0,
            sex = 0,
            stateVip = 0,
            shiHaiLevel = 0,
            playerVip = 0,
            spiritId = 0,
            soulArmorId = 0,
            serverId = nil,
            customHeadPath = nil,
            useCustomHead = nil,
            guildName = nil,
        },

       type = 0,
    },
    G2SReqPlayerSummaryInfo = {
       roleId = 0,
       targetRoleId = 0,
    },
    ReqPlayerSettingCustomHead = {
       customHeadPath = "",
       useCustomHead = false,
    },
    ReqPlayerChangeState = {
       playerState = 0,
    },
}
local L_StrDic = {
    [MSG_Player.ReqChangeJob] = "MSG_Player.ReqChangeJob",
    [MSG_Player.ReqGetAccunonlinetime] = "MSG_Player.ReqGetAccunonlinetime",
    [MSG_Player.ReqUpdataPkState] = "MSG_Player.ReqUpdataPkState",
    [MSG_Player.ReqLookOtherPlayer] = "MSG_Player.ReqLookOtherPlayer",
    [MSG_Player.ReqUpdateMainUIGuideID] = "MSG_Player.ReqUpdateMainUIGuideID",
    [MSG_Player.ReqMainUIGuideID] = "MSG_Player.ReqMainUIGuideID",
    [MSG_Player.ReqChangeRoleName] = "MSG_Player.ReqChangeRoleName",
    [MSG_Player.ReqCourageList] = "MSG_Player.ReqCourageList",
    [MSG_Player.ReqPeakLevelPanel] = "MSG_Player.ReqPeakLevelPanel",
    [MSG_Player.ReqChangeJobPanel] = "MSG_Player.ReqChangeJobPanel",
    [MSG_Player.ReqActiveFateStar] = "MSG_Player.ReqActiveFateStar",
    [MSG_Player.ReqActiveMainType] = "MSG_Player.ReqActiveMainType",
    [MSG_Player.ReqUpgradeBlood] = "MSG_Player.ReqUpgradeBlood",
    [MSG_Player.ReqOpenBloodPannel] = "MSG_Player.ReqOpenBloodPannel",
    [MSG_Player.ReqPlayerCareerChange] = "MSG_Player.ReqPlayerCareerChange",
    [MSG_Player.ReqSendGift] = "MSG_Player.ReqSendGift",
    [MSG_Player.ReqGetGiftLog] = "MSG_Player.ReqGetGiftLog",
    [MSG_Player.ReqReadGiftLog] = "MSG_Player.ReqReadGiftLog",
    [MSG_Player.ReqXiSui] = "MSG_Player.ReqXiSui",
    [MSG_Player.SyncXiSuiData] = "MSG_Player.SyncXiSuiData",
    [MSG_Player.ReqPlayerSummaryInfo] = "MSG_Player.ReqPlayerSummaryInfo",
    [MSG_Player.G2SSynPlayerSocialInfo] = "MSG_Player.G2SSynPlayerSocialInfo",
    [MSG_Player.G2SReqPlayerSummaryInfo] = "MSG_Player.G2SReqPlayerSummaryInfo",
    [MSG_Player.ReqPlayerSettingCustomHead] = "MSG_Player.ReqPlayerSettingCustomHead",
    [MSG_Player.ReqPlayerChangeState] = "MSG_Player.ReqPlayerChangeState",
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

return MSG_Player

