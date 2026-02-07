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

local UIListMenuRight = {
    Trans = nil,                        -- Transform
    CenterRes = nil,                    -- GameObject
    ResIconList = List:New(),           -- List<UIListMenuIcon>
    IconList = List:New(),              -- List<UIListMenuIcon>
    IconDataList = List:New(),          -- List<UIlistMenuIconData>
    ParentForm = nil,                   -- UINormalForm
    Table = nil,                        -- UITable
    SelectCallBacks = List:New(),       -- List<MyAction<int, bool>> Callback list
    IsHideIconByFunc = false,           -- Whether to hide menu buttons based on functions
    IsInit = false,                     -- Whether to initialize
    IconOnClick = nil,                  -- icon click callback
    IsStripLanSymbol = false,           -- Whether the menu automatically resolves multilingual
}

-- Create a new object
function UIListMenuRight:OnFirstShow(owner, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.ParentForm = owner
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
 end

 -- Find Components
 function UIListMenuRight:FindAllComponents()
    if self.IsInit then
        return
    end
    self.ResIconList = List:New()
    local trans = self.Trans:Find("Table")
    self.Count = trans.childCount
    for i = 0, self.Count - 1, 1 do
        self.CenterRes =  trans:GetChild(i).gameObject
        self.ResIconList:Add(UIListMenuIcon:New(self.CenterRes, self))
    end
    IsInit = true;
 end
 function UIListMenuRight:AddIcon(id, text, funcCode, normalSpr, selectSpr, selectSpr2)
    if #self.IconDataList >= self.Count then
        return
    end
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
 function UIListMenuRight:RemoveIcon(id)
    for i = 1, #self.IconDataList do
        if self.IconDataList[i].ID == id then
            self.IconDataList:RemoveAt(i)
        end
    end
    self:RefreshIcon()
 end
 function UIListMenuRight:RemoveAll()
    self.IconDataList:Clear()
    self:RefreshIcon()
 end
 function UIListMenuRight:SetSelectById(id)
     for i = 1, #self.IconList do
         if self.IconList[i].Data.ID == id then
             self:SetSelectByIndex(i)
             return
         end
    end
    self:SetSelectByIndex(1)
end

-- Uncheck
function UIListMenuRight:OnCancelSelectAll()
    -- Perform uncheck first
    for i = 1, #self.IconList do
        self.IconList[i]:IsSelect(false);
    end
end

function UIListMenuRight:SetSelectByIndex(index)
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
            self.IconList[i]:IsSelect(true)
        end
    end
end

-- Add callback
function UIListMenuRight:AddSelectEvent(func)
    if self.SelectCallBacks:Contains(func) then
        return
    end
    self.SelectCallBacks:Add(func)
end

-- Delete the callback
function UIListMenuRight:RemoveSelectEvent(func)
    self.SelectCallBacks:Remove(func)
end

function UIListMenuRight:ClearSelectEvent()
    self.SelectCallBacks:Clear()
end

-- Set whether to display
function UIListMenuRight:SetIconVisible(id, visible)
    for i = 1, #self.IconList do
        if self.IconList[i].Data.ID == id and not self.IsHideIconByFunc then
            self.IconList[i].RootGo:SetActive(visible)
        end
    end
end

-- Set red dots
function UIListMenuRight:SetRedPoint(id, show)
    for i = 1, #self.IconList do
        if self.IconList[i].Data.ID == id and not self.IsHideIconByFunc then
            self.IconList[i].Data.ShowRedPoint = show
            self.IconList[i].RedPoint:SetActive(show)
        end
    end
end

-- Set the display content
function UIListMenuRight:SetIconText(id, text)
    for i = 1, #self.IconDataList do
        if self.IconDataList[i].ID == id then
            self.IconDataList[i].Text = text
            self:RefreshIcon()
        end
    end
end

-- Set up icon
function UIListMenuRight:SetIconSpr(id, normalSpr, selectSpr)
    for i = 1, #self.IconDataList do
        if self.IconDataList[i].ID == id then
            self.IconDataList[i].NormalSpr = normalSpr
            self.IconDataList[i].SelectSpr = selectSpr
            self:RefreshIcon()
        end
    end
end

-- //Frame update
function UIListMenuRight:Update()
    -- for i = 1, #self.IconList do
    --     local icon = self.IconList[i]
    --     if icon.Data.FuncInfo ~= nil then
    --         if icon.Data.FuncInfo.IsShowRedPoint ~= icon.RedPoint.activeSelf then
    --             icon.RedPoint:SetActive(icon.Data.FuncInfo.IsShowRedPoint)
    --         end
    --         if icon.Data.FuncInfo.IsVisible ~= icon.RootGo.activeSelf and self.IsHideIconByFunc then
    --             icon.RootGo:SetActive(icon.Data.FuncInfo.IsVisible)
    --         end
    --     end
    -- end
end

function UIListMenuRight:OnFunctionUpdate(obj, sender)
    for i = 1, #self.IconDataList do
        if self.IconDataList[i].FuncInfo ~= nil then
            if self.IconDataList[i].FuncInfo.ID == obj.ID then
                self.IconDataList[i].FuncInfo = obj
                self:RefreshIcon()
                break
            end
        end
    end
end

function UIListMenuRight:RefreshIcon()
    self.IconList:Clear()
    local resIndex = 1
    for i = 1, #self.IconDataList do
        local icon = nil
        if resIndex <= #self.ResIconList then
            icon = self.ResIconList[resIndex]
        end
        if icon and ((self.IsHideIconByFunc and self.IconDataList[i].FuncInfo and self.IconDataList[i].FuncInfo.IsVisible) or not self.IsHideIconByFunc) then
            icon.RootGo.name = string.format("%03d", i - 1)
            icon:SetInfo(self.IconDataList[i])
            icon.RootGo:SetActive(true)
            self.IconList:Add(icon)
            resIndex = resIndex + 1
        end
    end
    for i = resIndex, #self.ResIconList do
        self.ResIconList[i].RootGo:SetActive(false)
    end
end

function UIListMenuRight:OnSelectChanged(icon)
    self:DoCallBack(icon.Data.ID, icon.Select)
end

function UIListMenuRight:DoCallBack(id, select)
    for i = 1, #self.SelectCallBacks do
        if self.SelectCallBacks[i] ~= nil then
            self.SelectCallBacks[i](id, select)
        end
    end
end

function UIListMenuRight:OnDisable()
    --self:SetSelectByIndex(-1)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFunctionUpdate, self)
end

function UIListMenuRight:OnEnable()
    if self.IsHideIconByFunc then
        for i = 1, #self.IconDataList do
            if self.IconDataList[i].FuncInfo then
                self.IconDataList[i].FuncInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(self.IconDataList[i].FuncInfo.ID)
            end
        end
    end
    self:RefreshIcon()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFunctionUpdate, self)
end
return UIListMenuRight