------------------------------------------------
-- Author: 
-- Date: 2020-7-29
-- File: PresentSystem.lua
-- Module: PresentSystem
-- Description: Gift Gift System
------------------------------------------------
local PresentSystem = {
    SendData = nil,
    RecData = nil
}

function PresentSystem:Initialize()

end

function PresentSystem:UnInitialize()
    self.SendData = nil;
    self.RecData = nil;
end

-- Are there any items to give away?
function PresentSystem:IsHavePresent()
    local _isHave = false;
    local _func = function(k, v)
        if GameCenter.ItemContianerSystem:GetItemCountFromCfgId(v.Id) > 0 then
            _isHave = true;
            return true;
        end
    end
    DataConfig.DataItemGift:ForeachCanBreak(_func)
    return _isHave;
end

function PresentSystem:IsRedpoint()
    return self:GetNotReadPresentCount() > 0;
end

function PresentSystem:GetNotReadPresentCount()
    local _count = 0;
    if self.RecData then
        for i = 1, #self.RecData do
            if self.RecData[i].readStatus == 0 then
                _count = _count + 1;
            end
        end
    end
    return _count;
end

-- Is it successful to return to the gift of friends?
function PresentSystem:ReqReadGiftLog(ids)
    local _req = ReqMsg.MSG_Player.ReqReadGiftLog:New();
    _req.ids = ids;
    _req:Send();
end

-- Is it successful to return to the gift of friends?
function PresentSystem:ResSendGift(msg)
    if msg.result == 0 then
        if not self.SendData then
            self.SendData = {}
        end
        if msg.log and #msg.log > 0 then
            for i = 1, #msg.log do
                table.insert(self.SendData, msg.log[i])
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SENDGIFT_RESULT, msg)
end

-- required int32 type = 1; //0 send, 1 receive
-- repeated GiftLog recordList = 2; //Log list
-- Receive and gift log return
function PresentSystem:ResGetGiftLog(msg)
    local _list = msg.recordList or {}
    local _cnt = #_list

    if msg.type == 0 then
        self.SendData = msg.recordList;
    elseif msg.type == 1 then
        self.RecData = msg.recordList;
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SENDGIFT_LOG_UPDATE)
end

-- New gift receiving log
function PresentSystem:ResNewGiftLog(msg)
    if not self.RecData then
        self.RecData = {}
    end
    if msg.log and #msg.log > 0 then
        for i = 1, #msg.log do
            table.insert(self.RecData, msg.log[i])
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SENDGIFT_LOG_UPDATE)
end

-- Read Return
function PresentSystem:ResReadGiftLog(msg)
    if self.RecData and msg.ids and #msg.ids > 0 then
        for i = 1, #msg.ids do
            for j = 1, #self.RecData do
                if msg.ids[i] == self.RecData[j].id then
                    self.RecData[j].readStatus = 1;
                end
            end
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_SENDGIFT_LOG_UPDATE)
end

return PresentSystem

-- message Gift {
-- required int32 giftId = 1;//id in item.gift table
-- 	required int32 giftNumber = 2;
-- }

-- message ReqSendGift {
-- 	enum MsgID { eMsgID = 105241; };
-- 	required int32 type = 1;
-- required int64 roleId = 2;//The player id to be given
-- required bool force = 3;//true means forced gift, false means no forced gift
-- 	repeated Gift gifts = 4;
-- }

-- message ResSendGift {
-- 	enum MsgID { eMsgID = 105141; };
-- required int32 result = 1;//0 means the gift is successful, 1 means I am not the other party’s friend
-- }

-- message GiftLog {
-- 	required int64 id = 1;				//id
-- required int32 type = 2; //0 send, 1 receive
-- required string sender = 3; //Sender
-- required string receiver = 4; //Recipient
-- required int32 itemId = 5; //item id
-- required int32 num = 6; //Quantity
-- required int32 time = 7; //Send time
-- required int32 readStatus = 8; //Read status
-- }

-- message ReqGetGiftLog {
-- 	enum MsgID { eMsgID = 105242; };
-- required int32 type = 1; //0 send, 1 receive
-- }

-- message ReqReadGiftLog {
-- 	enum MsgID { eMsgID = 105245; };
-- repeated int64 ids = 1; //Read the list of ids of the gift received
-- }

-- message ResNewGiftLog {
-- 	enum MsgID { eMsgID = 105146; };
-- required GiftLog log = 1; //Added gift log
-- }
