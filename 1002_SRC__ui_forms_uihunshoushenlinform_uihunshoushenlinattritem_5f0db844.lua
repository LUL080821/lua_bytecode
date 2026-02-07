------------------------------------------------
-- author:
-- Date: 2019-8-15
-- File: UIHunShouShenLinAttrItem.lua
-- Module: UIHunShouShenLinAttrItem
-- Description: Soul Beast Forest BOSS attribute loading
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIHunShouShenLinAttrItem = {
    Trans = nil,
    Go = nil,
    -- name
    NameLabel = nil,
    ValueLabel = nil,
}

-- Create a new object
function UIHunShouShenLinAttrItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Find all controls
function UIHunShouShenLinAttrItem:FindAllComponents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "AttrName")
    self.ValueLabel = UIUtils.FindLabel(self.Trans, "AttrValue")
end

-- Clone an object
function UIHunShouShenLinAttrItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

-- Set interface content
function UIHunShouShenLinAttrItem:SetInfo(id, value)
    UIUtils.SetTextByPropName(self.NameLabel, id)
    UIUtils.SetTextByPropValue(self.ValueLabel, id, value)
end
return UIHunShouShenLinAttrItem