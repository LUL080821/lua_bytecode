------------------------------------------------
-- Author: 
-- Date: 2019-03-25
-- File: AppConfig.lua
-- Module: AppConfig
-- Description: Application configuration definition
------------------------------------------------
-- //Module definition
local AppConfig =
{
	-- Whether to delete the ui prefabricated parts when the form is closed
	IsDestroyPrefabOnClose = false,
	-- Whether to run the analysis tool
	IsRuntimeProfiler = false,
	-- Whether it is recorded time-consuming to write files
	IsRecordWriteFile = false,
	-- Whether to collect time
	IsCollectRecord = false,
	IsShowCutScene = false,
}

return AppConfig