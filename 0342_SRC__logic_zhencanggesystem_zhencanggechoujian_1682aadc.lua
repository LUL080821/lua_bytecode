
------------------------------------------------
-- Author:
-- Date: 2020-09-02
-- File: ZhenCangGeChouJian.lua
-- Module: ZhenCangGeChouJian
-- Description: Treasure Pavilion lottery data
------------------------------------------------
-- Quote
local ZhenCangGeChouJian = {
    CfgId = 0,
    Cfg = nil,
    ItemData = nil,
}
function ZhenCangGeChouJian:New( k, v )
    local _m = Utils.DeepCopy(self)
    _m.CfgId = k
    _m.Cfg = v
    return _m
end

function ZhenCangGeChouJian:GetCfgId()
    return self.CfgId
end

function ZhenCangGeChouJian:GetCfg()
    return self.Cfg
end

-- Get display prop data {Id, Num}
function ZhenCangGeChouJian:GetItemData(occ)
    if self.ItemData == nil then
        if self.Cfg ~= nil then
            local list = Utils.SplitStr(self.Cfg.Reward, ';')
            for i = 1,#list do
                local subList = Utils.SplitNumber(list[i], '_')
                if occ == subList[4] or subList[4] == 9 then
                    self.ItemData = {Id = subList[1], Num = subList[2], IsBind = subList[3] == 1}
                    break
                end
            end
        end
    end
    return self.ItemData
end

function ZhenCangGeChouJian:IsSuper()
    return self.Cfg.Superreward == 1
end

return ZhenCangGeChouJian