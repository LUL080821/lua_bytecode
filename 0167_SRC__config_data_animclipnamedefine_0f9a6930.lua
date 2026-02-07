local AnimClipNameDefine = 
{
	--普通站立
	NormalIdle = "idle",
	--展示的动作
	Show = "show",
	--展示的idle
	ShowIdle = "show_idle",
	--走
	NormalWalk = "walk",
	--普通移动
	NormalRun = "run",
	--急速移动
	FastRun = "fastrun",
	--普通跳跃
	NormalJump = "jump",
	--亮剑
	SwordOutIdle = "sword_out_i",
	--亮剑
	SwordOutRun = "sword_out_r",
	--战斗站立
	FightIdle = "idle_f",
	--战斗往前移动
	FightRunFront = "run_f",
	--战斗往左移动
	FightRunLeft = "run_l",
	--战斗往右移动
	FightRunRight = "run_r",
	--战斗往后移动
	FightRunBack = "run_b",
	--战斗跳跃
	FightJump = "fightjump",
	--收剑
	SwordInIdle = "sword_in_i",
	--收剑
	SwordInRun = "sword_in_r",
	--翻滚
	Dodge = "dodge",
	--坐下
	SitDown = "sit_down",
	--打坐中
	Sit = "sit",
	--站起
	StandUp = "stand_up",
	--左转
	TurnLeft = "turnleft",
	--右转
	TurnRight = "turnright",
	--死亡
	Dead = "dead",
	--眩晕
	Dizzy = "dizzy",
	BeAttacked1 = "beattacked",
	BeAttacked2 = "beattacked1",
	--胜利
	Win = "win",
	--出生
	Born = "born",
	--idle表演动作
	IdleSpecial = "idle_rest",
	--登录界面表演
	LoginPlay = "loginplay",
	--采集
	Collect = "collection",
	--采集2
	Collect2 = "collection2",
	--采集3
	Collect3 = "collection3",
	--采集4
	Collect4 = "collection4",
	--被击飞
	HitFly = "hitfly",
	--躺地
	Lie = "lie",
	--躺地之后爬起
	GetUp = "getup",
	--轻功1
	Fly01 = "fly01",
	--轻功2
	Fly02 = "fly02",
	--轻功3
	Fly03 = "fly03",
	--轻功4
	Fly04 = "fly04",
	--轻功5
	Fly05 = "fly05",
	--轻功6
	Fly06 = "fly06",
	--轻功7
	Fly07 = "fly07",
	--轻功8
	Fly08 = "fly08",
	--轻功9
	Fly09 = "fly09",
	--轻功10
	Fly10 = "fly10",
	--轻功11
	Fly11 = "fly11",
	--骑乘1
	RideIdle1 = "ride_rest",
	--骑乘2
	RideIdle2 = "ride_rest1",
	--骑乘3
	RideIdle3 = "ride_rest2",
	--骑乘4
	RideIdle4 = "ride_rest3",
	--骑乘5
	RideIdle5 = "ride_rest4",
	--骑乘6
	RideIdle6 = "ride_rest5",
	--骑乘7
	RideIdle7 = "ride_rest6",
	--骑乘8
	RideIdle8 = "ride_rest7",
	--骑乘9
	RideIdle9 = "ride_rest8",
	--骑乘10
	RideIdle10 = "ride_rest9",
	--骑乘1
	RideRun1 = "ride",
	--骑乘2
	RideRun2 = "ride1",
	--骑乘3
	RideRun3 = "ride2",
	--骑乘4
	RideRun4 = "ride3",
	--骑乘5
	RideRun5 = "ride4",
	--骑乘6
	RideRun6 = "ride5",
	--骑乘7
	RideRun7 = "ride6",
	--骑乘8
	RideRun8 = "ride7",
	--骑乘9
	RideRun9 = "ride8",
	--骑乘10
	RideRun10 = "ride9",
	--飞行站立，坐骑专用
	FlyIdle = "idle1",
	--飞行移动，坐骑专用
	FlyRun = "run1",
	--抓取
	Catch = "catch",
	--渡劫
	DuJie1 = "dujie01",
	--渡劫
	DuJie2 = "dujie02",
	--渡劫
	DuJie3 = "dujie03",
	--渡劫
	DuJie4 = "dujie04",
	--渡劫
	DuJie5 = "dujie05",
	--渡劫
	DuJie6 = "dujie06",
	--渡劫
	DuJie7 = "dujie07",
	--渡劫
	DuJie8 = "dujie08",
	--渡劫
	DuJie9 = "dujie09",
	--渡劫
	DuJie10 = "dujie10",
	--渡劫
	DuJie11 = "dujie11",
	--划拳
	HuaQuan1 = "huaquan1",
	--划拳
	HuaQuan2 = "huaquan2",
	--喝酒
	Drink = "drink",
	--时装
	FashionShow = "fashion_show",
	--时装
	FashionIdle = "fashion_idle",
	--特殊
	SpecialShow = "special_show",
	--特殊
	SpecialIdle = "special_idle",
	--技能
	Skill_I_1 = "skill_i_1",
	--技能
	Skill_I_2 = "skill_i_2",
	--技能
	Skill_I_3 = "skill_i_3",
	--技能
	Skill_I_4 = "skill_i_4",
	--技能
	Skill_I_5 = "skill_i_5",
	--技能
	Skill_I_6 = "skill_i_6",
	--技能
	Skill_I_7 = "skill_i_7",
	--技能
	Skill_I_8 = "skill_i_8",
	--技能
	Skill_I_9 = "skill_i_9",
	--技能
	Skill_I_10 = "skill_i_10",
	--技能
	Skill_I_11 = "skill_i_11",
	--技能
	Skill_I_12 = "skill_i_12",
	--技能
	Skill_I_13 = "skill_i_13",
	--技能
	Skill_I_14 = "skill_i_14",
	--技能
	Skill_I_15 = "skill_i_15",
	--技能
	Skill_I_16 = "skill_i_16",
	--技能
	Skill_I_17 = "skill_i_17",
	--技能
	Skill_I_18 = "skill_i_18",
	--技能
	Skill_I_19 = "skill_i_19",
	--技能
	Skill_I_20 = "skill_i_20",
	--技能
	Skill_I_21 = "skill_i_21",
	--技能
	Skill_I_22 = "skill_i_22",
	--技能
	Skill_I_23 = "skill_i_23",
	--技能
	Skill_I_24 = "skill_i_24",
	--技能
	Skill_I_25 = "skill_i_25",
	--技能
	Skill_I_26 = "skill_i_26",
	--技能
	Skill_I_27 = "skill_i_27",
	--技能
	Skill_I_28 = "skill_i_28",
	--技能
	Skill_I_29 = "skill_i_29",
	--技能
	Skill_I_30 = "skill_i_30",
	--技能
	Skill_I_31 = "skill_i_31",
	--技能
	Skill_I_32 = "skill_i_32",
	--技能
	Skill_I_33 = "skill_i_33",
	--技能
	Skill_I_34 = "skill_i_34",
	--技能
	Skill_I_35 = "skill_i_35",
	--技能
	Skill_I_36 = "skill_i_36",
	--技能
	Skill_I_37 = "skill_i_37",
	--技能
	Skill_I_38 = "skill_i_38",
	--技能
	Skill_I_39 = "skill_i_39",
	--技能
	Skill_I_40 = "skill_i_40",
	--技能
	Skill_R_1 = "skill_r_1",
	--技能
	Skill_R_2 = "skill_r_2",
	--技能
	Skill_R_3 = "skill_r_3",
	--技能
	Skill_R_4 = "skill_r_4",
	--技能
	Skill_R_5 = "skill_r_5",
	--技能
	Skill_R_6 = "skill_r_6",
	--技能
	Skill_R_7 = "skill_r_7",
	--技能
	Skill_R_8 = "skill_r_8",
	--技能
	Skill_R_9 = "skill_r_9",
	--技能
	Skill_R_10 = "skill_r_10",
	--技能
	Skill_R_11 = "skill_r_11",
	--技能
	Skill_R_12 = "skill_r_12",
	--技能
	Skill_R_13 = "skill_r_13",
	--技能
	Skill_R_14 = "skill_r_14",
	--技能
	Skill_R_15 = "skill_r_15",
	--技能
	Skill_R_16 = "skill_r_16",
	--技能
	Skill_R_17 = "skill_r_17",
	--技能
	Skill_R_18 = "skill_r_18",
	--技能
	Skill_R_19 = "skill_r_19",
	--技能
	Skill_R_20 = "skill_r_20",
	--技能
	Skill_R_21 = "skill_r_21",
	--技能
	Skill_R_22 = "skill_r_22",
	--技能
	Skill_R_23 = "skill_r_23",
	--技能
	Skill_R_24 = "skill_r_24",
	--技能
	Skill_R_25 = "skill_r_25",
	--技能
	Skill_R_26 = "skill_r_26",
	--技能
	Skill_R_27 = "skill_r_27",
	--技能
	Skill_R_28 = "skill_r_28",
	--技能
	Skill_R_29 = "skill_r_29",
	--技能
	Skill_R_30 = "skill_r_30",
	--技能
	Skill_R_31 = "skill_r_31",
	--技能
	Skill_R_32 = "skill_r_32",
	--技能
	Skill_R_33 = "skill_r_33",
	--技能
	Skill_R_34 = "skill_r_34",
	--技能
	Skill_R_35 = "skill_r_35",
	--技能
	Skill_R_36 = "skill_r_36",
	--技能
	Skill_R_37 = "skill_r_37",
	--技能
	Skill_R_38 = "skill_r_38",
	--技能
	Skill_R_39 = "skill_r_39",
	--技能
	Skill_R_40 = "skill_r_40",
	--登录选角走出
	Walkout = "walkout",
	--游泳站立
	SwimIdle = "swim_idle",
	--游泳移动
	SwimRun = "swim_run",
	--游泳翻滚
	SwimDodge = "swim_dodge",
	--登录选角走出
	LoginIdle = "login_idle",
	--游游泳站立
	RiceIdle = "rice_idle",
	--游游泳移动
	RiceRun = "rice_walk",
}

return AnimClipNameDefine
