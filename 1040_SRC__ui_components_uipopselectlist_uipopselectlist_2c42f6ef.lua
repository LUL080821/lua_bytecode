------------------------------------------------
-- Author: 
-- Date: 2019-05-21
-- File: UIPopSelectList.lua
-- Module: UIPopSelectList
-- Description: Click the button to pop up list and select the item, the value of the item is assigned to the button, that is, a simple drop-down menu
------------------------------------------------
local PopItem = require "UI.Components.UIPopSelectList.PopItem"
local L_Flip = CS.UIBasicSprite.Flip
local UIPopSelectList = {
    Trans = nil,
    Go = nil,
    TextLabel = nil,
    MainBtn = nil,
    PopParentGo = nil,
    PopScroll = nil,
    PopGrid = nil,
    PopGridTrans = nil,
    PopTempItemGo = nil,
    -- List data
    DataList = List:New(),
    -- Pop-up item list
    PopItemList = List:New(),
    -- The currently selected data index
    CurSelectIndex = -1,
    -- Select the result callback
    OnSelectCallBack = nil,
    IsInit = false,
    VOrH = true,
}

function UIPopSelectList:OnFirstShow(trans, vorh)
    local _M = Utils.DeepCopy(self)
    _M.Trans = trans
    _M.Go = trans.gameObject
    if vorh ~= nil then
        _M.VOrH = vorh
    else
        _M.VOrH = true
    end
    _M:FindAllComponents()
    LuaBehaviourManager:Add(_M.Trans, _M)
    return _M
end

function UIPopSelectList:FindAllComponents()
    if self.IsInit then
        return
    end
    self.DownSpr = UIUtils.FindSpr(self.Trans, "DownArrow")
    self.TextLabel = UIUtils.FindLabel(self.Trans, "Text")
    self.MainBtn = UIUtils.FindBtn(self.Trans)
    self.PopParentGo = UIUtils.FindGo(self.Trans, "PopWidget")
    self.PopScroll = UIUtils.FindScrollView(self.Trans, "PopWidget/ScrollView")
    self.PopGrid = UIUtils.FindGrid(self.Trans, "PopWidget/ScrollView/Grid")
    self.PopGridTrans = UIUtils.FindTrans(self.Trans, "PopWidget/ScrollView/Grid")
    self.PopTempItemGo = UIUtils.FindGo(self.Trans, "PopWidget/ScrollView/Grid/PopBtnItem")
    local _redPoint = UIUtils.FindTrans(self.Trans, "Red")
    if _redPoint then
        self.RedPointGo = UIUtils.FindGo(self.Trans, "Red")
    end
    if self.PopTempItemGo ~= nil then
        self.PopTempItemGo:SetActive(false)
    end
    self.PopParentGo:SetActive(false)
    self.DownSpr.flip = L_Flip.Nothing
    UIUtils.AddBtnEvent(self.MainBtn, self.OnClickMainBtn, self)

    self.IsInit = true
end
function UIPopSelectList:SetData(dataList)
    self:Clear()
    if dataList == nil then
        return
    end
    if #dataList == 0 then
        return
    end
    UIUtils.SetTextByString(self.TextLabel, dataList[1].Text)
    self.CurSelectIndex = 1
    self.IsRed = false
    for i = 1, #dataList do
        local _popItemIns = nil
        self.DataList:Add(dataList[i])
        if i > self.PopGridTrans.childCount then
            _popItemIns = UnityUtils.Clone(self.PopTempItemGo)
        else
            _popItemIns = self.PopGridTrans:GetChild(i-1).gameObject
        end
        _popItemIns:SetActive(true)

        local popItemScript = PopItem:NewWithGo(_popItemIns)
        popItemScript:SetText(dataList[i].Text, i)
        popItemScript:SetOnClickCallback(Utils.Handler(self.OnPopItemClick, self))
        if dataList[i].Red then
            self.IsRed = true
            popItemScript:SetRed(true)
        else
            popItemScript:SetRed(false)
        end
        if dataList[i].IsActive == nil or  dataList[i].IsActive == true then
            popItemScript:SetGray(false)
        elseif dataList[i].IsActive == false then
            popItemScript:SetGray(true)
        end
        popItemScript:SetSelect(false)
        self.PopItemList:Add(popItemScript);
    end
    if self.RedPointGo then
        self.RedPointGo:SetActive(self.IsRed)
    end
end

-- Refresh a list data
function UIPopSelectList:UpdateChild(data)
    for i = 1, #self.DataList do
        if self.DataList[i].ID == data.ID then
            self.DataList[i] = data
            self.PopItemList[i]:SetText(data.Text, i)
            if data.Red then
                self.IsRed = true
                self.PopItemList[i]:SetRed(true)
            else
                self.PopItemList[i]:SetRed(false)
            end
            break
        end
    end
end

-- Refresh the red dot at the top
function UIPopSelectList:UpdateRedPoint()
    self.IsRed = false
    for i = 1, #self.DataList do
        if self.DataList[i].Red then
            self.IsRed = true
            break
        end
    end
    if self.RedPointGo then
        self.RedPointGo:SetActive(self.IsRed)
    end
end

function UIPopSelectList:Clear()
    for i = 1, #self.PopItemList do
        self.PopItemList[i].Go:SetActive(false)
    end
    self.PopItemList:Clear()
    self.DataList:Clear()
end

-- Select according to the index
function UIPopSelectList:SetSelect(index)
    self:OnPopItemClick(index)
end
-- Select according to the set data ID
function UIPopSelectList:SetSelectById(id)
    local _index = 1
    for i = 1, #self.DataList do
        if self.DataList[i].ID == id then
            _index = i
            break
        end
    end
    self:OnPopItemClick(_index)
end

function UIPopSelectList:SetSelectByRed()
    local _index = 1
    for i = 1, #self.DataList do
        if self.DataList[i].Red then
            _index = i
            break
        end
    end
    self:OnPopItemClick(_index)
end

-- Return the currently selected index
function UIPopSelectList:GetSelectedIndex()
    return self.CurSelectIndex
end

-- Set the selection result callback function
function UIPopSelectList:SetOnSelectCallback(func)
    self.OnSelectCallBack = func
end

function UIPopSelectList:RemoveCameraClickEvent()
    LuaDelegateManager.Remove(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end
function UIPopSelectList:AddCameraClickEvent()
    LuaDelegateManager.Add(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end
function UIPopSelectList:OnUICameraEventListener(curObj)
    if curObj ~= nil then
        if not self:IsUIInMyUI(curObj) then
            self:PopDownWidget()
        end
    end
end
function UIPopSelectList:IsUIInMyUI(go)
    if go == nil then
        return false
    end
    if go == self.Go then
        return true
    end
    if (CS.Thousandto.Core.Base.UnityUtils.CheckChild(self.Trans, go.transform)) then
        return true
    end
    return false
end

function UIPopSelectList:OnClickMainBtn()
    if self.PopParentGo.activeSelf then
        self:PopDownWidget()
    else
        self:PopUpWidget()
    end
end

function UIPopSelectList:OnPopItemClick(index)
    if #self.DataList == 0 then
        return;
    end
    UIUtils.SetTextByString(self.TextLabel, self.DataList[index].Text)
    self.CurSelectIndex = index
    self:OnSelectFinish(index)
end

function UIPopSelectList:PopUpWidget()
    if self.VOrH then
        self.DownSpr.flip = L_Flip.Horizontally
    else
        self.DownSpr.flip = L_Flip.Vertically
    end
    self.PopParentGo:SetActive(true)
    self.PopGrid:Reposition()

    -- Camera click event is registered only when the pop-up list is opened
    self:AddCameraClickEvent()
    for i = 1, #self.PopItemList do
        self.PopItemList[i]:SetSelect(i == self.CurSelectIndex)
    end
    self.PopScroll.repositionWaitFrameCount = 2
end

function UIPopSelectList:PopDownWidget()
    if self.PopParentGo then
        self.PopParentGo:SetActive(false)
        self.DownSpr.flip = L_Flip.Nothing
    end

    -- Close the list and remove the click event
    self:RemoveCameraClickEvent()
end

function UIPopSelectList:OnSelectFinish(index)
    if self.OnSelectCallBack ~= nil then
        self.OnSelectCallBack(index, self.DataList[index])
    end
    self:PopDownWidget()
end

function UIPopSelectList:OnDisable()

end
function UIPopSelectList:OnEnable()

end

function UIPopSelectList:OnDestroy()
    -- Remove click event
    self:RemoveCameraClickEvent()
    CS.UICamera.RemoveGenericEventHandler(self.Go)
end
return UIPopSelectList