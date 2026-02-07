-- ==============================--
-- 作者： [王圣]
-- 日期： 2020-08-21  14:04:49
-- 文件： UIFashionTjForm.lua
-- 模块： UIFashionTjForm
-- 描述： {时装图鉴功能!}
-- ==============================--
local ListTab = require "UI.Components.UIListTab.UIListTab"
local ListText = require "UI.Components.UIListText.UIListText"
local Fashion = require "UI.Forms.UIFashionTjForm.ListTjFashion"
local L_UIAnimDelayPlayer = require "UI.Components.UIAnimDelayPlayer"
local FightUtils = require "Logic.Base.FightUtils.FightUtils"
local L_BattlePropTools = CS.Thousandto.Code.Logic.BattlePropTools
local UIFashionTjForm = {
    ActiveBtn = nil,
    -- 升星按钮
    LvBtn = nil,
    LvBtnFull = nil,
    -- 当前星级
    CurStar = nil,
    -- 下一星级
    NextStar = nil,
    -- 箭头标记
    Flag = nil,
    -- 图鉴tab
    TuJianTab = nil,
    -- 套装属性Text组件
    TzTexts = nil,
    -- 全套属性Text组件
    QtTexts = nil,
    -- 需要的时装列表
    ListFashion = List:New(),

    -- 当前选中的图鉴Index
    CurSelectIndex = -1,

    -- 激活红点
    AcRedPoint = nil,
    -- 升星红点
    UpRedPoint = nil,

    BgTex = nil,
    Count = nil,
    CloseBtn = nil,
    -- CUSTOM - active đơn
    CurSelectType = 0,
    -- CUSTOM - active đơn
    -- CUSTOM - Right data
    RightName = nil,
    RightBGName = nil,
    RightBGType = nil,
    StarList = List:New(),
    CurrentData = nil,
    AcItemNum = nil,
    UpItemNum = nil,
    -- CUSTOM - Right data
}

-- 注册事件函数, 提供给CS端调用.
function UIFashionTjForm:OnRegisterEvents()
    self:RegisterEvent(UILuaEventDefine.UIFashionTjForm_OPEN, self.OnOpen)
    self:RegisterEvent(UILuaEventDefine.UIFashionTjForm_CLOSE, self.OnClose)

    self:RegisterEvent(LogicLuaEventDefine.EID_DOGIAM_UPSTAR_RESULT, self.OnUpStar)
    self:RegisterEvent(LogicLuaEventDefine.EID_DOGIAM_ACTIVE_RESULT, self.OnActive)

    self:RegisterEvent(LogicLuaEventDefine.EID_DOGIAM_SINGLE_ACTIVE, self.OnGetSingleData)
end

-- 第一只显示函数, 提供给CS端调用.
function UIFashionTjForm:OnFirstShow()
    self:FindAllComponents();
    self:RegUICallback();
    self.CSForm.UIRegion = UIFormRegion.TopRegion;
end

function UIFashionTjForm:OnOpen(obj, sender)
    self.CurSelectIndex = 1
    self.CSForm:Show(sender)
    -- CUSTOM - show tabs redpoint
    self:ShowRedPointForTabsAndCount()
    -- CUSTOM - show tabs redpoint
end

function UIFashionTjForm:OnClose(obj, sender)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_DOGIAM_CLOSE)
    self.CSForm:Hide()
end

function UIFashionTjForm:OnUpStar(obj, sender)
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local dataList = GameCenter.NewFashionSystem:GetTuJianDatas()
    if not dataList then
        return
    end

    -- Refresh list trước
    self:SetForm(dataList, false, false)

    -- Lấy lại data sau khi list đã refresh
    local data = GameCenter.NewFashionSystem:GetTuJianData(self.CurSelectIndex)
    if data then
        self:SetTuJian(data, occ, false)
    end
    -- CUSTOM - show tabs redpoint
    self:ShowRedPointForTabsAndCount()
    -- CUSTOM - show tabs redpoint
end

-- 图鉴激活
function UIFashionTjForm:OnActive(obj, sender)
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local dataList = GameCenter.NewFashionSystem:GetTuJianDatas()
    if dataList == nil then
        return
    end
    self:SetForm(dataList, false, false)

    -- Custom
    local data = GameCenter.NewFashionSystem:GetTuJianData(self.CurSelectIndex)
    if data then
        self:SetTuJian(data, occ, false)  -- refresh chi tiết bên phải
    end
    -- CUSTOM - show tabs redpoint
    self:ShowRedPointForTabsAndCount()
    -- CUSTOM - show tabs redpoint
end

-- 查找所有组件
function UIFashionTjForm:FindAllComponents()
    local _myTrans = self.Trans;
    self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "TopRight/UIMoneyForm"));
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    self.ActiveBtn = UIUtils.FindBtn(_myTrans, "QuanTao/ActiveBtn")
    self.AcItemNum = UIUtils.FindLabel(_myTrans, "QuanTao/ActiveBtn/Num")
    self.LvBtn = UIUtils.FindBtn(_myTrans, "QuanTao/LvBtn")
    self.UpItemNum = UIUtils.FindLabel(_myTrans, "QuanTao/LvBtn/Num")
    self.LvBtnFull = UIUtils.FindTrans(_myTrans, "QuanTao/LvBtn/Full")
    self.Flag = UIUtils.FindGo(_myTrans, "QuanTao/Star/Sprite")
    self.TuJianTab =
        ListTab:New(UIUtils.FindTrans(_myTrans, "UIListTab"), 1, Utils.Handler(self.OnClickTuJianTab, self))
    self.TzTexts = ListText:New(UIUtils.FindTrans(_myTrans, "FenDuan/UIListText"))
    self.QtTexts = ListText:New(UIUtils.FindTrans(_myTrans, "QuanTao/UIListText"))
    local gridTrans = UIUtils.FindTrans(_myTrans, "UIListFashion/Grid")
    self.ListFashion:Clear()
    for i = 1, gridTrans.childCount do
        local trans = gridTrans:GetChild(i - 1)
        local fashion = Fashion:New(trans)
        self.ListFashion:Add(fashion)
    end
    self.AcRedPoint = UIUtils.FindGo(_myTrans, "QuanTao/ActiveBtn/RedPoint")
    self.UpRedPoint = UIUtils.FindGo(_myTrans, "QuanTao/LvBtn/RedPoint")
    self.BgTex = UIUtils.FindTex(_myTrans, "BgTex")
    self.Count = UIUtils.FindLabel(_myTrans, "Count")
    self.AnimPlayer = L_UIAnimDelayPlayer:New(self.CSForm.AnimModule)
    self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)

    self.CloseBtn = UIUtils.FindBtn(_myTrans,"TopRight/CloseBtn")
    self.RightName = UIUtils.FindLabel(_myTrans, "Right/Name")
    self.RightBGName = UIUtils.FindLabel(_myTrans, "Right/BackBround/Name")
    self.RightBGType = UIUtils.FindLabel(_myTrans, "Right/BackBround/Type")
    self.RightDesc = UIUtils.FindLabel(_myTrans, "Right/BackBround/Desc")
end

-- 绑定UI组件的回调函数
function UIFashionTjForm:RegUICallback()
    UIUtils.AddBtnEvent(self.ActiveBtn, self.OnClickActive, self)
    UIUtils.AddBtnEvent(self.LvBtn, self.OnClickLv, self)
    UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickClose, self)
end

function UIFashionTjForm:LoadTextures(tex, name)
    self.CSForm:LoadTexture(tex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, name))
end

-- 显示之前的操作, 提供给CS端调用.
function UIFashionTjForm:OnShowBefore()
end

-- 显示后的操作, 提供给CS端调用.
function UIFashionTjForm:OnShowAfter()
    self:LoadTextures(self.BgTex, "tex_n_b_jianling")
    -- 获取时装图鉴数据
    local dataList = GameCenter.NewFashionSystem:GetTuJianDatas()
    if dataList == nil then
        return
    end
    self:SetForm(dataList, true, true)
end

-- 隐藏之前的操作, 提供给CS端调用.
function UIFashionTjForm:OnHideBefore()
end

-- 隐藏之后的操作, 提供给CS端调用.
function UIFashionTjForm:OnHideAfter()
end

-- 设置界面
function UIFashionTjForm:SetForm(dataList, playAnim, isFirstShow)
    local curSelectData = GameCenter.NewFashionSystem:GetTuJianData(self.CurSelectIndex)
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    -- 设置图鉴Tab
    local tabDataList = List:New()
    for i = 1, #dataList do
        local data = dataList[i]
        local name = data:GetName()

        local quality = data:GetQuality()
        local iconId = data:GetIconId(occ)
        local isRedPoint = false
        if data.IsActive then
            local lowStarNum = GameCenter.NewFashionSystem:GetLowStarLv(i)
            isRedPoint = data.StarNum < lowStarNum
        else
            isRedPoint = GameCenter.NewFashionSystem:IsCollectAll(i)
        end
        local tabData = {
            Name = name,
            IsRedPoint = isRedPoint,
            IconId = iconId,
            Quality = quality
        }
        tabDataList:Add(tabData)
    end
    if isFirstShow then
        self.TuJianTab:Refreash(tabDataList, 1)
    else
        self.TuJianTab:Refreash(tabDataList, self.CurSelectIndex)
    end
    self.TuJianTab:ResetPositionNow()
    self:SetTuJian(curSelectData, occ, isFirstShow)

    if playAnim then
        self:PlayAnim()
    end

end

function UIFashionTjForm:PlayAnim()
    self.AnimPlayer:Stop()
    local _index = 0
    for i = 1, self.TuJianTab:GetCount() do
        local _tab = self.TuJianTab:GetTab(i)
        if _tab ~= nil and _tab.Trans ~= nil then
            self.CSForm:RemoveTransAnimation(_tab.Trans)
            self.CSForm:AddAlphaPosAnimation(_tab.Trans, 0, 1, 0, 100, 0.3, false, false)
            self.AnimPlayer:AddTrans(_tab.Trans, _index * 0.1)
            _index = _index + 1
        end
    end
    self.AnimPlayer:Play()
end

function UIFashionTjForm:SetTuJian(data, occ, isFirstShow)
    if data == nil then
        return
    end

    --CUSTOM - set RightBGName
    UIUtils.SetTextByString(self.RightBGName, data.Name)
    --CUSTOM - set RightBGName
    --CUSTOM - set RightBGType
    UIUtils.SetTextByString(self.RightBGType, data:GetType())
    --CUSTOM - set RightBGType

    --CUSTOM - set RightDesc
    UIUtils.SetTextByString(self.RightDesc, data.Desc)
    --CUSTOM - set RightDesc

    local curData = self.CurrentData
    local cfgId = curData and curData:GetCfgId()

    -- CUSTOM - refresh right datas
    if curData ~= nil then
        self:OnGetSingleData(curData.ItemId)
    end
    -- CUSTOM - refresh right datas

    -- 设置需要的时装
    local activeCount = 0
    local needList = data:GetNeedDataList()
    
    local NatureWingsData = GameCenter.NatureSystem.NatureWingsData.super
    local cmpList
    -- Lấy dữ liệu từ NatureSystem
    if NatureWingsData ~= nil then
        cmpList = GosuSDK.InitData()
        -- print("📦 Danh sách cmpList:", Inspect(cmpList))
        GameCenter.NewFashionSystem.FallbackCmpList = cmpList
    end

    local counT = 0;

    -- Kiểm tra danh sách yêu cầu
    if needList ~= nil then
        -- print("📋 Danh sách needList:", Inspect(needList))

        for i = 1, #needList do
            local need = needList[i]
            -- print(string.format("🔍 Đang xử lý need[%d] với FashionId = %s", i, tostring(need.FashionId)))

            local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(need.FashionId)

            local itemId, iconId, starNum, name, desc, quality, type = nil, nil, nil, nil, nil, nil

            -- Nếu có dữ liệu gốc
            if fashionData ~= nil then
                -- print("✅ Tìm thấy fashionData gốc.")
                itemId   = fashionData:GetItemId(occ) or itemId
                iconId   = fashionData:GetIconId(occ) or iconId
                starNum  = fashionData:GetStarNum()  or starNum
                name     = fashionData:GetName()     or name
                desc     = fashionData:GetDesc()     or desc
                quality  = fashionData:GetQuality()  or quality
                type     = fashionData:GetType()  or type
                counT = counT + 1;
            end

            -- Fallback qua cmpList nếu dữ liệu gốc thiếu hoặc không tồn tại
            if (itemId == nil or iconId == nil or starNum == nil or name == nil or quality == nil or type == nil) and cmpList ~= nil then
                -- print("⚠️ Dữ liệu gốc thiếu hoặc không có, đang fallback qua cmpList...")
                local cmp = self:FindCmpByFashionId(cmpList, need.FashionId)
                if cmp then
                    -- print("   ✅ Khớp cmp.ItemId với need.FashionId, dùng dữ liệu fallback")
                    itemId   = itemId   or cmp.ItemId
                    iconId   = iconId   or cmp.IconId
                    starNum  = starNum  or cmp.StarNum
                    name     = name     or cmp.Name
                    desc     = desc     or cmp.Desc
                    quality  = quality  or cmp.Quality
                    type     = type     or cmp.Type
                end
            end

            -- Nếu vẫn không có dữ liệu thì log và bỏ qua
            if (itemId == nil or itemId == 0) and (iconId == nil) and (name == nil) then
                -- print("❌ Không tìm thấy dữ liệu nào cho FashionId:", need.FashionId)
            else
                -- Kiểm tra trạng thái hoạt động
                local isActive = false
                local sysData = GameCenter.NewFashionSystem:GetFashionDogiamData(need.FashionId)
                if sysData and sysData.IsActive then
                    isActive = true
                    activeCount = activeCount + 1
                elseif cmpList ~= nil then
                    -- Nếu không có trong hệ thống gốc, thì lấy isActive từ fallback cmp
                    local fallbackCmp = self:FindCmpByFashionId(cmpList, need.FashionId)
                    if fallbackCmp and fallbackCmp.IsActive then
                        isActive = true
                        activeCount = activeCount + 1
                        -- print("✅ [fallback] IsActive từ cmpList:", need.FashionId)
                    end
                end

                -- Đóng gói dữ liệu
                local cmpData = {
                    ItemId = itemId,
                    IconId = iconId,
                    StarNum = starNum,
                    Name = name,
                    Desc = desc,
                    IsActive = isActive,
                    Quality = quality,
                    Type = type
                }

                -- print("✅ data --- kết quả cuối cùng cmpData:", Inspect(cmpData))

                -- Gán vào UI
                if i <= #self.ListFashion then
                    local fashionCmp = self.ListFashion[i]
                    fashionCmp:SetCmp(cmpData)
                    fashionCmp:SetActive(true)
                end
            end
        end

        -- Ẩn những slot dư
        if #needList < #self.ListFashion then
            for i = #needList + 1, #self.ListFashion do
                local fashionCmp = self.ListFashion[i]
                fashionCmp:SetActive(false)
            end
        end
    end
    
    -- CUSTOM - chọn item đầu tiên
    if isFirstShow then

        -- set RightData
        self:OnGetSingleData(self.ListFashion[1].ItemId)

        -- set IconTex
        local gridTrans = UIUtils.FindTrans(self.Trans, "UIListFashion/Grid")
        for i = 1, gridTrans.childCount do
            local trans = gridTrans:GetChild(i - 1)

            if self.ListFashion[i].IconId ~= nil then
                UIUtils.FindTex(trans, "IconTex")
                self:LoadTextures(UIUtils.FindTex(trans, "IconTex"), "MonsterCard/" .. self.ListFashion[i].IconId)
            end
        end

    else
        self:OnGetSingleData(curData.ItemId)
    end

    -- CUSTOM - chọn item đầu tiên
end

function UIFashionTjForm:Update(dt)
    self.AnimPlayer:Update(dt)
end

-- [界面按钮回调 begin]--

-- 点击图鉴tab
function UIFashionTjForm:OnClickTuJianTab(i)
    self.CurSelectIndex = i
    local data = GameCenter.NewFashionSystem:GetTuJianData(i)
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    self:SetTuJian(data, occ, true)
end

-- CUSTOM - show RedPoint for tab
function UIFashionTjForm:ShowRedPointForTabsAndCount()
    local countActive = 0
    local countGroupActived = 0
    for i = 1, self.TuJianTab:GetCount() do
        local countItemActived = 0
        local countEnableRP = 0
        local data = GameCenter.NewFashionSystem:GetTuJianData(i)
        for j = 1, #data.ListNeedData do
            local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(data.ListNeedData[j].FashionId)
            if fashionData then
                local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(fashionData.ItemId)
                local needNum = fashionData:GetNeedItemNum(fashionData.StarNum)
                if (not fashionData.IsActive and count >= needNum) or 
                    (fashionData.IsActive and count >= needNum and fashionData.StarNum < 5) 
                then
                    countEnableRP = countEnableRP + 1
                end

                if fashionData.IsActive then
                    countActive = countActive + 1
                    countItemActived = countItemActived + 1
                end

                if countItemActived == #data.ListNeedData then
                    countGroupActived = countGroupActived + 1
                end
            end
        end

        --set RP
        self.TuJianTab:SetRedPoint(i, countEnableRP > 0)
    end

    -- set Count
    -- local format = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_FASHUON_TZSL"), activeCount, #needList)
    UIUtils.SetTextByString(self.Count, "Linh Bản đã nhận: " .. countActive)
end
-- CUSTOM - show RedPoint for tab

-- CUSTOM - fix ev click active
function UIFashionTjForm:OnClickActive()
    local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
    local curData = self.CurrentData
    local itemId = curData:GetItemId(occ)
    local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemId)
    local needNum = curData:GetNeedItemNum(0)
    if count >= needNum then
        GameCenter.NewFashionSystem:ReqActiveFashionDoGiam(curData:GetCfgId())
    else
        GameCenter.MsgPromptSystem:ShowPrompt(DataConfig.DataMessageString.Get("C_FASHION_WUPINBUZHU"))
        -- GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(itemId)
    end
end
-- CUSTOM - fix ev click active

-- CUSTOM - fix ev click Lv
function UIFashionTjForm:OnClickLv()
    local curData = self.CurrentData

    if curData ~= nil and curData.StarNum < 5 then
        local occ = GameCenter.GameSceneSystem:GetLocalPlayer().IntOcc
        local itemId = curData:GetItemId(occ)
        local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(itemId)
        local needNum = curData:GetNeedItemNum(curData.StarNum)
        if count >= needNum then
            GameCenter.NewFashionSystem:ReqFashionStarDoGiam(curData:GetCfgId())
        else
            Utils.ShowPromptByEnum("C_FASHION_CANNOTSTAR")
            -- GameCenter.ItemQuickGetSystem:OpenItemQuickGetForm(itemId)
        end
    else
        Utils.ShowPromptByEnum("C_FASHION_CANNOTSTAR")
    end
end
-- CUSTOM - fix ev click Lv

function UIFashionTjForm:FindCmpByFashionId(cmpList, fashionId)
    if cmpList == nil or fashionId == nil then return nil end
    for _, cmp in ipairs(cmpList) do
        if tostring(cmp.ModelId) == tostring(fashionId) then
            return cmp
        end
    end
    return nil
end

function UIFashionTjForm:OnClickClose()
    self:OnClose()
end

-- CUSTOM - hàm select item
function UIFashionTjForm:OnGetSingleData(ItemId)
    if ItemId == 0 then
        return
    end

    for i = 1, #self.ListFashion do
        local item = self.ListFashion[i]
        if (item.ItemId == ItemId) then
            -- set select
            item:SetSelect(true)

            -- set name
            UIUtils.SetTextByString(self.RightName, item.DataName)

            -- set desc
            UIUtils.SetTextByString(self.RightDesc, item.DataDesc)

            -- set attr
            self:OnSetAttr(ItemId, item.DataType)

            -- set attr
            self:OnSetGroupAttr(ItemId, item.DataType)

            -- set stars
            self:OnSetStars(item.DataStarNum, item.DataIsActive)

        else
            item:SetSelect(false)
        end

        -- set redpoint for items
        if item.DataStarNum ~= nil then
            local countContainer = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(item.ItemId)
            item:SetRedPoint(countContainer > item.DataStarNum and item.DataStarNum < 5)
        end
            
    end

    -- check + show RedPoints
    local curData = self.CurrentData
    local count = GameCenter.ItemContianerSystem:GetItemCountFromCfgId(ItemId)
    local AcNeedNum = 0
    local UpNeedNum = 0
    if not curData.IsActive then
        AcNeedNum = curData:GetNeedItemNum(0)
        UpNeedNum = curData:GetNeedItemNum(0)
    else
        AcNeedNum = curData:GetNeedItemNum(curData.StarNum)
        UpNeedNum = curData:GetNeedItemNum(curData.StarNum)
    end
    local AcFormat = UIUtils.CSFormat("{0}/{1}", count, AcNeedNum)
    local UpFormat = UIUtils.CSFormat("{0}/{1}", count, UpNeedNum)
    if count >= AcNeedNum or count >= UpNeedNum then
        UIUtils.SetColorByString(self.AcItemNum, "#00FF00")
        UIUtils.SetColorByString(self.UpItemNum, "#00FF00")
    else
        UIUtils.SetColorByString(self.AcItemNum, "#FF0000")
        UIUtils.SetColorByString(self.UpItemNum, "#FF0000")
    end
    UIUtils.SetTextByString(self.AcItemNum, AcFormat)
    UIUtils.SetTextByString(self.UpItemNum, UpFormat)
    -- Set activation red dot
    self.AcRedPoint:SetActive(not curData.IsActive and count >= AcNeedNum)
    -- Set up red dots of rising stars
    self.UpRedPoint:SetActive(curData.IsActive and count >= UpNeedNum and curData.StarNum < 5)
    -- check + show RedPoints

end
-- CUSTOM - hàm select item

-- CUSTOM - hàm set stars
function UIFashionTjForm:OnSetStars(StarNum, IsActive)
    self.StarList:Clear()
    local gridTrans = UIUtils.FindTrans(self.Trans, "Right/Star/Grid")
    for i = 1, gridTrans.childCount do
        local go = gridTrans:GetChild(i - 1).gameObject
        self.StarList:Add(go)
    end
    for i = 1,#self.StarList do
        local star = self.StarList[i]
        local _spr = UIUtils.FindSpr(self.StarList[i].transform)
        if i <= StarNum then
            _spr.spriteName = "n_z_5"
        else
            _spr.spriteName = "n_z_5_1"
        end
    end
    if StarNum == 5 then
        self.ActiveBtn.gameObject:SetActive(false)
        self.LvBtn.gameObject:SetActive(true)
        self.LvBtnFull.gameObject:SetActive(true)
    elseif IsActive and StarNum >= 0 and StarNum < 5 then
        self.ActiveBtn.gameObject:SetActive(false)
        self.LvBtn.gameObject:SetActive(true)
        self.LvBtnFull.gameObject:SetActive(false)
    else
        self.ActiveBtn.gameObject:SetActive(true)
        self.LvBtn.gameObject:SetActive(false)
        self.LvBtnFull.gameObject:SetActive(false)
    end
end
-- CUSTOM - hàm set stars

-- CUSTOM - hàm set group attr
function UIFashionTjForm:OnSetGroupAttr(ItemId, type)
    local countCurGroupActive = 0
    local data = GameCenter.NewFashionSystem:GetTuJianData(self.CurSelectIndex)
    for j = 1, #data.ListNeedData do
        local fashionData = GameCenter.NewFashionSystem:GetFashionDogiamData(data.ListNeedData[j].FashionId)
        if fashionData then
            if fashionData.IsActive then
                countCurGroupActive = countCurGroupActive + 1
            end
        end
    end
    local textDataList = List:New()
    -- 设置套装属性Text组件
    local tzAttrList = data:GetRentAttList()
    if tzAttrList ~= nil then
        for i = 1, #tzAttrList do
            local attr = tzAttrList[i]
            local name = L_BattlePropTools.GetBattlePropName(attr.AttId)
            local value = L_BattlePropTools.GetBattleValueText(attr.AttId, attr.Value)
            local text = UIUtils.CSFormat(DataConfig.DataMessageString.Get("C_FASHION_SHOUJI_COUNT"), attr.Num, name, value)

            if attr.Num <= countCurGroupActive then
                text = "[00FF00]" .. text .. "[-]" -- tô xanh
            end
            local _data = {
                Text = text,
                Add = 0
            }
            textDataList:Add(_data)
        end
    end
    self.TzTexts:Refreash(textDataList)

end
-- CUSTOM - hàm set group attr

-- CUSTOM - hàm set attr
function UIFashionTjForm:OnSetAttr(ItemId, type)
    local dataList = GameCenter.NewFashionSystem:GetFashionDogiamList(type)
    local curData = self.CurrentData

    for i = 1, #dataList do
        if dataList[i].ItemId == ItemId then
            curData = dataList[i]
            self.CurrentData = curData
            break
        end
    end

    -- Set properties
    if curData ~= nil then
        local attDataList = List:New()
        local attrList = curData:GetAttList()
        if attrList ~= nil then
            for i = 1, #attrList do
                local attr = attrList[i]
                local name = L_BattlePropTools.GetBattlePropName(attr.AttId)
                local value = attr.Value
                local add = 0
                local text = nil
                if curData.IsActive then
                    -- The currently selected fashion has been activated
                    value = value + curData.StarNum * attr.Add
                    value = L_BattlePropTools.GetBattleValueText(attr.AttId, value)
                    text = UIUtils.CSFormat("{0}:", name)
                    local isShowAdd = curData.StarNum < 5
                    if curData.StarNum < 5 then
                        local addValue = L_BattlePropTools.GetBattleValueText(attr.AttId, attr.Add)
                        add = addValue
                    end
                else
                    -- The currently selected fashion is not activated
                    value = L_BattlePropTools.GetBattleValueText(attr.AttId, value)
                    text = UIUtils.CSFormat("{0}:", name)
                end
                local data = {
                    Text = text,
                    Value = value,
                    Add = add
                }
                attDataList:Add(data)
            end
        end
        self.QtTexts:newRefresh(attDataList)
    end

end
-- CUSTOM - hàm set attr

---[界面按钮回调 end]---

return UIFashionTjForm;
