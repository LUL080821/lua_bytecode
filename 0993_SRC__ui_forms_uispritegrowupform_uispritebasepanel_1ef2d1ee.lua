------------------------------------------------
--author:
--Date: 2020-07-06
--File: UISpriteBasePanel.lua
--Module: UISpriteBasePanel
--Description: Sword Spirit Form Interface
------------------------------------------------
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UISpriteBasePanel = {
    Trans = nil,
    Go = nil,
}
local L_AttrItem = {
    Trans = nil,
    Go = nil,
}
local L_SkillItem = {
    Trans = nil,
    Go = nil,
}

--Create a new object
function UISpriteBasePanel:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

--Find controls
function UISpriteBasePanel:FindAllComponents()
    self.AttGrid = UIUtils.FindGrid(self.Trans, "Right/AttGrid")
    self.AttGridTrans = UIUtils.FindTrans(self.Trans, "Right/AttGrid")
    self.AttList = List:New()
    for i = 0, self.AttGridTrans.childCount - 1 do
        self.AttrItem = L_AttrItem:OnFirstShow(self.AttGridTrans:GetChild(i))
        self.AttList:Add(self.AttrItem)
    end
    --Active skills
    self.UseSkillItem = L_SkillItem:OnFirstShow(UIUtils.FindTrans(self.Trans, "Right/Skill"))
    self.UseSkillItem.IsShowTips = false
    --The Battle Button
    self.SkillItemList = List:New()
    self.SkillGrid = UIUtils.FindGrid(self.Trans, "Right/SkillGrid")
    self.SkillGridTrans = UIUtils.FindTrans(self.Trans, "Right/SkillGrid")
    for i = 0, self.SkillGridTrans.childCount - 1 do
        self.SkillItem = L_SkillItem:OnFirstShow(self.SkillGridTrans:GetChild(i))
        self.SkillItem.IsShowTips = true
        self.SkillItemList:Add(self.SkillItem)
    end
    self.NameLabel = UIUtils.FindLabel(self.Trans, "Right/Name")
    self.DescLabel = UIUtils.FindLabel(self.Trans, "Right/Desc")
end

function UISpriteBasePanel:OnOpen(type)
    self.Go:SetActive(true)
    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
	if _typeDic and _typeDic:ContainsKey(type) then
		local _typeData = _typeDic[type]
        self:SetAttr(_typeData.IDList)
        -- self:SetSkill(_typeData.IDList)
	end
end

function UISpriteBasePanel:OnClose()
    self.Go:SetActive(false)
end

function UISpriteBasePanel:SetAttr(list)
    if not list then
        return
    end
    local curCfg = nil
    local nextCfg = nil
    local _dataDic = GameCenter.FlySowardSystem:GetDataDic()
    for i = 1, #list do
        if _dataDic and _dataDic:ContainsKey(list[i]) then
            local _data = _dataDic[list[i]]
            if _data.IsActive then
                curCfg = _data.Cfg
            else
                nextCfg = _data.Cfg
                break
            end
        end
    end
    local flag = nil
    local attArr = nil
    if curCfg == nil and nextCfg ~= nil then
        flag = 0
        attArr = Utils.SplitStr(nextCfg.RentAtt, ';')
    elseif curCfg ~= nil and nextCfg ~= nil then
        flag = 1
        attArr = Utils.SplitStr(curCfg.RentAtt, ';')
    elseif curCfg ~= nil and nextCfg == nil then
        flag = 2
        attArr = Utils.SplitStr(curCfg.RentAtt, ';')
    end
    if flag ~= nil and attArr ~= nil then
        for i = 1, #attArr do
            local _item = nil
            if #self.AttList < i then
                _item = self.AttrItem:Clone()
                self.AttList:Add(_item)
            else
                _item = self.AttList[i]
            end
            if _item then
                local _single = Utils.SplitNumber(attArr[i], '_')
                if _single and #_single >= 3 then
                    if flag == 0 then
                        _item:UpdateData(_single[1], 0, _single[2])
                    elseif flag == 1 then
                        _item:UpdateData(_single[1], _single[2], _single[3])
                    else
                        _item:UpdateData(_single[1], _single[2], 0)
                    end
                end
            end
        end
    end
    self.AttGrid:Reposition()
end

function UISpriteBasePanel:SetSkill(list)
    if not list then
        return
    end
    local curCfg = nil
    local _dataDic = GameCenter.FlySowardSystem:GetDataDic()
    local _index = 1
    for i = 1, #list do
        if _dataDic and _dataDic:ContainsKey(list[i]) then
            local _data = _dataDic[list[i]]
            if _data.IsActive or i == 1 then
                curCfg = _data.Cfg
            end
            local _item = nil
            if _index > #self.SkillItemList then
                _item = self.SkillItem:Clone()
                _item.IsShowTips = true
                self.SkillItemList:Add(_item)
            else
                _item = self.SkillItemList[_index]
            end
            if _item then
                _item:UpdateData(_data.Cfg.PassiveSkill, _data.IsActive, i)
                _item.Go:SetActive(true)
                _index = _index + 1
            end
        end
    end
    for i = _index, #self.SkillItemList do
        self.SkillItemList[i].Go:SetActive(false)
    end
    self.SkillGrid:Reposition()
    if curCfg then
        self.UseSkillItem:UpdateData(curCfg.UseSkill, true)
    end
end

function UISpriteBasePanel:UpdateDesc(data)
    if data then
        UIUtils.SetTextByStringDefinesID(self.DescLabel, data._Describe)
		UIUtils.SetTextFormat(self.NameLabel, "【{0}】", data.Name)
    end
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

--------------------------------------------------------------------------------------------------------------------------------
function L_SkillItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    local _indexTrans = UIUtils.FindTrans(trans, "Name")
    if _indexTrans then
        _m.NameLabel = UIUtils.FindLabel(trans, "Name")
    end
    _indexTrans = UIUtils.FindTrans(trans, "Desc")
    if _indexTrans then
        _m.DescLabel = UIUtils.FindLabel(trans, "Desc")
    end
    _indexTrans = UIUtils.FindTrans(trans, "ActiveLabel")
    if _indexTrans then
        _m.ActiveLabel = UIUtils.FindLabel(trans, "ActiveLabel")
    end
    _m.IconSpr = UIUtils.FindSpr(trans, "Icon")
    _m.Btn = UIUtils.FindBtn(trans, "Bg")
    UIUtils.AddBtnEvent(_m.Btn, _m.OnClick, _m)
    return _m
end

function L_SkillItem:Clone()
    return self:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

function L_SkillItem:OnClick()
    if self.IsShowTips then
        GameCenter.PushFixEvent(UIEventDefine.UISkillTips_OPEN, self.skillID)
    end
end

function L_SkillItem:UpdateData(skillID, IsActive, index)
    self.skillID = skillID
    local Cfg = DataConfig.DataSkill[skillID]
    if Cfg then
        self.IconSpr.spriteName = UIUtils.CSFormat("skill_{0}", Cfg.Icon)
        self.IconSpr.IsGray = not IsActive
        if IsActive then
            if self.ActiveLabel then
                UIUtils.ClearText(self.ActiveLabel)
            end
        else
            if self.ActiveLabel then
                UIUtils.ClearText(self.ActiveLabel)
                if index and index == 1 then
                    UIUtils.SetTextByEnum(self.ActiveLabel, "C_MINGJIANJIHUO")
                elseif index and index == 2 then
                    UIUtils.SetTextByEnum(self.ActiveLabel, "C_JIANLINGJIHUO")
                elseif index and index == 3 then
                    UIUtils.SetTextByEnum(self.ActiveLabel, "C_JUEXINGJIHUO")
                end
            end
        end
        if self.NameLabel then
            UIUtils.SetTextByStringDefinesID(self.NameLabel, Cfg._Name)
        end
        if self.DescLabel then
            UIUtils.SetTextByStringDefinesID(self.DescLabel, Cfg._Desc)
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------------
return UISpriteBasePanel
