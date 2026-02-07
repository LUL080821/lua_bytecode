------------------------------------------------
-- Author: 
-- Date: 2019-04-15
-- File: UIListMenu.lua
-- Module: UIListMenu, UIlistMenuIconData, UIListMenuIcon
-- Description: List Menu
------------------------------------------------
-- C#
local GameObject = CS.UnityEngine.GameObject

local UIListMenuIcon = require "UI.Components.UIListMenu.UIListMenuIcon"
local UIlistMenuIconData = require "UI.Components.UIListMenu.UIlistMenuIconData"

local UIListMenu = {
    Trans = nil,                        -- Transform
    CenterRes = nil,                    -- GameObject
    ResIconList = List:New(),           -- List<UIListMenuIcon>
    LeftIcon = nil,                     -- UIListMenuIcon
    RightIcon = nil,                    -- UIListMenuIcon
    IconList = List:New(),              -- List<UIListMenuIcon>
    IconDataList = List:New(),          -- List<UIlistMenuIconData>
    ParentForm = nil,                   -- UINormalForm
    Table = nil,                        -- UITable
    SelectCallBacks = List:New(),       -- List<MyAction<int, bool>> Callback list
    IsHideIconByFunc = false,           -- Whether to hide menu buttons based on functions
    IsUpdateRedByFuc = true,            -- Whether to update red dots based on functions
    IsInit = false,                     -- Whether to initialize
    IconOnClick = nil,                  -- icon click callback
    VfxId = 0,
    IsStripLanSymbol = false,           -- Whether the menu automatically resolves multilingual
}

-- Create a new object
function UIListMenu:OnFirstShow(owner, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.ParentForm = owner
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
 end

 -- Find Components
 function UIListMenu:FindAllComponents()
    if self.IsInit then
        return
    end

    local trans = self.Trans:Find("Table")
    for i = 1, trans.childCount, 1 do
        if i == 1 then
            local LeftRes = trans:GetChild(i - 1).gameObject
            self.LeftIcon = UIListMenuIcon:New(LeftRes, self)
        elseif i == trans.childCount then
            local RightRes =  trans:GetChild(i - 1).gameObject
            self.RightIcon = UIListMenuIcon:New(RightRes, self)
        else
            self.CenterRes =  trans:GetChild(i - 1).gameObject
            self.CenterRes.gameObject:SetActive(false)
            self.ResIconList:Add(UIListMenuIcon:New(self.CenterRes, self))
        end
    end

    self.Table = UIUtils.FindTable(self.Trans, "Table")
    IsInit = true;
 end
 function UIListMenu:AddIcon(id, text, funcCode, normalSpr, selectSpr, selectSpr2)
        local data = UIlistMenuIconData:New()
        data.ID = id
        data.Text = text
        data.FuncID = funcCode
        if funcCode ~= nil then
            data.FuncInfo =  GameCenter.MainFunctionSystem:GetFunctionInfo(funcCode)
            if not text and data.FuncInfo then
                data.Text = data.FuncInfo.Text
            end
        else
            data.FuncInfo = nil
        end
        data.NormalSpr = normalSpr
        data.SelectSpr = selectSpr
        data.SelectSpr2 = selectSpr2
        self.IconDataList:Add(data)
        self:RefreshIcon()
 end
 function UIListMenu:RemoveIcon(id)
    for i = 1, #self.IconDataList do
        if self.IconDataList[i].ID == id then
            self.IconDataList:RemoveAt(i)
        end
    end
    self:RefreshIcon()
 end
 function UIListMenu:RemoveAll()
    self.IconDataList:Clear()
    self:RefreshIcon()
 end
 function UIListMenu:SetSelectById(id)
     for i = 1, #self.IconList do
         if self.IconList[i].Data.ID == id then
             self:SetSelectByIndex(i)
             break
         end
    end
end
function UIListMenu:SetSelectByIndex(index)
    -- If the currently selected function is not open, the first open function is selected by default.
    if self.IconList[index] and self.IconList[index].Data.FuncInfo and not self.IconList[index].Data.FuncInfo.IsVisible then
        for i = 1, #self.IconList do
            if  self.IconList[i].Data.FuncInfo and self.IconList[i].Data.FuncInfo.IsVisible then
                index = i
                break
            end
        end
    end
    -- Perform uncheck first
    for i = 1, #self.IconList do
        if i ~= index then
            self.IconList[i]:IsSelect(false);
        end
    end

    if self.ParentForm ~= nil  then
        if not self.ParentForm.IsVisible then
            return
        end
    end
    -- Execute the selection again
    for i = 1, #self.IconList do
        if i == index then
            self.IconList[i]:IsSelect(true, self.VfxId)
        end
    end
end

-- Add callback
function UIListMenu:AddSelectEvent(func)
    if self.SelectCallBacks:Contains(func) then
        return
    end
    self.SelectCallBacks:Add(func)
end

-- Delete the callback
function UIListMenu:RemoveSelectEvent(func)
    self.SelectCallBacks:Remove(func)
end

function UIListMenu:ClearSelectEvent()
    self.SelectCallBacks:Clear()
end

-- Set whether to display
function UIListMenu:SetIconVisible(id, visible)
    for i = 1, #self.IconList do
        if self.IconList[i].Data.ID == id and ((self.IconList[i].Data.FuncInfo and  not self.IsHideIconByFunc) or not self.IconList[i].Data.FuncInfo) then
            self.IconList[i].RootGo:SetActive(visible)
            break
        end
    end
    self.Table:Reposition()
end

-- Set red dots
function UIListMenu:SetRedPoint(id, show)
    for i = 1, #self.IconList do
        if self.IconList[i].Data.ID == id and ((self.IconList[i].Data.FuncInfo and  not self.IsUpdateRedByFuc) or not self.IconList[i].Data.FuncInfo) then
            self.IconList[i].Data.ShowRedPoint = show
            self.IconList[i].RedPoint:SetActive(show)
            break
        end
    end
end

-- Set the display content
function UIListMenu:SetIconText(id, text)
    for i = 1, #self.IconList do
        local icon = self.IconList[i]
        if icon.Data.ID == id then
            icon.Data.Text = text
            icon:SetInfo(icon.Data)
        end
    end
end

-- Set up icon
function UIListMenu:SetIconSpr(id, normalSpr, selectSpr)
    for i = 1, #self.IconList do
        local icon = self.IconList[i]
        if icon.Data.ID == id then
            icon.Data.NormalSpr = normalSpr
            icon.Data.SelectSpr = selectSpr
            icon:SetInfo(icon.Data)
        end
    end
end

-- //Frame update
function UIListMenu:Update()
    local repos = false
    for i = 1, #self.IconList do
        local icon = self.IconList[i]
        if icon.Data.FuncInfo ~= nil then
            if self.IsUpdateRedByFuc and icon.Data.FuncInfo.IsShowRedPoint ~= icon.RedPoint.activeSelf then
                icon.RedPoint:SetActive(icon.Data.FuncInfo.IsShowRedPoint)
            end
            if self.IsHideIconByFunc and icon.Data.FuncInfo.IsVisible ~= icon.RootGo.activeSelf then
                repos = true
                icon.RootGo:SetActive(icon.Data.FuncInfo.IsVisible)
            end
        end
    end
    if repos then
        self.Table:Reposition()
    end
end

function UIListMenu:OnFunctionUpdate(obj, sender)
    local _funcID = obj.ID
    for i = 1, #self.IconList do
        local icon = self.IconList[i]
        if icon.Data.FuncInfo ~= nil then
            if icon.Data.FuncInfo.ID == _funcID then
                icon.Data.FuncInfo = obj
            end
        end
    end
end

function UIListMenu:RefreshIcon()
    self.IconList:Clear()
    self.LeftIcon.RootGo:SetActive(false)
    self.RightIcon.RootGo:SetActive(false)
    for i = 1, #self.ResIconList do
        self.ResIconList[i].RootGo:SetActive(false)
    end
    local resIndex = 1
    for i = 1, #self.IconDataList do
        if i == 1 then
            self.LeftIcon.RootGo.name = string.format("%03d", i - 1)
            self.LeftIcon:SetInfo(self.IconDataList[i])
            self.LeftIcon.RootGo:SetActive(true)
            self.IconList:Add(self.LeftIcon)
        elseif i == #self.IconDataList then
            self.RightIcon.RootGo.name = string.format("%03d", i - 1)
            self.RightIcon:SetInfo(self.IconDataList[i])
            self.RightIcon.RootGo:SetActive(true)
            self.IconList:Add(self.RightIcon)
        else
            local icon = nil
            if resIndex <= #self.ResIconList then
                icon = self.ResIconList[resIndex]
            else
                icon = UIListMenuIcon:New(UnityUtils.Clone(self.CenterRes), self)
                self.ResIconList:Add(icon)
            end

            icon.RootGo.name = string.format("%03d", i - 1)
            icon:SetInfo(self.IconDataList[i])
            icon.RootGo:SetActive(true)
            self.IconList:Add(icon)
            resIndex = resIndex + 1
        end
    end
    self.Table.repositionNow = true
end

function UIListMenu:OnSelectChanged(icon)
    self:DoCallBack(icon.Data.ID, icon.Select)
end

function UIListMenu:DoCallBack(id, select)
    for i = 1, #self.SelectCallBacks do
        if self.SelectCallBacks[i] ~= nil then
            self.SelectCallBacks[i](id, select)
        end
    end
end

function UIListMenu:OnDisable()
    --self:SetSelectByIndex(-1)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFunctionUpdate, self)
end

function UIListMenu:OnEnable()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFunctionUpdate, self)
end
return UIListMenu