------------------------------------------------
-- Author: 
-- Date: 2021-03-03
-- File: UIPingBiRoot.lua
-- Module: UIPingBiRoot
-- Description: Block the friend bar
------------------------------------------------
local L_UIFriendBaseItem = require("UI.Forms.UIFriendForm.Base.UIFriendBaseItem")


local UIPingBiRoot = {
    Trans = nil,
    Parent = nil,
    -- Friends item
    ItemTrans = nil,
    -- Friend item parent object
    ListPanelTtans = nil,
    -- No information prompt
    NoInfoPrompt = nil,
    -- Friend List ScrollView
    ScrollViewCom = nil,
    -- Friend grid
    Grid = nil,
    -- Selected friend item
    SelectedItem = nil,
    -- Start animation
    --AnimModule = nil,
    -- item list
    ItemList = List:New(),
    -- Default friend item
    GobjItemBase = nil,
    -- Number of blocking
    ShieldNum = nil,
    -- Block players from chatting text
    Prompt_1 = nil,
    -- No blocked friend text yet
    Prompt_2 = nil,
}

-- Turn on, return to self
function UIPingBiRoot:OnFirstShow(trans , parent , rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    self.Go:SetActive(false)


    -- self.AnimModule = UIAnimationModule(self.Trans)
    -- self.AnimModule:AddAlphaAnimation()

    self.NoInfoPrompt = UIUtils.FindTrans(trans , "Prompt")
    self.ListPanelTtans = UIUtils.FindTrans(trans , "listPanel/Grid")
    self.Grid = UIUtils.FindGrid(self.ListPanelTtans)
    self.ItemTrans = UIUtils.FindTrans(trans , "listPanel/Grid/default")
    self.ScrollViewCom = UIUtils.FindScrollView(UIUtils.FindTrans(trans , "listPanel")) 

    self.ItemList:Clear()
    for i = 1, self.ListPanelTtans.childCount do
        local _go = self.ListPanelTtans:GetChild(i-1).gameObject
        _go:SetActive(false)
        local _item = L_UIFriendBaseItem:New(_go)
        self.ItemList:Add(_item)
        _item:OnFirstShow(self.ListPanelTtans:GetChild(i-1),self)
    end
    self.GobjItemBase = self.ItemList[1].gameObject

    self.ShieldNum = UIUtils.FindLabel(trans , "bottom/Label/valueLabel")
    self.Prompt_1 = UIUtils.FindTrans(trans , "Prompt/Prompt1")
    self.Prompt_2 = UIUtils.FindTrans(trans , "Prompt/Prompt2")
    UIUtils.FindTrans(trans , "Prompt").gameObject:SetActive(true)

    return self
end

-- closure
function UIPingBiRoot:OnClose()
    self.Go:SetActive(false)
    -- self.AnimModule:PlayDisableAnimation()
    -- if self.SelectedItem ~= nil then 
    --     self.SelectedItem:OnCancelSelection()
    -- end
    self.SelectedItem = nil
    GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
end

-- Open
function UIPingBiRoot:OnOpen()
    self.Go:SetActive(true)
    --self.AnimModule:PlayEnableAnimation()
end

-- Cancel selected
function UIPingBiRoot:OnCancelSelection()
    if self.SelectedItem ~= nil then 
        self.SelectedItem:OnCancelSelection()
    end
end

-- Refresh intimacy
function UIPingBiRoot:UpdateIntimacy(roleId , intimacy)
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
function UIPingBiRoot:GetFriendList(type)
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
function UIPingBiRoot:ReFreshFriendList(type , openChatPanel)
    --self:OnOpen()
    local _list = self:GetFriendList(type)
    if _list == nil or #_list <= 0  then 
        local _count = #self.ItemList
        for i = 1, _count do
            self.ItemList[i].gameObject:SetActive(false)
        end
        if self.SelectedItem ~= nil then 
            self.SelectedItem = nil
        end
        self.Grid:Reposition()
        self.ScrollViewCom:ResetPosition();
        GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
        return
    end
    local _listCount = #_list
    if self.SelectedItem ~= nil then 
        local _isExist = false
        for i = 1, _listCount  do
            if self.SelectedItem.PlayerInfo.playerId == _list[i].playerId then 
                _isExist = true
            end
        end
        if not _isExist then 
            self.SelectedItem.gameObject:SetActive(false)
            self.SelectedItem = nil
        end
    end
    if type ~= FriendType.Shield then 
        self.NoInfoPrompt.gameObject:SetActive(_listCount == 0)
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
            _item:OnFirstShow(self.ListPanelTtans:GetChild(i - 1),self)
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
        for i = _listCount , _childCount -1  do
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
end

-- Update red dots
function  UIPingBiRoot:UpdateRedPointShow()
    local _num = 0 
    for i = 1, self.ItemList:Count() do
        if self.ItemList[i]:IsRedPoint() then 
            _num = _num + 1
        end
    end
end

-- Refresh interface information
function UIPingBiRoot:UpdatePanelInfo()
    self:ReFreshFriendList(FriendType.Shield , false)
    local _maxShieldCount = DataConfig.DataGlobal[1440].Params
    local _count = GameCenter.FriendSystem.ShieldList:Count()
    UIUtils.SetTextByString(self.ShieldNum , _count .. "/" .. _maxShieldCount)

    if _count > 0 then 
        self.Prompt_1.gameObject:SetActive(true)
        self.Prompt_2.gameObject:SetActive(false)
    else 
        self.Prompt_1.gameObject:SetActive(false)
        self.Prompt_2.gameObject:SetActive(true)
    end
end


return UIPingBiRoot