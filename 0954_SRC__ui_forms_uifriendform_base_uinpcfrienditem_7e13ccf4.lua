------------------------------------------------
-- Author: Gao Ziyu
-- Date: 2021-07-13
-- File: UINPCFriendItem.lua
-- Module: UINPCFriendItem
-- Description: NPC friend system item
------------------------------------------------

local UINPCFriendItem = {
-- Level label
Lv = nil,
-- Red dot obj
RedPoint = nil,
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
--
CareerList = List:New(),

}

-- Open
function UINPCFriendItem:OnFirstShow(trans,parent)
    local _trans = trans
    self.gameObject = trans.gameObject
    self.Parent = parent
    local headCom = UIUtils.FindTrans(_trans, "Head/PlayerHeadLua")
    -- self.PlayerHead = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_trans, "Head/PlayerHeadLua/Icon"))
    self.PlayerHead = PlayerHead:New(headCom)
    self.RedPoint = UIUtils.FindGo(_trans , "RedPoint")
    self.Lv = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_trans , "Level"))
    self.GobjUnSelect = UIUtils.FindGo(_trans , "GobjUnSelect")
    self.GobjSelect = UIUtils.FindGo(_trans , "Select")
    self.Name = UIUtils.FindLabel(_trans , "Select/Name")
    self.NameUnSelect = UIUtils.FindLabel(_trans , "GobjUnSelect/Name")
    self.ChatBtn = UIUtils.FindBtn(_trans)
    self.sp = UIUtils.FindGo(_trans , "BG/Sprite")
    self.sp.gameObject:SetActive(true)

    self.RedPoint:SetActive(false)
    self.GobjSelect:SetActive(false)
    self.GobjUnSelect:SetActive(true)

    -- ========= Close unwanted nodes===================--
    self.Intimacy = UIUtils.FindGo(_trans , "Intimacy")
    self.Intimacy:SetActive(false)
    for i = 1, Occupation.Count do
        self.CareerList:Add(UIUtils.FindGo(_trans , "Career" .. i - 1))
    end
    for i = 0, #self.CareerList - 1 do
        self.CareerList[i + 1]:SetActive(false)
    end
    self.CareerList[2]:SetActive(true)
   
    self.ExpansionBtn = UIUtils.FindGo(_trans , "ExpansionBtn")
    self.ExpansionBtn:SetActive(false)
    -- ========= Close unwanted nodes===================--

end

-- Create an item
function UINPCFriendItem:New(obj)
    local _m = Utils.DeepCopy(self)
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

function UINPCFriendItem:Init(info)
    --Debug.LogTable(info.info.Icon)
    if info == nil then return end
    self.PlayerInfo = info.info
    self.PlayerInfo.playerId = info.info.Id
    if self.PlayerInfo.Level < 0 then
        self.PlayerInfo.Level = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    end
    self.Lv:SetLevel(self.PlayerInfo.Level, true)
    UIUtils.SetTextByString(self.Name , self.PlayerInfo.Name)
    UIUtils.SetTextByString(self.NameUnSelect , self.PlayerInfo.Name)
    self.PlayerHead:SetHead(self.PlayerInfo.Icon , nil , self.PlayerInfo.Occ , self.PlayerInfo.playerId , nil , false)
    
    self.FSBtn = UIUtils.FindBtn(self.gameObject.transform , "FriendShipBtn")
    self.FSBtn2 = UIUtils.FindBtn(self.gameObject.transform , "FriendShipBtn2")
    self.FSBtn.gameObject:SetActive(false)
    self.FSBtn2.gameObject:SetActive(false)
    UIUtils.AddBtnEvent(self.ChatBtn, self.OpenChatPrivateForm , self)
    self.FSBtnLabel = UIUtils.FindLabel(self.gameObject.transform , "FriendShipBtn/Label")
    self.FSSpriteGo = UIUtils.FindGo(self.gameObject.transform , "FriendShipBtn/Sprite")
    self.FSBtnLabel2 = UIUtils.FindLabel(self.gameObject.transform , "FriendShipBtn2/Label")
    self.FSSpriteGo2 = UIUtils.FindGo(self.gameObject.transform , "FriendShipBtn2/Sprite")

    UIUtils.AddBtnEvent(self.FSBtn, self.FriendshipBtnClick , self)
    UIUtils.AddBtnEvent(self.FSBtn2, self.FriendshipBtnClick , self)
    self:UpdateFriendshipState(GameCenter.NPCFriendSystem.CurNPCShipBtnType)
end

-- Open the chat interface
function UINPCFriendItem:OpenChatPrivateForm()
    self:SetSelection()
    local _sys = GameCenter.ChatPrivateSystem
    if _sys.currentChatPlayerId == self.PlayerInfo.Id and GameCenter.FormStateSystem:FormIsOpen("UIChatPrivateForm") then 
        return
    end
    _sys:ChatToPlayer(self.PlayerInfo.Id , self.PlayerInfo.Name , 1 ,self.PlayerInfo.Level, true, self.Parent.Parent.CSForm , true)
end

-- Selected
function UINPCFriendItem:OnSelection()
    self.GobjSelect:SetActive(true)
    self.GobjUnSelect:SetActive(false)
end

-- Cancel selected
function UINPCFriendItem:OnCancelSelection()
    self.GobjSelect:SetActive(false)
    self.GobjUnSelect:SetActive(true)
end

-- Set the selected status
function UINPCFriendItem:SetSelection()
    if self.Parent.SelectedItem ~= self then 
        self.Parent:OnCancelSelection()
        self.Parent.SelectedItem = self
        self:OnSelection()
    end

end

function UINPCFriendItem:UpdateFriendshipState()
   local type = GameCenter.NPCFriendSystem.CurNPCShipBtnType
   if type == FriendShipType.Send then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        -- UIUtils.SetAllChildColorGray(self.FSBtn.transform, false)
        self.FSSpriteGo:SetActive(false)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "Presented")
        self.isHaveShipCanRecvie = false
    elseif type == FriendShipType.HadSend then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "C_TARGET_YIZENGSONG")
        -- UIUtils.SetAllChildColorGray(self.FSBtn.transform, true)
        self.FSSpriteGo:SetActive(true)
        self.isHaveShipCanRecvie = false
    elseif type == FriendShipType.ReSend then
        self.FSBtn2.gameObject:SetActive(true)
        self.FSBtn.gameObject:SetActive(false)
        -- UIUtils.SetAllChildColorGray(self.FSBtn2.transform, false)
        self.FSSpriteGo2:SetActive(false)
        UIUtils.SetTextByEnum(self.FSBtnLabel2 , "C_TARGET_HUIZENG")
        self.isHaveShipCanRecvie = true
    elseif type == FriendShipType.Recvie then
        self.FSBtn2.gameObject:SetActive(true)
        self.FSBtn.gameObject:SetActive(false)
        -- UIUtils.SetAllChildColorGray(self.FSBtn2.transform, false)
        self.FSSpriteGo2:SetActive(false)
        UIUtils.SetTextByEnum(self.FSBtnLabel2 , "C_TARGET_LINGQU")
        self.isHaveShipCanRecvie = true
    elseif type == FriendShipType.Done then
        self.FSBtn2.gameObject:SetActive(false)
        self.FSBtn.gameObject:SetActive(true)
        UIUtils.SetTextByEnum(self.FSBtnLabel , "C_TARGET_YIHUZENG")
        -- UIUtils.SetAllChildColorGray(self.FSBtn.transform, true)
        self.FSSpriteGo:SetActive(true)
        self.isHaveShipCanRecvie = false
    end
end

function UINPCFriendItem:GetBtnTypeByInfo(info)
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
function UINPCFriendItem:FriendshipBtnClick()
    GameCenter.FriendSystem:ReqFriendShipEvent(0 , self.PlayerInfo.playerId , 2)
    if GameCenter.NPCFriendSystem.CurNPCShipBtnType == FriendShipType.ReSend then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP,1)-- I'll give back npc, npc speaks
    end
end



return UINPCFriendItem