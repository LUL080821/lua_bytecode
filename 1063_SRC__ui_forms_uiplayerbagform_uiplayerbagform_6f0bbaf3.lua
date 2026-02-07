------------------------------------------------
--author:
--Date: 2021-02-23
--File: UIPlayerBagForm.lua
--Module: UIPlayerBagForm
--Description: Backpack functional interface
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_UIEquipmentItem = require("UI.Components.UIEquipmentItem")
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local L_UIPopSelectList = require ("UI.Components.UIPopSelectList.UIPopSelectList")
local UIPlayerBagForm = {
    TypePopMenu = nil,
    ScrollView = nil,            --slide
    ItemContaners = nil,         -- Item container
    ItemDic = Dictionary:New(),  --Inventory
    LoopGrid = nil,              --Cycle slide control
    ClearBtn = nil,              --Solve button
    ClearBtnLabelTs = nil,
    SelectItem = nil,            --Select item
    CountSpriteGo = nil,           --Countdown background
    CountLabel = nil,            --Countdown to packing
    QuickBtn = nil,
    CurSelectTable = nil,        --Is the currently selected warehouse or backpack converted from the BagFormSubPanel enumeration
    BottomGrid = nil,            --The bottom Grid is used for button alignment
    SmeltBtn = nil,              --Smelting
    SmeltRedGo = nil,            --Smelting red dots
    RemainCountLabel = nil,
    PlayerModel = nil,           --Player model
    PlayerVfxSkin = nil,
    PlayerTitle = nil,           -- The callback function that binds the UI component
    FightValue = nil,            --Combat Power
    PlayerLevel = nil,           --grade
    Title = nil,                 --title
    EquipPanel = nil,
    TitleBtn = nil,
    TitleRedGo = nil,
    GemAttrBtn = nil,
    BackTexture = nil,

    BagTrans = nil,
    BottomTrans = nil,
    EquipTransGo = nil,
    EquipListTrans = nil,

    MaxItemCount = 120,           --The maximum number of grids for backpacks
    CurCategory = nil,            --Current pagination
    IsBeginCountDown = nil,       -- The hidden operation is provided to the CS side to call.
    CurCountTime = nil,           --Current countdown
    IsUpdateEquip = nil,
    UseCountDown = nil,

    EquipItemDic = Dictionary:New(),           --Equipment container
}


--------------------------------------------------------------------------------------------------------------------------------
function UIPlayerBagForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIPlayerBagForm_OPEN, self.OnOpen);
    self:RegisterEvent(UIEventDefine.UIPlayerBagForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_BACKFORM_ITEM_UNSELCT, self.UnSelect);
    self:RegisterEvent(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnUpdateItem);
    self:RegisterEvent(LogicEventDefine.EVENT_BACKFORM_UPDATE_ALL, self.OnUpdateForm);
    self:RegisterEvent(LogicEventDefine.EVENT_EQUIPMENTFORM_ITEM_UPDATE, self.OnEquipChangeBack);
    self:RegisterEvent(LogicEventDefine.EVENT_EQUIPMENTFORM_UPDATE_FORM, self.OnEquipChangeBack);
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_FASHION_UPDATECHANGE, self.OnEquipChangeBack);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FIGHT_POWER_CHANGED, self.OnFightPowerChanged);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnRoleInfoChange);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnUpdateFunc);
    self:RegisterEvent(LogicEventDefine.EID_EVENT_BAG_OPENCELL_UPDATE, self.OnOpenCellSuc);

     --Form hang message
     self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_SUSPEND_ALL_FORM_AFTER, self.OnSuspendAllFormAfter);
     --Form recovery message
     self:RegisterEvent(LogicEventDefine.EID_EVENT_ON_RESUME_ALL_FORM_AFTER, self.OnResumeAllFormAfter);
end

function UIPlayerBagForm:OnFirstShow()
    self:FindAllComponents();
    self:RegUICallback();
	self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, false, false)
    self.IsBeginCountDown = false;
end

function UIPlayerBagForm:OnShowAfter()
    self:OnInitForm();
    self:UpdateTitleRedPoint(nil);
    self.IsUpdateEquip = false;
    self.CSForm:LoadTexture(self.BackTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_z_combine_1"))
end

function UIPlayerBagForm:OnHideBefore()
    self.PlayerModel:ResetSkin()
end

--For update countdown
function UIPlayerBagForm:Update(dt)
    if self.IsBeginCountDown then
        if self.CurCountTime > 0 then
            self.CurCountTime = self.CurCountTime - dt
            local _num = math.ceil(self.CurCountTime)
            if _num ~= self.ShowCountTime then
                self.ShowCountTime = _num
                UIUtils.SetTextByNumber(self.CountLabel, _num)
            end
            if self.ClearBtnLabelTs.activeSelf then
                self.ClearBtnLabelTs:SetActive(false)
            end
        else
            self.IsBeginCountDown = false;
            self.CurCountTime = 10;
            GameCenter.ItemContianerSystem:SetBagSortTime(ContainerType.ITEM_LOCATION_BAG, 0);
            self.CountSpriteGo:SetActive(false);
            self.ClearBtnLabelTs:SetActive(true)
            UIUtils.ClearText(self.CountLabel)
        end
    end
    if self.IsUpdateEquip then
        self.IsUpdateEquip = false;
        self:OnUpdateEquipForm(nil);
    end
    if self.UseCountDown > 0 then
        self.UseCountDown = self.UseCountDown - dt
        if self.UseCountDown < 0 then
            self.UseCountDown = 0;
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------OnRegisterEvents event callback and delegate callback begin-------------
--Event trigger opening interface
function UIPlayerBagForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    self.CurSelectTable = obj;
    self.PlayerHead:SetLocalPlayer()
    self:OnListMenuSelected();
end

--Update the corresponding item in the backpack lattice
function UIPlayerBagForm:OnUpdateItem(obj, sender)
    if obj then
        local itemBase = obj
        local bpModel = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG);
        if itemBase and bpModel then
            self:OnSetBagRemainCount(bpModel);
            local bigType = self:GetItemBigTypeWithItemType(itemBase.Type);
            if self:isContainTypeInCategroyType(self.CurCategory, bigType) then
                self.ItemDic:ForeachCanBreak(function(k, v)
                    if itemBase.Index == v then
                        k.SingleClick = Utils.Handler(self.SelectItemCell, self)
                        local _dic = bpModel.ItemsOfUID
                        if _dic:ContainsKey(itemBase.DBID) then
                            itemBase = _dic[itemBase.DBID]
                        else
                            itemBase = nil
                        end
                        k:SelectItem(false);
                        k:UpdateItem(itemBase)
                        return true
                    end
                end)
            end
        end
        if self.CurCategory ~= BagCategoryType.BAG_CATEGORY_ALL then
            self:OnUpdateForm(nil);
        end
    end
end

--Update backpack form
function UIPlayerBagForm:OnUpdateForm(obj, sender)
    local _bpModel = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG);
    local bigType = self:GetItemTypeWithCategoryType(self.CurCategory);
    if _bpModel then
        self:OnSetBagRemainCount(_bpModel);
        if (_bpModel.AllCount == 0) then
            _bpModel.AllCount = self.MaxItemCount;
        end
        local itemList = _bpModel:GetItemListByItemBigType(bigType);
        self.ItemDic:Foreach(function(k, v)
            local bpItem = k
            bpItem.Index = v;
            bpItem.SingleClick = Utils.Handler(self.SelectItemCell, self)
            bpItem.IsOpened = v <= _bpModel.OpenedCount;

            local item = nil;
            if (bigType == ItemBigType.All) then
                local _dic = _bpModel.ItemsOfIndex
                if _dic:ContainsKey(v) then
                    item = _dic[v]
                end
            else
                if (v <= itemList.Count) then
                    item = itemList[v - 1];
                end
            end
            bpItem:UpdateItem(item);
        end)
        self.CurCountTime = GameCenter.ItemContianerSystem:GetBagSortTime(ContainerType.ITEM_LOCATION_BAG)
        --Whether to count down the new countdown
        if (GameCenter.ItemContianerSystem:GetBagSortTime(ContainerType.ITEM_LOCATION_BAG) ~= 0) then
            self.CountSpriteGo:SetActive(true);
            self.ClearBtnLabelTs:SetActive(false);
            self.IsBeginCountDown = true;
        end
    end
end

function UIPlayerBagForm:OnFightPowerChanged(obj, sender)
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer();
    if localPlayer == nil then
        return;
    end
    UIUtils.SetTextByBigNumber(self.FightValue, localPlayer.FightPower)
end

-- Listen to the change of the protagonist's information
function UIPlayerBagForm:OnRoleInfoChange(obj, sender)
    self:OnSetPlayerLevel();
end

--The form is hung
function UIPlayerBagForm:OnSuspendAllFormAfter(obj, sender)
    self.EquipPanel:Refresh();
end

--Form Recovery
function UIPlayerBagForm:OnResumeAllFormAfter(obj, sender)
    self.EquipPanel:Refresh();
end

--The grid is successfully opened
function UIPlayerBagForm:OnOpenCellSuc(obj, sender)
    self:UpdateItemCellAll(BagCategoryType.BAG_CATEGORY_ALL, true);
end

--Unselected
function UIPlayerBagForm:UnSelect(obj, sender)
    if self.SelectItem then
        self.SelectItem:SelectItem(false);
    end
end

-- Listen to the changes of red dots
function UIPlayerBagForm:OnUpdateFunc(funcInfo, sender)
    if (funcInfo == nil) then
        return;
    end
    if (funcInfo.ID == FunctionStartIdCode.EquipSmelt) then
        self.SmeltRedGo:SetActive(funcInfo.IsShowRedPoint)
    end
end

--The grid position changes, update grid
function UIPlayerBagForm:OnItemChangePos(trans, name, isClear)
    local index = -1;
    UIUtils.FindWid(trans):Invalidate(true);
    index = tonumber(trans.name)
    local _bagItem = UIUtils.RequireUIPlayerBagItem(trans);
    if self.ItemDic:ContainsKey(_bagItem) then
        self.ItemDic[_bagItem] = index
    else
        self.ItemDic:Add(_bagItem,  index)
    end
    if self.CurCategory ~= BagCategoryType.UnDefine then
        self:UpdateItemCell(self.CurCategory, _bagItem);
    end
end

--Title red dot
function UIPlayerBagForm:UpdateTitleRedPoint(obj, secder)
    self.TitleRedGo:SetActive(GameCenter.RoleTitleSystem:ShowRed());
end

function UIPlayerBagForm:OnEquipChangeBack(obj, sender)
    self.IsUpdateEquip = true;
end

--Update equipment information interface
function UIPlayerBagForm:OnUpdateEquipForm(obj, sender)
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer();
    if (nil == localPlayer) then
        return;
    end
    self:OnSetPlayerLevel();
    UIUtils.SetTextByString(self.PlayerTitle, localPlayer.Name)
    UIUtils.SetTextByBigNumber(self.FightValue, localPlayer.FightPower)
    for idx = 0, EquipmentType.Count - 1 do
        local equipItem = self.EquipItemDic[idx]
        local equipment = GameCenter.EquipmentSystem:GetPlayerDressEquip(idx);
        equipItem:UpdateEquipment(equipment, idx, 0);
    end

    --Load the protagonist model
    self.PlayerModel:ResetSkin();
    self.PlayerModel:RefreshPlayerSkinModel(localPlayer.IntOcc, localPlayer.VisualInfo);
    self.PlayerModel.Skin:SetClothEnable(true, 0.7, 0.04, 0.4);

    if self.PlayerVfxSkin then
        self.PlayerVfxSkin:OnCreateAndPlay(ModelTypeCode.BodyVFX, RoleVEquipTool.GetLPMatrixModel(), LayerUtils.GetAresUILayer());
    end
end
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--Click on the item
function UIPlayerBagForm:SelectItemCell(tmpBpItem)
    if not tmpBpItem.IsOpened then
        local bpModel = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG);
        if bpModel then
            local costNum = 0
            for i = 1000 + bpModel.OpenedCount + 1, 1000 + bpModel.NowOpenIndex do
                local cfg = DataConfig.DataBagGrid[i]
                if cfg then
                    costNum = costNum + cfg.Cost
                end
            end
            Utils.ShowMsgBox(function(x)
                if (x == MsgBoxResultCode.Button2) then
                    local _msg = ReqMsg.MSG_backpack.ReqOpenBagCell:New()
                    _msg.cellId = bpModel.NowOpenIndex
                    _msg:Send()
                end
            end, "C_UI_BAGFORM_OPENCELL_TIPS", costNum, L_ItemBase.GetItemName(1));
        end
    end

    if self.SelectItem and self.SelectItem ~= tmpBpItem then
        self.SelectItem:SelectItem(false);
    end
    self.SelectItem = tmpBpItem;
    self.SelectItem:SelectItem(true)
    if tmpBpItem.IsOpened then
        GameCenter.ItemTipsMgr:ShowTips(tmpBpItem.ItemInfo, tmpBpItem.Trans, self.CurSelectTable == BagFormSubPanel.Store and ItemTipsLocation.PutInStorage or ItemTipsLocation.Bag);
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_STORE_ITEM_UNSELECT);
end

--Quick Save Button Click
function UIPlayerBagForm:OnQuickPutinBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIBatchForm_OPEN, BagFormSubPanel.Bag);
end

--Equipment smelting
function UIPlayerBagForm:OnSmeltBtnClick()
    if (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSmelt)) then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.EquipSmelt);
    else
        Utils.ShowMsgBox(function(x)
            if (x == MsgBoxResultCode.Button2) then
                local _cfg = DataConfig.DataGlobal[GlobalName.Smelt_equip_npc]
                if _cfg then
                    GameCenter.PathSearchSystem:SearchPathToNpcTalk(tonumber(_cfg.Params))
                end
            end
        end, "C_UI_EQUIPSMELT_NOOPEN_TIPS");
    end
end

--tidy
function UIPlayerBagForm:OnBtnClearUp()
    if self.UseCountDown <= 0 then
        local _msg = ReqMsg.MSG_backpack.ReqBagClearUp:New()
        _msg:Send()
        self.UseCountDown = 1
        -- if not GameCenter.ItemContianerSystem.IsAlertAutoUse then
        --     -- local _str = DataConfig.DataMessageString.Get("C_UI_PLAYERBAG_AUTOUSE_TIPS")
        --     -- GameCenter.MsgPromptSystem:ShowSelectMsgBox(_str, DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
        --     -- DataConfig.DataMessageString.Get("C_MSGBOX_OK"), function(x)
        --     --     if x == MsgBoxResultCode.Button2 then
        --     --         local _useMsg = ReqMsg.MSG_backpack.ReqAutoUseItem:New()
        --     --         _useMsg:Send()
        --     --         --Experience Pill
        --     --         GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_USEEXP_ITEM);
        --     --     end
        --     -- end,
        --     -- function(x)
        --     --     GameCenter.ItemContianerSystem.IsAlertAutoUse = x == MsgBoxIsSelect.Selected
        --     -- end,
        --     -- DataConfig.DataMessageString.Get("RICHER_BEN_CI_DENG_LU_BU_ZAI_TI_SHI"))
        -- else
        --     local _useMsg = ReqMsg.MSG_backpack.ReqAutoUseItem:New()
        --     _useMsg:Send()
        --     --Experience Pill
        --     GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_USEEXP_ITEM);
        -- end
    else
        Utils.ShowPromptByEnum("DontMultipleClick");
    end
end

function UIPlayerBagForm:OnPopMenuSelectCallBack(index, data)
    if data then
        if (self.CurCategory ~= data.Id) then
            self.CurCategory = data.Id;
            self:UpdateItemCellAll(data.Id, false)
        end
    end
end

--Equipment bar click event
function UIPlayerBagForm:EquipItemClick(obj)
    if obj then
        if obj.Equipment then
            GameCenter.ItemTipsMgr:ShowTips(obj.Equipment, obj.Go, ItemTipsLocation.Equip, false);
        elseif obj.CurType == 8 or obj.CurType == 9 then
            obj:OnSelectItem(false)
        else
            local _glCfg = DataConfig.DataGlobal[GlobalName.New_Equip_ID]
            if _glCfg then
                local _getCfg = Utils.SplitStrBySeps(_glCfg.Params, {';','_'})
                local _count = #_getCfg
                for i = 1, _count do
                    if tonumber(_getCfg[i][1]) == obj.CurType then
                        GameCenter.ItemTipsMgr:ShowTipsByCfgid(tonumber(_getCfg[i][2]), obj.Go, true, ItemTipsLocation.Defult);
                        break
                    end
                end
            end
        end
    end
end

--Title button click
function UIPlayerBagForm:OnTitleBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.RoleTitle);
end

--Gem button click
function UIPlayerBagForm:OnGemAttrBtnClcik()
    -- GameCenter.PushFixEvent(UIEventDefine.UILianQiGemAllAttrForm_OPEN)
    GameCenter.PushFixEvent(UILuaEventDefine.UILianQiStrengthAllAttrForm_OPEN)
end
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Interface initialization
function UIPlayerBagForm:OnInitForm()
    self.QuickBtn.gameObject:SetActive(false)
    self.CurCategory = BagCategoryType.BAG_CATEGORY_COUNT;
    self.CurCountTime = 10;
    self.CountSpriteGo:SetActive(false);
    self.ClearBtnLabelTs:SetActive(true);
    self.EquipTransGo:SetActive(true);
    self.BackTexture.gameObject:SetActive(true)
    self.TypePopMenu:SetSelect(1);
    self:OnUpdateEquipForm();
    self.UseCountDown = 0;
    self.TitleBtn.gameObject:SetActive(true)
end

--Find various controls on the UI
function UIPlayerBagForm:FindAllComponents()
    local _myTrans = self.Trans
    self.BottomTrans = UIUtils.FindTrans(_myTrans, "Center/Container/Bottom");
    self.BagTrans = UIUtils.FindTrans(_myTrans, "Center/Container/Container")
    self.ScrollView = UIUtils.FindScrollView(self.BagTrans, "BagContainer")
    local _dataList = List:New();
    _dataList:Add({ Id = 0, Text = DataConfig.DataMessageString.Get("C_EQUIP_ALL")});
    _dataList:Add({ Id = 1, Text = DataConfig.DataMessageString.Get("C_ITEM_NAME_EQUIP") });
    _dataList:Add({ Id = 3, Text = DataConfig.DataMessageString.Get("C_ITEM_NAME_QITAITEM") });
    self.TypePopMenu = L_UIPopSelectList:OnFirstShow(UIUtils.FindTrans(self.BagTrans, "Side/TypeSelect"))
    self.TypePopMenu:SetData(_dataList)
    self.RemainCountLabel = UIUtils.FindLabel(self.BagTrans, "Side/RemainCount")

    self.BottomGrid = UIUtils.FindGrid(self.BottomTrans)
    self.ClearBtnLabelTs = UIUtils.FindGo(self.BottomTrans, "ClearButton/Label");
    self.ClearBtn = UIUtils.FindBtn(self.BottomTrans, "ClearButton")
    self.QuickBtn = UIUtils.FindBtn(self.BottomTrans, "QuickButton")
    self.SmeltBtn = UIUtils.FindBtn(self.BottomTrans, "SmeltButton")
    self.SmeltRedGo = UIUtils.FindGo(self.BottomTrans, "SmeltButton/Red")
    self.CountSpriteGo = UIUtils.FindGo(self.BottomTrans, "ClearButton/downBack");
    self.CountLabel = UIUtils.FindLabel(self.BottomTrans, "ClearButton/downBack/downLabel")
    self.ItemContaners = UIUtils.FindGrid(self.BagTrans, "BagContainer/Grid")

    self.MaxItemCount = CS.Thousandto.Code.Logic.ItemContianerSystem.GetBagMaxCount(ContainerType.ITEM_LOCATION_BAG);
    self.LoopGrid = UIUtils.RequireUILoopScrollViewBase(self.ItemContaners.transform)
    self.LoopGrid:SetDelegate(Utils.Handler(self.OnItemChangePos, self));

    --equipment
    self.EquipTransGo = UIUtils.FindGo(_myTrans, "Center/UIPlayerEquipForm");
    self.EquipPanel = UIUtils.FindPanel(_myTrans, "Center/UIPlayerEquipForm/Back/Panel")
    self.PlayerModel = UIUtils.RequireUIPlayerSkinCompoent(UIUtils.FindTrans(_myTrans, "Center/UIPlayerEquipForm/UIRoleSkinCompoent"))
    self.PlayerVfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_myTrans, "Center/UIPlayerEquipForm/UIVfxSkinCompoent"));
    self.PlayerLevel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/Level"))
    self.PlayerTitle = UIUtils.FindLabel(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/Name")
    self.PlayerHead = PlayerHead:New(UIUtils.FindTrans(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/PlayerHeadLua"))
    self.Title = UIUtils.FindLabel(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/Title")
    self.FightValue = UIUtils.FindLabel(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/Fight")
    self.BackTexture = UIUtils.FindTex(_myTrans, "Center/Texture")
    for idx = 0, EquipmentType.Count - 1 do
        local sKey = UIUtils.CSFormat("Center/UIPlayerEquipForm/Back/Panel/EquipIcons/UIEquipmentItem_{0}", idx);
        local itemGo = UIUtils.FindGo(_myTrans, sKey)
        if idx == 10 then
            itemGo:SetActive(false)
        end
        
        local equipItem = L_UIEquipmentItem:New(UIUtils.FindTrans(_myTrans, sKey))
        equipItem.CallBack = Utils.Handler(self.EquipItemClick, self)
        self.EquipItemDic:Add(idx, equipItem);
    end
    if self.PlayerModel then
        self.PlayerModel:OnFirstShow(self.CSForm, FSkinTypeCode.Player);
    end

    self.TitleBtn = UIUtils.FindBtn(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/EquipIcons/TitleBtn")
    self.GemAttrBtn = UIUtils.FindBtn(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/EquipIcons/GemAttrBtn")
    self.TitleRedGo = UIUtils.FindGo(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/EquipIcons/TitleBtn/RedPoint")
    self.EquipListTrans = UIUtils.FindTrans(_myTrans, "Center/UIPlayerEquipForm/Back/Panel/EquipIcons")
end

--Register events on the UI, such as click events, etc.
function UIPlayerBagForm:RegUICallback()
    self.TypePopMenu:SetOnSelectCallback(Utils.Handler(self.OnPopMenuSelectCallBack, self));
    UIUtils.AddBtnEvent(self.TitleBtn, self.OnTitleBtnClick, self)
    UIUtils.AddBtnEvent(self.GemAttrBtn, self.OnGemAttrBtnClcik, self)
    UIUtils.AddBtnEvent(self.SmeltBtn, self.OnSmeltBtnClick, self)
    UIUtils.AddBtnEvent(self.QuickBtn, self.OnQuickPutinBtnClick, self)
    UIUtils.AddBtnEvent(self.ClearBtn, self.OnBtnClearUp, self)
end

--Function list button click event like warehouse click event
function UIPlayerBagForm:OnListMenuSelected()
    if self.CurSelectTable == BagFormSubPanel.Bag then
        self.EquipTransGo:SetActive(true)
        self.BackTexture.gameObject:SetActive(true)
        self.QuickBtn.gameObject:SetActive(false)
        if (GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.EquipSmeltMain)) then
            self.SmeltBtn.gameObject:SetActive(true);
            self.SmeltRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.EquipSmelt))
        end
    elseif self.CurSelectTable == BagFormSubPanel.Store then
        self.EquipTransGo:SetActive(false);
        self.BackTexture.gameObject:SetActive(false)
        self.QuickBtn.gameObject:SetActive(true);
        self.SmeltBtn.gameObject:SetActive(false);
    end
    self.CSForm:PlayShowAnimation(self.Trans)
    self.BottomGrid.repositionNow = true;
end

--Update backpack inventory (single)
function UIPlayerBagForm:UpdateItemCell(type, bagItem, isNeedClearItem)
    local _bpModel = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG);
    local bigType = self:GetItemTypeWithCategoryType(type);
    if _bpModel then
        self:OnSetBagRemainCount(_bpModel);
        if (_bpModel.AllCount == 0) then
            _bpModel.AllCount = self.MaxItemCount;
        end

        local maxCell = (_bpModel.OpenedCount + 1) / self.ItemContaners.maxPerLine;
        maxCell = math.floor(maxCell + 1) * self.ItemContaners.maxPerLine;
        if (maxCell > _bpModel.AllCount) then
            maxCell = _bpModel.AllCount;
        end
        if bagItem then
            local _index = self.ItemDic[bagItem]
            bagItem.Index = _index;
            bagItem.SingleClick = Utils.Handler(self.SelectItemCell, self)
            bagItem.IsOpened = _index <= _bpModel.OpenedCount;

            local item = nil;
            if (bigType == ItemBigType.All) then
                local _dic = _bpModel.ItemsOfIndex
                if _dic:ContainsKey(_index) then
                    item = _dic[_index]
                end
            else
                local itemList = _bpModel:GetItemListByItemBigType(bigType);
                if (_index <= itemList.Count) then
                    item = itemList[_index - 1];
                end
            end
            bagItem:UpdateItem(item);
            bagItem:SelectItem(false);
        end
        self.CurCategory = type;
    end
end

--Update backpack inventory (all updates)
function UIPlayerBagForm:UpdateItemCellAll(type, isNeedClearItem)
    self.CurCategory = type;
    local maxCell = 0;
    local _bpModel = GameCenter.ItemContianerSystem:GetBackpackModelByType(ContainerType.ITEM_LOCATION_BAG);
    if _bpModel then
        self:OnSetBagRemainCount(_bpModel);
        if (_bpModel.AllCount == 0) then
            _bpModel.AllCount = self.MaxItemCount;
        end
        maxCell = _bpModel.OpenedCount;
        self.CurCountTime = GameCenter.ItemContianerSystem:GetBagSortTime(ContainerType.ITEM_LOCATION_BAG);
        if (self.CurCategory == BagCategoryType.BAG_CATEGORY_ALL) then
            maxCell = (_bpModel.OpenedCount + 1) / self.ItemContaners.maxPerLine;
            maxCell = math.floor(maxCell + 1) * self.ItemContaners.maxPerLine;
            if (maxCell > _bpModel.AllCount) then
                maxCell = _bpModel.AllCount;
            end
        end
    end

    --Whether to count down the new countdown
    if (GameCenter.ItemContianerSystem:GetBagSortTime(ContainerType.ITEM_LOCATION_BAG) ~= 0) then
        self.CountSpriteGo:SetActive(true);
        self.IsBeginCountDown = true;
    end

    if isNeedClearItem == nil then
        isNeedClearItem = false
    end
    if (maxCell ~= 0) then
        self.LoopGrid:Init(maxCell, nil, 1, not isNeedClearItem);
    else
        self.LoopGrid:Init(self.MaxItemCount, nil, 1, not isNeedClearItem);
    end
    if (isNeedClearItem) then
        for i = 0, self.LoopGrid.transform.childCount - 1 do
            local index = UIUtils.RequireUIPlayerBagItem(self.LoopGrid.transform:GetChild(i));
            self:UpdateItemCell(type, index, i == self.LoopGrid.transform.childCount - 1);
        end
    end
end

-- Obtain the corresponding prop type category according to the backpack pagination
function UIPlayerBagForm:GetItemTypeWithCategoryType(type)
    local retType = ItemBigType.UnDefine;
    if type == BagCategoryType.BAG_CATEGORY_ALL then
        retType = ItemBigType.All;
    elseif type == BagCategoryType.BAG_CATEGORY_EQUIP then
        retType = ItemBigType.Equip;
    elseif type == BagCategoryType.BAG_CATEGORY_ImortalEquip then
        retType = ItemBigType.ImmortalEquip;
    elseif type == BagCategoryType.BAG_CATEGORY_Other then
        retType = ItemBigType.Other;
    end
    return retType;
end

-- Obtain props based on the specific type
function UIPlayerBagForm:GetItemBigTypeWithItemType(type)
    local retType = ItemBigType.UnDefine;
    if type == ItemType.Equip then
            retType = ItemBigType.Equip;
    elseif type == ItemType.Material then
            retType = ItemBigType.ImmortalEquip;
    else
            retType = ItemBigType.Other;
    end
    return retType;
end

--Is the current type included in the category
function UIPlayerBagForm:isContainTypeInCategroyType(type, bigType)
    local ret = false;
    if type == BagCategoryType.BAG_CATEGORY_ALL then
        ret = true;
    elseif type == BagCategoryType.BAG_CATEGORY_EQUIP then
        if (bigType == ItemBigType.Equip) then
            ret = true;
        end
    elseif type == BagCategoryType.BAG_CATEGORY_ImortalEquip then
        if (bigType == ItemBigType.ImmortalEquip) then
            ret = true;
        end
    elseif type == BagCategoryType.BAG_CATEGORY_Other then
        if (bigType == ItemBigType.Other) then
            ret = true;
        end
    end
    return ret;
end

function UIPlayerBagForm:OnSetPlayerLevel()
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer();
    if localPlayer then
        self.PlayerLevel:SetLevel(localPlayer.Level, true)
    end
end

function UIPlayerBagForm:OnSetBagRemainCount(_bpModel)
    local _remainCount = GameCenter.ItemContianerSystem:GetRemainCount();
    if (_remainCount <= 10) then
        UIUtils.SetTextFormat(self.RemainCountLabel, "{0}/[ff0000]{1}[-]", _remainCount, _bpModel.OpenedCount)
    else
        UIUtils.SetTextFormat(self.RemainCountLabel, "{0}/[00ff00]{1}[-]", _remainCount, _bpModel.OpenedCount)
    end
end
--------------------------------------------------------------------------------------------------------------------------------
return UIPlayerBagForm