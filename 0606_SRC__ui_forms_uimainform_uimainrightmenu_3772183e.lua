------------------------------------------------
--作者： yangqf
--日期： 2021-02-25
--文件： UIMainRightMenu.lua
--模块： UIMainRightMenu
--描述： 主界面菜单分页
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute
local MainFunctionSystem = CS.Thousandto.Code.Logic.MainFunctionSystem

local FUNCTION_POS_TYPE = 6
local UIMainRightMenu = {
    MenuPanelGo                  = nil,
    MenuPanelTrans               = nil,
    BgBoxTex                     = nil,
    BlankClose                   = nil,

    PlayerInfo                   = nil,
    UIPlayerHead                 = nil,
    TxtLpLevel                   = nil,
    TxtExpValue                  = nil,
    ProgressBar                  = nil,
    TxtName                      = nil,
    RoleIDLabel                  = nil,
    TxtServer                    = nil,

    QuickAccessPanel             = nil,
    BtnList_QuickAccess          = List:New(), -- list all
    BtnDic_QuickAccess           = Dictionary:New(), -- list transform UI data
    VisibleIndexMap_QuickAccess  = List:New(), -- list realIndex (item visible)

    Scroll_MainFunction          = nil,
    Grid_MainFunction            = nil,
    UILoopGrid                   = nil,
    BtnList_MainFunction         = List:New(), -- list all
    BtnDic_MainFunction          = Dictionary:New(), -- list transform UI data
    VisibleIndexMap_MainFunction = List:New(), -- list realIndex (item visible)
    Count_MainFunction           = 10,
    IsMenuVisible                = false
}

function UIMainRightMenu:OnRegisterEvents()
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_BASE_ATTR_CHANGED, self.OnBaseProChanged)
end

local L_MainFunctionButton = nil
local L_QuickAccessButton = nil

function UIMainRightMenu:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, { __index = L_UIMainSubBasePanel.New() })
    self:BaseFirstShow(trans, parent, rootForm)

    local _trans = trans
    self.MenuBtn = UIUtils.FindBtn(_trans, "MenuBtnBox")
    UIUtils.AddBtnEvent(self.MenuBtn, self.OnMainRightMenuToggle, self)

    self.MenuPanelGo = UIUtils.FindGo(_trans, "Container")
    self.MenuPanelTrans = UIUtils.FindTrans(_trans, "Container")
    local _panelTrans = UIUtils.FindTrans(_trans, "Container")
    self.BgBoxTex = UIUtils.FindTex(_panelTrans, "BgBoxTex")
    self.BlankClose = UIUtils.FindBtn(_panelTrans, "BlankClose")
    UIUtils.AddBtnEvent(self.BlankClose, self.OnMainRightMenuClose, self)
    ----- Player Info
    self.PlayerInfo = UIUtils.FindTrans(_panelTrans, "TopBox")
    self.UIPlayerHead = PlayerHead:New(UIUtils.FindTrans(_panelTrans, "TopBox/Head"))
    self.HeadBtn = UIUtils.FindBtn(_panelTrans, "TopBox/Head")
    UIUtils.AddBtnEvent(self.HeadBtn, self.OnClickBtnChangeHeadCallBack, self);

    -- Level
    self.TxtLpLevel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(_panelTrans, "TopBox/Level"))
    -- Exp
    self.TxtExpValue = UIUtils.FindLabel(_panelTrans, "TopBox/Exp/TxtValue")
    self.ProgressBar = UIUtils.FindProgressBar(_panelTrans, "TopBox/Exp/ProgressExp")
    -- Name
    self.TxtName = UIUtils.FindLabel(_panelTrans, "NameBg/Name")
    self.BtnChangeName = UIUtils.FindBtn(_panelTrans, "NameBg/ChangeNameBtn")
    UIUtils.AddBtnEvent(self.BtnChangeName, self.OnClickBtnChangeNameCallBack, self)
    -- RoleID
    self.RoleIDLabel = UIUtils.FindLabel(_panelTrans, "TopBox/RoleID/Text")
    self.RoleIDCopyBtn = UIUtils.FindBtn(_panelTrans, "TopBox/RoleID/CopyBtn")
    -- Sever
    self.TxtServer = UIUtils.FindLabel(_panelTrans, "TopBox/Server/Text")
    UIUtils.AddBtnEvent(self.RoleIDCopyBtn, self.OnClickRoleIDCopyBtn, self);

    ----- Right Button Group
    self.Panel_QuickAccess = UIUtils.FindTrans(_panelTrans, "BtnBoxRGroup")
    self.Grid_QuickAccess = UIUtils.FindGrid(_panelTrans, "BtnBoxRGroup/Grid")
    ----- Main Button Group
    self.Scroll_MainFunction = UIUtils.FindScrollView(_panelTrans, "BtnBoxLGroupScroll")
    self.Grid_MainFunction = UIUtils.FindGrid(_panelTrans, "BtnBoxLGroupScroll/Grid")
    self.UILoopGrid = UIUtils.RequireUILoopScrollViewBase(self.Grid_MainFunction.transform)
    self.UILoopGrid:SetDelegate(Utils.Handler(self.LoopGridCallBack, self));
    ----- Init Data
    self:SplitDataBySortNum()
    ---- Set Animation
    self.AnimModule:RemoveTransAnimation(self.MenuPanelTrans)
    self.AnimModule:AddAlphaPosAnimation(self.MenuPanelTrans, 0, 1, 0, 0, 0.5, false, false)
end

function UIMainRightMenu:SetPlayerInfo()
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer();
    self.UIPlayerHead:SetLocalPlayer()

    -- ==== PLAYER INFO ====
    if _lp ~= nil then
        local lv = _lp.Level or 1
        local curExp = _lp.CurExp or 0
        local name = _lp.Name or "Unknown_Player"

        local cfgLv = DataConfig.DataCharacters[lv]
        local maxExp = (cfgLv and cfgLv.Exp) or 1

        -- Level
        self.TxtLpLevel:SetLevel(lv, true)
        -- Exp text
        UIUtils.SetTextByProgress(self.TxtExpValue, curExp, maxExp, false, 4)
        self.ProgressBar.value = curExp / maxExp
        -- Name & Role
        UIUtils.SetTextByString(self.TxtName, name)
        UIUtils.SetTextByString(self.RoleIDLabel, Utils.ToString(_lp.ID, 36))
    else
        -- Name & Role
        UIUtils.SetTextByString(self.TxtName, "Unknow_Reson")
        UIUtils.SetTextByEnum(self.RoleIDLabel, "Unknow_Reson")
    end

    -- ==== SERVER INFO ====
    local _curServer = GameCenter.ServerListSystem:GetCurrentServer();
    if _curServer ~= nil then
        UIUtils.SetTextByString(self.TxtServer, _curServer.Name);
    else
        UIUtils.SetTextByEnum(self.ServerLabel, "Unknow_Reson")
    end
end

function UIMainRightMenu:OnClickBtnChangeHeadCallBack()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.CustomHead);
end

function UIMainRightMenu:OnClickBtnChangeNameCallBack()
    GameCenter.PushFixEvent(UIEventDefine.UIChangeNameCardForm_OPEN, UIChangeNameCardType.Role);
end

function UIMainRightMenu:OnClickRoleIDCopyBtn()
    -- Copy to Clipboard
    UnityUtils.CopyToClipboard(UIUtils.GetText(self.RoleIDLabel))
    Debug.Log("Copy:::" .. UIUtils.GetText(self.RoleIDLabel));
end

function UIMainRightMenu:OnMainRightMenuToggle()
    if self.IsMenuVisible then
        self:OnMainRightMenuClose()
    else
        self:OnMainRightMenuOpen()
    end
end
function UIMainRightMenu:OnMainRightMenuOpen()
    self.IsMenuVisible = true
    self.AnimModule:PlayShowAnimation(self.MenuPanelTrans)
    if self.IsVisible == true then
        self:Render_QuickAccessUI()
        self:Render_MainFunctionUI()
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_MAIN_RIGHT_MENU_OPEN)
end
function UIMainRightMenu:OnMainRightMenuClose()
    self.IsMenuVisible = false
    self.AnimModule:PlayHideAnimation(self.MenuPanelTrans)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_ON_MAIN_RIGHT_MENU_CLOSE)
end

function UIMainRightMenu:LoopGridCallBack(trans, name, isClear)
    local index = tonumber(name)
    local _uiItem = self.BtnDic_MainFunction:Get(trans)
    if _uiItem == nil then
        _uiItem = L_MainFunctionButton:New(trans.gameObject)
        self.BtnDic_MainFunction:Add(trans, _uiItem)
    end

    local _realIndex = self.VisibleIndexMap_MainFunction[index]
    local _data = self.BtnList_MainFunction[_realIndex]
    _uiItem:SetData(_data)
end

--====================================================
--== Chia danh sách theo SortNum
--====================================================
function UIMainRightMenu:SplitDataBySortNum()
    self.BtnList_QuickAccess:Clear()
    self.BtnList_MainFunction:Clear() -- List lua: start Index = 1
    local _itemList = GameCenter.MainFunctionSystem:GetFunctionList(FUNCTION_POS_TYPE) -- List C#: start Index = 0
    local function SortFunc(left, right)
        return left.SortNum < right.SortNum
    end

    for index = 1, _itemList.Count do
        local data = _itemList[index - 1]
        if data.SortNum < 100 then
            self.BtnList_QuickAccess:Add(data)
        elseif data.SortNum >= 100 and data.SortNum <= 999 then
            self.BtnList_MainFunction:Add(data)
        else

        end
    end
    self.BtnList_QuickAccess:Sort(SortFunc)
    self.BtnList_MainFunction:Sort(SortFunc)
end

--====================================================
--== Tạo VisibleIndexMap cho mỗi list
--====================================================
function UIMainRightMenu:RebuildVisibleMap()
    -- QuickAccess
    self.VisibleIndexMap_QuickAccess:Clear()
    for index = 1, self.BtnList_QuickAccess:Count() do
        local data = self.BtnList_QuickAccess[index]
        if data.IsVisible then
            self.VisibleIndexMap_QuickAccess:Add(index)
        end
    end

    -- MainFunction
    self.VisibleIndexMap_MainFunction:Clear()
    for index = 1, self.BtnList_MainFunction:Count() do
        local data = self.BtnList_MainFunction[index]
        if data.IsVisible then
            self.VisibleIndexMap_MainFunction:Add(index)
        end
    end
end

--====================================================
--== Render button QuickAccess
--====================================================
function UIMainRightMenu:Render_QuickAccessUI()
    local _rootTrans = self.Grid_QuickAccess.transform
    local _temp = _rootTrans:GetChild(0)
    _temp.gameObject:SetActive(false)
    local _childCount = _rootTrans.childCount
    --
    local visibleCount = self.VisibleIndexMap_QuickAccess:Count()
    for index = 1, visibleCount do
        local _go = nil
        -- 1. Lấy gameObject của UIItem
        if index <= _childCount then
            _go = _rootTrans:GetChild(index - 1).gameObject
        else
            _go = UnityUtils.Clone(_temp.gameObject)
        end
        _go:SetActive(true)

        -- 2. Check UIItem đã xử lý hay chưa (đã tồn tại chưa)
        local _uiItem = self.BtnDic_QuickAccess:Get(_go.transform)
        if _uiItem == nil then
            -- 2. Map UIItem với class lua
            _uiItem = L_QuickAccessButton:New(_go, nil, self)
            self.BtnDic_QuickAccess:Add(_go.transform, _uiItem)
        end

        -- 3. set Data cho UIItem
        local _realIndex = self.VisibleIndexMap_QuickAccess[index]
        local _data = self.BtnList_QuickAccess[_realIndex]
        _uiItem:SetData(_data)
    end
    -- Hidden các item tạo thừa trên prefab
    for i = visibleCount, _childCount - 1 do
        _rootTrans:GetChild(i).gameObject:SetActive(false)
    end
    self.Grid_QuickAccess.repositionNow = true
end

--====================================================
--== Render button
--====================================================
function UIMainRightMenu:Render_MainFunctionUI()
    local _count = self.VisibleIndexMap_MainFunction:Count()
    if _count > 0 then
        if self.Count_MainFunction < _count then
            self.Count_MainFunction = _count
        end
    end
    if self.Grid_MainFunction and self.Grid_MainFunction.gameObject.activeInHierarchy then
        self.UILoopGrid:Init(self.Count_MainFunction)
        self.Grid_MainFunction.repositionNow = true
    end
end

function UIMainRightMenu:Refresh()
    self:SetPlayerInfo()
    -- 1. Update data func
    self:SplitDataBySortNum()

    -- 2. Update Visible map
    self:RebuildVisibleMap()

    -- 3. Render UI
    self:Render_QuickAccessUI()
    self:Render_MainFunctionUI()
end

function UIMainRightMenu:OnFuncUpdated(funcInfo, sender)
    -- 1. Validate func
    if funcInfo == nil then
        return
    end

    local _funcId = funcInfo.ID
    local _cfg = DataConfig.DataFunctionStart[_funcId]
    if _cfg == nil or _cfg.FunctionPosType ~= FUNCTION_POS_TYPE then
        return
    end
    -- 2. Detect group
    local _group = nil
    if _cfg.FunctionSortNum < 100 then
        _group = "Quick"
    elseif _cfg.FunctionSortNum >= 100 and _cfg.FunctionSortNum <= 999 then
        _group = "Main"
    else
        return
    end

    self:RebuildVisibleMap()
    if _group == "Quick" then
        self:Render_QuickAccessUI()
    else
        self:Render_MainFunctionUI()
    end
end

function UIMainRightMenu:OnBaseProChanged(prop, sender)
    if prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Name
            or prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Level
            or prop.CurrentChangeBasePropType == L_RoleBaseAttribute.Exp
            or prop.CurrentChangeBasePropType == L_RoleBaseAttribute.GuildName
            or prop.CurrentChangeBasePropType == L_RoleBaseAttribute.VipLevel
    then
        self:SetPlayerInfo()
    end
end

function UIMainRightMenu:OnShowBefore()
end

function UIMainRightMenu:OnShowAfter()
    self:SetPlayerInfo()
    self:RebuildVisibleMap()
    --self:Render_QuickAccessUI()
    --self:Render_MainFunctionUI()

    -- Set Default is Not-Active
    if self.IsVisible then
        self.IsMenuVisible = false
        self.MenuPanelGo:SetActive(false)
    end
    self.Parent:LoadTexture(self.BgBoxTex, ImageTypeCode.UI, "tex_n_d_right")
end

function UIMainRightMenu:OnHideBefore()
    self.Grid_MainFunction.repositionNow = false
    self.Grid_QuickAccess.repositionNow = false
end

function UIMainRightMenu:Update(dt)

end

function UIMainRightMenu:ClearAll()
    self.BtnList_AllData:Clear()
    self.BtnList_QuickAccess:Clear()
    self.BtnList_MainFunction:Clear()
    self.VisibleIndexMap_QuickAccess:Clear()
    self.VisibleIndexMap_MainFunction:Clear()
    self.BtnDic_MainFunction:Clear()
    self.BtnDic_QuickAccess:Clear()
end

------------------------------------------------------------------------------------------------------------------------
--region L_MainFunctionButton
-- Các icon menu chính. Ex: Bộ tộc, Cửa hàng, chợ,...
-- ---------------------------------------------------------------------------------------------------------------------
L_MainFunctionButton = {
    RootGo         = nil, -- The current button object
    RootTrans      = nil, -- The current button transform object
    Btn            = nil, -- Button component
    Bg             = nil, --
    Icon           = nil, -- Sprite component
    Name           = nil, -- Name
    RedPointGo     = nil, -- Red dot object
    EffectGo       = nil, -- Effect object
    Data           = nil, -- Button function information
    Cfg            = nil,
    Type           = nil,
    GetEffectTimer = -1,
    IsVisible      = false,
}
function L_MainFunctionButton:New(go, data)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    _m.RootTrans = go.transform

    local _trans = _m.RootTrans
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.Bg = UIUtils.FindSpr(_trans, "Bg")
    _m.Icon = UIUtils.FindSpr(_trans, "Icon")
    _m.Name = UIUtils.FindLabel(_trans, "Icon/Name")
    _m.RedPointGo = UIUtils.FindGo(_trans, "Icon/RedPoint")
    _m.EffectGo = UIUtils.FindGo(_trans, "Icon/Effect")
    -- bind event
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)

    _m:SetData(data)
    return _m
end

function L_MainFunctionButton:SetData(data)
    self.Data = data
    if not (data and data.ID) then
        self.RootGo:SetActive(false)
        return
    end

    local funcId = UnityUtils.GetObjct2Int(data.ID)
    local cfg = DataConfig.DataFunctionStart[funcId]
    if not cfg then
        self.RootGo:SetActive(false)
        return
    end
    self.Cfg = cfg
    self.RootGo.name = tostring(funcId or "Unknown")
    self.Type = self:GetButtonTypeBySortNum(data.SortNum)
    self:LoadBgSpriteByType(self.Type)
    self.Icon.spriteName = self.Cfg.MainIcon
    UIUtils.SetTextByStringDefinesID(self.Name, self.Cfg._FunctionName)

    -- Refresh
    self:RefreshData()
end

-- Refresh interface
function L_MainFunctionButton:RefreshData()
    local data = self.Data
    if data and data.IsVisible then
        self.RootGo:SetActive(true)
        self.RedPointGo:SetActive(data.IsShowRedPoint or false)
        self.EffectGo:SetActive(data.IsEffectShow or (data.IsEffectByAlert and data.IsShowRedPoint))
        self.IsVisible = true
    else
        self.RootGo:SetActive(false)
        self.GetEffectTimer = -1
        self.Icon.alpha = 1
        self.IsVisible = false
    end
end

--[[-- Play start effect
function L_MainFunctionButton:PlayOpenEffect(hideIcon)
    if hideIcon then
        self.GetEffectTimer = 1.2
        self.Icon.alpha = 0
    end
end

function L_MainFunctionButton:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.GetEffectTimer > 0 then
        self.GetEffectTimer = self.GetEffectTimer - dt
        if self.GetEffectTimer <= 0 then
            self.GetEffectTimer = -1
            self.Icon.alpha = 1
        end
    end
end]]

function L_MainFunctionButton:OnBtnClick()
    self.Data:OnClickHandler(nil)
end

local DEFAULT_TYPE = 0
local SPRITE_MAP_MAIN_BTN = {
    [0] = "n_bg_btnbox_1", -- XÁM
    [1] = "n_bg_btnbox_2", -- VÀNG
    [2] = "n_bg_btnbox_3", -- ĐỎ
}

function L_MainFunctionButton:GetButtonTypeBySortNum(sortNum)
    if sortNum == nil then
        return DEFAULT_TYPE
    end
    return sortNum % 10
end

function L_MainFunctionButton:LoadBgSpriteByType(buttonType)
    local spriteName = SPRITE_MAP_MAIN_BTN[buttonType] or SPRITE_MAP_MAIN_BTN[DEFAULT_TYPE]
    if self.Bg then
        self.Bg.spriteName = spriteName
    end
end

--endregion L_MainFunctionButton

------------------------------------------------------------------------------------------------------------------------
--region L_QuickAccessButton
-- Các icon menu truy cập nhanh. Ex: Nhân vật, túi, cài đặt
-- ---------------------------------------------------------------------------------------------------------------------
L_QuickAccessButton = {
    RootGo         = nil, -- The current button object
    RootTrans      = nil, -- The current button transform object
    ParentPanel    = nil, --
    Btn            = nil, -- Button component
    Icon           = nil, -- Sprite component
    Name           = nil, -- Name
    RedPointGo     = nil, -- Red dot object
    EffectGo       = nil, -- Effect object
    Data           = nil, -- Button function information
    Cfg            = nil,
    GetEffectTimer = -1,
}
function L_QuickAccessButton:New(go, data, parent)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = go
    _m.RootTrans = go.transform
    _m.ParentPanel = parent or nil
    local _trans = _m.RootTrans
    _m.Btn = UIUtils.FindBtn(_trans)
    _m.Icon = UIUtils.FindSpr(_trans, "Icon")
    _m.Name = UIUtils.FindLabel(_trans, "Name")
    _m.RedPointGo = UIUtils.FindGo(_trans, "RedPoint")
    _m.EffectGo = UIUtils.FindGo(_trans, "Effect")
    -- Bind event
    UIUtils.AddBtnEvent(_m.Btn, _m.OnBtnClick, _m)

    _m:SetData(data)
    return _m
end

function L_QuickAccessButton:SetData(data)
    self.Data = data
    if not (data and data.ID) then
        self.RootGo:SetActive(false)
        return
    end

    local funcId = UnityUtils.GetObjct2Int(data.ID)
    local cfg = DataConfig.DataFunctionStart[funcId]
    if not cfg then
        self.RootGo:SetActive(false)
        return
    end

    self.Cfg = cfg
    self.RootGo.name = tostring(funcId or "Unknown")
    self.Icon.spriteName = self.Cfg.MainIcon
    UIUtils.SetTextByStringDefinesID(self.Name, self.Cfg._FunctionName)

    -- Refresh
    self:RefreshData()
end

-- Refresh interface
function L_QuickAccessButton:RefreshData()
    local data = self.Data
    if data and data.IsVisible then
        self.RootGo:SetActive(true)
        self.RedPointGo:SetActive(data.IsShowRedPoint)
        self.EffectGo:SetActive(data.IsEffectShow or (data.IsEffectByAlert and data.IsShowRedPoint))
        self.IsVisible = true
    else
        self.RootGo:SetActive(false)
        self.GetEffectTimer = -1
        self.Icon.alpha = 1
        self.IsVisible = false
    end
end

--[[ Play start effect
function L_QuickAccessButton:PlayOpenEffect(hideIcon)
    if hideIcon then
        self.GetEffectTimer = 1.2
        self.Icon.alpha = 0
    end
end

function L_QuickAccessButton:Update(dt)
    if not self.IsVisible then
        return
    end
    if self.GetEffectTimer > 0 then
        self.GetEffectTimer = self.GetEffectTimer - dt
        if self.GetEffectTimer <= 0 then
            self.GetEffectTimer = -1
            self.Icon.alpha = 1
        end
    end
end]]

function L_QuickAccessButton:OnBtnClick()
    if self.ParentPanel then
        -- Close PopMenu khi Click các button QuickAccess
        self.ParentPanel:OnMainRightMenuClose()
    end
    self.Data:OnClickHandler(nil)
end

--endregion L_QuickAccessButton

return UIMainRightMenu