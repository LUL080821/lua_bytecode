------------------------------------------------
-- author:
-- Date: 2019-05-24
-- File: GuildApplyItem.lua
-- Module: GuildApplyItem
-- Description: Denominational Application List Subitem
------------------------------------------------

local GuildApplyItem = {
    Trans = nil,
    Go = nil,
    -- Player name
    NameLabel = nil,
    -- grade
    Lvlabel = nil,
    -- Fighting power
    FightingLabel = nil,
    Data = nil
}

-- Create a new object
function GuildApplyItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Clone one
function GuildApplyItem:Clone()
    local _go = UnityUtils.Clone(self.Go)
    return self:OnFirstShow(_go.transform)
end

 -- Find various controls on the UI
function GuildApplyItem:FindAllComponents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "List/NameLabel")
    self.FightingLabel = UIUtils.FindLabel(self.Trans, "List/FightLabel")
    self.Lvlabel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(self.Trans , "List/Level"))
    self.IconSpr = PlayerHead:New(UIUtils.FindTrans(self.Trans, "List/Icon"))
    local _btn = UIUtils.FindBtn(self.Trans, "AgreeBtn")
    UIUtils.AddBtnEvent(_btn, self.OnAgree, self)
    _btn = UIUtils.FindBtn(self.Trans, "RefuseBtn")
    UIUtils.AddBtnEvent(_btn, self.OnRefuse, self)
end

function GuildApplyItem:SetData(info)
    self.Data = info
    UIUtils.SetTextByString(self.NameLabel, info.name)
    self.Lvlabel:SetLevel(info.lv, true)
    UIUtils.SetTextByNumber(self.FightingLabel, info.fighting)
    self.IconSpr:SetHeadByMsg(info.roleId, info.career, info.head)
end

-- agree
function GuildApplyItem:OnAgree()
    local _req = {}
    local _temp = {}
    table.insert(_temp, self.Data.roleId)

    if #_temp > 0 then
        _req.roleId = _temp
        _req.agree = true
        GameCenter.Network.Send("MSG_Guild.ReqDealApplyInfo", _req)
    end
end

-- reject
function GuildApplyItem:OnRefuse()
    local _req = {}
    local _temp = {}
    table.insert(_temp, self.Data.roleId)

    if #_temp > 0 then
        _req.roleId = _temp
        _req.agree = false
        GameCenter.Network.Send("MSG_Guild.ReqDealApplyInfo", _req)
    end
end
return GuildApplyItem
