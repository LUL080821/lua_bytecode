------------------------------------------------
-- Author:
-- Date: 2021-06-22
-- File: CommunityMsgSystem.lua
-- Module: CommunityMsgSystem
-- Description: Community System Class
------------------------------------------------
-- Quote

--===============================================================--

local CommunityMsgSystem = {
   RoleId = nil,
   
   -- --Own community panel information data
   -- MyBoardData = nil,
   -- --Others' community panel information data
   -- OthersBoardData = nil,
   -- Current player information
   CurPlayerInfo = nil,
   --MSGlist
   LeaveMsgList = nil,
   DynamicList = nil,
   -- Return to your own community interface when determining whether to close it
   isNeedBackToSelf = false,
}

function CommunityMsgSystem:Initialize()

    
end

function CommunityMsgSystem:UnInitialize()
   self.MyBoardData = nil
   self.OthersBoardData = nil
end

-- Get a list of message information
function CommunityMsgSystem:GetLeaveMsgList()
   return self.LeaveMsgList
end

-- Get a list of personal dynamic information
function CommunityMsgSystem:GetDynamicMsgList()
   return self.DynamicList
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request player information
function CommunityMsgSystem:ReqPlayerCommunityInfo(palyerId)
   local _msg = ReqMsg.MSG_Community.ReqPlayerCommunityInfo:New()
   _msg.roleId = palyerId
   _msg:Send()
end

-- Update settings to the server Setting type 1, Decoration 2, Pendant 3, Personalized signature 4, Birthday 5, Are friends allowed to leave messages
function CommunityMsgSystem:ReqPlayerCommunityInfoSetting(type , data)
   local _msg = ReqMsg.MSG_Community.ReqPlayerCommunityInfoSetting:New()
   _msg.playerCommunityInfoSettingInfo = {}
   _msg.settingType = type
   if type == 1 then
      _msg.playerCommunityInfoSettingInfo.decorate = data
   elseif type == 2 then
      _msg.playerCommunityInfoSettingInfo.pendan = data
   elseif type == 3 then
      _msg.playerCommunityInfoSettingInfo.sign = data
   elseif type == 4 then
      _msg.playerCommunityInfoSettingInfo.brith = data
   elseif type == 5 then
      _msg.playerCommunityInfoSettingInfo.isNotFriendLeaveMsg = data
   end
   _msg:Send()
end


-- -==================================================--

-- Get a message list
function CommunityMsgSystem:ReqCommunityLeaveMessage(palyerId)
      local _msg = ReqMsg.MSG_Community.ReqCommunityLeaveMessage:New()
      _msg.roleId = palyerId
      _msg:Send()
end

-- Get dynamic list
function CommunityMsgSystem:ReqCommunityDynamic(palyerId)
      local _msg = ReqMsg.MSG_Community.ReqFriendCircle:New()
      _msg.roleId = palyerId
      _msg:Send()
end

-- Send a message
function CommunityMsgSystem:ReqAddCommunityLeaveMessage(palyerId , condition)
      local _msg = ReqMsg.MSG_Community.ReqAddCommunityLeaveMessage:New()
      _msg.roleId = palyerId
      _msg.condition = condition
      _msg:Send()
end

-- Delete a message
function CommunityMsgSystem:ReqDeleteCommunityLeaveMessage(palyerId , leaveMessageId)
      local _msg = ReqMsg.MSG_Community.ReqDeleteCommunityLeaveMessage:New()
      _msg.roleId = palyerId
      _msg.leaveMessageId = leaveMessageId
      _msg:Send()
end

-- Delete a dynamic
function CommunityMsgSystem:ReqCommunityDeletedDynamic(friendCircleId)
      local _msg = ReqMsg.MSG_Community.ReqDeleteFriendCircle:New()
      _msg.friendCircleId = friendCircleId
      _msg:Send()
end

-- Send a dynamic
function CommunityMsgSystem:ReqCommunityAddDynamic(palyerId , condition)
      local _msg = ReqMsg.MSG_Community.ReqSendFriendCircle:New()
      _msg.roleId = palyerId
      _msg.condition = condition
      _msg:Send()
end

-- Comment a news
function CommunityMsgSystem:ReqCommunityPingLunDynamic(palyerId , friendCircleId , commentCondition)
      local _msg = ReqMsg.MSG_Community.ReqCommentFriendCircle:New()
      _msg.targetRoleId = palyerId
      _msg.friendCircleId = friendCircleId
      _msg.commentCondition = commentCondition
      _msg:Send()
end



-- -==================================================--
-- Return to community information
function CommunityMsgSystem:ResPlayerCommunityInfo(msg)
      self.CurPlayerInfo = msg.playerCommunityInfo
      GameCenter.PushFixEvent(UILuaEventDefine.UICommunityMsgForm_OPEN)
end

-- Update settings information
function CommunityMsgSystem:ResPlayerCommunityInfoSetting(msg)
   GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_SETTING , msg)
end

-- Get a list of message information
function CommunityMsgSystem:ResCommunityLeaveMessage(msg)
   self.LeaveMsgList = msg.communityLeaveMessageInfoList
   GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_MSGBOARD_OPEN)
end

-- Get a list of personal dynamic information
function CommunityMsgSystem:ResCommunityDynamicMessage(msg)
   self.DynamicList = List:New()
   if msg.friendCircleInfo ~= nil then
      for i = 1, #msg.friendCircleInfo do
         self.DynamicList:Add(msg.friendCircleInfo[i])
      end
   end
   GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN , 1)
end

-- Received new updates
function CommunityMsgSystem:ResCommunityDynamicMsgAdd(info)
   self.DynamicList:Add(info.friendCircleInfo[1])
   GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN , 2)
end

-- Delete a dynamic
function CommunityMsgSystem:ResCommunityDynamicMsgDeleted(info)
   for i = 1, #self.DynamicList do
      if info.friendCircleInfo[1].friendCircleId == self.DynamicList[i].friendCircleId then
         self.DynamicList:RemoveAt(i)
         GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN , 3)
         return
      end
   end
   -- GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN , 3)
end

-- Refresh comments
function CommunityMsgSystem:ResCommunityDynamicMsgPingLun(info)
   for i = 1, #self.DynamicList do
      if info.friendCircleInfo[1].friendCircleId == self.DynamicList[i].friendCircleId then
         self.DynamicList[i].friendCircleLeaveMessageInfo = info.friendCircleInfo[1].friendCircleLeaveMessageInfo
      end
   end
   GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN , 4)
end

return CommunityMsgSystem
