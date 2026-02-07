------------------------------------------------
-- Author: 
-- Date: 2019-05-15
-- File: LogicLuaEventDefine.lua
-- Module: LogicLuaEventDefine
-- Description: Logical lua event definition
------------------------------------------------
-- The basic ID of the logical lua event
local L_BASE_ID = 700000

local LogicLuaEventDefine = {

    -- Events of changes in player feedback list
    EID_FEEDBACK_LIST_CHANGED = 1,
    -- Refresh the challenge copy
    EID_EVENT_UPDATE_TIAOZHANFUBEN = 2,
    -- Refresh the pet interface
    EID_REFRESH_PET_FORM = 4,
    -- Refresh the copy interface of the Gate of Heaven
    EID_EVENT_UPDATE_TIANJIEZHIMEN = 5,
    -- Refresh copy purchases
    EID_EVENT_UPDATE_COPY_VIPBUYCOUNT = 6,
    -- Refresh multiplayer copy
    EID_EVENT_UPDATE_MANYCOPYMAP = 7,
    -- Refresh experience copy information
    EID_EVENT_UPDATE_EXPCOPY_INFO = 8,
    -- Refresh multiplayer copy information
    EID_EVENT_UPDATE_ManyCOPY_INFO = 9,

    -- Refresh the status of the Tribulation Duplicate
    EID_EVENT_UPDATE_DUJIE_STATE = 11,
    -- The results of the Tribulation Copy Display
    EID_EVENT_SHOW_DUJIE_RESULT = 12,
    -- Magic weapon animation has been played
    EID_EVENT_FABAO_GET_FINISH = 13,
    -- Trial copy play text prompt
    EID_EVENT_FABAO_PLAY_TIPS = 14,
    -- Set, Gem Boss Refresh
    EID_EVENT_REFESH_REMAINCOUNT = 15,
    -- Set, Gem Boss Exit Copy Countdown
    EID_EVENT_QUIT_COPY_COUNTDOWN = 16,
    -- Friends, two-way friend data return
    EID_EVENT_MUTUALFRIENDS_UPDATE = 17,
    -- Friends, ranking information is returned
    EID_EVENT_INTIMATEFRIENDSRANKLIST_UPDATE = 18,
    -- Friends data update
    EID_EVENT_INTIMATEFRIEDSDATA_UPDATE = 19,
    -- Friends' name change updated
    EID_EVENT_INTIMATECHANGENAME_UPDATE = 20,
    -- Realm BOSS increases the number of entry times
    EID_EVENT_ADDSTATUREBOSSCOUNT = 21,
    -- Friends announcement update
    EID_EVENT_INTIMATFRIENDSNOTIVE_UPDATE = 22,
    -- Refreshing of marriage reward data
    EID_EVENT_MARRY_REWARD_UPDATE = 23,
    -- Marriage refreshes the invited friends list
    EID_EVENT_MARRY_INVITED_FRIEND_UPDATE = 24,
    -- Last time the request for help was issued
    EID_EVENT_WORLDSUPPORT_LASTSUPPORT_UPDATE = 25,
    -- Prize questionnaire status update
    EID_EVENT_REFRESH_QUESTION_NAIRE_DATA = 26,
    -- Request for help list update
    EID_EVTNT_WORLDSUPPORT_LISTUPDATE = 27,
    -- Refresh the data on the recharge interface
    EID_EVENT_REFESH_PAY_DATA = 28,
    -- Tianxu Battlefield (Terminal War) damage data update
    EID_EVENT_MANOR_HARMLIST_UPDATE = 29,
    -- Synchronize limited-time products
    EID_EVENT_SYNCLIMITSHOP = 30,

    -- Refresh guild task copy information
    EID_EVENT_REFRESH_GUILDTASKCOPY_INFO = 31,

    -- Refresh the list of evaluation levels of Xianmeng
    EID_EVENT_REFRESH_XM_RATE_LIST = 32,
    -- Immortal Alliance Statistics Record Refresh
    EID_EVENT_REFRESH_XM_RECORD_LIST = 33,
    -- The Immortal Alliance wins a new succession
    EID_EVENT_REFRESH_XM_LSREWARD_LIST = 34,
    -- Immortal Alliance copy interface update
    EID_EVENT_REFRESH_XM_COPYUI = 35,
    -- The news of the battle for the offensive and defensive transformation of the Immortal Alliance
    EID_EVENT_CHANGEATTACK_XM = 36,

    -- Immortal Alliance Boss Refresh
    EID_EVENT_XMBOSS_REFRSH = 37,
    -- Refresh rankings during battle between the Immortal Alliance Boss
    EID_EVENT_XMBOSSRANK_REFRSHRANK = 38,
    -- Xianmeng Boss Inspiration Interface Refresh
    EID_EVENT_XMBOSSHEARTEN_REFRSH = 39,

    -- Close limited time store
    EID_EVENT_CLOSELIMITSHOP = 40,
    -- Refresh the Immortal Armor Treasure Hunt
    EID_EVENT_XJXUNBAO_REFESH = 41,
    -- Refresh the Immortal Armor Secret Treasure
    EID_EVENT_XJMIBAO_REFESH = 42,

    -- Add update to the boss selected message for the boss of the Fudi copy
    EID_EVENT_FUDICOPY_SELECTUPDATE = 43,
    -- Refresh the Xianjia warehouse
    EID_EVENT_XJCANGKU_REFESH = 44,

    -- Notify the Immortal Alliance War dungeon to show the kill title
    EID_EVENT_XMCOPY_SHOWTITLE = 45,
    -- Notify the Immortal Alliance Battle Dun Hidden Killing Title
    EID_EVENT_XMCOPY_HIDETITLE = 46,
    -- Notification displays the Immortal Alliance Battle Teleportation Button
    EID_EVENT_XMCOPY_SHOWCROSSBTN = 47,
    -- Notify Hidden Immortal Alliance Battle Teleportation Button
    EID_EVENT_XMCOPY_HIDECROSSBTN = 48,
    -- Notification shows the Immortal Alliance War convening information
    EID_EVENT_XMCOPY_SHOWCALLINFO = 49,
    -- Server notifies the results of the secret treasure lottery
    EID_EVENT_XJMIBAO_CHOUJIANG_REFESH = 50,
    -- Minimap custom object refresh
    EID_EVENT_MAP_CUSTOMOBJECT_REFESH = 51,
    -- Changes in the Occupation and Ownership of Blessed Land
    EID_EVENT_FUDI_OWNCHAGE = 52,
    -- The preaching time synchronization of the head
    EID_EVENT_CHUANDAO_TIME_REFREASH = 53,
    -- Tianxu Battlefield Hall of Fame ranking information synchronization
    EID_EVENT_TERRITORIALWAR_CELEBRITY_RANKLIST = 54,
    -- Fashion wear changes
    EID_EVENT_NEWFASHION_CHANGE = 55,
    -- Click Safe Resurrection
    EID_EVENT_ONCLICKSAFEBORN = 56,
    -- Tianxu Battlefield Rage Reset Remaining Time Update
    EID_EVENT_TERRITORIALWAR_ANGERREMAINTIME_UPDATE = 57,
    -- Cross-Server Event Map Data Update
    EID_EVENT_CROSSSERVER_REFRESH = 58,
    -- Fashion activation message
    EID_EVENT_FASION_ACTIVE = 59,
    -- Receive VIP successfully
    EID_EVENT_VIP_RWARD_SUCCESS = 60,
    -- Return to receive the prize in VIP mission
    EID_EVENT_VIP_TASK_REWARD = 61,
    -- Spiritual star activation return
    EID_EVENT_LINGTI_STAR_UPDATE = 62,
    -- Activate the privilege card
    EID_EVENT_WELFARE_CARD_ACTIVATE = 63,
    -- Refresh the Cornucopia interface
    EID_EVENT_ATMFORM_FRESH = 64,
    -- Preaching settlement
    EID_EVENT_CHUANDAO_RESULT = 65,
    -- Wuji virtual domain novices layer settlement
    EID_EVENT_NEWCOMP_RESULT = 66,
    -- The task of updating the road to growth
    EID_EVENT_GROWTHUP_TASKUPDATE = 67,
    -- Spirit body unlock update message
    EID_EVENT_LINGTI_LOCKUPDATE = 68,
    -- The benefits and reward prompt interface is closed
    EID_EVENT_UIWelfareGetItemFormClose = 69,
    -- Mysterious store refresh event
    EID_EVENT_MYSTERYSHOP_UPDATE = 70,
    -- 0 yuan to refresh
    EID_EVENT_FREESHOP_REFRESH = 71,
    -- Refresh the server opening time
    EID_EVENT_OPENSERVERTIME_REFRESH = 72,
    -- Marriage copy information refresh
    EID_EVENT_MARRYCOPY_REFRESH = 73,
    -- Boss first kill interface update
    EID_EVENT_FBOSSKILL_UPDATE = 74,
    -- Receive the first kill red envelope for boss
    EID_EVENT_FBOSSKILL_HONGBAO_RESULT = 75,
    -- Refresh the number of people invited to purchase
    EID_EVENT_MARRY_ADD_INVITE_NUM_SUCCESS = 76,
    -- Refresh the data of the treasure hunt warehouse
    EID_EVENT_UPDATE_TREASURE_WAREHOUSE = 77,
    -- Switch sword spirit model
    EID_EVENT_FLYSWORD_CHANGEMODEL = 78,
    -- Sword Spirit Activated
    EID_EVENT_FLYSWORD_ACTIVE_NEW = 79,
    -- Sword Spirit Upgrade or Level
    EID_EVENT_FLYSWORD_UPDATE = 80,

    -- Refresh the job transfer interface
    EID_EVENT_REFRESH_CHANGEJOB_FORM = 81,
    -- Refresh information in the sword spirit copy
    EID_EVENT_REFRESH_SWORDSOUL = 82,
    -- Refresh information in the sword spirit copy
    EID_EVENT_NEXT_SWORDSOUL = 83,
    -- Update announcements to receive awards and refresh
    EID_EVENT_REFRESH_UPDATENOTICREWARD = 84,
    -- New server activities refresh
    EID_EVENT_REFRESH_NEWSERVERACTIVITY = 85,
    -- New server activities closed
    EID_EVENT_CLOSE_NEWSERVERACTIVITY = 86,

    -- Refresh the wedding blessing list
    EID_EVENT_REFRESH_MARRY_BLESSLIST = 87,
    -- When the title is updated, the main interface of marriage will be refreshed.
    EID_EVENT_TITLE_REFRESH_MARRIAGE_USE = 88,
    -- Refreshing news for marriage and love copy
    EID_EVENT_MARRY_QINGYUAN_COPY_REFESH = 89,
    -- Refresh the list of operation activities
    EID_EVENT_REFRESH_HDLIST = 90,
    -- Refresh the operation activity interface
    EID_EVENT_REFRESH_HDFORM = 91,
    -- Refresh the interface data of the marriage heart lock
    EID_REFRESH_MARRY_HEARTLOCK_FORM = 92,

    -- Return to the lucky cat lottery
    EID_REFRESH_LUCKCAT_RESULT = 93,
    -- Fashion illustration refresh interface
    EID_FASHION_TUJIAN_UPSTAR = 95,
    -- Fashion illustration activation
    EID_FASHION_TUJIAN_ACTIVE = 96,
    -- Fashion activation
    EID_FASHION_ACTIVE_RESULT = 97,
    -- Fashion Stars
    EID_FASHION_UPSTAR_RESULT = 98,

    -- Return to receive rewards on blind date wall
    EID_MARRY_WALL_GETREWARD = 99,
    -- Blind date wall refresh declaration list
    EID_MARRY_WALL_XUANYAN_LIST = 100,
    
    -- Saturday Carnival Buy Return
    EID_WEEKCRAZY_BUYRESULT = 101,

    -- Return to Zhenbao Pavilion lottery
    EID_ZHENBAOGE_CHOUJIANG_RESULT = 102,
    -- Return to receive the award in Zhenbao Pavilion
    EID_ZHENBAOGE_REWARD_RESULT = 103,
    -- Weekly welfare lottery data refresh
    EID_EVENT_LUCK_DRAW_REWARD_REFESH = 104,
    -- Weekly welfare interface data refresh
    EID_EVENT_LUCK_DRAW_WEEK_DATA_REFESH = 105,
    -- Refreshing news for the successful replacement of weekly benefits prizes
    EID_EVENT_LUCK_DRAW_CHANGE_SUCCESS = 106,
    -- Refreshing lottery record
    EID_EVENT_LUCK_DRAW_WEEK_RECORD_REFESH = 107,
    -- Return to the Treasure Pavilion for redemption
    EID_EVENT_CANGBAOGE_EXCHANGE_RESULT = 108,
    -- Treasure Pavilion record returns
    EID_EVENT_CANGBAOGE_RECORD = 109,
    -- Role comparison return
    EID_EVENT_PLAYERCOMPARE_RESULT = 110,

    -- The Emperor of Heaven won the grand prize
    EID_EVENT_TDBK_BIGAWARD = 111,

    -- Share and like interface refresh
    EID_EVENT_SHAREANDLIKEREFRESH = 112,

    -- Peak competitive ranking data update
    EID_EVENT_TOPJJCRANK_UPDATE = 113,

    -- Value discount data update
    EID_EVENT_LIMITDICRETESHOP_UPDATE = 114,

    -- Refresh activity prompt list
    EID_EVENT_REFRESH_ACTIVITY_LIST = 115,

    -- Lucky lottery draw return
    EID_EVENT_LUCKYCARD_LOTTERY_RESULT = 116,

    -- Lucky lottery mission return
    EID_EVENT_LUCKYCARD_TASK_RESULT = 117,

    -- Lucky lottery record returns
    EID_EVENT_LUCKYCARD_RECORD_RESULT = 118,

    -- Return after redemption of the word collection
    EID_EVENT_JIZIDUIHUAN_RESULT = 119,

    -- Refresh the death status of the wedding dungeon boss
    EID_EVENT_MARRYCOPY_BOSS_STATE = 120,

    -- Receive celebration missions and return
    EID_EVENT_QINGDIAN_TASK_RESULT = 121,
    -- Peak competitive data update
    EID_EVENT_TOPJJC_MAININFO_UPDATE = 122,
    EID_EVENT_TOPJJC_LVAWARDINFO_UPDATE = 123,
    -- Update information about eating fruits by magic weapon
    EID_EVENT_NATURE_EVENT_FABAO_UPDATEDRUG = 124,
    -- Pet wear equipment update
    EID_EVENT_PETEQUIP_WEARUPDATE = 125,
    EID_EVENT_PETEQUIP_PETLISTUPDATE = 126,

    -- Refreshing of the Heavenly Ban Level Rewards
    EID_EVENT_TIANJINLING_LVDATA_REFRESH = 127,
    -- Day ban mission refresh
    EID_EVENT_TIANJINLING_TASKDATA_REFRESH = 128,
    -- Day ban purchase return
    EID_EVENT_TIANJINLING_BUY_RESULT = 129,
    -- Pet enhancement update
    EID_EVENT_PETEQUIP_STRENGTHRESULT = 130,
    EID_EVENT_PETEQUIP_TOTALSTRENGTHRESULT = 131,
    EID_EVENT_PETEQUIP_SYNTHRESULT = 132,
    EID_EVENT_PETEQUIP_SoulRESULT = 133,
    EID_EVENT_PETEQUIP_TotalSoulRESULT = 134,
    -- Countdown to Peak Competitive Dun Close
    EID_EVENT_JJCTOP_CountDownfORMClose = 135,
    -- Ranking rewards and return
    EID_EVENT_RANKAWARD_GETRESULT = 136,
    -- Return to the New Year sign-in
    EID_EVENT_XINCHUN_SIGN_RESULT = 137,
    -- Return to receive New Year's blessings
    EID_EVENT_XINCHUN_REWARD_RESULT = 138,

    -- Play create character interface animation
    EID_EVENT_CREATE_PLAYER_ANIM_RESET = 139,
    EID_EVENT_CREATE_PLAYER_ANIM_START = 140,
    -- Soul Armor Tempering Level Update
    EID_EVENT_SOULEQUIP_STRENGTHLV_UPDATE = 141,
    -- Soul Armor Breakthrough Level Update
    EID_EVENT_SOULEQUIP_BREAKLV_UPDATE = 142,
    -- Soul Armor Awakening Level Update
    EID_EVENT_SOULEQUIP_AWEAKLV_UPDATE = 143,
    -- Divine Seal Pavilion Level
    EID_EVENT_SOULEQUIP_LOTTERYLV_UPDATE = 144,
    -- Divine Seal Inlay Update
    EID_EVENT_SOULEQUIP_INLAY_UPDATE = 145,
    -- Soul Armor Awakening Skill Upgrade Update
    EID_EVENT_SOULEQUIP_AWAKESKILL_LVUP = 146,
    -- Soul Armor Inlay Hole Position Update
    EID_EVENT_SOULEQUIP_HOLEUPDATE = 147,
    -- Blessed land details
    EID_EVENT_FUDI_DETAIL_INFO = 148,
    -- Spiritual combat power update
    EID_EVENT_LINGTI_FIGHTPOWER_UPDATE = 149,
    -- Data refresh of marriage gameplay introduction
    EID_EVENT_MARRY_TASK_REFRESH = 150,
    -- Updated results of the Blessed Land Sword Contest
    EID_EVENT_FUDI_LUNJIAN_ZHANJI = 151,
    -- Blessed Sword Controversy Broadcast
    EID_EVENT_FUDI_LUNJIAN_BROADCAST = 152,
    -- Updated on the Blessed Land Sword Contest
    EID_EVENT_FUDI_LUNJIAN_ZHANBAO = 153,
    -- Updated information of cross-server blessed land copy boss
    EID_EVENT_CROSSFUDI_BOSSINFO_UPDATE = 154,
    -- Cross-server Blessing Copy damage ranking information update
    EID_EVENT_CROSSFUDI_HURTRANK_UPDATE = 155,
    -- Request cross-server blessed land data to return
    EID_EVENT_CROSSFUDI_DATA_RESULT = 156,
    -- Return to the details of cross-server blessed land
    EID_EVENT_CROSSFUDI_CITY_DETAIL = 157,
    -- Return to the ranking information of cross-server blessed land
    EID_EVENT_CROSSFUDI_RANK_RESULT = 158,
    -- Synchronous cross-server blessed land copy data
    EID_EVENT_CROSSFUDI_COPY_DATAUPDATE = 159,
    -- Receive the treasure chest of cross-server blessed land
    EID_EVENT_CROSSFUDI_BOX_REWARDED = 160,
    -- Soul Seal Synthesis Results
    EID_EVENT_SOULPERARL_SYNTHRESULT = 161,
    -- Update cross-server blessed land refresh time
    EID_EVENT_CROSSFUDI_REFRESH_TIME = 162,
    -- Soul Armor Backpack Item Changes
    EVENT_SOULEQUIPPERAL_BAGCHANGE = 163,
    -- Pet equipment backpack changes
    EVENT_PETEQUIP_BAGCHANGE = 164,
    -- Select the boss interface of cross-server blessed land
    EID_EVENT_CROSSFUDI_COPY_BOSSSELECT = 165,
    -- The main interface displays a prompt to become stronger
    EID_EVENT_MAINFORM_SHOWBIANQIANG = 166,

        -- Add new features to enable the flight icon
    EID_EVENT_ADDNEWFUNCTION_FLYICON = 167,
    -- Refresh the page display status on the left side of the main interface
    EID_EVENT_MAINLEFTSUBPABNELOPENSTATE = 168,
    -- Show combat power change effect
    EID_EVENT_SHOWFIGHTPOWERCHANGE_EFFECT = 169,
    -- Update custom buttons
    EID_EVENT_UPDATECUSTONBTNS = 170,
    EID_EVENT_TASKTARGET_UPDATE = 171,                -- Target task update
    -- Email system
    EID_EVENT_MAIL_MAILNUM_PROMPT = 172,
    -- shop
    EID_EVENT_SHOPFORM_UPDATEPAGE = 173,
    EID_EVENT_SHOPFORM_UPDATEPAGEBTN = 174,
    -- Don't touch anyone else's own things
    EID_EVENT_UIENTERGAMEFORM_REFRESH = 175,
    -- loading interface
    EID_EVENT_UILOADINGFORM_SHOW_PROGRESS = 176,
    EID_EVENT_UILOADINGFORM_SHOW_PROGRESS_TEXT = 177,
    EID_EVENT_UILOADINGFORM_SHOW_TIPS = 178,
    -- VIP level changes
    EID_EVENT_VIP_LEVELCHANGE = 179,
    -- Update Vip interface
    EID_EVENT_VIPFORM_UPDATE = 180,
    -- Vip purchase and receive updates
    EID_EVENT_VIPFORM_BUY_RESULT = 181,
    -- Vip perimeter task update message
    EID_EVENT_IVPWEEK_UPDATE = 182,
    -- Vip cumulative recharge changes and updates
    EID_EVENT_VIPRECHARGE_UPDATE = 183,
    -- Hide login interface button
    EID_EVENT_LOGIN_HIDE_BTNS = 184,
    EID_EVENT_LOGIN_SHOW_BTNS = 185,
    -- Create role interface, window switching: create and select person switching
    EID_EVENT_CREATEPLAYER_DELPLAYER = 186,
    EID_EVENT_CREATEPLAYER_RECOVERPLAYER = 187,
    -- Announcement system, refresh the announcement panel
    EID_EVENT_LOGINNOTICE_REFRESH = 188,
    -- Character blocked
    EID_EVENT_PLAYER_FORBIDDEN = 189,
    -- Login status
    EID_EVENT_LOGIN_STATUS = 190,
    EID_EVENT_STORE_CLOSE = 191,
    EID_EVENT_SENDGIFT_RESULT = 192,
    EID_EVENT_SENDGIFT_LOG_UPDATE = 193,
    EID_EVENT_MONSTEREQUIPTIPS_PUTIN = 194,
    EID_EVENT_MONSTEREQUIPTIPS_PUTOUT = 195,
    -- Team up
    EID_EVENT_UITEAMMATCHFORM_UPDATE = 196,
    EID_EVENT_UITEAMAUTOMATCH_OVER = 197,
    EID_EVENT_UITEAMINVITEFORM_UPDATE = 198,
    EID_EVENT_UITEAMAPPLYFORM_UPDATE = 199,
    EID_EVENT_UITEAMREDPOINT = 200,
    EID_EVENT_UITEAMCUICUCD = 201,
    EID_EVENT_UITEAM_TEAM_SUCC = 202,
    EID_EVENT_MYSTERYSHOP_UPDATE_MAIN_ICON = 203,
    -- Auction house
    EID_EVENT_MARKET_UPDATE_LOG = 204,
    EID_EVENT_MARKET_UPDATE_BUY = 205,
    EID_EVENT_MARKET_UPDATE_OWN = 206,
    EID_EVENT_MARKET_UPDATE_SELLCOIN = 207,
    EID_EVENT_MARKET_UPDATE_OTHERLIST = 208,
    -- Update information
    EID_EVENT_JJC_UPDATECOUNT = 209,
    -- Update the top three
    EID_EVENT_JJC_UPDATEPLAYERS = 210,
    -- Update yesterday's ranking
    EID_EVENT_JJC_UPDATEYESTERDAY_RANK = 211,
    -- Click Challenge
    EID_EVENT_JJC_CLICKTIAOZHANPLAYER = 212,
    -- War report update
    EID_EVENT_JJC_RECORDUPDATE = 213,
    -- Refresh the arena countdown
    EID_EVENT_JJC_REFRESHTIME = 214,
    -- Refresh the arena for the first ranking reward
    EID_EVENT_JJC_FIRSTAWARD = 215,
    -- Arena Challenge Begins
    EID_EVENT_JJC_FIGHTSTART = 216,
    -- Arena flashback
    EID_EVENT_JJC_MIAOSHA_RESULT = 217,
    -- Ranking list
    EID_EVENT_RANK_UPDATE_MODEL = 218,
    EID_EVENT_RANK_REFRESH = 219,
    EID_EVENT_RANK_SHOWSHENG = 220,    
    EID_EVENT_RANK_SHOWCOMPARE = 221,
    -- Refresh the achievement interface
    EID_EVENT_UPDATE_ACHFORM = 222,
    -- Apocalypse Treasure Library
    EID_EVENT_APOCALYPASEQUCHU = 223,
    EID_EVENT_APOCALYPASEREFRESHDUIHUAN = 224,
    -- Guild System
    EID_EVENT_GUILD_CREATEGUILD_INVITELIST_UPDATE = 225,
    EID_EVENT_GUILD_CREATEGUILD_RECOMMENDGUILDLIST_UPDATE = 226,
    EID_EVENT_GUILD_BASEINFOCHANGE_UPDATE = 227,
    EID_EVENT_GUILD_MEMBERLIST_UPDATE = 228,
    EID_EVENT_GUILD_GUILDAPPLYLIST_UPDATE = 229,
    EID_EVENT_GUILD_GUILDLOGLIST_UPDATE = 230,
    EID_EVENT_GUILD_GUILDBUILDINGLV_UPDATE = 231,
    EID_EVENT_GUILD_OPENSETPANEL = 232,
    EID_EVENT_GUILD_OUTLINEITEM_UPDATE = 233,
    EID_EVENT_GUILD_OPENBUILDUPPANEL = 234,
    -- Top menu opens
    EID_EVENT_ON_TOPMENU_OPEN = 235,
    EID_EVENT_ON_TOPMENU_CLOSE = 236,
    -- The main interface displays animation events
    EID_EVENT_ON_MAINUISHOW_ANIM = 237,
    -- Hidden animation events on the main interface
    EID_EVENT_ON_MAINUIHIDE_ANIM = 238,
    -- Active baby data return
    EID_EVENT_GUILD_ACTIVEBABY_RESULT = 239,
    -- Refresh daily charging
    EID_EVENT_REFRESH_DAY_RECHARGEINFO = 240,
    -- Refresh the set interface
    EID_EVENT_UPDATE_EQUIPSUIT_PAGE = 241,
    -- Soul Beast Forest
    -- renew
    EID_EVENT_HUNSHOUSENLIN_UPDATE = 242,
    -- focus on
    EID_EVENT_HUNSHOU_GUANZHUREFREASH = 243,
    -- Kill
    EID_EVENT_HUNSHOU_SHOWKILLINFO = 244,
    -- BOSS damage ranking
    EID_EVENT_HUNSHOU_HURTRANKINFO = 245,
    -- Select a soul beast
    EID_EVENT_MONSTERSOUL_SELECT_SOUL = 246,
    -- Added beast soul equipment
    EID_EVENT_MONSTERSOUL_EQUIP_ADD = 247,
    -- Added beast soul enhancement material
    EID_EVENT_MONSTERSOUL_MATERIAL_ADD = 248,
    -- The wearable status of the beast soul equipment changes
    EID_EVENT_MONSTERSOUL_EQUIP_WEAR_CHANGE = 249,
    -- Change in combat status
    EID_EVENT_MONSTERSOUL_FIGHTING_STATUS_CHANGE = 250,
    -- Strengthened completion
    EID_EVENT_MONSTERSOUL_STRENGTHEN_FINISH = 251,
    -- Beast soul, check the red dot
    EID_EVENT_MONSTERSOUL_CHECK_REDPOINT = 252,
    -- Beast soul, slot increases
    EID_EVENT_MONSTERSOUL_ADD_SLOT = 253,
    -- Put the synthetic items in and out
    EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUT = 254,
    EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUTOUT = 255,
    -- Synthesis results
    EID_EVENT_UPDATE_ITEMSYNTH_RESULT = 256,
    -- Meditation
    EID_EVENT_SITDOWN_START = 257,
    EID_EVENT_SITDOWN_END = 258,
    EID_EVENT_SHOWEXP_UPDATE = 259,
    -- Update the hangup settings panel
    EID_EVENT_UPDATE_HOOKSITTING = 260,
    -- Update the hang-up checkout panel
    EID_EVENT_UPDATE_HOOKRESULT = 261,
    -- Initialization of the wings of creation
    NATURE_EVENT_WING_INIT = 262,
    -- Change of the level of the wings of creation
    NATURE_EVENT_WING_UPLEVEL = 263,
    -- Renewal of the wings of fortune eating fruits
    NATURE_EVENT_WING_UPDATEDRUG = 264,
    -- Creation and transformation upgrade
    NATURE_EVENT_WING_UPDATEFASHION = 265,
    -- Initialization of the magic tool
    NATURE_EVENT_TALISMAN_INIT = 266,
    -- Change of the level of the creation magic weapon
    NATURE_EVENT_TALISMAN_UPLEVEL = 267,
    -- Updated by the magic weapon of creation
    NATURE_EVENT_TALISMAN_UPDATEDRUG = 268,
    -- Initialization of the formation of fortune
    NATURE_EVENT_MAGIC_INIT = 269,
    -- Change of the level of the creation formation
    NATURE_EVENT_MAGIC_UPLEVEL = 270,
    -- The formation of fortune eats fruit update
    NATURE_EVENT_MAGIC_UPDATEDRUG = 271,
    -- Change notification of transformation model
    NATURE_EVENT_FASHION_CHANGEMODEL = 272,
    -- News of the upgrade of the magic weapon
    NATURE_EVENT_WEAPON_INIT = 273,
    NATURE_EVENT_WEAPON_UPLEVEL = 274,
    -- Mount Initialization
    NATURE_EVENT_MOUNT_INIT = 275,
    -- Mount upgrade
    NATURE_EVENT_MOUNT_UPLEVEL = 276,
    -- Eat fruits on the mount
    NATURE_EVENT_MOUNT_UPDATEDRUG = 277,
    -- Mount eating equipment
    NATURE_EVENT_MOUNT_UPDATEEQUIP = 278,
    -- Daily active refresh
    EID_EVENT_REFRESH_ACTIVEPANEL = 279,
    -- Play special effects
    EID_EVENT_DAILY_PLAYVFX = 280,
    -- Stop the special effects
    EID_EVENT_DAILY_STOPVFX = 281,
    -- Book of Heaven Refresh the Talisman Panel
    EID_EVENT_REFRESH_AMULETPANEL = 282,
    -- Heavenly Book Attributes and Spell Information
    EID_EVENT_REFRESH_AMULETINFO = 283,
    -- Equipment enhancement
    EID_EVENT_REFRESH_ALLINFO = 284,
    EID_EVENT_CHANGE_EQUIPMAXSTRENGTHLV = 285,
    -- Refresh the sea of consciousness interface
    EID_EVENT_REFRESH_PLAYER_SHIHAI = 286,
    -- Sectarian skills information refresh
    EID_EVENT_REFRESH_FACTIONSKILLINFO = 287,
    -- Sectarian skills refresh
    EID_EVENT_REFRESH_FACTIONSKILLS = 288,
    -- Update the Fudi Title Ranking UI
    EID_EVENT_UPDATE_FUDIRANKFORM = 289,
    -- Update the information on the Blessed Land Treasure Hunt Copy
    EID_EVENT_UPDATE_FUDIDUOBAO_COPYINFO = 290,
    -- Renew the blessing land to seize treasures
    EID_EVENT_UPDATE_FUDIDUOBAO = 291,
    -- Update the points for Fudi to receive awards
    EID_EVENT_UPDATE_SCOREREWARD = 292,
    -- Equipment gemstone
    EID_EVENT_REFRESHRIGHTINFOS = 293,
    -- Update the Fudi boss UI
    EID_EVENT_FUDIBOSS_ZONGLAN_UPDATE = 294,
    -- Update the information display of boss of Fudi
    EID_EVENT_FUDIBOSS_INFO_UPDATE = 295,
    -- Update gem inlay information
    EID_EVENT_GEMINLAYINFO = 296,
    EID_EVENT_GEM_HOLEOPENSTATE = 297,
    -- Update the inlay information of fairy jade
    EID_EVENT_JADEINLAYINFO = 298,
    EID_EVENT_JADE_HOLEOPENSTATE = 299,
    -- Update gem refining information
    EID_EVENT_GEMREFINEINFO = 300,
    -- Gem Refining: Select any equipment
    EID_EVENT_GEM_SELECTEQUIP = 301,
    -- Remaining refresh time for personal boss
    BOSS_EVENT_MYSELF_REMAINTEAM = 302,
    -- Personal BOSS enter copy message
    BOSS_EVENT_MYSELF_COPYINFO = 303,
    -- Personal BOSS death status update
    BOSS_EVENT_MYSELF_BOSSSTAGE = 304,
    -- Refresh personal BOSS props
    BOSS_EVENT_MYSELF_COPYITEM = 305,
    -- New World BOSS Refresh Time
    EID_EVENT_NEWWORLDBOSS_REFRESHTIME = 306,
    -- New World BOSS Kill Record
    EID_EVENT_NEWWORLDBOSS_KILLRECORD = 307,
    -- Follow/Unfollow a New World BOSS
    EID_EVENT_NEWWORLDBOSS_FOLLOW = 308,
    -- New World BOSS damage ranking interface refresh
    EID_EVENT_NEWWORLDBOSS_HARMRANKREFRESH = 309,
    -- Realm upgrade
    EID_EVENT_REALM_LEVELUP = 310,
    -- Turn off remote players' interactions
    EID_EVENT_CLOSE_REMOTE_PLAYER_ALTERNATELY = 311,
    -- Refresh the main interface of marriage
    EID_EVENT_MARRY_INFO_REFRESH = 312,
    -- Refreshing the data of marriage fairy kids
    EID_EVENT_MARRY_CHILD_REFRESH = 313,
    -- Refresh the data of marriage banquets
    EID_EVENT_MARRY_WEDDING_DATA_REFRESH = 314,
    -- Refresh the data of the marriage interface
    EID_EVENT_MARRY_BLESS_DATA_REFRESH = 315,
    -- Refresh the Marriage Treasure Box Data
    EID_EVENT_MARRY_BOX_REFRESH = 316,
    -- Initialization information of the Divine Soldier
    EID_EVENT_GODWEAPON_INIT = 317,
    -- Divine weapon upgrade
    EID_EVENT_GODWEAPON_LEVELUP = 318,
    -- Divine weapon upgrade
    EID_EVENT_GODWEAPON_QUALITYUP = 319,
    -- Divine weapon activation
    EID_EVENT_GODWEAPON_ACTIVE = 320,
    -- Divine weapon assembly
    EID_EVENT_GODWEAPON_EQUIP = 321,
    -- Divine weapons props update
    EID_EVENT_GODWEAPON_UPDATERED = 322,
    -- Play the magic weapon effect
    EID_EVENT_GODWEAPON_PLAYERANIM = 323,
    -- Welfare login gift package (login on 7th) interface update
    EID_EVENT_WELFARE_LOGINGIFT_REFRESH = 324,
    -- Refresh the welfare sign-in interface
    EID_EVENT_WELFARE_DAILYCHECK_REFRESH = 325,
    -- Update the growth fund interface
    EID_EVENT_WELFARE_INVEST_REFRESH = 326,
    -- Update the Hongmeng Enlightenment Interface
    EID_EVENT_WELFARE_WUDAO_REFRESH = 327,
    -- Update the daily gift package interface
    EID_EVENT_WELFARE_DAILYGIFT_REFRESH = 328,
    -- Successfully redeemed the gift package
    EID_EVENT_WELFARE_EXCHANGEGIFT_SUCCESS = 329,
    -- Refresh the welfare interface
    EID_EVENT_WELFARE_REFRESH_BASE_PANEL = 330,
    -- Welfare level gift pack refresh
    EID_EVENT_WELFARE_LVGIFT_REFRESH = 331,
    -- Open the server carnival and open the interface and request to return
    EID_EVENT_SERVECRAZYFORM_OPENRESULT = 332,
    -- Update the server carnival interface news
    EID_EVENT_SERVECRAZYFORM_UPDATE = 333,
    -- Update the results of the service opening carnival award
    EID_EVENT_SERVECRAZYFORM_REWARD = 334,
    -- Update the interface of growth path
    EID_EVENT_GROWTHWAYFORM_UPDATE = 335,
    -- Update the server opening activity interface
    EID_EVENT_SERVERACTIVEFORM_UPDATE = 336,
    -- Refresh the Immortal Soul Information
    EID_EVENT_XIANPOINFO_REFRESH = 337,
    -- Show the inlay information of the fairy soul
    EID_EVENT_SHOW_XIANPOINLAYINFOS = 338,
    -- Refresh the Xianpo decomposition interface
    EID_EVENT_XIANPO_DECOMPOSITION = 339,
    -- Refresh the Fairy Soul Exchange Interface
    EID_EVENT_XIANPO_EXCHANGE = 340,
    -- Refresh the Xianso synthesis interface
    EID_EVENT_XIANPO_SYNTHETIC = 341,
    -- Fashion information change message
    EID_EVENT_FASHION_UPDATECHANGE = 342,
    -- BOSS Home Refresh Time
    EID_EVENT_BOSSHOME_REFRESHTIME = 343,
    -- BOSS Home Kill Record
    EID_EVENT_BOSSHOME_KILLRECORD = 344,
    -- Follow/Unfollow a BOSS home of a BOSS
    EID_EVENT_BOSSHOME_FOLLOW = 345,
    -- Boss Home damage ranking interface refresh
    EID_EVENT_BOSSHOME_HARMRANKREFRESH = 346,
    -- Boss set, Gem Boss refresh
    BOSS_EVENT_SUIT_GEM_BOSS_REFESH = 347,
    -- Refresh the data of the treasure hunting prize pool
    EID_EVENT_TREASURE_FIND_REFRESH = 348,
    -- First charge interface refresh
    EID_EVENT_FIRST_CHARGE_REFRESH = 349,
    -- World answer status switching message
    EID_EVENT_WORLDANSWER_CHANGESTATE = 350,
    -- Updated world answer interface announcement
    EID_EVENT_WORLDANSWER_GONGGAO = 351,
    -- Guarding the Sect Data Refresh
    EID_EVENT_GUARDIANFACTION_REFRESH = 352,
    -- The server name has been successfully renamed
    EID_EVENT_SERVER_CHANGNAME_SUCCESS = 353,
    -- Players change their status
    EID_EVENT_COMMANDFOLLOW_CHANGE = 354,
    -- Add world BOSS rankings
    EID_EVENT_ADDWORLDRANKCOUNT = 355,
    -- Synchronous World BOSS Revenues
    EID_EVENT_UPDATEREMINRANKCOUNT = 356,
    -- Realm BOSS data update
    EID_EVENT_UIPDATESTATUREBOSSDATA = 357,
    -- Equipment smelting message returns
    EID_EVENT_UPDATEEQUIPSMELTRESULT = 358,
    EID_EVENT_UPDATEAUTOSMELTSTATE = 359,
    -- Refresh the realm of spiritual pressure information
    EID_EVENT_UPDATE_REALMSTIFLE_INFO = 360,
    -- Synchronize the world's BOSS ranking recovery time
    EID_EVENT_UPDATERRCOVERTIME = 361,
    -- Synchronous Eight Pole Array Copy Information
    EID_EVENT_UPDATE_BAJIZHENCOPY_INFO = 362,
    -- Remaining time for synchronous Eight Pole Array Copy
    EID_EVENT_UPDATE_BAJIZHENCOPY_TIME = 363,
    -- Territory Battle BOSS information update
    EID_EVENT_MANORWAR_BOSSLIST_UPDATE = 364,
    -- Territory War Rage Value Update
    EID_EVENT_MANORWAR_ANGER_UPDATE = 365,
    -- Cross-server territory war data update
    EID_EVENT_MANORWAR_CROSSNOMAL_UPDATE = 366,
    -- Auction house refresh list
    EID_EVENT_AUCTION_UPDATELIST = 367,
    -- The auction house successfully listed
    EID_EVENT_AUCTION_UP_SUCC = 368,
    -- The auction house takes off the shelves and returns
    EID_EVENT_AUCTION_DOWN_RESULT = 369,
    -- Buy it in one price and return
    EID_EVENT_AUCTION_BUY_RESULT = 370,
    -- Bidding Return
    EID_EVENT_AUCTION_JINGJIA_RESULT = 371,
    -- Return to personal record list
    EID_EVENT_AUCTION_SELFRECORD_LIST = 372,
    -- World List Record Return
    EID_EVENT_AUCTION_WORLDRECORD_LIST = 373,
    -- The auction house lists red dots updated
    EID_EVENT_AUCTION_REDPOINT_UPDATED = 374,
    -- The message of the Eight Pole Array Diagram UI is returned
    EID_EVENT_BAJIZHENTU_OPEN_RESULT = 375,
    -- Check the progress of the Eight Pole Array
    EID_EVENT_BAJIZHEN_OPEN_JINDU = 376,
    -- Bonfire activities related
    EID_EVENT_BONFIRE_ADD_WOOD = 377,
    -- Refresh the bonfire copy interface
    EID_EVENT_BONFIRE_REFRESH_PANEL = 378,
    -- End of single boxing
    EID_EVENT_BONFIRE_HQ_SINGLE_OVER = 379,
    -- The boxing game ends
    EID_EVENT_BONFIRE_HQ_GAME_OVER = 380,
    -- Receive boxing rewards
    EID_EVENT_BONFIRE_HQ_REWARD = 381,
    -- Cancel the punching match
    EID_EVENT_BONFIRE_CANCEL_MATCH = 382,
    -- End of punching
    EID_EVENT_BONFIRE_EXIT_GAME = 383,
    -- Refresh the spiritual body function interface
    EID_EVENT_LINGTIFORM_REFREASH = 384,
    -- Refresh the Hall of Fame interface
    EID_EVENT_CELEBRITY_UPDATE = 385,
    -- Open the first charge Tips
    EID_EVENT_FIRST_RECHAGE_TIPS = 386,
    -- Limited time store refresh
    EID_EVENT_LIMITSHOP_REFRSH = 387,
    -- Enter the map
    EID_EVENT_ENTERMAP = 388,
    -- World Support Reminder
    EID_EVENT_WORLDSUPPORT_ALERT = 389,
    -- Calculate the server opening time to push messages
    EID_EVENT_CALCULATE_OPENSERVERTIME = 390,
    -- Resource Retrieval Function Interface Update Message
    EID_EVENT_RESBACKFORM_UPDATE = 391,
    -- Refreshed to get new limited-time products
    EID_EVENT_NEWLIMITSHOP_REFRESH = 392,
    -- Update function trailer
    EID_EVENT_UPDATEFUNCNOTICE_INFO = 393,
    -- Model display
    EID_EVENT_SHOWMODEL_VIEW = 394,
    -- Refresh the Sword Spirit Pavilion
    EID_EVEMT_UPDATE_SWORDMANDATE = 395,
    -- Show Sword Ling Pavilion Rewards
    EID_EVEMT_UPDATE_SWORDMANDATE_RESULT = 396,
    -- Show quick rewards
    EID_EVEMT_QUICL_SWORDMANDATE_RESULT = 397,
    -- The main interface displays guest buttons
    EID_EVENT_MAIN_SHOW_BINGKE = 398,
    -- An email attachment exists
    EID_EVENT_MAILEXISTITEMS = 399,
    -- Set up Arena Copy Mask
    EID_EVENT_SETJJCMASK = 400,
    -- Free VIP state changes
    EID_FREEVIP_GETSTATE_CHANGED = 401,
    -- Level gift pack Tips refresh
    EID_LEVELGIFTTIPS_REFRESH = 402,
    -- Team recruitment
    EID_EVENT_UITEAMHANHUACD = 403,
    -- Open the welcome interface
    EID_EVENT_OPEN_WELECOME_PANEL = 404,
    -- Release the welcome interface resources
    EID_EVENT_UNLOAD_WELECOME_RES = 405,

    -- Log in to the gateway server successfully
    EID_EVENT_AGENT_LOGIN_SUCCESS = 406,
    -- Log in to the game successfully
    EID_EVENT_GAME_LOGIN_SUCCESS = 407,
    -- Immortal Alliance Settings Update
    EID_EVENT_GUILD_SETTING_UPDATE = 408,
    -- Mount BOSS data update
    EID_EVENT_CROSSMOUNTBOSS_REFRESHTIME = 409,
    EID_EVENT_CROSSMOUNTBOSS_FOLLOW = 410,
    EID_EVENT_CROSSMOUNTBOSS_ADDCOUNT = 411,
    -- Mount equipment backpack refresh
    EVENT_MOUNTEQUIP_BAGCHANGE = 412,
    -- Mount wear equipment update
    EID_EVENT_MOUNTEQUIP_WEARUPDATE = 413,
    EID_EVENT_MOUNTEQUIP_MOUNTLISTUPDATE = 414,
    EID_EVENT_MOUNTEQUIP_TOTALSTRENGTHRESULT = 415,
    -- Mount equipment enhancement update
    EID_EVENT_MOUNTEQUIP_STRENGTHRESULT = 416,
    EID_EVENT_MOUNTEQUIP_TotalSoulRESULT = 417,
    EID_EVENT_MOUNTEQUIP_SoulRESULT = 418,
    EID_EVENT_MOUNTEQUIP_SYNTHRESULT = 419,
    -- Give up belonging
    EID_EVENT_MOUNTBOSS_GIVEUP = 420,
    -- Mount equipment rating refresh
    EID_EVENT_MOUNTEQUIP_SCORE_UPDATE = 421,
    -- Refreshing the ancient order
    EID_EVENT_HuangGuLing_UPDATE = 422,
    EID_EVENT_HuangGuLing_BUYSUCCESS = 423,
    EID_EVENT_CROSSMOUNTBOSS_REFRESBTNREDPOINR = 424,
    EID_EVENT_HuangGuLing_REFRESHRANK = 425,
    -- Demon King Rift Group Data Refresh
    EID_EVENT_OYLIEKAI_COPYDATA_RESULT = 426,
    -- The interface data refresh of the Magic Chamber
    EID_EVENT_FENTMT_DRAW_REFRESH = 427,
    -- Updated data of Demon Removal Group
    EID_EVENT_SLAYER_LISTUPDATE = 428,
    -- The Demon Removal Group is concerned
    EID_EVENT_SLAYER_FOLLOW = 429,
    -- Updated points for Demon Removal Group
    EID_EVENT_SLAYER_SCORE_UPDATE = 430,
    -- The Magic Seal Platform refreshes the interface
    EID_EVENT_FMT_DRAW_REFRESH = 431,
    -- Gossip top set number menu is selected
    EID_EVENT_BAGUA_TOPMENU_UPDATE = 432,
    -- Update information about the Divine Soldier of Creation Eats Fruits
    NATURE_EVENT_WEAPON_UPDATEDRUG = 433,
    -- Demon Soul Equipment Backpack Refresh
    EID_EVENT_DEVILEQUIP_BAGCHANGE = 434,
    -- Demon Removal Group Point Ranking Data
    EID_EVENT_SLAYERRANK_UPDATE = 435,
    -- Demon Elimination Group BOSS Data
    EID_EVENT_SLAYERCOPY_BOSSINFO = 436,
    EID_EVENT_SLAYERCOPY_BOSSHARM = 437,
    -- Demon soul upgrade unlock
    EID_EVENT_DEVILCARD_LV_UP = 438,
    -- Demon Soul Equipment Synthesis
    EID_EVENT_DEVIL_EQUIP_SYNTHESIS = 439,
    -- Demon soul breakthrough
    EID_EVENT_DEVILCARD_BREAK = 440,
    -- Demon soul equipment wear
    EID_EVENT_DEVILCARD_EQUIP_WEAR = 441,
    -- All data of Demon Soul is refreshed
    EID_EVENT_DEVILCARD_DATA_REFESH = 442,
    -- Check the status of the super discount product to return
    EID_EVENT_LIMITSHOP_CHECK_RESULT = 443,
    -- Update the boss list of the Demon King's World Display
    EID_EVENT_HUOSHI_BOSSLIST_UPDATE = 444,
    -- Update ranking gossip
    EID_EVENT_RANK_BAGUA_UPDATE = 445,
    -- Demon Soul Battle Power Update
    EID_EVENT_DEVILCARD_FIGHT_POWER_REFESH = 446,
    -- Update the Peak Fund Interface
    EID_EVENT_WELFARE_Peak_REFRESH = 447,
    -- Demon Soul Equipment Synthesis
    EID_EVENT_DEVILEQUIPTIPS_PUTIN = 448,
    -- Resource recovery three times confirmation return
    EID_EVENT_RESBACK_MSG_TISHI_RESULT = 449,
    -- Demon Soul Red Dot News Update
    EID_EVENT_DEVILCARD_REDPOINT = 450,
    -- Spirit Soul Core Upgrade Return
    EID_EVENT_LINGPO_CORE_LV_RESULT = 451,
    -- House visitor record update
    EID_EVENT_HOME_VISITORNOTE_UPDATE = 452,
    -- House Grade Update
    EID_EVENT_HOME_LV_UPDATE = 453,
    -- House gift list issuance
    EID_EVENT_HOME_GIFTLIST = 454,
    -- House objects update
    EID_EVENT_HOME_JIAJU_UPDATE = 455,
    -- Wedding Coupon Barrage Detection, used to determine whether the special effects of purchasing hot gift packages are displayed
    EID_EVENT_MARRYCOPY_DANMU = 456,
    -- The status of the wedding copy hot gift package purchase changes
    EID_EVENT_MARRYCOPY_HOTGIFT_CHANGED = 457,
    -- House map object data issuance
    EID_EVENT_HOME_ALLJIAJU_UPDATE = 458,
    -- Perfect Love Ranking Data Refresh
    EID_EVENT_PREFECT_RANK_REFESH = 459,
    -- Perfect Love Store data refresh
    EID_EVENT_PREFECT_GIFT_REFESH = 460,
    -- Perfect Love Task Data Refresh
    EID_EVENT_PREFECT_TASK_REFESH = 461,
    -- Refresh friend application list
    EID_EVENT_FRIENDAPPLY_REFESH = 462,
    -- Friends gift friendship point status update
    EID_EVENT_FRIEND_UPDATE_FRIENDSHIP = 463,
     -- Friendship Point Status Update
    EID_EVENT_FRIEND_UPDATE_FRIENDSHIPPOINT = 464,
    -- A new friend shows a prompt
    EID_EVENT_FRIEND_UPDATE_NEWFRIENDNOTIC = 465,
    -- Immortal Alliance Treasure Chest List Update
    EID_EVENT_GUILDBOXLIST_UPDATE = 466,
    -- NPC Friends Dialogue Trigger Type
    EID_EVENT_NPCFRIENFTRIGGERTYPE_LEVEL = 467,
    EID_EVENT_NPCFRIENFTRIGGERTYPE_TASK = 468,
    EID_EVENT_NPCFRIENFTRIGGERTYPE_SENDSHIP = 469,
    EID_EVENT_NPCFRIENFTRIGGERTYPE_GETSHIP = 470,
    EID_EVENT_NPCFRIENFTRIGGERTYPE_SENGMSG = 471,
    EID_EVENT_NPCFRIENFTRIGGERTYPE_DAYOFF = 472,
    -- Community selects birthday date callback
    EID_EVENT_COMMUNITY_CHANGEBRITH = 473,
    -- NPC actively gives out friendship points incident
    EID_EVENT_NPCFRIEND_SENDSHIP = 474,
    -- Immortal Alliance Treasure Chest Record Update
    EID_EVENT_GUILDBOXLOG_UPDATE = 475,
    -- Refresh the server list form
    EID_EVENT_UISERVERLISTFORM_REFRESH_LIST = 476,
    -- Sword Lingge jumps to return
    EID_EVENT_JLG_TIAOGUAN_RESULT = 477,
    -- Community personal information settings are completed and refresh callback is called
    EID_EVENT_COMMUNITY_SETTING = 478,
    -- Sword Lingge data return
    EID_EVENT_JLG_DATA_RESULT = 479,
    -- Open monthly card Tips
    EID_EVENT_MONTH_CARD_TIPS = 480,
    -- Open the community message board
    EID_EVENT_COMMUNITY_MSGBOARD_OPEN = 481,
    -- Have unreceived friendship points
    EID_EVENT_FRIEND_FRIENDSHIP = 482,
    -- Main interface tryhide
    EID_EVENT_MIANUI_TRY_HIDE = 483,
    -- Confirmation of registration for fairy couples
    EID_EVENT_LOVERS_FREE_FIGHT_JOIN_CONFIRM = 484,
    -- Registration results for Fairy Couple Duel Examinations
    EID_EVENT_LOVERS_FREE_FIGHT_JOIN_RESULT = 485,
    -- Return information for fairy couple showdown
    EID_EVENT_LOVERS_FREE_FIGHT_INFO = 486,
    -- Receive rewards for fairy couples duel auditions
    EID_EVENT_LOVERS_FREE_REWARD = 487,
    -- The fairy couple showdown cancels match
    EID_EVENT_LOVERS_FREE_PIPEI_STOP = 488,
    -- Fairy Couple Duel Examinations Match Confirmation Return
    EID_EVENT_LOVERS_FREE_PIPEI_CONFIRM = 489,
    -- The fairy couple showdown match successfully returned
    EID_EVENT_LOVERS_FREE_PIPEI_SUCCESS = 490,
    -- The match begins with the fairy couple's duel auditions
    EID_EVENT_LOVERS_FREE_PIPEI_START = 491,
    -- Return information of the fairy couple duel group match
    EID_EVENT_LOVERS_GROUP_FIGHT_INFO = 492,
    -- Return the ranking information of the fairy couple duel group match
    EID_EVENT_LOVERS_GROUP_FIGHT_RANK = 493,
    -- Return information of the fairy couple duel championship match
    EID_EVENT_LOVERS_TOP_FIGHT_INFO = 494,
    -- Return of the Immortal Couple Confrontation Betting Data
    EID_EVENT_LOVERS_TOP_PICK_INFO = 495,
    -- Updated data for fairy couple showdown
    EID_EVENT_LOVERS_TOP_PICK_UPDATE = 496,
    -- Random voting for home decoration contest
    EID_EVENT_DECORATE_RANDOM_VOTE = 497,
    -- Return to the Fairy Couple Duel Support List
    EID_EVENT_LOVERS_TOP_ALLPICK_INFO = 498,
    -- Fan rankings for fairy couples
    EID_EVENT_LOVERS_TOP_RANK_INFO = 499,
    -- Refresh the data of the home improvement competition
    EID_EVENT_DECORATE_MAIN_DATA = 500,
    -- The character's custom avatar changes
    EID_EVENT_LP_CHANGE_CUSTOMHEAD = 501,
    -- Open community personal news
    EID_EVENT_COMMUNITY_DYNAMCIPANEL_OPEN = 502,
    -- Home interface message returns
    EID_EVENT_HOUSE_INFO_RESULT = 503,
    -- Refresh the realm preview
    EID_EVENT_REFRESH_CJ_PREVIEW = 504,
    -- Refresh the preaching tips
    EID_EVENT_REFRESH_CHUANDAOTIPS = 505,
    -- Daily task interface refresh message
    EID_EVENT_NEWDAILYTASK_REFRESH = 506,
    -- Refresh the boss home remaining times
    EID_EVENT_REFRESH_BOSSHOME_COUNT = 507,
    -- Refresh boss home kill record
    EID_EVENT_REFRESH_BOSSHOME_KILLRECORD = 508,
    -- Refresh the 0 yuan purchase interface
    EID_EVENT_REFRESH_ZEROBUY_FORM = 509,
    -- Refresh the 0 yuan purchase record interface
    EID_EVENT_REFRESH_ZEROBUY_RECORD_FORM = 510,
    -- Update on job transfer tasks
    EID_EVENT_CHANJEJOB_TASK_UPDATED = 511,
    -- Ranking status returns
    EID_EVENT_RANK_STATE_RESULT = 512,
    -- God-grade equipment or level up return
    EID_EVENT_GODEQUIP_RESULT = 513,
    -- Start automatic transfer tasks
    EID_EVENT_START_DITRANSFER_TASK = 514,
    -- Refresh the data of the treasure hunt treasure recycling interface
    EID_EVENT_TREASURE_RECOVERY_REFRESH = 515,
    -- Refresh properties online
    EID_EVENT_ONLINE_REFRESH_ATT = 516,
    -- Refresh the free gift package for benefits
    EID_EVENT_REFRESH_WEFREEGIFT = 517,
    -- Home Task Update Message
    EID_EVENT_HOMETASKCHANG = 518,
    -- Home Cornucopia Data
    EID_EVENT_HOMETUPINFO = 519,
    -- Refresh today's event interface
    EID_EVENT_REFRESH_TODAYFUNC_INFO = 520,
    -- The peak competitive match message was successfully sent and updated
    EID_EVENT_TOPJJC_MATCHSUC = 521,
    -- Experience update of Peak Competitive Dun
    EID_EVENT_TOPJJC_EXPUPDATE = 522,
    -- Return to the ranking information of the fairy couple showdown
    EID_EVENT_LVOERSFIGHT_FREE_RANK = 523,
    -- Immortal Alliance Battle Copy Map Experience Update
    EID_EVENT_XMFIGHT_EXP_UPDATE = 524,
    -- Xianlu store refresh
    EID_EVENT_XIANLV_SHOP_REFRESH = 525,
    -- Play peak competitive animation
    EID_EVENT_PLAYTOPJJC_UI_ANIM = 526,
    -- Update the red dot of the ancient demon seal
    EID_EVENT_LIEXI_REDPOINT = 527,
    -- Attached interface loading bottom map
    EID_EVENT_ATTACHORMLOAD_BACKTEX = 528,
    -- Changes in the number of synthetic materials for the fantasy
    EID_EVENT_UNREAL_ITEM_CHANGED = 529,
    -- Initialization of the fantasy installation online
    EID_EVENT_UNREAL_EQUIP_ONLINE = 530,
    -- Updated fantasy parts
    EID_EVENT_UNREAL_EQUIP_PART = 531,
    -- Phantom soul update
    EID_EVENT_UNREAL_EQUIP_SOULUPDATE = 532,
    -- Update backpack
    EID_EVENT_UNREAL_EQUIP_UPDATE_BAG = 533,
    -- Playing and synthesizing effects successfully
    EID_EVENT_UNREAL_EQUIP_PLAY_SYNCVFX = 534,
    -- Refresh the magical equipment combat power
    EID_EVENT_UNREAL_EQUIP_FIGHTPOWER = 535,
    -- Add a magic dress
    EID_EVENT_UNREAL_EQUIP_ADD = 536,
    -- Delete the magic outfit
    EID_EVENT_UNREAL_EQUIP_DELETE = 537,
    -- Spiritual Soul Change
    EID_EVENT_LINGPO_EXCHANGE = 538,
    -- Sumeru Treasure House BOSS damage update
    EID_EVENT_XUMIBAOKU_BOSSHARM = 539,
    EID_EVENT_XUMIBAOKU_BOSSINFO = 540,
    -- Refresh the protocol CheckBox
    EID_EVENT_LOGIN_REFRESH_AGREEMENT_CHECKBOX = 541,
    -- Fairy Couple Duel Examinations Settlement Return
    EID_EVENT_LOVERSFIGHT_FREE_RESULT = 542,
    -- Red envelope list update
    EID_EVENT_GUILDREDPACKAGE_UPDATE = 543,
    -- v4 helps to refresh the gift package
    EID_EVENT_V4HELP_REFRESH = 545,
    -- Refreshing the rebate package
    EID_EVENT_REBATEBOX_REFRESH = 546,
    -- v4 rebate refresh
    EID_EVENT_REBATE_REFRESH = 547,
    -- Fang Ze treasure tent refresh
    EID_EVENT_FZTB_REFRESH = 548,
    -- Data of the Immortal Alliance Contest
    EID_EVENT_XMZB_DATA_UPDATE = 549,
    -- Community mall product list update
    EID_EVENT_HOUSESHOP_UPDATE = 550,
    EID_EVENT_HOUSESHOPDATA_UPDATE = 551,
    EID_EVENT_XUKONG_UPDATE = 552,
    -- Chaos Void Boss List Update
    EID_EVENT_XUKONG_BOSS_UPDATE = 553,
    -- Fang Ze Treasure Opens the lottery interface
    EID_EVENT_FZTB_OPENDRAWVIEW = 554,
    -- Open the Temporary Warehouse for Treasure Hunt
    EID_EVENT_OPEN_TREASURE_WAREHOUSE = 555,
    -- Update offline recovery time
    EID_EVENT_UPDATE_OFFLINEFINDTIME = 556,
    EID_EVENT_UPDATE_REMOVE_GEM = 557, -- event gỡ gem
    -- Player Stat System Events
    EID_EVENT_PLAYERSTAT_UPDATE = 558,
    -- Chuyển cường hóa
    EID_EVENT_MOVE_EQUIP_STRENGTH_LV = 559,
    -- Shop Orb Result
    EID_EVENT_SHOP_ORB_RESULT = 560,
    EID_EVENT_SHOP_ORB_RESULT_1 = 561, -- Event ID placeholder
    EID_EVENT_SHOP_ORB_RESULT_2 = 562, -- Event ID placeholder
    EID_EVENT_SHOP_ORB_RESULT_3 = 563, -- Event ID placeholder
    EID_EVENT_SHOP_ORB_RESULT_4 = 564, -- Event ID placeholder 
    EID_EVENT_SHOP_ORB_RESULT_5 = 565, -- Event ID placeholder 
    -- Dogiam
    EID_DOGIAM_SINGLE_ACTIVE = 566,
    EID_DOGIAM_UPSTAR_RESULT = 567,
    EID_DOGIAM_ACTIVE_RESULT = 568,
    EID_DOGIAM_CLOSE = 569,
    -- Vận lúa
    EID_EVENT_ESCORT_DATA_UPDATE = 570,
    EID_EVENT_ESCORT_REFRESH = 571,
    -- BOSS
    EID_WORLD_BOSS_KILL_RECORD_CLOSE = 572,
    -- Menu Box
    EID_EVENT_ON_MAIN_RIGHT_MENU_OPEN = 573,
    EID_EVENT_ON_MAIN_RIGHT_MENU_CLOSE = 574,
    -- Linh khí, Sát khí
    EID_EVENT_PK_POINT = 575,
    EID_EVENT_EXP_TIME = 576,
    -- Map Nhà Giam
    EID_EVENT_ENTER_PRISON_MAP = 577,
    EID_EVENT_LEAVE_PRISON_MAP = 578,
};

for k, v in pairs(LogicLuaEventDefine) do
    LogicLuaEventDefine[k] = v + L_BASE_ID;
end

return LogicLuaEventDefine;
