local Network = {}

local pb = require("pb")
local CSNetworker = CS.Thousandto.Plugins.Common.Networker

-- Store all server response events [key: message id (enum), value: event] Only one response event can be created for a message.
local msgMap = {}
-- Store all types according to enumeration
local cmdMap = {}
-- Store all enums according to type
local msgIDMap = {}
-- Is it a re-registration message?
local isReRegisterMsg = false
-- Register received messages
local resMsgIDs = nil
local resMsgIDDic = nil
local resExtendMsgIDs = nil
local resExtendMsgIDDic = nil

-- Create a server message response event
function Network.CreatRespond(cmd, callback)
	if not cmd or not callback then
		Debug.LogError(string.format("Registration message error cmd = %s,callback = %s", cmd, callback))
		return
	end
	local _msgid = pb.enum(string.format("%s.MsgID", cmd), "eMsgID")

    if not _msgid then
		Debug.LogError(string.format("The message does not exist, please delete it manually %s", cmd))
		return
    end

	if msgMap[_msgid] and not isReRegisterMsg then
		Debug.LogError(string.format("Message Duplicate Registration cmd = %s", cmd))
		return
	end

	if _msgid <= 500000 then
		-- Messages that are less than 500,000 and are not in the registration list will not be processed through the Lua protocol.
		if resMsgIDs == nil then
			Network.GetResLuaMsgIDs()
		end
		-- Register the message for lua extension
		if resExtendMsgIDs == nil then
			Network.GetResLuaExtendMsgIDs()
		end
		if resMsgIDDic[_msgid] == nil and resExtendMsgIDDic[_msgid] == nil then
			return
		end
	end

	msgMap[_msgid] = callback
	cmdMap[_msgid] = cmd
	msgIDMap[cmd] = _msgid
end

-- Send message [Encoding-->Serialization-->Send]
function Network.Send(cmd, msg)
	msg = msg or {}
	if not cmd then
		Debug.LogError(string.format("Registration message error cmd = %s", cmd))
		return
	end

	if not msgIDMap[cmd] then
		msgIDMap[cmd] = pb.enum(string.format("%s.MsgID", cmd), "eMsgID")
		if not msgIDMap[cmd] then
			Debug.LogError(string.format("Message does not exist: %s",cmd))
			return
		end
	end

	local _code = pb.encode(cmd, msg)	
	CSNetworker.Instance:Send(_code, msgIDMap[cmd])
end

-- Process messages sent by the server
function Network.DoResMessage(msgid, bytes)
	local _cmd = cmdMap[msgid]
	if not _cmd then
		Debug.LogError(string.format("msgid = %s Message not registered", msgid))
		return
	end
	local _msg = pb.decode(_cmd, bytes)
	-- Save a MsgID
	_msg.MsgID = msgid
	msgMap[msgid](_msg)
	-- local _ok, _err = xpcall(function() msgMap[cmd](_msg) end, debug.traceback)
	-- if not _ok then
	-- end
end

-- Local simulation server
function Network.DoResTest(cmd, table)
	local msgid = msgIDMap[cmd]
	if not msgid then
		Debug.LogError(string.format("msgid = %s Message not registered", msgid))
		return
	end
	table.MsgID = msgid
	msgMap[msgid](table)
end

-- Get the message IDs of all Lua sides
function Network.GetResLuaMsgIDs()
	if resMsgIDs == nil then
		local resMsgCMDs = require("Network.ResMsgCMD")
		resMsgIDs = {}
		resMsgIDDic = {}
		for i=1, #resMsgCMDs do
			local _msgID = pb.enum(string.format("%s.MsgID", resMsgCMDs[i]), "eMsgID")
			if _msgID ~= nil then
				table.insert(resMsgIDs,_msgID )
				resMsgIDDic[_msgID] = true
			end
		end
	end
	return resMsgIDs
end

-- Get the message ID of all Lua-end extensions
function Network.GetResLuaExtendMsgIDs()
	if resExtendMsgIDs == nil then
		local resMsgCMDs = require("Network.ResMsgExtendCMD")
		resExtendMsgIDs = {}
		resExtendMsgIDDic = {}
		for i=1, #resMsgCMDs do
			local _msgID = pb.enum(string.format("%s.MsgID", resMsgCMDs[i]), "eMsgID")
			if _msgID ~= nil then
				table.insert(resExtendMsgIDs,_msgID )
				resExtendMsgIDDic[_msgID] = true
			end
		end
	end
	return resExtendMsgIDs
end

function Network.ReRegisterMsg(name)
	local _path = string.format("Network.Msg.%s", name)
	Utils.RemoveRequiredByName(_path)
	local _msgSystem = require(_path)
	if _msgSystem then
		isReRegisterMsg = true
		_msgSystem.RegisterMsg()
		isReRegisterMsg = false
	end
end

-- Register all messages
function Network.RegisterAllMsg()
	local _msgNames = require("Network.Msg.ResMsg.MsgNames")
	for i=1, #_msgNames do
		local _msgSystem = require(string.format("Network/Msg/ResMsg/%s", _msgNames[i]))
		if _msgSystem then
			_msgSystem.RegisterMsg()
		end
	end
end

-- initialization
function Network.Init(lite)
	if (lite == nil) then
		lite = false
	end
	if (CSNetworker.Instance.LiteNetwork ~=nil) then
		CSNetworker.Instance.LiteNetwork = lite
	end
	-- Load all protocol files
	local protoPaths = CSNetworker.GetAllProtoPath()
	local _count = protoPaths.Count - 1
	for i = 0, _count do
		local _path = protoPaths[i]
		local _isok = pb.load(_path)
	end

	Network.RegisterAllMsg()
end

function Network.GetMsgID(cmd)
	return pb.enum(string.format("%s.MsgID", cmd), "eMsgID")
end

-- Setting up IP and ports
function Network.GetIPAndPort()
	return CSNetworker.Instance.IP,CSNetworker.Instance.Port;
end
-- Setting up IP and ports
function Network.SetIPAndPort(ip,port)
	CSNetworker.Instance.IP = ip;
	CSNetworker.Instance.Port = port;
end

-- connect
function Network.Connect(func)
	CSNetworker.Instance:Connect(func);
end

-- Disconnect
function Network.Disconnect()
	CSNetworker.Instance:Disconnect();
end

-- Start threading
function Network.StartThread()
	CSNetworker.Instance:StartThread();
end

return Network