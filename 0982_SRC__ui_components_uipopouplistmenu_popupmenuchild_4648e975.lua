------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: PopoupMenuChild.lua
-- Module: PopoupMenuChild
-- Description: Drop-down menu submenu
------------------------------------------------

-- C# class
local PopupMenuChild = {
    Trans = nil,
    -- Red dot
    RedPoint = nil,
    -- Menu name
    NameLabel = nil,
    -- Select the menu name
    SelectName = nil,
    -- Menu background picture
    BackGround = nil,
    -- Select the picture on the menu
    CheckMark = nil,
    -- Menu Buttons
    MenuBtn = nil,
    --TweenPos = nil,
    -- Starting position of menu
    StartPos = Vector3.zero,
    -- Menu movement end position
    EndPos = Vector3.zero,
    -- External funcid
    FuncStartId = -1,
    -- child index
    ChildIndex = -1,
    -- Menu high
    MenuHeigh = -1,
    -- Menu spacing
    MenuDis = 2,
    Duration = 0.5,
    -- Is the menu open?
    IsOpen = false,
    -- Whether the menu is bounced back
    IsShrink = true,
    -- Menu Controller
    MenuControl = nil,
    --callBack
    MenuCall = nil,
    Tick = 0,
    Time = 0.5,
    CanOpen = true,
    NorColor = "#FFFFFF",
    SelectColor = "#865024",
    Enable = false,
    IsShowRedPoint = false,
}

-- Button Event
function PopupMenuChild:OnClickMenu()
    if self.IsOpen == false then
        -- Open
        self.MenuControl:UpdateChildMenu(self.FuncStartId)
    end
end

-- Create MenuChild
function PopupMenuChild:New(tempTrans, data,index,count, menuCol, call, needClone, initY, offsetY)
    local _m = Utils.DeepCopy(self)
    local yPos = 0
    if offsetY ~= 0 and offsetY ~= nil then
        _m.MenuDis = offsetY
    end
    _m.ChildIndex = index
    _m.FuncStartId = data.Id
    _m.MenuControl = menuCol
    _m.MenuCall = call
    if needClone then
        _m.Trans = UnityUtils.Clone(tempTrans.gameObject).transform
    else
        _m.Trans = tempTrans
        UnityUtils.SetLocalPositionY(_m.Trans, initY)
    end
    _m.Trans.gameObject:SetActive(false)
    _m:FindAllComponent()
    UIUtils.SetTextByString(_m.NameLabel, data.Name)
    UIUtils.SetTextByString(_m.SelectNameLabel, data.Name)
    _m:SetButton()
    _m:SetEndPos(count)
    yPos = (_m.MenuHeigh + _m.MenuDis) * (count-_m.ChildIndex)
    _m.StartPos = Vector3(0, yPos, 0)
    UnityUtils.SetLocalPosition(_m.Trans, 0, yPos, 0)
    _m.Time = math.abs(_m.StartPos.y-_m.EndPos.y)/_m.MenuControl.Speed
    _m.Trans.name = tostring(data.Id)
    _m.Enable = true
    return _m
end

function PopupMenuChild:Refreash(tempTrans, data,index,count, menuCol, call, needClone, initY, offsetY)
    local yPos = 0
    self.ChildIndex = index
    self.FuncStartId = data.Id
    self.MenuControl = menuCol
    self.MenuCall = call
    if needClone then
        self.Trans = UnityUtils.Clone(tempTrans.gameObject).transform
        self:FindAllComponent()
        self:SetButton()
    else
        self.Trans = tempTrans
        UnityUtils.SetLocalPositionY(self.Trans, initY)
    end
    self.Trans.gameObject:SetActive(false)
    UIUtils.SetTextByString(self.NameLabel, data.Name)
    self:SetEndPos(count)
    yPos = (self.MenuHeigh + self.MenuDis) * (count-self.ChildIndex)
    self.StartPos = Vector3(0, yPos, 0)
    UnityUtils.SetLocalPosition(self.Trans, 0, yPos, 0)
    self.Time = math.abs(self.StartPos.y-self.EndPos.y)/self.MenuControl.Speed
    self.Trans.name = tostring(data.Id)
    self.Enable = true
end

-- Find Components
function PopupMenuChild:FindAllComponent()
    local _myTrans = self.Trans
    local backSprite = nil
    self.BackGround = self.Trans:Find('BackBround')
    self.CheckMark = self.Trans:Find('CheckMark')
    self.MenuBtn = UIUtils.FindBtn(self.Trans)
    backSprite = UIUtils.FindSpr(self.BackGround)
    self.MenuHeigh = backSprite.height
    self.BackGround.gameObject:SetActive(true)
    self.CheckMark.gameObject:SetActive(false)
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Name")
    self.RedPoint = self.Trans:Find("RedPoint")
    self.RedPoint.gameObject:SetActive(false)
    if self.MenuControl.IsUseSelectName then
        self.SelectNameLabel = UIUtils.FindLabel(_myTrans, "NameSelect")
        self.NameLabel.gameObject:SetActive(true)
        self.SelectNameLabel.gameObject:SetActive(false)
    end
end

-- Set button
function PopupMenuChild:SetButton()
    UIUtils.AddBtnEvent(self.MenuBtn, self.OnClickMenu, self)
end

-- Open the UI
function PopupMenuChild:OpenFunction(isCall)
    self.IsOpen = true
    -- Set the selected status
    if self.MenuControl.IsUseSelectName then
        self.NameLabel.gameObject:SetActive(false)
        self.SelectNameLabel.gameObject:SetActive(true)
    end
    self.BackGround.gameObject:SetActive(false)
    self.CheckMark.gameObject:SetActive(true)
    if isCall then
        self.MenuCall(self.FuncStartId)
        self.MenuControl.CurSelectFuncId = self.FuncStartId
    end
    if self.CanOpen and not self.MenuControl.IsUseSelectName then
        UIUtils.SetColorByString(self.NameLabel, self.SelectColor)
    end
end

-- Set button unchecked
function PopupMenuChild:SetUnSelected()
    self.IsOpen = false
    if self.MenuControl.IsUseSelectName then
        self.NameLabel.gameObject:SetActive(true)
        self.SelectNameLabel.gameObject:SetActive(false)
    end
    self.BackGround.gameObject:SetActive(true)
    self.CheckMark.gameObject:SetActive(false)
    if not self.MenuControl.IsUseSelectName then
        UIUtils.SetColorByString(self.NameLabel, self.NorColor)
    end
end

-- Move to the target position
function PopupMenuChild:MoveToTargetPos()
    self.Tick = self.Time
    
end

-- Move back to the initial position
function PopupMenuChild:MoveToStartPos()
    self.Tick = self.Time
end

--hide
function PopupMenuChild:HideMenu()
    UnityUtils.SetLocalPosition(self.Trans, self.StartPos.x, self.StartPos.y, self.StartPos.z)
    self.Trans.gameObject:SetActive(false)
    self.Tick = 0
    self.IsShrink = true
end

-- Get the Y coordinate of the displacement target position
function PopupMenuChild:SetEndPos(count)
    local offsetY = 0
    if self.MenuControl.OffsetY ~= nil then
        offsetY = self.MenuControl.OffsetY
    end
    local yPos = (self.MenuHeigh + self.MenuDis) * self.ChildIndex + offsetY
    self.EndPos = Vector3(self.StartPos.x, -yPos, self.StartPos.z)
end

-- Get whether the submenu is shrinking
function PopupMenuChild:GetShrink()
    return self.IsShrink and self.Tick == 0
end

-- Get whether the submenu is moved
function PopupMenuChild:IsMove()
    return self.Tick ~=0
end

function PopupMenuChild:UpdatePos(dt,isOpen)
    if self.Tick ~= 0 then
        local _pos = nil
        if isOpen then
            if self.Tick>0 then
                --self.Tick = self.Tick - dt
                self.Tick = 0
                _pos = Utils.Lerp(self.EndPos,self.StartPos,0)--self.Tick/self.Time)
                if _pos.y<= -self.MenuHeigh then
                    self.Trans.gameObject:SetActive(self.Enable)
                end
            else
                self.Tick = 0
                self.IsShrink = false
                _pos = self.EndPos
            end
        else
            if self.Tick>0 then
                --self.Tick = self.Tick - dt
                self.Tick = 0
                _pos = Utils.Lerp(self.StartPos,self.EndPos,0)--self.Tick/self.Time)
                if _pos.y >= -self.MenuHeigh then
                    self.Trans.gameObject:SetActive(false)
                end
            else
                self.Tick = 0
                self.IsShrink = true
                _pos = self.StartPos
            end
        end
        UnityUtils.SetLocalPosition(self.Trans, _pos.x, _pos.y, _pos.z)
    end
end

function PopupMenuChild:SetRedPoint(b)
    self.RedPoint.gameObject:SetActive(b)
    self.IsShowRedPoint = b
end

function PopupMenuChild:Clear()
    CS.UnityEngine.Object.Destory(self.Trans.gameObject)
end
return PopupMenuChild
