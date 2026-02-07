------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: PopoupListMenu.lua
-- Module: PopoupListMenu
-- Description: Drop-down menu
------------------------------------------------

-- C# class
local PopupMenuChild = require 'UI.Components.UIPopoupListMenu.PopupMenuChild'
local PopupMenu = {
    Trans = nil,
    -- SubTrans Template
    TempChildTrans = nil,
    -- Red dot
    RedPoint = nil,
    -- Menu name
    NameLabel = nil,
    -- Select the menu name
    SelectNameLabel = nil,
    -- Menu Buttons
    MenuBtn = nil,
    -- Menu background picture
    BackGround = nil,
    -- Select the picture on the menu
    CheckMart = nil,
    -- Is the menu open?
    IsOpen = false,
    -- Whether to move to the maximum distance of Y
    IsMoveYDis = false,
    -- Whether to move to Start location
    IsMoveToStart = false,
    -- Menu Type
    MenuType = 0,
    -- Menu Index
    MenuIndex = 0, 
    -- Menu spacing
    MenuDis = 2,
    -- Submenu spacing
    ChildMenuDis = 0,
    Duration = 0.5,
    -- Submenu List
    Childs = List:New(),
    -- Starting location
    StartPos = Vector3.zero,
    -- End position
    EndPos = Vector3.zero,
    MovePos = Vector3.zero,
    -- Menu Controller
    MenuControl = nil,
    -- The submenu id currently clicked
    CurClickChildId = 0,
    --TweenPos = nil,
    --callBack
    Tick = 0,
    Time =0.5,
    -- Click to call back
    ClickSelfCallBack = nil,

    NorColor = "#FFFFFF",
    SelectColor = "#865024",
    IsShow = true
}

-- Click Menu
function PopupMenu:OnClickMenu(isShowChild)
    if not self.MenuControl:CanClickMenu() then
        return
    end
    for i = 1,#self.Childs do
        self.Childs[i]:SetUnSelected()
    end
    if (self.IsOpen ~= true and (isShowChild == nil or isShowChild == true)) then
        -- Open the drop-down list
        self.MenuControl.SpecialIndex = 0
        self.CheckMart.gameObject:SetActive(true)
        self.BackGround.gameObject:SetActive(false)
        if not self.MenuControl.IsUseSelectName then
            --TL cmt: change text #3E5079 -> #202027
            UIUtils.SetColor(self.NameLabel, 32/255, 32/255, 39/255, 1)
            --UIUtils.SetColor(self.NameLabel, 62/255, 80/255, 121/255, 1)
        end
        --self:OpenChildList()
        local childMenu = nil
        if self.CurClickChildId == 0 then
            childMenu = self:GetFristChild()
        else
            childMenu = self:GetChildMenu(self.CurClickChildId)
        end
        self.MenuControl:UpdateMenuList(self.MenuIndex)
        if childMenu ~= nil and self.MenuControl.IsSelectFirstChild then
            self:UpdateChildMenu(childMenu.FuncStartId)
        elseif not self.MenuControl.IsSelectFirstChild or childMenu == nil then
            -- If the first submenu is not opened by default, then click the parent menu callback
            self.ClickSelfCallBack(self.MenuType)
        end 
        self.Tick = self.Time
    else
        -- Close the drop-down list
        --self.CheckMart.gameObject:SetActive(false)
        --self.BackGround.gameObject:SetActive(true)
        --self:CloseChildList()
        self.CheckMart.gameObject:SetActive(true)
        self.BackGround.gameObject:SetActive(false)
        if not self.MenuControl.IsUseSelectName then
            --TL cmt: change text #3E5079 -> #202027
            UIUtils.SetColor(self.NameLabel, 32/255, 32/255, 39/255, 1)
            --UIUtils.SetColor(self.NameLabel, 62/255, 80/255, 121/255, 1)
        end
        self.MenuControl:UpdateMenuList(-1)
        self.Tick = self.Time
        self.ClickSelfCallBack(-1)
    end
end

-- Create PopoupMenu
function PopupMenu:New(tempRoot, type, index, name, childDataList, menuCol,childMenuCall, needClone, initY, offsetY, isHide)
    local _m = Utils.DeepCopy(self)
    _m.MenuType = type
    _m.MenuIndex = index
    _m.MenuControl = menuCol
    _m.ChildMenuDis = offsetY
    if needClone then
        _m.Trans = UnityUtils.Clone(tempRoot.gameObject).transform
    else
        _m.Trans = tempRoot
        UnityUtils.SetLocalPositionY(_m.Trans, initY)
    end
    _m.Trans.gameObject:SetActive(childDataList ~= nil)
    _m.MovePos = Vector3(0,0,0)
    _m.ClickSelfCallBack = childMenuCall
    _m:FindAllComponent()
    _m:SetButton()
    -- Setting ChildList
    _m:SetChildMenu(childDataList, childMenuCall,offsetY)
    UIUtils.SetTextByString(_m.NameLabel, name)
    UIUtils.SetTextByString(_m.SelectNameLabel, name)
    _m.Trans.name = tostring(type)
    local trans = _m.Trans:Find("ChildList")
    if trans ~= nil then
        for i = 1, trans.childCount do
            local child = trans:GetChild(i-1)
            child.gameObject:SetActive(false)
        end
    end
    if isHide then
        _m.IsShow = childDataList ~= nil
    end
    return _m
end

function PopupMenu:FindAllComponent()
    local _myTrans = self.Trans
    self.MenuBtn = UIUtils.FindBtn(_myTrans, "Menu")
    self.BackGround = self.Trans:Find("Menu/BackBround")
    self.CheckMart = self.Trans:Find("Menu/CheckMark")
    self.TempChildTrans = self.Trans:Find("ChildList/ChildMenuTemp")
    self.BackGround.gameObject:SetActive(true)
    self.CheckMart.gameObject:SetActive(false)
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Menu/Name")
    self.RedPoint  = self.Trans:Find("Menu/RedPoint")
    self.RedPoint.gameObject:SetActive(false)
    if self.MenuControl.IsUseSelectName then
        self.SelectNameLabel = UIUtils.FindLabel(_myTrans, "Menu/NameSelect")
        self.NameLabel.gameObject:SetActive(true)
        self.SelectNameLabel.gameObject:SetActive(false)
    end
end

function PopupMenu:SetButton()
    UIUtils.AddBtnEvent(self.MenuBtn, self.OnClickMenu, self)
end

-- Initialize menu button position
function PopupMenu:InitMenuPos(count, heigh, dis, isSetEndPos)
    local sprite = UIUtils.FindSpr(self.BackGround)
    if sprite ~= nil then
        -- Calculate the starting position
        local y = self.MenuControl.OrginPos.y - (sprite.height + self.MenuDis) * (self.MenuIndex-1)
        self.StartPos = {x = self.Trans.localPosition.x,y = y, z = self.Trans.localPosition.z}
        UnityUtils.SetLocalPositionY(self.Trans, y)
        -- Calculate the end position
        if isSetEndPos == false then
            self.EndPos = self.StartPos
        else
            if count == -1 then
                self.EndPos = Vector3(self.StartPos.x,self.StartPos.y,self.StartPos.z)
            else   
                local offsetY = 0
                if self.MenuControl.OffsetY ~= nil then
                    offsetY = self.MenuControl.OffsetY
                end
                y = self.StartPos.y - (heigh +dis) * count - offsetY
                self.EndPos = Vector3(self.StartPos.x,y,self.StartPos.z)
            end
        end
    end
end

-- Set menu color
function PopupMenu:SetTextColor(normalColor, selectColor)
    if not self.MenuControl.IsUseSelectName then
        self.NorColor = normalColor
        self.SelectColor = selectColor

        for i = 1, #self.Childs do
            self.Childs[i].NorColor = self.NorColor
            self.Childs[i].SelectColor = self.SelectColor
        end
    end
end

-- Move the Settings Menu button to the target position
function PopupMenu:MoveToTargetPos()
end

-- Settings menu button returns to the starting position
function PopupMenu:MoveToStartPos()
end

-- Get the number of submenu
function PopupMenu:GetChildMenuCount()
    local count = 0
    for i = 1,#self.Childs do
        local child = self.Childs[i]
        if child.Enable then
            count = count + 1
        end
    end
    return count
end

-- Get submenu image height
function PopupMenu:GetChildPicH()
    if self.Childs:Count() ~= 0 then
        local child = self.Childs[1]
        if child ~= nil then
            return child.MenuHeigh
        end
    end
    return -1
end

-- Get the spacing between submenu
function PopupMenu:GetChildDis()
    if self.Childs:Count() ~= 0 then
        local child = self.Childs[1]
        if child ~= nil then
            return child.MenuDis
        end
    end
    return -1
end

-- Get whether there is a submenu
function PopupMenu:HaveChildMenu()
    for i = 1,#self.Childs do
        local child = self.Childs[i]
        if child.Enable then
            return true
        end
    end
    return false
end

function PopupMenu:SetChildMenu(childDataList, call, offsetY)
    if childDataList == nil then
        return
    end
    for i = 1, #childDataList do
        local trans = self.Trans:Find(string.format( "ChildList/%d",childDataList[i].Id ) )
        local child = nil
        if trans == nil then
            self.TempChildTrans.gameObject:SetActive(false)
            child = PopupMenuChild:New(self.TempChildTrans, childDataList[i],i,#childDataList,self.MenuControl,call, true, 0, offsetY)
        else
            child = PopupMenuChild:New(trans, childDataList[i],i,#childDataList,self.MenuControl,call,false,self.TempChildTrans.localPosition.y, offsetY)
        end
        child.NorColor = self.NorColor
        child.SelectColor = self.SelectColor
        self.Childs:Add(child)
    end
end

function PopupMenu:RefreashChildData(childDataList, isHide)
    self.Trans.gameObject:SetActive(childDataList ~= nil)
    if isHide then
        self.IsShow = childDataList ~= nil
    end
    local length = 0
    if childDataList ~= nil then
        length = #childDataList
    end
    for i = 1, length do
        local child = nil
        if i > #self.Childs then
            self.TempChildTrans.gameObject:SetActive(false)
            child = PopupMenuChild:New(self.TempChildTrans, childDataList[i],i,#childDataList,self.MenuControl,self.ClickSelfCallBack, true, 0, self.ChildMenuDis)
            self.Childs:Add(child)
        else
            child = self.Childs[i]--PopupMenuChild:New(self.Childs[i].Trans, childDataList[i],i,#childDataList,self.MenuControl,self.ClickSelfCallBack,false,self.TempChildTrans.localPosition.y, self.ChildMenuDis)
        end
        child.NorColor = self.NorColor
        child.SelectColor = self.SelectColor
    end
    if length < #self.Childs then
        for i = length + 1 , #self.Childs do
            self.Childs[i].Trans.gameObject:SetActive(false)
            self.Childs[i].Enable = false
        end
    end
end

function PopupMenu:GetChildMenu(id)
    for i = 1, #self.Childs do
        if self.Childs[i].FuncStartId == id then
            return self.Childs[i]
        end
    end
    return nil
end

function PopupMenu:SetNormaleColor()
    if not self.MenuControl.IsUseSelectName then
        UIUtils.SetColorByString(self.NameLabel, self.NorColor)
    end
end

function PopupMenu:SetSelectColor()
    if not self.MenuControl.IsUseSelectName then 
        UIUtils.SetColorByString(self.NameLabel, self.SelectColor)
    end
end

-- Get the first child
function PopupMenu:GetFristChild()
    if self.Childs:Count()>=1 then
        return self.Childs[1]
    end
    return nil
end

-- Open the drop-down list
function PopupMenu:OpenChildList()
    for i = 1, #self.Childs do
        if self.Childs[i] ~= nil then
            self.Childs[i]:MoveToTargetPos()
        end
    end
    self.CheckMart.gameObject:SetActive(true)
    self.BackGround.gameObject:SetActive(false)
    if self.MenuControl.IsUseSelectName then
        self.NameLabel.gameObject:SetActive(false)
        self.SelectNameLabel.gameObject:SetActive(true)
    end
    self.IsOpen = true
end

-- Close the list
function PopupMenu:CloseChildList(index)
    for i = 1, #self.Childs do
        if self.Childs[i] ~= nil then
            self.Childs[i]:SetUnSelected()
            self.Childs[i]:MoveToStartPos()
        end
    end
    if index ~= -1 then
        self.CheckMart.gameObject:SetActive(false)
        self.BackGround.gameObject:SetActive(true)
        if self.MenuControl.IsUseSelectName then
            self.NameLabel.gameObject:SetActive(true)
            self.SelectNameLabel.gameObject:SetActive(false)
        end
        --self.CurClickChildId = 0
    end
    self.IsOpen = false
end

 -- Reset Menu location
function PopupMenu:ResetPos()
    self.Time = math.abs( self.StartPos.y-self.Trans.localPosition.y )/self.MenuControl.Speed
    self.Tick = self.Time
    self.IsMoveToStart = true
end

function PopupMenu:ResetSelect()
    self.CheckMart.gameObject:SetActive(false)
    self.BackGround.gameObject:SetActive(true)
    if self.MenuControl.IsUseSelectName then
        self.NameLabel.gameObject:SetActive(true)
        self.SelectNameLabel.gameObject:SetActive(false)
    end
end

-- Get Y coordinate displacement distance
function PopupMenu:GetMoveDisY()
    return self.EndPos.y - self.StartPos.y
end

-- Is it in the Start location?
function PopupMenu:IsOnStartPos()
    if self.Trans.localPosition.y == self.StartPos.y or math.abs( self.Trans.localPosition.y - self.StartPos.y ) < 0.1 then
        return true
    end
    return false
end
-- Is the submenu closed?
function PopupMenu:IsChildShrink()
    local isShrink = true
    for i = 1,#self.Childs do
        if not self.Childs[i]:GetShrink() then
            isShrink = false
        end
    end
    return isShrink
end

-- Determine whether the submenu is still moving
function PopupMenu:HaveChildMove()
    local have = false
    for i = 1,#self.Childs do
        if self.Childs[i]:IsMove() then
            have = true
        end
    end
    return have
end

-- Set Menu location
function PopupMenu:SetMenuMovePos(yDis)
    local _startPos = Vector3(self.StartPos)
    self.MovePos.x = _startPos.x
    self.MovePos.y = _startPos.y+yDis
    self.MovePos.z = _startPos.z
    self.Time = math.abs( yDis/self.MenuControl.Speed )
    self.Tick = self.Time
    self.IsMoveYDis = true
end

--Hide
function PopupMenu:HideMenu()
    UnityUtils.SetLocalPosition(self.Trans, self.StartPos.x, self.StartPos.y, self.StartPos.z)
    for i = 1,#self.Childs do
        self.Childs[i]:HideMenu()
    end
    self.Tick = 0
    self.IsOpen = false
    self.CurClickChildId = 0
end

-- Update submenu
function PopupMenu:UpdateChildMenu(id)
    local isCall = true
    local clickMenu = nil
    for i = 1, #self.Childs do
        self.Childs[i]:SetUnSelected()
    end
    if self.CurClickChildId == id then
        isCall = false
    else 
        self.CurClickChildId = id
    end
    clickMenu = self:GetChildMenu(id)
    clickMenu:OpenFunction(isCall)
end

function PopupMenu:UpdatePos(dt)
    if self.Tick ~=0 then
        local _pos = nil
        if self.IsMoveYDis then
            if self.Tick>0 then
                self.Tick = 0
                --self.Tick = self.Tick-dt
                _pos = Utils.Lerp(self.MovePos,self.StartPos,0)--self.Tick/self.Time)
            else
                self.Tick = 0
                self.IsMoveYDis = false
                _pos = self.MovePos
            end
            UnityUtils.SetLocalPosition(self.Trans, _pos.x, _pos.y, _pos.z)
        end
        if self.IsMoveToStart then
            if self.Tick>0 then
                self.Tick = 0
                --self.Tick = self.Tick-dt
                _pos = Utils.Lerp(self.StartPos,self.MovePos,0)--self.Tick/self.Time)
            else
                self.Tick = 0
                self.IsMoveToStart = false
                _pos = self.StartPos
            end
            UnityUtils.SetLocalPosition(self.Trans, _pos.x, _pos.y, _pos.z)
        end
    end
    if self.Childs then
        for i = 1,#self.Childs do
            self.Childs[i]:UpdatePos(dt,self.IsOpen)
        end
    end
end

function PopupMenu:SetRedPoint(b)
    self.RedPoint.gameObject:SetActive(b)
end
function PopupMenu:Clear()
    for i = 1,#self.Childs do
        self.Childs[i]:Clear()
    end
    self.Childs:Clear()
    CS.UnityEngine.Object.Destory(self.Trans.gameObject)
end
return PopupMenu
