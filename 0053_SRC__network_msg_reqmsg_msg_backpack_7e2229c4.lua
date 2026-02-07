local MSG_backpack = {
    ItemCoin = {
       type = 0,
       value = 0,
    },
    Key_Value = {
       key = 0,
       value = nil,
    },
    ItemInfo = {
       itemId = 0,
       itemModelId = 0,
       num = 0,
       gridId = nil,
       isbind = nil,
       lostTime = nil,
       cdTime = nil,
       suitId = nil,
       strengLv = nil,
       percent = nil,
    },
    OpenGiftInfo = {
       itemModelId = 0,
       num = 0,
       isbind = false,
       strengLv = nil,
       starLv = nil,
    },
    ReqDelItem = {
       itemId = 0,
    },
    ReqMoveItem = {
       itemId = 0,
       num = 0,
    },
    ReqUseItem = {
       itemId = 0,
       num = 0,
       index = nil,
    },
    ReqBagClearUp = {
    },
    ReqOpenBagCell = {
       cellId = 0,
    },
    ReqSellItems = {
       itemId = 0,
       num = 0,
    },
    ReqCompound = {
       nonBindId = List:New(),
       bindId = List:New(),
       type = 0,
    },
    ReqUseItemMakeBuff = {
       itemModelId = 0,
    },
    ReqAutoUseItem = {
    },
}
local L_StrDic = {
    [MSG_backpack.ReqDelItem] = "MSG_backpack.ReqDelItem",
    [MSG_backpack.ReqMoveItem] = "MSG_backpack.ReqMoveItem",
    [MSG_backpack.ReqUseItem] = "MSG_backpack.ReqUseItem",
    [MSG_backpack.ReqBagClearUp] = "MSG_backpack.ReqBagClearUp",
    [MSG_backpack.ReqOpenBagCell] = "MSG_backpack.ReqOpenBagCell",
    [MSG_backpack.ReqSellItems] = "MSG_backpack.ReqSellItems",
    [MSG_backpack.ReqCompound] = "MSG_backpack.ReqCompound",
    [MSG_backpack.ReqUseItemMakeBuff] = "MSG_backpack.ReqUseItemMakeBuff",
    [MSG_backpack.ReqAutoUseItem] = "MSG_backpack.ReqAutoUseItem",
}
local L_SendDic = setmetatable({},{__mode = "k"});

local mt = {}
mt.__index = mt
function mt:New()
    local _str = L_StrDic[self]
    local _clone = Utils.DeepCopy(self)
    L_SendDic[_clone] = _str
    return _clone
end
function mt:Send()
    GameCenter.Network.Send(L_SendDic[self], self)
end

for k,v in pairs(L_StrDic) do
    setmetatable(k, mt)
end

return MSG_backpack

