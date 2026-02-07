------------------------------------------------
-- author:
-- Date: 2021-02-27
-- File: UIFlySwordShowPanel.lua
-- Module: UIFlySwordShowPanel
-- Description: The main interface sword spirit display paging
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"
local L_RoleBaseAttribute = CS.Thousandto.Code.Global.RoleBaseAttribute

local L_SwordParams = {
    [1] = {
        Pos = {-55, -35},
        Rot = {0, 0, 0},
        Scale = 70,
        Anim = "idle",
    },
    [2] = {
        Pos = {-55, -35},
        Rot = {0, 0, 0},
        Scale = 70,
        Anim = "idle",
    },
    [7] = {
        Pos = {-55, -35},
        Rot = {0, 0, 0},
        Scale = 70,
        Anim = "idle",
    },
    [8] = {
        Pos = {-29, 30},
        Rot = {32, 129, -155},
        Scale = 100,
        Anim = "idle",
    },
    [13] = {
        Pos = {-4, 29},
        Rot = {32, 129, -155},
        Scale = 100,
        Anim = "idle",
    },
    [14] = {
        Pos = {-4, 29},
        Rot = {32, 129, -155},
        Scale = 100,
        Anim = "idle",
    },
    [19] = {
        Pos = {-84, -70},
        Rot = {0, 0, 0},
        Scale = 100,
        Anim = "idle",
    },
    [20] = {
        Pos = {-84, -70},
        Rot = {0, 0, 0},
        Scale = 100,
        Anim = "idle",
    },
    [25] = {
        Pos = {-94, -42},
        Rot = {0, 180, 0},
        Scale = 80,
        Anim = "idle",
    },
    [26] = {
        Pos = {-94, -42},
        Rot = {0, 180, 0},
        Scale = 80,
        Anim = "idle",
    },
    [31] = {
        Pos = {-91, -40},
        Rot = {0, 180, -13},
        Scale = 80,
        Anim = "idle",
    },
    [32] = {
        Pos = {-91, -40},
        Rot = {0, 180, -13},
        Scale = 80,
        Anim = "idle",
    },
}
local L_ModelParams = {
    [3] = {
        Pos = {-89, -30},
        Rot = {0, 150, 0},
        Scale = 120,
        Anim = "run",
    },
    [4] = {
        Pos = {-89, -20},
        Rot = {0, 150, 0},
        Scale = 100,
        Anim = "run",
    },
    [5] = {
        Pos = {-89, -43},
        Rot = {0, 150, 0},
        Scale = 100,
        Anim = "run",
    },
    [6] = {
        Pos = {-89, -55},
        Rot = {0, 150, 0},
        Scale = 100,
        Anim = "run",
    }
}

local UIFlySwordShowPanel = {
    RootGo = nil,
    RealmBtn = nil,
    RealmName = nil,
    RedPoint = nil,
    Icon = nil,
    GobjProgress = nil,
    TxtProgress = nil,
    SliderProgress = nil,
    VfxSkin = nil,
    BlinkSkin = nil,
    CurConditionID = 0,
    FrontLevelProgress = -1,
    ModelSkin = nil,
}
-- Register Events
function UIFlySwordShowPanel:OnRegisterEvents()
    -- Monitor the red dot status
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FUNCTION_UPDATE, self.OnFuncUpdated, self)
    -- Level changes
    self:RegisterEvent(LogicEventDefine.EID_EVENT_PLAYER_LEVEL_CHANGED, self.OnBasePropChanged, self)
    -- Change of combat power
    self:RegisterEvent(LogicEventDefine.EID_EVENT_FIGHT_POWER_CHANGED, self.OnFightChanged, self)
    -- Sword Spirit data refresh
    self:RegisterEvent(LogicEventDefine.EID_EVENT_UPDATE_FLYSWORDGRAVE, self.OnRefreshData, self)
end
function UIFlySwordShowPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.RootGo = UIUtils.FindGo(trans, "Root")
    self.RealmBtn = UIUtils.FindBtn(trans, "Root/Show")
    UIUtils.AddBtnEvent(self.RealmBtn, self.OnRealmBtnClick, self)
    self.RealmName = UIUtils.FindLabel(trans, "Root/Show/Name")
    self.RedPoint = UIUtils.FindGo(trans, "Root/Show/RedPoint")
    self.GobjProgress = UIUtils.FindGo(trans, "Root/Show/ProgressRoot")
    self.TxtProgress = UIUtils.FindLabel(trans, "Root/Show/ProgressRoot/TxtProgress")
    self.SliderProgress = UIUtils.FindSlider(trans, "Root/Show/ProgressRoot/SprProgress")
    self.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "Root/Show/UIVfxSkinCompoent"))
    self.BlinkSkin = UIUtils.RequireUIVfxSkinCompoent(UIUtils.FindTrans(trans, "Root/Show/BlinkSkin"))
    --self.Icon = UIUtils.RequireUIIconBase(UIUtils.FindTrans(trans, "Root/Show/Icon"))
    self.ModelSkin = UIUtils.RequireUIRoleSkinCompoent(UIUtils.FindTrans(trans, "Root/Show/UIRoleSkinCompoent"))
    self.ModelSkin:OnFirstShow(self.RootForm.CSForm, FSkinTypeCode.Monster, "idle")
end
-- After display
function UIFlySwordShowPanel:OnShowAfter()
    self.FrontLevelProgress = -1
    self:OnFuncUpdated(GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FlySwordGrave))
end
-- After closing
function UIFlySwordShowPanel:OnHideAfter()
    self.VfxSkin:OnDestory()
    self.BlinkSkin:OnDestory()
    self.ModelSkin:ResetSkin()
end
-- Open the realm interface
function UIFlySwordShowPanel:OnRealmBtnClick()
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.FlySwordGrave)
end
-- Realm red dot status update
function UIFlySwordShowPanel:OnFuncUpdated(func, sender)
    local _funcId = func.ID
    if _funcId == FunctionStartIdCode.FlySwordGrave then
        self:UpdateStateLevel()
    end
end
function UIFlySwordShowPanel:OnBasePropChanged(prop, sender)
    if self.CurConditionID == FunctionVariableIdCode.PlayerLevel then
        self:UpdateStateLevel()
    end
end
function UIFlySwordShowPanel:OnFightChanged(prop, sender)
    if self.CurConditionID == FunctionVariableIdCode.PlayerPower then
        self:UpdateStateLevel()
    end
end
function UIFlySwordShowPanel:OnRefreshData(prop, sender)
    self:UpdateStateLevel()
end
function UIFlySwordShowPanel:UpdateStateLevel()
    local _info = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.FlySwordGrave)
    self.RootGo:SetActive(_info.IsVisible)
    --self.RootGo:SetActive(false)
    if not _info.IsVisible then
        return
    end
    local _curId = GameCenter.FlySwordGraveSystem.CurSwordId
    local _cfg = DataConfig.DataFlySwordGrave[_curId]
    if _cfg ~= nil then
        -- --Start from here
        --self.Icon:UpdateIcon(_cfg.Icon)
        local _table = L_SwordParams[_curId]
        if _table == nil then
            local _smId = (_curId - 1) % 6 + 1
            _table = L_ModelParams[_smId]
        end
        self.ModelSkin:ResetSkin()
        self.ModelSkin:SetEquip(FSkinPartCode.Body, _cfg.FlySwordId)
        self.ModelSkin:SetPos(_table.Pos[1], _table.Pos[2], 0)
        self.ModelSkin:SetEulerAngles(_table.Rot[1], _table.Rot[2], _table.Rot[3])
        self.ModelSkin:SetLocalScale(_table.Scale)
        self.ModelSkin:SetDefaultAnim(_table.Anim, 0)
        self.ModelSkin:Play(_table.Anim, 0, 2, 1)

        UIUtils.SetTextByStringDefinesID(self.RealmName, _cfg._Name)
        self:OnRefreshTaskProgress(_cfg)
        if GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.FlySwordGrave, _cfg.Id) then
            self.RedPoint:SetActive(true)
            if not self.VfxSkin.IsPlaying then
                self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 131, LayerUtils.AresUI)
            end
        else
            self.RedPoint:SetActive(false)
            if self.VfxSkin.IsPlaying then
                self.VfxSkin:OnDestory()
            end
        end
    end
end
function UIFlySwordShowPanel:GetProcessValue(curValue, nextArr)
	local _forwNum = 0
	for i = GameCenter.FlySwordGraveSystem.CurSwordId - 1, 1, -1 do
		local _cfg = DataConfig.DataFlySwordGrave[i]
		if _cfg then
			local _ar = Utils.SplitNumber(_cfg.Condition, '_')
			if _ar[1] and _ar[2] and _ar[1] == nextArr[1] and curValue >= _ar[2] then
				_forwNum = _ar[2]
                break
			end
		end
	end
	return (curValue - _forwNum) / (nextArr[2] - _forwNum)
end
function UIFlySwordShowPanel:OnRefreshTaskProgress(cfg)
    local _needParams = Utils.SplitNumber(cfg.Condition, '_')
    if _needParams ~= nil and #_needParams >= 2 then
        local _type = _needParams[1]
        local _value = _needParams[2]
        local _progress = 1
        self.CurConditionID = _type
        if _type == FunctionVariableIdCode.PlayerLevel then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                _progress = self:GetProcessValue(_lp.Level, _needParams)
                if self.FrontLevelProgress >= 0 and self.FrontLevelProgress < _progress then
                    -- Play special effects
                    self.BlinkSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, 137, LayerUtils.AresUI)
                end
                self.FrontLevelProgress = _progress
            end
        elseif _type == FunctionVariableIdCode.PlayerPower then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil then
                _progress = _lp.FightPower / _value
            end
        end
        if _progress > 1 then
            _progress = 1
        end
        if _progress < 0 then
            _progress = 0
        end
        self.SliderProgress.value = _progress
        UIUtils.SetTextByEnum(self.TxtProgress, "Percent", math.floor(_progress * 100))
    end
end
return UIFlySwordShowPanel