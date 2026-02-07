
------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: PopoupListMenu.lua
-- Module: PopoupListMenu
-- Description: Drop-down menu component
------------------------------------------------

-- C# class
local PopupMenu = require "UI.Components.UIPopoupListMenu.PopupMenu"
local PopupListMenu = {
    -- Wait for index
    WaiteIndex = -1,
    SpecialIndex = 0,
    -- Do you need to wait for reset
    IsWaitReset = false,
    -- Is it possible to hide the parent menu without a submenu
    IsHideMenuForNoChild = false,
    -- Menu List
    MenuList = List:New(),
    -- Menu Root
    MenuRoot = nil,
    -- Menu clone object
    TempRoot = nil,
    -- Menu callback
    ClickCallBack = nil,
    -- Y direction offset value
    OffsetY = 0,
    Speed = 600,
    -- Whether to open the first menu by default
    IsSelectFirstChild = true,
    -- Menu Font Color
    NorColor = "#202027", --"#FFFFFF",
    SelectColor = "#202027", --"#865024",

    OrginPos = nil,
    -- Whether to use the selected name
    IsUseSelectName = false,

    ListBindFunc = List:New(),
    -- Whether to sort
    IsSort = true,
    CurSelectFuncId = 0,
}

function PopupListMenu:BindFuncId(type, id)
    self.ListBindFunc:Add({Type = type, Id = id})
    local info = GameCenter.MainFunctionSystem:GetFunctionInfo(id)
    if info ~= nil then
        for m = 1, #self.MenuList do
            local menu = self.MenuList[m]
            if menu.MenuType == type then
                menu.Trans.gameObject:SetActive(info.IsVisible)
            end
        end
    end
end

-- Create a drop-down menu
-- tempRoot cloning nodes
-- Click callback on the callBack menu
-- offsetY Y spacing cheap value
-- isSelectFirst Click on the large menu or open the menu for the first time. Whether to select the first submenu under the large menu by default.
function PopupListMenu:CreateMenu(Root, callBack, offsetY, isSelectFirst, isSort)
    local _m = Utils.DeepCopy(self)
    _m.MenuList:Clear()
    _m.MenuRoot = Root
    _m.TempRoot = Root:Find("MenuTemp")
    _m.TempRoot.gameObject:SetActive(false)
    _m.OrginPos = Vector3(_m.TempRoot.localPosition.x ,_m.TempRoot.localPosition.y, _m.TempRoot.localPosition.z)
    _m.ClickCallBack = callBack
    _m.OffsetY = offsetY
    if isSelectFirst ~= nil then
        -- The first submenu is not selected by default
        _m.IsSelectFirstChild = false
    end
    for i = 1, _m.MenuRoot.childCount do
        local child = _m.MenuRoot:GetChild(i-1)
        child.gameObject:SetActive(false)
    end
    if isSort == nil then
        _m.IsSort = true
    else
        _m.IsSort = isSort
    end
    return _m
end

-- Add menu
-- type large menu type (custom)
-- name big menu name
-- childDataList Customize submenu data (submenu id and name)
-- isHide Does not have a submenu hide large menu?
function PopupListMenu:AddMenu(type, name, childDataList, offsetY, isHide)
    local count = -1
    local heigh = -1
    local dis = -1
    local preMenu = nil
    local Menu = nil
    local trans = self.MenuRoot:Find(tostring(type))
    if isHide == nil then
        isHide = true
    end
    if trans == nil then
        Menu = PopupMenu:New(self.TempRoot,type, self.MenuList:Count() + 1, name,childDataList,self,self.ClickCallBack, true, 0 , offsetY, isHide)
    else
        Menu = PopupMenu:New(trans,type, self.MenuList:Count() + 1, name,childDataList,self,self.ClickCallBack, false, self.TempRoot.localPosition.y, offsetY, isHide)
    end
    Menu.MenuDis = self.OffsetY
    if not self.IsUseSelectName then
        Menu:SetTextColor(self.NorColor, self.SelectColor)
        Menu:SetNormaleColor()
    end
    self.MenuList:Add(Menu)
    if self.IsSort then
        -- Sort
        self.MenuList:Sort(function(a,b)
            return a.MenuType < b.MenuType
        end)
    end
    -- Reset all menu locations
    for i = 1, #self.MenuList do
        local Menu2 = self.MenuList[i]
        Menu2.MenuIndex = i
        local reSetMenuPos = false
        if not Menu2:HaveChildMenu() and self.IsHideMenuForNoChild then
            -- If there are no children and there are external settings that hide them without children
            Menu2.Trans.gameObject:SetActive(false)
        else
            reSetMenuPos = true
        end
        if reSetMenuPos then
            -- Reset the initial position of each menu
            if i ~= 1 then
                preMenu = self.MenuList[i]
            end
            count = self:GetBrotherChildCount(i)
            heigh = self:GetBrotherChildPicH(i)
            dis = self:GetBrotherChildDis(i)
            if preMenu == nil then
                Menu2:InitMenuPos(count,heigh,dis,false)
            else
                preMenu:InitMenuPos(count,heigh,dis,true)
            end 
            Menu2.Trans.gameObject:SetActive(Menu2.IsShow)
        end
    end
end

function PopupListMenu:GetPreMenu(index)
    local preMenu = nil
    if index <= self.MenuList:Count() and index >=1 then
        preMenu = self.MenuList[index]
        if not preMenu:HaveChildMenu() and self.IsHideMenuForNoChild then
            preMenu = self:GetPreMenu(index - 1)
        end
    end
    return preMenu
end

function PopupListMenu:RefreashMenu(type, childDataList, OpenFuncId, isHide)
    local count = 0
    local heigh = 0
    local dis = 0
    local preMenu = nil
    if isHide == nil then
        isHide = true
    end
    local index = 0
    for i = 1, #self.MenuList do
        local Menu = self.MenuList[i]
        local reSetMenuPos = false
        if Menu.MenuType == type then
            -- Menu that needs to be updated
            Menu:RefreashChildData(childDataList, isHide)
            if not Menu:HaveChildMenu() and self.IsHideMenuForNoChild then
                -- If there are no children and there are external settings that hide them without children
                Menu.Trans.gameObject:SetActive(false)
                Menu.MenuIndex = -1
            else
                reSetMenuPos = true
                index = index + 1
            end
        else
            if not Menu:HaveChildMenu() and self.IsHideMenuForNoChild then
                -- If there are no children and there are external settings that hide them without children
                Menu.Trans.gameObject:SetActive(false)
                Menu.MenuIndex = -1
            else
                reSetMenuPos = true
                index = index + 1
            end
        end
        if reSetMenuPos then
            -- Reset the initial position of each menu
            if i ~= 1 then
                preMenu = self.MenuList[i]
                count = self:GetChildCount(index)
                heigh = self:GetChildPicH(index)
                dis = self:GetChildDis(index)
            else
                count = self:GetBrotherChildCount(i)
                heigh = self:GetBrotherChildPicH(i)
                dis = self:GetBrotherChildDis(i)
            end
            if preMenu == nil then
                Menu.MenuIndex = index
                Menu:InitMenuPos(count,heigh,dis,false)
            else
                preMenu.MenuIndex = index
                preMenu:InitMenuPos(count,heigh,dis,true)
            end 
            Menu.Trans.gameObject:SetActive(Menu.IsShow)
        end
    end
    self:OpenMenuList(OpenFuncId)
end

-- Get the number of children of the brother node
function PopupListMenu:GetBrotherChildCount(index)
    if index <= self.MenuList:Count() and index>1 then
        local menu = self.MenuList[index-1]
        if menu ~= nil then
            local count = menu:GetChildMenuCount()
            return count
        end
    end
    return -1
end

function PopupListMenu:GetChildCount(menuIndex)
    for i = 1, #self.MenuList do
        if self.MenuList[i].MenuIndex == menuIndex - 1 then
            local count = self.MenuList[i]:GetChildMenuCount()
            return count
        end
    end
    return -1
end

-- Get the image height of the child node of the brother node
function PopupListMenu:GetBrotherChildPicH(index)
    if index <= self.MenuList:Count() and index>1 then
        local menu = self.MenuList[index-1]
        if menu ~= nil then
            local heigh = menu:GetChildPicH()
            return heigh
        end
    end
    return -1
end

function PopupListMenu:GetChildPicH(menuIndex)
    for i = 1, #self.MenuList do
        if self.MenuList[i].MenuIndex == menuIndex - 1 then
            local heigh = self.MenuList[i]:GetChildPicH()
            return heigh
        end
    end
    return -1
end

-- Get the spacing between children of the brother node
function PopupListMenu:GetBrotherChildDis(index)
    if index <= self.MenuList:Count()and index>1 then
        local menu = self.MenuList[index-1]
        if menu ~= nil then
            local dis = menu:GetChildDis()
            return dis
        end
    end
    return -1
end

function PopupListMenu:GetChildDis(menuIndex)
    for i = 1, #self.MenuList do
        if self.MenuList[i].MenuIndex == menuIndex - 1 then
            local dis = self.MenuList[i]:GetChildDis()
            return dis
        end
    end
    return -1
end

-- Get Menu
function PopupListMenu:GetMenuById(childId)
    for i = 1, #self.MenuList do
        local menu = self.MenuList[i]
        local childMenu = menu:GetChildMenu(childId)
        if childMenu~= nil and childMenu.FuncStartId == childId then
            return menu, childMenu
        end
    end
end

-- Get submenu
function PopupListMenu:GetChildMenuById(childId)
    for i = 1, #self.MenuList do
        local menu = self.MenuList[i]
        local childMenu = menu:GetChildMenu(childId)
        if childMenu~= nil and childMenu.FuncStartId == childId then
            return childMenu
        end
    end
    return nil
end

-- Update ChildMenu
function PopupListMenu:UpdateChildMenu(id)
    local menu = nil
    local clickChild = nil
    for i = 1,#self.MenuList do
        if self.MenuList[i] then
            for m = 1, #self.MenuList[i].Childs do
                local childMenu = self.MenuList[i].Childs[m]
                if childMenu.FuncStartId == id then
                    menu = self.MenuList[i]
                    menu.CurClickChildId = childMenu.FuncStartId
                    clickChild = childMenu
                    break
                end
                --childMenu.SetUnSelected()
            end
        end
    end
    if menu ~= nil then
        for n = 1,#menu.Childs do
            local childMenu = menu.Childs[n]
            childMenu:SetUnSelected()
        end
        if clickChild ~= nil then
            clickChild:OpenFunction(true)
        end
    end
end

-- Update MenuList
function PopupListMenu:UpdateMenuList(index)
    -- Close all open menus first
    for i = 1, #self.MenuList do
        if self.MenuList[i].IsOpen == true then
            -- If it is on, close the current button
            self.MenuList[i]:CloseChildList(index)
            if index == -1 or index == -5 then
                self.MenuList[i].IsOpen = false
            end
        else
            if index == -1 then
                self.MenuList[i]:SetNormaleColor()
            end
            self.MenuList[i]:ResetSelect()
        end
        if index ~= -1 and self.MenuList[i].MenuIndex ~= index then
            self.MenuList[i].CurClickChildId = 0
            self.MenuList[i]:SetNormaleColor()
        else
            if index ~= -1 then
                self.MenuList[i]:SetSelectColor()
            end
        end
        -- Reset button position
        self.MenuList[i]:ResetPos()
        self.IsWaitReset = true
        self.WaiteIndex = index
    end
end

-- Open Menu Pagination
function PopupListMenu:OpenMenuList(id, isShowChild)
    self.SpecialIndex = 0
    local needUpdateMenu = true
    if id == -2 then
        id = self.CurSelectFuncId
        needUpdateMenu = false
    end
    if id == nil or id == -1 then
        -- if GameCenter.RankSystem.CurFunctionId == -1 then
        -- --The first page of the first menu is opened by default
        if self.MenuList:Count() >=1 then
            local menu = self.MenuList[1]
            self:UpdateMenuList(menu.MenuType)
            if self.IsSelectFirstChild then
                local childMenu = menu:GetFristChild()
                if childMenu ~= nil then
                    menu:UpdateChildMenu(childMenu.FuncStartId)
                else
                    menu:OnClickMenu(isShowChild)
                end
            end
        end
    else
        -- Open the menu page corresponding to Id
        local menu,childMenu
        if self.IsSelectFirstChild then
            menu,childMenu = self:GetMenuById(id)
            if needUpdateMenu then
                self:UpdateMenuList(menu.MenuType)
            end
            menu:UpdateChildMenu(childMenu.FuncStartId)
        else
            for i = 1,#self.MenuList do
                if self.MenuList[i].MenuType == id then
                    menu = self.MenuList[i]
                    break
                end
            end
            if menu == nil then
                menu,childMenu = self:GetMenuById(id)
                if needUpdateMenu then
                    self:UpdateMenuList(menu.MenuType)
                end
                menu:UpdateChildMenu(childMenu.FuncStartId)
            else
                if needUpdateMenu then
                    if isShowChild ~= nil and not isShowChild then
                        self.SpecialIndex = -5
                    end
                    self:UpdateMenuList(menu.MenuIndex)
                end
                menu.ClickSelfCallBack(menu.MenuType)
            end
        end
    end
end

-- Close all Menu
function PopupListMenu:CloseAll()
    for i = 1, #self.MenuList do
        self.MenuList[i]:HideMenu()
        self.MenuList[i]:ResetSelect()
    end
    self.WaiteIndex = -1
    self.IsWaitReset = false
end

-- Determine whether you can click on the menu
function PopupListMenu:CanClickMenu()
    local canClick = true
    for i = 1,#self.MenuList do
        if self.MenuList[i]:HaveChildMove() then
            canClick = false
        end
    end
    return canClick
end

-- Get Menu
function PopupListMenu:GetMenuIndexByType(type)
    
    for i = 1,#self.MenuList do
        if type == self.MenuList[i].MenuType then
            return i
        end
    end
    return -1
end

--update
function PopupListMenu:Update(dt)
    if self.MenuList then
        for i = 1, #self.MenuList do
            self.MenuList[i]:UpdatePos(dt)
        end
    end
    if self.IsWaitReset then
        local isOpen = true
        for i = 1, #self.MenuList do
            local isStartPos = self.MenuList[i]:IsOnStartPos()
            if not isStartPos or not self.MenuList[i]:IsChildShrink() then
                isOpen = false
            else
                self.MenuList[i].IsMoveToStart = false
            end
            if self.WaiteIndex == self.MenuList[i].MenuIndex and self.SpecialIndex == -5 then
                self.MenuList[i].CheckMart.gameObject:SetActive(true)
                self.MenuList[i].BackGround.gameObject:SetActive(false)
            end
        end
        if isOpen then
            if self.WaiteIndex == -1 or self.SpecialIndex == -5 then
                self.IsWaitReset = false
                return
            end
            -- Open the Menu corresponding to index
            local moveY = 0
            local _menu = self:FindNextMenu(self.WaiteIndex)
            if _menu ~= nil then
                moveY = _menu:GetMoveDisY()
                if self.MenuList[self.WaiteIndex]:GetFristChild() ~= nil then
                    -- for i = self.WaiteIndex+1, #self.MenuList do
                    --     self.MenuList[i]:SetMenuMovePos(moveY)
                    -- end
                    for i = 1, #self.MenuList do
                        if self.MenuList[i].MenuIndex > self.WaiteIndex then
                            self.MenuList[i]:SetMenuMovePos(moveY)
                        end
                    end
                end
            end
            local _waiteMenu = self:FindMenu(self.WaiteIndex)
            if _waiteMenu ~= nil then
                _waiteMenu.IsOpen =true
                _waiteMenu:OpenChildList()
            end
            self.WaiteIndex = -1
            self.IsWaitReset = false
        end
    end
end

function PopupListMenu:FindNextMenu(index)
    local _ret = nil
    for i = 1, #self.MenuList do
        if index + 1 == self.MenuList[i].MenuIndex then
            _ret = self.MenuList[i]
            break
        end
    end
    return _ret
end

function PopupListMenu:FindMenu(index)
    local _ret = nil
    for i = 1, #self.MenuList do
        if index == self.MenuList[i].MenuIndex then
            _ret = self.MenuList[i]
            break
        end
    end
    return _ret
end

-- Show red dots
-- childIdList: child button id
function PopupListMenu:ShowRedPoint(childIdList)
    if childIdList == nil then
        return
    end
    for i = 1,#self.MenuList do
        local menu = self.MenuList[i]
        if menu ~= nil and menu.Childs ~= nil then
            menu:SetRedPoint(false)
            for m = 1,#menu.Childs do
                local isShow = false
                local child = menu.Childs[m]
                child:SetRedPoint(false)
                for k = 1,#childIdList do
                    if child.FuncStartId == childIdList[k] then
                        isShow = true
                        menu:SetRedPoint(true)
                        child:SetRedPoint(true)
                    end
                end
            end
        end
    end
end

-- Set large menu red dots
function PopupListMenu:ShowMenuRedPoint(menuType, isShow)
    for i = 1,#self.MenuList do
        local menu = self.MenuList[i]
        if menu ~= nil and menu.MenuType == menuType then
            menu:SetRedPoint(isShow)
        end
    end
end

-- Setting submenu red dots
function PopupListMenu:ShowChildMenuRedPoint(childId, isShow)
    for i = 1,#self.MenuList do
        local menu = self.MenuList[i]
        if menu ~= nil and menu.Childs ~= nil then
            menu:SetRedPoint(false)
            local isShowRedPoint = false
            for m = 1,#menu.Childs do
                local child = menu.Childs[m]
                if child.FuncStartId == childId then
                    child:SetRedPoint(isShow)
                end
                if child.IsShowRedPoint then
                    isShowRedPoint = true
                end
            end
            menu:SetRedPoint(isShowRedPoint)
        end
    end
end

function PopupListMenu:Clear()
    for i = 1,#self.MenuList do
        self.MenuList[i]:Clear()
    end
    self.MenuList:Clear()
end

return PopupListMenu