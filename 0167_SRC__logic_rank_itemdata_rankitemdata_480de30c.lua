------------------------------------------------
-- Author:
-- Date: 2019-04-26
-- File: RankItemData.lua
-- Module: RankItemData
-- Description: Ranking item data
------------------------------------------------
-- Quote
local RankItemData = {
    RankType = 0,
    -- Ranking
    Rank = 0,
    RoleId = 0,
    Level = 0,
    -- Profession
    Career = 0,
    -- Number of times you have been praised
    PraiseCount = 0,
    --vip
    VipLv = 0,
    Name = nil,
    -- Gang name
    GuildName = nil,
    Point = nil,
    -- Is it online or not
    IsOnline = false,
    -- Combat power
    FightPower = 0,
    -- Server id
    Sid = 0,
    -- Have you admired this player
    IsPraise = false,
    -- Appearance information
    VisInfo = nil,
    Head = nil,
}

function RankItemData:New(info, isCross, rankType)
    local _m = Utils.DeepCopy(self)
    _m.RankType = rankType
    _m.Rank = info.rank
    _m.RoleId = info.roleId
    _m.Level = info.level
    _m.Name = info.roleName
    _m.GuildName = info.guildName
    _m.Career = info.career
    if _m.RankType == 125 then
        local num = tonumber(info.rankData)
        local jie = math.floor( num/100 )
        local lv = num - (jie * 100)
        _m.Point = UIUtils.CSFormat(DataConfig.DataMessageString.Get("RANK_JIEXING"), jie, lv)
    else
        _m.Point = info.rankData
    end
    _m.PraiseCount = info.beWorshipedNum
    _m.IsOnline = info.isOnline
    _m.VipLv = info.viplevel
    _m.FightPower = info.fightPower
    _m.IsPraise = info.beWorship
    if isCross then
        _m.Sid = info.serverId
        _m.VisInfo = PlayerVisualInfo:New()
        _m.VisInfo:ParseByLua(info.facade, info.stateVip)
    end
    _m.Head = info.head
    return _m
end

function RankItemData:SetData(info, isCross)
    self.Rank = info.rank
    self.RoleId = info.roleId
    self.Level = info.level
    self.Name = info.roleName
    self.GuildName = info.guildName
    self.Career = info.career
    if self.RankType == 125 then
        local num = tonumber(info.rankData)
        local jie = math.floor( num/100 )
        local lv = num - (jie * 100)
        self.Point = UIUtils.CSFormat(DataConfig.DataMessageString.Get("RANK_JIEXING"), jie, lv)
    else
        self.Point = info.rankData
    end
    self.PraiseCount = info.beWorshipedNum
    self.IsOnline = info.isOnline
    self.VipLv = info.viplevel
    self.FightPower = info.fightPower
    self.IsPraise = info.beWorship
    if isCross then
        self.Sid = info.serverId
        self.VisInfo = PlayerVisualInfo:New()
        self.VisInfo:ParseByLua(info.facade, info.stateVip)
    end
    self.Head = info.head
end
return RankItemData