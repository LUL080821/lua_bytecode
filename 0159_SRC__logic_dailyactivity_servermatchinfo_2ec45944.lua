
------------------------------------------------
-- Author:
-- Date: 2019-04-22
-- File: ServerMatchInfo.lua
-- Module: ServerMatchInfo
-- Description: Daily data
------------------------------------------------
local ServerMatchInfo = {
    -- Average grade
    AverageLv = 0,
    -- Server information
    ServersInfo = List:New(),
}

local L_ServerInfo = {
    -- Server ID
    ServerID = 0,
    -- Server Name
    ServerName = nil,
    -- The world level corresponding to the server
    ServerWorldLv = 0,
}

-- Initial activity data
function ServerMatchInfo:New(list)
    local _M = Utils.DeepCopy(self)
    _M.ServersInfo:Clear()
    local _totalLv = 0
    for i = 1, #list do
        local _t = Utils.DeepCopy(L_ServerInfo)
        _t.ServerID = list[i].serverid
        _t.ServerName = list[i].servername
        _t.ServerWorldLv = list[i].serverWroldLv
        _M.ServersInfo:Add(_t)

        _totalLv = _totalLv + list[i].serverWroldLv
    end

    -- Average world level round up
    _M.AverageLv = math.ceil( _totalLv / #list )
    return _M
end


return ServerMatchInfo