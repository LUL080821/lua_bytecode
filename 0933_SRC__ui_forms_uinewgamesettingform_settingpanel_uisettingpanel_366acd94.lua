------------------------------------------------
-- author:
-- Date: 2019-05-07
-- File: UISettingPanel.lua
-- Module: UISettingPanel
-- Description: The game settings panel
------------------------------------------------
local UIToggleGroup = require("UI.Components.UIToggleGroup");
local FLanguage = CS.UnityEngine.Gonbest.MagicCube.FLanguage;
-- Maximum number of characters displayed
local L_CN_MaxPlayerCount = 50;
local L_CN_MinPlayerCount = 5;

local L_CN_MaxScreenScale = 1;
local L_CN_MinScreenScale = 0.95;


-- The panel that defines settings
local UISettingPanel = {
    IsVisibled = false,
    OwnerForm = nil,
    Trans = nil,

    -- Volume adjustment of background music
    MusicProgressBar = nil,    
    -- Volume adjustment of sound effects
    SFXProgressBar = nil,
    -- Display the number of players adjustments
    ShowNumProgressBar = nil,
    -- Screen zoom
    ScreenScaleProcessBar = nil,
    -- Skill level for other players
    OtherSkillLevelProcessBar = nil,

    -- Background music switch
    MusicToggleGroup = nil,
    -- Sound effect switch
    SFXToggleGroup = nil,
    -- Vision switch
    ViewToggleGroup = nil,
    -- Quality switch
    QualityToggleGroup = nil,
    -- Other player skill levels
    SkillLevelTogleGroup = nil,
    -- Flag
    FlagTogleGroup = nil,
    -- Hang-up switch
    OnHookTogleGroup = nil,
    -- Offline time
    OffLineLabel = nil,
    -- Offline hang-up button
    OffLineBtn = nil,
    -- Avatar frame
    HeadFrameIcon = nil,
    -- Account information
    AccountLabel = nil,
    -- Server information
    ServerLabel = nil,
    BottomBtnGrid = nil,
    -- Exit button
    ExitGameBtn = nil,
    -- Back to select button
    ToSelectPlayerBtn = nil,
    -- Announcement Button
    NoticeBtn = nil,
    -- Feedback button
    FeedBackBtn = nil,
    -- Language toggle button
    LanChangeBtn = nil,
    -- Close button
    CloseBtn = nil,    
    -- Maximum offline experience time
    MaxStorageTime = 0,

    -- Number Copy Button
    RoleIDCopyBtn = nil,
    -- Role ID
    RoleIDLabel = nil,
    -- Character avatar
    PlayerHead = nil,

    LiuHaiGo = nil,
    HitGroundGo = nil,

    FlagLabel = nil
};

-- Declare local variables, and handle various switch attributes
local L_MusicToggleProp,L_SFXToggleProp,L_ViewToggleProp,L_QualityToggleProp,L_SkillLevelToggleProp, L_FlagToggleProp, L_OnHookToggleProp;

function UISettingPanel:Initialize(owner,trans)
    self.OwnerForm = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();

    self.MaxStorageTime = tonumber(DataConfig.DataGlobal[GlobalName.OnHookMaxNum].Params) -- //The ones taken out here are minutes
    self.MaxStorageTime  = self.MaxStorageTime * 60 -- //Convert to seconds
    return self;
end


-- Find all components
function UISettingPanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.MusicToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Left/Music"),0,L_MusicToggleProp);
    self.SFXToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Left/SFX"),0,L_SFXToggleProp);
    self.ViewToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Left/View"),1000,L_ViewToggleProp);
    self.QualityToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Left/Quality"),1001,L_QualityToggleProp);
    self.SkillLevelTogleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Left/SkillLevel"),1002,L_SkillLevelToggleProp);
    self.FlagTogleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Right/Flag"),1003,L_FlagToggleProp);
    self.OnHookTogleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"Content/Right/OnHook"),0,L_OnHookToggleProp);    
    self.PlayerHead = PlayerHead:New(UIUtils.FindTrans(_myTrans, "Content/Bottom/PlayerHeadLua"))
    self.OffLineLabel = UIUtils.FindLabel(_myTrans,"Content/Right/OffLine/Text");
    self.OffLineBtn = UIUtils.FindBtn(_myTrans,"Content/Right/OffLine/AddBtn");
    self.BottomBtnGrid = UIUtils.FindGrid(_myTrans,"Content/Bottom/BtnGrid");
    self.ExitGameBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/BtnGrid/ExitGameBtn");
    self.ToSelectPlayerBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/BtnGrid/ToSelectPlayerBtn");
    self.NoticeBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/BtnGrid/NoticeBtn");
    self.FeedBackBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/BtnGrid/FeedBackBtn");
    self.LanChangeBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/BtnGrid/LanChangeBtn");
    self.AccountLabel = UIUtils.FindLabel(_myTrans,"Content/Bottom/Account/Text");
    self.ServerLabel = UIUtils.FindLabel(_myTrans,"Content/Bottom/Server/Text");
    self.FlagLabel = UIUtils.FindLabel(_myTrans,"Content/Right/Flag/Caption");
    self.CloseBtn = UIUtils.FindBtn(_myTrans,"Top/CloseBtn");
    self.MusicProgressBar = UIUtils.FindSlider(_myTrans,"Content/Left/Music/ProgressBar");
    self.SFXProgressBar = UIUtils.FindSlider(_myTrans,"Content/Left/SFX/ProgressBar");
    self.ShowNumProgressBar = UIUtils.FindSlider(_myTrans,"Content/Left/ShowNum/ProgressBar");
    self.ScreenScaleProcessBar = UIUtils.FindSlider(_myTrans,"Content/Left/ScreenScale/ProgressBar");
    self.ScreenScaleProcessBar = UIUtils.FindSlider(_myTrans,"Content/Left/ScreenScale/ProgressBar");

    -- Role ID processing
    self.RoleIDLabel = UIUtils.FindLabel(_myTrans,"Content/Bottom/RoleID/Text");
    self.RoleIDCopyBtn = UIUtils.FindBtn(_myTrans,"Content/Bottom/RoleID/Copy");

    self.LiuHaiGo = UIUtils.FindGo(_myTrans,"Content/Right/OnHook/Item_10");
    self.HitGroundGo = UIUtils.FindGo(_myTrans,"Content/Right/OnHook/Item_12");

    -- The account switch button does not display in PC mode
    self.ExitGameBtn.gameObject:SetActive(not UnityUtils.IsUseUsePCMOdel())
end

-- Callback function that binds UI components
function UISettingPanel:RegUICallback()
   UIUtils.AddBtnEvent(self.OffLineBtn,self.OnClickOffLineBtn,self);
   UIUtils.AddBtnEvent(self.ExitGameBtn,self.OnClickExitGameBtn,self);
   UIUtils.AddBtnEvent(self.ToSelectPlayerBtn,self.OnClickToSelectPlayerBtn,self);
   UIUtils.AddBtnEvent(self.NoticeBtn,self.OnClickNoticeBtn,self);
   UIUtils.AddBtnEvent(self.FeedBackBtn,self.OnClickFeedBackBtn,self);
   UIUtils.AddBtnEvent(self.LanChangeBtn,self.OnClickLanChangeBtn,self);
   UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickCloseBtn,self);

   UIUtils.AddBtnEvent(self.RoleIDCopyBtn,self.OnClickRoleIDCopyBtn,self);

   UIUtils.AddOnChangeEvent(self.MusicProgressBar,self.OnMusicProgressBarChanged,self);
   UIUtils.AddOnChangeEvent(self.SFXProgressBar,self.OnSFXProgressBarChanged,self);
   UIUtils.AddOnChangeEvent(self.ShowNumProgressBar,self.OnShowNumProgressBarChanged,self);
   UIUtils.AddOnChangeEvent(self.ScreenScaleProcessBar,self.OnScreenScaleProgressBarChanged,self);
   --self.QualityToggleGroup.RelateToggleGroups = {self.ViewToggleGroup};
end

function UISettingPanel:Show()
    self.IsVisibled = true;    
    self.Trans.gameObject:SetActive(true);
    self:Refresh();
end

function UISettingPanel:Hide()
    self.IsVisibled = false;
    self.Trans.gameObject:SetActive(false);
end

function UISettingPanel:Refresh()


    self.MusicToggleGroup:Refresh();
    self.SFXToggleGroup:Refresh();
    self.ViewToggleGroup:Refresh();
    self.QualityToggleGroup:Refresh();
    self.SkillLevelTogleGroup:Refresh();
    self.FlagTogleGroup:Refresh();
    self.OnHookTogleGroup:Refresh();
    self.LiuHaiGo:SetActive(not UnityUtils.IsUseUsePCMOdel())
    self.HitGroundGo:SetActive(UnityUtils.IsUseUsePCMOdel())
    
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if lp ~= nil then
        UIUtils.SetTextByString(self.AccountLabel, lp.Name)
        UIUtils.SetTextByString(self.FlagLabel, GosuSDK.GetLangString("FLAG_TEXT"))
        UIUtils.SetTextByString(self.RoleIDLabel, Utils.ToString(lp.ID, 36))
    else
        UIUtils.SetTextByEnum(self.AccountLabel, "Unknow_Reson")
        UIUtils.SetTextByEnum(self.RoleIDLabel, "Unknow_Reson")
    end
    local si = GameCenter.ServerListSystem.LastEnterServer;
    if si ~= nil then
        UIUtils.SetTextByString(self.ServerLabel, si.Name)
    else
        UIUtils.SetTextByEnum(self.ServerLabel, "Unknow_Reson")
    end
    -- Number of displayers
    local _count = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MaxShowPlayerCount);      
    self.ShowNumProgressBar.value = _count/L_CN_MaxPlayerCount;
    local _scale = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.CurvedScreenScreenScale) / 100;
    local _scaleParam = (_scale - L_CN_MinScreenScale) / (L_CN_MaxScreenScale-L_CN_MinScreenScale)
    self.ScreenScaleProcessBar.value = _scaleParam
    -- Background music
    local _mv = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.BGMusicVolume);
    self.MusicProgressBar.value = math.min(1,math.max(0,_mv/100));
    -- Other sound effects
    _mv = GameCenter.GameSetting:GetSetting(GameSettingKeyCode.SoundVolume);
    self.SFXProgressBar.value = math.min(1,math.max(0,_mv/100));
    self:RefreshOffLineTime()

    local _lansCount = FLanguage.EnabledSelectLans().Count
    self.LanChangeBtn.gameObject:SetActive(_lansCount > 1)
    self.BottomBtnGrid.repositionNow = true

    -- Set up player avatar
    self.PlayerHead:SetLocalPlayer()
end

-- Refresh offline hang-up time
function UISettingPanel:RefreshOffLineTime()
    -- Set the remaining time to hang offline
    if (GameCenter.OfflineOnHookSystem.RemainOnHookTime > 0) then    
        local h, m = GameCenter.OfflineOnHookSystem:GetHourAndMinuteBySecond(GameCenter.OfflineOnHookSystem.RemainOnHookTime)
        UIUtils.SetTextByEnum(self.OffLineLabel, "HOOK_HOURMINUTE", h, m)       
    else    
        UIUtils.SetTextByEnum(self.OffLineLabel, "HOOK_HOURMINUTE", 0, 0) 
    end
end

-- Click the offline time button
function UISettingPanel:OnClickOffLineBtn()
    -- Use the additional offline hang-up time prop
    local addHookTimeItemIDs = GameCenter.OfflineOnHookSystem.AddOnHookTimeItemID
    local _haveItem = false
    for i = 1, #addHookTimeItemIDs do
        local ownNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(addHookTimeItemIDs[i])
        local _itemCfg = DataConfig.DataItem[addHookTimeItemIDs[i]]
        if _itemCfg == nil then
            return
        end
        if ownNum > 0 then
            local itemList = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, addHookTimeItemIDs[i])
            -- Increase offline hang-up time props to use in batches. If offline hang-up is exceeded, you need to give a prompt
            local remainTime = GameCenter.OfflineOnHookSystem.RemainOnHookTime    -- //Unit: seconds
            if remainTime >= self.MaxStorageTime then
                Utils.ShowPromptByEnum("C_LIXIANSHIJIAN_FULL")
            else
                local arr = Utils.SplitStr(_itemCfg.EffectNum, "_")
                local oneItemAddTime = tonumber(arr[2]) -- //The unit assigned to the item here is also seconds
                if (remainTime + oneItemAddTime) > self.MaxStorageTime then
                    Utils.ShowMsgBoxAndBtn(function(x)
                        if( x == MsgBoxResultCode.Button2 ) then
                            -- //Sure
                            GameCenter.Network.Send("MSG_backpack.ReqUseItem", {itemId = itemList[0].DBID, num = 1})
                        end
                    end, "C_MSGBOX_CANEL", "C_MSGBOX_AGREE", "C_OFFLINETIEMMAX_TIPS")
                else
                    GameCenter.Network.Send("MSG_backpack.ReqUseItem", {itemId = itemList[0].DBID, num = 1})
                    GameCenter.NumberInputSystem:CloseInput()
                end
            end
            _haveItem = true
            break
        end
    end

    if not _haveItem then
        local _showItemCfg = DataConfig.DataItem[addHookTimeItemIDs[2]]
        -- You don't have "..itemName
        Utils.ShowPromptByEnum("HOOK_NOITEM0", _showItemCfg.Name)
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(addHookTimeItemIDs[2])
    end
end

-- Click the button to switch to login
function UISettingPanel:OnClickExitGameBtn()
    -- Maximum activity every day
    local _maxActivePoint = GameCenter.DailyActivitySystem.MaxActive
    -- Current activity level
    local _active = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
    -- Today's acquisition is not yet complete
    if _active < _maxActivePoint or _active > 0 then
        if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.ExitRewardTips) then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ExitRewardTips, 0)
        else
            GameCenter.LoginSystem:SwitchAccount();
        end
    else
        GameCenter.LoginSystem:SwitchAccount();
    end
end

-- Click the button to switch to select person
function UISettingPanel:OnClickToSelectPlayerBtn()
    -- Maximum activity every day
    local _maxActivePoint = GameCenter.DailyActivitySystem.MaxActive
    -- Current activity level
    local _active = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
    -- Today's acquisition is not yet complete
    if _active < _maxActivePoint or _active > 0 then
        if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.ExitRewardTips) then
            GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ExitRewardTips, 1)
        else
            GameCenter.GameSceneSystem:ReturnToLogin(false,true);
        end
    else
        GameCenter.GameSceneSystem:ReturnToLogin(false,true);
    end
end

-- Click the Announcement Button
function UISettingPanel:OnClickNoticeBtn()
    GameCenter.PushFixEvent(UIEventDefine.UI_LOGIN_NOTICE_OPEN, LoginNoticeType.Login)
end
-- Click the feedback button
function UISettingPanel:OnClickFeedBackBtn()
    self.OwnerForm:ShowFeedBackPanel();
end

-- Switch language
function UISettingPanel:OnClickLanChangeBtn()
    self.OwnerForm.LanguagePanel:Show()
end

-- Click the Close button
function UISettingPanel:OnClickCloseBtn()
    self.OwnerForm:OnClose();
end

function UISettingPanel:OnClickRoleIDCopyBtn()
    -- Copy the content to the paste board
    UnityUtils.CopyToClipboard(UIUtils.GetText(self.RoleIDLabel))
    --CS.UnityEngine.GUIUtility.systemCopyBuffer = UIUtils.GetText(self.RoleIDLabel);
    Debug.Log("Copy:::" .. UIUtils.GetText(self.RoleIDLabel));
end
-- Background music
function UISettingPanel:OnMusicProgressBarChanged()
    local _v = math.floor( self.MusicProgressBar.value * 100+0.5);
    GameCenter.GameSetting:SetSetting(GameSettingKeyCode.BGMusicVolume, _v, false);
end

-- Sound effects
function UISettingPanel:OnSFXProgressBarChanged()
    local _v = math.floor( self.SFXProgressBar.value * 100 + 0.5);
    GameCenter.GameSetting:SetSetting(GameSettingKeyCode.SoundVolume, _v, false);
end

-- Number of players
function UISettingPanel:OnShowNumProgressBarChanged()
    local _count = math.floor(L_CN_MaxPlayerCount * self.ShowNumProgressBar.value+0.5);
    if (_count < L_CN_MinPlayerCount) then
        _count = L_CN_MinPlayerCount;
    end        
    GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MaxShowPlayerCount, _count, false);
end

-- Screen zoom
function UISettingPanel:OnScreenScaleProgressBarChanged()
    local _value = math.Lerp(L_CN_MinScreenScale, L_CN_MaxScreenScale, self.ScreenScaleProcessBar.value) 
    local _scale = math.floor(_value * 100);
    GameCenter.GameSetting:SetSetting(GameSettingKeyCode.CurvedScreenScreenScale, _scale, false);
end

-- ==Internal variables and function definitions==--
-- Properties of background music switch
L_MusicToggleProp = {    
    [1] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.EnableBGMusic) > 0;
        end,
        Set = function(checked)
            GameCenter.GameSetting:SetSetting(GameSettingKeyCode.EnableBGMusic, checked and 1 or 0, false);
        end
    }
};
-- Sound effect switch
L_SFXToggleProp = {    
    [1] = {
        Get = function()
           return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.EnableSound) > 0;
        end,
        Set = function(checked)
            GameCenter.GameSetting:SetSetting(GameSettingKeyCode.EnableSound, checked and 1 or 0, false);
        end
    }
};

-- Vision switch
L_ViewToggleProp = {    
    -- Far-view
    [1] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.EnableFarView) == 1;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.EnableFarView, 1, false);
            end
        end
    },
    -- Myopia
    [2] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.EnableFarView) == 0;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.EnableFarView, 0, false);
            end
        end
    }
};

-- Selecting the quality switch
L_QualityToggleProp = {    
    -- Low quality
    [1] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.QualityLevel) == 2;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.QualityLevel, 2 , false);
            end
        end
    },
    -- Medium quality
    [2] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.QualityLevel) == 1;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.QualityLevel, 1, false);
            end
        end
    },
    -- High quality
    [3] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.QualityLevel) == 0;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.QualityLevel, 0, false);
            end
        end
    }
};

-- Skill level for other players
L_SkillLevelToggleProp = {    
    -- none
    [1] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel) == 0;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel, 0, false);
            end
        end
    },
    -- weak
    [2] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel) == 1;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel, 1, false);
            end
        end
    },
    -- middle
    [3] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel) == 2;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel, 2, false);
            end
        end
    },
    -- powerful
    [4] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel) == 3;
        end,
        Set = function(checked)
            if checked then
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.OtherPlayerSkillVfxLevel, 3, false);
            end
        end
    }
};

-- Hang up settings
L_OnHookToggleProp = {    
    -- Automatic counterattack
    [1] = {
         Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateAutoStrikeBack) > 0;
         end,
         Set = function(checked)
            GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MandateAutoStrikeBack, checked and 1 or 0, false);
         end
    },
    -- Automatic resurrection
    [2] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateReborn) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MandateReborn, checked and 1 or 0, false);
         end
    },
    -- Special effects
    [3] = {
         Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.HitVfx) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.HitVfx, checked and 1 or 0, false);
         end
    },
    -- Skill vibration
    [4] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.EnableShakeEffect) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.EnableShakeEffect, checked and 1 or 0, false);
         end
    },
    -- Block players
    [5] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.ShowOtherPlayer) <= 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.ShowOtherPlayer, checked and 0 or 1, false);
         end
    },
    -- Block monsters
    [6] = {
         Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.ShowMonster) <= 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.ShowMonster, checked and 0 or 1, false);
         end
    },
    -- Automatically use sword spirit awakening while hanging up
    [7] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateUseXPSkill) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MandateUseXPSkill, checked and 1 or 0, false);
         end
    },
    -- Automatically confirm entry to the team
    [8] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateAutoJoinTeam) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MandateAutoJoinTeam, checked and 1 or 0, false);
         end
    },
    -- Automatically make up for hang-up time
    [9] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.MandateAutoAddTime) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.MandateAutoAddTime, checked and 1 or 0, false);
         end
    },
    -- Adaptable equipment bangs
    [10] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.NotchShow) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.NotchShow, checked and 1 or 0, false);
         end
    },
    -- Automatically participate in activities
    [11] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.AutoJoinActive) > 0;
         end,
         Set = function(checked)
             GameCenter.GameSetting:SetSetting(GameSettingKeyCode.AutoJoinActive, checked and 1 or 0, false);
         end
    },
    -- Click on the ground to move
    [12] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(GameSettingKeyCode.CheckGroundMove) > 0;
            end,
            Set = function(checked)
                GameCenter.GameSetting:SetSetting(GameSettingKeyCode.CheckGroundMove, checked and 1 or 0, false);
            end
    }
};


-- for FlagSettings
local qualityOptionIDs = {4401, 4402, 4403, 4404, 4405, 4406, 4407, 4408, 4409, 4410}
L_FlagToggleProp = {}
for i, id in ipairs(qualityOptionIDs) do
    local realID = id
    L_FlagToggleProp[i] = {
        Get = function()
            return GameCenter.GameSetting:GetSetting(realID) == 1;
        end,
        Set = function(checked)
            if checked and 1 then
                GameCenter.GameSetting:SendSettingToServer(realID, 1);
                GameCenter.PushFixEvent(GosuSDK.Events.EID_GOSU_CORE_SET_FLAG, tostring(realID)) -- call C# update cờ
            else
                GameCenter.GameSetting:SendSettingToServer(realID, 0);
                local flagIdActive = GameCenter.GameSetting:GetFlagActive()
                if flagIdActive == realID then
                    GameCenter.PushFixEvent(GosuSDK.Events.EID_GOSU_CORE_SET_FLAG, "0") -- call C# update cờ
                end
            end
        end
    }
end
-- for FlagSettings

return UISettingPanel;
