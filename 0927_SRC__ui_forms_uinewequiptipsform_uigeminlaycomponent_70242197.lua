------------------------------------------------
-- author:
-- Date: 2019-04-22
-- File: UIGemInlayComponent.lua
-- Module: UIGemInlayComponent
-- Description: Equipped with TIPS gem inlay components
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIGemInlayComponent ={
    Trans = nil,
    Go = nil,
    ValueLabel = nil,
    Data = nil
}

function UIGemInlayComponent:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.GO = trans.gameObject
    _m:FindAllComponents()
    return _m
end

-- Find Components
function UIGemInlayComponent:FindAllComponents()
    self.NameLabel = UIUtils.FindLabel(self.Trans, "NameLabel")
    self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.Trans, "Icon"))
    self.AttLabel1 = UIUtils.FindLabel(self.Trans, "AttrLabel1")
    self.AttLabel2 = UIUtils.FindLabel(self.Trans, "AttrLabel2")
    self.LockGo = UIUtils.FindGo(self.Trans, "Lock")
end

-- Clone an object
function UIGemInlayComponent:Clone()
    local _go = GameObject.Instantiate(self.GO)
    local _trans = _go.transform
    _trans.parent = self.Trans.parent
    UnityUtils.ResetTransform(_trans)
    return UIGemInlayComponent:New( _trans)
end

-- Setting up Active
function UIGemInlayComponent:SetActive(active)
    self.GO:SetActive(active)
end

-- Setting up data or configuration files
function UIGemInlayComponent:SetData(dat)
    self.Data = dat
    self:RefreshData()
end

function UIGemInlayComponent:RefreshData()
    if(self.Data.Info ~= nil) then
        local _str = nil
        self.AttLabel1.gameObject:SetActive(true)
        self.AttLabel2.gameObject:SetActive(true)
        self.Icon:UpdateIcon(self.Data.Info.Icon)
        UIUtils.SetColorByQuality(self.NameLabel, self.Data.Info.Color)
        UIUtils.SetTextByString(self.NameLabel, self.Data.Info.Name)
        local _arr = Utils.SplitStr(self.Data.Info.EffectNum, ";")
        local _single = Utils.SplitStr(_arr[1], "_")
        if #_single == 3 then
            local _effectType = tonumber(_single[1])
            local _attType = tonumber(_single[2])
            local _attNum = tonumber(_single[3])
            if _effectType == 1 then
                _str = string.format( "%s +%s", L_BattlePropTools.GetBattlePropName(_attType), L_BattlePropTools.GetBattleValueText(_attType, _attNum))
            end
            UIUtils.SetTextByString(self.AttLabel1, _str)
        end
        if #_arr >= 2 then
            _single = Utils.SplitStr(_arr[2], "_")
            if _single and #_single == 3 then
                local _effectType = tonumber(_single[1])
                local _attType = tonumber(_single[2])
                local _attNum = tonumber(_single[3])
                if _effectType == 1 then
                    _str = string.format( "%s +%s", L_BattlePropTools.GetBattlePropName(_attType), L_BattlePropTools.GetBattleValueText(_attType, _attNum))
                end
                UIUtils.SetTextByString(self.AttLabel2, _str)
            end
        end
        self.LockGo:SetActive(false)
    else
        self.Icon:UpdateIcon(0)
        self.AttLabel1.gameObject:SetActive(false)
        self.AttLabel2.gameObject:SetActive(false)
        if self.Data.ID == 0 then
            UIUtils.SetTextByEnum(self.NameLabel, "C_WEIXIANGQIAN")
            UIUtils.SetColorByString(self.NameLabel, "#D6E8F4")
            self.LockGo:SetActive(false)
        else
            local _condition = GameCenter.LianQiGemSystem:GetHoleOpenCondition(self.Data.Type, self.Data.Pos, self.Data.Index)
            local _conditionList = Utils.SplitNumber(_condition, "_")
            if _conditionList[1] == 1 and #_conditionList == 2 then
                -- Level 1
                UIUtils.SetTextByEnum(self.NameLabel, "C_JIESUOLEVEL", CommonUtils.GetLevelDesc(_conditionList[2]))
            elseif _conditionList[1] == 17 and #_conditionList == 3 then
                -- 17 Equipment Level
                UIUtils.SetTextByEnum(self.NameLabel, "C_JIESUOCHUANDAI", _conditionList[3])
            elseif _conditionList[1] == 118 and #_conditionList == 3 then
                -- 118 Equipment Quality
                local _qua = LuaItemBase.GetQualityStr(_conditionList[3])
                UIUtils.SetTextByEnum(self.NameLabel, "C_JIESUOCHUANDAICOUNT", _qua)
            elseif _conditionList[1] == 210 and #_conditionList == 2 then
                -- 210 VIP level
                UIUtils.SetTextByEnum(self.NameLabel, "C_JIESUOGEM_VIP", _conditionList[2])
            end
            self.LockGo:SetActive(true)
            UIUtils.SetColorByString(self.NameLabel, "#9d9d9d")
        end
    end
end
-- Set a name
function UIGemInlayComponent:SetName(name)
    self.GO.name = name;
end

function UIGemInlayComponent:OnSetColor(r, g, b)
    UIUtils.SetColor(self.NameLabel, r, g, b, 1)
end

return UIGemInlayComponent
