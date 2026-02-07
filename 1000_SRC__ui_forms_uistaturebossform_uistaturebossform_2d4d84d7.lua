------------------------------------------------
--author:
--Date: 2019-08-21
--File: UIStatureBossForm.lua
--Module: UIStatureBossForm
--Description: Realm BOSS panel
------------------------------------------------

local L_BossItem = require("UI.Forms.UIStatureBossForm.UIStatureBossItem")
local L_AttrItem = require("UI.Forms.UIHunShouShenLinForm.UIHunShouShenLinAttrItem")
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"

local UIStatureBossForm = {
    LeftTrs = nil,                      --Transform named "left" on the left
    BossCloneRoot = nil,                --boss cloning root node
    BossCloneRootPanel = nil,           --The panel control of the root node
    BossCloneRootScrollView = nil,      --The ScrollView component on the root node of the boss cloning
    BossCloneRootGrid = nil,            --The Grid component on the boss cloning root node
    BossItem = nil,                     --Single BOSS component
    BossItemList = List:New(),          --Boss List
    CurSelectBossItem = nil,            --The currently selected BOSS
    AlertEmpty = nil,

    RightTrans = nil,                    --
    Item = nil,                         --Props clone
    ItemList = List:New(),              --Props List
    ItemCloneRootGrid = nil,            --The grid component on the prop cloning root node
    DropItem = nil,
    DropList = List:New(),
    DropGrid = nil,
    BottomTrs = nil,                    --Transform named "Bottom" at the bottom
    BtnDescLabel = nil,                 --button displays content label
    RecommandPowerLabel = nil,          --Recommended entry button label
    GotoBtn = nil,                      --Enter button
    Texture = nil,
    ModelBotTexture = nil,
    FootBotTexture = nil, 
    CurSelectBossID = 0,                --The currently selected bossid

    ArrowLeftBtn = nil,
    ArrowRightBtn = nil,

    BossCount = 0,
    StartIndexShow = 1,
    EndIndexShow = 3,
    CurIndexShow = 1,
    IndexList = List:New(),

    FirstGridPosX = 0,
    CurGridPosX = 0,
    LastX = 0,
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function UIStatureBossForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIStatureBossForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIStatureBossForm_CLOSE, self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_UIPDATESTATUREBOSSDATA, self.SetLeftBossList)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_ADDSTATUREBOSSCOUNT, self.AddSuccess)
end

--Register events on the UI, such as click events, etc.
function UIStatureBossForm:RegUICallback()
    UIUtils.AddBtnEvent(self.GotoBtn, self.OnClickGotoBtn, self)
    UIUtils.AddBtnEvent(self.AddCountBtn, self.OnAddCountBtnClick, self)
    UIUtils.AddBtnEvent(self.HelpBtn, self.OnClickHelpBtn)

    UIUtils.AddBtnEvent(self.ArrowLeftBtn, self.OnClickLeftBtn, self)
    UIUtils.AddBtnEvent(self.ArrowRightBtn, self.OnClickRightBtn, self)
end

function UIStatureBossForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
	self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
end

function UIStatureBossForm:OnShowBefore()
    self.PlayAnim = true
end

function UIStatureBossForm:OnShowAfter()
    local _msg = ReqMsg.MSG_copyMap.ReqOpenBossStatePanle:New()
    _msg:Send()
    self.CSForm:LoadTexture(self.FootBotTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_foot_boss"))
    self.StartIndexShow = 1
    self.EndIndexShow = 3
end

function UIStatureBossForm:OnHideBefore()
    self.CurSelectBossItem = nil
end

function UIStatureBossForm:Update(dt)
    self.AnimPlayer:Update(dt)
    
    if self:IsScrolling() then
        self:OnGridScroll()
    else
        UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
        self.CurGridPosX = self.FirstGridPosX
    end
end

function UIStatureBossForm:IsScrolling()
    local currentX = self.BossCloneRootGrid.transform.position.x
    local isMoving = currentX ~= self.LastX
    self.LastX = currentX
    
    return isMoving
end

function UIStatureBossForm:OnGridScroll()

    self.CurGridPosX = self.BossCloneRootGrid.transform.position.x

    if self.CurGridPosX < (self.FirstGridPosX + self.FirstGridPosX * 0.5) then
        if self.CurIndexShow < self.BossCount then

            UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
            self:OnClickRightBtn()
        end
    end

    if self.CurGridPosX > (self.FirstGridPosX - self.FirstGridPosX * 0.5) then
        if self.CurIndexShow <= self.BossCount and self.CurIndexShow > 1 then

            UnityUtils.SetPosition(self.BossCloneRootGrid.transform, self.FirstGridPosX, self.BossCloneRootGrid.transform.position.y, self.BossCloneRootGrid.transform.position.z)
            self:OnClickLeftBtn()
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Set the BOSS list
function UIStatureBossForm:SetLeftBossList(obj, sender)
    local _clickGameObj = nil
    --This parameter is used to calculate the position of automatic jump
    local _index = 1
    local _countIndex = 1
    local _go = nil
    local _dic = GameCenter.StatureBossSystem:GetBossInfoDic()

    local _animList = nil
    if self.PlayAnim then
        _animList = List:New()
        self.AnimPlayer:Stop()
    end

    -- xử lý data chỉ lấy ra mỗi lần tối đa 3 boss
    self.BossCount = 0
    local BossDatas = List:New()
    self.IndexList = List:New()
    _dic:Foreach(function(k, v)
        if v.IsShow then
            self.BossCount = self.BossCount + 1
            BossDatas:Add(v)
            self.IndexList:Add(v.Layer)
        end
    end)

    -- ẩn/hiện nếu còn boss
    self.ArrowLeftBtn.gameObject:SetActive(self.BossCount > 0)
    self.ArrowRightBtn.gameObject:SetActive(self.BossCount > 0)
    self.LeftTrs.gameObject:SetActive(self.BossCount > 0)
    self.RightTrans.gameObject:SetActive(self.BossCount > 0)

    if self.BossCount == 0 then
        self.AlertEmpty.gameObject:SetActive(true)
    else
        self.BossItemList = List:New()
        local _bossGridTrans = UIUtils.FindTrans(self.LeftTrs, "BossRoot/Grid")
        for i = 0, _bossGridTrans.childCount - 1 do
            self.BossItem = L_BossItem:OnFirstShow(_bossGridTrans:GetChild(i))
            -- self.BossItem.CallBack = Utils.Handler(self.OnClickLeftBoss, self)
            self.BossItemList:Add(self.BossItem)
        end

        for k = 1, #BossDatas do
            if k >= self.StartIndexShow and k <= self.EndIndexShow then
                if _countIndex <= #self.BossItemList then
                    _go = self.BossItemList[_countIndex]
                else
                    _go = self.BossItem:Clone()
                    -- _go.CallBack = Utils.Handler(self.OnClickLeftBoss, self)
                    self.BossItemList:Add(_go)
                end
                if _go then
                    if not self.AnimPlayer.Playing then
                        _go.Go:SetActive(true)
                    end
                    _go:OnSetSelect(false)
                    _go:SetInfo(BossDatas[k])

                    local _selfPower = GameCenter.GameSceneSystem:GetLocalPlayerFightPower()
                    local _needPower = _go.ItemData.BossCfg.Power
                    if _selfPower >= _needPower and BossDatas[k].Type == StatureBossState.Alive and not self.CurSelectBossItem then
                        _index = _countIndex
                        _clickGameObj = _go
                    end

                    -- hiển thị VP hiếm PreciousDrop
                    local _career = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
                    local _bossCfg = _go.ItemData.BossCfg
                    local _rewardItemList = Utils.SplitStrByTableS(_bossCfg.PreciousDrop)
                    local _rewardCount = #_rewardItemList

                    local ItemCloneRootGrid = UIUtils.FindGrid(self.BossItemList[_countIndex].Trans, "FristCrossGo/ItemRoot/Grid")
                    local ItemCloneRootScroll = UIUtils.FindScrollView(self.BossItemList[_countIndex].Trans, "FristCrossGo/ItemRoot")
                    local _itemGridTrans = UIUtils.FindTrans(self.BossItemList[_countIndex].Trans, "FristCrossGo/ItemRoot/Grid")
                    local Item = nil
                    local ItemList = List:New()
                    for i = 0, _itemGridTrans.childCount - 1 do
                        Item = UILuaItem:New(_itemGridTrans:GetChild(i))
                        ItemList:Add(Item)
                    end
                    local _index = 1
                    if _rewardCount > 0 then
                        for i = 1, _rewardCount do
                            local _occ = tonumber(_rewardItemList[i][1])
                            if (_career == 9) or  (_occ == _career) then
                                local _itemID = tonumber(_rewardItemList[i][2])
                                local _item
                                if _index <= #ItemList then
                                    _item = ItemList[_index]
                                else
                                    _item = Item:Clone()
                                    ItemList:Add(_item)
                                end
                                if _item then
                                    _item.RootGO:SetActive(true)
                                    _item:InItWithCfgid(_itemID)
                                    _index = _index + 1
                                    if _index > 6 then
                                        break
                                    end
                                end
                            end
                        end
                        for i = _index, #ItemList do
                            ItemList[i].RootGO:SetActive(false)
                        end
                        ItemCloneRootScroll.repositionWaitFrameCount = 3
                        ItemCloneRootGrid.repositionNow = true

                    else
                        for i = 1, #ItemList do
                            ItemList[i].RootGO:SetActive(false)
                        end
                    end

                    -- ẩn bậc + đồ quý > chỉ hiện khi item được selected
                    local FristCrossGo = UIUtils.FindTrans(self.BossItemList[_countIndex].Trans, "FristCrossGo")
                    FristCrossGo.gameObject:SetActive(false)
                    local StageGo = UIUtils.FindLabel(self.BossItemList[_countIndex].Trans, "Stage")
                    StageGo.gameObject:SetActive(false)

                end
                _countIndex = _countIndex + 1

                if self.PlayAnim then
                    _animList:Add(_go.Trans)
                end
            end

        end

        for i = _countIndex, #self.BossItemList do
            self.BossItemList[i].Go:SetActive(false)
        end

        self.BossCloneRootGrid:Reposition()

        if #self.BossItemList > 0 then
            if not self.CurSelectBossItem then
                self.CurSelectBossItem = self.BossItemList[1]
                self.CurIndexShow = 1
                self.ArrowLeftBtn.gameObject:SetActive(false)
            end
            self:OnClickLeftBoss(self.CurSelectBossItem)
        end
        self:SetDesc()

        if self.PlayAnim then
            for i = 1, #_animList do
                self.CSForm:RemoveTransAnimation(_animList[i])
                self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.3, false, false)
                self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.075)
            end
            self.AnimPlayer:AddTrans(self.RightTrans, 0)
            self.AnimPlayer:Play()
        end

        if self.BossCount == 1 then
            self.ArrowRightBtn.gameObject:SetActive(false)
        end

    end
end

function UIStatureBossForm:SetDesc()
    if self.CurSelectBossItem and self.CurSelectBossID then
        if GameCenter.GameSceneSystem:GetLocalPlayerFightPower() >= self.CurSelectBossItem.ItemData.BossCfg.Power then
            UIUtils.SetColorByString(self.RecommandPowerLabel, "#008561")
        else
            UIUtils.SetColorByString(self.RecommandPowerLabel, "#ff4e00")
        end
        UIUtils.SetTextByEnum(self.RecommandPowerLabel, "Stature_Boss_TuiJian_FightPower", self.CurSelectBossItem.ItemData.BossCfg.Power)
        local _type = self.CurSelectBossItem.ItemData.Type
        self.GoBtnRedGo:SetActive(not self.CurSelectBossItem.ItemData.IsFirst and _type ~= StatureBossState.WaitOpen and _type ~= StatureBossState.UnActive)
        if _type == StatureBossState.Killed then
            UIUtils.SetTextByEnum(self.BtnDescLabel, "BOSSACTIVITY_YIJISHA")
        elseif _type == StatureBossState.Alive then
            UIUtils.SetTextByEnum(self.BtnDescLabel, "BOSSFIGHT_ZHONGSHEN_LIJI")
        elseif _type == StatureBossState.WaitOpen then
            UIUtils.SetTextByEnum(self.BtnDescLabel, "Stature_Boss_LastFlower")
        elseif _type == StatureBossState.Sweeps then
            UIUtils.SetTextByEnum(self.BtnDescLabel, "Stature_Boss_AutoKill")
        else
            local _condition = Utils.SplitNumber(self.CurSelectBossItem.ItemData.BossCfg.StateLevel, "_")
            local _lv = _condition[2]
            UIUtils.SetTextByEnum(self.BtnDescLabel, "Stature_Boss_Someone_State", _lv)
        end
    end
    self.AddCountBtnRed:SetActive(GameCenter.StatureBossSystem:CanBuyCount())
    UIUtils.SetTextByEnum(self.RemainCountLabel, "Stature_Boss_Reamin_Count", GameCenter.StatureBossSystem.CurCount)
end

function UIStatureBossForm:AddSuccess(obj, sender)
    self.AddCountBtnRed:SetActive(GameCenter.StatureBossSystem:CanBuyCount())
    UIUtils.SetTextByEnum(self.RemainCountLabel, "Stature_Boss_Reamin_Count", GameCenter.StatureBossSystem.CurCount)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--Increase the number of clicks
function UIStatureBossForm:OnAddCountBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UIBossAddCountForm_OPEN, BossType.StatureBoss)
end

function UIStatureBossForm:OnClickHelpBtn()
    GameCenter.PushFixEvent(UIEventDefine.UI_HELP_FORM_OPEN, FunctionStartIdCode.StatureBoss);
end

function UIStatureBossForm:OnClickGotoBtn()
    if self.CurSelectBossItem and self.CurSelectBossID then
        local _type = self.CurSelectBossItem.ItemData.Type
        local _bossConfg = self.CurSelectBossItem.ItemData.BossCfg
        if _type == StatureBossState.UnActive then
            local _condition = Utils.SplitNumber(self.CurSelectBossItem.ItemData.BossCfg.StateLevel, "_")
            local _lv = _condition[2]
            Utils.ShowPromptByEnum("Stature_Boss_StateVip_NotEnough", CommonUtils.GetLevelDesc(_lv))
        elseif _type == StatureBossState.Alive then
            if GameCenter.StatureBossSystem.CurCount > 0 or not self.CurSelectBossItem.ItemData.IsFirst then
                GameCenter.StatureBossSystem.CurSelectMonsterID = _bossConfg.Monster
                GameCenter.CopyMapSystem:ReqEnterCopyMap(_bossConfg.CloneID, _bossConfg.ID);
                if _bossConfg.IsGuide and _bossConfg.IsGuide == 1 then
                    GameCenter.StatureBossSystem.IsGuide = _bossConfg.HPper
                else
                    GameCenter.StatureBossSystem.IsGuide = 0
                end
            else
                Utils.ShowPromptByEnum("Stature_Boss_ChangeCount_Finished")
            end
        elseif _type == StatureBossState.Sweeps then
            GameCenter.CopyMapSystem:ReqSweepCopyMap(_bossConfg.CloneID, _bossConfg.ID)
        end
    end
end

-- Click on the left BOSS list
function UIStatureBossForm:OnClickLeftBoss(go)
    -- if self.CurSelectBossItem ~= nil and self.CurSelectBossItem ~= go then
    --     -- đảo lại vị trí của item đang được chọn
    --     self:OnOrderLeftBossList(go, false)
    --     return
    --     -- đảo lại vị trí của item đang được chọn
    -- end
    self.CurSelectBossItem = go

    self.CostCountTipsGo:SetActive(not go.ItemData.IsFirstGet)
    local _bossCfg = go.ItemData.BossCfg
    if _bossCfg then

        -- set model
        for i = 1, #self.BossItemList do
            self.BossItemList[i]:OnSetSelect(false)
            local HeadIconItem = UIUtils.FindSpr(self.BossItemList[i].Trans, "HeadIcon");
            HeadIconItem.gameObject:SetActive(true)
            HeadIconItem.IsGray = true
            local UIRoleSkinCompoentItem = UIUtils.FindTrans(self.BossItemList[i].Trans, "UIRoleSkinCompoent")
            UIRoleSkinCompoentItem.gameObject:SetActive(false)
            
            -- ẩn bậc + đồ quý khi item được selected
            local FristCrossItem = UIUtils.FindTrans(self.BossItemList[i].Trans, "FristCrossGo")
            FristCrossItem.gameObject:SetActive(false)
            local StageItem = UIUtils.FindLabel(self.BossItemList[i].Trans, "Stage")
            StageItem.gameObject:SetActive(false)
        end

        local HeadIcon = UIUtils.FindSpr(self.CurSelectBossItem.Trans, "HeadIcon");
        local UIRoleSkinCompoent = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent")
        local SkinComp = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(self.CurSelectBossItem.Trans, "UIRoleSkinCompoent"));
        if SkinComp then
            SkinComp:OnFirstShow(self.CSForm, FSkinTypeCode.Custom)
            local _monsterCfg = DataConfig.DataMonster[_bossCfg.Monster]
            if _monsterCfg then
                SkinComp:SetEquip(FSkinPartCode.Body, _monsterCfg.Res);
                SkinComp:SetLocalScale(_bossCfg.Size)
                if _bossCfg.ModelYPos then
                    SkinComp:SetSkinPos(Vector3(0, _bossCfg.ModelYPos / _bossCfg.Size , 0))
                end
            end
        end
        HeadIcon.gameObject:SetActive(false)
        UIRoleSkinCompoent.gameObject:SetActive(true)

        -- hiện bậc + đồ quý khi item được selected
        local FristCrossGo = UIUtils.FindTrans(self.CurSelectBossItem.Trans, "FristCrossGo")
        FristCrossGo.gameObject:SetActive(true)
        local StageGo = UIUtils.FindLabel(self.CurSelectBossItem.Trans, "Stage")
        StageGo.gameObject:SetActive(true)

        self.CurSelectBossID = _bossCfg.Monster

        --Set drop
        local _career = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        
        local _rewardItemList = Utils.SplitStrByTableS(_bossCfg.Drop)
        local _rewardCount = #_rewardItemList
        local  _index = 1
        for i=1, _rewardCount do
            local _careerId = tonumber(_rewardItemList[i][1])
            local _item
            if (_careerId == 9) or (_career == _careerId) then
                if _index - 1 < #self.DropList then
                    _item = self.DropList[_index]
                else
                    _item = self.DropItem:Clone()
                    self.DropList:Add(_item)
                end
                if _item then
                    _item.RootGO:SetActive(true)
                    _item:InItWithCfgid(tonumber(_rewardItemList[i][2]), 0, false, false)
                end
                _index = _index + 1
                if _index > 6 then
                -- if _index > 4 then
                    break
                end
            end
        end
        for i=_index, #self.DropList do
            self.DropList[i].RootGO:SetActive(false)
        end
        self.DropScroll.repositionWaitFrameCount = 3
        self.DropGrid.repositionNow = true
        self:SetDesc()
        
        self.CurSelectBossItem:OnSetSelect(true)
    end
end

-- CUSTOM - xử lý hiển thị lại list khi click vào item ở sau
-- function UIStatureBossForm:OnOrderLeftBossList(go, IsBtnClick)

--     local _animList = nil
--     if self.PlayAnim then
--         _animList = List:New()
--         self.AnimPlayer:Stop()
--     end

--     local found_index = nil
--     local current_go = nil
--     local first_go = self.BossItemList[1]
--     local first_info = first_go.ItemData

--     for i = 1, #self.BossItemList do
--         local _go = self.BossItemList[i]
--         if _go == go then
--             found_index = i
--             current_go = _go
--         end

--         if self.PlayAnim then
--             _animList:Add(_go.Trans)
--         end
--     end

--     local current_info = current_go.ItemData

--     for i = 1, #self.IndexList do
--         if current_info.Layer == self.IndexList[i] then
--             self.CurIndexShow = i
--         end
--     end

--     first_go:SetInfo(current_info)
--     current_go:SetInfo(first_info)
--     self.CurSelectBossItem = first_go

--     -- hiển thị VP hiếm PreciousDrop
--     local _career = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
--     local _bossCfg = first_go.ItemData.BossCfg
--     local _rewardItemList = Utils.SplitStrByTableS(_bossCfg.PreciousDrop)
--     local _rewardCount = #_rewardItemList

--     local ItemCloneRootGrid = UIUtils.FindGrid(first_go.Trans, "FristCrossGo/ItemRoot/Grid")
--     local ItemCloneRootScroll = UIUtils.FindScrollView(first_go.Trans, "FristCrossGo/ItemRoot")
--     local _itemGridTrans = UIUtils.FindTrans(first_go.Trans, "FristCrossGo/ItemRoot/Grid")
--     local Item = nil
--     local ItemList = List:New()
--     for i = 0, _itemGridTrans.childCount - 1 do
--         Item = UILuaItem:New(_itemGridTrans:GetChild(i))
--         ItemList:Add(Item)
--     end
--     local _index = 1
--     if _rewardCount > 0 then
--         for i = 1, _rewardCount do
--             local _occ = tonumber(_rewardItemList[i][1])
--             if _occ == _career then
--                 local _itemID = tonumber(_rewardItemList[i][2])
--                 local _item
--                 if _index <= #ItemList then
--                     _item = ItemList[_index]
--                 else
--                     _item = Item:Clone()
--                     ItemList:Add(_item)
--                 end
--                 if _item then
--                     _item.RootGO:SetActive(true)
--                     _item:InItWithCfgid(_itemID)
--                     _index = _index + 1
--                     if _index > 6 then
--                         break
--                     end
--                 end
--             end
--         end
--         for i = _index, #ItemList do
--             ItemList[i].RootGO:SetActive(false)
--         end
--         ItemCloneRootScroll.repositionWaitFrameCount = 3
--         ItemCloneRootGrid.repositionNow = true

--     else
--         for i = 1, #ItemList do
--             ItemList[i].RootGO:SetActive(false)
--         end
--     end

--     -- hiển thị model
--     local HeadIcon = UIUtils.FindSpr(first_go.Trans, "HeadIcon");
--     local UIRoleSkinCompoent = UIUtils.FindTrans(first_go.Trans, "UIRoleSkinCompoent")
--     local SkinComp = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(first_go.Trans, "UIRoleSkinCompoent"));
--     if SkinComp then
--         SkinComp:OnFirstShow(self.CSForm, FSkinTypeCode.Custom)
--         local _monsterCfg = DataConfig.DataMonster[_bossCfg.Monster]
--         if _monsterCfg then
--             SkinComp:SetEquip(FSkinPartCode.Body, _monsterCfg.Res);
--             SkinComp:SetLocalScale(_bossCfg.Size)
--             if _bossCfg.ModelYPos then
--                 SkinComp:SetSkinPos(Vector3(0, _bossCfg.ModelYPos / _bossCfg.Size , 0))
--             end
--         end
--     end
--     HeadIcon.gameObject:SetActive(false)
--     UIRoleSkinCompoent.gameObject:SetActive(true)

--     -- hiện bậc + đồ quý khi item được selected
--     local FristCrossGo = UIUtils.FindTrans(first_go.Trans, "FristCrossGo")
--     FristCrossGo.gameObject:SetActive(true)
--     local StageGo = UIUtils.FindLabel(first_go.Trans, "Stage")
--     StageGo.gameObject:SetActive(true)

--     self.CurSelectBossID = _bossCfg.Monster

--     --Set drop
--     local _career = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
--     _rewardItemList = Utils.SplitStrByTableS(_bossCfg.Drop)
--     _rewardCount = #_rewardItemList
--     _index = 1
--     for i=1, _rewardCount do
--         local _careerId = tonumber(_rewardItemList[i][1])
--         local _item
--         if _career == _careerId then
--             if _index - 1 < #self.DropList then
--                 _item = self.DropList[_index]
--             else
--                 _item = self.DropItem:Clone()
--                 self.DropList:Add(_item)
--             end
--             if _item then
--                 _item.RootGO:SetActive(true)
--                 _item:InItWithCfgid(tonumber(_rewardItemList[i][2]), 0, false, false)
--             end
--             _index = _index + 1
--             if _index > 6 then
--                 break
--             end
--         end
--     end
--     for i=_index, #self.DropList do
--         self.DropList[i].RootGO:SetActive(false)
--     end
--     self.DropScroll.repositionWaitFrameCount = 3
--     self.DropGrid.repositionNow = true
--     self:SetDesc()

--     self.BossCloneRootGrid:Reposition()

--     if self.PlayAnim then
--         local totalCount = #_animList
--         if self.BossCount == 2 then
--             totalCount = 2
--         end
--         for i = 1, totalCount do
--             self.CSForm:RemoveTransAnimation(_animList[i])
--             self.CSForm:AddAlphaPosAnimation(_animList[i], 0, 1, -50, 0, 0.3, false, false)
--             self.AnimPlayer:AddTrans(_animList[i], (i - 1) * 0.075)
--         end
--         self.AnimPlayer:AddTrans(self.RightTrans, 0)
--         self.AnimPlayer:Play()

--     end

-- end
-- CUSTOM - xử lý hiển thị lại list khi click vào item ở sau

function UIStatureBossForm:OnClickLeftBtn()

    if self.CurIndexShow == self.BossCount then

        self.StartIndexShow = self.StartIndexShow - 1
        self.CurIndexShow = self.CurIndexShow - 1

    elseif self.StartIndexShow == self.BossCount - 1 then

        self.StartIndexShow = self.StartIndexShow - 1
        self.CurIndexShow = self.CurIndexShow - 1
        self.EndIndexShow = self.BossCount

    else

        self.CurIndexShow = self.CurIndexShow - 1
        self.StartIndexShow = self.StartIndexShow - 1
        self.EndIndexShow = self.EndIndexShow - 1

    end

    self:SetLeftBossList()
    prevBoss = self.IndexList[self.CurIndexShow]
    for i = 1, #self.BossItemList do
        if prevBoss == self.BossItemList[i].ItemData.Layer then
            self:OnClickLeftBoss(self.BossItemList[i])
            break
        end
    end
    self.ArrowLeftBtn.gameObject:SetActive(self.CurIndexShow > 1)

end

function UIStatureBossForm:OnClickRightBtn()

    self.CurIndexShow = self.CurIndexShow + 1
    self.StartIndexShow = self.StartIndexShow + 1

    if self.EndIndexShow < self.BossCount then
        self.EndIndexShow = self.EndIndexShow + 1
    else
        self.EndIndexShow = self.BossCount
    end

    self:SetLeftBossList()
    nextBoss = self.IndexList[self.CurIndexShow]
    for i = 1, #self.BossItemList do
        if nextBoss == self.BossItemList[i].ItemData.Layer then
            self:OnClickLeftBoss(self.BossItemList[i])
            break
        end
    end
    self.ArrowRightBtn.gameObject:SetActive(self.CurIndexShow < self.BossCount)

end

--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function UIStatureBossForm:FindAllComponents()
    self.AlertEmpty = UIUtils.FindLabel(self.Trans, "AlertEmpty")
    
    local _myTrans = self.Trans
    self.LeftTrs = UIUtils.FindTrans(_myTrans, "Left")
    local _leftTrs = self.LeftTrs
    self.BossCloneRoot = UIUtils.FindTrans(_leftTrs, "BossRoot")
    self.BossCloneRootPanel = UIUtils.FindPanel(_leftTrs, "BossRoot")
    self.BossCloneRootGrid = UIUtils.FindGrid(_leftTrs, "BossRoot/Grid")
    self.FirstGridPosX = self.BossCloneRootGrid.transform.position.x

    self.BossCloneRootScrollView = UIUtils.FindScrollView(_leftTrs, "BossRoot")

    self.RightTrans = UIUtils.FindTrans(_myTrans, "Right")
    local _rightTrs = self.RightTrans
    self.DropGrid = UIUtils.FindGrid(_rightTrs, "DropGo/ItemRoot/Grid")
    self.DropScroll = UIUtils.FindScrollView(_rightTrs, "DropGo/ItemRoot")
    local _itemGridTrans = UIUtils.FindTrans(_rightTrs, "DropGo/ItemRoot/Grid")
    for i = 0, _itemGridTrans.childCount - 1 do
        self.DropItem = UILuaItem:New(_itemGridTrans:GetChild(i))
        self.DropList:Add(self.DropItem)
    end

    self.BottomTrs = UIUtils.FindTrans(_myTrans, "Bottom")
    local _bottomTrs = self.BottomTrs
    self.BtnDescLabel = UIUtils.FindLabel(_rightTrs, "GoBtn/Label")
    self.GoBtnRedGo = UIUtils.FindGo(_rightTrs, "GoBtn/RedPoint")
    self.RecommandPowerLabel = UIUtils.FindLabel(_bottomTrs, "RecommendPower")
    self.RemainCountLabel = UIUtils.FindLabel(_rightTrs, "FreshTips")
    self.GotoBtn = UIUtils.FindBtn(_rightTrs, "GoBtn")
    self.ModelBotTexture = UIUtils.FindTex(_myTrans, "ModelBotTexture")
    self.FootBotTexture = UIUtils.FindTex(_myTrans, "FootBotTexture")
    self.AddCountBtn = UIUtils.FindBtn(_rightTrs, "AddCount")
    self.AddCountBtn.gameObject:SetActive(false)
    self.HelpBtn = UIUtils.FindBtn(_rightTrs, "Help")
    self.CostCountTipsGo = UIUtils.FindGo(_rightTrs, "Desc")

    self.AddCountBtnRed = UIUtils.FindGo(_rightTrs, "AddCount/Red")
    self.AddCountBtnRed.gameObject:SetActive(false)

    self.ArrowLeftBtn = UIUtils.FindBtn(_myTrans, "ArrowLeftBtn")
    self.ArrowRightBtn = UIUtils.FindBtn(_myTrans, "ArrowRightBtn")

    self.ArrowLeftBtn.gameObject:SetActive(false)
    self.ArrowRightBtn.gameObject:SetActive(false)
    self.LeftTrs.gameObject:SetActive(false)
    self.RightTrans.gameObject:SetActive(false)

    self.CSForm:AddAlphaPosAnimation(_rightTrs, 0, 1, 50, 0, 0.3, false, false)
end
--------------------------------------------------------------------------------------------------------------------------------
return UIStatureBossForm
