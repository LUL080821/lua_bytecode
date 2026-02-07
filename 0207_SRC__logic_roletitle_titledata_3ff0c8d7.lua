
------------------------------------------------
-- Author:
-- Date: 2019-06-12
-- File: TitleData.lua
-- Module: TitleData
-- Description: Title data
------------------------------------------------

local TitleData = {
    -- Configuration
    TitleCfg = nil,
    -- Title ID The id corresponding to the item table
    TitleID = nil,
    -- Do you have it
    Have = false,
    -- time left
    RemindTime = nil,
    -- Sort number
    Sort = nil,
    -- texture name
    TexName = nil,
    -- time
    Time = nil,
    -- The greater the value, the automatic wear of the title is preferred
    Level = 0,
    -- Title name
    TitleName = nil,
    -- Title Type
    TitleType = nil,
    -- Red dot
    ShowRed = false,
}

function TitleData:New(cfg)
    local _M = Utils.DeepCopy(self)
    _M.TitleCfg = cfg
    _M.TitleID = cfg.Id
    _M.Sort = cfg.Sort
    _M.TexName = cfg.Textrue
    _M.Time = cfg.Time
    _M.Level = cfg.Quality
    _M.TitleName = cfg.Name
    _M.TitleType = cfg.Type
    _M.CanShow = cfg.CanShow
    _M.AnimFrameRate = cfg.AnimFrameRate
    _M.VfxTitle = cfg.VfxTitle
    return _M
end

-- Update data
function TitleData:UpdateInfo(info)
    self.RemindTime = info.remainTime
    if info.remainTime == 0 then
        self.Have = true
    else
        self.Have = GameCenter.HeartSystem.ServerTime < info.remainTime
    end
end

-- Remove own
function TitleData:Remove()
    self.Have = false
    self.remainTime = nil
end

return TitleData