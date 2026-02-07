------------------------------------------------
-- Author: 
-- Date: 2021-03-03
-- File: UIRecentRoot.lua
-- Module: UIRecentRoot
-- Description: Recent Friends column
------------------------------------------------
local L_UIFriendBaseItem = require("UI.Forms.UIFriendForm.Base.UIFriendBaseItem")
local L_UINpcFriendItem = require("UI.Forms.UIFriendForm.Base.UINPCFriendItem")

local UIRecentRoot = {
    Trans = nil,
    Parent = nil,
    -- Is the interface open?
    IsVisible = nil,
    -- item's transform
    ItemTrans = nil,
    -- Friend item parent object
    ListPanelTtans = nil,
    -- No friend tips
    NoInfoPrompt = nil,
    -- Friend List ScrollView
    ScrollViewCom = nil,
    -- Friend grid
    Grid = nil,

    -- Selected item
    SelectedItem = nil,
    -- Animation
    --AnimModule = nil,
    -- Friend item list
    ItemList = List:New(),
    -- Friend information list
    FriendInfoList = List:New(),
    -- Default friend item
    GobjItemBase = nil,
    -- Number of friends
    FriendNum = nil,
    -- Apply Button
    ApplyBtn = nil,
    -- Receive friendship points with one click
    ReciveAllShipBtn = nil,
    -- Add friends button
    AddFriendBtn = nil,
    -- Jump the fairy armor treasure hunt button
    ToXianJiaXunBaoBtn = nil,
    -- Friendship Point Progress Adjustment
    ShipProgress = nil,
    -- Number of friendship points on the day text
    ShipProgressLabel = nil,
     -- Application button red dot
     redPoint = nil,
}

-- Turn on, return to self
function UIRecentRoot:OnFirstShow(trans , parent , rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    self.Go:SetActive(false)
    self.IsVisible = false
    self.NPCFrienditem = L_UINpcFriendItem:New(UIUtils.FindGo(self.Trans , "listPanel/Grid/default"))
    self.NPCFrienditem:OnFirstShow(UIUtils.FindTrans(self.Trans , "listPanel/Grid/default") , self)

    -- self.AnimModule = UIAnimationModule(self.Trans)
    -- self.AnimModule:AddAlphaAnimation()

    self.NoInfoPrompt = UIUtils.FindTrans(trans , "Prompt")
    self.ListPanelTtans = UIUtils.FindTrans(trans , "listPanel/Grid")
    self.Grid = UIUtils.FindGrid(self.ListPanelTtans)
    self.ItemTrans = UIUtils.FindTrans(trans , "listPanel/Grid/default")
    self.ScrollViewCom = UIUtils.FindScrollView(UIUtils.FindTrans(trans , "listPanel")) 

    self.ItemList:Clear()
    
    self.ListPanelTtans:GetChild(0).gameObject:SetActive(false)
    self.GobjItemBase = self.ListPanelTtans:GetChild(0).gameObject

    self.FriendNum = UIUtils.FindLabel(trans , "bottom/friendNumLabel/value")
    self.ApplyBtn = UIUtils.FindBtn(trans , "bottom/Sprite/ApplyBtn")
    self.AddFriendBtn = UIUtils.FindBtn(trans , "bottom/Sprite/addFriendBtn")
    self.ShipProgressLabel = UIUtils.FindLabel(trans , "bottom2/progress/valueLabel")
    self.ShipProgress = UIUtils.FindSlider(trans , "bottom2/progress")
    self.ToXianJiaXunBaoBtn = UIUtils.FindBtn(trans , "bottom2/XainjiaBtn")
    self.ReciveAllShipBtn = UIUtils.FindBtn(trans , "bottom2/Sprite/ReciveAllBtn")
    -- UIUtils.AddBtnEvent(self.AddFriendBtn, self.OnClickAddFriendBtn, self)
    self.redPoint = UIUtils.FindGo(trans , "bottom/Sprite/ApplyBtn/RedPoint")
    self.AddFriendBtn.gameObject:SetActive(false)
    UIUtils.AddBtnEvent(self.ApplyBtn, self.OnClickApplyBtnBtn, self)
    UIUtils.AddBtnEvent(self.ToXianJiaXunBaoBtn , self.OnClickToXunBao ,self)
    UIUtils.AddBtnEvent(self.ReciveAllShipBtn , self.OnReciveAllShipClick ,self)
    return self
end

-- closure
function UIRecentRoot:OnClose()
    self.Go:SetActive(false)
    --self.AnimModule:PlayDisableAnimation()
    -- if self.SelectedItem ~= nil then 
    --     self.SelectedItem:OnCancelSelection()
    -- end
    self.SelectedItem = nil
    self.IsVisible = false
    GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
end


-- Open
function UIRecentRoot:OnOpen()
    self.Go:SetActive(true)
    -- if not self.IsVisible then 
    --     self.AnimModule:PlayEnableAnimation()
    -- end
    self.IsVisible = true
end

-- Uncheck
function UIRecentRoot:OnCancelSelection()
    if self.SelectedItem ~= nil then 
        self.SelectedItem:OnCancelSelection()
    end
end

-- Update intimacy
function UIRecentRoot:UpdateIntimacy(roleId , intimacy)
    if self.SelectedItem ~= nil and self.SelectedItem.PlayerInfo.playerId == roleId then 
        self.SelectedItem:SetIntimacy(intimacy)
    else
        local _cnt = self.ItemList:Count()
        for i = 1, _cnt do
            local _item = self.ItemList[i]
            if _item.PlayerInfo.playerId == roleId then 
                _item:SetIntimacy(intimacy)
                break
            end
        end
    end
end

-- Get a friend list
function UIRecentRoot:GetFriendList(type)
    if type == FriendType.Recent then 
        return GameCenter.FriendSystem.RecentList
    elseif type == FriendType.Friend then
        return GameCenter.FriendSystem.FriendList
    elseif type == FriendType.Enemy then
        return GameCenter.FriendSystem.EnemyList
    elseif type == FriendType.Shield then
        return GameCenter.FriendSystem.ShieldList
    end
    return nil
end

-- Refresh the friend list
function UIRecentRoot:ReFreshFriendList(type , openChatPanel)
    --self:OnOpen()
    local _list = self:GetFriendList(type)
    if _list == nil or #_list <= 0  and self.NPCFrienditem == nil then 
        local _count = #self.ItemList
        for i = 1, _count do
            self.ItemList[i].gameObject:SetActive(false)
        end
        -- if self.SelectedItem ~= nil then 
        --     self.SelectedItem = nil
        -- end
        self.Grid:Reposition()
        self.ScrollViewCom:ResetPosition()
        GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
        return
    end
    if self.NPCFrienditem.PlayerInfo ~= nil and self.SelectedItem == nil then
        self.NPCFrienditem:OnCancelSelection()
        self.NPCFrienditem:UpdateFriendshipState(GameCenter.NPCFriendSystem.CurNPCShipBtnType)
    end

    local _listCount = #_list
    if self.SelectedItem ~= nil then 
        local _isExist = false
        for i = 1, _listCount do
            if self.SelectedItem.PlayerInfo.playerId == _list[i].playerId then 
                _isExist = true
            end
        end 
        if self.NPCFrienditem.PlayerInfo ~= nil and self.SelectedItem.PlayerInfo.playerId == self.NPCFrienditem.PlayerInfo.playerId then
            _isExist = true
        end
        if not _isExist then 
            self.SelectedItem.gameObject:SetActive(false)
            self.SelectedItem = nil
        end
    end
    if type ~= FriendType.Shield then 
        local isNoFriend = _listCount == 0 and self.NPCFrienditem.PlayerInfo == nil
        self.NoInfoPrompt.gameObject:SetActive(isNoFriend)
    end
    local _isChange = false
    local _curSelectplayerId = 0
    if self.SelectedItem ~= nil then 
        _curSelectplayerId = self.SelectedItem.PlayerInfo.playerId
    end
    for i = 1, _listCount  do
        local _item = nil

        if i >= #self.ItemList + 1 then 
            local _go = UnityUtils.Clone(self.GobjItemBase , self.ListPanelTtans)
            _item = L_UIFriendBaseItem:New(_go)
            _item:OnFirstShow(_go.transform,self)
            self.ItemList:Add(_item)
            _isChange = true
        else
            _item = self.ItemList[i]
        end

        if not _item.gameObject.activeSelf then 
            _isChange = true
            _item.gameObject:SetActive(true);
        end

        _item:Init(_list[i] , type == FriendType.Shield)

        if _curSelectplayerId > 0 then 
            if _curSelectplayerId == _list[i].playerId then 
                _item:OpenChatPrivateForm()
            else
                _item:OnCancelSelection()
            end
        else
            if i == 1 and openChatPanel then 
                _item:OpenChatPrivateForm()
            else
                _item:OnCancelSelection()
            end
        end
    end
    local _childCount = #self.ItemList
    if _listCount < _childCount then 
        for i = _listCount , _childCount-1 do
            if self.ItemList[i+1].gameObject.activeSelf then 
                self.ItemList[i+1].gameObject:SetActive(false)
                _isChange = true
            end
        end
    end
    if _isChange then 
        self.Grid:Reposition()
        self.ScrollViewCom:ResetPosition()
    end
    if self.SelectedItem == nil and self.NPCFrienditem.PlayerInfo ~= nil then
        self.NPCFrienditem:OpenChatPrivateForm()
    end
end

-- Update red dots
function  UIRecentRoot:UpdateRedPointShow()
    local _num = 0 
    for i = 1, self.ItemList:Count() do
        if self.ItemList[i]:IsRedPoint() then 
            _num = _num + 1
        end
    end
end

-- Add friend button event
function UIRecentRoot:OnClickAddFriendBtn()
    GameCenter.FriendSystem.PageType = FriendType.Recommend
    GameCenter.FriendSystem:ReqExternalGetRelationList(FriendType.Recommend , 
        function (obj)
            GameCenter.PushFixEvent( UIEventDefine.UISearchFriendForm_OPEN, obj )
        end
    )
    GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE )
end

-- Open the friend application interface event
function UIRecentRoot:OnClickApplyBtnBtn()
    self.Parent:OpenApplyRoot()
end

-- Jump treasure hunt interface
function UIRecentRoot:OnClickToXunBao()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.XJXunbaoRoot)
end

-- Update the friendship point
function UIRecentRoot:UpdateFriendshipPoint()
    local _qyCfg = GameCenter.XJXunbaoSystem.XJXunbaoDict[TreasureEnum.QingYi].Cfg
    local QingYiItemId = Utils.SplitNumber(_qyCfg.Times, '_')[2]
    local  _point = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(QingYiItemId)
    self.ShipProgress.value = _point/100;
    UIUtils.SetTextFormat(self.ShipProgressLabel , "{0}/100" , _point)
end

-- Receive all friendship points
function UIRecentRoot:OnReciveAllShipClick()
    local isHaveShip = false
    if self.NPCFrienditem.isHaveShipCanRecvie then
        isHaveShip = true
        self.NPCFrienditem:FriendshipBtnClick()
    end
    for i = 1, #self.ItemList do
        if self.ItemList[i].isHaveShipCanRecvie then
            self.ItemList[i].isHaveShipCanRecvie = false
            isHaveShip = true
            self.ItemList[i]:FriendshipBtnClick()
        end
    end
    if isHaveShip == false then
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_FRIENDSHIP_GETDONE"))
    end
end

-- Update the status of the gift friendship point button
function UIRecentRoot:UpdateFriendshipState(playerInfo ,type)
    for i = 1, #self.ItemList do
        local _item = self.ItemList[i]
        if _item.PlayerInfo.playerId == playerInfo.playerId then 
            _item:UpdateFriendshipState(playerInfo , type)
            break
        end
    end
end

-- Refresh the application button red dot
function UIRecentRoot:ApplyBtnRed(isRed)
    self.redPoint:SetActive(isRed)
end

-- Update interface information
function UIRecentRoot:UpdatePanelInfo()
    self:SetNPCFriend()
    self:ReFreshFriendList(FriendType.Recent, true)
    self:UpdateRedPointShow()
    local _maxFriendCount = DataConfig.DataGlobal[1437].Params
    UIUtils.SetTextByString(self.FriendNum ,  #GameCenter.FriendSystem.RecentList .. "/" .. _maxFriendCount)
end

function UIRecentRoot:SetNPCFriend()
    local data = GameCenter.NPCFriendSystem.CurNPC
    if data == nil then
        return 
    end
    if self.NPCFrienditem.PlayerInfo == nil then
        self.NPCFrienditem:Init(data)
    end
    local go = UIUtils.FindGo(self.Trans , "listPanel/Grid/default")
    if go.activeSelf == false then
        go:SetActive(true)
        self.Grid:Reposition()
        self.ScrollViewCom:ResetPosition()
    end
end


return UIRecentRoot