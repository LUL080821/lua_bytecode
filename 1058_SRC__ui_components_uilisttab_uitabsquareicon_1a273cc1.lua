------------------------------------------------
-- author:
-- Date: 2020-08-17
-- File: UITabCircularIcon.lua
-- Module: UITabCircularIcon
-- Description: Menu Pagination Square icon contains quality
------------------------------------------------
local ItemBase = CS.Thousandto.Code.Logic.ItemBase
local UITabSquareIcon = {
    Trans = nil,
    Go = nil,
    -- quality
    Quality = nil,        
    -- picture
    Icon = nil,
    Type = 0,
}

function UITabSquareIcon:New(trans, type)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Type = type
    _m:FindAllComponents()
    return _m
end

 -- Find Components
function UITabSquareIcon:FindAllComponents()
    local _myTrans = self.Trans
    self.Quality = UIUtils.FindSpr(_myTrans, "Quality")
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_myTrans, "Icon"))
end

-- Set up components
function UITabSquareIcon:SetCmp(qualityLv, iconId)
    self.Quality.spriteName = Utils.GetQualitySpriteName(qualityLv)--UIUtils.CSFormat("n_pinzhikuang_{0}", qualityLv)
    self.Icon:UpdateIcon(iconId)
end

function UITabSquareIcon:SetVisable(type)
    self.Go:SetActive(self.Type == type)
end

return UITabSquareIcon