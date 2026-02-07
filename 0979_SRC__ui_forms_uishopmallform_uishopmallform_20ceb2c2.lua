------------------------------------------------
--author:
--Date: 2019-7-4
--OK button
--Module: UIShopMallForm UIShopMallPanel
--Description: Mall interface logic
------------------------------------------------
local L_UIListMenu = require "UI.Components.UIListMenu.UIListMenu"
local L_PopupListMenu = require "UI.Components.UIPopoupListMenu.PopupListMenu"
local L_UIShopMallPanel = require("UI.Forms.UIShopMallForm.UIShopMallPanel")
local UIShopMallForm = {
    --background texture
    Texture = nil,
    --Close button
    CloseBtn = nil,
    --Mall scripts, product lists and purchase operations are processed in the script
    MallPanel = nil,
    --The currently selected page
    CurPanel = ShopPanelEnum.GoldShop,
    --Func function tag word
    FunctionDic = Dictionary:New()
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function UIShopMallForm:OnRegisterEvents()
	self:RegisterEvent(UIEventDefine.UIShopMallForm_OPEN,self.OnOpen)
	self:RegisterEvent(UIEventDefine.UIShopMallForm_CLOSE,self.OnClose)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGEBTN, self.OnUpdateBtn)
    self:RegisterEvent(LogicLuaEventDefine.EID_EVENT_SHOPFORM_UPDATEPAGE, self.OnUpdateShopItemList)
    self:RegisterEvent(LogicEventDefine.EVENT_COIN_CHANGE_UPDATE, self.OnUpdateCoin)
end

function UIShopMallForm:OnFirstShow()
    self:FindAllComponents()
    self:RegUICallback()
    self.CSForm:AddNormalAnimation()
end
function UIShopMallForm:OnHideBefore()
    self.CurSubPanel = nil
    self.CurPanel = ShopPanelEnum.GoldShop
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_SHOWANIMATION)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.VfxSkin_1:OnDestory()
    self.VfxSkin_2:OnDestory()
    self.VfxSkin_3:OnDestory()
end
function UIShopMallForm:OnShowAfter()
    GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_MAIN_HIDEANIMATION)
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_b_shangcheng"))
    self.MoenyForm:SetMoneyList(3, 12, 2, 1)
    -- self.CSForm:LoadTexture(self.LTexture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_a_107_1"))
    self.VfxSkin_1:OnCreateAndPlay(ModelTypeCode.UIVFX, 300, LayerUtils.GetAresUILayer());
    self.VfxSkin_2:OnCreateAndPlay(ModelTypeCode.UIVFX, 302, LayerUtils.GetAresUILayer());
    self.VfxSkin_3:OnCreateAndPlay(ModelTypeCode.UIVFX, 300, LayerUtils.GetAresUILayer());
end

function UIShopMallForm:OnTryHide()
    return self.MallPanel:OnTryHide()
end

function UIShopMallForm:Update(dt)
    self.MallPanel:Update(dt)
end
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function UIShopMallForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
    if obj ~= nil then
        if type(obj) == "number" then
            self.CurPanel = tonumber(obj)
        else
            self.CurPanel = obj[1]
            if obj[2] then
                self.CurSubPanel = obj[2]
            end
            if obj[3] then
                self.MallPanel.OpenSelectItemId = obj[3]
            else
                self.MallPanel.OpenSelectItemId = nil
            end
        end
    end
    self.MallPanel:OnClose();
    self.MallPanel:HideItemList()
    self.MallPanel:OnUpdateItemList(0, false)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("Load_GoodsList"));
    GameCenter.Network.Send("MSG_Shop.ReqShopSubList", {})
end

--Page message returns, refresh the sub-mall paging list
function UIShopMallForm:OnUpdateBtn(obj, sender)
    self.UIListMenu:RemoveAll()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.LimitShop)
    if _funcInfo.IsVisible then
        self.UIListMenu:AddIcon(ShopPanelEnum.LimitShop, _funcInfo.Cfg.FunctionName)
    end
    self:SetPopMenuForID(ShopPanelEnum.GoldShop)
    self:SetPopMenuForID(ShopPanelEnum.ExchangeShop)

    local _openPanel = self.CurPanel
    if self.CurSubPanel then
        _openPanel = self.CurSubPanel
    end
    self.UIListMenu:SetSelectById(_openPanel)
end

function UIShopMallForm:SetPopMenuForID(shopID)
    local _container = GameCenter.ShopSystem.ShopContainer
    if _container:ContainsKey(shopID) then
        local _spContainer = GameCenter.ShopSystem:GetShopItemContainer(shopID)
        if _spContainer ~= nil then
            local _pageList = _spContainer.ShopPageList
            local _pageFuncDic = Dictionary:New()
            if _pageList then
                for idx = 1, _pageList:Count() do
                    local _info = GameCenter.MainFunctionSystem:GetFunctionInfo(_pageList[idx]);
                    if _info ~= nil and _info.IsVisible then
                        _pageFuncDic:Add(_pageList[idx], _info)
                    end
                end
            end
            _pageFuncDic:SortValue(function(a, b)
                return a.Cfg.FunctionSortNum < b.Cfg.FunctionSortNum
            end)
            _pageFuncDic:Foreach(function(k, v)
                if shopID == self.CurPanel and self.CurSubPanel == nil then
                    self.CurSubPanel = k
                end
                self.UIListMenu:AddIcon(k, v.Cfg.FunctionName)
            end)
        end
    end
end

--Product list message, update product list
function UIShopMallForm:OnUpdateShopItemList(obj, sender)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    self.MallPanel:OnUpdateItemList(obj, sender == true)
end

--Money Change News
function UIShopMallForm:OnUpdateCoin(obj, sender)
    self.MallPanel:OnUpdateHaveCoin(obj)
end

--Click to callback on the big tag list of the mall on the right
function UIShopMallForm:OnClickCallBack(id, select)
    if id == -1 then
        return
    end
    if select then
        if id == ShopPanelEnum.GoldShop or id == ShopPanelEnum.LimitShop or id == ShopPanelEnum.ExchangeShop then
            self.CurPanel = id
            if self.FunctionDic:ContainsKey(id) and self.FunctionDic[id][1] then
                self.PopList:OpenMenuList(self.FunctionDic[id][1].Id)
                return
            end
        else
            self.CurSubPanel = id
            self.CurPanel = ShopPanelEnum.GoldShop
        end
        if self.CurPanel == ShopPanelEnum.GoldShop then
            if self.CurSubPanel then
                self.MallPanel:OnOpen();
                self.MallPanel:OnClickCallBack(self.CurSubPanel, self.CurPanel)
                GameCenter.PushFixEvent(UIEventDefine.UILimitShopForm_CLOSE);
            end
        elseif self.CurPanel == ShopPanelEnum.LimitShop then
            self.MallPanel:OnClose();
            GameCenter.PushFixEvent(UIEventDefine.UILimitShopForm_OPEN, nil, self.CSForm);
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Find various controls on the UI
function UIShopMallForm:FindAllComponents()
    local _myTrans = self.Trans
    self.Texture = UIUtils.FindTex(_myTrans, "BackTex")
    self.LTexture = UIUtils.FindTex(_myTrans, "LeftTop/BackTex")
    self.CloseBtn = UIUtils.FindBtn(_myTrans, "RightTop/CloseBtn")
	self.MoenyForm = UIUtils.RequireUIMoneyForm(UIUtils.FindTrans(_myTrans, "RightTop/UIMoneyForm"));
    self.MallPanel = L_UIShopMallPanel:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "ShopPanel"))
    self.UIListMenu = L_UIListMenu:OnFirstShow(self.CSForm, UIUtils.FindTrans(_myTrans, "UIListMenuTop"))
    self.UIListMenu:ClearSelectEvent();
    self.UIListMenu:AddSelectEvent(Utils.Handler(self.OnClickCallBack, self))
    self.UIListMenu.IsHideIconByFunc = false
    self.VfxSkin_1 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "UIVfxSkinCompoent"))
    self.VfxSkin_2 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "UIVfxSkinCompoent2"))
    self.VfxSkin_3 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(self.Trans, "UIVfxSkinCompoent3"))
end

--Register button callback
function UIShopMallForm:RegUICallback()
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnClickCloseBtn, self)
end

function UIShopMallForm:OnClickCloseBtn()
    if self.CurPanel == ShopPanelEnum.LimitShop then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_CLOSELIMITSHOP,self);
    else
        self:OnClose();
    end
end
--------------------------------------------------------------------------------------------------------------------------------
return UIShopMallForm
