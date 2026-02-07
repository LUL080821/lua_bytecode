------------------------------------------------
-- author:
-- Date: 2021-03-04
-- File: UIEquipmentItem.lua
-- Module: UIEquipmentItem
-- Description: Equipment lattice universal components
------------------------------------------------
local L_Itembase = CS.Thousandto.Code.Logic.ItemBase
local UIEquipmentItem = {
    Trans = nil,
    Go = nil,
    BackSpriteTrans = nil, -- Background color
    QualtySprite = nil,    -- quality
    EquipIcon = nil,       -- Equipment icon
    BindSpriteGo = nil,    -- Bind
    StageLevel = nil,      -- Order
    StrengthLevel = nil,   -- Strengthening level
    StarLevel = nil,       -- Star rating
    StarSpriteGo = nil,    -- Star rating pictures
    Equipment = nil,       -- The equipment data displayed
    EffectSpriteGo = nil,  -- Equipment effect
    EffectAni = nil,       -- Frame animation
    EquipInvalidGo = nil,  -- Equipment failure pictures
    EquipSelectGo = nil,   -- Select
    EquipRedGo = nil,      -- Strengthen red dots
    UpEquipSpriteGo = nil, -- Better equipment
    StarNumLabel = nil,    -- Equipment Star Rating
    DiamondGrid = nil,
    Effect2Ani = nil,      -- Special effects of fairy armor equipment
    EffectVFX = nil,       -- New equipment special effects
    LvBackTrans = nil,
    SingleClick = nil,
    CallBack = nil,
    CurType = 0,
}

function UIEquipmentItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.BackSpriteTrans = UIUtils.FindTrans(trans, "bg")
    if _m.BackSpriteTrans then
        _m.BackSprIcon = UIUtils.RequireUIIconBase(_m.BackSpriteTrans)
    end
    _m.EquipIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "EquipIcon"))
    _m.BindSpriteGo = UIUtils.FindGo(trans, "Bind")
    _m.StageLevel = UIUtils.FindLabel(trans, "Level")
    if (_m.StageLevel ~=nil) then
        _m.StageLevel.gameObject:SetActive(false)
    end
    _m.StrengthLevel = UIUtils.FindLabel(trans, "Intensify")
    _m.StarLevel = UIUtils.FindLabel(trans, "Star/Label")
    _m.StarSpriteGo = UIUtils.FindGo(trans, "Star")
    _m.QualtySprite = UIUtils.FindSpr(trans, "Qualty")

    local transs = UIUtils.FindTrans(trans, "Effect2");
    if transs then
        _m.Effect2Ani = UIUtils.RequireUISpriteAnimation(transs)
        _m.Effect2Ani.namePrefix = "item1_"
        _m.Effect2Ani.framesPerSecond = 10
        _m.Effect2Ani.PrefixSnap = false
    end
    transs = UIUtils.FindTrans(trans, "Grid")
    if transs then
        _m.DiamondGrid = UIUtils.FindGrid(transs)
    end
    transs = UIUtils.FindTrans(trans, "Effect")
    if transs then
        _m.EffectSpriteGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "Invalid")
    if transs then
        _m.EquipInvalidGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "Select")
    if transs then
        _m.EquipSelectGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "Red")
    if transs then
        _m.EquipRedGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "up")
    if transs then
        _m.UpEquipSpriteGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "LvBg")
    if transs then
        _m.LvBackGo = UIUtils.FindGo(transs);
    end
    transs = UIUtils.FindTrans(trans, "UIVfxSkinCompoent")
    if transs then
        _m.EffectVFX = UIUtils.RequireUIVfxSkinCompoent(transs)
    end
    local numTran = UIUtils.FindTrans(trans, "Effect1")
    if numTran then
        _m.EffectAni = UIUtils.RequireUISpriteAnimation(numTran)
        _m.EffectAni.namePrefix = "item_"
        _m.EffectAni.framesPerSecond = 10
        _m.EffectAni.PrefixSnap = false
    end
    numTran = UIUtils.FindTrans(trans, "StarNum");
    if numTran then
        _m.StarNumLabel = UIUtils.FindLabel(numTran)
    end
    local btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(btn, _m.OnOwnClick, _m)
    return _m
end

function UIEquipmentItem:SetStrengthLv(lv )
    UIUtils.SetTextFormat(self.StrengthLevel, "+{0}", lv)
end

function UIEquipmentItem:SetSoulLv(lv)
    UIUtils.SetTextByEnum(self.StageLevel, "LEVEL_FOR_JIE", lv)
end

function UIEquipmentItem:UpdateEquipmentByType(type, starLevel, isShowStar)
    if not isShowStar then
        isShowStar = false
    end
    self:UpdateEquipment(nil, type, starLevel, isShowStar)
end

function UIEquipmentItem:UpdateEquipment(eqpment, type, starLevel, isShowStar, strengthLv)
    if not isShowStar then
        isShowStar = false
    end
    if not strengthLv then
        strengthLv = -1
    end
    if self.EffectVFX then
        self.EffectVFX:OnDestory();
    end
    self.CurType = type;
    if self.Effect2Ani then
        self.Effect2Ani.gameObject:SetActive(false)
    end
    if self.BackSpriteTrans and eqpment == nil then
        local glItem = GameCenter.EquipmentSystem.DefaultEquipIconDic;
        if glItem:ContainsKey(type) then
            self.BackSprIcon:UpdateIcon(glItem[type])
            self.BackSpriteTrans.gameObject:SetActive(true)
        end
        self:OnSetEffect(0);
        self:OnSetDiamondSpr(0);
    end
    if self.LvBackGo then
        -- self.LvBackGo:SetActive(eqpment ~= nil);
        self.LvBackGo:SetActive(false); --[Gosu] ẩn Lvbg
    end
    self.EquipIcon.gameObject:SetActive(false)
    self.BackSpriteTrans.gameObject:SetActive(true)
    self.BindSpriteGo:SetActive(false);
    UIUtils.ClearText(self.StageLevel)
    self.StarSpriteGo:SetActive(false);
    self.StarLevel.gameObject:SetActive(false);
    self.QualtySprite.gameObject:SetActive(false);
    if self.EquipSelectGo then
        self.EquipSelectGo:SetActive(false);
    end
    if self.EquipRedGo then
        self.EquipRedGo:SetActive(false);
    end
    if self.UpEquipSpriteGo then
        self.UpEquipSpriteGo:SetActive(false);
    end
    if ( eqpment == nil ) then
        self.StrengthLevel.gameObject:SetActive( false )
    else
        local lv = strengthLv ~= -1 and strengthLv or GameCenter.LianQiForgeSystem:GetStrengthLvByPos(type)
        self.StrengthLevel.gameObject:SetActive( true )
        UIUtils.SetTextFormat(self.StrengthLevel, "+{0}", lv)
    end

    if isShowStar then
        self.EffectSpriteGo:SetActive(false);
    else
        self.Equipment = eqpment;
        if self.Equipment then
            local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
            if self.Equipment.Type == ItemType.Equip or self.Equipment.Type == ItemType.ImmortalEquip
                or self.Equipment.Type == ItemType.PetEquip or self.Equipment.Type == ItemType.HorseEquip then
                -- Load altas
                self.EquipIcon:UpdateIcon(self.Equipment.Icon);
                if self.BackSpriteTrans then
                    self.BackSpriteTrans.gameObject:SetActive(false);
                end
                -- Handle icon
                self.EquipIcon.gameObject:SetActive(true);

                -- Handle binding and restrictions
                self.BindSpriteGo:SetActive(self.Equipment.IsBind);
                self:OnSetEffect(self.Equipment.Effect);
                self:OnSetDiamondSpr(self.Equipment.StarNum);
                if self.Equipment:CheackOcc(_occ) and self.UpEquipSpriteGo then
                    self.UpEquipSpriteGo:SetActive(self.Equipment:CheckBetterThanDress());
                end
                if self.Equipment.Type == ItemType.ImmortalEquip then
                    UIUtils.ClearText(self.StageLevel)
                elseif self.Equipment.Type == ItemType.PetEquip then
                    UIUtils.SetTextByEnum(self.StageLevel, "LEVEL_FOR_JIE", starLevel)
                elseif self.Equipment.Type == ItemType.HorseEquip then
                    UIUtils.SetTextByEnum(self.StageLevel, "LEVEL_FOR_JIE", self.Equipment.Grade)
                else
                    UIUtils.SetTextByEnum(self.StageLevel, "LEVEL_FOR_JIE", self.Equipment.Grade)
                end
                self.QualtySprite.gameObject:SetActive(true);
                self.QualtySprite.spriteName = Utils.GetQualitySpriteName(self.Equipment.Quality)
            end
        end
        if self.EquipInvalidGo then
            self.EquipInvalidGo:SetActive(false);
        end
        if self.EquipRedGo then
            self.EquipRedGo:SetActive(false);
        end
    end
end

function UIEquipmentItem:OnSelectItem(isShow)
    if self.EquipSelectGo then
        self.EquipSelectGo:SetActive(isShow);
    end
end

function UIEquipmentItem:OnSetStrengthShow(isShow)
    if self.StrengthLevel then
        self.StrengthLevel.gameObject:SetActive(isShow);
    end
end

function UIEquipmentItem:OnUpdateForID(cfgID)
    local item = LuaItemBase.CreateItemBase(cfgID);
    self:UpdateEquipment(item, item.Part, 0)
end

function UIEquipmentItem:OnSetRed(isShow)
    if self.EquipRedGo then
        self.EquipRedGo.gameObject:SetActive(isShow);
    end
end

function UIEquipmentItem:OnOwnClick()
    if self.SingleClick then
        self.SingleClick(self.Go);
    end
    if self.CallBack then
        self.CallBack(self);
    end
end

-- Set special effects pictures, picture effects and frame animations
function UIEquipmentItem:OnSetEffect(effectID)
    if (effectID == 1 or effectID == 3) and self.EffectSpriteGo then
        self.EffectSpriteGo:SetActive(true);
    elseif  self.EffectSpriteGo then
        self.EffectSpriteGo:SetActive(false);
    end
    if (effectID == 2 or effectID > 3) and self.EffectAni then
        self.EffectAni.gameObject:SetActive(true);
        if (effectID == 2) then
            self.EffectAni.namePrefix = "item_";
        elseif (effectID == 4) then
            self.EffectAni.namePrefix = "item3_";
        elseif (effectID == 5) then
            self.EffectAni.namePrefix = "item4_";
        elseif (effectID == 6) then
            self.EffectAni.namePrefix = "item5_";
        elseif (effectID == 7) then
            self.EffectAni.namePrefix = "item6_";
        end
    elseif self.EffectAni then
        self.EffectAni.gameObject:SetActive(false);
    end
    if effectID == 3 and self.Effect2Ani then
        self.Effect2Ani.gameObject:SetActive(true);
    elseif self.Effect2Ani then
        self.Effect2Ani.gameObject:SetActive(false);
    end
end

-- Set diamond pictures
function UIEquipmentItem:OnSetDiamondSpr(diaNum)
    if self.DiamondGrid == nil then
        return;
    end
    --self.DiamondGrid.gameObject:SetActive(diaNum <= 5)
    self.DiamondGrid.gameObject:SetActive(false)
    if self.StarNumLabel then
        self.StarNumLabel.gameObject:SetActive(diaNum > 5);
    end
    if diaNum > 5 and self.StarNumLabel then
        UIUtils.SetTextByNumber(self.StarNumLabel, diaNum)
    else
        local childGo = nil
        local oldCount = self.DiamondGrid.transform.childCount
        for i = 1, diaNum do
            if i <= oldCount then
                childGo = self.DiamondGrid.transform:GetChild(i - 1).gameObject
            else
                childGo = UnityUtils.Clone(childGo)
            end
            if childGo ~= nil then
                childGo:SetActive(true)
            end
        end
        for i = diaNum + 1, oldCount do
            childGo = self.DiamondGrid.transform:GetChild(i - 1).gameObject
            if childGo ~= nil then
                childGo:SetActive(false)
            end
        end
    end
    self.DiamondGrid.repositionNow = true
end
return UIEquipmentItem