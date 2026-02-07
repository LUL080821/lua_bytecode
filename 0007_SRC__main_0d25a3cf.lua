------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: Main.lua
-- Module: Main
-- Description: Lua's script startup file
------------------------------------------------
-- Function module for Unity object operation
TESTING_MODE = false; -- false: release, true: debug
SUBMIT_MODE = false; -- false: release, true: debug
USE_SDK = false;
LOCAL_TESTER = true -- Dành cho chế độ test nội bộ, email công ty
SOCIAL_TESTER = true -- Dành cho chế độ test public có mã mời
--- phải bật LOCAL_TESTER thành true và bật option này thành true mới có hiệu lực để sau này switch logic qua lại cho tiện

LOAD_LANG_INGAME = true;
LOCAL_SVR_LIST = false; -- Whether to use the local server list

LITE_NETWORK = true; -- Whether to use lightweight protocol

local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils");
local Main = {
    DeltaTime = 0,
}

-- Main entry function. Starting from here lua logic
function Main.Start(startTime)
    if L_UnityUtils.UNITY_EDITOR() then
        require("LuaDebug")("localhost", 7003)
    end
    require("Global.Enum")

    Debug = require("Common.CustomLib.Utility.Debug");
    if L_UnityUtils.UNITY_EDITOR() then
        Debug.IsLogging = true
    end

    -- Time-dependent functions
    Time = require("Common.CustomLib.Utility.Time");
    Time.Start(startTime);
    -- collectgarbage("setpause",200)
    -- collectgarbage("setstepmul",5000)
end

-- 1
function Main.RequireGlobalCS()
    require("Global.GlobalCS")
end

-- 2
function Main.RequireGlobalLua()
    require("Global.GlobalLua")
    DataConfig.DataMapsetting:SetIsCache(true)
end

-- 3
function Main.RequireStringDefines()
    -- Text configuration (auto-generated, all configuration tables corresponding to text tables)
    StringDefines = DataConfig.Load("StringDefines")
    -- DataConfig.LoadAll();
end
-- 4
function Main.UnRequireStringDefines()
    StringDefines = {}
    -- Text configuration (auto-generated, all configuration tables corresponding to text tables)
    DataConfig.UnLoad("StringDefines")
    -- DataConfig.LoadAll();
end

-- Core system initialization
function Main.CoreInitialize()
    GameCenter:CoreInitialize()
end
-- Core system uninstallation
function Main.CoreUninitialize()
    GameCenter:CoreUninitialize()
end

function Main.ReInitialize()
    GameCenter:ReInitialize()
end

-- Logical system initialization
function Main.LogicInitialize(clearLoginData)
    GameCenter:LogicInitialize(clearLoginData)
end

-- Logical system uninstallation
function Main.LogicUninitialize(clearLoginData)
    GameCenter:LogicUninitialize(clearLoginData)
end

-- Update your heartbeat
function Main.Update(deltaTime, realtimeSinceStartup, frameCount)
    Time.SetDeltaTime(deltaTime, realtimeSinceStartup, frameCount);
    if UnityUtils.IsUseKeyCode() then
        KeyCodeSystem.Update(deltaTime)
    end
    GameCenter:Update(deltaTime)
    GameCenter:FrameUpdate(deltaTime)
    LuaBehaviourManager:Update(deltaTime)
end

-- Create a Lua control script corresponding to ui (C# call)
function Main.CreateLuaUIScript(name, gobj)
    GameCenter.UIFormManager:CreateLuaUIScript(name, gobj)
end

-- Process messages sent by the server
function Main.DoResMessage(msgid, bytes)
    GameCenter.Network.DoResMessage(msgid, bytes)
end

-- Get the message IDs of all Lua sides
function Main.GetResLuaMsgIDs()
    return GameCenter.Network.GetResLuaMsgIDs()
end

-- Get the message ID of all Lua-end extensions
function Main.GetResLuaExtendMsgIDs()
    return GameCenter.Network.GetResLuaExtendMsgIDs()
end

-- Determine whether the UI event is defined on the Lua end
function Main.HasEvent(eID)
    return UILuaEventDefine.HasEvent(eID)
end

-- Determine whether there is an event that UIEventDefine extends on the Lua side
function Main.HasUIEventExt(eID)
    return UIEventExtDefine.HasEvent(eID)
end

-- Whether to delete the ui prefabricated parts when the form is closed
function Main.IsDestroyPrefabOnClose()
    return AppConfig.IsDestroyPrefabOnClose
end

-- Whether to run the analysis tool
function Main.IsRuntimeProfiler()
    return AppConfig.IsRuntimeProfiler
end

-- Whether it is recorded time-consuming to write files
function Main.IsRecordWriteFile()
    return AppConfig.IsRecordWriteFile
end

-- Whether to collect time
function Main.IsCollectRecord()
    return AppConfig.IsCollectRecord
end

-- Time to load the printing configuration table
function Main.TimeRecordPrint()
    CS.Thousandto.Code.Logic.TimeRecord.Print()
end

-- Do you need to reload the interface?
function Main.IsRenewForm(name)
    return GameCenter.UIFormManager:IsRenew(name)
end

-- Reload the interface
function Main.RenewForm(name, paths)
    if not GameCenter.UIFormManager then
        return
    end
    GameCenter.UIFormManager:DestroyForm(name)
    GameCenter.UIFormManager:AddRenewForm(name)
    for i = 0, paths.Length - 1 do
        Utils.RemoveRequiredByName(paths[i])
    end
end

-- Reload the logic system
function Main.RenewSystem(name, paths)
    GameCenter[string.format("%sSystem", name)] = nil
    for i = 0, paths.Length - 1 do
        Utils.RemoveRequiredByName(paths[i])
    end
    GameCenter[string.format("%sSystem", name)] = require(string.format("Logic.%s.%sSystem", name, name))
end

-- Enter the scene callback
function Main.OnEnterScene(mapID, isPlane)
    -- Notify the map logic system to enter the scene
    if GameCenter.MapLogicSystem ~= nil then
        GameCenter.MapLogicSystem:OnEnterScene(mapID, isPlane)
    end
end

-- Leave the scene callback
function Main.OnLeaveScene(isPlane)
    -- Notify the map logic system to leave the scene
    if GameCenter.MapLogicSystem ~= nil then
        GameCenter.MapLogicSystem:OnLeaveScene(isPlane)
    end
end

-- Obtain equipment enhancement level
function Main.GetStrengthLvByPos(pos)
    if GameCenter.LianQiForgeSystem ~= nil then
        return GameCenter.LianQiForgeSystem:GetStrengthLvByPos(pos)
    end
end

-- Bind FSM
function Main.BindFSM(Owner)
    -- GameCenter.AIManager:Bind(Owner, 1001);
end

-- Unbind FSM
function Main.UnBindFSM(Owner)
    -- GameCenter.AIManager:UnBind(Owner);
end

-- Determine whether it is a bang screen
function Main.IsNotchInScreen()
    --local _device = CS.UnityEngine.SystemInfo.deviceModel;
    --if _device ~= nil then
    --    if string.find(_device, "iPhone10") ~= nil then
    --        return true;
            --[[
            -- This is where other models are adapted
        elseif string.find(_device,"??????") ~= nil then
            return true;
        ]]
    --    end
    --end
    -- After querying the existing models of large manufacturers, they have adapted to the Liuhai Screen.
    return GameCenter.SDKSystem.SDKImplement:HasNotchInScreen();
end

-- Get limited-time purchase status
function Main.GetLimitShopState()
    return GameCenter.LimitShopSystem:IsShowEnter()
end

-- Are there any new limited-time products available
function Main.IsExistNewLimitShop()
    return GameCenter.LimitShopSystem:IsExistNewShop()
end

-- Hide new limited-time product tips
function Main.HideNewLimitShopTips()
    GameCenter.PushFixEvent(UILuaEventDefine.UILimitShopTipsForm_CLOSE)
    return GameCenter.LimitShopSystem:HideNewShopTips()
end

-- Obtain the status of the Immortal Alliance Player Camp
function Main.GetXmFightCamp()
    return GameCenter.XmFightSystem.Camp
end

-- Return to the list of resources selected by login
function Main.ToLoginStateNeedAssets()
    --[[
    None = 0,
    VFX = 1,
    Role = 2,
    Scene = 3,
    UITexture = 4,
    Atlas = 5,
    Font = 6,
    Animation = 7,
    VFXTexture = 8,//VFX Textures
    Form = 9,//Forms
    MusicSound = 10,//Map Audio
    UISound = 11,//UI Audio
    SpeechSound = 12,//Speech Audio
    SfxSound = 13,//SFX Audio
    AmbientSound = 14,//Ambient Audio
    FormAsset = 15,//Forms
    ]]
    return {
        {
            Type = 4,
            AssetName = "tex_logininback_4"
        },
        {
            Type = 4,
            AssetName = "tex_logo2"
        }
    };
end

-- Get the number of email prompts
function Main.GetMailNumPrompt()
    return GameCenter.MailSystem:GetMailNumPrompt()
end

-- Get the number of unread gifts
function Main.GetNotReadPresentCount()
    return GameCenter.PresentSystem:GetNotReadPresentCount()
end

-- Open the corresponding function through the enumeration code of the function ID
function Main.DoFunctionCallBack(code, param)
    return GameCenter.LuaMainFunctionSystem:DoFunctionCallBack(code, param)
end

-- The display function is not enabled prompt
function Main.ShowFuncNotOpenTips(code, param)
    return GameCenter.LuaMainFunctionSystem:ShowFuncNotOpenTips(code)
end

-- Callback when function is turned on
function Main.OnFunctionOpened(idCode, isNew)
    return GameCenter.LuaMainFunctionSystem:OnFunctionOpened(idCode, isNew)
end

-- According to the configuration table id, get how many immortal souls there are in the backpack with this id
function Main.GetXianPoCountByCfgId(cfgId)
    return GameCenter.XianPoSystem:GetXianPoCountByCfgId(cfgId)
end

-- Upper limit for collecting objects in the island of Divine Beast
function Main.CrystalIsMax(id)
    return GameCenter.SoulMonsterSystem:CrystalIsMax(id);
end

-- Whether to display the title red dot
function Main.IsShowTitleRedpoint()
    return GameCenter.RoleTitleSystem:ShowRed();
end

-- The current wearable title id
function Main.GetCurrTitleID()
    return GameCenter.RoleTitleSystem:GetCurrTitleID();
end

-- Determine whether there is a mount model set
function Main.HasMountId()
    return GameCenter.NatureSystem:HasMountId();
end

-- Obtain the current wear wing ID
function Main.GetCurModelId()
    return GameCenter.NatureSystem:GetCurModelId();
end

-- Offline experience props
function Main.AddOnHookTimeItemID()
    return GameCenter.OfflineOnHookSystem:AddOnHookTimeItemID();
end

-- Accurate to seconds
function Main.RemainOnHookTime()
    return GameCenter.OfflineOnHookSystem.RemainOnHookTime;
end

-- Obtain current experience drug bonus ratio, percentage system
function Main.GetCurItemAddRate()
    return GameCenter.OfflineOnHookSystem:GetCurItemAddRate();
end

-- Get the current world level
function Main.GetCurWorldLevel()
    return GameCenter.OfflineOnHookSystem:GetCurWorldLevel();
end

function Main.GetVariableShowText(pType, curValue, value, simplifyValue)
    return GameCenter.LuaVariableSystem:GetVariableShowText(pType, curValue, value, simplifyValue);
end

function Main.GetVariableShowProgress(pType, curValue, value)
    return GameCenter.LuaVariableSystem:GetVariableShowProgress(pType, curValue, value);
end

function Main.IsVariableReach(pType, curValue, value)
    return GameCenter.LuaVariableSystem:IsVariableReach(pType, curValue, value);
end

function Main.GetVariableValue(code)
    return GameCenter.LuaVariableSystem:GetVariableValue(code);
end

function Main.SetXmSupportRedState(isRed)
    GameCenter.WorldSupportSystem:SetXmSupportRedState(isRed)
end

function Main.GetXmSupportRedState()
    return GameCenter.WorldSupportSystem.RedPoint
end

function Main.GetTeachArray()
    return {
        GameCenter.ChuanDaoSystem.TeachId,
        GameCenter.ChuanDaoSystem.ZhenFaId
    }
end

function Main.GetDailyMaxActive()
    return GameCenter.DailyActivitySystem.MaxActive
end

function Main.IsRewradGrowthWayFinal()
    return GameCenter.GrowthWaySystem:IsRewardFinal()
end

function Main.GetGrowthWayModellID()
    return GameCenter.GrowthWaySystem:GetGrowthWayModellID()
end

function Main.GetActiveSwordIdList()
    return GameCenter.FlySowardSystem:GetActiveSwordIdList()
end

function Main.OpenLimitShopTipsForm(trans)
    GameCenter.LimitShopSystem:HideNewShopTips();
    GameCenter.PushFixEvent(UILuaEventDefine.UILimitShopTipsForm_OPEN, trans)
end

function Main.GetAssistPetList()
    return GameCenter.PetEquipSystem:GetFightPetList()
end

function Main.GetDressPeralPower(part)
    return GameCenter.SoulEquipSystem:GetDressPeralPowerByPart(part)
end

-- Customize chat channel sorting (can be modified at any time)
function Main.GetChatChanelSort()
    -- WORLD = 0, //World
    -- GUILD, //Gang 1
    -- TEAM, // Team 2
    -- PERSONAL, //Private chat 3
    -- SYSTEM, //System 4
    -- MINI, //Small chat box, also treated as a channel 5
    -- PALACE, //Wangfu Channel 6
    -- ALL, //Comprehensive 7
    -- CURRENT, //Current 8
    -- JOINTEAM, //Team 9
    -- Live, //Live 10
    -- Friend, //Friends 11
    -- Experience, //Training, Adventure Channel 12
    -- Cross, //Cross Server 13
    -- ChuanWen, //Rumor 14
    -- CH = 20, //Chinese New addition to Southeast Asia
    -- EN, //English New Southeast Asia
    -- TH, //Thailand Newly added in Southeast Asia
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.CrossChat)
    if _funcInfo ~= nil then
        if _funcInfo.IsEnable then
            return {
                4,
                14,
                2,
                1,
                0,
                13,
                9,
                8
            }
        else
            return {
                4,
                14,
                2,
                1,
                0,
                9,
                8
            }
        end
    end
end

function Main.OpenSkipForm(skipFunc)
    if GameCenter.SkipSystem ~= nil then
        GameCenter.SkipSystem:OpenSkip(skipFunc)
    end
end

function Main.CloseSkipForm()
    if GameCenter.SkipSystem ~= nil then
        GameCenter.SkipSystem:ForceCloseSkip()
    end
end

function Main.CanRewardFreeVip()
    return GameCenter.VipSystem.IsGetFreeVipExp
end

function Main.GetJJCLeftTime()
    return math.ceil( GameCenter.ArenaShouXiSystem.LeftTime )
end

function Main.CanJoinDaily(id)
    return GameCenter.DailyActivitySystem:CanJoinDaily(id)
end

function Main.JoinDaily(id)
    return GameCenter.DailyActivitySystem:JoinActivity(id)
end

function Main.GetStringDefinedLength()
    return StringDefines.Count
end

function Main.GetStringByStringDefined(id)
    return StringDefines[id]
end

-- Get the number of next prompts (-1 means no prompt, 0 can be collected, greater than 0 shows how much level is missing)
function Main.GetGotoNextCountByLevelGift()
    return GameCenter.WelfareSystem.LevelGift:GetGotoNextCount()
end



function Main.GetMeridianAddSkillDic()
    return GameCenter.PlayerSkillLuaSystem:GetAddSkillTable()
end

-- 0: means to obtain the default data -1: means to obtain the worn other values represent to obtain the data of the specified incoming id
-- Get the chat bubble IconId
function Main.GetChatPaoPaoIconId(id)
    local _ret = 0
    local _data = nil
    if id == -1 then
        _data = GameCenter.NewFashionSystem:GetPlayerPaoPaoData()
    elseif id == 0 then
        _data = GameCenter.NewFashionSystem:GetPlayerPaoPaoDefaultData()
    else
        _data = GameCenter.NewFashionSystem:GetPlayerPaoPaoDataById(id)
    end
    if _data ~= nil then
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        _ret = _data:GetModelId(_occ)
    end
    return _ret
end

-- 0: means to obtain the default data -1: means to obtain the worn other values represent to obtain the data of the specified incoming id
-- Get the player's avatar IconId
function Main.GetChatHeadIconId(id, occ)
    local _ret = 0
    local _data = nil
    if id == -1 then
        _data = GameCenter.NewFashionSystem:GetPlayerHeadData()
    elseif id == 0 then
        _data = GameCenter.NewFashionSystem:GetPlayerHeadDefaultData()
    else
        _data = GameCenter.NewFashionSystem:GetPlayerHeadDataById(id)
    end
    if _data ~= nil then
        _ret = _data:GetModelId(occ)
    end
    return _ret
end

-- 0: means to obtain the default data -1: means to obtain the worn other values represent to obtain the data of the specified incoming id
-- Get the player avatar frame IconId
function Main.GetChatHeadFrameIconId(id)
    local _ret = 0
    local _data = nil
    if id == -1 then
        _data = GameCenter.NewFashionSystem:GetPlayerHeadFrameData()
    elseif id == 0 then
        _data = GameCenter.NewFashionSystem:GetPlayerHeadFrameDefaultData()
    else
        _data = GameCenter.NewFashionSystem:GetPlayerHeadFrameDataById(id)
    end
    if _data ~= nil then
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        _ret = _data:GetModelId(_occ)
    end
    return _ret
end

function Main.GetDefaultChatPaoPaoCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerPaoPaoDefaultData()
    if _data ~= nil then
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        _ret = _data:GetCfgId()
    end
    return _ret
end

function Main.GetDefaultChatHeadCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerHeadDefaultData()
    if _data ~= nil then
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        _ret = _data:GetCfgId()
    end
    return _ret
end

function Main.GetDefaultChatHeadFrameCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerHeadFrameDefaultData()
    if _data ~= nil then
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        _ret = _data:GetCfgId()
    end
    return _ret
end

-----------------------------------------------

function Main.GetPlayerChatPaoPaoCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerPaoPaoData()
    if _data ~= nil then
        _ret = _data:GetCfgId()
    end
    return _ret
end

function Main.GetPlayerChatHeadCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerHeadData()
    if _data ~= nil then
        _ret = _data:GetCfgId()
    end
    return _ret
end

function Main.GetPlayerChatHeadFrameCfgId()
    local _ret = 0
    local _data = nil
    _data = GameCenter.NewFashionSystem:GetPlayerHeadFrameData()
    if _data ~= nil then
        _ret = _data:GetCfgId()
    end
    return _ret
end

function Main.ReqCommandTargetPos()
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        GameCenter.MapLogicSystem.ActiveLogic:ReqTargetPos()
    end
end

function Main.GetCommandFollow()
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        return GameCenter.MapLogicSystem.ActiveLogic.IsFollow
    end
    return false
end

function Main.GetCommandHasMonster()
    if GameCenter.MapLogicSystem.MapCfg and GameCenter.MapLogicSystem.MapCfg.MapLogicType == MapLogicTypeDefine.TerritorialWar then
        return GameCenter.MapLogicSystem.ActiveLogic.CurTargetMonsterId == 0
    end
    return false
end

-- Show new items to obtain
function Main.AddShowNewItem(reason, itemInst, itemID, addCount)
    GameCenter.GetNewItemSystem:AddShowItem(reason, itemInst, itemID, addCount)
end

-- Use of display items
function Main.AddUseNewItem(itemInst, reason, addCount)
    GameCenter.GetNewItemSystem:AddShowTips(itemInst, reason, addCount)
end

-- Open the item quick access interface
function Main.OpenItemQuickGetForm(itemId)
    GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(itemId)
end

function Main.ShowItemTips(goods, obj, location, isShowGetBtn, cost, isResetPosion, ExtData)
    GameCenter.ItemTipsMgr:ShowTips(goods, obj, location, isShowGetBtn, cost, isResetPosion, ExtData)
end

function Main.ShowItemTipsByID(id, obj, isShowGetBtn, location)
    GameCenter.ItemTipsMgr:ShowTipsByCfgid(id, obj, isShowGetBtn, location)
end

function Main.CloseItemTips()
    GameCenter.ItemTipsMgr:Close()
end

function Main.HasJoinedGuild()
    return GameCenter.GuildSystem:HasJoinedGuild()
end

function Main.OnExitGuildMsg()
    GameCenter.GuildSystem:OnExitGuildMsg()
end

function Main.DownLoadPayList()
    GameCenter.PaySystem:DownLoadPayList()
end

function Main.GetLoginAccount() 
    return GameCenter.LoginSystem.Account;
end

function Main.ReconnectGameServer(isChangeRole)
    GameCenter.LoginSystem:ReconnectGameServer(isChangeRole);
end

function Main.GetCurrServerID()   
    local _cur = GameCenter.ServerListSystem:GetCurrentServer();
    if _cur then
        return _cur.ServerId;
    end
    return -1;
end


function Main.GetCurrServerName()   
    local _cur = GameCenter.ServerListSystem:GetCurrentServer();
    if _cur then
        return _cur.Name;
    end
    return "";
end

function Main.HasServer(serverID)   
    local _item = GameCenter.ServerListSystem:FindServer(serverID)
    if _item then
        return true;
    end
    return false;
end

function Main.GetServerName(serverID)  
    local _item = GameCenter.ServerListSystem:FindServer(serverID)
    if _item then
        return _item.Name;
    end    
    return "";
end

function Main.GetServerShowID(serverID)
    local _item = GameCenter.ServerListSystem:FindServer(serverID)
    if _item then
        return _item.ShowServerId;
    end
    return 0;
end

function Main.GetReallyServerID(serverID)
    local _item = GameCenter.ServerListSystem:FindServer(serverID)
    if _item then
        return _item.ReallyServerId;
    end
    return 0;
end

function Main.OpenLoadingForm(callBack)
    GameCenter.LoadingSystem:Open(callBack);   
end


function Main.CloseLoadingForm()
    GameCenter.LoadingSystem:Close();
end


function Main.SetLoadingFormProgress(val)
    GameCenter.LoadingSystem:SetProgress(val/10000);
end

-- Refresh player's model data
function Main.RefreshPlayerModel(player,info)
    RoleVEquipTool.RefreshPlayerModel(player,info);   
end

function Main.OpenNpcTalk(npc, taskID, isTaskOpenUI, openUIParam)
    GameCenter.NpcTalkSystem:OpenNpcTalk(npc, taskID, isTaskOpenUI, openUIParam)
end

function Main.BindLuaCharacter(character, initInfo)
    GameCenter.LuaCharacterSystem:BindLuaCharacter(character, initInfo)
end

-- Create an object that displays the information of the role
function Main.CreatePlayerVisualInfo(roleId)
    return GameCenter.PlayerVisualSystem:GetVisualInfo(roleId);
end

-- Create FSkinModel
function Main.CreateFSkinModel(code)
    return FSkinModelWrap:New(code):GetCSObj();
end

-- Does the team exist?
function Main.IsTeamExist()
    return GameCenter.TeamSystem:IsTeamExist()
end

-- Are you a team member
function Main.IsTeamMember(id)
    return GameCenter.TeamSystem:IsTeamMember(id)
end

-- Get the friend interface type
function Main.GetFriendType()
    return UnityUtils.GetObjct2Int(GameCenter.FriendSystem.PageType)
end

function Main.IsEnemy(id)
    return GameCenter.FriendSystem:IsEnemy(id)
end

function Main.IsFriend(id)
    return GameCenter.FriendSystem:IsFriend(id)
end

function Main.IsShield(id)
    return GameCenter.FriendSystem:IsShield(id)
end

function Main.GetHolyPartFightPower(part)
    local _equip = GameCenter.HolyEquipSystem:GetDressEquip(part)
    if _equip ~= nil and _equip.Equip ~= nil then
        return _equip.Equip.Power
    end
    return 0
end

function Main.GetDressHolyEquip(part)
    local _equip = GameCenter.HolyEquipSystem:GetDressEquip(part)
    if _equip ~= nil then
        return _equip.Equip
    end
    return nil
end

function Main.CanUseSkill(skillId)
    return GameCenter.PlayerSkillSystem:CanUseSkill(skillId)
end

function Main.SkillIsSyncServer(skillId)
    return GameCenter.PlayerSkillSystem:SkillIsSyncServer(skillId)
end

function Main.SkillIsCD(skillId)
    return GameCenter.PlayerSkillSystem:SkillIsCD(skillId)
end

function Main.GetMandateSkillList()
    return GameCenter.PlayerSkillSystem:GetMandateSkillList()
end

function Main.SetFlySwordSkill(swordSkill, playerSkill)
    GameCenter.PlayerSkillSystem:SetFlySwordSkill(DataConfig.DataSkill[swordSkill], DataConfig.DataSkill[playerSkill])
end

function Main.StartMandate(monsterId)
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:Start(monsterId)
    end
end
function Main.EndMandate()
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:End()
    end
end
function Main.RestartMandate()
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:ReStart()
    end
end
function Main.MandateOnMove()
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:OnMove()
    end
end
function Main.SetMandatePause(time)
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:SetPauseTime(time)
    end
end
function Main.IsMandating()
    if GameCenter.MandateSystem ~= nil then
        return GameCenter.MandateSystem:IsRunning()
    end
    return false
end
function Main.RefreshMandatePos()
    if GameCenter.MandateSystem ~= nil then
        GameCenter.MandateSystem:RefreshStartPos()
    end
end

function Main.StartMove()
    GameCenter.PushFixEvent(UILuaEventDefine.UIAutoSearchPathForm_OPEN)
end
function Main.EndMove()
    GameCenter.PushFixEvent(UILuaEventDefine.UIAutoSearchPathForm_CLOSE)
end

-- Action conversion
function Main.GetTranslateAnimName(animObj, animName, modeType, selfBoneIndex, parentBoneIndex, inWrapMode)
    if GameCenter.AnimManager ~= nil then
        return GameCenter.AnimManager:GetTranslateAnimName(animObj, animName, modeType, selfBoneIndex, parentBoneIndex, inWrapMode)
    end
    return animName, inWrapMode
end

-- Mission entry plane
function Main.TaskEnterPlane(taskId)
    local _type = GameCenter.LuaTaskManager:GetBehaviorType(taskId)
    if _type == TaskBeHaviorType.ArrivePosEx then
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(taskId)
        if _behavior ~= nil then
            GameCenter.Network.Send("MSG_zone.ReqEnterZone", {modelId = _behavior.PlaneCopyId})
        end
    end
end

-- Tasks enter plane to put animation
function Main.TaskEnterPlaneAnim(taskId)
    local _type = GameCenter.LuaTaskManager:GetBehaviorType(taskId)
    if _type == TaskBeHaviorType.ArriveToAnim then
        local _behavior = GameCenter.LuaTaskManager:GetBehavior(taskId)
        if _behavior ~= nil then
            GameCenter.Network.Send("MSG_zone.ReqEnterZone", {modelId = _behavior.PlaneCopyId})
        end
    end
end

-- Game message processing
function Main.OnGameMessage(msg)
    if GameCenter.GameMessager ~= nil then
        return GameCenter.GameMessager.OnGameMessage(msg)
    end
    return false
end

-- Switching Shader processing
function Main.ShaderSwitch(sh,modeltype,imodelid)
    return FGameObjectShaderUtils.ShaderSwitch(sh,modeltype,imodelid)
end

function Main.OnClientGM(cmd)
    local _result = false
    if cmd == "@@faxingsucai@@" then
        GameCenter.PushFixEvent(UILuaEventDefine.UIFaXingSuCaiForm_OPEN)
        _result = true
    elseif string.find(cmd, "@@mountspeed ") then
        local _cmdParams = Utils.SplitStr(cmd, ' ')
        local _speed = tonumber(_cmdParams[2])
        if _speed ~= nil then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                _lp.MountAnimSpeed = _speed
            end
        end
    end
    return _result
end

function Main.SetPlayerHead(trans, iconFashionId, frameFashionId, occ, playerId, headPicId, isShowHeadPic)
    local _head = PlayerHead:New(trans)
    if _head ~= nil then
        _head:SetHead(iconFashionId, frameFashionId, occ, playerId, headPicId, isShowHeadPic)
    end
end

function Main.SetPlayerLevel(trans, level, showLevelText)
    local _level = PlayerLevel:OnFirstShow(trans)
    if _level ~= nil then
        _level:SetLevel(level, showLevelText)
    end
end

function Main.EnterFengXi(cityId)
    if  GameCenter.CrossFuDiSystem:OyLiKaiIsOpen() then
        GameCenter.CrossFuDiSystem:SetCurCityId(cityId)
        GameCenter.CrossFuDiSystem:SetEnterCityId(cityId)
        GameCenter.CrossFuDiSystem:SetCurSelectBossId(0)
        GameCenter.CrossFuDiSystem:ReqCrossFudEnter(cityId, 1)
        GameCenter.CrossFuDiSystem.IsHelpFengXi = true
    else
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_GUMOFENGYING_END"))
    end
end

function Main.GetWordFilterIngore()
    return " &*"
end

function Main.CreateItembaseByCfgId(itemId)
    local _result = LuaItemBase.CreateItemBase(itemId)
    if type(_result) == "table" then
        return _result._SuperObj_
    else
        return _result
    end
end

function Main.IsCurrentTaskBlockTransport()
    local _ret = GameCenter.LuaTaskManager:IsCurrentTaskBlockTransport()
    if _ret == nil then
        return false
    end
    return _ret
end  

-- ================== Debug Tool Functions ===================
function Main.getDebugLocalPlayer()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local occ = _lp.IntOcc or 0
    
    local fashion_body_id = _lp.FashionBodyID or 0
    local fashion_weapon_id = _lp.FashionWeaponID or 0
    local wing_id = _lp.WingID or 0
    
  
    -- Body Model
    local fashion_body_cfg = GameCenter.NewFashionSystem:GetTotalData(fashion_body_id)
    local body_model_id = 0
    local body_model_prefab = 0
    if fashion_body_cfg ~= nil then
        body_model_id = fashion_body_cfg:GetModelId(occ)
        local body_model_cfg = DataConfig.DataModelConfig[body_model_id]
        if body_model_cfg ~= nil then
            body_model_prefab = body_model_cfg.Model
        end
    end

    -- Weapon Model
    local fashion_weapon_cfg = GameCenter.NewFashionSystem:GetTotalData(fashion_weapon_id)
    local weapon_model_id = 0
    local weapon_model_prefab = 0
    if fashion_weapon_cfg ~= nil then
        weapon_model_id = fashion_weapon_cfg:GetModelId(occ)
        local weapon_model_cfg = DataConfig.DataModelConfig[weapon_model_id]
        if weapon_model_cfg ~= nil then
            weapon_model_prefab = weapon_model_cfg.Model
        end
    end

    -- Skills
    local skill_configs = DataConfig.DataSkill or {}
    local skill_ids = GameCenter.PlayerSkillSystem:GetMandateSkillList()
    local skill_mandate_list_str = ""
    for _, skill_id in ipairs(skill_ids) do
        local skill_config = skill_configs[skill_id] or {}
        if skill_mandate_list_str ~= "" then
            skill_mandate_list_str = skill_mandate_list_str .. ""
        end
        skill_mandate_list_str = skill_mandate_list_str .. "- " ..  tostring(skill_id) .. " (" .. skill_config.VisualDef .. ") \n"
    end

    local data_str = ""
    
    data_str = data_str .. "occ: " .. tostring(occ) .. "\n"
    
    data_str = data_str .. "body_fashion_id: " .. tostring(fashion_body_id) .. "\n"
    data_str = data_str .. "body_model_id: " .. tostring(body_model_id) .. "\n"
    data_str = data_str .. "body_model_prefab: player_" .. tostring(body_model_prefab) .. "\n"
    
    data_str = data_str .. "weapon_fashion_id: " .. tostring(fashion_weapon_id) .. "\n"
    data_str = data_str .. "weapon_model_id: " .. tostring(weapon_model_id) .. "\n"
    data_str = data_str .. "weapon_model_prefab: gw_" .. tostring(weapon_model_prefab) .. "\n"
    
    data_str = data_str .. "wing_id: " .. tostring(wing_id) .. "\n"
    
    data_str = data_str .. "skill_ids: \n" .. skill_mandate_list_str .. "\n"

    return data_str
end

return Main
