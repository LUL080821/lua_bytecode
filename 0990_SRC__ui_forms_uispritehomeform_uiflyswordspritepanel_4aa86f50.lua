------------------------------------------------
--author:
--Date: 2020-07-06
--File: UIFlySwordSpritePanel.lua
--Module: UIFlySwordSpritePanel
--Description: Sword Spirit Basic Interface
------------------------------------------------
local UIFlySwordSpritePanel = {
    Trans = nil,
    Go = nil,
    SkinTransList = List:New(),
    SkinActiveGoList = List:New(),
    SkinUnActiveGoList = List:New(),
    SkinSelectEffctList = List:New(),
    SkinActiveEffctList = List:New(),
    --Whether to open the interface
    IsOpen = false
}
local L_FlySwordItem = {
    Trans = nil,
    Go = nil,
}
local L_SkillItem = {
    Trans = nil,
    Go = nil,
}

--Create a new object
function UIFlySwordSpritePanel:OnFirstShow(trans, cSharpForm)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = cSharpForm
    _m:FindAllComponents()
    return _m
end

--Find controls
function UIFlySwordSpritePanel:FindAllComponents()
    self.SkinTrans = UIUtils.FindTrans(self.Trans, "Skin/InfoPanel")
    self.ItemList = List:New()
    for i = 1, 6 do
        self.Item = L_FlySwordItem:OnFirstShow(UIUtils.FindTrans(self.SkinTrans, tostring(i)), self.CSForm)
        self.ItemList:Add(self.Item)
    end
    self.SkillScroll = UIUtils.FindScrollView(self.Trans, "SkillTrans/Scroll")
    local _gridTrans = UIUtils.FindTrans(self.Trans, "SkillTrans/Scroll/Grid")
    self.SkillItemList = List:New()
    if _gridTrans then
        self.SkillGrid = UIUtils.FindGrid(_gridTrans)
        for i = 0, _gridTrans.childCount - 1 do
            self.SkillItem = L_SkillItem:OnFirstShow(_gridTrans:GetChild(i))
            self.SkillItemList:Add(self.SkillItem)
        end
    end

    self.Skin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.Trans, "Skin/UIRoleSkinCompoent"))
    if self.Skin then
        self.Skin:OnFirstShow(self.CSForm, FSkinTypeCode.Player, AnimClipNameDefine.NormalIdle, 1, true)
        self.Skin.EnableDrag = false
        self.Skin:SetOnSkinPartChangedHandler(Utils.Handler(self.SkinLoadHandler, self))
    end
    self.Go:SetActive(false)
    self.CSForm:AddAlphaScaleAnimation(self.Trans, 0, 1, 1.1, 1.1, 1, 1, 0.3, false, false)
end

function UIFlySwordSpritePanel:OnOpen()
    self.IsFirstLoad = true
    self.CSForm:PlayShowAnimation(self.Trans)
    self:UpdateData(true)
    self.IsOpen = true
end

function UIFlySwordSpritePanel:OnClose()
    self.Go:SetActive(false)
    self.SkinActiveEffctList:Clear()
    self.IsOpen = false
    self.Skin:ResetSkin()
end

function UIFlySwordSpritePanel:Update(dt)
    if not self.IsOpen then
        return
    end
end

function UIFlySwordSpritePanel:UpdateData(isModelSet)
    local _index = 1
    if isModelSet then
        self.Skin:ResetSkin()
        self.Skin:SetEquip(FSkinPartCode.Body, 690042)
    end
    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
    if _typeDic then
        _typeDic:Foreach(function(k, v)
            local _item = nil
            if _index <= #self.ItemList then
                _item = self.ItemList[_index]
            end
            if _item then
                _item.Go:SetActive(true)
                _item:UpdateData(v)
                _index = _index + 1
            end
        end)
    end
    for i = _index, #self.ItemList do
        self.ItemList[i].Go:SetActive(false)
    end
    _index = 1
    DataConfig.DataHuaxingFlySwordSkill:Foreach(function(k, v)
        local _item = nil
        if _index <= #self.SkillItemList then
            _item = self.SkillItemList[_index]
        else
            _item = self.SkillItem:Clone()
            self.SkillItemList:Add(_item)
        end
        if _item then
            _item.Go:SetActive(true)
            _item:UpdateData(v)
            _index = _index + 1
        end
    end)
    for i = _index, #self.SkillItemList do
        self.SkillItemList[i].Go:SetActive(false)
    end
    self.SkillGrid.repositionNow = true
    self.SkillScroll.repositionWaitFrameCount = 3
end

function UIFlySwordSpritePanel:SkinLoadHandler(skin, part)
    if part ~= FSkinPartCode.Body or not self.Skin.Skin then
        return
    end
    local body = self.Skin.Skin:GetSkinPart(FSkinPartCode.Body);
    if body and body.RealTransform then
        self.SkinTransList:Clear()
        self.SkinActiveGoList:Clear()
        self.SkinUnActiveGoList:Clear()
        self.SkinSelectEffctList:Clear()
        self.SkinActiveEffctList:Clear()
        for i = 1, 6 do
            local _trans = UIUtils.FindTrans(body.RealTransform, tostring(i))
            if _trans then
                self.SkinTransList:Add(_trans)
                self.SkinActiveGoList:Add(UIUtils.FindGo(_trans, "Active"))
                self.SkinUnActiveGoList:Add(UIUtils.FindGo(_trans, "UnActive"))
                -- self.SkinSelectEffctList:Add(UIUtils.FindGo(_trans, "Effect"))
                -- self.SkinActiveEffctList:Add(UIUtils.FindGo(_trans, "Active/Act"))
                UIUtils.FindGo(_trans, "Effect"):SetActive(false)
                if GameCenter.FlySowardSystem:GetActiveByType(i) then
                    self.SkinActiveGoList[i]:SetActive(true)
                    self.SkinUnActiveGoList[i]:SetActive(false)
                else
                    self.SkinActiveGoList[i]:SetActive(false)
                    self.SkinUnActiveGoList[i]:SetActive(true)
                end
            end
        end
        if self.IsFirstLoad then
            self.IsFirstLoad = false
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function L_FlySwordItem:OnFirstShow(trans, cSharpForm)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.CSForm = cSharpForm
    _m.NameLabel = UIUtils.FindLabel(trans, "Name")
    _m.LvLabel = UIUtils.FindLabel(trans, "Lv")
    _m.RedGo = UIUtils.FindGo(trans, "Red")
    local _btn = UIUtils.FindBtn(trans, "Btn")
    UIUtils.AddBtnEvent(_btn, _m.onClick, _m)
    return _m
end

function L_FlySwordItem:onClick()
    if self.IsActive and self.SkillActive then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.FlySwordSpriteTrain, self.Type)
    else
        if not self.IsActive then
            Utils.ShowPromptByEnum("C_SPRITEHOME_CLICKERROR")
            return
        end
        if not self.SkillActive then
            local _skCfg = DataConfig.DataHuaxingFlySwordSkill[self.Type - 1]
            if _skCfg then
                local _skillCfg = DataConfig.DataSkill[_skCfg.PassiveSkill]
                if _skillCfg then
                    Utils.ShowPromptByEnum("C_FLYSWORD_SKILLACTIVE", _skillCfg.Name)
                end
            end
            return
        end
    end
end

function L_FlySwordItem:UpdateData(_typeData)
    if _typeData then
        self.Type = _typeData.Type
        if self.Type > 1 then
            local _skCfg = DataConfig.DataHuaxingFlySwordSkill[self.Type - 1]
            if _skCfg.Type == 1 then
                local _ar = Utils.SplitNumber(_skCfg.ActivePram, '_')
                if _ar[1] and _ar[2] then
                    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                    if _typeDic then
                        _typeDic:ForeachCanBreak(function(k, v)
                            if k == _ar[1] then
                                if v.Grade >= _ar[2] then
                                    self.SkillActive = true
                                else
                                    self.SkillActive = false
                                end
                            end
                        end)
                    end
                end
            elseif _skCfg.Type == 2 then
                local _ar = Utils.SplitNumber(_skCfg.ActivePram, '_')
                if _ar[1] and _ar[2] then
                    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                    if _typeDic then
                        local _num = 0
                        _typeDic:Foreach(function(k, v)
                            if v.Grade >= _ar[2] then
                                _num = _num + 1
                            end
                        end)
                        if _num >= _ar[1] then
                            self.SkillActive = true
                        else
                            self.SkillActive = false
                        end
                    end
                end
            end
        else
            self.SkillActive = true
        end
        self.IsActive = false
        local curCfg = nil
        local _dataDic = GameCenter.FlySowardSystem:GetDataDic()
        for i = 1, #_typeData.IDList do
            if _dataDic and _dataDic:ContainsKey(_typeData.IDList[i]) then
                local _data = _dataDic[_typeData.IDList[i]]
                if _data.IsActive or i == 1 then
                    curCfg = _data.Cfg
                end
                if _data.IsActive then
                    self.IsActive = true
                end
            end
        end
        if curCfg then
            UIUtils.SetTextByStringDefinesID(self.NameLabel, curCfg._Name)
            if GameCenter.FlySowardSystem:GetActiveByType(self.Type) then
                UIUtils.SetTextByEnum(self.LvLabel, "C_BLOOD_LEVEL", _typeData.Grade, _typeData.Level)
            else
                UIUtils.ClearText(self.LvLabel)
            end
        end
        self.RedGo:SetActive(false)
        -- self.RedGo:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpLv, self.Type) or GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordSpriteUpGrade, self.Type))
    end
end
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function L_SkillItem:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m.DescLabel = UIUtils.FindLabel(trans, "Desc")
    _m.NameLabel = UIUtils.FindLabel(trans, "Name")
    _m.StateLabel = UIUtils.FindLabel(trans, "State")
    _m.SkillIcon = UIUtils.FindSpr(trans, "Skill/Icon")
    local _btn = UIUtils.FindBtn(trans, "Skill")
    UIUtils.AddBtnEvent(_btn, _m.onClick, _m)
    return _m
end

function L_SkillItem:Clone()
    return L_SkillItem:OnFirstShow(UnityUtils.Clone(self.Go).transform)
end

function L_SkillItem:onClick()
    if self.Info then
        GameCenter.PushFixEvent(UIEventDefine.UISkillTips_OPEN, self.Info.PassiveSkill)
    end
end

function L_SkillItem:UpdateData(data)
    if data then
        self.Info = data
        local _skillCfg = DataConfig.DataSkill[data.PassiveSkill]
        if _skillCfg then
            self.SkillIcon.spriteName = string.format("skill_%d", _skillCfg.Icon)
            UIUtils.SetTextByStringDefinesID(self.DescLabel, data._Des)
            UIUtils.SetTextByStringDefinesID(self.NameLabel, _skillCfg._Name)
            if data.Type == 1 then
                local _ar = Utils.SplitNumber(data.ActivePram, '_')
                if _ar[1] and _ar[2] then
                    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                    if _typeDic then
                        _typeDic:ForeachCanBreak(function(k, v)
                            if k == _ar[1] then
                                if v.Grade >= _ar[2] then
                                    UIUtils.SetTextByEnum(self.StateLabel, "C_Done")
                                    UIUtils.SetColorByString(self.StateLabel, "#008561")
                                else
                                    UIUtils.SetTextByEnum(self.StateLabel, "C_UnDone")
                                    UIUtils.SetColorByString(self.StateLabel, "#ff4e00")
                                end
                                return true
                            end
                        end)
                    end
                end
            elseif data.Type == 2 then
                local _ar = Utils.SplitNumber(data.ActivePram, '_')
                if _ar[1] and _ar[2] then
                    local _typeDic = GameCenter.FlySowardSystem:GetTypeDic()
                    if _typeDic then
                        local _num = 0
                        _typeDic:Foreach(function(k, v)
                            if v.Grade >= _ar[2] then
                                _num = _num + 1
                            end
                        end)
                        if _num >= _ar[1] then
                            UIUtils.SetTextByEnum(self.StateLabel, "C_Done")
                            UIUtils.SetColorByString(self.StateLabel, "#008561")
                        else
                            UIUtils.SetTextByEnum(self.StateLabel, "C_UnDone")
                            UIUtils.SetColorByString(self.StateLabel, "#ff4e00")
                        end
                    end
                end
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------------
return UIFlySwordSpritePanel
