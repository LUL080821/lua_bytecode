------------------------------------------------
-- author:
-- Date: 2021-03-10
-- File: PlayerVisualSystem.lua
-- Module: PlayerVisualSystem
-- Description: Information management displayed by players
------------------------------------------------
local PlayerVisualInfo = require("Logic.Entity.Character.Player.PlayerVisualInfo");
local LocalPlayerRoot = CS.Thousandto.Code.Logic.LocalPlayerRoot

local PlayerVisualSystem = {
    PlayerVisualDict = nil,
}

function PlayerVisualSystem:Initialize()
   self.PlayerVisualDict = Dictionary:New();   
   GameCenter.RegFixEventHandle(LogicEventDefine.EID_EVENT_PLYAER_ENTER_SCENE,self.OnEnterScene,self);   
end

function PlayerVisualSystem:UnInitialize()
   GameCenter.UnRegFixEventHandle(LogicEventDefine.EID_EVENT_PLYAER_ENTER_SCENE,self.OnEnterScene,self);   
   self.PlayerVisualDict = nil;
end

-- Scene Switching
function PlayerVisualSystem:OnEnterScene()    
    local _pv = nil;
    if self.PlayerVisualDict:ContainsKey(LocalPlayerRoot.LocalPlayerID) then
        _pv = self.PlayerVisualDict[LocalPlayerRoot.LocalPlayerID];
    end        
    self.PlayerVisualDict:Clear();
    self.PlayerVisualDict[LocalPlayerRoot.LocalPlayerID] = _pv;
end
 

-- Get visual information
function PlayerVisualSystem:GetVisualInfo(roleId)
    if roleId~=nil and roleId ~= 0 then
        if not self.PlayerVisualDict:ContainsKey(roleId) then
            self.PlayerVisualDict[roleId] = PlayerVisualInfo:New();            
        end    
        return self.PlayerVisualDict[roleId];
    else
       return PlayerVisualInfo:New();
    end
end

-- Constructed through protocol
function PlayerVisualSystem:ResPlayerBaseInfo(msg)  
    self:Refresh(msg.roleID, msg.facade, msg.stateVip); 
end

-- Constructed through protocol
function PlayerVisualSystem:ResRoundObjs(msg)
    if msg.removeIds ~= nil then
        for _, value in ipairs(msg.removeIds) do
            self.PlayerVisualDict[value] = nil;
        end
    end

    if msg.players ~= nil then
        for _, _player in ipairs(msg.players) do                  
            self:Refresh(_player.playerId, _player.facade, _player.stateVip);            
        end
    end
end

-- Refresh the map player
function PlayerVisualSystem:ResMapPlayer(msg)
   if msg.player then
        local _player = msg.player;
        self:Refresh(_player.playerId, _player.facade, _player.stateVip);      
   end   
end

-- Delete the player
function PlayerVisualSystem:ResPlayerDisappear(msg)
    if msg.playerIds ~= nil then
        for _, value in ipairs(msg.playerIds) do
            self.PlayerVisualDict[value] = nil;
        end
    end
end

-- Delete NPC
function PlayerVisualSystem:ResRoundNpcDisappear(msg)  
    if msg.npcIds ~= nil then
        for _, value in ipairs(msg.npcIds) do
            self.PlayerVisualDict[value] = nil;
        end
    end
end

-- Team refresh
function PlayerVisualSystem:ResTeamInfo(msg)
    if msg.members then
        for _, _player in ipairs(msg.members) do            
            self:Refresh(_player.roleId, _player.facade, _player.stateLv);
        end
    end    
end

-- Team refresh
function PlayerVisualSystem:ResUpdateTeamMemberInfo(msg)
    if msg.member then     
        local _player = msg.member
        self:Refresh(_player.roleId, _player.facade, _player.stateLv);  
    end    
end


-- View other players
function PlayerVisualSystem:ResLookOtherPlayerResult(msg)    
    self:Refresh(msg.roleId, msg.facade, 0);
end

-- Refresh the character visual information
function PlayerVisualSystem:Refresh(roleId,facade,stateLv)      
    if not self.PlayerVisualDict:ContainsKey(roleId) then
        self.PlayerVisualDict[roleId] = PlayerVisualInfo:New();
    end
    self.PlayerVisualDict[roleId]:ParseByLua(facade, stateLv); 
end

return PlayerVisualSystem