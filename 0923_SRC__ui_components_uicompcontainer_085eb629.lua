------------------------------------------------
-- Author: 
-- Date: 2019-04-9
-- File: UICompContainer.lua
-- Module: UICompContainer
-- Description: UI component container, a list of components of varying lengths
------------------------------------------------

local UICompContainer = {
    -- Idle queue new List<TUI>();
    FreeList = List:New(),
    
    -- Queue used new Dictionary<TData, TUI>();
    UsedDict = Dictionary:New(),
    
    -- template
    Template = nil,

    -- New object callback
    NewCallBack = nil,
}


-- Create an instance
function UICompContainer:New()
    local _m = Utils.DeepCopy(self);
    return _m;
end

-- Setting up creating a new object callback MyAction<TUI>
function UICompContainer:SetNewCallBack(callBack)
    self.NewCallBack = callBack;
end

-- Clean up
function UICompContainer:Clear()
    self.FreeList:Clear();
    self.UsedDict:Clear();
    self.Template = nil;
    self.NewCallBack = nil;
end

-- Add new component TUI compInfo
function UICompContainer:AddNewComponent(compInfo)
    self.FreeList:Add(compInfo);
    compInfo:SetActive(false);
    if (self.FreeList:Count() == 1) then
        self:SetTemplate();
    end
end

-- Setting template TUI btn
function UICompContainer:SetTemplate(btn)
    self.Template = btn;
    if (btn == nil) then
        if (self.FreeList:Count() > 0) then
            self.Template = self.FreeList[1];
        end
    end
end

-- Experience all components in the Free queue
function UICompContainer:EnQueueAll()
    if (self.UsedDict:Count() > 0) then
        local _tmpList = List:New();
        for k,btn in pairs(self.UsedDict) do
            if btn ~= nil then
                btn:SetActive(false);
                btn:SetName("_");
                _tmpList:Add(btn);                
            end
        end
        self.UsedDict:Clear();
        -- The flip here is to allow the idle queue to save its original order
        self.FreeList:AddRange(_tmpList);
        _tmpList = nil;
    end
end

-- Rewind an object back to the TData type in the queue
function UICompContainer:EnQueue(type)
    local btn = self.UsedDict[type];
    if btn ~= nil then
        btn:SetActive(false);
        btn:SetName("_");
        self.FreeList:Add(btn);
    end
    self.UsedDict[type] = nil;
end

-- Get a TData type from the queue
--return TUI
function UICompContainer:DeQueue(type)
    local result = nil;
    local cnt = self.FreeList:Count();
    if (cnt > 0) then            
        -- Read the last one from the free table
        result = self.FreeList:RemoveAt(cnt);
    else
        if (self.Template ~= nil) then
            result = self.Template:Clone();
            if (self.NewCallBack ~= nil) then
                self.NewCallBack(result);
            end
        end
    end

    if (result ~= nil) then
        result:SetData(type);
        result:SetActive(true);
        self.UsedDict[type] = result;
    end
    return result;
end

-- Get the UI object used TData type
--return TUI
function UICompContainer:GetUsedUI(type)
    return self.UsedDict[type];
end

-- Get the number of components being used
function UICompContainer:GetUsedCount()
    return self.UsedDict:Count();
end


-- Refresh all objects' data
function UICompContainer:RefreshAllUIData()
    for k, v in pairs(self.UsedDict) do
        v:RefreshData();
    end   
end

return UICompContainer;