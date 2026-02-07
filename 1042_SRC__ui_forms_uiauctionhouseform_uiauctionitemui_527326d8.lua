------------------------------------------------
-- author:
-- Date: 2019-10-11
-- File: UIAuctionItemUI.lua
-- Module: UIAuctionItemUI
-- Description: Auction house item item
------------------------------------------------
local L_CD_TIME = nil
local L_GUILD_CD_TIME = nil

local UIAuctionItemUI = {
    -- Root node
    RootGO = nil,
    --uiitem
    UIItem = nil,
    -- name
    Name = nil,
    -- Fighting power
    PowerGO = nil,
    PowerValue = nil,
    PowerUPGO = nil,
    PowerDownGO = nil,
    -- time left
    RemainTime = nil,
    -- Wait for the start
    WaitStartGO = nil,
    WaitStartTime = nil,
    -- Current Price
    CurPriceGO = nil,
    CurPriceValue = nil,
    SelfMax = nil,
    SelfNotMax = nil,
    JingJiaing = nil,
    JingJiaBtn = nil,
    -- Maximum price
    MaxPriceGO = nil,
    MaxPriceValue = nil,
    GouMaiBtn = nil,
    -- Tips for not buying at a fixed price
    CanNotYiKouJia = nil,

    -- Item Example
    ItemInst = nil,
    -- Is there a start CD
    HaveStartCD = false,
    -- Is it a world auction?
    IsWorldAuction = true,
    -- The last refresh time
    FrontUpdateTime = -1,
    -- Parent UI
    Parent = nil,
    -- Password mark
    MimaFlag = nil,

    CurPriceIcon = nil,
    MaxPriceIcon = nil,

    -- [Gosu] thêm label cường hóa
    StrengthLevel = nil,   -- Strengthening level
    StrengthLevelLabel = nil,
}

function UIAuctionItemUI:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Parent = parent
    _m.RootGO = trans.gameObject
    _m.UIItem = UILuaItem:New(UIUtils.FindTrans(trans, "Item"))
    _m.Name = UIUtils.FindLabel(trans, "Name")
    _m.PowerGO = UIUtils.FindGo(trans, "Power")
    _m.PowerValue = UIUtils.FindLabel(trans, "Power/Value")
    _m.PowerUPGO = UIUtils.FindGo(trans, "Power/Up")
    _m.PowerDownGO = UIUtils.FindGo(trans, "Power/Down")
    _m.RemainTime = UIUtils.FindLabel(trans, "Time")
    _m.WaitStartGO = UIUtils.FindGo(trans, "Start")
    _m.WaitStartTime = UIUtils.FindLabel(trans, "Start/Time")
    _m.CurPriceGO = UIUtils.FindGo(trans, "CurPrice")
    _m.CurPriceValue = UIUtils.FindLabel(trans, "CurPrice/Label")
    _m.SelfMax = UIUtils.FindGo(trans, "CurPrice/SelfMax")
    _m.SelfNotMax = UIUtils.FindGo(trans, "CurPrice/SelfNotMax")
    _m.JingJiaing = UIUtils.FindGo(trans, "CurPrice/JingJiaIng")
    _m.JingJiaBtn = UIUtils.FindBtn(trans, "CurPrice/JingJiaBtn")
    UIUtils.AddBtnEvent(_m.JingJiaBtn, _m.OnJingJiaBtnClick, _m)
    _m.MaxPriceGO = UIUtils.FindGo(trans, "MaXPrice")
    _m.MaxPriceValue = UIUtils.FindLabel(trans, "MaXPrice/Label")
    _m.GouMaiBtn = UIUtils.FindBtn(trans, "MaXPrice/BuyBtn")
    UIUtils.AddBtnEvent(_m.GouMaiBtn, _m.OnBuyBtnClick, _m)
    _m.CanNotYiKouJia = UIUtils.FindGo(trans, "CanNotBuy")
    _m.MimaFlag = UIUtils.FindGo(trans, "MiMaFlag")


    -- [Gosu] lấy thông tin cường hóa vật phẩm trong túi

    local intensify = UIUtils.FindTrans(trans, "Intensify")
    if intensify then
        _m.StrengthLevel = intensify.gameObject
        _m.StrengthLevelLabel = UIUtils.FindLabel(intensify, "")
    else
        Debug.LogError("UIAuctionItemUI: Intensify not found")
    end





    if L_CD_TIME == nil then
        local _gCfg = DataConfig.DataGlobal[GlobalName.auction_countdown]
        L_CD_TIME = tonumber(_gCfg.Params)
    end

    if L_GUILD_CD_TIME == nil then
        local _gCfg = DataConfig.DataGlobal[GlobalName.Guild_auction_countdown]
        L_GUILD_CD_TIME = tonumber(_gCfg.Params)
    end
    _m.CurPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "CurPrice"))
    _m.MaxPriceIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "MaXPrice"))
    return _m
end
-- Setting up data
function UIAuctionItemUI:SetData(itemInst)

    -- Debug.Log("itemInstitemInstitemInstitemInstitemInst=================", Inspect(itemInst.ItemInst.DBID))
    -- Debug.Log("itemInstitemInstitemInstitemInstitemInst=================", Inspect(GameCenter.AuctionHouseSystem:GetItemStrengthLevel(itemInst.ItemInst.DBID)))

    self.ItemInst = itemInst
    if itemInst == nil then
        self.RootGO:SetActive(false)
        UIUtils.SetGameObjectNameByNumber(self.RootGO, 0)
    else
        local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        self.RootGO:SetActive(true)
        self.UIItem:InitWithItemData(itemInst.ItemInst, nil, nil, false, ItemTipsLocation.Market, nil) -- [Gosu] sửa lại để truyền vào type auction

        UIUtils.SetTextFormat(self.Name, "[{0}]{1}",  Utils.GetQualityStrColor(itemInst.ItemInst.Quality),  itemInst.ItemInst.Name)
        local _coinIcon = itemInst.UseCoinCfg.Icon
        self.CurPriceIcon:UpdateIcon(_coinIcon)
        self.MaxPriceIcon:UpdateIcon(_coinIcon)
        local _cfgID = itemInst.ItemInst.CfgID
        local _equipCfg = DataConfig.DataEquip[_cfgID]
        if _equipCfg ~= nil then
            local _power = itemInst.ItemInst.Power
            self.PowerGO:SetActive(true)
            local _powerDiff = 0
            if itemInst.ItemInst:CheackOcc(_lp.IntOcc) then
                _powerDiff = itemInst.ItemInst:GetDressPowerDiff()
            end
            self.PowerUPGO:SetActive(_powerDiff > 0)
            self.PowerDownGO:SetActive(_powerDiff < 0)
            UIUtils.SetTextByNumber(self.PowerValue, _power)
        else
            self.PowerGO:SetActive(false)
        end

        local _itemCount = itemInst.ItemInst.Count
        if itemInst.SinglePrice <= 0 or itemInst.HasMiMa or itemInst.UsePriceType == 1 then
            -- A single added value of 0 means that you cannot bid, a password means that you cannot bid, and a custom price cannot bid
            self.CurPriceGO:SetActive(false)
        else
            self.CurPriceGO:SetActive(true)
            UIUtils.SetTextByNumber(self.CurPriceValue, itemInst.CurPrice)
        end

        if itemInst.MaxPrice < 0 then
            -- Prices less than 0 meant that prices cannot be
            self.CanNotYiKouJia:SetActive(true)
            self.MaxPriceGO:SetActive(false)
        else
            self.CanNotYiKouJia:SetActive(false)
            self.MaxPriceGO:SetActive(true)
            if itemInst.HasMiMa or itemInst.UsePriceType == 1 then
                UIUtils.SetTextByNumber(self.MaxPriceValue, itemInst.CurPrice)
            else
                UIUtils.SetTextByNumber(self.MaxPriceValue, itemInst.MaxPrice)
            end
        end

        self.HaveStartCD = itemInst.HaveStartCD
        self.IsWorldAuction = itemInst.OwnerGuild <= 0

        if not self.HaveStartCD then
            self.WaitStartGO:SetActive(false)
            self.RemainTime.gameObject:SetActive(true)
        end
        if itemInst.IsSelfPriceOwner then
            self.SelfMax:SetActive(true)
            self.SelfNotMax:SetActive(false)
            self.JingJiaing:SetActive(false)
        else
            self.SelfMax:SetActive(false)
            local _selfJion = itemInst.IsSefJion
            self.SelfNotMax:SetActive(_selfJion)
            self.JingJiaing:SetActive(not _selfJion and itemInst.CurPriceOwner ~= 0)
        end
        self.FrontUpdateTime = -1
        self:Update(0)
        UIUtils.SetGameObjectNameByNumber(self.RootGO, _cfgID)
        self.MimaFlag:SetActive(itemInst.HasMiMa)

        -- reset trước
        -- if self.StrengthLevel then
        --     self.StrengthLevel:SetActive(false)
        -- end

        -- local lv = GameCenter.AuctionHouseSystem:GetItemStrengthLevel(itemInst.ItemInst.DBID)

        -- Debug.Log("===========================================lvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv===", lv)

        -- if lv > 0 then
        --     if self.StrengthLevel then
        --         self.StrengthLevel:SetActive(true)
        --         if self.StrengthLevelLabel then
        --             UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
        --         end
        --     end
        -- end

        local lv = self.ItemInst.Detail.strengthInfo.level
        if self.StrengthLevel then
            self.StrengthLevel:SetActive(lv > 0)
            if self.StrengthLevelLabel then
                UIUtils.SetTextByString(self.StrengthLevelLabel, "+" .. lv)
            end
        end

    end

    --[Gosu] luôn ẩn lực chiến
    self.PowerGO:SetActive(false)
end

-- Click on the bidding button
function UIAuctionItemUI:OnJingJiaBtnClick()
    -- Holy clothing, determine whether the player's VIP level is sufficient
    if self.ItemInst.ItemInst.Type == ItemType.HolyEquip and self.Parent.HolyEquipBuyNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.Parent.HolyEquipBuyNeedVipLevel then
            Utils.ShowPromptByEnum("Trade_VIP_Limit_Buy_Title", self.Parent.HolyEquipBuyNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_SZBUY_BAOZHU")
            return
        end
    end
    -- Demon soul equipment, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.DevilSoulChip and self.Parent.DevilEquipBuyNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.Parent.DevilEquipBuyNeedVipLevel then
            Utils.ShowPromptByEnum("Devil_Trade_VIP_Limit_Buy_Title", self.Parent.DevilEquipBuyNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_MHBUY_BAOZHU")
            return
        end
    end
    self.Parent.JingJiaPanel:Show(self.ItemInst)
end
-- Click on the Buy Button
function UIAuctionItemUI:OnBuyBtnClick()
    -- Holy clothing, determine whether the player's VIP level is sufficient
    if self.ItemInst.ItemInst.Type == ItemType.HolyEquip and self.Parent.HolyEquipBuyNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.Parent.HolyEquipBuyNeedVipLevel then
            Utils.ShowPromptByEnum("Trade_VIP_Limit_Buy_Title", self.Parent.HolyEquipBuyNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_SZBUY_BAOZHU")
            return
        end
    end
    -- Demon soul equipment, determine whether the player's VIP level is sufficient
    if self.ItemInstType == ItemType.DevilSoulChip and self.Parent.DevilEquipBuyNeedVipLevel > 0 then
        local _vipLevel = GameCenter.VipSystem:GetVipLevel()
        if _vipLevel < self.Parent.DevilEquipBuyNeedVipLevel then
            Utils.ShowPromptByEnum("Devil_Trade_VIP_Limit_Buy_Title", self.Parent.DevilEquipBuyNeedVipLevel)
            return
        end
        if not GameCenter.VipSystem:BaoZhuIsOpen() then
            Utils.ShowPromptByEnum("C_AUCTION_MHBUY_BAOZHU")
            return
        end
    end
    if self.ItemInst.HasMiMa then
        self.Parent.MiMaBuyPanel:Show(self.ItemInst)
    else
        self.Parent.BuyPanel:Show(self.ItemInst)
    end
end

-- renew
function UIAuctionItemUI:Update(dt)
    if self.ItemInst == nil then
        return false
    end
    local _remainTime = math.floor(self.ItemInst:GetRemainTime())
    if _remainTime < 0 then
        -- Delete yourself
        self:SetData(nil)
        return true
    end
    if _remainTime == self.FrontUpdateTime then
        return false
    end
    self.FrontUpdateTime = _remainTime

    local _allTime = self.ItemInst.AuctionAllTime
    local _useLabel = nil
    if self.HaveStartCD then
        if self.IsWorldAuction then
            -- There is a start CD, determine whether it is within the CD range
            if _remainTime > (_allTime - L_CD_TIME) then
                -- Still on CD
                self.WaitStartGO:SetActive(true)
                self.RemainTime.gameObject:SetActive(false)
                _useLabel = self.WaitStartTime
                _remainTime = _remainTime - (_allTime - L_CD_TIME)
                self.JingJiaBtn.isEnabled = false
                self.GouMaiBtn.isEnabled = false
            else
                self.WaitStartGO:SetActive(false)
                self.RemainTime.gameObject:SetActive(true)
                _useLabel = self.RemainTime
                self.JingJiaBtn.isEnabled = true
                self.GouMaiBtn.isEnabled = true
            end
        else
            -- There is a start CD, determine whether it is within the CD range
            if _remainTime > (_allTime - L_GUILD_CD_TIME) then
                -- Still on CD
                self.WaitStartGO:SetActive(true)
                self.RemainTime.gameObject:SetActive(false)
                _useLabel = self.WaitStartTime
                _remainTime = _remainTime - (_allTime - L_GUILD_CD_TIME)
                self.JingJiaBtn.isEnabled = false
                self.GouMaiBtn.isEnabled = false
            else
                self.WaitStartGO:SetActive(false)
                self.RemainTime.gameObject:SetActive(true)
                _useLabel = self.RemainTime
                self.JingJiaBtn.isEnabled = true
                self.GouMaiBtn.isEnabled = true
            end
        end
  
    else
        _useLabel = self.RemainTime
        self.JingJiaBtn.isEnabled = true
        self.GouMaiBtn.isEnabled = true
    end

    local d, h, m, s = Time.SplitTime(math.floor(_remainTime))
    UIUtils.SetTextByEnum(_useLabel, "HHMMSS", h, m, s)
    return false
end

return UIAuctionItemUI
