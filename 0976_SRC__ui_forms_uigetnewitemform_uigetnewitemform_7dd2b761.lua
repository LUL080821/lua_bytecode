------------------------------------------------
-- author:
-- Date: 2020-02-19
-- File: UIGetNewItemForm.lua
-- Module: UIGetNewItemForm
-- Description: Boss treasure chest opening interface
------------------------------------------------
local L_StarVfxList = require "UI.Components.UIStarVfxListComponent"

-- //Module definition
local UIGetNewItemForm = {
    -- Background picture
    BackTex = nil,
    -- Item grid
    ItemGrid = nil,
    -- thing
    Items = nil,
    -- closure
    CloseBtn = nil,
    CloseBtn2 = nil,
    -- Special Effects Node
    VfxPlayer = nil,

    -- Waiting for frame count
    WaitFrame = 0,
}

-- Inheriting Form functions
function UIGetNewItemForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIGetNewItemForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIGetNewItemForm_CLOSE, self.OnClose)
end

function UIGetNewItemForm:OnFirstShow()
    self.CSForm:AddNormalAnimation(0.3)
    local _trans = self.Trans
    self.BackTex = UIUtils.FindTex(_trans, "BackTex")
    self.ItemGrid = UIUtils.FindGrid(_trans, "Grid")
    self.Items = {}
    for i = 1, 16 do
        self.Items[i] = UILuaItem:New(UIUtils.FindTrans(_trans, string.format("Grid/%d", i)))
    end
    self.CloseBtn = UIUtils.FindBtn(_trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)
    self.CloseBtn2 = UIUtils.FindBtn(_trans, "Back")
    UIUtils.AddBtnEvent(self.CloseBtn2, self.OnCloseBtnClick, self)
    self.VfxPlayer = L_StarVfxList:OnFirstShow(UIUtils.FindTrans(_trans, "VfxRoot"))
    self.CSForm.UIRegion = UIFormRegion.TopRegion
end

function UIGetNewItemForm:OnShowAfter()
    self.WaitFrame = 2
    for i = 1, 16 do
        self.Items[i].RootGO:SetActive(false)
    end
    self.CloseBtn.gameObject:SetActive(false)
	self.CSForm:LoadTexture(self.BackTex,AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_270"))
end

function UIGetNewItemForm:OnHideBefore()
    GameCenter.GetNewItemSystem:OnFormClose();
end

-- Turn on the event
function UIGetNewItemForm:OnOpen(obj, sender)
    self.CSForm:Show(sender)
end

-- Close Event
function UIGetNewItemForm:OnClose(obj, sender)
    self.CSForm:Hide()
end

function UIGetNewItemForm:OnTryHide()
    if self.VfxPlayer.IsPlaying then
        self.VfxPlayer:ForcePlayAll()
        return false
    end
    return true
end

-- Click Close button
function UIGetNewItemForm:OnCloseBtnClick()
    if self.VfxPlayer.IsPlaying then
        self.VfxPlayer:ForcePlayAll()
        return
    end
    self:OnClose(nil, nil)
end

-- Update the interface
function UIGetNewItemForm:RefreshPanel()
    local _luaList = GameCenter.GetNewItemSystem.FormItemList
    local _itemCount = #_luaList
    local _itemVfxData = {}
    for i = 1, 16 do
        if i <= _itemCount then
            self.Items[i].RootGO:SetActive(true)
            if _luaList[i].Item ~= nil then
                local _itemInst = _luaList[i].Item
                self.Items[i]:InItWithCfgid(_itemInst.CfgID, _luaList[i].ItemCount, _itemInst.IsBind)
            else
                self.Items[i]:InItWithCfgid(_luaList[i].ItemCfgID, _luaList[i].ItemCount)
            end
            _itemVfxData[i] = {StarGo = self.Items[i].RootGO, VfxID = 65, Layer = LayerUtils.GetUITopLayer()}
        else
            self.Items[i].RootGO:SetActive(false)
        end
    end
    self.ItemGrid:Reposition()
    if _itemCount <= 8 then
        self.VfxPlayer:Play(_itemVfxData, 0.25, 0.3)
    else
        self.VfxPlayer:Play(_itemVfxData, 0.125, 0.3)
    end
    self.CloseBtn.gameObject:SetActive(true)
end

-- renew
function UIGetNewItemForm:Update(dt)
    if self.WaitFrame >= 0 then
        self.WaitFrame = self.WaitFrame - 1
        if self.WaitFrame < 0 then
            self:RefreshPanel()
        end
    end
end

return UIGetNewItemForm
