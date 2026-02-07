------------------------------------------------
-- author:
-- Date: 2019-12-05
-- File: LevelGift.lua
-- Module: LevelGift
-- Description: Welfare level gift package
------------------------------------------------

local LevelGift = {
    -- Received list
    ReciveList = List:New(),
    -- Login gift package list
    LevelGiftList = List:New(),
    -- Have you collected all the items (including those that have been collected)
    IsGetAll = false,
    -- Login gift package
    LevelGiftDic = Dictionary:New(),
}

function LevelGift:Initialize()
    self.IsGetAll = false;
    return self
end

function LevelGift:UnInitialize()
    self.ReciveList:Clear()
    self.LevelGiftList:Clear()
end

-- Update the level gift package data
function LevelGift:UpdateGiftData()
    local _lv = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _num = 0
    self.IsGetAll = true;
    -- 1: Can be collected 2: Waiting for collection 3: Received 4: Unable to collect
    for i = 1, #self.LevelGiftList do
        if self.LevelGiftList[i].receive and self.LevelGiftList[i].vipReceive then
            self.LevelGiftList[i].status = LevelGiftStatus.Geted
            self.LevelGiftList[i].SortNum = 2000 + self.LevelGiftList[i].level
        else
            self.LevelGiftList[i].SortNum = self.LevelGiftList[i].level
            if self.LevelGiftList[i].remain ~= 0 then
                if self.LevelGiftList[i].level <= _lv then
                    if not self.LevelGiftList[i].receive then
                        self.LevelGiftList[i].status = LevelGiftStatus.CanGet
                        _num = _num + 1
                    else
                        local _cfg = DataConfig.DataLevelReward[self.LevelGiftList[i].level]
                        if _cfg and GameCenter.VipSystem:GetVipLevel() >= _cfg.VipLimit then
                            self.LevelGiftList[i].status = LevelGiftStatus.CanGet
                            _num = _num + 1
                        else
                            self.LevelGiftList[i].status = LevelGiftStatus.VipLimit
                            self.LevelGiftList[i].SortNum = 1000 + self.LevelGiftList[i].level
                        end
                    end
                else
                    self.LevelGiftList[i].status = LevelGiftStatus.NotReach
                    self.LevelGiftList[i].SortNum = 1000 + self.LevelGiftList[i].level
                end
                self.IsGetAll = false;
            else
                self.LevelGiftList[i].status = LevelGiftStatus.SellOut
                self.LevelGiftList[i].SortNum = 1000 + self.LevelGiftList[i].level
            end
        end
    end

    table.sort(self.LevelGiftList, function(a, b)
        return a.SortNum < b.SortNum
    end)
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.WelfareLevelGift, _num > 0)
end

-- Settings function on and off
function LevelGift:SetLevelGiftFuncOpen()
    if self.IsGetAll then
        local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WelfareLevelGift)
        _funcInfo:SetIsVisible(false)
    end
end

-- Number of prompts to the next time
function LevelGift:GetGotoNextCount()
    local _curLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    for i = 1, #self.LevelGiftList do
        local _item = self.LevelGiftList[i];
        local _cfg = DataConfig.DataLevelReward[_item.level];
        if _item.status == LevelGiftStatus.CanGet then
            return 0;
        elseif _item.status == LevelGiftStatus.NotReach then
            local _remainLevel =  _item.level - _curLevel;
            if _cfg.PushLimit > 0 and _remainLevel <= _cfg.PushLimit then
                return _remainLevel < 0 and 0 or _remainLevel;
            end
        end
    end
    return -1
end

-- Request to receive a level gift package
function LevelGift:ReqReceiveLevelGift(lv)
    local _req = ReqMsg.MSG_Welfare.ReqReceiveLevelGift:New()
    _req.level = lv
    _req:Send()
end

-- Level gift package data
function LevelGift:GS2U_ResLevelGiftData(msg)
    local _levelGiftList = self.LevelGiftList;
    local _count = self.LevelGiftList:Count();
    self.LevelGiftDic:Clear();

    if msg.data then
        self.LevelGiftList = List:New(msg.data)
        for i=1,#msg.data do
            self.LevelGiftDic:Add(msg.data[i].level, msg.data[i]);
        end
    else
        self.LevelGiftList:Clear()
    end
    local _isFind = false;
    if _count > 0 then
        local _rewards = {};
        local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        for i=1, _count do
            local _item = self.LevelGiftDic[_levelGiftList[i].level];
            if _item and _levelGiftList[i].receive ~= _item.receive then
                local _arr = Utils.SplitStrByTableS(DataConfig.DataLevelReward[_levelGiftList[i].level].QReward);
                for j=1,#_arr do
                    if _arr[j][4] == 9 or _arr[j][4] == _occ then
                        table.insert(_rewards,{Id = _arr[j][1], Num =_arr[j][2], IsBind=_arr[j][3] == 1});
                    end
                end
                _isFind = true
            end
            if _item and _levelGiftList[i].vipReceive ~= _item.vipReceive then
                local _arr = Utils.SplitStrByTableS(DataConfig.DataLevelReward[_levelGiftList[i].level].QRewardVip);
                for j=1,#_arr do
                    if _arr[j][4] == 9 or _arr[j][4] == _occ then
                        table.insert(_rewards,{Id = _arr[j][1], Num =_arr[j][2], IsBind=_arr[j][3] == 1});
                    end
                end
                _isFind = true
            end
            if _isFind then
                break
            end
        end
        if #_rewards > 0 then
            GameCenter.PushFixEvent(UIEventDefine.UIWelfareGetItemForm_OPEN, _rewards, {Callback = Utils.Handler(function(sender)
                    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_LVGIFT_REFRESH, self.IsGetAll)
                end, self)})
        end
    end

    self:UpdateGiftData()
    self:SetLevelGiftFuncOpen()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WELFARE_LVGIFT_REFRESH, self.IsGetAll)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_LEVELGIFTTIPS_REFRESH)
end

return LevelGift
