------------------------------------------------
--author:
--Date: 2020-07-08
--File: UIRoleTitleForm.lua
--Module: UIRoleTitleForm
--Description: Title
------------------------------------------------
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local UIRoleTitleForm = {

}

function  UIRoleTitleForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIRoleTitleForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIRoleTitleForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_TITLE_REFRESH_TITLESTATE, self.OnRefreshForm)
end

function UIRoleTitleForm:OnFirstShow()
    self:FindAllComponents()
    self:OnRegUICallBack()
    --Add an animation
    self.CSForm:AddNormalAnimation(0.3)
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIRoleTitleForm:OnShowAfter()
    self:CreatTopAllItems();
    self:RefreshCenterArea(true, true)
    self.CSForm:LoadTexture(self.TexBg2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_81_4"))
    self.CSForm:LoadTexture(self.TexTaizi, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine_1"))
    self.CSForm:LoadTexture(self.Bg_HV, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_onhook_tt"))
end

function UIRoleTitleForm:OnHideBefore()
    self.UISkin:ResetSkin()
    self.AnimTitle:OnDestory()
    self.isShowingPlayer = false;
end

function UIRoleTitleForm:Update(dt)
    self.AnimPlayer:Update(dt)
    -- Countdown to title
    if self.IsCheckTime then
        local _serverTime = GameCenter.HeartSystem.ServerTime
        if _serverTime - self.LastServerTime >= 1 then
            self.LastServerTime = _serverTime
            self:SetTitleTime(self.RemindTime)
        end
    end
end

function UIRoleTitleForm:FindAllComponents()
    local _trans = self.Trans;
    self.BtnClose = UIUtils.FindBtn(_trans, "Center/BtnClose");
    -- self.TexBg = UIUtils.FindTex(_trans, "Center/TexBG")
    self.TexBg2 = UIUtils.FindTex(_trans, "Center/TexBG/TexBG2")
    self.TexTaizi = UIUtils.FindTex(_trans, "Center/TexBG/TexTaizi")
    self.Bg_HV = UIUtils.FindTex(_trans, "Center/TexBG/Bg_HV")
    --left
    self.TitleRoot = UIUtils.FindTrans(_trans, "Left/TitleRoot")
    self.CSForm:AddAlphaScaleAnimation(self.TitleRoot, 0, 1, 2, 2, 1, 1, 0.2, false, false)
    self.TexTitle = UIUtils.FindTex(_trans, "Left/TitleRoot/TexTitle")
    self.TxtRoleName = UIUtils.FindLabel(_trans, "Left/TxtRoleName");
    self.TxtLv = UIUtils.FindLabel(_trans, "Left/TxtLv")
    self.UISkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_trans, "Left/UIRoleSkinCompoent"))
    self.UISkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player)
    self.TxtState = UIUtils.FindLabel(_trans, "Left/TxtState")
    self.AnimTitle = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "Left/TitleRoot/VfxTitle"))
    self.TxtFight = UIUtils.FindLabel(_trans, "Left/TxtFight")
    --right
    self.TxtCondition = UIUtils.FindLabel(_trans, "Right/InfoRoot/TxtCondition")
    self.BtnActive = UIUtils.FindBtn(_trans, "Right/InfoRoot/BtnActive");
    self.BtnDown = UIUtils.FindBtn(_trans, "Right/InfoRoot/BtnDown");
    self.BtnWear = UIUtils.FindBtn(_trans, "Right/InfoRoot/BtnWear");
    self.BtnSource = UIUtils.FindBtn(_trans, "Right/InfoRoot/BtnSource");

    self.TfScrollView_Top = UIUtils.FindTrans(_trans, "Right/ScrollView_T")
    self.TfGrid_Top = UIUtils.FindTrans(_trans, "Right/ScrollView_T/Grid")
    self.TopList = List:New();
    local _count = self.TfGrid_Top.childCount;
    for i=0, _count-1 do
        local _go = self.TfGrid_Top:GetChild(i).gameObject;
        self.TopList:Add(self:CreatTopItem(_go, self.TfGrid_Top, true))
    end
    self.GobjTopItemBase = self.TopList[1].Gobj;

    self.TfScrollView_Center = UIUtils.FindTrans(_trans, "Right/ScrollView_C")
    self.TfGrid_Center = UIUtils.FindTrans(_trans, "Right/ScrollView_C/Grid")
    self.CenterList = List:New();
    _count = self.TfGrid_Center.childCount;
    for i=0, _count-1 do
        local _go = self.TfGrid_Center:GetChild(i).gameObject;
        self.CenterList:Add(self:CreatCenterItem(_go, self.TfGrid_Center, true))
    end
    self.GobjCenterItemBase = self.CenterList[1].Gobj;

    self.TfScrollView_Bottom = UIUtils.FindTrans(_trans, "Right/ScrollView_B")
    self.TfGrid_Bottom = UIUtils.FindTrans(_trans, "Right/ScrollView_B/Grid")
    self.BottomList = List:New();
    _count = self.TfGrid_Bottom.childCount;
    for i=0, _count-1 do
        local _go = self.TfGrid_Bottom:GetChild(i).gameObject;
        self.BottomList:Add(self:CreatBottomItem(_go, self.TfGrid_Bottom, true))
    end
    self.GobjBottomItemBase = self.BottomList[1].Gobj;
end

function UIRoleTitleForm:OnRegUICallBack()
    UIUtils.AddBtnEvent(self.BtnClose, self.OnClose, self)
    UIUtils.AddBtnEvent(self.BtnActive, self.OnClickBtnActive, self)
    UIUtils.AddBtnEvent(self.BtnDown, self.OnClickBtnDown, self)
    UIUtils.AddBtnEvent(self.BtnWear, self.OnClickBtnWear, self)
    UIUtils.AddBtnEvent(self.BtnSource, self.OnClickBtnSource, self)
end

-- Activate button
function UIRoleTitleForm:OnClickBtnActive()
    GameCenter.RoleTitleSystem:ReqActiveTitle(self.CurCenterItem.TitleID)
end
-- Remove button
function UIRoleTitleForm:OnClickBtnDown()
    GameCenter.RoleTitleSystem:ReqDownTitle(GameCenter.RoleTitleSystem.CurrWearTitle.TitleID)
end
-- Wear button
function UIRoleTitleForm:OnClickBtnWear()
    GameCenter.RoleTitleSystem:ReqWearTitle(self.CurCenterItem.TitleID)
end
-- Get the way button
function UIRoleTitleForm:OnClickBtnSource()
    local _cfg = DataConfig.DataTitle[self.CurCenterItem.TitleID]
    if _cfg then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(_cfg.OpenFunc, _cfg.FuncParam)
    end
end

-- Set title status info:GameCenter.RoleTitleSystem.CurrWearTitle
function UIRoleTitleForm:SetTitleState(info)
    if info.TitleID == self.CurCenterItem.TitleID then
        self.RemindTime = info.RemindTime;
        if self.RemindTime then
            if info.RemindTime == 0 then
                self.IsCheckTime = false;
                UIUtils.SetTextByEnum(self.TxtState, "Forevery")
            else
               if info.RemindTime > GameCenter.HeartSystem.ServerTime then
                    self.IsCheckTime = true;
                    self.LastServerTime = GameCenter.HeartSystem.ServerTime;
                    self:SetTitleTime(info.RemindTime)
               else
                    self.IsCheckTime = false;
                    UIUtils.SetTextByEnum(self.TxtState, "DidNotHave")
               end
            end
        else
            UIUtils.SetTextByEnum(self.TxtState, "DidNotHave")
            self.IsCheckTime = false;
        end
    end
end

-- Set the title time
function UIRoleTitleForm:SetTitleTime(remindTime)
    local _day = math.floor( (remindTime - GameCenter.HeartSystem.ServerTime) / 86400 )
    if _day > 0 then
        UIUtils.SetTextByEnum(self.TxtState, "RemainTimeSomeDay", _day)
        return
    end
    local _hour = math.floor( (remindTime - GameCenter.HeartSystem.ServerTime) / 3600 )
    if _hour > 0 then
        UIUtils.SetTextByEnum(self.TxtState, "RemainTimeSomeHour", _hour)
        return
    end
    local _minute = math.floor( (remindTime - GameCenter.HeartSystem.ServerTime) / 60 )
    if _minute > 0 then
        UIUtils.SetTextByEnum(self.TxtState, "RemainTimeSomeMinutes", _minute)
        return
    end
    local _time = remindTime - GameCenter.HeartSystem.ServerTime
    UIUtils.SetTextByEnum(self.TxtState, "RemainTimeSomeSecond", math.floor(_time + 0.5))
end

--Top Group
function UIRoleTitleForm:CreatTopItem(gobj, tfParent, isBase)
    local _gobj = isBase and gobj or UnityUtils.Clone(gobj, tfParent);
    local _tf = _gobj.transform;
    local _m = {
        Gobj = _gobj,
        Trans = _tf,
        TxtNameSelect = UIUtils.FindLabel(_tf, "SprSelect/TxtName"),
        TxtNameUnSelect = UIUtils.FindLabel(_tf, "SprUnSelect/TxtName"),
        GobjRedPoint = UIUtils.FindGo(_tf, "SprRedPoint"),
        GobjSelect = UIUtils.FindGo(_tf, "SprSelect"),
        GobjUnSelect = UIUtils.FindGo(_tf, "SprUnSelect"),
        GobjGetNew = UIUtils.FindGo(_tf, "SprGetNew"),
        TitleType = 0,
    }
    UIUtils.AddBtnEvent(UIUtils.FindBtn(_tf), self.OnClickTopItem, self, _m)
    return _m;
end

--Central title
function UIRoleTitleForm:CreatCenterItem(gobj, tfParent, isBase)
    local _gobj = isBase and gobj or UnityUtils.Clone(gobj, tfParent);
    local _tf = _gobj.transform;
    local _m = {
        Gobj = _gobj,
        Trans = _tf,
        GobjSelect = UIUtils.FindGo(_tf, "SprSelect"),
        GobjLock = UIUtils.FindGo(_tf, "SprLock"),
        GobjWearState = UIUtils.FindGo(_tf, "WearState"),
        GobjForever = UIUtils.FindGo(_tf, "Forever"),
        GobjLimit = UIUtils.FindGo(_tf, "Limit"),
        GobjRedPoint = UIUtils.FindGo(_tf, "SprRedPoint"),
        Tex = UIUtils.FindTex(_tf, "Tex"),
        GobjGetNew = UIUtils.FindGo(_tf, "SprGetNew"),
        TitleID = 0,
        TitleType = 0,
    }
    UIUtils.AddBtnEvent(UIUtils.FindBtn(_tf), self.OnClickCenterItem, self, _m)
    return _m;
end

--Bottom attribute data
function UIRoleTitleForm:CreatBottomItem(gobj, tfParent, isBase)
    local _gobj = isBase and gobj or UnityUtils.Clone(gobj, tfParent);
    local _tf = _gobj.transform;
    local _m = {
        Gobj = _gobj,
        Trans = _tf,
        TxtName = UIUtils.FindLabel(_tf, "TxtName"),
        TxtValue = UIUtils.FindLabel(_tf, "TxtValue"),
    }
    return _m;
end

--Create all groups at the top
function UIRoleTitleForm:CreatTopAllItems()
    local _list = GameCenter.RoleTitleSystem.TitleTypeData
    local _info = self:GetCurWearAndShowTitle()
    for i=1, #_list do
        local _data = _list[i];
        local _Item = self.TopList[i];
        if not _Item then
            _Item =  self:CreatTopItem(self.GobjTopItemBase, self.TfGrid_Top)
            self.TopList:Add(_Item);
        end
        _Item.Gobj:SetActive(true)
        _Item.TitleType = _data.Type
        UIUtils.SetTextByString(_Item.TxtNameSelect, _data.Name)
        UIUtils.SetTextByString(_Item.TxtNameUnSelect, _data.Name)
        _Item.GobjRedPoint.gameObject:SetActive(_data.ShowRed)
        _Item.GobjGetNew:SetActive(GameCenter.RoleTitleSystem:IsHaveGetNewByBigType(_Item.TitleType))
        if _info and _info.TitleType == _data.Type or not _info and i == 1 then
            self.CurTopItem = _Item;
            _Item.GobjSelect:SetActive(true);
            _Item.GobjUnSelect:SetActive(false);
        else
            _Item.GobjSelect:SetActive(false);
            _Item.GobjUnSelect:SetActive(true);
        end
    end

    self:HideNeedless(self.TopList, #_list)
    UnityUtils.GridResetPosition(self.TfGrid_Top)
    UnityUtils.ScrollResetPosition(self.TfScrollView_Top)
end

--Refresh the top area
function UIRoleTitleForm:RefreshTopArea()
    local _list = GameCenter.RoleTitleSystem.TitleTypeData
    for i=1, #_list do
        local _Item = self.TopList[i];
        _Item.GobjGetNew:SetActive(GameCenter.RoleTitleSystem:IsHaveGetNewByBigType(_Item.TitleType))
    end
end

--Refresh the central area
function UIRoleTitleForm:RefreshCenterArea(isReset, playAnim)
    local _curTitleType = self.CurTopItem.TitleType;
    local _list = GameCenter.RoleTitleSystem.TitlesData[_curTitleType]
    if not _list then
        return
    end
    local _info = self:GetCurWearAndShowTitle();
    local _curTitleId = 0
    if _info ~= nil then
        _curTitleId = _info.TitleID
    end

    local _hideList = GameCenter.RoleTitleSystem:GetNeedHideTitleList()
    local _haveList = GameCenter.RoleTitleSystem.CurrHaveTitleList;

    local _animList = nil
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end
    local _showCount = 0;
    for i = 1, #_list do
        local _titleItem = _list[i];
        local _titleId = _titleItem.TitleID
        local _cfg = DataConfig.DataTitle[_titleId];
        if _cfg then
            local _isShow = false;
            if _titleItem.CanShow > 1 then
                _isShow = _haveList:Contains(_titleId);
            else
                _isShow = not _hideList or not _hideList:Contains(_titleItem.TitleID);
            end
            if _isShow then
                _showCount = _showCount + 1
                local _item = self.CenterList[_showCount];
                if not _item then
                    _item =  self:CreatCenterItem(self.GobjCenterItemBase, self.TfGrid_Center)
                    self.CenterList:Add(_item);
                end
                _item.Gobj:SetActive(true)
                _item.TitleID = _titleId;
                _item.TitleType = _curTitleType;
                _item.Have = _titleItem.Have;
                if not self.CurCenterItem and (_info and _info.TitleType == _curTitleType and _titleId == _info.TitleID or not _info and _showCount == 1) then
                    self.CurCenterItem = _item;
                    _item.GobjSelect:SetActive(true);
                elseif self.CurCenterItem and (self.CurCenterItem.TitleType ~= _curTitleType and _showCount == 1 or self.CurCenterItem.TitleType == _curTitleType and self.CurCenterItem.TitleID == _titleId) then
                    self.CurCenterItem = _item;
                    _item.GobjSelect:SetActive(true);
                else
                    _item.GobjSelect:SetActive(false);
                end
                -- _item.GobjLock:SetActive(not _titleItem.Have);
                _item.GobjLock:SetActive(false);
                _item.Tex.IsGray = not _titleItem.Have
                if _titleItem.Have then
                    if _curTitleId == _titleId then
                        _item.GobjWearState:SetActive(true)
                        _item.GobjForever:SetActive(false)
                        _item.GobjLimit:SetActive(false)
                    else
                        _item.GobjWearState:SetActive(false)
                        _item.GobjForever:SetActive(_titleItem.Have and _cfg.Time <= 0)
                        _item.GobjLimit:SetActive(_titleItem.Have and _cfg.Time > 0)
                    end
                else
                    _item.GobjWearState:SetActive(false)
                    _item.GobjForever:SetActive(false)
                    _item.GobjLimit:SetActive(false)
                end
                self.CSForm:LoadTexture(_item.Tex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format("tex_chenghao_%s", _cfg.Textrue)))
                _item.GobjRedPoint:SetActive(_titleItem.ShowRed)
                _item.GobjGetNew:SetActive(GameCenter.RoleTitleSystem:IsGetNewTitle(_titleId));

                if playAnim then
                    _animList:Add(_item.Trans)
                end
            end
        end
    end

    self:HideNeedless(self.CenterList, _showCount);
    if isReset then
        UnityUtils.GridResetPosition(self.TfGrid_Center)
        UnityUtils.ScrollResetPosition(self.TfScrollView_Center)
    end
    self:RefreshBottomArea(playAnim)

    if playAnim then
        for i = 1, #_animList do
            self.CSForm:RemoveTransAnimation(_animList[i])
            self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, 0, 50, 0.3, false, false)
            self.AnimPlayer:AddTrans(_animList[i], (i - 1) // 2 * 0.1)
        end
        self.AnimPlayer:Play()
    end
end

--Refresh the bottom attribute
function UIRoleTitleForm:RefreshBottomArea(playAnim)
    local _cfg = DataConfig.DataTitle[self.CurCenterItem.TitleID];
    local _strs = Utils.SplitStr(_cfg.Property,";");
    for i=1, #_strs do
        local _arr = Utils.SplitNumber(_strs[i], "_");
        local _attCfg = DataConfig.DataAttributeAdd[_arr[1]];
        local _item = self.BottomList[i];
        if not _item then
            _item =  self:CreatBottomItem(self.GobjBottomItemBase, self.TfGrid_Bottom)
            self.BottomList:Add(_item);
        end
        _item.Gobj:SetActive(true)
        if _attCfg then
            UIUtils.SetTextByStringDefinesID(_item.TxtName, _attCfg._Name)
            if _attCfg.ShowPercent == 1 then
                UIUtils.SetTextByEnum(_item.TxtValue, "AddPercent", _arr[2])
            else
                UIUtils.SetTextByEnum(_item.TxtValue, "AddNum", _arr[2])
            end
        end
    end

    self:HideNeedless(self.BottomList, #_strs);
    UnityUtils.GridResetPosition(self.TfGrid_Bottom)
    UnityUtils.ScrollResetPosition(self.TfScrollView_Bottom)
    
    if _cfg then
        UIUtils.SetTextByEnum(self.TxtCondition, "Title_Condition", _cfg.ActiveDesc)
    end
    --Button
    local _currTitle = self:GetCurWearAndShowTitle()
    if self.CurCenterItem.Have then
        if _currTitle then
            self.BtnWear.gameObject:SetActive(_currTitle.TitleID ~= self.CurCenterItem.TitleID)
            self.BtnDown.gameObject:SetActive(_currTitle.TitleID == self.CurCenterItem.TitleID)
        else
            self.BtnWear.gameObject:SetActive(true)
            self.BtnDown.gameObject:SetActive(false)
        end
        self.BtnActive.gameObject:SetActive(false)
        self.BtnSource.gameObject:SetActive(false)
    else
        self.BtnWear.gameObject:SetActive(false)
        self.BtnDown.gameObject:SetActive(false)
        local _items = GameCenter.ItemContianerSystem:GetItemListByCfgidNOGC(ContainerType.ITEM_LOCATION_BAG, self.CurCenterItem.TitleID)
        local _active = _items.Count > 0 and _items[0].Type == ItemType.Title
        self.BtnActive.gameObject:SetActive(_active)
        if _cfg then
            local _enable = _cfg.OpenFunc ~= 0 and (not _active)
            self.BtnSource.gameObject:SetActive(_enable)
        else
            self.BtnSource.gameObject:SetActive(false)
        end
    end
    self:RefreshLeftArea(playAnim)
end

--Refresh the left side
function UIRoleTitleForm:RefreshLeftArea(playAnim)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    --Combat Power
    self.TxtFight.gameObject:SetActive(false)
    UIUtils.SetTextByNumber(self.TxtFight, _lp.FightPower)
    --Player name
    UIUtils.SetTextByString(self.TxtRoleName, _lp.Name)
    --Player level
    UIUtils.SetTextByNumber(self.TxtLv, _lp.Level)
    --Player model
    if not self.isShowingPlayer then
        self.isShowingPlayer = true;
        self.UISkin:ResetRot()
        self.UISkin:ResetSkin()
        self.UISkin:SetCameraSize(2.2)
        local _info = _lp.VisualInfo
        local _occ = _lp.IntOcc
        if _info.FashionBodyID > 0 then
            self.UISkin:SetEquip(FSkinPartCode.Body, RoleVEquipTool.GetFashionBodyModelID(_occ, _info.FashionBodyID))
        else
            self.UISkin:SetEquip(FSkinPartCode.Body, RoleVEquipTool.GetLingTiBodyID(_occ, _info.LingTiDegree))
        end
        self.UISkin:SetEquip(FSkinPartCode.GodWeaponHead, RoleVEquipTool.GetFashionWeaponModelID(_occ, _info.FashionWeaponID))
        self.UISkin:SetEquip(FSkinPartCode.XianjiaHuan, RoleVEquipTool.GetFashionHaloModelID(_info.FashionHaloID));
        self.UISkin:SetEquip(FSkinPartCode.XianjiaZhen, RoleVEquipTool.GetLPMatrixModel())
    end
    --title
    if self.CurCenterItem then
        local _titleCfg = DataConfig.DataTitle[self.CurCenterItem.TitleID];
        if _titleCfg.VfxTitle > 0 then
            if playAnim then
                self.AnimTitle:OnCreateAndPlay(ModelTypeCode.UIVFX, _titleCfg.VfxTitle, LayerUtils.GetAresUILayer(), function(x)
                    self.CSForm:PlayShowAnimation(self.TitleRoot)
                    UnityUtils.SetLocalScale(self.TitleRoot, 0, 0, 0)
                end)
            else
                self.AnimTitle:OnCreateAndPlay(ModelTypeCode.UIVFX, _titleCfg.VfxTitle, LayerUtils.GetAresUILayer())
            end
            self.TexTitle.gameObject:SetActive(false)
        else
            self.AnimTitle:OnDestory()
            self.TexTitle.gameObject:SetActive(true)
            self.CSForm:LoadTexture(self.TexTitle, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format("tex_chenghao_%s",_titleCfg.Textrue)), function(info)
                if playAnim then
                    self.CSForm:PlayShowAnimation(self.TitleRoot)
                end
            end)
        end
    else
        self.TexTitle.gamaObject:SetActive(false);
        self.AnimTitle:OnDestory()
    end

    if self.CurCenterItem then
        local _info = GameCenter.RoleTitleSystem:GetTitleInfo(self.CurCenterItem.TitleType, self.CurCenterItem.TitleID)
        self:SetTitleState(_info);
    else
        self.RemindTime = 0;
        UIUtils.ClearText(self.TxtState)
    end
end

--Hide the excess
function UIRoleTitleForm:HideNeedless(list, showCnt)
	local _listCnt = list:Count()
	local _needHideCnt = _listCnt - showCnt
	for i=_listCnt, _listCnt-_needHideCnt+1, -1 do
		list[i].Gobj:SetActive(false)
	end
end

function UIRoleTitleForm:OnClickTopItem(topItem)
    if self.CurTopItem then
        self.CurTopItem.GobjSelect:SetActive(false);
        self.CurTopItem.GobjUnSelect:SetActive(true);
    end
    self.CurTopItem = topItem;
    self.CurTopItem.GobjSelect:SetActive(true);
    self.CurTopItem.GobjUnSelect:SetActive(false);
    self:RefreshCenterArea(true, true);
end

function UIRoleTitleForm:OnRefreshForm()
    self:RefreshTopArea();
    self:RefreshCenterArea();
end

function UIRoleTitleForm:OnClickCenterItem(centerItem)
    if self.CurCenterItem then
        self.CurCenterItem.GobjSelect:SetActive(false);
        GameCenter.RoleTitleSystem:RemoveNewTitle(self.CurCenterItem.TitleID);
        self.CurCenterItem.GobjGetNew:SetActive(false)
    end
    self.CurCenterItem = centerItem;
    self.CurCenterItem.GobjSelect:SetActive(true);
    self:RefreshBottomArea(true);
    GameCenter.RoleTitleSystem:RemoveNewTitle(centerItem.TitleID);
    centerItem.GobjGetNew:SetActive(false)
    self:RefreshTopArea()
end

-- Get the title you are currently wearing and can display
function UIRoleTitleForm:GetCurWearAndShowTitle()
    local _info = GameCenter.RoleTitleSystem.CurrWearTitle;
    if _info and _info.TitleCfg.CanShow >= 1 then
        return _info
    end
end

return UIRoleTitleForm