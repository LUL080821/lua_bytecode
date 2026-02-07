------------------------------------------------
-- Author: gaoziyu
-- Date: 2021-02-23
-- File: UILoginNoticeForm.lua
-- Module: UILoginNoticeForm
-- Description: Log in to the announcement interface
------------------------------------------------

local UILoginNoticeForm = {
    -- Prompt text
    TitleLabel = nil,
    -- Announcement content text
    ContentLabel = nil,
    -- Close button
    CloseBtn = nil,
    -- Waiting for the UI interface
    WaitingUI = nil,
    -- No announcement interface yet
    EmptyTextGo = nil,
    -- Background picture of the service announcement
    --LeftTex = nil,
    -- Announcement background image
    --RightTex = nil,
    -- Announcement box UI component
    ScrollView = nil,
    -- Default prompt text
    DefaultTitle = nil,
    -- Announcement text list
    NoticeList = List:New()

}

-- Register Events
function UILoginNoticeForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UI_LOGIN_NOTICE_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_LOGINNOTICE_REFRESH, self.OnRefresh)
end

-- Open the first time to execute
function UILoginNoticeForm:OnFirstShow()
    local _trans = self.Trans
    self.TitleLabel = UIUtils.FindLabel(_trans, "ScrollPanel/TitleLabel")
    self.ContentLabel = UIUtils.FindLabel(_trans, "ScrollPanel/ScrollView/Label")
    self.CloseBtn = UIUtils.FindBtn(_trans, "CloseBtn")
    self.WaitingUI = UIUtils.FindGo(_trans, "ScrollPanel/Waiting")
    self.WaitingUI:SetActive(false)
    self.EmptyTextGo = UIUtils.FindGo(_trans, "ScrollPanel/EmptyLabel")
    --self.LeftTex = UIUtils.FindTex(_trans, "BGList/LeftTexture")
    --self.RightTex = UIUtils.FindTex(_trans, "BGList/RightTexture")
    self.ScrollView = UIUtils.FindScrollView(_trans, "ScrollPanel/ScrollView")
    self.DefaultTitle = UIUtils.GetText(self.TitleLabel)
    self.BgTex = UIUtils.FindTex(_trans, "BGList/BgTex")

    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
	self.CSForm.UIRegion = UIFormRegion.TopRegion
    self.CSForm:AddNormalAnimation(0.3)
end

-- The interface is enabled and executed
function UILoginNoticeForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj ~= nil then
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN)
        GameCenter.NoticeSystem.CurrentNoticeType = obj
        if not GameCenter.NoticeSystem:ReqNoticeData(obj) then
            self:OnRefresh(nil, nil)
        end
    end

end

-- Refresh announcement
function UILoginNoticeForm:OnRefresh(obj, sender)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE)
    self.NoticeList = GameCenter.NoticeSystem:GetCurrentNotice()
    if self.NoticeList ~= nil then
        self:RefreshNotice(self.NoticeList[1].Title, self.NoticeList[1].Content)
    else 
        self:RefreshNotice()
    end

end

-- Execute before hiding
function UILoginNoticeForm:OnHideBefore()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE)
end

-- Execute before opening the interface
function UILoginNoticeForm:OnShowBefore()
    -- self.CSForm:LoadTexture(self.LeftTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_200"))
    -- self.CSForm:LoadTexture(self.RightTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_200_1"))
    self.CSForm:LoadTexture(self.BgTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_b_gonggao"))
end

-- Refresh the announcement content
function UILoginNoticeForm:RefreshNotice(title,content)
    if title ~= nil then
        UIUtils.SetTextByString(self.TitleLabel , title)
    else
        UIUtils.SetTextByString(self.TitleLabel , self.DefaultTitle)
    end
    
    if content ~= nil then 
        UIUtils.SetTextByString(self.ContentLabel , content)
        self.EmptyTextGo:SetActive(false)
        self.ScrollView.gameObject:SetActive(true)
    else 
        UIUtils.SetTextByString(self.ContentLabel , "")
        self.EmptyTextGo:SetActive(true)
        self.ScrollView.gameObject:SetActive(false)
    end

    self.ScrollView.contentPivot = UIWidgetPivot.Top
    self.ScrollView:ResetPosition()
end

-- Close button execution event
function UILoginNoticeForm:OnCloseBtnClick()
    self:OnClose()
end
return UILoginNoticeForm