------------------------------------------------
-- Author: 
-- Date: 2021-07-06
-- File: UIFriendApplyItem.lua
-- Module: UIFriendApplyItem
-- Description: Friend item
------------------------------------------------

local UIFriendApplyItem = {
    -- Level label
    Lv = nil,
    -- Red dot obj
    RedPoint = nil,
    -- Career List
    CareerList = List:New(),
    -- Player avatar
    PlayerHead = nil,
    -- name
    Name = nil,
    -- Player information
    PlayerInfo = nil,
    -- item object
    gameObject = nil,
    -- Agree button
    AgreeBtn = nil,
    -- Reject button
    RefuseBtn = nil,
    -- Block this player application
    Tog = nil,
}

-- Create an item
function UIFriendApplyItem:New(obj)
    local _m = Utils.DeepCopy(self);
    _m.gameObject = obj.gameObject
    _m.OnFirstShow = self.OnFirstShow
    _m:OnFirstShow(obj)
    _m.Init = self.Init
    return _m
end

-- Open
function UIFriendApplyItem:OnFirstShow(trans)
    local _trans = trans
    local headCom = UIUtils.FindTrans(_trans, "Head/PlayerHeadLua")
    self.PlayerHead = PlayerHead:New(headCom)
    self.RedPoint = UIUtils.FindGo(_trans , "RedPoint")
    self.Lv = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_trans , "Level"))
    self.Name = UIUtils.FindLabel(_trans , "Name")
    self.AgreeBtn = UIUtils.FindBtn(_trans , "AgreeBtn")
    self.RefuseBtn = UIUtils.FindBtn(_trans , "RefuseBtn")
    self.Tog = UIUtils.FindToggle(_trans , "Tog")

    self.RedPoint:SetActive(false)

    self.CareerList:Clear()
    for i = 1, Occupation.Count do
        self.CareerList:Add(UIUtils.FindGo(_trans , "Career" .. i - 1))
    end

end

-- initialization
function UIFriendApplyItem:Init(info)
    if info == nil then return end
    self.PlayerInfo = info
    self.Lv:SetLevel(self.PlayerInfo.lv, true)
    UIUtils.SetTextByString(self.Name , self.PlayerInfo.name)
    self.PlayerHead:SetHeadByMsg(self.PlayerInfo.playerId, self.PlayerInfo.career, self.PlayerInfo.head)
    for i = 0, #self.CareerList - 1 do
        self.CareerList[i + 1]:SetActive(i == self.PlayerInfo.career)
    end
    UIUtils.AddBtnEvent(self.AgreeBtn, self.OnAgreeBtnClick , self)
    UIUtils.AddBtnEvent(self.RefuseBtn, self.OnRefuseBtnClick , self)
end

-- Agree button
function UIFriendApplyItem:OnAgreeBtnClick()
    local max = tonumber(DataConfig.DataGlobal[GlobalName.NearlyFriendMax].Params)
    if #GameCenter.FriendSystem.FriendList >= max then
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("FriendMaxSize"))
        return
    end
    self.PlayerInfo.isShieldAddFriend = self.Tog.value
    GameCenter.FriendSystem:ArgeeListAdd(self.PlayerInfo)
    GameCenter.FriendSystem:ReqApplyResult()
end

-- Reject button
function UIFriendApplyItem:OnRefuseBtnClick()
    self.PlayerInfo.isShieldAddFriend = self.Tog.value
    GameCenter.FriendSystem:RefuseListAdd(self.PlayerInfo)
    GameCenter.FriendSystem:ReqApplyResult()
end

-- Judge the red dot
function UIFriendApplyItem:IsRedPoint()
    if self.PlayerInfo ~= nil then 
        local _red = GameCenter.ChatPrivateSystem:IsHasUnReadMessage(self.PlayerInfo.playerId)
        self.RedPoint:SetActive(_red)
        return _red
    end
    return false
end

return UIFriendApplyItem