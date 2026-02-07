------------------------------------------------
-- Author: 
-- Date: 2019-05-22
-- File: UICheckBox.lua
-- Module: UICheckBox
-- Description: Select box control
------------------------------------------------

local UICheckBox ={
    Trans = nil,
    Go = nil,
    -- Select the icon
    OkGo = nil,
    -- Click
    CheckBtn = nil,
    IsChecked = false,
    CallBack = nil
}

function UICheckBox:OnFirstShow(trans)
    local _M = Utils.DeepCopy(self)
    _M.Trans = trans
    _M.Go = trans.gameObject
    _M.OkGo = UIUtils.FindGo(trans, "Ok")
    _M.CheckBtn = UIUtils.FindBtn(trans)
    _M.OkGo:SetActive(_M.IsChecked)
    UIUtils.AddBtnEvent(_M.CheckBtn, _M.onClickCheckBtn, _M)
    return _M
end

-- Setting up click events
function UICheckBox:SetOnClickFunc(func)
    self.CallBack = func
end

-- Settings are selected
function UICheckBox:SetChecked(ischeck, isCallBack)
    self.IsChecked = ischeck
    self.OkGo:SetActive(self.IsChecked)
    if isCallBack == nil then
        isCallBack = true
    end
    if self.CallBack ~= nil and isCallBack then
        self.CallBack(self.IsChecked)
    end
end

function UICheckBox:onClickCheckBtn()
    self.IsChecked = not self.IsChecked
    self.OkGo:SetActive(self.IsChecked)
    if self.CallBack ~= nil then
        self.CallBack(self.IsChecked)
    end
    if self.CallBack2 then
        self.CallBack2(self)
    end
end
return UICheckBox