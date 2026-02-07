------------------------------------------------
-- author:
-- Date: 2019-05-23
-- File: GuildOfficialPanel.lua
-- Module: GuildOfficialPanel
-- Description: Denominational Member Rights Management Interface
------------------------------------------------
local L_UICheckBox = require ("UI.Components.UICheckBox")
local GuildOfficalPanel = {
    Trans = nil,
    Go = nil,
    CSForm = nil,
    -- List of radio box
    CheckBoxDic = Dictionary:New(),
    -- Job Name List
    OfficalNameDic = Dictionary:New(),
    -- Current selected position
    CurSelectOffical = -1,
    -- Player's own position
    MyOffical = -1,

    -- Animation module
    AnimModule = nil,
}

-- Create a new object
function GuildOfficalPanel:OnFirstShow(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = parent
    _m.Go = trans.gameObject
    -- Create an animation module
    _m.AnimModule = UIAnimationModule(trans)
    -- Add an animation
    _m.AnimModule:AddNormalAnimation(0.3)
    _m:FindAllComponents()
    _m.Go:SetActive(false)
    _m.IsVisible = false
    return _m
end

-- Find controls
function GuildOfficalPanel:FindAllComponents()
    DataConfig.DataGuildOfficial:Foreach(function(k, v)
        local _check = L_UICheckBox:OnFirstShow(UIUtils.FindTrans(self.Trans, tostring(k)))
        _check.CallBack2 = Utils.Handler(self.OnClickCheckBox, self)
        self.CheckBoxDic:Add(k, _check)
        local _nameLabel = UIUtils.FindLabel(_check.Trans, "Name")
        self.OfficalNameDic:Add(k, _nameLabel)
    end)
    self.Texture = UIUtils.FindTex(self.Trans, "Texture")
    local _btn = UIUtils.FindBtn(self.Trans, "CloseBtn")
    UIUtils.AddBtnEvent(_btn, self.Close, self)
    _btn = UIUtils.FindBtn(self.Trans, "Back")
    UIUtils.AddBtnEvent(_btn, self.Close, self)
    _btn = UIUtils.FindBtn(self.Trans, "OfficalBtn")
    UIUtils.AddBtnEvent(_btn, self.OnLeaderClick, self)
end

function GuildOfficalPanel:Open(roleID)
    self.AnimModule:PlayEnableAnimation()
    self.PlayerID = roleID
    self:OnUpdateItem()
    self.CurSelectOffical = -1
    self.MyOffical = GameCenter.GuildSystem.Rank
    self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,"tex_n_d_3"))
    self.IsVisible = true
end

function GuildOfficalPanel:Close()
    self.AnimModule:PlayDisableAnimation()
    self.IsVisible = false
end
function GuildOfficalPanel:OnClickCheckBox(check)
    local _clickOffical = tonumber(check.Trans.name)
    if not check.IsChecked then
        if self.CurSelectOffical == _clickOffical then
            self.CurSelectOffical = -1
        end
        return
    end
    if GameCenter.GuildSystem.IsProxy then
        Utils.ShowPromptByEnum("C_UI_TIPS_GUILDOFFICAL_ERR")
        check:SetChecked(false, false)
        return
    end
    if _clickOffical > self.MyOffical and self.MyOffical ~= 4 and not GameCenter.GuildSystem.IsProxy then
        Utils.ShowPromptByEnum("C_GUILD_RANKNUMLIMITTIPS")
        check:SetChecked(false, false)
        return
    end
    if _clickOffical == self.MyOffical and self.MyOffical ~= 4 and not GameCenter.GuildSystem.IsProxy then
        Utils.ShowPromptByEnum("C_GUILD_RANKNUMLIMITTIPS")
        check:SetChecked(false, false)
        return
    end
    if self:OnNumIsMax(_clickOffical) then
        Utils.ShowPromptByEnum("KPAPPOINTEPOWERFULL")
        check:SetChecked(false, false)
        return
    end
    if self.CurSelectOffical > 0 then
        self.CheckBoxDic[self.CurSelectOffical]:SetChecked(false, false)
    end
    self.CurSelectOffical = _clickOffical
end
-- Job button click
function GuildOfficalPanel:OnLeaderClick()
    if self.CurSelectOffical > 0 then
        GameCenter.GuildSystem:ReqSetRank(self.PlayerID, self.CurSelectOffical)
        self:Close()
    else
        Utils.ShowPromptByEnum("C_GUILD_NOCHECKTIPS")
    end
end

function GuildOfficalPanel:OnUpdateItem()
    local _cfg = nil
    self.OfficalNumDic = GameCenter.GuildSystem.OfficalNumDic
    self.CheckBoxDic:ForeachCanBreak(function(k, v)
        v:SetChecked(false, false)
        _cfg = DataConfig.DataGuildOfficial[k]
        if _cfg then
            if k ~= 1 then
                local _num = 0
                if self.OfficalNumDic:ContainsKey(k) then
                    _num = self.OfficalNumDic[k]
                end
                UIUtils.SetTextFormat(self.OfficalNameDic[k], "{0}({1}/{2}):", _cfg.Name, _num, _cfg.Num)
            else
                UIUtils.SetTextFormat(self.OfficalNameDic[k], "{0}:", _cfg.Name)
            end
        end
    end)
end

function GuildOfficalPanel:OnNumIsMax(k)
    if k == 4 then
        return false
    end
    local _cfg = DataConfig.DataGuildOfficial[k]
    if _cfg and self.OfficalNumDic then
        if k ~= 1 then
            local _num = 0
            if self.OfficalNumDic:ContainsKey(k) then
                _num = self.OfficalNumDic[k]
                return _num >= _cfg.Num
            end
        else
            return false
        end
    end
    return false
end
return GuildOfficalPanel
