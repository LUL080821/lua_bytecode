------------------------------------------------
--author:
--Date: 2019-11-22
--File: UIShopMallTypeItem.lua
--Module: UIShopMallTypeItem
--Description: Mall interface product type pagination
------------------------------------------------
local L_Itembase = CS.Thousandto.Code.Logic.ItemBase
local UIShopMallTypeItem = {
    Trans = nil,
    Go = nil,
    --name
    NameLabel = nil,
    --Btn
    Btn = nil,
    CallBack = nil,
    Type = 1,
}

function UIShopMallTypeItem:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.NameLabel = UIUtils.FindLabel(trans, "Name")
    _m.SelectGo = UIUtils.FindGo(trans, "Select")
    if UIUtils.FindTrans(trans, "New") then
        _m.NewGo = UIUtils.FindGo(trans, "New")
    end
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnOwnClick, _m)
    return _m
end

function UIShopMallTypeItem:Clone()
    return self:New(UnityUtils.Clone(self.Go).transform)
end

function UIShopMallTypeItem:OnOwnClick()
    if self.CallBack ~= nil then
        self.CallBack(self, true)
    end
end

--Select
function UIShopMallTypeItem:Select(isSelect)
    self.SelectGo:SetActive(isSelect)
    if isSelect then
        UIUtils.SetColorByString(self.NameLabel, "#fffef5")
    else
        UIUtils.SetColorByString(self.NameLabel, "#fffef5")
    end
end

--Load product specific data
function UIShopMallTypeItem:UpdateItem(id)
    self.Type = id
    local _cfg = DataConfig.DataShopMenu[id]
    if _cfg then
        UIUtils.SetTextByStringDefinesID(self.NameLabel, _cfg._Name)
    end
end

function UIShopMallTypeItem:SetIsShow(isShow)
    if self.NewGo then
        self.NewGo:SetActive(isShow)
    end
end
return UIShopMallTypeItem