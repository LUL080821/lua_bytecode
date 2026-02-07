------------------------------------------------
-- author:
-- Date: 2020-01-17
-- File: UIAuctionCarePanel.lua
-- Module: UIAuctionCarePanel
-- Description: Follow the interface
------------------------------------------------
local L_PopupListMenu = require "UI.Components.UIPopoupListMenu.PopupListMenu"
local UIAuctionCareItemPanel = require "UI.Forms.UIAuctionHouseForm.UIAuctionCareItemPanel"

-- //Module definition
local UIAuctionCarePanel = {
    -- Current transform
    Trans = nil,
    Go = nil,
    -- father
    Parent = nil,
    -- Animation module
    AnimModule = nil,
    -- menu
    PopList = nil,
    -- Item pagination
    ItemPanel = nil,
}

function UIAuctionCarePanel:OnFirstShow(trans, parent, rootForm)
    self.Trans = trans
    self.Go = trans.gameObject
    self.Parent = parent
    self.RootForm = rootForm

    -- Create an animation module
    self.AnimModule = UIAnimationModule(self.Trans)
    -- Add an animation
	self.AnimModule:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
    self.Go:SetActive(false)
    -- Add PopoupListMenu
    self.PopList = L_PopupListMenu:CreateMenu(UIUtils.FindTrans(trans, "BtnScrll/PopoupList"), Utils.Handler(self.OnClickChildMenu,self), 3, false, false)
    self.PopList.IsHideMenuForNoChild = false
    self.BigTypeList = List:New()
    local _nameList = List:New()
    DataConfig.DataAuctionCareMenu:Foreach(function(key, value)
        if value.ParentId <= 0 then
            self.BigTypeList:Add(key)
            _nameList:Add(value.Name)
        end
    end)
    for i = 1, #self.BigTypeList do
        self.PopList:AddMenu(self.BigTypeList[i], _nameList[i], {})
    end
    self.ItemPanel = UIAuctionCareItemPanel:OnFirstShow(UIUtils.FindTrans(trans, "ItemPanel"), self, rootForm)
    return self
end

function UIAuctionCarePanel:Show()
    -- Play the start-up picture
    self.AnimModule:PlayEnableAnimation()
    local _menuDataDic = Dictionary:New()
    local _lpLevel = GameCenter.GameSceneSystem:GetLocalPlayerLevel()
    local _worldLevel = GameCenter.OfflineOnHookSystem:GetCurWorldLevel()
    local _openServerDay = Time.GetOpenSeverDay()
    DataConfig.DataAuctionCareMenu:Foreach(function(key, value)
        if value.LevelLimit > _lpLevel then
            return
        end
        if value.WorldLevelLimit > _worldLevel then
            return
        end
        if value.OpenServerDayLimit > _openServerDay then
            return
        end
        if value.ParentId <= 0 then
            _menuDataDic[key] = List:New()
        else
            local _parentData = _menuDataDic[value.ParentId]
            if _parentData then
                _parentData:Add({Id = value.Id ,Name = value.Name})
            end
        end
    end)
    for i = 1, #self.BigTypeList do
        local _key = self.BigTypeList[i]
	    self.PopList:RefreashMenu(_key, _menuDataDic[_key])
    end
    local _sex = Utils.OccToSex(GameCenter.GameSceneSystem:GetLocalPlayer().Occ)
    if _sex == 0 then
        self.PopList:OpenMenuList(100, false)
    else
        self.PopList:OpenMenuList(200, false)
    end
end

function UIAuctionCarePanel:Hide()
    -- Play Close animation
    self.Go:SetActive(false)
end

function UIAuctionCarePanel:OnClickChildMenu(id)
    if id <= 0 then
        return
    end
    self.ItemPanel:Refresh(id)
end

function UIAuctionCarePanel:Update(dt)
    self.PopList:Update(dt)
end

return UIAuctionCarePanel
