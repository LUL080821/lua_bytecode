-- Author: 
-- Date: 2020-02-18
-- File: XmRewardInfo.lua
-- Module: XmRewardInfo
-- Description: Public reward information in the Immortal Alliance
-----------------------------------------------
local XmRewardInfo =
{
    -- Arrange the sequence number
    OrderNo = 0,
    -- Item ID
    Id = 0,
    -- Quantity of items
    Num = 0,
    -- Whether to bind
    IsBind = false,   
}

-- Constructor
function XmRewardInfo:New(itemID,num,isBind,orderNo)
    local _m = Utils.DeepCopy(self);
    _m.Id = itemID;
    _m.OrderNo = 0;
    _m.IsBind = isBind;
    _m.OrderNo = orderNo;
    if num == nil or num < 0 then
        _m.Num = 0;
    else
        _m.Num = num
    end
    return _m;
end

-- Parsing reward strings
function XmRewardInfo:ParseStr(rewardstr,Occ)
    local _result = List:New();
    local list = Utils.SplitStr(rewardstr,';')
    if list ~= nil then
        for i = 1,#list do
            local _values = Utils.SplitStr(list[i],'_')
            local _occ = tonumber(_values[4])
            local _playerOcc = UnityUtils.GetObjct2Int(Occ)
            if _occ == nil or _playerOcc == _occ or _occ == 9 then
                local id = tonumber(_values[1])
                local num = tonumber(_values[2])
                local isBind = tonumber(_values[3]) == 1   
                _result:Add(XmRewardInfo:New(id,num,isBind,i));     
            end               
        end
    end
    return _result;
end

return XmRewardInfo;