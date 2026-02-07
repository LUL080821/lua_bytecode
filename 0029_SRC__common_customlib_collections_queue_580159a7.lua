------------------------------------------------
-- Author: 
-- Date: 2021-02-20
-- File: Queue.lua
-- Module: Queue
-- Description: Queue, implement the first-in-first-out principle
------------------------------------------------
local Queue = {}
Queue.__index = Queue

-- Create a new Queue. obj can nil, isNotCopy default deep copy
function Queue:New(obj, isNotCopy)
    local _Queue = nil
    if obj ~= nil then
        if type(obj) =="table" then
            _Queue = isNotCopy and obj or Utils.DeepCopy(obj)
        else
            _Queue = {first = 0, last = -1}
            for i = 0, obj.Count - 1 do
                table.insert(_Queue, obj[i])
            end
        end
    else
        _Queue = {first = 0, last = -1}
    end
    setmetatable(_Queue, Queue)
    return _Queue
end


-- Add a data to the end of the queue
function Queue:Enqueue(item)
    local _last = self.last + 1;
    self.last = _last;
    self[_last] = item;
end

-- Returns the data in the header of a queue and deletes it
function Queue:Dequeue()
    local _first = self.first
    if _first > self.last then
        error("List is empty")
    end
    local value = self[_first]
    self[_first] = nil
    self.first = _first + 1
    return value
end

-- Returns the data of a queue header
function Queue:Peek()
    local _first = self.first
    if _first > self.last then
        error("List is empty")
    end
    return self[_first];
end

-- Clear all contents of all queues
function Queue:Clear()
    local _count = #self;
    for i=_count, 1, -1 do
        table.remove(self)
    end
    self.first = 0;
    self.last = -1;
end

-- Number of items
function Queue:Count()
    return self.last - self.first + 1;
end

-- eg: UIUtils.CSFormat("{0}{1}",_Queue:Unpack())
function Queue:Unpack()
    return table.unpack(self);
end

return Queue