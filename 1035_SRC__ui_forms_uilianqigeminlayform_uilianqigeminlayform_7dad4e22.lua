-- author:
-- Date: 2019-05-09
-- File: UILianQiGemInlayForm.lua
-- Module: UILianQiGemInlayForm
-- Description: Secondary sub-panel of refining function: gem inlay. The upper panel is: Gem panel (UILianQiGemForm)
------------------------------------------------
local WrapMode = CS.UnityEngine.WrapMode
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local AnimationPartType = CS.Thousandto.Core.Asset.AnimationPartType
local L_UIEquipmentItem = require("UI.Components.UIEquipmentItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local UILianQiGemInlayForm = {
    EquipItemTrs = nil,     -- The currently selected equipment Transform
    AllGemInfosTrs = nil,   -- All Gem Information Transform
    -- BgTexture = nil,
    BackTex = nil,
    CurPos = 0,             -- Current location
    VfxID = 12,             -- Special effect id
    RedGemPosList = {0,1,2,3},
    GreenGemPosList = {4,5,6,7,11,12},
}
local L_HoleItem={}

function UILianQiGemInlayForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UILianQiGemInlayForm_OPEN,self.OnOpen)
    self:RegisterEvent(UIEventDefine.UILianQiGemInlayForm_CLOSE,self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_REFRESHRIGHTINFOS,self.RefreshRightInfos)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GEMINLAYINFO,self.RefreshGemInlayInfo)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UPDATE_REMOVE_GEM, self.RefreshGemRemove)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_GEM_HOLEOPENSTATE, self.RefreshGemOpenState)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated);
end

function UILianQiGemInlayForm:OnOpen(obj, sender)
    if obj then
        self.CurPos = obj
    end
    self.CSForm:Show(sender)
end

function UILianQiGemInlayForm:OnClose(obj,sender)
    self.CSForm:Hide()
end

function UILianQiGemInlayForm:RegUICallback()
    UIUtils.AddBtnEvent(self.AutoUpBtn, self.OnAutoBtnClick, self)
    UIUtils.AddBtnEvent(self.AutoRemoveBtn, self.OnAutoRemoveBtnClick, self)

end

function UILianQiGemInlayForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UILianQiGemInlayForm:OnShowBefore()
    
end

function UILianQiGemInlayForm:OnShowAfter()
    self:RefreshRightInfos(self.CurPos)
    self.SetEquipFrame = 2
    self.AnimPlayer:Stop()
    self.AnimPlayer:AddTrans(self.CenterTrans, 0)
    self.AnimPlayer:AddTrans(self.ButtomTrans, 0.1)
    self.AnimPlayer:Play()
    self.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_gem_1"))


    self:RefreshAutoRemoveRedPoint() -- set redpoint
end

function UILianQiGemInlayForm:OnHideBefore()
    self.ModelSkin:ResetSkin()
    self:ClearAllVfx()
    self.IsAuto = false
end

function UILianQiGemInlayForm:Update(dt)
    self.AnimPlayer:Update(dt)
    if self.SetEquipFrame > 0 then
        self.SetEquipFrame = self.SetEquipFrame - 1
        if self.SetEquipFrame <= 0 then
            self.ModelSkin:SetEquip(FSkinPartCode.Body, 6500001)
            self.ModelSkin:Play("show", AnimationPartType.AllBody, WrapMode.Once, 1)
        end
    end
end

function UILianQiGemInlayForm:ClearAllVfx()
    for i=1, #self.HoleItemList do
        self.HoleItemList[i].VfxSkin:OnDestory()
    end
end

function UILianQiGemInlayForm:OnClickEquipItem(go)
    if self.EquipmentItem.Equipment ~= nil then
        GameCenter.ItemTipsMgr:ShowTips(self.EquipmentItem.Equipment, go, ItemTipsLocation.Equip)
    end
end

function UILianQiGemInlayForm:OnAutoBtnClick()
    if self.IsAuto then
        Utils.ShowPromptByEnum("DontMultipleClick")
        return
    end
    if GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiGemInlay) then
        self.IsAuto = true
        self:OnAutoUp()
    else
        -- local _canInlayGemIDList = GameCenter.LianQiGemSystem.GemInlayCfgByPosDic[1].CanInlayGemIDList
        -- if _canInlayGemIDList then
        --     -- There are no more advanced gems, open the way to obtain
        --     GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_canInlayGemIDList[1])
        -- end

        Utils.ShowPromptByEnum("NotEnounghItem")
    end
end

function UILianQiGemInlayForm:OnClickGem(go)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurPos)

    local _gemID = go.GemID
    local _curSelectIndex = go.Index

    -- if(_gemID == nil) then
    --     Utils.ShowPromptByEnum("LIANQI_GEM_NOTUNLOCK")
    --     return
    -- end

    local quality = (_equip and _equip.ItemInfo and _equip.ItemInfo.Quality) or 1
    local maxLv = 0

    if GameCenter.LianQiGemSystem and GameCenter.LianQiGemSystem.GetGemMaxLevelByEquipLevel then
        maxLv = GameCenter.LianQiGemSystem:GetGemMaxLevelByEquipLevel(quality)
    end

    if not _gemID or maxLv <= 0 then
        Utils.ShowPromptByEnum("LIANQI_GEM_NOTUNLOCK")
        return
    end


    if(_gemID > 0) then
        GameCenter.PushFixEvent(UIEventDefine.UILianQiGemReplaceForm_OPEN, {1, self.CurPos, _curSelectIndex, _gemID}) -- custom ở đây để call và show cái pop up remove gem
        return;
    end

    if (_gemID) > 0 then
        if not _equip then
            Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")
            do return end
        end
        -- There are gems at the current location
        local _haveHigherLvGem = false
        local _curInlayGemLv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(_gemID)
        if GameCenter.LianQiGemSystem.GemInlayCfgByPosDic:ContainsKey(self.CurPos) then
            local _canInlayGemIDList = GameCenter.LianQiGemSystem.GemInlayCfgByPosDic[self.CurPos].CanInlayGemIDList
            if _canInlayGemIDList then
                for i=1, #_canInlayGemIDList do
                    if GameCenter.LianQiGemSystem:GetGemLevelByItemID(_canInlayGemIDList[i]) > _curInlayGemLv then
                        local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
                        if _haveCount > 0 then
                            _haveHigherLvGem = true
                        end
                    end
                end
            end
        end
        if _haveHigherLvGem then
            -- There are more advanced gems, open the replacement interface
            GameCenter.PushFixEvent(UIEventDefine.UILianQiGemReplaceForm_OPEN, {1, self.CurPos, _curSelectIndex})
        else
            -- There are no more advanced gems, open the upgrade interface
            GameCenter.PushFixEvent(UIEventDefine.UILianQiGemUpgradeForm_OPEN, {1, self.CurPos, _curSelectIndex})
        end
    elseif _gemID == 0 then
        if not _equip then
            Utils.ShowPromptByEnum("LIANQI_FORGE_STRENGTHNEEDEQUIP")

            do return end
        end
        if GameCenter.LianQiGemSystem.GemInlayCfgByPosDic:ContainsKey(self.CurPos) then
            -- There are no gems at the current location
            local _haveHigherLvGem = false
            local _canInlayGemIDList = GameCenter.LianQiGemSystem.GemInlayCfgByPosDic[self.CurPos].CanInlayGemIDList
            if _canInlayGemIDList then
                for i=1, #_canInlayGemIDList do
                    local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[i])
                    if _haveCount > 0 then
                        _haveHigherLvGem = true
                        break
                    end
                end
            end
            if _haveHigherLvGem then
                -- There are more advanced gems, open the replacement interface
                GameCenter.PushFixEvent(UIEventDefine.UILianQiGemReplaceForm_OPEN, {1, self.CurPos, _curSelectIndex})
            else
                -- There are no more advanced gems, open the way to obtain
                GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(_canInlayGemIDList[1])
            end
        else
          
            -- print("===========aaaaaaaaaaaaaaaaaaaaaaaaaaa", Inspect(GameCenter.LianQiGemSystem.GemInlayCfgByPosDic))
        end
    elseif _gemID < 0 then
        Utils.ShowPromptByEnum("LIANQI_GEM_NOTUNLOCK")
    end
end

function UILianQiGemInlayForm:FindAllComponents()
    local _myTrans = self.Trans
    self.HoleItemList = List:New()
    self.EquipItemTrs = UIUtils.FindTrans(_myTrans, "Center/UIEquipmentItem")
    self.EquipmentItem = L_UIEquipmentItem:New(self.EquipItemTrs)
    self.EquipmentItem.SingleClick = Utils.Handler(self.OnClickEquipItem, self)
    self.AllGemInfosTrs = UIUtils.FindTrans(_myTrans, "Center/AllGemInfos")
    for i = 0, self.AllGemInfosTrs.childCount - 1 do
        local _item = L_HoleItem:OnFirstShow(self.AllGemInfosTrs:GetChild(i))
        _item.CallBack = Utils.Handler(self.OnClickGem, self)
        self.HoleItemList:Add(_item)
    end
    self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_myTrans, "Center/UIRoleSkinCompoent"))
    self.ModelSkin:OnFirstShow(self.CSForm, FSkinTypeCode.Player, "idle")
    self.ModelSkin.EnableDrag = false
    self.ModelSkin:SetEulerAngles(90, 180, 0)
    self.AutoUpBtn = UIUtils.FindBtn(_myTrans, "Buttom/AutoUpBtn")

    self.AutoUpBtnRedGo = UIUtils.FindGo(_myTrans, "Buttom/AutoUpBtn/RedPoint")

    self.AutoRemoveBtn = UIUtils.FindBtn(_myTrans, "Buttom/ResetBtn")
    self.AutoRemoveBtnRedGo = UIUtils.FindGo(_myTrans, "Buttom/ResetBtn/RedPoint")

    self.CenterTrans = UIUtils.FindTrans(_myTrans, "Center")
    self.CSForm:AddAlphaScaleAnimation(self.CenterTrans, 0, 1, 1.5, 1.5, 1, 1, 0.3, false, false)
    self.ButtomTrans = UIUtils.FindTrans(_myTrans, "Buttom")
    self.CSForm:AddAlphaPosAnimation(self.ButtomTrans, 0, 1, 0, -30, 0.3, false, false)
    self.BackTex = UIUtils.FindTex(_myTrans, "BackTex")
end

-- Function refresh
function UILianQiGemInlayForm:OnFuncUpdated(functioninfo, sender)
    local _funcID = functioninfo.ID

    if FunctionStartIdCode.LianQiGemInlay == _funcID then
        self.AutoUpBtnRedGo:SetActive(functioninfo.IsShowRedPoint)
    end
end

function UILianQiGemInlayForm:RefreshGemOpenState(obj, sender)
    self:SetGemInfos()
end


-- Custom

-- Redpoint cho nút gỡ nhanh
function UILianQiGemInlayForm:RefreshAutoRemoveRedPoint()
    local hasGem = false
    local gemDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic
    if gemDic then
        for pos, list in pairs(gemDic) do
            if list then
                for _, gemId in ipairs(list) do
                    if gemId and gemId > 0 then
                        hasGem = true
                        break
                    end
                end
            end
            if hasGem then break end
        end
    end

    self.AutoRemoveBtnRedGo:SetActive(hasGem)
end



-- Cập nhật lại vòng tròn ngọc lúc remove ngọc
function UILianQiGemInlayForm:RefreshGemRemove(obj, sender)
    local _gemSystem = GameCenter.LianQiGemSystem
    local pos = obj[1]

    if(obj[2] == -1) then
        -- chỉ xử lý nếu là vòng tròn của item hiện tại
        if pos ~= self.CurPos then
            -- print("Bỏ qua vì pos khác CurPos:", pos, self.CurPos)
            return
        end

        -- lấy danh sách gem cũ và số slot
        local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurPos)
        local level = _equip and _equip.ItemInfo.Quality or 1
        local slotCount = _gemSystem:GetSlotCountByLevel(level, self.CurPos)

        -- reset toàn bộ danh sách gem ID về 0
        local _newGemIDList = {}
        for i = 1, slotCount do
            _newGemIDList[i] = 0
        end


        -- cập nhật vào hệ thống
        _gemSystem.GemInlayInfoByPosDic[self.CurPos] = _newGemIDList

        -- gọi lại hàm update UI cho từng slot
        for i = 1, GameCenter.LianQiGemSystem.MaxHoleNum do
            local holeItem = self.HoleItemList[i]
            if holeItem then
                if i <= slotCount then
                    holeItem:UpdateData(_newGemIDList[i], self.CurPos, i)
                else
                    holeItem:UpdateData(-1, self.CurPos, i)  -- slot bị khóa hoặc không tồn tại
                end
            end
        end

        -- print("Đã clear toàn bộ icon gem cho pos =", self.CurPos)

    else
        local slotIndex = obj[2] + 1
        local curPos = self.CurPos

        if pos ~= curPos then return end

        -- trực tiếp ẩn icon UI
        local holeItem = self.HoleItemList[slotIndex]
        if holeItem then
            holeItem:UpdateData(0, curPos, slotIndex)
            -- print(("🪶 [LOCAL] Hide gem UI slot=%d pos=%d"):format(slotIndex, curPos))
        end
       
    end

    
    -- Cập nhật lại red point
    self:RefreshAutoRemoveRedPoint()


end


-- End




-- Chức năng mới remove ngọc

-- One-click remove gems (gỡ từng viên)
function UILianQiGemInlayForm:AutoRemoveGem()
    return false -- này để gỡ từng viên -- tạm disable
end


-- Gỡ toàn bộ gem trong 1 trang bị
function UILianQiGemInlayForm:AutoRemoveAllGemInEquip(equipPos)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(equipPos)
    if not _equip then
        -- print(("Không tìm thấy trang bị ở vị trí %d"):format(equipPos))
        return false
    end

    local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[equipPos]
    if not _gemIDList then
        -- print(("Không có dữ liệu ngọc cho trang bị %d"):format(equipPos))
        return false
    end

    local _hasGem = false
    for j = 1, #_gemIDList do
        local _gemId = _gemIDList[j]
        if _gemId and _gemId > 0 then
            _hasGem = true
            break
        end
    end

    if not _hasGem then
        -- print(("Trang bị %d không có ngọc nào để gỡ"):format(equipPos))
        return false
    end

    -- Gửi request gỡ toàn bộ ngọc trong equip hiện tại
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, equipPos)
    GameCenter.LianQiGemSystem:ReqQuickRemoveGem(1, equipPos, -1) -- gỡ hết
    -- print(("Đã gửi yêu cầu gỡ toàn bộ ngọc cho Equip=%d"):format(equipPos))
    return true
end



function UILianQiGemInlayForm:OnAutoRemove()
    local curPos = self.CurPos
    -- print(("AutoRemove bắt đầu tại equipPos=%d"):format(curPos))

    local list = self:GetAllPosWithGem()
    if not list or #list == 0 then
        -- print("Không có gem nào để gỡ trong toàn bộ trang bị!")
        self.IsAuto = false
        return
    end

    -- Tìm xem tab hiện tại có gem không
    local hasGem = false
    for _, pos in ipairs(list) do
        if pos == curPos then
            hasGem = true
            break
        end
    end

    -- Nếu tab hiện tại không có gem thì nhảy tới tab đầu tiên có gem và gỡ
    if not hasGem then
        local firstPos = list[1]
        -- print(("Tab %d không có gem, chuyển sang tab %d để gỡ"):format(curPos, firstPos))
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, firstPos)
        curPos = firstPos
    end

    -- Gỡ ngọc của tab hiện tại
    local removed = self:AutoRemoveAllGemInEquip(curPos)
    if not removed then
        -- print(("EquipPos %d không có gem để gỡ"):format(curPos))
        self.IsAuto = false
        return
    end

    -- Sau khi gỡ xong, tìm tab tiếp theo có gem (để sẵn cho lượt kế)
    local nextPos = self:FindNextPosWithGem(curPos)
    if nextPos then
        -- print(("Gỡ xong tab %d, chuyển sẵn tới tab %d"):format(curPos, nextPos))
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, nextPos)
    else
        -- print("Đã gỡ hết tất cả gem, không còn tab nào có gem nữa.")
    end

    -- Dừng lại, chờ user click lần kế
    self.IsAuto = false
end



function UILianQiGemInlayForm:FindNextPosWithGem(curPos)
    local list = self:GetAllPosWithGem()
    for _, pos in ipairs(list) do
        if pos > curPos then
            return pos
        end
    end
    return nil
end

-- Trả về danh sách tất cả pos có gem khảm
function UILianQiGemInlayForm:GetAllPosWithGem()
    local result = {}
    local gemDic = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic

    if not gemDic then return result end

    for pos, list in pairs(gemDic) do
        if list then
            for _, gemId in ipairs(list) do
                if gemId and gemId > 0 then
                    table.insert(result, pos)
                    break -- chỉ cần biết có ít nhất 1 gem là đủ
                end
            end
        end
    end

    table.sort(result)
    return result
end


function UILianQiGemInlayForm:OnAutoRemoveBtnClick()
    if self.IsAuto then
        Utils.ShowPromptByEnum("DontMultipleClick")
        return
    end
    self.IsAuto = true
    self:OnAutoRemove()
end


-- End

function UILianQiGemInlayForm:RefreshGemInlayInfo(obj, sender)

    self:RefreshAutoRemoveRedPoint()

    if #obj >= 3 then
        local _pos = obj[1]
        if _pos == self.CurPos then
            local _index = obj[2]
            local _newGemID = obj[3]
            -- GetChild index starts at 0
            if self.HoleItemList[_index] then
                self.HoleItemList[_index]:UpdateData(_newGemID, self.CurPos, _index)
                self.HoleItemList[_index]:PlayVfx()
            end
        end
    end
    for i=1,GameCenter.LianQiGemSystem.MaxHoleNum do
        if self.HoleItemList[i] then
            self.HoleItemList[i].RedGo:SetActive(GameCenter.LianQiGemSystem:IsGemHoleHaveRedPoint(self.CurPos, i))
        end
    end

    if self.IsAuto then
        self.IsAuto = false
    end
end



----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Chỉnh sửa để server không ngậm request khi khảm, valided từ client

-- Chọn viên ngọc TỐT NHẤT có thể khảm
-- Ưu tiên: level cao nhất nhưng <= maxLv và > curLv
-- function UILianQiGemInlayForm:PickBestInlayGem(canList, curLv, maxLv)
--     if not canList or maxLv <= 0 then
--         return nil, 0
--     end

--     for ii = #canList, 1, -1 do
--         local gemId = canList[ii]
--         local gemLv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(gemId)

--         -- Debug.Log(string.format(
--         --     "[GemAuto] Check gemId=%s gemLv=%d curLv=%d maxLv=%d",
--         --     tostring(gemId), gemLv, curLv, maxLv
--         -- ))

--         if gemLv <= maxLv and gemLv > curLv then
--             local haveCount =
--                 GameCenter.ItemContianerSystem:GetItemCountFromCfgId(gemId)

--             if haveCount > 0 then
--                 -- Debug.Log(string.format(
--                 --     "[GemAuto] Pick gemId=%s gemLv=%d",
--                 --     tostring(gemId), gemLv
--                 -- ))
--                 return gemId, gemLv
--             end
--         end
--     end

--     return nil, 0
-- end


function UILianQiGemInlayForm:PickBestInlayGem(canList, curLv, maxLv)
    local gemSys = GameCenter.LianQiGemSystem
    local bestGemID = nil
    local bestLv = curLv

    for i = 1, #canList do
        local gemID = canList[i]
        local lv = gemSys:GetGemLevelByItemID(gemID)

        if lv > bestLv and lv <= maxLv then
            local have = gemSys.HaveNumCache[gemID]
            if have == nil then
                have = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(gemID)
                gemSys.HaveNumCache[gemID] = have
            end

            if have > 0 then
                if lv > bestLv then
                    bestLv = lv
                    bestGemID = gemID
                end
            end
        end
    end

    return bestGemID, bestLv
end


function UILianQiGemInlayForm:AutoInlay()
    for pos = 0, EquipmentType.Count - 1 do
        local equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        if equip then
            local gemList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[pos]

            local maxLv = GameCenter.LianQiGemSystem:GetEquipGemMaxLv(equip)

            if gemList
                and GameCenter.LianQiGemSystem.GemInlayCfgByPosDic:ContainsKey(pos) then

                local canList =
                    GameCenter.LianQiGemSystem.GemInlayCfgByPosDic[pos].CanInlayGemIDList

                if canList then

                    for index = 1, #gemList do
                        local curGemID = gemList[index]
                        local curLv = 0

                        -- ===== ƯU TIÊN KHẢM SLOT TRỐNG TRƯỚC =====
                        if gemList[index] == 0 then
                            local gemId, gemLv = self:PickBestInlayGem(canList, 0, maxLv)
                            if gemId then
                                Debug.Log(string.format(
                                    "[GemAuto] INLAY EMPTY pos=%d slot=%d gem=%d",
                                    pos, index, gemId
                                ))

                                GameCenter.PushFixEvent(
                                    LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
                                    pos
                                )
                                GameCenter.LianQiGemSystem:ReqInlay(1, pos, index, gemId)
                                return true
                            end
                        end

                        -- ===== SAU KHI FULL SLOT MỚI ĐƯỢC NÂNG =====
                        if curGemID and curGemID > 0 then
                            local curLv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(curGemID)

                            -- ❗ CHẶN NÂNG NẾU CÒN SLOT TRỐNG
                            if self:HasEmptyGemSlot(pos) then
                                Debug.Log(string.format(
                                    "[GemAuto] SKIP UPGRADE pos=%d slot=%d vì còn slot trống",
                                    pos, index
                                ))
                            else
                                if curLv < maxLv
                                   and self:IsLowestLevelGemInEquip(pos, curLv)
                                   and self:CanUpgradeGem(curGemID, curLv, curLv + 1) then

                                    Debug.Log(string.format(
                                        "[GemAuto] UPGRADE pos=%d slot=%d gem=%d lv=%d->%d",
                                        pos, index, curGemID, curLv, curLv + 1
                                    ))

                                    GameCenter.PushFixEvent(
                                        LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
                                        pos
                                    )
                                    GameCenter.LianQiGemSystem:ReqUpGradeGem(1, pos, index)
                                    return true
                                end
                            end
                        end


                        -- ⭐ ƯU TIÊN 2: Slot trống HOẶC gem không nâng được → mới xét thay gem mạnh hơn
                        -- ⭐ CHỈ ĐƯỢC REPLACE KHI KHÔNG CÒN SLOT TRỐNG
                        if not self:HasEmptyGemSlot(pos) and not self:HasAnyGemCanUpgrade(pos) then
                            local gemId, gemLv = self:PickBestInlayGem(canList, curLv, maxLv)

                            if gemId then
                                Debug.Log(string.format(
                                    "[GemAuto] REPLACE pos=%d slot=%d with gemID=%d gemLv=%d",
                                    pos, index, gemId, gemLv
                                ))

                                GameCenter.PushFixEvent(
                                    LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
                                    pos
                                )
                                GameCenter.LianQiGemSystem:ReqInlay(1, pos, index, gemId)
                                return true
                            end
                        end

                    end

                    -- for index = 1, #gemList do
                    --     if gemList[index] >= 0 then
                    --         local curLv =
                    --             GameCenter.LianQiGemSystem:GetGemLevelByItemID(
                    --                 gemList[index])

                    --         Debug.Log(string.format(
                    --             "[GemAuto] pos=%d slot=%d curLv=%d maxLv=%d",
                    --             pos, index, curLv, maxLv
                    --         ))

                    --         local gemId, gemLv =
                    --             self:PickBestInlayGem(canList, curLv, maxLv)

                    --         if gemId then
                    --             GameCenter.PushFixEvent(
                    --                 LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
                    --                 pos
                    --             )

                    --             GameCenter.LianQiGemSystem:ReqInlay(
                    --                 1, pos, index, gemId
                    --             )

                    --             return true
                    --         end
                    --     end
                    -- end
                end
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------------------------------------------------------------------------------
-- chỉnh sửa auto nâng
function UILianQiGemInlayForm:HasEmptyGemSlot(pos)
    local gemList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[pos]
    if not gemList then return false end

    for i = 1, #gemList do
        if gemList[i] == 0 then
            return true
        end
    end
    return false
end

function UILianQiGemInlayForm:IsLowestLevelGemInEquip(pos, curLv)
    local gemList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[pos]
    if not gemList then
        return false
    end

    local minLv = nil

    for i = 1, #gemList do
        local gemID = gemList[i]
        if gemID and gemID > 0 then
            local lv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(gemID)
            if not minLv or lv < minLv then
                minLv = lv
            end
        end
    end

    if not minLv then
        return false
    end

    return curLv == minLv
end


function UILianQiGemInlayForm:HasAnyGemCanUpgrade(pos)
    local gemList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[pos]
    if not gemList then return false end

    local equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    if not equip then return false end

    local maxLv = GameCenter.LianQiGemSystem:GetEquipGemMaxLv(equip)

    for i = 1, #gemList do
        local gemId = gemList[i]
        if gemId and gemId > 0 then
            local lv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(gemId)

            if lv < maxLv and self:CanUpgradeGem(gemId, lv, lv + 1) then
                return true -- chỉ cần 1 viên nâng được là phải ưu tiên nâng
            end
        end
    end

    return false
end



--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Các hàm liên quan để auto nâng ngọc đỏ ngọc xanh
function UILianQiGemInlayForm:FindLowestGemSlot(posList)
    local best = {
        gemLv = GameCenter.LianQiGemSystem.GemMaxLevel,
        gemID = nil,
        pos = 0,
        index = 0,
        maxLv = 0
    }

    for i = 1, #posList do
        local pos = posList[i]
        local equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        local equipMaxLv = GameCenter.LianQiGemSystem:GetEquipGemMaxLv(equip)

        if equip and equipMaxLv > 0 then
            local gemList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[pos]
            if gemList then
                for j = 1, #gemList do
                    local gemID = gemList[j]
                    if gemID and gemID > 0 then
                        local lv = GameCenter.LianQiGemSystem:GetJadeLevelByItemID(gemID)
                        -- 🔥 check maxLvEquip ở đây
                        if lv < best.gemLv and lv < equipMaxLv then
                            best.gemLv = lv
                            best.gemID = gemID
                            best.pos = pos
                            best.index = j
                            best.maxLv = equipMaxLv
                        end
                    end
                end
            end
        end
    end

    if best.gemID then
        return best
    end
    return nil
end

---Hàm check đủ nguyên liệu nâng (GIỮ NGUYÊN LOGIC CŨ, chỉ giới hạn lv)
function UILianQiGemInlayForm:CanUpgradeGem(gemID, curLv, targetLv)
    local cfg = DataConfig.DataItem[gemID]
    if not cfg or not cfg.HechenTarget or cfg.HechenTarget == "" then
        return false
    end

    local target = Utils.SplitStr(cfg.HechenTarget, "_")
    local needNum = tonumber(target[2])
    if not needNum then return false end

    local itemID = gemID
    local allList = List:New()
    for i = curLv, 1, -1 do
        allList:Add(itemID)
        itemID = itemID - 1
    end

    local bagCount = Dictionary:New()
    local bagItems = GameCenter.ItemContianerSystem:GetItemListByCfgidList(allList)
    if bagItems then
        for i = 1, bagItems.Count do
            local it = bagItems[i - 1]
            bagCount[it.CfgID] = (bagCount[it.CfgID] or 0) + it.Count
        end
    end

    local totalNeed = 0
    itemID = gemID
    for i = curLv, 1, -1 do
        local have = bagCount[itemID] or 0
        if i == curLv then
            totalNeed = needNum - 1 - have
        else
            totalNeed = totalNeed * needNum - have
        end
        if i > 1 then itemID = itemID - 1 end
    end

    return totalNeed <= 0
end

---
function UILianQiGemInlayForm:AutoUpRedMater()
    local slot = self:FindLowestGemSlot(self.RedGemPosList)
    if not slot then return false end

    local nextLv = slot.gemLv + 1
    if nextLv > slot.maxLv then
        return false
    end

    if self:CanUpgradeGem(slot.gemID, slot.gemLv, nextLv) then
        GameCenter.PushFixEvent(
            LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
            slot.pos
        )
        GameCenter.LianQiGemSystem:ReqUpGradeGem(1, slot.pos, slot.index)
        return true
    end
    return false
end
---
function UILianQiGemInlayForm:AutoUpGreenMater()
    local slot = self:FindLowestGemSlot(self.GreenGemPosList)
    if not slot then return false end

    local nextLv = slot.gemLv + 1
    if nextLv > slot.maxLv then
        return false
    end

    if self:CanUpgradeGem(slot.gemID, slot.gemLv, nextLv) then
        GameCenter.PushFixEvent(
            LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
            slot.pos
        )
        GameCenter.LianQiGemSystem:ReqUpGradeGem(1, slot.pos, slot.index)
        return true
    end
    return false
end


----- Hàm xử lý redpoint
-- function UILianQiGemInlayForm:CanAutoUpAnyGem()
--     -- red + green đều được
--     local slot = FindLowestGemSlot(self.RedGemPosList)
--     if slot then
--         if slot.gemLv + 1 <= slot.maxLv
--            and CanUpgradeGem(slot.gemID, slot.gemLv, slot.gemLv + 1) then
--             return true
--         end
--     end

--     slot = FindLowestGemSlot(self.GreenGemPosList)
--     if slot then
--         if slot.gemLv + 1 <= slot.maxLv
--            and CanUpgradeGem(slot.gemID, slot.gemLv, slot.gemLv + 1) then
--             return true
--         end
--     end

--     return false
-- end

function UILianQiGemInlayForm:RefreshAutoUpRedPoint()
    local canUp = self:CanAutoUpAnyGem()
    self.AutoUpBtnRedGo:SetActive(canUp)
    -- self.AutoUpBtnRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiGemInlay))
end






--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Các hàm xử lý liên quan đến khảm nhiều ngọc trong vật phẩm


function UILianQiGemInlayForm:CanAutoUpAnyGem()
    local slot = self:FindLowestGemSlot_All()
    if not slot then return false end

    if slot.gemLv + 1 <= slot.maxLv and
       self:CanUpgradeGem(slot.gemID, slot.gemLv, slot.gemLv + 1) then
        return true
    end

    return false
end



function UILianQiGemInlayForm:FindLowestGemSlot_All()
    local best = {
        gemLv = GameCenter.LianQiGemSystem.GemMaxLevel,
        gemID = nil,
        pos = 0,
        index = 0,
        maxLv = 0
    }

    local gemSys = GameCenter.LianQiGemSystem

    gemSys.GemInlayCfgByPosDic:Foreach(function(pos, cfg)

        local equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
        if not equip then return end

        local equipMaxLv = gemSys:GetEquipGemMaxLv(equip)
        if equipMaxLv <= 0 then return end

        local gemList = gemSys.GemInlayInfoByPosDic[pos]
        if not gemList then return end

        for i = 1, #gemList do
            local gemID = gemList[i]
            if gemID and gemID > 0 then
                local lv = gemSys:GetGemLevelByItemID(gemID)
                if lv < best.gemLv and lv < equipMaxLv then
                    best.gemLv = lv
                    best.gemID = gemID
                    best.pos = pos
                    best.index = i
                    best.maxLv = equipMaxLv
                end
            end
        end
    end)

    if best.gemID then
        return best
    end
    return nil
end

function UILianQiGemInlayForm:AutoUpgradeAnyGem()
    local slot = self:FindLowestGemSlot_All()
    if not slot then return false end

    local nextLv = slot.gemLv + 1
    if nextLv > slot.maxLv then
        return false
    end

    if self:CanUpgradeGem(slot.gemID, slot.gemLv, nextLv) then
        GameCenter.PushFixEvent(
            LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP,
            slot.pos
        )
        GameCenter.LianQiGemSystem:ReqUpGradeGem(1, slot.pos, slot.index)
        return true
    end

    return false
end



--------------------------------------------------------------------------------------------------------------------------------------------------------



-- One-click inlay
-- function UILianQiGemInlayForm:AutoInlay()
--     for i=0, EquipmentType.Count - 1 do
--         local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(i)
--         if _equip then
--             local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[i]


--             local quality = (_equip and _equip.ItemInfo and _equip.ItemInfo.Quality) or 1
--             local maxLv = 0

--             if GameCenter.LianQiGemSystem and GameCenter.LianQiGemSystem.GetGemMaxLevelByEquipLevel then
--                 maxLv = GameCenter.LianQiGemSystem:GetGemMaxLevelByEquipLevel(quality)
--             end

--             if _gemIDList then
--                 for j = 1, #_gemIDList do
--                     if _gemIDList[j] >= 0 then
--                         local _curInlayGemLv = GameCenter.LianQiGemSystem:GetGemLevelByItemID(_gemIDList[j])
--                         if GameCenter.LianQiGemSystem.GemInlayCfgByPosDic:ContainsKey(i) then
--                             local _canInlayGemIDList = GameCenter.LianQiGemSystem.GemInlayCfgByPosDic[i].CanInlayGemIDList
--                             if _canInlayGemIDList then
--                                 for ii= #_canInlayGemIDList, 1, -1 do


--                                     Debug.Log("============_curInlayGemLv====_curInlayGemLv_curInlayGemLv_curInlayGemLv===", _curInlayGemLv)
--                                     Debug.Log("============_curInlayGemLv====maxLvmaxLvmaxLvmaxLvmaxLvmaxLv===", maxLv)
--                                     Debug.Log("============_curInlayGemLv====maxLvmaxLvmaxLvmaxLvmaxLvmaxLv===",  _canInlayGemIDList[ii])

--                                     if GameCenter.LianQiGemSystem:GetGemLevelByItemID(_canInlayGemIDList[ii]) > _curInlayGemLv then
--                                         local _haveCount = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(_canInlayGemIDList[ii])
--                                         if _haveCount > 0 then
--                                             GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, i)
--                                             GameCenter.LianQiGemSystem:ReqInlay(1, i, j, _canInlayGemIDList[ii])
--                                             return true
--                                         end
--                                     end
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end
--     return false
-- end

-- One-click upgrade to rubies
-- function UILianQiGemInlayForm:AutoUpRedMater()
--     local _gemLv = GameCenter.LianQiGemSystem.GemMaxLevel
--     local _curInlayID
--     local _curPos = 0
--     local _curIndex = 0
--     for i=1, #self.RedGemPosList do
--         local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.RedGemPosList[i])
--         if _equip then
--             local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[self.RedGemPosList[i]]
--             if _gemIDList then
--                 for j = 1, #_gemIDList do
--                     if _gemIDList[j] > 0 then
--                         local _curInlayLv = GameCenter.LianQiGemSystem:GetJadeLevelByItemID(_gemIDList[j])
--                         if _curInlayLv < _gemLv then
--                             _curInlayID = _gemIDList[j]
--                             _gemLv = _curInlayLv
--                             _curPos = self.RedGemPosList[i]
--                             _curIndex = j
--                         end
--                     end

--                 end
--             end
--         end
--     end
--     if _gemLv ~=  GameCenter.LianQiGemSystem.GemMaxLevel then
--         local _allInlayItemIDlist = List:New()
--         local _itemID = _curInlayID
--         local _curInlayItemCfg = DataConfig.DataItem[_curInlayID]
--         for i = _gemLv, 1, -1 do
--             _allInlayItemIDlist:Add(_itemID)
--             _itemID = _itemID - 1
--         end
--         local _bagItemCountDic = Dictionary:New()
--         local _bagItemList = GameCenter.ItemContianerSystem:GetItemListByCfgidList(_allInlayItemIDlist)
--         if _bagItemList then
--             for i = 1, _bagItemList.Count do
--                 if _bagItemCountDic:ContainsKey(_bagItemList[i-1].CfgID) then
--                     local _count = _bagItemCountDic[_bagItemList[i-1].CfgID]
--                     _count = _count + _bagItemList[i-1].Count
--                     _bagItemCountDic[_bagItemList[i - 1].CfgID] = _count
--                 else
--                     _bagItemCountDic:Add(_bagItemList[i-1].CfgID, _bagItemList[i-1].Count)
--                 end
--             end
--         end
--         if _curInlayItemCfg.HechenTarget and _curInlayItemCfg.HechenTarget ~= "" then
--             local _targetList = Utils.SplitStr(_curInlayItemCfg.HechenTarget, "_")
--             if _targetList[2] then
--                 local _conbineNeedNum = tonumber(_targetList[2])
--                 local _totalNeedNum = 0
--                 _itemID = _curInlayID
--                 for i = _gemLv, 1, -1 do
--                     local _haveNum = 0
--                     if _bagItemCountDic[_itemID] and _bagItemCountDic[_itemID] > 0 then
--                         _haveNum = _bagItemCountDic[_itemID]
--                     end
--                     if i == _gemLv then
--                         _totalNeedNum = _conbineNeedNum - 1 - _haveNum
--                     else
--                         _totalNeedNum = _totalNeedNum * _conbineNeedNum - _haveNum
--                     end
--                     if i > 1 then
--                         _itemID = _itemID - 1
--                     end
--                 end
--                 local _conbineNeedMoney = _totalNeedNum --* _curInlayItemCfg.ItemPrice
--                 if _conbineNeedMoney <= 0 then
--                     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, _curPos)
--                     GameCenter.LianQiGemSystem:ReqUpGradeGem(1, _curPos, _curIndex)
--                     return true
--                 end
--             end
--         end
--     end
--     return false
-- end

-- -- Upgrade emeralds with one click
-- function UILianQiGemInlayForm:AutoUpGreenMater()
--     local _gemLv = GameCenter.LianQiGemSystem.GemMaxLevel
--     local _curInlayID
--     local _curPos = 0
--     local _curIndex = 0
--     for i=1, #self.GreenGemPosList do
--         local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.GreenGemPosList[i])
--         if _equip then
--             local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[self.GreenGemPosList[i]]
--             if _gemIDList then
--                 for j = 1, #_gemIDList do
--                     if _gemIDList[j] > 0 then
--                         local _curInlayLv = GameCenter.LianQiGemSystem:GetJadeLevelByItemID(_gemIDList[j])
--                         if _curInlayLv < _gemLv then
--                             _curInlayID = _gemIDList[j]
--                             _gemLv = _curInlayLv
--                             _curPos = self.GreenGemPosList[i]
--                             _curIndex = j
--                         end
--                     end

--                 end
--             end
--         end
--     end
--     if _gemLv ~=  GameCenter.LianQiGemSystem.GemMaxLevel then
--         local _allInlayItemIDlist = List:New()
--         local _itemID = _curInlayID
--         local _curInlayItemCfg = DataConfig.DataItem[_curInlayID]
--         for i = _gemLv, 1, -1 do
--             _allInlayItemIDlist:Add(_itemID)
--             _itemID = _itemID - 1
--         end
--         local _bagItemCountDic = Dictionary:New()
--         local _bagItemList = GameCenter.ItemContianerSystem:GetItemListByCfgidList(_allInlayItemIDlist)
--         if _bagItemList then
--             for i = 1, _bagItemList.Count do
--                 if _bagItemCountDic:ContainsKey(_bagItemList[i-1].CfgID) then
--                     local _count = _bagItemCountDic[_bagItemList[i-1].CfgID]
--                     _count = _count + _bagItemList[i-1].Count
--                     _bagItemCountDic[_bagItemList[i - 1].CfgID] = _count
--                 else
--                     _bagItemCountDic:Add(_bagItemList[i-1].CfgID, _bagItemList[i-1].Count)
--                 end
--             end
--         end
--         if _curInlayItemCfg.HechenTarget and _curInlayItemCfg.HechenTarget ~= "" then
--             local _targetList = Utils.SplitStr(_curInlayItemCfg.HechenTarget, "_")
--             if _targetList[2] then
--                 local _conbineNeedNum = tonumber(_targetList[2])
--                 local _totalNeedNum = 0
--                 _itemID = _curInlayID
--                 for i = _gemLv, 1, -1 do
--                     local _haveNum = 0
--                     if _bagItemCountDic[_itemID] and _bagItemCountDic[_itemID] > 0 then
--                         _haveNum = _bagItemCountDic[_itemID]
--                     end
--                     if i == _gemLv then
--                         _totalNeedNum = _conbineNeedNum - 1 - _haveNum
--                     else
--                         _totalNeedNum = _totalNeedNum * _conbineNeedNum - _haveNum
--                     end
--                     if i > 1 then
--                         _itemID = _itemID - 1
--                     end
--                 end
--                 local _conbineNeedMoney = _totalNeedNum --* _curInlayItemCfg.ItemPrice
--                 if _conbineNeedMoney <= 0 then
--                     GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_GEM_SELECTEQUIP, _curPos)
--                     GameCenter.LianQiGemSystem:ReqUpGradeGem(1, _curPos, _curIndex)
--                     return true
--                 end
--             end
--         end
--     end
--     return false
-- end

-- One-click upgrade logic
function UILianQiGemInlayForm:OnAutoUp()
    -- local _have = self:AutoInlay()
    -- if not _have then
    --     _have = self:AutoUpRedMater()
    -- end
    -- if not _have then
    --     _have = self:AutoUpGreenMater()
    -- end
    -- if not _have then
    --     self.IsAuto = false
    -- end

    local _have = self:AutoInlay()

    if not _have then
        _have = self:AutoUpgradeAnyGem()
    end

    if not _have then
        self.IsAuto = false
    end
end

function UILianQiGemInlayForm:RefreshRightInfos(obj, sender)
    self.CurPos = obj
    self:SetEquipItem(obj)
    self:SetGemInfos()
    self.AutoUpBtnRedGo:SetActive(GameCenter.MainFunctionSystem:GetAlertFlag(FunctionStartIdCode.LianQiGemInlay))
end

function UILianQiGemInlayForm:SetEquipItem(pos)
    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(pos)
    local _starLv = 0
    if _equip ~= nil then
        self.EquipmentItem:UpdateEquipment(_equip, pos, _starLv)
    else
        self.EquipmentItem:UpdateEquipmentByType(pos, _starLv)
    end
end





function UILianQiGemInlayForm:SetGemInfos()
    local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[self.CurPos]

    local _equip = GameCenter.EquipmentSystem:GetPlayerDressEquip(self.CurPos)
    local level = _equip and _equip.ItemInfo.Quality or 1

    local slotCount = GameCenter.LianQiGemSystem:GetSlotCountByLevel(level, self.CurPos)

    for i = 1, GameCenter.LianQiGemSystem.MaxHoleNum do
        if self.HoleItemList[i] then
            if i <= slotCount then
                -- self.HoleItemList[i].RootGO:SetActive(true)
                -- if(_gemIDList[i] == -1) then
                --     self.HoleItemList[i]:UpdateData(0, self.CurPos, i)
                -- else
                --     self.HoleItemList[i]:UpdateData(_gemIDList[i], self.CurPos, i)
                -- end
                self.HoleItemList[i]:UpdateData(_gemIDList[i], self.CurPos, i)
                    
            else
                -- self.HoleItemList[i]:UpdateData(_gemIDList[i], self.CurPos, i)
                -- self.HoleItemList[i].RootGO:SetActive(false) -- ẩn luôn
                -- Slot chưa mở nhưng vẫn hiển thị trạng thái khóa
                local holeItem = self.HoleItemList[i]
                if holeItem then
                    holeItem.RootGO:SetActive(true)
                    holeItem:ShowLockedIconOnly()
                end
            end
        end
    end
end


-- old code

-- function UILianQiGemInlayForm:SetGemInfos()
--     local _gemIDList = GameCenter.LianQiGemSystem.GemInlayInfoByPosDic[self.CurPos]
--     if _gemIDList then
--         for i=1, GameCenter.LianQiGemSystem.MaxHoleNum do
--             if self.HoleItemList[i] then
--                 self.HoleItemList[i]:UpdateData(_gemIDList[i], self.CurPos, i)
--             end
--         end
--     end
-- end

function L_HoleItem:OnFirstShow(trans)
    local _M = Utils.DeepCopy(self)
    _M.RootTrans = trans
    _M.RootGO = trans.gameObject
    _M:FindAllComponents()
    return _M
end
function L_HoleItem:FindAllComponents()
    self.LockGo = UIUtils.FindGo(self.RootTrans, "Lock")
    self.PlusGo = UIUtils.FindGo(self.RootTrans, "Plus")
    self.UnlockConditionGo = UIUtils.FindGo(self.RootTrans, "UnlockCondition")
    self.UnlockConditionLabel = UIUtils.FindLabel(self.RootTrans, "UnlockCondition")
    self.RedGo = UIUtils.FindGo(self.RootTrans, "RedPoint")
    self.GemGo = UIUtils.FindGo(self.RootTrans, "Gem")
    self.GemIcon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(self.RootTrans, "Gem/GemIcon"))
    self.GemNameLabel = UIUtils.FindLabel(self.RootTrans, "Gem/GemInfo/GemName")
    self.GemAtt1Label = UIUtils.FindLabel(self.RootTrans, "Gem/GemInfo/GemAttr1")
    self.GemAtt2Label = UIUtils.FindLabel(self.RootTrans, "Gem/GemInfo/GemAttr2")
    self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.RootTrans, "UIVfxSkinCompoent"))
    local _btn = UIUtils.FindBtn(self.RootTrans)
    if _btn then
        UIUtils.AddBtnEvent(_btn, self.OnClickGem, self)
    end
end

function L_HoleItem:ShowLockedIconOnly()
    self.LockGo:SetActive(true)
    self.GemGo:SetActive(false)
    self.PlusGo:SetActive(false)
    self.UnlockConditionGo:SetActive(false)
    self.RedGo:SetActive(false)
end


function L_HoleItem:OnClickGem()
    if self.CallBack then
        self.CallBack(self)
    end
end

function L_HoleItem:UpdateData(gemid, CurPos, index)
    self.GemID = gemid
    self.Index = index
    if gemid then
        -- >= 0, indicating that the hole position has been unlocked
        if gemid >= 0 then
            self.LockGo:SetActive(false)
            self.UnlockConditionGo:SetActive(false)
            if gemid > 0 then
                -- Greater than 0 means unlocked and gems are inlaid
                self.GemGo:SetActive(true)
                self.PlusGo:SetActive(false)
                local _itemCfg = DataConfig.DataItem[gemid]
                if _itemCfg then
                    self.GemIcon:UpdateIcon(_itemCfg.Icon)
                    self:SetGemNameAndAttrs(_itemCfg)

                else
                    self.GemIcon:UpdateIcon(0)
                end
            else
                -- Equal to 0, means unlocked, no gemstones are inlaid
                self.GemGo:SetActive(false)
                self.PlusGo:SetActive(true)
            end
        else
            -- Less than 0 means that it is not unlocked
            self.LockGo:SetActive(true)
            self.UnlockConditionGo:SetActive(false) --
            local _conditionText = GameCenter.LianQiGemSystem:GetConditionDesc(1, CurPos, index)
            UIUtils.SetTextByString(self.UnlockConditionLabel, _conditionText)
            self.GemGo:SetActive(false)
            self.PlusGo:SetActive(false)
        end
        self.RedGo:SetActive(GameCenter.LianQiGemSystem:IsGemHoleHaveRedPoint(CurPos, index))
    else
        self.RedGo:SetActive(false)
    end
end

function L_HoleItem:SetGemNameAndAttrs(itemCfg)
    UIUtils.SetTextByStringDefinesID(self.GemNameLabel, itemCfg._Name)
    local _attrs = Utils.SplitStrByTableS(itemCfg.EffectNum, {";", "_"})
    if _attrs[1] then
        -- self.GemAtt1Label.gameObject:SetActive(true)
        -- The first parameter of the effect is 1, indicating that the attribute is added
        if _attrs[1][1] == 1 then
            UIUtils.SetTextByPropNameAndValue(self.GemAtt1Label, tonumber(_attrs[1][2]), tonumber(_attrs[1][3]))
        else
            UIUtils.ClearText(self.GemAtt1Label)
        end
    else
        UIUtils.ClearText(self.GemAtt1Label)
    end
    if _attrs[2] then
        -- _gemAttr2Lab.gameObject:SetActive(true)
        if _attrs[2][1] == 1 then
            UIUtils.SetTextByPropNameAndValue(self.GemAtt2Label, tonumber(_attrs[2][2]), tonumber(_attrs[2][3]))
        else
            UIUtils.ClearText(self.GemAtt2Label)
        end
    else
        UIUtils.ClearText(self.GemAtt2Label)
    end
end

function L_HoleItem:PlayVfx()
    self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 12, LayerUtils.GetAresUILayer())
end

return UILianQiGemInlayForm