------------------------------------------------
-- Author: 
-- Date: 2019-05-24
-- File: UIAddReduce.lua
-- Module: UIAddReduce
-- Description: Digital input common control with addition and subtraction buttons
------------------------------------------------

local UIAddReduce = {
    Trans = nil,
    Go = nil,
    ValueLabel = nil,
    InputBtn = nil,
    -- add
    AddBtn = nil,
    AddBtnGo = nil,
    -- reduce
    SubBtn = nil,
    SubBtnGo = nil,
    -- Timer, used to respond when you press and add or subtract for a long time
    DeltaTime = 0.0,
    -- Whether to hold on for a long time
    IsPress = false,
    IsAddBtn = false,
    -- Click the callback in the input box
    OnClickInputFunc = nil,
    -- The callback of the button is long pressed, the first parameter true is the plus button, and false is the subtract button
    OnUpdateValueFunc = nil,
}
-- Create a new object
function UIAddReduce:OnFirstShow(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    LuaBehaviourManager:Add(_m.Trans, _m)
    return _m
end

-- Find controls
function UIAddReduce:FindAllComponents()
    self.ValueLabel = UIUtils.FindLabel(self.Trans, "LevelLabel")
    self.InputBtn = UIUtils.FindBtn(self.Trans, "LevelLabel")
    self.AddBtn = UIUtils.FindBtn(self.Trans, "AddBtn")
    self.AddBtnGo = UIUtils.FindGo(self.Trans, "AddBtn")
    self.SubBtn = UIUtils.FindBtn(self.Trans, "JianBtn")
    self.SubBtnGo = UIUtils.FindGo(self.Trans, "JianBtn")

    UIUtils.AddBtnEvent(self.InputBtn, self.OnClickInputBtn, self)
    UIEventListener.Get(self.AddBtnGo).onPress = Utils.Handler(self.OnPressBtn, self)
    UIEventListener.Get(self.SubBtn.gameObject).onPress = Utils.Handler(self.OnPressBtn, self)
end

-- Bind callback
function UIAddReduce:SetCallBack(clickFunc, inputFunc)
    self.OnUpdateValueFunc = clickFunc
    self.OnClickInputFunc = inputFunc
end

function UIAddReduce:OnClearCallBack()
    self.OnUpdateValueFunc = nil
    self.OnClickInputFunc = nil
end

function UIAddReduce:Update(dt)
    if self.IsPress then
        self.DeltaTime = self.DeltaTime + dt
        if self.DeltaTime >= 0.15 then
            self.DeltaTime = 0.0
            if self.OnUpdateValueFunc then
                self.OnUpdateValueFunc(self.IsAddBtn)
            end
        end
    end
end

-- Set the text display of the input box
function UIAddReduce:SetValueLabel(text)
    UIUtils.SetTextByString(self.ValueLabel, text)
end

function UIAddReduce:OnPressBtn(go, state)
    self.DeltaTime = 0.0
    self.IsPress = state
    self.IsAddBtn = go == self.AddBtnGo
    if (self.IsPress == false) then
        if self.OnUpdateValueFunc then
            self.OnUpdateValueFunc(self.IsAddBtn)
        end
    end
end
function UIAddReduce:OnClickInputBtn(go)
    if self.OnClickInputFunc ~= nil then
        self.OnClickInputFunc()
    end
end

-- Set whether the button is displayed
function UIAddReduce:OnSetBtnShow(isShow)
    self.AddBtnGo:SetActive(isShow)
    self.SubBtnGo:SetActive(isShow)
end
return UIAddReduce