------------------------------------------------
-- Author:
-- Date: 2021-03-26
-- File: PlayerSkillSystem.lua
-- Module: PlayerSkillSystem
-- Description: Player Skill System
------------------------------------------------
local L_PlayerSkill = require "Logic.PlayerSkill.PlayerSkill"
local L_PlayerSkillCell = require "Logic.PlayerSkill.PlayerSkillCell"

local MAX_CELL_COUNT = 5
local MAX_POS_COUNT = 9

local PlayerSkillSystem = {
    -- Grid Level
    CellLevel = 0,
    -- Whether the grid data has been initialized
    IsInitSkillPos = false,
    -- Skill position data, the grid where the skill is stored
    SkillPoss = {},
    -- Skills automatically release data, and stored skills automatically release data
    SkillUseState = {},
    -- Meridian activation data
    MeridianDic = Dictionary:New(),
    -- Active skills corresponding to meridians
    MeridianAddSkillDic = nil,
    -- The currently selected mind method id
    CurSelectMerId = 0,
    -- List of general attack skills corresponding to professional mind method
    NormalSkillCfg = Dictionary:New(),
    -- The number of times the mental method is reset
    CurResetMerCount = 0,
    -- Current public CD
    PublicCD = 0,
    -- Current total public CD
    PublicMaxCD = 0,
    -- Current skill list
    SkillList = nil,
    -- Skill grid data
    SkillCell = nil,

    -- List of active passive skills
    ActivePassSkills = nil,
    -- Current transformation skills list
    ChangeSkillList = nil,
    -- Current flying sword skills
    FlySwordSkill = nil,
    -- Number of meridian activation
    MeridianCount = 0,
    -- Flying Sword skill release automatically
    SkillSwordUseState = false,
}


function PlayerSkillSystem:Initialize()
    self.PublicCD = 0
    self.SkillCell = Dictionary:New()
    self.SkillList = List:New()
    self.ActivePassSkills = List:New()
    self.ChangeSkillList = List:New()
    self.NormalSkillCfg:Clear()
    local _gCfg = DataConfig.DataGlobal[GlobalName.meridian_special_skill]
    if _gCfg ~= nil then
        local _gParams = Utils.SplitStrByTableS(_gCfg.Params, {';', '_'})
        for i = 1, #_gParams do
            local _occ = _gParams[i][1]
            local _merId = _gParams[i][2]
            local _skillList = List:New()
            for j = 3, #_gParams[i] do
                _skillList:Add(_gParams[i][j])
            end
            local _occDic = self.NormalSkillCfg[_occ]
            if _occDic == nil then
                _occDic = Dictionary:New()
                self.NormalSkillCfg:Add(_occ, _occDic)
            end
            _occDic:Add(_merId, _skillList)
        end
    end

    for i = 0, MAX_POS_COUNT - 1 do
        self.SkillPoss[i] = -1
    end
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_BEGIN_SKILLCD, self.OnBegionSkillCD, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_END_SKILLCD, self.OEndSkillCD, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ON_USED_SKILL, self.OnUseSkillCallBack, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_SET_CHANGEMODEL_SKILL, self.OnSetChangeModelSkill, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_CLEAR_CHANGEMODEL_SKILL, self.OnClearChangeModelSkill, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_SETAUTOUSE_FLYSWORD_SKILL, self.OnSetSkillSwordUseState, self)
end

function PlayerSkillSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_BEGIN_SKILLCD, self.OnBegionSkillCD, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_END_SKILLCD, self.OEndSkillCD, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ON_USED_SKILL, self.OnUseSkillCallBack, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_SET_CHANGEMODEL_SKILL, self.OnSetChangeModelSkill, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_CLEAR_CHANGEMODEL_SKILL, self.OnClearChangeModelSkill, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_SETAUTOUSE_FLYSWORD_SKILL, self.OnSetSkillSwordUseState, self)
end

-- Total skill level
function PlayerSkillSystem:GetOverallLevel()
    return self.CellLevel
end


function PlayerSkillSystem:OnBegionSkillCD(obj, sender)
    self:BegionCD(obj)
end

function PlayerSkillSystem:OEndSkillCD(obj, sender)
    self:EndCD(obj)
end

function PlayerSkillSystem:OnUseSkillCallBack(obj, sender)
    self:OnUsedSkill(obj)
end

function PlayerSkillSystem:OnSetChangeModelSkill(obj, sender)
    local _changeCfg = DataConfig.DataChangeModel[obj]
    if _changeCfg ~= nil then
        local _changeSkills = Utils.SplitNumber(_changeCfg.Skill, '_')
        self:SetChangeModelSkill(_changeSkills)
    end
end

function PlayerSkillSystem:OnClearChangeModelSkill(obj, sender)
    self:ClearChangeModelSkill()
end

function PlayerSkillSystem:OnSetSkillSwordUseState(b, sender)
    if self.SkillSwordUseState ~= b then
        self.SkillSwordUseState = b
        self:SavePosData()
    end
end

function PlayerSkillSystem:GetMandateSkillList()
    local _result = List:New()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp == nil then
        return _result
    end
    if _lp.IsChangeModel then
        -- Transformation state, use transformation skills list
        for i = 1, #self.ChangeSkillList do
            _result:Add(self.ChangeSkillList[i].CfgID)
        end
    else
        -- Add skills
        for i = 1, MAX_POS_COUNT - 1 do
            if self.SkillUseState[i] then
                local _skillCell = self:GetSkillPosCell(i)
                if _skillCell ~= nil then
                    for j = 1, _skillCell.SkillCount do
                        _result:Add(_skillCell.SkillList[j].CfgID)
                    end
                end
            end
        end
        if self.SkillSwordUseState and GameCenter.MapLogicSwitch.AutoUseXPSkill then
            if self.FlySwordSkill ~= nil then
                _result:Add(self.FlySwordSkill.CfgID)
            end
        end
        -- Add general attack
        local _skillCell = self:GetSkillPosCell(0)
        if _skillCell ~= nil then
            for j = 1, _skillCell.SkillCount do
                _result:Add(_skillCell.SkillList[j].CfgID)
            end
        end
    end
    return _result
end

function PlayerSkillSystem:SkillIsSyncServer(skillId)
    local _skill = self:FindSkill(skillId)
    if _skill == nil then
        return false
    end
    return _skill.IsSync
end

function PlayerSkillSystem:SkillIsCD(skillId)
    local _skill = self:FindSkill(skillId)
    if _skill == nil then
        return true
    end
    return _skill:IsCDing()
end

function PlayerSkillSystem:CanUseSkill(skillId)
    local _skill = self:FindSkill(skillId)
    if _skill == nil then
        return false
    end
    local _cfg = DataConfig.DataSkill[skillId]
    if _cfg == nil then
        return false
    end
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().Occ
    -- Is it a character's skill?
    local _occRight = false
    if _cfg.UserType == SkillClass.None then
        _occRight = true
    elseif _cfg.UserType == SkillClass.XianJian and _occ == Occupation.XianJian then
        _occRight = true
    elseif _cfg.UserType == SkillClass.MoQiang and _occ == Occupation.MoQiang then
        _occRight = true
    elseif _cfg.UserType == SkillClass.DiZang and _occ == Occupation.DiZang then
        _occRight = true
    elseif _cfg.UserType == SkillClass.LuoCha and _occ == Occupation.LuoCha then
        _occRight = true
    else
        _occRight = false
    end
    if not _occRight then
        return false
    end
    -- Skill CD judgment
    if _skill:IsCDing() then
        return false
    end
    -- Public CD judgment
    if _skill.UsePublicCD and self.PublicCD > 0 then
        return false
    end
    return true
end


-- Obtain skill grid data
function PlayerSkillSystem:GetSkillCell(cellId)
    return self.SkillCell[cellId]
end

-- Obtain skill position data
function PlayerSkillSystem:GetSkillPosCell(posId)
    if posId >= 0 and posId < MAX_POS_COUNT then
        return self:GetSkillCell(self.SkillPoss[posId])
    end
    return nil
end

-- Get the skill index of equipment at this location
function PlayerSkillSystem:GetSkillPosCellValue(posId)
    if posId >= 0 and posId < MAX_POS_COUNT then
        return self.SkillPoss[posId]
    end
    return -1
end

-- Get the grid level
function PlayerSkillSystem:GetCellLevel()
    return self.CellLevel
end

function PlayerSkillSystem:FindSkill(skillId)
    for i = 1, #self.SkillList do
        if self.SkillList[i].CfgID == skillId then
            return self.SkillList[i]
        end
    end
    for i = 1, #self.ChangeSkillList do
        if self.ChangeSkillList[i].CfgID == skillId then
            return self.ChangeSkillList[i]
        end
    end
    if self.FlySwordSkill ~= nil and self.FlySwordSkill.CfgID == skillId then
        return self.FlySwordSkill
    end
    return nil
end

function PlayerSkillSystem:Update(dt)
    if self.PublicCD > 0 then
        self.PublicCD = self.PublicCD - dt
    end
    for _, v in pairs(self.SkillCell) do
        v:Update(dt)
    end
    if self.ChangeSkillList ~= nil then
        for i = 1, #self.ChangeSkillList do
            self.ChangeSkillList[i]:Update(dt)
        end
    end
    if self.FlySwordSkill ~= nil then
        self.FlySwordSkill:Update(dt)
    end
end

function PlayerSkillSystem:BegionCD(skillID)
    local _instSkill = self:FindSkill(skillID)
    if _instSkill ~= nil then
        if _instSkill.UsePublicCD and _instSkill.PubilcCD > 0 then
            self.PublicCD = _instSkill.PubilcCD
            self.PublicMaxCD = self.PublicCD
        else
            self.PublicCD = _instSkill.VisualInfo.FrameCount / 30
            self.PublicMaxCD = self.PublicCD
        end
        _instSkill:BeginCD()
    end
end

function PlayerSkillSystem:EndCD(skillID)
    local _instSkill = self:FindSkill(skillID)
    if _instSkill ~= nil then
        _instSkill:EndCD()
    end
end

function PlayerSkillSystem:OnUsedSkill(skillId)
    for _, v in pairs(self.SkillCell) do
        v:OnUseSkill(skillId)
    end
    if self.FlySwordSkill ~= nil and skillId == self.FlySwordSkill.CfgID then
        -- Trigger the use of the flying sword skill
        local _lf = GameCenter.GameSceneSystem:GetLocalFlySword()
        if _lf ~= nil then
            _lf:UseSkill()
        end
    end
end


-- Whether the passive skill has been activated
function PlayerSkillSystem:IsPassSkillActived(id)
    return self.ActivePassSkills:Contains(id)
end

-- Set transformation skills
function PlayerSkillSystem:SetChangeModelSkill(skills)
    self.ChangeSkillList:Clear()
    for i = 1, #skills do
        local _skillCfg = DataConfig.DataSkill[skills[i]]
        if _skillCfg ~= nil then
            self.ChangeSkillList:Add(L_PlayerSkill:New(_skillCfg, true))
        end
    end
end

-- Clear transformation skills
function PlayerSkillSystem:ClearChangeModelSkill()
    self.ChangeSkillList:Clear()
end


-- Set up flying sword skills
function PlayerSkillSystem:SetFlySwordSkill(flySwordSkill, playerSkill)
    local _oldSkillCD = 0
    if self.FlySwordSkill ~= nil then
        _oldSkillCD = self.FlySwordSkill.CurCD
    end

    self.FlySwordSkill = nil
    if flySwordSkill == nil or playerSkill == nil then
        return
    end
    self.FlySwordSkill = L_PlayerSkill:NewSwordSkill(flySwordSkill, playerSkill, _oldSkillCD)
    -- Reset the flying sword skill and start hanging up again
    GameCenter.MandateSystem:ReStart()
end

-- Set skill position data
function PlayerSkillSystem:SetSkillPos(posId, skillOder)
    if posId >= 0 and posId < MAX_POS_COUNT then
        -- Switch location
        local _oldPos = -1
        for i = 0, MAX_POS_COUNT - 1 do
            if self.SkillPoss[i] == skillOder then
                _oldPos = i
                break
            end
        end
        if _oldPos >= 0 then
            local _tmpOder = self.SkillPoss[posId]
            self.SkillPoss[posId] = skillOder
            self.SkillPoss[_oldPos] = _tmpOder
        else
            self.SkillPoss[posId] = skillOder
        end
        self:SavePosData()
        self:CheckRedPoint()
        -- Start hanging up again
        GameCenter.MandateSystem:ReStart()
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_SKILL_LIST_CHANGED)
    end
end

-- Is the skill already assembled
function PlayerSkillSystem:SkillIsEquip(oderValue)
    for i = 0, MAX_POS_COUNT - 1 do
        if self.SkillPoss[i] == oderValue then
            return true
        end
    end
    return false
end

-- Obtain a total talent level of a certain type
function PlayerSkillSystem:GetMeridianTypeLevel(type)
    local _allLevel = 0
    for k, v in pairs(self.MeridianDic) do
        local _typeId = math.floor(v % 1000000 / 10000)
        if _typeId == type then
            _allLevel = _allLevel + math.floor(v % 100)
        end
    end
    return _allLevel
end

-- Get the activation id of a talent
function PlayerSkillSystem:GetMeridianActvieID(id)
    local _result = self.MeridianDic[id]
    if _result == nil then
        _result = 0
    end
    return _result
end

-- Whether the skills are automatically released
function PlayerSkillSystem:IsAutoUse(posId)
    if posId >= 0 and posId < MAX_POS_COUNT then
        return self.SkillUseState[posId]
    end
    return false
end

-- Set whether the skill is automatically released
function PlayerSkillSystem:SetAutoUse(posId, value)
    if posId >= 0 and posId < MAX_POS_COUNT then
        self.SkillUseState[posId] = value
    end
end

-- Online data
function PlayerSkillSystem:ResSkillOnline(result)
    self.SkillCell:Clear()
    -- Current mental id
    self.CurSelectMerId = result.selectMentalType
    self.CurResetMerCount = result.resetMentalTimes
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().Occ
    for i = 1, #result.skillIds do
        local _cfg = DataConfig.DataSkillStarLevelup[result.skillIds[i]]
        if _cfg ~= nil then
            local _cellId = math.floor(_cfg.Id % 1000000 / 1000)
            local _skillList = nil
            if _cellId == 0 then
                -- General attack special treatment
                local _occDic = self.NormalSkillCfg[_occ]
                if _occDic ~= nil then
                    _skillList = _occDic[self.CurSelectMerId]
                end
            end
            self.SkillCell:Add(_cellId, L_PlayerSkillCell:New(_cfg, _skillList))
        end
    end
    self.CellLevel = result.cellLevel
    if self.CellLevel == nil then
        self.CellLevel = 1
    end
    self.MeridianDic:Clear()
    self.MeridianCount = 0
    if result.skillMeridianList ~= nil then
        for i = 1, #result.skillMeridianList do
            local _id = result.skillMeridianList[i]
            local _meId = math.floor(_id % 10000 / 100)
            self.MeridianDic:Add(_meId, _id)
            self.MeridianCount = self.MeridianCount + 1
        end
    end
    -- Initialize location data
    self:ParsePosData(result.playedSkillStr)
    self:FillSkillList()
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_SKILL_LIST_CHANGED)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_ONLINE)
end

-- Upgrade grid
function PlayerSkillSystem:ResUpCell(result)
    self.CellLevel = result.level
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPCELL)
end

-- Skills Upgrade
function PlayerSkillSystem:ResUpSkillStar(result)
    local _cfg = DataConfig.DataSkillStarLevelup[result.newSkillID]
    if _cfg == nil then
        return
    end
    local _cellId = math.floor(_cfg.Id % 1000000 / 1000)
    local _skillCell = L_PlayerSkillCell:New(_cfg)
    self.SkillCell[_cellId] = _skillCell

    local _emptyIndex = nil
    for i = 0, MAX_POS_COUNT - 1 do
        if self.SkillPoss[i] == -1 and _emptyIndex == nil then
            _emptyIndex = i
        end
        if self.SkillPoss[i] == _cellId then
            _emptyIndex = nil
            break
        end
    end
    if _emptyIndex ~= nil then
        -- New skills are automatically placed in empty spaces
        self.SkillPoss[_emptyIndex] = _cellId
        self:SavePosData()
    end
    self:FillSkillList()
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_SKILL_LIST_CHANGED)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPSTAR)

    -- Skills gain effects
    for i = 1, _skillCell.SkillCount do
        GameCenter.BlockingUpPromptSystem:AddNewFunction(PromptNewFunctionType.Skill, _skillCell.SkillList[i].CfgID)
    end
end

-- Passive skills list
function PlayerSkillSystem:ResPassiveSkill(result)
    self.ActivePassSkills:Clear()
    if result.skillID ~= nil then
        for i = 1, #result.skillID do
            self.ActivePassSkills:Add(result.skillID[i])
        end
    end
end

-- Update passive skills
function PlayerSkillSystem:ResUpdateSkill(result)
    if result.type == 0 then
        -- Increase
        if not self.ActivePassSkills:Contains(result.skillID) then
            self.ActivePassSkills:Add(result.skillID)
            GameCenter.BlockingUpPromptSystem:AddNewFunction(PromptNewFunctionType.Skill, result.skillID)
        end
    elseif result.type == 1 then
        -- delete
        self.ActivePassSkills:Remove(result.skillID)
    end
end

-- Meridian update
function PlayerSkillSystem:ResActivateMeridian(result)
    local _id = result.meridianID
    local _meId = math.floor(_id % 10000 / 100)
    self.MeridianDic[_meId] = _id
    self.MeridianCount = self.MeridianDic:Count()
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPMERIDIAN)
end

-- Select the mind method to return
function PlayerSkillSystem:ResSelectMentalType(result)
    self.CurSelectMerId = result.mentalType
    self.CurResetMerCount = result.resetMentalTimes
    local _occ = GameCenter.GameSceneSystem:GetLocalPlayer().Occ
    if self.CurSelectMerId == 0 then
        if self.MeridianAddSkillDic == nil then
            -- Initialize the corresponding skills of meridians
            self.MeridianAddSkillDic = GameCenter.PlayerSkillLuaSystem:GetAddSkillTable()
        end
        local _savePos = false
        for k, v in pairs(self.MeridianDic) do
            local _skillId = self.MeridianAddSkillDic[v]
            if _skillId ~= nil then
                local _cellId = math.floor(_skillId % 1000000 / 1000)
                -- Remove skills
                self.SkillCell:Remove(_cellId)
                for i = 0, MAX_POS_COUNT - 1 do
                    if self.SkillPoss[i] == _cellId then
                        _savePos = true
                        self.SkillPoss[i] = -1
                        break
                    end
                end
            end
        end
        self.MeridianDic:Clear()
        self.MeridianCount = self.MeridianDic:Count()
        if _savePos then
            self:SavePosData()
        end
    end
    -- Re-select general attack
    local _occDic = self.NormalSkillCfg[_occ]
    local _skillList = nil
    if _occDic ~= nil then
        _skillList = _occDic[self.CurSelectMerId]
    end
    local _cfg = self.SkillCell[0].Cfg
    self.SkillCell[0] = L_PlayerSkillCell:New(_cfg, _skillList)
    self:FillSkillList()
    self:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_SKILL_LIST_CHANGED)
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_SKILL_UPMERIDIAN)
    -- The mind method changes the message
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_PLAYER_XINFA_CHANGED)
    -- Start hanging up again
    GameCenter.MandateSystem:ReStart()

    if self.CurSelectMerId == 0 then
        -- Reset meridians
        GameCenter.PushFixEvent(UIEventDefine.UIOccSkillForm_Close)
    else
        -- Close the choice of mind
        GameCenter.PushFixEvent(UILuaEventDefine.UISelectXinFaForm_CLOSE)
        -- Open the meridian interface
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.PlayerSkillMeridian)
    end
end

-- Analyze skill position data
function PlayerSkillSystem:ParsePosData(posText)
    self.IsInitSkillPos = true
    local _setNormal = true
    if posText ~= nil and string.len(posText) > 0 and GameCenter.MainFunctionSystem:FunctionIsEnabled(FunctionStartIdCode.PlayerSkillPos) then
        local _pramsArray = Utils.SplitStrByTableS(posText, {';', '_'})
        if #_pramsArray >= 2 then
            local _posParams = _pramsArray[1]
            if #_posParams >= MAX_POS_COUNT then
                for i = 1, MAX_POS_COUNT do
                    local _cellId = _posParams[i]
                    self.SkillPoss[i - 1] = _cellId
                end
            end
            local _useParams = _pramsArray[2]
            if #_useParams >= MAX_POS_COUNT then
                for i = 1, MAX_POS_COUNT do
                    local _state = _useParams[i]
                    if _state == 0 then
                        self.SkillUseState[i - 1] = false
                    else
                        self.SkillUseState[i - 1] = true
                    end
                end
            end
            if #_useParams >= MAX_POS_COUNT + 1 then
                local _state = _useParams[MAX_POS_COUNT + 1]
                if _state == 0 then
                    self.SkillSwordUseState = false
                else
                    self.SkillSwordUseState = true
                end
            end
            _setNormal = false
        end
    end

    if _setNormal then
        -- Set as default value
        for i = 0, MAX_POS_COUNT - 1 do
            if i <= 4 then
                self.SkillPoss[i] = i
            else
                self.SkillPoss[i] = -1
            end
            self.SkillUseState[i] = true
        end
        self.SkillSwordUseState = false
        self:SavePosData()
    end
end

-- Save skill position data
function PlayerSkillSystem:SavePosData()
    if not self.IsInitSkillPos then
        return
    end
    local _posText = ""
    for i = 0, MAX_POS_COUNT - 1 do
        if i < MAX_POS_COUNT - 1 then
            _posText = _posText .. string.format("%d_", self.SkillPoss[i])
        else
            _posText = _posText .. string.format("%d", self.SkillPoss[i])
        end
    end
    _posText = _posText .. ';'
    for i = 0, MAX_POS_COUNT - 1 do
        local _value = 0
        if self.SkillUseState[i] then
            _value = 1
        end
        _posText = _posText .. string.format("%d_", _value)
    end
    if self.SkillSwordUseState then
        _posText = _posText .. '1'
    else
        _posText = _posText .. '0'
    end
    GameCenter.Network.Send("MSG_Skill.ReqSaveFightSkill", {playedSkillStr = _posText})
end
-- Fill in the skill list
function PlayerSkillSystem:FillSkillList()
    local _starVisible = false
    self.SkillList:Clear()
    for k, v in pairs(self.SkillCell) do
        v:FillSkillList(self.SkillList)
        if k ~= 0 then
            _starVisible = true
        end
    end
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PlayerSkillStar, _starVisible)
end

-- Detect red dots
function PlayerSkillSystem:CheckRedPoint()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_CHECK_SKILL_REDPOINT)
end

return PlayerSkillSystem