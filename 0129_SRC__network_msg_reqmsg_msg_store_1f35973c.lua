local MSG_store = {
    ReqStoreToBag = {
       cellId = 0,
    },
    ReqBagToStore = {
       cellId = 0,
    },
    ReqStoreMoveItem = {
       itemId = 0,
       toGridId = 0,
       num = 0,
    },
    ReqStoreClearUp = {
    },
    ReqOpenStoreCell = {
       cellId = 0,
    },
}
local L_StrDic = {
    [MSG_store.ReqStoreToBag] = "MSG_store.ReqStoreToBag",
    [MSG_store.ReqBagToStore] = "MSG_store.ReqBagToStore",
    [MSG_store.ReqStoreMoveItem] = "MSG_store.ReqStoreMoveItem",
    [MSG_store.ReqStoreClearUp] = "MSG_store.ReqStoreClearUp",
    [MSG_store.ReqOpenStoreCell] = "MSG_store.ReqOpenStoreCell",
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

return MSG_store

