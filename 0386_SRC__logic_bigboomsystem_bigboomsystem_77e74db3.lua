------------------------------------------------
-- Author: 
-- Date: 2021-03-05
-- File: BigBoomSystem.lua
-- Module: BigBoomSystem
-- Description: Silver Ingot Display System
------------------------------------------------
local BigBoomSystem = {
    Type = BoomType.Default,
    ToType = BoomToType.Default,
    LingShiId = 0,
}

-- initialization
function BigBoomSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_COIN_ADD_UPDATE, self.OnAddMoney, self)
    self.LingShiId = ItemTypeCode.Lingshi
end

-- De-initialization
function BigBoomSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_COIN_ADD_UPDATE, self.OnAddMoney, self)
end

function BigBoomSystem:Play(type, toType)
    type = type or BoomType.Default
    toType = toType or BoomToType.Default
    self.Type = type
    self.ToType = toType
    GameCenter.PushFixEvent(UIEventDefine.UIBigBoomForm_Open)
end

function BigBoomSystem:OnAddMoney(array, sender)
    if array == nil then
        return
    end
    local _cionId = array[0]
    if self.LingShiId == _cionId then
        self:Play()
    elseif 16 == _cionId then
        -- VIP Point
        self:Play(BoomType.VipExp, BoomToType.Vip)
    end
end

return BigBoomSystem