------------------------------------------------
-- author:
-- Date: 2020-05-08
-- File: AllAttrPanel.lua
-- Module: AllAttrPanel
-- Description: Spirit body unblocks total attribute bonus tips
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local AllAttrPanel ={
    Go = nil,
    Trans = nil,
    CSForm = nil,
    -- Animation module
    AnimModule = nil,
}

-- Create a new object
function AllAttrPanel:OnFirstShow(trans, csform)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = csform
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddNormalAnimation(0.3)
    _m:FindAllComponents()
    _m.Go:SetActive(false)
    _m.IsVisible = false
    return _m
 end

 -- Find various controls on the UI
function AllAttrPanel:FindAllComponents()
    self.CloseBtn = UIUtils.FindBtn(self.Trans, "closeButton")
    UIUtils.AddBtnEvent(self.CloseBtn, self.Close, self)
    self.CloseBtn = UIUtils.FindBtn(self.Trans, "Back")
    UIUtils.AddBtnEvent(self.CloseBtn, self.Close, self)
    self.NoAttrTipsGo = UIUtils.FindGo(self.Trans, "NoAttrTips")
    self.AttrNameLabelList = List:New()
    self.AttrValueLabelList = List:New()
    local _attrTrans = UIUtils.FindTrans(self.Trans, "GetLevelInfo")
    if _attrTrans then
        for i = 0, _attrTrans.childCount - 1 do
            local _trans = _attrTrans:GetChild(i)
            if _trans then
                self.AttrValueLabelList:Add(UIUtils.FindLabel(_trans))
                self.AttrNameLabelList:Add(UIUtils.FindLabel(_trans, "Txt"))
            end
        end
    end
end

 -- Open the interface
function AllAttrPanel:Open(lv, functionID)
    self.AnimModule:PlayEnableAnimation()
    local _dic = nil
    local listData = GameCenter.LingTiSystem:GetLocalData()
    local data = listData[lv]
    if data and functionID == FunctionStartIdCode.LingTiMain then
        _dic = data:GetAllAtt()
    elseif functionID == FunctionStartIdCode.LingtiFanTai then
        _dic = GameCenter.LingTiSystem.UnlockAttrDic
    else
        local _cfg = DataConfig.DataEquipCollectionStar[GameCenter.LingTiSystem.CurActiveStarNum]
        if _cfg then
            _dic = Dictionary:New()
            local _arr = Utils.SplitStr(_cfg.Attribute, ';')
            for i = 1, #_arr do
                local _single = Utils.SplitNumber(_arr[i], '_')
                if #_single >= 2 and _single[2] > 0 then
                    _dic:Add(_single[1], _single[2])
                end
            end
        end
    end
    local _index = 1
    if _dic then
        _dic:Foreach(function(k, v)
            if _index <= #self.AttrNameLabelList then
                UIUtils.SetTextByPropName(self.AttrNameLabelList[_index],  k)
                UIUtils.SetTextFormat(self.AttrValueLabelList[_index], "+{0}", L_BattlePropTools.GetBattleValueText(k, v))
                _index = _index + 1
            end
        end)
    end
    self.NoAttrTipsGo:SetActive(_index <= 1)
    for i = _index, #self.AttrNameLabelList do
        UIUtils.ClearText(self.AttrNameLabelList[i])
        UIUtils.ClearText(self.AttrValueLabelList[i])
    end
    self.IsVisible = true
end

 -- Close the interface
function AllAttrPanel:Close()
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end



return AllAttrPanel
