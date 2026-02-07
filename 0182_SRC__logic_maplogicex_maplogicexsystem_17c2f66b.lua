------------------------------------------------
-- Author: 
-- Date: 2019-04-15
-- File: MapLogicExSystem.lua
-- Module: MapLogicExSystem
-- Description: Map Logic Class
------------------------------------------------

local L_WaterParams = require "Logic.TaskSystem.Data.WaterWaveParam"
--local ChatSystem = CS.Thousandto.Code.Center.GameCenter.ChatSystem

-- Constructor
local MapLogicExSystem = {
    MapId = 0,
    MapCfg = nil,                        -- Current scene configuration
    ActiveLogicMoudle = nil,             -- Current copy logical file name
    ActiveLogic = nil,                   -- The logic currently activated
    CacheMsg = List:New(),               -- Cache message
    MainUIState = nil,                   -- Main interface paging status
    LeftUIState = nil,                   -- Left page status
    CopyFormUIState = nil,               -- Copy paging status
}

-- Enter the scene processing
function MapLogicExSystem:OnEnterScene(mapId, isPlane)
    -- Clear map settings when entering the scene
    GameCenter.MapLogicSwitch:Reset()
    GameCenter.GetNewItemSystem.PauseGetNewItemTips = false
    -- Find map configuration
    self.MapId = mapId
    self.MapCfg = DataConfig.DataMapsetting[mapId]
    -- Create a logical script
    self:NewMapLogic()

    self.MainUIState = nil
    self.LeftUIState = nil
    self.CopyFormUIState = nil
    -- Set whether the current map can be supported
    if self.MapCfg and self.MapCfg.IfWorldSupport == 1 then
        self.IsWorldSupport = true
    else
        self.IsWorldSupport = false
    end

    if self.ActiveLogic ~= nil then
        local _closeLoading = true
        if self.ActiveLogic.OnEnterScene ~= nil then
            -- Enter the scene processing
            if self.ActiveLogic:OnEnterScene(self) == false then
                _closeLoading = false
            end
        end
        if self.ActiveLogic.GetMainUIState ~= nil then
            self.MainUIState = self.ActiveLogic:GetMainUIState()
        end
        if self.MainUIState == nil then
            self.MainUIState = self:GetMainUIState()
        end

        if self.ActiveLogic.GetMainLeftUIState ~= nil then
            self.LeftUIState = self.ActiveLogic:GetMainLeftUIState()
        end
        if self.LeftUIState == nil then
            self.LeftUIState = self:GetMainLeftUIState()
        end

        -- Set the main interface switch status
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SUBPANELOPENSTATE)
        -- Set the left-hand teaming and task interface status
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAINLEFTSUBPABNELOPENSTATE)

        if self.CopyFormUIState ~= nil then
            GameCenter.MapLogicSwitch:SetCopyFormUIState(self.CopyFormUIState)
        end

        -- Process cached messages
        if self.ActiveLogic.OnMsgHandle ~= nil then
            for i = 1, self.CacheMsg:Count() do
                self.ActiveLogic:OnMsgHandle(self.CacheMsg[i])
            end
        end
        self.CacheMsg:Clear()

        self:OnSceneCinematicFinish(_closeLoading)
  
        if not isPlane then
            if self.MapCfg.PkState == 0 then
                -- Can't PK
                Utils.ShowPromptByEnum("C_ENTERMAPTIPS_SAFE")
                GameCenter.ChatSystem:AddChat(4, DataConfig.DataMessageString.Get("C_ENTERMAPTIPS_SAFE"))
            else
                -- Can PK
                Utils.ShowPromptByEnum("C_ENTERMAPTIPS_WEIXIAN")
                GameCenter.ChatSystem:AddChat(4, DataConfig.DataMessageString.Get("C_ENTERMAPTIPS_WEIXIAN"))
            end
        end

        -- Set screen water ripples
        local _param = GameCenter.LuaTaskManager:GetWaterWaveParam()
        if _param == nil then
            _param = L_WaterParams:New()
        end
        if _param ~= nil then
            if GameCenter.GameSetting:IsEnabled(GameSettingKeyCode.EnablePostEffect) then
                if _param.DistanceFactor == 0 and _param.TimeFactor == 0 and _param.WaveWidth == 0 and _param.WaveSpeed ==
                    0 then
                    GameCenter.TaskController:ResumeForTransPort()
                    GameCenter.NpcTalkSystem:ResumeAutoTalkNpc()
                else
                    PostEffectManager.Instance:StopWaterWave()
                    PostEffectManager.Instance:PlayWaterWave(_param.distanceFactor, _param.timeFactor,
                        _param.totalFactor, _param.waveWidth, _param.waveSpeed, function()
                            GameCenter.TaskController:ResumeForTransPort()
                            GameCenter.NpcTalkSystem:ResumeAutoTalkNpc()
                        end)
                end
            else
                GameCenter.TaskController:ResumeForTransPort()
                GameCenter.NpcTalkSystem:ResumeAutoTalkNpc()
            end
        end
    end
    -- turn on shadows for every scene
    -- CS.Thousandto.Core.PostEffect.PostEffectManager.Instance:EnablePlayerShadow(true);
    -- CS.Thousandto.Core.PostEffect.PostEffectManager.Instance:EnableSceneShadow(true);
end

-- Leave the scene processing
function MapLogicExSystem:OnLeaveScene(isPlane)
    -- if self.MapCfg ~= nil then
    --     Debug.Log("MapLogicExSystem:OnLeaveScene" .. self.MapCfg.MapId)
    -- end
    -- if self.MapCfg and self.MapCfg.IfNewguildCall == 1 then
    --     GameCenter.PushFixEvent(UIEventDefine.UICallSoulForm_CLOSE)
    -- end
    if not isPlane then
        if GameCenter.MapLogicSwitch.IsCopyMap then
            --copy
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLOSE_ALL_FORM, 
                {"UIPanelCopyFailedForm", "UIHUDForm", "UIMainForm", "UIMainFormPC", "UIGuideForm", "UIReliveForm", "UIMsgPromptForm", "UIMsgMarqueeForm", "UILoadingForm", "UICinematicForm", "UIGetEquipTIps", "UIPowerSaveForm", "UIPropertyChangeForm" })
        else
            --normal
            GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CLOSE_ALL_FORM, 
                {"UIPanelCopyFailedForm", "UIReliveForm", "UIHUDForm", "UIMainForm", "UIMainFormPC", "UIGuideForm", "UICopyTeamAskForm", "UICopyTeamPrepareForm", "UICrossMatchingForm", "UILoadingForm", "UIMsgPromptForm", "UIMsgMarqueeForm", "UICinematicForm", "UICopyMapResultExForm", "UIGetEquipTIps", "UIPowerSaveForm", "UIPropertyChangeForm" })
        end
    end

    -- Switch map to close peak competitive match
    local _msg = ReqMsg.MSG_Peak.ReqCancelPeakMatch:New()
	_msg:Send()

    if self.ActiveLogic ~= nil and self.ActiveLogic.OnLeaveScene ~= nil then
        -- Leave the scene processing
        self.ActiveLogic:OnLeaveScene()
    end
    self.ActiveLogic = nil

    if self.ActiveLogicMoudle ~= nil then
        -- Uninstall the script
        Utils.RemoveRequiredByName(self.ActiveLogicMoudle)
        self.ActiveLogicMoudle = nil
    end

    self.MapId = 0
    self.MapCfg = nil
    self.CacheMsg:Clear()
    self.MainUIState = nil
    self.LeftUIState = nil
    self.CopyFormUIState = nil
    -- Clear the configuration table ID of the system where the BOSS is located immediately to avoid misuse of other systems
    GameCenter.BossInfoTipsSystem.CustomCfgID = 0
    GameCenter.LuaCharacterSystem:OnLeaveScene()
end

-- renew
function MapLogicExSystem:Update(dt)
    if self.ActiveLogic ~= nil and self.ActiveLogic.Update ~= nil then
        self.ActiveLogic:Update(dt)
    end
end

-- Create a map logic processing class
function MapLogicExSystem:NewMapLogic()
    if self.MapCfg.MapLogicType == MapLogicTypeDefine.WanYaoTa then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.WanYaoTa.WanYaoTaLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.DaNengYiFu then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.DaNengYiFu.DaNengYiFuLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XianJieZhiMen then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.XianJieZhiMen.XianJieZhiMenLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.PlaneCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.PlaneCopy.PlaneCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.YZZDCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.YZZDCopy.YZZDMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.SZZQCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.SZZQLogic.SZZQMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.FuDiCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.FuDiCopy.FuDiLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.FuDiDuoBaoCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.FuDiCopy.FuDiDuoBaoLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.MySelfBossCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.MySelfBoss.MySelfBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.WorldBossCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.NewWorldBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.SuitGemCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.SuitGemBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.MarryQingYuanCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.MarryCopy.MarryQingYuanCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.WuXianBossCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.WuXianBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ArenaShouXi then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ArenaShouXi.ArenaShouXiLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.LvDuPanelCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.PlaneCopy.LvDuPlaneCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.SkyDoorCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.SkyDoor.SkyDoorMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ExpCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ExpCopy.ExpCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.WuXingCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ManyCopy.WuXingCopyMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XinMoCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ManyCopy.XinMoCopyMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.GuardianFaction then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.GuardianFaction.GuardianFactionLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.MonsterLand then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.HunShouShenLin.HunShouShenLinLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.RealmExpMap then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.RealmExpMap.RealmExpMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.StatureBossCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.StatureBoss.StatureBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ShanMen then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ShanMenMap.ShanMenMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.DuJieCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.DuJieCopy.DuJieCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.CeShiCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.CeShiCopy.CeShiCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.TerritorialWar.TerritorialWarLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.MarryCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.MarryCopy.MarryCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.BaJiZhenCopy then
        self.ActiveLogicMoudle = "Logic/MapLogicEx/BaJiZhen/BaJiZhenLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.WorldBonfire then
        self.ActiveLogicMoudle = "Logic/MapLogicEx/WorldBonfire/WorldBonfireLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ChuanDaoCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ChuanDaoCopy.ChuanDaoCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.GuildTaskCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.GuildTaskCopy.GuildTaskCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XmFight then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.XmFight.XmFightMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XMBoss then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.XMBoss.XMBossMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.WaoYaoJuanJieFeng then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.WYJJieFeng.WYJJieFengLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.NewComCopy then
        --self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.NewComLogic"
        -- Replace the novices layer with normal boss logic
        self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.NewWorldBossLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ChangeJobCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.ChangeJobLogic.ChangeJocLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.SwordSoulCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.SwordSoulCopy.SwordSoulCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.JZSLCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.JZSLCopy.JZSLCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.FirstFight then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.FirstFight.FirstFightLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.TopJjc then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.TopJjc.TopJjcLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.CrossFuDi then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.FuDiCopy.CrossFuDiLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.CrossMonutCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.CrossMount.CrossMountLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.OyLieKai then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.FuDiCopy.OyLieKaiLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.SlayerMap then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.SlayerMap.SlayerMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XianFuHouse then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.XianFu.XianFuHouseMapLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.TopJjcWait then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.TopJjc.TopJjcWaitLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.ChangeJobBos1 then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.PlaneCopy.ChangeJobBoss1CopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.LoversFightFight then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.LoversFight.LoversFightFreelogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.LoversFightWait then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.LoversFight.LoversFightWaitLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.XuMiBaoKu then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.XuMiBaoKu.XuMiBaoKuLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.CollectPlaneCopy then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.PlaneCopy.CollectPlaneCopyLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.TrainBossCopy then
        -- self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.TrainBossLogic"
        -- Use Default logic
        -- self.ActiveLogicMoudle = "Logic.MapLogicEx.Normal.NormalMapLogic"
        self.ActiveLogicMoudle = "Logic.MapLogicEx.NewWorldBoss.NewTrainMap"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.Escort then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.Escort.EscortLogic"
    elseif self.MapCfg.MapLogicType == MapLogicTypeDefine.Prison then
        self.ActiveLogicMoudle = "Logic.MapLogicEx.Prison.PrisonLogic"
    else
        self.ActiveLogicMoudle = "Logic.MapLogicEx.Normal.NormalMapLogic"
    end

    if self.ActiveLogicMoudle ~= nil then
        -- Register a copy logic script
        self.ActiveLogic = require(self.ActiveLogicMoudle)
    end
end

-- Processing Agreement
function MapLogicExSystem:OnMsgHandle(msg)
    if self.ActiveLogic == nil then
        -- Not yet entered the scene, cache messages
        self.CacheMsg:Add(msg)
    else
        -- Have entered the scene and process the message directly
        if self.ActiveLogic.OnMsgHandle ~= nil then
            self.ActiveLogic:OnMsgHandle(msg)
        end
    end
end

-- Enter the scene and play the plot completed
function MapLogicExSystem:OnSceneCinematicFinish(closeLoading)
    if closeLoading then
        -- Close loading
        GameCenter.LoadingSystem:Close()
    end
    -- Boot detection
    GameCenter.GuideSystem:Check(GuideTriggerType.EnterMap, self.MapCfg.MapId)
    GameCenter.MainFunctionSystem:OnEnterScene()
    GameCenter.CopyMapSystem:OnEnterScene()
    GameCenter.DailyActivityTipsSystem:OnEnterScene(self.MapCfg)
    GameCenter.AuctionHouseSystem:OnEnterScene()
    GameCenter.CrossFuDiSystem:OnEnterScene()
    GameCenter.WorldSupportSystem:OnEnterScene()
    GameCenter.FuDiSystem:OnEnterScene()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ENTERMAP, self.MapCfg.MapId)
    GameCenter.LuaCharacterSystem:OnEnterScene()
    GameCenter.RankAwardSystem:OnEnterScene()
    GameCenter.DailyActivitySystem:OnEnterScene()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    if self.MapCfg.CanRiding == 0 then
        -- The current map cannot ride a horse, dismount
        if _lp ~= nil then
            _lp:MountDown()
        end
    end
end

-- Send a departure map message
-- AskText is the exit content, if you do not pass it, the default is
function MapLogicExSystem:SendLeaveMapMsg(needAsk, askText)
    if needAsk then
        if askText ~= nil then
            GameCenter.MsgPromptSystem:ShowMsgBox(askText, function(code)
                    if code == MsgBoxResultCode.Button2 then
                        self:DoLeaveMap()
                    end
                end)
        else
            Utils.ShowMsgBox(function(code)
                if code == MsgBoxResultCode.Button2 then
                    self:DoLeaveMap()
                end
            end, "C_COPY_EXIT_ASK")
        end
    else
        self:DoLeaveMap()
    end
end

-- Execute leaving the map
function MapLogicExSystem:DoLeaveMap()
    GameCenter.Network.Send("MSG_copyMap.ReqCopyMapOut", {})
    if GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.WuXingCopy then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.SLTLeaveChallengeing)
    elseif GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.XinMoCopy then
        GameCenter.BISystem:ReqClickEvent(BiIdCode.XMHJLeaveChallengeing)
    end
end

-- Is there a prompt to leave the map
function MapLogicExSystem:IsShowExitPrompt()
    if self.MapCfg ~= nil and self.MapCfg.IsLeave == 1 then
        -- Popup prompt
        Utils.ShowPromptByEnum("C_PLEASE_LEAVE_CURCOPY")
        return true
    end
    return false
end

function MapLogicExSystem:GetMainUIState()
    return {
        [MainFormSubPanel.PlayerHead] = true,         -- Protagonist avatar
        [MainFormSubPanel.TargetHead] = true,         -- Target avatar
        [MainFormSubPanel.TopMenu] = true,            -- Top Menu
        [MainFormSubPanel.MiniMap] = true,            -- Mini map
        [MainFormSubPanel.FlySwordGrave] = false,     -- realm
        [MainFormSubPanel.TaskAndTeam] = true,        -- Mission and teaming
        [MainFormSubPanel.Joystick] = true,           -- Rocker
        [MainFormSubPanel.Exp] = true,                -- experience
        [MainFormSubPanel.MiniChat] = true,           -- Small chat box
        [MainFormSubPanel.Skill] = true,              -- Skill
        [MainFormSubPanel.SelectPkMode] = true,       -- Select PK mode
        [MainFormSubPanel.FunctionFly] = true,        -- New function enables flight interface
        [MainFormSubPanel.FastPrompt] = true,         -- Quick reminder interface
        [MainFormSubPanel.FastBts] = true,            -- Quick operation button interface
        [MainFormSubPanel.Ping] = true,               --ping
        [MainFormSubPanel.SkillWarning] = false,      -- Skill release warning
        [MainFormSubPanel.CustomBtn] = true,          -- Customize buttons
        [MainFormSubPanel.SitDown] = true,            -- Meditation
        [MainFormSubPanel.RemotePlayerHead] = true,     -- Remote player avatar
        [MainFormSubPanel.ChangeSkill] = true,     -- Transformation skills
        [MainFormSubPanel.RightMenuBox] = true,       -- Main RightMenuBox
    }
end

function MapLogicExSystem:GetMainLeftUIState()
    return {
        [MainLeftSubPanel.Task] = true,        -- Task pagination
        [MainLeftSubPanel.Team] = true,        -- Team pagination
        [MainLeftSubPanel.Other] = false,      -- Other pagination
    }
end

return MapLogicExSystem
