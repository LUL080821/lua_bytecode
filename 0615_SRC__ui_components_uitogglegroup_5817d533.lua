------------------------------------------------
-- Author: 
-- Date: 2019-04-9
-- File: UIToggleGroup.lua
-- Module: UIToggleGroup
-- Description: Click the Group of the switch component
--[[
    The shape of the object's GameObjectTree: 
    --ParentNode
              --Item_01
              --Item_02
              --Item_03
              --Item_04

    Note: The Item_xx node needs to add the UIToggle component.
]]--
------------------------------------------------

local UIToggleGroup={
   -- Current owner of ToggleGroup
   Owner = nil,
   -- Transform associated with the current group
   Trans = nil,
   -- Mutexual Toggle array
   GroupID = 0,
   -- All Toggle components
   Toggles = Dictionary:New(),
   -- Processing function table when Toggle is changed
   SwitchProps = nil,
   -- The associated ToggleGroup array, when the current ToggleGroup is changed, the associated TG will also be refreshed.
   RelateToggleGroups = nil,
};

-- Construct an object
function UIToggleGroup:New(owner,trans,groupID,switchProps,relateGroups)
    local _m = Utils.DeepCopy(self);
    _m.Owner = owner;
    _m.Trans = trans;
    _m.GroupID = groupID;
    _m.SwitchProps = switchProps;
    _m.RelateToggleGroups = relateGroups;
    _m:FindAllComponents();
    return _m;
end

-- Find all components
function UIToggleGroup:FindAllComponents()
    local _trans = self.Trans;
    for i = 0, _trans.childCount-1 do
        local _c = _trans:GetChild(i);
        local _toggle = UIUtils.FindToggle(_c)
        if _toggle ~= nil then                    
            _toggle.group = self.GroupID;
            UIUtils.AddOnChangeEvent(_toggle,self.OnToggleChanged,self,_toggle);
            local _flag = tonumber(string.sub(_c.name,-2));
            self.Toggles[_toggle] = _flag;
        end
    end
end

-- Refresh the current component
function UIToggleGroup:Refresh()
    if self.Toggles then
        for k,v in pairs(self.Toggles) do
            local _prop = self.SwitchProps[v];
            if _prop ~= nil then
                k.value = _prop.Get();
            end
        end
    end
end

-- Handling when the switch assembly is changed
function UIToggleGroup:OnToggleChanged(toggle)    
    if self.SwitchProps then
        local _flag = self.Toggles[toggle];
        local _prop = self.SwitchProps[_flag];        
        if _prop ~= nil then            
            _prop.Set(toggle.value);
        end
    else        
        if self.Owner ~= nil and self.Owner.OnToggleChanged ~= nil then            
            self.Owner.OnToggleChanged(toggle);
        end
    end
    if self.RelateToggleGroups then
        for _,v in ipairs(self.RelateToggleGroups) do
            v:Refresh();
        end
    end
end

return UIToggleGroup;