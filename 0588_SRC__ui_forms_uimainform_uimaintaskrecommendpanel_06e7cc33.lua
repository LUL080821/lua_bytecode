------------------------------------------------
--author:
--Date: 2021-08-20
--File: UIMainTaskRecommendPanel.lua
--Module: UIMainTaskRecommendPanel
--Description: Recommended main interface task
------------------------------------------------

local L_UIMainSubBasePanel = require "UI.Forms.UIMainForm.UIMainSubBasePanel"

local UIMainTaskRecommendPanel = {
    RootTrans = nil,
    Grid = nil,
    Back = nil,
    WYJBtn = nil,
    SJZDBtn = nil,
    LYYTBtn = nil,
    QFBtn = nil,
    CDBtn = nil,
    JJCBtn = nil,
    GRSLBtn = nil,
    TJZMBtn = nil,
    SCBtn = nil,
    XMRWBtn = nil,
    SJSLBtn = nil,
    CloseBtn = nil,
}


function UIMainTaskRecommendPanel:OnFirstShow(trans, parent, rootForm)
    setmetatable(self, {__index = L_UIMainSubBasePanel.New()})
    self:BaseFirstShow(trans, parent, rootForm)

    self.RootTrans = UIUtils.FindTrans(trans, "Root")
    self.Grid = UIUtils.FindGrid(trans, "Root/Grid")
    self.Back = UIUtils.FindSpr(trans, "Root/Bg")
    self.WYJBtn = UIUtils.FindBtn(trans, "Root/Grid/WYJ")
    UIUtils.AddBtnEvent(self.WYJBtn, self.OnWYJBtnClick, self)

    self.LYYTBtn = UIUtils.FindBtn(trans, "Root/Grid/LYYT")
    UIUtils.AddBtnEvent(self.LYYTBtn, self.OnLYYTBtnClick, self)

    self.SJZDBtn = UIUtils.FindBtn(trans, "Root/Grid/SJZD")
    UIUtils.AddBtnEvent(self.SJZDBtn, self.OnSJZDBtnClick, self)

    self.QFBtn = UIUtils.FindBtn(trans, "Root/Grid/QF")
    UIUtils.AddBtnEvent(self.QFBtn, self.OnQFBtnClick, self)

    self.CDBtn = UIUtils.FindBtn(trans, "Root/Grid/CD")
    UIUtils.AddBtnEvent(self.CDBtn, self.OnCDBtnClick, self)

    self.JJCBtn = UIUtils.FindBtn(trans, "Root/Grid/JJC")
    UIUtils.AddBtnEvent(self.JJCBtn, self.OnJJCBtnClick, self)

    self.GRSLBtn = UIUtils.FindBtn(trans, "Root/Grid/GRSL")
    UIUtils.AddBtnEvent(self.GRSLBtn, self.OnGRSLBtnClick, self)

    self.TJZMBtn = UIUtils.FindBtn(trans, "Root/Grid/TJZM")
    UIUtils.AddBtnEvent(self.TJZMBtn, self.OnTJZMBtnClick, self)

    self.SCBtn = UIUtils.FindBtn(trans, "Root/Grid/SC")
    UIUtils.AddBtnEvent(self.SCBtn, self.OnSCBtnClick, self)

    self.CloseBtn = UIUtils.FindBtn(trans, "CloseBtn")
    UIUtils.AddBtnEvent(self.CloseBtn, self.OnCloseBtnClick, self)

    self.XMRWBtn = UIUtils.FindBtn(trans, "Root/Grid/XMRW")
    UIUtils.AddBtnEvent(self.XMRWBtn, self.OnXMRWBtnClick, self)

    self.SJSLBtn = UIUtils.FindBtn(trans, "Root/Grid/SJSL")
    UIUtils.AddBtnEvent(self.SJSLBtn, self.OnSJSLBtnClick, self)

    self.AnimModule:AddNormalAnimation(0.3)

    self.GuildTaskMaxCount = 5
	local _cfg = DataConfig.DataGlobal[GlobalName.GuildTaskMax]
	if _cfg then
		local _arr = Utils.SplitStr(_cfg.Params, ';')
		for i = 1, #_arr do
			local _single = Utils.SplitNumber(_arr[i], '_')
			if #_single >= 2 and _single[1] == 2 then
				self.GuildTaskMaxCount = _single[2]
			end
		end
	end
end

function UIMainTaskRecommendPanel:OnShowAfter()
    local _backHeight = 16
    local _showCount = 0
    --Wan Yao Scroll, combat power and level are all satisfied
    self.WYJBtn.gameObject:SetActive(false)
    local _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.TowerCopyMap)
    --if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
    --    _backHeight = _backHeight + 46
    --    self.WYJBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.WYJBtn.gameObject:SetActive(false)
    --end

    --The Lingyun Demon Tower directly opens the dungeon, disappears when there are no purchases.
    _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ExpCopyMap)
    self.LYYTBtn.gameObject:SetActive(false)
    --if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
    --    _backHeight = _backHeight + 46
    --    self.LYYTBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.LYYTBtn.gameObject:SetActive(false)
    --end

    --The way of bounty is determined by the mission system
    if GameCenter.LuaTaskManager:GetDailyTask() ~= nil then
        self.SJZDBtn.gameObject:SetActive(true)
        _backHeight = _backHeight + 46
        _showCount = _showCount + 1
    else
        self.SJZDBtn.gameObject:SetActive(false)
    end

    --Pray directly on the blessing, disappearing when there are no times
    local _qfCount = GameCenter.WelfareSystem:GetRemainExpCount()
    if _qfCount > 0 then
        _backHeight = _backHeight + 46
        self.QFBtn.gameObject:SetActive(true)
        _showCount = _showCount + 1
    else
        self.QFBtn.gameObject:SetActive(false)
    end

    --The preaching function will be displayed only if there is an active point.
    self.CDBtn.gameObject:SetActive(false)
    local _point = GameCenter.ItemContianerSystem:GetEconomyWithType(ItemTypeCode.ActivePoint)
    --if _point > 0 then
    --    _backHeight = _backHeight + 46
    --    self.CDBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.CDBtn.gameObject:SetActive(false)
    --end

    --The Immortal Alliance mission, there is the Immortal Alliance and the remaining times are greater than 0
    if GameCenter.GuildSystem:HasJoinedGuild() then
        local _curTaskCount = GameCenter.LuaTaskManager.XmReciveCount
        if self.GuildTaskMaxCount - _curTaskCount > 0 then
            _backHeight = _backHeight + 46
            self.XMRWBtn.gameObject:SetActive(true)
            _showCount = _showCount + 1
        else
            self.XMRWBtn.gameObject:SetActive(false)
        end
    else
        self.XMRWBtn.gameObject:SetActive(false)
    end

    --Arena, open the interface directly, disappears when there are no times, no purchases
    _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.ArenaShouXi)
    if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
        _backHeight = _backHeight + 46
        self.JJCBtn.gameObject:SetActive(true)
        _showCount = _showCount + 1
    else
        self.JJCBtn.gameObject:SetActive(false)
    end

    -- Personal leader, open the interface directly, disappear when there are no times, no purchases
    _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.StatureBoss)
    if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
        _backHeight = _backHeight + 46
        self.GRSLBtn.gameObject:SetActive(true)
        _showCount = _showCount + 1
    else
        self.GRSLBtn.gameObject:SetActive(false)
    end

    --The Gate of Heavenly Forbidden, the interface is opened directly, disappears when there are no times, and there are no purchases.
    self.TJZMBtn.gameObject:SetActive(false)
    _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.TJZMCopyMap)
    --if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
    --    _backHeight = _backHeight + 46
    --    self.TJZMBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.TJZMBtn.gameObject:SetActive(false)
    --end

    --First recharge, disappears after recharge
    self.SCBtn.gameObject:SetActive(false)
    local _recharge = GameCenter.VipSystem.CurRecharge
    --if _recharge <= 0 then
    --    _backHeight = _backHeight + 58
    --    self.SCBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.SCBtn.gameObject:SetActive(false)
    --end

    --The world boss, show when there are red dots
    self.SJSLBtn.gameObject:SetActive(false)
    _funcInfo = GameCenter.MainFunctionSystem:GetFunctionInfo(FunctionStartIdCode.WorldBoss)
    --if _funcInfo.IsVisible and _funcInfo.IsShowRedPoint then
    --    _backHeight = _backHeight + 46
    --    self.SJSLBtn.gameObject:SetActive(true)
    --    _showCount = _showCount + 1
    --else
    --    self.SJSLBtn.gameObject:SetActive(false)
    --end

    if _showCount <= 8 then
        UnityUtils.SetLocalPositionY(self.RootTrans, -70)
    else
        UnityUtils.SetLocalPositionY(self.RootTrans, 0)
    end

    self.Grid:Reposition()
    self.Back.height = _backHeight
    if _showCount <= 0 then
        self:Close()
        --Open daily
        GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.DailyActivity)
    end
end

function UIMainTaskRecommendPanel:OnWYJBtnClick()
    --The Wan Yao Scroll directly opens the copy and keeps showing
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TowerCopyMap)
    self:Close()
end

function UIMainTaskRecommendPanel:OnSJZDBtnClick()
    --The way of bounty is determined by the mission system
    GameCenter.TaskController:RunDaiyTask(0, false, true)
    self:Close()
end

function UIMainTaskRecommendPanel:OnLYYTBtnClick()
    --The Lingyun Demon Tower directly opens the dungeon, disappears when there are no purchases.
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ExpCopyMap)
    self:Close()
end

function UIMainTaskRecommendPanel:OnQFBtnClick()
    --Pray directly on the blessing, disappearing when there are no times
    --GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WelfareWuDao)
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TrainBOSSMap)
    self:Close()
end

function UIMainTaskRecommendPanel:OnCDBtnClick()
    --Preach, directly turn on the preaching function
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ChuanDao)
    self:Close()
end

function UIMainTaskRecommendPanel:OnJJCBtnClick()
    --Arena, open the interface directly, disappears when there are no times, no purchases
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.ArenaShouXi)
    self:Close()
end

function UIMainTaskRecommendPanel:OnGRSLBtnClick()
    -- Personal leader, open the interface directly, disappear when there are no times, no purchases
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.StatureBoss)
    self:Close()
end

function UIMainTaskRecommendPanel:OnTJZMBtnClick()
    --The Gate of Heavenly Forbidden, the interface is opened directly, disappears when there are no times, and there are no purchases.
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.TJZMCopyMap)
    self:Close()
end

function UIMainTaskRecommendPanel:OnSCBtnClick()
    --First recharge, disappears after recharge
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.FirstCharge)
    self:Close()
end

function UIMainTaskRecommendPanel:OnXMRWBtnClick()
    --Immortal Alliance mission, open the Immortal Alliance mission interface
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.GuildTask)
    self:Close()
end

function UIMainTaskRecommendPanel:OnSJSLBtnClick()
    --The world leader, open the world leader interface
    GameCenter.MainFunctionSystem:DoFunctionCallBack(FunctionStartIdCode.WorldBoss)
    self:Close()
end

function UIMainTaskRecommendPanel:OnCloseBtnClick()
    self:Close()
end

return UIMainTaskRecommendPanel