------------------------------------------------
-- author:
-- Date: 2020-08-17
-- File: UITabCircularIcon.lua
-- Module: UITabCircularIcon
-- Description: Menu Pagination Circular icon
------------------------------------------------
local UITabCircularIcon = {
    Trans = nil,                        -- Transform
    Go = nil,
    Type = 0,
}

function UITabCircularIcon:New(trans, type)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.Type = type
    _m:FindAllComponents()
    return _m
end

 -- Find Components
function UITabCircularIcon:FindAllComponents()
    local _myTrans = self.Trans
end

function UITabCircularIcon:SetCmp(iconId)

end

function UITabCircularIcon:SetVisable(type)
    self.Go:SetActive(self.Type == type)
end

return UITabCircularIcon