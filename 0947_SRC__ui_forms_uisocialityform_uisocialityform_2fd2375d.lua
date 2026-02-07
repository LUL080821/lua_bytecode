------------------------------------------------
--author:
--Date: 2019-04-23
--File: UISocialityForm.lua
--Module: UISocialityForm
--Description: Social Blockchain
------------------------------------------------
local UIListMenu = require "UI.Components.UIListMenu.UIListMenuRight"

local UISocialityForm = {
   CloseBtn = nil,
   BackGroundTex = nil,
   ListMenu = nil,
   TitleName = nil,
   OpenPageType = SocialityFormSubPanel.Friend,
}

function  UISocialityForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UISocialityForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UISocialityForm_CLOSE,self.OnClose)
end

function UISocialityForm:OnFirstShow()
    self:FindAllComponents()
    self:OnRegUICallBack()
end

function UISocialityForm:FindAllComponents()
    local _trans = self.CSForm.transform;
    self.CSForm:AddNormalAnimation()
    self.CloseBtn = UIUtils.FindBtn(_trans, "Right/closeButton");
    self.TitleName = UIUtils.FindLabel(_trans, "Top/FormName/Label");
    self.BackGroundTex = UIUtils.FindTex(_trans, "Center/BG/TexBg");

    local _listTrans = UIUtils.FindTrans(_trans, "Right/UIListMenu");
    self.ListMenu = UIListMenu:OnFirstShow(self.CSForm, _listTrans);
    self.ListMenu:AddIcon(SocialityFormSubPanel.Friend, DataConfig.DataMessageString.Get("SOCIAL_FRIEND"), FunctionStartIdCode.Friend);
    self.ListMenu:AddIcon(SocialityFormSubPanel.Mail, DataConfig.DataMessageString.Get("C_UI_SOCIALITY_MAIL"), FunctionStartIdCode.Mail);

    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_trans, "UIMoneyForm"));
end

function UISocialityForm:OnRegUICallBack()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCLose, self)
    self.ListMenu:ClearSelectEvent()
    self.ListMenu:AddSelectEvent(Utils.Handler(self.OnSelectCallBack, self))
end


function UISocialityForm:OnShowAfter()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
end

function UISocialityForm:OnHideBefore()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
end

function UISocialityForm:OnSelectCallBack(id, selected)
    if selected then
        if id == SocialityFormSubPanel.Friend then
            UIUtils.SetTextByEnum(self.TitleName, "SOCIAL_FRIEND")
            if self.IsOpenAddFriend then
                GameCenter.PushFixEvent(UIEventDefine.UIFriendForm_OPEN, FunctionStartIdCode.AddFriend, self.CSForm)
                self.IsOpenAddFriend = false;
            else
                if self:CheckIsVisible(FunctionStartIdCode.Friend) then
                    GameCenter.PushFixEvent(UIEventDefine.UIFriendForm_OPEN, self.OpenPageType, self.CSForm)
                end
            end
        elseif id == SocialityFormSubPanel.Mail then
            UIUtils.SetTextByEnum(self.TitleName, "C_UI_SOCIALITY_MAIL")
            GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
            if self:CheckIsVisible(FunctionStartIdCode.Mail) then
                GameCenter.PushFixEvent(UIEventDefine.UIMailForm_OPEN, nil, self.CSForm)
            end
        end
    else
        if id == SocialityFormSubPanel.Friend then
            GameCenter.PushFixEvent(UIEventDefine.UIFriendForm_CLOSE)
        elseif id == SocialityFormSubPanel.Mail then
            GameCenter.PushFixEvent(UIEventDefine.UIMailForm_CLOSE)
        end
    end
end

function UISocialityForm:CheckIsVisible(code)
    local _funcData = GameCenter.MainFunctionSystem:GetFunctionInfo(code);
    if not _funcData then
        return false
    end
    if not _funcData.IsVisible then
        GameCenter.MainFunctionSystem:ShowNotOpenTips(_funcData)
        return false
    end
    return true
end

function UISocialityForm:LoadBgTex()
    self.CSForm:LoadTexture(self.BackGroundTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_1_3"))
end

function UISocialityForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self:LoadBgTex()
    self.OpenPageType = obj
    if obj == FunctionStartIdCode.AddFriend then
        self.IsOpenAddFriend = true;
        self.ListMenu:SetSelectById(SocialityFormSubPanel.Friend)
    elseif obj == SocialityFormSubPanel.RecentFriend then
        self.ListMenu:SetSelectById(SocialityFormSubPanel.RecentFriend)
    else
        self.ListMenu:SetSelectById(obj)
    end
end

function UISocialityForm:OnCLose(obj, sender)
    self.CSForm:Hide()
    GameCenter.PushFixEvent(UIEventDefine.UICHATPRIVATEFORM_CLOSE)
end

return UISocialityForm
