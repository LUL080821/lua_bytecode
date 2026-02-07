------------------------------------------------
-- Author: 
-- Date: 2019-04-28
-- File: UIItem.lua
-- Module: UIItem
-- Description: Item lattice common components
------------------------------------------------

local UIItem ={
    RootTrans = nil,
    RootGO = nil,
    gameObject = nil,
    -- Quality frame pictures
    QualitySpr = nil,
    -- Bind pictures
    BindSpr = nil,
    -- Frame animation
    EffectAniGO = nil,
    EffectScript = nil,
    Effect2AniGO = nil,
    Effect2Script = nil,
    -- Equipment material effect
    EffectGO = nil,
    -- Not available
    UnUseGo = nil,
    -- quantity
    NumLabel = nil,
    -- Equipment order
    LevelLabel = nil,
    -- Equipment Star Rating
    StarGrid = nil,
    -- Upward arrow indicates that the equipment has a higher score than the equipment on the body
    UpTransGo = nil,
    -- icon icon
    Icon = nil,
    IconSpr = nil,
    -- Grid lock icon
    LockGo = nil,
    -- Plus icon, in some places, click to add material
    AddSprGo = nil,
    -- Select the picture
    SelectGo = nil,
    Btn = nil,
    Location = ItemTipsLocation.Defult,
    IsBindBagNum = false,
    IsRegisterBagMsg = false,
    ShowNum = 0,
    IsShowTips = false,
    IsShowAddSpr = false,
    IsShowGet = false,
    ShowItemData = nil,
    ExtData = nil,
    SingleClick = nil,
    -- Is it a single number
    IsSingleNum = false,

    -- [Gosu] thêm label cường hóa
    StrengthLevel = nil,   -- Strengthening level
    StrengthLevelLabel = nil,
}

local L_ItemMap = {}

function UIItem:New(res)
    local _tmp = L_ItemMap[res]
    if _tmp ~= nil then
        _tmp:CanelBindBagNum()
        return _tmp
    end
    local _M = Utils.DeepCopy(self)
    _M.RootTrans = res
    _M.RootGO = res.gameObject
    _M.gameObject = _M.RootGO
    local trans = UIUtils.FindTrans(_M.RootTrans, "Quality")
    if trans ~= nil then
        _M.QualitySpr = UIUtils.FindSpr(_M.RootTrans, "Quality")
    end
    _M.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_M.RootTrans, "Icon"))
    _M.IconSpr = UIUtils.FindSpr(_M.RootTrans, "Icon")
    trans = UIUtils.FindTrans(_M.RootTrans, "Bind")
    if(trans ~= nil) then
        _M.BindSpr = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Effect")
    if(trans ~= nil) then
        _M.EffectGO = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Effect1")
    if(trans ~= nil) then
        _M.EffectAniGO = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Effect2")
    if(trans ~= nil) then
        _M.Effect2AniGO = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "XJbg")
    if(trans ~= nil) then
        _M.XJbgGo = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Num")
    if(trans ~= nil) then
        _M.NumLabel = UIUtils.FindLabel(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "NameLabel")
    if(trans ~= nil) then
        _M.NameLabel = UIUtils.FindLabel(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Level")
    if(trans ~= nil) then
        _M.LevelLabel = UIUtils.FindLabel(trans)
        if _M.LevelLabel ~= nil then
            --_M.LevelLabel.gameObject:SetActive(true)
            _M.LevelLabel.gameObject:SetActive(false)
        end
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Lock")
    if(trans ~= nil) then
        _M.LockGo = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Add")
    if(trans ~= nil) then
        _M.AddSprGo = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Select")
    if(trans ~= nil) then
        _M.SelectGo = trans.gameObject
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Grid")
    if(trans ~= nil) then
        _M.StarGrid = UIUtils.FindGrid(trans)
        _M.StarGridGo = UIUtils.FindGo(trans)
        if _M.StarGrid ~= nil then
            _M.StarGrid.gameObject:SetActive(false)
        end
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "up")
    if(trans ~= nil) then
        _M.UpTransGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "LvBg")
    if(trans ~= nil) then
        _M.LvBgGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "StarNum")
    if(trans ~= nil) then
        _M.StarNumLabel = UIUtils.FindLabel(trans)
        _M.StarNumGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "Title")
    if(trans ~= nil) then
        _M.TitleLabel = UIUtils.FindLabel(trans, "Label")
        _M.TitleGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(_M.RootTrans, "UnUseSprite")
    if(trans ~= nil) then
        _M.UnUseGo = UIUtils.FindGo(trans)
    end

    -- [Gosu] lấy thông tin cường hóa vật phẩm trong túi
    trans = UIUtils.FindTrans(_M.RootTrans, "Intensify")
    if(trans ~= nil) then
        _M.StrengthLevel = trans.gameObject
        _M.StrengthLevelLabel = UIUtils.FindLabel(trans, "")
    end

    _M.Location = ItemTipsLocation.Defult

    _M.Btn = UIUtils.FindBtn(_M.RootTrans)
    UIUtils.AddBtnEvent(_M.Btn, _M.OnBtnItemClick, _M)
    _M.IsShowTips = true
    LuaBehaviourManager:Add(_M.RootTrans, _M)
    L_ItemMap[res] = _M;
    return _M
end

-- Clone an object
function UIItem:Clone()
    local _trans = UnityUtils.Clone(self.RootGO)
    return UIItem:New(_trans.transform)
end

function UIItem:InitWithItemData(itemInfo, num, mastShowNum, isShowGetBtn, location, extData)
    -- Debug.Log("yy InitWithItemData")
    self.ShowItemData = itemInfo
    self.IsEnough = false
    local _unUseGoActive = false
    local _upTransGoActive = false
    local _addSprGoActive = false
    local _xjbgGoActive = false
    local _clearLevelLabel = true
    local _showLvBg = false
    if(isShowGetBtn ~= nil) then
        self.IsShowGet = isShowGetBtn
    end
    if location ~= nil then
        self.Location = location
    end
    self.ExtData = extData
    if num == nil and itemInfo ~= nil then
        num = itemInfo.Count
    end
    -- [Gosu] reset cường hóa khi slot rỗng
    if self.StrengthLevel then
        self.StrengthLevel:SetActive(false)
    end
    if self.ShowItemData ~= nil and self.ShowItemData:IsValid() == true then
        -- Debug.Log("yy InitWithItemData 111")
        local _itemType = self.ShowItemData.Type
        if _itemType == ItemType.ImmortalEquip then
            _xjbgGoActive = true
        end
        if _itemType == ItemType.Equip or _itemType == ItemType.HolyEquip or _itemType == ItemType.UnrealEquip
            or _itemType == ItemType.ImmortalEquip or _itemType == ItemType.SoulPearl then
            local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if lp ~= nil then
                if (self.ShowItemData:CheackOcc(lp.IntOcc)) and self.UpTransGo ~= nil then
                    _upTransGoActive = self.ShowItemData:CheckBetterThanDress()
                end
                if self.UnUseGo ~= nil then
                    _unUseGoActive = not self.ShowItemData:CheackOcc(lp.IntOcc)
                end
            end
            if self.LevelLabel ~= nil and _itemType ~= ItemType.ImmortalEquip and _itemType ~= ItemType.SoulPearl then
                _clearLevelLabel = false
                UIUtils.SetTextByEnum(self.LevelLabel, "LEVEL_FOR_JIE", self.ShowItemData.Grade)
                _showLvBg = true
            end

            -- [Gosu] check hiển thị label cường hóa

            if self.StrengthLevel then
                self.StrengthLevel:SetActive(false)
            end
            local lv = self:GetStrengthLevel(itemInfo.DBID)
            if lv and self.StrengthLevel then
                self.StrengthLevel:SetActive(lv > 0)
                if self.StrengthLevelLabel then
                    UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
                end
            end
        end
        if _itemType == ItemType.MonsterSoulEquip then
            if self.UpTransGo then
                _upTransGoActive = GameCenter.MonsterSoulSystem:CheckBetterThanDress(self.ShowItemData, self.ExtData)
            end
            if self.LevelLabel ~= nil then
                if self.ShowItemData.StrengthLevel > 0 then
                    _clearLevelLabel = false
                    UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.ShowItemData.StrengthLevel)
                    _showLvBg = true
                else
                    _clearLevelLabel = true
                end
            end
        end
        if _itemType == ItemType.PetEquip and location and location == ItemTipsLocation.Equip and extData and type(extData) == "number" then
            if self.LevelLabel ~= nil then
                local _lv = GameCenter.PetEquipSystem:GetPetEquipSoulLv(extData, self.ShowItemData.Part)
                UIUtils.SetTextByEnum(self.LevelLabel, "LEVEL_FOR_JIE", _lv)
                _showLvBg = true
                _clearLevelLabel = false
            end
        end
        if self.ShowItemData.Type == ItemType.HorseEquip then
            if self.LevelLabel ~= nil then
                _clearLevelLabel = false
                UIUtils.SetTextByEnum(self.LevelLabel, "LEVEL_FOR_JIE", self.ShowItemData.Grade)
                _showLvBg = true
            end
        end
        -- Debug.Log("yy self.ShowItemData.Icon "..tostring(self.ShowItemData.Icon))
        self.Icon:UpdateIcon(self.ShowItemData.Icon)
        if self.QualitySpr ~= nil then
            self.QualitySpr.spriteName = Utils.GetQualitySpriteName(self.ShowItemData.Quality)
        end
        if _itemType == ItemType.LingPo then
            -- Spirit Soul Get Spirit Soul Configuration Table Data
            local _immCfg = DataConfig.DataImmortalSoulAttribute[self.ShowItemData.CfgID]
            if _immCfg ~= nil then
                self:OnSetStarSpr(_immCfg.Star)
            else
                self:OnSetStarSpr(0)
            end
        else
            self:OnSetStarSpr(self.ShowItemData.StarNum)
        end
        self:OnSetEffect(self.ShowItemData.Effect)
        if self.NumLabel ~= nil then
            if num > 1 or mastShowNum then
                _showLvBg = true
                UIUtils.SetTextByNumber(self.NumLabel, num, true, 4)
            else
                UIUtils.ClearText(self.NumLabel)
            end
        end
        if self.NameLabel then
            UIUtils.SetTextByString(self.NameLabel, self.ShowItemData.Name)
        end
        if self.BindSpr ~= nil then
            self.BindSpr:SetActive(self.ShowItemData.IsBind)
        end
        if self.QualitySpr ~= nil then
            self.QualitySpr.gameObject:SetActive(true)
        end
        self.ShowNum = num
    else
        -- Debug.Log("yy InitWithItemData 222")
        self.Icon:UpdateIcon(-1)
        if self.BindSpr ~= nil then
            self.BindSpr:SetActive(false)
        end
        if self.QualitySpr ~= nil then
            self.QualitySpr.gameObject:SetActive(false)
        end
        if self.NumLabel ~= nil then
            UIUtils.ClearText(self.NumLabel)
        end
        if num and num == -1 then
            _clearLevelLabel = true
        end
        self.ShowNum = 0
        if self.IsShowAddSpr and self.AddSprGo then
            _addSprGoActive = true
            if self.LockGo ~= nil and self.LockGo.activeSelf then
                _addSprGoActive = false
            end
        end
        if self.NameLabel then
            UIUtils.ClearText(self.NameLabel)
        end
        self:OnSetStarSpr(0)
        self:OnSetEffect(-1)
    end
    if self.LvBgGo then
        -- self.LvBgGo:SetActive(_showLvBg)
        self.LvBgGo:SetActive(false); --[Gosu] ẩn Lvbg
    end
    if self.UnUseGo ~= nil then
        self.UnUseGo:SetActive(_unUseGoActive)
    end
    if self.UpTransGo ~= nil then
        self.UpTransGo:SetActive(_upTransGoActive)
    end
    if self.AddSprGo then
        self.AddSprGo:SetActive(_addSprGoActive)
    end
    if self.XJbgGo then
        self.XJbgGo:SetActive(_xjbgGoActive)
    end
    if _clearLevelLabel and self.LevelLabel ~= nil then
        UIUtils.ClearText(self.LevelLabel)
    end
end

function UIItem:InItWithCfgid(itemID, num, isBind, isShowGetBtn, mastShowNum)
    itemID = tonumber(itemID);
    num = tonumber(num);
    local item = LuaItemBase.CreateItemBase(itemID)
    if item ~= nil then
        item.Count = num
        item.IsBind = isBind and item.Type ~= 1 -- Item Type (1: Currency) The planner says that currency does not distinguish between binding and non-binding, and both are displayed as non-binding.
        if item.ItemInfo == nil and itemID ~= 0 then
            Debug.LogError("Configuration data not found cfgid = %d", itemID)
        end
        if itemID == 0 then
            item = nil
        end
    end
    if not mastShowNum then
        mastShowNum = false
    end
    self:InitWithItemData(item, num, mastShowNum, isShowGetBtn, ItemTipsLocation.Defult)
end

-- Settings of visible and hidden
function UIItem:SetActive(isActive)
    self.RootGO:SetActive(isActive)
end

-- Setting tags
function UIItem:SetTitle(titleStr)
    if titleStr and titleStr ~= "" and self.TitleLabel then
        UIUtils.SetTextByString(self.TitleLabel, titleStr)
        self.TitleGo:SetActive(true)
    else
        self.TitleGo:SetActive(false)
    end
end

-- Setting up stars pictures
function UIItem:OnSetStarSpr(diaNum)
    if self.StarGrid == nil then
        return
    end
    local oldCount = self.StarGrid.transform.childCount
    for i = 0, oldCount - 1 do
        self.StarGrid.transform:GetChild(i).gameObject:SetActive(false)
    end

    if self.StarNumGo then
        self.StarNumGo:SetActive(diaNum > 5)
    end
    if diaNum > 0 and diaNum <= 5 then
        local childGo = nil
        for i = 1, diaNum do
            if i <= oldCount then
                childGo = self.StarGrid.transform:GetChild(i - 1).gameObject
            else
                childGo = UnityUtils.Clone(childGo)
            end
            if childGo ~= nil then
                childGo:SetActive(true)
            end
        end
    elseif diaNum > 5 then
        UIUtils.SetTextByNumber(self.StarNumLabel, diaNum)
    end
    self.StarGrid.repositionNow = true
end

-- Set equipment special effects
function UIItem:OnSetEffect(effectID)
    if self.EffectGO ~= nil then
        self.EffectGO:SetActive(effectID == 1 or effectID == 3)
    end
    if self.EffectAniGO ~= nil then
        self.EffectAniGO:SetActive(effectID == 2 or effectID > 3)
        if (effectID == 2 or effectID > 3) then
            if self.EffectScript == nil then
                -- Register script
                local _animation = UIUtils.RequireUISpriteAnimation(self.EffectAniGO.transform)
                if(_animation ~= nil) then
                    _animation.namePrefix = "item_"
                    _animation.framesPerSecond = 10
                    _animation.PrefixSnap = false
                end
                self.EffectScript = _animation
            end
            if self.EffectScript ~= nil then
                if effectID == 2 then
                    self.EffectScript.namePrefix = "item_"
                elseif effectID == 4 then
                    self.EffectScript.namePrefix = "item3_"
                elseif effectID == 5 then
                    self.EffectScript.namePrefix = "item4_"
                elseif effectID == 6 then
                    self.EffectScript.namePrefix = "item5_"
                elseif effectID == 7 then
                    self.EffectScript.namePrefix = "item6_"
                end
            end
        end
    end
    if self.Effect2AniGO ~= nil then
        self.Effect2AniGO:SetActive(effectID == 3)
        if self.Effect2Script == nil then
            -- Register script
            local _animation = UIUtils.RequireUISpriteAnimation(self.Effect2AniGO.transform)
            if(_animation ~= nil) then
                _animation.namePrefix = "item1_"
                _animation.framesPerSecond = 10
                _animation.PrefixSnap = false
            end
            self.Effect2Script = _animation
        end
    end
end

-- Number of bound backpacks
function UIItem:BindBagNum(isSingleNum)
    self.IsSingleNum = not(not isSingleNum)
    self.IsBindBagNum = true
    self:RegisterMsg()
    self:UpdateBagNum()
end

-- Unbind the number of backpacks
function UIItem:CanelBindBagNum()
    self.IsBindBagNum = false
    self:UnRegisterMsg()
end

-- Set quantity
function UIItem:OnSetNum(sTx)
    if self.NumLabel ~= nil then
        UIUtils.SetTextByString(self.NumLabel, sTx)
    end
end

function UIItem:OnSetNumColor(r, g, b, a)
    if not Utils.IsNull(self.NumLabel) then
        UIUtils.SetColor(self.NumLabel, r, g, b, a)
    end
end

-- Set whether the grid is locked
function UIItem:OnLock(lock)
    if not Utils.IsNull(self.LockGo) then
        self.LockGo:SetActive(lock)
    end
end

-- Select
function UIItem:SelectItem(select)
    if not Utils.IsNull(self.SelectGo) then
        self.SelectGo:SetActive(select)
    end
end

-- Set ICON graying
function UIItem:SetIsGray(isGray)
    self.IconSpr.IsGray = isGray
    self.QualitySpr.IsGray = isGray
end

-- Button Event
function UIItem:OnBtnItemClick()
    -- Locked status does not respond to clicks
    if self.LockGo ~= nil and self.LockGo.activeSelf then
        return
    end
    if self.IsShowTips then
        if self.ShowItemData ~= nil then
            GameCenter.ItemTipsMgr:ShowTips(self.ShowItemData, self.RootGO, self.Location, self.IsShowGet, nil, true, self.ExtData)
        end
    end
    if self.SingleClick ~= nil then
        self.SingleClick(self)
    end
end

function UIItem:UpdateBagNum()
    if Utils.IsNull(self.RootTrans) then
        return
    end
    if self.ShowItemData == nil then
        return
    end
    if not self.IsBindBagNum then
        return
    end

    local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(self.ShowItemData.CfgID)

    self.IsEnough = haveNum >= self.ShowNum
    if self.IsSingleNum then
        if self.NumLabel ~= nil then
            UIUtils.SetTextByNumber(self.NumLabel, haveNum, true, 4);
        end
    else
        if self.NumLabel ~= nil then
            UIUtils.SetTextByProgress(self.NumLabel, haveNum, self.ShowNum, true, 4)
            UIUtils.SetColorByString(self.NumLabel, self.IsEnough and "#00ff00" or "#F37B11")
        end
    end
end

function UIItem:OnBagItemChanged(obj, sender)
    if Utils.IsNull(self.RootTrans) then
        return
    end
    if self.ShowItemData == nil then
        return
    end
    if not self.IsBindBagNum then
        return
    end
    local itemBase = obj
    if itemBase ~= nil then
        if itemBase.CfgID == self.ShowItemData.CfgID then
            self:UpdateBagNum()
        end
    end
end
function UIItem:OnCoinChanged(obj, sender)
    if Utils.IsNull(self.RootTrans) then
        return
    end
    if self.ShowItemData == nil then
        return
    end
    if not self.IsBindBagNum or self.ShowItemData.CfgID ~= obj then
        return
    end
    self:UpdateBagNum()
end
function UIItem:RegisterMsg()
    if self.IsRegisterBagMsg then
        return
    end
    self.IsRegisterBagMsg = true
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnBagItemChanged, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnCoinChanged, self)
end
function UIItem:UnRegisterMsg()
    if not self.IsRegisterBagMsg then
        return
    end
    self.IsRegisterBagMsg = false
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_BACKFORM_ITEM_UPDATE, self.OnBagItemChanged, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnCoinChanged, self)
end

function UIItem:OnEnable()
    if self.IsBindBagNum then
        self:RegisterMsg()
    end
end

function UIItem:OnDisable()
    if self.IsBindBagNum then
        self:UnRegisterMsg()
    end
end

function UIItem:OnDestroy()
    L_ItemMap[self.RootTrans] = nil;
    if self.IsBindBagNum then
        self:UnRegisterMsg()
    end
end

function UIItem:GetStrengthLevel(itemId)
    local itemId = itemId

    local _forgeSystem = GameCenter.LianQiForgeBagSystem
    local _starLv = 0
    if _forgeSystem.StrengthItemLevelDic:ContainsKey(itemId) then
        local _strengthInfo = _forgeSystem.StrengthItemLevelDic[itemId]
        _starLv = _strengthInfo.level
        return _starLv
    end

    return 0
end

return UIItem
