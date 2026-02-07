--==============================--
-- author:
-- Date: 2019-06-11
-- File: UIEquipSuitItem.lua
-- Module: UIEquipSuitItem
-- Description: Set interface
--==============================--
local Equipment = CS.Thousandto.Code.Logic.Equipment;
local ItemBase = CS.Thousandto.Code.Logic.ItemBase;

local UIEquipSuitItem = {
    -- Parent UI
    Parent = nil,
    -- Root node
    RootGo = nil,
    Trans = nil,
    -- Button
    Btn = nil,
    --item
    Item = nil,
    -- name
    Name = nil,
    -- describe
    Desc = nil,
    -- Select box
    Select = nil,
    -- Red dot
    RedPoint = nil,

    -- Equipment example
    EquipInst = nil,
    -- Showcased set configuration
    ShowSuitCfg = nil,
    -- Is it possible to upgrade
    CanLevelUP = false,
};

function UIEquipSuitItem:New(go, parent)
    local _m = Utils.DeepCopy(self);
    _m.Parent = parent;
    _m.RootGo = go;
    _m.Trans = go.transform;
    _m:OnFirstShow();
    return _m;
end

-- First time display
function UIEquipSuitItem:OnFirstShow()
    self.Btn = UIUtils.FindBtn(self.Trans)
    UIUtils.AddBtnEvent(self.Btn, self.OnBtnClick, self);
    self.Item = UILuaItem:New(UIUtils.FindTrans(self.Trans, "UIItem"));
    self.Name = UIUtils.FindLabel(self.Trans, "Name");
    self.Desc = UIUtils.FindLabel(self.Trans, "Desc");
    self.Select = UIUtils.FindGo(self.Trans, "Select");
    self.RedPoint = UIUtils.FindGo(self.Trans, "RedPoint");
end

-- Setting up data
function UIEquipSuitItem:SetInfo(equip, level)
    self.EquipInst = equip;
    if self.EquipInst ~= nil then
        local _equipCfg = DataConfig.DataEquip[self.EquipInst.CfgID];
        if level == 1 then
            -- CUSTOM -- fix lại logic hiển thị RedPoint cho 3 TB ở mỗi tabs
            -- self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel1, _equipCfg.Part));
            if _equipCfg.Part == EquipmentType.Helmet or _equipCfg.Part == EquipmentType.Necklace or _equipCfg.Part == EquipmentType.FingerRing then
                self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel1, _equipCfg.Part));
            end
            if _equipCfg.Part == EquipmentType.Clothes or _equipCfg.Part == EquipmentType.Sachet or _equipCfg.Part == EquipmentType.Pendant then
                self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel2, _equipCfg.Part));
            end
            if _equipCfg.Part == EquipmentType.Belt or _equipCfg.Part == EquipmentType.LegGuard or _equipCfg.Part == EquipmentType.Shoe then
                self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel3, _equipCfg.Part));
            end
            -- CUSTOM -- fix lại logic hiển thị RedPoint cho 3 TB ở mỗi tabs
        elseif level == 2 then
            self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel2, _equipCfg.Part));
        elseif level == 3 then
            self.RedPoint:SetActive(GameCenter.RedPointSystem:OneConditionsIsReach(FunctionStartIdCode.EquipSuitLevel3, _equipCfg.Part));
        end
        self.RootGo:SetActive(true);
        self.Item:InitWithItemData(self.EquipInst, 1, false, false, ItemTipsLocation.Nomal);
        UIUtils.SetTextFormat(self.Name, "[{0}]{1}[-]",  Utils.GetQualityStrColor(_equipCfg.Quality),  self.EquipInst.Name);
        local _suitList = GameCenter.EquipmentSuitSystem:GetEquipSuitCfgList(_equipCfg);
        local _findSuit = false;
        if _suitList ~= nil and #_suitList > 0 then
            if #_suitList >= level then
                _findSuit = true;
                self.ShowSuitCfg = _suitList[level];
                -- The currently activated level
                local _curLevel = 0;
                local _curSuitCfg = GameCenter.EquipmentSuitSystem:FindCfg(self.EquipInst.SuitID);
                if _curSuitCfg ~= nil then
                    _curLevel = _curSuitCfg.Cfg.Level;
                end
                if _curLevel == level then
                    UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_YIZHUANGBEI", self.EquipInst.CurLevelSuitEquipCount, #self.ShowSuitCfg.NeedParts)
                    UIUtils.SetGreen(self.Desc);
                    self.CanLevelUP = false;
                elseif _curLevel == (level - 1) then
                    -- Can be upgraded
                    UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_CANDUANZAO", _suitList[level].Cfg.Prefix)
                    UIUtils.SetGreen(self.Desc);    
                    self.CanLevelUP = true;
                elseif _curLevel < (level - 1) then
                    -- Need to forge superiors
                    UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_NEEDDUANZAO", _suitList[level - 1].Cfg.Prefix);
                    UIUtils.SetRed(self.Desc);
                    self.CanLevelUP = false;
                else
                    UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_YIJINGDUANZAO", _curSuitCfg.Cfg.Prefix)
                    UIUtils.SetRed(self.Desc);
                    self.CanLevelUP = false;
                end
            end
        end

        if _findSuit == false then
            self.ShowSuitCfg = GameCenter.EquipmentSuitSystem:GetSuitByGrade(_equipCfg, level);
            -- This equipment cannot be forged
            self.CanLevelUP = false;
            -- Find out the minimum requirements for this equipment component at this level
            local _minNeed = GameCenter.EquipmentSuitSystem:FindLowestNeed(_equipCfg.Part, level);
            if _equipCfg.Quality < _minNeed[1] then
                -- Insufficient quality
                UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_DYCSWFDZ", ItemBase.GetQualityString(_minNeed[1]))
                UIUtils.SetRed(self.Desc);
            elseif _equipCfg.DiamondNumber < _minNeed[2] then
                -- Insufficient diamonds
                UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_NEEDDAIZUAN", _minNeed[2])
                UIUtils.SetRed(self.Desc);
            elseif _equipCfg.Grade < _minNeed[3] then
                -- Insufficient order
                UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_DY5JWFDZ", _minNeed[3])
                UIUtils.SetRed(self.Desc);
            else
                -- The problem cannot be found
                UIUtils.SetTextByEnum(self.Desc, "C_EQUIP_SUIT_ERRORCFG")
                UIUtils.SetRed(self.Desc);
            end
        end
    else
        self.RootGo:SetActive(false);
        self.CanLevelUP = false;
    end
end

-- Set whether to select
function UIEquipSuitItem:SetSelect(b)
    self.Select:SetActive(b);
end

-- Click Event
function UIEquipSuitItem:OnBtnClick()
    self.Parent:SetSelectEquip(self);
end

return UIEquipSuitItem;
