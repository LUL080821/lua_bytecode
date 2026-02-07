------------------------------------------------
-- author:
-- Date: 2019-9-4
-- File: UIAttrItem.lua
-- Module: UIAttrItem
-- Description: List of the cleaning attributes in the middle of the equipment cleaning
------------------------------------------------
local UIAttrItem = {
    Trans            = nil,
    Go               = nil,

    -- ActiveAttribute
    NameLabel        = nil, -- Attribute name
    ValueLabel       = nil, -- Attribute value
    PercentLabel     = nil, -- Attribute percentage
    LimitLabel       = nil, -- Attribute range

    -- PreviewAttribute
    TempNameLabel    = nil, -- Temp Attribute name
    TempValueLabel   = nil, -- Temp Attribute value
    TempPercentLabel = nil, -- Temp Attribute percentage
    TempLimitLabel   = nil, -- Temp Attribute range

    -- Button click
    CallBack         = nil,
    -- data
    Data             = nil,
    -- Current line in washInfo
    CurIndex         = 0,
}

-- Create a new object
function UIAttrItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Find all controls
function UIAttrItem:FindAllComponents()
    --- ActiveAttribute
    self.ActiveGo = UIUtils.FindGo(self.Trans, "Actived")
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Actived/Name")
    self.ValueLabel = UIUtils.FindLabel(self.Trans, "Actived/AddValue")
    self.PercentLabel = UIUtils.FindLabel(self.Trans, "Actived/AddPercent")
    self.LimitLabel = UIUtils.FindLabel(self.Trans, "Actived/Limit")

    ---- PreviewAttribute
    self.PreviewGo = UIUtils.FindGo(self.Trans, "Actived/Preview")
    self.TempNameLabel = UIUtils.FindLabel(self.Trans, "Actived/Preview/Name")
    self.TempValueLabel = UIUtils.FindLabel(self.Trans, "Actived/Preview/AddValue")
    self.TempPercentLabel = UIUtils.FindLabel(self.Trans, "Actived/Preview/AddPercent")
    self.TempLimitLabel = UIUtils.FindLabel(self.Trans, "Actived/Preview/Limit")

    --
    self.LockIconGo = UIUtils.FindGo(self.Trans, "Actived/LockBtn/selected")
    self.LockIconGo:SetActive(false)
    self.UnActiveGo = UIUtils.FindGo(self.Trans, "ActiveCondition")
    self.UnActiveLabel = UIUtils.FindLabel(self.Trans, "ActiveCondition")
    local _btn = UIUtils.FindBtn(self.Trans, "Actived/LockBtn")
    UIUtils.AddBtnEvent(_btn, self.OnBtnClick, self)
end

-- Clone an object
function UIAttrItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

-- Button click
function UIAttrItem:OnBtnClick()
    if self.CallBack then
        self.CallBack(self)
    end
end

-- Updates the lock icon on lock state.
function UIAttrItem:SetLockedState(isSelected)
    if self.LockIconGo then
        self.LockIconGo:SetActive(isSelected)
    end
end

-- Handle Set lock
function UIAttrItem:HandleSetLock(equip, index, isLocked)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    if not equip then return end

    local part = equip:GetPart()
    local _useNewRule = _forgeSystem:IsUseNewWashRule()
    local washLine = _forgeSystem:GetWashInfoByPartAndIndex(part, index)
    local previewWashLine = _forgeSystem:GetPreviewWashInfoByPartAndIndex(part, index)
    if not (_useNewRule and washLine and previewWashLine) then
        return
    end

    local _targetInfo = (isLocked and washLine) or previewWashLine
    local _poolInfo = Utils.ParsePoolAttribute(_targetInfo.PoolID)
    if not _poolInfo then
        return
    end
    -- Update UI
    self:ShowWashValues(
            _forgeSystem,
            _targetInfo, _poolInfo,
            {
                name    = self.TempNameLabel,
                value   = self.TempValueLabel,
                percent = self.TempPercentLabel
            })
    UIUtils.SetTextByEnum(self.TempLimitLabel, "LIANQI_FORGE_WASH_RANGE", _poolInfo.minVal, _poolInfo.maxVal)
end

-- Set interface content
function UIAttrItem:SetInfo(index, equip, info, condition)
    self.CurIndex = index
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local _useNewRule = _forgeSystem:IsUseNewWashRule()
    if _useNewRule then
        self:HandleSetUI_NewRule(index, equip, condition)
    end
end

function UIAttrItem:HandleSetUI_NewRule(index, equip, condition)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    local part = equip:GetPart()
    local quality = equip:GetQuality()
    self.IsRedAttr = false

    local applyLine, requiredCondition = condition[1], condition[2]
    local canActivate = quality >= requiredCondition
    if not canActivate then
        self:ShowInactiveState(index, "C_UI_EQUIPSTARCONDITON", requiredCondition)
        return
    end

    self.IsActive = true
    self.ActiveGo:SetActive(true)
    self.UnActiveGo:SetActive(false)

    local washLine = _forgeSystem:GetWashInfoByPartAndIndex(part, index)
    if washLine then
        local poolInfo = Utils.ParsePoolAttribute(washLine.PoolID)
        if poolInfo then
            self.Trans.name = string.format("%d_%d", index, poolInfo.attrId)
            self:ShowWashValues(
                    _forgeSystem,
                    washLine, poolInfo,
                    {
                        name    = self.NameLabel,
                        value   = self.ValueLabel,
                        percent = self.PercentLabel,
                    })
            UIUtils.SetTextByEnum(self.LimitLabel, "LIANQI_FORGE_WASH_RANGE", poolInfo.minVal, poolInfo.maxVal)
        end
    else
        self:ShowEmptyState(index)
    end

    -- Hiển thị preview nếu có
    local previewWashLine = _forgeSystem:GetPreviewWashInfoByPartAndIndex(part, index)
    if previewWashLine then
        local previewPool = Utils.ParsePoolAttribute(previewWashLine.PoolID)
        if previewPool then
            self:ShowWashValues(
                    _forgeSystem,
                    previewWashLine, previewPool,
                    {
                        name    = self.TempNameLabel,
                        value   = self.TempValueLabel,
                        percent = self.TempPercentLabel,
                    })
            UIUtils.SetTextByEnum(self.TempLimitLabel, "LIANQI_FORGE_WASH_RANGE", previewPool.minVal, previewPool.maxVal)
        end
        self.PreviewGo:SetActive(true)
    else
        self.PreviewGo:SetActive(false)
    end
end

--- @param washInfo: thông tin tẩy luyện của 1 line (Index, Value, Percent, PoolID)
--- @param poolInfo: thông tin của pool (attrId, attrNameId, attrNameText, minVal, maxVal, showPercent)
function UIAttrItem:ShowWashValues(forgeSystem, washInfo, poolInfo, labels)
    if not (labels and labels.name and labels.value and labels.percent) then return end

    local isEmpty = not washInfo -- (washInfo == nil)
    local minVal = poolInfo.minVal or 0
    local maxVal = poolInfo.maxVal or 0
    local ratio = isEmpty and 0 or washInfo.Percent / 10000
    local percent = ratio * 100
    local value = isEmpty
            and minVal
            or math.floor((maxVal - minVal) * ratio + minVal)
   
    UIUtils.SetTextByStringDefinesID(labels.name, poolInfo.attrNameId) -- attr name
    UIUtils.SetTextByEnum(labels.value, "AddNum", Utils.FormatAttributeValue(poolInfo.attrId, value)) -- value text
    UIUtils.SetTextFormat(labels.percent, "({0}%)", math.FormatNumber(percent)) -- percent text
    -- Set color
    local colorPct = isEmpty and 0 or percent
    for _, label in pairs({ labels.name, labels.value, labels.percent }) do
        if label then
            forgeSystem:SetLabelColorByPercent(label, colorPct)
        end
    end
end

function UIAttrItem:ShowInactiveState(index, enumMess, requiredQuality)
    self.Trans.name = tostring(index)
    self.ActiveGo:SetActive(false)
    self.UnActiveGo:SetActive(true)
    local string = tostring(enumMess)
    UIUtils.SetTextByEnum(self.UnActiveLabel, string, requiredQuality)
end

function UIAttrItem:ShowEmptyState(index)
    self.Trans.name = tostring(index)
    UIUtils.SetTextFormat(self.NameLabel, "{0}", "N/A")
    UIUtils.SetTextByEnum(self.ValueLabel, "AddNum", 0)
    UIUtils.SetTextFormat(self.PercentLabel, "({0}%)", 0)
    local _forgeSystem = GameCenter.LianQiForgeSystem
    _forgeSystem:SetLabelColorByPercent(self.NameLabel, 0)
    _forgeSystem:SetLabelColorByPercent(self.ValueLabel, 0)
    _forgeSystem:SetLabelColorByPercent(self.PercentLabel, 0)
end

-------------------------- Helper --------------------------

------------------------------------------------------------
return UIAttrItem
