------------------------------------------------
-- Author:
-- Date: 2021-03-09
-- File: LuaCharacterSystem.lua
-- Module: LuaCharacterSystem
-- Description: lua role system
------------------------------------------------
local L_HunJia = require "Logic.LuaCharacter.HunJia.HunJia"
local L_FaBao = require "Logic.LuaCharacter.FaBao.FaBao"
local L_TaskTransNPC = require "Logic.LuaCharacter.FaBao.TaskTransNPC"
local L_TaskTransEquipPlayer = require "Logic.LuaCharacter.FaBao.TaskTransEquipPlayer"
local L_JiaJu = require("Logic.LuaCharacter.JiaJu.JiaJu")
local L_Wall = require("Logic.LuaCharacter.JiaJu.Wall")
local L_LuaCharInitInfo = CS.Thousandto.Code.Logic.LuaCharInitInfo

local LuaCharacterSystem = {
    CharList = nil,
    FirstEnterScene = true,

    -- The protagonist's soul armor information, reload when switching the map
    LocalHunJia = {
        MasterId = 0,
        CfgId = 0,
        CheckFrameCount = 0,
    },

    -- The protagonist's magic weapon information
    LocalFaBao = {
        MasterId = 0,
        MasterOcc = 0,
        Guid = 0,
        CfgId = 0,
        Spr1Id = 0,
        Spr2Id = 0,
        Spr3Id = 0,
        CheckFrameCount = 0,
    },

    -- NPC task type Hộ tống
    LocalTaskTransNPC = {
        MasterId = 0,
        MasterOcc = 0,
        TaskModelId = "",
        Guid = 0,
        CfgType = 0,
        CfgId = 0,
        CheckFrameCount = 0,
    },

    -- Player Model Animation
    LocalTaskTransEquipPlayer = {
        MasterId = 0,
        MasterOcc = 0,
        TaskModelId = "",
        Guid = 0,
        CfgId = 0,
        SlotNum = 0,
        CheckFrameCount = 0,
    }
}

function LuaCharacterSystem:Initialize()
    self.CharList = List:New()
end

function LuaCharacterSystem:UnInitialize()
    self.CharList = nil
end

function LuaCharacterSystem:BindLuaCharacter(character, initInfo)
    local _char = self:CreateScript(character, initInfo)
    if _char ~= nil then
        self.CharList:Add(_char)
    end
end

function LuaCharacterSystem:Update(dt)
    if self.LocalHunJia.CheckFrameCount > 0 then
        -- Refresh the protagonist's soul armor
        self.LocalHunJia.CheckFrameCount = self.LocalHunJia.CheckFrameCount - 1
        if self.LocalHunJia.CheckFrameCount <= 0 then
            self:RefreshHunJia(self.LocalHunJia.CfgId, self.LocalHunJia.MasterId, true)
        end
    end
    if self.LocalFaBao.CheckFrameCount > 0 then
        -- Refresh the protagonist's magic weapon
        self.LocalFaBao.CheckFrameCount = self.LocalFaBao.CheckFrameCount - 1
        if self.LocalFaBao.CheckFrameCount <= 0 then
            local _info = self.LocalFaBao
            self:RefreshFaBao(_info.MasterId, _info.MasterOcc, _info.Guid, _info.CfgId, _info.Spr1Id, _info.Spr2Id, _info.Spr3Id, true)
        end
    end
    if self.LocalTaskTransNPC.CheckFrameCount > 0 then
        -- Refresh the protagonist's task follow NPC
        self.LocalTaskTransNPC.CheckFrameCount = self.LocalTaskTransNPC.CheckFrameCount - 1
        if self.LocalTaskTransNPC.CheckFrameCount <= 0 then
            local _info = self.LocalTaskTransNPC
            self:RefreshTaskTransNPC(_info.MasterId, _info.MasterOcc, _info.Guid, _info.taskModelId, true)
        end
    end
    if self.LocalTaskTransEquipPlayer.CheckFrameCount > 0 then
        -- Refresh the protagonist's task equip player model
        self.LocalTaskTransEquipPlayer.CheckFrameCount = self.LocalTaskTransEquipPlayer.CheckFrameCount - 1
        if self.LocalTaskTransEquipPlayer.CheckFrameCount <= 0 then
            local _info = self.LocalTaskTransEquipPlayer    
            self:RefreshTaskTransEquipPlayer(_info.MasterId, _info.MasterOcc, _info.Guid, _info.taskModelId, true)
        end
    end

    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.IsDeleted then
            self.CharList:RemoveAt(i)
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        else
            _char:Update(dt)
        end
    end
end

function LuaCharacterSystem:CreateScript(character, initInfo)
    local _charType = initInfo.UserData.CharType
    if _charType == LuaCharacterType.HunJia then
        return L_HunJia:New(character, initInfo)
    elseif _charType == LuaCharacterType.FaBao then
        return L_FaBao:New(character, initInfo)
    elseif _charType == LuaCharacterType.JiaJu then
        return L_JiaJu:New(character, initInfo)
    elseif _charType == LuaCharacterType.Wall then
        return L_Wall:New(character, initInfo)
    elseif _charType == LuaCharacterType.TaskTransNPC then
        return L_TaskTransNPC:New(character, initInfo)
    elseif _charType == LuaCharacterType.TaskTransEquipPlayer then
        return L_TaskTransEquipPlayer:New(character, initInfo)
    end
    return nil
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LuaCharacterSystem:OnEnterScene()
    if not self.FirstEnterScene then
        -- Detect the protagonist's soul armor after 5 frames
        if self.LocalHunJia.MasterId > 0 and self.LocalHunJia.CfgId > 0 then
            self.LocalHunJia.CheckFrameCount = 5
        end
        -- Detect the protagonist's magic weapon after 5 frames
        if self.LocalFaBao.MasterId > 0 and self.LocalFaBao.Guid > 0 and self.LocalFaBao.CfgId > 0 then
            self.LocalFaBao.CheckFrameCount = 5
        end
        -- Detect the protagonist's task follow NPC after 5 frames
        if self.LocalTaskTransNPC.MasterId > 0 and self.LocalTaskTransNPC.Guid > 0 and self.LocalTaskTransNPC.CfgId > 0 then
            self.LocalTaskTransNPC.CheckFrameCount = 5
        end
        -- Detect the protagonist's task equip player model after 5 frames
        if self.LocalTaskTransEquipPlayer.MasterId > 0 and self.LocalTaskTransEquipPlayer.Guid > 0 and self.LocalTaskTransEquipPlayer.CfgId > 0 then
            self.LocalTaskTransEquipPlayer.CheckFrameCount = 5
        end
    end
    self.FirstEnterScene = false
end

function LuaCharacterSystem:OnLeaveScene()
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Refresh the soul armor
function LuaCharacterSystem:RefreshHunJia(hunjiaId, masterId, isLocal)
    if GameCenter.MapLogicSwitch.HideFaBao then
        return
    end
    hunjiaId = hunjiaId or 0
    masterId = masterId or 0
    -- Find the old soul armor
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.HunJia and _char.MasterID == masterId then
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    -- Initial Soul Armor
    local _cfg = DataConfig.DataSoulArmorBreach[hunjiaId]
    if  _cfg ~= nil then
        local _guid = LogicAdaptor.GenGUID()
        local _initData = {}
        _initData.CharType = LuaCharacterType.HunJia
        _initData.Cfg = _cfg
        _initData.MasterId = masterId
        _initData.IsLocal = isLocal
        local _initInfo = L_LuaCharInitInfo(_guid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
        if isLocal then
            self.LocalHunJia.MasterId = masterId
            self.LocalHunJia.CfgId = hunjiaId
        end
    else
        if isLocal then
            self.LocalHunJia.MasterId = 0
            self.LocalHunJia.CfgId = 0
        end
    end
end
-- Refresh the magic weapon
function LuaCharacterSystem:RefreshFaBao(masterId, masterOcc, uid, cfgid, spr1Id, spr2Id, spr3Id, islocal)
    if GameCenter.MapLogicSwitch.HideFaBao then
        return
    end
    masterId = masterId or 0
    masterOcc = masterOcc or 0
    uid = uid or 0
    cfgid = cfgid or 0
    spr1Id = spr1Id or 0
    spr2Id = spr2Id or 0
    spr3Id = spr3Id or 0
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.FaBao and _char.MasterID == masterId then
            -- Delete old magic treasures
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    local _cfg = DataConfig.DataHuaxingfabao[cfgid]
    if masterId > 0 and uid > 0 and _cfg ~= nil then
        if islocal then
            self.LocalFaBao.MasterId = masterId
            self.LocalFaBao.MasterOcc = masterOcc
            self.LocalFaBao.Guid = uid
            self.LocalFaBao.CfgId = cfgid
            self.LocalFaBao.Spr1Id = spr1Id
            self.LocalFaBao.Spr2Id = spr2Id
            self.LocalFaBao.Spr3Id = spr3Id
        end
        local _initData = {}
        _initData.CharType = LuaCharacterType.FaBao
        _initData.Cfg = _cfg
        _initData.IsLocal = islocal
        _initData.MasterId = masterId
        _initData.Spr1Cfg = DataConfig.DataStateStifleAdd[spr1Id]
        _initData.Spr2Cfg = DataConfig.DataStateStifleAdd[spr2Id]
        _initData.Spr3Cfg = DataConfig.DataStateStifleAdd[spr3Id]
        if masterOcc == 0 then
            _initData.FollowHeight = 1.5
        else
            _initData.FollowHeight = 1.2
        end

        -- Task Hộ tống
        if _cfg.Type == 3 then
            _initData.FollowHeight = 0    
        end

        local _initInfo = L_LuaCharInitInfo(uid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
    else
        if islocal then
            self.LocalFaBao.MasterId = 0
            self.LocalFaBao.Guid = 0
            self.LocalFaBao.CfgId = 0
            self.LocalFaBao.Spr1Id = 0
            self.LocalFaBao.Spr2Id = 0
            self.LocalFaBao.Spr3Id = 0
        end
    end
end

function LuaCharacterSystem:RefreshTaskTransNPC(masterId, masterOcc, uid, taskModelId, islocal)
    masterId = masterId or 0
    masterOcc = masterOcc or 0
    uid = uid or LogicAdaptor.GenGUID()
    local task_model_id_list = Utils.SplitNumber(taskModelId, '_') or {}
    local cfg_type = tonumber(task_model_id_list[1]) or 0
    local cfgid = tonumber(task_model_id_list[2]) or 0
    -- Debug.LogTable({ masterId = masterId, masterOcc = masterOcc, uid = uid, cfgid = cfgid, islocal = islocal }, "LuaCharacterSystem:RefreshTaskTransNPC")

    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.TaskTransNPC and _char.MasterID == masterId then
            -- Delete old magic treasures
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    
    local _model_cfg = ""
    if cfg_type == 1 then
        _model_cfg = DataConfig.DataNpc[cfgid]
    elseif cfg_type == 2 then
        _model_cfg = DataConfig.DataMonster[cfgid]
    end
    if masterId > 0 and uid > 0 and _model_cfg ~= nil then
        if islocal then
            self.LocalTaskTransNPC.MasterId = masterId
            self.LocalTaskTransNPC.MasterOcc = masterOcc
            self.LocalTaskTransNPC.TaskModelId = taskModelId
            self.LocalTaskTransNPC.Guid = uid
            self.LocalTaskTransNPC.CfgType = cfg_type
            self.LocalTaskTransNPC.CfgId = cfgid
        end
        
        local _initData = {}
        _initData.CharType = LuaCharacterType.TaskTransNPC
        _initData.CfgType = cfg_type
        _initData.Cfg = _model_cfg
        _initData.IsLocal = islocal
        _initData.MasterId = masterId
        _initData.FollowHeight = 0    

        local _initInfo = L_LuaCharInitInfo(uid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
    else
        if islocal then
            self.LocalTaskTransNPC.MasterId = 0
            self.LocalTaskTransNPC.TaskModelId = ""
            self.LocalTaskTransNPC.Guid = 0
            self.LocalTaskTransNPC.CfgType = 0
            self.LocalTaskTransNPC.CfgId = 0
        end
    end
end

function LuaCharacterSystem:ClearTaskTransNPC(masterId)
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.TaskTransNPC and _char.MasterID == masterId then
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    self.LocalTaskTransNPC.MasterId = 0
    self.LocalTaskTransNPC.Guid = 0
    self.LocalTaskTransNPC.CfgId = 0
    self:ReqTaskTransNPC("")
end

function LuaCharacterSystem:RefreshTaskTransEquipPlayer(masterId, masterOcc, uid, taskModelId, islocal)
    masterId = masterId or 0
    masterOcc = masterOcc or 0
    uid = uid or LogicAdaptor.GenGUID()
    local task_model_id_list = Utils.SplitNumber(taskModelId, '_') or {}
    local cfgid = task_model_id_list[2] or 0
    local slot_num = task_model_id_list[3] or 0
    -- Debug.LogTable({ masterId = masterId, masterOcc = masterOcc, uid = uid, cfgid = cfgid, islocal = islocal }, "LuaCharacterSystem:RefreshTaskTransEquipPlayer")

    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.TaskTransEquipPlayer and _char.MasterID == masterId then
            -- Delete old magic treasures
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    
    -- local _cfg = DataConfig.DataHuaxingfabao[cfgid]
    local _modelCfg = DataConfig.DataModelConfig[cfgid]
    if masterId > 0 and uid > 0 and _modelCfg ~= nil then
        -- Debug.LogTable({ Id = _modelCfg.Id, Model = _modelCfg.Model, }, "LuaCharacterSystem:RefreshTaskTransEquipPlayer _modelCfg")
        if islocal then
            self.LocalTaskTransEquipPlayer.MasterId = masterId
            self.LocalTaskTransEquipPlayer.MasterOcc = masterOcc
            self.LocalTaskTransEquipPlayer.TaskModelId = taskModelId
            self.LocalTaskTransEquipPlayer.Guid = uid
            self.LocalTaskTransEquipPlayer.CfgId = tonumber(cfgid)
            self.LocalTaskTransEquipPlayer.SlotNum = tonumber(slot_num)
        end
        
        local _initData = {}
        _initData.CharType = LuaCharacterType.TaskTransEquipPlayer
        _initData.Cfg = _modelCfg
        _initData.IsLocal = islocal
        _initData.MasterId = masterId
        _initData.FollowHeight = 0
        _initData.SlotNum = slot_num

        local _initInfo = L_LuaCharInitInfo(uid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
    else
        if islocal then
            self.LocalTaskTransEquipPlayer.MasterId = 0
            self.LocalTaskTransEquipPlayer.TaskModelId = ""
            self.LocalTaskTransEquipPlayer.Guid = 0
            self.LocalTaskTransEquipPlayer.CfgId = 0
            self.LocalTaskTransEquipPlayer.SlotNum = 0
        end
    end
end

function LuaCharacterSystem:ClearTaskTransEquipPlayer(masterId)
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CharType == LuaCharacterType.TaskTransEquipPlayer and _char.MasterID == masterId then
            GameCenter.GameSceneSystem:RemoveRemoteEntity(_char.CSChar.ID)
        end
    end
    self.LocalTaskTransEquipPlayer.MasterId = 0
    self.LocalTaskTransEquipPlayer.Guid = 0
    self.LocalTaskTransEquipPlayer.CfgId = 0
    self:ReqTaskTransEquipPlayer("")
end

-- Refresh the wall
function LuaCharacterSystem:RefreshWall(hunjiaId, id, cfg, lv)
    hunjiaId = hunjiaId or 0
    id = id or LogicAdaptor.GenGUID()
    -- initialization
    local _cfg = cfg == nil and DataConfig.DataSocialHouseFurniture[hunjiaId] or cfg
    if  _cfg ~= nil then
        local _guid = id
        local _initData = {}
        _initData.CharType = LuaCharacterType.Wall
        _initData.MasterId = hunjiaId
        _initData.Cfg = _cfg
        _initData.HouseLv = lv == nil and 1 or lv
        local _initInfo = L_LuaCharInitInfo(_guid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
    end
    return id
end

-- Refresh furniture
function LuaCharacterSystem:RefreshJiaJu(hunjiaId, info, cfg, isNew, lv)
    hunjiaId = hunjiaId or 0
    local _cfg = cfg == nil and DataConfig.DataSocialHouseFurniture[hunjiaId] or cfg
    if  _cfg ~= nil and info then
        local _guid = info.id or LogicAdaptor.GenGUID()
        local _initData = {}
        _initData.CharType = LuaCharacterType.JiaJu
        _initData.MasterId = hunjiaId
        _initData.Cfg = _cfg
        _initData.IsNew = isNew or false
        _initData.HouseLv = lv == nil and 1 or lv
        _initData.Row = info.pos == nil and 0 or info.pos.x
        _initData.Col = info.pos == nil and 0 or info.pos.z
        _initData.Dir = info.dir == nil and 1 or info.dir
        local _initInfo = L_LuaCharInitInfo(_guid, 0, 0, _initData)
        GameCenter.GameSceneSystem:RefreshLuaCharacter(_initInfo)
        return _guid
    end
end

function LuaCharacterSystem:ClearJiaJuByType(type)
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.Cfg and _char.Cfg.Type == type then
            local _ownInfo = GameCenter.MapLogicSystem.ActiveLogic.OwnerInfo
            local _msg = ReqMsg.MSG_Home.ReqHomeDecorate:New()
            _msg.type = 0
            if _ownInfo then
                _msg.targetId = _ownInfo.id
            end
            _msg.id = _char.CSChar.ID
            _msg.modelId = _char.CSChar.MasterID
            _msg:Send()
        end
    end
end

function LuaCharacterSystem:FindCharacter(id)
    local _count = #self.CharList
    for i = _count, 1, -1 do
        local _char = self.CharList[i]
        if _char.CSChar.ID == id then
            return _char
        end
    end
    return nil
end

function LuaCharacterSystem:ResPlayerBaseInfo(msg)
    self:RefreshHunJia(msg.facade.soulArmorId, msg.roleID, true)
    self:RefreshFaBao(msg.roleID, msg.occupation, msg.fabaoUid, msg.fabaoId, msg.soulSpirte1, msg.soulSpirte2, msg.soulSpirte3, true)

    local taskList = msg.taskList or {}
    if #taskList > 0 then
        local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
        for j = 1, #taskList do
            local _task = taskList[j]
            if _task.taskType == NatureTaskEnum.TaskFollow then
                -- RefreshTaskTransNPC(masterId, masterOcc, uid, cfgid, islocal)
                self:RefreshTaskTransNPC(msg.roleID, msg.occupation, _task.taskUid, _task.taskModelId, _lpId == msg.roleID)
            elseif _task.taskType == NatureTaskEnum.TaskEquip then
                -- RefreshTaskTransEquipPlayer(masterId, masterOcc, uid, cfgid, islocal)
                self:RefreshTaskTransEquipPlayer(msg.roleID, msg.occupation, _task.taskUid, _task.taskModelId, _lpId == msg.roleID)
            else
                -- Debug.LogWarning("LuaCharacterSystem:ResPlayerBaseInfo unknown task type:" .. tostring(_task.taskType))
            end 
        end
    end
end
function LuaCharacterSystem:ResRoundObjs(msg)
    if msg.players ~= nil then
        for i = 1, #msg.players do
            local _player = msg.players[i]
            self:RefreshHunJia(_player.facade.soulArmorId, _player.playerId, false)
            self:RefreshFaBao(_player.playerId, _player.career, _player.fabaoUid, _player.fabaoId, _player.soulSpirte1, _player.soulSpirte2, _player.soulSpirte3, false)
            
            local taskList = _player.taskList or {}
            if #taskList > 0 then
                -- local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
                for j = 1, #taskList do
                    local _task = taskList[j]
                    if _task.taskType == NatureTaskEnum.TaskFollow then
                        -- RefreshTaskTransNPC(masterId, masterOcc, uid, cfgid, islocal)
                        self:RefreshTaskTransNPC(_player.playerId, _player.career, _task.taskUid, _task.taskModelId, false)
                    elseif _task.taskType == NatureTaskEnum.TaskEquip then
                        -- RefreshTaskTransEquipPlayer(masterId, masterOcc, uid, cfgid, islocal)
                        self:RefreshTaskTransEquipPlayer(_player.playerId, _player.career, _task.taskUid, _task.taskModelId, false)
                    else
                        -- Debug.LogWarning("LuaCharacterSystem:ResRoundObjs unknown task type:" .. tostring(_task.taskType))
                    end
                end
            end
        end
    end
end
function LuaCharacterSystem:ResMapPlayer(msg)
    self:RefreshHunJia(msg.player.facade.soulArmorId, msg.player.playerId, false)
    self:RefreshFaBao(msg.player.playerId, msg.player.career, msg.player.fabaoUid, msg.player.fabaoId, msg.player.soulSpirte1, msg.player.soulSpirte2, msg.player.soulSpirte3, false)

    local taskList = msg.player.taskList or {}
    if #taskList > 0 then
        -- local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
        for j = 1, #taskList do
            local _task = taskList[j]
            if _task.taskType == NatureTaskEnum.TaskFollow then
                -- RefreshTaskTransNPC(masterId, masterOcc, uid, cfgid, islocal)
                self:RefreshTaskTransNPC(msg.player.playerId, msg.player.career, _task.taskUid, _task.taskModelId, false)
            elseif _task.taskType == NatureTaskEnum.TaskEquip then
                -- RefreshTaskTransEquipPlayer(masterId, masterOcc, uid, cfgid, islocal)
                self:RefreshTaskTransEquipPlayer(msg.player.playerId, msg.player.career, _task.taskUid, _task.taskModelId, false)
            else
                -- Debug.LogWarning("LuaCharacterSystem:ResMapPlayer unknown task type:" .. tostring(_task.taskType))
            end 
        end
    end
end
-- Soul Armor Refresh
function LuaCharacterSystem:ResSoulEquipChange(msg)
    local _master = GameCenter.GameSceneSystem:FindPlayer(msg.playerId)
    if _master ~= nil then
        local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
        self:RefreshHunJia(msg.soulArmorId, msg.playerId, _lpId == msg.playerId)
    end
end
-- Magic weapon refresh
function LuaCharacterSystem:ResFabaoInfoBroadCast(msg)
    local _master = GameCenter.GameSceneSystem:FindPlayer(msg.playerId)
    if _master ~= nil then
        local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
        -- RefreshFaBao(masterId, masterOcc, uid, cfgid, spr1Id, spr2Id, spr3Id, islocal)
        self:RefreshFaBao(msg.playerId, _master.IntOcc, msg.id, msg.cfgId, msg.soulSpirte1, msg.soulSpirte2, msg.soulSpirte3, msg.playerId == _lpId)
    end
end

function LuaCharacterSystem:ResTaskInfoBroadCast(msg)
    local _master = GameCenter.GameSceneSystem:FindPlayer(msg.playerId)
    if _master ~= nil then
        local _lpId = GameCenter.GameSceneSystem:GetLocalPlayerID()
        
        if msg.typeId == NatureTaskEnum.TaskFollow then
            -- RefreshTaskTransNPC(masterId, masterOcc, uid, cfgid, islocal)
            self:RefreshTaskTransNPC(msg.playerId, _master.IntOcc, msg.id, msg.taskModelId, msg.playerId == _lpId)
        end
        
        if msg.typeId == NatureTaskEnum.TaskEquip then
            -- RefreshTaskTransEquipPlayer(masterId, masterOcc, uid, cfgid, islocal)
            self:RefreshTaskTransEquipPlayer(msg.playerId, _master.IntOcc, msg.id, msg.taskModelId, msg.playerId == _lpId)
        end
    end
end

-- Refresh NPC to follow player
-- L_TaskTransNPC
function LuaCharacterSystem:ReqTaskTransNPC(taskModelId)
    local type = NatureTaskEnum.TaskFollow
    local task_model_id = taskModelId or ""
    GameCenter.NatureSystem:ReqNatureTaskModelSet(type,task_model_id)
end

-- Refresh player model animation
-- L_TaskTransEquipPlayer
function LuaCharacterSystem:ReqTaskTransEquipPlayer(taskModelId)
    local type = NatureTaskEnum.TaskEquip
    local task_model_id = taskModelId or ""
    GameCenter.NatureSystem:ReqNatureTaskModelSet(type,task_model_id)
end

return LuaCharacterSystem