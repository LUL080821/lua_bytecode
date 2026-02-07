------------------------------------------------
--author:
--Date: 2019-04-18
--File: UIInputAccountPanel.lua
--Module: UIInputAccountPanel
--Description: Enter the Panel of the account game,
------------------------------------------------
local UIToggleGroup = require("UI.Components.UIToggleGroup");
local LoginStatus = require("Logic.Login.LoginStatus");

local UIInputAccountPanel = {

    --Form
    Form = nil,
    --Current Panel's Trans
    Trans = nil,
    --Account input UIInput
    AccountInput = nil,    
    --Button to enter the game UIButton
    LoginBtn = nil,

    --Switch group
    ToggleGroup = nil,
    -- PassInput input, 
    PassInput = nil, 
    PassLabel = nil, 
   
};

local L_ToggleGroup;

--Platform initialization
function UIInputAccountPanel:Initialize(owner,trans)
    self.Form = owner;
    self.Trans = trans;
    self:FindAllComponents();
    self:RegUICallback();


    return self;
end

--Panboard display
function UIInputAccountPanel:Show()   
    self.Trans.gameObject:SetActive(true);    
    self:Refresh();
end

--Panboard hidden
function UIInputAccountPanel:Hide()
    self.Trans.gameObject:SetActive(false);
end

--Find all lists
function UIInputAccountPanel:FindAllComponents()
    local _myTrans = self.Trans;
    self.AccountInput = UIUtils.FindInput(_myTrans,"AccountInput");    
    self.LoginBtn = UIUtils.FindBtn(_myTrans,"LoginBtn");
    local _serverSelectGo = UIUtils.FindGo(_myTrans,"ServerSelect")    
    self.ToggleGroup = UIToggleGroup:New(self,UIUtils.FindTrans(_myTrans,"ServerSelect"),10010,L_ToggleGroup);
    --This is not available at the moment, you can hide this after you have the SDK
    _serverSelectGo:SetActive(false)


    --- input pass cho bản AT
    self.PassInput = UIUtils.FindInput(_myTrans,"PassInput"); 

    -- ✅ tìm UILabel bên trong PassInput, tên "account"
    self.PassLabel = UIUtils.FindLabel(_myTrans, "PassInput/account") 

    self:RegUICallback();
    -- GosuSDK.RegisterListener("ButtonClick", OnButtonClickListener) --> test OnButtonClickListener

    -- Đăng ký listener từ GosuSDK
    -- GosuSDK.RegisterListener("Login", OnLogin)
    GosuSDK.RegisterListener("Login", function(jsonData)
        UIInputAccountPanel:OnLogin(jsonData)
    end)

    self.PassInput.gameObject:SetActive(false); -- tạm ẩn ở Lua, đúng là ẩn ở prefab
end

--Binding UI button callback operation
function UIInputAccountPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.LoginBtn,self.OnLoginBtnClick,self);

    if(LOCAL_TESTER) then
        self.PassInput.gameObject:SetActive(true);

        UIUtils.AddEventDelegate(self.PassInput.onChange, self.OnPassInputEvent, self)
        -- UIUtils.AddEventDelegate(self.PassInput.onValidate, self.OnPassInputEvent, self)

    end
end

function UIInputAccountPanel:OnPassInputEvent()
   
    if(not SOCIAL_TESTER) then
        self.PassInput:UpdateLabel()
        local real = self.PassInput.value or ""
        UIUtils.SetTextByString(self.PassLabel, string.rep("*", string.len(real)))
    end
    
end

--test OnButtonClickListener
-- function OnButtonClickListener(jsonData)
--     Debug.Log("External Listener: Sự kiện ButtonClick đã nhận được!")
--     Debug.Log("Dữ liệu nhận được:", jsonData)
-- end


-- Xử lý khi SDK trả về dữ liệu
function UIInputAccountPanel:OnLogin(jsonData)
    Debug.Log("External Listener: Login Event Received!")
    local data = Json.decode(jsonData)
    if data.status == 1 then
        Debug.Log("GosuSDK Login thành công! UserID: " .. data.userid .. ", UserName: " .. data.username);
        GosuSDK.RecordValue("saveUserSdkId", data.username) -- save giá trị usernam của sdk
        -- Tiến hành Login
        local _account = data.userid ;
        self.AccountInput.value = _account;
        self:RecordAccount(_account);     
        self.Form:OnLoginGame(_account); 
    else
        Debug.Log("GosuSDK Login thất bại.")
    end
end

--Log in
function UIInputAccountPanel:OnLoginBtnClick()
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN, DataConfig.DataMessageString.Get("C_XIAOTIAN_TIPS1"));
    self.Form:OnLoginStatus(LoginStatus.CallSDK);
    GameCenter.LoginSystem.LastLoginSuccessTime = nil; 
    if (GameCenter.SDKSystem:IsSDKLogin()) then
        GameCenter.SDKSystem:Login();     
    else
         --Login to the Login server
        local _account = self.AccountInput.value;

        Debug.Log("OnLoginBtnClick SDK username:" .. tostring(_account));
        Debug.Log("OnLoginBtnClick SDK PassInput:" .. tostring(self.PassInput.value));
        -- GosuSDK.OnButtonClick() --test OnButtonClickListener
        local account = self:GetLocalAccount()

        if (_account == "") then
            if (USE_SDK) then
                GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_CLOSE);
                self.AccountInput.gameObject:SetActive(false);
                -- khởi tạo sdk và show form 
                --GosuSDK.InitSdk("SDK_Object", "OnSdkCallback") -- SDK_Object phải có hàm OnSdkCallback để lắng nghe dữ liệu từ sdk trả về
                -- GosuSDK.CallCSharpMethod("CallShowLogin")
                -- GosuSDK.CallCSharpMethod("BridgeTrackingFunction", "Login") -- hàm mới

                GosuSDK.CorrectFuntionIOS("CallShowLogin")
            else
                GameCenter.MsgPromptSystem:ShowMsgBox(
                        "Tên đăng nhập không được ít hơn 2 ký tự",
                        nil,
                        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                        function (x) end,
                        false,
                        false,
                        5,
                        CS.Thousandto.Code.Logic.MsgInfoPriority.Highest
                    )
            end
            
        else
            if (LOCAL_TESTER and type(GosuSDK.EmailWhiteLists) == "table") then

                local function showMsg(msg)
                    GameCenter.MsgPromptSystem:ShowMsgBox(
                        msg,
                        nil,
                        DataConfig.DataMessageString.Get("C_MSGBOX_OK"),
                        function (x) end,
                        false,
                        false,
                        5,
                        CS.Thousandto.Code.Logic.MsgInfoPriority.Highest
                    )
                end

                local function doLogin(errorMsg)
                    GosuSDK.DownloadRawJsonPost(
                        "https://gmt6100.oneteam.vn/api/user-login",
                        {
                            username = tostring(_account),
                            password = tostring(self.PassInput.value)
                        },
                        function(res)
                            local result = Json.decode(res)
                            if result.success == 1 then
                                self:RecordAccount(_account)
                                self:RecordPass(tostring(self.PassInput.value))
                                self.Form:OnLoginGame(_account)
                            elseif(result.success == 0) then
                                showMsg(errorMsg)
                            elseif(result.success == 2) then
                                showMsg("Tài khoản đã tồn tại, vui lòng nhập lại!")
                            end
                        end
                    )
                end

                -- ===== SOCIAL TEST MODE =====
                if SOCIAL_TESTER then
                    if self.PassInput.value == "" then
                        showMsg("Vui lòng nhập mã mời.")
                        return
                    end

                    doLogin("Mã mời sai hoặc đã được sử dụng!")
                    return
                end

                -- ===== NORMAL TESTER MODE =====
                if not GosuSDK.CheckAccount(_account) then
                    showMsg("Tài khoản của bạn không nằm trong danh sách tester.")
                    return
                end

                if self.PassInput.value == "" then
                    showMsg("Vui lòng nhập mật khẩu.")
                    return
                end

                doLogin("Bạn nhập sai mật khẩu.")
                return
            end

            

            self:RecordAccount(_account);     
            self.Form:OnLoginGame(_account);                   
        end
    end
end



--Refresh the UI interface
function UIInputAccountPanel:Refresh()
    self.AccountInput.value = self:GetLocalAccount();
    if(LOCAL_TESTER) then
        self.PassInput.value = self:GetLocalPass();
    end
    self.ToggleGroup:Refresh();
end

--Record the logged in account
function UIInputAccountPanel:RecordAccount(value)
    PlayerPrefs.SetString("account", value);    
end
function UIInputAccountPanel:RecordPass(value)
    PlayerPrefs.SetString("password", value);    
end

--Get local login account
function UIInputAccountPanel:GetLocalAccount()
    return PlayerPrefs.GetString("account","");
end

--Get local login account
function UIInputAccountPanel:GetLocalPass()
    return PlayerPrefs.GetString("password","");
end

--Hide button
function UIInputAccountPanel:HideBtns()
   self.AccountInput.gameObject:SetActive(false);   
   self.LoginBtn.gameObject:SetActive(false);
   --self.ToggleGroup.Trans.gameObject:SetActive(false);
end

--Show button
function UIInputAccountPanel:ShowBtns()    
    local _isnotSdkLogin = not GameCenter.SDKSystem:IsSDKLogin();
    --self.ToggleGroup.Trans.gameObject:SetActive(_isnotSdkLogin);
    self.AccountInput.gameObject:SetActive(_isnotSdkLogin);    
    self.LoginBtn.gameObject:SetActive(true);
end

--==Internal variables and function definitions==-
--Where does the server list come from?
L_ToggleGroup = { 
    --Internal network
    [1] = {
        Get = function()
            return true
            --return GameCenter.ServerListSystem.FromType == 0;
        end,
        Set = function(checked)
            if checked then
                -- Debug.LogError("Intranet");
                --GameCenter.ServerListSystem.FromType = 0;
            end
        end
    },
    --Outside Network
    [2] = {
        Get = function()
            return true
            --return GameCenter.ServerListSystem.FromType == 1;
        end,
        Set = function(checked)
            if checked then
                -- Debug.LogError("External Network");
                --GameCenter.ServerListSystem.FromType = 1;
            end
        end
    },
    --Public beta
    [3] = {
        Get = function()
            return true
            --return GameCenter.ServerListSystem.FromType == 2;
        end,
        Set = function(checked)
            if checked then
                -- Debug.LogError("public beta");
                --GameCenter.ServerListSystem.FromType = 2;
            end
        end
    }
};

return UIInputAccountPanel;