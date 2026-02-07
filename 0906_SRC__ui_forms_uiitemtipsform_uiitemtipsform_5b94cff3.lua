------------------------------------------------
-- author:
-- Date: 2019-04-18
-- File: UIItemTipsForm.lua
-- Module: UIItemTipsForm
-- Description: Item Tips
------------------------------------------------

-- C# class
local UICamera = CS.UICamera
local WrapMode = CS.UnityEngine.WrapMode
local ItemBase = CS.Thousandto.Code.Logic.ItemBase
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local ItemContianerSystem = CS.Thousandto.Code.Logic.ItemContianerSystem
local UIItemTipsForm = {
    -- Parent node, used to set the position
    ParentTrans = nil,
    -- Available buttons
    ButtonDic = Dictionary:New(),
    -- Level of use
    ItemLevelLabel = nil,
    -- Item name
    ItemNameLabel = nil,
    -- Item Description
    ItemDesLabel = nil,
    ItemDesLabelTrans = nil,
    -- Item Type
    ItemTypeLabel = nil,
    --Button Tabel
    ButtonTabel = nil,
    -- The item currently displayed
    ItemData = nil,
    -- Display item grid UIItem
    ItemUI = nil,
    -- Item display location, container
    Location = ItemTipsLocation.Defult,
    -- Background image for calculating interface length
    BackSprite = nil,
    -- Quality back
    QualityBack = nil,
    QualityFront = nil,
    -- Maximum number of listings
    MarketMaxCount = 8,
    IsShowGet = false,
    -- Countdown count
    TimeCount = 0,

    -- Model dynamic rotation angle, used for weapon model
    WeaponRotZ = nil,
    -- Title special effects
    TtileVfx = nil,
    -- Title picture
    TtileTex = nil,
}

-- Inheriting Form functions
function UIItemTipsForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIITEMTIPS_OPEN,self.OnOpen)
	self:RegisterEvent(UIEventDefine.UIITEMTIPS_CLOSE,self.OnClose)
end

function UIItemTipsForm:OnFirstShow()
    self:FindAllComponents()
    self.CSForm:AddNormalAnimation(0.3)
end
function UIItemTipsForm:OnShowAfter()
    CS.UICamera.AddGenericEventHandler(self.GO)
    self.Hander =  Utils.Handler(self.OnUICameraEventListener, self)
    self:AddCameraClickEvent()
    self:SetItemInfo()
    self:ResetFucBtn(self.Location == ItemTipsLocation.Defult and self.IsShowGet == true)
    self.CSForm:LoadTexture(self.BgTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_100_1"))
end
function UIItemTipsForm:OnHideBefore()
    self.ItemData = nil
    CS.UICamera.RemoveGenericEventHandler(self.GO)
    self:RemoveCameraClickEvent()
    if self.ModelSkin then
        self.ModelSkin:ResetSkin()
    end
    if self.PlayerSkin then
        self.PlayerSkin:ResetSkin()
    end
    if self.QualityVfx then
        self.QualityVfx:OnDestory()
    end
    if self.TtileVfx then
        self.TtileVfx:OnDestory()
    end
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_BACKFORM_ITEM_UNSELCT)
end
function UIItemTipsForm:OnLoad()
    self.CSForm.UIRegion = CS.Thousandto.Plugins.Common.UIFormRegion.TopRegion
end
-- Register a camera click event
function UIItemTipsForm:AddCameraClickEvent()
    LuaDelegateManager.Add(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end

-- Delete the camera click event
function UIItemTipsForm:RemoveCameraClickEvent()
    LuaDelegateManager.Remove(CS.UICamera, "onClick", self.OnUICameraEventListener, self)
end

function UIItemTipsForm:OnUICameraEventListener(curObj)
    if curObj ~= nil then
        if not self:IsUIInMyUI(curObj) then
            self:OnClose()
        end
    end
end
function UIItemTipsForm:IsUIInMyUI(go)
    if go == nil then
        return false
    end
    if go == self.GO then
        return true
    end
    if (CS.Thousandto.Core.Base.UnityUtils.CheckChild(self.Trans, go.transform)) then
        return true
    end
    if go == self.BatchBtnGo then
        return true
    end
    return false
end

function UIItemTipsForm:OnOpen(obj, sender)
    local itemSelect = obj
    if (nil ~= itemSelect and nil ~= itemSelect.ShowGoods and nil ~= itemSelect.SelectObj) then
        self.ItemData = itemSelect.ShowGoods
        self.Location = itemSelect.Locatioin
        self.IsShowGet = itemSelect.isShowGetBtn
        if (itemSelect.isResetPosion) then
            self.SelectObj = itemSelect.SelectObj
        end
        if not self.ItemData or not self.ItemData.ItemInfo then
            self:OnClose()
        else
            self.CSForm:Show(sender)
        end
    else
        self:OnClose()
    end
end
function UIItemTipsForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIItemTipsForm:Update(dt)
    if self.ItemData then
        if self.ItemData.LostTime > 0 and not self.ItemData:isTimeOut() then
            self.TimeCount = self.TimeCount + dt
            if self.TimeCount > 0.5 then
                self:SetDesLabel()
                self.TimeCount = self.TimeCount - 0.5
            end
        end
    end
    if self.WeaponRotZ ~= nil then
        self.WeaponRotZ = self.WeaponRotZ + 150 * dt
        local _skin = self.ModelSkin.Skin
        if _skin ~= nil then
            local _trans = _skin.RootTransform
            UnityUtils.SetLocalEulerAngles(_trans, 0, 0, self.WeaponRotZ)
        end
    end
end

-- Find various controls on the UI
function UIItemTipsForm:FindAllComponents()
    local trans = self.Trans
    self.ParentTrans = trans:Find("Container")
    self.Panel = UIUtils.FindPanel(trans)

    -- Operation button
    local button = UIUtils.FindBtn(trans, "Container/Table/ButtonUse")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Use)

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonQu")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.TakeOut)

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonGet")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Get)

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonSell")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Sell)

    button = UIUtils.FindBtn(trans, "Container/Table/MarketBtn")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Stall)

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonBatch")
    UIUtils.AddBtnEvent(button, self.BatchBtnClick, self)
    self.ButtonDic:Add(button, ItemOpertion.Batch)
    self.BatchBtnGo = UIUtils.FindGo(trans, "Container/Table/ButtonBatch")

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonSynth")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Synth)

    button = UIUtils.FindBtn(trans, "Container/Table/ButtonGive")
    UIUtils.AddBtnEvent(button, self.TipsViewBtnFuction, self)
    self.ButtonDic:Add(button, ItemOpertion.Give)

    -- Close button
    button = UIUtils.FindBtn(trans, "Container/ButtonClose")
    UIUtils.AddBtnEvent(button, self.OnBtnCloseClick, self)
    self.QualityVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "Container/UIVfxSkinCompoent"))

    -- other
    self.ItemNameLabel = UIUtils.FindLabel(trans, "Container/Top/Name")
    self.ItemLevelLabel = UIUtils.FindLabel(trans, "Container/Top/ItemLevel/ItemLevel")
    self.ItemTypeLabel = UIUtils.FindLabel(trans, "Container/Top/ItemType/ItemType")
    self.ItemDesLabel = UIUtils.FindLabel(trans, "Container/ItemDesLabel")
    self.ItemDesLabelTrans = self.ItemDesLabel.transform
    self.ButtonTabel = UIUtils.FindTable(trans, "Container/Table")
    self.BackSprite = UIUtils.FindSpr(trans, "Container/Background")
    self.ItemUI = UILuaItem:New(trans:Find("Container/Top/UIItem"))
    self.ItemUI.IsShowTips = false
    self.QualityBack = UIUtils.FindSpr(trans, "Container/Background/QualityBack")
    self.ModelGo = UIUtils.FindGo(trans, "Model")
    self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(trans, "Model/UIRoleSkinCompoent"))
    if self.ModelSkin then
        self.ModelSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player, "show_idle")
        self.ModelSkin.Layer = LayerUtils.GetUITopLayer()
        self.ModelSkin.SkinAnimationCullingType = AnimatorCullingMode.AlwaysAnimate
    end
    self.PlayerSkin = UIUtils.RequireUIPlayerSkinCompoent(UIUtils.FindTrans(trans, "Model/UIRoleSkinCompoent2"))
    if self.PlayerSkin then
        self.PlayerSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player)
        self.PlayerSkin.Layer = LayerUtils.GetUITopLayer()
        self.PlayerSkin.SkinAnimationCullingType = AnimatorCullingMode.AlwaysAnimate
    end
    self.BgTex = UIUtils.FindTex(trans, "Model/BgTex")
    self.TtileVfx = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "Container/UITitleVfx"))
    self.TtileTex = UIUtils.FindTex(trans, "Container/TitleTex")

    local _glConfig = DataConfig.DataGlobal[GlobalName.Trade_maxitem]
    if _glConfig then
        self.MarketMaxCount =  tonumber(_glConfig.Params)
    end
end

-- Close button click and background click response
function UIItemTipsForm:OnBtnCloseClick()
    self:OnClose()
end

-- Use buttons to click
function UIItemTipsForm:BatchBtnClick()
    if self.ItemData.Count > 1 then
        GameCenter.PushFixEvent(UIEventDefine.UIITEMBATCH_OPEN, self.ItemData)
    else
        self:UseItem()
    end
end

-- Click the button, such as using the button
function UIItemTipsForm:TipsViewBtnFuction()
    local buttonType = nil
    -- Traversal button dictionary
    for k, v in pairs(self.ButtonDic) do
        if k == CS.UIButton.current then
            buttonType = v
        end
    end
    if buttonType == ItemOpertion.Use then
        if self.Location == ItemTipsLocation.PutInStorage then
            ItemContianerSystem.RequestToStore(self.ItemData.Index)
        elseif self.Location == ItemTipsLocation.Synth then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUT, self.ItemData)
        elseif self.Location == ItemTipsLocation.SynthPutOut then
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_ITEMSYNTH_ITEMPUTOUT, self.ItemData)
        elseif self.Location == ItemTipsLocation.OutStorage then
            ItemContianerSystem.RequestToBag(self.ItemData.Index)
        elseif (self.Location == ItemTipsLocation.Market) then
            if GameCenter.ShopAuctionSystem.MarketOwnInfoDic:Count() >=  self.MarketMaxCount then
                Utils.ShowPromptByEnum("C_UI_TIPS_AUCTIONMAX", self.MarketMaxCount)
            else
                local _data = {}
                _data.Data = self.ItemData
                _data.PanelType = ShopAuctionPutType.PutIn
                GameCenter.PushFixEvent(UIEventDefine.UIShopAuctionShelvesForm_OPEN, _data)
            end
        else
            if self.ItemData:IsCanUse(ItemOpertion.Use) == false then
                GameCenter.MsgPromptSystem.ShowPrompt(DataConfig.DataMessageString.Get("C_ITEM_CANNOTUSE"))
            else
                if self.ItemData:IsNeedSecond() and self.ItemData.IsBind == false and self.ItemData.ItemInfo.Bind == 2 then
                    local sText = nil
                    self:RemoveCameraClickEvent()
                    sText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_ITEM_USE_BIND_TIPS"), UIUtils.CSFormat("[{0}]{1}[-]", Utils.GetQualityStrColor(self.ItemData.ItemInfo.Color), self.ItemData.Name))
                    GameCenter.MsgPromptSystem:ShowMsgBox(sText, DataConfig.DataMessageString.Get("C_MSGBOX_NO"), DataConfig.DataMessageString.Get("C_MSGBOX_YES"), function(x)
                        if x == MsgBoxResultCode.Button2 then
                            self:UseItem()
                        else
                            self:AddCameraClickEvent()
                        end
                    end)
                else
                    self:UseItem()
                end
                return
            end
        end
    elseif buttonType == ItemOpertion.Sell then
        if self.ItemData:IsNeedSecond() then
            self:RemoveCameraClickEvent()
            local sText = nil
            sText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_ITEM_SELL_CONFIRM_TIPS"), UIUtils.CSFormat("[{0}]{1}[-]", Utils.GetQualityStrColor(self.ItemData.ItemInfo.Color), self.ItemData.Name))
            GameCenter.MsgPromptSystem:ShowMsgBox(sText, DataConfig.DataMessageString.Get("C_MSGBOX_NO"), DataConfig.DataMessageString.Get("C_MSGBOX_YES"), function(x)
                if x == MsgBoxResultCode.Button2 then
                    self:SellItem()
                else
                    self:AddCameraClickEvent()
                end
            end)
        else
            self:SellItem()
        end
        return
    elseif buttonType == ItemOpertion.Get then
        GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.ItemData.CfgID)
        -- When you click on the props on the reward interface, you need to close the reward interface
        GameCenter.PushFixEvent(UIEventDefine.UIGetNewItemForm_CLOSE)
        GameCenter.PushFixEvent(UIEventDefine.UITHJRXYGetNewItemForm_CLOSE)
    elseif buttonType == ItemOpertion.Synth then
        local objct = { BagFormSubEnum.Synth, self.ItemData}
        GameCenter.PushFixEvent(UIEventDefine.UIPlayerBagBaseForm_OPEN, objct)
    elseif buttonType == ItemOpertion.Stall then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(UnityUtils.GetObjct2Int(FunctionStartIdCode.AuchtionSell), self.ItemData.DBID)
    elseif buttonType == ItemOpertion.Give then
        GameCenter.PushFixEvent(UIEventDefine.UISendGiftForm_OPEN, {0, self.ItemData})
    elseif buttonType == ItemOpertion.TakeOut then
        -- Immortal Armor Treasure Hunt
        if self.Location == ItemTipsLocation.XJTreasure then
            GameCenter.XJXunbaoSystem:ReqExtractByUID(self.ItemData.DBID)
        end
    end
    self:OnClose()
end
-- Use buttons
function UIItemTipsForm:UseItem()
    if self.ItemData.CfgID == GameCenter.WorldSupportSystem.TanksItemID then
        GameCenter.WorldSupportSystem:ReqAtLastHelp()
    else
        self.ItemData:UseItem()
    end
    self:OnClose()
end

-- Open other feature panels
function UIItemTipsForm:OpenFunction()
    -- GameCenter.MainFunctionSystem:DoFunctionCallBack(self.ItemData.ItemInfo.UesUIId, nil)
end

-- Items for sale
function UIItemTipsForm:SellItem()
    if  self.ItemData.Count > 1 then
        GameCenter.PushFixEvent(UIEventDefine.UIITEMBATCH_OPEN, {self.ItemData})
    else
        ItemContianerSystem.RequestSellItem(self.ItemData.DBID)
    end
    self:OnClose()
end

-- Set the specific content on the tips panel
function UIItemTipsForm:SetItemInfo()
    self:SetShowModel()
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer()
    if self.ItemData ~= nil and localPlayer ~= nil then
        UIUtils.SetTextByString(self.ItemNameLabel, self.ItemData.Name)
        UIUtils.SetColorByQuality(self.ItemNameLabel, self.ItemData.Quality)

        local levelValue = 1
        if self.ItemData.ItemInfo then
            levelValue = CommonUtils.GetLevelDesc(self.ItemData.ItemInfo.Level)
        end
        local typeString = "";
        if (self.ItemData:CheckLevel(localPlayer.Level)) then
            UIUtils.SetColorByString(self.ItemLevelLabel, "#00EE00")
        else
            UIUtils.SetColorByString(self.ItemLevelLabel, "#CD0000")
        end
        UIUtils.SetTextByEnum(self.ItemLevelLabel, "C_MAIN_NON_PLAYER_SHOW_LEVEL", levelValue)

        typeString = LuaItemBase.GetTypeNameWitType(self.ItemData.Type)
        if typeString ~= nil then
            UIUtils.SetTextByString(self.ItemTypeLabel, typeString)
        end

        self.ItemUI:InitWithItemData(self.ItemData, 0, false, self.IsShowGet, self.Location)
        self.ItemUI.IsShowTips = false
        self:SetDesLabel()
        self.QualityBack.spriteName = Utils.GetQualityBackName(self.ItemData.Quality)
        if self.QualityVfx and self.ItemData.Quality >= 6 then
            self.QualityVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, 126 + self.ItemData.Quality, LayerUtils.GetUITopLayer())
        end
    end
end

function UIItemTipsForm:SetDesLabel()
    local _str = nil
    if self.ItemData.ItemInfo.EffectNum and self.ItemData.ItemInfo.EffectNum ~= "" then
        local _ar = Utils.SplitNumber(self.ItemData.ItemInfo.EffectNum, '_')
        if _ar[1] then
            if _ar[1] == 10 and _ar[2] and _ar[3] then
                local _lp = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
                if _lp < _ar[2] then
                    _lp = _ar[2]
                elseif _lp > _ar[3] then
                    _lp = _ar[3]
                end
                local _cfg = DataConfig.DataCharacters[_lp]
                if _cfg then
                    _str = UIUtils.CSFormat(self.ItemData.ItemInfo.Description, CommonUtils.CovertToBigUnit(_cfg.Exp / 10000 * _ar[4], 4))
                end
            end
        end
    end
    if not _str then
        _str = self.ItemData.ItemInfo.Description
    end
    if self.ItemData.LostTime > 0 then
        if self.ItemData:isTimeOut() then
            _str = DataConfig.DataMessageString.Get("C_UI_TIPS_TIMEOUT") .. _str
        else
            local _remainTime = self.ItemData.LostTime - GameCenter.HeartSystem.ServerTime
            local d, h, m, s = Time.SplitTime(math.floor( _remainTime ))
            if d > 0 then
                _str = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_UI_ITEMTIPS_TIME1"), d, h, m, s) .. _str
            else
                if h > 0 then
                    _str = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_UI_ITEMTIPS_TIME2"), h, m, s) .. _str
                else
                    if m > 0 then
                        _str = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_UI_ITEMTIPS_TIME3"), m, s) .. _str
                    else
                        _str = UIUtils.CSFormat( DataConfig.DataMessageString.Get("C_UI_ITEMTIPS_TIME4"), s) .. _str
                    end
                end
            end
        end
    end
    UIUtils.SetTextByString(self.ItemDesLabel, _str)
    self.CSForm.AnimModule:UpdateAnchor(self.Trans)
    self:AdapterTipsPos()
end

function UIItemTipsForm:SetShowModel()
    self.ModelGo:SetActive(false)
    if self.PlayerSkin then
        self.PlayerSkin:ResetSkin()
    end
    if self.ModelSkin then
        self.ModelSkin:ResetSkin()
    end
    if self.TtileVfx then
        self.TtileVfx:OnDestory()
    end
    self.CSForm:UnloadTexture(self.TtileTex)
    UnityUtils.SetLocalPositionY(self.ItemDesLabelTrans, -153)
    self.WeaponRotZ = nil
    if self.ItemData ~= nil and self.ItemData.ItemInfo then
        local _cfg = self.ItemData.ItemInfo
        if _cfg.ShowType > 0 and _cfg.ShowId and string.len(_cfg.ShowId) > 0 then
            if _cfg.ShowType == 4 then
                self.TtileVfx:OnCreateAndPlay(ModelTypeCode.UIVFX, tonumber(_cfg.ShowId), LayerUtils.GetUITopLayer())
                UnityUtils.SetLocalPositionY(self.ItemDesLabelTrans, -248)
            elseif _cfg.ShowType == 5 then
	            self.CSForm:LoadTexture(self.TtileTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format("tex_chenghao_%s", _cfg.ShowId)))
                UnityUtils.SetLocalPositionY(self.ItemDesLabelTrans, -248)
            else
                self.ModelGo:SetActive(true)
                self.ModelSkin:ResetSkin()
                local _table = Utils.SplitStr(_cfg.ShowId, '_')
                if _table[1] then
                    if _cfg.ShowType == 3 then
                        self.PlayerSkin:SetEquip(FSkinPartCode.Body, RoleVEquipTool.GetLPBodyModel());
                        self.PlayerSkin:SetEquip(FSkinPartCode.Wing, tonumber(_table[1]));
                        self.PlayerSkin:SetEquip(FSkinPartCode.GodWeaponHead, RoleVEquipTool.GetLPWeaponModel());
                        self.PlayerSkin.EnableDrag = true
                        self.ModelSkin.EnableDrag = false
                        self.PlayerSkin:ResetRot()
                    else
                        self.ModelSkin:SetEquip(FSkinPartCode.Body, tonumber(_table[1]))
                        self.PlayerSkin.EnableDrag = false
                        self.ModelSkin.EnableDrag = true
                        local _modCfg = DataConfig.DataModelConfig[tonumber(_table[1])]
                        if _modCfg ~= nil and _modCfg.Type == 2 or _modCfg.Type == 9 then
                            self.WeaponRotZ = 0
                        end
                    end
                end
                local _scale = 320
                if _table[2] then
                    _scale = tonumber(_table[2])
                end
                self.ModelSkin:SetLocalScale(_scale)
                local _posX = 0
                local _posY = 0
                local _posZ = 0
                if _table[3] then
                    _posY = tonumber(_table[3])
                    if _table[7] then
                        _posX = tonumber(_table[7])
                    end
                    if _table[8] then
                        _posZ = tonumber(_table[8])
                    end
                end
                self.ModelSkin:SetPos(_posX, _posY, _posZ)

                local angleX = 0
                local angleY = 180
                local angleZ = 0
                if _table[5] then
                    angleX = tonumber(_table[5])
                end
                if _table[4] then
                    angleY = tonumber(_table[4])
                end
                if _table[6] then
                    angleZ = tonumber(_table[6])
                end
                self.ModelSkin:SetEulerAngles(angleX, angleY, angleZ)
                self.ModelSkin:ResetRot()
                if angleX ~= 0 or angleZ ~= 0 then
                    self.PlayerSkin.EnableDrag = false
                    self.ModelSkin.EnableDrag = false
                end
                local _skin = self.ModelSkin.Skin
                if _skin ~= nil then
                    local _trans = _skin.RootTransform
                    UnityUtils.SetLocalEulerAngles(_trans, 0, 0, 0)
                end
                if self.ItemData.ItemInfo.ShowType == 1 then
                    self.ModelSkin.Skin:SetDefaultAnim("show_idle", AnimationPartType.AllBody)
                    self.ModelSkin:Play("show", AnimationPartType.AllBody, WrapMode.Once, 1)
                elseif _cfg.ShowType ~= 3 then
                    self.ModelSkin:Play("idle", AnimationPartType.AllBody, WrapMode.Loop, 1)
                    self.ModelSkin.Skin:SetDefaultAnim("idle", AnimationPartType.AllBody)
                end
            end
        end
    end
end

function UIItemTipsForm:ResetFucBtn(isShow)
    -- //Adjust the button position
    if self.ItemData == nil then
        Debug.LogError("Item information does not exist, please check the reason ItemTipsForm");
        return
    end
    local willShowBtn = Dictionary:New()

    for k, v in pairs(self.ButtonDic) do
        k.gameObject:SetActive(false)
        if isShow then
            if v == ItemOpertion.Get then
                local _getText = self.ItemData.ItemInfo.GetText
                if _getText ~= nil and string.len(_getText) > 0 then
                    willShowBtn:Add(v, k)
                end
            end
        else
            if self.Location == ItemTipsLocation.PutInStorage or self.Location == ItemTipsLocation.Synth then
                if v == ItemOpertion.Use then
                    local name = UIUtils.FindLabel(k.transform, "Text")
                    UIUtils.SetTextByEnum(name, "C_ITEM_BAGTOSTORAGE")
                    willShowBtn:Add(v, k)
                end
            elseif self.Location == ItemTipsLocation.OutStorage or self.Location == ItemTipsLocation.SynthPutOut then
                if v == ItemOpertion.Use then
                    local name = UIUtils.FindLabel(k.transform, "Text")
                    UIUtils.SetTextByEnum(name, "C_ITEM_STORAGETOBAG")
                    willShowBtn:Add(v, k)
                end
            elseif self.Location == ItemTipsLocation.EquipSelect then
                if v == ItemOpertion.Use then
                    local name = UIUtils.FindLabel(k.transform, "Text")
                    UIUtils.SetTextByEnum(name, "C_ITEM_BAGTOSTORAGE")
                    willShowBtn:Add(v, k)
                end
            elseif self.Location == ItemTipsLocation.Market then
                if v == ItemOpertion.Use then
                    local name = UIUtils.FindLabel(k.transform, "Text")
                    UIUtils.SetTextByEnum(name, "UI_EQUIP_EQUIPSHANGJIA")
                    willShowBtn:Add(v, k)
                end
            else
                if v == ItemOpertion.Use and self.Location == ItemTipsLocation.Bag
                    and self.ItemData.Type ~= ItemType.Task and self.ItemData:IsCanUse(ItemOpertion.Use) then
                    local name = UIUtils.FindLabel(k.transform, "Text")
                    UIUtils.SetTextByEnum(name, "C_ITEM_USE")
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Sell and self.Location == ItemTipsLocation.Bag
                    and (self.ItemData:IsCanUse(ItemOpertion.Sell) or self.ItemData:isTimeOut()) then
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Stall and self.Location == ItemTipsLocation.Bag
                    and self.ItemData.IsBind == false and self.ItemData:IsCanUse(ItemOpertion.Stall) then
                    --and GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.AuctionHouse)
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Batch and self.Location == ItemTipsLocation.Bag
                    and self.ItemData:IsCanUse(ItemOpertion.Batch) and self.ItemData.Type ~= ItemType.SpecialBox then
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Synth and self.Location == ItemTipsLocation.Bag
                    and self.ItemData:IsCanUse(ItemOpertion.Synth) then
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Give and self.Location == ItemTipsLocation.Bag and self.ItemData:IsCanUse(ItemOpertion.Give) then
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.Get and self.Location == ItemTipsLocation.Bag and self.ItemData:IsCanUse(ItemOpertion.Get) then
                    willShowBtn:Add(v, k)
                elseif v == ItemOpertion.TakeOut and self.Location == ItemTipsLocation.XJTreasure then
                    willShowBtn:Add(v, k)
                end
            end
        end                
    end
    for k, v in pairs(willShowBtn) do
        v.gameObject:SetActive(true)
    end
    self.ButtonTabel.repositionNow = true
end
function UIItemTipsForm:AdapterTipsPos()
    local _height = self.BackSprite.height
    if self.ItemData ~= nil and self.ItemData.ItemInfo then
        local _cfg = self.ItemData.ItemInfo
        if _cfg.ShowType > 0 and _cfg.ShowType ~= 4 and _cfg.ShowType ~= 5 and _cfg.ShowId and string.len(_cfg.ShowId) > 0 then
            UnityUtils.SetLocalPosition(self.ParentTrans, 50, _height / 2, 0)
            return
        end
    end
    local _width = self.BackSprite.width
    UnityUtils.SetLocalPosition(self.ParentTrans, -_width / 2, _height / 2, 0)
end
return UIItemTipsForm
