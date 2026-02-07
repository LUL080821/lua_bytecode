------------------------------------------------
-- Author: 
-- Date: 2021-03-01
-- File: UIFriendBaseItem.lua
-- Module: UIFriendBaseItem
-- Description: Friend item
------------------------------------------------

local UIFriendBaseItem = {
    -- Level label
    Lv = nil,
    -- Intimacy
    Intimacy = nil,
    -- Red dot obj
    RedPoint = nil,
    -- Career List
    CareerList = List:New(),
    -- Expansion button
    ExpansionBtn = nil,
    -- Chat button
    ChatBtn = nil,
    -- relation
    Realation = nil,
    -- Player avatar
    PlayerHead = nil,
    -- The interface
    Parent = nil,
    -- Selected
    GobjSelect = nil,
    -- name
    Name = nil,
    -- Online
    Online = nil,
    -- Offline
    OffLine = nil,
    -- Not selected
    GobjUnSelect = nil,
    -- The name not selected
    NameUnSelect = nil,
    -- Not selected online
    OnLineUnSelect = nil,
    -- Not selected offline
    OffLineUnSelect = nil,
    -- Relationship text
    TxtRelation = nil,
    -- Player information
    PlayerInfo = nil,
    -- item object
    gameObject = nil,
    -- Friendship Point Button 1, 2
    FSBtn = nil,
    FSBtn2 = nil,
    -- Friendship Point Button 1, 2 Text
    FSBtnLabel = nil,
    FSBtnLabel2 = nil,
    -- First time display
    isFirstShow = true,
    -- Is there a friendship point that has not been received yet?
    isHaveShipCanRecvie = false,
}

-- Create an item
function UIFriendBaseItem:New(obj)
    local _m = Utils.DeepCopy(self);
    _m.gameObject = obj
    _m.OnFirstShow = self.OnFirstShow
    _m.Init = self.Init
    _m.OnExpansionBtnClick = self.OnExpansionBtnClick
    _m.OpenChatPrivateForm = self.OpenChatPrivateForm
    _m.OnSelection = self.OnSelection
    _m.OnCancelSelection = self.OnCancelSelection
    _m.SetSelection = self.SetSelection
    _m.SetIntimacy = self.SetIntimacy
    _m.IsRedPoint = self.IsRedPoint
    _m.PlayerInfo = self.PlayerInfo
    return _m
end

-- Open
function UIFriendBaseItem:OnFirstShow(trans,parent)
    local _trans = trans
    self.gameObject = trans.gameObject
    self.Parent = parent
    self.Realation = UIUtils.FindTrans(_trans , "Relation")
    local headCom = UIUtils.FindTrans(_trans, "Head/PlayerHeadLua")
    self.PlayerHead = PlayerHead:New(headCom)
    self.TxtRelation = UIUtils.FindLabel(_trans , "Relation/Label")
    self.RedPoint = UIUtils.FindGo(_trans , "RedPoint")
    self.Lv = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_trans , "Level"))
    self.Intimacy = UIUtils.FindLabel(_trans , "Intimacy")
    self.GobjUnSelect = UIUtils.FindGo(_trans , "GobjUnSelect")
    self.GobjSelect = UIUtils.FindGo(_trans , "Select")
    self.Name = UIUtils.FindLabel(_trans , "Select/Name")
    self.Online = UIUtils.FindGo(_trans , "Select/OnLine")
    self.OffLine = UIUtils.FindGo(_trans , "Select/OffLine")
    self.NameUnSelect = UIUtils.FindLabel(_trans , "GobjUnSelect/Name")
    self.OnLineUnSelect = UIUtils.FindGo(_trans , "GobjUnSelect/OnLine")
    self.OffLineUnSelect = UIUtils.FindGo(_trans , "GobjUnSelect/OffLine")
    self.ChatBtn = UIUtils.FindBtn(_trans)
    self.sp = UIUtils.FindGo(_trans , "BG/Sprite")
    if self.sp ~= nil then
        self.sp.gameObject:SetActive(false)
    end

    self.RedPoint:SetActive(false)
    self.GobjSelect:SetActive(false)
    self.GobjUnSelect:SetActive(true)

    self.CareerList:Clear()
    for i = 1, Occupation.Count do
        self.CareerList:Add(UIUtils.FindGo(_trans , "Career" .. i - 1))
    end
    self.ExpansionBtn = UIUtils.FindBtn(_trans , "ExpansionBtn")
    self.ExpansionBtn.gameObject:SetActive(true)
end

-- initialization
function UIFriendBaseItem:Init(info , isShield)
    if info == nil then return end
    self.PlayerInfo = info
    self.Lv:SetLevel(self.PlayerInfo.lv, true)
    UIUtils.SetTextByString(self.Name , self.PlayerInfo.name)
    UIUtils.SetTextByString(self.NameUnSelect , self.PlayerInfo.name)
    self.Online:SetActive(self.PlayerInfo.isOnline)
    self.OffLine:SetActive( not self.PlayerInfo.isOnline)
    self.OnLineUnSelect:SetActive(self.PlayerInfo.isOnline)
    self.OffLineUnSelect:SetActive(not self.PlayerInfo.isOnline)
    self.PlayerHead:SetHeadByMsg(self.PlayerInfo.playerId, self.PlayerInfo.career, self.PlayerInfo.head)
    for i = 0, #self.CareerList - 1 do
        self.CareerList[i + 1]:SetActive(i == self.PlayerInfo.career)
    end
    -- if GameCenter.FriendSystem:IsFriend( self.PlayerInfo.playerId ) then 
    --     self.Realation.gameObject:SetActive(true)
    --     if GameCenter.FriendSystem:IsMarryTarget(self.PlayerInfo.playerId) then
    --         UIUtils.SetTextByString(self.TxtRelation , DataConfig.DataMessageString.Get("C_FRIEND_FUQI")) 
    --     else
    --         UIUtils.SetTextByString(self.TxtRelation , DataConfig.DataMessageString.Get("SOCIAL_FRIEND")) 
    --     end
    --     self.Intimacy.gameObject:SetActive(true)
    --     UIUtils.SetTextByNumber(self.Intimacy , self.PlayerInfo.intimacy)
    -- else
    if info.isFriend then 
        self.Realation.gameObject:SetActive(true)
        if GameCenter.FriendSystem:IsMarryTarget(self.PlayerInfo.playerId) then
            UIUtils.SetTextByString(self.TxtRelation , DataConfig.DataMessageString.Get("C_FRIEND_FUQI")) 
        else
            UIUtils.SetTextByString(self.TxtRelation , DataConfig.DataMessageString.Get("SOCIAL_FRIEND")) 
        end
        self.Intimacy.gameObject:SetActive(true)
        UIUtils.SetTextByNumber(self.Intimacy , self.PlayerInfo.intimacy)
    else
        self.Realation.gameObject:SetActive(false)
        self.Intimacy.gameObject:SetActive(false)
    end
    if not isShield then
        self.FSBtn = UIUtils.FindBtn(self.gameObject.transform , "FriendShipBtn")
        self.FSBtn2 = UIUtils.FindBtn(self.gameObject.transform , "FriendShipBtn2")
        self.FSBtn.gameObject:SetActive(false)
        self.FSBtn2.gameObject:SetActive(false)
        UIUtils.AddBtnEvent(self.ChatBtn, self.OpenChatPrivateForm , self)
    end 
    if info.isFriend then
        self.FSBtnLabel = UIUtils.FindLabel(self.gameObject.transform , "FriendShipBtn/Label")
        self.FSBtnLabel2 = UIUtils.FindLabel(self.gameObject.transform , "FriendShipBtn2/Label")
        self.FSSpriteGo = UIUtils.FindGo(self.gameObject.transform , "FriendShipBtn/Sprite")
        self.FSSpriteGo2 = UIUtils.FindGo(self.gameObject.transform , "FriendShipBtn2/Sprite")
        UIUtils.AddBtnEvent(self.FSBtn, self.FriendshipBtnClick , self)
        UIUtils.AddBtnEvent(self.FSBtn2, self.FriendshipBtnClick , self)
        local type = self:GetBtnTypeByInfo(info)
        self:UpdateFriendshipState(info , type)
    elseif not info.isFriend and not isShield then
        self.FSBtn.gameObject:SetActive(false)
        self.FSBtn2.gameObject:SetActive(false)
    end
    UIUtils.AddBtnEvent(self.ExpansionBtn, self.OnExpansionBtnClick , self)
    if not isShield  and GameCenter.ChatPrivateSystem.currentChatPlayerId == self.PlayerInfo.playerId then
        self:OpenChatPrivateForm()
    end
end

-- Expansion button
function UIFriendBaseItem:OnExpansionBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LookOtherPlayer , self.PlayerInfo.playerId)
end

-- Open the chat interface
function UIFriendBaseItem:OpenChatPrivateForm()
    self:SetSelection()
    local _sys = GameCenter.ChatPrivateSystem
    if _sys.currentChatPlayerId == self.PlayerInfo.playerId and GameCenter.FormStateSystem:FormIsOpen("UIChatPrivateForm") then 
        return
    end
    _sys:ChatToPlayer(self.PlayerInfo.playerId , self.PlayerInfo.name , self.PlayerInfo.career ,self.PlayerInfo.lv, self.PlayerInfo.isOnline, self.Parent.Parent.CSForm)
    if GameCenter.FriendSystem:IsFriend(self.PlayerInfo.playerId) then 
        GameCenter.FriendSystem:AddRelation(FriendType.Recent , self.PlayerInfo.playerId)
    end
end

-- Selected
function UIFriendBaseItem:OnSelection()
    self.GobjSelect:SetActive(true)
    self.GobjUnSelect:SetActive(false)
end

-- Cancel selected
function UIFriendBaseItem:OnCancelSelection()
    self.GobjSelect:SetActive(false)
    self.GobjUnSelect:SetActive(true)
end

-- Set the selected status
function UIFriendBaseItem:SetSelection()
    if self.Parent.SelectedItem ~= self then 
        self.Parent:OnCancelSelection()
        self.Parent.SelectedItem = self
        self:OnSelection()
    end

end

-- Set intimacy
function UIFriendBaseItem:SetIntimacy(value)
    UIUtils.SetTextByNumber(self.Intimacy , value)
end

-- Judge the red dot
function UIFriendBaseItem:IsRedPoint()
    if self.PlayerInfo ~= nil then 
        local _red = GameCenter.ChatPrivateSystem:IsHasUnReadMessage(self.PlayerInfo.playerId)
        self.RedPoint:SetActive(_red)
        return _red
    end
    return false
end

function UIFriendBaseItem:UpdateFriendshipState(playerInfo,type)
    self.PlayerInfo = playerInfo
   if type == FriendShipType.Send then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        --UIUtils.SetAllChildColorGray(self.FSBtn.transform, false)
        --self.FSBtn.transform.isEnabled=true
        self.FSSpriteGo:SetActive(false)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "Presented")
        self.isHaveShipCanRecvie = false
    elseif type == FriendShipType.HadSend then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "C_TARGET_YIZENGSONG")
        --UIUtils.SetAllChildColorGray(self.FSBtn.transform, true)
        --self.FSBtn.transform.isEnabled=false
        self.FSSpriteGo:SetActive(true)
        self.isHaveShipCanRecvie = false
    elseif type == FriendShipType.ReSend then
        self.FSBtn2.gameObject:SetActive(true)
        self.FSBtn.gameObject:SetActive(false)
        --UIUtils.SetAllChildColorGray(self.FSBtn2.transform, false)
        UIUtils.SetTextByEnum(self.FSBtnLabel2 , "C_TARGET_HUIZENG")
        --self.FSBtn2.transform.isEnabled=true
        self.FSSpriteGo2:SetActive(false)
        self.isHaveShipCanRecvie = true
    elseif type == FriendShipType.Recvie then
        self.FSBtn2.gameObject:SetActive(true)
        self.FSBtn.gameObject:SetActive(false)
        --UIUtils.SetAllChildColorGray(self.FSBtn2.transform, false)
        UIUtils.SetTextByEnum(self.FSBtnLabel2 , "C_TARGET_LINGQU")
        --self.FSBtn2.transform.isEnabled=true
        self.FSSpriteGo2:SetActive(false)
        self.isHaveShipCanRecvie = true
    elseif type == FriendShipType.Done then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "C_TARGET_YIHUZENG")
        --UIUtils.SetAllChildColorGray(self.FSBtn.transform, true)
        --self.FSBtn.transform.isEnabled=false
        self.FSSpriteGo:SetActive(true)
        self.isHaveShipCanRecvie = false
    end
end

function UIFriendBaseItem:GetBtnTypeByInfo(info)
    local type = nil
    if not info.isGiveFriendshipPoint and not info.isReceiveFriendshipPoint and not info.isFriendshipPointAward then
        type = FriendShipType.Send
    elseif info.isGiveFriendshipPoint and not info.isReceiveFriendshipPoint and not info.isFriendshipPointAward then
        type = FriendShipType.HadSend
    elseif not info.isGiveFriendshipPoint and info.isReceiveFriendshipPoint and not info.isFriendshipPointAward then
        type = FriendShipType.ReSend
    elseif info.isGiveFriendshipPoint and info.isReceiveFriendshipPoint and not info.isFriendshipPointAward then
        type = FriendShipType.Recvie
    elseif info.isGiveFriendshipPoint and info.isReceiveFriendshipPoint and info.isFriendshipPointAward then
        type = FriendShipType.Done
    end
    return type
end

-- Career Point Button Event
function UIFriendBaseItem:FriendshipBtnClick()
    GameCenter.FriendSystem:ReqFriendShipEvent( 0 , self.PlayerInfo.playerId) -- 0 represents single 1 represents all
end

return UIFriendBaseItem