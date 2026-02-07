--==============================--
--Author: [name]
-- Date: 2020-11-02 17:08:28
-- File: UIPlayerPropetryForm.lua
-- Module: UIPlayerPropetryForm
-- Description: Role Attribute Interface
--==============================--
local PlayerStatEnum = require "Logic.PlayerStat.PlayerStatEnum"
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local L_AllBattleProp = CS.Thousandto.Code.Global.AllBattleProp
local L_PopupAttAdvanced = require("UI.Forms.UIPlayerPropetryForm.PopupAttAdvanced")
local L_PopupConfirmResetStats = require("UI.Forms.UIPlayerPropetryForm.PopupConfirmResetStats")

local EPlayerStat = PlayerStatEnum.Stat
local EPlayerStatReason = PlayerStatEnum.Reason
local statMapUI = {
    [EPlayerStat.Strength]     = "SM",
    [EPlayerStat.Agility]      = "NN",
    [EPlayerStat.Vitality]     = "TC",
    [EPlayerStat.Intelligence] = "TT"
}

local UIPlayerPropetryForm = {
    StatUI              = Dictionary:New(),
    BaseDataList        = nil, -- NOTE(TL): Not used
    SpecialDataList     = nil, -- NOTE(TL): Not used
    BaseAttrDataList    = List:New(),
    SpecialAttrDataList = List:New(),
}

--Register event function, provided to the CS side to call.
function UIPlayerPropetryForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UIPlayerPropetryForm_OPEN, self.OnOpen);
    self:RegisterEvent(UILuaEventDefine.UIPlayerPropetryForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnBaseProChanged)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BATTLE_ATTR_CHANGED, self.OnBattleProChanged)

    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_PLAYERSTAT_UPDATE, self.OnStatUpdate)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_GOSU_PK_POINT, self.UpdatePKPoint)
end

function UIPlayerPropetryForm:OnOpen(object, sender)
    self.CSForm:OnOpen(object, sender);
end

--The first display function is provided to the CS side to call.
function UIPlayerPropetryForm:OnFirstShow()
    --self.BaseDataList = {};
    --self.SpecialDataList = {};
    self.BaseAttrDataList = List:New();
    self.SpecialAttrDataList = List:New();
    local _func1 = function(_, v)
        if v.Hidden == 1 then
            self.BaseAttrDataList:Add(v)
        elseif v.Hidden == 2 then
            self.SpecialAttrDataList:Add(v)
        end
    end
    DataConfig.DataAttributeAdd:Foreach(_func1)
    local attrSorting = function(a, b)
        return a.Sorting < b.Sorting;
    end
    self.BaseAttrDataList:Sort(attrSorting);
    self.SpecialAttrDataList:Sort(attrSorting);
    --[[table.sort(self.BaseDataList, function(a, b)
        return a.Sorting < b.Sorting;
    end)
    table.sort(self.SpecialDataList, function(a, b)
        return a.Sorting < b.Sorting;
    end)]]

    self:FindAllComponents();
    self:RegUICallback()

    self.FormatId = DataConfig.DataMessageString.GetStringDefineId("PlayerPropetry_MaoHao");
    local _rightTrans = UIUtils.FindTrans(self.Trans, "Right")
    self.CSForm:AddAlphaPosAnimation(_rightTrans, 0, 1, 50, 0, 0.3, true, false)
end

--Find all components
function UIPlayerPropetryForm:FindAllComponents()
    local _myTrans = self.Trans;
    self.TexBg = UIUtils.FindTex(_myTrans, "Left/TexBg");
    --left
    --- Button
    self.PKBtn = UIUtils.FindBtn(_myTrans, "Left/SKIcon")
    UIUtils.AddBtnEvent(self.PKBtn, self.PKBtnClick, self) -- hiện gameobject OpenSKpanel là con của LKIcon
    self.PKPointCount = UIUtils.FindLabel(_myTrans, "Left/SKIcon/Label")
    self.PKCloseBtn = UIUtils.FindBtn(_myTrans, "Left/SKIcon/OpenSKpanel/CloseBtn")
    UIUtils.AddBtnEvent(self.PKCloseBtn, self.OnPKCloseBtnClick, self)
    -- Panel con
    self.OpenSKpanel = UIUtils.FindGo(_myTrans, "Left/SKIcon/OpenSKpanel")

    self.PkDesLabel = UIUtils.FindLabel(_myTrans, "Left/SKIcon/OpenSKpanel/ScrollView/SKDes")



    self.UIRoleSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_myTrans, "Left/UIRoleSkinCompoent"));
    self.UIRoleSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player, "idle")

    self.BtnTitle = UIUtils.FindBtn(_myTrans, "Left/BtnTitle");
    self.BtnTitle.gameObject:SetActive(true)
    self.GoTitleRedPoint = UIUtils.FindGo(_myTrans, "Left/BtnTitle/RedPoint");
    self.BtnGemAttr = UIUtils.FindBtn(_myTrans, "Left/BtnGemAttr");
    self.BtnGemAttr.gameObject:SetActive(true)
    self.TxtFightValue = UIUtils.FindLabel(_myTrans, "Left/FightPower/TxtValue");
    UIUtils.AddBtnEvent(self.BtnTitle, self.OnClickBtnTitleCallBack, self);
    UIUtils.AddBtnEvent(self.BtnGemAttr, self.OnClickBtnGemAttrCallBack, self);
    --right
    self.UIPlayerHead = PlayerHead:New(UIUtils.FindTrans(_myTrans, "Right/Head"))
    self.HeadBtn = UIUtils.FindBtn(_myTrans, "Right/Head")
    UIUtils.AddBtnEvent(self.HeadBtn, self.OnClickBtnChangeHeadCallBack, self);

    self.TxtName = UIUtils.FindLabel(_myTrans, "Right/Name");
    self.BtnChangeName = UIUtils.FindBtn(_myTrans, "Right/ChangeNameBtn");
    UIUtils.AddBtnEvent(self.BtnChangeName, self.OnClickBtnChangeNameCallBack, self);
    --Level
    self.GoVip = UIUtils.FindGo(_myTrans, "Right/Vip");
    self.TxtVip = UIUtils.FindLabel(_myTrans, "Right/Vip/TxtVip");
    self.TxtLpLevel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Right/Level"))
    --EXP
    self.TxtExpValue = UIUtils.FindLabel(_myTrans, "Right/Exp/TxtValue");
    self.BtnExpAddition = UIUtils.FindBtn(_myTrans, "Right/Exp/ExpAdditionBtn");
    UIUtils.AddBtnEvent(self.BtnExpAddition, self.OnClickBtnExpAdditionCallBack, self);
    self.ProgressBar = UIUtils.FindProgressBar(_myTrans, "Right/Exp/ProgressExp")
    self.TxtOcc = UIUtils.FindLabel(_myTrans, "Right/Occ/TxtOcc");
    self.TxtWife = UIUtils.FindLabel(_myTrans, "Right/Wife/TxtWife");
    self.TxtGuild = UIUtils.FindLabel(_myTrans, "Right/Guild/TxtGuild");
    self.TxtServer = UIUtils.FindLabel(_myTrans, "Right/Server/TxtServer");

    --------------------------------------------------------------------------------------------------------------------
    -- Player Stat Panel (TOP Panel)
    local _topTrans = UIUtils.FindTrans(_myTrans, "Right/Top");
    self.CoreHelpBtn = UIUtils.FindBtn(_topTrans, "BtnCoreHelp");
    UIUtils.AddBtnEvent(self.CoreHelpBtn, self.OnClickBtnSpecialHelpCallBack, self);
    self.ConfirmResetStats = L_PopupConfirmResetStats:OnFirstShow(self.CSForm, UIUtils.FindTrans(_topTrans, "ResetComfirm"))
    -- AvailablePoints
    self.TxtTotalPoint = UIUtils.FindLabel(_topTrans, "ValueTotalScore");
    -- UI
    self.StatUI = Dictionary:New()
    for statEnum, prefix in pairs(statMapUI) do
        local ui = {}
        -- Labels
        ui.TxtTitle = UIUtils.FindLabel(_topTrans, string.format("%s/TxtTitle", prefix))
        ui.TxtValue = UIUtils.FindLabel(_topTrans, string.format("%s/Value", prefix))
        ui.TxtAdd = UIUtils.FindLabel(_topTrans, string.format("%s/TxtAdd", prefix))
        -- Buttons
        ui.SubBtn = UIUtils.FindBtn(_topTrans, string.format("%s/UIAddReduce/SubBtn", prefix))
        ui.AddBtn = UIUtils.FindBtn(_topTrans, string.format("%s/UIAddReduce/AddBtn", prefix))
        ui.AddAllBtn = UIUtils.FindBtn(_topTrans, string.format("%s/UIAddReduce/AddAllBtn", prefix))

        self.StatUI[statEnum] = ui
    end
    -- 
    self.ResetAllBtn = UIUtils.FindBtn(_topTrans, "AddAllBtn");
    self.ProposeBtn = UIUtils.FindBtn(_topTrans, "BtnPropose");
    self.ResetBtn = UIUtils.FindBtn(_topTrans, "BtnReset");
    self.ApplyBtn = UIUtils.FindBtn(_topTrans, "BtnApply");
    self.ApplyBtnText = UIUtils.FindLabel(_topTrans, "BtnApply/NormalName");
    --------------------------------------------------------------------------------------------------------------------
    self.BtnBaseHelp = UIUtils.FindBtn(_myTrans, "Right/BtnBaseHelp");
    self.BtnSpecialHelp = UIUtils.FindBtn(_myTrans, "Right/BtnSpecialHelp");
    UIUtils.AddBtnEvent(self.BtnBaseHelp, self.OnClickBtnBaseHelpCallBack, self);
    UIUtils.AddBtnEvent(self.BtnSpecialHelp, self.OnClickBtnSpecialHelpCallBack, self);

    self.BtnAttExpand = UIUtils.FindBtn(_myTrans, "Right/BtnStats");
    UIUtils.AddBtnEvent(self.BtnAttExpand, self.OnClickBtnBtnAttExpandCallBack, self);
    self.PopupAttAdvanced = L_PopupAttAdvanced:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "PopupAttAdvancedTips"))

    --self.TfScrollViewBase = UIUtils.FindTrans(_myTrans, "Right/ScrollViewBase");
    --self.TfGridBase = UIUtils.FindTrans(_myTrans, "Right/ScrollViewBase/Grid");
    --self.TfScrollViewBase.gameObject:SetActive(false)
    --[[self.ItemList1 = List:New();
    for i = 0, self.TfGridBase.childCount - 1 do
        local _item = self:CreatItem(self.TfGridBase:GetChild(i).gameObject, self.TfGridBase, true)
        _item.GobjBg:SetActive(false)
        --_item.GobjBg:SetActive(i%2==1)
        if i % 2 == 1 then
            UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
            UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
        else
            UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
            UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
        end
        self.ItemList1:Add(_item);
    end
    self.GobjUIItemBase1 = self.ItemList1[1].Gobj;]]

    --self.TfScrollViewSpecial = UIUtils.FindTrans(_myTrans, "Right/ScrollViewSpecial");
    --self.TfGridSpecial = UIUtils.FindTrans(_myTrans, "Right/ScrollViewSpecial/Grid");
    --self.TfScrollViewSpecial.gameObject:SetActive(false)
    --[[self.ItemList2 = List:New();
    for i = 0, self.TfGridSpecial.childCount - 1 do
        local _item = self:CreatItem(self.TfGridSpecial:GetChild(i).gameObject, self.TfGridSpecial, true)
        _item.GobjBg:SetActive(false)
        --_item.GobjBg:SetActive(i%2==1)
        if i%2==1 then
            UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
            UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
        else
            UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
            UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
            UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
        end
        self.ItemList2:Add(_item);
    end
    self.GobjUIItemBase2 = self.ItemList2[1].Gobj;]]

    self.TfScrollViewTotal = UIUtils.FindTrans(_myTrans, "Right/ScrollViewTotal");
    self.TfGridTotal = UIUtils.FindTrans(_myTrans, "Right/ScrollViewTotal/Grid");
    self.TfScrollViewTotal.gameObject:SetActive(true)
    self.ItemList3 = List:New();
    for i = 0, self.TfGridTotal.childCount - 1 do
        local _item = self:CreateSimpleItem(self.TfGridTotal:GetChild(i).gameObject, self.TfGridTotal, true)
        self.ItemList3:Add(_item);
    end
    self.GobjUIItemBase3 = self.ItemList3[1].Gobj;
end

-- Create props
function UIPlayerPropetryForm:CreateItem(gobj, tfParent, isClone)
    local _gobj = isClone and gobj or UnityUtils.Clone(gobj, tfParent);
    local _trans = _gobj.transform;
    return {
        Gobj      = _gobj,
        Trans     = _trans,
        TxtKeyL   = UIUtils.FindLabel(_trans, "TxtKeyL"),
        TxtValueL = UIUtils.FindLabel(_trans, "TxtValueL"),
        TxtKeyR   = UIUtils.FindLabel(_trans, "GobjR/TxtKeyR"),
        TxtValueR = UIUtils.FindLabel(_trans, "GobjR/TxtValueR"),
        GobjR     = UIUtils.FindGo(_trans, "GobjR"),
        GobjBg    = UIUtils.FindGo(_trans, "SprBg"),
    }
end
-- Create props
function UIPlayerPropetryForm:CreateSimpleItem(gobj, tfParent, isClone)
    local _gobj = isClone and gobj or UnityUtils.Clone(gobj, tfParent);
    local _trans = _gobj.transform;
    return {
        Gobj      = _gobj,
        Trans     = _trans,
        TxtKeyL   = UIUtils.FindLabel(_trans, "TxtKeyL"),
        TxtValueL = UIUtils.FindLabel(_trans, "TxtValueL"),
    }
end

--Show the previous operation and provide it to the CS side to call.
function UIPlayerPropetryForm:OnShowBefore()
    self.CSForm:LoadTexture(self.TexBg, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine_1"))
end

--The operation after display is provided to the CS side to call.
function UIPlayerPropetryForm:OnShowAfter()
    self:OnRefresh(true)

    --- Handle Player Stat Panel
    self:OnStatUpdate(EPlayerStatReason.INIT)
    GameCenter.PlayerStatSystem:BeginEdit()

    self:UpdatePKPointIni()

end


function UIPlayerPropetryForm:UpdatePKPointIni()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()

    if not _lp then
        return
    end
    

    local prisonNameId = _lp.PrisonNameId or 0

    local prisonId = Utils.GetPrisonID(prisonNameId)

    local pk = _lp.PointSatKhi or 0

    if self.PKPointCount then
        UIUtils.SetTextByEnum(self.PKPointCount, "SKILL_POINTS_PLAYER", pk)
    end

    if self.PkDesLabel then
        UIUtils.SetTextByEnum(self.PkDesLabel, "KILLPOINTS", pk, prisonId)
    end
    

end

-- function UIPlayerPropetryForm:GetPrisonID(state)
    
--     if(state ~= nil and tonumber(state) > 0) then
--         return state;
--     else
--         return DataConfig.DataMessageString.Get("NOT_GRANTED") or "----"
--     end

-- end


-- Update PK Point

function UIPlayerPropetryForm:UpdatePKPoint(obj, sender)
    local lp = GameCenter.GameSceneSystem:GetLocalPlayer()


    if not lp then
        return
    end

    local prisonNameId = _lp.PrisonNameId or 0

    local prisonId = Utils.GetPrisonID(prisonNameId)

    local pkPoint = lp.PointSatKhi or 0

    if self.PkDesLabel then
        UIUtils.SetTextByEnum(self.PkDesLabel, "KILLPOINTS", pkPoint, prisonId)
    end
end



--Hide previous operations and provide them to the CS side to call.
function UIPlayerPropetryForm:OnHideBefore()
    self.UIRoleSkin:ResetSkin()
end

--The hidden operation is provided to the CS side to call.
function UIPlayerPropetryForm:OnHideAfter()
    self.UIRoleSkin:ResetSkin()
end

function UIPlayerPropetryForm:RegUICallback()
    self.StatUI:Foreach(function(statEnum, ui)
        UIUtils.AddBtnEvent(ui.SubBtn, self.SubStatOnClick, self, statEnum)
        UIUtils.AddBtnEvent(ui.AddBtn, self.AddStatOnClick, self, statEnum)
        UIUtils.AddBtnEvent(ui.AddAllBtn, self.MaxStatOnClick, self, statEnum)
    end)

    UIUtils.AddBtnEvent(self.ResetAllBtn, self.OnResetStatClick, self)
    UIUtils.AddBtnEvent(self.ProposeBtn, self.OnSuggestStatClick, self)
    UIUtils.AddBtnEvent(self.ResetBtn, self.OnRollbackStatClick, self)
    UIUtils.AddBtnEvent(self.ApplyBtn, self.OnConfirmStatClick, self)
end

------------------------------------------------------------------------------------------------------------------------
--region Handle Player Stat
-- ---------------------------------------------------------------------------------------------------------------------
function UIPlayerPropetryForm:OnStatUpdate(reason)
    --- Refresh
    self:HandleRefreshStatLabel()
    self:HandleRefreshStatButton()
end

function UIPlayerPropetryForm:HandleRefreshStatLabel()
    local statSys = GameCenter.PlayerStatSystem

    UIUtils.SetTextByString(self.TxtTotalPoint, statSys:GetRemainingPoints())
    self.StatUI:Foreach(function(statEnum, ui)
        local baseVal, _, diffVal = statSys:GetStatInfo(statEnum)
        if ui.TxtValue then
            UIUtils.SetTextByString(ui.TxtValue, baseVal)
        end
        if ui.TxtAdd then
            UIUtils.SetTextByString(ui.TxtAdd, string.format("%+d", diffVal))
        end
    end)
end

function UIPlayerPropetryForm:HandleRefreshStatButton()
    local statSys = GameCenter.PlayerStatSystem

    self.StatUI:Foreach(function(statEnum, ui)
        ui.SubBtn.isEnabled = statSys:CanSubStat(statEnum)
        ui.AddBtn.isEnabled = statSys:CanAddStat(statEnum)
        ui.AddAllBtn.isEnabled = statSys:CanAddStat(statEnum)
    end)

    self.ResetAllBtn.isEnabled = statSys:CanResetAll()
    --
    local remaining = statSys:GetRemainingPoints()
    local hasChanges = statSys:HasPendingChanges()
    self.ProposeBtn.isEnabled = remaining > 0
    self.ResetBtn.isEnabled = hasChanges
    self.ApplyBtn.isEnabled = hasChanges -- or remaining > 0
    UIUtils.SetColorByString(self.ApplyBtnText, self.ApplyBtn.isEnabled and "#252520" or "#FFFEF5")
end
function UIPlayerPropetryForm:PKBtnClick()

    self.OpenSKpanel:SetActive(true)

end

function UIPlayerPropetryForm:OnPKCloseBtnClick()
    self.OpenSKpanel:SetActive(false)
end
function UIPlayerPropetryForm:AddStatOnClick(stat)
    local statSys = GameCenter.PlayerStatSystem
    statSys:AddStat(stat, 1)
end

function UIPlayerPropetryForm:SubStatOnClick(stat)
    local statSys = GameCenter.PlayerStatSystem
    statSys:SubStat(stat, 1)
end

function UIPlayerPropetryForm:MaxStatOnClick(stat)
    local statSys = GameCenter.PlayerStatSystem
    statSys:AddAllToStat(stat)
end

function UIPlayerPropetryForm:OnSuggestStatClick()
    local statSys = GameCenter.PlayerStatSystem
    statSys:AutoDistributeByClass()
end

function UIPlayerPropetryForm:OnRollbackStatClick()
    local statSys = GameCenter.PlayerStatSystem
    statSys:Rollback()
    statSys:BeginEdit()
end

function UIPlayerPropetryForm:OnConfirmStatClick()
    local statSys = GameCenter.PlayerStatSystem
    local _, diffs = statSys:Confirm()
    statSys:SendStatToServer(diffs)
end

function UIPlayerPropetryForm:OnResetStatClick()
    local SHAN_MEN_MAP_ID = 102599 -- Map Thành Phong Châu (map chính)
    local _currMapId = GameCenter.MapLogicSystem.MapCfg.MapId
    if _currMapId ~= SHAN_MEN_MAP_ID then
        -- "Vui lòng quay về Thành Phong Châu để thực hiện tẩy điểm."
        Utils.ShowPromptByEnum('RESET_POINT_NOTICE')
    else
        self.ConfirmResetStats:OnOpen()
        --if not self.ConfirmResetStats.IsVisible then end
    end
end
--endregion Handle Player Stat

function UIPlayerPropetryForm:OnBaseProChanged(prop, sender)
    if prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Name or
            prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Level or
            prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Exp or
            prop.CurrentChangeBasePropType == L_RoleBaseAttribute.GuildName or
            prop.CurrentChangeBasePropType == L_RoleBaseAttribute.VipLevel
    then
        self:OnRefresh(false)
    end
end

function UIPlayerPropetryForm:OnBattleProChanged(prop, sender)
    --prop.CurrentChangeBasePropType == L_AllBattleProp.LingLi
    self:OnRefresh(false)
end

function UIPlayerPropetryForm:OnRefresh(resetScroll)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _lv = _lp.Level
    local _curExp = _lp.CurExp
    local _guildName = _lp.GuildName
    if resetScroll then
        self.UIRoleSkin:ResetRot()
        self.UIRoleSkin:ResetSkin()
        self.UIRoleSkin:SetCameraSize(2.2)
        self.UIRoleSkin:RefreshPlayerSkinModel(_lp.IntOcc, _lp.VisualInfo)
    end
    UIUtils.SetTextByNumber(self.TxtFightValue, _lp.FightPower)

    self.UIPlayerHead:SetLocalPlayer()
    UIUtils.SetTextByString(self.TxtName, _lp.Name)
    -- self.GoVip:SetActive(_lp.VipLevel > 0)
    UIUtils.SetTextByEnum(self.TxtVip, "LIANQI_GEM_CONDITION_VIP", _lp.VipLevel)
    self.TxtLpLevel:SetLevel(_lv, true)

    local _cfgLv = DataConfig.DataCharacters[_lv];
    UIUtils.SetTextByProgress(self.TxtExpValue, _curExp, _cfgLv.Exp, true, 4)
    self.ProgressBar.value = _curExp / _cfgLv.Exp

    local _wifeName = GameCenter.MarriageSystem.SpouseData.Name;
    local _occ = _lp.IntOcc
    if _occ == 0 then
        UIUtils.SetTextByEnum(self.TxtOcc, "XuanJian");
    elseif _occ == 1 then
        UIUtils.SetTextByEnum(self.TxtOcc, "TianYing");
    elseif _occ == 2 then
        UIUtils.SetTextByEnum(self.TxtOcc, "DiZang");
    else
        -- Invalid occupation
        UIUtils.SetTextByString(self.TxtOcc, "Hồng Anh");
    end
    UIUtils.SetTextByString(self.TxtWife, _wifeName and _wifeName or DataConfig.DataMessageString.Get("None"));
    UIUtils.SetTextByString(self.TxtGuild, (_guildName == "" or not _guildName) and DataConfig.DataMessageString.Get("None") or _guildName);
    local _serverName = GameCenter.ServerListSystem:GetCurrentServer().Name;
    UIUtils.SetTextByString(self.TxtServer, _serverName);

    local _propMoudle = _lp.PropMoudle;

    --[[self:SetItems(self.ItemList1, self.BaseDataList, self.GobjUIItemBase1, self.TfGridBase, _propMoudle)
    UIUtils.HideNeedless(self.ItemList1, math.floor((#self.BaseDataList + 1) / 2))
    UnityUtils.GridResetPosition(self.TfGridBase)
    if resetScroll then
        UnityUtils.ScrollResetPosition(self.TfScrollViewBase)
    end]]

    --[[self:SetItems(self.ItemList2, self.SpecialDataList, self.GobjUIItemBase2, self.TfGridSpecial, _propMoudle)
    UIUtils.HideNeedless(self.ItemList2, math.floor((#self.SpecialDataList + 1) / 2))
    UnityUtils.GridResetPosition(self.TfGridSpecial)
    if resetScroll then
        UnityUtils.ScrollResetPosition(self.TfScrollViewSpecial)
    end]]
    self.PopupAttAdvanced:OnUpdateData(self.SpecialAttrDataList, true)
    self:SetItems_SingleColumn(self.ItemList3, self.BaseAttrDataList, self.GobjUIItemBase3, self.TfGridTotal, _propMoudle)
    UIUtils.HideNeedless(self.ItemList3, #self.BaseAttrDataList)
    UnityUtils.GridResetPosition(self.TfGridTotal)
    if resetScroll then
        UnityUtils.ScrollResetPosition(self.TfScrollViewTotal)
    end

    self.GoTitleRedPoint:SetActive(GameCenter.RoleTitleSystem:ShowRed());
end

function UIPlayerPropetryForm:SetItems(itemList, dataList, gobjUIItemBase, tfGridBase, propMoudle)
    for i = 1, #dataList do
        local _dataItem = dataList[i]
        local _index = math.floor((i + 1) / 2);
        local _isLeft = i % 2 == 1;
        local _item = itemList[_index]
        if not _item then
            _item = self:CreateItem(gobjUIItemBase, tfGridBase);
            _item.GobjBg:SetActive(_index % 2 == 0)
            if _index % 2 == 0 then
                UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
                UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
                UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
                UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
            else
                UIUtils.SetColor(_item.TxtKeyL, 1, 0.996, 0.961, 1)
                UIUtils.SetColor(_item.TxtValueL, 1, 0.851, 0.502, 1)
                UIUtils.SetColor(_item.TxtKeyR, 1, 0.996, 0.961, 1)
                UIUtils.SetColor(_item.TxtValueR, 1, 0.851, 0.502, 1)
            end
            itemList:Add(_item);
        end
        _item.Gobj:SetActive(true);
        if _isLeft then
            self:SetItemText(_dataItem, _item.TxtKeyL, _item.TxtValueL, propMoudle)
            _item.GobjR:SetActive(false)
        else
            self:SetItemText(_dataItem, _item.TxtKeyR, _item.TxtValueR, propMoudle)
            _item.GobjR:SetActive(false)
        end
    end
    --Hide and clear the right side if the list has an odd number of elements
    if #dataList % 2 == 1 then
        local lastIndex = math.floor((#dataList + 1) / 2)
        local lastItem = itemList[lastIndex]
        if lastItem and lastItem.GobjR then
            lastItem.GobjR:SetActive(false)
            if lastItem.TxtKeyR then lastItem.TxtKeyR.text = "" end
            if lastItem.TxtValueR then lastItem.TxtValueR.text = "" end
        end
    end
end

function UIPlayerPropetryForm:SetItems_SingleColumn(itemList, dataList, gobjUIItemBase, tfGridBase, propMoudle)
    for i = 1, #dataList do
        local _dataItem = dataList[i]
        local _item = itemList[i]

        if not _item then
            _item = self:CreateSimpleItem(gobjUIItemBase, tfGridBase);
            itemList:Add(_item);
        end
        _item.Gobj:SetActive(true);
        self:SetItemText(_dataItem, _item.TxtKeyL, _item.TxtValueL, propMoudle)
    end
end

function UIPlayerPropetryForm:SetItemText(data, TxtKey, TxtValue, propMoudle)
    UIUtils.SetTextFormatById(TxtKey, self.FormatId, data._Name)
    -- UIUtils.SetTextByString(TxtKey, data.Name);
    if data.Id == 2 then
        UIUtils.SetTextByNumber(TxtValue, propMoudle.MaxHP);
    else
        local _v = propMoudle:GetBattleProp(data.Id);
        if data.ShowPercent == 1 then
            UIUtils.SetTextByPercent(TxtValue, _v / 100)
        else
            UIUtils.SetTextByNumber(TxtValue, _v);
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
--region Interface button callback begin
-- ---------------------------------------------------------------------------------------------------------------------
function UIPlayerPropetryForm:OnClickBtnTitleCallBack()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RoleTitle);
end

function UIPlayerPropetryForm:OnClickBtnGemAttrCallBack()
    -- GameCenter.PushFixEvent(UIEventDefine.UILianQiGemAllAttrForm_OPEN);
    GameCenter.PushFixEvent(UILuaEventDefine.UILianQiStrengthAllAttrForm_OPEN)
end

function UIPlayerPropetryForm:OnClickBtnChangeNameCallBack()
    GameCenter.PushFixEvent(UIEventDefine.UIChangeNameCardForm_OPEN, UIChangeNameCardType.Role);
end

function UIPlayerPropetryForm:OnClickBtnExpAdditionCallBack()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.OnHookSettingForm);
end

function UIPlayerPropetryForm:OnClickBtnChangeHeadCallBack()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.CustomHead);
end

function UIPlayerPropetryForm:OnClickBtnBaseHelpCallBack()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, UnityUtils.GetObjct2Int(FunctionStartIdCode.Propetry));
end

function UIPlayerPropetryForm:OnClickBtnSpecialHelpCallBack()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, UnityUtils.GetObjct2Int(FunctionStartIdCode.Point));
end

function UIPlayerPropetryForm:OnClickBtnBtnAttExpandCallBack()
    if not self.PopupAttAdvanced.IsVisible then
        self.PopupAttAdvanced:OnOpen()
    end
end
--endregion Interface button callback end

return UIPlayerPropetryForm;
