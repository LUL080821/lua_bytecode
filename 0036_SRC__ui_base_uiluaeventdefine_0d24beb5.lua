------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: UILuaEventDefine.lua
-- Module: UILuaEventDefine
-- Description: Event definition window (form event not defined by C#), the start of the event starts at 50000 + EventConstDefine.EVENT_UI_BASE_ID
------------------------------------------------
local L_BASE_ID = EventConstDefine.EVENT_UI_BASE_ID

-- Module definition
local UILuaEventDefine = {
    -- Message form definition
    UILogUploadForm_OPEN = 50100 + L_BASE_ID,
    UILogUploadForm_CLOSE = 50109 + L_BASE_ID,

    -- Email refresh
    UIMailRefreshUI = 50111 + L_BASE_ID,
    UIMailRefreshChangeMail = 50112 + L_BASE_ID,

    -- The interface of the Immortal Alliance War UI
    -- Immortal Alliance Battle Entrance Interface
    UIXmFightForm_OPEN = 50120 + L_BASE_ID,
    UIXmFightForm_CLOSE = 50129 + L_BASE_ID,

    -- Immortal Alliance Statistical Interface
    UIXmTongJiForm_OPEN = 50130 + L_BASE_ID,
    UIXmTongJiForm_CLOSE = 50139 + L_BASE_ID,

    -- Immortal Alliance God of War List
    UIXmRankForm_OPEN = 50140 + L_BASE_ID,
    UIXmRankForm_CLOSE = 50149 + L_BASE_ID,

    -- Xianlian settlement interface
    UIXmJieSuanForm_OPEN = 50150 + L_BASE_ID,
    UIXmJieSuanForm_CLOSE = 50159 + L_BASE_ID,

    -- Immortal Alliance dungeon interface
    UIXmZbCopyForm_OPEN = 50160 + L_BASE_ID,
    UIXmZbCopyForm_CLOSE = 50169 + L_BASE_ID,

    -- Immortal Alliance Boss
    UIXMBossForm_OPEN = 50170 + L_BASE_ID,
    UIXMBossForm_CLOSE = 50179 + L_BASE_ID,

    -- Vehicle interface
    UIXMFightCarForm_OPEN = 50180 + L_BASE_ID,
    UIXMFightCarForm_CLOSE = 50189 + L_BASE_ID,

    -- Ranking of the Immortal Alliance Boss during Battle
    UIXMBossRankForm_OPEN = 50190 + L_BASE_ID,
    UIXMBossRankForm_CLOSE = 50199 + L_BASE_ID,

    -- Xianmeng Boss settlement interface
    UIXMBossResultForm_OPEN = 50200 + L_BASE_ID,
    UIXMBossResultForm_CLOSE = 50209 + L_BASE_ID,

    -- Immortal League Boss Inspiration Interface
    UIXMBossHearten_OPEN = 50210 + L_BASE_ID,
    UIXMBossHearten_CLOSE = 50219 + L_BASE_ID,

    -- Immortal Armor Treasure Hunt
    UIXJXunbaoForm_OPEN = 50220 + L_BASE_ID,
    UIXJXunbaoForm_CLOSE = 50229 + L_BASE_ID,

    -- Fairy Armor Treasure Hunt Warehouse
    UIXJCangkuForm_OPEN = 50230 + L_BASE_ID,
    UIXJCangkuForm_CLOSE = 50239 + L_BASE_ID,

    -- Immortal Armor Treasure Hunt
    UIXJMibaoForm_OPEN = 50240 + L_BASE_ID,
    UIXJMibaoForm_CLOSE = 50249 + L_BASE_ID,

    -- The main interface of the fairy armor treasure hunt
    UIXJXunbaoRootForm_OPEN = 50250 + L_BASE_ID,
    UIXJXunbaoRootForm_CLOSE = 50259 + L_BASE_ID,

    -- VIP Basic Interface
    UIVipBaseForm_OPEN = 50260 + L_BASE_ID,
    UIVipBaseForm_CLOSE = 50269 + L_BASE_ID,

    -- Immortal Alliance Battle Help Interface
    UIXmHelpForm_OPEN = 50270 + L_BASE_ID,
    UIXmHelpForm_CLOSE = 50279 + L_BASE_ID,

    -- VIP upgrade interface
    UIVipLvForm_OPEN = 50280 + L_BASE_ID,
    UIVipLvForm_CLOSE = 50289 + L_BASE_ID,

    -- New fashion basic interface
    UINewFashionForm_OPEN = 50290 + L_BASE_ID,
    UINewFashionForm_CLOSE = 50299 + L_BASE_ID,

    -- Fashion cabinet interface
    UIWardrobeForm_OPEN = 50300 + L_BASE_ID,
    UIWardrobeForm_LOAD = 50301 + L_BASE_ID,
    UIWardrobeForm_CLOSE = 50309 + L_BASE_ID,

    -- Xianmeng Auction Tips
    UIXmAuctionTipsForm_OPEN = 50310 + L_BASE_ID,
    UIXmAuctionTipsForm_CLOSE = 50319 + L_BASE_ID,

    -- Cross-server stage display
    UICrossServerMapForm_OPEN = 50320 + L_BASE_ID,
    UICrossServerMapForm_CLOSE = 50329 + L_BASE_ID,

    -- Cross-Server Ranking
    UICrossRankForm_OPEN = 50330 + L_BASE_ID,
    UICrossRankForm_CLOSE = 50339 + L_BASE_ID,

    -- Downline prompt interface
    UIExitRewardTipsForm_OPEN = 50350 + L_BASE_ID,
    UIExitRewardTipsForm_CLOSE = 50359 + L_BASE_ID,

    -- O Yuan Purchase
    UIFreeGiftForm_OPEN = 50360 + L_BASE_ID,
    UIFreeGiftForm_CLOSE = 50369 + L_BASE_ID,

    -- The list of bosses on the left side of the crystal argent and domain
    UISuitGemWorldBossCopyLeftForm_OPEN = 50370 + L_BASE_ID,
    UISuitGemWorldBossCopyLeftForm_CLOSE = 50379 + L_BASE_ID,

    -- Wedding invitation interface
    UIMarryBanquetForm_OPEN = 50380 + L_BASE_ID,
    UIMarryBanquetForm_CLOSE = 50389 + L_BASE_ID,

    -- Marriage proposal interface
    UIMarryProposeForm_OPEN = 50390 + L_BASE_ID,
    UIMarryProposeForm_CLOSE = 50399 + L_BASE_ID,

    -- Activity prompt interface
    UIActivityNoticeForm_OPEN = 50400 + L_BASE_ID,
    UIActivityNoticeForm_CLOSE = 50409 + L_BASE_ID,

    -- Boss first kill prompt interface
    UIBossKillNoticeForm_OPEN = 50410 + L_BASE_ID,
    UIBossKillNoticeForm_CLOSE = 50419 + L_BASE_ID,

    -- Title acquisition prompt interface
    UITitleTipsForm_OPEN = 50420 + L_BASE_ID,
    UITitleTipsForm_Refresh = 50421 + L_BASE_ID,
    UITitleTipsForm_CLOSE = 50429 + L_BASE_ID,

    -- The interface of marriage consent and rejection
    UIMarryPromiseForm_OPEN = 50430 + L_BASE_ID,
    UIMarryPromiseForm_CLOSE = 50439 + L_BASE_ID,

    -- The main interface of Jianling Pavilion dungeon
    UISwordSoulCopyForm_OPEN = 50440 + L_BASE_ID,
    UISwordSoulCopyForm_CLOSE = 50449 + L_BASE_ID,

    -- Jianling Pavilion dungeon settlement interface
    UISwordSoulCopyResultForm_OPEN = 50450 + L_BASE_ID,
    UISwordSoulCopyResultForm_CLOSE = 50459 + L_BASE_ID,

    -- Update the announcement and award interface
    UIUpdateNoticeRewardForm_OPEN = 50460 + L_BASE_ID,
    UIUpdateNoticeRewardForm_CLOSE = 50469 + L_BASE_ID,

    -- New server activity interface
    UINewServerActivityForm_OPEN = 50470 + L_BASE_ID,
    UINewServerActivityForm_CLOSE = 50479 + L_BASE_ID,

    -- New server advantages
    UINewServerAdvantageForm_OPEN = 50480 + L_BASE_ID,
    UINewServerAdvantageForm_CLOSE = 50489 + L_BASE_ID,

    -- Perfect love
    UIPerfectLoveForm_OPEN = 50490 + L_BASE_ID,
    UIPerfectLoveForm_CLOSE = 50499 + L_BASE_ID,

    -- Spiritual Soul Lottery
    UILingPoLotteryForm_OPEN = 50500 + L_BASE_ID,
    UILingPoLotteryForm_CLOSE = 50509 + L_BASE_ID,

    -- Anti-addiction announcement tips
    UIFcmForm_OPEN = 50510 + L_BASE_ID,
    UIFcmForm_CLOSE = 50519 + L_BASE_ID,

    -- Recharge gift package related interface
    UIPayGiftPacksForm_OPEN = 50520 + L_BASE_ID,
    UIPayGiftPacksForm_CLOSE = 50529 + L_BASE_ID,

    -- Marriage Heart Lock Interface Definition
    UIMarryHeartLockForm_OPEN = 50530 + L_BASE_ID,
    UIMarryHeartLockForm_CLOSE = 50539 + L_BASE_ID,

    -- Skip the interface
    UISkipForm_OPEN = 50540 + L_BASE_ID,
    UISkipForm_CLOSE = 50549 + L_BASE_ID,

    -- Limited time login
    UIYYHDChild3000Form_OPEN = 50550 + L_BASE_ID,
    UIYYHDChild3000Form_CLOSE = 50559 + L_BASE_ID,

    -- Marriage and love copy
    UIMarryQingYuanCopyForm_OPEN = 50560 + L_BASE_ID,
    UIMarryQingYuanCopyForm_CLOSE = 50569 + L_BASE_ID,

    -- Fashion illustration
    UIFashionTjForm_OPEN = 50570 + L_BASE_ID,
    UIFashionTjForm_CLOSE = 50579 + L_BASE_ID,

    -- Fashion
    UIFashionForm_OPEN = 50580 + L_BASE_ID,
    UIFashionForm_CLOSE = 50589 + L_BASE_ID,

    -- Saturday Carnival
    UIWeekCrazyForm_OPEN = 50590 + L_BASE_ID,
    UIWeekCrazyForm_CLOSE = 50599 + L_BASE_ID,

    -- Treasure Pavilion
    UIZhenCangGeForm_OPEN = 50600 + L_BASE_ID,
    UIZhenCangGeForm_CLOSE = 50609 + L_BASE_ID,

    -- Weekly benefits interface
    UILuckyDrawWeekForm_OPEN = 50610 + L_BASE_ID,
    UILuckyDrawWeekForm_CLOSE = 50619 + L_BASE_ID,

    -- Weekly benefits exchange reward interface
    UILuckyDrawChangeForm_OPEN = 50620 + L_BASE_ID,
    UILuckyDrawChangeForm_CLOSE = 50629 + L_BASE_ID,

    -- Dui Treasure Hall
    UIZhenCangGeExChangeForm_OPEN = 50630 + L_BASE_ID,
    UIZhenCangGeExChangeForm_CLOSE = 50639 + L_BASE_ID,

    -- Interface for failed settlement of love copy
    UIMarryQingyuanCopyResultForm_OPEN = 50640 + L_BASE_ID,
    UIMarryQingyuanCopyResultForm_CLOSE = 50649 + L_BASE_ID,

    -- Role comparison
    UICompareForm_OPEN = 50650 + L_BASE_ID,
    UICompareForm_CLOSE = 50659 + L_BASE_ID,

    -- Share Like
    UIShareAndLikeForm_OPEN = 50660 + L_BASE_ID,
    UIShareAndLikeForm_CLOSE = 50669 + L_BASE_ID,

    -- Share Like prompt interface
    UIShareAndLikeTipsForm_OPEN = 50670 + L_BASE_ID,
    UIShareAndLikeTipsForm_CLOSE = 50679 + L_BASE_ID,

    -- Purchase-limited store prompt interface
    UILimitShopTipsForm_OPEN = 50680 + L_BASE_ID,
    UILimitShopTipsForm_CLOSE = 50689 + L_BASE_ID,

    -- Thailand cumulative recharge Christmas
    UIYYHDChild6008Form_OPEN = 50690 + L_BASE_ID,
    UIYYHDChild6008Form_CLOSE = 50699 + L_BASE_ID,

    -- Thailand's cumulative recharge New Year's Day
    UIYYHDChild6001Form_OPEN = 50700 + L_BASE_ID,
    UIYYHDChild6001Form_CLOSE = 50709 + L_BASE_ID,

    -- Special offer for Thai holidays (direct purchase gift package)
    UIYYHDChild14008Form_OPEN = 50710 + L_BASE_ID,
    UIYYHDChild14008Form_CLOSE = 50719 + L_BASE_ID,

    -- Thailand limited time gift bag
    UIYYHDChild17001Form_OPEN = 50720 + L_BASE_ID,
    UIYYHDChild17001Form_CLOSE = 50729 + L_BASE_ID,

    -- New Year's Day celebration task interface
    UIYYHDChild12008Form_OPEN = 50730 + L_BASE_ID,
    UIYYHDChild12008Form_CLOSE = 50739 + L_BASE_ID,

    -- Word collection exchange interface
    UIYYHDChild13001Form_OPEN = 50740 + L_BASE_ID,
    UIYYHDChild13001Form_CLOSE = 50749 + L_BASE_ID,

    -- Log in to have a gift (New Year's Day)
    UIYYHDChild3001Form_OPEN = 50750 + L_BASE_ID,
    UIYYHDChild3001Form_CLOSE = 50759 + L_BASE_ID,

    -- Log in to have a gift (Christmas)
    UIYYHDChild3008Form_OPEN = 50760 + L_BASE_ID,
    UIYYHDChild3008Form_CLOSE = 50769 + L_BASE_ID,

    -- Daily Activities Tips UI
    UIDailyActivityTipsForm_OPEN = 50770 + L_BASE_ID,
    UIDailyActivityTipsForm_CLOSE = 50779 + L_BASE_ID,

    -- Thai Festival redemption interface
    UIYYHDChild8008Form_OPEN = 50780 + L_BASE_ID,
    UIYYHDChild8008Form_CLOSE = 50789 + L_BASE_ID,

    -- Thailand limited time cumulative charging interface
    UIYYHDChild15001Form_OPEN = 50790 + L_BASE_ID,
    UIYYHDChild15001Form_CLOSE = 50799 + L_BASE_ID,

    -- Thailand limited-time mall interface
    UIYYHDChild16001Form_OPEN = 50800 + L_BASE_ID,
    UIYYHDChild16001Form_CLOSE = 50809 + L_BASE_ID,

    -- Thailand Points Ranking Interface
    UIYYHDChild18008Form_OPEN = 50810 + L_BASE_ID,
    UIYYHDChild18008Form_CLOSE = 50819 + L_BASE_ID,

    -- Carnival Lucky Flop Interface
    UILuckyCardForm_OPEN = 50820 + L_BASE_ID,
    UILuckyCardForm_CLOSE = 50829 + L_BASE_ID,

    -- Holiday Wishes
    UIYYHDChild19008Form_OPEN = 50830 + L_BASE_ID,
    UIYYHDChild19008Form_CLOSE = 50839 + L_BASE_ID,

    -- Share (New Year's Day)
    UIYYHDChild20001Form_OPEN = 50840 + L_BASE_ID,
    UIYYHDChild20001Form_CLOSE = 50849 + L_BASE_ID,

    -- Share (Christmas)
    UIYYHDChild20008Form_OPEN = 50850 + L_BASE_ID,
    UIYYHDChild20008Form_CLOSE = 50859 + L_BASE_ID,

    -- New Year's Day operation activity bottom board
    UIYYHDYDBaseForm_OPEN = 50860 + L_BASE_ID,
    UIYYHDYDBaseForm_CLOSE = 50869 + L_BASE_ID,

    -- Christmas operation activity base
    UIYYHDSDBaseForm_OPEN = 50870 + L_BASE_ID,
    UIYYHDSDBaseForm_CLOSE = 50879 + L_BASE_ID,

    -- Christmas Events--The Leader Carnival
    UIYYHDChild11008Form_OPEN = 50880 + L_BASE_ID,
    UIYYHDChild11008Form_CLOSE = 50889 + L_BASE_ID,

    -- Thailand's continuous cumulative charging interface
    UIYYHDChild21001Form_OPEN = 50890 + L_BASE_ID,
    UIYYHDChild21001Form_CLOSE = 50899 + L_BASE_ID,

    -- Character base plate interface
    UIPlayerBaseForm_OPEN = 50900 + L_BASE_ID,
    UIPlayerBaseForm_CLOSE = 50909 + L_BASE_ID,

    -- Role attribute interface
    UIPlayerPropetryForm_OPEN = 50910 + L_BASE_ID,
    UIPlayerPropetryForm_CLOSE = 50919 + L_BASE_ID,

    -- The basic interface of the heavenly ban
    UITianJinLingBaseForm_OPEN = 50920 + L_BASE_ID,
    UITianJinLingBaseForm_CLOSE = 50929 + L_BASE_ID,

    -- Heavenly ban interface
    UITianJinLingForm_OPEN = 50930 + L_BASE_ID,
    UITianJinLingForm_CLOSE = 50939 + L_BASE_ID,

    -- Heavenly Ban mission interface
    UITianJinLingTaskForm_OPEN = 50940 + L_BASE_ID,
    UITianJinLingTaskForm_CLOSE = 50949 + L_BASE_ID,

    -- Immortal Cultivation Treasure Mirror Interface
    UIRankAwardForm_OPEN = 50950 + L_BASE_ID,
    UIRankAwardForm_CLOSE = 50959 + L_BASE_ID,

    -- Xianyuan mission interface
    UIMarryTaskForm_OPEN = 50960 + L_BASE_ID,
    UIMarryTaskForm_CLOSE = 50969 + L_BASE_ID,

    -- Active redemption for Valentine's Day
    UIYYHDChild1002Form_OPEN = 50970 + L_BASE_ID,
    UIYYHDChild1002Form_CLOSE = 50979 + L_BASE_ID,

    -- Log in to Valentine's Day
    UIYYHDChild3002Form_OPEN = 50980 + L_BASE_ID,
    UIYYHDChild3002Form_CLOSE = 50989 + L_BASE_ID,

    -- Log in to Youli Lantern Festival
    UIYYHDChild3010Form_OPEN = 50990 + L_BASE_ID,
    UIYYHDChild3010Form_CLOSE = 50999 + L_BASE_ID,

    -- Cumulative recharge Valentine's Day
    UIYYHDChild6002Form_OPEN = 51000 + L_BASE_ID,
    UIYYHDChild6002Form_CLOSE = 51009 + L_BASE_ID,

    -- Cumulative recharge for the Spring Festival
    UIYYHDChild6009Form_OPEN = 51010 + L_BASE_ID,
    UIYYHDChild6009Form_CLOSE = 51019 + L_BASE_ID,

    -- Collection redemption for Spring Festival (celebration redemption)
    UIYYHDChild8009Form_OPEN = 51020 + L_BASE_ID,
    UIYYHDChild8009Form_CLOSE = 51029 + L_BASE_ID,

    -- Group Buy Valentine's Day
    UIYYHDChild9002Form_OPEN = 51030 + L_BASE_ID,
    UIYYHDChild9002Form_CLOSE = 51039 + L_BASE_ID,

    -- Lucky Cat Valentine's Day
    UIYYHDChild10002Form_OPEN = 51040 + L_BASE_ID,
    UIYYHDChild10002Form_CLOSE = 51049 + L_BASE_ID,

    -- The leader carnivalentine's day
    UIYYHDChild11002Form_OPEN = 51050 + L_BASE_ID,
    UIYYHDChild11002Form_CLOSE = 51059 + L_BASE_ID,

    -- The leader carnival in the Spring Festival
    UIYYHDChild11009Form_OPEN = 51060 + L_BASE_ID,
    UIYYHDChild11009Form_CLOSE = 51069 + L_BASE_ID,

    -- Festival collection of Chinese New Year
    UIYYHDChild13009Form_OPEN = 51070 + L_BASE_ID,
    UIYYHDChild13009Form_CLOSE = 51079 + L_BASE_ID,

    -- Holiday special Valentine's Day
    UIYYHDChild14002Form_OPEN = 51080 + L_BASE_ID,
    UIYYHDChild14002Form_CLOSE = 51089 + L_BASE_ID,

    -- Special holidays for Spring Festival
    UIYYHDChild14009Form_OPEN = 51090 + L_BASE_ID,
    UIYYHDChild14009Form_CLOSE = 51099 + L_BASE_ID,

    -- Limited time store Valentine's Day (all service limited purchase)
    UIYYHDChild16002Form_OPEN = 51100 + L_BASE_ID,
    UIYYHDChild16002Form_CLOSE = 51109 + L_BASE_ID,

    -- Limited time mall Spring Festival (all service limited purchase)
    UIYYHDChild16009Form_OPEN = 51110 + L_BASE_ID,
    UIYYHDChild16009Form_CLOSE = 51119 + L_BASE_ID,

    -- Festival Wishes for Spring Festival
    UIYYHDChild19009Form_OPEN = 51120 + L_BASE_ID,
    UIYYHDChild19009Form_CLOSE = 51129 + L_BASE_ID,

    -- FB Share Valentine's Day
    UIYYHDChild20002Form_OPEN = 51130 + L_BASE_ID,
    UIYYHDChild20002Form_CLOSE = 51139 + L_BASE_ID,

    -- FB shares Spring Festival
    UIYYHDChild20009Form_OPEN = 51140 + L_BASE_ID,
    UIYYHDChild20009Form_CLOSE = 51149 + L_BASE_ID,

    -- Continuously charged 2 Valentine's Day (in-app purchase)
    UIYYHDChild21002Form_OPEN = 51150 + L_BASE_ID,
    UIYYHDChild21002Form_CLOSE = 51159 + L_BASE_ID,

    -- Continuously cumulative recharge for 2 Spring Festival (in-house purchase)
    UIYYHDChild21009Form_OPEN = 51160 + L_BASE_ID,
    UIYYHDChild21009Form_CLOSE = 51169 + L_BASE_ID,

    -- New Year's gifts
    UIYYHDChild22009Form_OPEN = 51170 + L_BASE_ID,
    UIYYHDChild22009Form_CLOSE = 51179 + L_BASE_ID,

    -- Roll dice in Spring Festival
    UIYYHDChild23009Form_OPEN = 51180 + L_BASE_ID,
    UIYYHDChild23009Form_CLOSE = 51189 + L_BASE_ID,

    -- Spring Festival operation activity bottom board
    UIYYHDCJBaseForm_OPEN = 51190 + L_BASE_ID,
    UIYYHDCJBaseForm_CLOSE = 51199 + L_BASE_ID,

    -- Valentine's Day Operations Activity Base
    UIYYHDQRJBaseForm_OPEN = 51200 + L_BASE_ID,
    UIYYHDQRJBaseForm_CLOSE = 51209 + L_BASE_ID,

    -- Blessed land of swords
    UIFuDiLjForm_OPEN = 51210 + L_BASE_ID,
    UIFuDiLjForm_CLOSE = 51219 + L_BASE_ID,

    -- Blessed Land Sword Ranking Reward Interface
    UIFuDiLjRankForm_OPEN = 51220 + L_BASE_ID,
    UIFuDiLjRankForm_CLOSE = 51229 + L_BASE_ID,

    -- Blessed Sword Controversy Interface
    UIFuDiLjCopyForm_OPEN = 51230 + L_BASE_ID,
    UIFuDiLjCopyForm_CLOSE = 51239 + L_BASE_ID,

    -- Blessed Sword Controversy Copy Settlement Interface
    UIFuDiResultForm_OPEN = 51240 + L_BASE_ID,
    UIFuDiResultForm_CLOSE = 51249 + L_BASE_ID,

    -- Celebration mission Spring Festival
    UIYYHDChild12009Form_OPEN = 51250 + L_BASE_ID,
    UIYYHDChild12009Form_CLOSE = 51259 + L_BASE_ID,

    -- Cross-server blessed land attack details interface
    UICrossFuDiAttackInfoForm_OPEN = 51260 + L_BASE_ID,
    UICrossFuDiAttackInfoForm_CLOSE = 51269 + L_BASE_ID,

    -- Cross-server blessed land settlement interface
    UICrossFuDiResultForm_OPEN = 51270 + L_BASE_ID,
    UICrossFuDiResultForm_CLOSE = 51279 + L_BASE_ID,

    -- Cross-server blessed land interface
    UICrossFuDiForm_OPEN = 51280 + L_BASE_ID,
    UICrossFuDiForm_CLOSE = 51289 + L_BASE_ID,

    -- Cross-server blessed land copy interface
    UICrossFuDiCopyForm_OPEN = 51290 + L_BASE_ID,
    UICrossFuDiCopyForm_CLOSE = 51299 + L_BASE_ID,

    -- Plane failure prompt interface
    UIPanelCopyFailedForm_OPEN = 51300 + L_BASE_ID,
    UIPanelCopyFailedForm_CLOSE = 513099 + L_BASE_ID,

    -- Select the interface of the mind
    UISelectXinFaForm_OPEN = 51310 + L_BASE_ID,
    UISelectXinFaForm_CLOSE = 51319 + L_BASE_ID,

    -- Blessed land reward change interface
    UIFuDiChangeShowForm_OPEN = 51320 + L_BASE_ID,
    UIFuDiChangeShowForm_CLOSE = 51329 + L_BASE_ID,

    -- Festival Wishes and Waterstorm Festival
    UIYYHDChild19018Form_OPEN = 51330 + L_BASE_ID,
    UIYYHDChild19018Form_CLOSE = 51339 + L_BASE_ID,

    -- New Year gifts (Splashing Festival)
    UIYYHDChild22018Form_OPEN = 51340 + L_BASE_ID,
    UIYYHDChild22018Form_CLOSE = 51349 + L_BASE_ID,

    -- Roll the dice (Sprinkle Festival)
    UIYYHDChild23018Form_OPEN = 51350 + L_BASE_ID,
    UIYYHDChild23018Form_CLOSE = 51359 + L_BASE_ID,

    -- Operation activities Waterspring Festival interface
    UIYYHDPSJBaseForm_OPEN = 51360 + L_BASE_ID,
    UIYYHDPSJBaseForm_CLOSE = 51369 + L_BASE_ID,

    -- The lottery record interface for fairy armor treasure hunting
    UIXJXunbaoRecordForm_OPEN = 51370 + L_BASE_ID,
    UIXJXunbaoRecordForm_CLOSE = 51379 + L_BASE_ID,

    -- Activity reminder interface
    UIFunctionNoticeTipsForm_OPEN = 51380 + L_BASE_ID,
    UIFunctionNoticeTipsForm_CLOSE = 51389 + L_BASE_ID,

    -- Active exchange for water-splashing festival
    UIYYHDChild1018Form_OPEN = 51390 + L_BASE_ID,
    UIYYHDChild1018Form_CLOSE = 51399 + L_BASE_ID,

    -- Purchase restricted gift package water-splashing festival (personal restricted purchase)
    UIYYHDChild4018Form_OPEN = 51400 + L_BASE_ID,
    UIYYHDChild4018Form_CLOSE = 51409 + L_BASE_ID,

    -- Accumulated recharge and water-splashing festival
    UIYYHDChild6018Form_OPEN = 51410 + L_BASE_ID,
    UIYYHDChild6018Form_CLOSE = 51419 + L_BASE_ID,

    -- Group Buy Watersplash Festival
    UIYYHDChild9018Form_OPEN = 51420 + L_BASE_ID,
    UIYYHDChild9018Form_CLOSE = 51429 + L_BASE_ID,

    -- Continuous filling and water-splashing festival (recharge any)
    UIYYHDChild15018Form_OPEN = 51430 + L_BASE_ID,
    UIYYHDChild15018Form_CLOSE = 51439 + L_BASE_ID,

    -- Limited time mall water-splashing festival (all service limited purchase)
    UIYYHDChild16018Form_OPEN = 51440 + L_BASE_ID,
    UIYYHDChild16018Form_CLOSE = 51449 + L_BASE_ID,
    
    -- Continuous filling of 2 water-splashing festival (in-house purchase)
    UIYYHDChild21018Form_OPEN = 51450 + L_BASE_ID,
    UIYYHDChild21018Form_CLOSE = 51459 + L_BASE_ID,

    -- The leader carnival watersplashing festival
    UIYYHDChild11018Form_OPEN = 51460 + L_BASE_ID,
    UIYYHDChild11018Form_CLOSE = 51469 + L_BASE_ID,

    -- The lucky cat water-splashing festival
    UIYYHDChild10018Form_OPEN = 51470 + L_BASE_ID,
    UIYYHDChild10018Form_CLOSE = 51479 + L_BASE_ID,

    -- Festival collection of characters water-splashing festival
    UIYYHDChild13018Form_OPEN = 51480 + L_BASE_ID,
    UIYYHDChild13018Form_CLOSE = 51489 + L_BASE_ID,
    
    -- FB Share Water Splashing Festival
    UIYYHDChild20018Form_OPEN = 51490 + L_BASE_ID,
    UIYYHDChild20018Form_CLOSE = 51499 + L_BASE_ID,

    -- Request support interface
    UIReqSupportForm_OPEN = 51500 + L_BASE_ID,
    UIReqSupportForm_CLOSE = 51509 + L_BASE_ID,

    -- Main interface of mount equipment
    UIMountEquipMainForm_OPEN = 51510 + L_BASE_ID,
    UIMountEquipMainForm_CLOSE = 51519 + L_BASE_ID,

    -- Mount equipment synthesis interface
    UIMountEquipSynthForm_OPEN = 51520 + L_BASE_ID,
    UIMountEquipSynthForm_CLOSE = 51529 + L_BASE_ID,

    -- Mount Equipment TIPS
    UIMountEquipTipsForm_OPEN = 51530 + L_BASE_ID,
    UIMountEquipTipsForm_CLOSE = 51539 + L_BASE_ID,

    -- Mount Equipment Growth System Management Interface
    UIMountEquipBaseForm_OPEN = 51540 + L_BASE_ID,
    UIMountEquipBaseForm_CLOSE = 51549 + L_BASE_ID,

    -- Mount equipment enhancement interface
    UIMountEquipStrengthForm_OPEN = 51550 + L_BASE_ID,
    UIMountEquipStrengthForm_CLOSE = 51559 + L_BASE_ID,

    -- Mount equipment soul-attached interface
    UIMountEquipSoulForm_OPEN = 51560 + L_BASE_ID,
    UIMountEquipSoulForm_CLOSE = 51569 + L_BASE_ID,

    -- Mount equipment enhancement target interface
    UIMountEquipTotalStrengthForm_OPEN = 51570 + L_BASE_ID,
    UIMountEquipTotalStrengthForm_CLOSE = 51579 + L_BASE_ID,

    -- Mount equipment soul-attached target interface
    UIMountEquipTotalSoulForm_OPEN = 51580 + L_BASE_ID,
    UIMountEquipTotalSoulForm_CLOSE = 51589 + L_BASE_ID,

    -- Ancient altar
    UIMountBossForm_OPEN = 51590 + L_BASE_ID,
    UIMountBossForm_CLOSE = 51599 + L_BASE_ID,

    -- Reward base interface
    UIKaosOrderBaseForm_OPEN = 51600 + L_BASE_ID,
    UIKaosOrderBaseForm_CLOSE = 51609 + L_BASE_ID,

    -- Ancient Order Interface
    UIHuangGuLingForm_OPEN = 51610 + L_BASE_ID,
    UIHuangGuLingForm_CLOSE = 51619 + L_BASE_ID,
    -- Ancient altar copy
    UIMountBossCopyForm_OPEN = 51620 + L_BASE_ID,
    UIMountBossCopyForm_CLOSE = 51629 + L_BASE_ID,
    -- Ancient Altar copy settlement
    UIMountBossCopyResultForm_OPEN = 51630 + L_BASE_ID,
    UIMountBossCopyResultForm_CLOSE = 51639 + L_BASE_ID,

    -- Zhaocao operation activity bottom board
    UIYYHDZCMBaseForm_OPEN = 51640 + L_BASE_ID,
    UIYYHDZCMBaseForm_CLOSE = 51649 + L_BASE_ID,

    -- Special operation activities for Zhaocao
    UIYYHDChild10019Form_OPEN = 51650 + L_BASE_ID,
    UIYYHDChild10019Form_CLOSE = 51659 + L_BASE_ID,

    -- The gap between the devil
    UIOYLieKaiForm_OPEN = 51660 + L_BASE_ID,
    UIOYLieKaiForm_CLOSE = 51669 + L_BASE_ID,

    -- Demon Removal Group Main Interface
    UISlayerBaseForm_OPEN = 51670 + L_BASE_ID,
    UISlayerBaseForm_CLOSE = 51679 + L_BASE_ID,

    -- Join the Demon Elimination Group
    UISlayerJoinForm_OPEN = 51680 + L_BASE_ID,
    UISlayerJoinForm_CLOSE = 51689 + L_BASE_ID,

    -- Create a magic group
    UISlayerCreateForm_OPEN = 51690 + L_BASE_ID,
    UISlayerCreateForm_CLOSE = 51699 + L_BASE_ID,

    -- Demon Elimination Group Duplicate
    UISlayerCopyForm_OPEN = 51700 + L_BASE_ID,
    UISlayerCopyForm_CLOSE = 51709 + L_BASE_ID,

    -- Copy points ranking
    UISlayerRankForm_OPEN = 51710 + L_BASE_ID,
    UISlayerRankForm_CLOSE = 51719 + L_BASE_ID,

    -- Demon King's Crack Duplicate
    UIOYLieKaiCopyForm_OPEN = 51720 + L_BASE_ID,
    UIOYLieKaiCopyForm_CLOSE = 51729 + L_BASE_ID,

    -- Main interface
    UIAssistFightBaseForm_OPEN = 51740 + L_BASE_ID,
    UIAssistFightBaseForm_CLOSE = 51749 + L_BASE_ID,

    -- Demon-sealing platform
    UIFengMoTaiForm_OPEN = 51730 + L_BASE_ID,
    UIFengMoTaiForm_CLOSE = 51739 + L_BASE_ID,

    -- Demon Soul Main Interface
    UIDevilSoulMainForm_OPEN = 51750 + L_BASE_ID,
    UIDevilSoulMainForm_CLOSE = 51759 + L_BASE_ID,

    -- Demon Soul Backpack
    UIDevilSoulBagForm_OPEN = 51760 + L_BASE_ID,
    UIDevilSoulBagForm_CLOSE = 51769 + L_BASE_ID,

    -- Demon soul breakthrough
    UIDevilSoulSurmountForm_OPEN = 51770 + L_BASE_ID,
    UIDevilSoulSurmountForm_CLOSE = 51779 + L_BASE_ID,

    -- Demon Soul Synthesis
    UIDevilSoulSynthForm_OPEN = 51780 + L_BASE_ID,
    UIDevilSoulSynthForm_CLOSE = 51789 + L_BASE_ID,

    -- Demon Soul Equipment Tips
    UIDevilSoulEquipTipsForm_OPEN = 51790 + L_BASE_ID,
    UIDevilSoulEquipTipsForm_CLOSE = 51799 + L_BASE_ID,

    -- The main interface of Xianjia Bagua
    UIXianjia8GuaBaseForm_OPEN = 51800 + L_BASE_ID,
    UIXianjia8GuaBaseForm_CLOSE = 51809 + L_BASE_ID,

    -- Fairy-Armor Bagua Backpack
    UIXianjia8GuaForm_OPEN = 51810 + L_BASE_ID,
    UIXianjia8GuaForm_CLOSE = 51819 + L_BASE_ID,

    -- Immortal Garment Eight Trigrams Synthesis
    UIXianjia8GuaSynthForm_OPEN = 51820 + L_BASE_ID,
    UIXianjia8GuaSynthForm_CLOSE = 51829 + L_BASE_ID,

    -- Fairy-Armor Bagua Exchange
    UIXianjia8GuaExchangeForm_OPEN = 51830 + L_BASE_ID,
    UIXianjia8GuaExchangeForm_CLOSE = 51839 + L_BASE_ID,

    -- Daily task settlement
    UIDailyTaskFinishForm_OPEN = 51840 + L_BASE_ID,
    UIDailyTaskFinishForm_CLOSE = 51849 + L_BASE_ID,

    -- Home House Map Main Interface
    UIHouseCopyFormForm_OPEN = 51850 + L_BASE_ID,
    UIHouseCopyFormForm_CLOSE = 51859 + L_BASE_ID,

    -- Event appearance display
    UIYYHDChild24000Form_OPEN = 51860 + L_BASE_ID,
    UIYYHDChild24000Form_CLOSE = 51869 + L_BASE_ID,

    -- Event appearance display
    UIYYHDChild25000Form_OPEN = 51870 + L_BASE_ID,
    UIYYHDChild25000Form_CLOSE = 51879 + L_BASE_ID,

    -- Home House Management Interface
    UIHouseManagerForm_OPEN = 51880 + L_BASE_ID,
    UIHouseManagerForm_CLOSE = 51889 + L_BASE_ID,

    -- Home personal information interface
    UICommunityMsgForm_OPEN = 51890 + L_BASE_ID,
    UICommunityMsgForm_CLOSE = 51899 + L_BASE_ID,

    -- Home Home Decoration Competition Main Interface
    UIDecorateMainForm_OPEN = 51900 + L_BASE_ID,
    UIDecorateMainForm_CLOSE = 51909 + L_BASE_ID,

    -- Home Home Decoration Competition Voting Interface
    UIDecorateVoteForm_OPEN = 51910 + L_BASE_ID,
    UIDecorateVoteForm_CLOSE = 51919 + L_BASE_ID,

    -- Cornucopia activity
    UIYYHDChild26000Form_OPEN = 51930 + L_BASE_ID,
    UIYYHDChild26000Form_CLOSE = 51939 + L_BASE_ID,

    -- Lucky egg smashing activity
    UIYYHDChild27000Form_OPEN = 51940 + L_BASE_ID,
    UIYYHDChild27000Form_CLOSE = 51949 + L_BASE_ID,

    -- Welfare Peak Fund
    UIWelfareIPeakFundForm_OPEN = 51920 + L_BASE_ID,
    UIWelfareIPeakFundForm_CLOSE = 51929 + L_BASE_ID,

    -- House layout interface
    UIHouseBuZhiForm_OPEN = 51950 + L_BASE_ID,
    UIHouseBuZhiForm_CLOSE = 51959 + L_BASE_ID,

    UICommunityDecorateForm_OPEN = 51960 + L_BASE_ID,
    UICommunityDecorateForm_CLOSE = 51969 + L_BASE_ID,
    		
    -- Special treasure chest display interface
    UIBaoXiangModelForm_OPEN = 51970 + L_BASE_ID,
    UIBaoXiangModelForm_CLOSE = 51979 + L_BASE_ID,

    -- Perfect love basic interface
    UIPrefectRomanceForm_OPEN = 51990 + L_BASE_ID,
    UIPrefectRomanceForm_CLOSE = 51999 + L_BASE_ID,

    -- Perfect Love Fairy Couple Interface
    UIPrefectSpouseForm_OPEN = 52000 + L_BASE_ID,
    UIPrefectSpouseForm_CLOSE = 52009 + L_BASE_ID,

    -- Perfect love mission interface
    UIPrefectTaskForm_OPEN = 52010 + L_BASE_ID,
    UIPrefectTaskForm_CLOSE = 52019 + L_BASE_ID,

    -- Perfect love gift package interface
    UIPrefectGiftForm_OPEN = 52020 + L_BASE_ID,
    UIPrefectGiftForm_CLOSE = 52029 + L_BASE_ID,

    -- Perfect love lucky bag interface
    UIPrefectPackForm_OPEN = 52030 + L_BASE_ID,
    UIPrefectPackForm_CLOSE = 52039 + L_BASE_ID,

    -- Distribution material recording interface
    UIFaXingSuCaiForm_OPEN = 51980 + L_BASE_ID,
    UIFaXingSuCaiForm_CLOSE = 51989 + L_BASE_ID,
    -- Home and house gift-giving interface
    UIHouseGiftForm_OPEN = 52040 + L_BASE_ID,
    UIHouseGiftForm_CLOSE = 52049 + L_BASE_ID,

    -- The main interface of the fairy couple showdown
    UILoversFightForm_OPEN = 52050 + L_BASE_ID,
    UILoversFightForm_CLOSE = 52059 + L_BASE_ID,

    -- Fairy Couple Duel Examination Interface
    UILoversFreeFightForm_OPEN = 52060 + L_BASE_ID,
    UILoversFreeFightForm_CLOSE = 52069 + L_BASE_ID,

    -- Fairy Couple duel group match interface
    UILoversGroupFightForm_OPEN = 52070 + L_BASE_ID,
    UILoversGroupFightForm_CLOSE = 52079 + L_BASE_ID,

    -- Fairy Couple Duel Championship Interface
    UILoversTopFightForm_OPEN = 52080 + L_BASE_ID,
    UILoversTopFightForm_CLOSE = 52089 + L_BASE_ID,

    -- Immortal Couple Duel Ranking Reward Interface
    UILoversRankRewardsForm_OPEN = 52090 + L_BASE_ID,
    UILoversRankRewardsForm_CLOSE = 52099 + L_BASE_ID,

    -- Fairy Couple Duel Store Interface
    UILoversShopForm_OPEN = 52100 + L_BASE_ID,
    UILoversShopForm_CLOSE = 52109 + L_BASE_ID,

    -- Immortal Alliance Guidance Interface
    UIGuildGuideForm_OPEN = 52120 + L_BASE_ID,
    UIGuildGuideForm_CLOSE = 52129 + L_BASE_ID,

    -- Blessed land guidance interface
    UIFuDiGuideForm_OPEN = 52130 + L_BASE_ID,
    UIFuDiGuideForm_CLOSE = 52139 + L_BASE_ID,

    -- Immortal Alliance Treasure Box Interface
    UIGuildBoxForm_OPEN = 52140 + L_BASE_ID,
    UIGuildBoxForm_CLOSE = 52149 + L_BASE_ID,

    -- Jianling Pavilion Quick Customs Clearance Settlement Interface
    UISwordSoulTiaoGuanResultForm_OPEN = 52150 + L_BASE_ID,
    UISwordSoulTiaoGuanResultForm_CLOSE = 52159 + L_BASE_ID,

    -- Marriage world blessing interface
    UIMarryWorldZhuFuForm_OPEN = 52160 + L_BASE_ID,
    UIMarryWorldZhuFuForm_CLOSE = 52169 + L_BASE_ID,

    -- Monthly card tips interface
    UIMonthCardTipsForm_OPEN = 52170 + L_BASE_ID,
    UIMonthCardTipsForm_CLOSE = 52179 + L_BASE_ID,

    -- Home Preview Interface
    UIHousePreviewForm_OPEN = 52180 + L_BASE_ID,
    UIHousePreviewForm_CLOSE = 52189 + L_BASE_ID,

    -- User Agreement before changing avatar
    UICommunityAgreementForm_OPEN = 52190 + L_BASE_ID,
    UICommunityAgreementForm_CLOSE = 52199 + L_BASE_ID,

    -- Change the custom avatar interface
    UIChangeHeadForm_OPEN = 52200 + L_BASE_ID,
    UIChangeHeadForm_CLOSE = 52209 + L_BASE_ID,

    -- Prompt interface before exiting the game
    UIExitTipsForm_OPEN = 52210 + L_BASE_ID,
    UIExitTipsForm_CLOSE = 52219 + L_BASE_ID,

    -- Worry-free treasure house interface
    UITreasureWuyouForm_OPEN = 52220 + L_BASE_ID,
    UITreasureWuyouForm_CLOSE = 52229 + L_BASE_ID,

    -- Daily Share
    UIShareForDayForm_OPEN = 52230 + L_BASE_ID,
    UIShareForDayForm_CLOSE = 52239 + L_BASE_ID,

    -- Great value
    UIChaoZhiForm_OPEN = 52240 + L_BASE_ID,
    UIChaoZhiForm_CLOSE = 52249 + L_BASE_ID,

    -- VIP invitation
    UIVipInvationForm_OPEN = 52250 + L_BASE_ID,
    UIVipInvationForm_CLOSE = 52259 + L_BASE_ID,

    -- New daily task interface
    UINewDailyTaskform_OPEN = 52260 + L_BASE_ID,
    UINewDailyTaskform_CLOSE = 52269 + L_BASE_ID,

    -- Lucky Egg Smashing Grand Prize Interface
    UIXYZDBigWAwardForm_OPEN = 52270 + L_BASE_ID,
    UIXYZDBigWAwardForm_CLOSE = 52279 + L_BASE_ID,

    -- Preview interface for mental method selection
    UIXinFaPreviewForm_OPEN = 52280 + L_BASE_ID,
    UIXinFaPreviewForm_CLOSE = 52289 + L_BASE_ID,

    -- Divine equipment and star upgrade interface
    UIGodEquipForm_OPEN = 52290 + L_BASE_ID,
    UIGodEquipForm_CLOSE = 52299 + L_BASE_ID,

    -- Add interface to preaching experience
    UICDExpAddForm_OPEN = 52300 + L_BASE_ID,
    UICDExpAddForm_CLOSE = 52309 + L_BASE_ID,

    -- New great discount interface
    UILimitDicretShopForm2_OPEN = 52310 + L_BASE_ID,
    UILimitDicretShopForm2_CLOSE = 52319 + L_BASE_ID,

    -- Vip orb purchasing interface
    UIVipBaoZhuForm_OPEN = 52320 + L_BASE_ID,
    UIVipBaoZhuForm_CLOSE = 52329 + L_BASE_ID,

    -- Boss House
    UINewBossHomeForm_OPEN = 52330 + L_BASE_ID,
    UINewBossHomeForm_CLOSE = 52339 + L_BASE_ID,

    -- VIP orb activation interface
    UIVipBaoZhuUseForm_OPEN = 52340 + L_BASE_ID,
    UIVipBaoZhuUseForm_CLOSE = 52349 + L_BASE_ID,

    -- Peak Competition Waiting for Duplicate Interface
    UITopJjcWaitCopyForm_OPEN = 52350 + L_BASE_ID,
    UITopJjcWaitCopyForm_CLOSE = 52359 + L_BASE_ID,

    -- Zero Yuan shopping interface
    UIZeroBuyForm_OPEN = 52360 + L_BASE_ID,
    UIZeroBuyForm_CLOSE = 52369 + L_BASE_ID,

    -- Jump to Google Store to comment on game
    UIPingLunGameForm_OPEN = 52370 + L_BASE_ID,
    UIPingLunGameForm_CLOSE = 52379 + L_BASE_ID,

    -- Skill VIP bonus preview interface
    UISkillVipAddForm_OPEN = 52380 + L_BASE_ID,
    UISkillVipAddForm_CLOSE = 52389 + L_BASE_ID,

    -- VIP zero-yuan shopping interface
    UIZeroBuyVIPForm_OPEN = 52390 + L_BASE_ID,
    UIZeroBuyVIPForm_CLOSE = 52399 + L_BASE_ID,

    -- Treasure Hunt Treasure Recycling Interface
    UITreasureRecoveryForm_OPEN = 52400 + L_BASE_ID,
    UITreasureRecoveryForm_CLOSE = 52409 + L_BASE_ID,

    -- Home Mission
    UIHomeTaskForm_OPEN = 52410 + L_BASE_ID,
    UIHomeTaskForm_CLOSE = 52419 + L_BASE_ID,

    -- Today's Event
    UITodyFuncForm_OPEN = 52420 + L_BASE_ID,
    UITodyFuncForm_CLOSE = 52429 + L_BASE_ID,
    -- Escort event main interface
    UIHuSongForm_OPEN = 52430 + L_BASE_ID,
    UIHuSongForm_CLOSE = 52439 + L_BASE_ID,
    -- Escort activity status interface
    UIHuSongStateForm_OPEN = 52440 + L_BASE_ID,
    UIHuSongStateForm_CLOSE = 52449 + L_BASE_ID,
    -- Escort result interface
    UIHuSongResultForm_OPEN = 52450 + L_BASE_ID,
    UIHuSongResultForm_CLOSE = 52459 + L_BASE_ID,
    -- Escort animation interface
    UIHuSongFlashForm_OPEN = 52460 + L_BASE_ID,
    UIHuSongFlashForm_CLOSE = 52469 + L_BASE_ID,

    -- Immortal Couple Duel Interface
    UILoversFightCopyForm_OPEN = 52470 + L_BASE_ID,
    UILoversFightCopyForm_CLOSE = 52479 + L_BASE_ID,

    -- Upgrade level improvement interface
    UIFeiShengBoxForm_OPEN = 52480 + L_BASE_ID,
    UIFeiShengBoxForm_CLOSE = 52489 + L_BASE_ID,

    -- Fairy Couple Duel Settlement Interface
    UILoversFightResultForm_OPEN = 52490 + L_BASE_ID,
    UILoversFightResultForm_CLOSE = 52499 + L_BASE_ID,
    -- Equipment dismantling interface
    UIEquipSplitForm_OPEN = 52500 + L_BASE_ID,
    UIEquipSplitForm_CLOSE = 52509 + L_BASE_ID,

    -- Fairy Couple Duel Waiting for Duplicate Interface
    UILoversFightWaitCopyForm_OPEN = 52510 + L_BASE_ID,
    UILoversFightWaitCopyForm_CLOSE = 52519 + L_BASE_ID,

    -- Bind jade lucky cat activity interface
    UIYYHDChild28000Form_OPEN = 52520 + L_BASE_ID,
    UIYYHDChild28000Form_CLOSE = 52529 + L_BASE_ID,

    -- Dice roll activity ten consecutive draw settlement panel
    UIRollResultForm_OPEN = 52530 + L_BASE_ID,
    UIRollResultForm_CLOSE = 52539 + L_BASE_ID,

    -- Attached interface
    UIAttachEquipForm_OPEN = 52540 + L_BASE_ID,
    UIAttachEquipForm_CLOSE = 52549 + L_BASE_ID,

    -- Fantasy interface
    UIUnrealEquipForm_OPEN = 52550 + L_BASE_ID,
    UIUnrealEquipForm_CLOSE = 52559 + L_BASE_ID,

    -- Tips interface for fantasy
    UIUnrealEquipTipsForm_OPEN = 52560 + L_BASE_ID,
    UIUnrealEquipTipsForm_CLOSE = 52569 + L_BASE_ID,

    -- Fang Ze treasure exploration activity interface
    UIYYHDChild29000Form_OPEN = 52570 + L_BASE_ID,
    UIYYHDChild29000Form_CLOSE = 52579 + L_BASE_ID,

    -- Sumeru Treasure Library
    UIXuMiBaoKuForm_OPEN = 52580 + L_BASE_ID,
    UIXuMiBaoKuForm_CLOSE = 52589 + L_BASE_ID,

    -- Disassembly of immortal soul
    UIXianPoAnalyse_OPEN = 52590 + L_BASE_ID,
    UIXianPoAnalyse_CLOSE = 52599 + L_BASE_ID,

    -- Copy of the Sumeru Treasure House
    UIXuMiBaoKuCopyForm_OPEN = 52600 + L_BASE_ID,
    UIXuMiBaoKuCopyForm_CLOSE = 52609 + L_BASE_ID,
    -- Immortal Alliance Red Packet
    UIGuildRedPackageForm_OPEN = 52610 + L_BASE_ID,
    UIGuildRedPackageForm_CLOSE = 52619 + L_BASE_ID,
    -- Fairy couple showdown match waiting interface
    UILoversFightPiPeiWaitForm_OPEN = 52620 + L_BASE_ID,
    UILoversFightPiPeiWaitForm_CLOSE = 52629 + L_BASE_ID,

    -- Fairy couple match interface
    UILoversFightPiPeiForm_OPEN = 52630 + L_BASE_ID,
    UILoversFightPiPeiForm_CLOSE = 52639 + L_BASE_ID,

    -- Open red envelope interface
    UIGuildRedPackageOpenForm_OPEN = 52640 + L_BASE_ID,
    UIGuildRedPackageOpenForm_CLOSE = 52649 + L_BASE_ID,

    -- Red envelope interface
    UIGuildRedPackageSendForm_OPEN = 52650 + L_BASE_ID,
    UIGuildRedPackageSendForm_CLOSE = 52659 + L_BASE_ID,

    -- v4 power interface
    UIVIPHelpForm_OPEN = 52660 + L_BASE_ID,
    UIVIPHelpForm_CLOSE = 52669 + L_BASE_ID,

    -- v4 rebate interface
    UIVIP4FanLiForm_OPEN = 52670 + L_BASE_ID,
    UIVIP4FanLiForm_CLOSE = 52679 + L_BASE_ID,

    -- v4 assist base plate interface
    UIVIPHelpBaseForm_OPEN = 52680 + L_BASE_ID,
    UIVIPHelpBaseForm_CLOSE = 52689 + L_BASE_ID,

    -- Rebate treasure chest interface
    UIRebateBoxForm_OPEN = 52690 + L_BASE_ID,
    UIRebateBoxForm_CLOSE = 52699 + L_BASE_ID,

    -- Immortal Alliance Battle Interface
    UIXMZhengBaForm_OPEN = 52700 + L_BASE_ID,
    UIXMZhengBaForm_CLOSE = 52709 + L_BASE_ID,

    -- Community mall interface
    UIHouseShopForm_OPEN = 52710 + L_BASE_ID,
    UIHouseShopForm_CLOSE = 52719 + L_BASE_ID,

    -- Chaos Void Copy Interface
    UIXuKongCopyForm_OPEN = 52720 + L_BASE_ID,
    UIXuKongCopyForm_CLOSE = 52729 + L_BASE_ID,

    -- Fairyland treasure exploration activity interface
    UIYYHDChild30000Form_OPEN = 52730 + L_BASE_ID,
    UIYYHDChild30000Form_CLOSE = 52739 + L_BASE_ID,

    -- Offline experience recovery interface
    UIOfflineFindForm_OPEN = 52740 + L_BASE_ID,
    UIOfflineFindForm_CLOSE = 52749 + L_BASE_ID,

    -- QQ Big Play Cat Interface
    UIQQRichManForm_OPEN = 52750 + L_BASE_ID,
    UIQQRichManForm_CLOSE = 52759 + L_BASE_ID,

    -- Automatic road search prompt
    UIAutoSearchPathForm_OPEN = 52760 + L_BASE_ID,
    UIAutoSearchPathForm_CLOSE = 52769 + L_BASE_ID,  
    
    -- Train BOSS copy interface
    UITrainBossCopyForm_OPEN = 52780 + L_BASE_ID,
    UITrainBossCopyForm_CLOSE = 52789 + L_BASE_ID,

    -- The main interface in the train boss copy
    UITrainBossCopyMainForm_OPEN = 52790 + L_BASE_ID,
    UITrainBossCopyMainForm_CLOSE = 52799 + L_BASE_ID,

    --Forge: Upgrade
    UILianQiForgeUpgradeForm_OPEN = 52800 + L_BASE_ID,
    UILianQiForgeUpgradeForm_CLOSE = 52809 + L_BASE_ID,

    --Forge: Upgrade : Tranfer
    UILianQiForgeStrengthTransferForm_OPEN = 52810 + L_BASE_ID,
    UILianQiForgeStrengthTransferForm_CLOSE = 52819 + L_BASE_ID,

    --Forge: Upgrade : Split
    UILianQiForgeStrengthSplitForm_OPEN = 52820 + L_BASE_ID,
    UILianQiForgeStrengthSplitForm_CLOSE = 52829 + L_BASE_ID,

    --Shop: Orb (Tinh chau)
    UIShopOrbForm_OPEN = 52830 + L_BASE_ID,
    UIShopOrbForm_CLOSE = 52839 + L_BASE_ID,

    -- Escort (Vận lúa)
    UIEscortForm_OPEN = 52840 + L_BASE_ID,
    UIEscortForm_CLOSE = 52849 + L_BASE_ID,

    -- EscortSuccess (Vận lúa thành công)
    UIEscortSuccessForm_OPEN = 52850 + L_BASE_ID,
    UIEscortSuccessForm_CLOSE = 52859 + L_BASE_ID,

    -- EscortFail (Vận lúa thất bại)
    UIEscortFailForm_OPEN = 52860 + L_BASE_ID,
    UIEscortFailForm_CLOSE = 52869 + L_BASE_ID,

    -- EscortNoti (Đang vận lúa)
    UIEscortNotiForm_OPEN = 52870 + L_BASE_ID,
    UIEscortNotiForm_CLOSE = 52879 + L_BASE_ID,

    -- UILianQiStrengthAllAttr (Tổng CH toàn thân)
    UILianQiStrengthAllAttrForm_OPEN = 52880 + L_BASE_ID,
    UILianQiStrengthAllAttrForm_CLOSE = 52889 + L_BASE_ID,

}

-- Here, flip the Key and Value in Event and save it to _temp.
local _temp = {}
for k, v in pairs(UILuaEventDefine) do
    _temp[v] = k
end

-- Determine if there is an event
function UILuaEventDefine.HasEvent(eID)
    return not (not _temp[eID])
end

return UILuaEventDefine
