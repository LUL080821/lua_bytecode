------------------------------------------------
-- Author: 
-- Date: 2019-05-23
-- File: UIPlayerLevelLabel.lua
-- Module: UIPlayerLevelLabel
-- Description: Player level tag component
------------------------------------------------

local UIPlayerLevelLabel = {
    Trans = nil,
    Go = nil,
    LevelLabel = nil,
    DfLevelLabel = nil,
    DfLevelIcon = nil,
    DfLevelGo = nil,
    LevelGo = nil,
}

local L_LevelTable = {}
-- Create a new object
function UIPlayerLevelLabel:OnFirstShow(trans)
    local _cacheLevel = L_LevelTable[trans]
    if _cacheLevel ~= nil then
        return _cacheLevel
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    L_LevelTable[trans] = _m
    LuaBehaviourManager:Add(trans, _m)
    return _m
end

function UIPlayerLevelLabel:OnDestroy()
    L_LevelTable[self.Trans] = nil
end

 -- Find various controls on the UI
function UIPlayerLevelLabel:FindAllComponents()
    self.LevelLabel = UIUtils.FindLabel(self.Trans, "Level")
    self.LevelGo = UIUtils.FindGo(self.Trans, "Level")
    self.DfLevelGo = UIUtils.FindGo(self.Trans, "DFLevel")
    self.DfLevelIcon = UIUtils.FindSpr(self.Trans, "DFLevel/Icon")
    self.DfLevelLabel = UIUtils.FindLabel(self.Trans, "DFLevel/Text")
end

-- Set text directly-not display marks.
function UIPlayerLevelLabel:SetLabelText(text)
    if not self.LevelGo.activeSelf then
        self.LevelGo:SetActive(true)
    end
    if self.DfLevelGo.activeSelf then
        self.DfLevelGo:SetActive(false)
    end
    UIUtils.SetTextByString(self.LevelLabel, text)
end

-- Set the level to the tag to display the peak mark
function UIPlayerLevelLabel:SetLevel(level, showLevelText)
    local _dfLevel = 0
    local _isDf = false
    _isDf, _dfLevel = CommonUtils.TryGetDFLevel(level)
    if _isDf then
        self.LevelGo:SetActive(false)
        self.DfLevelGo:SetActive(true)
        UIUtils.SetTextByNumber(self.DfLevelLabel, _dfLevel)
    else
        self.LevelGo:SetActive(true)
        self.DfLevelGo:SetActive(false)
        if showLevelText then
            UIUtils.SetTextByEnum(self.LevelLabel, "LevelValue", level)
        else
            UIUtils.SetTextByNumber(self.LevelLabel, level)
        end
    end
end

-- Set the level to the tag, but without any peak mark
function UIPlayerLevelLabel:SetLevelOutFlag(level)
    local _dfLevel = 0
    local _isDf = false
    _isDf, _dfLevel = CommonUtils.TryGetDFLevel(level)
    if not self.LevelGo.activeSelf then
        self.LevelGo:SetActive(true)
    end
    if self.DfLevelGo.activeSelf then
        self.DfLevelGo:SetActive(false)
    end
    UIUtils.SetTextByNumber(self.LevelLabel, _dfLevel)
end

function UIPlayerLevelLabel:SetColor(color)
    self.DfLevelLabel.color = color
    self.LevelLabel.color = color
end

function UIPlayerLevelLabel:SetIconIsGray(isGray)
    self.DfLevelIcon.IsGray = isGray
end
return UIPlayerLevelLabel
