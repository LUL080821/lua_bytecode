------------------------------------------------
-- Author: 
-- Date: 2019-06-1
-- File: UIPlayerBagItem.lua
-- Module: UIPlayerBagItem
-- Description: Backpack lattice common component, you can use this where you need to double-click.
------------------------------------------------
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local UIPlayerBagItem = {
    Trans = nil,
    Go = nil,
    -- Select the icon
    SelectGo = nil,
    --ICON
    Icon = nil,
    IconGo = nil,
    -- Grid lock icon
    LockSprGo = nil,
    -- Bind Icon
    BindSprGo = nil,
    -- Quantity of items
    NumLabel = nil,
    -- quality
    QualitySpr = nil,
    -- Equipment order
    LevelLabel = nil,
    -- Equipment upward arrow, used to compare equipment with body
    UpSprGo = nil,
    -- Equipment special effects 1
    EffectSprGo1 = nil,
    -- Equipment Special Effects 2
    EffectSprGo2 = nil,
    EffectScript2 = nil,
    -- No wearable equipment icon
    UnUseEquipSprGo = nil,
    -- Star
    StarGrid = nil,
    StarGridGo = nil,
    StarGridTrans = nil,
    StarItemGo = nil,
    -- Animation, display effect of wearable equipment
    TweenScale = nil,
    TweenColor = nil,
    -- Data Cache
    ShowData = nil,
    -- Callback
    SingleClick = nil,
    DoubleClick = nil,
    -- Whether to select
    IsSelect = false,
    -- Subscript
    Index = 0,
    -- Is the backpack lattice turned on?
    IsOpened = false,

    -- Whether it is timed, it is used to determine whether it is clicked or double-clicked
    IsTime = false,
    -- Timer
    TimeCount = 0,

    BackItem = nil,   -- Back
    StrengthLevel = nil,   -- Strengthening level
    StrengthLevelLabel = nil,

}

local L_ItemMap = {}

-- Create a new object
function UIPlayerBagItem:New(trans)
    if L_ItemMap[trans] then
        return L_ItemMap[trans]
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    L_ItemMap[trans] = _m
    return _m
end

-- Clone an object
function UIPlayerBagItem:Clone()
    return UnityUtils.Clone(self.Go)
end

-- Find each control
function UIPlayerBagItem:FindAllComponents()
    self.SelectGo = UIUtils.FindGo(self.Trans, "Back/select")
    self.IconGo = UIUtils.FindGo(self.Trans, "Back/icon")
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Back/icon"))
    self.TweenColor = UIUtils.FindTweenColor(self.Trans, "Back/icon")
    self.TweenScale = UIUtils.FindTweenScale(self.Trans, "Back/icon")
    self.LockSprGo = UIUtils.FindGo(self.Trans, "Back/Lock")
    self.BindSprGo = UIUtils.FindGo(self.Trans, "Back/Bind")
    self.NumLabel = UIUtils.FindLabel(self.Trans, "Back/Num")
    self.LevelLabel = UIUtils.FindLabel(self.Trans, "Back/Level")
    if (self.LevelLabel ~=nil) then
        self.LevelLabel.gameObject:SetActive(false)
    end
    self.QualitySpr = UIUtils.FindSpr(self.Trans, "Back/Qualty")
    self.StarGrid = UIUtils.FindGrid(self.Trans, "Back/Grid")
    self.StarGridGo = UIUtils.FindGo(self.Trans, "Back/Grid")
    self.StarGridTrans = UIUtils.FindTrans(self.Trans, "Back/Grid")
    self.StarItemGo = self.StarGridTrans:GetChild(0).gameObject
    self.UpSprGo = UIUtils.FindGo(self.Trans, "Back/up")
    self.UnUseEquipSprGo = UIUtils.FindGo(self.Trans, "Back/UnUseSprite")
    self.EffectSprGo1 = UIUtils.FindGo(self.Trans, "Back/Effect")
    self.EffectSprGo2 = UIUtils.FindGo(self.Trans, "Back/Effect1")
    self.EffectSprGo3 = UIUtils.FindGo(self.Trans, "Back/Effect2")
    local trans = UIUtils.FindTrans(self.Trans, "Back/LvBg")
    if(trans ~= nil) then
        self.LvBgGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(self.Trans, "Back/XJbg")
    if(trans ~= nil) then
        self.XijiaBgGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(self.Trans, "Back/TimeOut")
    if(trans ~= nil) then
        self.TimeOutGo = UIUtils.FindGo(trans)
    end
    trans = UIUtils.FindTrans(self.Trans, "Back/StarNum")
    if(trans ~= nil) then
        self.StarNumLabel = UIUtils.FindLabel(trans)
    end
    self:SelectItem(false)


    -- [Gosu] lấy thông tin cường hóa vật phẩm trong túi

    self.BackItem = UIUtils.FindGo(self.Trans, "Back")

    if self.BackItem then
        local t = UIUtils.FindTrans(self.BackItem.transform, "Intensify")
        if t then
            self.StrengthLevel = t.gameObject
            self.StrengthLevelLabel = UIUtils.FindLabel(t, "")
        end
    end

    local _button = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(_button, self.OnOwnClick, self)
    UIUtils.AddBtnDoubleClickEvent(_button, self.onOwnDoubleClick, self)
end

-- Frame update
function UIPlayerBagItem:Update(dt)
    if self.IsTime then
        self.TimeCount = self.TimeCount + Time.GetDeltaTime()
        if self.TimeCount > 0.3 then
            if self.SingleClick ~= nil then
                self.SingleClick(self)
                self.IsTime = false
            end
        end
    end
end

-- Set special effects pictures, picture effects and frame animations
function UIPlayerBagItem:OnSetEffect(effectID)
    if self.EffectSprGo1 ~= nil then
        self.EffectSprGo1:SetActive(effectID == 1 or effectID == 3)
    end
    if self.EffectSprGo2 ~= nil then
        if effectID == 2 or effectID > 3 then
            if self.EffectScript2 == nil then
                self.EffectScript2 = UIUtils.RequireUISpriteAnimation(UIUtils.FindTrans(self.Trans, "Back/Effect1"))
            end
            if self.EffectScript2 ~= nil then
                self.EffectScript2.PrefixSnap = false
                self.EffectScript2.framesPerSecond = 10
                if effectID == 2 then
                    self.EffectScript2.namePrefix = "item_"
                elseif effectID == 4 then
                    self.EffectScript2.namePrefix = "item3_"
                elseif effectID == 5 then
                    self.EffectScript2.namePrefix = "item4_"
                elseif effectID == 6 then
                    self.EffectScript2.namePrefix = "item5_"
                elseif effectID == 7 then
                    self.EffectScript2.namePrefix = "item6_"
                end
            end
            self.EffectSprGo2:SetActive(true)
        else
            self.EffectSprGo2:SetActive(false)
        end
    end
    if self.EffectSprGo3 ~= nil then
        self.EffectSprGo3:SetActive(effectID == 3)
        if self.Effect2Script == nil then
            -- Register script
            local _animation = UIUtils.RequireUISpriteAnimation(self.EffectSprGo3.transform)
            if(_animation ~= nil) then
                _animation.namePrefix = "item1_"
                _animation.framesPerSecond = 10
                _animation.PrefixSnap = false
            end
            self.Effect2Script = _animation
        end
    end
end

-- Set equipment star rating
function UIPlayerBagItem:OnSetStarSpr(diaNum)
    if self.StarGrid == nil then
        return
    end
    --self.StarGridGo:SetActive(diaNum > 0 and diaNum <= 5)
    self.StarGridGo:SetActive(false)
    if self.StarNumLabel then
        self.StarNumLabel.gameObject:SetActive(diaNum > 5)
        if diaNum > 5 then
            UIUtils.SetTextByNumber(self.StarNumLabel, diaNum)
        end
    end
    if diaNum > 0  and diaNum <= 5 then
        local childGo = nil
        for i = 1, diaNum do
            if i <= self.StarGridTrans.childCount then
                childGo = self.StarGridTrans:GetChild(i - 1).gameObject
            else
                childGo = UnityUtils.Clone(self.StarItemGo)
            end
            if childGo ~= nil then
                childGo:SetActive(true)
            end
        end
        for i = diaNum, self.StarGridTrans.childCount - 1 do
            self.StarGridTrans:GetChild(i).gameObject:SetActive(false)
        end
    end
    self.StarGrid.repositionNow = true
end

-- Set whether to select
function UIPlayerBagItem:SelectItem(isSelect)
    self.IsSelect = isSelect
    self.SelectGo:SetActive(isSelect)
end

-- Determine whether the equipment is wearable
function UIPlayerBagItem:OnCheckCanEquip()
    local _isShow = false;
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer()
    if self.ShowData ~= nil and localPlayer ~= nil then
        _isShow = true;
        if not self.ShowData:CheckLevel(localPlayer.Level) then
            _isShow = false
        end
        if not self.ShowData:CheackOcc(localPlayer.IntOcc) then
            _isShow = false
        end
        if self.ShowData:isTimeOut() then
            _isShow = false
        end
        if not self.ShowData:CheckClass() then
            _isShow = false
        end
    end
    return _isShow
end

-- Click Event
function UIPlayerBagItem:OnOwnClick()

    if self.DoubleClick ~= nil and not self.IsTime then
        self.IsTime = true
        self.TimeCount = 0
    elseif self.DoubleClick == nil then
        if self.SingleClick ~= nil then
            self.SingleClick(self)
        end
    end
end

-- double click
function UIPlayerBagItem:onOwnDoubleClick()
    self.IsTime = false
    if self.DoubleClick ~= nil then
        self.DoubleClick(self)
    end
end

-- Setting up external response callbacks
function UIPlayerBagItem:OnSetCallBack(singleFunc, doubleFunc)
    self.SingleClick = singleFunc
    self.DoubleClick = doubleFunc
end

function UIPlayerBagItem:GetStrengthLevel(itemId)
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

-- Set display data
function UIPlayerBagItem:UpdateItem(good, userData)
    -- reset trước
    if self.StrengthLevel then
        self.StrengthLevel:SetActive(false)
    end
    local canShowSprite = false
    local isSelectActive = false
    local isIconSpriteActive = false
    local isLockSpriteActive = false
    local isBindSpriteActive = false
    local isUpEquip = false
    self.Index = 6
    local isNumLabelActive = false;
    local isShowStren = false;
    if self.XijiaBgGo then
        self.XijiaBgGo:SetActive(false);
    end
    self.ItemInfo = good;
    if self.TimeOutGo then
        self.TimeOutGo:SetActive(false);
    end
    UIUtils.ClearText(self.LevelLabel)
    self.TimeCount = 0
    self.ShowData = good
    if self.LvBgGo then
        -- self.LvBgGo:SetActive(good ~= nil)
        self.LvBgGo:SetActive(false); --[Gosu] ẩn Lvbg
    end
    if  good == nil then
        canShowSprite = false
        isSelectActive = false
        isIconSpriteActive = false
        isLockSpriteActive = false
        isBindSpriteActive = false
        local qualityName = ""
        self.QualitySpr.spriteName = qualityName
        self:OnSetStarSpr(0)
        self:OnSetEffect(0)
        UIUtils.ClearText(self.NumLabel)

        -- [Gosu] reset cường hóa khi slot rỗng
        if self.StrengthLevel then
            self.StrengthLevel:SetActive(false)
        end
    else
        isLockSpriteActive = false
        isSelectActive = false
        isIconSpriteActive = true
        if good.IsBind then
            isBindSpriteActive = true
        end

        local num = good.Count

        if num <= 1 then
            UIUtils.ClearText(self.NumLabel)
        else
            UIUtils.SetTextByNumber(self.NumLabel, num, true, 4)
        end

        local qulityValue = 0
        if good.Type == ItemType.Equip or good.Type == ItemType.HolyEquip or good.Type == ItemType.ImmortalEquip or good.Type == ItemType.UnrealEquip
            or good.Type == ItemType.PetEquip or good.Type == ItemType.HorseEquip or good.Type == ItemType.SoulPearl or good.Type == ItemType.DevilSoulEquip then
            local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer()
            if self.ShowData.ItemInfo ~= nil and localPlayer ~= nil then
                self.Icon:UpdateIcon(good.Icon)
                qulityValue = good.Quality
                self:OnSetEffect(good.Effect)
                local _occRight = good:CheackOcc(localPlayer.Occ)
                canShowSprite = not _occRight
                isUpEquip = _occRight and good:CheckBetterThanDress()
                if userData then
                    if good.Type == ItemType.HorseEquip then
                        isUpEquip = good.ItemInfo.Score > userData
                    elseif good.Type == ItemType.DevilSoulEquip then
                        isUpEquip = good.ItemInfo.Quality > userData
                    else
                        isUpEquip = good.Power > userData
                    end
                end
                if good.Type == ItemType.Equip or good.Type == ItemType.HolyEquip or good.Type == ItemType.HorseEquip or good.Type == ItemType.UnrealEquip then
                    UIUtils.SetTextByEnum(self.LevelLabel, "LEVEL_FOR_JIE", good.ItemInfo.Grade)
                end
                self:OnSetStarSpr(good.StarNum)

                -- Debug.Log("good.ItemInfo.Qualitygood.ItemInfo.Qualitygood.ItemInfo.Qualitygood.ItemInfo.Quakkkkklity==", good.DBID)
                
                -- reset trước
                if self.StrengthLevel then
                    self.StrengthLevel:SetActive(false)
                end

                local lv = self:GetStrengthLevel(good.DBID)
                if lv > 0 then
                    if self.StrengthLevel then
                        self.StrengthLevel:SetActive(true)
                        if self.StrengthLevelLabel then
                            UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
                        end
                    end
                end


            end
        else
            if good.ItemInfo ~= nil then
                self.Icon:UpdateIcon(good.Icon)
                qulityValue = good.Quality
                self:OnSetStarSpr(0)
                self:OnSetEffect(good.Effect)
            end
        end
        local qualityName = Utils.GetQualitySpriteName(qulityValue)
        self.QualitySpr.spriteName = qualityName
    end

    if not self.IsOpened then
        isLockSpriteActive = true
        isSelectActive = false
        isIconSpriteActive = false
        isBindSpriteActive = false
        UIUtils.ClearText(self.NumLabel)
    end

    self.IsSelect = isSelectActive
    self.SelectGo:SetActive(isSelectActive)
    self.IconGo:SetActive(isIconSpriteActive)
    self.LockSprGo:SetActive(isLockSpriteActive)
    self.BindSprGo:SetActive(isBindSpriteActive)
    if self.UpSprGo ~= nil then
        self.UpSprGo:SetActive(isUpEquip)
    end
    if self.UnUseEquipSprGo ~= nil then
        self.UnUseEquipSprGo:SetActive(canShowSprite)
    end
    if self.TweenColor ~= nil and self.TweenScale ~= nil then
        if isUpEquip and self:OnCheckCanEquip() then
            self.TweenColor.enabled = true
            self.TweenScale.enabled = true
        else
            self.TweenColor.enabled = false
            self.TweenScale.enabled = false
            UnityUtils.SetLocalScale(self.IconGo.transform, 1, 1, 1)
        end
    end

end

function UIPlayerBagItem:OnDestroy()
    L_ItemMap[self.Trans] = nil;
end
return UIPlayerBagItem
