------------------------------------------------
-- author:
-- Date: 2020-01-13
-- File: UIMailForm.lua
-- Module: UIMailForm
-- Description: Email
------------------------------------------------
local L_UrlTips = require "UI.Forms.UIMailForm.MailUrlTips"
local UIMailForm = {
    AnimModule = nil, -- Animation
    GobjListRoot = nil, -- Mailing List Root
    GobjInfoRoot = nil, -- Email content information Root
    TfListRoot = nil, -- Mailing List Root
    TfInfoRoot = nil, -- Email content information Root
    GobjNoMail = nil, -- No email prompt
    -- TexNoMail = nil, -- Email prompt Tex
    IsSuccGetAll = false, -- Is it successful to receive one click
    RewardUIItems = List:New(), -- Attachment list
    MailItems = List:New(), -- Mailing List
    curSelectItem = nil, -- Currently selected to item

    TxtTitle = nil, -- title
    TxtContent = nil, -- content
    TxtName = nil, -- Sender
    TxtTime = nil, -- time
    GobjRewardList = nil, -- Reward the parent node
    TfGridRewards = nil, -- Reward Grid
    BaseUIItem = nil, -- Reward uiitem
    GobjBaseUIItem = nil, -- Reward uiitem
    BtnGet = nil, -- receive
    BtnDelete = nil, -- delete
    GobjBtnGet = nil, -- receive
    GobjBtnDelete = nil, -- delete

    TfUIScroll = nil, -- Scrolling window
    TfGridListPanel = nil, -- Grid
    BtnRecAll = nil, -- One click to collect
    BtnDelAll = nil, -- One click to delete
    GobjBaseItem = nil, -- Email item
    ContentBtn1 = nil,
    ContentBtn2 = nil,
    UrlTips = nil,
}

function UIMailForm:OnRegisterEvents()
    self:RegisterEvent(UIEventDefine.UIMailForm_OPEN, self.OnOpen)
    self:RegisterEvent(UIEventDefine.UIMailForm_CLOSE, self.OnClose)
    self:RegisterEvent(UILuaEventDefine.UIMailRefreshUI, self.Refresh)
    self:RegisterEvent(UILuaEventDefine.UIMailRefreshChangeMail, self.RefreshChangeMail)
end

function UIMailForm:OnFirstShow()
    self:FindAllComponents();
    self:RegUICallback();
	self.CSForm:AddAlphaScaleAnimation(nil, 0, 1, 1.05, 1.05, 1, 1, 0.3, true, false)
end

function UIMailForm:FindAllComponents()
    local _trans = self.Trans
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Left/MailListRoot/BtnRecAll/Txt"), "OnekeyGet")
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Left/MailListRoot/BtnDelAll/Txt"), "OnekeyDelete")
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Right/MailInfoRoot/TxtSender"), "Sender")
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Right/MailInfoRoot/Rewards/RewardList/TxtItemTitle"), "AccessoryList")
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Right/MailInfoRoot/BtnGet/Txt"), "UI_MAIL_RECIEVE")
    -- UIUtils.SetTextByEnum(UIUtils.FindLabel(_trans, "Right/MailInfoRoot/BtnDelete/Txt"), "Delete")

    self.GobjNoMail = UIUtils.FindGo(_trans, "Center/NoMail")
    -- self.TexNoMail = UIUtils.FindTex(_trans, "Center/NoMail/TexBg")
    self.GobjListRoot = UIUtils.FindGo(_trans, "Left/MailListRoot")
    self.TfListRoot = self.GobjListRoot.transform;
    self.GobjInfoRoot = UIUtils.FindGo(_trans, "Right/MailInfoRoot")
    self.TfInfoRoot = self.GobjInfoRoot.transform;

    self.TxtTitle = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/TxtTitle")

    self.GobjRewardList = UIUtils.FindGo(_trans, "Right/MailInfoRoot/Rewards/RewardList")
    self.TfGridRewards = UIUtils.FindTrans(_trans, "Right/MailInfoRoot/Rewards/RewardList/Grid")
    self.BaseUIItem = UILuaItem:New(UIUtils.FindTrans(_trans, "Right/MailInfoRoot/Rewards/RewardList/Grid/UIItem"))
    self.GobjBaseUIItem = self.BaseUIItem.RootGO;
    self.RewardUIItems:Add(self.BaseUIItem);
    self.BtnGet = UIUtils.FindBtn(_trans, "Right/MailInfoRoot/BtnGet")
    self.BtnDelete = UIUtils.FindBtn(_trans, "Right/MailInfoRoot/BtnDelete")
    self.GobjBtnGet = self.BtnGet.gameObject;
    self.GobjBtnDelete = self.BtnDelete.gameObject;

    self.TfUIScroll = UIUtils.FindTrans(_trans, "Left/MailListRoot/ListPanel");
    self.TfGridListPanel = UIUtils.FindTrans(_trans, "Left/MailListRoot/ListPanel/Grid")
    self.BtnRecAll = UIUtils.FindBtn(_trans, "Left/MailListRoot/BtnRecAll")
    self.BtnDelAll = UIUtils.FindBtn(_trans, "Left/MailListRoot/BtnDelAll")
    self.GobjBaseItem = UIUtils.FindGo(_trans, "Left/MailListRoot/ListPanel/Grid/Item")
    self.MailItems:Add(UIMailForm:CreatCell(self.GobjBaseItem.transform));

    self.GobjRewards = UIUtils.FindGo(_trans, "Right/MailInfoRoot/Rewards")
    self.TxtContent1 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/Rewards/ScrollView/TxtContent")
    self.TxtTime1 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/Rewards/TxtSender/TxtTime")
    self.TxtName1 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/Rewards/TxtSender/TxtName")
    self.ContentBtn1 = UIUtils.FindBtn(_trans, "Right/MailInfoRoot/Rewards/ScrollView/TxtContent")

    self.GobjNoRewards = UIUtils.FindGo(_trans, "Right/MailInfoRoot/NoRewards")
    self.TxtContent2 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/NoRewards/ScrollView/TxtContent")
    self.TxtTime2 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/NoRewards/TxtSender/TxtTime")
    self.TxtName2 = UIUtils.FindLabel(_trans, "Right/MailInfoRoot/NoRewards/TxtSender/TxtName")
    self.ContentBtn2 = UIUtils.FindBtn(_trans, "Right/MailInfoRoot/NoRewards/ScrollView/TxtContent")

    --Url
    self.UrlTips = L_UrlTips:New(UIUtils.FindTrans(_trans, "Right/UrlTips"))
end

function UIMailForm:RegUICallback()
    UIUtils.AddBtnEvent(self.BtnGet, self.OnClickGetBtn, self)
    UIUtils.AddBtnEvent(self.BtnDelete, self.OnClickDelateBtn, self)
    UIUtils.AddBtnEvent(self.BtnRecAll, self.OnClickOneGetBtn, self)
    UIUtils.AddBtnEvent(self.BtnDelAll, self.OnClickOneDeleteBtn, self)
    UIUtils.AddBtnEvent(self.ContentBtn1, self.OnClickContentBtn, self)
    UIUtils.AddBtnEvent(self.ContentBtn2, self.OnClickContentBtn, self)
end

function UIMailForm:OnClickGetBtn()
    GameCenter.MailSystem:ReqGetRewardByCurRead()
end

function UIMailForm:OnClickDelateBtn()
    GameCenter.MailSystem:ReqDeleteByCurRead()
end

function UIMailForm:OnClickOneGetBtn()
    self.IsSuccGetAll = GameCenter.MailSystem:ReqGetAllReward()
end

function UIMailForm:OnClickOneDeleteBtn()
    Utils.ShowMsgBox(function(code)
        if code == MsgBoxResultCode.Button2 then
            GameCenter.MailSystem:ReqDeleteAllMail()
        end
    end, "C_SHANCHUYOUJIAN_ASK")
end

function UIMailForm:OnClickReadBtn(item)
    GameCenter.MailSystem.CurReadMailId = item.MailId;
    if self.curSelectItem then
        self:SetItemState(self.curSelectItem)
    end
    self.curSelectItem = item;
    if not GameCenter.MailSystem.DetailInfos[item.MailId] then
        GameCenter.MailSystem:ReqReadSingleMail(GameCenter.MailSystem.CurReadMailId);
    else
        self:RefreshChangeMail();
    end
end

function UIMailForm:OnClickContentBtn()
    if self.TxtContent2 ~= nil then
        local _url = self.TxtContent2:GetUrlAtPosition(CS.UICamera.lastWorldPosition)
        if _url ~= nil and _url ~= "" then
            self.UrlTips:Open(_url, CS.UICamera.lastWorldPosition)
        end
    end
end

function UIMailForm:OnShowBefore()
    if GameCenter.MailSystem.CurReadMailId == -1 then
        local _allMails = GameCenter.MailSystem.AllMails;
        local _keys = _allMails:GetKeys();
        if #_keys > 0 then
            GameCenter.MailSystem.CurReadMailId = _allMails[_keys[1]].mailId;
        end
    end
end

function UIMailForm:OnShowAfter()
    self:Refresh();
    self.UrlTips:Close()
    KeyCodeSystem.IsOpenEnter = true
end

function UIMailForm:RefreshChangeMail()
    if self.curSelectItem then
        self:SetItemState(self.curSelectItem)
    end
    self:RefreshRightInfo()
end

function UIMailForm:SetItemState(mailItem)
    local _mailMsgData = GameCenter.MailSystem.AllMails[mailItem.MailId];
    mailItem.GobjSelect:SetActive(_mailMsgData.mailId == GameCenter.MailSystem.CurReadMailId);
    mailItem.GobjUnSelect:SetActive(_mailMsgData.mailId ~= GameCenter.MailSystem.CurReadMailId);
    mailItem.GobjAnnex:SetActive(_mailMsgData.hasAttachment and not _mailMsgData.isAttachReceived);
    -- mailItem.GobjAnnex2:SetActive(_mailMsgData.hasAttachment and not _mailMsgData.isAttachReceived);
    -- mailItem.GobjReceive:SetActive(_mailMsgData.hasAttachment and _mailMsgData.isAttachReceived);
    mailItem.GobjOpen:SetActive(_mailMsgData.isRead);
    mailItem.GobjClose:SetActive(not _mailMsgData.isRead);
end

function UIMailForm:Refresh()
    local _allMails = GameCenter.MailSystem.AllMails;
    local _keys = _allMails:GetKeys();
    local _count = #_keys;

    self:SetState(_count > 0)
    if _count > 0 then
        if not GameCenter.MailSystem.DetailInfos[GameCenter.MailSystem.CurReadMailId] then
            GameCenter.MailSystem:ReqReadSingleMail(GameCenter.MailSystem.CurReadMailId);
        end
        -- Refresh the left list
        for i = 1, _count do
            local _mailMsgData = _allMails[_keys[i]];
            if i > #(self.MailItems) then
                self.MailItems:Add(self:CreatCell(UnityUtils.Clone(self.GobjBaseItem, self.TfGridListPanel).transform));
            end
            local _mailItem = self.MailItems[i];
            _mailItem.Gobj:SetActive(true);
            UIUtils.SetTextByString(_mailItem.TxtTitle, _mailMsgData.mailTitle)
            UIUtils.SetTextByString(_mailItem.TxtTime, os.date("%Y/%m/%d  %H:%M", math.floor(_mailMsgData.receiveTime / 1000) + Time.GetZoneOffset()))
            UIUtils.SetTextByString(_mailItem.TxtTitle2, _mailMsgData.mailTitle)
            UIUtils.SetTextByString(_mailItem.TxtTime2, os.date("%Y/%m/%d  %H:%M", math.floor(_mailMsgData.receiveTime / 1000) + Time.GetZoneOffset()))
            _mailItem.MailId = _mailMsgData.mailId;
            if _mailMsgData.mailId == GameCenter.MailSystem.CurReadMailId then
                self.curSelectItem = _mailItem;
            end
            self:SetItemState(_mailItem)
        end

        for i = _count + 1, #self.MailItems do
            self.MailItems[i].Gobj:SetActive(false);
        end

        -- Refresh the data on the right
        self:RefreshRightInfo()
        if self.IsSuccGetAll then
            self:OnClickOneDeleteBtn();
        end
    end

    UnityUtils.GridResetPosition(self.TfGridListPanel);
    UnityUtils.ScrollResetPosition(self.TfUIScroll);
    self.IsSuccGetAll = false;
end

function UIMailForm:CreatCell(trans)
    local _m = {
        Gobj = trans.gameObject,
        Btn = UIUtils.FindBtn(trans, "SprBg"),

        GobjSelect = UIUtils.FindGo(trans, "SprSelect"),
        GobjAnnex = UIUtils.FindGo(trans, "SprAnnex"),
        TxtTitle = UIUtils.FindLabel(trans, "SprSelect/TxtTitle"),
        TxtTime = UIUtils.FindLabel(trans, "SprSelect/TxtTime"),
        -- GobjReceive = UIUtils.FindGo(trans, "SprReceive"),
        GobjOpen = UIUtils.FindGo(trans, "SprOpen"),
        GobjClose = UIUtils.FindGo(trans, "SprClose"),
        GobjUnSelect = UIUtils.FindGo(trans, "GobjUnSelect"),
        -- GobjAnnex2 = UIUtils.FindGo(trans, "GobjUnSelect/SprAnnex"),
        TxtTitle2 = UIUtils.FindLabel(trans, "GobjUnSelect/TxtTitle"),
        TxtTime2 = UIUtils.FindLabel(trans, "GobjUnSelect/TxtTime"),
        MailId = -1
    }

    UIUtils.AddBtnEvent(_m.Btn, self.OnClickReadBtn, self, _m)
    return _m;
end

-- Refresh the data on the right
function UIMailForm:RefreshRightInfo()
    local _selectId = GameCenter.MailSystem.CurReadMailId;
    if _selectId ~= -1 then
        local _detailInfo = GameCenter.MailSystem.DetailInfos[_selectId];
        local _mailInfo = GameCenter.MailSystem.AllMails[_selectId];
        if _detailInfo then
            self.GobjInfoRoot:SetActive(true);
            UIUtils.SetTextByString(self.TxtTitle, _detailInfo.mailTitle)
            UIUtils.SetTextByString(self.TxtName1, _detailInfo.sender)
            UIUtils.SetTextByString(self.TxtName2, _detailInfo.sender)
            UIUtils.SetTextByString(self.TxtTime1, os.date("%Y/%m/%d  %H:%M", math.floor(_mailInfo.receiveTime / 1000) + Time.GetZoneOffset()))
            UIUtils.SetTextByString(self.TxtTime2, os.date("%Y/%m/%d  %H:%M", math.floor(_mailInfo.receiveTime / 1000) + Time.GetZoneOffset()))
            UIUtils.SetTextByString(self.TxtContent1, _detailInfo.mailContent)
            UIUtils.SetTextByString(self.TxtContent2, _detailInfo.mailContent)
            self.GobjBtnGet:SetActive(_detailInfo.hasAttachment and not _detailInfo.isAttachReceived);
            self.GobjBtnDelete:SetActive(not _detailInfo.hasAttachment or (_detailInfo.hasAttachment and _detailInfo.isAttachReceived));
            self.GobjRewardList:SetActive(_detailInfo.hasAttachment);
            self.GobjRewards:SetActive(_detailInfo.hasAttachment);
            self.GobjNoRewards:SetActive(not _detailInfo.hasAttachment);

            if _detailInfo.hasAttachment then
                local _childCount = self.TfGridRewards.childCount;
                for i = 1, _childCount do
                    self.TfGridRewards:GetChild(i - 1).gameObject:SetActive(false);
                end
                local _itemList = _detailInfo.itemList;
                for i = 1, #_itemList do
                    local _reward = _itemList[i]
                    if i > _childCount then
                        self.RewardUIItems:Add(UILuaItem:New(UnityUtils.Clone(self.GobjBaseUIItem, self.TfGridRewards).transform));
                    end
                    local _UIItem = self.RewardUIItems[i];
                    _UIItem.RootGO:SetActive(true);
                    -- _UIItem:InItWithCfgid(_reward.itemModelId, _reward.num, _reward.isbind, false);

                    -- local itemInst = self:BuildItemInstByMailDetail(_detailInfo, _reward)




                    local itemInst = self:BuildItemInstByMailDetail(_detailInfo, _reward, i)

                    Debug.Log("itemInstitemInstitemInstitemInstitemInstitemInst=============", Inspect(itemInst))

                    if itemInst then
                        _UIItem:InitWithItemData(
                            itemInst,
                            _reward.num,
                            true,
                            false,
                            ItemTipsLocation.Mail,
                            {
                                itemId = itemInst.ItemID,
                                from = "Mail"
                            }
                        )
                    else
                        _UIItem:InItWithCfgid(_reward.itemModelId, _reward.num, _reward.isbind, false)
                    end

                    _UIItem.Location = ItemTipsLocation.Mail -- [Gosu] set lại để phân biệt là item trong mail

                    UIUtils.FindGo(_UIItem.RootTrans, "SprGeted"):SetActive(_detailInfo.isAttachReceived);
                    UIUtils.SetTextByNumber(UIUtils.FindLabel(_UIItem.RootTrans, "Num"), _reward.num, true, 4)
                end
            end
            UnityUtils.GridResetPosition(self.TfGridRewards);
            return;
        else
            self.GobjInfoRoot:SetActive(false);
        end
    else
        self.GobjInfoRoot:SetActive(false);
    end
end

function UIMailForm:BuildItemInstByMailDetail(mailDetail, reward, index)
    if not mailDetail or not mailDetail.equipListDetail then
        Debug.Log("[Mail] no equipListDetail")
        return nil
    end

    index = index or 1

    local equipWrapper = mailDetail.equipListDetail[index]
    if not equipWrapper then
        Debug.Log("[Mail] equipListDetail empty, index =", index)
        return nil
    end

    local equipDetail = equipWrapper.equip
    if not equipDetail then
        Debug.Log("[Mail] equip detail missing at index =", index)
        return nil
    end

    local buildMsg = {
        itemId      = equipDetail.itemId,
        itemModelId = equipDetail.itemModelId,
        num         = reward.num or 1,
        gridId      = 0,
        isbind      = reward.isbind or false,
        lostTime    = equipDetail.lostTime or 0,

        suitId      = equipDetail.suitId or 0,
        percent     = equipDetail.percent or 0,
    }

    if equipWrapper.strengthInfo then
        buildMsg.strengLv = equipWrapper.strengthInfo.level or 0
    end

    Debug.Log("[Mail] BuildItemMsg =", Inspect(buildMsg))

    local itemInst = LuaItemBase.CreateItemBaseByMsg(buildMsg)
    if not itemInst then
        Debug.Log("[Mail] CreateItemBaseByMsg FAILED")
        return nil
    end

    Debug.Log(string.format(
        "[Mail] Create Item OK cfg=%d itemId=%d streng=%d",
        itemInst.CfgID,
        itemInst.ItemID or -1,
        itemInst.StrengthLevel or 0
    ))

    return itemInst
end



function UIMailForm:SetState(isHasMail)
    self.GobjListRoot:SetActive(isHasMail)
    self.GobjInfoRoot:SetActive(isHasMail)
    self.GobjNoMail:SetActive(not isHasMail)
end

function UIMailForm:OnHideAfter()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    GameCenter.MailSystem:SortMailList();
    GameCenter.MailSystem.CurReadMailId = -1;
    KeyCodeSystem.IsOpenEnter = false
end

return UIMailForm
