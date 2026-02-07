------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIWeeklItem.lua
-- Module: UIWeeklItem
-- Description: Weekly Item
------------------------------------------------

local UIWeeklItem = {
    Trans = nil,
    Name = nil,                                                 -- Activity name display
    Time = nil,                                                 -- Time display
    Btn = nil,                                                  -- Button
    SelectSprite = nil,                                         -- Select Show
    ID = 0,                                                     -- The corresponding id of DataActiveWeek
    NormalLine = nil,                                           -- Default line display
    SelectLine = nil,                                           -- Selected line display
    ActivityID = 0,                                             -- Id of drinking daily
}

function UIWeeklItem:New(trans, id)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.ID = id
    _m:FindAllComponents()
    _m:RegUICallback()
    _m:Show()
    return _m
end

function UIWeeklItem:FindAllComponents()
    self.Btn = UIUtils.FindBtn(self.Trans)
    self.Name1 = UIUtils.FindLabel(self.Trans,"UnSelect/Name")
    self.Time1 = UIUtils.FindLabel(self.Trans, "Time")
    self.Name2 = UIUtils.FindLabel(self.Trans,"Select/Name")

    self.NormalGo = UIUtils.FindTrans(self.Trans, "UnSelect")
    self.SelectGo = UIUtils.FindTrans(self.Trans, "Select")
end

function UIWeeklItem:RefreshWeekly(week)
    local _cfg = DataConfig.DataActiveWeek[self.ID]
    if not _cfg then
        self.Trans.gameObject:SetActive(false)
        return
    end
    self.Trans.gameObject:SetActive(true)
    self.ActivityID = _cfg.ActiveId
    local _active = false
    if _cfg.Week == week then
        _active = true
    elseif week == 0 and _cfg.Week == 7 then
        _active = true
    else
        _active = false
    end
    local _dailyCfg = DataConfig.DataDaily[self.ActivityID]
    if _dailyCfg ~= nil then
        local _day = _dailyCfg.Openday
        UIUtils.SetTextByStringDefinesID(self.Time1, _cfg._Time)
        if _day == nil or _day == 0 then
            if _active then
                UIUtils.SetColorByString(self.Time1, "#fffef5")
            else
                UIUtils.SetColorByString(self.Time1, "#666654")
            end
        else
            local _openDay = Time.GetOpenSeverDay()
            if _openDay < _day then
                UIUtils.SetTextByEnum(self.Time1, "C_DAILY_WEEK_DES", _day)
                UIUtils.SetColorByString(self.Time1, "#FF2A2A")
            else
                if _active then
                    UIUtils.SetColorByString(self.Time1, "#fffef5")
                else
                    UIUtils.SetColorByString(self.Time1, "#666654")
                end
            end
        end
    end
    self.SelectGo.gameObject:SetActive(_active)
    self.NormalGo.gameObject:SetActive(not _active)
    UIUtils.SetTextByStringDefinesID(self.Name1, _cfg._Name)
    UIUtils.SetTextByStringDefinesID(self.Name2, _cfg._Name)
end

function UIWeeklItem:RegUICallback()
    UIUtils.AddBtnEvent( self.Btn, self.OnBtnClick, self)
end

function UIWeeklItem:OnBtnClick()
    local _info = GameCenter.DailyActivitySystem:GetActivityInfo(self.ActivityID)
    if _info ~= nil then
        GameCenter.PushFixEvent(UIEventDefine.UIActivityTipsForm_OPEN, _info)
    else
    end
end

function UIWeeklItem:Clone(go, parentTrans, id)
    local obj = UnityUtils.Clone(go, parentTrans).transform
    return self:New(obj, id)
end

function UIWeeklItem:Show()
    if not self.Trans.gameObject.activeSelf then
        self.Trans.gameObject:SetActive(true)
    end
end

function UIWeeklItem:Close()
    self.Trans.gameObject:SetActive(false)
end

return UIWeeklItem