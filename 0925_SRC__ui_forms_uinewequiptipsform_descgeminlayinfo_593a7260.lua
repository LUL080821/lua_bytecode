------------------------------------------------
-- author:
-- Date: 2019-06-11
-- File: DescGemInlayInfo.lua
-- Module: DescGemInlayInfo
-- Description: Equipment single gem attribute data model on TIPS
------------------------------------------------

local DescGemInlayInfo = {
    ID = nil,
    Info = nil
}

function DescGemInlayInfo:New(id, type, pos, index)
    local _m = Utils.DeepCopy(self)
    _m.Type = 1
    if type then
        _m.Type = type
    end
    _m.Pos = pos
    _m.Index = index
    _m.ID = id
    _m.Info = DataConfig.DataItem[id]
    return _m
end
return DescGemInlayInfo