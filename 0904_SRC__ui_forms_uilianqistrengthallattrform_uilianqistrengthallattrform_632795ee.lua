-- author:
-- Date: 2019-05-20
-- File: UILianQiStrengthAllAttrForm.lua
-- Module: UILianQiStrengthAllAttrForm
-- Description: A subpanel in UIPlayerBaseForm to display all gem properties
------------------------------------------------

local UILianQiStrengthAllAttrForm = {
    AnimModule = nil,-- Animation module
    GetLevelInfoTrs = nil,-- Currently obtained property Transform
    CurLevelLab = nil,-- Current gem total level label
    NextLevelInfoTrs = nil,-- The attributes obtained by the lower level Transform
    CloseBtn = nil,
    CloseBtn2 = nil,
}

-- Register event functions and provide them to the CS side to call.
function UILianQiStrengthAllAttrForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UILianQiStrengthAllAttrForm_OPEN,self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UILianQiStrengthAllAttrForm_CLOSE,self.OnClose)
end

function UILianQiStrengthAllAttrForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

function UILianQiStrengthAllAttrForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

-- Load function, provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnLoad()
    
end

-- The first display function is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnFirstShow()
	self:FindAllComponents();
	self:RegUICallback();
    self.CSForm:AddNormalAnimation(0.3)
end

-- Displays the previous operation and provides it to the CS side to call.
function UILianQiStrengthAllAttrForm:OnShowBefore()
    
end

-- The displayed operation is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnShowAfter()
    self:SetAllInfo()
end

-- Hide previous operations and provide them to the CS side to call.
function UILianQiStrengthAllAttrForm:OnHideBefore()
    
end

-- The hidden operation is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnHideAfter()
    
end

-- The operation of the uninstall event is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnUnRegisterEvents()
    
end

-- UnLoad operation is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnUnload()
    
end

-- The operation of form uninstallation is provided to the CS side to call.
function UILianQiStrengthAllAttrForm:OnFormDestroy()
    
end

-- Find all components
function UILianQiStrengthAllAttrForm:FindAllComponents()
    local _myTrans = self.Trans
    self.CloseBtn = UIUtils.FindBtn(_myTrans, "closeButton")
    self.CloseBtn2 = UIUtils.FindBtn(_myTrans, "Close2")
    self.GetLevelInfoTrs = UIUtils.FindTrans(_myTrans, "GetLevelInfo")
    self.CurLevelLab = UIUtils.FindLabel(_myTrans, "CurLevel")
    self.NextLevelInfoTrs = UIUtils.FindTrans(_myTrans, "NextLevelInfo")
    -- Create an animation module
    self.AnimModule = UIAnimationModule(_myTrans)
    -- Add an animation
    self.AnimModule:AddAlphaAnimation()
    
    --self:SetAllInfo()
end

-- Callback function that binds UI components
function UILianQiStrengthAllAttrForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.Close, self)
    UIUtils.AddBtnEvent(self.CloseBtn2, self.Close, self)
end

function UILianQiStrengthAllAttrForm:Close()
    self:OnClose()
end

function UILianQiStrengthAllAttrForm:SetAllInfo()
    -- The table starts from 1, you can use # to get the length
    local _strengthTotalLv = GameCenter.LianQiForgeSystem:GetTotalStrengthLv()
    local _curCfg, _nextCfg = self:GetCurAndNextCfg(_strengthTotalLv)
    if _curCfg then
        self:SetAttrInfo(self.GetLevelInfoTrs, _curCfg)
    else
        self:SetAttrInfo(self.GetLevelInfoTrs, _nextCfg, true)
    end

    UIUtils.SetTextByNumber(self.CurLevelLab, _strengthTotalLv)
    self:SetAttrInfo(self.NextLevelInfoTrs, _nextCfg)
end

function UILianQiStrengthAllAttrForm:SetAttrInfo(trans, cfg, isShowZero)
    if cfg == nil then
        trans.gameObject:SetActive(false)
        do return end
    else
        trans.gameObject:SetActive(true)
    end
    local _leveLab = UIUtils.FindLabel(trans, "TotalLevel")
    UIUtils.SetTextByNumber(_leveLab, isShowZero and 0 or cfg.Level)
    local _attrs = Utils.SplitStrByTableS(cfg.Value, {";", "_"})
    if _attrs[1] then
        local _attrNameLab = UIUtils.FindLabel(trans, "Attr1/Txt")
        local _attrValueLab = UIUtils.FindLabel(trans, "Attr1")
        local _attrCfg = DataConfig.DataAttributeAdd[_attrs[1][1]]
        if _attrCfg then
            UIUtils.SetTextByStringDefinesID(_attrNameLab, _attrCfg._Name)
            self:SetAttrValueLabel(_attrValueLab, _attrs[1][2], isShowZero, _attrCfg.ShowPercent)
        end
    end
    if _attrs[2] then
        local _attrNameLab = UIUtils.FindLabel(trans, "Attr2/Txt")
        local _attrValueLab = UIUtils.FindLabel(trans, "Attr2")
        local _attrCfg = DataConfig.DataAttributeAdd[_attrs[2][1]]
        if _attrCfg then
            UIUtils.SetTextByStringDefinesID(_attrNameLab, _attrCfg._Name)
            self:SetAttrValueLabel(_attrValueLab, _attrs[2][2], isShowZero, _attrCfg.ShowPercent)
        end
    end
    if _attrs[3] then
        local _attrNameLab = UIUtils.FindLabel(trans, "Attr3/Txt")
        local _attrValueLab = UIUtils.FindLabel(trans, "Attr3")
        local _attrCfg = DataConfig.DataAttributeAdd[_attrs[3][1]]
        if _attrCfg then
            UIUtils.SetTextByStringDefinesID(_attrNameLab, _attrCfg._Name)
            self:SetAttrValueLabel(_attrValueLab, _attrs[3][2], isShowZero, _attrCfg.ShowPercent)
        end
    end
    if _attrs[4] then
        local _attrNameLab = UIUtils.FindLabel(trans, "Attr4/Txt")
        local _attrValueLab = UIUtils.FindLabel(trans, "Attr4")
        local _attrCfg = DataConfig.DataAttributeAdd[_attrs[4][1]]
        if _attrCfg then
            UIUtils.SetTextByStringDefinesID(_attrNameLab, _attrCfg._Name)
            self:SetAttrValueLabel(_attrValueLab, _attrs[4][2], isShowZero, _attrCfg.ShowPercent)
        end
    end
end

function UILianQiStrengthAllAttrForm:SetAttrValueLabel(label, value, isShowZero, isShowPercent)
    if isShowZero then
        UIUtils.SetTextByNumber(label, 0)
    else
        if isShowPercent == 0 then
            UIUtils.SetTextByNumber(label, value)
        else
            UIUtils.SetTextByEnum(label, "Percent", value/100)
        end
    end
end

function UILianQiStrengthAllAttrForm:GetCurAndNextCfg(totalLv)
    local _cfgLength = DataConfig.DataEquipIntenClass.Count
    -- Default data
    local _curLvCfg = nil
    local _nextLvCfg = DataConfig.DataEquipIntenClass:GetByIndex(1)
    if totalLv >= _nextLvCfg.Level then
        local _index = 1
        local function  _forFunc(key, value)
            -- Compare with the first n-1 data (because you need to compare with the levels of "current entry" and "next entry")
            if _index < _cfgLength then
                local _cfg1 = DataConfig.DataEquipIntenClass[key]
                local _cfg2 = DataConfig.DataEquipIntenClass:GetByIndex(_index + 1)
                if totalLv >= _cfg1.Level and totalLv < _cfg2.Level then
                    _curLvCfg = _cfg1
                    _nextLvCfg = _cfg2
                    return true
                end
            else
                -- If the last data has not yet been broken
                _curLvCfg = DataConfig.DataEquipIntenClass:GetByIndex(_index)
                _nextLvCfg = nil
            end
            _index = _index + 1
        end
        DataConfig.DataEquipIntenClass:ForeachCanBreak(_forFunc)
    end
    return _curLvCfg, _nextLvCfg
end

return UILianQiStrengthAllAttrForm;
