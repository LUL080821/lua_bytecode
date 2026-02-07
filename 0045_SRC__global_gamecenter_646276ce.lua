------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: GameCenter.lua
-- Module: GameCenter
-- Description: The center of game logic, saving almost all logical information
------------------------------------------------
-- //Module reference
local CSGameCenter = CS.Thousandto.Code.Center.GameCenter

-- //Module definition
local GameCenter = {
    IsCoreInit  = false,
    IsLogicInit = false,
    DeltaTime   = 0,
    FrameCount  = 0,
}

-- Core system initialization
function GameCenter:CoreInitialize()
    if self.IsCoreInit then
        return
    end
    -- Network Management
    self.Network = require("Network.Network");
    -- UI management category
    self.UIFormManager = require("UI.Base.UIFormManager");
    -- Map logic management class
    self.MapLogicSystem = require("Logic.MapLogicEx.MapLogicExSystem");
    -- Game message management category
    self.GameMessager = require("Logic.GameMessager.GameMessager");
    -- Picture synchronization system
    self.TexHttpSyncSystem = require "Logic.TexHttpSync.TexHttpSyncSystem";

    -- -Define the core system referenced from CS
    self.GameSceneSystem = CSGameCenter.GameSceneSystem
    self.MapLogicSwitch = CSGameCenter.MapLogicSwitch
    self.SDKSystem = CSGameCenter.SDKSystem;
    self.Network.Init(LITE_NETWORK)
    self.GameMessager.Init()
    self.IsCoreInit = true
    self.TexHttpSyncSystem:Initialize()
end

-- Core system uninstallation
function GameCenter:CoreUninitialize()
    if not self.IsCoreInit then
        return
    end
    self.Network = nil
    Utils.RemoveRequiredByName("Network.Network")
    self.UIFormManager = nil
    Utils.RemoveRequiredByName("UI.Base.UIFormManager")
    self.MapLogicSystem = nil
    Utils.RemoveRequiredByName("Logic.MapLogicEx.MapLogicExSystem")
    self.TexHttpSyncSystem:UnInitialize()
    self.TexHttpSyncSystem = nil
    Utils.RemoveRequiredByName("Logic.TexHttpSync.TexHttpSyncSystem")

    self.GameSceneSystem = nil
    self.MapLogicSwitch = nil
    self.SDKSystem = nil
    self.IsCoreInit = false
end

-- Logical system initialization
function GameCenter:LogicInitialize(clearLoginData)
    if self.IsLogicInit then
        return
    end
    -- local _t1 = os.clock();

    -- -Define the logical system referenced from CS
    self.RedPointSystem = CSGameCenter.RedPointSystem
    self.ItemContianerSystem = CSGameCenter.ItemContianerSystem
    self.EquipmentSystem = CSGameCenter.EquipmentSystem
    self.GameSetting = CSGameCenter.GameSetting;
    self.WorldMapInfoManager = CSGameCenter.WorldMapInfoManager
    self.MsgPromptSystem = CSGameCenter.MsgPromptSystem
    self.PathFinderSystem = CSGameCenter.PathFinderSystem
    self.MainFunctionSystem = CSGameCenter.MainFunctionSystem
    self.GuideSystem = CSGameCenter.GuideSystem
    self.RechargeSystem = CSGameCenter.RechargeSystem
    self.MainCustomBtnSystem = CSGameCenter.MainCustomBtnSystem
    self.HeartSystem = CSGameCenter.HeartSystem
    self.PathSearchSystem = CSGameCenter.PathSearchSystem
    self.GuildRepertorySystem = CSGameCenter.GuildRepertorySystem
    self.TimerEventSystem = CSGameCenter.TimerEventSystem
    self.LanguageConvertSystem = CSGameCenter.LanguageConvertSystem
    self.VariableSystem = CS.Thousandto.Code.Logic.VariableSystem;
    self.BuffSystem = CSGameCenter.BuffSystem;
    self.ImmortalResSystem = CSGameCenter.ImmortalResSystem
    self.BlockingUpPromptSystem = CSGameCenter.BlockingUpPromptSystem
    self.AuctionHouseSystem = CSGameCenter.AuctionHouseSystem
    self.UpdateSystem = CSGameCenter.UpdateSystem;
    self.ReconnectSystem = CSGameCenter.ReconnectSystem;
    self.CacheSceneSystem = CSGameCenter.CacheSceneSystem
    self.BISystem = CSGameCenter.BISystem
    self.ChatSystem = CSGameCenter.ChatSystem
    self.ChatPrivateSystem = CSGameCenter.ChatPrivateSystem
    self.FormStateSystem = CSGameCenter.FormStateSystem
    self.TextureManager = CSGameCenter.TextureManager
    self.GatherTishiSystem = CSGameCenter.GatherTishiSystem
    self.DropAscriptionSystem = CSGameCenter.DropAscriptionSystem
    self.SkillSelectFiledManager = CSGameCenter.SkillSelectFiledManager
    self.InputSystem = CSGameCenter.InputSystem
    self.SkillVisualManager = CSGameCenter.SkillVisualManager
    self.SceneRestoreSystem = CSGameCenter.SceneRestoreSystem
    self.ChatMonitorSystem = CSGameCenter.ChatMonitorSystem
    self.MaterialManager = CSGameCenter.MaterialManager

    -- local _t2 = os.clock();
    if clearLoginData then
        Debug.LogError("After cleaning up the login data, reload all data");
        -- Player character list
        self.PlayerRoleListSystem = require("Logic.PlayerRoleList.PlayerRoleListSystem");
        self.LoginSystem = require("Logic.Login.LoginSystem");
        self.ServerListSystem = require("Logic.ServerList.ServerListSystem");
        -- Recharge system
        self.PaySystem = require("Logic.PaySystem.PaySystem")
    end

    self.LuaMainFunctionSystem = require("Logic.LuaMainFunction.LuaMainFunctionSystem")
    self.OfflineOnHookSystem = require("Logic.OfflineOnHook.OfflineOnHookSystem")
    self.LuaVariableSystem = require("Logic.LuaVariable.LuaVariableSystem")
    self.NatureSystem = require("Logic.Nature.NatureSystem")
    self.CopyMapSystem = require("Logic.CopyMapSystem.CopyMapSystem")
    self.DailyActivitySystem = require("Logic.DailyActivity.DailyActivitySystem")
    self.LianQiForgeSystem = require("Logic.LianQiForge.LianQiForgeSystem")
    self.LianQiForgeBagSystem = require("Logic.LianQiForge.LianQiForgeBagSystem")
    self.LianQiGemSystem = require("Logic.LianQiGem.LianQiGemSystem")
    self.RankSystem = require("Logic.Rank.RankSystem")
    self.GodBookSystem = require("Logic.GodBook.GodBookSystem")
    self.ItemTipsMgr = require("Logic.Item.ItemTipsMgr")
    self.NewItemContianerSystem = require("Logic.Item.NewItemContianerSystem")
    -- Sea of consciousness system
    self.PlayerShiHaiSystem = require("Logic.PlayerShiHai.PlayerShiHaiSystem")
    self.FactionSkillSystem = require("Logic.FactionSkill.FactionSkillSystem")
    -- Blessed land system
    self.FuDiSystem = require("Logic.FuDi.FuDiSystem")
    -- BOSS system
    self.BossSystem = require("Logic.Boss.BossSystem")
    -- BOSS system
    self.MountBossSystem = require("Logic.Boss.MountBossSystem")
    self.SlayerBossSystem = require("Logic.Boss.SlayerBossSystem")
    -- Feedback System
    self.FeedBackSystem = require("Logic.FeedBack.FeedBackSystem");
    -- Achievement System
    self.AchievementSystem = require("Logic.Achievement.AchievementSystem")
    -- Marriage system
    self.MarriageSystem = require("Logic.Marriage.MarriageSystem")
    -- Chief Arena System
    self.ArenaShouXiSystem = require("Logic.ArenaShouXi.ArenaShouXiSystem")
    -- Go to the BOSS location system
    self.BossInfoTipsSystem = require("Logic.BossInfoTips.BossInfoTipsSystem")
    -- Email system
    self.MailSystem = require("Logic.Mail.MailSystem")
    -- Set system
    self.EquipmentSuitSystem = require("Logic.EquipmentSuit.EquipmentSuitSystem")
    -- Title xitong
    self.RoleTitleSystem = require("Logic.RoleTitle.RoleTitleSystem")
    -- Pet system
    self.PetSystem = require("Logic.Pet.PetSystem")
    -- Welfare system
    self.WelfareSystem = require("Logic.Welfare.WelfareSystem")
    -- Mall System
    self.ShopSystem = require("Logic.Shop.ShopManager")
    -- Shop Special System
    self.ShopSpecialSystem = require("Logic.ShopSpecial.ShopSpecialSystem")
    -- Opening a server carnival
    self.ServeCrazySystem = require("Logic.ServeCrazy.ServeCrazySystem")
    -- The road to growth
    self.GrowthWaySystem = require("Logic.GrowthWay.GrowthWaySystem")
    -- Service opening activities
    self.ServerActiveSystem = require("Logic.ServerActive.ServerActiveSystem")
    -- Daily recharge
    self.DailyRechargeSystem = require("Logic.DailyRecharge.DailyRechargeSystem")
    -- Fairy Soul System
    self.XianPoSystem = require("Logic.XianPo.XianPoSystem")
    -- Treasure Hunt System
    self.TreasureHuntSystem = require("Logic.TreasureHunt.TreasureHuntSystem")
    -- Immortal Armor Treasure Hunt
    self.XJXunbaoSystem = require("Logic.TreasureHunt.XJXunbaoSystem")
    -- Screen CD system
    self.ScreenCDSystem = require("Logic.ScreenCDSystem.ScreenCDSystem")
    -- First charge system
    self.FristChargeSystem = require("Logic.FristCharge.FristChargeSystem")
    -- Trading bank
    self.ShopAuctionSystem = require("Logic.ShopAuction.ShopAuctionSystem")
    -- World Question Answer
    self.WorldAnswerSystem = require("Logic.WorldAnswer.WorldAnswerSystem")
    -- Guarding the Sect
    self.GuardianFactionSystem = require("Logic.GuardianFaction.GuardianFactionSystem")
    -- The Island of the Divine Beast
    self.SoulMonsterSystem = require("Logic.SoulMonster.SoulMonsterSystem")
    -- Realm BOSS
    self.StatureBossSystem = require("Logic.StatureBoss.StatureBossSystem")
    -- Realm Spiritual Pressure
    self.RealmStifleSystem = require("Logic.RealmStifle.RealmStifleSystem")
    -- Monologue Dialog Box
    self.SoliloquySystem = require("Logic.Soliloquy.SoliloquySystem")
    -- Eight-pole array diagram
    self.BaJiZhenSystem = require("Logic.BaJiZhen.BaJiZhenSystem")
    -- Territory War
    self.TerritorialWarSystem = require("Logic.TerritorialWar.TerritorialWarSystem")
    -- bonfire
    self.BonfireActivitySystem = require("Logic.BonfireActivitySystem.BonfireActivitySystem")
    -- Spiritual body
    self.LingTiSystem = require("Logic.LingTi.LingTiSystem")
    -- Master's teachings
    self.ChuanDaoSystem = require("Logic.ChuanDao.ChuanDaoSystem")
    -- Hall of Fame
    self.CelebritySystem = require("Logic.Celebrity.CelebritySystem")
    -- The leader seeks help
    self.WorldSupportSystem = require("Logic.WorldSupport.WorldSupportSystem")
    -- vip
    self.VipSystem = require("Logic.VipSystem.VipSystem")
    -- Vip Zhou Chang
    self.ZhouChangSystem = require("Logic.VipZhouChang.ZhouChangSystem")
    -- Robot chat system
    self.RobotChatSystem = require("Logic.RobotChat.RobotChatSystem")
    -- Resource Retrieval
    self.ResBackSystem = require("Logic.ResBack.ResBackSystem")
    -- Marrow washing system
    self.RealmXiSuiSystem = require("Logic.RealmXiSui.RealmXiSuiSystem")
    -- Limited time purchase
    self.LimitShopSystem = require("Logic.LimitShop.LimitShopSystem")
    -- Immortal Alliance Battle
    self.XmFightSystem = require("Logic.XmFight.XmFightSystem")
    -- Immortal Alliance Boss
    self.XMBossSystem = require("Logic.XMBoss.XMBossSystem")
    -- Immortal Alliance Battle Help Interface
    self.XmHelpSystem = require("Logic.XmHelp.XmHelpSystem")
    -- Map system
    self.MapSystem = require("Logic.Map.MapSystem")
    -- New fashion system
    self.NewFashionSystem = require("Logic.NewFashion.NewFashionSystem")
    -- Model display interface
    self.ModelViewSystem = require("Logic.ModelView.ModelViewSystem")
    -- Cross-Server Event Display Map
    self.CrossServerMapSystem = require("Logic.CrossServerMapSystem.CrossServerMapSystem")
    -- Function preview function
    self.FunctionNoticeSystem = require("Logic.FunctionNotice.FunctionNoticeSystem")
    -- Mysterious store
    self.MysteryShopSystem = require("Logic.MysteryShopSystem.MysteryShopSystem")
    -- Sword Spirit
    self.FlySowardSystem = require("Logic.FlySoward.FlySowardSystem")
    -- Transfer
    self.ChangeJobSystem = require("Logic.ChangeJob.ChangeJobSystem")
    -- New server activities
    self.NewServerActivitySystem = require("Logic.NewServerActivity.NewServerActivitySystem")
    -- Gift Gift System
    self.PresentSystem = require("Logic.Present.PresentSystem")
    -- Limited time discount
    self.LimitDicretShopMgr = require("Logic.Shop.LimitDicretShopMgr")
    self.LimitDicretShopMgr2 = require("Logic.Shop.LimitDicretShopMgr2")
    -- Operations
    self.YYHDSystem = require("Logic.YYHD.YYHDSystem")
    -- jump over
    self.SkipSystem = require("Logic.Skip.SkipSystem")
    -- Blind date wall
    self.MarryDatingWallSystem = require("Logic.MarryDatingWall.MarryDatingWallSystem")

    -- Weekly benefits lottery
    self.LuckyDrawWeekSystem = require("Logic.LuckyDrawWeek.LuckyDrawWeekSystem");

    -- Saturday Carnival
    self.WeekCrazySystem = require("Logic.WeekCrazy.WeekCrazySystem")
    -- Collection Pavilion
    self.ZhenCangGeSystem = require("Logic.ZhenCangGeSystem.ZhenCangGeSystem")
    -- Skill system lua end logic
    self.PlayerSkillLuaSystem = require("Logic.PlayerSkill.PlayerSkillLuaSystem")
    -- Share Like
    self.ShareAndLikeSystem = require("Logic.ShareAndLike.ShareAndLike")
    -- Peak competition
    self.TopJjcSystem = require("Logic.TopJjc.TopJjcSystem")
    -- HuSong
    self.HuSongSystem = require("Logic.HuSong.HuSongSystem")
    -- Escort
    self.EscortSystem = require("Logic.Escort.EscortSystem")
    -- Main interface limited time icon
    self.MainLimitIconSystem = require("Logic.MainLimitIcon.MainLimitIconSystem")
    -- Daily activity reminder system
    self.DailyActivityTipsSystem = require("Logic.DailyActivityTips.DailyActivityTipsSystem")
    -- Lucky flop
    self.LuckyCardSystem = require("Logic.LuckyCard.LuckyCardSystem")
    -- Pet equipment system
    self.PetEquipSystem = require("Logic.Pet.PetEquipSystem")
    -- Mount Equipment System
    self.MountEquipSystem = require("Logic.MountEquip.MountEquipSystem")
    -- Heavenly ban order
    self.TianJinLingSystem = require("Logic.TianJinLing.TianJinLingSystem")
    -- Full-level reminder
    self.FullLevelTipsSystem = require("Logic.FullLevelTips.FullLevelTipsSystem")
    -- Immortal Cultivation Treasure Mirror
    self.RankAwardSystem = require("Logic.RankAward.RankAwardSystem")
    -- Soul Armor
    self.SoulEquipSystem = require("Logic.SoulEquip.SoulEquipSystem")
    -- Cross-server blessed place
    self.CrossFuDiSystem = require("Logic.CrossFuDi.CrossFuDiSystem")
    -- Digital input
    self.NumberInputSystem = require("Logic.NumberInput.NumberInputSystem")
    -- Meditation system
    self.SitDownSystem = require("Logic.SitDown.SitDownSystem")
    -- New item display system
    self.GetNewItemSystem = require("Logic.GetNewItemSystem.GetNewItemSystem")
    -- Background texture management required for loading form
    self.LoadingTextureManager = require("Logic.Loading.LoadingTextureManager")
    -- Quick item acquisition system
    self.ItemQuickGetSystem = require("Logic.ItemQuickGetSystem.ItemQuickGetSystem")
    -- Auction house
    self.AuctionHouseSystem = require("Logic.AuctionHouse.AuctionHouseSystem")
    -- Custom button system
    self.MainCustomBtnSystem = require("Logic.MainCustomBtnSystem.MainCustomBtnSystem")
    -- Announcement system
    self.NoticeSystem = require("Logic.Notice.NoticeSystem")
    -- Divine beast
    self.MonsterSoulSystem = require("Logic.MonsterSoul.MonsterSoulSystem")
    -- Immortal Alliance
    self.GuildSystem = require("Logic.Guild.GuildSystem")
    -- Gosu event sdk
    self.GosuEventSystem = require("Logic.GosuEvent.GosuEventSystem")

    -- Jianlingge hanging system
    self.SwordMandateSystem = require("Logic.SwordMandate.SwordMandateSystem")
    -- Loading the form system
    self.LoadingSystem = require("Logic.Loading.LoadingSystem")
    -- Spirit stone acquisition system
    self.BigBoomSystem = require("Logic.BigBoomSystem.BigBoomSystem")
    -- New equipment system
    self.NewEquipmentSystem = require("Logic.Item.NewEquipmentSystem")
    -- NPC dialogue system
    self.NpcTalkSystem = require("Logic.NpcTalkSystem.NpcTalkSystem")
    -- lua role system
    self.LuaCharacterSystem = require("Logic.LuaCharacter.LuaCharacterSystem")
    -- Friend system
    self.FriendSystem = require("Logic.Friend.FriendsSystem")
    -- Player display system
    self.PlayerVisualSystem = require("Logic.Entity.Character.Player.PlayerVisualSystem")
    -- Team system
    self.TeamSystem = require("Logic.Team.TeamSystem")
    -- Target system
    self.TargetSystem = require("Logic.TargetSystem.TargetSystem")
    -- Holy installation system
    self.HolyEquipSystem = require("Logic.HolyEquip.HolyEquipSystem")
    -- Skill System
    self.PlayerSkillSystem = require("Logic.PlayerSkill.PlayerSkillSystem")
    -- Player Stat System
    self.PlayerStatSystem = require("Logic.PlayerStat.PlayerStatSystem")
    -- Hang-up system
    self.MandateSystem = require("Logic.Mandate.MandateSystem")
    -- Action Manager
    self.AnimManager = require("Logic.AnimManager.AnimManager")
    -- Task Management
    self.LuaTaskManager = require("Logic.TaskSystem.Manager.LuaTaskManager")
    CSGameCenter.TaskManager = self.LuaTaskManager
    -- Task behavior management
    self.TaskController = require("Logic.TaskSystem.Manager.TaskController")
    CSGameCenter.TaskController = self.TaskController
    -- Task message management
    self.TaskManagerMsg = require("Logic.TaskSystem.Manager.TaskManagerMsg")
    -- Boot system
    self.GuideSystem = require("Logic.GuideSystem.GuideSystem")
    CSGameCenter.GuideSystem = self.GuideSystem
    -- Blocking the system
    self.BlockingUpPromptSystem = require("Logic.BlockingUpPrompt.BlockingUpPromptSystem")
    CSGameCenter.BlockingUpPromptSystem = self.BlockingUpPromptSystem
    -- Reward Order System
    self.KaosOrderSystem = require("Logic.KaosOrderBaseSystem.KaosOrderSystem")
    -- Magic sealing platform system
    self.FengMoTaiSystem = require("Logic.FengMoTaiSystem.FengMoTaiSystem")
    -- Demon Soul System
    self.DevilSoulSystem = require("Logic.DevilSoul.DevilSoulSystem")
    -- ui scenario management
    self.UISceneManager = require("Logic.UIScene.UISceneManager")
    self.FlySwordGraveSystem = require("Logic.FlySoward.FlySwordGraveSystem")
    -- Home Mission
    self.HomeTaskSystem = require "Logic.HomeTaskSystem.HomeTaskSystem"
    -- Perfect love system
    self.PrefectRomanceSystem = require "Logic.PrefectRomance.PrefectRomanceSystem"
    -- NPC friend system
    self.NPCFriendSystem = require "Logic.Friend.NPCFriendSystem"
    -- Home Personal Information Message Board
    self.CommunityMsgSystem = require "Logic.CommunityMsg.CommunityMsgSystem"
    -- Home Decoration Competition
    self.DecorateSystem = require "Logic.Decorate.DecorateSystem"
    -- Custom avatar change system
    self.CustomChangeHeadSystem = require "Logic.CustomChangeHeadSystem.CustomChangeHeadSystem"
    -- Zero Yuan Purchase System
    self.ZeroBuySystem = require "Logic.ZeroBuy.ZeroBuySystem"
    -- Today's Event System
    self.TodayFuncSystem = require "Logic.TodayFunc.TodayFuncSystem"
    -- Fairy Couple Showdown
    self.LoversFightSystem = require "Logic.LoversFight.LoversFightSystem"
    -- Magic installation system
    self.UnrealEquipSystem = require "Logic.UnrealEquip.UnrealEquipSystem"
    -- The Immortal Alliance Fights for Hegemony
    self.XMZhengBaSystem = require "Logic.XMZhengBa.XMZhengBaSystem"
    -- Prison
    self.PrisonSystem = require("Logic.Prison.PrisonSystem")

    -- local _t3 = os.clock();
    -- Player character list
    self.PlayerRoleListSystem:Initialize(clearLoginData)
    self.LoginSystem:Initialize(clearLoginData)
    self.ServerListSystem:Initialize(clearLoginData)
    -- Recharge system
    self.PaySystem:Initialize(clearLoginData)
    self.FriendSystem:Initialize()
    self.FlySwordGraveSystem:Initialize()
    self.GuildSystem:Initialize()
    -- Pet equipment system
    self.PetEquipSystem:Initialize()
    -- Mount Equipment System
    self.MountEquipSystem:Initialize()
    -- System of creation
    self.NatureSystem:Initialize()
    -- DataConfig.LoadAll()
    self.CopyMapSystem:Initialize()
    -- Daily activities system
    self.DailyActivitySystem:Initialize()
    -- Offline experience system
    self.OfflineOnHookSystem:Initialize()
    -- Refining forging system
    self.LianQiForgeSystem:Initialize()
    -- Refining forging bag system
    self.LianQiForgeBagSystem:Initialize()
    -- Refining gem system
    self.LianQiGemSystem:Initialize()
    -- Ranking list
    self.RankSystem:Initialize()
    -- Heavenly Book System
    self.GodBookSystem:Initialize()
    -- Sectarian Skill System
    self.FactionSkillSystem:Initialize()
    -- Feedback System
    self.FeedBackSystem:Initialize();
    -- Achievement System
    self.AchievementSystem:Initialize()
    -- BossSystem
    self.BossSystem:Initialize()
    self.MountBossSystem:Initialize()
    self.SlayerBossSystem:Initialize()
    -- magic weapon
    self.RealmStifleSystem:Initialize()
    -- Marriage system
    self.MarriageSystem:Initialize()
    -- Chief Arena System
    self.ArenaShouXiSystem:Initialize()
    -- Email system
    self.MailSystem:Initialize()
    -- Set system
    self.EquipmentSuitSystem:Initialize()
    -- Title system
    self.RoleTitleSystem:Initialize()
    -- Pet system
    self.PetSystem:Initialize()
    -- Welfare system
    self.WelfareSystem:Initialize()
    -- Mall System
    self.ShopSystem:Initialize()
    -- Shop Special System
    self.ShopSpecialSystem:Initialize()
    -- Opening a server carnival
    self.ServeCrazySystem:Initialize()
    -- The road to growth
    self.GrowthWaySystem:Initialize()
    -- Service opening activities
    self.ServerActiveSystem:Initialize()
    -- Daily recharge
    self.DailyRechargeSystem:Initialize()
    -- Fairy Soul System
    self.XianPoSystem:Initialize()
    -- Treasure Hunt System
    self.TreasureHuntSystem:Initialize()
    -- Immortal Armor Treasure Hunt
    self.XJXunbaoSystem:Initialize()
    -- First charge system
    self.FristChargeSystem:Initialize()
    -- Trading bank
    self.ShopAuctionSystem:Initialize()
    -- World Question Answer
    self.WorldAnswerSystem:Initialize()
    -- Guarding the Sect
    self.GuardianFactionSystem:Initialize()
    -- The Island of the Divine Beast
    self.SoulMonsterSystem:Initialize()
    -- Realm BOSS
    self.StatureBossSystem:Initialize()
    -- Monologue Dialog Box
    self.SoliloquySystem:Initialize()
    -- Territory War
    self.TerritorialWarSystem:Initialize()
    -- Eight-pole array diagram
    self.BaJiZhenSystem:Initialize()
    -- bonfire
    self.BonfireActivitySystem:Initialize()
    -- Spiritual body
    self.LingTiSystem:Initialize()
    -- Master's teachings
    self.ChuanDaoSystem:Initialize()
    -- Hall of Fame
    self.CelebritySystem:Initialize()
    -- The leader seeks help
    self.WorldSupportSystem:Initialize()
    -- Vip
    self.VipSystem:Initialize()
    -- Zhou Chang
    self.ZhouChangSystem:Initialize()
    -- Robot chat system
    self.RobotChatSystem:Initialize()
    -- Resource Retrieval
    self.ResBackSystem:Initialize()
    -- Marrow washing system
    self.RealmXiSuiSystem:Initialize()
    -- Limited time purchase
    self.LimitShopSystem:Initialize()
    -- Immortal Alliance Battle
    self.XmFightSystem:Initialize()
    -- Immortal Alliance Boss
    self.XMBossSystem:Initialize()
    -- Blessed land
    self.FuDiSystem:Initialize()
    -- Immortal Alliance Battle
    self.XmHelpSystem:Initialize()
    -- Map system
    self.MapSystem:Initialize()
    -- Fashion system
    self.NewFashionSystem:Initialize()
    -- Model display system
    self.ModelViewSystem:Initialize()
    -- Cross-Server Event Display Map
    self.CrossServerMapSystem:Initialize()
    -- Functional preview system
    self.FunctionNoticeSystem:Initialize()
    self.MysteryShopSystem:Initialize()
    -- Transfer system
    self.ChangeJobSystem:Initialize()
    -- Discount gift pack
    self.LimitDicretShopMgr:Initialize()
    self.LimitDicretShopMgr2:Initialize()
    -- Operations
    self.YYHDSystem:Initialize()
    -- Peak competition
    self.TopJjcSystem:Initialize()
    -- HuSong
    self.HuSongSystem:Initialize()
    -- Escort
    self.EscortSystem:Initialize()
    -- Transfer system
    self.NewServerActivitySystem:Initialize()
    -- Blind date wall
    self.MarryDatingWallSystem:Initialize()
    -- Lucky lottery
    self.LuckyDrawWeekSystem:Initialize();
    -- Saturday Carnival
    self.WeekCrazySystem:Initialize()
    -- Collection Pavilion
    self.ZhenCangGeSystem:Initialize()
    -- Skill system lua end logic
    self.PlayerSkillLuaSystem:Initialize()
    -- Share Like
    self.ShareAndLikeSystem:Initialize()
    -- Main interface limited time icon
    self.MainLimitIconSystem:Initialize()
    -- Daily activity reminder system
    self.DailyActivityTipsSystem:Initialize()
    -- Lucky flop
    self.LuckyCardSystem:Initialize()
    -- Heavenly ban order
    self.TianJinLingSystem:Initialize()
    -- Full-level reminder
    self.FullLevelTipsSystem:Initialize()
    -- Immortal Cultivation Treasure Mirror
    self.RankAwardSystem:Initialize()
    -- Soul Armor
    self.SoulEquipSystem:Initialize()
    -- Cross-server blessed land system
    self.CrossFuDiSystem:Initialize()
    -- New item display system
    self.GetNewItemSystem:Initialize()
    -- Background texture processing of loading form
    self.LoadingTextureManager:Initialize()
    -- Quick item acquisition system
    self.ItemQuickGetSystem:Initialize()
    -- Auction house
    self.AuctionHouseSystem:Initialize()
    -- Custom button system
    self.MainCustomBtnSystem:Initialize()
    -- Announcement system
    self.NoticeSystem:Initialize()
    -- Jianlingge hanging system
    self.SwordMandateSystem:Initialize()
    -- Spirit stone acquisition system
    self.BigBoomSystem:Initialize()
    -- lua role system
    self.LuaCharacterSystem:Initialize()
    -- Player display information
    self.PlayerVisualSystem:Initialize()
    -- Team system
    self.TeamSystem:Initialize()
    -- Holy installation system
    self.HolyEquipSystem:Initialize()
    -- Skill System
    self.PlayerSkillSystem:Initialize()
    -- Player Stat System
    self.PlayerStatSystem:Initialize()
    -- Gosu event SDK
    self.GosuEventSystem:Initialize()
    -- Hang-up system
    self.MandateSystem:Initialize()
    self.MonsterSoulSystem:Initialize()
    -- Task system
    self.LuaTaskManager:IniItialization()
    self.TaskManagerMsg:Initialize()
    -- Boot system
    self.GuideSystem:Initialize()
    -- Blocking the system
    self.BlockingUpPromptSystem:Initialize()
    -- Reward Order System
    self.KaosOrderSystem:Initialize()
    -- Magic sealing platform system
    self.FengMoTaiSystem:Initialize()
    -- Demon Soul System
    self.DevilSoulSystem:Initialize()
    -- Home Mission System
    self.HomeTaskSystem:Initialize()
    -- Perfect love system
    self.PrefectRomanceSystem:Initialize()
    -- NPC friend system
    self.NPCFriendSystem:Initialize()
    -- Home Personal Information Message Board
    self.CommunityMsgSystem:Initialize()
    -- Home Decoration Competition
    self.DecorateSystem:Initialize()
    -- Custom avatar change system
    self.CustomChangeHeadSystem:Initialize()
    -- Zero Yuan Purchase System
    self.ZeroBuySystem:Initialize()
    -- Today's Event System
    self.TodayFuncSystem:Initialize()
    -- Fairy Couple Showdown
    self.LoversFightSystem:Initialize()
    -- Magic installation system
    self.UnrealEquipSystem:Initialize()
    -- The Immortal Alliance Fights for Hegemony
    self.XMZhengBaSystem:Initialize()
    -- Prison
    self.PrisonSystem:Initialize()

    -- local _t4 = os.clock();
    self.IsLogicInit = true

    -- Debug.Log("====================== CSLogicInitialize require CS",_t2-_t1)
    -- Debug.Log("====================== CSLogicInitialize require Lua",_t3-_t2)
    -- Debug.Log("====================== CSLogicInitialize Initialize()",_t4-_t3)
end

-- Logical system uninstallation
function GameCenter:LogicUninitialize(clearLoginData)
    if not self.IsLogicInit then
        return
    end
    self.FlySwordGraveSystem = nil
    Utils.RemoveRequiredByName("Logic.FlySoward.FlySwordGraveSystem")
    -- New equipment system
    self.NewEquipmentSystem = nil
    Utils.RemoveRequiredByName("Logic.Item.NewEquipmentSystem")
    -- New item management system
    self.NewItemContianerSystem = nil
    Utils.RemoveRequiredByName("Logic.Item.NewItemContianerSystem")
    -- Message prompt system
    self.MsgPromptSystem = nil
    Utils.RemoveRequiredByName("Logic.MsgPrompt.MsgPromptSystem")
    -- System of creation
    self.NatureSystem:UnInitialize()
    self.NatureSystem = nil
    Utils.RemoveRequiredByName("Logic.Nature.NatureSystem")

    self.FlySowardSystem:UnInitialize()
    self.FlySowardSystem = nil
    Utils.RemoveRequiredByName("Logic.FlySoward.FlySowardSystem")

    -- Replica system
    self.CopyMapSystem:UnInitialize()
    self.CopyMapSystem = nil
    Utils.RemoveRequiredByName("Logic.CopyMapSystem.CopyMapSystem")
    -- Daily activities system
    self.DailyActivitySystem:UnInitialize()
    self.DailyActivitySystem = nil
    Utils.RemoveRequiredByName("Logic.DailyActivity.DailyActivitySystem")
    -- Offline hang-up system
    self.OfflineOnHookSystem:UnInitialize()
    self.OfflineOnHookSystem = nil
    Utils.RemoveRequiredByName("Logic.OfflineOnHook.OfflineOnHookSystem")
    -- Refining forging system
    self.LianQiForgeSystem:UnInitialize()
    self.LianQiForgeSystem = nil
    Utils.RemoveRequiredByName("Logic.LianQiForge.LianQiForgeSystem")
    -- Refining forging bag system
    self.LianQiForgeBagSystem:UnInitialize()
    self.LianQiForgeBagSystem = nil
    Utils.RemoveRequiredByName("Logic.LianQiForge.LianQiForgeBagSystem")
    -- Refining gem system
    self.LianQiGemSystem:UnInitialize()
    self.LianQiGemSystem = nil
    Utils.RemoveRequiredByName("Logic.LianQiGem.LianQiGemSystem")
    -- Heavenly Book System
    self.GodBookSystem:UnInitialize()
    self.GodBookSystem = nil
    Utils.RemoveRequiredByName("Logic.GodBook.GodBookSystem")
    -- Sea of consciousness system
    self.PlayerShiHaiSystem = nil
    Utils.RemoveRequiredByName("Logic.PlayerShiHai.PlayerShiHaiSystem")
    -- Sectarian Skill System
    self.FactionSkillSystem:UnInitialize()
    self.FactionSkillSystem = nil
    Utils.RemoveRequiredByName("Logic.FactionSkill.FactionSkillSystem")

    -- Feedback System
    self.FeedBackSystem:UnInitialize();
    self.FeedBackSystem = nil;
    Utils.RemoveRequiredByName("Logic.FeedBack.FeedBackSystem");

    -- Achievement System
    self.AchievementSystem:UnInitialize()
    self.AchievementSystem = nil;
    Utils.RemoveRequiredByName("Logic.Achievement.AchievementSystem")

    self.FriendSystem:UnInitialize()
    self.FriendSystem = nil;
    Utils.RemoveRequiredByName("Logic.Friend.FriendsSystem")

    -- BossSystem
    self.BossSystem:UnInitialize()
    self.BossSystem = nil
    Utils.RemoveRequiredByName("Logic.Boss.BossSystem")
    self.MountBossSystem:UnInitialize()
    self.MountBossSystem = nil
    Utils.RemoveRequiredByName("Logic.Boss.MountBossSystem")
    self.SlayerBossSystem:UnInitialize()
    self.SlayerBossSystem = nil
    Utils.RemoveRequiredByName("Logic.Boss.SlayerBossSystem")

    -- Marriage system
    self.MarriageSystem:UnInitialize()
    self.MarriageSystem = nil
    Utils.RemoveRequiredByName("Logic.Marriage.MarriageSystem")

    -- Chief Arena System
    self.ArenaShouXiSystem:UnInitialize()
    self.ArenaShouXiSystem = nil
    Utils.RemoveRequiredByName("Logic.Arena.ArenaShouXiSystem")

    -- Go to the BOSS location system
    self.BossInfoTipsSystem = nil
    Utils.RemoveRequiredByName("Logic.BossInfoTips.BossInfoTipsSystem")

    -- Email system
    self.MailSystem:UnInitialize()
    self.MailSystem = nil
    Utils.RemoveRequiredByName("Logic.Mail.MailSystem")

    -- Set system
    self.EquipmentSuitSystem:UnInitialize()
    self.EquipmentSuitSystem = nil
    Utils.RemoveRequiredByName("Logic.EquipmentSuit.EquipmentSuitSystem")

    -- Title system
    self.RoleTitleSystem:UnInitialize()
    self.RoleTitleSystem = nil
    Utils.RemoveRequiredByName("Logic.RoleTitle.RoleTitleSystem")

    -- Pet system
    self.PetSystem:UnInitialize()
    self.PetSystem = nil
    Utils.RemoveRequiredByName("Logic.Pet.PetSystem")

    -- Welfare system
    self.WelfareSystem:UnInitialize()
    self.WelfareSystem = nil
    Utils.RemoveRequiredByName("Logic.Welfare.WelfareSystem")

    -- Mall System
    self.ShopSystem:UnInitialize()
    self.ShopSystem = nil
    Utils.RemoveRequiredByName("Logic.Shop.ShopManager")

    -- Shop Orb System
    self.ShopSpecialSystem:UnInitialize()
    self.ShopSpecialSystem = nil
    Utils.RemoveRequiredByName("Logic.ShopSpecial.ShopSpecialSystem")

    -- Daily recharge
    self.DailyRechargeSystem:UnInitialize()
    self.DailyRechargeSystem = nil
    Utils.RemoveRequiredByName("Logic.DailyRcharge.DailyRchargeSystem")

    -- Fairy Soul System
    self.XianPoSystem:UnInitialize()
    self.XianPoSystem = nil
    Utils.RemoveRequiredByName("Logic.XianPo.XianPoSystem")

    -- Treasure Hunt System
    self.TreasureHuntSystem:UnInitialize()
    self.TreasureHuntSystem = nil
    Utils.RemoveRequiredByName("Logic.TreasureHunt.TreasureHuntSystem")

    -- Immortal Armor Treasure Hunt
    self.XJXunbaoSystem:UnInitialize()
    self.XJXunbaoSystem = nil
    Utils.RemoveRequiredByName("Logic.TreasureHunt.XJXunbaoSystem")

    -- Service opening activities
    self.ServerActiveSystem:UnInitialize()
    self.ServerActiveSystem = nil
    Utils.RemoveRequiredByName("Logic.ServerActive.ServerActiveSystem")

    -- First charge system
    self.FristChargeSystem:UnInitialize()
    self.FristChargeSystem = nil
    Utils.RemoveRequiredByName("Logic.FristCharge.FristChargeSystem")

    -- Trading bank
    self.ShopAuctionSystem:UnInitialize()
    self.ShopAuctionSystem = nil
    Utils.RemoveRequiredByName("Logic.ShopAuction.ShopAuctionSystem")

    -- World Question Answer
    self.WorldAnswerSystem:UnInitialize()
    self.WorldAnswerSystem = nil
    Utils.RemoveRequiredByName("Logic.WorldAnswer.WorldAnswerSystem")

    -- Guarding the Sect
    self.GuardianFactionSystem:UnInitialize()
    self.GuardianFactionSystem = nil
    Utils.RemoveRequiredByName("Logic.GuardianFaction.GuardianFactionSystem")

    -- The Island of the Divine Beast
    self.SoulMonsterSystem:UnInitialize()
    self.SoulMonsterSystem = nil
    Utils.RemoveRequiredByName("Logic.SoulMonster.SoulMonsterSystem")

    -- Realm BOSS
    self.StatureBossSystem:UnInitialize()
    self.StatureBossSystem = nil
    Utils.RemoveRequiredByName("Logic.StatureBoss.StatureBossSystem")

    -- Small dialog box for monologue
    self.SoliloquySystem:UnInitialize()
    self.SoliloquySystem = nil
    Utils.RemoveRequiredByName("Logic.Soliloquy.SoliloquySystem")

    -- Territory War
    self.TerritorialWarSystem:UnInitialize()
    self.TerritorialWarSystem = nil
    Utils.RemoveRequiredByName("Logic.TerritorialWar.TerritorialWarSystem")

    -- bonfire
    self.BonfireActivitySystem:UnInitialize()
    self.BonfireActivitySystem = nil
    Utils.RemoveRequiredByName("Logic.BonfireActivitySystem.BonfireActivitySystem")

    -- Blessed land
    self.FuDiSystem:UnInitialize()
    self.FuDiSystem = nil
    Utils.RemoveRequiredByName("Logic.FuDi.FuDiSystem")

    -- ranking
    self.RankSystem = nil
    Utils.RemoveRequiredByName("Logic.Rank.RankSystem")

    -- Eight-pole array diagram
    self.BaJiZhenSystem = nil
    Utils.RemoveRequiredByName("Logic.BaJiZhen.BaJiZhenSystem")

    -- Spiritual body
    self.LingTiSystem:UnInitialize()
    self.LingTiSystem = nil
    Utils.RemoveRequiredByName("Logic.LingTi.LingTiSystem")

    -- Spiritual body
    self.ChuanDaoSystem:UnInitialize()
    self.ChuanDaoSystem = nil
    Utils.RemoveRequiredByName("Logic.ChuanDao.ChuanDaoSystem")

    -- Hall of Fame
    self.CelebritySystem:UnInitialize()
    self.CelebritySystem = nil
    Utils.RemoveRequiredByName("Logic.Celebrity.CelebritySystem")

    -- The leader seeks help
    self.WorldSupportSystem:UnInitialize()
    self.WorldSupportSystem = nil
    Utils.RemoveRequiredByName("Logic.WorldSupport.WorldSupportSystem")

    -- vip
    self.VipSystem:UnInitialize()
    self.VipSystem = nil
    Utils.RemoveRequiredByName("Logic.VipSystem.VipSystem")

    -- Vip Zhou Chang
    self.ZhouChangSystem:UnInitialize()
    self.ZhouChangSystem = nil
    Utils.RemoveRequiredByName("Logic.VipZhouChang.ZhouChangSystem")

    -- Robot chat system
    self.RobotChatSystem:UnInitialize()
    self.RobotChatSystem = nil
    Utils.RemoveRequiredByName("Logic.RobotChat.RobotChatSystem")

    -- Resource Retrieval
    self.ResBackSystem:UnInitialize()
    self.ResBackSystem = nil
    Utils.RemoveRequiredByName("Logic.ResBack.ResBackSystem")

    -- Marrow washing system
    self.RealmXiSuiSystem:UnInitialize()
    self.RealmXiSuiSystem = nil
    Utils.RemoveRequiredByName("Logic.RealmXiSui.RealmXiSuiSystem")

    -- Limited time purchase
    self.LimitShopSystem:UnInitialize()
    self.LimitShopSystem = nil
    Utils.RemoveRequiredByName("Logic.LimitShop.LimitShopSystem")

    -- Immortal Alliance Battle
    self.XmFightSystem:UnInitialize()
    self.XmFightSystem = nil
    Utils.RemoveRequiredByName("Logic.XmFight.XmFightSystem")

    -- Immortal Alliance Boss
    self.XMBossSystem:UnInitialize()
    self.XMBossSystem = nil
    Utils.RemoveRequiredByName("Logic.XMBoss.XMBossSystem")

    -- Immortal Alliance Boss
    self.RealmStifleSystem:UnInitialize()
    self.RealmStifleSystem = nil
    Utils.RemoveRequiredByName("Logic.RealmStifle.RealmStifleSystem")

    -- Map system
    self.MapSystem:UnInitialize()
    self.MapSystem = nil
    Utils.RemoveRequiredByName("Logic.Map.MapSystem")

    -- Model display interface
    self.ModelViewSystem:UnInitialize()
    self.ModelViewSystem = nil
    Utils.RemoveRequiredByName("Logic.ModelView.ModelViewSystem")

    -- Cross-Server Event Display Map
    self.CrossServerMapSystem:UnInitialize()
    self.CrossServerMapSystem = nil
    Utils.RemoveRequiredByName("Logic.CrossServerMap.CrossServerMapSystem")

    -- Functional preview system
    self.FunctionNoticeSystem:UnInitialize()
    self.FunctionNoticeSystem = nil
    Utils.RemoveRequiredByName("Logic.FunctionNotice.FunctionNoticeSystem")

    -- Mysterious store
    self.MysteryShopSystem:UnInitialize()
    self.MysteryShopSystem = nil
    Utils.RemoveRequiredByName("Logic.MysteryShopSystem.MysteryShopSystem")

    -- Transfer system
    self.ChangeJobSystem:UnInitialize()
    self.ChangeJobSystem = nil
    Utils.RemoveRequiredByName("Logic.ChangeJob.ChangeJobSystem")

    -- New server activities
    self.NewServerActivitySystem:UnInitialize()
    self.NewServerActivitySystem = nil
    Utils.RemoveRequiredByName("Logic.NewServerActivity.NewServerActivitySystem")

    -- Gift gift activities
    self.PresentSystem:UnInitialize()
    self.PresentSystem = nil
    Utils.RemoveRequiredByName("Logic.Present.PresentSystem")

    self.LimitDicretShopMgr:UnInitialize()
    self.LimitDicretShopMgr = nil
    Utils.RemoveRequiredByName("Logic.Shop.LimitDicretShopMgr")
    self.LimitDicretShopMgr2:UnInitialize()
    self.LimitDicretShopMgr2 = nil
    Utils.RemoveRequiredByName("Logic.Shop.LimitDicretShopMgr2")

    self.YYHDSystem:UnInitialize()
    self.YYHDSystem = nil
    Utils.RemoveRequiredByName("Logic.YYHD.YYHDSystem")

    self.SkipSystem = nil
    Utils.RemoveRequiredByName("Logic.Skip.SkipSystem")

    -- Blind date wall
    self.MarryDatingWallSystem:UnInitialize()
    self.MarryDatingWallSystem = nil
    Utils.RemoveRequiredByName("Logic.MarryDatingWall.MarryDatingWallSystem")

    -- Weekly benefits lottery
    self.LuckyDrawWeekSystem:UnInitialize()
    self.LuckyDrawWeekSystem = nil
    Utils.RemoveRequiredByName("Logic.LuckyDrawWeek.LuckyDrawWeekSystem")

    -- Fashion
    self.NewFashionSystem:UnInitialize()
    self.NewFashionSystem = nil
    Utils.RemoveRequiredByName("Logic.NewFashion.NewFashionSystem")

    -- Saturday Carnival
    self.WeekCrazySystem = nil
    Utils.RemoveRequiredByName("Logic.WeekCrazy.WeekCrazySystem")

    -- Collection Pavilion
    self.ZhenCangGeSystem = nil
    Utils.RemoveRequiredByName("Logic.ZhenCangGeSystem.ZhenCangGeSystem")

    -- Skill system lua end logic
    self.PlayerSkillLuaSystem:UnInitialize()
    self.PlayerSkillLuaSystem = nil
    Utils.RemoveRequiredByName("Logic.PlayerSkill.PlayerSkillLuaSystem")

    -- Peak competition
    self.TopJjcSystem:UnInitialize()
    self.TopJjcSystem = nil
    Utils.RemoveRequiredByName("Logic.TopJjc.TopJjcSystem")

    -- HuSong
    self.HuSongSystem:UnInitialize()
    self.HuSongSystem = nil
    Utils.RemoveRequiredByName("Logic.HuSong.HuSongSystem")

    -- Escort
    self.EscortSystem:UnInitialize()
    self.EscortSystem = nil
    Utils.RemoveRequiredByName("Logic.Escort.EscortSystem")

    -- share
    self.ShareAndLikeSystem:UnInitialize();
    self.ShareAndLikeSystem = nil
    Utils.RemoveRequiredByName("Logic.ShareAndLike.ShareAndLike")

    -- Main interface limited time icon
    self.MainLimitIconSystem:UnInitialize();
    self.MainLimitIconSystem = nil
    Utils.RemoveRequiredByName("Logic.MainLimitIcon.MainLimitIconSystem")

    -- Daily activity reminder system
    self.DailyActivityTipsSystem:UnInitialize();
    self.DailyActivityTipsSystem = nil
    Utils.RemoveRequiredByName("Logic.DailyActivityTips.DailyActivityTipsSystem")

    -- Lucky flop
    self.LuckyCardSystem:UnInitialize();
    self.LuckyCardSystem = nil
    Utils.RemoveRequiredByName("Logic.LuckyCard.LuckyCardSystem")

    -- Pet equipment
    self.PetEquipSystem:UnInitialize();
    self.PetEquipSystem = nil
    Utils.RemoveRequiredByName("Logic.Pet.PetEquipSystem")

    -- Mount Equipment
    self.MountEquipSystem:UnInitialize();
    self.MountEquipSystem = nil
    Utils.RemoveRequiredByName("Logic.MountEquip.MountEquipSystem")

    -- Heavenly ban order
    self.TianJinLingSystem:UnInitialize();
    self.TianJinLingSystem = nil
    Utils.RemoveRequiredByName("Logic.TianJinLing.TianJinLingSystem")

    -- Full-level reminder
    self.FullLevelTipsSystem:UnInitialize()
    self.FullLevelTipsSystem = nil
    Utils.RemoveRequiredByName("Logic.FullLevelTips.FullLevelTipsSystem")

    -- Immortal Cultivation Treasure Mirror
    self.RankAwardSystem:UnInitialize()
    self.RankAwardSystem = nil
    Utils.RemoveRequiredByName("Logic.RankAward.RankAwardSystem")

    -- Soul Armor
    self.SoulEquipSystem:UnInitialize()
    self.SoulEquipSystem = nil
    Utils.RemoveRequiredByName("Logic.SoulEquip.SoulEquipSystem")

    -- Opening a server carnival
    self.ServeCrazySystem:UnInitialize()
    self.ServeCrazySystem = nil
    Utils.RemoveRequiredByName("Logic.ServeCrazy.ServeCrazySystem")

    -- Cross-server blessed place
    self.CrossFuDiSystem:UnInitialize()
    self.CrossFuDiSystem = nil
    Utils.RemoveRequiredByName("Logic.CrossFuDi.CrossFuDiSystem")

    -- Digital input
    self.NumberInputSystem = nil
    Utils.RemoveRequiredByName("Logic.NumberInput.NumberInputSystem")

    -- Meditation system
    self.SitDownSystem = nil
    Utils.RemoveRequiredByName("Logic.SitDown.SitDownSystem")

    -- Background texture management required for loading form
    self.LoadingTextureManager:UnInitialize();
    self.LoadingTextureManager = nil;
    Utils.RemoveRequiredByName("Logic.Loading.LoadingTextureManager")

    -- New item display system
    self.GetNewItemSystem:UnInitialize();
    self.GetNewItemSystem = nil
    Utils.RemoveRequiredByName("Logic.GetNewItemSystem.GetNewItemSystem")

    -- Quick item acquisition system
    self.ItemQuickGetSystem:UnInitialize();
    self.ItemQuickGetSystem = nil
    Utils.RemoveRequiredByName("Logic.ItemQuickGetSystem.ItemQuickGetSystem")

    self.ItemTipsMgr = nil
    Utils.RemoveRequiredByName("Logic.Item.ItemTipsMgr")

    -- Auction house
    self.AuctionHouseSystem:UnInitialize();
    self.AuctionHouseSystem = nil
    Utils.RemoveRequiredByName("Logic.AuctionHouse.AuctionHouseSystem")

    -- Custom button system
    self.MainCustomBtnSystem:UnInitialize();
    self.MainCustomBtnSystem = nil
    Utils.RemoveRequiredByName("Logic.MainCustomBtnSystem.MainCustomBtnSystem")

    -- Announcement system
    self.NoticeSystem:UnInitialize()
    self.NoticeSystem = nil
    Utils.RemoveRequiredByName("Logic.Notice.NoticeSystem")

    -- Divine beast
    self.MonsterSoulSystem:UnInitialize()
    self.MonsterSoulSystem = nil
    Utils.RemoveRequiredByName("Logic.MonsterSoul.MonsterSoulSystem")

    -- Immortal Alliance
    self.GuildSystem:UnInitialize();
    self.GuildSystem = nil
    Utils.RemoveRequiredByName("Logic.Guild.GuildSystem")

    --Gosu SDK Event
    self.GosuEventSystem:UnInitialize()
    self.GosuEventSystem = nil
    Utils.RemoveRequiredByName("Logic.GosuEvent.GosuEventSystem")

    -- Jianlingge hanging system
    self.SwordMandateSystem:UnInitialize();
    self.SwordMandateSystem = nil
    Utils.RemoveRequiredByName("Logic.SwordMandate.SwordMandateSystem")

    -- Spirit stone acquisition system
    self.BigBoomSystem:UnInitialize();
    self.BigBoomSystem = nil
    Utils.RemoveRequiredByName("Logic.BigBoomSystem.BigBoomSystem")

    -- lua role system
    self.LuaCharacterSystem:UnInitialize();
    self.LuaCharacterSystem = nil
    Utils.RemoveRequiredByName("Logic.LuaCharacter.LuaCharacterSystem")

    -- Home Decoration Competition
    self.DecorateSystem:UnInitialize();
    self.DecorateSystem = nil
    Utils.RemoveRequiredByName("Logic.Decorate.DecorateSystem")

    -- Loading the form system
    self.LoadingSystem = nil
    Utils.RemoveRequiredByName("Logic.Loading.LoadingSystem")

    -- Custom avatar change system
    self.CustomChangeHeadSystem:UnInitialize()
    self.CustomChangeHeadSystem = nil
    Utils.RemoveRequiredByName("Logic.CustomChangeHeadSystem.CustomChangeHeadSystem")

    -- Zero Yuan Purchase System
    self.ZeroBuySystem:UnInitialize()
    self.ZeroBuySystem = nil
    Utils.RemoveRequiredByName("Logic.ZeroBuy.ZeroBuySystem")

    self.PlayerRoleListSystem:UnInitialize(clearLoginData);
    self.LoginSystem:UnInitialize(clearLoginData);
    self.ServerListSystem:UnInitialize(clearLoginData);
    self.PaySystem:UnInitialize(clearLoginData)

    if clearLoginData then
        Debug.Log("After cleaning up the login data, uninstall all data!");
        -- Player character list
        self.PlayerRoleListSystem = nil
        Utils.RemoveRequiredByName("Logic.PlayerRoleList.PlayerRoleListSystem");
        -- Log in to the system
        self.LoginSystem = nil;
        Utils.RemoveRequiredByName("Logic.Login.LoginSystem");

        -- Server list
        self.ServerListSystem = nil;
        Utils.RemoveRequiredByName("Logic.ServerList.ServerListSystem")

        -- Recharge system
        self.PaySystem = nil
        Utils.RemoveRequiredByName("Logic.PaySystem.PaySystem")
    end

    -- Player display system
    self.PlayerVisualSystem:UnInitialize();
    self.PlayerVisualSystem = nil;
    Utils.RemoveRequiredByName("Logic.Entity.Character.Player.PlayerVisualSystem")

    -- Team system
    self.TeamSystem = nil
    Utils.RemoveRequiredByName("Logic.Team.TeamSystem")

    -- Target system
    self.TargetSystem = nil
    Utils.RemoveRequiredByName("Logic.TargetSystem.TargetSystem")

    -- Holy installation system
    self.HolyEquipSystem:UnInitialize()
    self.HolyEquipSystem = nil
    Utils.RemoveRequiredByName("Logic.HolyEquip.HolyEquipSystem")

    -- Skill System
    self.PlayerSkillSystem:UnInitialize()
    self.PlayerSkillSystem = nil
    Utils.RemoveRequiredByName("Logic.PlayerSkill.PlayerSkillSystem")

    -- Player Stat System
    self.PlayerStatSystem:UnInitialize()
    self.PlayerStatSystem = nil
    Utils.RemoveRequiredByName("Logic.PlayerStat.PlayerStatSystem")

    -- Hang-up system
    self.MandateSystem:UnInitialize()
    self.MandateSystem = nil
    Utils.RemoveRequiredByName("Logic.Mandate.MandateSystem")

    -- Action Manager
    self.AnimManager = nil
    Utils.RemoveRequiredByName("Logic.AnimManager.AnimManager")

    -- Task system
    self.LuaTaskManager:UnInitialization()
    self.TaskManagerMsg:UnInitialize()
    self.LuaTaskManager = nil
    self.TaskManagerMsg = nil
    self.TaskController = nil
    Utils.RemoveRequiredByName("Logic.TaskSystem.Manager.LuaTaskManager")
    Utils.RemoveRequiredByName("Logic.TaskSystem.Manager.TaskManagerMsg")
    Utils.RemoveRequiredByName("Logic.TaskSystem.Manager.TaskController")

    -- Boot system
    self.GuideSystem:UnInitialize()
    self.GuideSystem = nil
    Utils.RemoveRequiredByName("Logic.GuideSystem.GuideSystem")

    -- Blocking the system
    self.BlockingUpPromptSystem:UnInitialize()
    self.BlockingUpPromptSystem = nil
    Utils.RemoveRequiredByName("Logic.BlockingUpPrompt.BlockingUpPromptSystem")

    self.KaosOrderSystem:UnInitialize()
    self.KaosOrderSystem = nil
    Utils.RemoveRequiredByName("Logic.KaosOrderBaseSystem.KaosOrderSystem")

    self.FengMoTaiSystem:UnInitialize()
    self.FengMoTaiSystem = nil
    Utils.RemoveRequiredByName("Logic.FengMoTaiSystem.FengMoTaiSystem")

    -- Demon Soul System
    self.DevilSoulSystem:UnInitialize()
    self.DevilSoulSystem = nil
    Utils.RemoveRequiredByName("Logic.DevilSoul.DevilSoulSystem")

    -- The road to growth
    self.GrowthWaySystem:UnInitialize()
    self.GrowthWaySystem = nil
    Utils.RemoveRequiredByName("Logic.GrowthWay.GrowthWaySystem")

    self.UISceneManager = nil
    Utils.RemoveRequiredByName("Logic.UIScene.UISceneManager")

    -- Home Mission
    self.HomeTaskSystem:UnInitialize()
    self.HomeTaskSystem = nil
    Utils.RemoveRequiredByName("Logic.HomeTaskSystem.HomeTaskSystem")

    -- Perfect love
    self.PrefectRomanceSystem:UnInitialize()
    self.PrefectRomanceSystem = nil
    Utils.RemoveRequiredByName("Logic.PrefectRomance.PrefectRomanceSystem")

    -- NPC friend system
    self.NPCFriendSystem:UnInitialize()
    self.NPCFriendSystem = nil
    Utils.RemoveRequiredByName("Logic.Friend.NPCFriendSystem")

    -- Home Personal Information Message Board
    self.CommunityMsgSystem:UnInitialize()
    self.CommunityMsgSystem = nil
    Utils.RemoveRequiredByName("Logic.CommunityMsg.CommunityMsgSystem")

    -- Today's Event System
    self.TodayFuncSystem:UnInitialize()
    self.TodayFuncSystem = nil
    Utils.RemoveRequiredByName("Logic.TodayFunc.TodayFuncSystem")

    -- Fairy Couple Showdown
    self.LoversFightSystem:UnInitialize()
    self.LoversFightSystem = nil
    Utils.RemoveRequiredByName("Logic.LoversFight.LoversFightSystem")

    -- Magic installation system
    self.UnrealEquipSystem:UnInitialize()
    self.UnrealEquipSystem = nil
    Utils.RemoveRequiredByName("Logic.UnrealEquip.UnrealEquipSystem")

    -- The Immortal Alliance Fights for Hegemony
    self.XMZhengBaSystem:UnInitialize()
    self.XMZhengBaSystem = nil
    Utils.RemoveRequiredByName("Logic.XMZhengBa.XMZhengBaSystem")

    -- Prison
    self.PrisonSystem:UnInitialize()
    self.PrisonSystem = nil
    Utils.RemoveRequiredByName("Logic.Prison.PrisonSystem")

    self.IsLogicInit = false
    -- Remove all events defined by Lua
    LuaEventManager.ClearAllLuaEvents();
end

function GameCenter:ReInitialize()
    self.NatureSystem:UnInitialize()
    self.NatureSystem = nil
    Utils.RemoveRequiredByName("Logic.Nature.NatureSystem")

    self.NatureSystem = require("Logic.Nature.NatureSystem")
    self.NatureSystem:Initialize()

    self.LoadingTextureManager:UnInitialize();
    self.LoadingTextureManager = nil;
    Utils.RemoveRequiredByName("Logic.Loading.LoadingTextureManager")

    self.LoadingTextureManager = require("Logic.Loading.LoadingTextureManager")
    self.LoadingTextureManager:Initialize()
end

-- Update heartbeat refresh every frame
function GameCenter:Update(deltaTime)
    -- Debug.Log("============[Update]================",deltaTime)
    if self.IsCoreInit then
        self.UIFormManager:Update(deltaTime);
        -- self.AIManager:Update(deltaTime);
        -- self.TexHttpSyncSystem:Update(deltaTime);
    end
    if self.IsLogicInit then
        self.MapLogicSystem:Update(deltaTime)
        self.BonfireActivitySystem:Update(deltaTime)
        self.ArenaShouXiSystem:Update(deltaTime)
        self.FunctionNoticeSystem:Update(deltaTime)
        self.YYHDSystem:Update()
        self.ShareAndLikeSystem:Update()
        self.MainLimitIconSystem:Update()
        self.PetEquipSystem:Update(deltaTime)
        self.MountEquipSystem:Update(deltaTime)
        self.CrossFuDiSystem:Update(deltaTime)
        self.SwordMandateSystem:Update()
        self.ModelViewSystem:Update(deltaTime)
        self.LuaCharacterSystem:Update(deltaTime)
        self.TeamSystem:Update(deltaTime)
        self.LuaMainFunctionSystem:Update(deltaTime)
        self.MandateSystem:Update(deltaTime)
        self.LoginSystem:Update(deltaTime);
        self.LuaTaskManager:Update(deltaTime)
        self.TaskController:Update(deltaTime)
        self.BlockingUpPromptSystem:Update(deltaTime)
        self.UISceneManager:Update(deltaTime)
        self.DevilSoulSystem:Update(deltaTime)
        self.LoversFightSystem:Update(deltaTime)
    end
end

-- Update heartbeat 5 frames once
function GameCenter:FrameUpdate(deltaTime)
    self.FrameCount = self.FrameCount + 1
    self.DeltaTime = self.DeltaTime + deltaTime
    if self.FrameCount >= 5 then
        if self.IsLogicInit then
            self.GuildSystem:Update(self.DeltaTime)
            self.MonsterSoulSystem:Update(self.DeltaTime)
            self.TopJjcSystem:Update(self.DeltaTime)
            self.LimitDicretShopMgr:Update(self.DeltaTime)
            self.LimitDicretShopMgr2:Update(self.DeltaTime)
            self.BossSystem:Update(self.DeltaTime)
            self.MountBossSystem:Update(self.DeltaTime)
            self.SlayerBossSystem:Update(self.DeltaTime)
            self.EquipmentSuitSystem:Update(self.DeltaTime)
            self.DailyActivitySystem:Update(self.DeltaTime)
            self.TerritorialWarSystem:Update(self.DeltaTime)
            self.MarriageSystem:Update(self.DeltaTime)
            self.RobotChatSystem:Update(self.DeltaTime)
            self.LingTiSystem:Update(self.DeltaTime)
            self.FuDiSystem:Update(self.DeltaTime) -- 0.07ms, optimization algorithm is required
            self.LimitShopSystem:Update(self.DeltaTime)
            self.VipSystem:Update(self.DeltaTime)
            self.ChuanDaoSystem:Update(self.DeltaTime)
            self.GrowthWaySystem:Update(self.DeltaTime)
            self.WelfareSystem:Update()
            self.ServeCrazySystem:Update(self.DeltaTime)
            self.ChangeJobSystem:Update(self.DeltaTime)
            self.XianPoSystem:Update(self.DeltaTime)
            self.NewServerActivitySystem:Update(self.DeltaTime)
            self.DailyActivityTipsSystem:Update()
            self.SoulEquipSystem:Update()
            self.GetNewItemSystem:Update(self.DeltaTime)
            self.AuctionHouseSystem:Update(self.DeltaTime)
            self.MainCustomBtnSystem:Update(self.DeltaTime)
            -- Skill system update
            self.PlayerSkillSystem:Update(self.DeltaTime)
            self.FristChargeSystem:Update(self.DeltaTime)
            self.PrefectRomanceSystem:Update(self.DeltaTime)
            self.TreasureHuntSystem:Update(self.DeltaTime)
            self.NPCFriendSystem:Update(self.DeltaTime)
            self.HuSongSystem:Update(self.DeltaTime)
            self.UnrealEquipSystem:Update(self.DeltaTime)
            self.XMZhengBaSystem:Update(self.DeltaTime)
        end
        self.DeltaTime = 0
        self.FrameCount = 0
    end
end

function GameCenter.PushFixEvent(eventID, obj, sender)
    LuaEventManager.PushFixEvent(eventID, obj, sender);
end

function GameCenter.RegFixEventHandle(eventID, func, caller)
    LuaEventManager.RegFixEventHandle(eventID, func, caller);
end

function GameCenter.UnRegFixEventHandle(eventID, func, caller)
    LuaEventManager.UnRegFixEventHandle(eventID, func, caller);
end

return GameCenter
