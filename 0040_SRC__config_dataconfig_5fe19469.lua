------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: DataConfig.lua
-- Module: DataConfig
-- Description: Data loading processing
------------------------------------------------
-- //Module definition
local DataConfig = {}
local ConfigNames = nil

-- Record the loading time of each configuration
local L_IsReCord_Ms = false;

-- Record the memory loading of each configuration
local L_IsRecord_GCAlloc = false;

local MetaTable = {}
setmetatable(DataConfig, MetaTable)

MetaTable.__index = function(mytable, name)
	return DataConfig.Load(name)
end

-- Data loading
function DataConfig.Load(name)
	if L_IsRecord_GCAlloc and Record then
		Record.GCBegin(name)
	end
	if L_IsReCord_Ms and Record then
		Record.TimeBegin(name)
	end
	DataConfig[name] = require(string.format("Config.Data.%s", name))
	if L_IsReCord_Ms and Record then
		Record.TimeEnd()
	end
	if L_IsRecord_GCAlloc and Record then
		Record.GCEnd()
	end
	return DataConfig[name]
end

-- Uninstall data
function DataConfig.UnLoad(name)
	if DataConfig[name] then
		DataConfig.RemoveRequiredByName(string.format("Config.Data.%s", name))
		DataConfig[name] = nil
	end
end

-- Get all configuration table names
function DataConfig.GetConfigNames()
	if not ConfigNames then
		ConfigNames = require("Config.Data.ConfigNames")
	end
	return ConfigNames
end

-- Load all configuration data
function DataConfig.LoadAll()
	local _names = DataConfig.GetConfigNames()
	for i = 1, #_names do
		DataConfig.Load(_names[i])
	end
end

-- Uninstall all configuration data
function DataConfig.UnLoadAll()
	local _names = DataConfig.GetConfigNames()
	for i = 1, #_names do
		DataConfig.UnLoad(_names[i])
	end
end

function DataConfig.RemoveRequiredByName(preName)
    for key, _ in pairs(package.preload) do
        if string.find(tostring(key), preName) == 1 then
            package.preload[key] = nil
        end
    end
    for key, _ in pairs(package.loaded) do
        if string.find(tostring(key), preName) == 1 then
            package.loaded[key] = nil
        end
    end
end

return DataConfig
