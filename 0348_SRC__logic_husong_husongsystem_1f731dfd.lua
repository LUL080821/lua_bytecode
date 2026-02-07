local HuSongSystem = {
    ReMainTime = 0,
    CurHuSongID = 1,
}

function HuSongSystem:Initialize()
    self.ReMainTime = 0
end

function HuSongSystem:UnInitialize()
    self.ReMainTime = 0
end


function HuSongSystem:Update(dt)
    if self.ReMainTime and self.ReMainTime > 0 then
        self.ReMainTime = self.ReMainTime - dt
        if self.ReMainTime <= 0 then
            self.ReMainTime = 0
            local _msg = ReqMsg.MSG_Couplefight.ReqCoupleEscortOver:New()
            _msg:Send()
            GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongFlashForm_CLOSE)
        end
    end
end

-- Escort request returns
function HuSongSystem:ResEnterCoupleEscortResult(msg)
    if msg.result == 1 then
        local _cfg = DataConfig.DataConvoyGirl[msg.type]
        if _cfg then
            self.CurHuSongID = msg.type
            self.ReMainTime = _cfg.ConvoyTime
            GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongForm_CLOSE)
            GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongFlashForm_OPEN)
        end
    end
end

-- Escort result notice
function HuSongSystem:ResCoupleEscortReward(msg)
    if msg.rewards then
        GameCenter.PushFixEvent(UILuaEventDefine.UIHuSongResultForm_OPEN, msg.rewards)
    end
end
return HuSongSystem