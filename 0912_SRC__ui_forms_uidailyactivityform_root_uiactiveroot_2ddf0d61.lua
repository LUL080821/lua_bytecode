------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIActiveRoot.lua
-- Module: UIActiveRoot
-- Description: Activity Root
------------------------------------------------

local UIActiveRoot = {
    -- Owner
    Owner = nil,
    -- Trans
    Trans = nil,
    -- Activity
    Active = nil,
    -- Activity Button
    -- ActiveBtn = nil,
    -- Activity Sprite
    ActiveSpr = nil,
    -- Current activity level
    ActiveValue = nil,
    -- Active Reward Button
    ActiveRewardBtn = nil,
    -- Number of active treasures used
    UseItemCount = nil,
    -- Increased activity
    AddActive = nil,
    -- InfoPanel
    InfoPanel = nil,

    -- item
    Item = nil,
    -- ListPanel
    ListPanel = nil,
    -- Activity Progress Display
    ProcessBar = nil,
    -- RewardPanel
    RewardPanel = nil,

    BgBottom = nil,
    -- List
    ActiveItemList = List:New(),
    -- Animation module
    AnimModule = nil,

    ------------------------------------------------
    RewardBtnList = nil,
    ------------------------------------------------
}

local L_ServerRewItem = {}

function UIActiveRoot:New(owner, trans)
    self.Owner = owner
    self.Trans = trans
    
    self:FindAllComponents()
    self:RegUICallback()
    self:Close()
    return self
end

function UIActiveRoot:FindAllComponents()
    -- self.ActiveBtn = UIUtils.FindBtn(self.Trans, "Active")
    self.ActiveSpr = UIUtils.FindSpr(self.Trans, "Active")
    -- self.ActiveSpr.fillAmount = 1
    self.ActiveRewardBtn = UIUtils.FindBtn(self.Trans, "ActiveReward")
    self.ActiveValue = UIUtils.FindLabel(self.Trans, "Active/Value")

    self.InfoPanel = UIUtils.FindTrans(self.Trans, "InfoPanel")
    self.Active = UIUtils.FindLabel(self.InfoPanel, "Active/Value")
    self.BgTex = UIUtils.FindTex(self.InfoPanel, "Active/BgTex")
    self.AddActive = UIUtils.FindLabel(self.InfoPanel, "AddActive/Value")
    self.UseItemCount = UIUtils.FindLabel(self.InfoPanel, "UseItemCount/Value")

    self.RewardPanel = UIUtils.FindTrans(self.Trans, "RewardPanel")
    self.ListPanel = UIUtils.FindTrans(self.RewardPanel, "ListPanel/Grid")
    self.Item = UIUtils.FindGo(self.RewardPanel, "ListPanel/Grid/Clone")
    self.ProcessBar = UIUtils.FindProgressBar(self.RewardPanel, "ActiveProgress")
    self.BgBottom = UIUtils.FindTex(self.RewardPanel, "BgBottom")
    self.CloseRewardPanelBtn = UIUtils.FindBtn(self.RewardPanel, "CloseButton")

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.RewardPanel)
    -- Add an animation
    self.AnimModule:AddNormalAnimation(0.3)
    -- self.InfoPanel.gameObject:SetActive(false)
    self.RewardPanel.gameObject:SetActive(false)
    self.RewardPanelShow = false

    ------------------------------------------------
    -- self.RewardProgressTrans = UIUtils.FindTrans(self.Trans, "RewardProgress")
    -- self.RewardBtnList = List:New()
    -- for i = 1, 3 do
    --     local btn = UIUtils.FindBtn(self.RewardProgressTrans, "ActiveReward" .. i)
    --     self.RewardBtnList:Add(btn)
    -- end
    -- self.RewardProcessBar = UIUtils.FindProgressBar(self.RewardProgressTrans, "ActiveProgress")
    
    self.BottomRewardProgress = UIUtils.FindTrans(self.Trans, "RewardProgress")
    self.ListRewardPanel = UIUtils.FindTrans(self.BottomRewardProgress, "Root")
    self.ServerRewItem = UIUtils.FindGo(self.ListRewardPanel, "ItemClone")
    self.BottomScrollView = UIUtils.FindScrollView(self.Trans, "RewardProgress")
    self.BottomProgressBar = UIUtils.FindProgressBar(self.Trans, "RewardProgress/Back")

    local _proSpr = UIUtils.FindSpr(self.BottomRewardProgress, "ActiveProgress")
    self.BottomSprWidth = _proSpr.width
    ------------------------------------------------
end

function UIActiveRoot:RegUICallback()
    -- UIUtils.AddBtnEvent(self.ActiveBtn, self.ActiveBtnOnClick, self) 
    UIUtils.AddBtnEvent(self.ActiveRewardBtn, self.OpenRewardPanel, self)
    UIUtils.AddBtnEvent(self.CloseRewardPanelBtn, self.CloseRewardPanel, self)
end

-- Refresh the panel
function UIActiveRoot:RefreshPanel()
    self:UpdateInfoPanel()
    self:UpdateRewardPanel()
    self:UpdateRewardProgressPanel()
end

function UIActiveRoot:UpdateInfoPanel()
    self.Owner.CSForm:LoadTexture(self.BgBottom, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_daily"))
    self.Owner.CSForm:LoadTexture(self.BgTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_109"))
    local _sys = GameCenter.DailyActivitySystem
    UIUtils.SetTextByNumber(self.AddActive, _sys.AddActive)
    UIUtils.SetTextByNumber(self.UseItemCount, _sys.UseItemCount)
    UIUtils.SetTextByEnum(self.Active, "Progress", _sys.CurrActive, _sys.MaxActive)
    -- self.ActiveSpr.fillAmount = _sys.CurrActive / _sys.MaxActive

    local _active = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
    UIUtils.SetTextByNumber(self.ActiveValue, _active)
    local _showRed = GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.DailyActivity, 3)
    UIUtils.FindGo(self.ActiveRewardBtn.transform, "RedPoint"):SetActive(_showRed)
end

-- Update panel information
function UIActiveRoot:UpdateRewardPanel()
    local _sys = GameCenter.DailyActivitySystem
    self.ProcessBar.value = _sys.CurrActive / _sys.MaxActive
    UIUtils.SetTextByProgress(UIUtils.FindLabel(self.RewardPanel, "Active"), _sys.CurrActive, _sys.MaxActive)
    local _list = {}
    DataConfig.DataDailyReward:Foreach(function(k, v)
        local _t = {}
        if _sys.ReceiveGiftIDList:Contains(k) then
            _t.Sort = 3
        else
            if v.QNeedintegral <= _sys.CurrActive then
                _t.Sort = 1
            else
                _t.Sort = 2
            end
        end
        _t.Value = v.QNeedintegral
        _t.Data = v
        table.insert(_list, _t)
    end)
    table.sort(_list, function(a, b)
        if a.Sort == b.Sort then
            return a.Value < b.Value
        else
            return a.Sort < b.Sort
        end
    end)

    local _index = 0
    for i = 1, #_list do
        local _cfg = _list[i].Data
        local _go = nil
        if _index < self.ListPanel.childCount then
            _go = self.ListPanel:GetChild(_index)
        else
            _go = UnityUtils.Clone(self.Item, self.ListPanel).transform
        end
        _index = _index + 1
        UIUtils.SetTextByNumber(UIUtils.FindLabel(_go, "Desc/Value"), _cfg.QNeedintegral)
        local _getBtn = UIUtils.FindGo(_go, "GetBtn")
        if _sys.ReceiveGiftIDList:Contains(_cfg.Id) then
            _getBtn:SetActive(false)
            UIUtils.FindGo(_go, "Recive"):SetActive(true)
            UIUtils.FindGo(_go, "Progressing"):SetActive(false)
        else
            UIUtils.FindGo(_go, "Recive"):SetActive(false)
            _getBtn:SetActive(_cfg.QNeedintegral <= _sys.CurrActive)
            UIUtils.FindGo(_go, "Progressing"):SetActive(_cfg.QNeedintegral > _sys.CurrActive)
        end
        UIEventListener.Get(_getBtn).parameter = _cfg.Id
        UIEventListener.Get(_getBtn).onClick = Utils.Handler(self.GetBtnOnClick, self)

        local _itemCfg = Utils.SplitStr(_cfg.QRewardItem, "_")
        local _itemTrans = UIUtils.FindTrans(_go, "UIItem")
        local _item = UILuaItem:New(_itemTrans)
        if _item then
            _item:InItWithCfgid(tonumber(_itemCfg[1]), tonumber(_itemCfg[2]), tonumber(_itemCfg[3]) == 1, false)
        end
    end
    
    self.BottomScrollView:ResetPosition()
end

function UIActiveRoot:UpdateRewardProgressPanel()
    local _sys = GameCenter.DailyActivitySystem
    local _list = {}
    DataConfig.DataDailyReward:Foreach(function(k, v)
        local _t = {}
        if _sys.ReceiveGiftIDList:Contains(k) then
            _t.Sort = 3
        else
            if v.QNeedintegral <= _sys.CurrActive then
                _t.Sort = 1
            else
                _t.Sort = 2
            end
        end
        _t.Value = v.QNeedintegral
        _t.Data = v
        table.insert(_list, _t)
    end)

    local _index = 0
    local _maxTimes = #_list
    local curTimes = _cfg.Id
    local length = self.BottomSprWidth - 100
    local step = length/(_maxTimes - 1)
    local startPos = self.ServerRewItem.transform.localPosition
    local reachedIndex = 0
    for i = 1, #_list do
        local _cfg = _list[i].Data
        local _go = nil
        if _index < self.ListRewardPanel.childCount then
            _go = self.ListRewardPanel:GetChild(_index)
        else
            _go = UnityUtils.Clone(self.ServerRewItem, self.ListRewardPanel).transform
        end
        _index = _index + 1
        UIUtils.SetTextByNumber(UIUtils.FindLabel(_go, "Sprite/Label"), _cfg.QNeedintegral)


        local _getBtn = UIUtils.FindGo(_go)
        if _sys.ReceiveGiftIDList:Contains(_cfg.Id) then
            UIUtils.FindGo(_go, "Open"):SetActive(true)
            UIUtils.FindGo(_go, "Effect"):SetActive(false)
            UIUtils.FindGo(_go, "Close"):SetActive(false)
        else
            UIUtils.FindGo(_go, "Open"):SetActive(false)
            UIUtils.FindGo(_go, "Effect"):SetActive(_cfg.QNeedintegral <= _sys.CurrActive)
            UIUtils.FindGo(_go, "Close"):SetActive(true)
        end

        if _cfg.QNeedintegral <= _sys.CurrActive then
            reachedIndex = i
        end

        UIEventListener.Get(_getBtn).parameter = _cfg.Id
        UIEventListener.Get(_getBtn).onClick = Utils.Handler(self.GetBtnOnClick, self)

        local _posX = startPos.x + step * (i - 1)
        UnityUtils.SetLocalPosition(_getBtn.transform, _posX, 11, 0)
    end


    local total = #_list
    local progress = reachedIndex / total
    if _sys.CurrActive >= _sys.MaxActive - 10 then
        self.BottomProgressBar.value = _sys.CurrActive / _sys.MaxActive
    else
        self.BottomProgressBar.value = progress - 0.1
    end    
        -- self.BottomProgressBar.value = _sys.CurrActive / _sys.MaxActive
        -- UIUtils.SetTextByProgress(UIUtils.FindLabel(self.RewardProgressTrans, "Active"), _sys.CurrActive, _sys.MaxActive)

    -- for i = 1, _maxTimes do
    --     local go = self.ObjList[i]
    --     local _posX = startPos.x + step * (i - 1)
    --     UnityUtils.SetLocalPosition(go.transform, _posX, 11, 0)
    -- end


    -- local _posX = -(self.BottomSprWidth / 2) + curTimes / _maxTimes * self.BottomSprWidth
    --     UnityUtils.SetLocalPosition(_go.transform, _posX, 11, 0)



end

-- function UIActiveRoot:ActiveBtnOnClick()
--     local _enable = self.InfoPanel.gameObject.activeSelf
--     self.InfoPanel.gameObject:SetActive( not _enable )
-- end

function UIActiveRoot:OpenRewardPanel()
    if not self.RewardPanelShow then
        self.AnimModule:PlayEnableAnimation()
    end
    self.RewardPanelShow = true
end

function UIActiveRoot:CloseRewardPanel()
    if self.RewardPanelShow then
        self.AnimModule:PlayDisableAnimation()
    end
    self.RewardPanelShow = false
end

function UIActiveRoot:OnTryHide()
    if self.RewardPanelShow then
        self:CloseRewardPanel()
        return false
    end
    return true
end

function UIActiveRoot:GetBtnOnClick(go)
    local _id = UIEventListener.Get(go).parameter
    GameCenter.DailyActivitySystem:ReqGetActiveReward(_id)
end

function UIActiveRoot:Show()
    self.Trans.gameObject:SetActive(true)
    self:RefreshPanel()
end

function UIActiveRoot:Close()
    self.Trans.gameObject:SetActive(false)
end


function L_ServerRewItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    -- _m.TweenTrans = UIUtils.FindTrans(trans, "Btn")
    -- _m.TweenPos = UIUtils.RequireTweenPosition(_m.TweenTrans)
    -- _m.GetBtnState = UIUtils.FindGo(trans, "Btn/GetState")
    -- _m.GetBtn = UIUtils.FindBtn(trans, "Btn")
    -- _m.DayLabel = UIUtils.FindLabel(trans, "Day")
    -- UIUtils.AddBtnEvent(_m.GetBtn, _m.GetAllServerOnClick, _m)
    -- _m.Item = UILuaItem:New(UIUtils.FindTrans(trans, "Btn/UIItem"))

    _m.Btn = UIUtils.FindBtn(trans)
    _m.Label = UIUtils.FindLabel(trans, "Sprite/Label")
    _m.Effect = UIUtils.FindTweenRotation(trans, "Effect")
    _m.EffectGo = UIUtils.FindGo(trans, "Effect")
    _m.Close = UIUtils.FindGo(trans, "Close")
    _m.Open = UIUtils.FindGo(trans, "Open")

    return _m
end

function L_ServerRewItem:Clone()
    return self:New(UnityUtils.Clone(self.Go).transform)
end

function L_ServerRewItem:SetAllServerReward(_cfg)
    
end


return UIActiveRoot
