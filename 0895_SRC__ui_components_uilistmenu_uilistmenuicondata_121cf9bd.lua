------------------------------------------------
-- Author: 
-- Date: 2019-04-15
-- File: UIlistMenuIconData.lua
-- Module: UIlistMenuIconData
-- Description: Data class for a single child in the list menu
------------------------------------------------
local UIlistMenuIconData ={
    ID = 0,
    Text = nil,
    FuncID = FunctionStartIdCode.MainFuncRoot,
    FuncInfo = nil,
    ShowRedPoint = false,
    NormalSpr = nil,
    SelectSpr = nil,
    SelectSpr2 = nil,
}

function UIlistMenuIconData:New()
    local _m = Utils.DeepCopy(self)
    return _m
end
return UIlistMenuIconData