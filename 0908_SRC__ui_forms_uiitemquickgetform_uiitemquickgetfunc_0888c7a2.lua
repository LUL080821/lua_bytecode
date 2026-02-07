------------------------------------------------
-- author:
-- Date: 2019-05-30
-- File: UIItemQuickGetFunc.lua
-- Module: UIItemQuickGetFunc
-- Description: Feature entry for quick item acquisition
------------------------------------------------

local UIItemQuickGetFunc = {
    -- Parent UI
    Parent = nil,
    -- Root node
    RootGo = nil,
    RootTrans = nil,
    -- Button
    Btn = nil,
    -- Function name
    FuncName = nil,
    -- Not enabled sign
    NotOpenGo = nil,
    -- Completed mark
    FinishGo = nil,
    -- Sold out mark
    SellOutGo = nil,
    -- Not available tags
    BuKeYong = nil,

    -- Functional id
    FuncId = 0,
    -- Functional parameters
    FuncParam = nil,
    -- Open the function ID of the interface
    OpenFuncID = nil,
    -- Functional parameters for opening the interface
    OpenFuncParam = nil,
    -- Whether to enable
    IsVisible = false,

    -- Sort values
    SortValue = 0,
}

function UIItemQuickGetFunc:New(go, parent)
    local _result = Utils.DeepCopy(UIItemQuickGetFunc)
    _result.Parent = parent
    _result.RootGo = go
    _result.RootTrans = go.transform
    _result.Btn = UIUtils.FindBtn(go.transform, "Back")
    _result.FuncName = UIUtils.FindLabel(go.transform, "Back/Desc")
    _result.NotOpenGo = UIUtils.FindGo(go.transform, "Back/NotOpen")
    _result.FinishGo = UIUtils.FindGo(go.transform, "Back/Finish")
    _result.SellOutGo = UIUtils.FindGo(go.transform, "Back/SellOut")
    _result.BuKeYong = UIUtils.FindGo(go.transform, "Back/BuKeYong")
    UIUtils.AddBtnEvent( _result.Btn, _result.OnBtnClick, _result)
    return _result
end

function UIItemQuickGetFunc:Refresh(funcId, name, param, itemId, openFunc, openParam)
    self.FuncId = funcId
    self.FuncParam = param
    self.OpenFuncID = openFunc
    self.OpenFuncParam = openParam
    UIUtils.SetTextByString(self.FuncName, name)
    if funcId > 0 then
        local _useFunc = self.FuncId
        local _funcIsVisable = GameCenter.MainFunctionSystem:FunctionIsVisible(funcId)
        local _isFinish = false
        local _isSellOut =  false
        local _isCanNotUseInCross = GameCenter.MainFunctionSystem:FunctionIsCanNotUseInCross(funcId)
        if funcId == FunctionStartIdCode.DailyActivity and type(param) == "number" then
            -- Special processing of daily interface
            local _activityInfo = GameCenter.DailyActivitySystem:GetActivityInfo(param)
            if _activityInfo ~= nil then
                if string.len(_activityInfo.Cfg.OpenUI) <= 0 then
                    _funcIsVisable = true
                else
                    local _uiCfg = Utils.SplitStr(_activityInfo.Cfg.OpenUI, "_")
                    _useFunc = tonumber(_uiCfg[1])
                    local _useFuncCfg = DataConfig.DataFunctionStart[_useFunc]
                    if _useFuncCfg == nil then
                        _funcIsVisable = true
                        _isCanNotUseInCross = false
                    else
                        _funcIsVisable = GameCenter.MainFunctionSystem:FunctionIsVisible(_useFunc)
                        _isCanNotUseInCross = GameCenter.MainFunctionSystem:FunctionIsCanNotUseInCross(_useFunc)
                    end
                end
                _isFinish = _activityInfo.Complete
            end
        elseif funcId == FunctionStartIdCode.TaskMain then
            -- Special handling of main tasks
            local _taskCfg = DataConfig.DataTask[GameCenter.LuaTaskManager:GetMainTaskId()]
            if _taskCfg == nil then
                _isFinish = true
            else
                local _targetParams = Utils.SplitNumber(_taskCfg.Target, '_')
                if #_targetParams > 1 and _targetParams[1] == 19 then
                    -- Card Realm Mission
                    _isFinish = true
                end
            end
        elseif funcId == FunctionStartIdCode.LimitShop then
            _isSellOut = not GameCenter.LimitShopSystem:IsCanBuy(itemId)
        end
        
        if not _isFinish and not _isSellOut and not _isCanNotUseInCross and _funcIsVisable then
            self.SortValue = _useFunc + 40000000
        elseif _isFinish or _isSellOut then
            self.SortValue = _useFunc + 30000000
        elseif not _funcIsVisable then
            self.SortValue = _useFunc + 10000000
        else
            self.SortValue = _useFunc
        end
        self.IsVisible = _funcIsVisable
        if _isCanNotUseInCross then
            self.BuKeYong:SetActive(true)
            self.NotOpenGo:SetActive(false)
            self.FinishGo:SetActive(false)
            self.SellOutGo:SetActive(false)
        else
            self.NotOpenGo:SetActive(_funcIsVisable == false)
            self.FinishGo:SetActive(_isFinish)
            self.SellOutGo:SetActive(_isSellOut)
            self.BuKeYong:SetActive(false)
        end
    else
        -- When configured as 0, it means that no interface is opened, it is just displayed.
        self.NotOpenGo:SetActive(false)
        self.FinishGo:SetActive(false)
        self.SellOutGo:SetActive(false)
        self.BuKeYong:SetActive(false)
        self.SortValue = 20000000
    end

end

function UIItemQuickGetFunc:OnBtnClick()
    if self.OpenFuncID ~= nil and tonumber(self.OpenFuncID) > 0 then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(tonumber(self.OpenFuncID), tonumber(self.OpenFuncParam))
    elseif self.FuncId > 0 then
        GameCenter.MainFunctionSystem:DoFunctionCallBack(self.FuncId, self.FuncParam)
    end
    self.Parent:OnClose(nil, nil)
end

return UIItemQuickGetFunc