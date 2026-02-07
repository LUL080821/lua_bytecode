------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIActivityRoot.lua
-- Module: UIActivityRoot
-- Description: Activity Root
------------------------------------------------
local UIActivityItem = require "UI.Forms.UIDailyActivityForm.Item.UIActivityItem"

local UIActivityRoot = {
    -- Owner
    Owner = nil,
    -- Trans
    Trans = nil,
    Go = nil,
    -- Event item Trans
    Item = nil,
    -- Activity item parent
    ListPanel = nil,
    ListProgress = nil,
    ScrollCompTrans = nil
}

function UIActivityRoot:New(owner, trans)
    local _m = Utils.DeepCopy(self)
    _m.Owner = owner
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:Close()
    return _m
end

function UIActivityRoot:FindAllComponents()
    self.Item = UIUtils.FindTrans(self.Trans, "ListPanel/Grid/Item")
    self.TfGrid = UIUtils.FindTrans(self.Trans, "ListPanel/Grid")
    self.Grid = UIUtils.FindGrid(self.Trans, "ListPanel/Grid")
    self.ScrollCompTrans = UIUtils.FindTrans(self.Trans, "ListPanel")
    self.ItemHeight = self.Grid.cellHeight;
    self.Panel = UIUtils.FindPanel(self.Trans, "ListPanel")
    self.ScrollView = UIUtils.FindScrollView(self.Trans, "ListPanel")
    self.ScrollViewHeight = self.Panel:GetViewSize().y
    self.ListProgress = self.ScrollView.verticalScrollBar

    self.ItemList = List:New();
    local item = nil
    for i = 0, self.TfGrid.childCount - 1 do
        item = UIActivityItem:New(self.TfGrid:GetChild(i));
    end
    self.GobjUIItemBase = item.Gobj;
    self.ItemList:Add(item)
end

function UIActivityRoot:RefreshActivity(activityList, id, trans)
    local _index = 0
    -- for i = 0, self.TfGrid.childCount - 1 do
    --     self.TfGrid:GetChild(i).gameObject:SetActive(false)
    -- end


    self.GobjUIItemBase:SetActive(true)

    if not self.GobjUIItemTemplate then
        self.GobjUIItemTemplate = UnityUtils.Clone(self.GobjUIItemBase, self.TfGrid)
        self.GobjUIItemTemplate:SetActive(false) -- ẩn template
    end

    local _animList = nil
    if self.PlayAnim then
        _animList = List:New()
        self.Owner.AnimPlayer:Stop()
    end
    local _haveGuild = false
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _haveGuild = _lp.GuildID > 0
    end
    local _showIndex = -1;
    local _select = nil
    for i = 1, #activityList do
        local _cfg = DataConfig.DataDaily[activityList[i].ID]
        local _item = nil
        if i == 1 then
            if not self.ItemList[1] then
                self.ItemList[1] = UIActivityItem:New(self.GobjUIItemBase.transform)
            end
            _item = self.ItemList[1]
        else
            _item = self.ItemList[i]
            if not _item then
                local go = UnityUtils.Clone(self.GobjUIItemTemplate, self.TfGrid)
                go:SetActive(true)
                _item = UIActivityItem:New(go.transform)
                self.ItemList[i] = _item
            end
        end
        -- local _item = UIActivityItem:New(UnityUtils.Clone(self.GobjUIItemBase, self.TfGrid).transform)
        -- _item.Gobj:SetActive(true)
        -- self.ItemList:Add(_item);



        -- 17 Immortal Alliance Mission 110 Immortal Alliance Battle 111 Immortal Alliance Leader
        if activityList[i].ID == 17 or activityList[i].ID == 110 or activityList[i].ID == 111 then
            if not self.Owner.AnimPlayer.Playing or not _haveGuild then
                _item.Gobj:SetActive(_haveGuild)
            end
            if _haveGuild and self.PlayAnim then
                _animList:Add(_item.Trans)
            end
        else
            local _isAdd = true
            if not self.Owner.AnimPlayer.Playing then
                _item.Gobj:SetActive(true)
            end
            if activityList[i].IsCloseShow == 0 and not activityList[i].IsOpen or _cfg.ActiveValue <= 0 then
                _isAdd = false
                _item.Gobj:SetActive(false)
            end
            if self.PlayAnim and _isAdd then
                _animList:Add(_item.Trans)
            end
        end

        _item:SetInfo(activityList[i])
        _item:RefreshInfo()
        if _animList ~= nil and id and id == activityList[i].ID then
            _select = _item.JoinBtn.transform
            _showIndex = #_animList - 1;
        end
        _index = _index + 1
    self.Grid:Reposition()
    self.ScrollView:ResetPosition()
    end

    UIUtils.HideNeedless(self.ItemList, #activityList)
    if _select and trans then
        trans.parent = _select
        UnityUtils.ResetTransform(trans)
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DAILY_PLAYVFX)
    end
    -- UnityUtils.GridResetPosition(self.TfGrid)
    -- UnityUtils.ScrollResetPosition(self.ScrollCompTrans)
    self.Grid:Reposition()
    self.ScrollView:ResetPosition()
    -- position
    local _dingwei = false
    if _showIndex ~= -1 and _animList ~= nil then
        local _allSize = math.ceil(#_animList / 2) * 128
        local _curSize = math.floor((_showIndex - 1) / 2) * 128
        self.ProgressValue = _curSize / (_allSize - self.ScrollViewHeight)
        self.ListProgress.value = self.ProgressValue
        self.ProgressFrameCount = 3
        _dingwei = true
    end
    
    if self.PlayAnim then
        for i = 1, #_animList do
            self.Owner.CSForm:RemoveTransAnimation(_animList[i])
            if _dingwei then
                self.Owner.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.001, false, false)
                self.Owner.AnimPlayer:AddTrans(_animList[i], 0)
            else
                self.Owner.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.2, false, false)
                self.Owner.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.05)
            end
        end
        self.Owner.AnimPlayer:Play()
    end
    self.PlayAnim = false
end

function UIActivityRoot:Update(dt)
    if self.ProgressFrameCount ~= nil and self.ProgressFrameCount > 0 then
        self.ProgressFrameCount = self.ProgressFrameCount - 1
        if self.ProgressFrameCount <= 0 then
            self.ListProgress.value = self.ProgressValue
        end
    end
end

function UIActivityRoot:Show()
    self.Go:SetActive(true)
    self.PlayAnim = true
end

function UIActivityRoot:Close()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_DAILY_STOPVFX)
    self.Go:SetActive(false)
end

return UIActivityRoot
