------------------------------------------------
-- Author: 
-- Date: 2019-04-15
-- File: UIListMenuIcon.lua
-- Module: UIListMenuIcon
-- Description: Single child item in the list menu
------------------------------------------------
local UIListMenuIcon = {
    RootGo = nil,
    NormalName = nil,
    SelectName = nil,
    RedPoint = nil,
    SelectGo = nil,
    NormalSpr = nil,
    SelectSpr = nil,
    SelectSpr2 = nil,
    Btn = nil,
    Data = nil,
    Parent = nil,
    Select = false,
}

-- Settings are selected
function UIListMenuIcon:IsSelect(value, id)
    if self.Select ~= value or value == true then
        self.Select = value
        self.Parent:OnSelectChanged(self)
        self.NormalName.gameObject:SetActive(not self.Select)
        self.SelectName.gameObject:SetActive(self.Select)
        self.SelectGo:SetActive(self.Select)
        if self.SelectSpr2 ~= nil then
            self.SelectSpr2.gameObject:SetActive(self.Select)
        end
    end
    if self.VfxSkin ~= nil then
        self.VfxSkin:OnDestory()
        if value and id ~= nil then
            self.VfxSkin:OnCreateAndPlay(ModelTypeCode.UIVFX, id, LayerUtils.GetAresUILayer());
        end
    end
end

-- Create a new object
function UIListMenuIcon:New(res, parent)
    local _M = Utils.DeepCopy(self)
    _M.Parent = parent
    _M.RootGo = res

    local _trans = _M.RootGo.transform
    self.Trans = _trans
    local toggle = UIUtils.FindToggle(_trans)
    if toggle ~= nil then
        GameObject.Destroy(toggle);
    end
    _M.NormalName = UIUtils.FindLabel(_trans, "NormalName")
    _M.SelectName = UIUtils.FindLabel(_trans, "SelectName")
    _M.RedPoint = UIUtils.FindGo(_trans, "RedPoint")
    _M.SelectGo = UIUtils.FindGo(_trans, "Select")
    _M.NormalSpr = UIUtils.FindSpr(_trans)
    _M.SelectSpr = UIUtils.FindSpr(_trans, "Select")
    local spr2Trans = UIUtils.FindTrans(_trans, "Select2")
    if(spr2Trans ~= nil) then
        _M.SelectSpr2 = UIUtils.FindSpr(_trans, "Select2")
    end

    _M.Btn = UIUtils.FindBtn(_M.RootGo.transform)
    UIUtils.AddBtnEvent(_M.Btn, _M.OnBtnClick, _M)

    _M.NormalName.gameObject:SetActive(not _M.Select)
    _M.SelectName.gameObject:SetActive(_M.Select)
    _M.SelectGo:SetActive(_M.Select)
    if(_M.SelectSpr2 ~= nil) then
        _M.SelectSpr2.gameObject:SetActive(_M.Select)
    end
    local _vfxTrans = UIUtils.FindTrans(_trans, "UIVfxSkinCompoent")
    if _vfxTrans then
        _M.VfxSkin = UIUtils.RequireUIVfxSkinCompoent(_vfxTrans)
    end
    return  _M
end

-- Clone an object
function UIListMenuIcon:Clone()
    local _trans = UnityUtils.Clone(self.RootGo).transform
    return UIListMenuIcon:New(_trans, self.Parent);
end

function UIListMenuIcon:OnBtnClick()
    -- Return directly if it has been selected
    if self.Select or not self.Data then
        return
    end

    if self.Parent.IconOnClick ~= nil and not self.Parent.IconOnClick(self.Data) then
        return
    end

    if self.Data.FuncInfo ~= nil then
        if not self.Data.FuncInfo.IsVisible then
            GameCenter.MainFunctionSystem:ShowNotOpenTips(self.Data.FuncInfo)
            return
        end
    end
    self.Parent:SetSelectById(self.Data.ID)
end

function UIListMenuIcon:SetInfo(data)
    self.Data = data
    -- Whether to support parsing languages
    self.SelectName.IsStripLanSymbol = self.Parent.IsStripLanSymbol
    self.NormalName.IsStripLanSymbol = self.Parent.IsStripLanSymbol
    UIUtils.SetTextByString(self.SelectName, data.Text)
    UIUtils.SetTextByString(self.NormalName, data.Text)
    if self.Data.FuncInfo == nil then
        self.RedPoint:SetActive(data.ShowRedPoint)
    else
        self.RedPoint:SetActive(self.Data.FuncInfo.IsShowRedPoint)
    end
    if data.NormalSpr ~= nil then
        self.NormalSpr.spriteName = data.NormalSpr
    end
    if data.SelectSpr ~= nil then
        self.SelectSpr.spriteName = data.SelectSpr
    end
    if data.SelectSpr2 ~= nil and self.SelectSpr2 ~= nil then
        self.SelectSpr2.spriteName = data.SelectSpr2
    end
end

return UIListMenuIcon