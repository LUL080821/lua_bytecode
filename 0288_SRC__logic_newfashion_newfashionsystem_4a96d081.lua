
------------------------------------------------
-- Author:
-- Date: 2020-03-23
-- File: NewFashionSystem.lua
-- Module: NewFashionSystem
-- Description: New fashion system category
------------------------------------------------
-- Quote
-- Image data
local L_TuJianData = require "Logic.NewFashion.FashionTuJianData"
local L_FashionData = require "Logic.NewFashion.FashionData"
local L_ListTuJianData = List:New()
local L_ListFashionData = List:New()
local L_DicFashionData = Dictionary:New()
-- CUSTOM - Dic Data Dogiam
local L_DicFashionDogiamData = Dictionary:New()
-- CUSTOM - Dic Data Dogiam
local L_DicTotalFashionData = Dictionary:New()
local L_RedPointItemCondition = CS.Thousandto.Code.Logic.RedPointItemCondition
local NewFashionSystem = {    
    DefaultList = List:New(),
    IsShowActive = false,
    -- Player wear fashion dictionary
    WearDic = Dictionary:New(),
}

function NewFashionSystem:Initialize()
end

function NewFashionSystem:UnInitialize()
    -- L_ListTuJianData:Clear()
    -- L_ListFashionData:Clear()
end

-- Update the player wear list
function NewFashionSystem:UpdateWearList(wearList)
    if wearList == nil then
        return
    end
    -- Updated fashion wear
    self:UpdateWearFashion(wearList)
    -- Update the wardrobe wear
    self:UpdateTotalWear(wearList)
end

-- Add to wearable dictionary
function NewFashionSystem:SetWearData(data, type)
    self.WearDic[type] = data
end

-- Change the fashion or not
function NewFashionSystem:IsWear(data)
    if data == nil then
        return false
    end
    local type = data:GetType()
    local wearData = self.WearDic[type]
    return data:GetCfgId() == wearData:GetCfgId()
end

-- Fashion activation red dot update
function NewFashionSystem:UpdateFashionRedPoint()
    GameCenter.RedPointSystem:CleraFuncCondition(FunctionStartIdCode.Fashion)
    local dic = self:GetFashionDataDic()
    if dic == nil then
        return
    end
    local keys = dic:GetKeys()
    if keys == nil then
        return
    end
    local isShow = false
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    for i = 1, #keys do
        local dataList = dic[keys[i]]
        if dataList ~= nil then
            for m = 1, #dataList do
                local data = dataList[m]
                local itemId = data:GetItemId(occ)
                if data.IsActive then
                    -- If the fashion is activated, determine whether it can be upgraded
                    -- if not isShow then
                    --     isShow = data:CanUpStar(occ)
                    -- end
                    -- if data.StarNum < 5 then
                    --     local itemId = data:GetItemId(occ)
                    --     local needNum = data:GetNeedItemNum(data.StarNum)
                    --     GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.Fashion, data:GetCfgId(), L_RedPointItemCondition(itemId, needNum))
                    -- end
                else
                    -- If not activated, determine whether it can be activated
                    if not isShow then
                        isShow = data:CanActive(occ)
                    end
                    local needNum = data:GetNeedItemNum(0)
                    GameCenter.RedPointSystem:AddFuncCondition(FunctionStartIdCode.Fashion, data:GetCfgId(), L_RedPointItemCondition(itemId, needNum))
                end
            end
        end
    end
    --GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Fashion,isShow)
end

-- CUSTOM - New Fashion illustration red dot update
function NewFashionSystem:UpdateTjRedPoint()
    local dataList = self:GetTuJianDatas()
    if dataList == nil then
        return
    end
    local isShowCount = 0
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    for i = 1, #dataList do
        local data = dataList[i]
        for j = 1, #data.ListNeedData do
            local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(data.ListNeedData[j].FashionId)
            if fashionData then
                if fashionData.IsActive then
                    if fashionData:CanUpStar(occ) then
                        isShowCount = isShowCount + 1
                    end
                else
                    if fashionData:CanActive(occ) then
                        isShowCount = isShowCount + 1
                    end
                end
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.FashionTj, isShowCount > 0)
end
-- CUSTOM - New Fashion illustration red dot update

-- Fashion Wardrobe Red Dot Update
function NewFashionSystem:UpdateTotalRedPoint()
    local dic = self:GetTotalDataDic()
    if dic == nil then
        return
    end
    local keys = dic:GetKeys()
    if keys == nil then
        return
    end
    local isShow = false
    for i = 1, #keys do
        local dataList = dic[keys[i]]
        if dataList ~= nil then
            for m = 1 ,#dataList do
                local data = dataList[m]
                if data.IsNew and not isShow and data:GetType() <= 10 then
                    isShow = true
                end
            end
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Wardrobe,isShow)
end

-- ---------------------------------------------------information-----------------------------------------------------

-- Request to activate fashion
function NewFashionSystem:ReqActiveFashion(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqActiveFashion", {fashionID = id})
end

--CUSTOM - Dogiam
function NewFashionSystem:ReqActiveFashionDoGiam(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqActiveFashionDoGiam", {fashionID = id})
end
--CUSTOM - Dogiam

-- Request to wear fashion
function NewFashionSystem:ReqSaveFashion(ids)
    GameCenter.Network.Send("MSG_NewFashion.ReqSaveFashion", {wearIds = ids})
end

-- Request to activate the image
function NewFashionSystem:ReqActiveTj(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqActiveTj", {tjID = id})
end

-- Request for fashion promotion
function NewFashionSystem:ReqTjStar(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqTjStar", {tjID = id})
end

-- Request for image book to upgrade
function NewFashionSystem:ReqFashionStar(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqFashionStar", {fashionID = id})
end

--CUSTOM - Dogiam
function NewFashionSystem:ReqFashionStarDoGiam(id)
    GameCenter.Network.Send("MSG_NewFashion.ReqFashionStarDoGiam", {fashionID = id})
end
--CUSTOM - Dogiam

--CUSTOM - Dogiam
-- Activated fashion list sent online
function NewFashionSystem:ResOnlineInitFashionDoGiamInfo(msg)
    if msg == nil then
        return 
    end

    self:UpdateActiveFashionDogiam(msg.activeIds)
    self:UpdateTjDatas(msg.activeIds)
    -- Update red dots
    self:UpdateTjRedPoint()
end
--CUSTOM - Dogiam

-- Activated fashion list sent online
function NewFashionSystem:ResOnlineInitFashionInfo(msg)
    if msg == nil then
        return 
    end
    self:UpdateActiveFashion(msg.activeIds)
    self:UpdateTotalActive(msg.activeIds)
    self:UpdateWearList(msg.wearData)
    -- Update red dots
    self:UpdateFashionRedPoint()
    -- self:UpdateTotalRedPoint()
end

-- Return after wearing (activated) fashion
function NewFashionSystem:ResSaveFashionResult(msg)
    if msg == nil then
        return 
    end
    if msg.isActivate then
        -- There are new fashion activations
        local list = List:New()
        list:Add(msg.activateID)
        self:UpdateActiveFashion(list)
        self:UpdateTotalActive(list)
        -- Showcase new fashion models
        if msg.activateID ~= nil then
            local data = self:GetFashionData(msg.activateID.fashionID)
            if data ~= nil then
                data.IsNew = true
            end
            data = self:GetTotalData(msg.activateID.fashionID)
            if data ~= nil then
                if data:GetCfg().IfNew == 0 then
                    data.IsNew = true
                end
                local _iswear = true
                local type = data:GetType()
                if type == FashionType.Body then
                    type = ShowModelType.Player
                elseif type == FashionType.Weapon then
                    type = ShowModelType.LpWeapon
                elseif type == FashionType.Wing then
                    type = ShowModelType.Wing
                elseif type == FashionType.Mount then
                    type = ShowModelType.Mount
                    _iswear = false
                elseif type == FashionType.Pet then
                    type = ShowModelType.Pet
                    _iswear = false
                elseif type == FashionType.FaBao then
                    type = ShowModelType.FaBao
                    _iswear = false
                elseif type == FashionType.HunJia then
                    type = ShowModelType.SoulEquip
                end
                local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
                -- if type == ShowModelType.Player or type == ShowModelType.LpWeapon then
                --     GameCenter.ModelViewSystem:ShowModel(type, data:GetModelId(occ), 200, 0 , data:GetName(), true, msg.activateID.fashionID)
                -- end
                if data.Cfg.IsShow == 1 then
                    GameCenter.ModelViewSystem.IsStartTaskOnHide = data.Cfg.IsTask == 1
                    GameCenter.ModelViewSystem:ShowModel(type, data:GetModelId(occ), data.Cfg.ShowCameraSize, data.Cfg.ShowModelYPos/100 , data:GetName(), _iswear, msg.activateID.fashionID)
                end
            end
            self:UpdateTjData(msg.activateID.fashionID) 
        end
    end
    -- No fashion activation is just a wear update
    self:UpdateWearList(msg.retData)
    if msg.retData ~= nil then
        -- Update the picture data
        for i = 1, #msg.retData do
            local acData = msg.retData[i]
            self:UpdateTjData(acData.fashionID) 
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FASHION_ACTIVE_RESULT)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_NEWFASHION_CHANGE)
    -- Update red dots
    self:UpdateFashionRedPoint()
    -- self:UpdateTjRedPoint()
    self:UpdateTotalRedPoint()
end

-- CUSTOM - Dogiam - Return after wearing (activated) fashion
function NewFashionSystem:ResSaveFashionDoGiamResult(msg)
    if msg == nil then
        return 
    end
    if msg.isActivate then
        -- There are new fashion activations
        local list = List:New()
        list:Add(msg.activateID)
        self:UpdateActiveFashionDogiam(list)
        if msg.activateID ~= nil then
            local data = self:GetFashionDogiamData(msg.activateID.fashionID)
            self:UpdateTjData(msg.activateID.fashionID) 
        end
    end
    -- self:UpdateWearList(msg.retData)
    if msg.retData ~= nil then
        -- Update the picture data
        for i = 1, #msg.retData do
            local acData = msg.retData[i]
            self:UpdateTjData(acData.fashionID) 
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_DOGIAM_ACTIVE_RESULT)
    -- Update red dots
    self:UpdateTjRedPoint()
end
-- CUSTOM - Dogiam - Return after wearing (activated) fashion

-- CUSTOM - Dogiam - Fashion Star Return
function NewFashionSystem:ResFashionStarDoGiamResult(msg)
    if msg == nil then
        return
    end
    self:UpdateFashionDogiam(msg.retData)
    self:UpdateTjData(msg.retData.fashionID)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_DOGIAM_UPSTAR_RESULT)
    self:UpdateTjRedPoint()
end
-- CUSTOM - Dogiam - Fashion Star Return

-- Fashion Star Return
function NewFashionSystem:ResFashionStarResult(msg)
    if msg == nil then
        return
    end
    self:UpdateFashion(msg.retData)
    self:UpdateTjData(msg.retData.fashionID)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FASHION_UPSTAR_RESULT)
    self:UpdateFashionRedPoint()
    self:UpdateTjRedPoint()
end

-- Illustration activation return
function NewFashionSystem:ResActiveTjResult(msg)
    if msg == nil then
        return
    end
    local data = self:GetTuJianData(msg.tjData.tjID)
    if data ~= nil then
        data.IsActive = true
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FASHION_TUJIAN_ACTIVE)
    self:UpdateTjRedPoint()
end

function NewFashionSystem:GetLastActivatedStage(cfgId)
    -- local val = GosuSDK.GetLocalValue("FashionStage_" .. tostring(cfgId) .. GosuSDK.GetLocalValue("saveRoleId"))

    local roleKey = GosuSDK.GetLocalValue("saveRoleId") or ""
    local val = GosuSDK.GetLocalValue("FashionStage_" .. tostring(cfgId) .. "_" .. roleKey)
   

    -- print("=============================cfgId", cfgId)
    -- print("=============================val", val)

    -- GosuSDK.RecordValue("FashionStage_" .. tostring(cfgId) .. "_" .. roleKey, 0)

    --  print("=============================val cfgIdcfgIdcfgId", GosuSDK.GetLocalValue("FashionStage_" .. tostring(cfgId) .. "_" .. roleKey))

    return tonumber(val) or nil
end
-- Picture book to upgrade the star return
-- function NewFashionSystem:ResTjStarResult(msg)
--     if msg == nil then
--         return
--     end
--     local data = self:GetTuJianData(msg.tjData.tjID)
--     if data ~= nil then
--         data.StarNum = msg.tjData.star
--     end
--     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FASHION_TUJIAN_UPSTAR)
--     self:UpdateTjRedPoint()
-- end

function NewFashionSystem:ResTjStarResult(msg)
    if not msg or not msg.tjData then return end

    local tjId = msg.tjData.tjID
    local dataList = self:GetTuJianDatas()
    if not dataList then return end

    local data = nil
    -- 1) Nếu tjId là index hợp lệ
    if type(tjId) == "number" and tjId >= 1 and tjId <= #dataList then
        local cand = dataList[tjId]
        if cand and cand:GetCfgId() == tjId then
            data = cand
        end
    end

    -- 2) Nếu không, tìm theo CfgId
    if not data then
        for i = 1, #dataList do
            if dataList[i]:GetCfgId() == tjId then
                data = dataList[i]
                break
            end
        end
    end

    if data then
        data.StarNum = msg.tjData.star or data.StarNum
        if data.UpdateNeedDataList then
            data:UpdateNeedDataList()
        end
    else
        -- Debug.Log("NewFashionSystem:ResTjStarResult - can't find tujian data for tjId:", tostring(tjId))
    end

    self:UpdateTjRedPoint()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_FASHION_TUJIAN_UPSTAR)
end
-- Broadcast equipment new fashion, broadcast after changes, current map within range player
function NewFashionSystem:ResNewFashionBodyBroadcast(msg)
    local player = GameCenter.GameSceneSystem:FindPlayer(msg.playerId)
    if player == nil then
        return
    end
    if msg.retData ~= nil then
        for i = 1, #msg.retData do
            local ret = msg.retData[i]
            if ret.type == FashionType.Body then
                player.FashionBodyID = ret.fashionID
            elseif ret.type == FashionType.Weapon then
                player.FashionWeaponID = ret.fashionID
            elseif ret.type == FashionType.Wing then
                player.WingID = ret.fashionID
                player:EquipWithType(FSkinPartCode.Wing, RoleVEquipTool.GetLPWingModel())
            end
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_FASHION_UPDATECHANGE)
        end
    end
end

-- =====================================================================================================

-- Get all data in the wardrobe
function NewFashionSystem:GetTotalDataDic()
    if L_DicTotalFashionData:Count() == 0 then
        DataConfig.DataFashionTotal:Foreach(function(k, v)
            local data = L_FashionData:New(k,v)
            local list = nil
            if L_DicTotalFashionData:ContainsKey(v.Type) then
                list = L_DicTotalFashionData[v.Type]
                list:Add(data)
            else
                list = List:New()
                list:Add(data)
                L_DicTotalFashionData:Add(v.Type, list)
            end
        end)
    end
    return L_DicTotalFashionData
end

-- Get a list of fashion activated in the wardrobe
function NewFashionSystem:GetTotalActiveList(type)
    local dic = self:GetTotalDataDic()
    if dic == nil then
        return nil
    end
    local activeList = List:New()
    local list = dic[type]
    if list == nil then
        return nil
    end
    for i = 1, #list do
        local data = list[i]
        if data.IsActive and data:GetType() <= 10 then
            activeList:Add(data)
        end
    end
    return activeList
end

-- Get fashion data in the wardrobe
function NewFashionSystem:GetTotalData(fashionId)
    local dic = self:GetTotalDataDic()
    if dic == nil then
        return nil
    end
    local keys = dic:GetKeys()
    if keys == nil then
        return nil
    end
    for i = 1, #keys do
        local key = keys[i]
        local dataList = dic[key]
        if dataList ~= nil then
            for m = 1, #dataList do
                local data = dataList[m]
                if data:GetCfgId() == fashionId then
                    return data
                end
            end
        end
    end
    return nil
end

-- Determine if there is a new fashion
function NewFashionSystem:HaveNewByType(type)
    local list = self:GetTotalActiveList(type)
    if list == nil then
        return false
    end
    local ret = false
    for i = 1, #list do
        local data = list[i]
        if not ret and data.IsNew then
            ret = true
        end
    end
    return ret
end

-- Whether to activate
function NewFashionSystem:IsActive(fashionId)
    local data = self:GetTotalData(fashionId)
    if data == nil then
        return false
    end
    return data.IsActive
end

function NewFashionSystem:GetTotalDataByModelId(id, occ)
    local dic = self:GetTotalDataDic()
    --IsEquialWithModelId
    if dic == nil then
        return nil 
    end
    local keys = dic:GetKeys()
    if keys == nil then
        return
    end
    for i = 1, #keys do
        local key = keys[i]
        local dataList = dic[key]
        if dataList ~= nil then
            for m = 1, #dataList do
                local data = dataList[m]
                if data:IsEquialWithModelId(id, occ) then
                    return data
                end
            end
        end
    end
    return nil
end

function NewFashionSystem:UpdateTotalActive(dataList)
    local dic = self:GetTotalDataDic()
    if dic == nil then
        return
    end
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local acData = dataList[i]
        local list = dic[acData.type]
        if list ~= nil then
            for m = 1, #list do
                local data = list[m]
                if data:GetCfgId() == acData.fashionID then
                    data.IsActive = true
                end
            end
        end
    end
end

-- Update the wardrobe wear
function NewFashionSystem:UpdateTotalWear(dataList)
    local dic = self:GetTotalDataDic()
    if dic == nil then
        return
    end
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local acData = dataList[i]
        local list = dic[acData.type]
        if list ~= nil then
            for m = 1, #list do
                local data = list[m]
                data.IsWear = false
                if data:GetCfgId() == acData.fashionID then
                    data.IsWear = true
                    self:SetWearData(data, acData.type)
                end
            end
        end
    end
end

-- ===================================================================================================
-- Obtain the picture data
function NewFashionSystem:GetTuJianDatas()
    if #L_ListTuJianData == 0 then
        DataConfig.DataFashionDogiamLink:Foreach(function(k, v)
            local data = L_TuJianData:New(k,v)
            L_ListTuJianData:Add(data)
        end)
    end
    return L_ListTuJianData
end

-- Obtain the image data based on index
function NewFashionSystem:GetTuJianData(index)
    local dataList = self:GetTuJianDatas()
    if dataList ~= nil and index <= #dataList then
        return dataList[index]
    end
    return nil
end

-- Get the lowest star rating of fashion in the corresponding picture book of index
function NewFashionSystem:GetLowStarLv(index)
    local ret = 999
    local data = nil
    local dataList = self:GetTuJianDatas()
    if dataList ~= nil and index <= #dataList then
        data = dataList[index]
        local fashionList = data:GetNeedDataList()
        if fashionList == nil then
            return ret
        end
        for i = 1, #fashionList do
            local id = fashionList[i].FashionId
            -- local fashionData = self:GetFashionData(id)
            local fashionData = self:GetFashionDogiamData(id)
            local num = fashionData:GetStarNum()
            if ret > num then
                ret = num
            end
        end
    end
    return ret
end

-- Determine whether all the fashions required for the index are collected
function NewFashionSystem:IsCollectAll(index)
    local data = nil
    local dataList = self:GetTuJianDatas()
    if dataList ~= nil and index <= #dataList then
        data = dataList[index]
        local fashionList = data:GetNeedDataList()
        if fashionList == nil then
            return false
        end
        for i = 1, #fashionList do
            local isActive = fashionList[i].IsActive
            if not isActive then
                return false
            end
        end
    end
    return true
end

-- Update the picture data
function NewFashionSystem:UpdateTjDatas(activeIds)
    local dataList = self:GetTuJianDatas()
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local data = dataList[i]
        data:UpdateNeedDataList()
    end
end

-- Update the picture data
function NewFashionSystem:UpdateTjData(fashionId)
    local fashionData = self:GetFashionDogiamData(fashionId)
    local dataList = self:GetTuJianDatas()
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local data = dataList[i]
        data:SetNeedData(fashionData)
    end
end

-- ===================================================================================================
-- CUSTOM - FashionDogiam

-- Get all the fashion data
function NewFashionSystem:GetFashionDogiamDataDic()
    if L_DicFashionDogiamData:Count() == 0 then
        DataConfig.DataFashionDogiam:Foreach(function(k, v)
            local data = L_FashionData:New(k,v)
            local list = nil
            if L_DicFashionDogiamData:ContainsKey(v.Type) then
                list = L_DicFashionDogiamData[v.Type]
                list:Add(data)
            else
                list = List:New()
                list:Add(data)
                L_DicFashionDogiamData:Add(v.Type, list)
            end
        end)
    end
    return L_DicFashionDogiamData
end

-- Get the fashion list corresponding to the type
function NewFashionSystem:GetFashionDogiamList(type)
    local retList = List:New()
    local dic = self:GetFashionDogiamDataDic()
    if dic ~= nil then
        local list = dic[type]
        if list ~= nil then
            for i = 1, #list do
                local data = list[i]
                if data:GetCfg().IsHide ~= 1 then
                    retList:Add(data)
                end
            end
        end
    end
    return retList
end

-- Get fashion data
function NewFashionSystem:GetFashionDogiamData(fashionId)
    local dic = self:GetFashionDogiamDataDic()
    if dic == nil then
        return nil
    end
    local keys = dic:GetKeys()
    if #keys == 0 then
        return nil
    end
    for i = 1,#keys do
        local list = dic[keys[i]]
        for m = 1,#list do
            local data = list[m]
            if data:GetCfgId() == fashionId then
                return data
            end
        end
    end
    return nil
end

-- Updated fashion
function NewFashionSystem:UpdateFashionDogiam(data)
    local dic = self:GetFashionDogiamDataDic()
    if dic == nil then
        return
    end
    if data == nil then
        return
    end
    local list = dic[data.type]
    if list ~= nil then
        for m = 1, #list do
            if list[m]:GetCfgId() == data.fashionID then
                list[m].StarNum = data.star
            end
        end
    end
end

-- Update fashion activation data
function NewFashionSystem:UpdateActiveFashionDogiam(dataList)
    local dic = self:GetFashionDogiamDataDic()
        
    if dic == nil then
        return
    end
    if dataList == nil then
        return
    end

    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc

    for i = 1, #dataList do
        local acData = dataList[i]
        local list = dic[acData.type]
        if list ~= nil then
            for m = 1, #list do
                local data = list[m]
                if data:GetCfgId() == acData.fashionID then
                    data.IsActive = true
                    data.StarNum = acData.star
                    data:GetItemId(occ)
                end
            end
        end
    end
end

-- CUSTOM - FashionDogiam
-- ===================================================================================================

-- Get all the data of fashion
function NewFashionSystem:GetFashionDatas()
    if #L_ListFashionData == 0 then
        -- Initialize the picture data
        DataConfig.DataFashion:Foreach(function(k, v)
            local data = L_FashionData:New(k,v)
            L_ListFashionData:Add(data)
        end)
    end
    return L_ListFashionData
end

-- Get all the fashion data
function NewFashionSystem:GetFashionDataDic()
    if L_DicFashionData:Count() == 0 then
        DataConfig.DataFashion:Foreach(function(k, v)
            local data = L_FashionData:New(k,v)
            local list = nil
            if L_DicFashionData:ContainsKey(v.Type) then
                list = L_DicFashionData[v.Type]
                list:Add(data)
            else
                list = List:New()
                list:Add(data)
                L_DicFashionData:Add(v.Type, list)
            end
        end)
    end
    return L_DicFashionData
end

-- Get the fashion list corresponding to the type
function NewFashionSystem:GetFashionList(type)
    local retList = List:New()
    local dic = self:GetFashionDataDic()
    if dic ~= nil then
        local list = dic[type]
        if list ~= nil then
            for i = 1, #list do
                local data = list[i]
                if data:GetCfg().IsHide ~= 1 then
                    retList:Add(data)
                end
            end
        end
    end
    return retList
end

function NewFashionSystem:GetAllFashionList(type)
    local retList = nil
    local dic = self:GetFashionDataDic()
    if dic ~= nil then
        retList = dic[type]
    end
    return retList
end

-- Get fashion data
function NewFashionSystem:GetFashionData(fashionId)
    local dic = self:GetFashionDataDic()
    if dic == nil then
        return nil
    end
    local keys = dic:GetKeys()
    if #keys == 0 then
        return nil
    end
    for i = 1,#keys do
        local list = dic[keys[i]]
        for m = 1,#list do
            local data = list[m]
            if data:GetCfgId() == fashionId then
                return data
            end
        end
    end
    return nil
end

-- Updated fashion
function NewFashionSystem:UpdateFashion(data)
    local dic = self:GetFashionDataDic()
    if dic == nil then
        return
    end
    if data == nil then
        return
    end
    local list = dic[data.type]
    if list ~= nil then
        for m = 1, #list do
            if list[m]:GetCfgId() == data.fashionID then
                list[m].StarNum = data.star
            end
        end
    end
end

-- Update fashion activation data
function NewFashionSystem:UpdateActiveFashion(dataList)
    local dic = self:GetFashionDataDic()
    if dic == nil then
        return
    end
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local acData = dataList[i]
        local list = dic[acData.type]
        if list ~= nil then
            for m = 1, #list do
                local data = list[m]
                if data:GetCfgId() == acData.fashionID then
                    data.IsActive = true
                    data.StarNum = acData.star
                end
            end
        end
    end
end

-- Update fashion wear data
function NewFashionSystem:UpdateWearFashion(dataList)
    local dic = self:GetFashionDataDic()
    if dic == nil then
        return
    end
    if dataList == nil then
        return
    end
    for i = 1, #dataList do
        local acData = dataList[i]
        local list = dic[acData.type]
        if list ~= nil then
            for m = 1, #list do
                local data = list[m]
                data.IsWear = false
                if data:GetCfgId() == acData.fashionID then
                    data.IsWear = true
                    data.StarNum = acData.star
                    self:SetWearData(data, acData.type)
                end
            end
        end
    end
end

-- Get avatar data
function NewFashionSystem:GetPlayerHeadData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Head)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data.IsActive and data.IsWear then
                ret = data
                break
            end
        end
    end
    return ret
end

-- Get avatar frame data
function NewFashionSystem:GetPlayerHeadFrameData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Frame)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data.IsActive and data.IsWear then
                ret = data
                break
            end
        end
    end
    return ret
end

-- Get chat bubble data
function NewFashionSystem:GetPlayerPaoPaoData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.PaoPao)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data.IsActive and data.IsWear then
                ret = data
                break
            end
        end
    end
    return ret
end

function NewFashionSystem:GetPlayerHeadDataById(id)
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Head)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfgId() == id then
                ret = data
                break
            end
        end
    end
    return ret
end

function NewFashionSystem:GetPlayerHeadFrameDataById(id)
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Frame)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfgId() == id then
                ret = data
                break
            end
        end
    end
    return ret
end

function NewFashionSystem:GetPlayerPaoPaoDataById(id)
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.PaoPao)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfgId() == id then
                ret = data
                break
            end
        end
    end
    return ret
end

-- Get the default avatar data
function NewFashionSystem:GetPlayerHeadDefaultData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Head)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfg().IsHide == 1 then
                ret = data
                break
            end
        end
    end
    return ret
end

-- Get the default avatar frame data
function NewFashionSystem:GetPlayerHeadFrameDefaultData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.Frame)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfg().IsHide == 1 then
                ret = data
                break
            end
        end
    end
    return ret
end

-- Get the default chat bubble data
function NewFashionSystem:GetPlayerPaoPaoDefaultData()
    local ret = nil
    local list = self:GetAllFashionList(ShowModelType.PaoPao)
    if list ~= nil then
        for i = 1, #list do
            local data = list[i]
            if data:GetCfg().IsHide == 1 then
                ret = data
                break
            end
        end
    end
    return ret
end

return NewFashionSystem
