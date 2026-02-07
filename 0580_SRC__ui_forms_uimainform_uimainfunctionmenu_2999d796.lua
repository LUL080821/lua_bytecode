------------------------------------------------
-- author:
-- Date: 2021-02-25
-- File: UIMainFunctionMenu.lua
-- Module: UIMainFunctionMenu
-- Description: Top menu page at the main interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local CSInput = CS.UnityEngine.Input

local UIMainFunctionMenu = {
    Res = nil,
    BackSpr = nil,
    Grid = nil,
    ItemItem = List:New(),
    CurRootFunc = nil,
    OpenFrameCount = 0,
}

local L_FunctionMenuItem = nil

function UIMainFunctionMenu:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    local _rootTrans = UIUtils.FindTrans(trans, "Grid")
    local _childCount = _rootTrans.childCount
    self.Res = nil
    self.ItemItem:Clear()
    for i = 1, _childCount do
        local _childTrans = _rootTrans:GetChild(i - 1)
        if self.Res == nil then
            self.Res = _childTrans.gameObject
        end
        self.ItemItem:Add(L_FunctionMenuItem:New(_childTrans.gameObject, self))
    end
    self.BackSpr = UIUtils.FindSpr(trans, "Back")
    self.Grid = UIUtils.FindGrid(trans, "Grid")
    self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 0.5, 0.5, 1, 1)
    return self
end
function UIMainFunctionMenu:OpenMenu(funcInfo, pos)
    if funcInfo == nil then
        return
    end
    local _childList = funcInfo.ChildList
    local _childCount = _childList.Count
    self.CurRootFunc = funcInfo
    local _resIndex = 1
    for i = 1, _childCount do
        local _chidData = _childList[i - 1]
        if _chidData.IsVisible then
            local _itemUI = nil
            if _resIndex <= #self.ItemItem then
                _itemUI = self.ItemItem[_resIndex]
            else
                _itemUI = L_FunctionMenuItem:New(UnityUtils.Clone(self.Res), self)
                self.ItemItem:Add(_itemUI)
            end
            _itemUI:SetInfo(_chidData)
            _resIndex = _resIndex + 1
        end
    end
    self.BackSpr.height = (_resIndex - 1) * 48 + 11
    for i = _resIndex, #self.ItemItem do
        self.ItemItem[i]:SetInfo(nil)
    end
    local _posZ = self.Trans.localPosition.z
    UnityUtils.SetLocalPosition(self.Trans, pos.x, pos.y, _posZ)
    self:Open()
    self.Grid.repositionNow = true
    self.OpenFrameCount = Time.GetFrameCount()
end

function UIMainFunctionMenu:OnHideAfter()
    self.CurRootFunc = nil
end
function UIMainFunctionMenu:Update(dt)
    if self.IsVisible then
        if Time.GetFrameCount() - self.OpenFrameCount < 10  then
            return
        end
        if CSInput.GetMouseButtonUp(0) then
            self:Close()
        end
    end
end

L_FunctionMenuItem = {
    Go = nil,
    Name = nil,
    Btn = nil,
    RedPoint = nil,
    FuncInfo = nil,
    Parent = nil,
}

function L_FunctionMenuItem:New(go, parent)
    local _m = Utils.DeepCopy(self)
    _m.Go = go
    _m.Parent = parent
    local _trans = go.transform
    _m.Name = UIUtils.FindLabel(_trans, "Name")
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.RedPoint = UIUtils.FindGo(_trans, "RedPoint")
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    return _m
end
function L_FunctionMenuItem:SetInfo(funcInfo)
    self.FuncInfo = funcInfo
    self.Go:SetActive(funcInfo ~= nil)
    if funcInfo ~= nil then
        local _funcId = funcInfo.ID
        local _cfg = DataConfig.DataFunctionStart[_funcId]
        UIUtils.SetTextByStringDefinesID(self.Name, _cfg._FunctionName)
        self.RedPoint:SetActive(funcInfo.IsShowRedPoint)
    end
end
function L_FunctionMenuItem:OnClick()
    self.Parent:Close()
    if self.FuncInfo ~= nil then
        self.FuncInfo:OnClickHandler(nil)
    end
end
return UIMainFunctionMenu