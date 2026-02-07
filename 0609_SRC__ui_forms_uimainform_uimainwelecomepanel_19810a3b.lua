-- author:
-- Date: 2019-07-19
-- File: UIMainWeleComePanel.lua
-- Module: UIMainWeleComePanel
-- Description: Welcome interface
------------------------------------------------
local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local CSGameCenter = CS.Thousandto.Code.Center.GameCenter

local UIMainWeleComePanel = {
    -- Background picture
    BackTex = nil,
    BackTex2 = nil,
    -- Start button
     StartBtn = nil,
     -- Start countdown
     RemainTime = nil,
     -- Countdown
     Timer = 0,
     FrontUpdateTime = -1,
     IsClickStart = false,
     MainPanel = nil,
     -- Role Model
     Skin = nil,

     Vfx1 = nil,
     Vfx2 = nil,
     Vfx3 = nil,

     CloseTimer = 0,

     ModelIsLoad = false,
     TexIsLoad = false,
}

function UIMainWeleComePanel:OnClose(obj,sender)
    self:Close()
end

function UIMainWeleComePanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    local _trans = trans
    self.BackTex = UIUtils.FindTex(_trans, "BackTex")
    self.BackTex2 = UIUtils.FindTex(_trans, "BackTex/RightTop/Texture")
    self.StartBtn = UIUtils.FindBtn(_trans, "BackTex/Start")
    UIUtils.AddBtnEvent(self.StartBtn, self.OnStartBtnClick, self)
    self.RemainTime = UIUtils.FindLabel(_trans, "BackTex/Start/Time")
    self.Skin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(_trans, "BackTex/UIRoleSkinCompoent"))
    self.Skin:OnFirstShow(rootForm.CSForm, FSkinTypeCode.Monster, "idle", 1, true)
    self.Skin.EnableDrag = false
    self.Vfx1 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "BackTex/RightTop/UIVfxSkinCompoent"))
    self.Vfx2 = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(_trans, "UIVfxSkinCompoent"))
    self.MainPanel = UIUtils.FindPanel(_trans)
    self.AnimModule:AddNormalAnimation(0.3)
end

function UIMainWeleComePanel:OnShowAfter()
    self.ModelIsLoad = false
    self.TexIsLoad = false
    if(CSGameCenter.TextureManager) then 
        if(CSGameCenter.TextureManager.UnLockAsset) then
            if(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_272")) then
                CSGameCenter.TextureManager:UnLockAsset(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_272"))
            else
                Debug.Log("AssetUtils.GetImageAssetPath(ImageTypeCode.UI, tex_n_d_272) is nil")
            end
        else
            Debug.Log("CSGameCenter.TextureManager.UnLockAsset is nil")
        end
    else
        Debug.Log("CSGameCenter.TextureManager is nil")
    end
    -- CSGameCenter.TextureManager:UnLockAsset(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_272"))
    self.RootForm.CSForm:LoadTexture(self.BackTex, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_272"), Utils.Handler(self.OnTexLoaded, self))
    self.RootForm.CSForm:LoadTexture(self.BackTex2, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_272_1"))
    self.FrontUpdateTime = -1
    self.IsClickStart = false
    self.Skin:SetEquip(FSkinPartCode.Body, 7000003)
    self.Skin:SetOnSkinPartChangedHandler(Utils.Handler(self.OnSkinPartChanged, self))
    self.Vfx1:OnCreateAndPlay(ModelTypeCode.UIVFX, 272, LayerUtils.GetAresUILayer())
    self.Vfx2:OnCreateAndPlay(ModelTypeCode.UIVFX, 273, LayerUtils.GetAresUILayer())
    self.BackTex.alpha = 1
    self.Timer = -1
end

function UIMainWeleComePanel:OnHideBefore()
    self.Skin:ResetSkin()
    self.Vfx1:OnDestory()
    self.Vfx2:OnDestory()
    self:UnLoadPreLoadTex()
    self.Skin:SetOnSkinPartChangedHandler(nil)
end

function UIMainWeleComePanel:UnLoadPreLoadTex()
    self.RootForm.CSForm:UnloadTexture(self.BackTex)
    self.RootForm.CSForm:UnloadTexture(self.BackTex2)
end

function UIMainWeleComePanel:OnSkinPartChanged(x, y)
    self.ModelIsLoad = true
    if self.ModelIsLoad and self.TexIsLoad then
        -- Close loading after loading is completed
        if GameCenter.LoadingSystem then
           GameCenter.LoadingSystem:Close()
        end
        self.Timer = 10
    end
end

function UIMainWeleComePanel:OnTexLoaded(x)
    self.TexIsLoad = true
    if self.ModelIsLoad and self.TexIsLoad then
        -- Close loading after loading is completed
        if GameCenter.LoadingSystem then
           GameCenter.LoadingSystem:Close()
        end
        self.Timer = 10
    end
end

function UIMainWeleComePanel:OnStartBtnClick()
    if self.IsClickStart then
        return
    end
    self.IsClickStart = true
    self.CloseTimer = 0.1
    self.BackTex.alpha = 0
    self.Skin:ResetSkin()
    self.Vfx1:OnDestory()
    self.Vfx2:OnDestory()

    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    if _lp ~= nil then
        _lp.FightState = false
    end
end

function UIMainWeleComePanel:Update(dt)
    if not self.IsVisible then
        return
    end

    if self.Timer > 0 then
        self.Timer = self.Timer - dt
        local _iTime = math.floor(self.Timer)
        if _iTime >= 0 and _iTime ~= self.FrontUpdateTime then
            self.FrontUpdateTime = _iTime
            UIUtils.SetTextFormat(self.RemainTime, "({0}s)", _iTime)
        end
        if self.Timer <= 0 then
            -- complete
            GosuSDK.CallCSharpMethod("GTrackingFunction", "completeTutorial", GosuSDK.GetLocalValue("account"), GosuSDK.GetLocalValue("saveRoleId") , GosuSDK.getNamePlayer(), GosuSDK.GetLocalValue("saveEnterServerId"))
            self:OnStartBtnClick()
        end
    end

    if self.CloseTimer > 0 then
        self.CloseTimer = self.CloseTimer - dt
        if self.CloseTimer <= 0 then
            self:OnClose(nil)

            Debug.Log("Disable auto run task when create character")
            -- local _logic = GameCenter.MapLogicSystem.ActiveLogic
            -- if _logic ~= nil and _logic.PlayLongBorn ~= nil then
            --     _logic:PlayLongBorn()
            -- else
            --     GameCenter.TaskController:Run(GameCenter.LuaTaskManager:GetMainTaskId())
            -- end
        end
    end
end

return UIMainWeleComePanel
