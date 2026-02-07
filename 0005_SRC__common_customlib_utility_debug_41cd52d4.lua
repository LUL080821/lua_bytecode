------------------------------------------------
-- Author:
-- Date: 2019-04-08
-- File: Debug.lua
-- Module: Debug
-- Description: Lua end package of UnityEnging.Debug
------------------------------------------------
-- Get the Debug class of unity
local CSDebug = CS.UnityEngine.Debug

local Debug = {
    -- Whether the debugger has logging enabled (only for Lua side)
    IsLogging = true
}

-- Log a message to the Unity Console.
function Debug.Log(...)
    if not Debug.IsLogging then return end

    local _count = select('#', ...)
    if _count == 0 then
        CSDebug.Log(debug.traceback("==========[No parameters passed! ]==========="))
        return
    end
    local _str = nil
    local _argument = {...}
    for i = 1, _count do
        _str = _str and string.format("%s    %s", _str, _argument[i]) or
                   tostring(_argument[i])
    end
    _str = string.format("<color=#000000>%s</color>", _str)
    CSDebug.Log(debug.traceback(_str))
end

-- A variant of Debug.Log that logs an assertion message to the console.
function Debug.LogError(...)
    if not Debug.IsLogging then return end

    local _count = select('#', ...)
    if _count == 0 then
        CSDebug.LogError(
            debug.traceback("==========[No parameters passed! ]==========="))
        return
    end
    local _str = nil
    local _argument = {...}
    for i = 1, _count do
        _str = _str and string.format("%s    %s", _str, _argument[i]) or
                   tostring(_argument[i])
    end
    _str = string.format("<color=#000000>%s</color>", _str)
    CSDebug.LogError(debug.traceback(_str))
end

function Debug.LogTableWhite(tb, title, notSort)
    Debug.LogTable(tb, title, notSort, "000000")
end

function Debug.LogTableRed(tb, title, notSort)
    Debug.LogTable(tb, title, notSort, "000000")
end

function Debug.LogTableGreen(tb, title, notSort)
    Debug.LogTable(tb, title, notSort, "000000")
end

function Debug.LogTableYellow(tb, title, notSort)
    Debug.LogTable(tb, title, notSort, "000000")
end

-- Print table structure (tb:table, title: first row information displayed in the Console panel, notSort: keys sort, rgb: color displayed in the Console panel)
function Debug.LogTable(tb, title, notSort, rgb)
    if not Debug.IsLogging then return end
    local _format = string.format
    rgb = rgb or "000000"
    local fmtColor = "<color=#" .. rgb .. ">%s</color>"
    local strConcat = ""

    if not tb or type(tb) ~= "table" then
        strConcat = _format(fmtColor, tostring(tb) .. " " .. os.date("%H:%M:%S"))
        Debug.Log(strConcat)
        return
    end

    local str = {}
    local titleInfo = title or "table"
    table.insert(str, _format(fmtColor, "=========" .. titleInfo .. "=========[" .. os.date("%H:%M:%S") .. "]\n"));

    table.insert(str,Debug.GetTableStr(tb,notSort));

    table.insert(str, _format("\n=========== [%s]=========\n", titleInfo))

    strConcat = table.concat(str, "")
    CSDebug.Log(debug.traceback(strConcat));
end

-- Get the string of the table
function Debug.GetTableStr(tb,notSort)
    if not Debug.IsLogging then return end
    local _format = string.format
    local strConcat = ""

    if not tb or type(tb) ~= "table" then
        strConcat = tostring(tb) .. " " .. os.date("%H:%M:%S")       
        return strConcat;
    end

    local _insert = table.insert
    local _tostring = tostring

    local tabNum = 0
    local function stab(numTab) return string.rep("    ", numTab) end
    local str = {}

    local function _printTable(t)
        _insert(str, "{")
        tabNum = tabNum + 1

        local keys = {}
        for k, _ in pairs(t) do _insert(keys, k) end

        if not notSort then table.sort(keys) end

        local _v, _kk, _vv, _ktp, _vtp
        for _, k in pairs(keys) do
            _v = t[k]
            _ktp = type(k)
            if _ktp == "string" then
                _kk = "['" .. k .. "']"
            else
                _kk = "[" .. _tostring(k) .. "]"
            end

            _vtp = type(_v)

            if _vtp == "table" then
                _insert(str, _format("\n%s%s = ", stab(tabNum), _kk))
                _printTable(_v)
            else
                if _vtp == "string" then
                    _vv = _format("\"%s\"", _v)
                elseif _vtp == "number" or _vtp == "boolean" then
                    _vv = _tostring(_v)
                else
                    _vv = "['" .. _vtp .. "']"
                end

                if _ktp == "string" then
                    _insert(str,
                            _format("\n%s%-10s = %s,", stab(tabNum), _kk,
                                    string.gsub(_vv, "%%", "?")))
                else
                    _insert(str,
                            _format("\n%s%-4s = %s,", stab(tabNum), _kk,
                                    string.gsub(_vv, "%%", "?")))
                end
            end
        end
        tabNum = tabNum - 1

        if tabNum == 0 then
            _insert(str, "}")
        else
            _insert(str, "},")
        end
    end
    _printTable(tb)    
    strConcat = table.concat(str, "")
    return strConcat;
end

return Debug
