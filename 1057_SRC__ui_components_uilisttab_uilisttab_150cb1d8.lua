------------------------------------------------
-- author:
-- Date: 2020-08-17
-- File: UIListTab.lua
-- Module: UIListTab
-- Description: Menu pagination Menu tab data = {Name: menu name, IsRedPoint: Whether to display red dots, IconId: IconId on the menu, Quality: Icon's quality background,
-- IsWear: Whether to display wearable marks IsShowStar: Whether to display star nodes StarNum: Number of stars}
------------------------------------------------

local SquareIcon = require "UI.Components.UIListTab.UITabSquareIcon"
local CrcularIcon = require "UI.Components.UIListTab.UITabCircularIcon"
local UIListTab = {
    Trans = nil,                        -- Transform
    TempTab = nil,
    Scroll = nil,
    Grid = nil,
    OnClickFunc = nil,

    UseIconFrameType = -1,               -- Icon type used (0: round icon, 1: square icon, 2: prop Item)
    ListTab = List:New(),
}

function UIListTab:New(trans, iconFrameType, clickFunc)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.UseIconFrameType = iconFrameType
    _m.OnClickFunc = clickFunc
    _m:FindAllComponents()
    return _m
end

 -- Find Components
function UIListTab:FindAllComponents()
    local _myTrans = self.Trans
    self.TempTab = UIUtils.FindGo(_myTrans, "Tab")
    self.Scroll = UIUtils.FindScrollView(_myTrans, "TabScroll")
    self.Grid = UIUtils.FindGrid(_myTrans, "TabScroll/Grid")

    self.TempTab:SetActive(false)
end

function UIListTab:Refreash(dataList, selectIndex)
    local gridTrans = self.Grid.transform
    if dataList == nil then
        for i = 1, gridTrans.childCount do
            local _trans = gridTrans:GetChild(i - 1)
            _trans.gameObject:SetActive(false)
        end
        return
    end
    local length = #dataList
    for i = 1, length do
        local tab = nil
        if i - 1 < gridTrans.childCount then
            tab = self.ListTab[i]
        else
            local go = UnityUtils.Clone(self.TempTab, gridTrans)
            local trans = go.transform
            local starRoot = UIUtils.FindGo(trans, "Star")
            local starGridTrans = UIUtils.FindTrans(trans, "Star/StarGrid")
            local name = UIUtils.FindLabel(trans, "Name")
            local selectName = UIUtils.FindLabel(trans, "SelectName")
            local select = UIUtils.FindGo(trans, "Select")
            local redPoint = UIUtils.FindGo(trans, "RedPoint")
            local cIcon = CrcularIcon:New(trans:Find("CircularIcon"),0)
            local sIcon = SquareIcon:New(trans:Find("SquareIcon"),1)
            local wearFlag = UIUtils.FindGo(trans, "WearFlag")
            local listStarGo = List:New()
            wearFlag:SetActive(false)
            if starRoot ~= nil then
                for m = 1, starGridTrans.childCount do
                    local starGo = starGridTrans:GetChild(m - 1):Find("Star").gameObject
                    listStarGo:Add(starGo)
                end
            end
            local btn = trans:GetComponent("UIButton")
            tab = {Go = go, Trans = trans, Name = name, SelectName = selectName, Select = select, RedPoint = redPoint, Btn = btn, CIcon = cIcon, SIcon = sIcon, WearFlag = wearFlag,
        StarRoot = starRoot, ListStarGo = listStarGo}
            self.ListTab:Add(tab)
        end
        if tab ~= nil and tab.Go ~= nil then
            -- Setting up data
            local data = dataList[i]
            UIUtils.SetTextByString(tab.Name, data.Name)
            UIUtils.SetTextByString(tab.SelectName, data.Name)
            if i == selectIndex then
                -- Selected status
                tab.Select:SetActive(true)
                tab.Name.gameObject:SetActive(false)
                tab.SelectName.gameObject:SetActive(true)
            else
                -- Unselected status
                tab.Select:SetActive(false)
                tab.Name.gameObject:SetActive(true)
                tab.SelectName.gameObject:SetActive(false)
            end
            tab.RedPoint:SetActive(data.IsRedPoint)
            UIUtils.AddBtnEvent(tab.Btn, self.OnClickBtn, self)
            if self.UseIconFrameType == 0 then
                tab.CIcon:SetCmp(data.IconId)
                tab.CIcon:SetVisable(self.UseIconFrameType)
            elseif self.UseIconFrameType == 1 then
                tab.SIcon:SetCmp(data.Quality, data.IconId)
                tab.SIcon:SetVisable(self.UseIconFrameType)
            end
            tab.WearFlag:SetActive(data.IsWear ~= nil and data.IsWear)
            if tab.StarRoot ~= nil then
                if data.IsShowStar == nil or not data.IsShowStar then
                    -- No stars are displayed
                    tab.StarRoot:SetActive(false)
                else
                    for m = 1, #tab.ListStarGo do
                        local starGo = tab.ListStarGo[m]
                        starGo:SetActive(m <= data.StarNum)
                    end
                    tab.StarRoot:SetActive(true)
                end
            end
            tab.Go:SetActive(true)
        end
    end
    if length < #self.ListTab then
        for i = length + 1, #self.ListTab do
            local tab = self.ListTab[i]
            if tab ~= nil and tab.Go ~= nil then
                tab.Go:SetActive(false)
            end
        end
    end
end

function UIListTab:NewRefresh(dataList, selectIndex)
    local gridTrans = self.Grid.transform
    if dataList == nil then
        for i = 1, gridTrans.childCount do
            local _trans = gridTrans:GetChild(i - 1)
            _trans.gameObject:SetActive(false)
        end
        return
    end
    local length = #dataList
    for i = 1, length do
        local tab = nil
        if i - 1 < gridTrans.childCount then
            tab = self.ListTab[i]
        else
            local go = UnityUtils.Clone(self.TempTab, gridTrans)
            local trans = go.transform
            local starRoot = UIUtils.FindGo(trans, "Star")
            local starGridTrans = UIUtils.FindTrans(trans, "Star/StarGrid")
            local name = UIUtils.FindLabel(trans, "Name")
            local selectName = UIUtils.FindLabel(trans, "SelectName")
            local select = UIUtils.FindGo(trans, "Select")
            local selectSpr = UIUtils.FindSpr(trans, "Select")
            local spriteSpr = UIUtils.FindSpr(trans, "Sprite")
            local SIQualitySpr = UIUtils.FindSpr(trans, "SquareIcon/Quality")
            local SIIConSpr = UIUtils.FindSpr(trans, "SquareIcon/Icon")
            local redPoint = UIUtils.FindGo(trans, "RedPoint")
            local cIcon = CrcularIcon:New(trans:Find("CircularIcon"),0)
            local sIcon = SquareIcon:New(trans:Find("SquareIcon"),1)
            local wearFlag = UIUtils.FindGo(trans, "WearFlag")
            local listStarGo = List:New()
            wearFlag:SetActive(false)
            -- if starRoot ~= nil then
            --     for m = 1, starGridTrans.childCount do
            --         local starGo = starGridTrans:GetChild(m - 1):Find("Star").gameObject
            --         listStarGo:Add(starGo)
            --     end
            -- end
            local btn = trans:GetComponent("UIButton")
            tab = {
                Go = go, 
                Trans = trans, 
                Name = name, 
                SelectName = selectName, 
                Select = select, 
                SelectSpr = selectSpr,
                SpriteSpr = spriteSpr,
                SIQualitySpr = SIQualitySpr,
                SIIConSpr = SIIConSpr,
                RedPoint = redPoint, 
                Btn = btn, 
                CIcon = cIcon, 
                SIcon = sIcon, 
                WearFlag = wearFlag
            }
            self.ListTab:Add(tab)
        end
        if tab ~= nil and tab.Go ~= nil then
            -- Setting up data
            local data = dataList[i]
            UIUtils.SetTextByString(tab.Name, data.Name)
            UIUtils.SetTextByString(tab.SelectName, data.Name)
            if i == selectIndex then
                -- Selected status
                tab.Select:SetActive(true)
                tab.Name.gameObject:SetActive(false)
                tab.SelectName.gameObject:SetActive(true)
            else
                -- Unselected status
                tab.Select:SetActive(false)
                tab.Name.gameObject:SetActive(true)
                tab.SelectName.gameObject:SetActive(false)
            end
            tab.RedPoint:SetActive(data.IsRedPoint)
            UIUtils.AddBtnEvent(tab.Btn, self.OnClickBtn, self)
            if self.UseIconFrameType == 0 then
                tab.CIcon:SetCmp(data.IconId)
                tab.CIcon:SetVisable(self.UseIconFrameType)
            elseif self.UseIconFrameType == 1 then
                tab.SIcon:SetCmp(data.Quality, data.IconId)
                tab.SIcon:SetVisable(self.UseIconFrameType)
            end
            tab.WearFlag:SetActive(data.IsWear ~= nil and data.IsWear)
            tab.Go:SetActive(true)

            -- set gray
            tab.SelectSpr.IsGray = not data.IsActive
            tab.SpriteSpr.IsGray = not data.IsActive
            tab.SIQualitySpr.IsGray = not data.IsActive
            tab.SIIConSpr.IsGray = not data.IsActive

        end
    end
    if length < #self.ListTab then
        for i = length + 1, #self.ListTab do
            local tab = self.ListTab[i]
            if tab ~= nil and tab.Go ~= nil then
                tab.Go:SetActive(false)
            end
        end
    end
end

-- Reset position
function UIListTab:ResetPosition()
    self.Grid.repositionNow = true
    self.Scroll.repositionWaitFrameCount = 2
end

function UIListTab:ResetPositionNow()
    self.Grid:Reposition()
    self.Scroll:ResetPosition()
end

-- Set red dots
function UIListTab:SetRedPoint(index, b)
    if index <= #self.ListTab then
        local tab = self.ListTab[index]
        if tab ~= nil and tab.RedPoint ~= nil then
            tab.RedPoint:SetActive(b)
        end
    end
end

-- Settings are selected
function UIListTab:SetSelectIndex(index, notDoFunc)
    for i = 1, #self.ListTab do
        local tab = self.ListTab[i]
        if tab ~= nil and tab.Btn ~= nil then
            local select = tab.Select
            select:SetActive(false)
            tab.Name.gameObject:SetActive(true)
            tab.SelectName.gameObject:SetActive(false)
            if i == index then
                select:SetActive(true)
                tab.Name.gameObject:SetActive(false)
                tab.SelectName.gameObject:SetActive(true)
                if self.OnClickFunc ~= nil then
                    if notDoFunc == nil or not notDoFunc then
                        self.OnClickFunc(i)
                    end
                end
            end
        end
    end
end

-- Click the menu button
function UIListTab:OnClickBtn()
    for i = 1, #self.ListTab do
        local tab = self.ListTab[i]
        if tab ~= nil and tab.Btn ~= nil then
            local select = tab.Select
            select:SetActive(false)
            tab.Name.gameObject:SetActive(true)
            tab.SelectName.gameObject:SetActive(false)
            if CS.UIButton.current == tab.Btn then
                select:SetActive(true)
                tab.Name.gameObject:SetActive(false)
                tab.SelectName.gameObject:SetActive(true)
                if self.OnClickFunc ~= nil then
                    self.OnClickFunc(i)
                end
            end
        end
    end
end

function UIListTab:GetScroll()
    return self.Scroll
end

function UIListTab:GetGrid()
    return self.Grid
end

function UIListTab:GetTab(index)
    local _ret = nil
    if self.ListTab ~= nil and index <= #self.ListTab then
        _ret = self.ListTab[index]
    end
    return _ret
end

function UIListTab:GetCount()
    local _ret = 0
    if self.ListTab ~= nil then
        _ret = #self.ListTab
    end
    return _ret
end

return UIListTab