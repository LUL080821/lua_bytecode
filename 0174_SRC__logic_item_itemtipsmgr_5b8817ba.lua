------------------------------------------------
-- Author:
-- Date: 2021-02-22
-- File: ItemTipsMgr.lua
-- Module: ItemTipsMgr
-- Description: Tips Manager
------------------------------------------------
local ItemTipsMgr = {
    -- Props information to be displayed
    TipsModel = nil,
}

-- Show props tips
-- <param name="goods">Item information that needs to be displayed</param>
-- <param name="obj">Click game object</param>
-- <param name="location">location</param>
function ItemTipsMgr:ShowTips(goods, obj, location, isShowGetBtn, cost, isResetPosion, ExtData, washDic, gemInlayList, jadeInlayList, gemRefinLv, suitData)
    self:Close()
    if (goods == nil) then
        return
    end
    local _goodsType = goods.Type
    if _goodsType == -1 then
        -- C# side parsing error, re-parse using lua
        goods = LuaItemBase.CreateItemBase(goods.CfgID)
    end
    local _goodsClassType = type(goods)
    if _goodsClassType == "userdata" then
        -- Objects created by C# side need to be converted into lua objects
        if _goodsType == ItemType.PetEquip or
            _goodsType == ItemType.SoulPearl or
            _goodsType == ItemType.HorseEquip or
            _goodsType == ItemType.DevilSoulEquip or
            _goodsType == ItemType.UnrealEquip then
            goods = LuaItemBase.CreateItemBase(goods.CfgID)
        end
    end
    if location == nil then
        location = ItemTipsLocation.Defult
    end
    if isShowGetBtn == nil then
        isShowGetBtn = true
    end
    if isResetPosion == nil then
        isResetPosion = true
    end
    local select = {};
    select.ShowGoods = goods;
    select.SelectObj = obj;
    select.Locatioin = location;
    select.costEquip = cost;
    select.isShowGetBtn = isShowGetBtn;
    select.ExtData = ExtData;
    -- Refined attribute dictionary eg: {{ Index, { AttrID = _attrID, Value = _realValue, Percent = 0 }}}
    select.WashDic = washDic
    -- Gem inlay list Put in the inlayed stone ID, uninlayed hair 0 eg:{13001, 0, 0, 0, 0, 0}
    select.GemInlayList = gemInlayList
    -- Fairy Jade Inlay List Put the inlayed stone ID, uninlaid hair 0 eg:{13001, 0, 0, 0, 0, 0}
    select.JadeInlayList = jadeInlayList
    -- Gem Refined Level
    select.GemRefinLv = gemRefinLv
    -- Set of data
    select.SuitData = suitData
    self.TipsModel = goods;
    select.isResetPosion = isResetPosion;

    if (_goodsType == ItemType.Equip) then
        GameCenter.PushFixEvent(UIEventDefine.UIEQUIPTIPSFORM_OPEN, select);
    elseif (_goodsType == ItemType.MonsterSoulEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIMonsterEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.HolyEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIHolyEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.ImmortalEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIImmortalEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.LingPo) then
        GameCenter.PushFixEvent(UIEventDefine.UILingPoTipsForm_Open, select);
    elseif (_goodsType == ItemType.PetEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIPetEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.HorseEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.DevilSoulEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIDevilSoulEquipTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.SoulPearl) then
        GameCenter.PushFixEvent(UIEventDefine.UISoulPearlTipsForm_OPEN, select);
    elseif (_goodsType == ItemType.UnrealEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIUnrealEquipTipsForm_OPEN, select);
    else
        GameCenter.PushFixEvent(UIEventDefine.UIITEMTIPS_OPEN, select);
    end
end

-- Show props tips
-- <param name="id">Item configuration table id</param>
-- <param name="obj">Click game object</param>
-- <param name="isShowGetBtn">Whether to display the Get button</param>
-- <param name="location">Location</param>
function ItemTipsMgr:ShowTipsByCfgid(id, obj, isShowGetBtn, location)
    local itemBase = LuaItemBase.CreateItemBase(id);
    self:ShowTips(itemBase, obj, location, isShowGetBtn);
end

-- Close prop tips
function ItemTipsMgr:Close()
    if self.TipsModel == nil then
        return
    end
    if (self.TipsModel.Type == ItemType.Equip) then
        GameCenter.PushFixEvent(UIEventDefine.UIEQUIPTIPSFORM_CLOSE);
    elseif (self.TipsModel.Type == ItemType.MonsterSoulEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIMonsterEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.HolyEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIHolyEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.ImmortalEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIImmortalEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.LingPo) then
        GameCenter.PushFixEvent(UIEventDefine.UILingPoTipsForm_Close);
    elseif (self.TipsModel.Type == ItemType.PetEquip) then
        GameCenter.PushFixEvent(UIEventDefine.UIPetEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.HorseEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIMountEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.DevilSoulEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIDevilSoulEquipTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.SoulPearl) then
        GameCenter.PushFixEvent(UIEventDefine.UISoulPearlTipsForm_CLOSE);
    elseif (self.TipsModel.Type == ItemType.UnrealEquip) then
        GameCenter.PushFixEvent(UILuaEventDefine.UIUnrealEquipTipsForm_CLOSE);
    else
        GameCenter.PushFixEvent(UIEventDefine.UIITEMTIPS_CLOSE);
    end
end
return ItemTipsMgr