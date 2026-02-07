-- Author: 
-- Date: 2020-02-18
-- File: XmFightRecordInfo.lua
-- Module: XmFightRecordInfo
-- Description: Statistics of the Immortal Alliance War
-----------------------------------------------
local XmFightRecordMemberInfo = require("Logic.XmFight.XmFightRecordMemberInfo");

local XmFightRecordInfo =
{
    -- Sorting number
    OrderNo = 0;
    -- name
    Name = "",
    -- integral
    Score = 0,
    -- Whether to win
    IsWin = false,
    -- Gang Banner
    Icon = 0,
    -- Gang member information
    MemberList = nil,

    -- Is it currently selected
    IsSelected = false;
    
}

function XmFightRecordInfo:New(pb_msg)
    if pb_msg then 
        local _m = Utils.DeepCopy(self);
        _m.Name = pb_msg.guildName;
        _m.Score = pb_msg.guildScore;
        _m.IsWin = pb_msg.res;
        _m.Icon = pb_msg.icon;
        _m.MemberList = XmFightRecordMemberInfo:Parse( pb_msg.members);
        return _m;
    else
        return nil;
    end
end

-- Parsing the message
function XmFightRecordInfo:Parse(inmsglist,outlist)
    if outlist == nil then
        outlist = List:New();
    else
        outlist:Clear();
    end
    local _list = inmsglist;
    if _list ~= nil then
        for i =1, #_list do
            local _item = XmFightRecordInfo:New(_list[i]);
            if _item  then
                outlist:Add(_item);         
            end
        end
    end

      -- Sorting
    outlist:Sort(function(a,b) 
        if a.IsWin and (not b.IsWin) then
            return true;
        elseif (not a.IsWin) and b.IsWin then
            return false;
        else
            return a.Score > b.Score ;
        end
    end );

   -- Set the sort
   for i=1,#outlist do
       outlist[i].OrderNo = i;
    end
    return outlist;
end

--[[
-- Demo Data
function XmFightRecordInfo:DemoData()
    local _res = List:New();
    _res:Add(XmFightRecordInfo:New({
        guildName = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_1"),
        guildFight = 999934,
        res = true,
        members = {
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            }
        }
    }
    ));

    _res:Add(XmFightRecordInfo:New({
        guildName = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_3"),
        guildFight = 11111,
        res = false,
        members = {
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            }
        }
    }
    ));

    _res:Add(XmFightRecordInfo:New({
        guildName = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_4"),
        guildFight = 2222,
        res = false,
        members = {
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            },
            {
                name = DataConfig.DataMessageString.Get("XMFIGHTRECORD_TISHI_2"),
                career = 0,
                record = 3000,
                killNum = 1000,
                destroyNum = 10,
                repairNum = 44,
                breakNum = 2,
            }
        }
    }
    ));

        -- Sorting
        _res:Sort(function(a,b) 
            if a.IsWin and (not b.IsWin) then
                return true;
            elseif (not a.IsWin) and b.IsWin then
                return false;
            else
                return a.Score > b.Score ;
            end
        end );
    
       -- Set the sort
       for i=1,#_res do
        _res[i].OrderNo = i;
        end
    return _res;
end
]]

return XmFightRecordInfo;
