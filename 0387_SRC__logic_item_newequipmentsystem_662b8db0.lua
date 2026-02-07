------------------------------------------------
-- Author:
-- Date: 2021-03-04
-- File: NewEquipmentSystem.lua
-- Module: NewEquipmentSystem
-- Description: Equipment system
------------------------------------------------
local NewEquipmentSystem ={}

-- Get the price of some equipment at the auction house
function NewEquipmentSystem:GetEquipScoreInAuction(occ, quality, grade, diaNum)
    local _ret = 0
    DataConfig.DataEquip:ForeachCanBreak(function(k, v)
        if (k < 3000000) then
            if (string.find(v.Gender, "9") ~= nil or string.find(v.Gender, tostring(occ)) ~= nil) and v.Quality == quality and v.Grade == grade and v.DiamondNumber == diaNum then
                _ret = v.AuctionMaxPrice;
                return true
            end
        end
    end)
    return _ret;
end

function NewEquipmentSystem:OnCheckCanEquip(equipment)
    if equipment then
        local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer();
        if (localPlayer == nil) then
            return false;
        end
        if not equipment:CheckLevel(localPlayer.Level) then
            return false;
        end
        if not equipment:CheackOcc(localPlayer.IntOcc) then
            return false;
        end
        if (equipment:isTimeOut()) then
            return false;
        end
        if not equipment:CheckClass() then
            return false;
        end
    end
    return true;
end

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove
function NewEquipmentSystem:RequestEquipUnWear(equipDBID)
    if (GameCenter.ItemContianerSystem:GetRemainCount() == 0) then
        Utils.ShowPromptByEnum("C_EQUIP_UNWEAR_NOBAG")
        return;
    end
    local reqEquip = ReqMsg.MSG_Equip.ReqEquipUnWear:New();
    reqEquip.equipId = equipDBID;
    reqEquip:Send();
end

-- Wear
function NewEquipmentSystem:RequestEquipWear(equip)
    if (equip == nil) then
        return;
    end
    local localPlayer = GameCenter.GameSceneSystem:GetLocalPlayer();
    local level = GameCenter.GameSceneSystem:GetLocalPlayerLevel();
    if not equip:CheackOcc(localPlayer.IntOcc) then
        Utils.ShowPromptByEnum("C_EQUIP_OCC_ERROR");
    elseif not equip:CheckClass() then
        local cfg = DataConfig.DataChangejob[equip.ItemInfo.Classlevel]
        if cfg then
            Utils.ShowMsgBoxAndBtn(nil, "C_MSGBOX_OK", nil, "C_EQUIP_WARFIALECLASEE", cfg.ChangejobName)
        end
    elseif not equip:CheckLevel(level) then
        Utils.ShowPromptByEnum("C_TIPS_EQUIPCLASSLESS", CommonUtils.GetLevelDesc(equip.ItemInfo.Level), equip.ItemInfo.Level - level);
    else
        if (self:OnCheckCanEquip(equip) == false) then
            Utils.ShowPromptByEnum("C_EQUIP_WEAR_FIALD")
            return;
        end
        local dressEquip = GameCenter.EquipmentSystem:GetPlayerDressEquip(equip.Part);
        if dressEquip and dressEquip.SuitCfg then
            Utils.ShowMsgBox(function(x)
                if (x == MsgBoxResultCode.Button2) then
                    self:OnSendWearEquipMsg(equip, dressEquip);
                end
            end, "C_EQUIP_TIPS_SUIT");
        else
            self:OnSendWearEquipMsg(equip, dressEquip);
        end
    end
end


function NewEquipmentSystem:ReqEqipSell(idList)
    local msg = ReqMsg.MSG_Equip.ReqEquipSell:New();
    msg.id = idList
    msg:Send();
end

function NewEquipmentSystem:OnSendWearEquipMsg(equipid, dressEquip)
    if (dressEquip and dressEquip.Quality == QualityCode.Golden
        and equipid.Quality == QualityCode.Red
        and dressEquip.StarNum > equipid.StarNum and dressEquip.Grade == equipid.Grade) then
        Utils.ShowMsgBoxAndBtn(function(x)
                if (x == MsgBoxResultCode.Button2) then
                    local msg = ReqMsg.MSG_Equip.ReqEquipWear:New();
                    msg.Inherit = true;
                    msg.equipId = equipid.DBID;
                    msg:Send();
                else
                    local msg = ReqMsg.MSG_Equip.ReqEquipWear:New();
                    msg.Inherit = false;
                    msg.equipId = equipid.DBID;
                    msg:Send();
                end
            end, "C_MSGBOX_NO", "C_MSGBOX_YES", "C_TIPS_EQUIPJICHEN");
    else
        local msg = ReqMsg.MSG_Equip.ReqEquipWear:New();
        msg.Inherit = false;
        msg.equipId = equipid.DBID;
        msg:Send();
    end
end
-- --------------------------------------------------------------------------------------------------------------------------------
return NewEquipmentSystem