
local UIChangeLanguagePanel = {
    Form = nil,
    Trans = nil,
};

--Platform initialization
function UIChangeLanguagePanel:Initialize(owner,trans)
    self.Form = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();
    return self;
end

--Panboard display
function UIChangeLanguagePanel:Show()
    self.Trans.gameObject:SetActive(true);    
    UIChangeLanguagePanel:Refresh(); 
end

--Panboard hidden
function UIChangeLanguagePanel:Hide()
    self.Trans.gameObject:SetActive(false);
end

--Find all lists
function UIChangeLanguagePanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.englishBtn = UIUtils.FindBtn(_myTrans,"Panel/englishBtn");
    self.vietnameseBtn = UIUtils.FindBtn(_myTrans,"Panel/vietnameseBtn");
    self.khomeBtn = UIUtils.FindBtn(_myTrans,"Panel/khomeBtn");
    self.englishLabel = UIUtils.FindLabel(_myTrans,"Panel/englishBtn/Label");
    self.vietnameseLabel = UIUtils.FindLabel(_myTrans,"Panel/vietnameseBtn/Label");
    self.khomeLabel = UIUtils.FindLabel(_myTrans,"Panel/khomeBtn/Label");
    self:RegUICallback();
end

function UIChangeLanguagePanel:RegUICallback()  
    UIUtils.AddBtnEvent(self.englishBtn,self.OnEnglishBtnClick,self);
    UIUtils.AddBtnEvent(self.vietnameseBtn,self.OnVietnameseBtnClick,self);
    UIUtils.AddBtnEvent(self.khomeBtn,self.OnKhomeBtnClick,self);
end


function UIChangeLanguagePanel:Refresh()
    UIUtils.SetTextByString(self.englishLabel, GosuSDK.UILangConst.BTN_LANG_EN)
    UIUtils.SetTextByString(self.vietnameseLabel, GosuSDK.UILangConst.BTN_LANG_VI)
    UIUtils.SetTextByString(self.khomeLabel, GosuSDK.UILangConst.BTN_LANG_KH)
end

function UIChangeLanguagePanel:OnEnglishBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
    self.Form.ClearCacheScript:DoChangeLang("EN");
    -- bắn sự kiện để cập nhật lại tex
    GosuSDK.GoSuDispatchEvent("UpdateLangConst", "EN") 
end
function UIChangeLanguagePanel:OnVietnameseBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
    self.Form.ClearCacheScript:DoChangeLang("JP");
    GosuSDK.GoSuDispatchEvent("UpdateLangConst", "JP") 
end
function UIChangeLanguagePanel:OnKhomeBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UILOGINFORM_CLOSE)
    self.Form.ClearCacheScript:DoChangeLang("VIE");
    GosuSDK.GoSuDispatchEvent("UpdateLangConst", "VIE") 
end
return UIChangeLanguagePanel;
