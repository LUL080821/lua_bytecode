------------------------------------------------
-- Author:
-- Date: 2019-04-4
-- File: Enum.lua
-- Module: None
-- Description: Global enum, with Enum as suffix
------------------------------------------------
-- All types of c#
CSType = {
    Class    = 0, -- kind
    Enum     = 1, -- enumerate
    Struct   = 2, -- structure
    Delegate = 3, -- Entrustment
    Event    = 4 -- event
}

-- Map type definition
MapTypeDefine = {
    Login     = -1, -- Login scene
    World     = 0, -- World map
    Copy      = 1, -- Replica map
    Arena     = 2, -- Arena
    CrossCopy = 3, -- Cross-server copy
    PlaneCopy = 5 -- PlaneCopy
}

-- Map logic type definition
MapLogicTypeDefine = {
    None              = 0, -- No type
    WanYaoTa          = 1, -- Ten Thousand Demon Tower
    DaNengYiFu        = 2, -- The Great Relics of the House
    XianJieZhiMen     = 3, -- The Gate of the Immortal World
    PlaneCopy         = 4, -- Plane copy
    YZZDCopy          = 5, -- Top of the Brave Duel
    SZZQCopy          = 6, -- Duplica of the Holy War (Three Realms Battlefield)
    FuDiCopy          = 7, -- Copy of the Blessed Land of Sect
    FuDiDuoBaoCopy    = 8, -- Sects take treasures in blessed land
    ArenaShouXi       = 9, -- Chief Arena
    MySelfBossCopy    = 10, -- Personal BOSS copy
    WorldBossCopy     = 11, -- World BOSS copy
    LvDuPanelCopy     = 12, -- Green poison plane copy
    SkyDoorCopy       = 13, -- Copy of the Gate of Heaven
    ExpCopy           = 14, -- Copy of experience
    XinMoCopy         = 15, -- Demon copy
    WuXingCopy        = 16, -- Five Elements Copy
    GuardianFaction   = 17, -- Guarding the Sect
    MonsterLand       = 18, -- The Island of the Divine Beast
    RealmExpMap       = 19, -- Realm Practice Room
    StatureBossCopy   = 20, -- Realm BOSS
    ShanMen           = 21, -- Mountain Gate Logic
    WuXianBossCopy    = 22, -- Fake wireless layer copy
    DuJieCopy         = 23, -- Tribulation Copy
    CeShiCopy         = 24, -- Test Strength Copy
    TerritorialWar    = 25, -- Territory War
    MarryCopy         = 26, -- Wedding banquet
    BaJiZhenCopy      = 27, -- Baji Array Copy
    WorldBonfire      = 28, -- World Bonfire Copy
    BossHome          = 29, -- Boss House
    SuitGemCopy       = 30, -- Sets and Gem Boss
    ChuanDaoCopy      = 31, -- Master's teachings
    GuildTaskCopy     = 32, -- Guild Task Copy
    XmFight           = 33, -- Immortal Alliance Battle
    XMBoss            = 34, -- Immortal Alliance Boss
    WaoYaoJuanJieFeng = 35, -- Unsealed the Ten Thousand Demons
    NewComCopy        = 36, -- Wuji virtual domain novices layer
    ChangeJobCopy     = 37, -- Transfer performance plane
    SwordSoulCopy     = 38, -- Sword Ling Pavilion dungeon
    JZSLCopy          = 39, -- Sword Master Trial Duplicate
    MarryQingYuanCopy = 40, -- Love copy
    FirstFight        = 41, -- First battle
    TopJjc            = 42, -- Peak competition
    CrossFuDi         = 43, -- Cross-server blessed place
    CrossMonutCopy    = 44, -- Cross-server mount dungeon, ancient altar
    OyLieKai          = 45, -- Demon King's Rift
    SlayerMap         = 46, -- Demon Elimination Group
    XianFuHouse       = 47, -- Fairy House
    TopJjcWait        = 48, -- Peak Competition Waiting for Duplicate
    ChangeJobBos1     = 49, -- The first time the boss appears
    LoversFightWait   = 50, -- Fairy Couple Showdown Waiting for Duplicate
    LoversFightFight  = 51, -- Fairy Couple Battle Duel
    XuMiBaoKu         = 53, -- Sumeru Treasure Library
    CollectPlaneCopy  = 54, -- Collection Plane
    TrainBossCopy     = 55, -- Train BOSS Copy (From World BOSS copy)
    Escort            = 56, -- Escort copy
    Prison            = 57 -- Prison map logic
}

-- Replica type definition (temporary definition, modified later)
CopyMapTypeEnum = {
    ManyPeopleCopy   = 1, -- Multiple copy
    TowerCopy        = 2, -- Personal Challenge Copy
    ShouXiCopy       = 3, -- Chief copy
    MarriageCopy     = 4, -- Marriage copy
    BossHomeCopy     = 5, -- Boss Home
    PersonalBossCopy = 6, -- Personal boss
    DreamlandCopy    = 7, -- Fantasy boss
    SGZDCopy         = 8, -- Ancient battlefield
    YZZDCopy         = 9, -- The Brave's Conquest
    MonsterSoulCopy  = 10, -- Soul Beast Forest
    PlaneCopy        = 11, -- Plane copy
    GuildFuDiCopy    = 12, -- Blessed land of sects
    FuDiBaoZangCopy  = 13, -- Blessed treasures
    StarCopy         = 14, -- The Great Relics of the House, star-rated dungeon, how many stars can you get rewards
    SkyDoor          = 15 -- The Gate of Heaven
}

-- Copy Open Status Definition
CopyMapStateEnum = {
    NotOpen   = 0, -- Not enabled
    WaitFight = 1, -- Turn on Wait for entry
    Fighting  = 2 -- Start fighting
}

-- Copy main page definition
UICopyMainPanelEnum = {
    SinglePanel = 0, -- Single copy
    TeamPanel   = 1 -- Team dungeon
}

-- Single copy pagination definition
UISingleCopyPanelEnum = {
    TowerPanel = 0, -- Tower climbing copy
    StarPanel  = 1, -- Star Copy
    TJZMPanel  = 2, -- The Gate of Heaven
    ExpPanel   = 3 -- Copy of experience
}

-- Multi-person copy pagination definition
UIManyCopyPanelEnum = {
    XinMoPanel  = 0, -- Demon copy
    WuXingPanel = 1 -- Five Elements Copy
}

-- Used to distinguish the page types of creation panels, and use it as well as red dots
NatureEnum = {
    Begin    = 1,
    Mount    = 1, -- Mount
    Wing     = 2, -- wing
    Talisman = 3, -- magic weapon
    Magic    = 4, -- Formation
    Weapon   = 5, -- Divine Soldier
    FaBao    = 6, -- magic weapon
    FlySword = 7, -- Flying sword
    Pet      = 8, -- pet
    Count    = 8
}

NatureTaskEnum = {
    Begin       = 1,
    TaskFollow  = 11, -- Task NPC follows
    TaskEquip   = 12, -- Task NPC equips
    Count       = 2
}

-- Used to distinguish the paging types of the Divine Soldier panel, and use it as well as red dots.
GodWeaponEnum = {
    Begin   = 1,
    Equip   = 1, -- assembly
    Preview = 2, -- Preview
    Count   = 2
}

-- Used to distinguish the paging types of the Divine Soldier panel, and use it as well as red dots.
GodWeaponSubEnum = {
    Begin = 1,
    Head  = 1, -- head
    Body  = 2, -- body
    VFX   = 3, -- Special effects parts
    Count = 3
}
-- Used to distinguish subtypes in the page of the Creation Panel, and use it as well as red dots.
NatureSubEnum = {
    Begin         = 1,
    BaseUpLevel   = 1, -- Basic upgrade interface
    Drug          = 2, -- Second page: Eat pill or break through
    Fashionable   = 3, -- Fashion
    MountEatEquip = 4, -- Mount eating equipment
    Count         = 4
}

-- Used to distinguish subtypes in the mount panel page, and use it as well as red dots
MountEnum = {
    Begin      = 1,
    BaseGrowUp = 1, -- Basic upgrade interface
    HighGrowUp = 2, -- Advanced growth is not available yet
    Count      = 2
}

-- Used for fashion type distinction
FashionEnum = {
    Begin     = 0,
    Body      = 0, -- Fashion Clothes
    Theme     = 1, -- theme
    Head      = 2, -- avatar
    HeadFrame = 3, -- Avatar frame
    ChatBg    = 4, -- Chat background bubbles
    BuChen    = 5, -- Buchen
    Count     = 5
}

-- Backpack function enumeration
BagFormSubEnum = {
    Bag      = 0, -- --Backpack
    Store    = 1, -- --storehouse
    Synth    = 2, -- --synthesis
    EquipSyn = 3 -- Combined installation
}

-- Types of daily activities
ActivityTypeEnum = {
    None  = 0,
    Daily = 1, -- daily
    Limit = 2 -- Limited time
}

-- Daily panel pagination
ActivityPanelTypeEnum = {
    Daily      = 1, -- daily
    Limit      = 2, -- Limited time
    Target     = 3,
    Week       = 4, -- Weekly calendar
    Push       = 5, -- Push
    ResGetBack = 6, -- Resource Retrieval
    CrossShow  = 7, -- Cross-server display
    Active     = 8 -- Activity
}

-- Daily activity status
ActivityState = {
    -- Function not enabled
    NotInSpecialDay    = 1, -- There is a special opening time, but not within the opening time
    UnreachedOpenDay   = 2, -- The minimum number of days of service opening has not been reached
    UnreachedLevel     = 3, -- Not reached the level
    Unopen             = 4, -- Special conditions not met
    -- Function is enabled
    CanJoin            = 5, -- Open, can be participated
    CompleteCanBuy     = 6, -- Used up, can be purchased
    CompleteNoBuyCount = 7 -- Completed No purchases available
}

-- First-level paging of refining tools
LianQiSubEnum = {
    Begin    = 1,
    UpGrade  = 1, -- CH
    Forge    = 2, -- forging
    Gem      = 3, -- gem
    Suit     = 4, -- Set
    GodEquip = 5, -- Divine outfit
    Count    = 5,
}

-- Refining tools, forging pages
-- LianQiForgeSubEnum = {
--     Begin    = 1,
--     Strength = 3, -- Equipment enhancement
--     Wash     = 2, -- Equipment refining
--     Synth    = 1, -- synthesis
--     Count    = 3
-- }
LianQiForgeSubEnum = {
    Begin    = 1,
    Wash     = 1, -- Equipment refining
    Count    = 1
}

--Upgrade: add new
LianQiForgeUpgradeSubEnum = {
    Begin    = 1,
    Strength = 1, -- CH
    Transfer = 2, -- Chuyen ch
    Split    = 3, -- Tach ch
    Count    = 3
}

-- Refining weapons, gem pagination
LianQiGemSubEnum = {
    Begin  = 1,
    Inlay  = 1, -- Gem inlay
    Refine = 2, -- Gem Refining
    Jade   = 3, -- Fairy Jade Inlay
    Count  = 3
}

-- Refining weapons, magical installation paging
LianQiGodSubEnum = {
    Begin = 1,
    Star  = 1, -- Star Up
    LvUp  = 2, -- Upgrade
    Count = 2
}

-- Refining weapons, spiritual body paging
LianQiLingTiSubEnum = {
    Begin  = 1,
    Main   = 1, -- Main function of spirit body
    Synth  = 2, -- Spiritual equipment synthesis
    Star   = 3, -- Spirit Star
    Unlock = 4, -- Unblocking
    Count  = 4
}

-- Talisman mission status
AmuletTaskStatusEnum = {
    Available  = 1, -- Available
    UnFinished = 2, -- Not available
    RECEIVED   = 3 -- Received
}

-- The talisman value corresponds to the id of the Amulet table
AmuletEnum = {
    LuoFan  = 101, -- Falling the Flame Curse
    JiuXing = 201, -- Nine Stars Curse
    TuDi    = 301, -- Land spell
    PoDi    = 401, -- Breaking the Hell Curse
    JingXin = 50 -- The Mantra of Purifying the Mind
}

-- Talisman: Condition types that require special treatment
AmuletConditionEnum = {
    None        = 0,
    KillMonster = 1 -- Kill boss, monster
}

-- Talisman Activation Conditions
AmuletActiveConditionEnum = {
    LevelComplete       = 1, -- Level achieved
    TaskComplete        = 2, -- Complete the task
    AchievementComplete = 3, -- Complete achievements
    RealmLevel          = 4, -- Realm level
    TransferLevel       = 5 -- Transfer Level
}

-- Enumeration of sectarian buildings
GuildBuildEnum = {
    GuildBase     = 1, -- Base/Lobby
    GuildShop     = 2, -- shop
    GuildStation  = 3, -- station
    GuildTask     = 4, -- Task
    GuildWealfare = 5 -- Welfare office
}

-- BOSS interface enumeration, used for BOSS interface pagination logo
BossEnum = {
    WuxianBoss      = 0, -- Unlimited Boss
    WorldBoss       = 1, -- World BOSS
    MySelfBoss      = 2, -- Personal BOSS
    BossHome        = 3, -- BOSS Home
    SoulMonsterCopy = 4, -- Soul Beast Forest
    SuitBoss        = 5, -- Set of BOSS
    GemBoss         = 6, -- Gem BOSS
    StatureBoss     = 7, -- Realm BOSS
    TrainBoss = 18 -- Train BOSS
}

-- World BOSS Pagination Enumeration
WorldBossPageEnum = {
    WuXianBoss = 1,
    WordBoss   = 2,
    SuitBoss   = 3,
    BossHome   = 4,
    GemBoss    = 5,
    TrainBoss  = 6,
}

SuitGemBossEnum = {
    -- Boss set
    SuitBoss = 7,
    -- Gem boss
    GemBoss  = 8
}

-- Marriage function enumeration
MarriageSubEnum = {
    Main      = 0, -- Backpack
    House     = 1, -- Xianju
    Child     = 2, -- Fairy baby
    Box       = 3, -- Treasure box
    Bless     = 4, -- Pray for blessings
    Process   = 5, -- process
    HeartLock = 6 -- Heart lock
}

-- Treasure Hunt Function Enumeration
TreasureEnum = {
    -- 1. Treasure hunting by chance
    Hunt        = 1,
    -- 2. Treasure hunting in the immortal soul
    Inscription = 2,
    -- 3. Treasure hunting for fortune
    ZaoHua      = 3,
    -- 4. Hongmeng Treasure Hunt
    HongMeng    = 4,
    -- 5. Ancient treasure hunt
    ShangGu     = 5,
    -- 6. Immortal Armor Treasure Hunt
    XJXunbao    = 6,
    -- 7. Immortal Armor Secret Treasure
    XJMibao     = 7,
    -- 8. Love and friendship lottery
    QingYi      = 8,
    -- 9. Spiritual Soul Lottery
    LingPo      = 9,
    -- 10. Worry-free treasure house
    Wuyou       = 10,
}

-- Worry-free treasure house red dot enumeration
TreasureWuyouEnum = {
    Bag     = 1000,
    GetItem = 2000,
}

-- Enumeration of the Immortal Armor Treasure Hunt Functions
XJTreasureEnum = {
    -- 1. Treasure Hunt
    XJXunbao = 1,
    -- 2. Warehouse
    XJCangku = 2,
    -- 3. Secret treasure
    XJMibao  = 3
}

-- --Grade category of guild interface
GuildSubEnum = {
    TYPE_BUILD      = 0, -- architecture
    TYPE_INFO       = 1, -- information
    TYPE_REPERTORY  = 2, -- storehouse
    TYPE_LIST       = 3, -- Skill
    TYPE_ACTION     = 4, -- Activity
    TYPE_BOX        = 5, -- Treasure box
    Type_RedPackage = 6, -- Red envelope
    Info_Base       = 11, -- Basic information pagination
    Info_Member     = 12, -- Member list pagination
    Info_List       = 13, -- Fairy Alliance List Pagination
    Info_ApplyList  = 14, -- Application List Pagination
    Info_RedPackage = 15, -- Immortal Alliance Red Packet Pagination
    Info_RankList   = 16, -- Immortal Alliance Battle List Pagination
    Box_Normal      = 0, -- Ordinary treasure chest
    Box_Special     = 1, -- Special treasure chest
}

-- Realm gift package purchase type corresponding to the state_package table type
PurchaseTypeEnum = {
    Money    = 1, -- Direct purchase
    YuanBao  = 2, -- Yuanbao
    BangYuan = 3 -- Tie the Yuan
}

-- Enumeration of sectarian positions
GuildOfficalEnum = {
    Student      = -1, -- Students, used in the past, reserved temporarily
    Member       = 0, -- member
    Elder        = 1, -- Elder
    Guardian     = 2, -- Protective Dharma
    ViceChairman = 3, -- Deputy Sect Master
    Chairman     = 4 -- metropolitan
}
-- Achievement status
AchievementStateEnum = {
    CanGet = 1, -- Available
    None   = 2, -- Not achieved
    Finish = 3 -- Completed
}

-- Magic weapon pagination
TreasureSubEnum = {
    Begin       = 1,
    ListSubForm = 1, -- Magic weapon list pagination
    SoulSubForm = 2, -- Dharma Soul Pagination
    Count       = 2
}

-- Equipment synthesis page
EquipSynthSubEnum = {
    EquipSynth        = 1, -- Equipment synthesis
    MonsterEquipSynth = 2 -- Divine beast equipment synthesis
}

-- Gift gift log type
GiftLogType = {
    SendLog = 1, -- I gave it
    RecLog  = 2 -- The logs I received
}

-- Chief Arena First Ranking Reward Status
ArenaSXFirstAwardEnum = {
    CanGet = 1, -- Available
    None   = 2, -- Not achieved
    Finish = 3 -- Completed
}

JJCRankType = {
    FirstReward = 1, -- First ranking reward
    RankReward  = 2 -- Ranking Rewards
}

-- Pet interface pagination definition
PetFormSubPanelEnum = {
    ProPanel    = 1, -- Properties pagination
    LevelPanel  = 2, -- Level pagination
    DegreePanel = 3 -- Promotion pagination
}

-- Function to enable trailer pagination
FuncOpenTipsPanelEnum = {
    FuncPanel   = 1,
    ModelPanel  = 2,
    NoticePanel = 3,
}

-- Behavior enumeration
ActionEnum = {
    Idle  = "Idle",
    Move  = "Move",
    Run   = "Run",
    Eat   = "Eat",
    Sleep = "Sleep",
    Dead  = "Dead"
}

--Shop hiem
SpecialShopPanelEnum = {
    OrbShop                 = 1, -- Shop tinh chau
}
-- Mall page enumeration
ShopPanelEnum = {
    GoldShop                 = 1, -- Yuanbao Mall
    ExchangeShop             = 2, -- Redeem Mall
    FuDiShop                 = 3, -- Fudi Mall
    GuildShop                = 4, -- Xianmeng Mall
    TerritorShop             = 5, -- Tianxu Mall
    AuctionTradeSub          = 10, -- Trading bank transaction page
    AuctionTradeBuyPanel     = 11, -- Trading bank purchase paging
    AuctionTradeSellPanel    = 12, -- Trading bank sale paging
    AuctionAskTradeSub       = 13,
    AuctionAskTradeListPanel = 14, -- Trading bank purchase list pagination
    AuctionAskTradePanel     = 15, -- Trading bank I requested to purchase paging
    LimitShop                = 16
}

-- Mall sub-pagination
ShopSubPanelEnum = {
    BindGoldShop = 1
}

-- Mall sub-pagination
HouseShopSubPanelEnum = {
    HouseShop   = 1, -- House Mall
    PeopleShop  = 2, -- Popular malls
    ZhenBaoShop = 3, -- Treasure Mall
}

-- Welfare sign-in prop double type
WelfareDailyCheckRatioType = {
    Realm         = 1, -- realm
    MonthCard     = 2, -- Monthly Card
    ExclusiveCard = 3 -- Exclusive card
}

-- Benefit function type, used to request messages
WelfareType = {
    TypeStart         = 0, -- ===Start===
    LoginGift         = 1, -- Login gift package
    DayCheckIn        = 2, -- Sign in every day
    ExclusiveCard     = 3, -- Monthly Card Exclusive Card
    FeelingExp        = 4, -- Insight into experience
    GrowthFund        = 5, -- Growth Fund
    DayGift           = 6, -- Daily gift pack
    ExchangeGift      = 7, -- Redeem gift package (gift package code)
    LevelGift         = 8, -- Level gift pack
    UpdateNoticReward = 9, -- Update announcement
    PeakFund          = 10,
    TianJinLing       = 11,
    TypeEnd           = 12, -- ===End===
}

-- Paging of combat assistance functions
AssistFightingEnum = {
    AssistFighting = 1, -- Help the battle
    Monster        = 11, -- Divine beast
    Synth          = 12, -- Divine beast equipment synthesis
    Strength       = 13
}

-- The server carnival function pagination, ps: Before the production, the planner said that there are 6 pages fixed, but if you cannot determine the specific content of the page, you may adjust it.
ServeCrazyEnum = {
    Table_1 = 1,
    Table_2 = 2,
    Table_3 = 3,
    Table_4 = 4,
    Table_5 = 5,
    Table_6 = 6,
    Count   = 7
}

-- The road to growth tag type
GrowthWayType = {
    Day_1 = 1,
    Day_2 = 2,
    Day_3 = 3,
    Count = 4
}

-- Service opening activities pagination
ServerActiveEnum = {
    -- Sectarian Star
    GuildStar    = 1,
    -- Realm achievement
    JingJie      = 2,
    -- Perfect love
    QinqYuan     = 3,
    -- Sectarian battle for hegemony
    GuildFight   = 4,
    -- Seven-day gift pack
    SevenDayGifg = 5,
    -- Word redemption
    Collect      = 6,
    Count        = 7
}

-- Equipment parts of the divine beast (1 helmet, 2 collars, 3 armor, 4 claws, 5 feathered wings)
MonsterEquipType = {
    Head    = 1,
    Necklet = 2,
    Cloth   = 3,
    Weapon  = 4,
    Wing    = 5,

    Count   = 5
}

-- Function buttons on equipment tips
EquipButtonType = {
    Undeine    = -1, -- Undefined
    Equiped    = 0, -- equipment
    UnEquip    = 1, -- Remove
    Sell       = 2, -- sell
    More       = 3, -- More
    PutStorage = 4, -- storehouse
    Train      = 5,
    Comprese   = 6,
    QuChu      = 7, -- Take out the Treasure House of Apocalypse
    MarketUp   = 8, -- Auction house
    GuildStore = 9,
    Destory    = 10, -- New destruction button for guild warehouse
    Split      = 11, -- Equipment disassembly
    Synth      = 12, -- synthesis
    PutIn      = 4, -- Put in
    PutOut     = 5, -- take out
    Get        = 14, -- Get
    GodStar    = 15, -- God-quality equipment upgrade
    GodLv      = 16, -- Upgrade of magical equipment
    Appraise    = 17, -- Appraise equipment
    AdvancedAppraise      = 18, -- Advanced Appraise equipment
    Count      = 18
}

-- Immortal Soul Function Sub-Pagination
XianPoBaseSubPanel = {
    Begin     = 1,
    XianPo    = 1, -- Fairy soul
    HolyEquip = 2, -- Holy outfit
    Count     = 3
}

-- Fairy Soul Function Sub-Pagination
XianPoMainSubPanel = {
    Begin         = 1,
    Inlay         = 1, -- mosaic
    Decomposition = 2, -- break down
    Exchange      = 3, -- exchange
    Synthetic     = 4, -- synthesis
    Analyse       = 5, -- Disassembly
    Count         = 5
}

-- Enumeration of the quality of immortal soul
XianPoQuality = {
    Blue   = 3, -- blue
    Purple = 4, -- purple
    Gold   = 6, -- gold
    Red    = 7 -- red
}

-- Offline hang-up experience bonus enumeration
OnHookExpAddType = {
    Drug         = 1, -- Addition of potion
    Team         = 2, -- Team up
    VIP          = 3, -- realm
    FuZhou       = 4, -- Talisman
    WorldLevel   = 5, -- World Level
    FaBaoCore    = 6, -- Magic weapon core
    Other        = 7, -- other
    ShenXianLing = 8, -- Ascension Order
    XianLv       = 9, -- Fairy couple team up
    ShouZhuo     = 10, -- bracelet
    ErHuan       = 11, -- earrings
}

-- Boss type enum
BossType = {
    TrueWuXianBoss = 0, -- Really infinite bosses
    WorldBoss      = 1, -- World BOSS
    BossHome       = 2, -- BOSS Home
    SoulMonster    = 5, -- Soul Beast Forest Divine Beast Island
    WuXianBoss     = 6, -- Fake Infinite BOSS
    SuitBoss       = 7, -- Set of BOSS
    GemBoss        = 8, -- Gem BOSS
    TerritorialWar = 9, -- Territory War
    TianXuWar      = 10, -- Tianxu Battlefield
    StatureBoss    = 11, -- Realm boss, this is actually a copy, without a type ID
    FuDiBoss       = 12, -- Blessed boss
    CrossFuDi      = 13, -- Cross-server blessed place
    CrossHorseBoss = 14,
    SlayerBoss     = 15, -- Demon Elimination Group
    NewBossHome    = 16, -- New boss home
    XuMiBaoKu      = 17, -- The second stage copy of Chaos Void, Sumeru Treasure Library
    TrainBoss      = 18, -- Train BOSS
}

MarketBtnType = {
    All      = 1, -- all
    Equip    = 2, -- equipment
    Meterial = 3, -- Material
    Ohter    = 4, -- other
    Count    = 4 -- Total count
}

-- World answer status
WorldAnswerState = {
    ReadyState    = 0, -- Preparation phase for answering questions
    ChooseState   = 1, -- Multiple choice question stage
    ReChooseState = 2, -- Reselect phase
    WaitState     = 3, -- Waiting phase
    FinishState   = 4 -- Final phase of answering
}

-- Trading bank listing interface type
ShopAuctionPutType = {
    PutIn  = 1, -- On the shelves
    PutOut = 2 -- Removed
}

-- First-charge model display type
ModelShowType = {
    GodWeapon = 1, -- Divine Soldier
    Fashion   = 2, -- Fashion
    Pet       = 3, -- pet
    Nature    = 4, -- Mount
    Wing      = 5, -- wing
    Title     = 6 -- title
}

-- Beast Island item type
SoulMonsterItemType = {
    GodCrystal   = 1, -- Beast God Crystal, Beast Spirit Crystal
    BloodCrystal = 2, -- Beast Blood Crystal
    Monster      = 3, -- Ordinary monster
    Boss         = 4 -- BOSS
}

-- Realm BOSS status
StatureBossState = {
    Killed   = 1, -- Killed
    Alive    = 2, -- Can challenge, monsters survive First challenge
    Sweeps   = 3, -- Sweepable, monsters survive, not the first challenge
    WaitOpen = 4, -- Wait for opening, that is, you can open the upper layer by clearing the upper layer.
    UnActive = 5 -- Not activated
}

-- Cross-server panel pagination function enumeration
CrossServerEnum = {
    GodIsland   = 1, -- The Island of the Divine Beast
    BaJiZhen    = 2, -- Eight-pole array diagram
    CrossFuDi   = 3, -- Cross-server blessed place
    HuangGuCopy = 4, -- Ancient altar
}

-- Tribulation copy status
DuJieCopyState = {
    Wait            = 1, -- Wait for the start
    MoveToPos       = 2, -- Move to the start point
    CameraToPlayer  = 3, -- The camera switches to the protagonist, the player turns and meditates
    ChangeScene     = 4, -- Switch scenes
    WaitPlayerStart = 5, -- Wait for the player to click to start
    ConvergePower   = 6, -- Gas accumulation, players play gas accumulation action and play gas accumulation special effects
    Thunder         = 7, -- Start thundering, play the special effects of lightning, and the camera or player starts to rotate, play the interface where the combat power is constantly jumping
    Success         = 8, -- Success, play the player's successful action and play the special effects successfully. At this time, the player's new model will be switched.
    ShowFlySword    = 9, -- Show the flying sword to get the effect
    ShowResult      = 10 -- Show the functions enabled after the tribulation are successful, the rights obtained, the attributes added, and the final combat power
}

-- Test copy status
CeShiCopyState = {
    WaitStart = 1, -- Wait for the start
    Step1     = 2, -- Stage 1
    Step2     = 3, -- Stage 2
    GetFaBao  = 4, -- Obtain magic treasure
    Finish    = 5 -- Finish
}

-- Demon copy status
XinMoCopyState = {
    None            = 0,
    WaitMonsterBorn = 1, -- Wait for the monster to refresh
    Fighting        = 2, -- In battle
    MoveToTransport = 3, -- Move to the transfer point
    WaitSwitch      = 4 -- Wait for the switch
}

-- Definition of the Baji Formation Point
BaJiJuDian = {
    Dui      = 0, -- Dui
    Lei      = 1, -- thunder
    Zhen     = 2, -- shock
    Kun      = 3, -- Kun
    Gen      = 4, -- Gen
    Kan      = 5, -- Kan
    Xun      = 6, -- Xun
    Qian     = 7, -- Dry
    QingLong = 8, -- Green Dragon
    XuanWu   = 9, -- Xuanwu
    BaiHu    = 10, -- White Tiger
    ZhuQue   = 11, -- Vermilion Bird
    TaiJi    = 12, -- Taiji
    Count    = 13
}

-- Level 8 formation stronghold status
BaJiJuDianState = {
    LocalServer = 0, -- This server takes over
    OtherServer = 1, -- Other server occupation
    NoneServer  = 2 -- Not occupied
}

-- Color definition of the Eight-Pole Array
BaJiColor = {
    Color_0 = 1,
    Color_1 = 2,
    Color_2 = 3,
    Color_3 = 4,
    Color_4 = 5,
    Color_5 = 6,
    Color_6 = 7,
    Color_7 = 8,
    Count   = 8
}

-- Baji Array Chart Ranking Type
BaJiRankType = {
    FightRank = 1, -- Battle Ranking
    SaiJiRank = 2 -- Season ranking
}

-- Auction house pagination
AuctionSubPanel = {
    World      = 0, -- World Auction
    Guild      = 1, -- Union Auction
    SelfBuy    = 2, -- My bidding
    SelfSell   = 3, -- Mine is on the shelves
    Record     = 4, -- Transaction history
    SelfFollow = 5 -- My attention
}

-- Friends interface subcategory
IntimateFriendsSubPanel = {
    Base        = 0, -- Basic interface, used when there are no close friends
    Information = 1, -- information
    Rights      = 2 -- rights and interests
}

-- Holy Dress Interface Pagination
HolyEquipSubPanel = {
    EquipDress     = 0, -- Holy dress
    EquipIntensify = 1, -- Holy suit enhancement
    EquipCompose   = 2, -- Holy costume synthesis

    EquipSplit     = 3, -- Holy outfit breakdown
    EquipSoul      = 4, -- Holy Soul
    EquipSuit      = 4 -- Holy Soul
}

-- Attached interface pagination
AttachEquipSubpanel = {
    HolyEquip   = 1,
    UnrealEquip = 2,
}

-- Equipment synthesis status
EquipSynState = {
    UnActive = 0, -- Synthesis conditions are not met
    Active   = 1, -- Can be synthesized
    Max      = 2, -- The largest star rating has been reached
    Undefine = 9 -- Undefined
}

-- Magic weapon pagination
RealmStifleSubPanel = {
    RealmStifle  = 1, -- magic weapon
    Organ        = 2, -- Spirit of the weapon
    OrganEvo     = 3, -- Evolution of the spirit of the weapon
    OrganPromote = 4 -- Promotion of the spirit of the weapon
}

-- Skill interface pagination
OccSkillSubPanel = {
    AtkPanel  = 1,
    PassPanel = 2,
    FuZhou    = 3,
    Meridian  = 4,
    XinFa     = 5
}

-- Level gift pack status
LevelGiftStatus = {
    CanGet   = 1, -- Available
    NotReach = 2, -- Not achieved
    SellOut  = 3, -- Sold out
    Geted    = 4, -- Already received
    VipLimit = 0, -- Insufficient VIP level
}

-- Zhou Chang
VipWeekTab = {
    VipWeek       = 1,
    VipWeekReward = 2
}

-- Privileged card - write 4 and 5 first to modify it later. What Lao Huang said is write 4 and 5 first to modify it
SpecialCard = {
    Week  = 4,
    Month = 5,
    Vip   = 3
}

-- Marrow washing
XiSuiLevelPanel = {
    Level1 = 1,
    Level2 = 2,
    Level3 = 3,
    Level4 = 4,
    Level5 = 5
}

-- Resurrection mode
-- 0. The pop-up panel has the [On-place] [Return to City] button to click; 1. The pop-up panel has the [Return to City] button to click; 2. Automatically resurrect [No-broad panel]; 3. Automatically resurrect [No-broad panel]
ReliveType = {
    OriAndSafe = 0,
    OnlySafe   = 1,
    AutoOri    = 2,
    AutoSafe   = 3
}

-- The Immortal Alliance Fights for Hegemony and Finds the Way
XmFightFindPath = {
    Default        = 0,
    Start          = 1,
    FindPath       = 2, -- Wait for the best path
    StartMove      = 3, -- Start moving
    Moving         = 4, -- move
    ShowControl    = 5, -- Display the transfer operation button
    WaitControl    = 6, -- Wait for operation
    Control        = 7, -- Player transfer
    WaitCrossBack  = 8, -- Wait for the transfer to return
    WaitTrans      = 9, -- Waiting for delivery
    MoveAgin       = 10, -- Players continue to move
    HideControl    = 11, -- Hide the action button
    NWaitCrossBack = 12 -- Non-automatic wayfinding waiting for delivery
}

-- Immortal Alliance Battle Help Explain Interface Type
XmFightHelpPage = {
    Normal  = 0, -- Just a text description
    Texture = 1 -- Pictures and texts are both rich
}

-- Immortal Alliance War Help Description Icon Types on the Picture
XmFightHelpTexType = {
    ChengMen      = 1, -- City Gate
    ShangGu       = 2, -- Ancient Will
    CrossTrans    = 3, -- Teleportation array
    BronPoint     = 4, -- Birth point
    MonsterChange = 5 -- Beast transformation
}

-- Map custom object type
MapCustomType = {
    XMDoor    = 1, -- Immortal Alliance Battle City Gate
    XMNpc     = 2, -- Immortal Alliance
    XMCollect = 3, -- Immortal Alliance Battle Collected
    XMTrigger = 4, -- The trigger point of the Immortal Alliance
    XMBoss    = 5 -- Immortal Alliance Fights the Ancient Will
}

-- Fashion pagination
NewFashionSheet = {
    Fashion   = 0,
    ZhuangShi = 1
}

-- Fashion Type Definition
NewFashionType = {
    Body   = 0,
    Weapon = 1,
    Count  = 2
}

-- Model display type
ShowModelType = {
    Mount      = 0, -- Mount
    Wing       = 1, -- wing
    FaBao      = 2, -- magic weapon
    Player     = 3, -- Role
    Fashion    = 4, -- Temporary fashion
    Pet        = 5, -- pet
    LpWeapon   = 6, -- The protagonist's weapon
    SoulEquip  = 7, -- Soul Armor
    SpecialBox = 8, -- Treasure box

    Head       = 11, -- avatar
    Frame      = 12, -- Avatar frame
    PaoPao     = 13, -- Chat bubbles

    Gather     = 14 -- gathering
}

-- Unblocking the copy status of Wan Yao Scroll
WYJJieFengState = {
    Wait          = 1, -- Wait for the start
    CameraFeature = 2, -- Camera close-up
    CameraShake   = 3, -- Camera vibration
    CameraBack    = 4, -- Camera restore
    Finish        = 5, -- Finish
    DeadShow      = 6, -- Death close-up
}

LingtiUnlockState = {
    UnMet         = 1, -- Prerequisites not met
    LastLock      = 2, -- The previous level is not activated
    WaitForFinish = 3, -- Unblocking is being unblocked, waiting for unblocking to be completed
    Finish        = 4 -- Unblocked
}

-- Color Type
ColorType = {
    Default = 0, -- Default (Label text uses the color set on the prefab)
    White   = 1, -- White
    Black   = 2, -- black
    Red     = 3, -- red
    Blue    = 4, -- blue
    Green   = 5, -- green
    Yellow  = 6, -- yellow
    Gray    = 7, -- grey
    Clear   = 8, -- Colorless transparent
    Orange  = 9 --#FF4E00
}

-- The state of the great powerhouse
DNYFCopyState = {
    None        = 0,
    WaitStart   = 1, -- Wait for the start
    FightMoving = 2, -- move
    BossFight   = 3, -- Boss Battle
    Finish      = 4 -- Settlement
}

-- Transfer copy status
ChangeJobCopyState = {
    Wait            = 1, -- Wait for the start
    MoveToPos       = 2, -- Move to the start point
    CameraToPlayer  = 3, -- The camera switches to the protagonist, the player turns and meditates
    ChangeScene     = 4, -- Switch scenes
    WaitPlayerStart = 5, -- Wait for the player to click to start
    ConvergePower   = 6, -- Gas accumulation, players play gas accumulation action and play gas accumulation special effects
    Thunder         = 7, -- Start thundering, play the special effects of lightning, and the camera or player starts to rotate, play the interface where the combat power is constantly jumping
    Success         = 8, -- Success, play the player's successful action and play the special effects successfully. At this time, the player's new model will be switched.
    ShowResult      = 10 -- Show the functions enabled after the tribulation are successful, the rights obtained, the attributes added, and the final combat power
}

-- Types of recharge interface
PaySubType = {
    -- 1 Normal recharge
    Normal = 1,
    -- 2 Newbie gift packs (once once in a lifetime)
    Novice = 2,
    -- 3-week gift pack (refreshed every week)
    Week   = 3,
    -- 4-day gift pack (refreshed every day)
    Day    = 4
}

PayType = {
    -- top up
    Recharge        = 1,
    -- Daily gift pack
    DayGift         = 2,
    -- Weekly Card
    WeekCard        = 3,
    -- Monthly Card
    MonthCard       = 4,
    -- Lifetime card
    LifelongCard    = 5,
    -- Growth Fund
    GrowthFund      = 6,
    -- Mysterious store
    LimitShop       = 7,
    -- Buy 0 yuan
    ZeroBuy         = 8,
    -- Direct purchase gift package (excellent discount)
    InternalBuyPack = 9,
    -- Carnival Week
    CrazyWeek       = 10
}

-- First charge status
FirstChargeState = {
    CanGet         = 1, -- Available
    NextCanGet     = 2, -- Can be collected the next day
    NoMoney        = 3, -- No recharge quantity requirements are met
    Geted          = 4, -- Received
    NextNextCanGet = 5 -- Can be collected on the third day
}

-- Blind date wall pagination
MarryWallSubEnum = {
    LevelPanel = 1, -- Level pagination
    WallPanel  = 2 -- Manifesto Wall Pagination
}

-- {"Clothing Armor", "Weapon", "Back Decoration", "Pet", "Mount", "Magic Weapon", Soul Armor}
FashionType = {
    Body   = 1,
    Weapon = 2,
    Wing   = 3,
    Mount  = 4,
    Pet    = 5,
    FaBao  = 6,
    HunJia = 7
}

-- Reward status (general)
RewardState = {
    CanReceive = 1, -- Available
    None       = 2, -- Not achieved
    Received   = 3, -- Received
    OutDate    = 4, -- Expired
    Unopen     = 5 -- Not open
}

-- Ranking Types
RankModelType = {
    Mount = 103, -- Mount
    Wing  = 104, -- Back decoration
    FaBao = 106, -- magic weapon
    Pet   = 117 -- Pet ranking
}

-- Ranking configuration table displays model type
RankCfgShowModelType = {
    Player = 1,
    Pet    = 2,
    Mount  = 3,
    FaBao  = 4,
    HunJia = 5
}

-- Arena Type
JJCType = {
    Normal   = 1, -- Ordinary Arena
    DianFeng = 2 -- Peak Arena
}

-- Day Ban Menu Pagination
TJLMenu = {
    TJL       = 0,
    DailyTask = 1,
    StepTask  = 2,
    ChuMoTask = 3
}

-- language
LanguageConstDefine = {
    CH  = "CH", -- Chinese
    TW  = "TW", -- Taiwan --big5
    EN  = "EN", -- English
    KR  = "KR", -- Korean
    VIE = "VIE", -- Vietnam
    JP  = "JP", -- Japanese
    TH  = "TH" -- Thai
}

YYHDLogicDefine = {
    HuoYueDuiHuan      = 1, -- Active redemption
    MeiRiChonZhi       = 2, -- Daily recharge
    XianShiDenglu      = 3, -- Log in with gifts
    XianGouLiBao       = 4, -- Purchase limited gift bag
    TianDiBaoKu        = 5, -- The Treasure Library of Heavenly Emperor
    XianShiLeiChong    = 6, -- Accumulated recharge
    XianShiXiaoHao     = 7, -- Limited time consumption
    JiWuDuiHuan        = 8, -- Collection exchange
    TuanGou            = 9, -- Group Purchase
    ZhaoCaiMao         = 10, -- The lucky cat
    BossHappy          = 11, -- The leader carnival
    QingDianTask       = 12, -- Celebration mission
    JieRiJiZhi         = 13, -- Festival collection
    JieRiTeHui         = 14, -- Holiday special offer (direct purchase gift package)
    LianXuLeiChong     = 15, -- Continuous filling
    XianShiShangCheng  = 16, -- Limited time mall
    XianShiLiBao       = 17, -- Limited time gift bag
    JiFenPaiMing       = 18, -- Points ranking
    JieRiXueYuan       = 19, -- Holiday Wishes
    FBFenXiang         = 20, -- FB Share
    LianXuLeiChong2    = 21, -- Continuously accumulated 2 (purchase directly)
    XinNianZhuFu       = 22, -- New Year greetings
    ZhiTouZi           = 23, -- dice
    WaiGuanZhanShi     = 24, -- Appearance display
    OnlinePrompt       = 25, -- Online tips
    JuBaoPen           = 26, -- treasure bowl
    XingYunZaDan       = 27, -- Lucky to smash eggs
    ZhaoCaiMaoBangDing = 28, -- Tie jade to win fortune cat
    FZTB               = 29, -- Fang Ze's treasure ​​seeking
    XJTB               = 30, -- Treasure Exploration in Wonderland
}

DynamicProcessDir = {
    Width  = 0,
    Height = 1
}

FuDiCrossType = {
    Cross_2 = 2,
    Cross_4 = 4,
    Cross_8 = 8
}

BagFormSubPanel = {
    Bag   = 0,
    Store = 1,
    Synth = 2
}

UIChangeNameCardType = {
    Role  = 0,
    Guild = 1,
    Count = 2
}

-- The position type of digital input
NumInputPosType = {
    ELEFTUP     = 0, -- Align the upper left corner
    ELEFTMID    = 1, -- Align left center
    ELEFTDOWN   = 2, -- Align the lower left corner
    ERIGHTUP    = 3, -- Align the upper right corner
    ERIGHTMID   = 4, -- Right center aligned
    ERIGHTTDOWN = 5, -- Align the lower right corner
    EMID        = 6 -- Central alignment
}

-- Social interface pagination definition
SocialityFormSubPanel = {
    Friend       = 0,
    Marry        = 1,
    Master       = 2,
    Mail         = 3,
    RecentFriend = 4,
}

-- Items get display position definition 0 not displayed, 1 lower right corner, 2 top, 3 middle pop-up (hide)
ItemChangeShowPos = {
    None        = 0, -- Not displayed
    RightButtom = 1, -- Lower right corner
    Top         = 2, -- top
    CenterPop   = 3, -- Pop up in the middle
    BossBox     = 4 -- Boss treasure chest
}

-- Backpack item classification
BagCategoryType = {
    UnDefine                  = -1, -- Undefined
    BAG_CATEGORY_ALL          = 0, -- all
    BAG_CATEGORY_EQUIP        = 1, -- equipment
    BAG_CATEGORY_ImortalEquip = 2, -- Fairy Armor
    BAG_CATEGORY_Other        = 3, -- other
    BAG_CATEGORY_COUNT        = 4 -- sum
}

LoginNoticeType = {
    Update = 0, -- Announcements that open automatically are generally login maintenance announcements
    Login  = 1, -- Manually click on the login announcement button
    Action = 2 -- Manually click on the event announcement button
}
-- Equipment locations (1 helmet, 2 collars, 3 armor, 4 claws, 5 feathered wings)
MonsterSoulEquipType = {
    Head    = 1,
    Necklet = 2,
    Cloth   = 3,
    Weapon  = 4,
    Wing    = 5,
    Count   = 5
}

-- Main interface pagination definition
MainFormSubPanel = {
    TopMenu          = 1, -- Top Menu
    PlayerHead       = 2, -- Protagonist avatar
    TargetHead       = 3, -- Target avatar
    MiniMap          = 4, -- Mini map
    TaskAndTeam      = 5, -- Mission and teaming
    Joystick         = 6, -- Rocker
    Exp              = 7, -- experience
    MiniChat         = 8, -- Small chat box
    Skill            = 9, -- Skill
    SelectPkMode     = 10, -- Select PK mode
    FunctionFly      = 11, -- New function enables flight interface
    FastPrompt       = 12, -- Quick reminder interface
    FastBts          = 13, -- Quick operation button interface
    Ping             = 14, -- ping
    CustomBtn        = 15, -- Customize buttons
    SitDown          = 16, -- Meditation
    RemotePlayerHead = 17, -- Remote player avatar
    ChangeSkill      = 18, -- Transformation skills
    FlySwordGrave    = 19, -- Sword Tomb
    SkillWarning     = 20, -- Skill Warning
    RightMenuBox     = 21, -- Main right menu
    Count            = 21  -- quantity
}

-- Top menu status of main interface
MainTopMenuState = {
    Show    = 1,
    Showing = 2,
    Hide    = 3,
    Hiding  = 4
}

-- Task team copy page definition on the left side of the main interface
MainLeftSubPanel = {
    Task  = 1,
    Team  = 2,
    Other = 3,
    Count = 3
}

GuildSubPanel = {
    GuildJoin    = 0,
    GuildCreate  = 1,
    GuildInvit   = 2,
    GuildInfo    = 3,
    GuildMember  = 4,
    GuildBuild   = 5,
    GuildSkill   = 6,
    GuildWelfare = 7
}

GuildOfficalType = {
    Student      = -1,
    Member       = 1,
    Guardian     = 2,
    ViceChairman = 3,
    Chairman     = 4
}

-- Backpack type
LuaContainerType = {
    UnDefine                 = -1, -- Undefined
    ITEM_LOCATION_BAG        = 0, -- Player backpack
    ITEM_LOCATION_EQUIP      = 1, -- The equipment on the player
    ITEM_LOCATION_STORAGE    = 2, -- Player warehouse
    ITEM_LOCATION_CLEAR      = 3, -- Clean the parcel
    ITEM_LOCATION_BACKEQUIP  = 4, -- Player backup equipment bar
    ITEM_LOCATION_IMMORTAL   = 5, -- Fairy Armor Backpack
    ITEM_LOCATION_PETEQUIP   = 6, -- Pet equipment backpack
    ITEM_LOCATION_PEREAL     = 7, -- Soul Seal Backpack (Soul Armor Inlay Props)
    ITEM_LOCATION_MOUNTEQUIP = 8, -- Mount equipment backpack
    ITEM_LOCATION_DEVILEQUIP = 9, -- Demon Soul Equipment Backpack
    ITEM_LOCATION_COUNT      = 10, -- The sum of item containers
}

-- Spirit Stone Obtain Usage Effect Type
BoomType = {
    Default    = 1,
    RedpPackge = 1,
    VipExp     = 2
}

-- Where to fly the special effects icon
BoomToType = {
    Default   = 1,
    -- Fly to the backpack
    BagPackge = 1,
    -- Fly to the VIP function entrance
    Vip       = 2
}

NpcTalkAnimPlayState = {
    -- Play default action clips
    Default = 0,
    -- Play other action clips
    Other   = 1,
    -- Wait for playback to be completed
    Waite   = 2
}

-- lua role instance type definition
LuaCharacterType = {
    -- Soul Armor
    HunJia               = 1,
    -- magic weapon
    FaBao                = 2,
    -- furniture
    JiaJu                = 3,
    -- wall
    Wall                 = 4,
    -- Task Trans NPC move follow character sermilar FaBao
    TaskTransNPC         = 5,
    -- Task Trans Equip Player slot character
    TaskTransEquipPlayer = 6
}

-- Pet equipment parts
PetEquipType = {
    Defalt    = -1, --  1-99
    ClawCover = 201, -- Claw cover
    Necklace  = 202, -- Necklace
    Bell      = 203, -- Bell
    FuDai     = 204, -- Lucky bag
    Count     = 4
}

-- Mount equipment part
MountEquipType = {
    Defalt = -1, --  1-99
    Face   = 301, -- Facial lines
    Heart  = 302, -- Heart pattern
    Ring   = 303, -- Ring pattern
    Foot   = 304, -- Foot lines
    Count  = 4
}

FriendType = {
    Undefine  = 0,
    Friend    = 1, -- Friends
    Enemy     = 2, -- Enemy
    Shield    = 3, -- shield
    Recommend = 4, -- recommend
    Recent    = 5, -- recent
    Search    = 6 -- Find
}

-- Team interface pagination definition
TeamFormSubPanel = {
    Team  = 1,
    Match = 2
}

-- Target system task type
TargetTaskDefine = {
    -- all
    All         = -1,
    -- Sword Spirit
    JianLing    = 0,
    -- Equipment development
    EquipGrowth = 1,
    -- Role development
    RoleGrowth  = 2,
    -- Riding pet creation
    MountAndPet = 3,
    -- other
    Other       = 4
}

-- Ordinary equipment parts
EquipmentType = {
    Defalt     = -1, --  1-99
    Helmet     = 0, -- helmet
    Weapon     = 1, -- arms
    Clothes    = 2, -- Breastplate
    Necklace   = 3, -- necklace
    Belt       = 4, -- belt
    LegGuard   = 5, -- Pants
    Shoe       = 6, -- shoe
    FingerRing = 7, -- Left-handed ring
    Bracelet   = 8, -- bracelet
    EarRings   = 9, -- earrings
    Badge      = 10, -- badge
    Sachet     = 11, -- ngoc boi
    Pendant    = 12, -- tui thom
    Count      = 13
}

EquipmentGroup = {
    Attack = {
        EquipmentType.Weapon
    },
    Defense = {
        EquipmentType.Helmet,
        EquipmentType.Clothes,
        EquipmentType.Belt,
        EquipmentType.LegGuard,
        EquipmentType.Shoe
    },
    Accessory = {
        EquipmentType.Necklace,
        EquipmentType.FingerRing,
        EquipmentType.Sachet,
        EquipmentType.Pendant
    }
}

-- Role Career Definition
Occupation = {
    XianJian = 0,
    MoQiang  = 1,
    DiZang   = 2,
    LuoCha   = 3,
    Count    = 4
}

-- Skill User Definition
SkillClass = {
    XianJian  = 0, -- Fairy Sword Skill
    MoQiang   = 1, -- Magic gun skills
    DiZang    = 2, -- Ksitigarbha skills
    LuoCha    = 3, -- Rakshasa skills
    KaPai     = 4, -- Card Master Skill
    QiangShou = 5, -- Gunman skills
    None      = 10, -- Unlimited
    Monster   = 11, -- Monster skills
    Pet       = 12, -- Pet skills
    Married   = 13, -- Marriage skills
    FaBao     = 14 -- Magical weapon skills
}

-- Hang-up type
MandateType = {
    Map    = 0, -- Map hanger
    Screen = 1 -- Screen hanging machine
}

-- Chat Insert Type
ChatInsertType = {
    Expression  = 1,
    Item        = 2,
    History     = 3,
    HolyEquip   = 4,
    UnrealEquip = 5,
}

TaskType = {
    Default     = -1,
    Main        = 0,    -- Main line
    Daily       = 1,    -- daily
    Guild       = 2,    -- guild
    Branch      = 3,    -- Side line
    BianJing    = 4,    -- Border Mission
    ZhuanZhi    = 5,    -- Transfer tasks
    TanBao      = 6,    -- Treasure Exploration
    JunXian     = 7,    -- Military rank
    ZhanChang   = 8,    -- Battlefield missions
    Prompt      = 9,    -- Prompt task 9
    NewBranch   = 11,   -- New side mission 11
    HuSong      = 12,   -- Escort mission
    Prison      = 13,   -- Prison tasks
    DailyPrison = 14,   -- Prison daily tasks
    Not_Recieve = 15    -- Unreceived tasks
}

-- Task reception status
TaskReciveState = {
    Recived   = 0, -- Already received
    NotRecive = 1 -- Not accepted
}

-- Task behavior type
TaskBeHaviorType = {
    Default             = -1,
    Talk                = 0, -- dialogue
    Kill                = 1, -- Kill monsters
    Collection          = 2, -- Collect items
    UseItem             = 3, -- Use props
    SubMit              = 4, -- Submit props
    Trans               = 5, -- Send
    OpenUI              = 6, -- Open the UI
    Level               = 7, -- Card Level
    CopyKill            = 8, -- Copy kills monsters
    CopyKillForUI       = 10, -- Open the UI and enter the copy and kill monsters
    KillPlayer          = 11, -- Defeat players
    ArrivePosEx         = 12, -- Arrive at the designated destination (no circle)
    ArriveToAnim        = 15, -- Play actions to a certain location (character action, magic weapon action, pet action)
    PassCopy            = 16, -- Clearance Copy
    KillMonsterTrainMap = 17, -- Kill monsters in the training map
    KillMonsterDropItem = 18, -- Drop items by killing monsters
    FindCharactor       = 19, -- Finding someone
    ArrivePos           = 20, -- Arrive at the specified location
    OpenUIToSubMit      = 21, -- Open the UI to complete the task (requires active submission)
    MountFlyUp          = 22, -- Flying mount takes off to complete the mission
    CollectItem         = 23, -- Collect props
    CollectRealItem     = 24, -- Collect real drop props
    AddFriends          = 25, -- Add friends of the opposite sex
    Count               = 26
}
-- Mission status on Npc
NpcTaskState = {
    Default    = -1,
    Can_Access = 0, -- Available
    Accessed   = 1, -- Mission received
    Submit     = 2 -- Submitable

}

-- Daily Task Star Rating
DailyTaskStarNum = {
    Default = -1,
    Star_0  = 0, -- 0 stars
    Star_1  = 1, -- 1 star
    Star_2  = 2, -- 2 stars
    Star_3  = 3, -- 3 stars
    Star_4  = 4, -- 4 stars
    Star_5  = 5 -- 5 stars
}

-- Prison Daily Task Star Rating
DailyPrisonTaskStarNum = {
    Default = -1,
    Star_0  = 0, -- 0 stars
    Star_1  = 1, -- 1 star
    Star_2  = 2, -- 2 stars
    Star_3  = 3, -- 3 stars
    Star_4  = 4, -- 4 stars
    Star_5  = 5 -- 5 stars
}

-- Battlefield Mission Star Rating
BattleTaskStarNum = {
    Default = 0,
    Star_1  = 1, -- 1 star
    Star_2  = 2, -- 2 stars
    Star_3  = 3, -- 3 stars
    Star_4  = 4, -- 4 stars
    Star_5  = 5 -- 5 stars
}

-- Task sorting
TaskSort = {
    Default    = -1,
    DailyExp   = 0, -- Daily experience
    DailyGold  = 1, -- Daily gold coins
    GuildDaily = 2, -- Trade Union Daily
    GuildWeek  = 3 -- Union circumference
}

-- Daily tasks subType enumeration
DailyTaskSubType = {
    Exp  = 0, -- Daily experience
    Gold = 1 -- Daily gold coins
}

-- Gang Task SubType Enumeration
GuildTaskSubType = {
    Week  = 0, -- perimeter
    Daily = 1 -- daily
}

-- Controller status
TaskControllerState = {
    Stop  = 0, -- stop
    Play  = 1, -- Play
    Pause = 2 -- pause

}

TaskAnimType = {
    Default  = 0,
    MoveTo   = 1,
    PlayAnim = 2
}

-- Blocking system type
BlockingUpPromptType = {
    ForceGuide       = 0, -- Forced guidance
    NewFunction      = 1, -- New features are enabled
    FlyTeleport      = 2, -- Flying delivery
    TimelineTeleport = 3, -- Animation delivery
    Count            = 4,
}
-- Block system status
BlockingUpPromptState = {
    None       = 0,
    Initialize = 1, -- initialization
    Running    = 2, -- Execution
    Finish     = 3, -- Finish
}

-- Blocking the system's new function activation type
PromptNewFunctionType = {
    Skill    = 0, -- Skill
    Function = 1, -- Function
    GuJi     = 2, -- Ancient books
}

-- Boot Force Type
GuideForcedType = {
    NotForced    = 0, -- Non-forced guidance
    Forced       = 1, -- Forced guidance
    SceneAnim    = 2, -- Scene animation
    TimelineAnim = 3, -- Timeline resource animation
}

-- Reward Order Type
KaosOrderType = {
    HuangGuLing = 1,
    PetLing     = 2,
}

FengMoTaiCost = {
    High = 1,
    Mid  = 2,
    Low  = 3,
}

-- Item Type
ItemType = {
    UnDefine            = -1, -- Undefined
    Money               = 1, -- currency
    Equip               = 2, -- equipment
    Effect              = 3, -- Effect props: Give players certain effects after use; effects include, adding attributes, buffs, currency, etc.
    Material            = 4, -- Material
    GemStone            = 5, -- gem
    GiftPack            = 6, -- Gift bag props
    SpecialPingZiItem   = 7, -- Fragments
    Gift                = 8, -- Gift
    Normal              = 9, -- Ordinary things
    Special             = 10, -- Special items
    Title               = 11, -- title
    MonsterSoulEquip    = 12, -- Divine beast equipment
    MonsterSoulMaterial = 13, -- Soul Beast Crystal Divine Beast Equipment Enhancement Materials
    HolyEquip           = 14, -- Holy outfit
    SpecialBox          = 15, -- Choose a treasure chest
    ChangeJob           = 16, -- Transfer props
    XiShui              = 17, -- Transfer job marrow cleaning common props
    VipExp              = 18, -- VIP Experience
    ImmortalEquip       = 19, -- Fairy Armor
    LingPo              = 21, -- Spirit
    PetEquip            = 23, -- Pet equipment
    SoulPearl           = 24, -- Divine Seal (Soul Bead)
    HorseEquip          = 25, -- Mount Equipment
    DevilSoulEquip      = 26, -- Demon Soul Equipment
    DevilSoulChip       = 27, -- Demon Soul Fragments
    UnrealEquip         = 28, -- Fantasy
    UnrealEquipChip     = 29, -- Phantom pack fragments
}

XianJiaType = {
    XianJiaWeapon   = 30, -- Fairy armor weapon,
    XianJiaClothes  = 31, -- Fairy armor,
    XianJiaRing     = 32, -- Fairy Armor Halo,
    XianJiaZhenD    = 33, -- Immortal Armor Array,
    XianJiaLeftP    = 34, -- The left handed down fairy armor,
    XianJiaRightP   = 35, -- The right armour of the fairy armor,
    XianJiaHelmet   = 36, -- Fairy armor crown,
    XianJiaShoulder = 37, -- Fairy armor shoulder ornaments,
    XianJiaHuWan    = 38, -- Fairy Armor Wristguard,
    XianJiaShouT    = 39, -- Fairy armor gloves,
    XianJiaNeiCen   = 40, -- Fairy armor lining,
    XianJiaBelt     = 41, -- Fairy armor belt,
    XianJiaLeg      = 42, -- Fairy armor pants,
    XianJiaShoe     = 43, -- Fairy armor shoes
    HunJiaWeapon    = 44, -- Soul Armor Weapon,
    HunJiaClothes   = 45, -- Soul Armor,
    HunJiaRing      = 46, -- Soul Armor Halo,
    HunJiaZhenD     = 47, -- Soul Armor Array
    HunJiaLeftP     = 48, -- Soul armor left pants,
    HunJiaRightP    = 49, -- The right pants of soul armor,
    HunJiaHelmet    = 50, -- Soul Armor Head Crown,
    HunJiaShoulder  = 51, -- Soul Armor Shoulder Decoration,
    HunJiaHuWan     = 52, -- Soul Armor Wristguard,
    HunJiaShouT     = 53, -- Soul Armor Gloves,
    HunJiaNeiCen    = 54, -- Soul armor lining,
    HunJiaBelt      = 55, -- Soul armor belt,
    HunJiaLeg       = 56, -- Soul armor pants,
    HunJiaShoe      = 57, -- Soul Armor Shoes
    YangBaGua       = 401, -- Yang Bagua
    YinBaGua        = 402, -- Yin Bagua
    BaGua1          = 403, -- Bagua part 1
    BaGua2          = 404, -- Bagua Part 2
    BaGua3          = 405, -- Bagua Part 3
    BaGua4          = 406, -- Bagua Part 4
    BaGua5          = 407, -- Bagua part 5
    BaGua6          = 408, -- Bagua part 6
    BaGua7          = 409, -- Bagua part 7
    BaGua8          = 410, -- Bagua parts 8
    BaGuaCount      = 10, -- Number of gossip headquarters
}

UISceneDefine = {
    Default         = 0,
    -- Fashion scene
    FasionScene     = 1,
    -- Sword Tomb
    SwordGraveScene = 2,
    -- Sword Spirit Activated
    SwordActive     = 3,
}

SkinType = {
    Player = 0,
    Pet    = 1,
    FaBao  = 2,
    Soul   = 3,
}

CommunityMsg = {
    Presonel   = 1,
    MsgBoard   = 2,
    Dynamic    = 3,
    FairyHouse = 4,
}

-- Home Task Type
HomeTaskDefine = {
    -- daily
    MeiRi       = 0,
    -- Popularity
    RenQi       = 1,
    -- Decorative degree
    ZhuangShiDu = 2,
    -- collect
    ShouJi      = 3,
    -- other
    Other       = 4
}

JiaJuDirDefine = {
    Dir0   = 1,
    Dir90  = 2,
    Dir180 = 3,
    Dir270 = 4,
}
JiaJuTypeDefine = {
    Wall      = 1,
    Window    = 2,
    JiaJu     = 3,
    ZhuangShi = 4,
}

FriendShipType = {
    Send    = 1,
    HadSend = 2,
    ReSend  = 3,
    Recvie  = 4,
    Done    = 5,
}

NPCFriendTask = {
    Level       = 1,
    Task        = 2,
    SendShip    = 3,
    GetShip     = 4,
    SendMessage = 5,
    DayOff      = 6,
    ChangeJob   = 7,
}

LoversFight = {
    Free  = 1,
    Group = 2,
    Top   = 3,
    Rank  = 4,
    Shop  = 5,
}

-- Fairy Couple Confrontation Stage
LoverFightStep = {
    Default  = 0,
    FreeStep = 1,
    GropStep = 2,
    TopStep  = 3,
}

-- Image synchronization type
TexHttpSyncType = {
    -- avatar
    HeadPic   = 0,
    -- Social pictures
    SocialPic = 1,
}

-- Image synchronization status
TexHttpSyncState = {
    -- Error, link is incorrect
    Error           = -1,
    -- Already existed locally
    AlredayDownload = 0,
    -- Downloading
    Downloading     = 1,
    -- Uploading
    UpLoading       = 2,
    -- Querying
    Checking        = 3,
    -- No picture
    NotHaveTex      = 4,
    -- Already uploaded
    AlreadyUpload   = 5,
}

-- Home Task Classification
HomeTaskType = {
    -- all
    Default     = 0,
    -- visit
    BaiFang     = 1,
    -- Gift gift
    SongLi      = 2,
    -- Buy
    GouMai      = 3,
    -- Popularity
    RenQi       = 4,
    -- Decorative degree
    ZhuangShiDu = 5,
}

-- Fantasy type
UnreadEquipType = {
    TouKui    = 441, -- Phantom helmet
    ErHuan    = 442, -- Phantom earrings
    XiangLian = 443, -- Fantasy necklace
    YiFu      = 444, -- Fantasy clothes
    KuZi      = 445, -- Fantasy trousers
    WuQi      = 446, -- Phantom Weapon
    HuWan     = 447, -- Phantom wrist guard
    XieZi     = 448, -- Fantasy shoes
    JieZhi    = 449, -- Fantasy ring
    ShouZHuo  = 450, -- Fantasy bracelet
}

--===========================================================================
--============================= UI Color Config =============================
--===========================================================================
ColorTargetType = {
    Wash_Attribute      = 1000,
    Strength_Level      = 2000,
    Equip_Name          = 3000,
    Appraise_Attribute  = 4000,
    Special_Attribute  = 5000,
    Appraise_Plus_Attribute  = 6000
}
--===========================================================================