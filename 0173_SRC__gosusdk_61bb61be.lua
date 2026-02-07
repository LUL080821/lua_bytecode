-- Đóng gói GosuSDK vào bảng
local GosuSDK = {}
local clientId = "6100.bchirgmgtakmvbgjqh"

-- Biến cờ để kiểm tra xem SDK đã được khởi tạo chưa
local isSdkInitialized = false
local sdkBridge = CS.FactorySdkBridge
local UnityEngine = CS.UnityEngine
local Button = CS.UnityEngine.UI.Button
local GameObject = CS.UnityEngine.GameObject
local Debug = CS.UnityEngine.Debug
local LuaManager = CS.GosuLuaManager

local newSdkBridge = CS.UnifiedSdkBridge

-- chỉnh sửa để lấy hàm
local ServerUrlInfo = require("Logic.ServerList.ServerUrlInfo");
local ServerDataInfo = require("Logic.ServerList.ServerDataInfo");
StringDefines = DataConfig.Load("StringDefines")

GosuSDK.CurrentLang = nil

GosuSDK.EmailWhiteLists = nil

GosuSDK.NewMd5 = nil

GosuSDK.LangConst = {
    -- Area robot name
    ["Chief Trial Officer"] = {
        CH = "Chief Trial Officer",
        VIE = "ĸŐŒŐņŗŘņŐőţŌŊŒŉŜŐœņĳ",
        EN = "Chief of Trial",
        JP = "Quan Thí Luyện Thủ Lĩnh"
    },

    ["CHANGE_LANG_ALERT_IOS"] = {
        VIE = "អ្នកត្រូវបិទហ្គេម ហើយបើកឡើងវិញ ដើម្បីប្តូរភាសា",
        EN = "You need to close and reopen the game to change the language.",
        JP = "Bạn cần tắt và mở lại game để đổi ngôn ngữ"
    },

    ["NEED_UPDATE_ALERT"] = {
        -- VIE = "អ្នកត្រូវបិទហ្គេម ហើយបើកឡើងវិញ ដើម្បីប្តូរភាសា",
        EN = "There is a new version available, please restart the game to update.",
        JP = "Có phiên bản mới, vui lòng khởi động lại trò chơi để cập nhật."
    },

    ["NEW_YEAR_EVENT_TEXT"] = {
        VIE = "ŐņŗīĴœņĳ³ ňĻőŊőŌŊōÁŒŗņőŨéŋ¶, ĭņňĺĺĿőħņœŐéĸŒĩņŊĸňįœ¡",
        EN = "Event Rules: Celebrate the New Year by logging into the game every day and receive a huge amount of rewards!",
        JP = "Chi tiết hoạt động: Vui năm mới, đăng nhập game mỗi ngày, nhận ngay phúc lợi lớn!"
    },

    ["FLAG_TEXT"] = {
        VIE = "ŊĸĩįŘŊŗįŘĺŌŨĩņřŎ",
        EN = "Select Flag",
        JP = "Chọn Quốc Kỳ"
    },
    ["GOSU_DELETE_ACCOUNT"] = {
        VIE = "នេះនឹងលុបគណនីរបស់អ្នក និងទិន្នន័យទាំងអស់ដែលពាក់ព័ន្ធ។ អ្នកនឹងបាត់បង់ការចូលប្រើដំណើរការនិងការប្រតិបត្តិទិញទាំងអស់របស់អ្នក។ តើអ្នកច្បាស់ថាចង់បន្តឬទេ",
        EN = "Are you sure you want to delete your account?",
        JP = "Bạn có chắc chắn muốn xoá tài khoản không?"
    },

    ["GOSU_AT_MAINTAIN"] = {
        VIE = "Máy chủ đang bảo trì",
        EN = "Máy chủ đang bảo trì",
        JP = "Máy chủ thử nghiệm sẽ mở vào 10h00 - 03/02/2026"
    },

    ["REMOTE_GEM_TEXT"] = {
        VIE = "Gỡ",
        EN = "Gỡ",
        JP = "Gỡ"
    },

    -- KHẢM TEXT
    ["MOSAIC_GEM_TEXT"] = {
        VIE = "Khảm",
        EN = "Khảm",
        JP = "Khảm"
    },

    -- KHẢM TEXT
    ["MOSAIC_COFIRM_TEXT"] = {
        VIE = "Xác nhận muốn giám định, một vật phẩm chỉ giám định một lần duy nhất",
        EN = "Xác nhận muốn giám định, một vật phẩm chỉ giám định một lần duy nhất",
        JP = "Xác nhận muốn giám định, một vật phẩm chỉ giám định một lần duy nhất"
    },

    -- KHẢM TEXT
    ["MOSAIC_SUCCESS_TEXT"] = {
        VIE = "Giám định thành công",
        EN = "Giám định thành công",
        JP = "Giám định thành công"
    },


    ["APPRAISE_PLACEHOLDER"] = {
        VIE = "Trang bị chưa được GĐ",
        EN = "Trang bị chưa được GĐ",
        JP = "Trang bị chưa được GĐ"
    },

    ["HAS_GEM_ALERT"] = {
        VIE = "Đã để lại %d trang bị đang khảm ngọc, nếu bạn muốn dung luyện thì hãy tháo ngọc trước",
        EN  = "Left %d equipped items with gems",
        JP  = "Đã để lại %d trang bị đang khảm ngọc, nếu bạn muốn dung luyện thì hãy tháo ngọc trước"
    },



}

-- text button lang sau này có thể chỉnh sửa:
GosuSDK.UILangConst = {
    BTN_LANG_EN = "English",
    BTN_LANG_VI = "Tiếng Việt",
    BTN_LANG_KH = "Cambodia",
}


-- phi thăng theo cách mới lấy từ Lua không qua file dịch và call hàm Lua từ C# luôn


-- Lấy dịch text phi thăng từ file Lua
GosuSDK.NameToId = {
    ["Golden Dan"] = 1,
    ["Yuanying"] = 2,
    ["Transforming God"] = 3,
    ["Combination"] = 4,
    ["Mahayana"] = 5,
    ["Earth Immortal"] = 6,
}

GosuSDK.Events = {
    GOSU_LEVEL = "user_lv",
    GOSU_CHECKIN = "user_checkinday_",
    GOSU_VIP = "user_vip",
    GOSU_CREATE_PLAYER = "create_player",
    Done_NRU = "Done_NRU",
    Quanapdau = "Quanapdau",
    GOSU_DELETE_ACCOUNT = "នេះនឹងលុបគណនីរបស់អ្នក និងទិន្នន័យទាំងអស់ដែលពាក់ព័ន្ធ។ អ្នកនឹងបាត់បង់ការចូលប្រើដំណើរការនិងការប្រតិបត្តិទិញទាំងអស់របស់អ្នក។ តើអ្នកច្បាស់ថាចង់បន្តឬទេ",
    GOSU_DELETE_SUCCESS = "ការលុបគណនីបានជោគជ័យ",
    GOSU_DELETE_FAILED = "ការលុបគណនីបានបរាជ័យ",
    GOSU_LIMIT_BUY = "អ្នកអាចទិញបានបន្ទាប់ពី {0} វិនាទី",
    GOSU_AT_ALERT_TEXT = "ដំណាក់កាល AT មិនជំនួយផ្នែកបញ្ចូលទឹកប្រាក់ IAP។ សូមបញ្ចូលទឹកប្រាក់នៅលើគេហទំព័រ ដើម្បីទទួលបានការសំណងទៅលដល់ 200% ពេលហ្គេមបើកចេញជាផ្លូវការ។",
    GOSU_AT_OPTION = "0",
    GOSU_AT_MAINTAIN = "Máy chủ đang bảo trì" ,
    MD5_KEY = "753509031ad2ced8d284f0f20f4277a8",
    STORE_LINK = "https://play.google.com/store/apps/details?id=com.mega.kh.kols",
    SHOW_DELETE_BUTTON = false,
    GOSU_RECENT_SERVER = "recent_server", -- set recent
    GOSU_L_CN_RECENT_SERVER_KEY = "recent_server_key",-- recent tab,
    EID_GOSU_CORE_SET_FLAG = 9012345,
}


-- Bảng chứa các hàm callback
local callbackHandlers = {}

-- Bảng chứa các listener từ file khác
local globalListeners = {}


-- Hàm khởi tạo SDK
function GosuSDK.InitSdk(luaObj, callback)
    if not isSdkInitialized then
        -- Gọi khởi tạo SDK
        if sdkBridge and sdkBridge.CallInitSdkBridge then
            -- sdkBridge.CallInitSdkBridge(luaObj, callback, clientId)
            -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "InitSdkService", luaObj, callback, clientId) -- hàm mới

            GosuSDK.CorrectFuntionIOS("CallInitSdkBridge", luaObj, callback, clientId)

            isSdkInitialized = true
            -- print("GosuSDK: SDK initialized successfully!")
        else
            -- print("Error: sdkBridge.CallInitSdkBridge is nil!")
        end
    else
        -- print("GosuSDK: SDK is already initialized.")
    end
   
    if (SUBMIT_MODE) then
        GosuSDK.Events.SHOW_DELETE_BUTTON = true
    end
end

-- Hàm chỉnh sửa để call sdk cho đúng trên iOS
function GosuSDK.CorrectFuntionIOS(method, luaObj, callback, clientId)
    local isIOS = (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer)

    -- Đây là 2 hàm không cần tham số
    local simpleMethods = {
        CallShowLogin = true,
        CallLogOut = true
    }

    if isIOS then
        -- ---------- iOS ----------
        if method == "CallInitSdkBridge" then
            -- iOS cần đủ tham số
            sdkBridge.CallInitSdkBridge(luaObj, callback, clientId)

        elseif simpleMethods[method] then
            -- iOS: CallShowLogin / CallLogOut (không tham số)
            GosuSDK.CallCSharpMethod(method)

        else
            -- print("[GosuSDK] Unknown iOS method: " .. tostring(method))
        end

    else
        -- ---------- Non-iOS (Android / Editor) ----------
        if method == "CallInitSdkBridge" then
            GosuSDK.CallCSharpMethod(
                "BridgeTrackingFunction",
                "InitSdkService",
                luaObj, callback, clientId
            )

        elseif simpleMethods[method] then
            -- Non-iOS: CallShowLogin / CallLogOut (không tham số)
            if(method == "CallShowLogin") then
                method = "Login"
            end
            if(method == "CallLogOut") then
                method = "Logout"
            end
            GosuSDK.CallCSharpMethod(
                "BridgeTrackingFunction",
                method
            )

        else
            -- print("[GosuSDK] Unknown Non-iOS method: " .. tostring(method))
        end
    end
end




-- Hàm để đăng ký listener từ bên ngoài
function GosuSDK.RegisterListener(eventName, listener)
    if not globalListeners[eventName] then
        globalListeners[eventName] = {}
    end
    table.insert(globalListeners[eventName], listener)
end

-- Hàm để gỡ bỏ listener
function GosuSDK.UnregisterListener(eventName, listener)
    if globalListeners[eventName] then
        for i, l in ipairs(globalListeners[eventName]) do
            if l == listener then
                table.remove(globalListeners[eventName], i)
                break
            end
        end
    end
end

-- Hàm để gọi tất cả listener đã đăng ký cho một sự kiện
function DispatchEvent(eventName, ...)
    if globalListeners[eventName] then
        for _, listener in ipairs(globalListeners[eventName]) do
            -- print("Calling listener for event:", eventName)
            listener(...)
        end
    else
        -- print("No listeners found for event:", eventName)
    end
end

-- Hàm để gọi tất cả listener đã đăng ký cho một sự kiện
function GosuSDK.GoSuDispatchEvent(eventName, ...)
    if globalListeners[eventName] then
        for _, listener in ipairs(globalListeners[eventName]) do
            -- print("Calling listener for event:", eventName)
            listener(...)
        end
    else
        -- print("No listeners found for event:", eventName)
    end
end

LuaManager.SetCallback(function(funcName, jsonData)
    -- print("GosuSDK FuncName: " .. funcName)
    if jsonData then
        -- print("GosuSDK ==== Data: " .. jsonData)
    end

    -- Kiểm tra và gọi hàm xử lý tương ứng
    if callbackHandlers[funcName] then
        -- print("GosuSDK Đang xử lý hàm: " .. funcName)
        callbackHandlers[funcName](jsonData) -- Gọi hàm xử lý
    else
        -- print("GosuSDK Không tìm thấy handler cho: " .. funcName)
    end

    -- Gọi các listener bên ngoài
    DispatchEvent(funcName, jsonData)
    
end)

-- Hàm mô phỏng sự kiện phát ra khi button được click
function GosuSDK.OnButtonClick()
    -- print("Button đã được nhấn! Phát ra sự kiện 'ButtonClick'.")
    -- DispatchEvent("ButtonClick", "{ \"message\": \"Dữ liệu cứng từ sự kiện button click\" }")
end

-- Lấy name của player
function GosuSDK.getNamePlayer()
    
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
    
    if _lp and _lp.Name then
        return _lp.Name
    else
        return "" 
    end
end
-- Lưu giá trị với key tuỳ chỉnh
function GosuSDK.RecordValue(key, value)
    -- PlayerPrefs.SetString(key, value)
    -- PlayerPrefs.Save()

    local current = PlayerPrefs.GetString(key, "")
    if current ~= value then
        PlayerPrefs.SetString(key, value)
        PlayerPrefs.Save()
        -- print("GosuSDK.RecordValue: Updated", key, "=>", value)
    else
        -- print("GosuSDK.RecordValue: No change for", key)
    end
end

-- Lấy giá trị với key tuỳ chỉnh
function GosuSDK.GetLocalValue(key)
    return PlayerPrefs.GetString(key, "")
end

function GosuSDK.GetRecentServerKey(baseKey)
    local account = GosuSDK.GetLocalValue("account")
    return baseKey .. tostring(account)
end

function GosuSDK.GetFixedName(name)
    -- Tách phần tên gốc và phần số (nếu có)
    local namePart = name:gsub("%d+$", "") -- Loại bỏ tất cả các chữ số ở cuối
    local randomSuffix = tostring(math.random(10, 999)) -- Tạo số ngẫu nhiên mới

    -- Ghép tên gốc với số ngẫu nhiên mới và chuyển đổi sang Unicode
    return UIUtils.ConvertKhmerLegacyToUnicodeString(name .. randomSuffix) -- ស៊ូវជា
end


-- Đăng ký các callback nội bộ

-- Đăng ký hàm xử lý Login
callbackHandlers["Login"] = function(jsonData)
    --print("GosuSDK Lua xử lý Login:")
    local data = Json.decode(jsonData)
    if data.status == 1 then
        -- print("GosuSDK Login thành công! UserID: " .. data.userid .. ", UserName: " .. data.username)
    else
        -- print("GosuSDK Login thất bại.")
    end
end

-- Đăng ký hàm xử lý Logout
callbackHandlers["Logout"] = function(jsonData)
    if jsonData == nil or jsonData == "" then
        -- print("GosuSDK Logout thành công.")
    else
        local data = Json.decode(jsonData)
        -- print("GosuSDK Logout data: ", data)
    end
end


-- Sửa hàm call back chỉ nhận 1 lần
function onPaymentResult(jsonData)
    --print("Lua xử lý Payment:")
    local data = Json.decode(jsonData)

    if data.status == 1 then
        -- print("GosuSDK Thanh toán thành công! : " .. data.message)
    else
        -- print("GosuSDK Thanh toán thất bại.")
    end

    -- Xóa callback hiện tại để tránh trùng lặp
    callbackHandlers["PaymentIAP"] = nil
    
    -- Tự động đăng ký lại để lắng nghe lần tiếp theo
    callbackHandlers["PaymentIAP"] = onPaymentResult
end

-- Đăng ký callback ban đầu
callbackHandlers["PaymentIAP"] = onPaymentResult


-- Đăng ký hàm xử lý Delete Account
callbackHandlers["DeleteAccount"] = function(jsonData)
    
    local data = Json.decode(jsonData)
    local message ;
    if data.status == 1 then
        message = GosuSDK.Events.GOSU_DELETE_SUCCESS
    else
        message = GosuSDK.Events.GOSU_DELETE_FAILED
    end
    GosuSDK.ShowMessageBox(
        message,
        nil,
        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
        function()
            GosuSDK.CallCSharpMethod("CallLogOut")
            GosuSDK.CallCSharpMethod("CallShowLogin")
        end
    )
end

function GosuSDK.ParseServersJsonNew(jsonStr)
    -- Debug.Log("Server list string:" .. jsonStr)

    local _jsonTable = Json.decode(jsonStr)
    if _jsonTable and _jsonTable.data and _jsonTable.data.servers then
        return _jsonTable.data.servers -- ✅ trả ra bảng thô
    else
        -- Debug.LogError("The obtained game server Json string has no data:" .. tostring(jsonStr))
        return nil
    end
end

function GosuSDK.FindServerByID(allList, serID)
    for _, server in ipairs(allList) do
        if server.svr_id == serID then
            return server
        end
    end
    return nil
end


function GosuSDK.DownloadServerList(onDone, customUrl)
    local url = customUrl or ServerUrlInfo:GetServerListNewURL()

    local function onSuccess(wwwText)
        if LOCAL_SVR_LIST then
            wwwText = "{  \"data\": {\"lg_server\": [{\"svr_host\": \"s33.oneteam.vn\",\"svr_port\": 9200,\"svr_name\": \"login\"}],\"servers\": [{\"svr_id\": 1003,\"svr_host\": \"s33.oneteam.vn\",\"svr_port\": 9103,\"register_num\": 0,\"svr_sort\": 1,\"svr_label\": \"3\",\"group_type\": 4,\"svr_status\": 1,\"svr_name\": \"DEV (Vie)\"},{\"svr_id\": 1001,\"svr_host\": \"s39.oneteam.vn\",\"svr_port\": 9101,\"register_num\": 0,\"svr_sort\": 1,\"svr_label\": \"2,3\",\"group_type\": 4,\"svr_status\": 1,\"svr_name\": \"DUO (Vie)\"},{\"svr_id\": 1004,\"svr_host\": \"s33.oneteam.vn\",\"svr_port\": 9102,\"register_num\": 0,\"svr_sort\": 2,\"svr_label\": \"0,1,2\",\"group_type\": 5,\"svr_status\": 1,\"svr_name\": \"D100 (Vie)\"},{\"svr_id\": 2001,\"svr_host\": \"127.0.0.1\",\"svr_port\": 9102,\"register_num\": 0,\"svr_sort\": 2,\"svr_label\": \"0,1,2\",\"group_type\": 5,\"svr_status\": 1,\"svr_name\": \"D100 (Local)\"}]  }}";
        end
        local allList = GosuSDK.ParseServersJsonNew(wwwText)

        if allList then
           

            if onDone then
                onDone(allList)
            end
        else
            -- Debug.LogError("[Lua] Parse server list failed - no list returned")
        end
    end

    local function onFail(tryLeft, error)
        -- Debug.LogError("[Lua] Download failed. Try left: " .. tostring(tryLeft) .. ", error: " .. tostring(error))
    end

    LuaCoroutineUtils.WebRequestText(url, onSuccess, onFail, nil, 3, nil)
end

function GosuSDK.DownloadRawJson(url, onDone)
    LuaCoroutineUtils.WebRequestText(
        url,
        function(text)
            if onDone then onDone(text) end
        end,
        function(code, err)
            if onDone then onDone(nil) end
        end,
        nil,
        3,
        nil
    )
end

-- Gọi hàm C# bằng tên và truyền đối số
function GosuSDK.CallCSharpMethod(methodName, ...)
    if sdkBridge[methodName] then
        -- print("Lua: Calling C# method - " .. methodName)
        local args = {...}
        if #args > 0 then
            sdkBridge[methodName](table.unpack(args)) -- Gọi hàm với đối số nếu có
        else
            sdkBridge[methodName]() -- Gọi hàm không có đối số
        end
    else
        -- print("Lua: Method " .. methodName .. " not found in FactorySdkBridge")
    end
end


function GosuSDK.ShowMessageBox(message, cancelText, okText, callback)
    
    GameCenter.MsgPromptSystem:ShowMsgBox(
        UIUtils.ConvertKhmerUnicodeToLegacyString(message),
        cancelText,
        okText or DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
        function (x)
            if x == MsgBoxResultCode.Button2 and callback then
                callback()
            end
        end,
        false,
        false,
        5,
        CS.Thousandto.Code.Logic.MsgInfoPriority.Highest
    )
   
end

-- Các hàm xử lý được gom nhóm lại để xử lý tiện lợi hơn trong android và ios

-- Hàm gom chung cho LevelUp, VipUp và CreateNewPlayer

function GosuSDK.TrackingEvent(eventType, value)
    value = value or nil -- Đặt giá trị mặc định là nil nếu không được truyền vào

    -- print("GosuSDK: TrackingEvent được gọi với eventType = " .. tostring(eventType) .. ", value = " .. tostring(value or "nil"))
    if eventType == "deleteAccount" then   

        if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer then
                -- print("GosuSDK: Gọi deleteAccount -- chỉ thực thi trên iOS")
                if not value or value == "" then
                    value = "0"
                end

                GosuSDK.ShowMessageBox(
                    -- GosuSDK.Events.GOSU_DELETE_ACCOUNT,
                    GosuSDK.GetLangString("GOSU_DELETE_ACCOUNT"),
                    DataConfig.DataMessageString.Get("C_MSGBOX_CANCEL"),
                    DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                    function()
                        -- Khi người dùng nhấn OK
                        GosuSDK.CallCSharpMethod("GTrackingFunction", "deleteAccount", value)
                    end
                )


                return
        else
            -- print("deleteAccount chỉ hoạt động trên iOS");
            return;
        end
        
    end
    -- Lấy các giá trị cần thiết
    local roleId = GosuSDK.GetLocalValue("saveRoleId")
    local serverId = GosuSDK.GetLocalValue("saveEnterServerId")
    local playerName = GosuSDK.getNamePlayer()

    -- Kiểm tra dữ liệu hợp lệ
    if roleId ~= "" and serverId ~= "" then
        if eventType == "levelUp" or eventType == "vipUp" then
            -- Kiểm tra nếu value tồn tại
            if value ~= nil then
                local intValue = tonumber(value) -- Chuyển thành số nguyên cho an toàn
                if intValue then
                    if eventType == "levelUp" then
                        -- print("GosuSDK: Gọi levelUp với roleId = " .. roleId .. ", serverId = " .. serverId .. ", level = " .. intValue)
                        GosuSDK.CallCSharpMethod("GTrackingFunction", "levelUp", roleId, serverId, intValue)
                    elseif eventType == "vipUp" then
                        -- print("GosuSDK: Gọi vipUp với roleId = " .. roleId .. ", serverId = " .. serverId .. ", vipLevel = " .. intValue)
                        GosuSDK.CallCSharpMethod("GTrackingFunction", "vipUp", roleId, serverId, intValue)
                    end
                else
                    -- print("GosuSDK: Lỗi - value không phải là số hợp lệ!")
                end
            else
                -- print("GosuSDK: Lỗi - value bị thiếu cho eventType: " .. eventType)
            end

        elseif eventType == "createNewPlayer" then
            -- Không cần tham số thứ 2 vì dùng playerName trong hàm
            if playerName ~= "" then
                -- print("GosuSDK: Gọi createNewPlayer với roleId = " .. roleId .. ", serverId = " .. serverId .. ", playerName = " .. playerName)
                GosuSDK.CallCSharpMethod("GTrackingFunction", "createNewCharacter", serverId, roleId, playerName)
            else
                -- print("GosuSDK: Lỗi - playerName trống khi gọi createNewPlayer!")
            end
        else
            -- print("GosuSDK: Lỗi - EventType không hợp lệ!")
        end
    else
        -- print("GosuSDK: Lỗi - Dữ liệu không hợp lệ khi gọi TrackingEvent!")
    end
end


function GosuSDK.GetPlatformName()
    if (not USE_SDK) then 
        return "PC";
    end
    -- Kiểm tra xem đang chạy trên Unity Editor hay không
    if (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXEditor) then
        return "PC";
    else
        if (CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.OSXPlayer or CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsPlayer) then
            return "PC";
        end
     
       
        return GameCenter.SDKSystem.PlatformName;
    end    
end


-- // chỉnh sửa hàm dùng chung khi load lang trong game không ra màn hình start
--
------
function GosuSDK.GetRuntimeLang()
    return GosuSDK.CurrentLang or (CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "VIE")
end


-- Lấy ngôn ngữ hiện tại để set sdk
function GosuSDK.GetCurrentLang()
    
    -- local dlang = CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "JP"

    local dlang = GosuSDK.GetRuntimeLang()

    local langMap = {
        VIE = "km", -- ngôn ngữ km dựa vào setting của game
        JP = "vi" -- ngôn ngữ vi dựa vào setting của game
    }


    if(CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.IPhonePlayer) then
        langMap = {
            VIE = "khmer", -- set lại để thích hợp với set trong sdk ios
            JP = "vi"
        }
    end

    return langMap[dlang] or "en"
end

function GosuSDK.GetLocalizedName(multiLangString)
    local nameParts = {}
    for part in string.gmatch(multiLangString or "", "[^@]+") do
        table.insert(nameParts, part)
    end

    -- local dlang = CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "VIE"
    local dlang = GosuSDK.GetRuntimeLang()

    if dlang == "VIE" then
        return nameParts[1] or multiLangString
    elseif dlang == "EN" then
        return nameParts[2] or multiLangString
    elseif dlang == "JP" then
        return nameParts[#nameParts] or multiLangString
    else
        return multiLangString
    end
end


function GosuSDK.SendLangToServer()

    -- local dlang = CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "VIE"
    local dlang = GosuSDK.GetRuntimeLang()

    local langIndexMap = {
        VIE = 0,
        EN = 1,
        JP = 2,
        -- thêm nữa nếu cần
    }

    local idx = langIndexMap[dlang]
    if idx then
        return idx or 0
    end
    return 0
end


--[ Hàm này dùng cho unity call ngược]
function GosuSDK.GetLocalizedUseForUnity(multiLangString)
    local nameParts = {}
    for part in string.gmatch(multiLangString or "", "[^@]+") do
        table.insert(nameParts, part)
    end

    -- local dlang = CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "VIE"

    -- Gosu cập nhật load lang không load màn hình đầu
    local dlang = GosuSDK.GetRuntimeLang()

    local langIndexMap = {
        VIE = 1,
        EN = 2,
        JP = 3,
        -- thêm nữa nếu cần
    }

    local idx = langIndexMap[dlang]
    if idx then
        return nameParts[idx] or multiLangString
    end
    return multiLangString
end



function GosuSDK.GetLang()

    if GosuSDK.CurrentLang then
        return GosuSDK.CurrentLang
    end

    local dlang = CS.UnityEngine.Gonbest.MagicCube.FLanguage.Default or "VIE"
    return dlang
end

-- lắng nghe sự kiện và update lang
GosuSDK.RegisterListener("UpdateLangConst", function(newLang)
    GosuSDK.CurrentLang = newLang
    -- cập nhật lại cache
    GosuSDK.CacheChangejobNameMapToPrefs("ChangejobNameMap")
end)

-- Gosu chỉnh sửa thời trang
function GosuSDK.InitData()
   

    local cmpList = {}
    local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()

    -- Lấy dữ liệu từ hai nguồn
    local mountList = GameCenter.NatureSystem.NatureMountData.super and GameCenter.NatureSystem.NatureMountData.super.FishionList or {}
    local wingList = GameCenter.NatureSystem.NatureWingsData.super and GameCenter.NatureSystem.NatureWingsData.super.FishionList or {}
    local natureList = GameCenter.NatureSystem.NatureFaBaoData.super and GameCenter.NatureSystem.NatureFaBaoData.super.FishionList or {}
    -- local petList = GosuSDK.GetAllActivePetCmpData() or {}

    -- Gộp hai bảng lại
    local allList = {}
    for i = 1, #mountList do
        table.insert(allList, mountList[i])
    end
    for i = 1, #wingList do
        table.insert(allList, wingList[i])
    end
    for i = 1, #natureList do
        table.insert(allList, natureList[i])
    end
    -- for i = 1, #petList do
    --     table.insert(allList, petList[i])
    -- end

    -- Lọc và build cmpData
    for i = 1, #allList do
        local _info = allList[i]
        --if _info.Occ == nil or (_info.Occ and _lp and _lp.IntOcc == _info.Occ) then
            local cmpData = {
                ItemId = _info.Item,
                ModelId = _info.ModelId,
                IconId = _info.Icon,
                StarNum = _info.Level or _info.StarNum ,
                Name = _info.Name,
                IsActive = _info.IsActive,
                Quality = 7
            }
            table.insert(cmpList, cmpData)
       -- end
    end


    return cmpList

end
function GosuSDK.GetLangString(key)
    local lang = GosuSDK.GetLang()
    local entry = GosuSDK.LangConst[key]
    if entry then
        return entry[lang] or entry["EN"] or key -- fallback về EN hoặc key
    end
    return key -- fallback nếu không có key
end

function GosuSDK.GetLangJson()
    return Json.encode(GosuSDK.LangConst)
end


function GosuSDK.GetLocalizedChangejobNameByOriginal(originalName)
    local id = GosuSDK.NameToId[originalName]
    if not id then return nil end

    local cfg = DataConfig.DataChangejob:GetByIndex(id)
    return cfg and cfg.ChangejobName or nil
end


function GosuSDK.CacheChangejobNameMapToPrefs(key)
    local map = {}

    for originalName, id in pairs(GosuSDK.NameToId) do
        local cfg = DataConfig.DataChangejob:GetByIndex(id)
        if cfg and cfg.ChangejobName then
            map[originalName] = cfg.ChangejobName
        end
    end

    local jsonStr = Json.encode(map)

    GosuSDK.RecordValue(key, jsonStr)
end


function GosuSDK.DownloadRawJsonPost(url, params, onDone)
    -- Tạo WWWForm
    local form =  CS.UnityEngine.WWWForm()

    -- params là table: { key1 = "value1", key2 = "value2" }
    if params then
        for k, v in pairs(params) do
            form:AddField(k, tostring(v))
        end
    end

    LuaCoroutineUtils.WebRequestText(
        url,
        function(text)
            if onDone then onDone(text) end
        end,
        function(code, err)
            -- print("POST Error:", code, err)
            if onDone then onDone(nil) end
        end,
        nil,
        3,
        form   -- ĐIỂM QUAN TRỌNG: truyền form vào đây
    )
end



-- Gọi InitSdk sau khi đã định nghĩa
if (USE_SDK) then

    GosuSDK.InitSdk("SDK_Object", "OnSdkCallback") -- ===================== khởi tạo sdk để tránh click 2 lần
    local lang = GosuSDK.GetCurrentLang()
    -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "setLanguage", lang)
end

if(LOCAL_TESTER) then
    GosuSDK.DownloadRawJson("https://gmt6100.oneteam.vn/api/list-user", function(json)
        -- GosuSDK.EmailWhiteLists = Json.decode(json)
        GosuSDK.BuildAccountCache(json)
    end)
end

function GosuSDK.BuildAccountCache(json)
    local list = Json.decode(json)

    local map = {}
    for _, email in ipairs(list) do
        map[email] = true
    end

    GosuSDK.EmailWhiteLists = map
end

function GosuSDK.CheckAccount(input)
    return GosuSDK.EmailWhiteLists and GosuSDK.EmailWhiteLists[input] == true
end


-- Lấy md5 động từ server
GosuSDK.DownloadRawJson("https://gmt6100.oneteam.vn/assets/json/key.json", function(json)
    local result = Json.decode(json)
    GosuSDK.NewMd5 = (result and result.data) or GosuSDK.Events.MD5_KEY -- fallback sang key cũ
    
end)


-- Tạo cache phi thăng
GosuSDK.CacheChangejobNameMapToPrefs("ChangejobNameMap")


-- core util:  itemId + strengthInfo -- dùng chung để lưu level khảm cho item
function GosuSDK.UpdateItemStrengthLevel(map, itemId, strengthInfo)
    if not map or not itemId or not strengthInfo then
        return
    end
    map[itemId] = strengthInfo.level or 0
end

-- convert số phút -> chuỗi "hh:mm"
function GosuSDK.MinutesToHHMM(totalMinutes)
    if not totalMinutes or totalMinutes < 0 then
        return "00:00"
    end

    local hours = math.floor(totalMinutes / 60)
    local minutes = totalMinutes % 60

    return string.format("%02d:%02d", hours, minutes)
end




return GosuSDK
