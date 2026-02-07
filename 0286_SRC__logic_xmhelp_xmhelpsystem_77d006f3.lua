
------------------------------------------------
-- Author:
-- Date: 2020-03-02
-- File: XmHelpSystem.lua
-- Module: XmHelpSystem
-- Description: Immortal Alliance War Help Description Category
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local XmHelpSystem = {
    CurFunctionId = 0,
    Show = -1,
    PrevHour = 23,
    -- {key = large menu type, List = {Id = small menu Id, cName = small menu name}}
    DicHelp = Dictionary:New(),
    -- Ouyang flirted with that funny guy and changed it to the first time he entered the Immortal Alliance battle.
    IsLogicCanShow = true,
}

function XmHelpSystem:Initialize()
    self.DicHelp:Clear()
    DataConfig.DataGuideWarNewbie:Foreach(function(k, v)
        local list = nil
        local tab = {Id = v.Id, cName = v.Name}
        if self.DicHelp:ContainsKey(v.Type) then
            list = self.DicHelp[v.Type]
            list:Add(tab)          
        else
            list = List:New()
            list:Add(tab)
            self.DicHelp[v.Type] = list
        end
    end)
end

function XmHelpSystem:CanShow()
    -- local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    -- if lp == nil then
    --     return 
    -- end
    -- local week = TimeUtils.GetStampTimeWeekly(math.ceil( GameCenter.HeartSystem.ServerTime ))
    -- local str = string.format( "XmHelp_{0}" ,lp.ID)
    -- self.Show = PlayerPrefs.GetInt(str) 
    -- if self.Show == nil or self.Show == -1  then
    --     PlayerPrefs.SetInt(str, week)
    --     self.Show = week 
    --     PlayerPrefs.Save()
    --     return true
    -- else
    --     self.Show = PlayerPrefs.GetInt(str)
    --     if self.Show ~= week then
    --         PlayerPrefs.SetInt(str, week)
    --         self.Show = week 
    --         PlayerPrefs.Save()
    --         return true
    --     end
    --     return false
    -- end
    if self.IsLogicCanShow then
        self.IsLogicCanShow = false
        return true
    else
        return false
    end
end

function XmHelpSystem:Update(dt)
    -- if self.Show == -1 then
    --     local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    --     if lp == nil then
    --         return 
    --     end
    --     local str = UIUtils.CSFormat("XmHelp_{0}",lp.ID)
    --     self.Show = PlayerPrefs.GetInt(str)
    -- end
    -- if self.Show == local week = TimeUtils.GetStampTimeWeekly(math.ceil( GameCenter.HeartSystem.ServerTime )) then
    --     local hour = TimeUtils.GetStampTimeHH(math.floor( GameCenter.HeartSystem.ServerTime ))
    --     if self.PrevHour == 23 and hour == 0 then
    --         self.Show = 0
    --         local lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    --         if lp == nil then
    --             return 
    --         end
    --         local str = UIUtils.CSFormat("XmHelp_{0}",lp.ID)
    --         PlayerPrefs.SetInt(str, 0)
    --         PlayerPrefs.Save()
    --     end
    -- end
end

return XmHelpSystem
