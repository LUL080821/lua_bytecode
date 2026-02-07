------------------------------------------------
-- Author: 
-- Date: 2020-08-14
-- File: LimitTimeLogin.lua
-- Module: LimitTimeLogin
-- Description: Limited time login data
------------------------------------------------
local BaseData = require("Logic.YYHD.YYHDBaseData")

local LimitTimeLogin = {
    -- Configuration data
    CfgData = nil,
    -- All purchase rewards()
    AllBuyRewardDic = nil,
    -- Player data
    PlayerData = nil,
    -- Total days
    TotalDays = 0,
    -- Ordinary little red dots
    NormalRedpoints = nil,
    -- Buy a little red dot
    BuyRedpoints = nil,
    -- Normal acquisition status
    NormalGetStates = nil,
    -- Purchase and get status
    BuyGetStates = nil,
    -- Normal days of collection
    NormalDay = 0,
    -- Purchase and collect days
    BuyDay = 0
}

function LimitTimeLogin:New(typeId)
    local _n = Utils.DeepCopy(self)
    local _mn = setmetatable(_n, {
        __index = BaseData:New(typeId)
    })
    return _mn
end

-- Parse activity configuration data
function LimitTimeLogin:ParseSelfCfgData(jsonTable)
    self.CfgData = jsonTable;

    self.TotalDays = #jsonTable.normalAwardList;
    self.NormalRedpoints = {}
    self.BuyRedpoints = {}
    self.NormalGetStates = {}
    self.BuyGetStates = {}
    for i = 1, self.TotalDays do
        table.insert(self.NormalRedpoints, false)
        table.insert(self.BuyRedpoints, false)
        table.insert(self.NormalGetStates, false)
        table.insert(self.BuyGetStates, false)
    end

    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    self.AllBuyRewardDic = Dictionary:New()
    local _buyAwardList = jsonTable.buyAwardList
    for i = 1, #_buyAwardList do
        local _awards = _buyAwardList[i];
        for j = 1, #_awards do
            local _award = _awards[j];
            if _award.c == 9 or _award.c == _occ then
            if self.AllBuyRewardDic:ContainsKey(_award.i) then
                    self.AllBuyRewardDic[_award.i] = self.AllBuyRewardDic[_award.i] + _award.n
                else
                    self.AllBuyRewardDic:Add(_award.i, _award.n)
                end
            end
        end
    end
    self.PlayerData = nil;
end

-- Resolve custom data and update it
function LimitTimeLogin:ParsePlayerData(jsonTable)
    if not self:IsActive() then
        return;
    end
    local _isFirst = self.PlayerData == nil;
    if not _isFirst then
        if self.PlayerData.isBought <= 0 and jsonTable.isBought > 0 then
            Utils.ShowPromptByEnum("C_BUY_SUCC2")
        end
    end

    self.PlayerData = jsonTable;
    local _day = 0;
    for i = 1, self.TotalDays do
        local _normalGetState = ((jsonTable.getDays >> (i - 1)) & 1) == 1
        local _buyGetState = ((jsonTable.getBuyDays >> (i - 1)) & 1) == 1
        if self.NormalGetStates[i] ~= _normalGetState then
            self.NormalDay = i;
        end
        if self.BuyGetStates[i] ~= _buyGetState then
            self.BuyDay = i;
        end
        self.NormalGetStates[i] = _normalGetState;
        self.NormalRedpoints[i] = i <= jsonTable.loginDays and not _normalGetState;
        self.BuyGetStates[i] = _buyGetState
        self.BuyRedpoints[i] = jsonTable.isBought > 0 and i <= jsonTable.loginDays and not _buyGetState;
    end
    if _isFirst then
        self.NormalDay = 0;
        self.BuyDay = 0;
    end
end

-- Is there a small red dot in this function
function LimitTimeLogin:IsRedpoint()
    for i = 1, self.TotalDays do
        if self.NormalRedpoints[i] then
            return true;
        end
        if self.BuyRedpoints[i] then
            return true;
        end
    end
    return false
end

-- Is there a small red dot usually retrieve?
function LimitTimeLogin:IsRedpointByNormal()
    for i = 1, self.TotalDays do
        if self.NormalRedpoints[i] then
            return true;
        end
    end
    return false
end

-- Purchase to get if there are any small red dots
function LimitTimeLogin:IsRedpointByBuy()
    for i = 1, self.TotalDays do
        if self.BuyRedpoints[i] then
            return true;
        end
    end
    return false
end

-- Refresh data
function LimitTimeLogin:RefreshData()
    self:RemoveRedPoint()
    if self:IsRedpoint() then
        self:AddRedPoint(1, nil, nil, nil, true, nil)
    end
end

-- Operation activity return
function LimitTimeLogin:ResActivityDeal(jsonTable)

end

return LimitTimeLogin

-- "{
--   'showType':0,
--   'showTexId':0,
--   'showItemID':0
--   'showModelID':0,
--   'ShowModelXRot':0,
--   'ShowModelYRot':0,
--   'ShowModelZRot':0,
--   'ShowModelYOffset':0,
--   'ShowModelXOffset':0,
--   'ShowModelScale':1,
--   'buyMoneyType':1,
--   'buyMoneyNum':100,

--   'buyAwardList':[
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}],
--       [{'b':1,'c':9,'i':12005,'n':10},{'b':1,'c':9,'i':12005,'n':20}]
--       ],
--   'normalAwardList':[
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}],
--       [{'b':1,'c':9,'i':12004,'n':10},{'b':1,'c':9,'i':12004,'n':20}]
--       ],
--   }"
