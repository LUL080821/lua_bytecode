------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIAttributeComponent.lua
-- Module: UIAttributeComponent
-- Description: Equipped with a single attribute component on TIPS
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIAttributeComponent = {
    Trans         = nil,
    Go            = nil,
    ValueLabel    = nil,
    Data          = nil,
    IsPlaceholder = nil
}

function UIAttributeComponent:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.GO = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Find Components
function UIAttributeComponent:FindAllComponents()
    self.ValueLabel = UIUtils.FindLabel(self.Trans)
end

-- Clone an object
function UIAttributeComponent:Clone()
    local _go = GameObject.Instantiate(self.GO)
    local _trans = _go.transform
    _trans.parent = self.Trans.parent
    UnityUtils.ResetTransform(_trans)
    return UIAttributeComponent:New(_trans)
end

-- Setting up Active
function UIAttributeComponent:SetActive(active)
    self.GO:SetActive(active)
end

-- Setting up data or configuration files
function UIAttributeComponent:SetData(dat)
    self.Data = dat

    -- print("self.IsPlaceholder SetData", self.IsPlaceholder )

    self.IsPlaceholder = (dat.ID == nil or dat.Value == nil)

    self:RefreshData()
end

function UIAttributeComponent:RefreshData()
    --- Set text mặc định chưa giám định cho
    if self.IsPlaceholder then
        UIUtils.SetTextByString(self.ValueLabel, GosuSDK.GetLangString("APPRAISE_PLACEHOLDER"))  -- dùng tên làm text hiển thị
        -- UIUtils.SetTextByEnum(self.ValueLabel, "Trang bị chưa được giám định")
        return
    end

    local _data = self.Data
    if self:HasValidValue(_data) then
        local displayFormat = "{0}  +{1}"
        local bonus = _data.ExtraData and _data.ExtraData.bonus
        if bonus and bonus > 0 then
            --local attrCfg = DataConfig.DataAttributeAdd[_data.ID]
            --local bonusText = tostring(bonus)
            --if attrCfg and attrCfg.ShowPercent == 1 then
            --    bonusText = bonusText .. "%"
            --end
            --displayFormat = string.format("{0}  +{1} [1F7F1A]+(%s)[-]", bonusText)
            local bonusText = Utils.FormatAttributeValue(_data.ID, bonus)
            displayFormat = string.format("{0}  +{1} [1F7F1A]+(%s)[-]", bonusText)
        end

        UIUtils.SetTextByPropNameAndValue(self.ValueLabel, _data.ID, _data.Value, displayFormat)
        return
    end

    if _data and _data.Placeholder then
        UIUtils.SetTextByEnum(self.ValueLabel, _data.Placeholder)
    else
        UIUtils.SetTextByString(self.ValueLabel, "--")
    end
end
-- Set a name
function UIAttributeComponent:SetName(name)
    self.GO.name = name;
end

function UIAttributeComponent:OnSetValueShow()
    if (self.Data ~= nil) then
        UIUtils.SetTextByPropNameAndValue(self.ValueLabel, self.Data.ID, self.Data.Value, "{0}  +{1}%")
    else
        Debug.LogError("Data is empty, UIAttributeComponent:OnSetValueShow");
    end
end

function UIAttributeComponent:OnSetColor(r, g, b)
    UIUtils.SetColor(self.ValueLabel, r, g, b, 1)
end

function UIAttributeComponent:HasValidValue(data)
    if not data then return false end

    if data.ID == nil or data.ID == 99 then
        return false
    end

    if data.Value == nil then
        return false
    end

    return true
end

return UIAttributeComponent