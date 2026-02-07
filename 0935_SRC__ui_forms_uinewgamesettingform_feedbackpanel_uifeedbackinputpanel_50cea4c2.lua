------------------------------------------------
--author:
--Date: 2019-05-13
--File: UIFeedBackInputPanel.lua
--Module: UIFeedBackInputPanel
--Description: The interface to fill in the feedback and submit
------------------------------------------------

local UIToggleGroup = require("UI.Components.UIToggleGroup");

--Define feedback panel
local UIFeedBackInputPanel = {
   -- Whether to display
   IsVisibled = false,
   --Main panel
   MainPanel = nil,
   --Own Transform
   Trans = nil,

   --Select the type of feedback
   StateToggleGroup = nil,

   --Submit Button
   PostBtn = nil,

   --Input area
   Input = nil,

   --Current status
   State = 0,
};

--Status switch group
local L_StateToggleProp = nil;

function UIFeedBackInputPanel:Initialize(owner,trans)
    self.MainPanel = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();
    return self;
end

function UIFeedBackInputPanel:Show()
    self.IsVisibled = true;    
    self.Trans.gameObject:SetActive(true);
    self:Refresh();
end

function UIFeedBackInputPanel:Hide()
    self.IsVisibled = false;
    self.Trans.gameObject:SetActive(false);
end


--Find all components
function UIFeedBackInputPanel:FindAllComponents()
    local _myTrans = self.Trans;    
    self.StateToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"State"),2002,L_StateToggleProp);
    self.PostBtn = UIUtils.FindBtn(_myTrans,"PostBtn");
    self.Input = UIUtils.FindInput(_myTrans,"Content/Panel/Input");	
end

--Binding UI components callback function
function UIFeedBackInputPanel:RegUICallback()
   UIUtils.AddBtnEvent(self.PostBtn,self.PostFeedBack,self);
end

function UIFeedBackInputPanel:Refresh()
   self.State = 1;
   self.StateToggleGroup:Refresh();
end

function UIFeedBackInputPanel:PostFeedBack()
    local _s = Time.GetNowSeconds() - GameCenter.FeedBackSystem:GetLastPostDateTime();
    --Wait 10 minutes
    if _s < 600 then
        Debug.Log("Time between the last submission feedback:".. tostring(_s).."< 600");
        Utils.ShowPromptByEnum("PleaseWaitAMoment")
    else
        local _c = self.Input.value;          
        if _c then
            Debug.Log("Submit feedback".. tostring(self.State) .. _c);

            -- CUSTOM - bỏ qua check ký tự chuyển qua check từ
            -- local cnt = Utils.UTF8Len( _c );
            local _,countWord = string.gsub(_c, "%S+", "")
            -- CUSTOM - bỏ qua check ký tự chuyển qua check từ

            if countWord >= 3 and countWord <= 300 then
                -- if not CS.Thousandto.Code.Logic.WordFilter.IsContainsSensitiveWord(_c) then
                    GameCenter.FeedBackSystem:PostFeedBack(self.State,_c);
                    self.Input.value = "";
                    -- Utils.ShowPromptByEnum("") -- thêm thông báo nếu có
                    -- self.MainPanel:ShowListPanel();
                -- else
                --     Utils.ShowPromptByEnum("WrongChar")
                -- end
                
                --[[
                local lp = GameCenter.GameSceneSystem:GetLocalPlayer();
                local req ={};
                req.chattype = 0;
                req.recRoleId = lp.ID;
                req.condition = UIUtils.CSFormat("&feedback %d %d %s",lp.ID,self.State,DataConfig.DataMessageString.Get("YourMachineWrong"));
                req.chatchannel = 8;
                req.voiceLen = 0;
                req.test = 111;
                req.testfun = function() return 0; end
                Debug.Log(req.condition);
                GameCenter.Network.Send("MSG_Chat.ChatReqCS",req);
                ]]--
            else
                Utils.ShowPromptByEnum("ContentLengthIsWrong")
            end
        else
            Utils.ShowPromptByEnum("ContentIsEmpty")
        end
    end
end

function UIFeedBackInputPanel:SetState(val)    
    self.State = val;
end

--==Internal variables and function definitions==-
--Properties of status switch
L_StateToggleProp = {    
    [1] = {
        Get = function()
            return UIFeedBackInputPanel.State == 1;
        end,
        Set = function(checked)
            if checked then UIFeedBackInputPanel:SetState(1); end
        end
    },
    [2] = {
        Get = function()
            return UIFeedBackInputPanel.State == 2;
        end,
        Set = function(checked)
            if checked then UIFeedBackInputPanel:SetState(2); end
        end
    },
    [3] = {
        Get = function()
            return UIFeedBackInputPanel.State == 3;
        end,
        Set = function(checked)
            if checked then UIFeedBackInputPanel:SetState(3); end
        end
    },
    [4] = {
        Get = function()
            return UIFeedBackInputPanel.State == 4;
        end,
        Set = function(checked)
            if checked then UIFeedBackInputPanel:SetState(4); end
        end
    }
};


return UIFeedBackInputPanel;
