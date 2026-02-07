------------------------------------------------
--author:
--Date: 2019-05-13
--File: UIFeedBackMainPanel.lua
--Module: UIFeedBackMainPanel
--Description: The panel of player feedback
------------------------------------------------
local UIFeedBackInputPanel = require("UI.Forms.UINewGameSettingForm.FeedBackPanel.UIFeedBackInputPanel");
local UIFeedBackListPanel = require("UI.Forms.UINewGameSettingForm.FeedBackPanel.UIFeedBackListPanel");

--Define feedback panel
local UIFeedBackMainPanel = {
    -- Whether to display
    IsVisibled = false,
    --The form
    OwnerForm = nil,
    --Own Transform
    Trans = nil,
    --Submit feedback
    DoFeedBackBtn = nil,
    --Open feedback information
    FeedBackListBtn = nil,
    --Upload log button
    UploadLogBtn = nil,

     --Submit feedback button text
     DoFeedBackBtnLabel = nil,
     --Open the text of the feedback message button
     FeedBackListBtnLabel = nil,    
 

    --Submit feedback panel
    DoFeedBackPanel = nil,
    --Display feedback information panel
    FeedBackListPanel = nil,
      --Close button
      CloseBtn = nil,
};

function UIFeedBackMainPanel:Initialize(owner,trans)
    self.OwnerForm = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();
    return self;
end

function UIFeedBackMainPanel:Show()
    self.IsVisibled = true;    
    self.Trans.gameObject:SetActive(true);
    self:Refresh();
end

function UIFeedBackMainPanel:Hide()
    self.IsVisibled = false;
    self.Trans.gameObject:SetActive(false);
end


--Find all components
function UIFeedBackMainPanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.DoFeedBackBtn =  UIUtils.FindBtn(_myTrans,"Content/Top/DoFeedBackBtn");    
    self.DoFeedBackBtnLabel = UIUtils.FindLabel(_myTrans,"Content/Top/DoFeedBackBtn/Text");
    self.FeedBackListBtn =  UIUtils.FindBtn(_myTrans,"Content/Top/FeedBackListBtn");
    self.FeedBackListBtn.gameObject:SetActive(false);
    self.FeedBackListBtnLabel = UIUtils.FindLabel(_myTrans,"Content/Top/FeedBackListBtn/Text");
    self.UploadLogBtn =  UIUtils.FindBtn(_myTrans,"Content/Top/UploadLogBtn");    

    local _tmpTrans =  UIUtils.FindTrans(_myTrans,"Content/Content/DoFeedBackPanel");
    self.DoFeedBackPanel = UIFeedBackInputPanel:Initialize(self,_tmpTrans);

    _tmpTrans =  UIUtils.FindTrans(_myTrans,"Content/Content/FeedBackListPanel");
    self.FeedBackListPanel = UIFeedBackListPanel:Initialize(self,_tmpTrans);
    self.CloseBtn = UIUtils.FindBtn(_myTrans,"Top/CloseBtn");

    --Taiwan
    -- local _hasTW = FLanguage.EnabledSelectLans():ContainsKey(FLanguage.TW);
    -- if _hasTW then
        self.UploadLogBtn.gameObject:SetActive(false);
    -- else
    --     self.UploadLogBtn.gameObject:SetActive(true);
    -- end
end

--Binding UI components callback function
function UIFeedBackMainPanel:RegUICallback()
   UIUtils.AddBtnEvent(self.DoFeedBackBtn,self.OnClickDoFeedBackBtn,self);
   UIUtils.AddBtnEvent(self.FeedBackListBtn,self.OnClickFeedBackListBtn,self);
   UIUtils.AddBtnEvent(self.UploadLogBtn,self.OnClickUploadLogBtn,self);
   UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickCloseBtn,self);
end

function UIFeedBackMainPanel:Refresh()
    self:ShowInputPanel();    
end

function UIFeedBackMainPanel:RefreshListPanel()
   if self.FeedBackListPanel.IsVisibled then 
        self.FeedBackListPanel:Refresh(true);
   end
end

function ChangeButtonSprite(btn,name)
    btn.hoverSprite = name;
    btn.pressedSprite = name;
    btn.disabledSprite = name;
    btn.normalSprite = name;
end

function UIFeedBackMainPanel:ShowInputPanel()   
    ChangeButtonSprite(self.DoFeedBackBtn,"n_a_16");    
    ChangeButtonSprite(self.FeedBackListBtn,"n_a_14");
    UIUtils.SetColor(self.DoFeedBackBtnLabel, 1, 0.996,0.961, 1);
    UIUtils.SetColor(self.FeedBackListBtnLabel, 1, 0.996,0.961, 1);
    self.DoFeedBackPanel:Show();
    self.FeedBackListPanel:Hide();
end

function UIFeedBackMainPanel:ShowListPanel()
    ChangeButtonSprite(self.DoFeedBackBtn,"n_a_14");
    ChangeButtonSprite(self.FeedBackListBtn,"n_a_16");
    UIUtils.SetColor(self.DoFeedBackBtnLabel,  1, 0.996,0.961, 1);
    UIUtils.SetColor(self.FeedBackListBtnLabel, 1, 0.996,0.961, 1);
    self.DoFeedBackPanel:Hide();
    self.FeedBackListPanel:Show();
end


function UIFeedBackMainPanel:OnClickDoFeedBackBtn()
    self:ShowInputPanel();
end

function UIFeedBackMainPanel:OnClickFeedBackListBtn()
    self:ShowListPanel();
end

function UIFeedBackMainPanel:OnClickUploadLogBtn() 
    local pid = tostring(GameCenter.GameSceneSystem:GetLocalPlayerID());     
    GameCenter.PushFixEvent(UILuaEventDefine.UILogUploadForm_OPEN, pid);
end

function UIFeedBackMainPanel:OnClickCloseBtn()
   -- self.OwnerForm:ShowSettingPanel();
   self.OwnerForm:OnClose();
end
return UIFeedBackMainPanel;