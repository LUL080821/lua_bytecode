local FunctionStartIdCode = 
{
	--主功能根节点
	MainFuncRoot = 1,
	--顶层按钮根节点
	TopFuncRoot = 2,
	--玩家技能
	PlayerSkill = 10000,
	--玩家技能列表
	PlayerSkillList = 12000,
	--玩家技能格子升级
	PlayerSkillCell = 12100,
	--玩家技能升星
	PlayerSkillStar = 12200,
	--玩家技能装配
	PlayerSkillPos = 12300,
	--被动技能
	PassSkill = 13000,
	--符咒
	GodBook = 14000,
	--技能经脉
	PlayerSkillMeridian = 15000,
	--三转经脉
	PlayerSkillSanZhuan = 15100,
	--四转经脉
	PlayerSkillSiZhuan = 15200,
	--五转经脉
	PlayerSkillWuZhuan = 15300,
	--技能心法
	PlayerSkillXinFa = 16000,
	--背包
	Bag = 20000,
	--仓库
	Store = 21000,
	--背包物品合成
	BagSynth = 22000,
	--装备合成
	EquipSynthesis = 23000,
	--背包子功能
	BagSub = 24000,
	--装备熔炼
	EquipSmeltMain = 24100,
	--远程熔炼
	EquipSmelt = 24110,
	--宗派
	Guild = 50000,
	--宗派信息分类
	GuildFuncTypeInfo = 51000,
	--宗派分页-基础信息
	GuildTabBaseInfo = 51100,
	--宗派工资
	GuildWages = 51110,
	--宗派分页-成员信息
	GuildTabMemberInfo = 51200,
	--宗派分页-申请列表
	GuildTabApplyList = 51300,
	--宗派分页-仙盟列表
	GuildTabGuildList = 51400,
	--宗派红包
	GuildTabRedPackage = 51500,
	--宗派分页-战榜
	GuildTabRankList = 51600,
	--宗派仓库分类
	GuildFuncTypeRepertoy = 52000,
	--宗派宝箱分类
	GuildFuncTypeBox = 53000,
	--宗派分页-普通宝箱
	GuildTabBoxNomal = 53100,
	--宗派分页-稀有宝箱
	GuildTabBoxSpecial = 53200,
	--宗派活动分类
	GuildFuncTypeAction = 54000,
	--宗派分页-试炼boss
	GuildTabBoss = 54100,
	--宗派分页-篝火
	GuildTabExp = 54200,
	--宗派分页-答题
	GuildTabQuestion = 54300,
	--宗派分页-宗派战
	GuildTabPVP = 54400,
	--宗派分页-活跃宝贝
	GuildActiveBaby = 54500,
	--宗派分页-怪物入侵
	GuildTabMonster = 54600,
	--宗派分页-怪物攻城
	GuildTabMonsterIntrusion = 54700,
	--宗派创建
	GuildCreate = 55000,
	--宗派建筑
	GuildBuild = 56000,
	--宗派建筑升级
	GuildBuildLvUp = 56100,
	--宗派技能
	GuildSkill = 56200,
	--宗派任务（废弃）
	GuildTask = 56300,
	--仙盟任务副本入口
	GuildTaskCopyEnter = 56400,
	--宗派分页-捐献
	GuildTabDonate = 56500,
	--宗派战（仙盟战）
	GuildWar = 57000,
	--宗派Boss
	GuildBoss = 58000,
	--婚姻
	Marry = 60000,
	--婚宴预约
	MarryAppointment = 60100,
	--婚姻缔结
	MarryEngagement = 60200,
	--婚姻邀请
	MarryInvite = 60300,
	--婚姻入口
	MarryPrepare = 60400,
	--婚姻礼金
	MarryGifts = 60500,
	--婚姻流程
	MarryProcess = 60600,
	--婚姻求婚
	MarryType = 60700,
	--婚姻好友
	MarryFriend = 60800,
	--婚姻宝匣
	MarryBox = 60900,
	--婚姻情缘
	MarryBless = 61000,
	--婚姻信息
	MarryInfo = 61100,
	--婚姻仙居
	MarryHouse = 61200,
	--婚姻仙娃
	MarryChild = 61300,
	--婚宴请帖
	MarryBanquet = 61400,
	--婚姻心锁
	MarryHeartLock = 61500,
	--仙缘任务
	MarryTask = 61600,
	--挚友
	Intimate = 70000,
	--挚友创建
	IntimateBase = 71000,
	--挚友信息
	IntimateMember = 72000,
	--挚友权益
	IntimateWelfare = 73000,
	--游戏设置
	GameSetting = 120000,
	--系统设置
	SystemSetting = 121000,
	--造化
	Nature = 150000,
	--造化翅膀
	NatureWing = 151000,
	--造化翅膀升级
	NatureWingLevel = 151100,
	--造化翅膀吃丹分页
	NatureWingDrug = 151200,
	--造化翅膀化形
	NatureWingFashion = 151300,
	--造化翅膀模型外显
	NatureWingModelShow = 151400,
	--造化法宝
	NatureTalisman = 152000,
	--造化法宝升级
	NatureTalismanLevel = 152100,
	--造化法宝吃丹分页
	NatureTalismanDrug = 152200,
	--造化法宝化形
	NatureTalismanFashion = 152300,
	--造化法宝模型外显
	NatureTalismanModelShow = 152400,
	--造化阵法
	NatureMagic = 153000,
	--造化阵法升级
	NatureMagicLevel = 153100,
	--造化阵法丹分页
	NatureMagicDrug = 153200,
	--造化阵法化形
	NatureMagicFashion = 153300,
	--造化阵法模型外显
	NatureMagicModelShow = 153400,
	--造化神兵
	NatureWeapon = 154000,
	--造化神兵升级
	NatureWeaponLevel = 154100,
	--造化神兵吃药
	NatureWeaponDrag = 154200,
	--造化神兵化形
	NatureWeaponFashion = 154300,
	--造化神兵模型外显
	NatureWeaponModelShow = 154400,
	--法宝
	RealmStifle = 155000,
	--法宝子功能
	FaBaoSub = 155100,
	--法宝化形
	FaBaoHuaxing = 155110,
	--法宝升级
	FaBaoUpGrade = 155120,
	--法宝御魂
	FaBaoDrug = 155130,
	--法宝器灵
	FaBaoOrgan = 155200,
	--法宝进化
	FaBaoEvolution = 155210,
	--法宝晋升
	FaBaoPromote = 155220,
	--器灵激活
	FaBaoActive = 155230,
	--炼器
	LianQi = 160000,
	LianQiForgeUpgrade = 160100,
	LianQiForgeStrengthTransfer = 160110,
	LianQiForgeStrengthSplit = 160120,
	--锻造
	LianQiForge = 161000,
	--装备强化
	LianQiForgeStrength = 161100,
	--装备洗炼
	LianQiForgeWash = 161200,
	--装备合成子功能
	EquipSynthSub = 161300,
	--装备宝石
	LianQiGem = 162000,
	--宝石镶嵌
	LianQiGemInlay = 162100,
	--宝石精炼
	LianQiGemRefine = 162200,
	--仙玉镶嵌
	LianQiGemJade = 162300,
	--套装
	EquipSuit = 163000,
	--1级套装
	EquipSuitLevel1 = 163100,
	--2级套装
	EquipSuitLevel2 = 163200,
	--3级套装
	EquipSuitLevel3 = 163300,
	--灵体
	LingTi = 164000,
	--灵体
	LingTiMain = 164100,
	--灵体装备合成
	LingTiSynth = 164200,
	--灵星
	LingTiStar = 164300,
	--古籍
	LingtiFanTai = 165000,
	--神品装备
	GodEquip = 166000,
	--神装升星
	GodEquipStar = 166100,
	--神装升阶
	GodEquipUplv = 166200,
	--坐骑
	Mount = 170000,
	--坐骑基础面板
	MountBase = 171000,
	--坐骑基础属性
	MountBaseAttr = 171100,
	--坐骑吃装备
	MountEatEquip = 171110,
	--坐骑升级
	MountLevel = 171200,
	--坐骑吃果子
	MountDrug = 171300,
	--坐骑化形
	MountFashion = 171400,
	--坐骑模型外显
	MountModelShow = 171500,
	--坐骑装备
	MountEquip = 172000,
	--坐骑装备合成
	MountEquipSynth = 172100,
	--坐骑装备强化
	MountEquipStrength = 172200,
	--坐骑装备附魂
	MountEquipFuhun = 172300,
	--坐骑装备穿戴
	MountEquipWear = 172400,
	--坐骑助阵
	MountFight = 172500,
	--宠物
	Pet = 190000,
	--宠物属性详情
	PetProDet = 191100,
	--宠物属性御魂
	PetProSoul = 191200,
	--宠物进阶
	PetLevel = 192000,
	--宠物助阵
	PetEquip = 193000,
	--宠物装备合成
	PetEquipSynth = 193100,
	--宠物装备强化
	PetEquipStrength = 193200,
	--宠物装备附魂
	PetEquipFuhun = 193300,
	--宠物装备穿戴
	PetEquipWear = 193400,
	--宠物助阵
	PetFight = 193500,
	--福利
	Welfare = 200000,
	--登陆礼包
	WelfareLoginGift = 201000,
	--每日签到
	WelfareDailyCheck = 202000,
	--鸿蒙悟道
	WelfareWuDao = 204000,
	--兑换礼包
	WelfareExchangeGift = 207000,
	--等级礼包
	WelfareLevelGift = 208000,
	--更新公告
	UpdateNoticReward = 209000,
	--助战系统
	AssistFighting = 210000,
	--助战子功能神兽
	AssistFightingSub = 211000,
	--神兽
	MonsterAF = 211100,
	--神兽装备合成
	MonsterEquipSynth = 211200,
	--神兽装备强化
	MonsterEquipStrength = 211300,
	--圣装
	HolyEquip = 222000,
	--圣装穿戴
	HolyEquipDress = 222100,
	--圣装分解
	HolyEquipSplit = 222110,
	--圣装圣魂
	HolyEquipSoul = 222120,
	--圣装套装
	HolyEquipSuit = 222130,
	--圣装强化
	HolyEquipIntensify = 222200,
	--圣装觉醒
	HolyEquipCompose = 222300,
	--超值
	ChaoZhi = 230000,
	--成长基金
	WelfareInvestment = 203000,
	--巅峰基金
	WelfareIPeakFund = 203100,
	--特权卡
	WelfareCard = 205000,
	--特权卡tips
	WelfareCardTips = 205001,
	--每日礼包
	WelfareDailyGift = 206000,
	--附装
	AttachEquip = 240000,
	--幻装
	UnrealEquip = 250000,
	--幻魂
	UnrealEquipSoul = 251000,
	--幻装合成
	UnrealEquipSync = 252000,
	--竞技
	Arena = 1050000,
	--首席
	ArenaShouXi = 1051000,
	--竞技排行
	ArenaRank = 1051100,
	--竞技奖励
	ArenaReward = 1051200,
	--竞技战报
	ArenaFightInfo = 1051300,
	--巅峰竞技
	ArenaTop = 1052000,
	--巅峰竞技段位排行
	ArenaTopLvRank = 1052100,
	--巅峰竞技段位排行奖励
	ArenaTopLvRankAward = 1052200,
	--巅峰竞技段位奖励
	ArenaTopLvAward = 1052300,
	--巅峰竞技每日宝箱
	ArenaTopDailyBox = 1052400,
	--巅峰竞技自动匹配
	ArenaTopAutoMatch = 1052500,
	--巅峰竞技活动开启
	ArenaTopActive = 1052600,
	--排行榜基础界面
	RankBase = 1100000,
	--排行榜
	Rank = 1100010,
	--名人堂
	Celebrith = 1100020,
	--跨服排行榜
	CrossRank = 1100030,
	--成就系统
	ChengJiu = 1120000,
	--成就总览
	ChengjiuBase = 1121000,
	--BOSS主界面
	Boss = 1210000,
	--个人BOSS
	MySelfBoss = 1211000,
	--世界BOSS
	WorldBoss = 1212000,
	--BOSS之家
	BossHome = 1213000,
	--神兽岛
	SoulMonsterCopy = 1214000,
	--境界BOSS
	StatureBoss = 1215000,
	--境界BOSS连续挑战
	StatureBossContinue = 1215100,
	--套装BOSS
	WorldBoss1 = 1216000,
	--宝石BOSS
	WorldBoss2 = 1217000,
	--无限Boss
	WuXianBoss = 1218000,
	--火车BOSS
	TrainBoss = 1219000,
	--宗派福地
	FuDi = 1220000,
	--福地称号排行
	FuDiRank = 1221000,
	--福地boss
	FuDiBoss = 1222000,
	--福地论剑
	FuDiLj = 1223000,
	--福地商店
	FuDiShop = 1224000,
	--福地论剑排行奖励
	FuDiLjRnak = 1225000,
	--副本
	CopyMap = 1230000,
	--单人副本
	SingleCopyMap = 1231000,
	--万妖卷
	TowerCopyMap = 1231100,
	--大能遗府
	StarCopyMap = 1231200,
	--天界之门
	TJZMCopyMap = 1231300,
	--经验副本
	ExpCopyMap = 1232100,
	--组队副本
	TeamCopyMap = 1232000,
	--心魔副本
	XinMoCopyMap = 1232200,
	--五行副本
	WuXingCopyMap = 1232300,
	--商城
	Shop = 1240000,
	--元宝商城
	GoldShop = 1241000,
	--每日特惠
	DailyShop = 1241100,
	--常用道具
	NormalShop = 1241200,
	--绑元商城
	BindgoldShop = 1241300,
	--荣誉商城
	HonorShop = 1241400,
	--兑换商城
	ExchangeShop = 1242000,
	--积分商城
	IntegralShop = 1242100,
	--寻宝商城
	TreasureShop = 1242200,
	--阵道商城
	ArrayroadShop = 1242300,
	--帮贡商城
	ContributionShop = 1242400,
	--神秘限购
	LimitShop = 1242500,
	--限时折扣
	LimitDicretShop = 1243000,
	--限时折扣
	LimitDicretShop2 = 1244000,
	--九天争峰副本
	JiuTianCopy = 1250000,
	--交易行
	AuctionShop = 1260000,
	--跨服
	CrossServer = 1270000,
	--神兽岛
	GodIsland = 1271000,
	--八极阵图
	BaJiZhen = 1272000,
	--跨服福地
	CrossFuDi = 1273000,
	--坐骑装备副本
	MountECopy = 1274000,
	--犒赏令
	KaosOrder = 1274100,
	--荒古令
	HuangguOrder = 1274110,
	--魔王缝隙
	OyLieKai = 1275000,
	--混沌虚空
	CrossXuKong = 1276000,
	--练功房
	RealmExpMap = 1280000,
	--领地战
	TerritorialWar = 1290000,
	--领地战
	TerritorialWarMain = 1291000,
	--领地战名人堂
	TerritorialWarCelebrity = 1293000,
	--天墟战场商城
	TerritoriaShop = 1294000,
	--拍卖行
	Auchtion = 1300000,
	--世界拍卖
	AuchtionWorld = 1301000,
	--工会拍卖
	AuchtionGuild = 1302000,
	--我的竞拍
	AuchtionBuy = 1303000,
	--我的上架
	AuchtionSell = 1304000,
	--交易记录
	AuchtionRecord = 1305000,
	--我的关注
	AuchtionFollow = 1306000,
	--仙甲
	XianJia = 1310000,
	--仙级合成
	Xianji = 1311000,
	--仙佩合成
	XianPeiSyn = 1311100,
	--仙甲合成
	XianJiaSyn = 1311200,
	--副装合成
	SubEquip = 1311300,
	--魂甲合成
	HunJia = 1312000,
	--魂佩合成
	HunPeiSyn = 1312100,
	--魂甲合成
	HunJiaSyn = 1312200,
	--副装合成
	HunjiaSubEquip = 1312300,
	--仙甲兑换
	XianJiaExchange = 1313000,
	--仙甲背包
	XianjiaBag = 1314000,
	--第一套仙甲
	Xianjia1 = 1315000,
	--第一套仙甲八卦
	XianjiaBagua1 = 1315100,
	--第二套仙甲
	Xianjia2 = 1316000,
	--第二套仙甲八卦
	XianjiaBagua2 = 1316100,
	--第三套仙甲
	Xianjia3 = 1317000,
	--第三套仙甲八卦
	XianjiaBagua3 = 1317100,
	--第四套仙甲
	Xianjia4 = 1318000,
	--第4套仙甲八卦
	XianjiaBagua4 = 1318100,
	--仙甲八卦
	XianjiaBaGua = 1319000,
	--八卦合成
	BaGuaSyn = 1319100,
	--八卦兑换
	BaGuaExchange = 1319200,
	--八卦背包
	BaGuaBag = 1319300,
	--灵阁
	SpriteHome = 1320000,
	--剑灵
	FlySwordSprite = 1321000,
	--剑灵形态
	FlySwordSpriteBase = 1321100,
	--剑灵培养
	FlySwordSpriteTrain = 1321200,
	--剑灵升级
	FlySwordSpriteUpLv = 1321210,
	--剑灵进阶
	FlySwordSpriteUpGrade = 1321220,
	--仙魄主功能
	XianPoMain = 1321300,
	--仙魄镶嵌
	XianPoInlay = 1321310,
	--仙魄分解
	XianPoDecomposition = 1321320,
	--仙魄兑换
	XianPoExchange = 1321330,
	--仙魄合成
	XianPoSynthetic = 1321340,
	--仙魄拆解
	XianPoAnalyse = 1321350,
	--剑灵挂机
	FlySwordMandate = 1340000,
	--相亲墙
	MarryWall = 1350000,
	--相亲墙等级分页
	MarryWallLevel = 1351000,
	--相亲墙宣言分页
	MarryWallXuanYan = 1352000,
	--新服活动主入口
	XFHDMain = 1360000,
	--周福利主入口
	ZFLMain = 1370000,
	--魂甲
	SoulEquip = 1380000,
	--魂甲强化
	SoulEquipStrength = 1381000,
	--魂甲镶嵌
	SoulEquipInlay = 1382000,
	--神印阁
	SoulEquipLottery = 1382100,
	--神印强化
	SoulPearlStrength = 1382200,
	--神印分解
	SoulPearlSplit = 1382300,
	--神印穿戴
	SoulPearlWear = 1382400,
	--神印合成
	SoulPearlSynth = 1382500,
	--魂甲突破
	SoulEquipBreak = 1383000,
	--魂甲觉醒
	SoulEquipAweak = 1384000,
	--除魔团
	Slayer = 1390000,
	--加入除魔团
	SlayerJoin = 1391000,
	--开启除魔团
	SlayerCreate = 1392000,
	--角色
	Player = 2000000,
	--DiemTiemNang
	Point = 2000001,
	--角色属性
	Propetry = 2001000,
	--时装基础
	FashionableBase = 2001100,
	--时装衣服
	FashionableBody = 2001110,
	--时装主题
	FashionableTheme = 2001120,
	--时装装配
	FashionableAssemble = 2001200,
	--时装装配头像
	FashionableHead = 2001210,
	--时装装配头像框
	FashionableHeadFrame = 2001220,
	--时装装配气泡
	FashionableChatBg = 2001230,
	--时装装配步尘
	FashionableBuChen = 2001240,
	--角色识海
	PlayerJingJie = 2002000,
	--角色称号
	RoleTitle = 2003000,
	--查看其他玩家
	LookOtherPlayer = 2010000,
	--添加好友
	AddFriend = 2011000,
	--邀请组队
	InviteTeam = 2012000,
	--邀请入帮
	InviteGuild = 2013000,
	--私聊
	PrivateChat = 2015000,
	--屏蔽玩家
	Screen = 2020000,
	--社交
	Sociality = 2040000,
	--好友
	Friend = 2041000,
	--邮件
	Mail = 2042000,
	--任务
	Task = 2050000,
	--主线任务
	TaskMain = 2051000,
	--日常任务
	TaskDaily = 2052000,
	--宗派任务
	TaskGuild = 2053000,
	--支线任务
	TaskBranch = 2054000,
	--转职任务
	TaskZhuanZhi = 2059000,
	--区域地图
	AreaMap = 2060000,
	--组队
	Team = 2080000,
	--队伍界面
	TeamInfo = 2081000,
	--队伍匹配界面
	TeamMatch = 2082000,
	--队伍调整目标界面
	TeamModify = 2083000,
	--组队申请界面
	TeamApply = 2084000,
	--日常
	DailyActivity = 2100000,
	--每日活跃
	ActiveResult = 2101000,
	--资源找回
	ResBack = 2102000,
	--周历
	Calendar = 2103000,
	--限时
	LimitActivity = 2104000,
	--跨服展示
	CrossShow = 2105000,
	--目标任务
	TargetTask = 2106000,
	--结婚邀请
	MarryMain = 2220000,
	--参加婚宴
	MarryWed = 2230000,
	--离婚
	MarryDivoce = 2240000,
	--NPC对话
	TalkToNPC = 2270000,
	--巅峰等级
	DianFenLevel = 2370001,
	--离线挂机设置面板
	OnHookSettingForm = 2440000,
	--离线挂机结算面板
	OnHookForm = 2450000,
	--神魔战场
	ArenaSZZQ = 2460000,
	--天之禁地
	ArenaYZZD = 2470000,
	--神兵
	GodWeapon = 2480000,
	--神兵装配
	GodWeaponEquip = 2481000,
	--神兵头部装备
	GodWeaponEquipHead = 2481100,
	--神兵身体装备
	GodWeaponEquipBody = 2481200,
	--神兵特效装备
	GodWeaponEquipVfx = 2481300,
	--神兵预览
	GodWeaponPreview = 2482000,
	--境界
	Realm = 2490000,
	--境界化形
	RealmHuaxing = 2491000,
	--境界洗髓
	RealmXiSui = 2492000,
	--境界洗髓1
	RealmXiSuiLv1 = 2492100,
	--境界洗髓2
	RealmXiSuiLv2 = 2492200,
	--境界洗髓3
	RealmXiSuiLv3 = 2492300,
	--境界洗髓4
	RealmXiSuiLv4 = 2492400,
	--境界洗髓5
	RealmXiSuiLv5 = 2492500,
	--功能开启提示
	FuncOpenTips = 2500000,
	--功能分页
	FuncFuncPanel = 2501000,
	--模型分页
	FuncModelPanel = 2502000,
	--开服狂欢
	ServeCrazy = 2510000,
	--成长之路
	GrowthWay = 2520000,
	--开服活动
	ServerActive = 2530000,
	--宗派之星
	ZongPaiStar = 2531000,
	--境界达成
	JingJieReach = 2532000,
	--完美情缘
	PerfectQingYuan = 2533000,
	--宗派争霸
	ZongPaiFight = 2534000,
	--七日红包
	ServerRedPacket = 2535000,
	--集字兑换
	ServerExChange = 2536000,
	--每日累充
	DailyRechargeForm = 2540000,
	--寻宝
	TreasureHunt = 2550000,
	--机缘寻宝
	TreasureFind = 2551000,
	--仙魄寻宝
	TreasureXianPo = 2552000,
	--造化寻宝
	TreasureZaoHua = 2553000,
	--鸿蒙寻宝
	TreasureHongMeng = 2554000,
	--上古寻宝
	TreasureShangGu = 2555000,
	--无忧宝库
	TreasureWuyou = 2556000,
	--欢迎
	Welcome = 2560000,
	--世界答题
	WorldAnser = 2570000,
	--首充
	FirstCharge = 2580000,
	--服务器仓库
	ServerStore = 2590000,
	--打坐功能
	SitDown = 2600000,
	--续充
	ReCharge = 2610000,
	--服务器改名
	ChangeServer = 2620000,
	--焚天
	FireSky = 2630000,
	--独白窗口
	Soliloquy = 2640000,
	--假无限Boss入口
	UnlimitBoss = 2650000,
	--师门传道
	ChuanDao = 2660000,
	--变强
	BianQiang = 2670000,
	--世界篝火
	WorldBonfire = 2680000,
	--有奖问卷
	Question = 2690000,
	--超级会员
	VipBase = 2700000,
	--超级会员
	Vip = 2700010,
	--世界求援
	WorldSupport = 2710000,
	--周常基础
	VipWeekBase = 2720000,
	--周常
	VipWeek = 2721000,
	--领奖
	VipWeekReward = 2722000,
	--vip累计充值
	VipRecharge = 2730000,
	--修神锻体
	VipLianTi = 2740000,
	--充值Root
	Pay = 2750000,
	--基础充值
	PayBase = 2751000,
	--新手充值
	PayNewbie = 2752000,
	--周充值
	PayWeek = 2753000,
	--日充值
	PayDay = 2754000,
	--仙盟载具
	XMFightCar = 2760000,
	--仙甲寻宝
	XJXunbaoRoot = 2770000,
	--仙甲寻宝
	XJXunbao = 2771000,
	--仙甲仓库
	XJCangku = 2772000,
	--仙甲秘宝
	XJMibao = 2773000,
	--跨服聊天
	CrossChat = 2780000,
	--新时装
	NewFashion = 2790000,
	--时装
	Fashion = 2790090,
	--时装图鉴
	FashionTj = 2790100,
	--时装衣柜
	Wardrobe = 2791000,
	--更新有礼
	UpdateGift = 2792000,
	--聚宝盆
	Atm = 2800000,
	--功能预告
	FunctionNotice = 2810000,
	--下线提示
	ExitRewardTips = 2820000,
	--实名认证
	Certification = 2830000,
	--0元购
	FreeShop = 2840000,
	--0元购2
	FreeShop2 = 2841000,
	--VIP0元购
	FreeShopVIP = 2842000,
	--婚姻商店
	MarryShop = 2850000,
	--今日活动
	ActivityNotice = 2860000,
	--聊天
	Chat = 2870000,
	--转职洗髓
	ChangeJob = 2890000,
	--剑冢
	FlySwordGrave = 2900000,
	--运营活动
	YunYingHD = 2910000,
	--新服活动
	NewServerActivity = 3000000,
	--新服优势
	NewServerAdvantage = 3001000,
	--完美情缘
	PerfectLove = 3002000,
	--灵魄抽奖
	LingPoLottery = 3003000,
	--福利抽奖
	LuckyDrawWeek = 3004000,
	--珍藏阁
	ZhenCangGe = 3006000,
	--兑宝殿
	DuiBaoDian = 3006100,
	--玩家对比
	PlayerCompare = 3007000,
	--狂欢周
	WeekCrazy = 3008000,
	--周六狂欢
	CrazySat = 3008100,
	--周一狂欢
	CrazyMon = 3008200,
	--周二狂欢
	CrazyTue = 3008300,
	--周三狂欢
	CrazyWed = 3008400,
	--周四狂欢
	CrazyThur = 3008500,
	--周五狂欢
	CrazyFir = 3008600,
	--周日狂欢
	CrazySun = 3008700,
	--首杀
	FirstKill = 3009000,
	--邀请评分SDK弹窗
	ThaiScore = 3010000,
	--FB分享有礼
	ThaiShareGroup = 3010001,
	--FB分享有礼-分享
	ThaiShare = 3010002,
	--FB分享有礼-点赞
	ThaiLike = 3010003,
	--FB每日分享有礼-分享
	DayShare = 3010004,
	--幸运翻牌
	LucyCard = 3020000,
	--天禁令父功能
	TJLBase = 3030000,
	--天禁令
	TJL = 3031000,
	--天禁令每日任务
	TJLDailyTask = 3032000,
	--天禁令阶段任务
	TJLStepTask = 3033000,
	--天禁令除魔任务
	TJLChuMoTask = 3034000,
	--排行榜奖励（修仙宝鉴）
	RankAward = 3040000,
	--18+
	Eighteen = 3050000,
	--魔魂主界面
	DevilSoulMain = 3070000,
	--魔魂背包
	DevilSoulBag = 3071000,
	--魔魂突破
	DevilSoulSurmount = 3072000,
	--魔魂合成
	DevilSoulSynth = 3073000,
	--封魔台
	FengMoTai = 3074000,
	--社区主界面
	Community = 3080000,
	--自定义头像
	CustomHead = 3086000,
	--社区留言板
	MsgBoard = 3081000,
	--社区个人信息
	Presonel = 3082000,
	--家装大赛
	Decorate = 3083000,
	--仙府
	FairyHouse = 3084000,
	--个人动态
	Dynamic = 3085000,
	--仙侣对决
	LoversFight = 3090000,
	--仙侣海选赛
	LoversFreeFight = 3091000,
	--仙侣小组赛
	LoversGroupFight = 3092000,
	--仙侣冠军赛
	LoversTopFight = 3093000,
	--仙侣冠军赛地榜
	LoversTopFightL = 3093100,
	--仙侣冠军赛天榜
	LoversTopFightH = 3093200,
	--仙侣竞猜
	LoversPickFight = 3094000,
	--仙侣商城
	LoversShop = 3095000,
	--仙侣排行奖励
	LoversRankRewards = 3096000,
	--完美情缘
	PrefectRomance = 3100000,
	--完美情缘仙侣
	PrefectSpouse = 3101000,
	--完美情缘任务
	PrefectTask = 3102000,
	--完美情缘礼包
	PrefectGift = 3103000,
	--美情缘福袋
	PrefectPack = 3104000,
	--vip普通邀请
	VipInvationNormal = 3110000,
	--vip至尊邀请
	VipInvationZunGui = 3120000,
	--心法预览
	PreviewXinFa = 3130000,
	--Vip宝珠购买
	VipBaoZhu = 3140000,
	--Vip宝珠激活
	VipBaoZhuJiHuo = 3150000,
	--今日活动
	ToDayFunc = 3160000,
	--护送
	HuSong = 3170000,
	--v4助力
	V4HelpBase = 3180000,
	--v4助力
	VIPHelp = 3181000,
	--v4返利
	V4Rebate = 3182000,
	--返利宝箱
	RebateBox = 3183000,
	--仙盟争霸
	XMZhengBa = 3184000,
	--家园任务
	HomeTask = 3190000,
	--离线挂机找回
	OfflineFind = 3200000,
	--副本
	CopyMapMenu = 3210000,
	--Gm命令
	Gm = 9999999,
	--后台充值
	BackRecharge = 9999998,
	SpecialShop = 3220000,
	OrbShop = 3221000,
	--Escort
	Escort = 3230000,
	--EscortMap
	EscortMap = 3230001,
	--TrainBOSSMap
	TrainBOSSMap = 3230002,
	--PetHuaXing
	PetHuaXing = 191300,
	--Prison
	Prison = 3230010,
	--PrisonMap
	PrisonMap = 3230011,
	--TaskPrison
	TaskPrison = 3230012,
	--TaskDailyPrison
	TaskDailyPrison = 3230013,
	--Feedback
	Feedback = 3230200,
}

return FunctionStartIdCode
