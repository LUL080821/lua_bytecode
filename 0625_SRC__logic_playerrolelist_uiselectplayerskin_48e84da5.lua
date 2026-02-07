------------------------------------------------
-- Author:
-- Date: 2021-02-24
-- File: UISelectPlayerSkin.lua
-- Module: UISelectPlayerSkin
-- Description: Log in to the selected player
------------------------------------------------
local LoginSelectPlayer = require("Logic.PlayerRoleList.LoginSelectPlayer");

local UISelectPlayerSkin = {
    -- Select a list of users
    SelectPlayerDict = nil,
    -- The currently selected player
    CurSelectPlayer = nil,
    -- The player's root node
    PlayerRoot = nil,
}

function UISelectPlayerSkin:New()
    local _m = Utils.DeepCopy(self)
    _m.SelectPlayerDict = Dictionary:New();
    return _m
end
function UISelectPlayerSkin:Init()
    local _playerList = GameCenter.PlayerRoleListSystem.RoleList;
    self:UnLoadSelectPlayer();
    self.SelectPlayerDict:Clear();-- new Dictionary<ulong, LoginSelectPlayer>();
    for i = 1, _playerList:Count() do
        self.SelectPlayerDict:Add(_playerList[i].RoleId , LoginSelectPlayer:New(_playerList[i],self.PlayerRoot));
    end    
end

-- uninstall
function UISelectPlayerSkin:UnInit()
    self:UnLoadSelectPlayer();
end

-- Set the selected role
function UISelectPlayerSkin:SetCurSelectPlayer(playerID)    
    if self.SelectPlayerDict then
        self.SelectPlayerDict:Foreach(function (k,v)            
            if (k == playerID) then            
                self.CurSelectPlayer = v;
                v:ShowPlayer();            
            else
                v:HidePlayer();
            end
        end);
    end
end

-- Remove the selected role
function UISelectPlayerSkin:RemoveSelectPlayer(playerID)
    if self.SelectPlayerDict then
       local _p = self.SelectPlayerDict[playerID];
       if _p then
            _p:Destroy();
            self.SelectPlayerDict:Remove(playerID);
       end
    end
end

-- Release the selected role list
function UISelectPlayerSkin:UnLoadSelectPlayer()
    if self.SelectPlayerDict then
        self.SelectPlayerDict:Foreach(function (k,v)
            v:Destroy();
        end);
        self.SelectPlayerDict:Clear();        
    end
    self.CurSelectPlayer = nil;
end

-- renew
function UISelectPlayerSkin:Update(dt)
    if self.CurSelectPlayer then        
        self.CurSelectPlayer:Update(dt);
    end
end

-- Set the current rotation value
function UISelectPlayerSkin:AddCurRotY(dtRotY)
    if self.CurSelectPlayer then
        self.CurSelectPlayer:AddRotY(dtRotY);
    end
end

return UISelectPlayerSkin;