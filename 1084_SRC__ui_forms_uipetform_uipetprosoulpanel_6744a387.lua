--==============================--
--author:
--Date: 2019-06-25
--File: UIPetProSoulPanel.lua
--Module: UIPetProSoulPanel
--Description: Pet Attribute Soul-Reigning Interface
--==============================--
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools

local UIPetProSoulPanel = {
    --transform
    Trans = nil,
    Go = nil,
    --Parent node
    Parent = nil,
    --Affiliated form
    RootForm = nil,

    --Sliding list
    ScrollView = nil,
    --grid
    Grid = nil,
    --resource
    ResGo = nil,
    --Resource list
    ResList = nil,
    IsVisible = false,
}

local L_SoulItem = nil
function UIPetProSoulPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm

    self.DrugGrid = UIUtils.FindGrid(self.Trans,"Panel/Grid")
    self.DrugScrollView = UIUtils.FindScrollView(self.Trans,"Panel")
    local _gridTrans = UIUtils.FindTrans(self.Trans, "Panel/Grid")
    self.DrugItemList = List:New()
    for i = 0, _gridTrans.childCount - 1 do
        self.DrugClone = L_SoulItem:New(_gridTrans:GetChild(i))
        self.DrugItemList:Add(self.DrugClone)
    end
    self.Go:SetActive(false)
    self.IsVisible = false
    return self
end

function UIPetProSoulPanel:Show()
    --Play the start-up picture
    self.Go:SetActive(true)
    self:RefreshPanel(self.IsVisible == false, nil)
    self.IsVisible = true
end

function UIPetProSoulPanel:Hide()
    --Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
end

--Refresh the page
function UIPetProSoulPanel:RefreshPanel(playAnim, sender)
    local _animPlayer = self.Parent.AnimPlayer
    local _animList = nil
    playAnim = playAnim == true
    if playAnim then
        _animPlayer:Stop()
        _animList = List:New()
    end
    local _druglist = GameCenter.NatureSystem.NaturePetData.super.DrugList
    for i = 1, #_druglist do
        local _item = nil
        if #self.DrugItemList >= i then
            _item = self.DrugItemList[i]
        else
            _item = self.DrugClone:Clone()
            self.DrugItemList:Add(_item)
        end
        if _item then
            _item:SetInfo(_druglist[i])

            if playAnim then
                _animList:Add(_item.Trans)
            end
        end
    end
    if #_druglist > 0 and not self.IsInit then
        self.DrugGrid:Reposition()
        self.DrugScrollView.repositionWaitFrameCount = 1

        if playAnim then
            for i = 1, #_animList do
                local _trans = _animList[i]
                self.Parent.CSForm:RemoveTransAnimation(_trans)
                self.Parent.CSForm:AddAlphaPosAnimation(_trans, 0, 1, -50, 0, 0.2, false, false)
                _animPlayer:AddTrans(_trans, (i - 1) * 0.1)
            end
            _animPlayer:Play()
        end
    end
end

--Soul item
L_SoulItem = {
    Trans = nil,
    GO = nil,
    Item = nil,
    Btn = nil,
    Icon = nil,
    Num = nil,
    Name = nil,
    Level = nil,
    ProNames = nil,
    ProValues = nil,
    Progress = nil,
    Exp = nil,
    SoulInfo = nil,
    RedPoint = nil,
}

function L_SoulItem:New(trans)
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
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Item.SingleClick = Utils.Handler(_m.ItemClick, _m)
    return _m
end

function L_SoulItem:Clone()
    return self:New(UnityUtils.Clone(self.GO).transform)
end

function L_SoulItem:SetInfo(info, vfxitem)
    self.Info = info
    if not info then
        return
    end
    local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(info.ItemId)
    self.Item:InItWithCfgid(info.ItemId, 1,true, true)
    self.Item:BindBagNum("%s")

    self.UpSprGo:SetActive(_haveNum > 0 and info.Level < GameCenter.NatureSystem:GetDrugItemMax(NatureEnum.Pet, info.ItemId))
    self.Item.IsShowTips = _haveNum == 0
    UIUtils.SetTextByString(self.NameLabel, self.Item.ShowItemData.Name)
    UIUtils.SetTextByEnum(self.StageLabel, "NATURESTAGE", info.Level)
    UIUtils.SetTextByEnum(self.ArrtiLabel, "NATUREATTRADD",
    L_BattlePropTools.GetBattlePropName(info.PeiyangAtt[1]),
    L_BattlePropTools.GetBattleValueText(info.PeiyangAtt[1], info.PeiyangAtt[2]) )
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
            UIUtils.SetTextByString(self.PropLabel, L_BattlePropTools.GetBattlePropName(info.AttrList[j].AttrID))
            UIUtils.SetTextByString(self.PropValueLabel, L_BattlePropTools.GetBattleValueText(info.AttrList[j].AttrID,info.AttrList[j].Attr))
        elseif j == 2 then
             UIUtils.SetTextByString(self.PropLabel1, L_BattlePropTools.GetBattlePropName(info.AttrList[j].AttrID))
            UIUtils.SetTextByString(self.PropValueLabel1, L_BattlePropTools.GetBattleValueText(info.AttrList[j].AttrID,info.AttrList[j].Attr))
        end
    end
end

function L_SoulItem:ItemClick(Item)
    if not self.Item.IsShowTips then
        self:OnBtnClick()
    end
end

function L_SoulItem:OnBtnClick()
    local _itemId = 0
    if self.Info then
        _itemId = self.Info.ItemId
        if self.Info.EatNum >= self.Info.LeveLimit then
            Utils.ShowPromptByEnum("ReachMaxLevel")
        else
            local _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
            if _haveNum > 0 then
                GameCenter.NatureSystem:ReqNatureDrug(NatureEnum.Pet, _itemId)
            else
                local _itemDb = DataConfig.DataItem[_itemId]
                Utils.ShowPromptByEnum("Item_Not_Enough", _itemDb.Name)
                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_itemId)
            end
        end
    end
end


return UIPetProSoulPanel
