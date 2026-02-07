------------------------------------------------
-- Author:
-- Date: 2020-01-13
-- File: MailSystem.lua
-- Module: MailSystem
-- Description: Email system
------------------------------------------------
local MailSystem = {
    -- Maximum number
    MaxMailCount = 0,
    -- The remaining number of unreturned messages is, if there is no value of 0
    RemainMailNum = 0,
    -- The currently read email ID
    CurReadMailId = -1,
    -- Text Cache
    ContentList = List:New(),
    -- All emails (summary)
    AllMails = Dictionary:New(),
    -- Cache email details
    DetailInfos = Dictionary:New(),
    -- The server sends it to the mailing list
    MsgMailList = {},
    -- MSG Read Email
    ReqReadMail = nil,
    -- MSG receive attachment content
    ReqReceiveSingleMailAttach = nil,
    -- MSG receives all email attachments in one click
    ReqOneClickReceiveMailAttach = nil,
    -- MSG deletes all emails without attachments with one click
    ReqOneClickDeleteMail = nil,

    StrengthItemLevelDic   = Dictionary:New(),
    ItemWashInfoDic        = Dictionary:New(),
    ItemAppraiseInfoDic    = Dictionary:New(),
    ItemSpecialInfoDic    = Dictionary:New(),
    GemInlayInfoByItemIdDic    = Dictionary:New(),
}

function MailSystem:Initialize()
    self.MaxMailCount = tonumber(DataConfig.DataGlobal[33].Params)
end

function MailSystem:UnInitialize()
    self.AllMails:Clear();
    self.DetailInfos:Clear();
    self.RemainMailNum = 0;
    self.CurReadMailId = -1;
    self.MsgMailList = {}
end

-- Refresh the red dots
function MailSystem:RefreshRepoint()
    GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Mail, self:GetMailNumPrompt() > 0)
end

-- Sort
function MailSystem:SortMailList()
    -- 1. Not read, 2. Time is long
    local _keys = self.AllMails:GetKeys();
    table.sort(_keys, function(a, b)
        local _mailA = self.AllMails[a];
        local _mailB = self.AllMails[b];
        if _mailA.isRead == _mailB.isRead then
            local _isGetA = _mailA.hasAttachment and not _mailA.isAttachReceived;
            local _isGetB = _mailB.hasAttachment and not _mailB.isAttachReceived;
            if _isGetA == _isGetB then
                return self.AllMails[a].receiveTime > self.AllMails[b].receiveTime;
            else
                return _isGetA;
            end
        end
        return _mailB.isRead;
    end)
end

-- Get the number of email prompts
function MailSystem:GetMailNumPrompt()
    -- Unread, read attachments not received, server storage not sent
    local _allMails = self.AllMails;
    local _keys = _allMails:GetKeys();
    local _tipsCount = 0;
    if #_keys > 0 then
        for i = 1, #_keys do
            local _mail = _allMails[_keys[i]];
            if not _mail.isRead or (_mail.hasAttachment and not _mail.isAttachReceived) then
                _tipsCount = _tipsCount + 1;
            end
        end
    end
    local _cnt = _tipsCount + self.RemainMailNum;
    _cnt = _cnt > 999 and 999 or _cnt;
    return _cnt;
end

-- MSG
-- Request to read a single email
function MailSystem:ReqReadSingleMail(id)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    if not self.ReqReadMail then
        self.ReqReadMail = ReqMsg.MSG_Mail.ReqReadMail:New()
    end
    self.ReqReadMail.mailId = id
    self.ReqReadMail:Send()
end

-- Request to get the currently read email to the reward
function MailSystem:ReqGetRewardByCurRead()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    self:ReqReceiveSingleMail(self.CurReadMailId)
end

-- Request a reward for receiving a single email
function MailSystem:ReqReceiveSingleMail(id)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    if not self.ReqReceiveSingleMailAttach then
        self.ReqReceiveSingleMailAttach = ReqMsg.MSG_Mail.ReqReceiveSingleMailAttach:New();
    end
    self.ReqReceiveSingleMailAttach.mailId = id;
    self.ReqReceiveSingleMailAttach:Send();
end

-- Request one click to receive the reward
function MailSystem:ReqGetAllReward()
    if not self.ReqOneClickReceiveMailAttach then
        self.ReqOneClickReceiveMailAttach = ReqMsg.MSG_Mail.ReqOneClickReceiveMailAttach:New();
    end
    local _mailIds = self.ReqOneClickReceiveMailAttach.mailIdList;
    local _allMails = self.AllMails;
    local _keys = _allMails:GetKeys();
    for i = 1, #_keys do
        local _mail = _allMails[_keys[i]];
        if _mail.hasAttachment and not _mail.isAttachReceived then
            _mailIds:Add(_mail.mailId);
        end
    end

    if #_mailIds <= 0 then
		Utils.ShowPromptByEnum("NoRewardMail")
        return false;
    end
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    self.ReqOneClickReceiveMailAttach:Send();
    _mailIds:Clear();
    return true;
end

-- Request to delete the currently read email
function MailSystem:ReqDeleteByCurRead()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    self:ReqDeleteMaill(self.CurReadMailId)
end

-- Request to delete the email
function MailSystem:ReqDeleteMaill(id)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    if not self.ReqOneClickDeleteMail then
        self.ReqOneClickDeleteMail = ReqMsg.MSG_Mail.ReqOneClickDeleteMail:New()
    end
    self.ReqOneClickDeleteMail.mailIdList:Add(id);
    self.ReqOneClickDeleteMail:Send()
    self.ReqOneClickDeleteMail.mailIdList:Clear();
end

-- Request one-click to delete the email
function MailSystem:ReqDeleteAllMail()
    if not self.ReqOneClickDeleteMail then
        self.ReqOneClickDeleteMail = ReqMsg.MSG_Mail.ReqOneClickDeleteMail:New()
    end
    local _mailIds = self.ReqOneClickDeleteMail.mailIdList;
    local _allMails = self.AllMails;
    local _keys = _allMails:GetKeys();
    for i = 1, #_keys do
        local _mail = _allMails[_keys[i]];
        if _mail.isRead and (not _mail.hasAttachment or (_mail.hasAttachment and _mail.isAttachReceived)) then
            _mailIds:Add(_mail.mailId);
        end
    end

    if #_mailIds <= 0 then
		Utils.ShowPromptByEnum("NoDelateMail")
        return
    end

    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
    self.ReqOneClickDeleteMail:Send()
    _mailIds:Clear();
end

-- Return to request to read mail
-- required MailDetailInfo mailDetailInfo = 1; //Details of the read mail
function MailSystem:ResReadMail(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    local _mailDetailInfo = msg.mailDetailInfo;
    if not _mailDetailInfo then
        return;
    end


    -- Debug.Log("=======msg=====================================================================================", Inspect(msg))

    local _mailId = _mailDetailInfo.mailId;
    if _mailId then
        local _mailInfo = self.AllMails[_mailId];
        _mailInfo.isRead = true;
        self.CurReadMailId = _mailId;
        if self.DetailInfos:ContainsKey(_mailId) then
            self.DetailInfos[_mailId] = _mailDetailInfo;
        else
            self.DetailInfos:Add(_mailId, _mailDetailInfo);
        end

        self:HandleAppraiseInfos(_mailDetailInfo.equipListDetail)
        self:HandleSpecialInfos(_mailDetailInfo.equipListDetail)
        self:HandleStrengthInfos(_mailDetailInfo.equipListDetail)
        self:HandleWashInfos(_mailDetailInfo.equipListDetail)
        self:InitGemInlayInfoByEquipList(_mailDetailInfo.equipListDetail)

        local _isReadTable = _mailDetailInfo.readTable;
        local _GetByKeyFunc = DataConfig.DataMessageString.GetByKey;
        local _mailTitle = _mailDetailInfo.mailTitle;
        _mailDetailInfo.mailTitle = _isReadTable and _GetByKeyFunc(tonumber(_mailTitle)) or _mailTitle;
        _mailDetailInfo.sender = _isReadTable and _GetByKeyFunc(tonumber(_mailDetailInfo.sender)) or _mailDetailInfo.sender;
        if _isReadTable then
            _mailDetailInfo.mailContent = self:CetContent(_mailDetailInfo.mailContent, _mailDetailInfo.paramlists);
        end
        -- Refresh the interface
        GameCenter.PushFixEvent(UILuaEventDefine.UIMailRefreshChangeMail);
        -- Refresh the little red dots
        self:RefreshRepoint();
        -- Number of refresh interfaces
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAIL_MAILNUM_PROMPT);
    end
end

-- Accessories for receiving single emails
-- required uint64 mailId = 1; //The email Id of the attached attachment
-- required bool isAttachReceived = 2; //Whether the attachment is successfully received
function MailSystem:ResReceiveSingleMailAttach(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if msg.isAttachReceived then
        self.AllMails[msg.mailId].isAttachReceived = true;
        self.DetailInfos[msg.mailId].isAttachReceived = true;
    else
		Utils.ShowPromptByEnum("GetMailRewardFail")
    end
    -- Refresh the interface
    GameCenter.PushFixEvent(UILuaEventDefine.UIMailRefreshChangeMail);
    -- Refresh the little red dots
    self:RefreshRepoint();
    -- Number of refresh interfaces
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAIL_MAILNUM_PROMPT);
end

-- Return to the client player's mailing list data (the synchronization after login, one-click collection and deletion requires sending this message)
-- repeated MailSummaryInfo mailList = 1; //Returned mailing list
-- required int32 remainMailNum = 2; //The remaining number of unreturned messages, if there is no value of 0
function MailSystem:ResMailInfoList(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if not msg.mailList then
        msg.mailList = {}
    end

    self.RemainMailNum = msg.remainMailNum;
    self.AllMails:Clear();
    self.DetailInfos:Clear();

    self.MsgMailList = msg.mailList;
    local _mailList = msg.mailList;
    for i = 1, #_mailList do
        local _mailMsgData = _mailList[i];
        local _GetByKeyFunc = DataConfig.DataMessageString.GetByKey;
        _mailMsgData.mailTitle = _mailMsgData.readTable and _GetByKeyFunc(tonumber(_mailMsgData.mailTitle)) or _mailMsgData.mailTitle;
        self.AllMails:Add(_mailList[i].mailId, _mailMsgData);
    end

    -- Sort
    self:SortMailList();
    local _keys = self.AllMails:GetKeys();
    self.CurReadMailId = #_keys > 0 and self.AllMails[_keys[1]].mailId or -1;
    -- Refresh the interface
    GameCenter.PushFixEvent(UILuaEventDefine.UIMailRefreshUI);
    -- Refresh the little red dots
    self:RefreshRepoint();
    -- Number of refresh interfaces
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAIL_MAILNUM_PROMPT);
end

-- New email notifications
-- required MailSummaryInfo newMail = 1; //New Mail Summary Information
function MailSystem:ResNewMail(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    if not msg.newMail then
        return
    end
    -- More than the maximum number
    Utils.ShowPromptByEnum("GetNewMail")
    table.insert(self.MsgMailList, 1, msg.newMail);
    if self.AllMails:Count() >= self.MaxMailCount then
        self.RemainMailNum = self.RemainMailNum + 1;
        Utils.ShowPromptByEnum("MailOverFlow")

        for i = self.MaxMailCount + 1, #self.MsgMailList do
            local _mail = table.remove(self.MsgMailList, i);
            self.AllMails:Remove(_mail.mailId);
        end
    end

    local _newMail = msg.newMail;
    -- Is there any attachment
    if _newMail.hasAttachment then
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAILEXISTITEMS);
    end

    local _GetByKeyFunc = DataConfig.DataMessageString.GetByKey;
    _newMail.mailTitle = _newMail.readTable and _GetByKeyFunc(tonumber(_newMail.mailTitle)) or _newMail.mailTitle;
    self.CurReadMailId = _newMail.mailId;
    self.AllMails:Add(_newMail.mailId, _newMail);

    -- Sort
    self:SortMailList();
    -- Refresh the interface
    GameCenter.PushFixEvent(UILuaEventDefine.UIMailRefreshUI);
    -- Refresh the little red dots
    self:RefreshRepoint();
    -- Number of refresh interfaces
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_MAIL_MAILNUM_PROMPT);
end

function MailSystem:CetContent(content, params)
    local _key = tonumber(content);
    if not _key then
        return content
    end
    local _content = DataConfig.DataMessageString.GetByKey(_key)
    if _content and params then
        self.ContentList:Clear();
        for i = 1, #params do
            if params[i].mark == 0 then
                table.insert(self.ContentList, params[i].paramsValue)
            elseif params[i].mark == 1 then
                table.insert(self.ContentList, DataConfig.DataMessageString.GetByKey(tonumber(params[i].paramsValue)))
            elseif params[i].mark == 2 then
                table.insert(self.ContentList, GameCenter.LanguageConvertSystem:ConvertLan(params[i].paramsValue))
            end
        end
        return #self.ContentList > 0 and UIUtils.CSFormatLuaTable(_content, self.ContentList) or _content;
    end
    return _content or content
end

---------------------------------------- Custom view mail



local INVALID_POOL_ID = 0

local L_EquipWashInfo = {
    Index   = 0,
    Value   = 0,
    Percent = 0,
    PoolID  = INVALID_POOL_ID,
}

local L_EquipAppraiseInfo = {
    Index   = 0,
    Value   = 0,
    Percent = 0,
    PoolID  = INVALID_POOL_ID,
}

local L_EquipSpecialInfo = {
    Index   = 0,
    Value   = 0,
    Percent = 0,
    PoolID  = INVALID_POOL_ID,
}
----
function MailSystem:HandleStrengthInfos(equipListDetail)
    if not equipListDetail or Utils.GetTableLens(equipListDetail) == 0 then return end

    self.StrengthItemLevelDic = self.StrengthItemLevelDic or Dictionary:New()

    for i = 1, #equipListDetail do
        local detail = equipListDetail[i]
        local equip = detail and detail.equip
        local strengthInfo = detail and detail.strengthInfo

        if equip and strengthInfo then
            self.StrengthItemLevelDic[equip.itemId] = {
                level = strengthInfo.level or 0,
                exp   = strengthInfo.exp or 0,
                type  = strengthInfo.type or detail.type
            }
        end
    end

    -- Debug.Log("self.StrengthItemLevelDicself.StrengthItemLevelDic====", Inspect(self.StrengthItemLevelDic))
end
----
function MailSystem:HandleWashInfos(equipListDetail)
    if not equipListDetail or Utils.GetTableLens(equipListDetail) == 0 then return end

    self.ItemWashInfoDic = self.ItemWashInfoDic or Dictionary:New()

    for i = 1, #equipListDetail do
        local detail = equipListDetail[i]
        local equip = detail and detail.equip
        local washInfos = detail and detail.washInfo

        if equip and washInfos then
            local list = List:New()
            for j = 1, #washInfos do
                local src = washInfos[j]
                local data = Utils.DeepCopy(L_EquipWashInfo)
                data.Index   = src.index
                data.Value   = src.value
                data.Percent = src.per
                data.PoolID  = src.poolId or INVALID_POOL_ID
                list:Add(data)
            end

            list:Sort(function(a,b) return a.Index < b.Index end)
            self.ItemWashInfoDic[equip.itemId] = list
        end
    end
end
----
function MailSystem:InitGemInlayInfoByEquipList(equipListDetail)
    if not equipListDetail then return end

    self.GemInlayInfoByItemIdDic = self.GemInlayInfoByItemIdDic or Dictionary:New()

    for _, detail in ipairs(equipListDetail) do
        local equip   = detail.equip
        local gemInfo = detail.gemInfo

        if equip and equip.itemId and gemInfo then
            self.GemInlayInfoByItemIdDic[equip.itemId] = {
                part    = detail.type,
                gemIds  = gemInfo.gemIds  and List:New(gemInfo.gemIds)  or nil,
                jadeIds = gemInfo.jadeIds and List:New(gemInfo.jadeIds) or nil,
                refine  = {
                    Level = gemInfo.level or 0,
                    Exp   = gemInfo.exp   or 0
                }
            }
        end
    end
end
----
function MailSystem:HandleAppraiseInfos(equipListDetail)
    if not equipListDetail or Utils.GetTableLens(equipListDetail) == 0 then return end

    self.ItemAppraiseInfoDic = self.ItemAppraiseInfoDic or Dictionary:New()

    for i = 1, #equipListDetail do
        local detail = equipListDetail[i]
        local equip = detail and detail.equip
        local infos = detail and detail.raisalInfo

        if equip then
            local list = List:New()
            if infos then
                for j = 1, #infos do
                    local src = infos[j]
                    local data = Utils.DeepCopy(L_EquipAppraiseInfo)
                    data.Index   = src.index
                    data.Value   = src.value
                    data.Percent = src.per
                    data.PoolID  = src.poolId or INVALID_POOL_ID
                    list:Add(data)
                end
                list:Sort(function(a,b) return a.Index < b.Index end)
            end
            self.ItemAppraiseInfoDic[equip.itemId] = list
        end
    end
end
---
function MailSystem:HandleSpecialInfos(equipListDetail)
    if not equipListDetail or Utils.GetTableLens(equipListDetail) == 0 then return end

    self.ItemSpecialInfoDic = self.ItemSpecialInfoDic or Dictionary:New()

    for i = 1, #equipListDetail do
        local detail = equipListDetail[i]
        local equip = detail and detail.equip
        local infos = detail and detail.attrSpecial

        if equip then
            local list = List:New()
            if infos then
                for j = 1, #infos do
                    local src = infos[j]
                    local data = Utils.DeepCopy(L_EquipSpecialInfo)
                    data.Index   = src.index
                    data.Value   = src.value
                    data.Percent = src.per
                    data.PoolID  = src.poolId or INVALID_POOL_ID
                    list:Add(data)
                end
                list:Sort(function(a,b) return a.Index < b.Index end)
            end
            self.ItemSpecialInfoDic[equip.itemId] = list
        end
    end
end
---


function MailSystem:GetAllStrengthAttrDicByItemId(itemId, strengthLevel)

    local _retAttrDic = Dictionary:New()
    local strengthLevels = self.StrengthItemLevelDic
    if (not itemId) or (not strengthLevels) then
        return _retAttrDic
    end

    -- itemData: Equipment.cs
    local itemData = GameCenter.ItemContianerSystem:GetItemByUIDFormBag(itemId);

    local _useLevel = 0
    if strengthLevel then
        _useLevel = strengthLevel
    elseif (strengthLevels[itemId] and strengthLevels[itemId].level) then
        _useLevel = strengthLevels[itemId].level
    end

    local _userType = nil
    if (strengthLevels[itemId] and strengthLevels[itemId].type) then
        _userType = strengthLevels[itemId].type
    elseif (itemData and itemData.Part) then
        _userType = itemData.Part
    end

    if not _userType then
        return _retAttrDic
    end

    local cfgID = self:GetCfgID(_userType, _useLevel)
    local cfg = DataConfig.DataEquipIntenMain[cfgID]
    if cfg and cfg.Value then
        local attrList = Utils.SplitStrByTableS(cfg.Value, { ';', '_' })
        for i = 1, #attrList do
            local attrId = tonumber(attrList[i][1])
            local value = tonumber(attrList[i][2])
            if not _retAttrDic:ContainsKey(attrId) then
                _retAttrDic:Add(attrId, { Value = value, Level = _useLevel })
            end
        end
    end

    return _retAttrDic
end

function MailSystem:GetCfgID(part, level)
    return (part + 100) * 1000 + level
end

function MailSystem:GetStrengthLvByItemId(itemID)
    if self.StrengthItemLevelDic and self.StrengthItemLevelDic:ContainsKey(itemID) then
        return self.StrengthItemLevelDic[itemID].level or 0
    end
    return 0
end


function MailSystem:GetAllAppraiseAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemAppraiseInfoDic or not self.ItemAppraiseInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get appraise info list from dictionary
    local appraiseInfos = self.ItemAppraiseInfoDic[itemId]
    if not appraiseInfos or #appraiseInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all appraise lines
    for i = 1, #appraiseInfos do
        local appraiseLine = appraiseInfos[i]
        if appraiseLine then
            local index = appraiseLine.Index or 0
            local poolId = appraiseLine.PoolID or INVALID_POOL_ID
            local percent = appraiseLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)
                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            else
                -- Debug.LogError("[LDebug] [GetAllAppraiseAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end


function MailSystem:GetAllSpecialAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemSpecialInfoDic or not self.ItemSpecialInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get appraise info list from dictionary
    local specialInfos = self.ItemSpecialInfoDic[itemId]
    if not specialInfos or #specialInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all appraise lines
    for i = 1, #specialInfos do
        local specialLine = specialInfos[i]
        if specialLine then
            local index = specialLine.Index or 0
            local poolId = specialLine.PoolID or INVALID_POOL_ID
            local percent = specialLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)
                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            else
                -- Debug.LogError("[LDebug] [GetAllAppraiseAttrDicByItemId]", string.format("Invalid pool info for itemId=%s, poolId=%s", tostring(itemId), tostring(poolId)))
            end
        end
    end

    return _retAttrDic
end


function MailSystem:GetAllWashAttrDicByItemId(itemId)
    --- Result data: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    local _retAttrDic = Dictionary:New()

    -- Validate input
    if not itemId then
        return _retAttrDic
    end
    if not self.ItemWashInfoDic or not self.ItemWashInfoDic:ContainsKey(itemId) then
        return _retAttrDic
    end

    -- Get wash info list from dictionary
    local washInfos = self.ItemWashInfoDic[itemId]
    if not washInfos or #washInfos == 0 then
        return _retAttrDic
    end

    -- Iterate all wash lines
    for i = 1, #washInfos do
        local washLine = washInfos[i]
        if washLine then
            local index = washLine.Index or 0
            local poolId = washLine.PoolID or INVALID_POOL_ID
            local percent = washLine.Percent or 0

            -- Parse attribute pool info
            local _poolInfo = Utils.ParsePoolAttribute(poolId)
            if _poolInfo and _poolInfo.minVal and _poolInfo.maxVal then
                local _value = math.floor((_poolInfo.maxVal - _poolInfo.minVal) * (percent / 10000) + _poolInfo.minVal)

                local _data = {
                    AttrID  = _poolInfo.attrId,
                    Value   = _value,
                    Percent = percent
                }

                if not _retAttrDic:ContainsKey(index) then
                    _retAttrDic:Add(index, _data)
                end
            end
        end
    end

    return _retAttrDic
end


return MailSystem
