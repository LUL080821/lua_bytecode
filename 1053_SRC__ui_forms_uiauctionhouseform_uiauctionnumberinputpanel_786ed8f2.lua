------------------------------------------------
-- author:
-- Date: 2021-03-16
-- File: UIAuctionNumberInputPanel.lua
-- Module: UIAuctionNumberInputPanel
-- Description: Task paging on the left side of the main interface
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIAuctionNumberInputPanel = {
    Btns = nil,
    OKBtn = nil,
    DelBtn = nil,
    CloseBtn = nil,
    InputCallBack = nil, 
    DelCallBack = nil,
    BackTex = nil,
}

function UIAuctionNumberInputPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)
    self.AnimModule:AddNormalAnimation(0.3)

    self.Btns = {}
    for i = 1, 10 do
        self.Btns[i] = UIUtils.FindBtn(trans, string.format("Root/%d", i - 1))
        UIUtils.AddBtnEvent(self.Btns[i], self.OnNumberClick, self, i - 1)
    end
    self.OKBtn = UIUtils.FindBtn(trans, "Root/OK")
    UIUtils.AddBtnEvent(self.OKBtn, self.OnCloseBtnClcik, self)
    self.DelBtn = UIUtils.FindBtn(trans, "Root/Del")
    UIUtils.AddBtnEvent(self.DelBtn, self.OnDelBtnClcik, self)
    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClcik, self)
    self.BackTex = UIUtils.FindTex(trans, "Root/bg")
end

function UIAuctionNumberInputPanel:OnShowAfter()
	self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_3_2"))
end

function UIAuctionNumberInputPanel:OnHideAfter()
    if self.HideCallBack ~= nil then
        self.HideCallBack()
    end
end

function UIAuctionNumberInputPanel:OpenInput(inputCallBack, delCallBack, hideCallBack)
    if inputCallBack == nil or delCallBack == nil then
        return
    end
    self.InputCallBack = inputCallBack
    self.DelCallBack = delCallBack
    self.HideCallBack = hideCallBack
    self:Open()
end

function UIAuctionNumberInputPanel:OnNumberClick(num)
    self.InputCallBack(num)
end

function UIAuctionNumberInputPanel:OnDelBtnClcik()
    self.DelCallBack()
end

function UIAuctionNumberInputPanel:OnCloseBtnClcik()
    self:Close()
end

return UIAuctionNumberInputPanel