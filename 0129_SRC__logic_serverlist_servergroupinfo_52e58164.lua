------------------------------------------------
-- Author:
-- Date: 2021-02-25
-- File: ServerGroupInfo.lua
-- Module: ServerGroupInfo
-- Description: Information about server packets
------------------------------------------------

local ServerGroupInfo = {
    Name = nil,

    -- The start ID of the current group
    StartID = nil,

    -- The end ID of the current group
    EndID = nil,

    -- Server list
    ServerList = nil,
}

function ServerGroupInfo:New(startid,endid,serlist,name)
    local _m = Utils.DeepCopy(self);
    _m.StartID = startid;
    _m.EndID = endid;
    _m.ServerList = serlist;
    _m.Name = name;
    Debug.Log("ServerGroupInfo:New:" ..  tostring(name));
    _m.ServerList:Sort(function (x,y)            
        return x.ShowOrder > y.ShowOrder;
    end) ;
    return _m;
end

function ServerGroupInfo:Create(alllist,startid,endid)
    local _list = nil;
    for i = alllist:Count() , 1, -1 do
        if (alllist[i].ShowOrder >= startid) and (alllist[i].ShowOrder <= endid) then
            if _list == nil then
                _list = List:New();
            end
            _list:Add(alllist[i]);
            alllist:RemoveAt(i);
        end
    end
    if _list then
        -- Sort from size - operational requirements
        return ServerGroupInfo:New(startid,endid,_list,DataConfig.DataMessageString.Get("Area",startid,endid));
    end
    return nil;
end

function ServerGroupInfo:GetName()
    return self.Name;
end

return ServerGroupInfo;