local LuaMainFunctionSystem = {
	DelayOpenFuncId = nil,
	DelayOpenFrameCount = 0,
}

-- Open the Creation Panel
function LuaMainFunctionSystem.OpenNaturePanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,NatureEnum.Wing)
end

-- Open the Creation Wings Upgrade Panel
function LuaMainFunctionSystem.OpenNatureWingPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Wing,NatureSubEnum.BaseUpLevel})
end


-- Open the wings of creation and eat fruit panel
function LuaMainFunctionSystem.OpenNatureWingDrugPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Wing,NatureSubEnum.Drug})
end

-- Open the wings of creation to transform
function LuaMainFunctionSystem.OpenNatureWingFashaionPanel(param)
	if param then
		if type(param) == "number" then
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Wing, param})
		else
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Wing, param[0]})
		end
	else
		GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, NatureEnum.Wing)
	end
end

-- Open the display interface of the creation wing model
function LuaMainFunctionSystem.OpenNatureWingModelShowPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN,NatureEnum.Wing)
end

-- Open the magic tool of creation
function LuaMainFunctionSystem.OpenNatureTalismanPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Talisman,NatureSubEnum.BaseUpLevel})
end

-- Open the magic tool of creation and eat fruits
function LuaMainFunctionSystem.OpenNatureTalismanDrugPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Talisman,NatureSubEnum.Drug})
end

-- Open the magic instrument of creation to transform
function LuaMainFunctionSystem.OpenNatureTalismanFashionPanel(param)

end

-- Open the Creation Magic Model Display Interface
function LuaMainFunctionSystem.OpenNatureTalismanModelShowPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN,NatureEnum.Talisman)
end

-- Open the formation of creation
function LuaMainFunctionSystem.OpenNatureMagicPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Magic,NatureSubEnum.BaseUpLevel})
end

-- Open the formation of creation to eat fruits
function LuaMainFunctionSystem.OpenNatureMagicDrugPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Magic,NatureSubEnum.Drug})
end

-- Open the creation array to transform
function LuaMainFunctionSystem.OpenNatureMagicFashionPanel(param)

end

-- Open the Creation Magic Model Display Interface
function LuaMainFunctionSystem.OpenNatureMagicModelShowPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN,NatureEnum.Magic)
end

-- Open the magic weapon of creation
function LuaMainFunctionSystem.OpenNatureWeaponLevelPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Weapon,NatureSubEnum.BaseUpLevel})
end

-- Open the magic weapon of creation and take medicine
function LuaMainFunctionSystem.OpenNatureWeaponBreakPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Weapon,NatureSubEnum.Drug})
end

-- Open the magic weapon of creation
function LuaMainFunctionSystem.OpenNatureWeaponFashionPanel(param)
	if param then
		if type(param) == "number" then
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Weapon, param})
		else
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Weapon, param[0]})
		end
	else
		GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, NatureEnum.Weapon)
	end
end


-- Open the Creation Magic Model Display Interface
function LuaMainFunctionSystem.OpenNatureWeaponModelShowPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN,NatureEnum.Weapon)
end

-- Open the copy panel single-person pagination
function LuaMainFunctionSystem.OpenCopyMapSinglePanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.SinglePanel, UISingleCopyPanelEnum.TowerPanel})
end

-- Open the Replica Panel Tower Climbing Copy Pagination
function LuaMainFunctionSystem.OpenCopyMapTowerPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.SinglePanel, UISingleCopyPanelEnum.TowerPanel})
end

-- Open the Star Copy Pagination of the Copy Panel
function LuaMainFunctionSystem.OpenCopyMapStarPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.SinglePanel, UISingleCopyPanelEnum.StarPanel})
end

-- Open the copy panel of the Heavenly Gate copy page
function LuaMainFunctionSystem.OpenCopyMapTJZMPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.SinglePanel, UISingleCopyPanelEnum.TJZMPanel})
end

-- Open the Copy Panel Experience Copy
function LuaMainFunctionSystem.OpenCopyMapExpPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.SinglePanel, UISingleCopyPanelEnum.ExpPanel})
end

-- Open the Copy Panel Team Pagination
function LuaMainFunctionSystem.OpenCopyMapTeamPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.TeamPanel, UIManyCopyPanelEnum.XinMoPanel})
end

-- Open the copy panel inner demon copy pagination
function LuaMainFunctionSystem.OpenCopyMapXinMoPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.TeamPanel, UIManyCopyPanelEnum.XinMoPanel})
end

-- Open the copy panel Five Elements copy pagination
function LuaMainFunctionSystem.OpenCopyMapWuXingPanel(param)
	GameCenter.PushFixEvent(UIEventDefine.UICopyMapForm_OPEN, {UICopyMainPanelEnum.TeamPanel, UIManyCopyPanelEnum.WuXingPanel})
end

-- Open the copy panel
function LuaMainFunctionSystem.OpenCopyMapPanel(param)
	if(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.TowerCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapTowerPanel(param)
	elseif (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.StarCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapStarPanel(param)
	elseif (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.TJZMCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapTJZMPanel(param)
	elseif (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.ExpCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapExpPanel(param)
	elseif (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.XinMoCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapXinMoPanel(param)
	elseif (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WuXingCopyMap)) then
		LuaMainFunctionSystem.OpenCopyMapWuXingPanel(param)
	end
end


-- Refining main panel
function LuaMainFunctionSystem.LianQiCallBack(param)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSynthSub) then
		GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Synth})
	else
		GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Strength})
	end
end

-- Refining Weapon Level 1 Pagination: Magical Products
function LuaMainFunctionSystem.LianQiGodEquipCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.GodEquip, LianQiGodSubEnum.Star})
end
-- Refining Weapon Level 1 Pagination: Magical Products
function LuaMainFunctionSystem.LianQiGodEquipStarCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.GodEquip, LianQiGodSubEnum.Star})
end
-- Refining Weapon Level 1 Pagination: Magical Products
function LuaMainFunctionSystem.LianQiGodEquipLvUpCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.GodEquip, LianQiGodSubEnum.LvUp})
end
-- Refining the weapon level one pagination: forging
function LuaMainFunctionSystem.LianQiForgeCallBack(param)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSynthSub) then
		GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Synth})
	else
		GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Strength})
	end
end

-- Refining the first level page: Forging the second level page: Equipment enhancement
function LuaMainFunctionSystem.LianQiForgeStrengthCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Strength})
end

function LuaMainFunctionSystem.LianQiForgeWashCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Wash})
end

-- Refining Weapon Level 1 Pagination: Gem
function LuaMainFunctionSystem.LianQiGemCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Gem, LianQiGemSubEnum.Begin})
end

-- Refining the weapon level one page: Gem under Secondary page: Gem inlay
function LuaMainFunctionSystem.LianQiGemInlayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Gem, LianQiGemSubEnum.Inlay})
end

-- Refining the weapon level one page: Gem under Secondary page: Gem Refining
function LuaMainFunctionSystem.LianQiGemRefineCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Gem, LianQiGemSubEnum.Refine})
end

-- Refining Weapon Level 1 Pagination: Gem Level 2 Pagination: Immortal Jade Inlay
function LuaMainFunctionSystem.LianQiGemJadeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Gem, LianQiGemSubEnum.Jade})
end

-- Set
function LuaMainFunctionSystem.EquipSuitCalllBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Suit, 1})
end

-- Set of Heavenly Wrath
function LuaMainFunctionSystem.EquipSuitLevel1CallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Suit, 1})
end

-- Set God's Wrath
function LuaMainFunctionSystem.EquipSuitLevel2CallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Suit, 2})
end

-- Set God's Wrath
function LuaMainFunctionSystem.EquipSuitLevel3CallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Suit, 3})
end

function LuaMainFunctionSystem.LianQiForgeUpgradeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.UpGrade, LianQiForgeUpgradeSubEnum.Transfer})
end

-- Mount
function LuaMainFunctionSystem.OpenMountForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.Mount, NatureSubEnum.BaseUpLevel})
end

-- Mount upgrade
function LuaMainFunctionSystem.OpenMountLevelForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.Mount, NatureSubEnum.BaseUpLevel})
end

-- Eat fruits on the mount
function LuaMainFunctionSystem.OpenMountDrugForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.Mount, NatureSubEnum.Drug})
end

-- Mount transformation
function LuaMainFunctionSystem.OpenMountFashionForm(param)
	if param then
		if type(param) == "number" then
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Mount, param})
		else
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Mount, param[0]})
		end
	else
		GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, NatureEnum.Mount)
	end
end

-- Mount model display
function LuaMainFunctionSystem.OpenMountModelShowForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureModelShowForm_OPEN, NatureEnum.Mount)
end

-- World BOSS interface
function LuaMainFunctionSystem.OpenWorldBossForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.WorldBoss, param})
end

-- Set BOSS interface
function LuaMainFunctionSystem.OpenWorldBoss1Form(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.SuitBoss, param})
end

-- Gem BOSS interface
function LuaMainFunctionSystem.OpenWorldBoss2Form(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.GemBoss, param})
end

-- Personal BOSS interface
function LuaMainFunctionSystem.OpenMySelfBossForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.MySelfBoss, param})
end
-- BOSS Home Interface
function LuaMainFunctionSystem.OpenBossHomeForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.BossHome, param})
end

-- Unlimited Boss Interface
function LuaMainFunctionSystem.OpenWuXianBossForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.WuxianBoss, param})
end

-- Realm BOSS
function LuaMainFunctionSystem.OpenStatureBossForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.StatureBoss, param})
end

-- Train BOSS interface
function LuaMainFunctionSystem.OpenTrainBossForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, {BossEnum.TrainBoss, param})
end

-- The Brave's Conquest
function LuaMainFunctionSystem.OpenYZZDEnterForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UIYZZDEnterForm_OPEN)
end
-- The battlefield of the three realms
function LuaMainFunctionSystem.OpenSZZQEnterForm(param)
	GameCenter.PushFixEvent(UIEventDefine.UISZZQEnterForm_OPEN)
end

-- Pet interface
function LuaMainFunctionSystem.OnPetCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Pet, 1})
end
function LuaMainFunctionSystem.OnPetProDetCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Pet, 1})
end
function LuaMainFunctionSystem.OnPetProSoulCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN,{NatureEnum.Pet, 2})
end
function LuaMainFunctionSystem.OnPetLevelCallBack(param)
	if param then
		if type(param) == "number" then
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Pet, param})
		else
			GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.Pet, param[0]})
		end
	else
		GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, NatureEnum.Pet)
	end
end

-- Open the Divine Soldier Interface
function LuaMainFunctionSystem.OnGodWeaponCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGodWeaponForm_OPEN, GodWeaponEnum.Equip);
end

-- Open the head interface of the Divine Soldier Equipment
function LuaMainFunctionSystem.OnGodWeaponEquipHeadCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGodWeaponForm_OPEN, {GodWeaponEnum.Equip,GodWeaponSubEnum.Head});
end

-- Open the body interface of the Divine Soldier Equipment
function LuaMainFunctionSystem.OnGodWeaponEquipBodyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGodWeaponForm_OPEN, {GodWeaponEnum.Equip,GodWeaponSubEnum.Body});
end

-- Open the interface of the special effects parts of the magic weapon equipment
function LuaMainFunctionSystem.OnGodWeaponEquipBodyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGodWeaponForm_OPEN, {GodWeaponEnum.Equip,GodWeaponSubEnum.VFX});
end

-- Open the preview interface of the Divine Soldiers
function LuaMainFunctionSystem.OnGodWeaponPreviewCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGodWeaponForm_OPEN, GodWeaponEnum.Preview);
end

-- Welfare interface main panel
function LuaMainFunctionSystem.OnWelfareCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN)
end

-- Welfare weekly card monthly card panel
function LuaMainFunctionSystem.OnWelfareCardCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.ExclusiveCard)
end
function LuaMainFunctionSystem.OnWelfareCardTipsCallBack(param)
	local _welfareCard = GameCenter.WelfareSystem.WelfareCard
	if _welfareCard == nil then
		return
	end
	if _welfareCard.OwnedCards == nil or _welfareCard.OwnedCards:Count() < 2 then
		GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MONTH_CARD_TIPS)
	end
end

-- Benefits Daily Sign-in Panel
function LuaMainFunctionSystem.OnWelfareDailyCheckCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN, WelfareType.DayCheckIn)
end

-- Welfare Daily Gift Pack Panel
function LuaMainFunctionSystem.OnWelfareDailyGiftCallBack(param)
	if param ~= nil then
		GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, {WelfareType.DayGift, param})
	else
		GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.DayGift)
	end
end

-- Welfare redemption gift pack panel
function LuaMainFunctionSystem.OnWelfareExchangeGiftCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN, WelfareType.ExchangeGift)
end

-- Welfare Growth Fund Panel
function LuaMainFunctionSystem.OnWelfareInvestmentCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.GrowthFund)
end

-- Welfare Peak Fund Panel
function LuaMainFunctionSystem.OnWelfareIPeakFundCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.PeakFund)
end

-- Welfare login gift package panel
function LuaMainFunctionSystem.OnWelfareLoginGiftCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN, WelfareType.LoginGift)
end

-- Welfare Hongmeng Enlightenment Panel
function LuaMainFunctionSystem.OnWelfareWuDaoCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN, WelfareType.FeelingExp)
end

function LuaMainFunctionSystem.OnWelfareLevelGiftCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIWelfareForm_OPEN, WelfareType.LevelGift)
end

-- Function opening reminder interface
function LuaMainFunctionSystem.OnFuncOpenTipsCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuncOpenTipsForm_OPEN, FuncOpenTipsPanelEnum.FuncPanel);
end
function LuaMainFunctionSystem.OnFuncOpenFuncCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuncOpenTipsForm_OPEN, FuncOpenTipsPanelEnum.FuncPanel);
end
function LuaMainFunctionSystem.OnFuncOpenModelCallBack(param)
	if param ~= nil then
		GameCenter.PushFixEvent(UIEventDefine.UIFuncOpenTipsForm_OPEN, {FuncOpenTipsPanelEnum.ModelPanel, param});
	else
		GameCenter.PushFixEvent(UIEventDefine.UIFuncOpenTipsForm_OPEN, FuncOpenTipsPanelEnum.ModelPanel);
	end
end

-- Mall
function LuaMainFunctionSystem.OnShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, {ShopPanelEnum.GoldShop})
end
function LuaMainFunctionSystem.OnGoldShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, {ShopPanelEnum.GoldShop})
end
function LuaMainFunctionSystem.OnDailyShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.DailyShop, param)
end
function LuaMainFunctionSystem.OnBindgoldShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.BindgoldShop, param)
end
function LuaMainFunctionSystem.OnHonorShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.HonorShop, param)
end
function LuaMainFunctionSystem.OnNormalShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.NormalShop, param)
end
function LuaMainFunctionSystem.OnExchangeShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, {ShopPanelEnum.ExchangeShop})
end
function LuaMainFunctionSystem.OnIntegralShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.IntegralShop, param)
end
function LuaMainFunctionSystem.OnTreasureShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.TreasureShop, param)
end
function LuaMainFunctionSystem.OnArrayroadShopCallBack(param)
	GameCenter.ShopSystem:OpenShopMallPanel(FunctionStartIdCode.ArrayroadShop, param)
end

-- Help the battle
function LuaMainFunctionSystem.OnAssistFightCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.AssistFightingSub, AssistFightingEnum.Monster})
end
function LuaMainFunctionSystem.OnAssistFightSubCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.AssistFightingSub, AssistFightingEnum.Monster})
end
function LuaMainFunctionSystem.OnAssistFightMonsterCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.AssistFightingSub, AssistFightingEnum.Monster})
end

-- Open the welcome interface
function LuaMainFunctionSystem.OnWelComeCallBack(param)
	GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_OPEN_WELECOME_PANEL)
end

-- Open the fashion body interface
function LuaMainFunctionSystem.OnFashionBodyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.Body)
end

-- Open the fashion theme interface
function LuaMainFunctionSystem.OnFashionThemeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.Theme)
end

-- Open the fashion avatar interface
function LuaMainFunctionSystem.OnFashionHeadCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.Head)
end

-- Open the fashion avatar frame interface
function LuaMainFunctionSystem.OnFashionHeadFrameCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.HeadFrame)
end

-- Open the fashion bubble interface
function LuaMainFunctionSystem.OnFashionChatBgCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.ChatBg)
end

-- Open the Fashion Step Dust Interface
function LuaMainFunctionSystem.OnFashionBuChenCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFashionableForm_OPEN, FashionEnum.BuChen)
end

-- Open the basic interface of Xianpo
function LuaMainFunctionSystem.OnXianPoBaseCallBack(param)
	--GameCenter.PushFixEvent(UIEventDefine.UIXianPoBaseForm_OPEN, {XianPoBaseSubPanel.HolyEquip, HolyEquipSubPanel.EquipDress})
	--UIXianPoMainForm_OPEN
	GameCenter.PushFixEvent(UIEventDefine.UIXianPoMainForm_OPEN, XianPoMainSubPanel.Begin)
end

-- Open the Immortal Soul Main Interface
function LuaMainFunctionSystem.OnXianPoMainCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianPoMainForm_OPEN, param)
end


-- Open the Xianpo decomposition interface
function LuaMainFunctionSystem.OnXianPoDecompositionCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.XianPoMain, XianPoMainSubPanel.Decomposition})
end

-- Open the Xianpo synthesis interface
function LuaMainFunctionSystem.OnXianPoSyntheticCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.XianPoMain, XianPoMainSubPanel.Synthetic})
end

-- Open the Holy Clothing Interface
function LuaMainFunctionSystem.OnHolyEquipCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.HolyEquip, HolyEquipSubPanel.EquipDress})
end
-- Open the Holy Dress Wearing Interface
function LuaMainFunctionSystem.OnHolyEquipDressCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.HolyEquip, HolyEquipSubPanel.EquipDress})
end
-- Open the Holy Equipment Decomposition Interface
function LuaMainFunctionSystem.OnHolyEquipSplitCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN,
					{AttachEquipSubpanel.HolyEquip, {HolyEquipSubPanel.EquipDress, HolyEquipSubPanel.EquipSplit}})
end
-- Open the Holy Soul interface
function LuaMainFunctionSystem.OnHolyEquipSoulCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN,
					{AttachEquipSubpanel.HolyEquip, {HolyEquipSubPanel.EquipDress, HolyEquipSubPanel.EquipSoul}})
end
-- Open the Holy Clothing Enhancement Interface
function LuaMainFunctionSystem.OnHolyEquipIntensifyCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN,
					{AttachEquipSubpanel.HolyEquip, HolyEquipSubPanel.EquipIntensify})
end
-- Open the Holy Clothing Synthesis Interface
function LuaMainFunctionSystem.OnHolyEquipComposeCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN,
					{AttachEquipSubpanel.HolyEquip, {HolyEquipSubPanel.EquipCompose, param}})
end

-- The interface of marriage
-- Open the main interface of marriage
function LuaMainFunctionSystem.OnMarryCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN, {MarriageSubEnum.Main, param});
end
function LuaMainFunctionSystem.OnMarryInfoCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN, {MarriageSubEnum.Main, param});
end
-- Open a marriage appointment
function LuaMainFunctionSystem.OnMarryAppointmentCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryAppointmentForm_OPEN)
end
-- Open the interface to establish a marriage
function LuaMainFunctionSystem.OnMarryEngagementCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryEngagementForm_OPEN, param)
end
-- Open a marriage invitation
function LuaMainFunctionSystem.OnMarryInviteCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryInviteForm_OPEN)
end
-- Open the marriage process
function LuaMainFunctionSystem.OnMarryProcessCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryProcessForm_OPEN)
end
-- Open the marriage gift
function LuaMainFunctionSystem.OnMarryGiftsCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryGiftsForm_OPEN)
end
-- Open marriage proposal
function LuaMainFunctionSystem.OnMarryTypeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryTypeForm_OPEN, param)
end

function LuaMainFunctionSystem.OnMarryFriendCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryFriendForm_OPEN)
end
-- Open the marriage fairy kid
function LuaMainFunctionSystem.OnMarryChildCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN,  {MarriageSubEnum.Child, param});
end

function LuaMainFunctionSystem.OnMarryBlessCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN, {MarriageSubEnum.Bless, param});
end

function LuaMainFunctionSystem.OnMarryBanquetCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIMarryBanquetForm_OPEN, param);
end

function LuaMainFunctionSystem.OnMarryHeartLockCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN, {MarriageSubEnum.HeartLock, param});
end

function LuaMainFunctionSystem.OnMarryBoxCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarriageForm_OPEN, {MarriageSubEnum.Box, param});
end

-- Open the server repository interface
function LuaMainFunctionSystem.OnServerStoreCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIStoreHouseForm_OPEN)
end

-- Treasure Hunt Main Interface
function LuaMainFunctionSystem.OnTreasureHuntCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.Hunt, param});
end

-- Treasure Hunt Prize Pool
function LuaMainFunctionSystem.OnTreasureFindCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.Hunt, param});
end

-- Treasure Hunt Prize Pool
function LuaMainFunctionSystem.OnTreasureWuyouCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UITreasureWuyouForm_OPEN);
end

-- Treasure hunt for fortune
function LuaMainFunctionSystem.OnTreasureZaoHuaCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.ZaoHua, param});
end

-- Hongmeng Treasure Hunt
function LuaMainFunctionSystem.OnTreasureHongMengCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.HongMeng, param});
end

-- Ancient treasure hunt
function LuaMainFunctionSystem.OnTreasureShangGuCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.ShangGu, param});
end

-- Equipment synthesis
function LuaMainFunctionSystem.OnEquipSynthesisCallBack(param)
	-- local objct = { BagFormSubEnum.EquipSyn, nil}
	GameCenter.PushFixEvent(UIEventDefine.UILianQiForm_OPEN, {LianQiSubEnum.Forge, LianQiForgeSubEnum.Synth, param})
end

-- Equipment synthesis
function LuaMainFunctionSystem.OnBagEquipSynCallBack(param)
	local objct = { BagFormSubEnum.EquipSyn, nil}
	GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagBaseForm_OPEN, objct)
end

-- Equipment synthesis
function LuaMainFunctionSystem.OnBagSynCallBack(param)
	local objct = { BagFormSubEnum.Synth, param}
	GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagBaseForm_OPEN, objct)
end

-- Server name change
function LuaMainFunctionSystem.OnChangeServerNameCallBack(param)
	-- GameCenter.PushFixEvent(UIEventDefine.UIChangeServerNameForm_OPEN);
end

-- Realm Practice Room
function LuaMainFunctionSystem.OnRealmExpMapCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIRealmExpForm_OPEN);
end

-- Burning the sky
function LuaMainFunctionSystem.OnFireSkyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFireSkyForm_OPEN);
end

-- Daily recharge
function LuaMainFunctionSystem.OnDailyRechargeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIDailyRechargeForm_OPEN);
end

-- Cross-server
function LuaMainFunctionSystem.OnCrossServerCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UICrossServerForm_OPEN)
end

-- The Island of the Divine Beast, Cross-Server
function LuaMainFunctionSystem.OnGodIslandCallBack(parm)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.GodIsland) then
		GameCenter.PushFixEvent(UIEventDefine.UICrossServerForm_OPEN, {CrossServerEnum.GodIsland, parm})
	else
		local funcData = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.GodIsland)
		Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", funcData.Cfg.FunctionName)
	end
end
-- Eight-pole formation
function LuaMainFunctionSystem.OnBaJiZhenCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UICrossServerForm_OPEN, {CrossServerEnum.BaJiZhen})
end
-- Eight-pole formation
function LuaMainFunctionSystem.OnMountECopyCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UICrossServerForm_OPEN, {CrossServerEnum.HuangGuCopy, parm})
end
-- This suit, the island of the beast
function LuaMainFunctionSystem.OnGodIslandLocalCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UIBossForm_OPEN, BossEnum.SoulMonsterCopy)
end

-- Spiritual Pressure
function LuaMainFunctionSystem.OnRealmStifleCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.FaBao, NatureSubEnum.BaseUpLevel})
end

-- Spiritual Pressure
function LuaMainFunctionSystem.OnRealmStifleDrugCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.FaBao, NatureSubEnum.Drug})
end

-- Magic weapon spirit
function LuaMainFunctionSystem.OnRealmStifleOrganCallBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UINatureForm_OPEN, {NatureEnum.FaBao, NatureSubEnum.BaseUpLevel})
end

-- Magical treasure transformation
function LuaMainFunctionSystem.OnFabaoHuaxingCallBack(parm)
    GameCenter.PushFixEvent(UIEventDefine.UIFasionBaseForm_OPEN, {NatureEnum.FaBao, parm})
end
-- Magic weapon evolution
function LuaMainFunctionSystem.OnRealmStifleEvoCallBack(parm)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.FaBaoOrgan) then
        GameCenter.PushFixEvent(UIEventDefine.UIRealmStifleEvolutionForm_Open, parm)
    else
        Utils.ShowPromptByEnum("C_TIPS_LINGTI_ERR2")
    end
end

-- monologue
function LuaMainFunctionSystem.OnSoliloquyBack(parm)
	GameCenter.PushFixEvent(UIEventDefine.UISoliloquyForm_OPEN, parm)
end

-- Melting
function LuaMainFunctionSystem.OnSmeltEquipMain(param)
	GameCenter.PushFixEvent(UIEventDefine.UIEquipSmeltForm_OPEN)
end
-- Remote smelting
function LuaMainFunctionSystem.OnSmeltEquip(param)
	if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSmelt) then
		Utils.ShowMsgBox(function(code)
				if code == MsgBoxResultCode.Button2 then
					local _cfg = DataConfig.DataGlobal[GlobalName.Smelt_equip_npc]
					if _cfg then
						GameCenter.PathSearchSystem:SearchPathToNpcTalk(tonumber(_cfg.Params))
					end
				end
			end, "C_UI_EQUIPSMELT_NOOPEN_TIPS")
	else
		GameCenter.PushFixEvent(UIEventDefine.UIEquipSmeltForm_OPEN)
	end
end

-- Fake Infinite Boss Entry Interface
function LuaMainFunctionSystem.OnUnlimitBoss(param)
	GameCenter.PushFixEvent(UIEventDefine.UIUnlimitBossForm_OPEN, param)
end

-- Auction house
function LuaMainFunctionSystem.OnAuctionCallBack(param)
	if type(param) == "string" then
		-- Open search directly
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, {AuctionSubPanel.World, param})
	else
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.World)
	end
end
-- World Auction
function LuaMainFunctionSystem.OnAuctionWorldCallBack(param)
	if type(param) == "string" then
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, {AuctionSubPanel.World, param})
	else
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.World)
	end
end
-- Guild Auction
function LuaMainFunctionSystem.OnAuctionGuildCallBack(param)
	if type(param) == "string" then
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, {AuctionSubPanel.Guild, param})
	else
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.Guild)
	end
end
-- My bidding
function LuaMainFunctionSystem.OnAuctionBuyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.SelfBuy)
end
-- Mine is on the shelves
function LuaMainFunctionSystem.OnAuctionSellCallBack(param)
	if type(param) == "number" then
		-- Open it directly
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, {AuctionSubPanel.SelfSell, param})
	else
		GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.SelfSell)
	end
end
-- Transaction history
function LuaMainFunctionSystem.OnAuctionRecordCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.Record)
end
-- My attention
function LuaMainFunctionSystem.OnAuctionFollowCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIAuctionHouseForm_OPEN, AuctionSubPanel.SelfFollow)
end

-- Ranking list
function LuaMainFunctionSystem.OnRankCallBack(param)
	if param ~= nil and type(param) == "number" then
		local cfg = DataConfig.DataRankBase[tonumber(param)]
		if cfg ~= nil then
			if cfg.FunctionOpen ~= 0 then
				-- Determine whether the function is turned on
				if not GameCenter.MainFunctionSystem:FunctionIsVisible(cfg.FunctionOpen) then
					Utils.ShowPromptByEnum("C_RANK_NOT_OPEN")
					return
				end
			end
		end
	end
	GameCenter.PushFixEvent(UIEventDefine.UIRankBaseForm_Open, {SubTab = 1, Param = param})
end
-- Hall of Fame
function LuaMainFunctionSystem.OnCelebrithCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIRankBaseForm_Open, {SubTab = 2, Param = param})
end

function LuaMainFunctionSystem.OnRankBaseCallBack(param)
	if(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Rank)) then
		LuaMainFunctionSystem.OnRankCallBack(param)
	elseif(GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Celebrith)) then
		LuaMainFunctionSystem.OnCelebrithCallBack(param)
	end
end

-- World Bonfire Entrance
function LuaMainFunctionSystem.OnWorldBonfireEnterCallBack(param)
	Utils.ShowMsgBox(function(code)
		if code == MsgBoxResultCode.Button2 then
			-- Enter the Bonfire Copy
			GameCenter.DailyActivitySystem:ReqJoinActivity(105)
        end
    end, "C_GOUHUOOPEN_TIPS")
end

-- Prize questionnaire
function LuaMainFunctionSystem.OnQuestionCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIQuestionnaireForm_OPEN, param)
end

-- Spiritual body
function LuaMainFunctionSystem.OnLingTiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILingTiBaseForm_Open, {LianQiLingTiSubEnum.Main, param})
end
function LuaMainFunctionSystem.OnLingTiSynthCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILingTiBaseForm_Open, {LianQiLingTiSubEnum.Synth, param})
end
function LuaMainFunctionSystem.OnLingTiStarCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILingTiBaseForm_Open, {LianQiLingTiSubEnum.Star, param})
end
function LuaMainFunctionSystem.OnLingTiFantaiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILingtiOpenForm_OPEN)
end

function LuaMainFunctionSystem.OnVipBaseCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIVipForm_Open, param)
end

-- Vip Zhou Chang
function LuaMainFunctionSystem.OnVipWeekCallBack(param)
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	if _lp == nil then
		return
	end
	if _lp.VipLevel <= 0 then
		Utils.ShowPromptByEnum("C_FREE_OPENVIP_STATE")
		return
	end
	GameCenter.PushFixEvent(UILuaEventDefine.UIVipBaseForm_OPEN, 2)
end

-- VIP cumulative recharge
function LuaMainFunctionSystem.OnVipRechargeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIVipRechargeForm_Open)
end

-- Vip Cultivate the Spirit and Forge the Body
function LuaMainFunctionSystem.OnVipDuanTiCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVipBaseForm_OPEN, 4)
end

-- Vip Cultivate the Spirit and Forge the Body
function LuaMainFunctionSystem.OnResBackCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIResBackForm_Open)
end

-- Skill interface
function LuaMainFunctionSystem.OnOccSkillCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, OccSkillSubPanel.AtkPanel)
end

-- Skill List
function LuaMainFunctionSystem.OnOccSkillAtkCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, OccSkillSubPanel.AtkPanel)
end

-- Skill slot upgrade
function LuaMainFunctionSystem.OnOccSkillCellCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, {OccSkillSubPanel.AtkPanel, FunctionStartIdCode.PlayerSkillCell})
end

-- Skills Upgrade
function LuaMainFunctionSystem.OnOccSkillStarCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, {OccSkillSubPanel.AtkPanel, FunctionStartIdCode.PlayerSkillStar})
end

-- Passive skills
function LuaMainFunctionSystem.OnOccSkillPassCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, OccSkillSubPanel.PassPanel)
end

-- Talisman
function LuaMainFunctionSystem.OnOccSkillFuZhouCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, OccSkillSubPanel.FuZhou)
end

function LuaMainFunctionSystem.OnPlayerSkillMeridianCallBack(param)
	local _merId = GameCenter.PlayerSkillSystem.CurSelectMerId
	if _merId == 0 then
		-- The mind method has not been selected yet, open the interface of the mind method selection
		GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.PlayerSkillXinFa)
		return
	end
	GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Open, OccSkillSubPanel.Meridian)
end

-- top up
function LuaMainFunctionSystem.OnPayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPayRootForm_Open, {FunctionStartIdCode.PayBase, param})
end

-- Newbie recharge
function LuaMainFunctionSystem.OnPayNewbieCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPayRootForm_Open, {FunctionStartIdCode.PayNewbie, param})
end

-- Weekly recharge
function LuaMainFunctionSystem.OnPayWeekCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPayRootForm_Open, {FunctionStartIdCode.PayWeek, param})
end

-- Daily recharge
function LuaMainFunctionSystem.OnPayDayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPayRootForm_Open, {FunctionStartIdCode.PayDay, param})
end

-- Marrow washing
function LuaMainFunctionSystem.OnRealmXiSuiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXiSuiForm_OPEN, param)
end

-- Mysterious limited purchase
function LuaMainFunctionSystem.OnLimitShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIShopMallForm_OPEN, ShopPanelEnum.LimitShop)
end

function LuaMainFunctionSystem.OnXianjiaCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, param)
end
function LuaMainFunctionSystem.OnXianjiaExchangeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, FunctionStartIdCode.XianJiaExchange)
end
function LuaMainFunctionSystem.OnXianjiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, FunctionStartIdCode.Xianji)
end
function LuaMainFunctionSystem.OnXianPeiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, FunctionStartIdCode.XianPeiSyn)
end
function LuaMainFunctionSystem.OnXianjiaSubCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, FunctionStartIdCode.XianJiaSyn)
end
function LuaMainFunctionSystem.OnXianjiaSubEquipCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIXianjiaForm_OPEN, FunctionStartIdCode.SubEquip)
end
function LuaMainFunctionSystem.OnGuildTaskCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
        GameCenter.PushFixEvent(UIEventDefine.UIGuildTaskGetForm_Open)
	else
		Utils.ShowPromptByEnum("C_OPENGUILDTASK_NOGUILD")
	end
end

function LuaMainFunctionSystem.OnHuSongCallBack(param)
	if GameCenter.HuSongSystem.ReMainTime > 0 then
		GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongFlashForm_OPEN)
	else
		GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongForm_OPEN)
	end
end

-- Immortal Alliance Vehicle
function LuaMainFunctionSystem.OnXMFightCarCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIXMFightCarForm_OPEN)
end

-- Xianmeng Store
function LuaMainFunctionSystem.OnGuildShopCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildShopForm_OPEN, param)
	else
		Utils.ShowPromptByEnum("FUDISYSTEM_TISHI_7")
	end
end
-- Tianxu Store
function LuaMainFunctionSystem.OnTerrialtShopCallBack(param)
	local _mapCfg = GameCenter.GameSceneSystem:GetActivedMapSetting()
	if _mapCfg and _mapCfg.MapType == 1 then
		Utils.ShowPromptByEnum("UNIVERSE_SHOP_TITLE")
	else
		GameCenter.PushFixEvent(UIEventDefine.UITerritoriaShopForm_OPEN, param)
	end
end

-- Immortal Alliance Mission Copy Portal
function LuaMainFunctionSystem.OnEnterGuildTaskCopy(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGuildTaskCopyEnterForm_OPEN)
end

-- Immortal Armor Treasure Hunt
function LuaMainFunctionSystem.OnXJXunbaoCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIXJXunbaoRootForm_OPEN, {XJTreasureEnum.XJXunbao, param})
end

-- Fairy Armor Treasure Hunt Warehouse
function LuaMainFunctionSystem.OnXJCangkuCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIXJCangkuForm_OPEN)
end

-- Immortal Armor Treasure Hunt
function LuaMainFunctionSystem.OnXJMibaoCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIXJMibaoForm_OPEN)
end

-- New fashion
function LuaMainFunctionSystem.OnNewFashionCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewFashionForm_OPEN)
end

-- First rush
function LuaMainFunctionSystem.OnFirstChargeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFristChargeForm_Open, param)
end

-- Tips for offline download
function LuaMainFunctionSystem.OnExitRewardTipsCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIExitRewardTipsForm_OPEN, param)
end

-- Functional preview
function LuaMainFunctionSystem.OnFunctionNoticeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuncOpenTipsForm_OPEN, FuncOpenTipsPanelEnum.NoticePanel)
end

-- Real-name authentication
function LuaMainFunctionSystem.OnCertificationCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UICertificationForm_OPEN)
end

-- Buy 0 yuan
function LuaMainFunctionSystem.OnFreeShopCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIFreeGiftForm_OPEN)
end

-- Buy 2 yuan
function LuaMainFunctionSystem.OnFreeShop2CallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIZeroBuyForm_OPEN, param)
end

-- VIP zero yuan purchase
function LuaMainFunctionSystem.OnFreeShopVIPCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIZeroBuyVIPForm_OPEN)
end

-- Marriage Store
function LuaMainFunctionSystem.OnMarryShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryShopForm_OPEN, param)
end

-- Open the Add Friends Interface
function LuaMainFunctionSystem.OnAddFriendCallBack(param)
	if param then
		GameCenter.FriendSystem:AddRelation(FriendType.Friend, param);
	else
		GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN, FunctionStartIdCode.AddFriend)
	end
end

-- Transfer
function LuaMainFunctionSystem.OnChangeJobCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIChangeJobForm_OPEN, param)
end
-- Lingge
function LuaMainFunctionSystem.OnSpriteHoemCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 1})
end
-- Sword Spirit
function LuaMainFunctionSystem.OnFlySwordSpriteCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 2})
end
-- Sword Spirit Form
function LuaMainFunctionSystem.OnFlySwordSpriteBaseCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 2, param})
end
-- Sword Spirit Cultivation
function LuaMainFunctionSystem.OnFlySwordSpriteTrainCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 3, FunctionStartIdCode.FlySwordSpriteUpLv, param})
end
-- Sword Spirit Upgrade
function LuaMainFunctionSystem.OnFlySwordSpriteLvCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 3, FunctionStartIdCode.FlySwordSpriteUpLv, param})
end
-- Sword Spirit Upgrade
function LuaMainFunctionSystem.OnFlySwordSpriteUpGradeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.FlySwordSprite, 3, FunctionStartIdCode.FlySwordSpriteUpGrade, param})
end
-- Sword Tomb
function LuaMainFunctionSystem.OnFlySwordGraveCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFlySwordGraveForm_OPEN)
end

-- New server activities
function LuaMainFunctionSystem.OnNewServerActivityCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewServerActivityForm_OPEN, 0)
end

-- New server advantages
function LuaMainFunctionSystem.OnNewServerAdvantageCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewServerActivityForm_OPEN, 0)
end

-- Perfect love
function LuaMainFunctionSystem.OnPerfectLoveCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewServerActivityForm_OPEN, 1)
end

-- Spiritual Soul Lottery
function LuaMainFunctionSystem.OnLingPoLotteryCallBack(param)
	--GameCenter.PushFixEvent(UILuaEventDefine.UILingPoLotteryForm_OPEN, param)
    GameCenter.PushFixEvent(UIEventDefine.UITreasureHuntForm_OPEN, {TreasureEnum.LingPo, param});
end

-- Spiritual Soul Inlay
function LuaMainFunctionSystem.OnXianPoInlayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.XianPoMain, XianPoMainSubPanel.Inlay})
end

-- Spiritual Soul Exchange
function LuaMainFunctionSystem.OnXianPoExchangeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISpriteHomeForm_OPEN, {FunctionStartIdCode.XianPoMain, XianPoMainSubPanel.Exchange})
end

-- Limited time discount
function LuaMainFunctionSystem.OnLimitDicretShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UILimitDicretShopForm_OPEN, param)
end

-- Limited time discount
function LuaMainFunctionSystem.OnLimitDicretShop2CallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILimitDicretShopForm2_OPEN, param)
end

-- Target tasks
function LuaMainFunctionSystem.OnTargetTaskCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_OPEN, - ActivityPanelTypeEnum.Target)
end

-- Weekly calendar
function LuaMainFunctionSystem.OnCalendarCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_OPEN, - ActivityPanelTypeEnum.Week)
end

-- Operations
function LuaMainFunctionSystem.OnYunYingHDCallBack(param)
	GameCenter.YYHDSystem:OpenHD(param)
end

-- Blind date wall
function LuaMainFunctionSystem.OnMarryWallCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryDatingWallForm_OPEN, MarryWallSubEnum.LevelPanel)
end

-- Blind date wall
function LuaMainFunctionSystem.OnMarryWallLevelCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryDatingWallForm_OPEN, MarryWallSubEnum.LevelPanel)
end

-- Blind date wall
function LuaMainFunctionSystem.OnMarryWallXuanYanCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIMarryDatingWallForm_OPEN, MarryWallSubEnum.WallPanel)
end

-- Weekly benefits
function LuaMainFunctionSystem.OnLuckyDrawWeekCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILuckyDrawWeekForm_OPEN)
end

-- Fashion call
function LuaMainFunctionSystem.OnFashionCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewFashionForm_OPEN,{SubForm = 1, Param = param})
end

-- Fashion illustration
function LuaMainFunctionSystem.OnFashionTjCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewFashionForm_OPEN,{SubForm = 2, Param = param})
end

function LuaMainFunctionSystem.OnWardrobeCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewFashionForm_OPEN,{SubForm = 3, Param = nil})
end

-- Treasure Pavilion Call
function LuaMainFunctionSystem.OnZhenCangGeCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIZhenCangGeForm_OPEN)
end

-- Calling the Treasure Pavilion Dui Temple
function LuaMainFunctionSystem.OnDuiBaoDianCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIZhenCangGeForm_OPEN, 1)
end

-- Saturday Carnival
function LuaMainFunctionSystem.OnCrazySatCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIWeekCrazyForm_OPEN)
end

-- Open Share Like Tips
function LuaMainFunctionSystem.OnThaiShareGroupCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIShareAndLikeTipsForm_OPEN, param)
end

-- Open the character interface
function LuaMainFunctionSystem.OnPlayerCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerBaseForm_OPEN, param)
end

-- Open the role attribute interface
function LuaMainFunctionSystem.OnPropetryCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerBaseForm_OPEN, param)
end

-- Open the main interface of the Heavenly Ban Order
function LuaMainFunctionSystem:OnTianJinLingBaseCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.TianJinLing)
end

-- Pet equipment enhancement
function LuaMainFunctionSystem.OnPetEquipStrengthCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPetEquipBaseForm_OPEN, {FunctionStartIdCode.PetEquipStrength, param})
end

-- Pet equipment with soul
function LuaMainFunctionSystem.OnPetEquipFuhunCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPetEquipBaseForm_OPEN, {FunctionStartIdCode.PetEquipFuhun, param})
end

-- Pet equipment synthesis
function LuaMainFunctionSystem.OnPetEquipSynthCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIPetEquipBaseForm_OPEN, {FunctionStartIdCode.PetEquipSynth, param})
end

-- Pet equipment
function LuaMainFunctionSystem.OnPetEquipCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UIPetEquipMainForm_OPEN)
end

-- Mount Equipment Enhancement
function LuaMainFunctionSystem.OnMountEquipStrengthCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipBaseForm_OPEN, {FunctionStartIdCode.MountEquipStrength, param})
end

-- Mount equipment with soul
function LuaMainFunctionSystem.OnMountEquipFuhunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipBaseForm_OPEN, {FunctionStartIdCode.MountEquipFuhun, param})
end

-- Mount equipment synthesis
function LuaMainFunctionSystem.OnMountEquipSynthCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipBaseForm_OPEN, {FunctionStartIdCode.MountEquipSynth, param})
end

-- Mount Equipment
function LuaMainFunctionSystem.OnMountEquipCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipMainForm_OPEN)
end

-- Automatic matching of peak competition
function LuaMainFunctionSystem.OnArenaTopMatchCallBack(param)
	if not GameCenter.DailyActivitySystem:GetLimitActiveRedByID(21) then
		Utils.ShowPromptByEnum("WorldAnswerAppError")
		return
	end
	-- if not GameCenter.FormStateSystem:FormIsOpen("UITopJjcMainForm") then
	-- 	GameCenter.PushFixEvent(UIEventDefine.UIArenaForm_Open, JJCType.DianFeng)
    -- end
	--if GameCenter.TopJjcSystem.IsAutoMatch then
		local _msg = ReqMsg.MSG_Peak.ReqEnterPeakMatch:New()
		_msg:Send()
	--end
end

-- Peak competition
function LuaMainFunctionSystem.OnArenaTopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaForm_Open, JJCType.DianFeng)
end

-- Soul Armor
function LuaMainFunctionSystem.OnSoulEquipCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulEquipBaseForm_OPEN)
end
-- Soul Seal
function LuaMainFunctionSystem.OnSoulEquipInlayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulEquipBaseForm_OPEN, FunctionStartIdCode.SoulEquipInlay)
end

-- Soul Seal Praying Spirit
function LuaMainFunctionSystem.OnSoulEquipLotteryCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulPearlLotteryForm_OPEN)
end

-- Soul Seal Strengthening
function LuaMainFunctionSystem.OnSoulPearlStrengthCallBack(param)
	if GameCenter.SoulEquipSystem:HavePearl() then
		GameCenter.PushFixEvent(UIEventDefine.UISoulPearlBaseForm_OPEN, {FunctionStartIdCode.SoulPearlStrength})
	else
		Utils.ShowPromptByEnum("C_SOULEQUIP_INLAY_NEEDWEAR")
	end
end

-- Soul Seal Synthesis
function LuaMainFunctionSystem.OnSoulPearlSYnthCallBack(param)
	if GameCenter.SoulEquipSystem:HavePearl() then
		GameCenter.PushFixEvent(UIEventDefine.UISoulPearlBaseForm_OPEN, {FunctionStartIdCode.SoulPearlSynth})
	else
		Utils.ShowPromptByEnum("C_SOULEQUIP_INLAY_NEEDWEAR")
	end
end

-- Soul Seal Decomposition
function LuaMainFunctionSystem.OnSoulPearlSplitCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulEquipSplitForm_OPEN)
end

-- Soul Armor Breakthrough
function LuaMainFunctionSystem.OnSoulEquipBreakCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulEquipBaseForm_OPEN, FunctionStartIdCode.SoulEquipBreak)
end

-- Soul Armor Awakens
function LuaMainFunctionSystem.OnSoulEquipAweakCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISoulEquipBaseForm_OPEN, FunctionStartIdCode.SoulEquipAweak)
end

-- Immortal Cultivation Treasure Mirror
function LuaMainFunctionSystem.OnRankAwardCallBack(param)
	if param == nil then
		return
	end
	if type(param) ~= "number" then
		return
	end
	GameCenter.Network.Send("MSG_ActivityRanklist.ReqActivityRankInfo", {rankKind = param})
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("Watting_Form_Msg"))
end

-- Blessed Sword Contest Ranking Reward
function LuaMainFunctionSystem.OnFuDiLjRnakCallBack(param)
    GameCenter.PushFixEvent(UILuaEventDefine.UIFuDiLjRankForm_OPEN)
end

-- Main function menu
function LuaMainFunctionSystem.OnMainFuncRootCallBack(param)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_OPEN_MAINMENU)
end
-- Backpack
function LuaMainFunctionSystem.OnBagCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagBaseForm_OPEN)
	-- GameCenter.PushFixEvent(UILuaEventDefine.UISlayerBaseForm_OPEN, {FunctionStartIdCode.SlayerCreate, 20011})
end
-- Game settings
function LuaMainFunctionSystem.OnGameSettingCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UIGameSettingForm_OPEN)
end
-- System Settings
function LuaMainFunctionSystem.OnSystemSettingCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UIGameSettingForm_OPEN)
end
-- Game feedback
function LuaMainFunctionSystem.OnGameFeedbackCallBack(param)
    GameCenter.PushFixEvent(UIEventDefine.UIGameSettingForm_FB_OPEN)
end
-- Social functions
function LuaMainFunctionSystem.OnSocialityCallBack(param)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.Friend) then
		GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN, SocialityFormSubPanel.Friend)
	else
		GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN, SocialityFormSubPanel.Mail)
	end
end
-- Friends function
function LuaMainFunctionSystem.OnFriendCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN, SocialityFormSubPanel.Friend)
end
-- Email function
function LuaMainFunctionSystem.OnMailCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISocialityForm_OPEN, SocialityFormSubPanel.Mail)
end
-- Mini map
function LuaMainFunctionSystem.OnAreaMapCallBack(param)
	local _info = GameCenter.PathFinderSystem:GetMapObjInfo(GameCenter.GameSceneSystem:GetActivedMapID())
	if _info == nil then
		return
	end
	GameCenter.PushFixEvent(UIEventDefine.UI_MAP_OPEN, _info)
end
-- Team
function LuaMainFunctionSystem.OnTeamCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITeamForm_OPEN, TeamFormSubPanel.Team)
end
-- Team
function LuaMainFunctionSystem.OnTeamInfoCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITeamForm_OPEN, TeamFormSubPanel.Team)
end
-- Team Match
function LuaMainFunctionSystem.OnTeamMatchCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITeamForm_OPEN, {TeamFormSubPanel.Match, param})
end
-- arena
function LuaMainFunctionSystem.OnArenaCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaForm_Open, 1)
end
-- arena
function LuaMainFunctionSystem.OnArenaShouXiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaForm_Open, 1)
end
-- arena
function LuaMainFunctionSystem.OnArenaRankCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaRankForm_Open)
end
-- arena
function LuaMainFunctionSystem.OnArenaRewardCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaRewardForm_Open)
end
-- arena
function LuaMainFunctionSystem.OnArenaFightInfoCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIArenaFightInfoForm_Open)
end
-- daily
function LuaMainFunctionSystem.OnDailyActivityCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_OPEN, param)
end
-- Private chat
function LuaMainFunctionSystem.OnPrivateChatCallBack(param)
	if param ~= nil then
		local _targetId = tonumber(param[0])
		if not GameCenter.FriendSystem:IsShield(_targetId) then
			GameCenter.FriendSystem:AddRelation(5, _targetId)
		else
			Utils.ShowPromptByEnum("SOCIAL_PROMPT", param[1])
		end
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildCallBack(param)
	GameCenter.GuildSystem:OnOpenPanel()
end
-- Gang
function LuaMainFunctionSystem.OnGuildCreateCallBack(param)
	GameCenter.GuildSystem:OnOpenPanel()
end
-- Gang
function LuaMainFunctionSystem.OnGuildTabBaseInfoCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_INFO})
	else
		GameCenter.GuildSystem:OnOpenPanel()
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildBuildCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_BUILD})
	else
		GameCenter.GuildSystem:OnOpenPanel()
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildTabGuildListCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_INFO, GuildSubEnum.Info_List})
	else
		GameCenter.GuildSystem:OnOpenPanel()
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildBossCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_ACTION, FunctionStartIdCode.GuildBoss})
	else
		GameCenter.GuildSystem:OnOpenPanel()
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildWarCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_ACTION, FunctionStartIdCode.GuildWar})
	else
		GameCenter.GuildSystem:OnOpenPanel();
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildBoxCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.TYPE_BOX})
	else
		GameCenter.GuildSystem:OnOpenPanel();
	end
end
-- Gang
function LuaMainFunctionSystem.OnGuildRedPackageCallBack(param)
	if GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIGuildNewForm_OPEN, {GuildSubEnum.Type_RedPackage})
	else
		GameCenter.GuildSystem:OnOpenPanel();
	end
end
-- Offline hanging machine
function LuaMainFunctionSystem.OnOnHookFormCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOnHookForm_OPEN)
end
-- Offline hanging machine
function LuaMainFunctionSystem.OnOnHookSettingFormCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIOnHookSettingForm_OPEN, param)
end
-- Blessed land
function LuaMainFunctionSystem.OnFuDiCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuDiForm_Open, 1)
end
-- Blessed land
function LuaMainFunctionSystem.OnFuDiRankCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuDiForm_Open, 1)
end
-- Blessed land
function LuaMainFunctionSystem.OnFuDiBossCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuDiForm_Open, 2)
end
-- Fudi Store
function LuaMainFunctionSystem.OnFuDiShopCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuDiForm_Open, 4)
end
-- Blessed land of swords
function LuaMainFunctionSystem.OnFuDiLjCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIFuDiForm_Open, 3)
end
-- title
function LuaMainFunctionSystem.OnRoleTitleCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIRoleTitleForm_OPEN)
end
-- Opening a server carnival
function LuaMainFunctionSystem.OnServeCrazyCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIServeCrazyForm_Open, param)
end
-- The road to growth
function LuaMainFunctionSystem.OnGrowthWayCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIGrowthWayForm_Open)
end
--
function LuaMainFunctionSystem.OnServerActiveCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIServerActiveForm_Open)
end
function LuaMainFunctionSystem.OnWorldAnserCallBack(param)
	GameCenter.Network.Send("MSG_WorldAnswer.ReqApplyAnswer", {})
end
-- top up
function LuaMainFunctionSystem.OnReChargeCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIRechargeForm_Open)
end
-- The Realm of Chaos
function LuaMainFunctionSystem.OnTerritorialWarCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITerritorialWarForm_OPEN)
end
-- The Realm of Chaos
function LuaMainFunctionSystem.OnTerritorialWarMainCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITerritorialWarForm_OPEN, FunctionStartIdCode.TerritorialWarMain)
end
-- The Realm of Chaos
function LuaMainFunctionSystem.OnTerritorialWarCelebrityCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UITerritorialWarForm_OPEN, FunctionStartIdCode.TerritorialWarCelebrity)
end
-- Preaching
function LuaMainFunctionSystem.OnChuanDaoCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIChuanDaoForm_Open)
end
--vip
function LuaMainFunctionSystem.OnVipCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UIVipForm_Open, param)
end
-- chat
function LuaMainFunctionSystem.OnChatCallBack(param)
	if param == nil then
		GameCenter.PushFixEvent(UIEventDefine.UIChatMainForm_OPEN, {0, -1})
	else
		local _param2 = math.floor(param / 1000)
		param = param % 1000
		GameCenter.PushFixEvent(UIEventDefine.UIChatMainForm_OPEN, {param, _param2})
	end
end
-- World Support
function LuaMainFunctionSystem.OnWorldSupportCallBack(param)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WorldSupport) and GameCenter.GuildSystem:HasJoinedGuild() then
		GameCenter.PushFixEvent(UIEventDefine.UIWorldSupportForm_Open);
	else
		if not GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WorldSupport) then
			Utils.ShowPromptByEnum("C_TIPS_FUNCTION_ZHIYUAN")
		end
		if not GameCenter.GuildSystem:HasJoinedGuild() then
			Utils.ShowPromptByEnum("C_TIPS_ERROR_ZHIYUAN")
		end
	end
end
-- Sword Spirit Pavilion
function LuaMainFunctionSystem.OnFlySwordMandateCallBack(param)
	GameCenter.PushFixEvent(UIEventDefine.UISwordMandateForm_OPEN, param)
end
-- View other players
function LuaMainFunctionSystem.OnLookOtherPlayerCallBack(param)
	if param == nil or type(param) ~= "number" then
		return
	end
	if GameCenter.FormStateSystem:GetFormState("UIGuildForm") == 4 then
		GameCenter.Network.Send("MSG_Player.ReqLookOtherPlayer", {otherPlayerId = param})
	else
		GameCenter.Network.Send("MSG_Player.ReqPlayerSummaryInfo", {roleId = param})
	end
end
-- shield
function LuaMainFunctionSystem.OnScreenCallBack(param)
	if param == nil or type(param) ~= "number" then
		return
	end
	GameCenter.FriendSystem:AddConfirmation(FriendType.Shield, param);
end
-- Invite to join the team
function LuaMainFunctionSystem.OnInviteTeamCallBack(param)
	if param == nil or type(param) ~= "number" then
		return
	end
	GameCenter.TeamSystem:ReqInvite(param);
end
-- NPC dialogue
function LuaMainFunctionSystem.OnTalkToNPCCallBack(param)
	if param ~= nil and type(param) == "number" then
		GameCenter.PathSearchSystem:SearchPathToNpcTalk(param);
		GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_HIDE_CURFULLSCREEN_FORM);
	end
end
-- Cross-server blessed place
function LuaMainFunctionSystem.OnCrossFuDiCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UICrossFuDiForm_OPEN)
end
-- Switching mind method
function LuaMainFunctionSystem.OnPlayerSkillXinFaCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UISelectXinFaForm_OPEN)
end
-- Tips for becoming stronger
function LuaMainFunctionSystem.OnBianQiangCallBack(param)
	GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAINFORM_SHOWBIANQIANG)
end
-- Know the sea
function LuaMainFunctionSystem.OnPlayerJingJieCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPlayerBaseForm_OPEN, 1)
end

-- Reward Order
function LuaMainFunctionSystem.OnKaosOrderCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIKaosOrderBaseForm_OPEN)
end

-- Open the Demon Removal Group
function LuaMainFunctionSystem.OnSlayerCreateCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UISlayerBaseForm_OPEN, {FunctionStartIdCode.SlayerCreate, param})
end

-- Join the Demon Elimination Group
function LuaMainFunctionSystem.OnSlayerJoinCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UISlayerBaseForm_OPEN, {FunctionStartIdCode.SlayerJoin, param})
end

-- Gossip
function LuaMainFunctionSystem.OnXianjiaBaGuaCallBack(param)
	if param == nil then
		param = 1
	end
	GameCenter.PushFixEvent(UILuaEventDefine.UIXianjia8GuaBaseForm_OPEN, {FunctionStartIdCode.BaGuaBag, param})
end
-- Gossip backpack
function LuaMainFunctionSystem.OnXianjiaBaGuaBagCallBack(param)
	if param == nil then
		param = 1
	end
	GameCenter.PushFixEvent(UILuaEventDefine.UIXianjia8GuaBaseForm_OPEN, {FunctionStartIdCode.BaGuaBag, param})
end
-- Gossip synthesis
function LuaMainFunctionSystem.OnXianjiaBaGuaSynCallBack(param)
	if param == nil then
		param = 1
	end
	GameCenter.PushFixEvent(UILuaEventDefine.UIXianjia8GuaBaseForm_OPEN, {FunctionStartIdCode.BaGuaSyn, param})
end
-- Bagua Exchange
function LuaMainFunctionSystem.OnXianjiaBaGuaExchangeCallBack(param)
	if param == nil then
		param = 1
	end
	GameCenter.PushFixEvent(UILuaEventDefine.UIXianjia8GuaBaseForm_OPEN, {FunctionStartIdCode.BaGuaExchange, param})
end

-- Demon-sealing platform
function LuaMainFunctionSystem.OnFengMoTaiCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIFengMoTaiForm_OPEN);
end

-- Demon Soul Main Interface
function LuaMainFunctionSystem.OnDevilSoulMainCallBack(param)
	if type(param) == "userdata" then
		GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.DevilSoulMain, {FunctionStartIdCode.DevilSoulMain, param[0]}})
	else
		GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.DevilSoulMain, FunctionStartIdCode.DevilSoulMain})
	end
end

-- Demon Soul Backpack
function LuaMainFunctionSystem.OnDevilSoulBagCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.DevilSoulMain, FunctionStartIdCode.DevilSoulBag})
end

-- Demon soul breakthrough
function LuaMainFunctionSystem.OnDevilSoulSurmountCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.DevilSoulMain, FunctionStartIdCode.DevilSoulSurmount})
end

-- Demon Soul Synthesis
function LuaMainFunctionSystem.OnDevilSoulSynthCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAssistFightBaseForm_OPEN, {FunctionStartIdCode.DevilSoulMain, FunctionStartIdCode.DevilSoulSynth})
end

-- Community
function LuaMainFunctionSystem.OnCommunityCallBack(param)
	GameCenter.CommunityMsgSystem:ReqPlayerCommunityInfo(GameCenter.GameSceneSystem:GetLocalPlayerID())
end

-- The gap between the devil
function LuaMainFunctionSystem.OnOyLieKaiCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIOYLieKaiForm_OPEN, 2)
end

-- Perfect love
function LuaMainFunctionSystem.OnPrefectRomanceCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPrefectRomanceForm_OPEN, FunctionStartIdCode.PrefectSpouse)
end

-- Perfect love fairy couple
function LuaMainFunctionSystem.OnPrefectSpouseCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPrefectRomanceForm_OPEN, FunctionStartIdCode.PrefectSpouse)
end

-- Perfect love mission
function LuaMainFunctionSystem.OnPrefectTaskCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPrefectRomanceForm_OPEN, FunctionStartIdCode.PrefectTask)
end

-- Perfect love gift pack
function LuaMainFunctionSystem.OnPrefectGiftCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPrefectRomanceForm_OPEN, FunctionStartIdCode.PrefectGift)
end

-- Beautiful love fortune bag
function LuaMainFunctionSystem.OnPrefectPackCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIPrefectRomanceForm_OPEN, FunctionStartIdCode.PrefectPack)
end

function LuaMainFunctionSystem.OnChaoZhiCallBack(param)
	if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.WelfareDailyGift) then
		GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.DayGift)
	else
		GameCenter.PushFixEvent(UILuaEventDefine.UIChaoZhiForm_OPEN, WelfareType.ExclusiveCard)
	end
end

-- Home Decoration Competition
function LuaMainFunctionSystem.OnDecorateCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIDecorateMainForm_OPEN)
end

-- Preview of the mind method
function LuaMainFunctionSystem.OnPreviewXinFaCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIXinFaPreviewForm_OPEN)
end

function LuaMainFunctionSystem.OnDailyTaskCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UINewDailyTaskform_OPEN)
end

function LuaMainFunctionSystem.OnVipInvationNorCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVipInvationForm_OPEN, 1)
end

function LuaMainFunctionSystem.OnVipInvationZbCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVipInvationForm_OPEN, 2)
end

function LuaMainFunctionSystem.OnVipBaoZhuJiHuoCallBack(param)
	if param ~= nil then
		GameCenter.PushFixEvent(UILuaEventDefine.UIVipBaoZhuUseForm_OPEN, tonumber(param[0]))
	end
end

function LuaMainFunctionSystem.OnToDayFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UITodyFuncForm_OPEN, param)
end

function LuaMainFunctionSystem.OnLoversFightFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightForm_OPEN, {Sub = 1, Param = nil})
end

function LuaMainFunctionSystem.OnLoversFightFreeFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightForm_OPEN, {Sub = 1, Param = nil})
end

function LuaMainFunctionSystem.OnLoversFightGroupFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightForm_OPEN, {Sub = 2, Param = param})
end

function LuaMainFunctionSystem.OnLoversFightTopFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightForm_OPEN, {Sub = 3, Param = nil})
end

function LuaMainFunctionSystem.OnLoversFightPickFuncCallBack(param)
	--GameCenter.PushFixEvent(UILuaEventDefine.UILoversFightForm_OPEN, 4)
end

function LuaMainFunctionSystem.OnAttachFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.HolyEquip, HolyEquipSubPanel.EquipDress})
end

function LuaMainFunctionSystem.OnUnrealEquipFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.UnrealEquip, 0})
end

function LuaMainFunctionSystem.OnUnrealEquipSoulFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.UnrealEquip, 1})
end

function LuaMainFunctionSystem.OnUnrealEquipSyncFuncCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIAttachEquipForm_OPEN, {AttachEquipSubpanel.UnrealEquip, 2})
end

function LuaMainFunctionSystem.OnCustomHeadFunCallBack()
	if  PlayerPrefs.GetInt("PlayerAgreementForChangeHead") == nil or PlayerPrefs.GetInt("PlayerAgreementForChangeHead") == 0 then
		GameCenter.PushFixEvent(UILuaEventDefine.UICommunityAgreementForm_OPEN)
    else
		GameCenter.PushFixEvent(UILuaEventDefine.UIChangeHeadForm_OPEN)
	end
end

function LuaMainFunctionSystem.OnV4HelpBaseFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVIPHelpBaseForm_OPEN, 3)
end

function LuaMainFunctionSystem.OnVIPHelpFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVIPHelpBaseForm_OPEN, 0)
end

function LuaMainFunctionSystem.OnV4RebateFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVIPHelpBaseForm_OPEN, 1)
end

function LuaMainFunctionSystem.OnRebateBoxFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVIPHelpBaseForm_OPEN, 2)
end

function LuaMainFunctionSystem.OnXMZhengBaFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIVIPHelpBaseForm_OPEN, 3)
end

function LuaMainFunctionSystem.OnOfflineFindFunCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIOfflineFindForm_OPEN, param)
end
function LuaMainFunctionSystem.OnSpecialShopCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIShopOrbForm_OPEN, {SpecialShopPanelEnum.OrbShop})
end
function LuaMainFunctionSystem.OnOrbShopCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIShopOrbForm_OPEN, {SpecialShopPanelEnum.OrbShop})
end

function LuaMainFunctionSystem.OnEscortCallBack(param)
	GameCenter.PushFixEvent(UILuaEventDefine.UIEscortForm_OPEN)
end

function LuaMainFunctionSystem.OnEscortMapCallBack(param)
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	if _lp == nil then
		return
	end
	-- Switch scene to escort map 1700
	if (GameCenter.GameSceneSystem.ActivedScene.MapId == 1700)then
		Utils.ShowPromptByEnum("CAMPMAP_HAVAINMAP")
	else
		_lp:Action_CrossMapTran(1700)
	end
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
end

function LuaMainFunctionSystem.OnTrainBOSSMapCallBack(param)
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	if _lp == nil then
		return
	end
	-- Switch scene to train map 1602
	if (GameCenter.GameSceneSystem.ActivedScene.MapId == 1602)then
		Utils.ShowPromptByEnum("CAMPMAP_HAVAINMAP")
	else
		_lp:Action_CrossMapTran(1602)
	end
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
end

function LuaMainFunctionSystem.OnPrisonMapCallBack(param)
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	if _lp == nil then
		return
	end
	-- Switch scene to train map 1650
	local prison_map_id_cfg = DataConfig.DataGlobal[GlobalName.Prison_Map_ID]
	-- Debug.Log("Prison Map ID:" .. tostring(prison_map_id_cfg.Params))
	if prison_map_id_cfg == nil then
		return
	end
	local prison_map_id = tonumber(prison_map_id_cfg.Params)
	if (GameCenter.GameSceneSystem.ActivedScene.MapId == prison_map_id)then
		Utils.ShowPromptByEnum("CAMPMAP_HAVAINMAP")
	else
		_lp:Action_CrossMapTran(prison_map_id)
	end
	GameCenter.PushFixEvent(UIEventDefine.UIDailyActivityForm_CLOSE)
end

-- Registration for all open interfaces
local functionStartkMap = {
	[FunctionStartIdCode.XianjiaBaGua] = LuaMainFunctionSystem.OnXianjiaBaGuaCallBack,
	[FunctionStartIdCode.BaGuaBag] = LuaMainFunctionSystem.OnXianjiaBaGuaBagCallBack,
	[FunctionStartIdCode.BaGuaSyn] = LuaMainFunctionSystem.OnXianjiaBaGuaSynCallBack,
	[FunctionStartIdCode.BaGuaExchange] = LuaMainFunctionSystem.OnXianjiaBaGuaExchangeCallBack,
	[FunctionStartIdCode.SlayerCreate] = LuaMainFunctionSystem.OnSlayerCreateCallBack,
	[FunctionStartIdCode.SlayerJoin] = LuaMainFunctionSystem.OnSlayerJoinCallBack,
	[FunctionStartIdCode.SoulEquip] = LuaMainFunctionSystem.OnSoulEquipCallBack,
	[FunctionStartIdCode.SoulEquipStrength] = LuaMainFunctionSystem.OnSoulEquipCallBack,
	[FunctionStartIdCode.SoulEquipInlay] = LuaMainFunctionSystem.OnSoulEquipInlayCallBack,
	[FunctionStartIdCode.SoulEquipLottery] = LuaMainFunctionSystem.OnSoulEquipLotteryCallBack,
	[FunctionStartIdCode.SoulPearlStrength] = LuaMainFunctionSystem.OnSoulPearlStrengthCallBack,
	[FunctionStartIdCode.SoulPearlSynth] = LuaMainFunctionSystem.OnSoulPearlSYnthCallBack,
	[FunctionStartIdCode.SoulPearlSplit] = LuaMainFunctionSystem.OnSoulPearlSplitCallBack,
	[FunctionStartIdCode.SoulPearlWear] = LuaMainFunctionSystem.OnSoulEquipInlayCallBack,
	[FunctionStartIdCode.SoulEquipBreak] = LuaMainFunctionSystem.OnSoulEquipBreakCallBack,
	[FunctionStartIdCode.SoulEquipAweak] = LuaMainFunctionSystem.OnSoulEquipAweakCallBack,
	[FunctionStartIdCode.ArenaTop] = LuaMainFunctionSystem.OnArenaTopCallBack,
	[FunctionStartIdCode.ArenaTopAutoMatch] = LuaMainFunctionSystem.OnArenaTopMatchCallBack,
	[FunctionStartIdCode.PetEquipStrength] = LuaMainFunctionSystem.OnPetEquipStrengthCallBack,
	[FunctionStartIdCode.PetEquipFuhun] = LuaMainFunctionSystem.OnPetEquipFuhunCallBack,
	[FunctionStartIdCode.PetEquipSynth] = LuaMainFunctionSystem.OnPetEquipSynthCallBack,
	[FunctionStartIdCode.PetEquip] = LuaMainFunctionSystem.OnPetEquipCallBack,
	[FunctionStartIdCode.MountEquipStrength] = LuaMainFunctionSystem.OnMountEquipStrengthCallBack,
	[FunctionStartIdCode.MountEquipFuhun] = LuaMainFunctionSystem.OnMountEquipFuhunCallBack,
	[FunctionStartIdCode.MountEquipSynth] = LuaMainFunctionSystem.OnMountEquipSynthCallBack,
	[FunctionStartIdCode.MountEquip] = LuaMainFunctionSystem.OnMountEquipCallBack,
	[FunctionStartIdCode.LimitDicretShop] = LuaMainFunctionSystem.OnLimitDicretShopCallBack,
	[FunctionStartIdCode.LimitDicretShop2] = LuaMainFunctionSystem.OnLimitDicretShop2CallBack,
	[FunctionStartIdCode.FlySwordGrave] = LuaMainFunctionSystem.OnFlySwordGraveCallBack,
	[FunctionStartIdCode.SpriteHome] = LuaMainFunctionSystem.OnSpriteHoemCallBack,
	[FunctionStartIdCode.FlySwordSprite] = LuaMainFunctionSystem.OnFlySwordSpriteCallBack,
	[FunctionStartIdCode.FlySwordSpriteBase] = LuaMainFunctionSystem.OnFlySwordSpriteBaseCallBack,
	[FunctionStartIdCode.FlySwordSpriteTrain] = LuaMainFunctionSystem.OnFlySwordSpriteTrainCallBack,
	[FunctionStartIdCode.FlySwordSpriteUpLv] = LuaMainFunctionSystem.OnFlySwordSpriteLvCallBack,
	[FunctionStartIdCode.FlySwordSpriteUpGrade] = LuaMainFunctionSystem.OnFlySwordSpriteUpGradeCallBack,
	[FunctionStartIdCode.Certification] = LuaMainFunctionSystem.OnCertificationCallBack,
	[FunctionStartIdCode.TerritoriaShop] = LuaMainFunctionSystem.OnTerrialtShopCallBack,
	[FunctionStartIdCode.GuildTaskCopyEnter] = LuaMainFunctionSystem.OnEnterGuildTaskCopy,
	[FunctionStartIdCode.ContributionShop] = LuaMainFunctionSystem.OnGuildShopCallBack,
	[FunctionStartIdCode.GuildTask] = LuaMainFunctionSystem.OnGuildTaskCallBack,
	[FunctionStartIdCode.HuSong] = LuaMainFunctionSystem.OnHuSongCallBack,
	[FunctionStartIdCode.XianJia] = LuaMainFunctionSystem.OnXianjiaCallBack,
	[FunctionStartIdCode.Xianji] = LuaMainFunctionSystem.OnXianjiCallBack,
	[FunctionStartIdCode.XianPeiSyn] = LuaMainFunctionSystem.OnXianPeiCallBack,
	[FunctionStartIdCode.XianJiaSyn] = LuaMainFunctionSystem.OnXianjiaSubCallBack,
	[FunctionStartIdCode.SubEquip] = LuaMainFunctionSystem.OnXianjiaSubEquipCallBack,
	[FunctionStartIdCode.XianJiaExchange] = LuaMainFunctionSystem.OnXianjiaExchangeCallBack,
	[FunctionStartIdCode.Intimate] = LuaMainFunctionSystem.OnIntimateCallBack,
	[FunctionStartIdCode.EquipSmelt] = LuaMainFunctionSystem.OnSmeltEquip,
	[FunctionStartIdCode.EquipSmeltMain] = LuaMainFunctionSystem.OnSmeltEquipMain,
	[FunctionStartIdCode.CrossServer] = LuaMainFunctionSystem.OnCrossServerCallBack,
	[FunctionStartIdCode.GodIsland] = LuaMainFunctionSystem.OnGodIslandCallBack,
	[FunctionStartIdCode.BaJiZhen] = LuaMainFunctionSystem.OnBaJiZhenCallBack,
	[FunctionStartIdCode.MountECopy] = LuaMainFunctionSystem.OnMountECopyCallBack,
	[FunctionStartIdCode.SoulMonsterCopy] = LuaMainFunctionSystem.OnGodIslandLocalCallBack,
	[FunctionStartIdCode.StatureBoss] = LuaMainFunctionSystem.OpenStatureBossForm,
	[FunctionStartIdCode.EquipSynthSub] = LuaMainFunctionSystem.OnEquipSynthesisCallBack,
	[FunctionStartIdCode.EquipSynthesis] = LuaMainFunctionSystem.OnBagEquipSynCallBack,
	[FunctionStartIdCode.BagSynth] = LuaMainFunctionSystem.OnBagSynCallBack,
	[FunctionStartIdCode.AssistFighting] = LuaMainFunctionSystem.OnAssistFightCallBack,
	[FunctionStartIdCode.AssistFightingSub] = LuaMainFunctionSystem.OnAssistFightSubCallBack,
	[FunctionStartIdCode.MonsterAF] = LuaMainFunctionSystem.OnAssistFightMonsterCallBack,
	[FunctionStartIdCode.Nature] = LuaMainFunctionSystem.OpenNaturePanel,
	[FunctionStartIdCode.NatureWing] = LuaMainFunctionSystem.OpenNaturePanel,
	[FunctionStartIdCode.NatureWingLevel] = LuaMainFunctionSystem.OpenNatureWingPanel,
	[FunctionStartIdCode.NatureWingDrug] = LuaMainFunctionSystem.OpenNatureWingDrugPanel,
	[FunctionStartIdCode.NatureWingFashion] = LuaMainFunctionSystem.OpenNatureWingFashaionPanel,
	[FunctionStartIdCode.NatureWingModelShow] = LuaMainFunctionSystem.OpenNatureWingModelShowPanel,
	[FunctionStartIdCode.NatureTalismanLevel] = LuaMainFunctionSystem.OpenNatureTalismanPanel,
	[FunctionStartIdCode.NatureTalismanDrug] = LuaMainFunctionSystem.OpenNatureTalismanDrugPanel,
	[FunctionStartIdCode.NatureTalismanFashion] = LuaMainFunctionSystem.OpenNatureTalismanFashionPanel,
	[FunctionStartIdCode.NatureTalismanModelShow] = LuaMainFunctionSystem.OpenNatureTalismanModelShowPanel,
	[FunctionStartIdCode.NatureMagicLevel] = LuaMainFunctionSystem.OpenNatureMagicPanel,
	[FunctionStartIdCode.NatureMagicDrug] = LuaMainFunctionSystem.OpenNatureMagicDrugPanel,
	[FunctionStartIdCode.NatureMagicFashion] = LuaMainFunctionSystem.OpenNatureMagicFashionPanel,
	[FunctionStartIdCode.NatureMagicModelShow] = LuaMainFunctionSystem.OpenNatureMagicModelShowPanel,
	[FunctionStartIdCode.NatureWeaponLevel] = LuaMainFunctionSystem.OpenNatureWeaponLevelPanel,
	[FunctionStartIdCode.NatureWeaponDrag] = LuaMainFunctionSystem.OpenNatureWeaponBreakPanel,
	[FunctionStartIdCode.NatureWeaponFashion] = LuaMainFunctionSystem.OpenNatureWeaponFashionPanel,
	[FunctionStartIdCode.NatureWeaponModelShow] = LuaMainFunctionSystem.OpenNatureWeaponModelShowPanel,
	[FunctionStartIdCode.NatureWeapon] = LuaMainFunctionSystem.OpenNatureWeaponLevelPanel,
	[FunctionStartIdCode.Mount] = LuaMainFunctionSystem.OpenMountForm,
	[FunctionStartIdCode.MountBase] = LuaMainFunctionSystem.OpenMountForm,
	[FunctionStartIdCode.MountBaseAttr] = LuaMainFunctionSystem.OpenMountForm,
	[FunctionStartIdCode.MountLevel] = LuaMainFunctionSystem.OpenMountLevelForm,
	[FunctionStartIdCode.MountDrug] = LuaMainFunctionSystem.OpenMountDrugForm,
	[FunctionStartIdCode.MountFashion] = LuaMainFunctionSystem.OpenMountFashionForm,
	[FunctionStartIdCode.MountModelShow] = LuaMainFunctionSystem.OpenMountModelShowForm,
	[FunctionStartIdCode.MountEatEquip] = LuaMainFunctionSystem.OpenMountForm,

	[FunctionStartIdCode.FashionableBase] = LuaMainFunctionSystem.OnFashionBodyCallBack,
	[FunctionStartIdCode.FashionableBody] = LuaMainFunctionSystem.OnFashionBodyCallBack,
	[FunctionStartIdCode.FashionableTheme] = LuaMainFunctionSystem.OnFashionThemeCallBack,
	[FunctionStartIdCode.FashionableAssemble] = LuaMainFunctionSystem.OnFashionHeadCallBack,
	[FunctionStartIdCode.FashionableHead] = LuaMainFunctionSystem.OnFashionHeadCallBack,
	[FunctionStartIdCode.FashionableHeadFrame] = LuaMainFunctionSystem.OnFashionHeadFrameCallBack,
	[FunctionStartIdCode.FashionableChatBg] = LuaMainFunctionSystem.OnFashionChatBgCallBack,
	[FunctionStartIdCode.FashionableBuChen] = LuaMainFunctionSystem.OnFashionBuChenCallBack,

	[FunctionStartIdCode.CopyMap] = LuaMainFunctionSystem.OpenCopyMapPanel,
	[FunctionStartIdCode.SingleCopyMap] = LuaMainFunctionSystem.OpenCopyMapSinglePanel,
	[FunctionStartIdCode.TowerCopyMap] = LuaMainFunctionSystem.OpenCopyMapTowerPanel,
	[FunctionStartIdCode.CopyMapMenu] = LuaMainFunctionSystem.OpenCopyMapTowerPanel,
	[FunctionStartIdCode.StarCopyMap] = LuaMainFunctionSystem.OpenCopyMapStarPanel,
	[FunctionStartIdCode.TJZMCopyMap] = LuaMainFunctionSystem.OpenCopyMapTJZMPanel,
	[FunctionStartIdCode.TeamCopyMap] = LuaMainFunctionSystem.OpenCopyMapTeamPanel,
	[FunctionStartIdCode.ExpCopyMap] = LuaMainFunctionSystem.OpenCopyMapExpPanel,
	[FunctionStartIdCode.XinMoCopyMap] = LuaMainFunctionSystem.OpenCopyMapXinMoPanel,
	[FunctionStartIdCode.WuXingCopyMap] = LuaMainFunctionSystem.OpenCopyMapWuXingPanel,

	[FunctionStartIdCode.LianQi] = LuaMainFunctionSystem.LianQiCallBack,
	[FunctionStartIdCode.LianQiForge] = LuaMainFunctionSystem.LianQiForgeCallBack,
	[FunctionStartIdCode.LianQiForgeStrength] = LuaMainFunctionSystem.LianQiForgeStrengthCallBack,
	[FunctionStartIdCode.LianQiForgeWash] = LuaMainFunctionSystem.LianQiForgeWashCallBack,
	[FunctionStartIdCode.LianQiGem] = LuaMainFunctionSystem.LianQiGemCallBack,
	[FunctionStartIdCode.LianQiGemInlay] = LuaMainFunctionSystem.LianQiGemInlayCallBack,
	[FunctionStartIdCode.LianQiGemRefine] = LuaMainFunctionSystem.LianQiGemRefineCallBack,
	[FunctionStartIdCode.LianQiGemJade] = LuaMainFunctionSystem.LianQiGemJadeCallBack,
	[FunctionStartIdCode.GodEquip] = LuaMainFunctionSystem.LianQiGodEquipCallBack,
	[FunctionStartIdCode.GodEquipStar] = LuaMainFunctionSystem.LianQiGodEquipStarCallBack,
	[FunctionStartIdCode.GodEquipUplv] = LuaMainFunctionSystem.LianQiGodEquipLvUpCallBack,

	[FunctionStartIdCode.EquipSuit] = LuaMainFunctionSystem.EquipSuitCalllBack,
	[FunctionStartIdCode.EquipSuitLevel1] = LuaMainFunctionSystem.EquipSuitLevel1CallBack,
	[FunctionStartIdCode.EquipSuitLevel2] = LuaMainFunctionSystem.EquipSuitLevel2CallBack,
	[FunctionStartIdCode.EquipSuitLevel3] = LuaMainFunctionSystem.EquipSuitLevel3CallBack,

	[FunctionStartIdCode.LianQiForgeUpgrade] = LuaMainFunctionSystem.LianQiForgeUpgradeCallBack,

	[FunctionStartIdCode.Boss] = LuaMainFunctionSystem.OpenWorldBossForm,
	[FunctionStartIdCode.MySelfBoss] = LuaMainFunctionSystem.OpenMySelfBossForm,
	[FunctionStartIdCode.WorldBoss] = LuaMainFunctionSystem.OpenWorldBossForm,
	[FunctionStartIdCode.WorldBoss1] = LuaMainFunctionSystem.OpenWorldBoss1Form,
	[FunctionStartIdCode.WorldBoss2] = LuaMainFunctionSystem.OpenWorldBoss2Form,
	[FunctionStartIdCode.BossHome] = LuaMainFunctionSystem.OpenBossHomeForm,
	[FunctionStartIdCode.WuXianBoss] = LuaMainFunctionSystem.OpenWuXianBossForm,
	[FunctionStartIdCode.TrainBoss] = LuaMainFunctionSystem.OpenTrainBossForm,
	[FunctionStartIdCode.ArenaYZZD] = LuaMainFunctionSystem.OpenYZZDEnterForm,
	[FunctionStartIdCode.ArenaSZZQ] = LuaMainFunctionSystem.OpenSZZQEnterForm,
	[FunctionStartIdCode.Pet] = LuaMainFunctionSystem.OnPetCallBack,
	[FunctionStartIdCode.PetProDet] = LuaMainFunctionSystem.OnPetProDetCallBack,
	[FunctionStartIdCode.PetProSoul] = LuaMainFunctionSystem.OnPetProSoulCallBack,
	[FunctionStartIdCode.PetLevel] = LuaMainFunctionSystem.OnPetLevelCallBack,

	[FunctionStartIdCode.GodWeapon] = LuaMainFunctionSystem.OnGodWeaponCallBack,
	[FunctionStartIdCode.GodWeaponEquip] = LuaMainFunctionSystem.OnGodWeaponCallBack,
	[FunctionStartIdCode.GodWeaponEquipHead] = LuaMainFunctionSystem.OnGodWeaponEquipHeadCallBack,
	[FunctionStartIdCode.GodWeaponEquipBody] = LuaMainFunctionSystem.OnGodWeaponEquipBodyCallBack,
	[FunctionStartIdCode.GodWeaponEquipVfx] = LuaMainFunctionSystem.OnGodWeaponEquipBodyCallBack,
	[FunctionStartIdCode.GodWeaponPreview] = LuaMainFunctionSystem.OnGodWeaponPreviewCallBack,

	[FunctionStartIdCode.Welfare] = LuaMainFunctionSystem.OnWelfareCallBack,
	[FunctionStartIdCode.WelfareCard] = LuaMainFunctionSystem.OnWelfareCardCallBack,
	[FunctionStartIdCode.WelfareCardTips] = LuaMainFunctionSystem.OnWelfareCardTipsCallBack,
	[FunctionStartIdCode.WelfareDailyCheck] = LuaMainFunctionSystem.OnWelfareDailyCheckCallBack,
	[FunctionStartIdCode.WelfareDailyGift] = LuaMainFunctionSystem.OnWelfareDailyGiftCallBack,
	[FunctionStartIdCode.WelfareExchangeGift] = LuaMainFunctionSystem.OnWelfareExchangeGiftCallBack,
	[FunctionStartIdCode.WelfareInvestment] = LuaMainFunctionSystem.OnWelfareInvestmentCallBack,
	[FunctionStartIdCode.WelfareIPeakFund] = LuaMainFunctionSystem.OnWelfareIPeakFundCallBack,
	[FunctionStartIdCode.WelfareLoginGift] = LuaMainFunctionSystem.OnWelfareLoginGiftCallBack,
	[FunctionStartIdCode.WelfareWuDao] = LuaMainFunctionSystem.OnWelfareWuDaoCallBack,
	[FunctionStartIdCode.WelfareLevelGift] = LuaMainFunctionSystem.OnWelfareLevelGiftCallBack,

	[FunctionStartIdCode.Shop] = LuaMainFunctionSystem.OnShopCallBack,
	[FunctionStartIdCode.GoldShop] = LuaMainFunctionSystem.OnGoldShopCallBack,
	[FunctionStartIdCode.DailyShop] = LuaMainFunctionSystem.OnDailyShopCallBack,
	[FunctionStartIdCode.NormalShop] = LuaMainFunctionSystem.OnNormalShopCallBack,
	[FunctionStartIdCode.BindgoldShop] = LuaMainFunctionSystem.OnBindgoldShopCallBack,
	[FunctionStartIdCode.HonorShop] = LuaMainFunctionSystem.OnHonorShopCallBack,
	[FunctionStartIdCode.ExchangeShop] = LuaMainFunctionSystem.OnExchangeShopCallBack,
	[FunctionStartIdCode.IntegralShop] = LuaMainFunctionSystem.OnIntegralShopCallBack,
	[FunctionStartIdCode.TreasureShop] = LuaMainFunctionSystem.OnTreasureShopCallBack,
	[FunctionStartIdCode.ArrayroadShop] = LuaMainFunctionSystem.OnArrayroadShopCallBack,
	[FunctionStartIdCode.LimitShop] = LuaMainFunctionSystem.OnLimitShopCallBack,

	[FunctionStartIdCode.FuncOpenTips] = LuaMainFunctionSystem.OnFuncOpenTipsCallBack,
	[FunctionStartIdCode.FuncFuncPanel] = LuaMainFunctionSystem.OnFuncOpenFuncCallBack,
	[FunctionStartIdCode.FuncModelPanel] = LuaMainFunctionSystem.OnFuncOpenModelCallBack,
	[FunctionStartIdCode.Welcome] = LuaMainFunctionSystem.OnWelComeCallBack,

	[FunctionStartIdCode.XianPoMain] = LuaMainFunctionSystem.OnXianPoMainCallBack,
	[FunctionStartIdCode.XianPoInlay] = LuaMainFunctionSystem.OnXianPoInlayCallBack,
	[FunctionStartIdCode.XianPoDecomposition] = LuaMainFunctionSystem.OnXianPoDecompositionCallBack,
	[FunctionStartIdCode.XianPoExchange] = LuaMainFunctionSystem.OnXianPoExchangeCallBack,
	[FunctionStartIdCode.XianPoSynthetic] = LuaMainFunctionSystem.OnXianPoSyntheticCallBack,
	[FunctionStartIdCode.HolyEquip] = LuaMainFunctionSystem.OnHolyEquipCallBack,
	[FunctionStartIdCode.HolyEquipDress] = LuaMainFunctionSystem.OnHolyEquipDressCallBack,
	[FunctionStartIdCode.HolyEquipSplit] = LuaMainFunctionSystem.OnHolyEquipSplitCallBack,
	[FunctionStartIdCode.HolyEquipSoul] = LuaMainFunctionSystem.OnHolyEquipSoulCallBack,
	[FunctionStartIdCode.HolyEquipIntensify] = LuaMainFunctionSystem.OnHolyEquipIntensifyCallBack,
	[FunctionStartIdCode.HolyEquipCompose] = LuaMainFunctionSystem.OnHolyEquipComposeCallBack,

	[FunctionStartIdCode.Marry] = LuaMainFunctionSystem.OnMarryCallBack,
	[FunctionStartIdCode.MarryInfo] = LuaMainFunctionSystem.OnMarryInfoCallBack,
	[FunctionStartIdCode.MarryAppointment] = LuaMainFunctionSystem.OnMarryAppointmentCallBack,
	[FunctionStartIdCode.MarryEngagement] = LuaMainFunctionSystem.OnMarryEngagementCallBack,
	[FunctionStartIdCode.MarryInvite] = LuaMainFunctionSystem.OnMarryInviteCallBack,
	[FunctionStartIdCode.MarryProcess] = LuaMainFunctionSystem.OnMarryProcessCallBack,
	[FunctionStartIdCode.MarryGifts] = LuaMainFunctionSystem.OnMarryGiftsCallBack,
	[FunctionStartIdCode.MarryType] = LuaMainFunctionSystem.OnMarryTypeCallBack,
	[FunctionStartIdCode.MarryFriend] = LuaMainFunctionSystem.OnMarryFriendCallBack,
	[FunctionStartIdCode.MarryChild] = LuaMainFunctionSystem.OnMarryChildCallBack,
	[FunctionStartIdCode.MarryBless] = LuaMainFunctionSystem.OnMarryBlessCallBack,
	[FunctionStartIdCode.MarryBanquet] = LuaMainFunctionSystem.OnMarryBanquetCallBack,
	[FunctionStartIdCode.MarryHeartLock] = LuaMainFunctionSystem.OnMarryHeartLockCallBack,
	[FunctionStartIdCode.MarryBox] = LuaMainFunctionSystem.OnMarryBoxCallBack,
	[FunctionStartIdCode.ServerStore] = LuaMainFunctionSystem.OnServerStoreCallBack,
	[FunctionStartIdCode.TreasureHunt] = LuaMainFunctionSystem.OnTreasureHuntCallBack,
	[FunctionStartIdCode.TreasureFind] = LuaMainFunctionSystem.OnTreasureFindCallBack,
	[FunctionStartIdCode.TreasureZaoHua] = LuaMainFunctionSystem.OnTreasureZaoHuaCallBack,
	[FunctionStartIdCode.TreasureHongMeng] = LuaMainFunctionSystem.OnTreasureHongMengCallBack,
	[FunctionStartIdCode.TreasureShangGu] = LuaMainFunctionSystem.OnTreasureShangGuCallBack,
	[FunctionStartIdCode.ChangeServer] = LuaMainFunctionSystem.OnChangeServerNameCallBack,
	[FunctionStartIdCode.RealmExpMap] = LuaMainFunctionSystem.OnRealmExpMapCallBack,
	[FunctionStartIdCode.FireSky] = LuaMainFunctionSystem.OnFireSkyCallBack,
	[FunctionStartIdCode.DailyRechargeForm] = LuaMainFunctionSystem.OnDailyRechargeCallBack,
	[FunctionStartIdCode.RealmStifle] = LuaMainFunctionSystem.OnRealmStifleCallBack,
	[FunctionStartIdCode.FaBaoUpGrade] = LuaMainFunctionSystem.OnRealmStifleCallBack,
	[FunctionStartIdCode.FaBaoDrug] = LuaMainFunctionSystem.OnRealmStifleDrugCallBack,
	[FunctionStartIdCode.FaBaoHuaxing] = LuaMainFunctionSystem.OnFabaoHuaxingCallBack,
	[FunctionStartIdCode.FaBaoSub] = LuaMainFunctionSystem.OnRealmStifleCallBack,
	[FunctionStartIdCode.FaBaoOrgan] = LuaMainFunctionSystem.OnRealmStifleOrganCallBack,
	[FunctionStartIdCode.FaBaoPromote] = LuaMainFunctionSystem.OnRealmStifleOrganCallBack,
	[FunctionStartIdCode.FaBaoEvolution] = LuaMainFunctionSystem.OnRealmStifleEvoCallBack,
	[FunctionStartIdCode.FaBaoActive] = LuaMainFunctionSystem.OnRealmStifleCallBack,
	[FunctionStartIdCode.Soliloquy] = LuaMainFunctionSystem.OnSoliloquyBack,
	[FunctionStartIdCode.UnlimitBoss] = LuaMainFunctionSystem.OnUnlimitBoss,

	[FunctionStartIdCode.Auchtion] = LuaMainFunctionSystem.OnAuctionCallBack,
	[FunctionStartIdCode.AuchtionWorld] = LuaMainFunctionSystem.OnAuctionWorldCallBack,
	[FunctionStartIdCode.AuchtionGuild] = LuaMainFunctionSystem.OnAuctionGuildCallBack,
	[FunctionStartIdCode.AuchtionBuy] = LuaMainFunctionSystem.OnAuctionBuyCallBack,
	[FunctionStartIdCode.AuchtionSell] = LuaMainFunctionSystem.OnAuctionSellCallBack,
	[FunctionStartIdCode.AuchtionRecord] = LuaMainFunctionSystem.OnAuctionRecordCallBack,
	[FunctionStartIdCode.AuchtionFollow] = LuaMainFunctionSystem.OnAuctionFollowCallBack,
	[FunctionStartIdCode.RankBase] = LuaMainFunctionSystem.OnRankBaseCallBack,
	[FunctionStartIdCode.Rank] = LuaMainFunctionSystem.OnRankCallBack,
	[FunctionStartIdCode.Celebrith] = LuaMainFunctionSystem.OnCelebrithCallBack,
	[FunctionStartIdCode.WorldBonfire] = LuaMainFunctionSystem.OnWorldBonfireEnterCallBack,

	[FunctionStartIdCode.PlayerSkill] = LuaMainFunctionSystem.OnOccSkillCallBack,
	[FunctionStartIdCode.PlayerSkillList] = LuaMainFunctionSystem.OnOccSkillAtkCallBack,
	[FunctionStartIdCode.PlayerSkillCell] = LuaMainFunctionSystem.OnOccSkillCellCallBack,
	[FunctionStartIdCode.PlayerSkillStar] = LuaMainFunctionSystem.OnOccSkillStarCallBack,
	[FunctionStartIdCode.GodBook] = LuaMainFunctionSystem.OnOccSkillFuZhouCallBack,
	[FunctionStartIdCode.PlayerSkillMeridian] = LuaMainFunctionSystem.OnPlayerSkillMeridianCallBack,
	[FunctionStartIdCode.Question] = LuaMainFunctionSystem.OnQuestionCallBack,
	[FunctionStartIdCode.LingTi] = LuaMainFunctionSystem.OnLingTiCallBack,
	[FunctionStartIdCode.LingTiMain] = LuaMainFunctionSystem.OnLingTiCallBack,
	[FunctionStartIdCode.LingTiSynth] = LuaMainFunctionSystem.OnLingTiSynthCallBack,
	[FunctionStartIdCode.LingTiStar] = LuaMainFunctionSystem.OnLingTiStarCallBack,
	[FunctionStartIdCode.LingtiFanTai] = LuaMainFunctionSystem.OnLingTiFantaiCallBack,
	[FunctionStartIdCode.VipBase] = LuaMainFunctionSystem.OnVipBaseCallBack,
	[FunctionStartIdCode.VipWeekBase] = LuaMainFunctionSystem.OnVipWeekCallBack,
	[FunctionStartIdCode.VipWeek] = LuaMainFunctionSystem.OnVipWeekCallBack,
	[FunctionStartIdCode.VipRecharge] = LuaMainFunctionSystem.OnVipRechargeCallBack,
	[FunctionStartIdCode.VipLianTi] = LuaMainFunctionSystem.OnVipDuanTiCallBack,
	[FunctionStartIdCode.Pay] = LuaMainFunctionSystem.OnPayCallBack,
	[FunctionStartIdCode.PayBase] = LuaMainFunctionSystem.OnPayCallBack,
	[FunctionStartIdCode.PayNewbie] = LuaMainFunctionSystem.OnPayNewbieCallBack,
	[FunctionStartIdCode.PayWeek] = LuaMainFunctionSystem.OnPayWeekCallBack,
	[FunctionStartIdCode.PayDay] = LuaMainFunctionSystem.OnPayDayCallBack,
	[FunctionStartIdCode.ResBack] = LuaMainFunctionSystem.OnResBackCallBack,
	[FunctionStartIdCode.RealmXiSui] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.RealmXiSuiLv1] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.RealmXiSuiLv2] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.RealmXiSuiLv3] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.RealmXiSuiLv4] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.RealmXiSuiLv5] = LuaMainFunctionSystem.OnRealmXiSuiCallBack,
	[FunctionStartIdCode.XMFightCar] = LuaMainFunctionSystem.OnXMFightCarCallBack,
	[FunctionStartIdCode.XJXunbaoRoot] = LuaMainFunctionSystem.OnXJXunbaoCallBack,
	[FunctionStartIdCode.XJXunbao] = LuaMainFunctionSystem.OnXJXunbaoCallBack,
	[FunctionStartIdCode.XJCangku] = LuaMainFunctionSystem.OnXJCangkuCallBack,
	[FunctionStartIdCode.XJMibao] = LuaMainFunctionSystem.OnXJMibaoCallBack,
	[FunctionStartIdCode.NewFashion] = LuaMainFunctionSystem.OnNewFashionCallBack,
	[FunctionStartIdCode.FirstCharge] = LuaMainFunctionSystem.OnFirstChargeCallBack,
	[FunctionStartIdCode.ExitRewardTips] = LuaMainFunctionSystem.OnExitRewardTipsCallBack,
	[FunctionStartIdCode.FunctionNotice] = LuaMainFunctionSystem.OnFunctionNoticeCallBack,
	[FunctionStartIdCode.FreeShop] = LuaMainFunctionSystem.OnFreeShopCallBack,
	[FunctionStartIdCode.FreeShop2] = LuaMainFunctionSystem.OnFreeShop2CallBack,
	[FunctionStartIdCode.FreeShopVIP] = LuaMainFunctionSystem.OnFreeShopVIPCallBack,
	[FunctionStartIdCode.MarryShop] = LuaMainFunctionSystem.OnMarryShopCallBack,
	[FunctionStartIdCode.AddFriend] = LuaMainFunctionSystem.OnAddFriendCallBack,
	[FunctionStartIdCode.ChangeJob] = LuaMainFunctionSystem.OnChangeJobCallBack,
	[FunctionStartIdCode.NewServerActivity] = LuaMainFunctionSystem.OnNewServerActivityCallBack,
	[FunctionStartIdCode.NewServerAdvantage] = LuaMainFunctionSystem.OnNewServerAdvantageCallBack,
	[FunctionStartIdCode.PerfectLove] = LuaMainFunctionSystem.OnPerfectLoveCallBack,
	[FunctionStartIdCode.LingPoLottery] = LuaMainFunctionSystem.OnLingPoLotteryCallBack,
	[FunctionStartIdCode.TargetTask] = LuaMainFunctionSystem.OnTargetTaskCallBack,
	[FunctionStartIdCode.Task] = LuaMainFunctionSystem.OnTargetTaskCallBack,
	[FunctionStartIdCode.YunYingHD] = LuaMainFunctionSystem.OnYunYingHDCallBack,
	[FunctionStartIdCode.MarryWall] = LuaMainFunctionSystem.OnMarryWallCallBack,
	[FunctionStartIdCode.MarryWallLevel] = LuaMainFunctionSystem.OnMarryWallLevelCallBack,
	[FunctionStartIdCode.MarryWallXuanYan] = LuaMainFunctionSystem.OnMarryWallXuanYanCallBack,
	[FunctionStartIdCode.LuckyDrawWeek] = LuaMainFunctionSystem.OnLuckyDrawWeekCallBack,
	[FunctionStartIdCode.Fashion] = LuaMainFunctionSystem.OnFashionCallBack,
	[FunctionStartIdCode.FashionTj] = LuaMainFunctionSystem.OnFashionTjCallBack,
	[FunctionStartIdCode.Wardrobe] = LuaMainFunctionSystem.OnWardrobeCallBack,
	[FunctionStartIdCode.ZhenCangGe] = LuaMainFunctionSystem.OnZhenCangGeCallBack,
	[FunctionStartIdCode.DuiBaoDian] = LuaMainFunctionSystem.OnDuiBaoDianCallBack,
	[FunctionStartIdCode.CrazySat] = LuaMainFunctionSystem.OnCrazySatCallBack,
	[FunctionStartIdCode.ThaiShareGroup] = LuaMainFunctionSystem.OnThaiShareGroupCallBack,
	[FunctionStartIdCode.Calendar] = LuaMainFunctionSystem.OnCalendarCallBack,
	[FunctionStartIdCode.Player] = LuaMainFunctionSystem.OnPlayerCallBack,
	[FunctionStartIdCode.Propetry] = LuaMainFunctionSystem.OnPropetryCallBack,
	[FunctionStartIdCode.TJLBase] = LuaMainFunctionSystem.OnTianJinLingBaseCallBack,
	[FunctionStartIdCode.RankAward] = LuaMainFunctionSystem.OnRankAwardCallBack,
	[FunctionStartIdCode.FuDiLjRnak] = LuaMainFunctionSystem.OnFuDiLjRnakCallBack,
	[FunctionStartIdCode.FuDiLj] = LuaMainFunctionSystem.OnFuDiLjCallBack,

	[FunctionStartIdCode.MainFuncRoot] = LuaMainFunctionSystem.OnMainFuncRootCallBack,
	[FunctionStartIdCode.Bag] = LuaMainFunctionSystem.OnBagCallBack,
	[FunctionStartIdCode.BagSub] = LuaMainFunctionSystem.OnBagCallBack,
	[FunctionStartIdCode.GameSetting] = LuaMainFunctionSystem.OnGameSettingCallBack,
	[FunctionStartIdCode.SystemSetting] = LuaMainFunctionSystem.OnSystemSettingCallBack,
	[FunctionStartIdCode.Feedback] = LuaMainFunctionSystem.OnGameFeedbackCallBack,
	[FunctionStartIdCode.Sociality] = LuaMainFunctionSystem.OnSocialityCallBack,
	[FunctionStartIdCode.Friend] = LuaMainFunctionSystem.OnFriendCallBack,
	[FunctionStartIdCode.Mail] = LuaMainFunctionSystem.OnMailCallBack,
	[FunctionStartIdCode.AreaMap] = LuaMainFunctionSystem.OnAreaMapCallBack,
	[FunctionStartIdCode.Team] = LuaMainFunctionSystem.OnTeamCallBack,
	[FunctionStartIdCode.TeamInfo] = LuaMainFunctionSystem.OnTeamInfoCallBack,
	[FunctionStartIdCode.TeamMatch] = LuaMainFunctionSystem.OnTeamMatchCallBack,
	[FunctionStartIdCode.Arena] = LuaMainFunctionSystem.OnArenaCallBack,
	[FunctionStartIdCode.ArenaShouXi] = LuaMainFunctionSystem.OnArenaShouXiCallBack,
	[FunctionStartIdCode.ArenaRank] = LuaMainFunctionSystem.OnArenaRankCallBack,
	[FunctionStartIdCode.ArenaReward] = LuaMainFunctionSystem.OnArenaRewardCallBack,
	[FunctionStartIdCode.ArenaFightInfo] = LuaMainFunctionSystem.OnArenaFightInfoCallBack,
	[FunctionStartIdCode.DailyActivity] = LuaMainFunctionSystem.OnDailyActivityCallBack,
	[FunctionStartIdCode.PrivateChat] = LuaMainFunctionSystem.OnPrivateChatCallBack,
	[FunctionStartIdCode.Guild] = LuaMainFunctionSystem.OnGuildCallBack,
	[FunctionStartIdCode.GuildCreate] = LuaMainFunctionSystem.OnGuildCreateCallBack,
	[FunctionStartIdCode.GuildTabBaseInfo] = LuaMainFunctionSystem.OnGuildTabBaseInfoCallBack,
	[FunctionStartIdCode.GuildBuild] = LuaMainFunctionSystem.OnGuildBuildCallBack,
	[FunctionStartIdCode.GuildTabGuildList] = LuaMainFunctionSystem.OnGuildTabGuildListCallBack,
	[FunctionStartIdCode.GuildBoss] = LuaMainFunctionSystem.OnGuildBossCallBack,
	[FunctionStartIdCode.GuildWar] = LuaMainFunctionSystem.OnGuildWarCallBack,
	[FunctionStartIdCode.GuildFuncTypeBox] = LuaMainFunctionSystem.OnGuildBoxCallBack,
	[FunctionStartIdCode.GuildTabRedPackage] = LuaMainFunctionSystem.OnGuildRedPackageCallBack,
	[FunctionStartIdCode.OnHookForm] = LuaMainFunctionSystem.OnOnHookFormCallBack,
	[FunctionStartIdCode.OnHookSettingForm] = LuaMainFunctionSystem.OnOnHookSettingFormCallBack,
	[FunctionStartIdCode.FuDi] = LuaMainFunctionSystem.OnFuDiCallBack,
	[FunctionStartIdCode.FuDiRank] = LuaMainFunctionSystem.OnFuDiRankCallBack,
	[FunctionStartIdCode.FuDiBoss] = LuaMainFunctionSystem.OnFuDiBossCallBack,
	[FunctionStartIdCode.FuDiShop] = LuaMainFunctionSystem.OnFuDiShopCallBack,
	[FunctionStartIdCode.RoleTitle] = LuaMainFunctionSystem.OnRoleTitleCallBack,
	[FunctionStartIdCode.ServeCrazy] = LuaMainFunctionSystem.OnServeCrazyCallBack,
	[FunctionStartIdCode.GrowthWay] = LuaMainFunctionSystem.OnGrowthWayCallBack,
	[FunctionStartIdCode.ServerActive] = LuaMainFunctionSystem.OnServerActiveCallBack,
	[FunctionStartIdCode.WorldAnser] = LuaMainFunctionSystem.OnWorldAnserCallBack,
	[FunctionStartIdCode.ReCharge] = LuaMainFunctionSystem.OnReChargeCallBack,
	[FunctionStartIdCode.TerritorialWar] = LuaMainFunctionSystem.OnTerritorialWarCallBack,
	[FunctionStartIdCode.TerritorialWarMain] = LuaMainFunctionSystem.OnTerritorialWarMainCallBack,
	[FunctionStartIdCode.TerritorialWarCelebrity] = LuaMainFunctionSystem.OnTerritorialWarCelebrityCallBack,
	[FunctionStartIdCode.ChuanDao] = LuaMainFunctionSystem.OnChuanDaoCallBack,
	[FunctionStartIdCode.Vip] = LuaMainFunctionSystem.OnVipCallBack,
	[FunctionStartIdCode.Chat] = LuaMainFunctionSystem.OnChatCallBack,
	[FunctionStartIdCode.WorldSupport] = LuaMainFunctionSystem.OnWorldSupportCallBack,
	[FunctionStartIdCode.FlySwordMandate] = LuaMainFunctionSystem.OnFlySwordMandateCallBack,
	[FunctionStartIdCode.LookOtherPlayer] = LuaMainFunctionSystem.OnLookOtherPlayerCallBack,
	[FunctionStartIdCode.Screen] = LuaMainFunctionSystem.OnScreenCallBack,
	[FunctionStartIdCode.InviteTeam] = LuaMainFunctionSystem.OnInviteTeamCallBack,
	[FunctionStartIdCode.TalkToNPC] = LuaMainFunctionSystem.OnTalkToNPCCallBack,
	[FunctionStartIdCode.CrossFuDi] = LuaMainFunctionSystem.OnCrossFuDiCallBack,
	[FunctionStartIdCode.PlayerSkillXinFa] = LuaMainFunctionSystem.OnPlayerSkillXinFaCallBack,
	[FunctionStartIdCode.BianQiang] = LuaMainFunctionSystem.OnBianQiangCallBack,
	[FunctionStartIdCode.PlayerJingJie] = LuaMainFunctionSystem.OnPlayerJingJieCallBack,
	[FunctionStartIdCode.KaosOrder] = LuaMainFunctionSystem.OnKaosOrderCallBack,
	[FunctionStartIdCode.FengMoTai] = LuaMainFunctionSystem.OnFengMoTaiCallBack,
	[FunctionStartIdCode.DevilSoulMain] = LuaMainFunctionSystem.OnDevilSoulMainCallBack,
	[FunctionStartIdCode.DevilSoulBag] = LuaMainFunctionSystem.OnDevilSoulBagCallBack,
	[FunctionStartIdCode.DevilSoulSurmount] = LuaMainFunctionSystem.OnDevilSoulSurmountCallBack,
	[FunctionStartIdCode.DevilSoulSynth] = LuaMainFunctionSystem.OnDevilSoulSynthCallBack,
	[FunctionStartIdCode.Community] = LuaMainFunctionSystem.OnCommunityCallBack,
	[FunctionStartIdCode.PrefectRomance] = LuaMainFunctionSystem.OnPrefectRomanceCallBack,
	[FunctionStartIdCode.PrefectSpouse] = LuaMainFunctionSystem.OnPrefectSpouseCallBack,
	[FunctionStartIdCode.PrefectTask] = LuaMainFunctionSystem.OnPrefectTaskCallBack,
	[FunctionStartIdCode.PrefectGift] = LuaMainFunctionSystem.OnPrefectGiftCallBack,
	[FunctionStartIdCode.PrefectPack] = LuaMainFunctionSystem.OnPrefectPackCallBack,
	[FunctionStartIdCode.OyLieKai] = LuaMainFunctionSystem.OnOyLieKaiCallBack,
	[FunctionStartIdCode.TreasureWuyou] = LuaMainFunctionSystem.OnTreasureWuyouCallBack,
	[FunctionStartIdCode.ChaoZhi] = LuaMainFunctionSystem.OnChaoZhiCallBack,
	[FunctionStartIdCode.Decorate] = LuaMainFunctionSystem.OnDecorateCallBack,
	[FunctionStartIdCode.PreviewXinFa] = LuaMainFunctionSystem.OnPreviewXinFaCallBack,
	[FunctionStartIdCode.TaskDaily] = LuaMainFunctionSystem.OnDailyTaskCallBack,
	[FunctionStartIdCode.VipInvationNormal] = LuaMainFunctionSystem.OnVipInvationNorCallBack,
	[FunctionStartIdCode.VipInvationZunGui] = LuaMainFunctionSystem.OnVipInvationZbCallBack,
	[FunctionStartIdCode.VipBaoZhuJiHuo] = LuaMainFunctionSystem.OnVipBaoZhuJiHuoCallBack,
	[FunctionStartIdCode.ToDayFunc] = LuaMainFunctionSystem.OnToDayFuncCallBack,
	[FunctionStartIdCode.LoversFight] = LuaMainFunctionSystem.OnLoversFightFuncCallBack,
	[FunctionStartIdCode.LoversFreeFight] = LuaMainFunctionSystem.OnLoversFightFreeFuncCallBack,
	[FunctionStartIdCode.LoversGroupFight] = LuaMainFunctionSystem.OnLoversFightGroupFuncCallBack,
	[FunctionStartIdCode.LoversTopFight] = LuaMainFunctionSystem.OnLoversFightTopFuncCallBack,
	[FunctionStartIdCode.LoversPickFight] = LuaMainFunctionSystem.OnLoversFightPickFuncCallBack,
	[FunctionStartIdCode.AttachEquip] = LuaMainFunctionSystem.OnAttachFuncCallBack,
	[FunctionStartIdCode.UnrealEquip] = LuaMainFunctionSystem.OnUnrealEquipFuncCallBack,
	[FunctionStartIdCode.UnrealEquipSoul] = LuaMainFunctionSystem.OnUnrealEquipSoulFuncCallBack,
	[FunctionStartIdCode.UnrealEquipSync] = LuaMainFunctionSystem.OnUnrealEquipSyncFuncCallBack,
	[FunctionStartIdCode.CustomHead] = LuaMainFunctionSystem.OnCustomHeadFunCallBack,
	[FunctionStartIdCode.V4HelpBase] = LuaMainFunctionSystem.OnV4HelpBaseFunCallBack,
	[FunctionStartIdCode.VIPHelp] = LuaMainFunctionSystem.OnVIPHelpFunCallBack,
	[FunctionStartIdCode.V4Rebate] = LuaMainFunctionSystem.OnV4RebateFunCallBack,
	[FunctionStartIdCode.RebateBox] = LuaMainFunctionSystem.OnRebateBoxFunCallBack,
	[FunctionStartIdCode.XMZhengBa] = LuaMainFunctionSystem.OnXMZhengBaFunCallBack,
	[FunctionStartIdCode.OfflineFind] = LuaMainFunctionSystem.OnOfflineFindFunCallBack,
	[FunctionStartIdCode.SpecialShop] = LuaMainFunctionSystem.OnSpecialShopCallBack,
	[FunctionStartIdCode.OrbShop] = LuaMainFunctionSystem.OnOrbShopCallBack,
	[FunctionStartIdCode.Escort] = LuaMainFunctionSystem.OnEscortCallBack,
	[FunctionStartIdCode.EscortMap] = LuaMainFunctionSystem.OnEscortMapCallBack,
	[FunctionStartIdCode.TrainBOSSMap] = LuaMainFunctionSystem.OnTrainBOSSMapCallBack,
	[FunctionStartIdCode.PrisonMap] = LuaMainFunctionSystem.OnPrisonMapCallBack,
	-- [FunctionStartIdCode.TaskDailyPrison] = LuaMainFunctionSystem.OnDailyPrisonTaskCallBack,
}

local prisonAllowFunctionStartkMap = {
	[FunctionStartIdCode.Pay] = true,
	[FunctionStartIdCode.GameSetting] = true,
	[FunctionStartIdCode.ExitRewardTips] = true,
}

-- Open the corresponding function through the enumeration code of the function ID
function LuaMainFunctionSystem:DoFunctionCallBack(code, param)
	-- Debug.Log("LuaMainFunctionSystem:DoFunctionCallBack "..tostring(code))
	
	-- Block when in prison
	local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
	if _lp == nil then return end
	if _lp.IsInPrison then
		if prisonAllowFunctionStartkMap[code] == nil then
			Utils.ShowPromptByEnum("CANNOT_TRANS_BY_TASK_BLOCK")
			return
		end
	end
	
	-- Callback function
	local _callBack = functionStartkMap[code]
	if _callBack then
		_callBack(param)
	else
		Debug.LogError(string.format("LuaMainFunctionSystem:DoFunctionCallBack(%d) not implement!", code))
	end
end

-- The display function is not enabled prompt
function LuaMainFunctionSystem:ShowFuncNotOpenTips(code)
	-- Debug.Log("yy ShowFuncNotOpenTips "..tostring(code))
	if code == FunctionStartIdCode.MainFuncRoot then
		return
	end
	if code == FunctionStartIdCode.CustomHead then
		-- The custom avatar does not pop up
		return
	end
	if code == FunctionStartIdCode.AreaMap then
        Utils.ShowPromptByEnum("C_COPYMAP_CANNOTOPENMINIMAP")
		return
	end
	local _funcData = GameCenter.MainFunctionSystem:GetFunctionInfo(code);
	local _funcCfg = DataConfig.DataFunctionStart[code]
	local _curMapCfg = GameCenter.MapLogicSystem.MapCfg
	if _funcData == nil or _funcCfg == nil or _curMapCfg == nil then
		return
	end

	Debug.Log("ShowFuncNotOpenTips funId=" .. tostring(code) .. " funcName=" .. tostring(_funcCfg.FunctionName))

	if _funcData.IsEnable and not _funcData.FuncationInCross and _curMapCfg ~= nil and _curMapCfg.MapType ~= 0 then
		Utils.ShowPromptByEnum("C_CROSS_CANNOT_USE_FUNCTION", _funcCfg.FunctionName)
		return
	end
	local _showNormalPrompt = true
	local _startParamsArray = Utils.SplitStrByTableS(_funcCfg.StartVariables, {';', '_'})
	if #_startParamsArray > 0 and #_startParamsArray[1] > 1 then
		if _funcData.ID == FunctionStartIdCode.FuDi or
			_funcData.ID == FunctionStartIdCode.FuDiRank or
			_funcData.ID == FunctionStartIdCode.FuDiBoss or
			_funcData.ID == FunctionStartIdCode.FuDiLj or
			_funcData.ID == FunctionStartIdCode.FuDiShop or
			_funcData.ID == FunctionStartIdCode.FuDiLjRnak then
			-- Special processing of functions of Blessings series
			_showNormalPrompt = false
			Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", _funcCfg.FunctionName)
			return
		end
		if #_startParamsArray > 1 then
			local _type = _startParamsArray[1][1]
			local _value = _startParamsArray[1][2]

			local _typeDay = _startParamsArray[2][1]
			local _valueDay = _startParamsArray[2][2]

			if _type == FunctionVariableIdCode.PlayerLevel and _typeDay == FunctionVariableIdCode.Sever_Open_Day then
				if _value < 1000 then
					_showNormalPrompt = false;
					Utils.ShowPromptByEnum("C_FUNCTIONOPENNEED_LEVEL_SERVER_OPEN_DAY", _funcCfg.FunctionName, CommonUtils.GetLevelDesc(_value), _valueDay)
				end
			end
		else
			local _type = _startParamsArray[1][1]
			local _value = _startParamsArray[1][2]
			if _type == FunctionVariableIdCode.PlayerLevel then
				local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
				if _value < 1000 and _value > _lpLevel then
					_showNormalPrompt = false;
					Utils.ShowPromptByEnum("C_FUNCTIONOPENNEED_LEVEL", _funcCfg.FunctionName, CommonUtils.GetLevelDesc(_value))
				end
			elseif _type == FunctionVariableIdCode.PlayerTaskID then
				local _task = DataConfig.DataTask[_value]
				if _value ~= nil and not GameCenter.LuaTaskManager:IsMainTaskOver(_value) then
					_showNormalPrompt = false;
					Utils.ShowPromptByEnum("C_FUNCTIONOPENNEED_TASK", _funcCfg.FunctionName, _task.TaskName)
				end
			end
		end
	end
	if _funcData.ID == FunctionStartIdCode.EscortMap then
		_showNormalPrompt = false
		Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", _funcCfg.FunctionName)
		return
	end
	if _showNormalPrompt then
		Utils.ShowPromptByEnum("C_MAIN_GONGNENGWEIKAIQI", _funcCfg.FunctionName)
	end
end

-- Callback when function is turned on
function LuaMainFunctionSystem:OnFunctionOpened(code, isNew)
	local _code = code
	if _code == FunctionStartIdCode.GrowthPlan then
	elseif _code == FunctionStartIdCode.PetProSoul then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Pet)
	elseif _code == FunctionStartIdCode.NatureWing then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Wing)
	elseif _code == FunctionStartIdCode.NatureTalisman then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Talisman)
	elseif _code == FunctionStartIdCode.NatureMagic then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Magic)
	elseif _code == FunctionStartIdCode.NatureWeapon then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Weapon)
	elseif _code == FunctionStartIdCode.MountBase then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.Mount)
	elseif _code == FunctionStartIdCode.FaBaoHuaxing then
		GameCenter.NatureSystem:ReqNatureInfo(NatureEnum.FaBao)
	elseif _code == FunctionStartIdCode.CopyMap then
		-- Send a message to get a copy of the challenge
		GameCenter.CopyMapSystem:ReqOpenChallengePanel();
	elseif _code == FunctionStartIdCode.PlayerJingJie then
		GameCenter.PlayerShiHaiSystem:ReqShiHaiData();
	elseif _code == FunctionStartIdCode.OnHookSettingForm then
		GameCenter.OfflineOnHookSystem:ReqHookSetInfo()
	elseif _code == FunctionStartIdCode.FashionableBase then
	elseif _code == FunctionStartIdCode.TowerCopyMap then
		-- Tower climbing copy
		GameCenter.CopyMapSystem:ReqOpenChallengePanel();
	elseif _code == FunctionStartIdCode.StarCopyMap then
		-- Star Copy
		GameCenter.CopyMapSystem:ReqOpenStarPanel();
	elseif _code == FunctionStartIdCode.TJZMCopyMap then
		-- The Gate of Heaven
		GameCenter.CopyMapSystem:ReqOpenTJZMPanel();
	elseif _code == FunctionStartIdCode.ExpCopyMap then
		-- Copy of experience
		GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.ExpCopyID);
	elseif _code == FunctionStartIdCode.XinMoCopyMap then
		-- Demon copy
		GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.XinMoCopyID);
	elseif _code == FunctionStartIdCode.WuXingCopyMap then
		-- Five Elements Copy
		GameCenter.CopyMapSystem:ReqOpenManyCopyPanel(GameCenter.CopyMapSystem.WuXingCopyID);
	elseif _code == FunctionStartIdCode.FirstCharge then
	elseif _code == FunctionStartIdCode.ReCharge then
		GameCenter.FristChargeSystem.RechargeOpen = true
	elseif _code == FunctionStartIdCode.RealmStifle then
		-- Spiritual Pressure System
		GameCenter.RealmStifleSystem:ReqOpenPanel();
	elseif _code == FunctionStartIdCode.Arena then
		-- Get data for the first reward
		GameCenter.ArenaShouXiSystem:ReqGetFirstReward();
	elseif _code == FunctionStartIdCode.StatureBoss then
		local _msg = ReqMsg.MSG_copyMap.ReqOpenBossStatePanle:New()
		_msg:Send()
	elseif _code == FunctionStartIdCode.TerritorialWar then
		GameCenter.TerritorialWarSystem:OnCrossDay()
		-- GameCenter.TerritorialWarSystem:OpenPanel()
	elseif _code == FunctionStartIdCode.Guild then
		GameCenter.Network.Send("MSG_Guild.ReqGuildInfo", {})
	elseif _code == FunctionStartIdCode.GodIsland then
		GameCenter.SoulMonsterSystem:ReqSoulAnimalForestCrossPanel()
	elseif _code == FunctionStartIdCode.EquipSmelt then
		local _cfg = DataConfig.DataGlobal[GlobalName.Smelt_equip_auto_level]
		-- Set VIP level
		local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
		if lp ~= nil and _cfg then
			local _needVipLevel = tonumber(_cfg.Params)
			if lp.VipLevel >= _needVipLevel and GameCenter.VipSystem.BaoZhuState ~= 0 then
				local _msg = ReqMsg.MSG_Recycle.ReqSetAuto:New()
				_msg.isOpen = true
				_msg:Send()
			end
		end
	elseif _code == FunctionStartIdCode.EquipSmeltMain and isNew then
		PlayerPrefs.SetInt("EquipSmeltOccCheck", 0)
		PlayerPrefs.Save()
	elseif _code == FunctionStartIdCode.WorldBoss then
		GameCenter.Network.Send("MSG_Boss.ReqNoobBossPannel", {})
		GameCenter.BossSystem:ReqAllWorldBossInfo(BossType.WorldBoss)
		GameCenter.BossSystem:ReqSuitBossInfo()
	elseif _code == FunctionStartIdCode.BossHome then
		-- Request boss home data
		GameCenter.BossSystem:ReqAllWorldBossInfo(BossType.NewBossHome)
	elseif _code == FunctionStartIdCode.TrainBoss then
		-- Request train boss data
		GameCenter.BossSystem:ReqAllWorldBossInfo(BossType.TrainBoss)
	elseif _code == FunctionStartIdCode.Certification and GameCenter.SDKSystem:IsRealNameAuthorized() then
		GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.Certification, false)
	elseif _code == FunctionStartIdCode.WelfareLoginGift then
		GameCenter.WelfareSystem.LoginGift:RefreshLittleName();
	elseif _code == FunctionStartIdCode.FlySwordGrave then
		GameCenter.Network.Send("MSG_HuaxinFlySword.ReqSwordTombPannel", {})
	elseif _code == FunctionStartIdCode.ArenaTop then
		GameCenter.Network.Send("MSG_Peak.ReqPeakInfo", {})
		GameCenter.Network.Send("MSG_Peak.ReqPeakStageInfo", {})
	elseif _code == FunctionStartIdCode.ArenaShouXi then
		GameCenter.ArenaShouXiSystem:ReqOpenJJC()
		GameCenter.Network.Send("MSG_JJC.ReqGetYesterdayRank", {})
	elseif _code == FunctionStartIdCode.FlySwordMandate then
		GameCenter.Network.Send("MSG_HuaxinFlySword.ReqSwordSoulPannel", {})
	elseif _code == FunctionStartIdCode.MountECopy then
		local _req = ReqMsg.MSG_CrossHorseBoss.ReqCrossHorseBossPanel:New()
		_req.level = 1
		_req:Send()
	elseif _code == FunctionStartIdCode.Pay then
		GameCenter.SDKSystem:DownLoadPayList();
	elseif _code == FunctionStartIdCode.XJXunbao then
		GameCenter.XJXunbaoSystem.XJXunbaoOpen = true
	elseif _code == FunctionStartIdCode.TreasureWuyou then
		local _msg = ReqMsg.MSG_TreasureHuntWuyou.ReqOpenPanel:New()
		_msg:Send()
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.TreasureWuyou, false)
	elseif _code == FunctionStartIdCode.Slayer then
		local _req = ReqMsg.MSG_DevilSeries.ReqOpenDeviBossPanel:New()
		_req:Send()
	elseif _code == FunctionStartIdCode.DailyActivity then
		-- Request daily data
		GameCenter.DailyActivitySystem:ReqActivePanel()
	end
end

-- Set delayed on function
function LuaMainFunctionSystem:SetDelayOpenFunc(funcId, delayFrameCount)
	self.DelayOpenFuncId = funcId
	self.DelayOpenFrameCount = delayFrameCount
end

function LuaMainFunctionSystem:Update(deltaTime)
	if self.DelayOpenFuncId ~= nil then
		self.DelayOpenFrameCount = self.DelayOpenFrameCount - 1
		if self.DelayOpenFrameCount <= 0 then
			self:DoFunctionCallBack(self.DelayOpenFuncId, nil)
			self.DelayOpenFuncId = nil
		end
	end
end

return LuaMainFunctionSystem
