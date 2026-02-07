------------------------------------------------
-- author:
-- Date: 2019-05-14
-- File: UIMemberRankItem.lua
-- Module: UIMemberRankItem
-- Description: Sectarian Personal Ranking Subcontrol
------------------------------------------------
local UIMemberListItem = require ("UI.Forms.UIGuildListForm.UIMemberListItem")

local UIMemberRankItem = {
    Trans = nil,
    Go = nil,
    CSForm = nil,
    Texture = nil,
    TitleLabel = nil,
    MemberList = List:New()
}

-- Create a new object
function UIMemberRankItem:OnFirstShow(trans, CSForm)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.CSForm = CSForm
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
 end

 -- Find various controls on the UI
 function UIMemberRankItem:FindAllComponents()
    self.Texture = UIUtils.FindTex(self.Trans, "Title/Texture")
    self.TitleLabel = UIUtils.FindLabel(self.Trans, "Title/TipsLabel")
    for i = 1, 6 do
        local _trans = UIUtils.FindTrans(self.Trans, string.format( "List%d", i))
        if _trans ~= nil then
            local _memberItem = nil
            _memberItem = UIMemberListItem:OnFirstShow(_trans)
            _memberItem.CallBack = Utils.Handler(self.ListClick, self)
            self.MemberList:Add(_memberItem)
        end
    end
 end

 function UIMemberRankItem:OnUpdateItem(infoList, config)
    if config ~= nil then
        UIUtils.SetTextByEnum(self.TitleLabel, "C_GUILD_RANK_TITLEPOWER", config.TitleFighting)
        self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, string.format("tex_chenghao_%d", DataConfig.DataTitle[config.Title].Textrue)))
    else
        UIUtils.ClearText(self.TitleLabel)
        self.CSForm:LoadTexture(self.Texture, AssetUtils.GetImageAssetPath(ImageTypeCode.UI, ""))
    end
    for i = 1, #self.MemberList do
        if infoList[i] ~= nil then
            self.MemberList[i].Go:SetActive(true)
            self.MemberList[i]:OnUpdateItem(infoList[i], true, config ~= nil)
            self.MemberList[i]:OnSetSelect(false)
        else
            self.MemberList[i].Go:SetActive(false)
        end
    end
 end

 function UIMemberRankItem:ListClick(item)
    -- if self.SelectItem then
    --     self.SelectItem:OnSetSelect(false)
    -- end
    -- self.SelectItem = item
    if self.CallBack then
        self.CallBack(item)
    end
 end
return UIMemberRankItem
