-- Author:
-- Date: 2019-05-09
-- File: LianQiGemSystem.lua
-- Module: LianQiGemSystem
-- Description: 1. This system is: sub-function of the refining function Gem system
-- (There is another sub-function of refining tools, forging)
-- 2. The panel is: UILianQiGemForm (currently there are 3 pagings: gem inlay, gem refinement, and fairy jade inlay)
------------------------------------------------

local LianQiGemSystem = {
    GemInlayCfgByPosDic = Dictionary:New(),             -- Gem inlay configuration table dictionary
    AllCanInlayGemIDList = List:New(),                  -- List of all gems that can be inlaid
    JadeInlayCfgByPosDic = Dictionary:New(),            -- Fairy Jade Inlay Configuration Table Dictionary
    AllCanInlayJadeIDList = List:New(),                 -- All the inlayed immortal jade list
    GemInlayInfoByPosDic = Dictionary:New(),            -- Gem inlay information dictionary
    JadeInlayInfoByPosDic = Dictionary:New(),           -- Immortal Jade Inlay Information Dictionary
    GemRefineInfoByPosDic = Dictionary:New(),           -- Gem Refined Information Dictionary
    RefineColorTypeDic = Dictionary:New(),              -- Refined color dictionary
    GemRefineItemIDList = {19001, 19002, 19003, 19004, 19005, 19006},  -- List of ids required for refining
    MaxHoleNum = 6,                                     -- Maximum hole position
    GemMaxLevel = 0,                                    -- Maximum level of gems
    GemRefineMaxLevel = 100,                            -- The maximum refining level of gems
    JadeMaxLevel = 0,                                   -- The largest level of immortal jade
    HaveNumCache = {},
    UseNewSlotConfig = true,  -- set theo cái game D100

    GemInlayInfoByItemIdDic = Dictionary:New(), -- New dic to save itemid => partgeminfo
}

function LianQiGemSystem:Initialize()
    
    for i=0, EquipmentType.Pendant do
        local _gemCfgID = 1000 + i
        local _gemCfg = DataConfig.DataGemstoneInlay[_gemCfgID]
        if _gemCfg then
            local _canInlayGemIDList = List:New()
            local _gemIDStringList = Utils.SplitStr(_gemCfg.GemstoneId, "_")




            for ii=1,#_gemIDStringList do
                local _gemID = tonumber(_gemIDStringList[ii])
                _canInlayGemIDList:Add(_gemID)
                if not self.AllCanInlayGemIDList:Contains(_gemID) then
                    self.AllCanInlayGemIDList:Add(_gemID)
                end
            end
            _canInlayGemIDList:Sort(
                function (a, b)
                    return a < b
                end
            )
            

            self.GemMaxLevel = self:GetGemLevelByItemID(_canInlayGemIDList[#_canInlayGemIDList])
            local _holeOpenConditions = Utils.SplitStr(_gemCfg.LocationCondition, ";")
            local _maxHole = _gemCfg.LimitNumber
            local _tempCfg = {CanInlayGemIDList = _canInlayGemIDList, HoleOpenConditions = _holeOpenConditions, MaxHole = _maxHole}
            self.GemInlayCfgByPosDic:Add(i, _tempCfg)

            -- ====== TEST: thêm gem nhóm 210xx vào slot 0 ======
            -- if i == 0 then
            --     local testList = {180001, 180002, 180003, 180004, 180005}
            --     for k = 1, #testList do
            --         local id = testList[k]
            --         if not _canInlayGemIDList:Contains(id) then
            --             _canInlayGemIDList:Add(id)
            --         end
            --         if not self.AllCanInlayGemIDList:Contains(id) then
            --             self.AllCanInlayGemIDList:Add(id)
            --         end
            --     end
            --     _canInlayGemIDList:Sort(function(a,b) return a < b end)
            -- end
            -- ==================================================


            if self.RefineColorTypeDic:ContainsKey(_gemCfg.ColorType) then
                local _posList = self.RefineColorTypeDic[_gemCfg.ColorType]
                if not _posList:Contains(i) then
                    _posList:Add(i)
                end
            else
                local _posList = List:New()
                _posList:Add(i)
                self.RefineColorTypeDic:Add(_gemCfg.ColorType, _posList)
            end
        end
        local _jadeCfgID = 2000 + i
        local _jadeCfg = DataConfig.DataGemstoneInlay[_jadeCfgID]
        if _jadeCfg then
            local _canInlayJadeIDList = List:New()
            local _jadeIDStringList = Utils.SplitStr(_jadeCfg.GemstoneId, "_")
            for ii=1,#_jadeIDStringList do
                local _jadeID = tonumber(_jadeIDStringList[ii])
                _canInlayJadeIDList:Add(_jadeID)
                if not self.AllCanInlayJadeIDList:Contains(_jadeID) then
                    self.AllCanInlayJadeIDList:Add(_jadeID)
                end
            end
            _canInlayJadeIDList:Sort(
                function (a, b)
                    return a < b
                end
            )
            self.JadeMaxLevel = self:GetJadeLevelByItemID(_canInlayJadeIDList[#_canInlayJadeIDList])
            local _holeOpenConditions = Utils.SplitStr(_jadeCfg.LocationCondition, ";")
            local _maxHole = _jadeCfg.LimitNumber
            local _tempCfg = {CanInlayJadeIDList = _canInlayJadeIDList, HoleOpenConditions = _holeOpenConditions, MaxHole = _maxHole}
            self.JadeInlayCfgByPosDic:Add(i, _tempCfg)

            if self.RefineColorTypeDic:ContainsKey(_jadeCfg.ColorType) then
                local _posList = self.RefineColorTypeDic[_jadeCfg.ColorType]
                if not _posList:Contains(i) then
                    _posList:Add(i)
                end
            else
                local _posList = List:New()
                _posList:Add(i)
                self.RefineColorTypeDic:Add(_jadeCfg.ColorType, _posList)
            end
        end
    end
    self.GemRefineMaxLevel = 100
    GameCenter.RegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemUpdate, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.SetFuncRedPoint, self);
    --GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_UNWEAREQUIPSUC, self.SetFuncRedPoint, self);
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);

    Debug.Log("_gemIDStringList_gemIDStringList_gemIDStringList=GemInlayCfgByPosDic=", Inspect(self.GemInlayCfgByPosDic))
    Debug.Log("_gemIDStringList_gemIDStringList_gemIDStringList=AllCanInlayGemIDList=", Inspect(self.AllCanInlayGemIDList))
end

function LianQiGemSystem:UnInitialize()
    self.GemInlayCfgByPosDic:Clear()
    self.JadeInlayCfgByPosDic:Clear()
    self.GemInlayInfoByPosDic:Clear()
    self.JadeInlayInfoByPosDic:Clear()
    self.GemRefineInfoByPosDic:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EVENT_ITEM_CHANGE_UPDATE, self.OnItemUpdate, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_WEAREQUIPSUC, self.SetFuncRedPoint, self);
    --GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_UNWEAREQUIPSUC, self.SetFuncRedPoint, self);
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_RESEQUIPPARTINFO, self.ResEquipPartInfo, self);
end

function LianQiGemSystem:ResEquipPartInfo(obj, sender)
    self:GS2U_ResGemInfo(obj)
end


--------------------------------------------BEGIN CUSTOM---------------------------------------------------
function LianQiGemSystem:GS2U_ResGemInfo(result)
    -- 🔹 Dic mới: itemId => gemInfo (KHÔNG ảnh hưởng code cũ)
    self.GemInlayInfoByItemIdDic = self.GemInlayInfoByItemIdDic or Dictionary:New()

    if result.infos then
        local _infos = List:New(result.infos)
        if _infos then
            for i = 1, #_infos do
                local info = _infos[i]
                local _pos = info.type
                local gemInfo = info.gemInfo
                local equip = info.equip

                if gemInfo then
                    local _gemIDList = nil
                    local _jadeIDList = nil

                    -- ===== GIỮ LOGIC CŨ: PART => GEM =====
                    if gemInfo.gemIds ~= nil then
                        _gemIDList = List:New(gemInfo.gemIds)

                        if self.GemInlayInfoByPosDic:ContainsKey(_pos) then
                            self.GemInlayInfoByPosDic[_pos] = _gemIDList
                        else
                            self.GemInlayInfoByPosDic:Add(_pos, _gemIDList)
                        end
                    end

                    if gemInfo.jadeIds ~= nil then
                        _jadeIDList = List:New(gemInfo.jadeIds)

                        if self.JadeInlayInfoByPosDic:ContainsKey(_pos) then
                            self.JadeInlayInfoByPosDic[_pos] = _jadeIDList
                        else
                            self.JadeInlayInfoByPosDic:Add(_pos, _jadeIDList)
                        end
                    end

                    local _refineInfo = {
                        Level = gemInfo.level,
                        Exp   = gemInfo.exp
                    }

                    if self.GemRefineInfoByPosDic:ContainsKey(_pos) then
                        self.GemRefineInfoByPosDic[_pos] = _refineInfo
                    else
                        self.GemRefineInfoByPosDic:Add(_pos, _refineInfo)
                    end

                    -- ===== MỚI: ITEMID => GEM INFO =====
                    -- if equip and equip.itemId then
                    --     self.GemInlayInfoByItemIdDic[equip.itemId] = {
                    --         part    = _pos,
                    --         gemIds  = _gemIDList,
                    --         jadeIds = _jadeIDList,
                    --         refine  = _refineInfo
                    --     }
                    -- end
                end
            end

            -- ===== GIỮ NGUYÊN LOGIC RED POINT =====
            if #_infos > 0 and _infos[1].gemInfo ~= nil then
                self.HaveNumCache = {}
                self:SetGemInlayRedPoint()
                self:SetJadeInlayRedPoint()
                self:SetGemRefineRedPoint()
                self.HaveNumCache = {}
            end
        end
    end

    -- print(
    --     "GemInlayInfoByPosDic=====================",
    --     Inspect(self.GemInlayInfoByPosDic)
    -- )

    -- print(
    --     "GemInlayInfoByItemIdDic==================",
    --     Inspect(self.GemInlayInfoByItemIdDic)
    -- )
end


-- =========================================================
-- Init GemInlayInfoByItemIdDic from bag snapshot (LOGIN)
-- Source: GS2U_ResItemInfoBags
-- =========================================================
function LianQiGemSystem:InitGemInlayInfoByBagInfos(bagInfos)
    if not bagInfos then
        return
    end

    -- 🔒 ensure dic
    self.GemInlayInfoByItemIdDic = self.GemInlayInfoByItemIdDic or Dictionary:New()

    for _, bag in ipairs(bagInfos) do
        local info    = bag.info
        local equip   = info and info.equip
        local gemInfo = info and info.gemInfo

        if equip and equip.itemId and gemInfo then
            local _pos = info.type

            local _gemIDList  = gemInfo.gemIds  and List:New(gemInfo.gemIds)  or nil
            local _jadeIDList = gemInfo.jadeIds and List:New(gemInfo.jadeIds) or nil

            local _refineInfo = {
                Level = gemInfo.level or 0,
                Exp   = gemInfo.exp   or 0
            }

            -- ✅ SAME STRUCT AS GS2U_ResGemInfo
            self.GemInlayInfoByItemIdDic[equip.itemId] = {
                part    = _pos,
                gemIds  = _gemIDList,
                jadeIds = _jadeIDList,
                refine  = _refineInfo
            }
        end
    end

    -- print("===========self.GemInlayInfoByItemIdDic=========================================================", Inspect(self.GemInlayInfoByItemIdDic))

end


-- =====================================================
-- Check HasGemInlay
-- =====================================================
function LianQiGemSystem:HasGemInlay(itemId)
    if not itemId then
        return false
    end

    local info = self.GemInlayInfoByItemIdDic
                and self.GemInlayInfoByItemIdDic[itemId]

    if not info or not info.gemIds then
        return false
    end

    for i = 1, #info.gemIds do
        local gemId = info.gemIds[i]
        if gemId and gemId ~= -1 and gemId ~= 0 then
            return true
        end
    end

    return false
end





-- =====================================================
-- Update FULL gem info by PART
-- (gemIds + jadeIds + refine)
-- =====================================================
function LianQiGemSystem:UpdateGemInfoByPart(part, gemInfo)
    if part == nil or gemInfo == nil then
        return
    end

    -- đảm bảo dic tồn tại
    self.GemInlayInfoByPosDic  = self.GemInlayInfoByPosDic  or Dictionary:New()
    self.JadeInlayInfoByPosDic = self.JadeInlayInfoByPosDic or Dictionary:New()
    self.GemRefineInfoByPosDic = self.GemRefineInfoByPosDic or Dictionary:New()

    local gemIDList  = nil
    local jadeIDList = nil

    -- ===== GEM IDS =====
    if gemInfo.gemIds ~= nil then
        gemIDList = List:New(gemInfo.gemIds)

        if self.GemInlayInfoByPosDic:ContainsKey(part) then
            self.GemInlayInfoByPosDic[part] = gemIDList
        else
            self.GemInlayInfoByPosDic:Add(part, gemIDList)
        end
    end

    -- ===== JADE IDS =====
    if gemInfo.jadeIds ~= nil then
        jadeIDList = List:New(gemInfo.jadeIds)

        if self.JadeInlayInfoByPosDic:ContainsKey(part) then
            self.JadeInlayInfoByPosDic[part] = jadeIDList
        else
            self.JadeInlayInfoByPosDic:Add(part, jadeIDList)
        end
    end

    -- ===== REFINE INFO =====
    local refineInfo = {
        Level = gemInfo.level or 0,
        Exp   = gemInfo.exp   or 0
    }

    if self.GemRefineInfoByPosDic:ContainsKey(part) then
        self.GemRefineInfoByPosDic[part] = refineInfo
    else
        self.GemRefineInfoByPosDic:Add(part, refineInfo)
    end

    -- print(
    --     "[UpdateGemInfoByPart]",
    --     "part=", part,
    --     "gem=", Inspect(gemIDList),
    --     "jade=", Inspect(jadeIDList),
    --     "refine=", Inspect(refineInfo)
    -- )
end


-- =====================================================
-- Update / Add gem info by itemId (from bag / item update)
-- =====================================================
function LianQiGemSystem:UpdateGemInfoByItem(itemId, gemInfo, equipPart)
    if not itemId or not gemInfo then
        return
    end

    -- đảm bảo dic tồn tại
    self.GemInlayInfoByItemIdDic =
        self.GemInlayInfoByItemIdDic or Dictionary:New()

    local gemIds  = gemInfo.gemIds and List:New(gemInfo.gemIds) or nil
    local jadeIds = gemInfo.jadeIds and List:New(gemInfo.jadeIds) or nil
    local refineInfo = {
        Level = gemInfo.level or 0,
        Exp   = gemInfo.exp   or 0
    }

    -- update / add
    self.GemInlayInfoByItemIdDic[itemId] = {
        part    = equipPart,   -- có thì tốt, không có vẫn OK
        gemIds  = gemIds,
        jadeIds = jadeIds,
        refine  = refineInfo
    }

    -- print(
    --     "[UpdateGemInfoByItem]",
    --     "itemId=", itemId,
    --     "data=", Inspect(self.GemInlayInfoByItemIdDic[itemId])
    -- )
end


----------- END CUSTOM
-- Request an upgrade, upgradeType = 1 is the gem upgrade, upgradeType = 2 is the immortal jade upgrade. The following parameters are: location, inlay position
function LianQiGemSystem:ReqUpGradeGem(upgradeType, pos, inlayIndex)
    -- The server index starts at 0, but the index starts at 1 in the list of Lua
    local _req = ReqMsg.MSG_Equip.ReqUpGradeGem:New()
    _req.type = upgradeType
    _req.part = pos
    _req.index = inlayIndex - 1
    _req:Send()
    --GameCenter.Network.Send("MSG_Equip.ReqUpGradeGem", {type = upgradeType, part = pos, index = inlayIndex - 1})
end

-- Request inlay, inlayType = 1 is a gem inlay, and inlayType = 2 is a fairy jade inlay. The following parameters are: location, inlay position, inlaid gem/Xianyu ID
function LianQiGemSystem:ReqInlay(inlayType, pos, index, id)
    -- The server index starts at 0, but the index starts at 1 in the list of Lua
    local _req = ReqMsg.MSG_Equip.ReqInlay:New()
    _req.type = inlayType
    _req.part = pos
    _req.gemIndex = index - 1
    _req.gemId = id
    _req:Send()
    Debug.Log(" _req.gemId  _req.gemId  _req.gemId  _req.gemId  _req.gemId  _req.gemId ",  _req.gemId )
    --GameCenter.Network.Send("MSG_Equip.ReqInlay", {type = inlayType, part = pos, gemIndex = index - 1, gemId = id})
end



-- Xử lý remove gem
-- Request remove gem, inlayType = 1 is a gem inlay, and inlayType = 2 is a fairy jade inlay. The following parameters are: location, inlay position, inlaid gem/Xianyu ID
function LianQiGemSystem:ReqQuickRemoveGem(inlayType, pos, index)
    -- The server index starts at 0, but the index starts at 1 in the list of Lua
    local _req = ReqMsg.MSG_Equip.ReqQuickRemoveGem:New()
    _req.type = inlayType
    _req.part = pos
    _req.index = index
    _req:Send()
    --GameCenter.Network.Send("MSG_Equip.ReqInlay", {type = inlayType, part = pos, gemIndex = index - 1, gemId = id})
end

-- Update gems and fairy jade information
function LianQiGemSystem:GS2U_ResUpdateQuickRemoveGem(result)

    local part = result and result.result and result.result[1] and result.result[1].part
    
    -- print("===> part =", part)
    if part then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REMOVE_GEM, {part, result.result[1].exp or 0 })
        self:SetGemInlayRedPoint()
    else
        -- print("Không tìm thấy part trong kết quả server gửi về!")
    end

end

-- End


-- Update gems and fairy jade information
function LianQiGemSystem:GS2U_ResUpdateGemDatas(result)
    self.HaveNumCache = {}
    -- 1 is a gem, 2 is a fairy jade
    if result.type == 1 then
        if self.GemInlayInfoByPosDic:ContainsKey(result.part) then
            local _gemInlayInfo = self.GemInlayInfoByPosDic[result.part]
            _gemInlayInfo[result.gemIndex + 1] = result.gemId
            -- The index sent by the server starts from 0. However, the List index sent by the server starts from 1 in lua
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEMINLAYINFO, {result.part, result.gemIndex + 1, result.gemId})
        end
        self:SetGemInlayRedPoint()
    elseif result.type == 2 then
        if self.JadeInlayInfoByPosDic:ContainsKey(result.part) then
            local _jadeInlayInfo = self.JadeInlayInfoByPosDic[result.part]
            _jadeInlayInfo[result.gemIndex + 1] = result.gemId
            -- The index sent by the server starts from 0. However, the List index sent by the server starts from 1 in lua
            GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_JADEINLAYINFO, {result.part, result.gemIndex + 1, result.gemId})
        end
        self:SetJadeInlayRedPoint()
    end
end

-- Request quick refining gems, pos: part, id: prop id used
function LianQiGemSystem:ReqQuickRefineGem(pos, id)
    local _req = ReqMsg.MSG_Equip.ReqQuickRefineGem:New()
    _req.part = pos
    _req.itemId = id
    _req:Send()
end

-- Quick refining return
function LianQiGemSystem:GS2U_ResQuickRefineGem(result)
    if self.GemRefineInfoByPosDic:ContainsKey(result.result.part) then
        local _gemRefineInfo = self.GemRefineInfoByPosDic[result.result.part]
        _gemRefineInfo.Level = result.result.level
        _gemRefineInfo.Exp = result.result.exp
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEMREFINEINFO, result.result.part);
        self.HaveNumCache = {}
        self:SetGemRefineRedPoint()
    end
end

-- Request for intelligent refining
function LianQiGemSystem:ReqAutoRefineGem(pos)
    local _req = ReqMsg.MSG_Equip.ReqAutoRefineGem:New()
    _req.part = pos
    _req:Send()
end

-- Intelligent refining return
function LianQiGemSystem:GS2U_ResAutoRefineGem(result)
    if result.result then
        local _newRefineInfo = result.result
        for i=1, #_newRefineInfo do
            if self.GemRefineInfoByPosDic:ContainsKey(_newRefineInfo[i].part) then
                local _gemRefineInfo = self.GemRefineInfoByPosDic[_newRefineInfo[i].part]
                _gemRefineInfo.Level = _newRefineInfo[i].level
                _gemRefineInfo.Exp = _newRefineInfo[i].exp
                GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEMREFINEINFO, _newRefineInfo[i].part);
            end
        end
        self.HaveNumCache = {}
        self:SetGemRefineRedPoint()
    end
end


function LianQiGemSystem:SetFuncRedPoint()
    self.HaveNumCache = {}
    self:SetGemInlayRedPoint()
    self:SetJadeInlayRedPoint()
    self:SetGemRefineRedPoint()
    self.HaveNumCache = {}
end

-- Gem inlaid with red dots
function LianQiGemSystem:SetGemInlayRedPoint()
    for i=0, EquipmentType.Count - 1 do
        if self:IsGemPosHaveRedPoint(i) then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemInlay, true);
            return true
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemInlay, false);
    return false
end

function LianQiGemSystem:IsGemPosHaveRedPoint(pos)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if not _equip then
        return false
    end
    if self.GemInlayInfoByPosDic:ContainsKey(pos) then
        for i=1,GameCenter.LianQiGemSystem.MaxHoleNum do
            if self:IsGemHoleHaveRedPoint(pos, i) then
                return true
            end
        end
    end
    return false
end



-- function LianQiGemSystem:IsGemHoleHaveRedPoint(pos, index)
--     local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
--     if not _equip then
--         return false
--     end
--     local _gemIDList = self.GemInlayInfoByPosDic[pos]
--     local _gemID = _gemIDList[index]


 
--     local _maxLv = self:GetEquipGemMaxLv(_equip)

--     if _maxLv <= 0 then
--         return false
--     end

--     if _gemID then
--         if _gemID > 0 then
--             local _curInlayGemLv = self:GetGemLevelByItemID(_gemID)


--             if _curInlayGemLv >= _maxLv then
--                 return false
--             end

--             local _itemCfg = DataConfig.DataItem[_gemID]
--             if _itemCfg then
--                 local strArr = Utils.SplitStr(_itemCfg.HechenTarget, "_")
--                 if #strArr == 2 then
--                     local _conbineNeedNum = tonumber(strArr[2])
--                     local _totalNeedNum = 0
--                     local _index = 0
--                     for i = _curInlayGemLv, 1, -1 do
--                         local _haveNum = self.HaveNumCache[_gemID - _index]
--                         if _haveNum == nil then
--                             _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_gemID - _index)
--                             self.HaveNumCache[_gemID - _index] = _haveNum
--                         end
--                         if i == _curInlayGemLv then
--                             _totalNeedNum = _conbineNeedNum - 1 - _haveNum
--                         else
--                             _totalNeedNum = _totalNeedNum * _conbineNeedNum - _haveNum
--                         end
--                         _index = _index + 1
--                     end
--                     if _totalNeedNum <= 0 then
--                         return true
--                     end
--                 end
--             end
--             if self.GemInlayCfgByPosDic:ContainsKey(pos) then
--                 local _canInlayGemIDList = self.GemInlayCfgByPosDic[pos].CanInlayGemIDList
--                 if _canInlayGemIDList then
--                     for i=1, #_canInlayGemIDList do
--                         -- if self:GetGemLevelByItemID(_canInlayGemIDList[i]) > _curInlayGemLv then
--                         local _targetLv = self:GetGemLevelByItemID(_canInlayGemIDList[i])
--                         if _targetLv > _curInlayGemLv and _targetLv <= _maxLv then
--                             local _haveCount = self.HaveNumCache[_canInlayGemIDList[i]]
--                             if _haveCount == nil then
--                                 _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
--                                 self.HaveNumCache[_canInlayGemIDList[i]] = _haveCount
--                             end
--                             if _haveCount > 0 then
--                                 return true
--                             end
--                         end
--                     end
--                 end
--             end
--             return false
--         elseif _gemID == 0 then
--             if self.GemInlayCfgByPosDic:ContainsKey(pos) then
--                 local _canInlayGemIDList = self.GemInlayCfgByPosDic[pos].CanInlayGemIDList
--                 if _canInlayGemIDList then
--                     for i=1, #_canInlayGemIDList do
--                         local _targetLv = self:GetGemLevelByItemID(_canInlayGemIDList[i])
--                         if _targetLv <= _maxLv then
--                             local _haveCount = self.HaveNumCache[_canInlayGemIDList[i]]
--                             if _haveCount == nil then
--                                 _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
--                                 self.HaveNumCache[_canInlayGemIDList[i]] = _haveCount
--                             end
--                             if _haveCount > 0 then
--                                 return true
--                             end
--                         end
--                         -- local _haveCount = self.HaveNumCache[_canInlayGemIDList[i]]
--                         -- if _haveCount == nil then
--                         --     _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
--                         --     self.HaveNumCache[_canInlayGemIDList[i]] = _haveCount
--                         -- end
--                         -- if _haveCount > 0 then
--                         --     return true
--                         -- end
--                     end
--                 end
--             end
--             return false
--         else
--             return false
--         end
--     end
-- end

----------- Gosu logic nhiều đá khảm
function LianQiGemSystem:IsGemHoleHaveRedPoint(pos, index)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if not _equip then
        return false
    end

    local _gemIDList = self.GemInlayInfoByPosDic[pos]
    local _gemID = _gemIDList[index]

    local _maxLv = self:GetEquipGemMaxLv(_equip)
    if _maxLv <= 0 then
        return false
    end

    if _gemID and _gemID > 0 then
        local _curInlayGemLv = self:GetGemLevelByItemID(_gemID)
        if _curInlayGemLv >= _maxLv then
            return false
        end

        -- ================= 合成升级判断（★ 已改为同组查找）=================
        local _itemCfg = DataConfig.DataItem[_gemID]
        if _itemCfg then
            local strArr = Utils.SplitStr(_itemCfg.HechenTarget, "_")
            if #strArr == 2 then
                local _conbineNeedNum = tonumber(strArr[2])

                local groupList = self:GetSameGroupGemList(pos, _gemID)
                if groupList then
                    local curIdx = nil
                    for i = 1, #groupList do
                        if groupList[i] == _gemID then
                            curIdx = i
                            break
                        end
                    end

                    if curIdx then
                        local _totalNeedNum = 0
                        for i = curIdx, 1, -1 do
                            local checkId = groupList[i]
                            local _haveNum = self.HaveNumCache[checkId]
                            if _haveNum == nil then
                                _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(checkId)
                                self.HaveNumCache[checkId] = _haveNum
                            end

                            if i == curIdx then
                                _totalNeedNum = _conbineNeedNum - 1 - _haveNum
                            else
                                _totalNeedNum = _totalNeedNum * _conbineNeedNum - _haveNum
                            end

                            if _totalNeedNum <= 0 then
                                return true
                            end
                        end
                    end
                end
            end
        end

        -- ================= 有更高等级宝石可替换（★ 只查同组）=================
        if self.GemInlayCfgByPosDic:ContainsKey(pos) then
            local groupList = self:GetSameGroupGemList(pos, _gemID)
            if groupList then
                for i = 1, #groupList do
                    local id = groupList[i]
                    local _targetLv = self:GetGemLevelByItemID(id)
                    if _targetLv > _curInlayGemLv and _targetLv <= _maxLv then
                        local _haveCount = self.HaveNumCache[id]
                        if _haveCount == nil then
                            _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(id)
                            self.HaveNumCache[id] = _haveCount
                        end
                        if _haveCount > 0 then
                            return true
                        end
                    end
                end
            end
        end

        return false

    elseif _gemID == 0 then
        -- ================= 空孔：看背包有没有任意可镶嵌 =================
        if self.GemInlayCfgByPosDic:ContainsKey(pos) then
            local _canInlayGemIDList = self.GemInlayCfgByPosDic[pos].CanInlayGemIDList
            if _canInlayGemIDList then
                for i = 1, #_canInlayGemIDList do
                    local id = _canInlayGemIDList[i]
                    local _targetLv = self:GetGemLevelByItemID(id)
                    if _targetLv <= _maxLv then
                        local _haveCount = self.HaveNumCache[id]
                        if _haveCount == nil then
                            _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(id)
                            self.HaveNumCache[id] = _haveCount
                        end
                        if _haveCount > 0 then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    return false
end


----------- Gosu logic nhiều đá khảm


-- Fairy jade inlaid with red dots
function LianQiGemSystem:SetJadeInlayRedPoint()
    for i=0, EquipmentType.Count - 1 do
        if self:IsJadePosHaveRedPoint(i) then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemJade, true);
            return true
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemJade, false);
    return false
end

function LianQiGemSystem:IsJadePosHaveRedPoint(pos)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if not _equip then
        return false
    end
    if self.JadeInlayInfoByPosDic:ContainsKey(pos) then
        for i=1,GameCenter.LianQiGemSystem.MaxHoleNum do
            if self:IsJadeHoleHaveRedPoint(pos, i) then
                return true
            end
        end
    end
    return false
end

function LianQiGemSystem:IsJadeHoleHaveRedPoint(pos, index)
    local _jadeIDList = self.JadeInlayInfoByPosDic[pos]
    local _jadeID = _jadeIDList[index]
    if _jadeID then
        if _jadeID > 0 then
            local _curInlayGemLv = self:GetJadeLevelByItemID(_jadeID)
            local _itemCfg = DataConfig.DataItem[_jadeID]
            if _itemCfg then
                local strArr = Utils.SplitStr(_itemCfg.HechenTarget, "_")
                if #strArr == 2 then
                    local _conbineNeedNum = tonumber(strArr[2])
                    local _totalNeedNum = 0
                    local _index = 0
                    for i = _curInlayGemLv, 1, -1 do
                        local _haveNum = self.HaveNumCache[_jadeID - _index]
                        if _haveNum == nil then
                            _haveNum = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_jadeID - _index)
                            self.HaveNumCache[_jadeID - _index] = _haveNum
                        end
                        if i == _curInlayGemLv then
                            _totalNeedNum = _conbineNeedNum - 1 - _haveNum
                        else
                            _totalNeedNum = _totalNeedNum * _conbineNeedNum - _haveNum
                        end
                        _index = _index + 1
                    end
                    if _totalNeedNum <= 0 then
                        return true
                    end
                end
            end
            if self.JadeInlayCfgByPosDic:ContainsKey(pos) then
                local _canInlayGemIDList = self.JadeInlayCfgByPosDic[pos].CanInlayJadeIDList
                if _canInlayGemIDList then
                    for i=1, #_canInlayGemIDList do
                        if self:GetJadeLevelByItemID(_canInlayGemIDList[i]) > _curInlayGemLv then
                            local _haveCount = self.HaveNumCache[_canInlayGemIDList[i]]
                            if _haveCount == nil then
                                _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
                                self.HaveNumCache[_canInlayGemIDList[i]] = _haveCount
                            end
                            if _haveCount > 0 then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        elseif _jadeID == 0 then
            if self.JadeInlayCfgByPosDic:ContainsKey(pos) then
                local _canInlayjadeIDList = self.JadeInlayCfgByPosDic[pos].CanInlayJadeIDList
                if _canInlayjadeIDList then
                    for i=1, #_canInlayjadeIDList do
                        local _haveCount = self.HaveNumCache[_canInlayjadeIDList[i]]
                        if _haveCount == nil then
                            _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayjadeIDList[i])
                            self.HaveNumCache[_canInlayjadeIDList[i]] = _haveCount
                        end
                        if _haveCount > 0 then
                            return true
                        end
                    end
                end
            end
            return false
        else
            return false
        end
    end
end

function LianQiGemSystem:SetGemRefineRedPoint()
    for i=0, EquipmentType.Count - 1 do
        if self:IsGemRefinePosHaveRedPoint(i) then
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemRefine, true);
            return true
        end
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LianQiGemRefine, false);
    return false
end

function LianQiGemSystem:IsGemRefinePosHaveRedPoint(pos)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if not _equip then
        return false
    end
    local _refineInfo = self.GemRefineInfoByPosDic[pos]
    if _refineInfo and self:IsPosHaveGem(pos) then
        if _refineInfo.Level + 1 <= self.GemRefineMaxLevel then
            local _refineCfg = DataConfig.DataGemRefining[self:GetGemRefineCfgID(pos, _refineInfo.Level + 1)]
            if _refineCfg then
                local _itemIDList = Utils.SplitStr(_refineCfg.ItemID, "_")
                for i=1, #_itemIDList do
                    local _itemID = tonumber(_itemIDList[i])
                    local _haveCount = self.HaveNumCache[_itemID]
                    if _haveCount == nil then
                        _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_itemID)
                        self.HaveNumCache[_itemID] = _haveCount
                    end
                    if _haveCount > 0 then
                        return true
                    end
                end
            end
            return false
        else
            return false
        end
    end
    return false
end

function LianQiGemSystem:OnItemUpdate(itemID,sender)
    self.HaveNumCache = {}
    if self.AllCanInlayGemIDList:Contains(itemID) then
        self:SetGemInlayRedPoint()
    end
    if self.AllCanInlayJadeIDList:Contains(itemID) then
        self:SetJadeInlayRedPoint()
    end
    local _needUpdateGemRefineRedPoint = false
    for i=1, #self.GemRefineItemIDList do
        if itemID == self.GemRefineItemIDList[i] then
            _needUpdateGemRefineRedPoint = true
            break
        end
    end
    self.HaveNumCache = {}
    if _needUpdateGemRefineRedPoint then self:SetGemRefineRedPoint() end
end


-- Get the total level of gemstones in all parts
function LianQiGemSystem:GetGemTotalLevel()
    local _totalLv = 0
    for i=0, EquipmentType.Count - 1 do
        if self.GemInlayInfoByPosDic:ContainsKey(i) then
            local _gemIDList = self.GemInlayInfoByPosDic[i]
            if _gemIDList then
                for ii=1, #_gemIDList do
                    if _gemIDList[ii] and _gemIDList[ii] > 0 then
                        _totalLv = _totalLv + self:GetGemLevelByItemID(_gemIDList[ii])
                    end
                end
            end
        end
    end
    return _totalLv
end


-- 🔹 Hàm mới lấy slotCount
function LianQiGemSystem:GetSlotCountByLevel(level, pos)
    if self.UseNewSlotConfig then
        -- đọc từ bảng mới DataGemSlotSetting
        local cfg = DataConfig.DataGemSlotSetting[level]
        return cfg and cfg.NumberSlot or 0
    else
        -- fallback về logic cũ
        local cfg = self.GemInlayCfgByPosDic[pos]
        if not cfg then return 0 end

        -- số condition trong config
        local condCount = #cfg.HoleOpenConditions

        -- mỗi condition mở ra 1 slot, nhưng không vượt MaxHole
        local slotCount = math.min(condCount, cfg.MaxHole or condCount)

        return slotCount
    end
end

-- Hàm lấy gem level tối đa
function LianQiGemSystem:GetGemMaxLevelByEquipLevel(level)
    if self.UseNewSlotConfig then
        local cfg = DataConfig.DataGemSlotSetting[level]
        return cfg and cfg.GemstoneLevel or 1
        
    else
        -- fallback từ GemInlayCfgByPosDic cũ
        for _, cfg in pairs(self.GemInlayCfgByPosDic) do
            if cfg and cfg.MaxHole then
                return self.GemMaxLevel or 0
            end
        end
        return 0
    end
end


-- Hàm lấy về max gem được khảm cho equip

function LianQiGemSystem:GetEquipGemMaxLv(equip)
    if not equip then return 0 end
    local quality = equip.ItemInfo and equip.ItemInfo.Quality or 1
    return self:GetGemMaxLevelByEquipLevel(quality) or 0
end


-- Determine whether the current part has gems inlaid based on the location
function LianQiGemSystem:IsPosHaveGem(pos)
    local _haveGem = false
    if self.GemInlayInfoByPosDic:ContainsKey(pos) then
        local _gemList = self.GemInlayInfoByPosDic[pos]
        for i=1, #_gemList do
            if _gemList[i] > 0 then _haveGem = true end
        end
    end
    return _haveGem
end

-- type = 1 means gem, type = 2 means fairy jade. According to the (equipment) location, and the hole index (value range: [1, 6]), the hole unlocking condition is string
function LianQiGemSystem:GetHoleOpenCondition(type, pos, index)
    if index > self.MaxHoleNum then
        Debug.LogError("The index is over the max number!!!!!   index = ", index, " Maxnumber = ", self.MaxHoleNum)
        return nil
    end
    if type == 1 and self.GemInlayCfgByPosDic:ContainsKey(pos) then
        return self.GemInlayCfgByPosDic[pos].HoleOpenConditions[index]
    elseif type == 2 and self.JadeInlayCfgByPosDic:ContainsKey(pos) then
        return self.JadeInlayCfgByPosDic[pos].HoleOpenConditions[index]
    end
    return nil
end

-- type = 1 means gem, type = 2 means fairy jade. According to the (equipment) location, and the hole index (value range: [1, 6]) to obtain: Whether the hole is unlocked (index starts from 1)
function LianQiGemSystem:IsHoleUnlockByIndex(type, pos, index)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if _equip then
        local _condition = self:GetHoleOpenCondition(type, pos, index)
        if _condition then
            return self:IsConditionTrue(pos, _condition)
        end
    end
    return false
end

-- Determine whether the current condition is true. (condition is a string, example: 2_99). Pos is used to obtain the order of equipment
function LianQiGemSystem:IsConditionTrue(pos, condition)
    local _conditionList = Utils.SplitStr(condition, "_")
    if #_conditionList > 1 then
        local _conditionType = tonumber(_conditionList[1])
        local _conditionData = 0
        if type == 1 then
            _conditionData = tonumber(_conditionList[2])
        elseif type == 2 then
            _conditionData = tonumber(_conditionList[3])
        end
        if _conditionType == 1 then
            -- Level 1
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp then
                return _lp.Level >= _conditionData
            end
        elseif _conditionType == 17 then
            -- 17 Equipment Level
            local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
            if _equip then
                if _equip.ItemInfo then
                    return _equip.ItemInfo.Grade >= _conditionData
                else
                    return false
                end
            else
                return false
            end
        end
    end
    return false
end

-- type = 1 means gem, type = 2 means fairy jade. Get the text of the condition. For example: 1_99, return "level 99"; 36_3, return "VIP3"
function LianQiGemSystem:GetConditionDesc(type, pos, index)
    local _condition = self:GetHoleOpenCondition(type, pos, index)
    if _condition then
        local _conditionList = Utils.SplitStr(_condition, "_")
        if #_conditionList > 1 then
            local _conditionType = tonumber(_conditionList[1])
            local _conditionData = tonumber(_conditionList[#_conditionList])
            if _conditionType == 1 then
                -- Level 1
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("LIANQI_GEM_CONDITION_LEVEL"), CommonUtils.GetLevelDesc(_conditionData))
            elseif _conditionType == 19 then
                -- 19 Realm Level
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("LIANQI_GEM_CONDITION_JINGJIE0"), _conditionData)
            elseif _conditionType == 17 then
                -- 17 Equipment Level
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("LIANQI_GEM_CONDITION_EQUIPSTAGE"), _conditionData)
            elseif _conditionType == 118 then
                return UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_LIANQI_EQUIPQUALITY"), CS.Thousandto.Code.Logic.ItemBase.GetQualityString(_conditionData))
            elseif _conditionType == 210 then
                --VIP
                return UIUtils.CSFormat("VIP{0}", _conditionData)
            end
        end
    end
    return ""
end

function LianQiGemSystem:GetGemRefineCfgID(pos, level)
    return pos * 1000 + level
end

function LianQiGemSystem:GetGemLevelByItemID(itemID)
    return itemID % 1000
end

function LianQiGemSystem:GetJadeLevelByItemID(itemID)
    return itemID % 1000
end


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--Gosu chỉnh sửa để 1 item có thể khảm được nhiều ngọc
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------


function LianQiGemSystem:GetGemGroup(itemID)
    return math.floor(itemID / 1000)
end

function LianQiGemSystem:GetSameGroupGemList(pos, gemID)
    if not self.GemInlayCfgByPosDic:ContainsKey(pos) then
        return nil
    end

    local list = self.GemInlayCfgByPosDic[pos].CanInlayGemIDList
    local group = self:GetGemGroup(gemID)

    local result = {}
    for i = 1, #list do
        local id = list[i]
        if self:GetGemGroup(id) == group then
            table.insert(result, id)
        end
    end

    table.sort(result)
    return result
end




---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-------------------------------Gosu chỉnh sửa để 1 item có thể khảm được nhiều ngọc

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------


return LianQiGemSystem
