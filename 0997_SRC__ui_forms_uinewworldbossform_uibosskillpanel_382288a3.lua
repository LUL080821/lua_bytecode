--==============================--
--author:
--Date: 2019-07-17 06:19:18
--File: UIBossKillPanel.lua
--Module: UIBossKillPanel
--Description: Boss kill interface
--==============================--

local UIBossKillPanel =
{
    --The root node of the entire UI
    Trans = nil,
    --Preparent class
    Parent = nil,
    --Animation
    AnimModule = nil,
    --Close button
    CloseBtn = nil,
    --Background picture
    BgTex = nil,
    --No kill yet
    NoRecordTips = nil,
    KillGrid = nil,
    KilledItemGo = nil,
    KilledItemList = nil,
}

local L_KillItem = nil

function UIBossKillPanel:OnFirstShow(trans, parent)
    self.Trans = trans
    self.Parent = parent
    --Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    --Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    self.CloseBtn = UIUtils.FindBtn(self.Trans, "CloseButton")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.BgTex = UIUtils.FindTex(self.Trans, "Texture")
    self.NoRecordTips = UIUtils.FindGo(self.Trans, "NoRecordTips")
    self.NoRecordTips:SetActive(false)
    self.KillGrid = UIUtils.FindGrid(self.Trans, "RecordRoot/Grid")
    self.KilledItemGo = self.KillGrid.transform:GetChild(0).gameObject
    local _childCount = self.KillGrid.transform.childCount
    self.KilledItemList = List:New()
    for i = 0, _childCount - 1 do
        self.KilledItemList:Add(L_KillItem:New(self.KillGrid.transform:GetChild(i), self))
    end
    self.Trans.gameObject:SetActive(false)
    self.IsVisible = false
    return self
end

--Play the start-up picture
function UIBossKillPanel:Show(killedList)
    self.AnimModule:PlayEnableAnimation()
    self.IsVisible = true
    self.Parent.CSForm:LoadTexture(self.BgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_daily"))
    local _usedCount = #killedList
    local _itemCount = #self.KilledItemList
    for i = 1, _usedCount do
        local _killedItem = nil
        if i <= _itemCount then
            _killedItem = self.KilledItemList[i]
        else
            _killedItem = L_KillItem:New(UnityUtils.Clone(self.KilledItemGo).transform, self)
            self.KilledItemList:Add(_killedItem)
        end
        _killedItem:SetData(killedList[i])
        _killedItem.RootGo:SetActive(true)
    end
    for i = _usedCount + 1, _itemCount do
        self.KilledItemList[i].RootGo:SetActive(false)
    end
    self.KillGrid.repositionNow = true
    --No kill record mark display
    self.NoRecordTips:SetActive(_usedCount <= 0)
end

--Play Close animation
function UIBossKillPanel:Hide()
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end

function UIBossKillPanel:OnCloseBtnClick()
    self:Hide()
    -- CUSTOM - hiển thị lại model khi tắt popup KillRecord
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_WORLD_BOSS_KILL_RECORD_CLOSE)
    -- CUSTOM - hiển thị lại model khi tắt popup KillRecord
end

--The specific time of killing and killing
L_KillItem = {
    RootGo = nil,
    Parent = nil,
    Time = nil,
    Name = nil,
}

function L_KillItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = trans.gameObject
    _m.Parent = parent
    _m.Time = UIUtils.FindLabel(trans, "Time")
    _m.Name = UIUtils.FindLabel(trans, "Name")
    return _m
end

function L_KillItem:SetData(data)
    local _timeStr = Time.StampToDateTime(data.killTime, "yyyy-MM-dd HH:mm:ss")
    UIUtils.SetTextByString(self.Time, _timeStr)
    local _killerName = data.killer
    UIUtils.SetTextByEnum(self.Name, "NEWWORLDBOSS_COLOREDKILLINFO", _killerName)
end


return UIBossKillPanel;