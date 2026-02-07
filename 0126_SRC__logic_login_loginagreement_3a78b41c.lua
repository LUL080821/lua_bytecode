------------------------------------------------
-- Author: 
-- Date: 2021-02-26
-- File: LoginAgreement.lua
-- Module: LoginAgreement
-- Description: Processing of login protocol
------------------------------------------------
local LoginAgreement = {
    AgreeValue = 0,
}

function LoginAgreement:New()
    local _m = Utils.DeepCopy(self)  
    return _m
end
-- Protocol processing
function LoginAgreement:CheckAgree()
    local _agree = false;
    if PlayerPrefs.HasKey("Agreement") then
        _agree = PlayerPrefs.GetInt("Agreement",0) > 0;
    end
    if not _agree then
        -- Only judgment here
        local _hasCH = (GameCenter.SDKSystem.LocalFGI == 1101);
        _agree = not _hasCH;
    end
    return _agree;
end

-- Read the user agreement
function LoginAgreement:ReadUserAgreement(url)    
    -- Debug.Log("Click User Agreement:" .. url);
    GameCenter.PushFixEvent(GlobalConst.OpenURLEventID, url);
    self.AgreeValue = self.AgreeValue | 1;
end

-- Read the Privacy Agreement
function LoginAgreement:ReadPrivacyAgreement(url)  
    Debug.Log("Click Privacy Agreement:" .. url);  
    GameCenter.PushFixEvent(GlobalConst.OpenURLEventID, url);
    self.AgreeValue = self.AgreeValue | 2;
end

-- Whether the settings are agreed
function LoginAgreement:SetIsAgree(val)
    if val then
        --[[
            if ((self.AgreeValue & 1) ~= 1) then
                self.AgCheckedBox.value = false;
                Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK",nil,"C_DONT_READ_USER_AGREEMENT");
                -- GameCenter.MsgPromptSystem:ShowMsgBox("Please read carefully [00ff00]Game User Agreement [-]", DataConfig.DataMessageString.Get("C_MSGBOX_OK"));
                return false;
            end

            if ((self.AgreeValue & 2) ~= 2) then
                self.AgCheckedBox.value = false;
                Utils.ShowMsgBoxAndBtn(nil,"C_MSGBOX_OK",nil,"C_DONT_READ_PRIVACY_AGREEMENT");
                -- GameCenter.MsgPromptSystem:ShowMsgBox("Please read the [00ff00] Privacy Protection Agreement [-]", DataConfig.DataMessageString.Get("C_MSGBOX_OK"));
                return false;
            end
        ]]
        PlayerPrefs.SetInt("Agreement",1);
        PlayerPrefs:Save();
        return true;
    else
        PlayerPrefs.SetInt("Agreement",0);
        PlayerPrefs:Save();
        return false;
    end
end

return LoginAgreement