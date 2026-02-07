------------------------------------------------
-- Author: 
-- Date: 2019-08-07
-- File: UISelectPlayerHead.lua
-- Module: UISelectPlayerHead
-- Description: Select character avatar information
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils
local LoginSceneState = require("Logic.Login.LoginSceneState")

local UISelectPlayerHead = {
    Parent = nil, -- Parent class
    RootGo = nil, -- node
    Trs = nil, -- node
    AddGo = nil, -- Add a sign
    PlayerGo = nil, -- Player node
    ContentTran = nil, -- Content Trans
    Btn = nil, -- Button
    HeadSpr = nil, -- Avatar picture
    NameLabel = nil, -- name
    DeleteLabel = nil, -- delete
    LevelLabel = nil, -- grade
    GroupSpr = nil,
    PlayerInfo = nil, -- Player information
    -- HeadFrameSpr = nil, --ava box
    DeleteTime = 0 , -- Delete time

    LineGo = nil, -- Decorative lines
}
UISelectPlayerHead.__index = UISelectPlayerHead

function UISelectPlayerHead:New(go,prent)
    local _M = Utils.DeepCopy(self)
    _M.RootGo =  go
    _M.Trs = go.transform
    _M.Parent = prent
    _M:Init()
    return _M
end

function UISelectPlayerHead:Init()
    self.ContentTran = UIUtils.FindTrans(self.Trs,"Content")
    self.LineGo =UIUtils.FindGo(self.Trs,"Content/Decorate/Line") 
    self.AddGo = UIUtils.FindGo(self.Trs,"Content/Add")
    self.PlayerGo = UIUtils.FindGo(self.Trs,"Content/Head")
    self.Btn = UIUtils.FindBtn(self.Trs)
    UIUtils.AddBtnEvent(self.Btn, self.OnClick, self)
    self.HeadSpr = UIUtils.FindSpr(self.Trs,"Content/Head/Icon")
    --self.HeadFrameSpr = UIUtils.FindSpr(self.Trs,"Head/Back_1")
    self.NameLabel = UIUtils.FindLabel(self.Trs,"Content/Head/Name")
    self.DeleteLabel =  UIUtils.FindLabel(self.Trs,"Content/Head/Time")
    self.LevelLabel = PlayerLevel:OnFirstShow(UIUtils.FindTrans(self.Trs, "Content/Head/Level"))
end

-- Settings selection
function UISelectPlayerHead:SetSelected(isSelected)
    if isSelected then
        UnityUtils.SetLocalPosition(self.ContentTran, 45, 0, 0)
        UnityUtils.SetLocalScale(self.ContentTran, 1.2, 1.2, 1.2)
        self.LineGo:SetActive(false)
    else
        UnityUtils.SetLocalPosition(self.ContentTran, 0, 0, 0)
        UnityUtils.SetLocalScale(self.ContentTran, 1, 1, 1)
        self.LineGo:SetActive(true)
    end
end

function UISelectPlayerHead:SetInfo(player)
    self.PlayerInfo = player
    if self.PlayerInfo == nil then
        self.AddGo:SetActive(true)
        self.PlayerGo:SetActive(false)
    else
        self.AddGo:SetActive(false)
        self.PlayerGo:SetActive(true)

        self.HeadSpr.spriteName = string.format("n_icon_chuangjue_%d", self.PlayerInfo.Career)
        --self.HeadFrameSpr.spriteName = self.PlayerInfo.HeadFrameName
        UIUtils.SetTextByString(self.NameLabel, self.PlayerInfo.Name)
        self.LevelLabel:SetLevel(self.PlayerInfo.Level, true)

        local _delTime = self.PlayerInfo.DeleteTime + (48 * 60 * 60);
        self:SetDeleteTime(_delTime - TimeUtils.GetNow())
    end
end

function UISelectPlayerHead:SetDeleteTime( time)
    self.DeleteTime = time    
    if time > 0 then
        self.DeleteLabel.gameObject:SetActive(true)   
        self:RefreshDeleteTimeLabel(); 
    else
        self.DeleteLabel.gameObject:SetActive(false)   
    end
end

function UISelectPlayerHead:Update(dt)
    if self.PlayerGo.activeSelf and self.DeleteLabel.gameObject.activeSelf then
        self.DeleteTime = self.DeleteTime - dt;
        if self.DeleteTime >= 0 then            
            if Time.GetFrameCount() % 10 == 0 then
                self:RefreshDeleteTimeLabel();
            end
        else
            self:SetInfo(nil)
        end
    end
end

function UISelectPlayerHead:RefreshDeleteTimeLabel()
    UIUtils.SetTextHHMMSS(self.DeleteLabel, math.floor(self.DeleteTime))
end

function UISelectPlayerHead:OnClick()
    if self.PlayerInfo == nil then
        self.Parent.Parent:ChangePanel(LoginSceneState.CreatePlayer)
    else
        self.Parent:SetSelectHead(self, false)
    end
end

return UISelectPlayerHead