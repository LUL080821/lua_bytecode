local ItemChangeReasonName = 
{
	--移动
	Move = 1001,
	--拆分
	Slip = 1002,
	--合并
	ComBin = 1003,
	--出库
	StoreToBag = 1004,
	--入库
	BagToStore = 1005,
	--背包整理
	BagClearUp = 1006,
	--仓库整理
	StoreClearUp = 1007,
	--仓库移动
	StoreMove = 1008,
	--手动删除消耗
	OwnDeleteDec = 1009,
	--开启背包格子消耗
	OpenBagCellDec = 1013,
	--开启仓库格子消耗
	OpenStoreCellDec = 1014,
	--达成成就获得
	AchievementGet = 1015,
	--好友物品培养增加亲密度消耗
	FriendSendItemAddValueDec = 1101,
	--背包到服务器仓库消耗
	BagServerStoreHouseDec = 1102,
	--挚友改名消耗
	ChumChangeNameDec = 1103,
	--玩家赠送
	FreindGiftGet = 1104,
	--玩家领取获得情义点奖励
	QingyiReciveGoodsGet = 1105,
	--玩家赠送获得情义点奖励
	QingyiSendGoodsGet = 1106,
	--创建帮会消耗
	CreateGuildDec = 1201,
	--帮会改名消耗
	ChangeGuildNameDec = 1202,
	--弹劾会长消耗
	GuildImpeachDec = 1203,
	--帮会捐献消耗
	GuildDonateDec = 1204,
	--玩家学习公会技能消耗
	GuildLearnSkillDec = 1205,
	--参加公会物品竞拍获得
	AuctionGet = 1206,
	--背包到公会仓库消耗
	BagGuildStoreHouseDec = 1207,
	--公会退出消耗
	GuildQuitDec = 1208,
	--加入公会消耗
	GuildJoinDec = 1209,
	--公会每日领取道具获得
	GuildReceiveItemGet = 1210,
	--帮会日常、周常一键完成单个任务消耗
	GuildTaskOneKeyDec = 1211,
	--公会建筑升级消耗
	GuildBuildExpDec = 1212,
	--公会维修基金消耗
	GuildFoundExpDec = 1213,
	--公会领取工资
	GuildGetItemGet = 1214,
	--仙盟任务刷新消耗
	GuildTaskRefreshDec = 1215,
	--仙盟战点赞
	GuildBattlePraiseGet = 1216,
	--仙盟boss奖励
	GuildBossRewardGet = 1218,
	--公会日常奖励获取
	GuildTaskGet = 1219,
	--公会周常奖励获取
	GuildTaskGet1 = 1220,
	--仙盟日常奖励获取
	GuildTaskGet2 = 1221,
	--公会日常奖励消耗
	GuildTaskDec = 1222,
	--公会周常奖励消耗
	GuildTaskDec1 = 1223,
	--仙盟日常奖励消耗
	GuildTaskDec2 = 1224,
	--仙盟战个人奖励
	GuildWarPersonalRewardGet = 1225,
	--仙盟boss鼓舞获得
	GuildBossInspireGet = 1230,
	--仙盟boss鼓舞消耗
	GuildBossInspireDec = 1231,
	--仙盟宝箱获得
	GuildGiftGet = 1232,
	--翅膀升级消耗
	WingUpDec = 1301,
	--坐骑进阶消耗
	HorseUpDec = 1401,
	--坐骑化形消耗
	HorseHuaxingDec = 1402,
	--坐骑吃药消耗
	HorseDrugDec = 1403,
	--坐骑装备穿戴消耗
	HorseEquipWearDec = 1420,
	--坐骑装备穿戴获得
	HorseEquipWearGet = 1421,
	--坐骑装备强化消耗
	HorseEquipIntenDec = 1422,
	--坐骑装备附魂消耗
	HorseEquipSoulDec = 1423,
	--坐骑装备升级消耗
	HorseEquipComposeDec = 1424,
	--坐骑装备升级获得
	HorseEquipComposeGet = 1425,
	--坐骑装备分解消耗
	HorseEquipDecomposeDec = 1426,
	--坐骑装备分解获得
	HorseEquipDecomposeGet = 1427,
	--坐骑装备激活消耗
	HorseEquipActiveDec = 1428,
	--坐骑装备自动分解获得
	HorseEquipAutoDecomposeGet = 1429,
	-- 魂甲抽奖获得
	SoulArmorLotteryGet = 1501,
	-- 魂甲抽奖消耗
	SoulArmorLotteryDec = 1502,
	-- 魂甲.魂印分解获得
	SoulArmorBallSplitGet = 1503,
	-- 魂甲.魂印分解消耗
	SoulArmorBallSplitDec = 1504,
	-- 魂甲.魂印卸下获得
	SoulArmorUnWearGet = 1505,
	-- 魂甲淬炼消耗
	SoulArmorUpDec = 1506,
	-- 魂甲突破消耗
	SoulArmorUpQualityDec = 1507,
	-- 魂甲觉醒消耗
	SoulArmorUpSkillLevelDec = 1508,
	-- 魂甲觉醒技能升级消耗
	SoulArmorUpSkillDec = 1509,
	-- 魂甲魂印孔位升级消耗
	SoulArmorUpSlotDec = 1510,
	-- 魂甲魂印穿戴消耗
	SoulArmorWearDec = 1511,
	-- 魂甲.魂印合成消耗
	SoulArmorBallMergeDec = 1512,
	--魂甲.魂印合成获得
	SoulArmorBallMergeGet = 1513,
	-- 魂甲双倍抽奖获得
	SoulArmorGoldLotteryGet = 1514,
	--仙甲兑换获得
	ExchangeImmortalEquipGet = 1601,
	--仙甲兑换消耗
	ExchangeImmortalEquipDec = 1602,
	--仙甲分解获得
	ResolveImmortalEquipGet = 1603,
	--仙甲分解消耗
	ResolveImmortalEquipDec = 1604,
	--仙甲穿戴镶嵌
	InlayImmortalEquip = 1605,
	--仙甲合成
	CompoundImmortalEquip = 1606,
	--仙甲寻宝消耗
	TreasureXianjiaHuntDec = 1607,
	--仙魄合成系统获得
	ImmortalcompoundGet = 1701,
	--仙魄合成系消耗
	ImmortalcompoundgetDec = 1702,
	--仙魄升级系统消耗
	ImmortalLevelUpDec = 1703,
	--仙魄分解获得
	ImmortalResolveGet = 1704,
	--仙魄分解消耗
	ImmortalResolveDec = 1705,
	--仙魄兑换获得
	ImmortalexchangeGet = 1706,
	--仙魄分解消耗
	ImmortalexchangeDec = 1707,
	--仙魄拆解获得
	ImmortalDismountingGet = 1708,
	--仙魄拆解消耗
	ImmortalDismountingDec = 1709,
	--神兵突破消耗
	WeaponUpDec = 1801,
	--神兵化形消耗
	WeaponHuaxingDec = 1802,
	--神兵升级消耗
	GodWeaponUplevelDec = 1803,
	--神兵磨具激活消耗
	GodWeaponActModleDec = 1804,
	--神兵升品消耗
	GodWeaponUpQualityDec = 1805,
	--神兵日常奖励获取
	DailyTaskGet1 = 1806,
	--神兵日常奖励消耗
	DailyTaskDec1 = 1807,
	--神兵日日常奖励获取
	DailyPrisonTaskGet1 = 1808,
	--神兵日日常奖励消耗
	DailyPrisonTaskDec1 = 1809,
	--宠物激活消耗
	PetActiveDec = 1901,
	--宠物升阶消耗
	PetStrengthDec = 1902,
	--宠物御魂消耗
	PetSoulDec = 1903,
	--宠物吞噬装备消耗
	PetEatEquipDec = 1904,
	--替换宠物装备获得
	ReplacePetEquipGet = 1905,
	--熔炼宠物装备扣除
	MeltPetEquipDec = 1907,
	--强化宠物装备扣除
	IntenPetEquipDec = 1908,
	--附魂宠物装备扣除
	SoulPetEquipDec = 1909,
	--合成宠物装备扣除
	ComposePetEquipDec = 1910,
	--主动分解宠物装备扣除
	DecomposePetEquipDec = 1911,
	--主动分解宠物装备获得
	DecomposePetEquipGet = 1912,
	--自动分解宠物装备扣除
	AutoDecomposePetEquipDec = 1913,
	--自动分解宠物装备获得
	AutoDecomposePetEquipGet = 1914,
	--激活宠物装备槽
	ActivePetEquipSlotDec = 1915,
	--穿戴宠物装备旧装备背包获得
	DressPetEquipGet = 1920,
	--穿戴宠物装备背包扣除
	DressPetEquipDec = 1921,
	--合成宠物装备获得
	ComposePetEquipGet = 1922,
	--阵法升级消耗
	MagicUpDec = 2001,
	--阵法化形消耗
	MagicHuaxingDec = 2002,
	--阵法吃药消耗
	MagicDrugDec = 2003,
	--阵法附灵消耗
	WeaponAffiliatedSpiritDec = 2101,
	--市集求购消耗
	MarketWantBuyDec = 2102,
	--市集求购商品下架获得
	MarketWantBuyDownBackGet = 2103,
	--市集交易下架获得
	MarketDownBackGet = 2104,
	--市集求购售卖消耗
	MarketWantBuySellDec = 2105,
	--市集求购获得
	MarketWantBuySellGet = 2106,
	--交易消耗
	TradeDec = 2107,
	--交易获得
	TradeGet = 2108,
	--交易卸下获得
	TradeUnloadGet = 2109,
	--交易取消获得
	TradeCancelGet = 2110,
	--交易失败获得
	TradeFailGet = 2111,
	--交易异常获得
	TradeExceptionGet = 2112,
	--拍卖行合成购买获得
	AuctionFastPurGet = 2113,
	--竞拍失败退回获得
	AuctionFailureGet = 2114,
	--拍卖成功获得
	AuctionSuccessfulGet = 2115,
	--出售成功获得
	SaleSuccessfulGet = 2116,
	--无人购买退回物品获得
	SaleFailureGet = 2117,
	--拍卖行下架获得
	AuctionOutGet = 2118,
	--拍卖行合成购买消耗
	AuctionFastPurDec = 2119,
	--购买市集的物品消耗
	MarketBuyItemDec = 2120,
	--贩卖市集的物品获得
	MarketSellItemGet = 2121,
	--市集中上架物品消耗
	MarketUpItemDec = 2122,
	--交易失败货币返回获得
	MarketBuyFailureGet = 2123,
	--集市邮件的附件领取获得
	MarketMailReceiveGet = 2124,
	--拍卖行竞价消耗
	AuctionPriceDec = 2125,
	--拍卖行上架消耗
	AuctionPutDec = 2126,
	--拍卖行一口价消耗
	AuctionPurDec = 2127,
	--神器升级消耗
	TalismanUpDec = 2301,
	--神器化形消耗
	TalismanHuaxingDec = 2302,
	--神器吃药消耗
	TalismanDrugDec = 2303,
	--穿上装备消耗
	WearEquipDec = 2401,
	--卸下装备获得
	UnWearEquipGet = 2402,
	--分解装备消耗
	ResolveEquipDec = 2403,
	--合成消耗
	CompoundDec = 2404,
	--装备出售消耗
	EquipSellDec = 2405,
	--装备神炼消耗
	EquipGodTriedDec = 2406,
	--装备合成消耗
	EquipSyntheticDec = 2407,
	--装备合成消耗
	EquipSyntheticSellDec = 2408,
	--装备套装消耗
	EquipSuitDec = 2409,
	--装备套装石合成消耗
	EquipSuitSynDec = 2410,
	--合成的装备拆解获得
	EquipSynSplitGet = 2411,
	--转换职业时删除装备消耗
	ChangeJobDeleteEquipDec = 2412,
	--合成新物品
	CompoundAdd = 2413,
	--装备部位强化消耗
	EquipPartStrengthenDec = 2414,
	--宝石镶嵌or卸下
	GemInlayDown = 2415,
	--仙玉镶嵌or卸下
	JadeInlayDown = 2416,
	--宝石精炼消耗
	GemRefineDec = 2417,
	--洗练消耗
	EquipWashDec = 2418,
	--洗髓消耗
	XiSuiDec = 2419,
	--合成获得
	CompoundGet = 2420,
	--回收炉删除装备获得
	RecycleGet = 2421,
	--回收炉删除装备消耗
	RecycleDec = 2422,
	--神品装备升星消耗
	ShenpinEquipUpStarDec = 2423,
	--神品装备升星获得
	ShenpinEquipUpStarGet = 2424,
	--神品装备升阶消耗
	ShenpinEquipUpStageDec = 2425,
	--神品装备升阶获得
	ShenpinEquipUpStageGet = 2426,
	--装备拆解消耗
	EquipSplitDec = 2427,
	--装备拆解获得
	EquipSplitGet = 2428,
	--GiamDinh
	EquipRaisalInfo = 2429,
	--TayCuongHoa
	EquipSplitRemove = 2430,
	--GoNgoc
	GemRemoveDown = 2431,
	--GoNgocVip
	JadeRemoveDown = 2432,
	--MoveLevel
	EquipSplitMove = 2433,
	--手动使用物品消耗
	OwnUseDec = 2501,
	--卖出物品消耗
	SellItemDec = 2502,
	--图鉴吞噬消耗
	CardSmeltDec = 2503,
	--开礼包获得
	OpenGiftGet = 2504,
	--角色改名卡道具消耗
	ChangeNameDec = 2505,
	--使用道具增加魅力消耗
	ItemUseAddIntimacyDec = 2506,
	--吃药消耗
	DrugDec = 2507,
	--经验丹经验获得
	ExpAddItemGet = 2508,
	--消费元宝卡元宝值获得
	UserItemCardGetGoldGet = 2520,
	--使用圣魂消耗
	UseHolySoulDec = 2521,
	--商城元宝消费获得
	ShopBuyGoldGet = 2601,
	--商城元宝消费消耗
	ShopBuyGoldDec = 2602,
	--商城消费获得
	ShopBuyCostGet = 2603,
	--商城消费消耗
	ShopBuyCostDec = 2604,
	--神秘限购商品
	LimitShop = 2610,
	--神秘限购商品获得
	LimitShopGet = 2611,
	--神秘限购商品消耗
	LimitShopDec = 2612,
	--神秘商店
	MyShopReward = 2620,
	--神秘商店获得
	MyShopRewardGet = 2621,
	--神秘商店消耗
	MyShopRewardDec = 2622,
	--任务完成奖励获得
	TaskRewardsGet = 2721,
	--任务完成奖励消耗
	TaskRewardsDec = 2722,
	--日常任务扣除消耗
	DailyTaskDec = 2702,
	--任务加倍完成消耗
	TaskFinishFanBeiDec = 2703,
	--主线任务奖励获得
	MainTaskRewardGet = 2704,
	--直线任务奖励获得
	BranchTaskRewardGet = 2705,
	--任务提交道具消耗
	TaskSubmitItemDec = 2706,
	--任务收集道具消耗
	CollectTaskSubmitItemDec = 2707,
	--领取护送任务消耗
	ReceiveEscortTaskCostDec = 2708,
	--日常任务一键完成单个任务消耗
	DailyTaskOneKeyDec = 2709,
	--领取任务目标奖励消耗
	TaskTargetRewardDec = 2710,
	--任务目标奖励获得
	TaskTargetRewardGet = 2711,
	--完成日常次数获得
	CompleteDailyGet = 2715,
	--日日常任务扣除消耗
	DailyPrisonTaskDec = 2716,
	--日日常任务一键完成单个任务消耗
	DailyPrisonTaskOneKeyDec = 2717,
	--圣装合成获得
	HolyEquipCompoundGet = 2801,
	--圣装分解获得
	HolyEquipResolveGet = 2802,
	--圣装合成消耗
	HolyEquipCompoundDec = 2803,
	--圣装镶嵌获得
	HolyInlayReasonGet = 2804,
	--圣装分解扣除消耗
	HolyEquipResolveDec = 2805,
	--结婚消耗
	GetMarriageDec = 2901,
	--强制离婚消耗
	ForceDivorceDec = 2902,
	--参加婚宴送礼金消耗
	CashGiftDec = 2903,
	--仙缘心锁升级消耗
	MarryLocalUpLevelDec = 2904,
	--婚姻仙居突破消耗
	MarryHouseBreakDec = 2905,
	--仙缘.情缘副本获得
	MarryCopyMapGet = 2906,
	--结婚--仙娃激活消耗
	MarryChildActiveDec = 2907,
	--结婚--仙娃升级消耗
	MarryChildLevelDec = 2908,
	--婚姻领取每日宝匣奖励获得
	MarryDailyBoxRewardGet = 2909,
	--婚姻领取宝匣返利奖励获得
	MarryRebateBoxRewardGet = 2910,
	--婚姻购买宝匣消耗
	MarryBoxBuyDec = 2911,
	--婚姻系统--对诗获得
	MarryPrayPoemGet = 2912,
	--婚姻系统--祈福收取果实获得
	MarryPrayGetAppleGet = 2913,
	--婚姻系统--领取亲密度奖励获得
	MarryIntimacyGet = 2914,
	--婚姻系统--满足条件称号获得
	MarryTitleGet = 2915,
	--婚宴操作--购买喜糖消耗
	WeddingBuyCandiesDec = 2916,
	--婚宴操作--购买礼炮消耗
	WeddingBuySaluteDec = 2917,
	--婚宴操作--购买烟花消耗
	WeddingBuyFireDec = 2918,
	--婚姻--三倍领取祈福果实获得
	MarryTripleGet = 2919,
	--婚姻-仙娃改名消耗
	MarryChildChangeNameDec = 2920,
	--结婚消耗
	MarryDec = 2921,
	--结婚宣言消耗
	MarryNoticeDec = 2922,
	--强制离婚消耗
	Force_Divorce_Dec = 2923,
	--婚礼赠送消耗
	WeddingSendDec = 2924,
	--婚礼购买消耗
	WeddingBuyDec = 2925,
	--婚礼使用消耗
	WeddingUseDec = 2926,
	--婚礼购买获得
	WeddingBuyGet = 2927,
	-- 仙缘任务获得
	MarryTaskGet = 2928,
	--仙缘奖励获得
	MarrySuccessGet = 2929,
	--婚宴获得
	MarryBossRewardGet = 2930,
	--仙缘-缘定三生
	MarryWall = 2931,
	--仙缘-缘定三生消耗
	MarryWallDec = 2932,
	--仙缘-缘定三生获得
	MarryWallGet = 2933,
	--发布爱情宣言获得
	PushMarryDeclarationGet = 2934,
	--发布爱情宣言消耗
	PushMarryDeclarationCost = 2935,
	--普通结婚消耗
	MarryGeneralDec = 2936,
	--高级结婚消耗
	MarryHigherDec = 2937,
	--豪华结婚消耗
	MarryLuxuryDec = 2938,
	--普通结婚获得
	MarryGeneralGet = 2939,
	--高级结婚获得
	MarryHigherGet = 2940,
	--豪华结婚获得
	MarryLuxuryGet = 2941,
	--完美情缘排名奖励获得
	MarryActivityRankGet = 2942,
	--完美情缘商店购买获得
	MarryActivityShopBuyGet = 2943,
	--完美情缘任务奖励获得
	MarryActivityTaskRewardGet = 2944,
	--婚姻副本购买热度消耗
	MarryCopyBuyHotDes = 2945,
	--完美情缘任务奖励获得
	MarryCopySigRewardGet = 2946,
	--情缘福袋回收
	MarryActivityGiftCost = 2947,
	--情缘福袋回收
	MarryActivityGiftGet = 2948,
	-- 婚礼祝福获得
	MarryBlessGiftGet = 2949,
	--激活称号消耗
	ActiveTitleDec = 3001,
	--邮件附件领取获得
	MailAttachReceiveGet = 3101,
	--邮件发送使用
	MailSentUse = 3102,
	--灵魄寻宝购买扣除
	SoulBuyDec = 3301,
	--灵魄寻宝购买赠送获得
	SoulBuySendGet = 3302,
	--灵魄寻宝抽奖扣除
	SoulHuntDec = 3303,
	--灵魄寻宝抽奖获得
	SoulHuntGet = 3304,
	--寻宝回收道具获得
	TreasureRecoveryGet = 3305,
	--寻宝回收道具扣除
	TreasureRecoveryCost = 3306,
	--剑灵阁领取收益
	SwordSoulTowerGet = 3401,
	--剑灵阁快速收益获得
	SwordSoulQuickRewardGet = 3402,
	--vip周奖励礼包奖励获得
	VipWeekGiftGet = 3502,
	--vip周奖励自动领取礼包奖励获得
	VipWeekAutoGiftGet = 3503,
	--vip充值奖励获得
	VipRechargeGiftGet = 3504,
	--VIP经验道具获得
	VipExpItemGet = 3505,
	--Vip目标奖励获得
	VipTargetRewardGet = 3506,
	--充值vip经验获得
	RechargeVipExpGet = 3507,
	--在线送vip经验获得
	OnlineVipExpGet = 3508,
	-- VIP经验版本修正获得
	VIPExpFixedGet = 3509,
	--购买vip礼包奖励
	VipPurGift = 3510,
	--购买vip礼包奖励获得
	VipPurGiftGet = 3511,
	--购买vip礼包奖励消耗
	VipPurGiftDec = 3512,
	--vip升级获得
	VipLevelUpGet = 3513,
	--vip珠宝使用获得
	VipPearlGet = 3514,
	--魂兽增加额外格子消耗
	SoulBeastAddExtendGridDec = 3601,
	--魂兽售卖道具和装备获得
	soulbestSellItemGet = 3602,
	--魂兽装备强化消耗
	SoulBeastStrengthenDec = 3603,
	--魂兽装备合成消耗
	SoulBeastMergeDec = 3604,
	--魂兽装备合成获得
	SoulBeastMergeGet = 3605,
	--魂兽售卖道具消耗
	SoulbestSellItemDec = 3606,
	--竞技场每日奖励获得
	JJCRewardGet = 3701,
	--首席竞技场获得
	JJCBattleGet = 3702,
	--竞技场首次达到排名奖励获得
	JJCFirstRewardGet = 3703,
	--竞技场购买次数消耗
	JJCBuyCountGetDec = 3704,
	--巅峰竞技场段位奖励获得
	PeekStageRewardGet = 3705,
	--巅峰竞技场场次奖励获得
	PeekTimesRewardGet = 3706,
	--巅峰竞技场挑战奖励获得
	PeekPkRewardGet = 3707,
	--竞技场排行奖励
	JJCRankGet = 3708,
	--福利：每日签到消耗
	WelfareDayCheckInDec = 3801,
	--福利：每日签到
	WelfareDayCheckIn = 3802,
	--福利：月卡尊享卡
	WelfareExclusiveCard = 3803,
	--福利：月卡尊享卡获得
	WelfareExclusiveCardGet = 3804,
	--福利：月卡尊享卡消耗
	WelfareExclusiveCardDec = 3805,
	--福利：感悟经验获得
	WelfareFeelingExpGet = 3806,
	--福利：感悟经验消耗
	WelfareFeelingExpDec = 3807,
	--福利：累计签到获得
	WelfareDayTotalCheckInGet = 3808,
	--福利：每日签到获得
	WelfareDayCheckInGet = 3809,
	--福利：感悟经验
	WelfareFeelingExp = 3810,
	--等级礼包获得奖励
	LevelGiftAdd = 3811,
	--vip每日礼包奖励
	VipDailyGift = 3812,
	--福利：感悟银币获得
	WelfareFeelingCoinGet = 3813,
	--福利：感悟银币消耗
	WelfareFeelingCoinDec = 3814,
	--福利：周卡
	WelfareCardWeek = 3815,
	--福利：周卡获得
	WelfareCardWeekGet = 3816,
	--成长基金
	WelfareGrowthFund = 3817,
	--福利：登陆礼包
	WelfareLoginGift = 3820,
	--福利：登陆礼包获得
	WelfareLoginGiftGet = 3821,
	--周福利幸运抽奖消耗
	LuckyDrawWeekDec = 3822,
	--周福利幸运抽奖获得
	LuckyDrawWeekGet = 3823,
	--等级礼包vip额外获得奖励
	LevelGiftVipAdd = 3824,
	--免费礼包 获得奖励
	WelfareFreeGiftGet = 3825,
	--转职消耗
	ChangeJobDec = 3901,
	--转职任务奖励获得
	GenderTaskRewardGet = 3902,
	--转职任务一键完成的时候扣除消耗
	GenderTaskOneKeyFinishDec = 3903,
	--转职任务一键完成
	GenderTaskOneKeyFinish = 3904,
	--转职阶段完成获得
	GenderStageFinishGet = 3905,
	--崇拜排行榜玩家奖励获得
	WorshipRewardGet = 4001,
	--掉落获得
	DropTinhChau = 4100,
	--掉落获得
	DropGet = 4101,
	--复活消耗
	ReliveDec = 4102,
	--小地图传送消耗
	MiniMapTransDec = 4103,
	--Pk消耗
	PkDec = 4104,
	--杀怪掉落获得
	DropByKillMonsterGet = 4105,
	--离线挂机获得
	HookOfflineGet = 4106,
	--在线打坐获得
	HookOnlineGet = 4107,
	--地图经验获得
	HookMapGet = 4108,
	--职业掉落获得
	ProDropGet = 4109,
	--采集掉落获得
	DropByGatherGet = 4110,
	--首杀红包奖励
	FirstKillRedPacket = 4112,
	--服务器首杀奖励
	ServerFirstKillReward = 4113,
	--共享掉落
	ShareDrop = 4114,
	--神兽岛采集获得
	SoulAnimalGatherDropGet = 4115,
	--恭喜获得服务器首杀奖励
	FirstKillBossKillRewardGain = 4116,
	--挂机经验找回获得
	HookFindTimeGet = 4117,
	--挂机经验找回扣除
	HookFindTimeDec = 4118,
	--掉落获得
	TaskDropGet = 4119,
	--通关副本获得
	CopyMapGet = 4201,
	--鼓舞消耗
	UpMoraleDec = 4202,
	--掉落获得
	DropByFightServerGet = 4203,
	--扫荡副本道具消耗
	SweepCloneUseItemDec = 4204,
	--星级副本星数奖励获得
	StarCopyRewardGet = 4205,
	--星级副本扫荡消耗
	StarCopySweepDec = 4206,
	--进入星级副本消耗
	StarCopyEnterDec = 4207,
	--vip副本次数购买消耗
	VipCopyMapBuyDec = 4208,
	--经验副本获得
	ExpCopyGet = 4209,
	--婚礼副本经验获得
	MarrigeCopyExpGet = 4210,
	-- 集字活动副本掉落
	HolidayActivityWordsCloneDrop = 4211,
	--副本合并消耗
	ZoneMergeDec = 4212,
	--仙缘.情缘副本
	MarryCopyMap = 4213,
	--boss之家进入消耗
	EnterBossHomeDec = 4301,
	--击杀Boss活动获得
	ActivityKillBossGet = 4302,
	--个人boss消耗
	PersonalBossDec = 4303,
	--boss击杀归属奖励获得
	BossOrdinaryGet = 4304,
	--boss次数特殊掉落获得
	BossRelationGet = 4305,
	--boss排名掉落获得
	BossRankGet = 4306,
	--boss阳光普照奖励获得
	BossCapitaGet = 4307,
	--购买boss排名奖励次数消耗
	BuyBossRankDec = 4308,
	--套装boss进入消耗
	SuitBossDec = 4309,
	--宝石boss进入消耗
	GemBossDec = 4310,
	--首杀boss个人击杀奖励获得
	PersonFirstKillRewardGet = 4311,
	--首领活动掉落获得
	HolidayBossDropGet = 4312,
	--首领活动礼包开启掉落获得
	HolidayBossGiftDropGet = 4313,
	--首领活动购买获得
	HolidayBossShopGet = 4314,
	--荒古神坛活动掉落
	HorseBossDropGet = 4315,
	--重置经脉获得
	MeridianRestGet = 4401,
	--重置经脉扣除消耗
	MeridianRestDec = 4402,
	--激活经脉扣除消耗
	MeridianActiveDec = 4403,
	--感谢支援玩家时被支援者的奖励获得
	WorldHelpThkAddGet = 4501,
	--感谢支援玩家时支援者的奖励获得
	WorldHelpThkAdd2Get = 4502,
	--BOSS死亡时被支援者的奖励获得
	WorldHelpBossDieAddGet = 4503,
	--BOSS死亡时支援者的奖励获得
	WorldHelpBossDieAdd2Get = 4504,
	--感谢支援玩家时扣除道具消耗
	WorldHelpThkDec = 4506,
	--GM后台移除物品消耗
	GMDeductItemDec = 4601,
	--后台功能扣除元宝值消耗
	BackServerGoldDec = 4602,
	--gm获得
	GM = 4603,
	--gm扣除
	GMDec = 4605,
	--gm获得
	GMGet = 4606,
	--GM来增加元宝获得
	GMToGetGoldGet = 4609,
	--后台过来增加元宝获得
	BackServerToRechargeGet = 4668,
	--识海升级消耗
	ShiHaiDec = 4701,
	--境界任务领奖获得
	StateVipRewardGet = 4802,
	--境界突破奖励获得
	StateVipUpRewardGet = 4803,
	--境界礼包购买获得
	StateGiftPurGet = 4804,
	--境界经验掉落获得
	StateVipExpDropGet = 4805,
	--境界副本挑战获取
	BossStateChanllageGet = 4806,
	--境界副本扫荡提取
	BossStateSawapGet = 4807,
	--升级境界灵压消耗
	UpLevelStateStifleDec = 4808,
	--购买境界boss进入次数消耗
	BuyBossStateVipCountDec = 4809,
	--蜕变消耗
	MentalSkillTuibianDec = 4901,
	--心法升级消耗
	MentalUpDec = 5001,
	--掌门传道经验获得
	LeaderPreachAddExpGet = 5101,
	--掌门传道道具奖励获得
	LeaderPreachRewardGet = 5102,
	--掌门传道扣除
	LeaderPreachDec = 5103,
	--寻宝消耗
	TreasureHuntDec = 5204,
	--寻宝获得
	TreasureHuntGet = 5205,
	--寻宝提取获得
	TreasureHuntExtractGet = 5206,
	--寻宝处购买消耗
	TreasureHuntBuyDec = 5207,
	--寻宝处购买获得
	TreasureHuntBuyGet = 5208,
	--寻宝仓库一键提取获得
	TreasureStoreOnekeyExtractGet = 5209,
	--秘宝获得
	TreasureHuntMibaoGet = 5210,
	--仙甲寻宝获得
	TreasureHuntXJGet = 5211,
	--仙甲寻宝奖励获得
	TreasureHuntXJAwardGet = 5212,
	--聚宝盆领取获得
	AgateGet = 5301,
	--聚宝盆奖池领取获得
	AgatePoolGet = 5302,
	--灵压法宝升级消耗
	StiflefFaBaoUpDec = 5403,
	--法宝器灵激活升级消耗
	SoulSpiritDec = 5404,
	--法宝日常奖励获取
	DailyTaskGet = 5405,
	--法宝日日常奖励获取
	DailyPrisonTaskGet = 5406,
	--时装升星消耗
	FashionStarUpDec = 5606,
	--时装激活消耗
	ActiveFashionDec = 5607,
	--时装发型该表消耗
	FashionHairChangeDec = 5608,
	--ActiveDoGiam
	ActiveFashionDoGiamDec = 5609,
	--UpStarFashionDoGiam
	FashionDoGiamStarUpDec = 5610,
	--激活神兽消耗
	ActiveMythicalDec = 5701,
	--技能等级升级消耗
	SkillLevelUpDec = 5801,
	--心法被动技能升级消耗
	MentalSkillUp = 5802,
	--新技能格子升级
	NewSkillUpCellDec = 5803,
	--新技能升星
	NewSkillUpstarDec = 5804,
	--升级血脉系统消耗
	UpBloodDec = 5901,
	--灵体放入或替换装备获得
	SpiritGet = 6001,
	--灵体放入或替换装备消耗
	SpiritDec = 6002,
	--灵体解封消耗
	SpiritStartUseDec = 6003,
	--服务器改名消耗
	ChangeServerNameDec = 6101,
	--新服活动奖励
	NewActive = 6103,
	--平台评价点赞奖励获得
	PlatformEvaluateLike = 6105,
	--平台评价分享奖励获得
	PlatformEvaluateShare = 6106,
	--平台评价每日分享奖励获得
	PlatformEvaluateEveryDayShare = 6107,
	--商店评价引导奖励获得
	ShopCommentRewardsGet = 6108,
	--犒赏令-荒古令获得
	KaoShangLingHorseGet = 6201,
	--犒赏令-荒古令消耗
	KaoShangLingHorseDec = 6202,
	--犒赏令-荒古令购买高级消耗
	KaoShangLingHorseBuySpecailDec = 6203,
	--魔魂升级消耗
	DevilCardLevelUpCost = 6301,
	--魔魂升阶消耗
	DevilCardRankUpCost = 6302,
	--魔魂突破消耗
	DevilCardBreakCost = 6303,
	--魔魂解锁消耗
	DevilCardUnlockCost = 6304,
	--魔魂装备合成消耗
	DevilEquipSynthesisCost = 6305,
	--魔魂装备合成获得
	DevilEquipSynthesisGet = 6306,
	--魔魂装备穿戴获得
	DevilEquipWearGet = 6307,
	--魔魂装备穿戴消耗
	DevilEquipWearCost = 6308,
	--封魔台高级抽奖获得
	DevilHunt1Get = 6310,
	--封魔台中级抽奖获得
	DevilHunt2Get = 6311,
	--封魔台低级抽奖获得
	DevilHunt3Get = 6312,
	--除魔团副本开启扣除
	DevilCopyMapCost = 6313,
	--除魔团副本获得
	DevilCopyMapGet = 6314,
	--挚友等级提升获得
	IntimateLevelUpGet = 6401,
	--仙府送礼
	HouseGiftCost = 6501,
	--仙府商店购买
	HouseShopCost = 6502,
	--仙府商店获得
	HouseShopGet = 6503,
	--家装大赛获得
	HouseMatchGet = 6504,
	--任务获得
	HouseTaskGet = 6505,
	--投票获得
	HouseVoteGet = 6506,
	--房屋升级消耗
	HouseLevelUpCost = 6507,
	--房屋聚宝盆获得
	HouseTupGet = 6508,
	--幻装合成消耗
	UnrealEquipCompoundDec = 6601,
	--幻装合成获得
	UnrealEquipCompoundGet = 6602,
	--幻装镶嵌获得
	UnrealInlayReasonGet = 6603,
	--幻装拆解扣除消耗
	UnrealEquipResolveDec = 6604,
	--幻装拆解获得
	UnrealEquipResolveGet = 6605,
	--使用幻魂消耗
	UseUnrealSoulDec = 6606,
	--激活命星消耗
	ActiveFateStarDec = 9901,
	--篝火升级消耗
	WorldBonfireLevelDec = 50001,
	--篝火猜拳领奖获得
	WorldBonfireRewardGet = 50002,
	--篝火经验获得
	WorldBonfireExpGet = 50003,
	--篝火获取经验获得
	BonfireExpGet = 50004,
	--资源找回消耗
	RetrieveResDec = 50101,
	--资源完美找回奖励
	RetrieveResAdd = 50102,
	--资源部分找回奖励
	RetrieveResPartAdd = 50103,
	--太虚战场奖励
	UniverseReward = 50201,
	--联赛每月奖励获得
	LeagueMonthlyRewardGet = 50301,
	--联赛每周奖励获得
	LeagueWeeklyRewardGet = 50302,
	--世界答题获得
	WorldAnswerGet = 50401,
	--世界答题结束获得
	WorldAnswerOverGet = 50402,
	--位面奖励获得
	PlaneRewardGet = 50501,
	--藏宝阁抽奖获得
	CangbaogeLotteryGet = 50601,
	--藏宝阁兑换获得
	CangbaogeExchangeGet = 50602,
	--藏宝阁领奖获得
	CangbaogeRewardGet = 50603,
	--藏宝抽奖消耗
	CangbaogeLotteryDel = 50604,
	--藏宝兑换消耗
	CangbaogeExchangeDel = 50605,
	-- 跨服福地解锁消耗
	CrossFudUnLockCost = 50701,
	--跨服福地积分获得
	CrossFudScoreBoxGain = 50702,
	--跨服福地城市占领获得
	CrossFudCityBoxGain = 50703,
	--跨服福地Boss归属获得
	CrossFudBossOwnGain = 50704,
	--跨服魔王Boss归属获得
	CrossDevilBossOwnGain = 50705,
	--八级阵图城市占领奖励
	EightCityParticipantReward = 50801,
	--八级阵图积分奖励
	EightCityIntegralReward = 50802,
	--实名认证奖励
	NameCertificationAward = 50901,
	--使用激活码获得物品
	ActiveCodeGetContentGain = 51001,
	--混沌名人堂第一阶段结束
	UniveresRankEnd = 51101,
	--分享奖励
	ShareRewardGain = 51201,
	-- 福地论剑获得
	GuildFudGain = 51301,
	--更新有礼获得
	UpdateRewardGet = 51401,
	--荣耀之战领奖获得
	BraveGloryRewardGet = 51501,
	--充值元宝获得
	RechargeAddGoldGet = 51601,
	--充值活动获得
	ActivityRechargeGet = 51602,
	--充值赠送获得
	RechargeRewardGet = 51603,
	--充值源代码
	RechargeSourceCode = 51605,
	--周末狂欢充值获得（BI统计使用）
	CrazyWeekend = 51606,
	--充值获得（BI统计使用）
	Charge = 51607,
	--充值新手礼包获得（BI统计使用）
	ChargeNewPlayer = 51608,
	--充值每日礼包获得（BI统计使用）
	ChargeEverydayGift = 51609,
	--充值每周礼包获得（BI统计使用）
	ChargeEveryWeekFGift = 51610,
	--充值超值折扣获得（BI统计用）
	Chaozhizhekou = 51611,
	--跨服领地战上一轮奖励获得
	ManorLastRewardGet = 51701,
	--首充赠送获得
	FirstRechargeGet = 51801,
	--百元首充获得（BI统计使用）
	hundredFirstRecharge = 51802,
	--领取活跃度奖励获得
	ActiveRewardGet = 51901,
	--活跃度每日清零
	ActivePointDailyClear = 51903,
	--活跃日常奖励获取
	DailyTaskGet2 = 51904,
	--活跃日常奖励消耗
	DailyTaskDec2 = 51905,
	--活跃日日常奖励获取
	DailyPrisonTaskGet2 = 51906,
	--活跃日日常奖励消耗
	DailyPrisonTaskDec2 = 51907,
	--点击红包获得的金币值获得
	RedPacketClickGet = 52001,
	--提交红包扣除的货币值消耗
	RedPacketSubmitDelDec = 52002,
	--退还红包获得
	RedPacketRebateGet = 52003,
	--万人之上奖励获得
	AllMenUpAwardGet = 52201,
	--宗派玩法--福地日常奖励获得
	GuildActivityDayRewardGet = 52301,
	--宗派玩法--福地boss掉落获得
	GuildActivityBossDropGet = 52302,
	--宗派玩法--福地排名获得
	GuildActivityRankGet = 52303,
	--功能领奖获得
	FunctionRewardGet = 52401,
	--成长基金获得
	WelfareGrowthFundGet = 52501,
	--成长基金消耗
	WelfareGrowthFundCost = 52502,
	--开服狂欢获得
	OpenServerAcGet = 52601,
	--开服成长之路领取获得
	OpenServerGrowPointGet = 52602,
	--开服成长之路积分领取获得
	OpenServerGrowPointRewardGet = 52603,
	--开服成长之路购买获得
	OpenServerGrowupPurGet = 52604,
	--开服特殊活动
	OpenServerSpecAc = 52605,
	--开服特殊活动兑换
	OpenServerSpecAcExchange = 52606,
	--开服幸运翻牌活动获得
	LuckyCardGet = 52607,
	--新服优势奖励
	NewServerAdvantage = 52608,
	--V4返利获得
	V4RebateGet = 52609,
	--v4助力投资领取奖励
	V4GetAwardGet = 52610,
	--v4助力被投资领取奖励
	V4GetAward1Get = 52611,
	--v4助力消耗
	V4HelpOtherCost = 52612,
	--开服返利宝箱获得
	RebateBoxGet = 52613,
	--开服仙盟争霸获得
	XMZBGet = 52614,
	--神魔战场奖励获得
	GodDevilRewardGet = 52701,
	--有奖问卷获得
	QuestionaireReward = 52801,
	--开启特殊宝箱
	OpenSpecialGift = 52901,
	--开服活动预告奖励
	OpenServerAcNoticeReward = 52907,
	--修神断体奖励
	VipRechargeReward = 53001,
	--下载奖励
	DownloadReward = 53101,
	--0元购
	FreeShopReward = 53201,
	--购买人数上限消耗
	PurInviteNum = 53202,
	--0元购
	FreeShopCost = 53203,
	--新零元购
	NewFreeShowCost = 53204,
	--新零元购
	NewFreeShopReward = 53205,
	--元宝超值折扣
	GoldDiscountCost = 53206,
	--元宝超值折扣
	GoldDiscountReward = 53207,
	--免费超值折扣
	FreeDiscountReward = 53208,
	--免费元宝超值折扣
	FreeGoldDiscountReward = 53209,
	--更新公告奖励的领取
	UpdateNoticeAwardGet = 53301,
	--每日充值获得
	DailyRechargeget = 53401,
	--每日消耗获得
	DailyConsumeget = 53402,
	--首领活动购买消耗
	HolidayBossShopCost = 53501,
	--节日许愿活动临时仓库提取
	FestvialWishExtract = 53601,
	--天禁令获得
	FallingSkyGet = 53701,
	--天禁令扣除
	FallingSkyDec = 53702,
	--天禁令奖励
	FallingSkyRewardGain = 53703,
	--天禁令任务奖励获得
	FallingSkyTaskRewardGain = 53704,
	--天禁令等级奖励获得
	FallingSkyLevelRewardGain = 53705,
	--等级升级获得
	LevelChangeGet = 53801,
	--限时活动排行榜领取获得【修仙宝鉴】
	ActivityRankGet = 53901,
	--全服狂欢排行奖励
	SeverCrazyRankRewardGain = 54001,
	--全服狂欢个人奖励
	SeverCrazyPersonalReward = 54002,
	--天虚战场获得
	UniverseGet = 54101,
	--巅峰基金获得
	InvestPeakGet = 54201,
	--巅峰基金消耗
	InvestPeakCost = 54202,
	--仙侣对决海选赛战斗获得
	CoupleFightTrialsFightGet = 54301,
	--仙侣对决小组赛战斗获得
	CoupleFightGroupsFightGet = 54302,
	--仙侣对决冠军赛地榜战斗获得
	CoupleFightDiFightGet = 54303,
	--仙侣对决冠军赛天榜战斗获得
	CoupleFightTianFightGet = 54304,
	--仙侣对决小组赛排名获得
	CoupleFightGroupsRankGet = 54305,
	--仙侣对决冠军赛地榜排名获得
	CoupleFightDiRankGet = 54306,
	--仙侣对决冠军赛天榜排名获得
	CoupleFightTianRankGet = 54307,
	--仙侣对决竞猜消耗
	CoupleFightGuessCost = 54308,
	--仙侣对决竞猜获得
	CoupleFightGuessGet = 54309,
	--仙侣对决海选赛奖励获得
	CoupleFightTrialsAwardGet = 54310,
	--仙女护送扣除
	CoupleEscortCost = 54311,
	--仙女护送获得
	CoupleEscortGet = 54312,
	--仙女护送获得
	CoupleShopGet = 54313,
	--仙女护送扣除
	CoupleShopCost = 54314,
	--无忧宝库寻宝消耗
	WuyouHuntCost = 54401,
	--无忧宝库寻宝获得
	WuyouHuntGet = 54402,
	--无忧宝库免费获得
	WuyouHuntFreeGet = 54403,
	--无忧宝库提取获得
	WuyouHuntExtractGet = 54404,
	--功能任务获得
	FunctionTaskGet = 54501,
	--功能任务充值获得
	FunctionTaskRechargeGet = 54502,
	--混沌虚空宝库获得
	AlienGemGet = 54601,
	--充值返利获得
	RechargeRebateGet = 54701,
	--化形消耗
	HuaxingDec = 990075,
	--活跃兑换获得
	GetActiveActivityGet = 100100000,
	--活跃币的获得
	GetActiveCoinActiveActivity = 100100001,
	--我要变强的每日充值专属礼包获得
	DailyRechargeRewardGet = 100200001,
	--运营活动限时登陆获得
	LimitTimeLoginActivityGet = 100300001,
	--运营活动限时登陆高级获得
	LimitTimeLoginActivityHighGradeGet = 100300002,
	--限购礼包获得
	LimitGiftBagAcitvityGet = 100400001,
	--限购礼包消耗
	LimitGiftBagAcitvityDec = 100400002,
	--天帝宝库普通
	DailyDraw = 100500000,
	--天帝宝库轮次奖励活动获得
	DailyDrawRollGet = 100500002,
	--天帝宝库进度奖励获得
	DailyDrawPrcGet = 100500003,
	--天帝宝库扣除
	DailyDrawCost = 100500004,
	--天帝宝库翻卡牌
	DailyDrawOpenCard = 100500005,
	--天帝宝库翻卡牌获得
	DailyDrawOpenCardGet = 100500006,
	--天帝宝库翻卡牌扣除
	DailyDrawOpenCardDec = 100500007,
	--运营活动限时累充获得
	RechargeTotalActivityGet = 100600000,
	--运营活动限时消耗获得
	TotalConsumeActivityGet = 100700001,
	--集物兑换获得
	CollectGoodsExchangeGet = 100800001,
	--集物兑换扣除
	CollectGoodsExchangeDel = 100800002,
	--运营活动团购活动获得
	GroupBuyActivityGet = 100900001,
	--运营活动团购活动消耗
	GroupBuyActivityDec = 100900002,
	--运营活动团购活动返还获得
	GroupBuyActivityReturnGet = 100900003,
	--运营活动招财猫获得
	ActivityLuckyCatGet = 101000001,
	--运营活动招财猫消耗
	ActivityLuckyCatDec = 101000002,
	--运营活动幸运宝玉获得
	ActivityLuckyCat2Get = 101000003,
	--运营活动幸运宝玉消耗
	ActivityLuckyCat2Dec = 101000004,
	-- 庆典任务获得
	HolidayActivityTaskGet = 101200001,
	-- 集字活动扣除
	HolidayActivityWordsCost = 101300001,
	-- 集字活动兑换
	HolidayActivityWordsGet = 101300002,
	--节日特惠活动获得
	FestivalPreferenceGet = 101400000,
	--连续充值获得
	ContinuousRechargeGet = 101500000,
	--每日充值活动获得
	DailyRechargeAcitvityGet = 101500200,
	--每日充值累计奖励获得
	DailyRechargeAcitvityTotalGet = 101500201,
	--限购商城获得
	LimitShopActivetyGet = 101600001,
	--限购商城扣除消耗
	LimitShopActivetyDec = 101600002,
	--限时礼包活动购买消耗
	LimitTimeGiftActivityBuyDec = 101700001,
	--限时礼包活动购买获得
	LimitTimeGiftActivityGet = 101700002,
	-- 庆典积分获得
	HolidayActivityScoreRankReachGet = 101800001,
	--节日许愿活动消耗
	FestvialWishCost = 101900000,
	--节日许愿活动获得
	FestvialWishGet = 101900001,
	--节日许愿积分奖励获得
	FestvialWishScoreAwardGet = 101900002,
	--圣诞分享活动获得
	FBShareChristmasActivityGet = 102000001,
	--元旦分享活动获得
	FBShareNewYearActivityGet = 102000002,
	--连续充值2充值获得
	ContinuousRechargeGet2 = 102100000,
	--连续充值2累计天数获得
	ContinuousRechargeDaysGet2 = 102100001,
	--新年祝福活动签到获得
	NewYearWishSignGet = 102200001,
	--新年祝福活动补签消耗
	NewYearWishSignCost = 102200002,
	--掷骰子
	DiceRewardGain = 102300000,
	--掷骰子通关次数奖励
	DicePlayerTimesGet = 102300001,
	--掷骰子跳格子奖励
	DiceGridGet = 102300002,
	--掷骰子通关奖励
	DiceCrossGet = 102300003,
	--掷骰子消耗
	DiceCost = 102300004,
	--聚宝盆抽奖获得
	CornucopiaGet = 102600000,
	--聚宝盆抽奖消耗
	CornucopiaCost = 102600001,
	--聚宝盆元宝池抽奖获得
	CornucopiaGoldGet = 102600002,
	--聚宝盆次数奖励获得
	CornucopiaCountGet = 102600003,
	--聚宝盆活跃奖励获得
	CornucopiaActiveGet = 102600004,
	--砸金蛋抽奖获得
	SmashEggGet = 102700000,
	--砸金蛋抽奖消耗
	SmashEggCost = 102700001,
	--砸金蛋刷新消耗
	SmashEggRefreshCost = 102700002,
	--砸金蛋次数奖励获得
	SmashEggCountGet = 102700003,
	--砸金蛋在线时长奖励获得
	SmashEggOnlineGet = 102700004,
	--方泽探宝抽奖获得
	FZTBActivityGet = 102900001,
	--方泽探宝抽奖消耗
	FZTBActivityDec = 102900002,
	--方泽探宝抽9次奖励获得
	FZTBActivityDraw9Get = 102900003,
	--方泽探宝重置抽奖消耗
	FZTBActivityResetDrawMapDec = 102900004,
	--PhanThuongNhiemVuNhaGiamNhanDuoc
	PrisonTaskRewardGet = 102900005,
	--PhanThuongDacBietTuBossDaNgoai
	FieldBossGet = 102900006,
}

return ItemChangeReasonName
