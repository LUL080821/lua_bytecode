local MSG_Map = {}
local Network = GameCenter.Network

function MSG_Map.RegisterMsg()
    Network.CreatRespond("MSG_Map.ResEnterMap",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResRoundObjs",function (msg)
        --TODO
        GameCenter.LuaCharacterSystem:ResRoundObjs(msg)
        GameCenter.PlayerVisualSystem:ResRoundObjs(msg);
    end)

    Network.CreatRespond("MSG_Map.ResMapPlayer",function (msg)
        --TODO
        GameCenter.LuaCharacterSystem:ResMapPlayer(msg)
        GameCenter.PlayerVisualSystem:ResMapPlayer(msg);
    end)

    Network.CreatRespond("MSG_Map.ResRoundNpcDisappear",function (msg)
        --TODO
        GameCenter.PlayerVisualSystem:ResRoundNpcDisappear(msg);
    end)

    Network.CreatRespond("MSG_Map.ResStopMove",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMoveTo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResJump",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPlayerDisappear",function (msg)
        --TODO
        GameCenter.PlayerVisualSystem:ResPlayerDisappear(msg);
    end)

    Network.CreatRespond("MSG_Map.ResRoundNpcInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMapMonster",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMonsterDisappear",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResDirMove",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMapGatherInfo",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResGatherDisappear",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResBreakGather",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResRelive",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMoveSpeedChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResAttackspeedChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResLineList",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPlayerCloakChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPetBirth",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPetDisappear",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResJumpBlock",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResBlockDoors",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResUpdateBlockDoor",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMagicBirth",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMagicClean",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResUpdateCamp",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMonsterPos",function (msg)
        --TODO
        GameCenter.MandateSystem:OnGetMonsterResult(msg.x, msg.Y)
    end)

    Network.CreatRespond("MSG_Map.ResMonsterDieGetItem",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResBeginGather",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResEndGather",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResUpdateMoveState",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPlayEffect",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResRoleStatue",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResCityFlag",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResJumpTransport",function (msg)
        --TODO
        -- local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
        -- if _lp ~= nil then
        --     GameCenter.BlockingUpPromptSystem:AddFlyTeleport(msg.transId)
        -- end
        -- GOSU Modification Start: Handle fly teleport for both local and remote players
        if msg.playerId > 0 then
            local _lp = GameCenter.GameSceneSystem:GetLocalPlayer()
            if _lp ~= nil and _lp.ID == msg.playerId then
                GameCenter.BlockingUpPromptSystem:AddFlyTeleport(msg.transId)
                return
            end

            local _rlp = GameCenter.GameSceneSystem:FindRemotePlayer(msg.playerId)
            if _rlp ~= nil then
                _rlp:Action_FlyTeleport(msg.transId)
            else
                Debug.Log("No remote player found with playerId: "..msg.playerId)
            end
        end
    end)

    Network.CreatRespond("MSG_Map.ResJumpDown",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResBonfireBirth",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResBonfireClean",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMonsterDieGetCoin",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPetHpChange",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResMonsterDropMark",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResTombstoneBirth",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResTombstoneClean",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResGroundBuffBirth",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResGroundBuffClean",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResGroundBuffStar",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResShowMonsterPop",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResPlayCinematic",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResNotCanGather",function (msg)
        --TODO
    end)

    Network.CreatRespond("MSG_Map.ResShiHaiBroadcast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResVipLvBroadCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResGuildInfoBroadCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResFabaoInfoBroadCast",function (msg)
        --TODO
        GameCenter.LuaCharacterSystem:ResFabaoInfoBroadCast(msg)
    end)

    Network.CreatRespond("MSG_Map.ResTaskInfoBroadCast",function (msg)
        --TODO
        GameCenter.LuaCharacterSystem:ResTaskInfoBroadCast(msg)
    end)


    Network.CreatRespond("MSG_Map.ResSpiritIdBroadCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResHuaxinFlySwordBroadCast",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResChildCallInfo",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResPlayerPlayVfx",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Map.ResSoulEquipChange",function (msg)
        --TODO
        GameCenter.LuaCharacterSystem:ResSoulEquipChange(msg)
        GameCenter.SoulEquipSystem:SetCurWearEquipID(msg.soulArmorId)
    end)

end
return MSG_Map

