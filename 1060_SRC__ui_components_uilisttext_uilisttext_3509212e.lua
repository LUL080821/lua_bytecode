------------------------------------------------
-- author:
-- Date: 2020-08-22
-- File: UIListText.lua
-- Module: UIListText
-- Description: data = {Text: Description, Add: Add value}
------------------------------------------------

local UIListText = {
    Trans = nil,                        -- Transform
    Temp = nil,
    Scroll = nil,
    Grid = nil,
    ListText = List:New(),
}

function UIListText:New(trans)
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m:FindAllComponents()
    return _m
end

 -- Find Components
function UIListText:FindAllComponents()
    local _myTrans = self.Trans
    self.Temp = UIUtils.FindGo(_myTrans, "Item")
    self.Scroll = UIUtils.FindScrollView(_myTrans, "Scroll")
    self.Grid = UIUtils.FindGrid(_myTrans, "Scroll/Grid")

    self.Temp:SetActive(false)
end

function UIListText:Refreash(dataList)
    if dataList == nil then
        return
    end
    local gridTrans = self.Grid.transform
    local length = #dataList
    for i = 1, length do
        local item = nil
        if i - 1 < gridTrans.childCount then
            item = self.ListText[i]
        else
            local go = UnityUtils.Clone(self.Temp, gridTrans)
            local trans = go.transform
            local text = UIUtils.FindLabel(trans, "Text")
            local addValue = UIUtils.FindLabel(trans, "Text/Add/Label")
            local add = UIUtils.FindGo(trans, "Text/Add")
            item = {Go = go, Text = text, Add = add, AddValue = addValue}
            self.ListText:Add(item)
        end
        if item ~= nil and item.Go ~= nil then
            -- Setting up data
            local data = dataList[i]
            UIUtils.SetTextByString(item.Text, data.Text)
            if data.Add == nil or data.Add == 0 then
                item.Add:SetActive(false)
            else
                UIUtils.SetTextByString(item.AddValue, data.Add)
                item.Add:SetActive(true)
            end
            item.Go:SetActive(true)
        end
    end
    if length < #self.ListText then
        for i = length + 1, #self.ListText do
            local item = self.ListText[i]
            if item ~= nil and item.Go ~= nil then
                item.Go:SetActive(false)
            end
        end
    end
    self.Grid.repositionNow = true
    self.Scroll.repositionWaitFrameCount = 3
end

--CUSTOM - clone for new data
function UIListText:newRefresh(dataList)
    if dataList == nil then
        return
    end
    local gridTrans = self.Grid.transform
    local length = #dataList
    for i = 1, length do
        local item = nil
        if i - 1 < gridTrans.childCount then
            item = self.ListText[i]
        else
            local go = UnityUtils.Clone(self.Temp, gridTrans)
            local trans = go.transform
            local text = UIUtils.FindLabel(trans, "Text")
            local value = UIUtils.FindLabel(trans, "Text/Value")
            local addValue = UIUtils.FindLabel(trans, "Text/Add/Label")
            local add = UIUtils.FindGo(trans, "Text/Add")
            item = {Go = go, Text = text, Value = value, Add = add, AddValue = addValue}
            self.ListText:Add(item)
        end
        if item ~= nil and item.Go ~= nil then
            -- Setting up data
            local data = dataList[i]
            UIUtils.SetTextByString(item.Text, data.Text)
            UIUtils.SetTextByString(item.Value, data.Value)
            if data.Add == nil or data.Add == 0 then
                item.Add:SetActive(false)
            else
                UIUtils.SetTextByString(item.AddValue, data.Add)
                item.Add:SetActive(true)
            end
            item.Go:SetActive(true)
        end
    end
    if length < #self.ListText then
        for i = length + 1, #self.ListText do
            local item = self.ListText[i]
            if item ~= nil and item.Go ~= nil then
                item.Go:SetActive(false)
            end
        end
    end
    self.Grid.repositionNow = true
    self.Scroll.repositionWaitFrameCount = 3
end
--CUSTOM - clone for new data

return UIListText