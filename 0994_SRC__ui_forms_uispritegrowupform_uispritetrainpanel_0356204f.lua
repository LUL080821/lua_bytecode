------------------------------------------------
--author:
--Date: 2020-07-06
--File: UISpriteTrainPanel.lua
--Module: UISpriteTrainPanel
--Description: Sword Spirit Cultivation Interface
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIListMenu = require ("UI.Components.UIListMenu.UIListMenu")
local UISpriteTrainPanel = {
    Trans = nil,
    Go = nil,
    IsVisible = false,
}
local L_AttrItem = {
    Trans = nil,
    Go = nil,
}

--Create a new object
function UISpriteTrainPanel:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

--Find controls
function UISpriteTrainPanel:FindAllComponents()
    self.AttGrid = UIUtils.FindGrid(self.Trans, "AttGrid")
    self.AttGridTrans = UIUtils.FindTrans(self.Trans, "AttGrid")
    self.AttList = List:New()
    for i = 0, self.AttGridTrans.childCount - 1 do
        self.AttrItem = L_AttrItem:OnFirstShow(self.AttGridTrans:GetChild(i))
        self.AttList:Add(self.AttrItem)
    end
	self.UIListMenu = UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(self.Trans, "UIListMenu"))
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnMenuSelect,self))
    --Total attribute bonus
    self.TotalAttGo = UIUtils.FindGo(self.Trans, "TotalAttr")
    self.TotalAttLabel = UIUtils.FindLabel(self.Trans, "TotalAttr/ValueLabel")
    self.TotalAttNextGo = UIUtils.FindGo(self.Trans, "TotalAttr/Sprite")
    self.TotalAttNextLabel = UIUtils.FindLabel(self.Trans, "TotalAttr/Sprite/AddValueLabel")
    self.CostTitleLabel = UIUtils.FindLabel(self.Trans, "CostTitleLabel")
    self.CostItemGrid = UIUtils.FindGrid(self.Trans, "CostItemGrid")
    self.CostItemGridTrans = UIUtils.FindTrans(self.Trans, "CostItemGrid")
    self.CostItemList = List:New()
    for i = 0, self.CostItemGridTrans.childCount - 1 do
        self.CostItem = UILuaItem:New(self.CostItemGridTrans:GetChild(i))
        self.CostItem.IsShowTips = true
        self.CostItemList:Add(self.CostItem)
    end
    self.LvDescLabel = UIUtils.FindLabel(self.Trans, "LvDescLabel")
    self.LvDescLabelGo = UIUtils.FindGo(self.Trans, "LvDescLabel")
    self.BtnLabel = UIUtils.FindLabel(self.Trans, "Button/Label")
    self.LvMaxGo = UIUtils.FindGo(self.Trans, "LvMax")
    self.BtnRedGo = UIUtils.FindGo(self.Trans, "Button/Red")
    self.Btn = UIUtils.FindBtn(self.Trans, "Button")
    UIUtils.AddBtnEvent(self.Btn, self.OnClickBtn, self)
end

function UISpriteTrainPanel:OnOpen(type, panel, model)
    self.Go:SetActive(true)
    self.IsVisible = true
    self.Type = type
    self.CurSelctModelID = model
    if panel then
        self.CurSelectFunc = panel
    else
        self.CurSelectFunc = FunctionStartIdCode.FlySwordSpriteUpLv
    end
    self.UIListMenu:RemoveAll()
	self.UIListMenu:AddIcon(FunctionStartIdCode.FlySwordSpriteUpLv, DataConfig.DataMessageString.Get("C_UI_SPRITEHOME_UP"))
    self.UIListMenu:AddIcon(FunctionStartIdCode.FlySwordSpriteUpGrade, DataConfig.DataMessageString.Get("C_UI_SPRITEHOME_LVUP"))
    self.UIListMenu:SetSelectById(self.CurSelectFunc)
    -- self:UpdateData()
end

function UISpriteTrainPanel:OnClose()
    self.Go:SetActive(false)
    self.IsVisible = false
end

function UISpriteTrainPanel:OnMenuSelect(id, select)
	if select then
		self.CurSelectFunc = id
        self:UpdateData()
    end
end

function UISpriteTrainPanel:OnClickBtn()
    local _flg = true
    for i = 1, #self.CostItemList do
        if self.CostItemList[i].RootGO.activeSelf and not self.CostItemList[i].IsEnough then
            GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.CostItemList[i].ShowItemData.CfgID)
		    Utils.ShowPromptByEnum("C_UI_SPRITEHOME_ITEMLESS")
            _flg = false
            break
        end
    end
    if _flg then
        if self.CurSelectFunc == FunctionStartIdCode.FlySwordSpriteUpLv then
            if self.IsMaxLv then
		        Utils.ShowPromptByEnum("C_UI_SPRITEHOME_MSG2")
            else
                GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
                    type = 2,
                    huaxinID = self.CurSelctModelID
                })
            end
        else
            if self.IsMaxLv then
		        Utils.ShowPromptByEnum("C_UI_SPRITEHOME_MSG3")
            else

                if not self.LvIsEnough then
		            Utils.ShowPromptByEnum("C_UI_SPRITEHOME_MSG4")
                else
                    GameCenter.Network.Send("MSG_HuaxinFlySword.ReqUseHuxin",{
                        type = 4,
                        huaxinID = self.CurSelctModelID
                    })
                end
            end
        end
    end
end

function UISpriteTrainPanel:UpdateData(type)
    if type then
        self.Type = type
    end
    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(self.Type) then
        local _typeData = _typeDic[self.Type]
        local attArr = nil
        local curCfg = nil
        local nextCfg = nil
        if not _typeData then
            return
        end
        if self.CurSelectFunc == FunctionStartIdCode.FlySwordSpriteUpLv then
            curCfg = DataConfig.DataHuaxingFlySwordLevelup[_typeData.Level]
            nextCfg = DataConfig.DataHuaxingFlySwordLevelup[_typeData.Level + 1]
            if curCfg then
                attArr = Utils.SplitStr(curCfg.Attribute, ';')
                self:SetCostItem(curCfg.UpItem)
            end
            --Consumption
            UIUtils.SetTextByEnum(self.CostTitleLabel, "C_UI_SPRITEHOME_TITLENAME1")
            self.LvDescLabelGo:SetActive(false)
            UIUtils.SetTextByEnum(self.BtnLabel, "C_UI_SPRITEHOME_UP")
        else
            curCfg = DataConfig.DataHuaxingFlySwordAdvanced[_typeData.Grade]
            nextCfg = DataConfig.DataHuaxingFlySwordAdvanced[_typeData.Grade + 1]
            if curCfg then
                attArr = Utils.SplitStr(curCfg.RentAtt, ';')
                --Total attribute bonus
                UIUtils.SetTextFormat(self.TotalAttLabel, "{0}%", curCfg.AttAllAdd / 100)
                if nextCfg then
                    self.TotalAttNextGo:SetActive(true)
                    UIUtils.SetTextFormat(self.TotalAttNextLabel, "{0}%", nextCfg.AttAllAdd / 100)
                else
                    self.TotalAttNextGo:SetActive(false)
                end
                --Consumption
                self:SetCostItem(curCfg.ActiveItem)
                if _typeData.Level >= curCfg.Levelmax or nextCfg == nil then
                    self.LvDescLabelGo:SetActive(false)
                    self.LvIsEnough = true
                else
                    self.LvDescLabelGo:SetActive(true)
                    UIUtils.SetTextByEnum(self.LvDescLabel, "C_UI_SPRITEHOME_MSG5", curCfg.Levelmax)
                    self.LvIsEnough = false
                end
            end
            UIUtils.SetTextByEnum(self.BtnLabel, "C_UI_SPRITEHOME_LVUP")
            UIUtils.SetTextByEnum(self.CostTitleLabel, "C_UI_SPRITEHOME_TITLENAME2")
        end
        self.IsMaxLv = nextCfg == nil
        self.LvMaxGo:SetActive(self.IsMaxLv)
        self:SetAttr(attArr, nextCfg == nil)
        self:SetBtnRed()
        self.TotalAttGo:SetActive(self.CurSelectFunc == FunctionStartIdCode.FlySwordSpriteUpGrade)
	end
end

function UISpriteTrainPanel:SetBtnRed()
    if self.IsMaxLv then
        self.BtnRedGo:SetActive(false)
    end
    if not self.IsVisible then
        return
    end
    self.BtnRedGo:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(self.CurSelectFunc, self.Type))
    self.UIListMenu:SetRedPoint(FunctionStartIdCode.FlySwordSpriteUpLv, GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpLv, self.Type))
    self.UIListMenu:SetRedPoint(FunctionStartIdCode.FlySwordSpriteUpGrade, GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpGrade, self.Type))
end

function UISpriteTrainPanel:SetAttr(attArr, ifMax)
    local _index = 1
    if attArr ~= nil then
        for i = 1, #attArr do
            local _item = nil
            if #self.AttList < _index then
                _item = self.AttrItem:Clone()
                self.AttList:Add(_item)
            else
                _item = self.AttList[_index]
            end
            if _item then
                local _single = Utils.SplitNumber(attArr[i], '_')
                if _single and #_single >= 3 then
                    if not ifMax then
                        _item:UpdateData(_single[1],  _single[2], _single[3])
                    else
                        _item:UpdateData(_single[1], _single[2], 0)
                    end
                    _index = _index + 1
                end
            end
        end
    end
    for i = _index, #self.AttList do
        self.AttList[i].Go:SetActive(false)
    end
    self.AttGrid:Reposition()
end

function UISpriteTrainPanel:SetCostItem(itemStr)
    local _index = 1
    if itemStr and itemStr ~= "" then
        local itemArr = Utils.SplitStr(itemStr, ';')
        if itemArr then
            for i = 1, #itemArr do
                local _item = nil
                if #self.CostItemList < _index then
                    _item = self.CostItem:Clone()
                    _item.IsShowTips = true
                    self.CostItemList:Add(_item)
                else
                    _item = self.CostItemList[_index]
                end
                if _item then
                    local _single = Utils.SplitNumber(itemArr[i], '_')
                    if _single and #_single >= 2 then
                        _item:InItWithCfgid(_single[1],  _single[2], false, true)
                        _item:BindBagNum()
                        _item:SetActive(true)
                        _index = _index + 1
                    end
                end
            end
        end
    end
    for i = _index, #self.CostItemList do
        self.CostItemList[i]:SetActive(false)
    end
    self.CostItemGrid:Reposition()
end
--------------------------------------------------------------------------------------------------------------------------------
function L_AttrItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.NameLabel = UIUtils.FindLabel(trans, "Label")
    _m.ValueLabel = UIUtils.FindLabel(trans, "ValueLabel")
    _m.AddValueLabel = UIUtils.FindLabel(trans, "Sprite/AddValueLabel")
    _m.NextGo = UIUtils.FindGo(trans, "Sprite")
    return _m
end

function L_AttrItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

function L_AttrItem:UpdateData(id, value, addValue)
    UIUtils.SetTextByPropName(self.NameLabel, id, "{0}:")
    UIUtils.SetTextByPropValue(self.ValueLabel, id, value)
    if addValue and addValue > 0 then
        self.NextGo:SetActive(true)
        UIUtils.SetTextByPropValue(self.AddValueLabel, id, addValue, "+{0}")
    else
        self.NextGo:SetActive(false)
    end
end
--------------------------------------------------------------------------------------------------------------------------------
return UISpriteTrainPanel
