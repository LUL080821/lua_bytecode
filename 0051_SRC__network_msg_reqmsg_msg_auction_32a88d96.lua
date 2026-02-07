local MSG_Auction = {
    AuctionInfo = {
       item = nil,
       guildId = 0,
       time = 0,
       price = 0,
       ownId = 0,
       roleId = 0,
       id = 0,
       roleIds = List:New(),
       isPassword = nil,
       detail = nil,
    },
    AuctionRecord = {
       itemId = 0,
       price = 0,
       type = 0,
       time = 0,
       num = 0,
       detail = nil,
    },
    ReqAuctionInfoPut = {
       itemUid = 0,
       num = 0,
       type = 0,
       password = nil,
       price = nil,
    },
    ReqAuctionInfoOut = {
       auctionId = 0,
    },
    ReqAuctionInfo = {
       auctionId = 0,
       price = 0,
    },
    ReqAuctionInfoPur = {
       auctionId = 0,
       password = nil,
    },
    ReqAuctionInfoList = {
    },
    ReqAuctionRecordList = {
    },
}
local L_StrDic = {
    [MSG_Auction.ReqAuctionInfoPut] = "MSG_Auction.ReqAuctionInfoPut",
    [MSG_Auction.ReqAuctionInfoOut] = "MSG_Auction.ReqAuctionInfoOut",
    [MSG_Auction.ReqAuctionInfo] = "MSG_Auction.ReqAuctionInfo",
    [MSG_Auction.ReqAuctionInfoPur] = "MSG_Auction.ReqAuctionInfoPur",
    [MSG_Auction.ReqAuctionInfoList] = "MSG_Auction.ReqAuctionInfoList",
    [MSG_Auction.ReqAuctionRecordList] = "MSG_Auction.ReqAuctionRecordList",
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

return MSG_Auction

