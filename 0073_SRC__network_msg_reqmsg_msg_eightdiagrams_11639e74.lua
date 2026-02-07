local MSG_EightDiagrams = {
    ReqEightDiagramsPanel = {
    },
    CityBattleInfo = {
       sid = 0,
       playerNum = 0,
       colorCamp = 0,
       bossHurt = 0,
       serverName = "",
    },
    CityInfo = {
       cityID = 0,
       birthSid = 0,
       modelID = 0,
       curSid = 0,
       serverName = "",
       bossID = 0,
       curHp = nil,
       maxHp = nil,
       cityBattleInfoList = List:New(),
       colorCamp = nil,
    },
    RankInfo = {
       integral = 0,
       name = "",
       rank = 0,
       colorCamp = nil,
       serverid = nil,
    },
    ReqRankPanel = {
    },
    ReqEnterEightCityMap = {
       cityID = 0,
    },
    ReqTickMapInfo = {
       cityID = 0,
    },
    RewardInfo = {
       roleID = 0,
       value = 0,
    },
    EightCityAttribute = {
       type = 0,
       value = 0,
       param = nil,
    },
}
local L_StrDic = {
    [MSG_EightDiagrams.ReqEightDiagramsPanel] = "MSG_EightDiagrams.ReqEightDiagramsPanel",
    [MSG_EightDiagrams.ReqRankPanel] = "MSG_EightDiagrams.ReqRankPanel",
    [MSG_EightDiagrams.ReqEnterEightCityMap] = "MSG_EightDiagrams.ReqEnterEightCityMap",
    [MSG_EightDiagrams.ReqTickMapInfo] = "MSG_EightDiagrams.ReqTickMapInfo",
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

return MSG_EightDiagrams

