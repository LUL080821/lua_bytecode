------------------------------------------------
-- Author:
-- Date: 2019-04-03
-- File: KeyCodeSystem.lua
-- Module: KeyCodeSystem
-- Description: Keyboard shortcut monitoring system
------------------------------------------------
local M = {}
local CSInput = CS.UnityEngine.Input
local GetKeyDown = CS.UnityEngine.Input.GetKeyDown
local GetTouch = CS.UnityEngine.Input.GetTouch
local GetMouseButtonDown = CS.UnityEngine.Input.GetMouseButtonDown
local KeyCode = CS.UnityEngine.KeyCode

M.IsDown = false
M.IsOpenEnter = true
M.CfgPassword = {5,2,1}
M.CurPassword = {}
M.CfgTotalTime = 10
M.CurTotalTime = 0
M.CfgSingleTime = 0.33
M.CurSingleTime = 0
M.CurNumber = 0

function M.Update(deltaTime)
	if GetKeyDown(KeyCode.Y) then
		M.KeyCodeY()
	elseif GetKeyDown(KeyCode.F) then
		M.KeyCodeF();
	elseif GetKeyDown(KeyCode.G) then
		M.KeyCodeG();
	elseif GetKeyDown(KeyCode.H) then
		M.KeyCodeH();
	end
	if M.IsOpenEnter then
		M.InputPassword(deltaTime)
	end
end

function M.InputPassword(deltaTime)
	if M.IsDown then
		if CSInput.touchCount == 0 then
			M.IsDown = false;
		end
	else
		if CSInput.touchCount > 0 then
			M.IsDown = true;
			M.CurSingleTime = 0
			M.CurNumber = M.CurNumber + 1
		end
	end
	
	if M.CurNumber > 0 then
		M.CurTotalTime = M.CurTotalTime + deltaTime
		if M.CurTotalTime > M.CfgTotalTime then
			M.ClearPassword()
		else
			M.CurSingleTime = M.CurSingleTime + deltaTime
			if M.CurSingleTime > M.CfgSingleTime then
				table.insert(M.CurPassword, M.CurNumber)
				M.CurNumber = 0
			end
		end
	end
	if #M.CurPassword > 0 then
		local _isInputRight = true
		local _isDone = true
		for i=1, #M.CfgPassword do
			if M.CurPassword[i] then
				if M.CurPassword[i] ~= M.CfgPassword[i] then
					_isInputRight = false
				end
			else
				_isDone = false
			end
		end

		if _isInputRight and _isDone then
			M.ClearPassword()
			-- CS.Thousandto.Code.Logic.RunTimeProfiler2.instance.isRunProfiler = true;
			CS.Thousandto.Code.Center.GameUICenter.UIFormManager.UIRoot.gameObject:SetActive(true);
		elseif not _isInputRight then
			M.ClearPassword()
		end
	end
end

function M.ClearPassword()
	M.CurNumber = 0
	M.CurTotalTime = 0
	M.CurSingleTime = 0
	for j=#M.CurPassword, 1, -1 do
		M.CurPassword[j] = nil
	end
end

function M.KeyCodeY()
	-- Debug.Log("=============[KeyCode.Y]=================")

end

function M.KeyCodeF()
	-- Debug.Log("=============[KeyCode.F]=================")

end

function M.KeyCodeG()
	-- Debug.Log("=============[KeyCode.G]=================")
end

function M.KeyCodeH()
	Debug.Log("=============[KeyCode.H]=================")
end

return M