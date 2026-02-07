local FunctionVariableIdCode = 
{
	--玩家等级
	PlayerLevel = 1,
	--玩家任务ID
	PlayerTaskID = 2,
	--玩家战力到达多少
	PlayerPower = 3,
	--技能总等级达到X级
	SkillCountLevel = 4,
	--每日进行X次竞技
	ArenaChallenge = 5,
	--杀死boss怪数量
	KillBOSS = 6,
	--累计登录N天
	CumulativeLogin = 7,
	--累计消耗X绑定元宝
	ConsumeBindDiamonds = 8,
	--消耗X元宝
	ConsumeDiamonds = 9,
	--转职到XX
	ChangeJob = 10,
	--加入宗派
	Joinguild = 11,
	--当天活跃点增加到X
	CurDayActiveValue = 12,
	--参与X次勇者之巅
	YZZD = 13,
	--杀死boss怪数量 条件id_bossid_boss数量
	KillSpecialBoss = 14,
	--穿戴X件X阶及以上的X色X星装备,条件id_阶数id_品质id_星数_件数
	WornEquip = 15,
	--激活XX符咒_激活数量
	Getamulet = 16,
	--部位装备的阶数,枚举id_部位id_阶数
	OrderEquip = 17,
	--成就点达到X点
	AchievementPoints = 18,
	--境界等级
	StateLevel = 19,
	--装备强化总等级
	EquipStrengthenLevelMax = 20,
	--装备洗练次数
	EquipWashingNum = 21,
	--所有部位镶嵌的普通宝石总等级
	GemLevelMax = 22,
	--装备X阶以上套装件数,装备阶数_件数
	EquipSuitNum = 23,
	--翅膀展示激活指定的id
	WingsActivateID = 24,
	--阵法达到X级
	MagicLevel = 25,
	--法器达到X级
	TalismanLevel = 26,
	--累计打坐X小时
	MeditationTime = 27,
	--累计开启背包格子数量
	OpenBackpackNum = 28,
	--识海达到的阶数
	ShiHaiLevel = 29,
	--累计完成日常经验任务次数
	RiChangJingYanNum = 30,
	--累计完成日常银币任务次数
	RiChangYinBiNum = 31,
	--累计宗派日常任务次数
	GuildRiChangNum = 32,
	--累计宗派周常任务次数
	GuildZhouChangNum = 33,
	--参加大能遗府次数
	DaNengYiFuNum = 34,
	--参加万妖卷层数
	WanYaoJuanNum = 35,
	--绑定金币累计达到x
	Boundgold = 36,
	--翅膀达到X级
	WingNum = 37,
	--坐骑达到X阶数
	HorseNum = 38,
	--神兵达到X阶数
	WeaponNum = 39,
	--累计竞技场次数
	ArenaNum = 40,
	--累计参加天之禁地次数（新名字：天芒鬼城）
	ForbiddenAreaNum = 41,
	--累计参加神魔战场次数（新名字：天道秘境）
	GhostBattlefieldNum = 42,
	--合成X阶及以上装备X件(废弃,ID:55已经拥有)
	SynthesisEquipNum = 43,
	--完成X个当前境界的任务
	StateTask = 44,
	--激活命星X个
	ChangeJobFateStar = 45,
	--完成转职任务的id
	ChangeJobclone = 46,
	--激活五转第1阶段龙魂
	ChangeJobDragonSoul_1 = 47,
	--激活五转第2阶段龙魂
	ChangeJobDragonSoul_2 = 48,
	--激活五转第3阶段龙魂
	ChangeJobDragonSoul_3 = 49,
	--创建1个宗派
	GuildCreate = 50,
	--拥有X个副宗主
	GuildOffice = 51,
	--宗派成员到达X个
	GuildMembNub = 52,
	--宗派等级到达X级
	GuildLevel = 53,
	--完成X级别的结婚
	MarrageLevel = 54,
	--合成X件X阶及以上的X色X星装备,条件id_阶数id_品质id_星数_件数
	ComposeEquip = 55,
	--宠物等级到达X级
	PetLevel = 56,
	--进行X次宠物升阶
	PetNum = 57,
	--宠物兽魂培养X次
	PetSoul = 58,
	--坐骑御魂培养X次
	HorseSoul = 59,
	--领取X次登陆礼包
	LandGiftReceive = 60,
	--在服务器仓库捐献X次
	ServerStoreDonate = 61,
	--神兵锻造等级到达X级，神兵ID_锻造等级
	Special_Weapon_level = 62,
	--宠物吞噬X次
	PetDevour = 63,
	--仙魄达到总等级XX
	ImmortalSou = 64,
	--大能遗府获得总星数XX
	DanengYifuStar = 65,
	--法宝(灵压法宝)达到x等级
	MagicWeapon = 66,
	--击杀XX场景idXX个boss
	SceneBoss = 67,
	--参与天界之门XX次
	GateOfHeaven = 68,
	--参与心魔副本X次
	CopyOfHeartDevi = 69,
	--通关五行副本X次
	Five_lineCopy = 70,
	--经验副本参与X次
	CopiesOfExperience = 71,
	--熔炼X次
	EquipSmelt = 72,
	--助战神兽X个
	SoulBeastsNum = 73,
	--助战神兽id大于等于填写的id
	SoulBeastsID = 74,
	--结婚X次
	marryNum = 75,
	--夫妻亲密度X点
	marry_intimacy = 76,
	--婚姻房子X阶
	marry_house = 77,
	--婚姻祈福到X等级
	marry_blessLevel = 78,
	--购买婚姻宝匣X次
	marry_boxNum = 79,
	--激活仙娃X个
	marry_childNum = 80,
	--激活指定法宝ID
	state_stifleID = 81,
	--激活指定翅膀ID(废弃,ID:24已经拥有)
	NatureWingID = 82,
	--激活指定坐骑ID
	NatureHorseID = 83,
	--激活宠物id
	PetID = 84,
	--神兵锻造总等级
	GodWeaponLevelNum = 85,
	--加好友X个
	AddFriends = 86,
	--击杀x类型（世界，宝石，套装，领地）BOSSx个
	TypeBoss = 87,
	--灵石商城购买x物品n个
	ManaStoneShopBuy = 88,
	--当天活跃点消耗X
	CurDayActiveValueCos = 89,
	--灵体穿戴X阶X色X星及以上装备X件,条件id_阶数id_品质id_星数_件数
	LingTiEquip = 90,
	--累计经验悟道次数
	EXPPrayNum = 91,
	--累计灵石悟道次数
	MoneyPrayNum = 92,
	--真实充值金额
	TrueRecharge = 93,
	--领取X元每日礼包X次
	WelfareDailyGiftNum = 94,
	--购买X卡Y次（周卡，月卡，尊享卡）
	WelfareCard = 95,
	--升级技能X次
	SkillLevelUp = 96,
	--累计采集神兽岛水晶X个（包含所有类型的水晶）
	CollectionCrystal = 97,
	--累计参加世界答题X次（新名字：心境博弈）
	WorldQuestionNum = 98,
	--累计接受X次法宝任务
	RealmStifleTaskNum = 99,
	--累计发起X次求援
	WorldSupportSeek = 100,
	--累计完成X次求援
	WorldSupportHelp = 101,
	--VIP功能开启类使用
	VIPFunctionStart = 102,
	--仙盟大厅等级
	BaseLevel = 103,
	--仙盟商店等级
	ShopLevel = 104,
	--仙盟驻地等级
	StationLevel = 105,
	--完成洗髓x
	XisuiAccomplished = 106,
	--坐骑达到X星数(取NatureHorse表的ID段）
	HorseStarNum = 107,
	--仙盟日常副本
	guildtaskconquerclone = 108,
	--领取0元每日礼包X次（废弃字段，前VIP周常专用）
	WelfareDaily0GiftNum = 109,
	--领取1元每日礼包X次（废弃字段，前VIP周常专用）
	WelfareDaily1GiftNum = 110,
	--领取6元每日礼包X次（废弃字段，前VIP周常专用）
	WelfareDaily6GiftNum = 111,
	--领取30元每日礼包X次（废弃字段，前VIP周常专用）
	WelfareDaily30GiftNum = 112,
	--击杀世界BOSSX次（废弃字段，前VIP周常专用）
	KillWorldBossNum = 113,
	--击杀宝石BOSSX次（废弃字段，前VIP周常专用）
	KillGemBossNum = 114,
	--击杀境界BOSSX次（废弃字段，前VIP周常专用）
	KillStateBossNum = 115,
	--穿戴X阶及以上的X色圣装X件,条件id_阶数id_品质id_件数
	WornHolyEquip = 116,
	--累计获得X点尘晶
	VipWeekValue = 117,
	--穿戴X部位X品质
	EquipPositionQuality = 118,
	--击杀套装BOSSX次（废弃字段，前VIP周常专用）
	KillSuitBossNum = 119,
	--累计完成X次法宝任务
	RealmStifleTaskCompNum = 120,
	--参与X类型寻宝Y次(X为Treasure_Pop表中，reward_type字段中的类型)
	TreasurePopNum = 121,
	--获得某个ID的装备
	GetEquipId = 122,
	--声望商城购买道具：道具ID_数量
	IntegralShopBuy = 123,
	--灵体解封等级X：灵体解封至ID
	LingtiSealRelief = 124,
	--激活器灵X：激活器灵ID（对应state_stifle_add主键）
	StatestifleAddActivated = 125,
	--A技能升级成A1技能：心法ID_技能位置_被动等级
	Occ_SkillAdvanced = 126,
	--拍卖行上架X阶X品质X部位装备X次
	AuchtionSell = 127,
	--拍卖行购买X阶X品质X部位装备X次
	AuchtionBuy = 128,
	--是否进行过首充
	FirstRechargeReward = 129,
	--激活成长基金X档Y次
	BuyInvest = 130,
	--圣装战力
	EquipHolyPower = 131,
	--参与合成X次
	ComposeEquiponce = 132,
	--领取邮件X次
	MailRecive = 133,
	--领取第X天首充奖励
	ReceiveFirstRechargeReward = 134,
	--在与仙盟成员组队状态下参与传道X次
	GroupLeaderpreach = 135,
	--在仙盟频道发言X次
	GuildChat = 136,
	--参加X次仙盟战
	GuildWar = 137,
	--在仙盟福地内参与击杀X个BOSS
	FudiBossKill = 138,
	--穿戴X类圣装X件
	EquipHolyTypeWorn = 139,
	--装备X阶及以上X级套装X件
	EquipSuitLevel = 140,
	--击杀(跨服)XX场景idXX个boss
	CrossSceneBoss = 141,
	--完成仙盟首领活动X次
	GuildBossFinish = 142,
	--完成仙盟S级协助X次
	GuildCopySupport = 143,
	--组队完成组队X副本X次
	GroupCopymap = 144,
	--获取个人X首领首杀奖励X次(取boss_FirstBlood的ID)
	BossFirstBloodreward = 145,
	--累计升级技能X次（技能蜕变次数）
	SkillEvolutionTotal = 146,
	--器灵进化到X级（X对应state_stifle_add的主键ID）
	StateStifleAddTotal = 147,
	--累计完成X次S级仙盟任务
	GuildTaskTotal = 148,
	--完成X档婚礼
	MarryTotal = 149,
	--通过X层剑灵阁
	Soul_copy_Num = 150,
	--购买0元购XX挡
	free_shop_total = 151,
	--激活剑灵X
	FlyswardActivated = 152,
	--世界等级达到XX
	WorldLevelLimit = 153,
	--剑灵（type)X等级培养至X级
	FlyswardLevelup = 154,
	--法宝(灵压法宝)达到x阶（state_stifle表的level字段）
	MagicWeaponRank = 155,
	--坐骑达到X阶(取NatureHorse表的steps段）
	HorseStarNumRank = 156,
	--充值XX礼包YY次（XX对应rechargeItem表的主键）
	Recharge_Money_Limit = 157,
	--充值XX充值礼包YY次（XX对应rechargeItem表的rechargeSubType字段）
	Recharge_Gift_Limit = 158,
	--今日是否登陆过
	Daily_Log_In = 159,
	--开服天数达到XXX
	Sever_Open_Day = 160,
	--每天充值金额XXX
	Recharge_Money_Day = 161,
	--仙盟商城购买x物品n个
	GuildShopBuy = 162,
	--今日是否充值XX钱（单位：分）
	IsRechargeToday = 163,
	--累计获得活跃点X
	ActiveValueGet = 164,
	--购买XX礼包，对应limit_direct_shop主键
	limit_direct_shop_condition = 165,
	--今日在线X分钟
	Daily_Online_Time = 166,
	--今日仙甲寻宝X次
	Daily_XianJiaXunBao_Times = 167,
	--今日掌门传道消耗X活跃点
	Daily_LeaderPreach_Time = 168,
	--今日打坐X分钟
	Daily_Meditation_Time = 169,
	--今日领取X次剑灵阁收益
	Daily_SwordSoul_Times = 170,
	--今日挑战X次竞技场
	Daily_JJC_Times = 171,
	--今日击杀个人首领X次
	Daily_Kill_Self_Boss_Times = 172,
	--今日击杀无限首领X次
	Daily_Kill_UnLimit_Boss_Times = 173,
	--今日击杀无极虚域首领x次
	Daily_Kill_WuJIArea_Boss_Times = 174,
	--今日击杀晶甲首领x次
	Daily_Kill_JingJia_Boss_Times = 175,
	--今日参与天禁之门X次
	Daily_Enter_TJZM_Times = 176,
	--今日完成赏金之道x次
	Daily_ShangJingFunc_Times = 177,
	--今日活跃度达到x点
	Daily_Active_Value = 178,
	--技能总星级X
	Skill_Star_Count = 179,
	--在世界频道发言X次
	WorldChat = 180,
	--新技能总等级X
	Akill_Position_Level = 181,
	--开启宠物装备槽位数X
	Pet_Equip_Inten = 182,
	--赠送X次一朵玫瑰给其他玩家【天禁令每日任务】
	Give_Gift = 183,
	--领取X次VIP每日礼包【天禁令每日任务】
	Get_Vip_Daily_Reward = 184,
	--银元宝商城购买X个任意商品【天禁令每日任务】
	Buy_Any_Good = 185,
	--拍卖行上架X次任意商品【天禁令每日任务】
	Auchtion_Any_Shelf = 186,
	--进行X次经验悟道或银元宝悟道（二者次数总和达到X）【天禁令每日任务】
	Welfare_Any = 187,
	--进行X次剑灵阁灵魂抽取【天禁令每日任务】
	LingPoLottery_Any = 188,
	--进行X次排行榜点赞【天禁令每日任务】
	Rank_Thumbs_Up = 189,
	--巅峰竞技累计胜利X场【天禁令阶段任务】
	ArenaTop_Win = 190,
	--参加日暮篝火X次【天禁令阶段任务】
	Join_Bon_Fire = 191,
	--参加情缘副本X次【天禁令阶段任务】
	Join_Marry_Copy = 192,
	--击杀X个仙盟福地BOSS或者混沌之境BOSS（二者击杀总和达到X即可）【天禁令阶段任务】
	Kill_Guild_Territorial_Boss = 193,
	--进行X次机缘寻宝或者造化寻宝（二者寻宝总和达到X即可）【天禁令阶段任务】
	Hunt_Treasure_Num = 194,
	--击杀无极虚域首领X个【天禁令阶段任务】
	Kill_World_Boss_Num = 195,
	--击杀晶甲和域首领X个【天禁令阶段任务】
	Kill_Suit_Boss_Num = 196,
	--击杀个人首领首领X个【天禁令阶段任务】
	Kill_Private_Boss_Num = 197,
	--击杀神兽岛首领X个【天禁令阶段任务】
	Kill_Cross_Boss_Num = 198,
	--累计抽取X次仙甲寻宝【天禁令阶段任务】
	Treasure_XianJia_Num = 199,
	--点亮灵星X点亮ID为X的灵星
	LingTiStar = 200,
	--（跨服）击杀年兽封域（神兽岛)BOSS X个
	Kill_SoulBeast_Boss_Num = 201,
	--参加X次巅峰竞技
	Join_ArenaTop_Num = 202,
	--在荣誉商城购买A物品X次(道具ID_数量)
	GloryShop_Buy = 203,
	--宠物装备分解X次
	Pet_Equip_Resolve = 204,
	--宠物装备强化等级达到X
	Pet_Equip_Strengthen_Level = 205,
	--获得X次八极阵图结算奖励
	EightCity_Reward_Num = 206,
	--新神兵强化等级达到X
	God_weapon_Strengthen_Level = 207,
	--击杀X个诸界远征的BOSS
	Kill_crossfudi_Boss = 208,
	--获得ID为X的称号
	playertitle = 209,
	--Vip等级达到X
	VipLevel = 210,
	--穿戴X战力及以上的装备X件
	WornEquipPower = 211,
	--拍卖行上架任意魔魂卡片X次
	AuchtionDevilCardSell = 212,
	--拍卖行购买任意魔魂卡片X次
	AuchtionDevilCardBuy = 213,
	--获得某个ID的装备
	GetEquipsId = 214,
	--提升任意装备的星级【天禁令阶段任务】
	Equip_Star_Level_Up = 215,
	--击杀X个VIP首领【天禁令阶段任务】
	Kill_Vip_Boss_Num = 216,
	--角色身上穿戴a部位b阶数以上c品质以上的装备d个
	new_sever_growup_wear_equip = 217,
	--杀死福地或者诸界远征对应BOSS类型的数量
	KillfudiBoss_type = 218,
	--在副本X中击杀其他玩家的数量
	Killpalyer_daily_num = 219,
	--在仙盟战中使用神骑的次数
	GuildWar_special_skill = 220,
	--参加福地论剑
	Guild_battle_final = 221,
	--在诸界远征汇总获得X次任意城市占领奖励
	Cross_fudi_hold_reward = 222,
	--今日八极阵图结束时至少占领X座城池
	Bajizhentu_hold_city = 223,
	--今日是否参加过除魔团（0，否，1是）
	if_today_Slayer = 224,
	--坐骑脉轮中XX轮评价达到X级
	Horse_equip_score = 225,
	--坐骑脉轮中XX轮是否为激活（0，否，1是）
	Horse_equip_pos = 226,
	--今日击杀VIP首领x次
	Daily_Kill_VIP_Boss_Times = 227,
	--今日封魔台抽取次数
	Daily_DevilHunt_Times = 228,
	--参加神女巡游X次【天禁令阶段任务】
	Join_Convoy_Girl_Num = 229,
	--在仙盟拍卖行上架X次商品
	Guild_auction_company_business_frequency = 230,
	--参与仙盟战并成功摧毁上古意志
	GuildWar_KillfudiBoss = 231,
	--参与仙盟战作为盟主摧毁上古意志
	GuildWar_KillfudiBoss_leader = 232,
	--圣装强化总等级达到X级
	WornHolyEquip_strengthen_Grade = 233,
	--激活X阶X色以上斗心
	WornHolyEquip_activation_level_cool = 234,
	--合成一个X阶以上的圣装
	synthesis_level_Holydress = 235,
	--圣装穿戴总数
	Holydress_sum = 236,
	--参加神女巡游X次【天禁令阶段任务】
	Join_Escort_Num = 237,
	--PrisonPointPK
	Prison_Point_PK = 238,
}

return FunctionVariableIdCode
