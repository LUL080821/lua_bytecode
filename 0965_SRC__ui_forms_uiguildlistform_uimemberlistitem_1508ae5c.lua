------------------------------------------------
-- author:
-- Date: 2019-05-14
-- File: UIMemberRankItem.lua
-- Module: UIMemberRankItem
-- Description: Sectarian Personal Ranking Subcontrol
------------------------------------------------

local UIMemberListItem = {
    Trans = nil,
    Go = nil,
    -- name
    NameLabel = nil,
    -- Ranking
    RankLabel = nil,
    -- grade
    LevelLabel = nil,
    -- Title description
    TitleLabel = nil,
    -- Fighting power
    FightLabel = nil
}

-- Create a new object
function UIMemberListItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
 end

function UIMemberListItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

 -- Find various controls on the UI
 function UIMemberListItem:FindAllComponents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "NameLabel")
    self.FightLabel = UIUtils.FindLabel(self.Trans, "PowerLabel")
    if UIUtils.FindTrans(self.Trans, "TitleLabel") then
        self.TitleLabel = UIUtils.FindLabel(self.Trans, "TitleLabel")
    end
    self.OfficalLabel = UIUtils.FindLabel(self.Trans, "OfficalLabel")
    self.ContributeLabel = UIUtils.FindLabel(self.Trans, "ContributeLabel")
    self.StateLabel = UIUtils.FindLabel(self.Trans, "StateLabel")
    self.IconSpr = PlayerHead:New(UIUtils.FindTrans(self.Trans, "Icon"))
    self.SelectGo = UIUtils.FindGo(self.Trans, "Select")
    self.Lvlabel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(self.Trans , "LvLabel"))
    local _btn = UIUtils.FindBtn(self.Trans, "Box")
    UIUtils.AddBtnEvent(_btn, self.ListClick, self)
 end

  -- Update items
  function UIMemberListItem:OnUpdateItem(info, isTitle, isRank)
    if info == nil then
        Debug.LogError("Loading error, data is empty")
        return
    end
    self.PlayerData = info
    UIUtils.SetTextByString(self.NameLabel, info.name)
    UIUtils.SetTextByNumber(self.FightLabel, info.fighting)
    self.Lvlabel:SetLevel(info.lv, true)
    UIUtils.SetTextByString(self.OfficalLabel, GameCenter.GuildSystem:OnGetOfficalString(info.rank, info.isProxy))
    UIUtils.SetTextByNumber(self.ContributeLabel, info.contribute)
    if info.lastOffTime > 0 then
        UIUtils.SetTextByString(self.StateLabel, UIUtils.CSFormat("[D6DDF0]{0}[-]", GameCenter.GuildSystem:OnGetOnlineStateStr(info.lastOffTime)))
    else
        UIUtils.SetTextByString(self.StateLabel, UIUtils.CSFormat("[73ed6b]{0}[-]", GameCenter.GuildSystem:OnGetOnlineStateStr(info.lastOffTime)))
    end
    self.IconSpr:SetHeadByMsg(info.roleId, info.career, info.Head)
    if self.TitleLabel then
        if isRank then
            if not isTitle then
                UIUtils.SetTextByEnum(self.TitleLabel, "GuildNoTitleTips")
            else
                UIUtils.ClearText(self.TitleLabel)
            end
        else
            UIUtils.SetTextByEnum(self.TitleLabel, "C_GUILD_TITLE_NULL")
        end
    end
    self:OnSetSelect(false)
 end

 function UIMemberListItem:OnSetSelect(isSelect)
    self.SelectGo:SetActive(isSelect)
end

function UIMemberListItem:ListClick()
    if self.CallBack ~= nil then
        self.CallBack(self)
    end
end
return  UIMemberListItem
