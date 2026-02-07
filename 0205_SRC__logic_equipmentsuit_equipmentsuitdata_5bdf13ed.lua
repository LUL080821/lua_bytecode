
------------------------------------------------
-- Author: 
-- Date: 2019-06-10
-- File: EquipmentSuitData.lua
-- Module: EquipmentSuitData
-- Description: Set of data
------------------------------------------------
-- Quote
local EquipmentSuitData = {
    -- Configuration
    Cfg = nil,
    --id
    ID = 0,
    -- Demand equipment order
    NeedEquipDegrees  = nil,
    -- Demand quality
    NeedQuality  = 0,
    -- Demand number of drills
    NeedDiamondsCount = 0,
    -- List of occupations required list<int>
    NeedOccs = List:New(),
    -- List of required parts list<int>
    NeedParts = List:New(),
    -- List of required items Dictionary<int, List<{int, int}>>
    NeedItems = Dictionary:New(),
    -- Set properties Dictionary<int, List<{int, int}>>
    Props = Dictionary:New(),
};

function EquipmentSuitData:New(cfg)
    local _m = Utils.DeepCopy(self);
    _m:ParseData(cfg);
    return _m;
end

function EquipmentSuitData:ParseData(cfg)
    self.Cfg = cfg;
    self.ID = cfg.Id;
    -- Analyze the required equipment order
    self.NeedEquipDegrees = Utils.SplitNumber(cfg.NeedDegree, '_');
    self.NeedQuality = cfg.NeedQuality;
    self.NeedDiamondsCount = cfg.NeedDiamonds;
    -- A list of careers that analyze the needs
    self.NeedOccs = Utils.SplitNumber(cfg.NeedGender, '_');
    -- Analyze the required location list
    self.NeedParts = Utils.SplitNumber(cfg.NeedParts, '_');

    -- Analyze the required items, each part is different
    local _paramsArray = Utils.SplitStr(cfg.NeedItems, ';');
    for i = 1, #_paramsArray do
        local _itemParam = Utils.SplitStr(_paramsArray[i], '_');
        if #_itemParam >= 3 then
            local _part = tonumber(_itemParam[1]);
            local _itemId = tonumber(_itemParam[2]);
            local _itemCount = tonumber(_itemParam[3]);

            local _itemList = self.NeedItems:Get(_part);
            if _itemList == nil then
                _itemList = List:New();
                self.NeedItems:Add(_part, _itemList);
            end
            _itemList:Add({_itemId, _itemCount});
        end
    end

    -- Analyze 1 piece of attributes
    if string.len(cfg.Attribute1) > 0 then
        self.Props:Add(1, Utils.SplitStrByTableS(cfg.Attribute1, {';', '_'}));
    end

    -- Analyze 2-piece attributes
    if string.len(cfg.Attribute2) > 0 then
        self.Props:Add(2, Utils.SplitStrByTableS(cfg.Attribute2, {';', '_'}));
    end

    -- CUSTOM - thêm thuộc tính lúc 3 TB
    if string.len(cfg.Attribute3) > 0 then
        self.Props:Add(3, Utils.SplitStrByTableS(cfg.Attribute3, {';', '_'}));
    end
    -- CUSTOM - thêm thuộc tính lúc 3 TB

    -- Analyze 4-piece attributes
    if string.len(cfg.Attribute4) > 0 then
        self.Props:Add(4, Utils.SplitStrByTableS(cfg.Attribute4, {';', '_'}));
    end

    -- Analyze 6-piece attributes
    if string.len(cfg.Attribute6) > 0 then
        self.Props:Add(6, Utils.SplitStrByTableS(cfg.Attribute6, {';', '_'}));
    end
end

function EquipmentSuitData:CheckOcc(gener)
    if self.NeedOccs and gener then
        local list = Utils.SplitNumber(gener, '_')
        for i = 1, #list do
            if self.NeedOccs:Contains(list[i]) then
                return true
            end
        end
    end
    return false
end

return EquipmentSuitData;