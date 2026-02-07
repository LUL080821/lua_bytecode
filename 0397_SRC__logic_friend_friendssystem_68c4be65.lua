------------------------------------------------
-- Author: Gao Ziyu
-- Date: 2021-03-05
-- File: FriendsSystem.lua
-- Module: FriendsSystem
-- Description: Friend system class
------------------------------------------------

local FriendsSystem = {
    -- Friend data
    FriendList = List:New(),
    -- Enemy data
    EnemyList = List:New(),
    -- Block data
    ShieldList = List:New(),
    -- Recommended List
    RecommendInfoList = List:New(),
    -- Query results
    DimSelectList = List:New(),
    -- Recent data
    RecentList = List:New(),
    -- List of requests to add friends
    ApplyList = List:New(),
    -- Send friends requested to the server
    ReqArgeeList = List:New(),
    -- Send friends that failed to request to the server
    ReqRefuseList = List:New(),

    -- Whether to refresh the list
    RefreshList = true,
    -- Whether to open the recent friend interface
    OpenRecentPanel = false,
    -- Is the friend interface displayed?
    FriendPanelEanble = false,
    -- Current Tab Page
    PageType = FriendType.Undefine,
    -- Delegation to obtain friend data
    Func = nil,
    -- Spouse Id
    MarryTargetId = 0,
    -- The number of times the gift points remain
    ResidueSendFriendShipCount = nil,
    -- Remaining the friendship point
    ResidueReciveFriendShipCount = nil,
    -- Friendship points obtained today
    FriendShip = 0,
    -- Have friends applied
    isHaveNewFriendApply = false,

}

-- initialization
function FriendsSystem:Initialize()
end

-- De-initialization
function FriendsSystem:UnInitialize()
    self.FriendList:Clear()
    self.EnemyList:Clear()
    self.ShieldList:Clear()
    self.RecommendInfoList:Clear()
    self.DimSelectList:Clear()
    self.RecentList:Clear()
    self.MarryTargetId = 0
end

-- Jump to private chat and add to the recent list first
function FriendsSystem:JumpToChatPrivate(roleID , roleName , career , level)
    if GameCenter.GameSceneSystem:GetLocalPlayerID() == roleID then 
        Utils.ShowPromptByEnum("C_FRIEND_CANNOT_CHATME")
        return
    end
    self.OpenRecentPanel = true
    self:AddRelation(FriendType.Recent , roleID)
end

-- Determine whether a friend is blocked
function FriendsSystem:IsShield(id)
    for i = 1, #self.ShieldList do
        if self.ShieldList[i].playerId == id then 
            return true
        end
    end
    return false
end

-- Determine whether a friend is an enemy
function FriendsSystem:IsEnemy(id)
    for i = 1, #self.EnemyList do
        if self.EnemyList[i].playerId == id then 
            return true
        end
    end
    return false
end

-- Determine whether you are a friend
function FriendsSystem:IsFriend(id)
    local isFriend = false
    for i = 1, #self.FriendList do
        if self.FriendList[i].playerId == id and self.FriendList[i].isFriend  then 
            isFriend = true
        end
    end
    -- for i = 1, #self.RecentList do
    --     if self.RecentList[i].isFriend  then 
    --         isFriend = true
    --     end
    -- end
    return isFriend
end

-- Determine whether there is no acceptance of friendship
function FriendsSystem:IsHaveShip()
    local isHaveShip = false
    for i = 1, #self.FriendList do
        if self:GetQYDTypeByPlayer(self.FriendList[i]) then 
            isHaveShip = true
        end
    end
    if isHaveShip == false then
        for i = 1, #self.RecentList do
            if self:GetQYDTypeByPlayer(self.RecentList[i]) then 
                isHaveShip = true
            end
        end
    end
    if GameCenter.NPCFriendSystem.CurNPC ~= nil and isHaveShip == false then
        isHaveShip = GameCenter.NPCFriendSystem.CurNPCShipBtnType == FriendShipType.Recvie or GameCenter.NPCFriendSystem.CurNPCShipBtnType == FriendShipType.ReSend
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Friend, isHaveShip )
    return isHaveShip
end

-- Get friends information
function FriendsSystem:GetFriend(id)
    for i = 1, #self.FriendList do
        if self.FriendList[i].playerId == id then 
            return self.FriendList[i]
        end
    end
    return nil
end

-- Determine whether it is a recommended list player
function FriendsSystem:IsRecommend(id)
    for i = 1, #self.RecommendInfoList do
        if self.RecommendInfoList[i].playerId == id then
            return true
        end
    end
    return false
end

-- Determine if it is the latest player
function FriendsSystem:IsRecent(id)
    for i = 1, #self.RecentList do
        if self.RecentList[i].playerId == id then 
            return true
        end
    end
    return false    
end

-- Get name
function FriendsSystem:GetName(id , type)
    local _name  = nil
    local _list = nil
    if     type == FriendType.Friend then 
        _list = self.FriendList
    elseif type == FriendType.Enemy  then
        _list = self.EnemyList
    elseif type == FriendType.Shield then
        _list = self.ShieldList
    elseif type == FriendType.Recent then
        _list = self.RecentList
    end

    if _list ~= nil then 
        for i = 1, #_list do
            if _list[i].playerID == id then 
                _name = _list[i].name
            end
        end
    end
    return _name
end

-- Get friends information
function FriendsSystem:GetFriendInfo(type , playerId)
    local _ret =  nil 
    local _list = nil

    if type == FriendType.Friend then 
        _list = self.FriendList
    elseif type == FriendType.Enemy then
        _list = self.EnemyList
    elseif type == FriendType.Shield then
        _list = self.ShieldList
    end

    if _list ~= nil then 
        for i = 1, #_list do
            if _list[i].playerId == playerId then 
                _ret = _list[i]
            end
        end
    end

    return _ret
end

-- Delete relationship secondary confirmation
function FriendsSystem:DeleteConfirmation(type , playerId)
    local _msg = nil
    if     type == FriendType.Friend then 
        _msg = DataConfig.DataMessageString.Get("C_MSG_FRIEND_IS_DELETE_FRIEND")
    elseif type == FriendType.Enemy then
        _msg = DataConfig.DataMessageString.Get("C_MSG_FRIEND_IS_DELETE_ENEMY")
    elseif type == FriendType.Shield then
        _msg = DataConfig.DataMessageString.Get("C_MSG_FRIEND_IS_DELETE_SHIELD")
    end

    GameCenter.MsgPromptSystem:ShowMsgBox(_msg , DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL") ,
                                                DataConfig.DataMessageString.Get("C_MSGBOX_OK")     ,
                                                function(x)
                                                    if x == MsgBoxResultCode.Button2 then
                                                        self:DeleteRelation(type , playerId)
                                                    end
                                                end,
                                                false , false , 5 , CS.Thousandto.Code.Logic.MsgInfoPriority.Highest )
end

-- Add enemy blocking secondary confirmation
function FriendsSystem:AddConfirmation(type , playerId)
    if self:IsMarryTarget(playerId) then 
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_FRIENT_FUQI_PINGBI"))
        return
    end
    local _friendInfo = self:GetFriend(playerId)
    if _friendInfo ~= nil and _friendInfo.intimacy > 0 then 
        GameCenter.MsgPromptSystem:ShowMsgBox(DataConfig.DataMessageString.Get("C_FRIENT_PINGBI_ASK") , 
            function (x)
                if x == MsgBoxResultCode.Button2 then
                    self:AddRelation(type , playerId)
                end
            end    
        )
    else
        local _msg = type == FriendType.Enemy and DataConfig.DataMessageString.Get("C_MSG_FRIEND_IS_ADD_ENEMY") or DataConfig.DataMessageString.Get("C_MSG_FRIEND_IS_ADD_SHIELD")
        GameCenter.MsgPromptSystem:ShowMsgBox( _msg , DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL") , 
                                                      DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                                                      function (x)
                                                            if x == MsgBoxResultCode.Button2 then 
                                                          self:AddRelation(type , playerId)
                                                            end
                                                      end , false , false , 5 , CS.Thousandto.Code.Logic.MsgInfoPriority.Highest )
    end 
end

-- Delete relationship 1 Friend 2 Enemy 3 Block
function FriendsSystem:DeleteRelation(type , playerId , targetServerId)
    self:ReqDeleteRelation( UnityUtils.GetObjct2Int(type) , playerId)
    if type == FriendType.Enemy or type == FriendType.Shield then
        self:AddRelation(FriendType.Recent , playerId , targetServerId)  
    end
end

-- Add relationship 1 Friend 2 Enemies 3 Block 5 Recent
function FriendsSystem:AddRelation( type , playerId , targetServerId)
    if targetServerId == nil then
        targetServerId = 0
    end
    if     type == FriendType.Friend then 
        local _friendMaxCount = tonumber( DataConfig.DataGlobal[1438].Params)
        if #self.FriendList >= _friendMaxCount then 
            self:ShowInfoMsg(DataConfig.DataMessageString.Get("C_FRIEND_ADD_FULL"))
            return
        end
        self:ShowInfoMsg(DataConfig.DataMessageString.Get("C_SendFriendApply"))
    elseif type == FriendType.Enemy then
        local _enemyMaxCount = tonumber( DataConfig.DataGlobal[1439].Params  )
        if #self.EnemyList >= _enemyMaxCount then 
            self:ShowInfoMsg(DataConfig.DataMessageString.Get("C_FRIEND_ADDCHOUREN_FULL"))
            return
        end
    elseif type == FriendType.Shield then
        local _shieldMaxCount = tonumber( DataConfig.DataGlobal[1440].Params )
        if #self.ShieldList >= _shieldMaxCount then 
            self:ShowInfoMsg(DataConfig.DataMessageString.Get("C_FRIEND_ADDHEIMINGDAN_FULL"))
            return
        end
    end

    self:ReqAddRelation(type , playerId , targetServerId)

    if type == FriendType.Enemy then 
        self:ReqAddRelation(FriendType.Recent , playerId , targetServerId)
    end
end

-- Is it a marriage partner?
function FriendsSystem:IsMarryTarget(uid)
    return uid == self.MarryTargetId
end

-- Assign value to the list
function FriendsSystem:AddValueToList( list_1 , list_2)
    list_1:Clear()
    if list_2 ~= nil  and  #list_2 > 0 then 
        for i = 1, #list_2 do
            list_1:Add(list_2[i])
        end
    end
end

-- Prompt information
function FriendsSystem:ShowInfoMsg( showString )
    GameCenter.MsgPromptSystem:ShowPrompt(showString)
end

-- Sort
function FriendsSystem:OnSortData(list)
    list:Sort(
        function(a , b)
        if a.isOnline and not b.isOnline then 
            return true 
        elseif (a.isOnline == b.isOnline) then
            if a.intimacy ~= nil and b.intimacy ~= nil then
                if a.intimacy > b.intimacy then 
                    return true
                elseif a.intimacy == b.intimacy then
                    if a.lv > b.lv then
                        return true
                    else 
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end)
end

-- Sorting logic method


-- Request Friend List 1 Friend, 2 Enemies, 3 Blocked, 4 Request Recommended Friends, 5 Recent Chat List
function FriendsSystem:ReqGetRelationList(type , isShowWitingForm)
    if isShowWitingForm == nil then 
        isShowWitingForm = true
    end
    if type ~= FriendType.Undefine then 
        local _msg = ReqMsg.MSG_Friend.ReqGetRelationList:New()
        _msg.type = UnityUtils.GetObjct2Int(type)
        _msg:Send()
        if isShowWitingForm then 
            GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN)
        end
    end
end

-- External call Request friend list 1 friend, 2 enemy, 3 blocked, 4 request recommended friend, 5 recent chat list
function FriendsSystem:ReqExternalGetRelationList(type , func)
    self.Func = func 
    local _msg = ReqMsg.MSG_Friend.ReqGetRelationList:New()
    _msg.type = UnityUtils.GetObjct2Int(type)
    _msg:Send()
end

-- Delete relationship 1 Friend 2 Enemy 3 Block
function FriendsSystem:ReqDeleteRelation(type , playerId)
    local _msg = ReqMsg.MSG_Friend.ReqDeleteRelation:New()
    _msg.type = type
    _msg.targetPlayerId = playerId
    _msg:Send()
end

-- Add relationship 1 friend, 2 enemies, 3 blocking
function FriendsSystem:ReqAddRelation(type , playerId , targetServerId)
    local _msg = ReqMsg.MSG_Friend.ReqAddRelation:New()
    _msg.type = UnityUtils.GetObjct2Int(type)
    _msg.targetPlayerId = playerId
    _msg.targetServerId = targetServerId
    _msg:Send()
end

-- Find friends -> Match names
function FriendsSystem:ReqDimSelect(name)
    local _msg = ReqMsg.MSG_Friend.ReqDimSelect:New()
    _msg.name = name
    _msg:Send()
end

-- report
function FriendsSystem:ReqReport(playerId , type ,content)
    local _msg = ReqMsg.MSG_Friend.ReqReport:New()
    _msg.roleId = playerId
    _msg.type = type
    _msg.context = content
    _msg:Send()
end

-- Server returns data
function FriendsSystem:ResFriendList(msg)
    if msg == nil then
        return
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE)
    self.MarryTargetId = msg.marryTargetId
    if msg.type == 1 then
        self:AddValueToList(self.FriendList , msg.resultList)
        self:AddValueToList(self.RecentList , msg.resultList)
        self:OnSortData(self.FriendList)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_FRIENDSHIP)
    elseif msg.type == 2 then
        self:AddValueToList(self.EnemyList , msg.resultList)
        self:OnSortData(self.EnemyList)
    elseif msg.type == 3 then
        self:AddValueToList(self.ShieldList , msg.resultList)
    elseif msg.type == 4 then
        self:AddValueToList(self.RecommendInfoList , msg.resultList)
        self:OnSortData(self.RecommendInfoList)
    elseif msg.type == 5 then
        self:AddValueToList(self.RecentList , msg.resultList)
    end

    if msg.type == 4 then 
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_SEARCHFRIENDPANEL , nil)
    end
    if self.FriendPanelEanble and self.RefreshList then 
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_FRIENDLIST , msg.type)
    end
    if self.Func ~= nil then 
        local _list = List:New()
        self:AddValueToList(_list , msg.resultList)
        self.Func(_list)
        self.Func = nil
        return
    end
end

-- The server returns the list of successfully deleted relationships //1 friend, 2 enemy, 3 blocked, 4 recommended friends, 5 recent chat list
function FriendsSystem:ResDeleteRelationSuccess(msg)
    if msg == nil then
        return
    end
    local _list = nil
    local _msgStr = nil
    if msg.type == UnityUtils.GetObjct2Int(FriendType.Friend) then 
        _list = self.FriendList
        _msgStr = DataConfig.DataMessageString.Get("C_MSG_FRIEND_DELETEFRIENDSUC")
    elseif msg.type == UnityUtils.GetObjct2Int(FriendType.Enemy) then
        _list = self.EnemyList
        _msgStr = DataConfig.DataMessageString.Get("C_MSG_FRIEND_DELETENISUC")
    elseif msg.type == UnityUtils.GetObjct2Int(FriendType.Shield) then
        _list = self.ShieldList
        _msgStr = DataConfig.DataMessageString.Get("C_MSG_FRIEND_DELETESHIELDSUC")
    end
    for i = 1, #_list do
        if _list[i].playerId == msg.targetPlayerId then 
            _list:RemoveAt(i)
            break
        end
    end
    self:ShowInfoMsg(_msgStr)

    if self.FriendPanelEanble then 
        self:ReqGetRelationList(self.PageType)
    end
end

-- The server returns the relationship to be added successfully
function FriendsSystem:ResAddFriendSuccess(msg)
    if msg == nil then
        return
    end
    local _msgStr = nil 
    if msg.type == UnityUtils.GetObjct2Int(FriendType.Friend) then 
        self.FriendList:Add(msg.resultList)
        self.RecentList:Add(msg.resultList)
        self:OnSortData(self.FriendList)
    elseif msg.type == UnityUtils.GetObjct2Int(FriendType.Enemy) then
        self.EnemyList:Add(msg.resultList)
        self:OnSortData(self.EnemyList)
        _msgStr = DataConfig.DataMessageString.Get("C_MSG_FRIEND_ADDENIMYSUC")
    elseif msg.type == UnityUtils.GetObjct2Int(FriendType.Shield) then
        self.ShieldList:Add(msg.resultList)
        for i = 1, #self.FriendList do
            if self.FriendList[i].playerId == msg.resultList.playerId then 
                self.FriendList:RemoveAt(i)
                break
            end
        end
        self:OnSortData(self.ShieldList)
        _msgStr = DataConfig.DataMessageString.Get("C_MSG_FRIEND_ADDSHIELDSUC")
    elseif msg.type == UnityUtils.GetObjct2Int(FriendType.Recent) then
        self.RecentList:Add(msg.resultList)
    end
    self:ShowInfoMsg(_msgStr)

    if msg.type == UnityUtils.GetObjct2Int(FriendType.Recent) then
        if self.OpenRecentPanel and  not self.FriendPanelEanble then
            self.OpenRecentPanel = false
            GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN , SocialityFormSubPanel.RecentFriend)
        elseif self.OpenRecentPanel and self.FriendPanelEanble then
            self.OpenRecentPanel = false
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FRIEND_OPEN_FRIENDPANEL , FriendType.Recent)
        end
        return
    end

    if self.FriendPanelEanble then 
        self:ReqGetRelationList(self.PageType)
    end
end

-- The server returns the query result
function FriendsSystem:ResDimSelectList(msg)
    if msg == nil then
        return
    end
    if msg.list == nil or #msg.list == 0 then 
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_FRIEND_ID_ERROR"))
        return 
    end
    self:AddValueToList(self.DimSelectList , msg.list)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_FRIEND_UPDATE_SEARCHFRIENDPANEL , FriendType.Search)
end

-- The server returns a friend's request for personal request
function FriendsSystem:ResApproval(msg)
    local isNew = true
    for i = 1, #self.ApplyList do
        if msg.playerId == self.ApplyList[i].playerId then
            -- Players have been included, new
            isNew = false
            break
        end
    end
    if isNew then
        self.ApplyList:Add(msg)
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_GetFriendApply"))
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIENDAPPLY_REFESH)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC, true)
        self.isHaveNewFriendApply = true
    end
end

-- Judge the status of the friendship point button
function FriendsSystem:GetQYDTypeByInfo(msg)
    local playerInfo
    if msg.npcFriendInfo then
        playerInfo = msg.npcFriendInfo
    elseif msg.friendInfo then
        playerInfo = msg.friendInfo
    end
    local QYDSendR = Utils.SplitStr( DataConfig.DataGlobal[GlobalName.qingyi_send_goods_max].Params , "_")
    local QYDReciveR = Utils.SplitStr( DataConfig.DataGlobal[GlobalName.qingyi_recive_goods_max].Params , "_")

    local type = FriendShipType.Send
    if not playerInfo.isGiveFriendshipPoint and not playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.Send
    elseif playerInfo.isGiveFriendshipPoint and not playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.HadSend
        local str = ""
        if msg.residueGiveRewardCount > 0 then
            str = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_1"), QYDSendR[1] ,msg.residueGiveRewardCount)
        else
            str = DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_3")
        end
        GameCenter.MsgPromptSystem:ShowPrompt(str)
        -- Judgment is npc automatically rewarded
        if msg.npcFriendInfo ~= nil then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP,1)-- 1 = I give it to npc npc
            GameCenter.FriendSystem:ReqNpcFriendGiveShipPoint(msg.npcFriendInfo.npcId)
        end
    elseif not playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.ReSend
        local str = ""
        if msg.residueReceiveRewardCount > 0 then
            str = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_2"), QYDReciveR[1] ,msg.residueReceiveRewardCount)
        else
            str = DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_4")
        end
        GameCenter.MsgPromptSystem:ShowPrompt(str)
        if msg.npcFriendInfo ~= nil then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP,2)-- 2 = npc gift to me npc speaking
        end
    elseif playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.Recvie
    elseif playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and playerInfo.isFriendshipPointAward then
        type = FriendShipType.Done
        local str = ""
        if msg.residueReceiveRewardCount > 0 then
            str = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_5"), QYDReciveR[1] ,msg.residueReceiveRewardCount)
        else
            str = DataConfig.DataMessageString.Get("C_FRIENDSHIP_NOTIC_6")
        end
        GameCenter.MsgPromptSystem:ShowPrompt(str)
    end

    return type
end

-- Determine the status of the friendship point button separately
function FriendsSystem:GetQYDTypeByPlayer(data)
    local playerInfo = nil
    if data.isGiveFriendshipPoint ~= nil then
        playerInfo = data
    else
        playerInfo = data[1]
    end
    local type = FriendShipType.Send
    if not playerInfo.isGiveFriendshipPoint and not playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.Send
    elseif playerInfo.isGiveFriendshipPoint and not playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.HadSend
    elseif not playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.ReSend
    elseif playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and not playerInfo.isFriendshipPointAward then
        type = FriendShipType.Recvie
    elseif playerInfo.isGiveFriendshipPoint and playerInfo.isReceiveFriendshipPoint and playerInfo.isFriendshipPointAward then
        type = FriendShipType.Done
    end
    if type == FriendShipType.ReSend or type == FriendShipType.Recvie then
        return true
    else
        return false
    end
end

-- The server returns to the friend application list
function FriendsSystem:ResApprovalList(msg)
    self.ApplyList = msg
    if #self.ApplyList > 0 then
        self.isHaveNewFriendApply = true
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC, true)
    else
        self.isHaveNewFriendApply = false
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC, false)
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIENDAPPLY_REFESH)
end

-- The server returns the friend approval result
function FriendsSystem:ResApprovalResult(msg , type)
    if type == 1 then
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_MSG_FRIEND_ADDFRIEND_SUCESS"))
    elseif type == 2 then
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_RefuseFriendApply"))
    end
    self.ApplyList = msg
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FRIENDAPPLY_REFESH)
end

-- Get a friend application list
function FriendsSystem:GetApplyList()
    return self.ApplyList
end

-- Agree to add a friend's consent list
function FriendsSystem:ArgeeListAdd(info)
    self.ReqArgeeList:Clear()
    self.ReqRefuseList:Clear()
    self.ReqArgeeList:Add(info)
end

-- Reject list of friends that refuse to add
function FriendsSystem:RefuseListAdd(info)
    self.ReqRefuseList:Clear()
    self.ReqArgeeList:Clear()
    self.ReqRefuseList:Add(info)
end

-- Send application results to the server
function FriendsSystem:ReqApplyResult()
    local _msg = ReqMsg.MSG_Friend.ReqAddFriendApproval:New()
    _msg.agreeList = self.ReqArgeeList
    _msg.declineList = self.ReqRefuseList
    _msg:Send()
end

-- Send a friendship point request to the server
function FriendsSystem:ReqFriendShipEvent(type , playerId , isNpc)
    local _msg = ReqMsg.MSG_Friend.ReqGiveFriendShipPoint:New()
    if isNpc == nil then
        isNpc = 1
    end
    _msg.type = type
    _msg.friendPlayerId = playerId
    _msg.friendType = isNpc
    _msg:Send()
end

function FriendsSystem:ReqNpcFriendGiveShipPoint(id)
    local _msg = ReqMsg.MSG_Friend.ReqNpcFriendGiveShipPoint:New()
    _msg.npcId = id
    _msg:Send()
    
end

return FriendsSystem