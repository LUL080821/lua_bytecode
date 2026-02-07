
------------------------------------------------
-- author:
-- Date: 2019-08-01
-- File: WorldAnswerSystem.lua
-- Module: WorldAnswerSystem
-- Description: World Question Answer
------------------------------------------------
-- Quote
local TimeUtils = CS.Thousandto.Core.Base.TimeUtils;
local WorldAnswerSystem = {
    -- Current status Default ready state
    CurState = WorldAnswerState.ReadyState,
    -- Obtain points
    Score = 0,
    -- Gain experience
    Exp = 0,
    -- Get Money
    Money = 0,
    -- Show Rewards
    ShowItemList = List:New(),
    -- Final prop reward
    RewardItemList = List:New(),
    -- announcement
    ListDes = List:New(),
    -- Remaining time (preparation time, answering time, reselecting time, waiting time)
    LeftTime = 0,
    SyncTime = 0,
    -- Total number of questions
    TCount = 0,
    -- Current number of questions
    Count = 0,
    -- question
    Question = nil,
    -- Answer
    ListAnswer = List:New(),
    -- Number of people supported
    ListSupport = List:New(),
    -- Player announcement text template List
    ListGongGaoTemp = List:New(),
    -- Player announcement
    ListGongGao = List:New(),
    -- Number of announcements displayed by the client
    GongGaoCount = 4,
    -- Did you choose the answer
    IsChoose = false,
    -- Current configuration table data
    Cfg = nil,
    -- Set end percentage
    Percent = 0,
    -- The activity id of the daily configuration table
    DailyId = 104,
    -- The answer chosen by the player Id
    SelectId = -1,

    Answerok = nil,
}

function WorldAnswerSystem:Initialize()
    self:InitGongGao()
    self:InitQuestoinTCount()
    self:InitShowItemData()
    -- Initialization Support Rate
    self.ListSupport:Add(-1)
    self.ListSupport:Add(-1)
    self.ListSupport:Add(-1)
    self.ListSupport:Add(-1)
end

function WorldAnswerSystem:UnInitialize()
end

-- Initialize player announcement templates
function WorldAnswerSystem:InitGongGao()
    self.ListGongGaoTemp:Add(DataConfig.DataMessageString.Get("WorldAnswerNotice1"))
    self.ListGongGaoTemp:Add(DataConfig.DataMessageString.Get("WorldAnswerNotice2"))
    self.ListGongGaoTemp:Add(DataConfig.DataMessageString.Get("WorldAnswerNotice3"))
    self.ListGongGaoTemp:Add(DataConfig.DataMessageString.Get("WorldAnswerNotice4"))
end

-- Get the total number of questions
function WorldAnswerSystem:InitQuestoinTCount()
    self.TCount = 10
end

-- Set display reward prop data
function WorldAnswerSystem:InitShowItemData()
    self.ShowItemList:Clear()
    local cfg = DataConfig.DataDaily[self.DailyId]
    if cfg ~= nil then
        local list = Utils.SplitStr(cfg.Reward,'_')
        for i = 1,list ~= nil and #list do
            self.ShowItemList:Add(tonumber(list[i]))
        end
    end
end

-- Random announcement template
function WorldAnswerSystem:RandGongGao()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    if #self.ListGongGaoTemp >0 then
        local id = math.random(1, #self.ListGongGaoTemp)
        if id<= #self.ListGongGaoTemp then
            return self.ListGongGaoTemp[id]
        end
    end
end

-- Setting up announcements
function WorldAnswerSystem:SetGongGao(str)
    if #self.ListGongGao <self.GongGaoCount then
        -- If it is less than the maximum display entry
        self.ListGongGao:Insert(str,1)
    else
        -- If the maximum display entry is exceeded
        self.ListGongGao:RemoveAt(#self.ListGongGao)
        self:SetGongGao(str)
    end
end

-- Clear all announcements
function WorldAnswerSystem:ClearGongGao()
    self.ListGongGao:Clear()
end

--
function WorldAnswerSystem:FormatAnswer(id)
    if id == 1 then
        return "A"
    elseif id == 2 then
        return "B"
    elseif id == 3 then
        return "C"
    elseif id == 4 then
        return "D"
    end
end

-- Get the configuration table
function WorldAnswerSystem:SetCfg(cfgId)
    if cfgId ~= 0 then
        self.Cfg = DataConfig.DataWorldQuestion[cfgId]
    end 
end

-- Get the question by configuring the table
function WorldAnswerSystem:SetQuestion()
    if self.Cfg ~= nil then
        self.Question = self.Cfg.Describe
    end
end

-- Get four answers through the configuration table
function WorldAnswerSystem:SetAnswerList()
    self.ListAnswer:Clear()
    if self.Cfg ~= nil then
        self.ListAnswer:Add(self.Cfg.Answer1)
        self.ListAnswer:Add(self.Cfg.Answer2)
        self.ListAnswer:Add(self.Cfg.Answer3)
        self.ListAnswer:Add(self.Cfg.Answer4)
    end
end

function WorldAnswerSystem:SetAnswerOke()
    if self.Cfg ~= nil then
        self.Answerok = self.Cfg.Answerok
    end
end

-- Get the remaining time
function WorldAnswerSystem:GetleftTime()
    local time = self.LeftTime - (Time.GetRealtimeSinceStartup()- self.SyncTime)
    return time
end

-- Set the remaining time
function WorldAnswerSystem:SetLeftTime(t)
    self.LeftTime = t
    self.SyncTime = Time.GetRealtimeSinceStartup()
end

-- Message prompts increased points, experience, money
function WorldAnswerSystem:ShowMsg(result)
    if result.questionRound == 3 then
        if result.integral ~= nil then
            local score = result.integral.integral - self.Score
            local exp = result.integral.exp - self.Exp
            local money = result.integral.money - self.Money
            if score>0 then
                Utils.ShowPromptByEnum("GetIntegralByAnswer",score)
            end
            if exp>0 then
                Utils.ShowPromptByEnum("GetExpByAnswer",exp)
            end
        end
    end
end

-- Switch answer status
function WorldAnswerSystem:ChangeState(round,time,choose)
    -- If it is the preparation stage
    if round == -1 then
        self.CurState = WorldAnswerState.ReadyState
        -- Get the countdown for activity preparation
        local readyTime = 0
        local _cfg = DataConfig.DataDaily[104]
        if _cfg ~= nil then
            local _list = Utils.SplitNumber(_cfg.Time, '_')
            local _openTime = _list[1] * 60
            local hour, min, sec = TimeUtils.GetStampTimeHHMMSSNotZone(math.floor(GameCenter.HeartSystem.ServerZoneTime))
            local _curSec = hour * 3600 + min * 60 + sec
            readyTime = _openTime - _curSec
        end
        self:SetLeftTime(readyTime)
        self.IsChoose = false
        self.SelectId = -1
    -- The first round of multiple-choice questions
    elseif round == 1 then
        self.CurState = WorldAnswerState.ChooseState
        -- Set up topics
        self:SetQuestion()
        -- Setting up the answer
        self:SetAnswerList()
        self:SetAnswerOke()
        self:SetLeftTime(time)
        self:ClearGongGao()
        self.SelectId = choose
        self.IsChoose = choose ~= 0
    -- The second round of reselect
    elseif round == 2 then
        self.CurState = WorldAnswerState.ReChooseState
        self:SetLeftTime(time)
        if choose > 10 then
            self.SelectId = choose % 10
            self.IsChoose = false
        else
            self.IsChoose = choose ~= 0
        end
    -- The third round is waiting for the next round of answering questions
    elseif round == 3 then
        self.CurState = WorldAnswerState.WaitState
        self:SetLeftTime(time)
        self:ClearGongGao()
        if self.Count ~= self.TCount then
            self:SetGongGao(DataConfig.DataMessageString.Get("NextProblemBeComing"))
        end
        self.IsChoose = true
    elseif round == 4 then
        self.CurState = WorldAnswerState.FinishState
    end
end

-- Get it by configuring the table id

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Request to register to answer questions
function WorldAnswerSystem:ReqApplyAnswer()
    GameCenter.Network.Send("MSG_WorldAnswer.ReqApplyAnswer")
end

-- Submit selection results to serviceless
function WorldAnswerSystem:ReqAnswerResult(id)
    GameCenter.Network.Send("MSG_WorldAnswer.ReqAnswerResult",{resultIndex = id})
    self.IsChoose = true
end

-- Leave the answering interface
function WorldAnswerSystem:ReqLeaveOutAnswer()
    GameCenter.Network.Send("MSG_WorldAnswer.ReqLeaveOutAnswer")
end
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Open the answering interface to return the message
function WorldAnswerSystem:ResApplyAnswerResult(result)
    if result == nil then
        return
    end
    -- Set Cfg
    self:SetCfg(result.questionID)
    self:ShowMsg(result)
    if result.integral ~= nil then
        self.Score = result.integral.integral
        self.Exp = result.integral.exp
        self.Money = result.integral.money
    end
    -- Set what question is currently
    self.Count = result.curQuestionNum
    if self.Count == self.TCount and (result.questionRound == 3 or result.questionRound == 4) then
        Utils.ShowPromptByEnum("AnswerEnd")
        return
    end
    -- Set support rate
    self.ListSupport:Clear()
    if result.chooseNum ~= nil then
        local tCount = result.chooseNum.chooseACount + result.chooseNum.chooseBCount + result.chooseNum.chooseCCount + result.chooseNum.chooseDCount
        self.ListSupport:Add(result.chooseNum.chooseACount)
        self.ListSupport:Add(result.chooseNum.chooseBCount)
        self.ListSupport:Add(result.chooseNum.chooseCCount)
        self.ListSupport:Add(result.chooseNum.chooseDCount)
    else
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
    end
    self.SelectId = result.curChoose
    self:ChangeState(result.questionRound,result.lastTime,result.curChoose)
    -- Open the world answering interface
    GameCenter.PushFixEvent(UIEventDefine.UIWorldAnswerForm_Open);
    GameCenter.BISystem:ReqClickEvent(BiIdCode.SJDTEnter)
end

-- Update the topic in the middle
function WorldAnswerSystem:ResSendQuestion(result)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if result == nil then
        return
    end
    -- Set Cfg
    self:SetCfg(result.questionID)
    -- Set support rate
    self.ListSupport:Clear()
    if result.chooseNum ~= nil then
        local tCount = result.chooseNum.chooseACount + result.chooseNum.chooseBCount + result.chooseNum.chooseCCount + result.chooseNum.chooseDCount
        self.ListSupport:Add(result.chooseNum.chooseACount)
        self.ListSupport:Add(result.chooseNum.chooseBCount)
        self.ListSupport:Add(result.chooseNum.chooseCCount)
        self.ListSupport:Add(result.chooseNum.chooseDCount)
    else
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
        self.ListSupport:Add(-1)
    end
    self:ShowMsg(result)
    if result.integral ~= nil then
        self.Score = result.integral.integral
        self.Exp = result.integral.exp
        self.Money = result.integral.money
    end
    -- Set what question is currently
    self.Count = result.curQuestionNum
    -- Set status
    self:ChangeState(result.questionRound,result.lastTime,0)
    -- Update the UI
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WORLDANSWER_CHANGESTATE)
end

-- Synchronous announcement
function WorldAnswerSystem:ResSendOtherPlayerSelect(result)
    if result == nil then
        return
    end
    -- Get a random template
    local gongGao = self:RandGongGao()
    gongGao = UIUtils.CSFormat(gongGao, result.roleName,self:FormatAnswer(result.questionIndex))
    self:SetGongGao(gongGao)
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WORLDANSWER_GONGGAO)
end

-- The answer ends
function WorldAnswerSystem:ResWorldAnswerOver(result)
    if result == nil then
        return
    end
    -- Update points
    if result.integral ~= nil then
        self.Score = result.integral.integral
        self.Exp = result.integral.exp
        self.Money = result.integral.money
    end
    -- Set reward props
    if result.reward ~= nil then
        self.RewardItemList:Clear()
        for i = 1, #result.reward do
            self.RewardItemList:Add(result.reward[i])
        end
    end
    self.Percent = result.rankPer
    self:ChangeState(4,0,0)
    -- Update the UI
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_WORLDANSWER_CHANGESTATE)
end

return WorldAnswerSystem
