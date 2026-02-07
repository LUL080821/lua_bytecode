------------------------------------------------
-- Author: 
-- Date: 2019-05-22
-- File: PopItem.lua
-- Module: PopItem
-- Description: Submenu of POP drop-down menu
------------------------------------------------

local PopItem = {
    Trans = nil,
    Go = nil,
    TextLabel = nil,
    ID = 0,
    CallBack = nil,
}

function PopItem:NewWithTrans(trans)
    local _M = Utils.DeepCopy(self)
    _M.Trans = trans
    _M.Go = trans.gameObject
    local _redPoint = UIUtils.FindTrans(_M.Trans, "Red")
    if _redPoint then
        _M.RedPointGo = UIUtils.FindGo(_M.Trans, "Red")
    end
    if UIUtils.FindTrans(_M.Trans, "Select") then
        _M.SelectGo = UIUtils.FindGo(_M.Trans, "Select")
    end
    _M.TextLabel = UIUtils.FindLabel(trans, "PopItemLabel")
    local _btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_btn, _M.OnClickBtn, _M)
    _M.BtnSpr = UIUtils.FindSpr(trans)
    return _M
end
function PopItem:NewWithGo(go)
    local _M = Utils.DeepCopy(self)
    _M.Trans = go.transform
    _M.Go = go
    local _redPoint = UIUtils.FindTrans(_M.Trans, "Red")
    if _redPoint then
        _M.RedPointGo = UIUtils.FindGo(_M.Trans, "Red")
    end
    if UIUtils.FindTrans(_M.Trans, "Select") then
        _M.SelectGo = UIUtils.FindGo(_M.Trans, "Select")
    end
    _M.TextLabel = UIUtils.FindLabel(_M.Trans, "PopItemLabel")
    local _btn = UIUtils.FindBtn(_M.Trans)
    UIUtils.AddBtnEvent(_btn, _M.OnClickBtn, _M)
    _M.BtnSpr = UIUtils.FindSpr(_M.Trans)
    return _M
end

function PopItem:OnClickBtn()
    if self.CallBack ~= nil then
        self.CallBack(self.ID)
    end
end

function PopItem:SetText(text, id)
    UIUtils.SetTextByString(self.TextLabel, text)
    self.ID = id;
end

function PopItem:SetSelect(isSelect)
    if(self.SelectGo) then
        self.SelectGo:SetActive(isSelect)
    end
end

function PopItem:SetRed(isRed)
    if self.RedPointGo then
        self.RedPointGo:SetActive(isRed)
    end
end

function PopItem:SetOnClickCallback(func)
    self.CallBack = func
end

function PopItem:SetGray(isg)
    self.BtnSpr.IsGray = isg
end
return PopItem