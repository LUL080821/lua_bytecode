local MSG_LuckyDraw = {
    awardIndexInfo = {
       indexes = List:New(),
       awardType = 0,
    },
    awardRecordInfo = {
       playername = "",
       itemId = 0,
       itemNum = 0,
       bind = false,
       awardType = 0,
    },
    getDrawVolumeInfo = {
       id = 0,
       maxCount = 0,
       progress = 0,
       isGet = false,
    },
    ReqOpenLuckyDrawPanel = {
    },
    ReqLuckyDraw = {
    },
    ReqGetLuckyDrawVolume = {
       id = 0,
    },
    ReqChangeAwardIndex = {
       items = List:New(),
    },
    ReqCloseLuckyDrawPanel = {
    },
}
local L_StrDic = {
    [MSG_LuckyDraw.ReqOpenLuckyDrawPanel] = "MSG_LuckyDraw.ReqOpenLuckyDrawPanel",
    [MSG_LuckyDraw.ReqLuckyDraw] = "MSG_LuckyDraw.ReqLuckyDraw",
    [MSG_LuckyDraw.ReqGetLuckyDrawVolume] = "MSG_LuckyDraw.ReqGetLuckyDrawVolume",
    [MSG_LuckyDraw.ReqChangeAwardIndex] = "MSG_LuckyDraw.ReqChangeAwardIndex",
    [MSG_LuckyDraw.ReqCloseLuckyDrawPanel] = "MSG_LuckyDraw.ReqCloseLuckyDrawPanel",
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

return MSG_LuckyDraw

