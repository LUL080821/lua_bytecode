local LimitShopSystem = {
    -- Server synchronizes data
    MsgSyncData = nil,
    -- Buy
    ReqLimitBuyData = nil,
    -- Whether to display a prompt
    IsShowTips = true,
    -- Is it necessary to detect
    IsCheck = false,
    -- Whether to add new products
    IsAddNewShop = false,
    -- Are products that expired after offline are displayed
    IsShowedOverTimeShop = false,
    -- Tips status after 10 minutes expires
    TipsMap = {},
    -- Is the 10-minute expiration prompt being displayed?
    IsShowingTips = false,
    -- New product id
    NewShopId = 0,
}

function LimitShopSystem:Initialize()
    self.MsgSyncData = nil;
    self.TipsMap = {};
    self.IsCheck = false;
    self.IsShowTips = true;
    self.IsAddNewShop = false;
    self.IsShowedOverTimeShop = false;
    self.IsShowingTips = false;
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.RefreshOverTimeShopTips, self);
end

function LimitShopSystem:UnInitialize()
    self.IsEnterMap = false;
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.RefreshOverTimeShopTips, self);
end

-- Whether to display the entrance
function LimitShopSystem:IsShowEnter()
    return not (not self.MsgSyncData) and #self.MsgSyncData.shops > 0
end

-- Is there a new product
function LimitShopSystem:IsExistNewShop()
    return self.IsAddNewShop;
end

-- Hide new limited-time product tips
function LimitShopSystem:HideNewShopTips()
    self.IsAddNewShop = false;
end

function LimitShopSystem:Refresh()
    local _isExistShop = not (not self.MsgSyncData) and #self.MsgSyncData.shops > 0
    GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitShop):SetIsVisible(_isExistShop)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIMITSHOP_REFRSH, _isExistShop);
end

function LimitShopSystem:Update(deltaTime)
    if not self.IsEnterMap then
        return;
    end
    if self.MsgSyncData and self.IsCheck then
        local _shops = self.MsgSyncData.shops;
        if #_shops > 0 then
            local _isRefrsh = false;
            for i = #_shops, 1, -1 do
                if _shops[i].endTime ~= -1 then
                    local _remainTime = _shops[i].endTime - Time.GetNowSeconds() * 1000;
                    if _remainTime <= 0 then
                        table.remove(_shops, i);
                        _isRefrsh = true;
                    elseif not self.TipsMap[_shops[i].id] and _remainTime <= 600000 then
                        -- Debug.LogError(">>>>>>>>>>>>>>>>>>>>>>>>>>>", _shops[i].id);
                        self.TipsMap[_shops[i].id] = true;
                        if not self.IsShowingTips then
                            self.IsShowingTips = true;
                            GameCenter.MsgPromptSystem:ShowMsgBox(true, DataConfig.DataMessageString.Get("LimitShopOutOfDateTips"), function(code)
                                if code == MsgBoxResultCode.Button2 then
                                    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LimitShop);
                                end
                                self.IsShowingTips = false;
                            end, false, false, 10);
                        end
                    end
                end
            end
            if _isRefrsh then
                self:Refresh();
            end
        else
            self.IsCheck = false;
        end
    end
end

-- Synchronize limited-time products
-- repeated LimitShop shops = 1; // List of items allowed to be purchased
-- repeated int32 buyIds = 2; // List of purchased items
function LimitShopSystem:SyncLimitShop(msg)
    -- Debug.LogError("===========[LimitShopSystem]=========")
    if self.MsgSyncData then
        local _odlShops = self.MsgSyncData.shops;
        local _oldShopDic = {};
        for i = 1, #_odlShops do
            _oldShopDic[_odlShops[i].id] = true;
        end
        if msg.shops then
            for i = 1, #msg.shops do
                if not _oldShopDic[msg.shops[i].id] then
                    self.IsAddNewShop = true;
                    self.NewShopId = msg.shops[i].id;
                end
            end
            if self.IsAddNewShop then
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWLIMITSHOP_REFRESH);
                -- Debug.LogError("============================================”,"There are new limited-time products")
            end
        end
    end

    self.MsgSyncData = msg;
    self.MsgSyncData.shops = self.MsgSyncData.shops or {};

    table.sort(self.MsgSyncData, function(a, b)
        local _cfgA = DataConfig.DataLimitShop[a.id];
        local _cfgb = DataConfig.DataLimitShop[b.id];
        return (_cfgA.Sort or 0) < (_cfgb.Sort or 0)
    end)

    self.MsgSyncData.buyIds = self.MsgSyncData.buyIds or {};
    self.IsCheck = #self.MsgSyncData.shops > 0
    local _shops = self.MsgSyncData.shops;
    for j = 1, #_shops do
        if _shops[j].endTime ~= -1 then
            local _remainTime = _shops[j].endTime - Time.ServerTime() * 1000;
            -- Debug.LogError("==================== _remainTime = ",_shops[j].endTime, Time.ServerTime() * 1000,  _remainTime, _shops[j].id)
            if not self.TipsMap[_shops[j].id] and _remainTime < 600000 then
                self.TipsMap[_shops[j].id] = true;
                -- Debug.LogError("============================================ Deadline products that are about to expire", _shops[j].id)
            end
        end
    end
    self:Refresh()
    self:RefreshOverTimeShopTips();
end

-- Request a purchase
function LimitShopSystem:ReqLimitBuy(id)
    if not self.ReqLimitBuyData then
        self.ReqLimitBuyData = ReqMsg.MSG_Shop.ReqLimitBuy:New();
    end
    self.ReqLimitBuyData.id = id;
    self.ReqLimitBuyData:Send();
end

-- Refresh expired items when offline
function LimitShopSystem:RefreshOverTimeShopTips(obj, sender)
    self.IsEnterMap = true;
    if not self.IsShowedOverTimeShop and self.MsgSyncData then
        for i = 1, #self.MsgSyncData.shops do
            local _shop = self.MsgSyncData.shops[i];
            if _shop.isOverTime then
                GameCenter.MsgPromptSystem:ShowMsgBox(true, DataConfig.DataMessageString.Get("LimitShopOutOfDateTipsAddTime"), function(code)
                    if code == MsgBoxResultCode.Button2 then
                        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.LimitShop);
                    end
                end, false, false, 10);
                self.IsShowedOverTimeShop = true;
                break
            end
        end
    end
end

-- Is this item available for purchase at a limited purchase store
function LimitShopSystem:IsCanBuy(itemId)
    if self.MsgSyncData and #self.MsgSyncData.shops > 0 then
        local _player = GameCenter.GameSceneSystem:GetLocalPlayer()
        if not _player then
            return false;
        end
        local _occ = _player.IntOcc
        local _shops = self.MsgSyncData.shops;
        for i = #_shops, 1, -1 do
            local _cfg = DataConfig.DataLimitShop[_shops[i].id];
            if _cfg then
                local _rewards = Utils.SplitStr(_cfg.Reward, ";");
                for j = 1, #_rewards do
                    local _reward = Utils.SplitNumber(_rewards[j], "_");
                    if (_reward[4] == _occ or _reward[4] == 9) and _reward[1] == itemId then
                        return true;
                    end
                end
            end
        end
    end
    return false;
end

return LimitShopSystem
