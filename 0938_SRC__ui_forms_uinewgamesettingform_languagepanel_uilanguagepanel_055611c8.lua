------------------------------------------------
--author:
--Date: 2020-10-15
--File: UILanguagePanel.lua
--Module: UILanguagePanel
--Description: Language Switch Select Language Panel
------------------------------------------------
local FLanguage = CS.UnityEngine.Gonbest.MagicCube.FLanguage;

--Define settings panel
local UILanguagePanel = {
    IsVisibled = false,
    OwnerForm = nil,
    Trans = nil,
    CloseBtn = nil,
    OkBtn = nil,
    --The language of choice
    SelectLan = nil,
    LanGrid = nil,
    LanItemGo = nil,
    LanItemList = nil,
};

--Language-selected control cache class
local L_LanSelectItem = nil

function UILanguagePanel:Initialize(owner,trans)
    self.OwnerForm = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();
    return self;
end


--Find all components
function UILanguagePanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.CloseBtn = UIUtils.FindBtn(_myTrans,"CloseBtn");
    self.OkBtn = UIUtils.FindBtn(_myTrans,"OkBtn");

    self.LanGrid = UIUtils.FindGrid(_myTrans, "ScrollView/Grid")
    self.LanItemGo = self.LanGrid.transform:GetChild(0).gameObject
    self.LanItemList = List:New()
    for i = 0, self.LanGrid.transform.childCount - 1 do
        local _item = L_LanSelectItem:New(self.LanGrid.transform:GetChild(i), self)
        self.LanItemList:Add(_item)
    end
end

--Binding UI components callback function
function UILanguagePanel:RegUICallback()
   UIUtils.AddBtnEvent(self.CloseBtn,self.OnClickCloseBtn,self);
   UIUtils.AddBtnEvent(self.OkBtn,self.OnClickOkBtn,self);
end

function UILanguagePanel:OnClickCloseBtn()
    self:Hide()
end

function UILanguagePanel:Show()
    self.IsVisibled = true;    
    self.Trans.gameObject:SetActive(true);
    self:Refresh();
end

function UILanguagePanel:Hide()
    self.IsVisibled = false;
    self.Trans.gameObject:SetActive(false);
end

function UILanguagePanel:Refresh()
    local _itemCount = #self.LanItemList
    local _lans = FLanguage.EnabledSelectLans()
    local _iter = _lans:GetEnumerator()
    local _usedCount = _lans.Count
    local _index = 1
    while _iter:MoveNext() do
        --CH
        local _lan = _iter.Current.Key
        --Simplified Chinese
        local _lanDes = _iter.Current.Value
        local _lanSelectItem = nil
        if _index <= _itemCount then
            _lanSelectItem = self.LanItemList[_index]
        else
            _lanSelectItem = L_LanSelectItem:New(UnityUtils.Clone(self.LanItemGo).transform, self)
            self.LanItemList:Add(_lanSelectItem)
        end
        _lanSelectItem:SetText(_lan, _lanDes)
        _lanSelectItem.RootGo:SetActive(true)
        _index = _index + 1
    end
    for i = _usedCount + 1, _itemCount do
        self.LanItemList[i].RootGo:SetActive(false)
    end
    self.LanGrid.repositionNow = true
end

--OK button
function UILanguagePanel:OnClickOkBtn()
    if self.SelectLan ~= nil then
        Utils.ShowMsgBox(function(code)
            if code == MsgBoxResultCode.Button2 then
                self.OwnerForm.ClearCacheScript:DoStart()
                --Set language AppPersistKeyDefine.CN_USE_LANGUAGE_KEY
                PlayerPrefs.SetString("uselanguage", self.SelectLan)
                PlayerPrefs.Save()
                self:Hide()
            end
        end, "C_RESTART_GAME_TIPS")
    else
        Utils.ShowPromptByEnum("C_CHANGE_LAN_NOT_SELECTED_TIPS")
    end
end

L_LanSelectItem = {
    RootGo = nil,
    Parent = nil,
    LanLab = nil,
    SelectGo = nil,
    Toggle = nil,
    SelectedBtn = nil,
    Lan = nil,
}

function L_LanSelectItem:New(trans, parent)
    local _m = Utils.DeepCopy(self)
    _m.RootGo = trans.gameObject
    _m.Parent = parent
    _m.LanLab = UIUtils.FindLabel(trans, "Label")
    _m.SelectGo = UIUtils.FindGo(trans, "Select")
    _m.SelectGo:SetActive(false)
    _m.Toggle = UIUtils.FindToggle(trans)
    _m.SelectedBtn = UIUtils.FindBtn(trans)
    UIUtils.AddBtnEvent(_m.SelectedBtn, _m.OnSelectedBtnClick, _m);
    return _m
end

function L_LanSelectItem:SetText(lan, lanText)
    self.Lan = lan
    UIUtils.SetTextByString(self.LanLab, lanText)
end

function L_LanSelectItem:SetShow(show)
    --Set the selected status
    self.Toggle:Set(show)
    self.SelectGo:SetActive(show)
    if show then
        self.Parent.SelectLan = self.Lan
    end
end

function L_LanSelectItem:OnSelectedBtnClick()
    self:SetShow(true)
end

return UILanguagePanel;
