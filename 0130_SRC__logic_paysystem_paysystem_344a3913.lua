------------------------------------------------
-- Author:
-- Date: 2020-01-02
-- File: PaySystem.lua
-- Module: PaySystem
-- Description: Recharge System
------------------------------------------------
local SDKCacheData = CS.Thousandto.CoreSDK.SDKCacheData
local L_PayData = require("Logic.PaySystem.PayData")
local L_ServerData = require("Logic.PaySystem.ServerData")
local RuntimePlatform = CS.UnityEngine.RuntimePlatform
local L_UnityUtils = require("Common.CustomLib.Utility.UnityUtils");

-- The path to save the recharge data
local L_JSON_SAVE_PATH = string.format("%s/PayJson.txt",PathUtils.GetWritePath("../"))

local PaySystem = {
    -- Recharged amount
    RechargeNum = 0,
    -- The real amount of recharge
    RechargeRealMoney = 0,
    -- Recharge data, Id, Data
    PayDataIdDict = nil,
    -- Recharge data, rechargeType, List<Data>
    PayDataTypeDict = nil,
    -- Function time remaining
    SubTypeTimeDict = nil,
    -- Have you set the red dot
    HasSetRedPoint = false,
    -- Current platform type
    CurPlatform = nil,
    -- The MD5 value of this recharge data is used to verify data with the server
    Md5 = "",
    -- Channel configuration parameter table
    SdkPlatCfg = nil,
    CacheMoneySign = nil,
    TempPayJson = nil,
}

function PaySystem:Initialize(clearLoginData)
    if clearLoginData then
        self.SubTypeTimeDict = Dictionary:New()
        self.PayDataIdDict = Dictionary:New()
        self.PayDataTypeDict = Dictionary:New()
        -- The recharge list is downloaded successfully, refresh the data
        self.CurPlatform = LogicAdaptor.GetRuntimePlatform()
        local _fgi = GameCenter.SDKSystem.LocalFGI
        self.SdkPlatCfg = DataConfig.DataSdkplatform[_fgi]
    end
end

function PaySystem:UnInitialize(clearLoginData)
    if clearLoginData then
    end
end

-- Download the data of the recharge list
function PaySystem:DownLoadPayList()
    if File.Exists(L_JSON_SAVE_PATH) then
        self.Md5 = string.upper(MD5Utils.MD5String(File.ReadAllText(L_JSON_SAVE_PATH)))
    end
    local _msg = ReqMsg.MSG_Recharge.ReqCheckRechargeMd5:New()
    _msg.md5 = self.Md5
    _msg:Send()
end


-- A set of data obtained by the rechargeType field of the configuration table
function PaySystem:GetPayDataByRechargeType(rechargeType)
    local _rechargeType = tonumber(rechargeType)
    local _payDataList = nil
    if self.PayDataTypeDict:ContainsKey(_rechargeType) then
        _payDataList = self.PayDataTypeDict[_rechargeType]
    end
    return _payDataList
end

-- Configure table id field
function PaySystem:GetPayDataById(cfgId)
    local _cfgId = tonumber(cfgId)
    local _payData = nil
    if self.PayDataIdDict:ContainsKey(_cfgId) then
        _payData = self.PayDataIdDict[_cfgId]
    end
    return _payData
end

-- Configure table rechargeType, subType fields
function PaySystem:GetPayDataByType(rechargeType, subType)
    -- 1. Fetch out the corresponding List data according to the rechargeType
    local _rechargeType = tonumber(rechargeType)
    local _typeDataList = nil
    if self.PayDataTypeDict:ContainsKey(_rechargeType) then
        _typeDataList = self.PayDataTypeDict[_rechargeType]
    end
    -- 2. Fetch the corresponding List data according to the subType
    local _payDataList = List:New()
    if _typeDataList ~= nil and #_typeDataList > 0 then
        for i = 1, #_typeDataList do
            if _typeDataList[i].ServerCfgData.RechargeSubType == subType then
                _payDataList:Add(_typeDataList[i])
            end
        end
    end
    _payDataList:Sort(
        function(x, y)
            return x.ServerCfgData.Money < y.ServerCfgData.Money
        end
    )
    return _payDataList
end

-- Recharge directly based on the ID of the configuration table
function PaySystem:PayByCfgId(cfgId)
    
    local platform = "android";
    if (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer) then
        platform = "ios";
    end

    if self.PayDataIdDict:Count() > 0 and self.PayDataIdDict:ContainsKey(cfgId) then

        local _msg = ReqMsg.MSG_Recharge.ReqCheckGoodsIsCanbuy:New()
        _msg.id = cfgId
        _msg.moneyType = platform
        _msg:Send()
        -- Debug.LogError(string.format("Current recharge configuration table ID %s", cfgId))
        GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_LOCK_OPEN);

        -- if L_UnityUtils.UNITY_EDITOR() then
        --     local _payData = self.PayDataIdDict[cfgId]
        -- --Send the recharge gm command directly in editor mode
        --     local req ={}
        --     req.chattype = 0
        --     req.recRoleId = 0
        --     req.condition = string.format("&rechargeid %d", _payData.ServerCfgData.Id)
        --     req.chatchannel = 0
        --     req.voiceLen = 0
        --     GameCenter.Network.Send("MSG_Chat.ChatReqCS",req)
        --     -- Custom payment


        --     local _msg = ReqMsg.MSG_Recharge.ReqCheckGoodsIsCanbuy:New()
        --     _msg.id = cfgId
        --     _msg.moneyType = platform
        --     _msg:Send()
        -- Debug.LogError(string.format("Current recharge configuration table ID %s", cfgId))
        --     GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_LOCK_OPEN);


        -- else
        --     local _msg = ReqMsg.MSG_Recharge.ReqCheckGoodsIsCanbuy:New()
        --     _msg.id = cfgId
        --     _msg.moneyType = self.SdkPlatCfg.MoneyCode
        --     _msg:Send()
        -- Debug.LogError(string.format("Current recharge configuration table ID %s", cfgId))
        --     GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_LOCK_OPEN);
        -- end
    else
        Debug.LogError(string.format("The current %s ID cannot be found and recharge cannot be performed!",cfgId))
        Utils.ShowPromptByEnum("C_PAY_ID_NOT_FIND", cfgId)
    end
end

-- rechargeType 3: Weekly Card 4: Monthly Card 5: Lifetime Card
function PaySystem:PayByCardType(rechargeType)
    -- There is only one data here
    local _payDataList = nil
    local _cardData = nil
    if self.PayDataTypeDict:ContainsKey(rechargeType) then
        _payDataList = self.PayDataTypeDict[rechargeType]
        if _payDataList ~= nil and _payDataList:Count() > 0 then
            _cardData = _payDataList[1]
        end
    end
    if _cardData ~= nil then
        -- Request the server to see if you can recharge. The server can recharge before calling the SDK to deduct the money.
        self:PayByCfgId(_cardData.ServerCfgData.CfgId)
    else
        Debug.LogError("PayByCardType _cardData is nil!")
    end
end

-- Get the currency quantity based on the recharge id
function PaySystem:GetMoneyCountById(cfgId)
    if self.PayDataIdDict:ContainsKey(cfgId) then
        local _data = self.PayDataIdDict[cfgId]
        if _data ~= nil then
            return _data.ServerCfgData.Money
        end
    end
    return 0
end

-- The total value of the player's current recharge
function PaySystem:ResRechargeTotalValue(msg)
    -- The total number of recharged ingots for the player's current account
    GameCenter.PaySystem.RechargeNum = msg.goldTotal
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_PAY_DATA)
end

-- How much has it been recharged
function PaySystem:ResVipRechageMoney(rechargeMoney)
    self.RechargeRealMoney = rechargeMoney
end

-- Return the recharge data
function PaySystem:ResRechargeData(msg)
    if msg ~= nil and msg.items ~= nil then
        local _dataList = msg.items
        local _typeTimeList = msg.typeTime
        local _serverTime = GameCenter.HeartSystem.ServerTime
        if _typeTimeList ~= nil then
            for i = 1, #_typeTimeList do
                local _subType = _typeTimeList[i].subtype % 10000
                local _remiantime = _typeTimeList[i].remiantime
                if not self.SubTypeTimeDict:ContainsKey(_subType) then
                    self.SubTypeTimeDict:Add(_subType, _remiantime)
                else
                    self.SubTypeTimeDict[_subType] = _remiantime
                end
                if _subType == PaySubType.Novice then
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PayNewbie,  _serverTime < _remiantime)
                elseif _subType == PaySubType.Day then
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PayDay,  _serverTime < _remiantime)
                elseif _subType == PaySubType.Week then
                    GameCenter.MainFunctionSystem:SetFunctionVisible(FunctionStartIdCode.PayWeek,  _serverTime < _remiantime)
                end
            end
        end
        for i = 1, #_dataList do
            -- Product ID, here is cfg.id
            local _cfgId = _dataList[i].id
            -- Number of recharges
            local _num = _dataList[i].count
            -- Number of updates
            if self.PayDataIdDict:ContainsKey(_cfgId) then
                self.PayDataIdDict[_cfgId]:UpdateNum(_num)
            end
            local _keys = self.PayDataTypeDict:GetKeys()
            if _keys ~= nil then
                for k = 1, #_keys do
                    local _rechargeType = _keys[k]
                    local _typeDataList = self.PayDataTypeDict[_rechargeType]
                    if _typeDataList ~= nil then
                        for j = 1, #_typeDataList do
                            if _typeDataList[j].ServerCfgData.CfgId == _cfgId then
                                _typeDataList[j]:UpdateNum(_num)
                                break
                            end
                        end
                    end
                end
            end
        end
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_PAY_DATA)
    end
end

-- Return if the client requests the product to be purchased
function PaySystem:ResCheckGoodsResult(msg)
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
    -- 0 Cannot be purchased, 1 can be purchased
    local _result = msg.result
    local _payId = msg.id
    local _orderInfo = msg.orderInfo
    Debug.LogError(string.format("ResCheckGoodsResult result = %s, id = %s, _orderInfo = %s", _result, _payId, _orderInfo))
    
    if _result == 1 then
        local _orderData = Json.decode(_orderInfo)
        local _order = _orderData.data
        local serverId = GosuSDK.GetLocalValue("saveEnterServerId")
        local userName = GosuSDK.GetLocalValue("saveUserSdkId")
        local playerId = GosuSDK.GetLocalValue("saveRoleId")
        if _order ~= nil and _order ~= "" then
            
            if L_UnityUtils.UNITY_EDITOR() then
                print("============== editor mode, not call sdk")
                print("Product ID:", _order.productId)
                print("Order No:", _order.order_no)
                print("Amount:", _order.amount)
                print("Server ID:", serverId)
                print("User Name:", userName)
                print("Player ID:", playerId)
                print("Currency Unit:", _order.currencyUnit)
                print("Product Name:", _order.productName)

            else
                local extraInfo = string.format("%s|%s", _order.order_no, _orderData.goodsId)
                local isIOS = (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer)
                
                -- call sdk
                -- string productId, string orderId, string orderInfo, string amount, string serverId, string userName, string playerId, string extraInfo
                -- Sửa lại theo sdk mới
                if isIOS then
                    GosuSDK.CallCSharpMethod("PaymentIAP", _order.productId, _order.order_no, '', _order.amount, serverId, userName, playerId, extraInfo, _order.currencyUnit,  _order.productName)
                else
                    GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "PaymentIAP", _order.productId, _order.productName, _order.currencyUnit, _order.order_no, _order.amount, serverId, playerId, extraInfo)
                end
            end
        else
            Utils.ShowPromptByEnum("Pay_CAN_NOT_BUY_TIPS", _payId)
        end


        -- //////////////////////////////////// OLD CODE
        -- if self.PayDataIdDict:Count() > 0 and self.PayDataIdDict:ContainsKey(_payId) then
        --     local _sData = self.PayDataIdDict[_payId].ServerCfgData
        -- -- Here is a payment request to the SDK, and the payment ID recognized by the SDK needs to be passed in.
        --     local _itemId        = _sData.Id
        --     local _itemName      = _sData.Desc
        --     local _price         = _sData.SDKPrice
        --     local _rechargeType      = _sData.RechargeType
        --     local _goodsDealType = _sData.GoodsDealType
        --     local _payNotifyUrl = GameCenter.ServerListSystem.LastEnterServer.PayCallURL
        --     local _orderData = Json.decode(_orderInfo)
        -- --1 is the order successfully
        --     if _orderData.state == 1 then
        --         local _order = _orderData.data
        -- --The unique order number generated by U8Server requires a return SDK
        --         local _orderNo = _order.order_no
        -- --Extended data of channel SDK payment, return to the SDK
        --         local _extension = _order.extension
        --         local _buyNum = 1
        -- Debug.LogError(string.format("The parameters passed by the current call to SDK payment _itemId = %s, _itemName = %s, _price = %s, _goodsDealType = %s, _payNotifyUrl = %s, _rechargeType = %s, _extension = %s, _cfgId = %s, _orderNo = %s", _itemId, _itemName, _price, _goodsDealType, _payNotifyUrl, _rechargeType, _extension, _payId, _orderNo))
        --         GameCenter.SDKSystem:Pay( tostring(_itemId), tostring(_itemName), _buyNum, tonumber(_price), tostring(_goodsDealType), tostring(_payNotifyUrl), tostring(_rechargeType), _extension, tonumber(_payId), tostring(_orderNo))
        --     else
        -- --Earning failed
        --         Utils.ShowPromptByEnum("C_PAY_ORDER_CREATE_FAIL")
        --     end
        -- end
        -- //////////////////////////////////// OLD CODE
    else
        Utils.ShowPromptByEnum("Pay_CAN_NOT_BUY_TIPS", _payId)
    end
end

-- The server issues all recharged products
function PaySystem:ResRechargeItems(msg)
    local _payJson = msg.rechargeItemJson
    if msg.md5 ~= nil or msg.md5 ~= "" then
        -- Determine whether the recharged string has been stored in the memory, and MD5 has changed, so if you don’t change it, don’t touch the data.
        if self.TempPayJson == nil or msg.md5 ~= self.MD5 then
            -- Read local data when the data is empty
            if _payJson == nil or _payJson == "" then
                if File.Exists(L_JSON_SAVE_PATH) then
                    _payJson = File.ReadAllText(L_JSON_SAVE_PATH)
                    self.TempPayJson = _payJson
                    self.MD5 = string.upper(MD5Utils.MD5String(_payJson))
                    if msg.md5 ~= self.MD5 then
                        Debug.LogError("MD5 does not match, and there is an exception in the recharge data.."..msg.md5)
                    end
                else
                    Debug.LogError("Oh, the server did not send recharge data... there was no local recharge data...")
                end
            -- If the recharge data is not empty, save it locally
            else
                -- Here rechargeItemJson is not empty, it may be the first time it is issued and the data has changed.
                if not File.Exists(L_JSON_SAVE_PATH) then
                    File.Create(L_JSON_SAVE_PATH):Dispose()
                else
                    -- If there is a file, then the data will definitely change.
                    Debug.LogError("Recharge MD5 has changed, latest data...MD5 = "..msg.md5..", json = ".._payJson)
                end
                File.WriteAllText(L_JSON_SAVE_PATH, _payJson);
            end
        else
            _payJson = self.TempPayJson
        end
    else
        Debug.LogError("The json data of server recharge is abnormal")
    end
    if _payJson ~= nil and _payJson ~= "" then
        local _payDataTab = Json.decode(_payJson)
        local _payDataList = List:New(_payDataTab)
        for _key, _data in pairs(_payDataList) do
            local _cfgId = tonumber(_data.goods_system_cfg_id)
            -- 1. Store data according to the configuration table ID
            local _sData = L_ServerData:New(_data)
            local _payData = self.PayDataIdDict[_cfgId]
            if _payData ~= nil then
                _payData:RefeshData(_sData)
            else
                _payData = L_PayData:New(_sData)
                self.PayDataIdDict:Add(_cfgId, _payData)
            end
            -- 2. Store data according to RechargeType
            local _rechargeType = _sData.RechargeType
            if not self.PayDataTypeDict:ContainsKey(_rechargeType) then
                local _dataList = List:New()
                _dataList:Add(_payData)
                self.PayDataTypeDict:Add(_rechargeType, _dataList)
            else
                local _dataList = self.PayDataTypeDict[_rechargeType]
                local _hasSameData = false
                local _curCfgId = _payData.ServerCfgData.CfgId
                for i = 1, #_dataList do
                    if _curCfgId == _dataList[i].ServerCfgData.CfgId then
                        self.PayDataTypeDict[_rechargeType][i] = _payData
                        _hasSameData = true
                        break
                    end
                end
                if not _hasSameData then
                    self.PayDataTypeDict[_rechargeType]:Add(_payData)
                end
            end
        end
        -- Process what needs to be processed when going online
        self:HandleOnline()
        GameCenter.PushFixEvent(LogicLuaEventDefine.EID_EVENT_REFESH_PAY_DATA)
        -- Refresh the data of the monthly card weekly card
        GameCenter.PushFixEvent(LogicEventDefine.EID_EVENT_WELFARE_CARD_REFRESH, nil)
    else
        Debug.LogError("The server did not issue recharged json data!")
    end
    local _sing = self:GeMoneySignByCfg()
end

-- Process what needs to be processed when going online
function PaySystem:HandleOnline()
    -- When online, set the red dots for all recharge functions, click the interface and turn off the red dots.
    if not self.HasSetRedPoint then
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.Pay, true)
        GameCenter.MainFunctionSystem:SetFunctionEffect(FunctionStartIdCode.Pay, true)
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PayBase, true)
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PayNewbie, true)
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PayWeek, true)
        GameCenter.MainFunctionSystem:SetAlertFlag(FunctionStartIdCode.PayDay, true)
        self.HasSetRedPoint = true
    end
    local _localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer()
    -- Here is a judgment to prevent requesting data before entering the game server. If the localplayer has data, it must have entered the scene.
    if _localPlayer ~= nil then
        -- Request the recharge data of the game server
        local _reqMsg = ReqMsg.MSG_Recharge.ReqRechargeData:New()
        _reqMsg:Send()
    end
end

-- Get the current currency symbol according to the configuration table
function PaySystem:GeMoneySignByCfg()
    if self.CacheMoneySign == nil then
        local _region = GameCenter.LoginSystem.Region
        if _region ~= nil and _region ~= "" and _region ~= 0 then
            --tw
            local _chanel = self.SdkPlatCfg.Chanel
            DataConfig.DataSdkplatform:ForeachCanBreak(
                function(_id, _cfg)
                    if _cfg.Chanel == _chanel and _cfg.Region == _region then
                        self.CacheMoneySign = _cfg.MoneySign
                        return true
                    end
                end
            )
        else
            if self.SdkPlatCfg ~= nil then
                if self.SdkPlatCfg.Chanel == "TW" then
                    self.CacheMoneySign = "$"
                else
                    self.CacheMoneySign = self.SdkPlatCfg.MoneySign
                end
            end
        end
    end
    return self.CacheMoneySign
end

return PaySystem