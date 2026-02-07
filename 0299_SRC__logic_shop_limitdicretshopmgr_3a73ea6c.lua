local LimitDicretShopMgr = {
    DataDic = Dictionary:New(),
    FreeGiftRemainTime = 0,
    IsInitCfg = false,
}

function LimitDicretShopMgr:Initialize()
    self.IsInitCfg = false
    self.TipsMap = {}
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
end

function LimitDicretShopMgr:UnInitialize()
    self.DataDic:Clear()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_FIRSTENTERMAP, self.OnFirstEnterMap, self)
end

function LimitDicretShopMgr:InitCfg()
    DataConfig.DataLimitDirectShop:Foreach(function(k, v)
        local _item = {}
        _item.Cfg = v
        _item.BuyNum = v.BuyNum
        _item.ID = k
        if self.DataDic:ContainsKey(v.Group) then
            self.DataDic[v.Group].DataList:Add(_item)
        else
            local _data = {}
            _data.DataList = List:New()
            _data.DataList:Add(_item)
            _data.RemainTime = 0
            self.DataDic:Add(v.Group, _data)
        end
    end)
    self.IsInitCfg = true
end

function LimitDicretShopMgr:Update(dt)
    local _setFunc = false
    local _keys = self.DataDic:GetKeys()
    for i=1,#_keys do
        local k = _keys[i]
        local v = self.DataDic[k]
        if v.RemainTime > 0 then
            v.RemainTime = v.RemainTime - dt
            if v.RemainTime <= 0 then
                v.RemainTime = 0
                _setFunc = true
            elseif not self.TipsMap[k] and v.RemainTime <= 600 and v.RemainTime >= 599 and self:GoodsIsBuyOut(v) then
                self.TipsMap[k] = true;
                if not self.IsShowingTips then
                    self.IsShowingTips = true;
                    GameCenter.MsgPromptSystem:ShowMsgBox(true, DataConfig.DataMessageString.Get("LimitShopOutOfDateTips"), function(code)
                        if code == MsgBoxResultCode.Button2 then
                            GameCenter.PushFixEvent(UIEventDefine.UILimitDicretShopForm_OPEN);
                        end
                        self.IsShowingTips = false;
                    end, false, false, 10);
                end
            end
        end
    end
    if _setFunc then
        self:SetFunctionVisible()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIMITDICRETESHOP_UPDATE, _setFunc)
    end
    if self.FreeGiftRemainTime > 0 then
        self.FreeGiftRemainTime = self.FreeGiftRemainTime - dt
        if self.FreeGiftRemainTime <= 0 then
            self.FreeGiftRemainTime = 0
            GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LimitDicretShop, true)
        end
    end
end

function LimitDicretShopMgr:GoodsIsBuyOut(v)
    local _find = false
    if v and v.DataList then
        for j = 1, #v.DataList do
            if v.DataList[j].BuyNum > 0 then
                _find = true
                break
            end
        end
    end
    return _find
end

function LimitDicretShopMgr:SetFunctionVisible()
    local _isHave = false
    self.DataDic:ForeachCanBreak(function(k, v)
        if v.RemainTime > 0 and self:GoodsIsBuyOut(v) then
            _isHave = true
            return true
        end
    end)
    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.LimitDicretShop, _isHave)
end

-- Remaining the remaining time for a discount package
function LimitDicretShopMgr:GetGoodsRemainTime(id)
    local _rem = 0
    local _idList = Utils.SplitNumber(id, '_')
    if _idList and #_idList > 0 then
        self.DataDic:ForeachCanBreak(function(k, v)
            if _idList:Contains(k) then
                for j = 1, #v.DataList do
                    if v.DataList[j].BuyNum > 0 and v.RemainTime > 0 then
                        _rem = v.RemainTime
                        break
                    end
                end
                if _rem > 0 then
                    return true
                end
            end
        end)
    end
    return _rem > 0
end

function LimitDicretShopMgr:GetDataDic(type)
    if not self.IsInitCfg then
        self:InitCfg()
    end
    if type then
        return self.DataDic[type]
    end
    return self.DataDic
end

function LimitDicretShopMgr:OnFirstEnterMap(obj, sendeer)
    self.IsEnterMap = true
    if GameCenter.MainFunctionSystem:FunctionIsVisible(FunctionStartIdCode.LimitDicretShop) then
        GameCenter.Network.Send("MSG_Recharge.ReqDiscountRecharge", {})
        GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.LimitDicretShop, false)
    end
end

-- Server data issuance
function LimitDicretShopMgr:ResDiscountRechargeData(msg)
    if not self.IsInitCfg then
        self:InitCfg()
    end
    if not self.IsEnterMap then
        return
    end
    if msg.freeGoodsRemainTime then
        self.FreeGiftRemainTime = msg.freeGoodsRemainTime / 1000
    else
        self.FreeGiftRemainTime = 0
    end
    local _findKey = 1
    if msg.items then
        for i = 1, #msg.items do
            self.DataDic:ForeachCanBreak(function(k, v)
                local _find = false
                for j = 1, #v.DataList do
                    if v.DataList[j].ID == msg.items[i].id then
                        v.DataList[j].BuyNum = v.DataList[j].BuyNum - msg.items[i].count
                        v.RemainTime = msg.items[i].timeout
                        _find = true
                        break
                    end
                end
                if _find then
                    _findKey = k
                    return true
                end
            end)
        end
        self:SetFunctionVisible()
    end
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.LimitDicretShop, self.FreeGiftRemainTime <= 0)
    if msg.first and msg.first == 1 then
        GameCenter.PushFixEvent(UIEventDefine.UILimitDicretShopForm_OPEN, _findKey)
    elseif msg.first and msg.first == 2 then
        if not self.IsShowedOverTimeShop then
            GameCenter.MsgPromptSystem:ShowMsgBox(true, DataConfig.DataMessageString.Get("LimitShopOutOfDateTipsAddTime"), function(code)
                if code == MsgBoxResultCode.Button2 then
                    GameCenter.PushFixEvent(UIEventDefine.UILimitDicretShopForm_OPEN);
                end
            end, false, false, 10);
            self.IsShowedOverTimeShop = true;
        end
    end
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_LIMITDICRETESHOP_UPDATE)
end
return LimitDicretShopMgr