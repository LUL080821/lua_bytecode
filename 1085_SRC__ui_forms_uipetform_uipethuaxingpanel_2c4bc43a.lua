local NGUITools = CS.NGUITools
local L_ItemBase = CS.Thousandto.Code.Logic.ItemBase
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local CenterType = CS.NGUI.UICenterOnChild
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UIPetHuaXingPanel = {
    -- Pet List
    ScrollView = nil,
    ItemGrid = nil,
    --
    ItemRes = nil,
    -- Resource list
    ItemResList = nil,
    -- Model skin
    ModelSkin = nil,
    ModelRoot = nil,

    -- property
    ProGos = nil,
    ProNames = nil,
    ProCurValues = nil,
    ProNextValues = nil,

    -- Skill
    SkillGrid = nil,
    SkillIcons = nil,
    -- Background picture
    BackTex = nil,
    -- Need items
    NeedItemm = nil,
    ItemProgress = nil,
    ItemCount = nil,
    LevelUPBtn = nil,
    LevelUPRedPoint = nil,
    OutFightBtn = nil,
    AlreadyFull = nil,
    ActiveBtn = nil,
    ActiveRedPoint = nil,

    -- Combat power
    FightPower = nil,

    -- Currently selected pet
    CurSelectItem = nil,

    -- List of interface display
    ShowPetList = nil,
}

-- Register event functions and provide them to the CS side to call.
function UIPetHuaXingPanel:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIPetHuaXingForm_OPEN, self.OnOpen);
    self:RegisterEvent(UIEventDefine.UIPetHuaXingForm_CLOSE, self.OnClose);
    self:RegisterEvent(LogicLuaEventDefine.EID_REFRESH_PET_FORM, self.OnRefreshPanel);
end

local L_PetItem = nil
local L_SkillIcon = nil


function UIPetHuaXingPanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm
    --Create an animation module
    self.AnimModule = UIAnimationModule(trans)
        --Add an animation
    self.AnimModule:AddAlphaAnimation()

    self.ScrollView = UIUtils.FindScrollView(trans, "List")


    self.ItemGrid = UIUtils.FindGrid(trans, "List/Grid")
    self.ItemRes = UIUtils.FindGo(trans, "List/Grid/Res")
    self.ItemResList = List:New()

    local _itemParent = self.ItemGrid.transform
    for i = 0, _itemParent.childCount - 1 do
        self.ItemResList:Add(L_PetItem:New(_itemParent:GetChild(i), self))
    end

    self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(parent.Trans, "Center/UIRoleSkinCompoent"))
    self.ModelSkin:OnFirstShow(self.this, FSkinTypeCode.Pet, "show_idle")
    self.BackTex = UIUtils.FindTex(trans, "BackTex")
    self.ModelRoot = UIUtils.FindTrans(trans, "UIRoleSkinCompoent/Box/ModelRoot")
    self.ProGos = {}
    self.ProNames = {}
    self.ProCurValues = {}
    self.ProNextValues = {}

    for i = 1, 4 do
        self.ProGos[i] = UIUtils.FindGo(trans, string.format("Buttom/Pro%d", i))
        self.ProNames[i] = UIUtils.FindLabel(trans, string.format("Buttom/Pro%d/Name", i))
        self.ProCurValues[i] = UIUtils.FindLabel(trans, string.format("Buttom/Pro%d/CurValue", i))
        self.ProNextValues[i] = UIUtils.FindLabel(trans, string.format("Buttom/Pro%d/NextValue", i))
    end

    self.SkillGrid = UIUtils.FindGrid(trans, "Buttom/Skills")
    self.SkillIcons = {}
    for i = 1, 4 do
        self.SkillIcons[i] = L_SkillIcon:New(UIUtils.FindTrans(trans, string.format("Buttom/Skills/%d", i), i == 1))
    end

    self.NeedItemm = UILuaItem:New(UIUtils.FindTrans(trans, "Buttom/UIItem"))
    self.ItemProgress = UIUtils.FindProgressBar(trans, "Buttom/Bless")
    self.ItemCount = UIUtils.FindLabel(trans, "Buttom/Bless/Label")
    self.LevelUPBtn = UIUtils.FindBtn(trans, "Buttom/LevelUp")
    self.DisableLevelUPBtn = UIUtils.FindBtn(trans, "Buttom/LevelUp/Disable")
    self.LevelUPRedPoint = UIUtils.FindGo(trans, "Buttom/LevelUp/RedPoint")
    UIUtils.AddBtnEvent(self.LevelUPBtn, self.OnLevelUpBtnClick, self)
    self.OutFightBtn = UIUtils.FindBtn(trans, "Buttom/OutFight")
    UIUtils.AddBtnEvent(self.OutFightBtn, self.OnOutFightBtnClick, self)
    self.AlreadyFull = UIUtils.FindGo(trans, "Buttom/AlreadyFull")
    self.ActiveBtn = UIUtils.FindBtn(trans, "Buttom/ActiveBtn")
    self.ActiveRedPoint = UIUtils.FindGo(trans, "Buttom/ActiveBtn/RedPoint")
    UIUtils.AddBtnEvent(self.ActiveBtn, self.OnActiveBtnClick, self)
    self.FightPower = UIUtils.FindLabel(trans, "Buttom/Fight")
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.RootForm.AnimModule)
    self.ButtomTrans = UIUtils.FindTrans(trans, "Buttom")
    -- self.RootForm:AddAlphaPosAnimation(self.ButtomTrans, 0, 1, 0, -50, 0.4, false, false)
    self.ScrollProgress = UIUtils.FindProgressBar(trans, "Buttom/Bless")

    self.ShowPetList = List:New()
    local function  _forFunc(key, cfg)
        if cfg.IfFashion ~= 0 and cfg.IsIgnore == 1  then
            self.ShowPetList:Add(cfg)
        end
    end
    DataConfig.DataPet:Foreach(_forFunc)
    self.ShowPetList:Sort(function(x, y)
        return x.Order < y.Order
    end)
    self.IsFirstShow = true

    self.ItemGrid:Reposition()
    self.ScrollView:ResetPosition()
    return self

    
end


function UIPetHuaXingPanel:Show()
    -- --Play the start-up picture
    self.Go:SetActive(true)
    -- self:RefreshPanel(self.IsVisible == false, nil)
    -- self.IsVisible = true
    self:RefreshPanel(nil, nil)
end

function UIPetHuaXingPanel:Hide()
    --Play Close animation
    self.Go:SetActive(false)
    self.IsVisible = false
end


-- Turn on event
function UIPetHuaXingPanel:Update(dt)
    if self.CurSelectPanel == 1 then
        self.DetPanel:Update(dt)
    end
    self.AnimPlayer:Update(dt)
    if self.ScrollValue ~= nil and self.ScrollValueFrameCount ~= nil then
        self.ScrollValueFrameCount = self.ScrollValueFrameCount - 1
        if self.ScrollValueFrameCount <= 0 then
            self.ScrollProgress.value = self.ScrollValue
            self.ScrollValue = nil
            self.ScrollValueFrameCount = nil
            self.AnimPlayer:Play()
        end
    end
end

-- Turn on event
function UIPetHuaXingPanel:OnOpen(obj, sender)
    self.CSForm:Show(sender);
    self:RefreshPanel(obj, true)
end

-- Close event
function UIPetHuaXingPanel:OnClose(obj, sender)
    self.CSForm:Hide();
end

-- Refresh the interface
function UIPetHuaXingPanel:RefreshPanel(selectPet, playAnim)
    local _petSystem = GameCenter.PetSystem
    local _startY = 32.0
    local _selectItem = nil
    local _index = 1
    local _animList = nil
    if playAnim ~= true then
        playAnim = false
    end
    if playAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    local _selectIndex = 1
    for i = 1, #self.ShowPetList do
        local value = self.ShowPetList[i]
        local key = value.Id
        local _uiItem = nil
        if _index <= #self.ItemResList then
            _uiItem = self.ItemResList[_index]
        else
            _uiItem = L_PetItem:New(UnityUtils.Clone(self.ItemRes).transform, self)
            self.ItemResList:Add(_uiItem)
        end
        _startY = _startY - 100.0
        UnityUtils.SetLocalPosition(_uiItem.Trans, -90.0, _startY, 0)
        _uiItem:SetInfo(value)

        if selectPet ~= nil then
            if selectPet == key then
                _selectItem = _uiItem
                _selectIndex = _index
            end
        elseif key == _petSystem.CurFightPet then
            _selectItem = _uiItem
            _selectIndex = _index
        end
        _index = _index + 1

        if playAnim then
            _animList:Add(_uiItem.Trans)
        end
    end

    for i = _index, #self.ItemResList do
        self.ItemResList[i]:SetInfo(nil)
    end



    if self.CurSelectItem == nil then
        if _selectItem ~= nil then
            self:SetSelect(_selectItem)
            -- self:EnsureVisibleHorizontal(_selectItem.Trans)
        else
            self:SetSelect(self.ItemResList[1])
            _selectIndex = 1
        end
        self.ItemGrid:Reposition()
        self.ScrollView:ResetPosition()
        if playAnim then
            local _startIndex = 1
            local _fashionCount = _index - 1
            if (_fashionCount - _selectIndex) <= 5 then
                _startIndex = _fashionCount - 5
            else
                _startIndex = _selectIndex
            end
            local _allSize = _fashionCount * 91 - 488.5
            local _curSize = (_selectIndex - 1) * 91

            if self.IsFirstShow then
                self.ScrollValue = _curSize / _allSize
                self.ScrollValueFrameCount = 2
            else
                self.ScrollProgress.value = _curSize / _allSize
            end
        
            for i = 1, #_animList do
                self.CSForm:RemoveTransAnimation(_animList[i])
                self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.2, false, false)
                if i >= _startIndex then
                    self.AnimPlayer:AddTrans(_animList[i], (i - _startIndex) * 0.1)
                else
                    self.AnimPlayer:AddTrans(_animList[i], 0)
                end
            end
            self.AnimPlayer:AddTrans(self.ButtomTrans, 0.1)
            if not self.IsFirstShow then
                self.AnimPlayer:Play()
            end
            self.IsFirstShow = false
        end
    else
        self.ItemGrid:Reposition()
        self.ScrollView:ResetPosition()
        self:RefreshDetPanel()
    end

        

    -- SpringPanel để scroll mượt
    local SpringPanel = CS.SpringPanel or CS.NGUI.SpringPanel
    if not SpringPanel then
        Debug.Log("SpringPanel not found")
        return
    else
        Debug.Log("SpringPanel founded")
    end

    
end

-- function UIPetHuaXingPanel:EnsureVisibleHorizontal(itemTrans)
--     if not (self.ScrollView and itemTrans) then
--         print("EnsureVisibleHorizontal: missing ScrollView or itemTrans")
--         return
--     end

--     -- Lấy UIPanel của List
--     local panel = UIUtils.FindPanel(self.Trans, "List")
--     if not panel then
--         print("EnsureVisibleHorizontal: panel nil")
--         return
--     end

--     local svTrans = self.ScrollView.transform

--     -- corners ở world -> đổi về local ScrollView
--     local corners = panel.worldCorners
--     local leftLocal  = svTrans:InverseTransformPoint(corners[0])
--     local rightLocal = svTrans:InverseTransformPoint(corners[2])
--     local itemLocal  = svTrans:InverseTransformPoint(itemTrans.position)

--     local leftX  = leftLocal.x
--     local rightX = rightLocal.x    -- chưa dùng nhưng để đó nếu muốn tinh chỉnh
--     local itemX  = itemLocal.x

--     -- Vị trí mong muốn của item được chọn: sát mép trái + padding
--     local padding = 40   -- chỉnh tuỳ mắt, ví dụ để đúng vị trí thẻ bên trái như ảnh 2
--     local targetX = leftX + padding

--     local dx = targetX - itemX
--     -- debug nếu cần
--     -- print("leftX", leftX, "itemX", itemX, "dx", dx)

--     local delta = CS.UnityEngine.Vector3(dx, 0, 0)
--     self.ScrollView:MoveRelative(delta)
--     self.ScrollView:RestrictWithinBounds(true)
-- end

-- Choose a pet
function UIPetHuaXingPanel:SetSelect(petItem)
    self.CurSelectItem = petItem
    for i = 1, #self.ItemResList do
        self.ItemResList[i]:SetSelect(self.ItemResList[i] == petItem)
    end
    self:RefreshDetPanel()
end

-- Refresh the details interface
function UIPetHuaXingPanel:RefreshDetPanel()
    local _petCfg = self.CurSelectItem.PetCfg
    local _petInst = GameCenter.PetSystem:FindActivePetInfo(_petCfg.Id)
    local _curLevel = 0
    local _activeLevels = nil
    if _petInst ~= nil then
        self.ActiveBtn.gameObject:SetActive(false)
        _curLevel = _petInst.CurLevel
        _activeLevels = _petInst.SkillActiveLevels
        -- Already activated
        local _curPros = nil
        local _nextPros = nil

        if _petInst.CurLevel >= _petInst.Cfg.FullDegress then
            local _fullCfg = DataConfig.DataPetRank[_petInst.ID * 1000 + _petInst.Cfg.FullDegress]
            if _fullCfg ~= nil then
                _curPros = Utils.SplitStrByTableS(_fullCfg.Attribute)
                -- Add activation attributes
                _curPros = Utils.MergePropTable(_curPros, _petInst.ActivePros)
                _nextPros = nil
            end

            self.AlreadyFull:SetActive(true)
            -- self.LevelUPBtn.gameObject:SetActive(false)
            self.LevelUPBtn.gameObject:SetActive(true)
            -- NGUITools.SetButtonGrayAndNotOnClick(self.LevelUPBtn.transform, true)
            self.DisableLevelUPBtn.gameObject:SetActive(true)
            self.DisableLevelUPBtn.isEnabled = false
        else
            _curPros = _petInst.CurAllPros
            _nextPros = _petInst.NextAddPros

            self.AlreadyFull:SetActive(false)
            self.LevelUPBtn.gameObject:SetActive(true)
            -- NGUITools.SetButtonGrayAndNotOnClick(self.LevelUPBtn.transform, false)
            self.DisableLevelUPBtn.gameObject:SetActive(false)
            self.DisableLevelUPBtn.isEnabled = false
        end
        self.OutFightBtn.gameObject:SetActive(_petInst.ID ~= GameCenter.PetSystem.CurFightPet)
 
        for i = 1, 4 do
            if i <= #_curPros then
                self.ProGos[i]:SetActive(true)
                UIUtils.SetTextByPropName(self.ProNames[i], _curPros[i][1])
                UIUtils.SetTextByPropValue(self.ProCurValues[i], _curPros[i][1], _curPros[i][2])
                if _nextPros ~= nil then
                    self.ProNextValues[i].gameObject:SetActive(true)
                    UIUtils.SetTextByPropValue(self.ProNextValues[i], _nextPros[i][1], _nextPros[i][2])
                else
                    self.ProNextValues[i].gameObject:SetActive(false)
                end
            else
                self.ProGos[i]:SetActive(false)
            end
        end

        local _needItemParam = Utils.SplitStr(_petInst.CurLevelCfg.RankExp, '_')
        local _itemId = tonumber(_needItemParam[1])
        local _itemCount = tonumber(_needItemParam[2])
        self.LevelUPRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetLevel, _petCfg.Id))
        self.SkillIcons[1]:SetSkill(DataConfig.DataSkill[_petCfg.PetSkill], nil, true)
        local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemId)
        if _petInst.CurLevel >= _petInst.Cfg.FullDegress then
            self.ItemProgress.value = 1
            UIUtils.ClearText(self.ItemCount)
            self.NeedItemm:InItWithCfgid(_itemId, 0, false, true)
            self.NeedItemm:CanelBindBagNum()
        else
            self.NeedItemm:InItWithCfgid(_itemId, _itemCount, false, true)
            self.NeedItemm:BindBagNum()
            self.ItemProgress.value = haveNum / _itemCount
            UIUtils.SetTextByProgress(self.ItemCount, haveNum, _itemCount, false)
        end
        UIUtils.SetTextByNumber(self.FightPower, FightUtils.GetPropetryPowerByList(_petInst.CurAllPros), false)
    else
        self.LevelUPBtn.gameObject:SetActive(false)
        self.OutFightBtn.gameObject:SetActive(false)
        self.ActiveBtn.gameObject:SetActive(true)
        self.AlreadyFull:SetActive(false)
        _activeLevels = {}
        -- Activation level of computing skills
        for i = 1, _petCfg.MaxDegree do
            local _levelCfg = DataConfig.DataPetRank[_petCfg.Id * 1000 + i]
            if _levelCfg ~= nil then
                local _skillParam =  Utils.SplitStrByTableS(_levelCfg.PetSkill, {';', '_'})
                for j = 1, #_skillParam do
                    if _activeLevels[_skillParam[j][1]] == nil then
                        _activeLevels[_skillParam[j][1]] = {_skillParam[j][2], _levelCfg, i}
                    end
                end
            end
        end
        local _firstLevelCfg = DataConfig.DataPetRank[_petCfg.Id * 1000 + 1]
        local _nextPros = Utils.SplitStrByTableS(_firstLevelCfg.Attribute)
        local _activePros = Utils.SplitStrByTableS(_petCfg.Attribute)
        _nextPros = Utils.MergePropTable(_nextPros, _activePros)
        UIUtils.SetTextByNumber(self.FightPower, FightUtils.GetPropetryPowerByList(_nextPros), false)
        for i = 1, 4 do
            if i <= #_nextPros then
                self.ProGos[i]:SetActive(true)
                UIUtils.SetTextByPropName(self.ProNames[i], _nextPros[i][1])
                UIUtils.SetTextByPropValue(self.ProCurValues[i], _nextPros[i][1], _nextPros[i][2])
                self.ProNextValues[i].gameObject:SetActive(false)
            else
                self.ProGos[i]:SetActive(false)
            end
        end

        local _ulockParam = Utils.SplitStr(_petCfg.Unlock, '_');
        self.ActiveRedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetLevel, _petCfg.Id))
        -- Props unlock
        self.NeedItemm:InItWithCfgid(_ulockParam[2], 1, false, true)
        self.NeedItemm:BindBagNum()
        self.SkillIcons[1]:SetSkill(DataConfig.DataSkill[_petCfg.PetSkill], _firstLevelCfg, false)
        local haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_ulockParam[2])
        self.ItemProgress.value = haveNum / 1
        UIUtils.SetTextByProgress(self.ItemCount, haveNum, 1, false)
    end

    local _skillCount = #_activeLevels
    for i = 2, #self.SkillIcons do
        if (i - 1) <= _skillCount then
            self.SkillIcons[i]:SetSkill(DataConfig.DataSkill[_activeLevels[i - 1][1]], _activeLevels[i - 1][2], _curLevel >= _activeLevels[i - 1][3])
        else
            self.SkillIcons[i]:SetSkill(nil, nil, nil)
        end
    end
    self.SkillGrid:Reposition()

    
        self:SetModelSkin(_petCfg)
end

function UIPetHuaXingPanel:SetModelSkin(_petCfg)
    self.ModelSkin:ResetSkin()
    self.ModelSkin:ResetRot()
    self.ModelSkin:SetEquip(FSkinPartCode.Body, _petCfg.Model)
    self.ModelSkin:SetLocalScale(_petCfg.UiScale)
    self.ModelSkin:Play("show", 0, 1, 1)
    UnityUtils.SetLocalPositionY(self.ModelRoot, _petCfg.UiModelHeight)
end

-- Unlock button click
function UIPetHuaXingPanel:OnActiveBtnClick()
    if self.NeedItemm.ShowItemData and self.NeedItemm.IsEnough then
        GameCenter.PetSystem:ReqActivePet(self.CurSelectItem.PetCfg.Id)
    else
        if self.NeedItemm.ShowItemData then
            GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.NeedItemm.ShowItemData.CfgID)
        end
    end
end

-- Click on the upgrade button
function UIPetHuaXingPanel:OnLevelUpBtnClick()
    if self.NeedItemm.ShowItemData and self.NeedItemm.IsEnough then
        GameCenter.PetSystem:ReqUpPet(self.CurSelectItem.PetCfg.Id)
    else
        if self.NeedItemm.ShowItemData then
            GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(self.NeedItemm.ShowItemData.CfgID)
        end
    end
end

-- Click on the Battle button
function UIPetHuaXingPanel:OnOutFightBtnClick()
    GameCenter.PetSystem:ReqOutPet(self.CurSelectItem.PetCfg.Id)
end

-- Refresh event
function UIPetHuaXingPanel:OnRefreshPanel(obj, sender)
    self:RefreshPanel(obj, sender)
end

-- Pet avatar
L_PetItem = {
    Trans = nil,
    GO = nil,
    Parent = nil,
    Btn = nil,
    Name = nil,
    StarRootGo = nil,
    StarGos = nil,
    Select = nil,
    SelectName = nil,
    PetCfg = nil,
    RedPoint = nil,
    LockGo = nil,
    OutFightGo = nil,
    HeadIcon = nil,
}

function L_PetItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.GO = trans.gameObject
    _m.Parent = parent
    _m.Btn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Name = UIUtils.FindLabel(_m.Trans, "Name")
    _m.Select = UIUtils.FindGo(_m.Trans, "Select")
    _m.SelectName = UIUtils.FindLabel(_m.Trans, "Select/SelectName")
    _m.StarGos = {}
    for i = 1, 5 do
        _m.StarGos[i] = UIUtils.FindGo(_m.Trans, string.format("Grid/%d/Bg", i))
    end
    _m.StarRootGo = UIUtils.FindGo(_m.Trans, "Grid")
    _m.RedPoint = UIUtils.FindGo(_m.Trans, "UpSprite")
    _m.LockGo = UIUtils.FindGo(_m.Trans, "NotActive")
    _m.OutFightGo = UIUtils.FindGo(_m.Trans, "Equip")
    _m.HeadIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(_m.Trans, "Icon"))
    return _m
end

function L_PetItem:SetInfo(petCfg)
    self.PetCfg = petCfg
    if self.PetCfg ~= nil then
        self.GO:SetActive(true)
        self.GO.name = UIUtils.CSFormat("{0:D4}", petCfg.Order)
        UIUtils.SetTextByStringDefinesID(self.Name, self.PetCfg._Name)
        UIUtils.SetTextByStringDefinesID(self.SelectName, self.PetCfg._Name)
        local _peInst = GameCenter.PetSystem:FindActivePetInfo(self.PetCfg.Id)
        if _peInst ~= nil then
            self.LockGo:SetActive(false)
            self.StarRootGo:SetActive(true)
            self.OutFightGo:SetActive(_peInst.ID == GameCenter.PetSystem.CurFightPet)
            local _curLevel = _peInst.CurLevel
            for i = 1, 5 do
                self.StarGos[i]:SetActive(_curLevel > i)
            end
        else
            self.LockGo:SetActive(true)
            self.OutFightGo:SetActive(false)
            -- self.StarRootGo:SetActive(false)
        end
        self.HeadIcon:UpdateIcon(petCfg.Icon)
        self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.PetLevel, petCfg.Id))
    else
        self.GO:SetActive(false)
    end
end

function L_PetItem:SetSelect(b)
    self.Select:SetActive(b)
    self.Name.gameObject:SetActive(not b)
end

function L_PetItem:OnBtnClick()
    self.Parent:SetSelect(self)
end

-- Pet Skills icon
L_SkillIcon = {
    Trans = nil,
    GO = nil,
    Btn = nil,
    Icon = nil,
    Name = nil,
    SkillCfg = nil,
}

function L_SkillIcon:New(trans, atkSkill)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.GO = trans.gameObject
    _m.Btn = UIUtils.FindBtn(_m.Trans)
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)
    _m.Icon = UIUtils.FindSpr(_m.Trans, "Icon")
    _m.Name = UIUtils.FindLabel(_m.Trans, "Name")
    return _m
end

function L_SkillIcon:SetSkill(skillCfg, levelCfg, isActive)
    self.SkillCfg = skillCfg
    if skillCfg ~= nil then
        self.GO:SetActive(true)
        self.Icon.spriteName = string.format("skill_%d", skillCfg.Icon)
        UIUtils.SetTextByStringDefinesID(self.Name, skillCfg._Name)
    else
        self.GO:SetActive(false)
    end
end

function L_SkillIcon:OnBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIPetSkillTips_OPEN, self.SkillCfg.Id)
end

return UIPetHuaXingPanel

