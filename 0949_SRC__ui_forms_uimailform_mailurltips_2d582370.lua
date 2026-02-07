------------------------------------------------
-- author:
-- Date: 2021-07-30
-- File: MailUrlTips.lua
-- Module: MailUrlTips
-- Description: Mail hyperlink
------------------------------------------------

-- C# class
local MailUrlTips = {
    Trans = nil,
    Go = nil,
    CopyBtn = nil,
    OpenBtn = nil,
    CloseBtn = nil,
    Url = "",
}

function MailUrlTips:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CopyBtn = UIUtils.FindBtn(trans, "Bg/CopyBtn")
    _m.OpenBtn = UIUtils.FindBtn(trans, "Bg/OpenBtn")
    _m.CloseBtn = UIUtils.FindBtn(trans, "Close")
    UIUtils.AddBtnEvent(_m.CopyBtn, _m.OnClickCopy, _m)
    UIUtils.AddBtnEvent(_m.OpenBtn, _m.OnClickOpen, _m)
    UIUtils.AddBtnEvent(_m.CloseBtn, _m.OnClickClose, _m)
    return _m
end

function MailUrlTips:Open(url, pos)
    self.Url = url
    UnityUtils.SetPosition(self.Trans, pos.x, pos.y, pos.z)
    self.Go:SetActive(true)
end

function MailUrlTips:Close()
    self.Go:SetActive(false)
end

function MailUrlTips:OnClickCopy()
    UnityUtils.CopyToClipboard(self.Url)
end

function MailUrlTips:OnClickOpen()
    CS.UnityEngine.Application.OpenURL(self.Url)
end

function MailUrlTips:OnClickClose()
    self:Close()
end

return MailUrlTips
