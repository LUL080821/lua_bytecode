------------------------------------------------
-- Author: 
-- Date: 2019-04-18
-- File: CommonPanelRedData.lua
-- Module: CommonPanelRedData
-- Description: The red dot data inside the general panel, please note that you should use this script button below, for example, there should be a red dot with the name of RedPoint
------------------------------------------------

local NGUITools = CS.NGUITools

local CommonPanelRedData = {
    FunctionStartId = 0, --FunctionStartIdCode
    NotRedIsGray = false, -- Set gray button when there are no red dots
    RedGo = nil, -- Red dot gameObejct
    DataId = 0, -- Pagination ID
    Trans = nil,-- node
}
CommonPanelRedData.__index = CommonPanelRedData

function CommonPanelRedData:New(functionStartId,trs,dataid,isgray)
    local _M = Utils.DeepCopy(self)
    _M.FunctionStartId = functionStartId
    _M.Trans = trs
    _M.NotRedIsGray = isgray
    _M.DataId = dataid
    _M.RedGo = trs:Find("RedPoint").gameObject
    return _M
end

function CommonPanelRedData:RefreshInfo()
    local _red = GameCenter.MainFunctionSystem:GetAlertFlag(self.FunctionStartId)
    self.RedGo:SetActive(_red)
    if self.NotRedIsGray then
            NGUITools.SetButtonGrayAndNotOnClick(self.Trans,not _red)
    else
        NGUITools.SetButtonGrayAndNotOnClick(self.Trans,false)
    end
end

return CommonPanelRedData