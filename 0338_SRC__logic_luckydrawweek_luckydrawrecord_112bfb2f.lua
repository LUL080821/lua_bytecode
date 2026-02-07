------------------------------------------------
-- Author: 
-- Date: 2020-02-26
-- File: LuckyDrawRecord.lua
-- Module: LuckyDrawRecord
-- Description: Raffle Record
------------------------------------------------
local LuckyDrawRecord = {
    -- Character name
    PlayerName = nil,
    -- Item ID
    ItemID = 0,
    -- Quantity of items
    ItemNum = 1,
    -- Is the item bound?
    ItemIsBind = false,
    -- Current reward type: 0: Special prize, 1: First prize, 2: Second prize, 3: Third prize
    AwardType = 0,
    -- Records of lottery
    MsgText = nil,
}

function LuckyDrawRecord:New(sinfo, recType)
    local _m = Utils.DeepCopy(self)
    _m:Init(sinfo, recType);    
    return _m;
end

function LuckyDrawRecord:Init(sinfo, recType)
    self.PlayerName = sinfo.playername;
    self.ItemID = sinfo.itemId;
    self.ItemNum = sinfo.itemNum;
    self.ItemIsBind = sinfo.bind;
    self.AwardType = sinfo.awardType;
    local _awardTypeText = nil
    if self.AwardType == 0 then
        _awardTypeText = DataConfig.DataMessageString.Get("C_TEDENGJIANG")
    elseif self.AwardType == 1 then
        _awardTypeText = DataConfig.DataMessageString.Get("C_YIDENGJIANG")
    elseif self.AwardType == 2 then
        _awardTypeText = DataConfig.DataMessageString.Get("C_ERDENGJIANG")
    elseif self.AwardType == 3 then
        _awardTypeText = DataConfig.DataMessageString.Get("C_SANDENGJIANG")
    end
    local _itemName = DataConfig.DataItem[self.ItemID].Name
    -- 0 Full server record 1 own record
    if recType == 1 then
        self.MsgText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_LUCK_GONGXICHOUZHONG"),_awardTypeText, _itemName)
    else
        self.MsgText = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_LUCK_GONGXICHOUZHONG2"),self.PlayerName, _awardTypeText, _itemName)
    end
end

return LuckyDrawRecord;
