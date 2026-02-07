------------------------------------------------
-- Author: 
-- Date: 2019-08-07
-- File: UICreatePlayerPanel.lua
-- Module: UICreatePlayerPanel
-- Description: Create role information
------------------------------------------------
-- Quote
local CSGameCenter = CS.Thousandto.Code.Center.GameCenter
local UIShowSelectPlayerScript = require("UI.Forms.UICreatePlayerForm.UIShowSelectPlayerScript")
local UIVideoPlayUtils = CS.Thousandto.Plugins.Common.UIVideoPlayUtils;

local UICreatePlayerPanel = {
    IsVisible = false, -- Whether to display
    Parent = nil, -- Parent class
    Go = nil , -- node
    Trs = nil, -- node
    NameInput = nil, -- Name input
    NameInputLabel = nil, -- Name input
    SelectOcc = Occupation.Count, -- Choose a career
    PlayerTrans = List:New(), -- Role Node
    PlayerContentTrans = List:New(), -- Node of role content
    PlayerLineGos = List:New(), -- Character performance in the middle line
    PlayeRotTrans = List:New(), -- Role root node
    PlayeEnableRotGo = List:New(), -- Determine whether an object can be rotated
    PlayerIcons = List:New(), -- Role ICon
    SelectTrans = nil, -- Selected node
    PlayerGame = List:New(), -- Player node
    EnterBtn = nil, -- Enter button
    RandNameBtn = nil, -- Random name button
    InputNameGo = nil, -- Node with name entered
    TipsGo = nil, -- Prompt node
    LastRandomName = nil, -- The last random name

    SelectOccPanelTran = nil, -- Trans
    TipsSpriteGo = nil, -- Stay tuned
    
    OnlyHaveGoList = List:New(), -- List of unique objects

    -- Show player scripts
    ShowPlayerScripts = List:New(),

    -- Animation nodes entered by players
    PlayerEnterGos = List:New(),

    isSeeded = false,

    toggleInitCount   = 0,

    IsStartTime = false, -- Whether to start timing
}
UICreatePlayerPanel.__index = UICreatePlayerPanel

function UICreatePlayerPanel:New(trs,prent)
    local _M = Utils.DeepCopy(self)
    _M.Trs = trs
    _M.Go = trs.gameObject
    _M.Parent = prent
    _M:Init()
    return _M
end

-- Get Components
function UICreatePlayerPanel:FindAllComponentsNew()
    self.EnterBtn = UIUtils.FindBtn(self.Trs,"FunPanel/RightButtom/Container/CreateEnterBtn")
    self.RandNameBtn = UIUtils.FindBtn(self.Trs,"FunPanel/Bottom/Container/NameInput/RandName")
    self.NameInput = UIUtils.FindInput(self.Trs, "FunPanel/Bottom/Container/NameInput/Input")
    self.NameInputLabel = UIUtils.FindLabel(self.Trs, "FunPanel/Bottom/Container/NameInput/Label")
    self.InputNameGo = UIUtils.FindGo(self.Trs,"FunPanel/Bottom/Container/NameInput");
    self.SelectOccPanelTran  = UIUtils.FindTrans(self.Trs, "FunPanel/Left/Container/CreateOccPanel")
    self.TipsSpriteGo = UIUtils.FindGo(self.Trs,"FunPanel/RightButtom/Container/TipsSprite");

    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Left/Container/CreateOccPanel"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Bottom/Container/NameInput"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/CreateEnterBtn"));
    
    self.TipsGo = UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/GoalTips")

    -- Here we deal with the problem of inconsistent creation of roles in multiple countries and regions.
    local _occVer = "0"
    -- local _occVerCfg = DataConfig.DataGlobal[1385]
    -- if _occVerCfg ~= nil then
    --     _occVer = _occVerCfg.Params
    -- end
    -- for i=1,10 do
    --     local _go =  UIUtils.FindTrans(self.SelectOccPanelTran , tostring(i - 1))
    --     if _go ~= nil then
    --         _go.gameObject:SetActive(_occVer == tostring(i - 1));
    --     end
    -- end
    -- Get the root node of the scene
    local _root = UnityUtils.FindSceneRoot("SceneRoot")
    -- Added a pre-exhibition Rakshasa.
    local _count = Occupation.Count-1;
    for i= 0,_count do
        local _trsString = string.format( "new%s/%d",_occVer,i)
        local _trsContentString = string.format( "%s/%d/Content",_occVer,i)
        local player = UIUtils.FindTrans(self.SelectOccPanelTran ,_trsString)
        self.PlayerTrans:Add(player)
        -- local bg = UIUtils.FindSpr(player, "Background")
        -- player:Add(bg)
        -- local checkmark = UIUtils.FindSpr(player, "Checkmark")
        -- player:Add(checkmark)
        -- local _playerBtn = UIUtils.FindGo(self.SelectOccPanelTran ,_trsString)
        -- UIEventListener.Get(_playerBtn).onClick = Utils.Handler( self.OnPlayerBtnClick,self)
        local playerToggle = player:GetComponent("UIToggle")
        UIUtils.AddOnChangeEvent(playerToggle, self.OnToggleChange, self)
        if _root then
            local _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d", i))
            if _tran then
                self.PlayerGame:Add(_tran.gameObject)
            end
            _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d/[RotRoot]", i));
            if _tran then                
                self.PlayeRotTrans:Add(_tran)      
                self.ShowPlayerScripts:Add(UIShowSelectPlayerScript:New(_tran));      
                -- Hidden
                _tran.gameObject:SetActive(false) -- tạm thời ẩn để dùng video
            end

            _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d/[RotRoot]/[EnableRotate]", i));
            if _tran then                
                self.PlayeEnableRotGo:Add(_tran.gameObject)
            end

            -- _tran = _root.transform:Find(string.format("[PlayerRoot]/Enter/Player_%d", i))
            -- if _tran then
            --     self.PlayerEnterGos:Add(_tran.gameObject);
            -- end
        end
    end
    
    -- No input restrictions, make your own judgment
    self.NameInput.characterLimit = 18

    -- self.SelectTrans = UIUtils.FindTrans(self.SelectOccPanelTran ,string.format("%s/Select", _occVer))

    -- GosuSDK.RegisterListener("ResCreateRoleError", onResCreateRoleError)
    -- Đăng ký listener cho sự kiện lỗi tạo nhân vật
    GosuSDK.RegisterListener("ResCreateRoleError", function(msg)
        self:onResCreateRoleError(msg) -- Gọi phương thức onResCreateRoleError với self
    end)

end

-- Định nghĩa hàm xử lý sự kiện lỗi tạo nhân vật
function UICreatePlayerPanel:onResCreateRoleError(msg)
    -- print("============================= Received ResCreateRoleError event with message:", Inspect(msg))

    
    self:OnRandNameClick()
    local fixedName = GosuSDK.GetFixedName(self.NameInput.value)
    self.NameInput.value = fixedName


    
end

function UICreatePlayerPanel:FindAllComponents()
    self.EnterBtn = UIUtils.FindBtn(self.Trs,"FunPanel/RightButtom/Container/CreateEnterBtn")
    self.RandNameBtn = UIUtils.FindBtn(self.Trs,"FunPanel/Bottom/Container/NameInput/RandName")
    self.NameInput = UIUtils.FindInput(self.Trs, "FunPanel/Bottom/Container/NameInput/Input")
    self.InputNameGo = UIUtils.FindGo(self.Trs,"FunPanel/Bottom/Container/NameInput");
    self.SelectOccPanelTran  = UIUtils.FindTrans(self.Trs, "FunPanel/Left/Container/CreateOccPanel")
    self.TipsSpriteGo = UIUtils.FindGo(self.Trs,"FunPanel/RightButtom/Container/TipsSprite");

    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Left/Container/CreateOccPanel"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/Bottom/Container/NameInput"));
    self.OnlyHaveGoList:Add(UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/CreateEnterBtn"));
    
    self.TipsGo = UIUtils.FindGo(self.Trs, "FunPanel/RightButtom/Container/GoalTips")

    -- Here we deal with the problem of inconsistent creation of roles in multiple countries and regions.
    local _occVer = "0"
    local _occVerCfg = DataConfig.DataGlobal[1385]
    if _occVerCfg ~= nil then
        _occVer = _occVerCfg.Params
    end
    for i=1,10 do
        local _go =  UIUtils.FindTrans(self.SelectOccPanelTran , tostring(i - 1))
        if _go ~= nil then
            _go.gameObject:SetActive(_occVer == tostring(i - 1));
        end
    end
    -- Get the root node of the scene
    local _root = UnityUtils.FindSceneRoot("SceneRoot")
    -- Added a pre-exhibition Rakshasa.
    local _count = Occupation.Count-1;
    for i= 0,_count do
        local _trsString = string.format( "%s/%d",_occVer,i)
        local _trsContentString = string.format( "%s/%d/Content",_occVer,i)
        self.PlayerTrans:Add(UIUtils.FindTrans(self.SelectOccPanelTran ,_trsString))
        local _playerBtn = UIUtils.FindGo(self.SelectOccPanelTran ,_trsString)
        UIEventListener.Get(_playerBtn).onClick = Utils.Handler( self.OnPlayerBtnClick,self)
        self.PlayerIcons:Add(UIUtils.FindSpr(self.SelectOccPanelTran ,_trsContentString .. "/icon"))
        self.PlayerContentTrans:Add(UIUtils.FindTrans(self.SelectOccPanelTran ,_trsContentString))
        self.PlayerLineGos:Add(UIUtils.FindGo(self.SelectOccPanelTran ,_trsContentString.."/Decorate/Line"))
        
        if _root then
            local _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d", i))
            if _tran then
                self.PlayerGame:Add(_tran.gameObject)
            end
            _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d/[RotRoot]", i));
            if _tran then                
                self.PlayeRotTrans:Add(_tran)      
                self.ShowPlayerScripts:Add(UIShowSelectPlayerScript:New(_tran));          
            end

            _tran = _root.transform:Find(string.format("[PlayerRoot]/Create/Player_%d/[RotRoot]/[EnableRotate]", i));
            if _tran then                
                self.PlayeEnableRotGo:Add(_tran.gameObject)
            end

            -- _tran = _root.transform:Find(string.format("[PlayerRoot]/Enter/Player_%d", i))
            -- if _tran then
            --     self.PlayerEnterGos:Add(_tran.gameObject);
            -- end
        end
    end
    
    -- No input restrictions, make your own judgment
    self.NameInput.characterLimit = 0

    self.SelectTrans = UIUtils.FindTrans(self.SelectOccPanelTran ,string.format("%s/Select", _occVer))

    

end

-- Register events on the UI, such as click events, etc.
function UICreatePlayerPanel:RegUICallback()
    UIUtils.AddBtnEvent(self.EnterBtn, self.OnEnterGameBtnClick, self)
    UIUtils.AddBtnEvent(self.RandNameBtn, self.OnRandNameClick, self)
    -- There is no input verification here, only judgment is made when final determination
    --UIUtils.AddEventDelegate(self.NameInput.onSubmit, self.OnSubmit, self)
    UIUtils.AddEventDelegate(self.NameInput.onChange, self.OnNameInputChange, self)
end

function UICreatePlayerPanel:OnOpen()
    self:OnShowBefore()
    for i = 1, #self.OnlyHaveGoList do
        self.OnlyHaveGoList[i]:SetActive(true);
    end
    self.TipsGo:SetActive(true);
    self.IsVisible = true
    self.Parent:PlayVoiceOnOpen(true)
    self:OnShowAfter()
end

function UICreatePlayerPanel:OnClose(hideParam)
    self:OnHideBefore()    
    for i = 1, #self.OnlyHaveGoList do
        self.OnlyHaveGoList[i]:SetActive(false);
    end
    self.TipsGo:SetActive(false);
    --Debug.LogError("UICreatePlayerPanel:OnClose::" ..  tostring(self.IsVisible) .. tostring(hideParam));
    -- This will be called only the last time it is displayed
    if self.IsVisible then
        if hideParam == 1 then
            local _occ = UnityUtils.GetObjct2Int(self.SelectOcc);
            --Debug.LogError("UICreatePlayerPanel:OnClose::::::" .. tostring(_occ));
            local _go = self.PlayerEnterGos[_occ + 1];
           -- Debug.LogError("UICreatePlayerPanel:OnClose:;;;;;:::::" .. tostring(_go));
            if _go then
                _go:SetActive(true);
            end
        end
    end
    self.IsVisible = false
    self.Parent:PlayVoiceOnOpen(false)
    self:PlayVideo(false);
    self:OnHideAfter()
end


function UICreatePlayerPanel:Init()
    self:FindAllComponentsNew()
    self:RegUICallback()
end

-- function UICreatePlayerPanel:OnShowAfter()
--     self.SelectOcc = Occupation.Count;
--     --self:SetSelectPlayerNew(Occupation.XianJian,false)



--     if not self.isSeeded then
--         math.randomseed(os.time() + tonumber(tostring(os.clock()):reverse():sub(1, 6)))
--         self.isSeeded = true
--     end

--     local occList = {
--         Occupation.MoQiang,
--         Occupation.DiZang,
--         Occupation.XianJian,
--         Occupation.LuoCha
--     }

--     local randomIndex = math.random(1, #occList)
--     print("-------------------------ii", randomIndex)
--     local randomOcc = occList[randomIndex]
--    -- self.SelectOcc = randomIndex;
    
--     -- self:SetSelectPlayerNew(randomOcc, false)

--      -- Set toggle tương ứng
--     for i = 1, self.PlayerTrans:Count() do
--         local playerToggle = self.PlayerTrans[i]:GetComponent("UIToggle")
--         local occ = tonumber(playerToggle.name)
        
--         if occ == randomOcc then
--             playerToggle.value = false  -- reset trạng thái
--             playerToggle.value = true   -- set lại để trigger OnToggleChange
--         else
--             playerToggle.value = false
--         end
--     end


-- end

function UICreatePlayerPanel:OnShowAfter()
    self.SelectOcc = Occupation.Count

    -- Lấy occupation lần trước từ local
    local lastOcc = tonumber(GosuSDK.GetLocalValue("LastSelectedOcc") or "0")

    -- Seed random
    if not self.isSeeded then
        math.randomseed(os.time() + tonumber(tostring(os.clock()):reverse():sub(1, 6)))
        self.isSeeded = true
    end

    local occList = {
        Occupation.MoQiang,
        Occupation.DiZang,
        Occupation.XianJian,
        Occupation.LuoCha
    }

    -- Loại bỏ occupation trước đó (nếu có)
    local filteredList = {}
    for _, occ in ipairs(occList) do
        if occ ~= lastOcc then
            table.insert(filteredList, occ)
        end
    end

    -- Nếu tất cả occupation đều bị loại (rất hiếm), thì dùng lại occList gốc
    local finalList = (#filteredList > 0) and filteredList or occList

    -- Random occupation mới
    local randomIndex = math.random(1, #finalList)
    local randomOcc = finalList[randomIndex]
    -- print("Random new occupation:", randomOcc, "(last was:", lastOcc, ")")

    -- Ghi nhớ occupation được chọn lần này
    GosuSDK.RecordValue("LastSelectedOcc", tostring(randomOcc))

    -- Set toggle tương ứng (reset để chắc chắn trigger OnToggleChange)
    for i = 1, self.PlayerTrans:Count() do
        local toggle = self.PlayerTrans[i]:GetComponent("UIToggle")
        local occ = tonumber(toggle.name)

        if occ == randomOcc then
            toggle.value = false
            toggle.value = true
        else
            toggle.value = false
        end
    end    
end


function UICreatePlayerPanel:OnShowBefore()
    GameCenter.LoginSystem.MapLogic:SetState(LoginMapStateCode.CreateRolePanelOpened);
    
end

function UICreatePlayerPanel:OnHideAfter()    
    for i=1,self.PlayerTrans:Count() do
        if self.PlayerGame[i] then self.PlayerGame[i]:SetActive(false) end
    end
    self:PlayVideo(false);
end

function UICreatePlayerPanel:OnHideBefore()
    self.InputNameGo:SetActive(true);
    self.TipsSpriteGo:SetActive(false);
end

function UICreatePlayerPanel:OnFormDestroy()
    for i = 1, self.ShowPlayerScripts:Count() do
        if self.ShowPlayerScripts[i] then
            
        end
    end

    -- GosuSDK.UnregisterListener("ResCreateRoleError", ResCreateRoleError)
    GosuSDK.UnregisterListener("ResCreateRoleError", function(msg)
        self:onResCreateRoleError(msg)
    end)
end

function UICreatePlayerPanel:AddRotY(dtRotY)
    local index = UnityUtils.GetObjct2Int(self.SelectOcc) + 1;
    if self.PlayeEnableRotGo[index] and self.PlayeEnableRotGo[index].activeSelf then
        local _curLocalEuler = self.PlayeRotTrans[index].localEulerAngles
        _curLocalEuler.y =  _curLocalEuler.y + dtRotY
        self.PlayeRotTrans[index].localEulerAngles = _curLocalEuler             
    end
end

function UICreatePlayerPanel:SetSelectPlayerNew(csocc)
    -- Debug.Log("UICreatePlayerPanel:SetSelectPlayerNew csocc: " .. tostring(csocc))
    -- print("OnPlayerBtnClick _occVer", Inspect(csocc))
    if self.SelectOcc == csocc then
        return
    end
    self.SelectOcc = csocc;
    local _occ = UnityUtils.GetObjct2Int(self.SelectOcc) + 1    
    -- Stop before playing new voice so other voices
    AudioPlayer.Stop(AudioTypeCode.Speech)
    AudioPlayer.PlaySpeech(nil, string.format("snd_player_%02d",self.SelectOcc));
    self:PlayVideo(true, csocc);
    for i=1,self.PlayerTrans:Count() do
        if self.PlayerGame[i] ~= nil then
            self.PlayerGame[i]:SetActive(i == _occ)
        end

        if self.PlayeRotTrans[i] ~= nil then
            self.PlayeRotTrans[i].localRotation = Quaternion.identity
        end
    end    
    self.Parent:SetCurSelectOcc(self.SelectOcc, 0)
    self:OnRandNameClick()
    
    -- Handle open careers
    if GameCenter.PlayerRoleListSystem:OccIsValid(_occ) then        
        self.EnterBtn.gameObject:SetActive(true);
        self.InputNameGo:SetActive(true);
        self.TipsSpriteGo:SetActive(false);
    else
        self.EnterBtn.gameObject:SetActive(false);
        self.InputNameGo:SetActive(false);
        self.TipsSpriteGo:SetActive(true);
    end
end

function UICreatePlayerPanel:SetSelectPlayer(csocc,moveAnim)
    if self.SelectOcc == csocc then
        return
    end
    self.SelectOcc = csocc;
    local _occ = UnityUtils.GetObjct2Int(self.SelectOcc) + 1    
    self.SelectTrans.localPosition = self.PlayerTrans[_occ].localPosition;
    -- Stop before playing new voice so other voices
    AudioPlayer.Stop(AudioTypeCode.Speech)
    AudioPlayer.PlaySpeech(nil, string.format("snd_player_%02d",self.SelectOcc));

    for i=1,self.PlayerContentTrans:Count() do
        if self.PlayerGame[i] ~= nil then
            self.PlayerGame[i]:SetActive(i == _occ)
        end

        if self.PlayeRotTrans[i] ~= nil then
            self.PlayeRotTrans[i].localRotation = Quaternion.identity
        end

        if self.PlayerContentTrans[i] ~= nil then
            if i == _occ then
                UnityUtils.SetLocalPosition(self.PlayerContentTrans[i], 45, 0, 0)
                UnityUtils.SetLocalScale(self.PlayerContentTrans[i], 1.2, 1.2, 1.2)
                if self.PlayerLineGos[i] ~= nil then
                    self.PlayerLineGos[i]:SetActive(false);
                end
            else
                UnityUtils.SetLocalPosition(self.PlayerContentTrans[i], 0, 0, 0)
                UnityUtils.SetLocalScale(self.PlayerContentTrans[i], 1, 1, 1)
                if self.PlayerLineGos[i] ~= nil then
                    self.PlayerLineGos[i]:SetActive(true);
                end
            end
        end
    end    
    self.Parent:SetCurSelectOcc(self.SelectOcc, 0)
    self:OnRandNameClick()
 
    -- Handle open careers
    if GameCenter.PlayerRoleListSystem:OccIsValid(_occ) then        
        self.EnterBtn.gameObject:SetActive(true);
        self.InputNameGo:SetActive(true);
        self.TipsSpriteGo:SetActive(false);
    else
        self.EnterBtn.gameObject:SetActive(false);
        self.InputNameGo:SetActive(false);
        self.TipsSpriteGo:SetActive(true);
    end
end

function UICreatePlayerPanel:OnPlayerBtnClick(go)

    local _occ = tonumber(go.name)
    self:SetSelectPlayer(_occ, true)
end

-- function UICreatePlayerPanel:OnToggleChange()
    
--     -- Nếu đang trong lần gọi tự động khi khởi tạo
--     -- if self.toggleInitCount <= (Occupation.Count - 1) then
--     --     self.toggleInitCount = self.toggleInitCount + 1
--     --     return
--     -- end
--     for i=1,self.PlayerTrans:Count() do
--         local playerToggle = self.PlayerTrans[i]:GetComponent("UIToggle")
        
--         if playerToggle.value == true then
--             local _occ = tonumber(playerToggle.name)
           
--             self:SetSelectPlayerNew(_occ, true)
--             break
--         end
--     end
-- end

function UICreatePlayerPanel:OnToggleChange()
    for i = 1, self.PlayerTrans:Count() do
        local player = self.PlayerTrans[i]
        local playerToggle = player:GetComponent("UIToggle")
        ---thêm mới
        local bg = UIUtils.FindSpr(player, "Background")
        local checkmark = UIUtils.FindSpr(player, "Checkmark")
        local isOn = playerToggle.value
        if bg then bg.gameObject:SetActive(not isOn) end
        if checkmark then checkmark.gameObject:SetActive(isOn) end
        if playerToggle.value == true then
            local _occ = tonumber(playerToggle.name)

            -- Nếu đã chọn rồi thì không xử lý lại
            if self.SelectOcc == _occ then
                -- print("[OnToggleChange] Đã chọn occupation này rồi, bỏ qua:", _occ)
                return
            end

            self:SetSelectPlayerNew(_occ, true)
            GosuSDK.RecordValue("LastSelectedOcc", tostring(_occ))
            break
        end
    end
end


function UICreatePlayerPanel:OnNameInputChange()
    local _name = self.NameInput.value
    if self.NameInputLabel then
        local _strConvert = UIUtils.ConvertKhmerUnicodeToLegacyString(_name)
        -- Trim _strConvert last 10 characters
        local _maxLen = 30
        local _nameLen = string.len(_strConvert)
        if _nameLen > _maxLen then
            _strConvert = string.sub(_strConvert, _nameLen-_maxLen, _maxLen)
        end
        UIUtils.SetTextByString(self.NameInputLabel,_strConvert)
    end
end

function UICreatePlayerPanel:OnEnterGameBtnClick()
    local _name = self.NameInput.value
    if string.find(_name,"\r") or  string.find(_name,"\n")then
        _name = string.gsub(_name,"\r","")
        _name = string.gsub(_name,"\n","")
        self.NameInput.value = _name
    end
    local _minLen = GameCenter.PlayerRoleListSystem.MinNameLength;
    local _maxLen = GameCenter.PlayerRoleListSystem.MaxNameLength;

    local _nameLen = Utils.UTF8LenForLan(_name,FLanguage.Default);   
    if _nameLen > _maxLen or _nameLen < _minLen then
        Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_CREATEPLAYER_ERROR_NAMELEN", _minLen, _maxLen)
        -- Gosu custom
        local fixedName = GosuSDK.GetFixedName(_name)
        self.NameInput.value = fixedName

        return
    end
    if _name ~= nil and _name ~= "" then
        local _charArray = Utils.StringToList(_name)
        for i=1,_charArray:Count() do
            if i + 1 == _charArray:Count() then
                break
            end
            local _hight = _charArray[i]
            local _low = _charArray[ i + 1]
            -- The special expression consists of 2 characters, divided into high and low characters, with high and low ranges ranging from 0xd800~0xdbff, and low ranges ranging from 0xdc00~0xdfff
            if string.byte(_hight) > 0xd800 and string.byte(_hight)  < 0xdbff then
                if string.byte( _low) > 0xdc00 and string.byte( _low) < 0xdfff then
                    Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_CREATEPLAYER_ERROR_SYMBOL")

                    -- Gosu custom
                    local fixedName = GosuSDK.GetFixedName(_name)
                    self.NameInput.value = fixedName
                    return;
                end
            end
        end
    end

    -- Processing after creating a role
    GameCenter.ImmortalResSystem:ClearImmortalAll()
    GameCenter.ImmortalResSystem:SetImmortalResourceFirst(UnityUtils.GetObjct2Int(self.SelectOcc))
    
    -- Convert to legacy string before sending to server
    local _strConvert = UIUtils.ConvertKhmerUnicodeToLegacyString(_name)
    local _isRandom = (_strConvert == self.LastRandomName);  
    GameCenter.PlayerRoleListSystem:SendCreateRoleMsg(_strConvert, UnityUtils.GetObjct2Int(self.SelectOcc),_isRandom)
    -- Preload the welcome interface Texture in advance
    --CSGameCenter.PrefabManager:PreLoadPrefab(CS.Thousandto.Core.Asset.UIPoolAssetsLoader.FormPrefabPath("UIWeleComeForm", "UIWeleComeForm"), nil, true);
    CSGameCenter.TextureManager:PreLoadTexture(AssetUtils.GetImageAssetPath(ImageTypeCode.UI, "tex_n_d_208_c"));
    GameCenter.PushFixEvent(UIEventDefine.UI_WAITING_OPEN);
end

function UICreatePlayerPanel:OnRandNameClick()  
    self.LastRandomName = GameCenter.PlayerRoleListSystem:GetRandomName(UnityUtils.GetObjct2Int(self.SelectOcc));
    -- self.NameInput.value = self.LastRandomName;
    
    local _strUnicode = '';
    if (FLanguage.Default ~= FLanguage.VIE) then
        -- _strUnicode = self.LastRandomName;
        _strUnicode = string.gsub(self.LastRandomName, "%s+", "") -- loại bỏ khoảng trắng
    else
        _strUnicode = UIUtils.ConvertKhmerLegacyToUnicodeString(self.LastRandomName)
    end
    
    self.NameInput.value = _strUnicode
end

function UICreatePlayerPanel:PlayVideo(status, occ)
    if occ == nil then
        return
    end
    if status == true then
        local fileName = "player_" .. tostring(occ)
        UIVideoPlayUtils.PlayVideo( fileName, function() self.IsStartTime = true; end, nil, false, true );
    else
        if UIVideoPlayUtils.IsPlaying() then
            UIVideoPlayUtils.StopVideo()
        end
    end
end

return UICreatePlayerPanel
