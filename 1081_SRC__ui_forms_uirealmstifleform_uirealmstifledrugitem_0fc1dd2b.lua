------------------------------------------------
--author:
--Date: 2020-10-27
--File: UIRealmstifleDrugItem.lua
--Module: UIRealmstifleDrugItem
--Description: Magic weapon soul-controlling sliding component
------------------------------------------------
local BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
--Function item
local UIRealmstifleDrugItem = {
    --tansform
    Trans = nil,
    --gameobject
    GO = nil,
};

--create
function UIRealmstifleDrugItem:New(trans)
    local _m = Utils.DeepCopy(self);
    _m.Trans = trans;
    _m.GO = trans.gameObject;

    _m.NameLabel =  UIUtils.FindLabel(trans, "Name")
    _m.StageLabel =  UIUtils.FindLabel(trans, "Stage")
    _m.ArrtiLabel =  UIUtils.FindLabel(trans, "Arrti")
    _m.Bless =  UIUtils.FindSlider(trans, "Bless")
    _m.UpSprGo =  UIUtils.FindGo(trans, "UpSprite")
    _m.BlessLabel =  UIUtils.FindLabel(trans, "Bless/Label")
    _m.Btn = UIUtils.FindBtn(trans, "Box")
    _m.Item = UILuaItem:New(UIUtils.FindTrans(trans, "default"))
    _m.PropLabel = UIUtils.FindLabel(trans, "Prop")
    _m.PropLabel1 = UIUtils.FindLabel(trans, "Prop1")
    _m.PropValueLabel = UIUtils.FindLabel(trans, "Prop/Value")
    _m.PropValueLabel1 =UIUtils.FindLabel(trans, "Prop1/Value")
    _m.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "UIVfxSkinCompoent"))
    _m.Item.SingleClick = Utils.Handler(_m.ItemClick, _m)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClickDrugBtn, _m)
    return _m;
end

function UIRealmstifleDrugItem:Clone()
    return self:New(UnityUtils.Clone(self.GO).transform)
end

--Set data
function UIRealmstifleDrugItem:SetInfo(info, vfxitem, type)
    self.Info = info
    if not info then
        return
    end
    self.NatureType = type
    local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(info.ItemId)
    self.Item:InItWithCfgid(info.ItemId, 1,true, true)
    self.Item:BindBagNum("%s")

    self.UpSprGo:SetActive(_haveNum > 0 and info.Level < GameCenter.NatureSystem:GetDrugItemMax(self.NatureType, info.ItemId))
    self.Item.IsShowTips = _haveNum == 0
    UIUtils.SetTextByString(self.NameLabel, self.Item.ShowItemData.Name)
    UIUtils.SetTextByEnum(self.StageLabel, "NATURESTAGE", info.Level)
    UIUtils.SetTextByEnum(self.ArrtiLabel, "NATUREATTRADD",
    BattlePropTools.GetBattlePropName(info.PeiyangAtt[1]),
    BattlePropTools.GetBattleValueText(info.PeiyangAtt[1], info.PeiyangAtt[2]) )
    self.Bless.value = info.LeveLimit == 0 and 0 or info.EatNum / info.LeveLimit
    if info.EatNum == info.LeveLimit then
        UIUtils.SetTextByEnum(self.BlessLabel, "ReachMaxLevel")
    else
        UIUtils.SetTextFormat(self.BlessLabel, "{0}/{1}", info.EatNum, info.LeveLimit)
    end
    if vfxitem == info.ItemId then
        self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 19, LayerUtils.GetAresUILayer())
    end

    for j=1,#info.AttrList do
        if j == 1 then
            UIUtils.SetTextByString(self.PropLabel, BattlePropTools.GetBattlePropName(info.AttrList[j].AttrID))
            UIUtils.SetTextByString(self.PropValueLabel, BattlePropTools.GetBattleValueText(info.AttrList[j].AttrID,info.AttrList[j].Attr))
        elseif j == 2 then
             UIUtils.SetTextByString(self.PropLabel1, BattlePropTools.GetBattlePropName(info.AttrList[j].AttrID))
            UIUtils.SetTextByString(self.PropValueLabel1, BattlePropTools.GetBattleValueText(info.AttrList[j].AttrID,info.AttrList[j].Attr))
        end
    end
end

function UIRealmstifleDrugItem:ItemClick(item)
    if not self.Item.IsShowTips then
        self:OnClickDrugBtn()
    end
end

--Click
function UIRealmstifleDrugItem:OnClickDrugBtn()
    local _itemId = 0
    if self.Info then
        _itemId = self.Info.ItemId
    end
    if _itemId > 0 then
        if self.Info.EatNum >= self.Info.LeveLimit then
            Utils.ShowPromptByEnum("ReachMaxLevel")
        else
            local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
            if _haveNum > 0 then
                GameCenter.NatureSystem:ReqNatureDrug(self.NatureType, _itemId)
            else
                local _itemDb = DataConfig.DataItem[_itemId]
                Utils.ShowPromptByEnum("Item_Not_Enough", _itemDb.Name)
                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_itemId)
            end
        end
    end
end

return UIRealmstifleDrugItem
