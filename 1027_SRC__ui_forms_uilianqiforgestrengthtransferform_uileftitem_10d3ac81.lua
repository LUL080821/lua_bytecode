------------------------------------------------
-- author:
-- Date: 2019-9-4
-- File: UILeftItem.lua
-- Module: UILeftItem
-- Description: Equipment Enhancement List Add-in
------------------------------------------------
local L_UIEquipmentItem = require("UI.Components.UIEquipmentItem")
local UILeftItem = {
    Trans       = nil,
    Go          = nil,
    --icon
    Item        = nil,
    -- name
    NameLabel   = nil,
    -- Strengthening level
    LevelLabel  = nil,
    -- Select the picture
    SelectSprGo = nil,
    -- Button click
    CallBack    = nil,
    -- data
    ItemData    = nil,
    -- Current level
    CurLv       = 0,
}

-- Create a new object
function UILeftItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Find all controls
function UILeftItem:FindAllComponents()
    self.Item = L_UIEquipmentItem:New(UIUtils.FindTrans(self.Trans, "UIBagItem"))
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Name")
    self.LevelLabel = UIUtils.FindLabel(self.Trans, "StrLv")
    self.SelectSprGo = UIUtils.FindGo(self.Trans, "Select")
    self.RedGo = UIUtils.FindGo(self.Trans, "Red")
    local _btn = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(_btn, self.OnBtnClick, self)
    self.Item.SingleClick = Utils.Handler(self.OnClickItem, self)
end

-- Clone an object
function UILeftItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

-- Button click
function UILeftItem:OnBtnClick()
    if self.CallBack then
        self.CallBack(self)
    end
end

-- Click on the equipment
function UILeftItem:OnClickItem(go)
    self:OnBtnClick()
end

-- Set interface content
function UILeftItem:SetInfo(pos, info, strInfo)
    self.Pos = pos
    self.ItemData = info
    self.StrInfo = strInfo
    self.Item:UpdateEquipment(self.ItemData, pos, 0)
    self.Item:OnSetStrengthShow(false)
    UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.StrInfo.level)
    GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.LevelLabel, self.StrInfo.level)
    if self.ItemData then
        UIUtils.SetTextByString(self.NameLabel, self.ItemData.Name)
    else
        UIUtils.SetTextByEnum(self.NameLabel, "C_UI_EQUIPSYNTH_NOEQUIP3")
    end
end
function UILeftItem:SetStrengthLv(lv)
    self.StrInfo.level = lv
    if self.IsSelect then
        UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.StrInfo.level)
    else
        UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.StrInfo.level)
    end
    GameCenter.LianQiForgeSystem:SetLabelColorByStrengthLevel(self.LevelLabel, self.StrInfo.level)
end

-- Set the selected status
function UILeftItem:OnSetSelect(isSelct)
    if self.SelectSprGo then
        self.IsSelect = isSelct
        self.SelectSprGo:SetActive(isSelct)
        if self.ItemData then
            if isSelct then
                UIUtils.SetTextFormat(self.NameLabel, "[202027]{0}[-]", self.ItemData.Name)
                UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.StrInfo.level)
            else
                UIUtils.SetTextFormat(self.NameLabel, "[202027]{0}[-]", self.ItemData.Name)
                UIUtils.SetTextFormat(self.LevelLabel, "+{0}", self.StrInfo.level)
            end
        end
    end
end

return UILeftItem
