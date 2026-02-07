------------------------------------------------
--author:
--Date: 2025-12-02
--File: PopupAttAdvanced.lua
--Module: UIPlayerPropetryForm
------------------------------------------------
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local PopupAttAdvanced = {
    Trans       = nil,
    Go          = nil,
    CSForm      = nil,

    AttItemGo   = nil,
    AttItemList = List:New(),
    IsVisible   = false,
}

function PopupAttAdvanced:OnFirstShow(parent, trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    _m:RegUICallback()
    _m.AnimPlayer = L_UIAnimDelayPlayer:New(_m.CSForm.AnimModule)
    return _m
end

function PopupAttAdvanced:OnOpen()
    self.Go:SetActive(true)
    self.IsVisible = true
end

function PopupAttAdvanced:OnClose()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function PopupAttAdvanced:Update(dt)
    if not self.IsVisible then
        return
    end
    self.AnimPlayer:Update(dt)
end

function PopupAttAdvanced:FindAllComponents()
    local _trans = self.Trans;
    self.BlankClose = UIUtils.FindBtn(_trans, "BgBlank")
    self.BtnClose = UIUtils.FindBtn(_trans, "CloseBtn")
    self.TitleLabel = UIUtils.FindLabel(_trans, "TitleLabel");

    self.ScrollViewTrans = UIUtils.FindTrans(_trans, "ScrollViewTotal");
    self.GridTrans = UIUtils.FindTrans(_trans, "ScrollViewTotal/Grid");

    self.AttItemList:Clear()
    self.AttItemGo = self.GridTrans:GetChild(0).gameObject
    for i = 0, self.GridTrans.childCount - 1 do
        local _item = self:CreateAttrItem(self.GridTrans:GetChild(i).gameObject, self.GridTrans, true)
        self.AttItemList:Add(_item);
    end
end

function PopupAttAdvanced:RegUICallback()
    UIUtils.AddBtnEvent(self.BlankClose, self.OnClose, self)
    UIUtils.AddBtnEvent(self.BtnClose, self.OnClose, self)
end

function PopupAttAdvanced:OnUpdateData(dataList, isResetScroll)
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    local _propMoudle = _lp.PropMoudle;
    local itemCount = #dataList
    local poolCount = #self.AttItemList

    local _scrollViewGO = self.ScrollViewTrans.gameObject
    _scrollViewGO:SetActive(true)
    if itemCount == 0 then
        -- show notify empty
        _scrollViewGO:SetActive(false)
        return
    end

    local index = 1
    for i = 1, itemCount do
        local item = nil
        if index <= poolCount then
            item = self.AttItemList[index]
        else
            item = self:CreateAttrItem(self.AttItemGo, self.GridTrans, false);
            self.AttItemList:Add(item)
            poolCount = poolCount + 1
        end
        item.GO:SetActive(true);
        self:SetAttrText(dataList[i], item.TxtKeyL, item.TxtValueL, _propMoudle)

        index = index + 1
    end
    for i = index, poolCount do
        local leftoverItem = self.AttItemList[i]
        leftoverItem.GO:SetActive(false)
    end
    UnityUtils.GridResetPosition(self.GridTrans)
    if isResetScroll then
        UnityUtils.ScrollResetPosition(self.ScrollViewTrans)
    end
end

function PopupAttAdvanced:CreateAttrItem(originalGo, parent, isClone)
    local useOriginal = isClone
    local _go = useOriginal and originalGo or UnityUtils.Clone(originalGo, parent)
    local _trans = _go.transform;
    return {
        GO        = _go,
        Trans     = _trans,
        TxtKeyL   = UIUtils.FindLabel(_trans, "TxtKeyL"),
        TxtValueL = UIUtils.FindLabel(_trans, "TxtValueL"),
    }
end

function PopupAttAdvanced:SetAttrText(data, TxtKey, TxtValue, propMoudle)
    local format = DataConfig.DataMessageString.GetStringDefineId("PlayerPropetry_MaoHao"); -- {0}：
    UIUtils.SetTextFormatById(TxtKey, format, data._Name)
    if data.Id == 2 then
        UIUtils.SetTextByNumber(TxtValue, propMoudle.MaxHP);
    else
        local _v = propMoudle:GetBattleProp(data.Id);
        if data.ShowPercent == 1 then
            UIUtils.SetTextByPercent(TxtValue, _v / 100)
        else
            UIUtils.SetTextByNumber(TxtValue, _v);
        end
    end
end

return PopupAttAdvanced