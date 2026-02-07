-- Author: 
-- Date: 2019-04-16
-- File: NatureSkillSet.lua
-- Module: NatureSkillSet
-- Description: Creation Panel Skill Data Settings
------------------------------------------------
-- Quote
local UIEventListener = CS.UIEventListener
local NGUITools = CS.NGUITools

local NatureSkillSet = {
    NatureType = 0, -- type
    Tras = nil, -- Root node
    Go = nil, --obj
    Clone = nil, -- Clones
    Grid = nil, -- Gird Components
    IconList = nil ,-- Skill icon component
}

NatureSkillSet.__index = NatureSkillSet

function NatureSkillSet:New(trans,naturetype)
    local _M = Utils.DeepCopy(self)
    _M.Tras = trans
    _M.Go = trans.gameObject
    _M.Clone = trans:Find("default").gameObject
    _M.Grid = UIUtils.FindGrid(trans)
    _M.IconList = List:New()
    _M.NatureType = naturetype
    return _M
end

function NatureSkillSet:RefreshSkill(skilllist)
    local _listobj = NGUITools.AddChilds(self.Go,self.Clone,#skilllist)
    for i = 1,#skilllist do
        local _go = _listobj[i - 1]
        local _info = skilllist[i]
        if not self.IconList[i] then
            local _icon = {
                Icon = nil,-- Icon components
                NotActive = nil,-- Whether to activate the component
            }
            _icon.Icon = UIUtils.FindSpr(_go.transform, "Icon")
            _icon.NotActive = _go.transform:Find("NotActive").gameObject
            self.IconList:Add(_icon)
        end
        if _info.SkillInfo then
            self.IconList[i].Icon.spriteName = UIUtils.CSFormat("skill_{0}", _info.SkillInfo.Icon)
        end
        self.IconList[i].Icon.IsGray = not _info.IsActive
        self.IconList[i].NotActive:SetActive(_info.IsActive == false)
        UIEventListener.Get(_go).parameter = _info
        UIEventListener.Get(_go).onClick = Utils.Handler( self.OnClickSkill,self)
    end
    self.Grid:Reposition()
end

function NatureSkillSet:OnClickSkill(go)
    local _info = UIEventListener.Get(go).parameter
    local _tipsinfo = {info = _info,NeedlvStr = ""}
    if _info.IsActive then
        if self.NatureType == NatureEnum.Mount then
            _tipsinfo.NeedlvStr = "MOUNTEXFORM_AOTULEVEL"
        else
            _tipsinfo.NeedlvStr = "NATURESKILLTIPSFORM_AOTULEVEL"
        end
    else
        if self.NatureType == NatureEnum.Mount then
            _tipsinfo.NeedlvStr = "MOUNTEXFORM_AOTUSTAGE"
        else
            _tipsinfo.NeedlvStr = "MOUNTEXFORM_ZIDONGJIHUO"
        end
    end
    GameCenter.PushFixEvent(UIEventDefine.UINatureSkillTipsForm_OPEN, _tipsinfo)
end

return NatureSkillSet