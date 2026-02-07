local MSG_Auction = {}
local Network = GameCenter.Network

function MSG_Auction.RegisterMsg()

    Network.CreatRespond("MSG_Auction.ResAuctionInfoList",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionInfoList(msg)
    end)

    Network.CreatRespond("MSG_Auction.ResAuctionInfoOut",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionInfoOut(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionInfoPutSuccess",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionInfoPutSuccess(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionInfoPur",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionInfoPur(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResPersonAuctionRecordList",function (msg)
        --TODO
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_SELFRECORD_LIST, msg)
    end)


    Network.CreatRespond("MSG_Auction.ResWorldAuctionRecordList",function (msg)
        --TODO
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_AUCTION_WORLDRECORD_LIST, msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionPur",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionPur(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionUpdate",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionUpdate(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionDelete",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionDelete(msg)
    end)


    Network.CreatRespond("MSG_Auction.ResAuctionInfo",function (msg)
        --TODO
        GameCenter.AuctionHouseSystem:ResAuctionInfo(msg)
    end)

end
return MSG_Auction

