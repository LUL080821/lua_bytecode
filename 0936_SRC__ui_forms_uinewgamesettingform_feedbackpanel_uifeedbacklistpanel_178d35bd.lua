------------------------------------------------
-- author:
-- Date: 2019-05-13
-- File: UIFeedBackListPanel.lua
-- Module: UIFeedBackListPanel
-- Description: The interface that displays feedback information
------------------------------------------------
local UIToggleGroup = require("UI.Components.UIToggleGroup");
local UICompContainer = require("UI.Components.UICompContainer");
local UIFeedBackItem = require("UI.Forms.UINewGameSettingForm.FeedBackPanel.UIFeedBackItem");

-- Define feedback panel
local UIFeedBackListPanel = {
    -- Whether to display
    IsVisibled = false,
    -- Main panel
    MainPanel = nil,
    -- Transform
    Trans = nil,
    -- Select the type of feedback
    StateToggleGroup = nil,

    -- Feedback container
    FeedBackContainer = nil,
    -- Sort Table
    UITable = nil,

    -- Scrolling view
    UIScrollView = nil,

    -- Check what status feedback
    State = 0,

    -- Scroll to the end
    IsScrollLast = false;
};
-- Status switch group
local L_StateToggleProp = nil;

function UIFeedBackListPanel:Initialize(owner,trans)
    self.MainPanel = owner;
    self.Trans = trans;
    self:FindAllComponents();    
    return self;
end

function UIFeedBackListPanel:Show()
    self.IsVisibled = true;    
    self.Trans.gameObject:SetActive(true);    
    self.State = 0;
    self:Refresh(false);
    self.StateToggleGroup:Refresh();
end

function UIFeedBackListPanel:Hide()
    self.IsVisibled = false;
    self.Trans.gameObject:SetActive(false);
end


-- Find all components
function UIFeedBackListPanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.StateToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"State"),2004,L_StateToggleProp);    
    self.UIScrollView = UIUtils.FindScrollView(_myTrans,"Content/ListPanel");
    --self.UIButton = UIUtils.FindBtn(_myTrans,"Content/Bg");
    local _tblTrans = UIUtils.FindTrans(_myTrans,"Content/ListPanel/Table");
    self.UITable = UIUtils.FindTable(_tblTrans)
    local _c = UICompContainer:New();
    for i = 0, _tblTrans.childCount - 1 do
        _c:AddNewComponent(UIFeedBackItem:New(self, _tblTrans:GetChild(i)));
    end
    _c:SetTemplate();
    self.FeedBackContainer = _c;
    self.UITable.onReposition = Utils.Handler(self.OnRepositionChanged,self);
    --UIUtils.AddBtnEvent(self.UIButton,self.OnUIButtonClick,self);
end

function UIFeedBackListPanel:OnRepositionChanged()
    if self.IsScrollLast then
        self.UIScrollView:ResetPosition();
        local _by = self.UIScrollView.bounds.size.y;
        local _py = self.UIScrollView.panel.baseClipRegion.w;
        local _y = _by -_py;
        _y = _y > 0 and _y or 0;
        self.UIScrollView:MoveRelative(Vector3(0,_y,0));
        self.IsScrollLast = false;
    end
end

-- Refresh the interface
function UIFeedBackListPanel:Refresh(scrollLast)    
    self.IsScrollLast = scrollLast;
    local _dataList = GameCenter.FeedBackSystem:GetFeedBackByType(self.State);
    self.FeedBackContainer:EnQueueAll();    
    local _id = 1;
    for _,v in ipairs(_dataList) do
        local _item =  self.FeedBackContainer:DeQueue(v);
        _item:SetName(string.format("item_%02d",_id));
        _id = _id + 1;
    end
    self.FeedBackContainer:RefreshAllUIData();
    self.UITable.repositionWaitFrameCount = 3;
    self.UITable.repositionNow = true;
    self.UIScrollView:ResetPosition();
end

-- Set feedback type
function UIFeedBackListPanel:SetState(val)
    if self.State ~= val then
        self.State = val;
        self:Refresh(false);
    end
end

-- ==Internal variables and function definitions==--
-- Properties of status switch
L_StateToggleProp = {    
    [1] = {
        Get = function()
            return UIFeedBackListPanel.State == 0;
        end,
        Set = function(checked)
            if checked then UIFeedBackListPanel:SetState(0); end            
        end
    },
    [2] = {
        Get = function()
            return UIFeedBackListPanel.State == 1;
        end,
        Set = function(checked)
            if checked then UIFeedBackListPanel:SetState(1); end
        end
    },
    [3] = {
        Get = function()
            return UIFeedBackListPanel.State == 2;
        end,
        Set = function(checked)
            if checked then UIFeedBackListPanel:SetState(2); end
        end
    },
    [4] = {
        Get = function()
            return UIFeedBackListPanel.State == 3;
        end,
        Set = function(checked)
            if checked then UIFeedBackListPanel:SetState(3); end
        end
    },
    [5] = {
        Get = function()
            return UIFeedBackListPanel.State == 4;
        end,
        Set = function(checked)
            if checked then UIFeedBackListPanel:SetState(4); end
        end
    }
};


return UIFeedBackListPanel;