

local GosuEventSystem = {
    validLevels = {31, 50, 100, 200, 240},
    currentLevel = 1 -- Khởi tạo level hiện tại
}


function GosuEventSystem:Initialize()
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ON_GOSU_CREATE_PLAYER, self.OnGosuCreatelayer, self)
    GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_ON_GOSU_USED_LEVEL, self.OnUseLevelCallBack, self)
    -- Debug.Log("===========================GosuEventSystem  ===============================================")
end

function GosuEventSystem:UnInitialize()
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ON_GOSU_CREATE_PLAYER, self.OnGosuCreatelayer, self)
    GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_ON_GOSU_USED_LEVEL, self.OnUseLevelCallBack, self)
 
end


function GosuEventSystem:OnUseLevelCallBack(newLevel, sender)
    -- Chuyển obj thành số (nếu obj là chuỗi)

    -- Debug.Log("===========================OnUseLevelCallBack  level ===============================================", Inspect(newLevel))

    local newLevelNumber = tonumber(newLevel)
    if not newLevelNumber then
        -- Debug.LogError("Invalid newLevel:", newLevel)
        return
    end

    -- Lấy level hiện tại
    local currentLevel = GosuEventSystem.currentLevel

    -- Kiểm tra tất cả các mốc level hợp lệ trong khoảng [currentLevel + 1, newLevel]
    for _, validLevel in ipairs(GosuEventSystem.validLevels) do
        if validLevel > currentLevel and validLevel <= newLevelNumber then
            -- Gửi sự kiện cho mốc level hợp lệ
            GosuEventSystem:SendLevelEvent(validLevel)
        end
    end

    -- Cập nhật level hiện tại
    GosuEventSystem.currentLevel = newLevelNumber
    
    
end


function GosuEventSystem:SendLevelEvent(level)
    -- local data = {
    --     event = GosuSDK.Events.GOSU_LEVEL .. tostring(level), 
        
    --     params = { 
    --         role_id = GosuSDK.GetLocalValue("saveRoleId"),
    --         character_name = GosuSDK.getNamePlayer(),
    --         server = GosuSDK.GetLocalValue("saveEnterServerId"),
    --     }
      
    -- }
    -- Log dữ liệu sự kiện
    -- Debug.Log("=======================================[Gosu tracking] GOSU_LEVEL ", Json.encode(data))
    
    -- Gọi phương thức C# để gửi sự kiện
    -- GosuSDK.CallCSharpMethod("GTrackingFunction", "levelUp", GosuSDK.GetLocalValue("saveRoleId"), GosuSDK.GetLocalValue("saveEnterServerId"), tonumber(level))
    
    GosuSDK.TrackingEvent("levelUp", level)
    -- GosuSDK.CallCSharpMethod("TrackingEvent", GosuSDK.Events.GOSU_LEVEL .. tostring(level), Json.encode(data))
end


function GosuEventSystem:OnGosuCreatelayer(obj, sender)

    -- local data = {
    --     event = GosuSDK.Events.Done_NRU,
    --     role_id = GosuSDK.GetLocalValue("saveRoleId"),
    --     server = GosuSDK.GetLocalValue("saveEnterServerId"),
        
    -- }
    --GosuSDK.CallCSharpMethod("TrackingDoneNRU", GosuSDK.GetLocalValue("saveEnterServerId"), GosuSDK.GetLocalValue("saveRoleId"), GosuSDK.getNamePlayer())
    -- GosuSDK.CallCSharpMethod("GTrackingFunction", "createNewCharacter", GosuSDK.GetLocalValue("saveEnterServerId"), GosuSDK.GetLocalValue("saveRoleId"), GosuSDK.getNamePlayer())
    
    GosuSDK.TrackingEvent("createNewPlayer")


    local dataLv1 = {
        event = GosuSDK.Events.GOSU_LEVEL .. "1",
        params = { 
            role_id = GosuSDK.GetLocalValue("saveRoleId"),
            character_name = GosuSDK.getNamePlayer(),
            server = GosuSDK.GetLocalValue("saveEnterServerId"),
        }
        
    }

    -- Debug.Log("=======================================[Gosu tracking] user_lv1", Json.encode(dataLv1))

    GosuSDK.TrackingEvent("levelUp", 1)

   -- GosuSDK.CallCSharpMethod("TrackingEvent", GosuSDK.Events.GOSU_LEVEL .. "1", Json.encode(dataLv1))
   -- GosuSDK.CallCSharpMethod("GTrackingFunction", "levelUp", GosuSDK.GetLocalValue("saveRoleId"), GosuSDK.GetLocalValue("saveEnterServerId"), tonumber(1))
   
end

return GosuEventSystem