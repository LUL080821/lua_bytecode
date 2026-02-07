/**
 * Frida Script: Hook Main.OnClientGM and Auto-Open GM UI
 * Target: Unity + XLua game (LTCC)
 * 
 * Usage:
 *   frida -U -f <package_name> -l frida_hook_clientgm.js --no-pause
 */

function log(msg) {
    console.log("[ClientGM] " + msg);
}

function hookXLua() {
    const xlua = Process.findModuleByName("libxlua.so");
    if (!xlua) {
        log("[ERROR] libxlua.so not found!");
        return;
    }
    log("Found libxlua.so at: " + xlua.base);

    // Find essential XLua functions
    const lua_getglobal = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_getglobal"),
        'void', ['pointer', 'pointer']
    );
    
    const lua_getfield = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_getfield"),
        'void', ['pointer', 'int', 'pointer']
    );
    
    const lua_pushstring = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_pushstring"),
        'pointer', ['pointer', 'pointer']
    );
    
    const lua_pushboolean = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_pushboolean"),
        'void', ['pointer', 'int']
    );
    
    const lua_pcall = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_pcall"),
        'int', ['pointer', 'int', 'int', 'int']
    );
    
    const lua_toboolean = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_toboolean"),
        'int', ['pointer', 'int']
    );
    
    const lua_tolstring = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_tolstring"),
        'pointer', ['pointer', 'int', 'pointer']
    );
    
    const lua_settop = new NativeFunction(
        Module.findExportByName("libxlua.so", "lua_settop"),
        'void', ['pointer', 'int']
    );

    log("XLua functions loaded");

    // Global lua_State storage
    let g_L = null;

    // ========== HOOK 1: Capture lua_State ==========
    Interceptor.attach(lua_getglobal, {
        onEnter: function(args) {
            g_L = args[0];
            const name = args[1].readCString();
            
            if (name === "Main" || name === "GameCenter") {
                log("Captured lua_State: " + g_L);
                log("Getting global: " + name);
            }
        }
    });

    // ========== HOOK 2: Intercept Main.OnClientGM ==========
    Interceptor.attach(lua_pcall, {
        onEnter: function(args) {
            this.L = args[0];
            this.nargs = args[1].toInt32();
            this.nresults = args[2].toInt32();
            
            // Try to read function name from stack
            if (this.nargs > 0) {
                const strPtr = lua_tolstring(this.L, -this.nargs, NULL);
                if (strPtr && !strPtr.isNull()) {
                    const cmd = strPtr.readCString();
                    if (cmd && cmd.startsWith("@@")) {
                        log("[DETECTED] GM Command: " + cmd);
                        this.isGMCommand = true;
                    }
                }
            }
        },
        onLeave: function(retval) {
            if (this.isGMCommand) {
                // Get original return value
                const origResult = lua_toboolean(this.L, -1);
                log("Original OnClientGM result: " + origResult);
                
                // Force return true
                lua_settop(this.L, -2); // Pop original result
                lua_pushboolean(this.L, 1); // Push true
                
                log("[PATCHED] Forced OnClientGM to return TRUE");
            }
        }
    });

    // ========== FUNCTION: Inject GM Command ==========
    function injectGMCommand(cmd) {
        if (!g_L || g_L.isNull()) {
            log("[ERROR] lua_State not captured yet!");
            return false;
        }

        log("Injecting GM command: " + cmd);

        try {
            // Get Main.OnClientGM function
            lua_getglobal(g_L, Memory.allocUtf8String("Main"));
            lua_getfield(g_L, -1, Memory.allocUtf8String("OnClientGM"));
            
            // Push command argument
            lua_pushstring(g_L, Memory.allocUtf8String(cmd));
            
            // Call Main.OnClientGM(cmd)
            const result = lua_pcall(g_L, 1, 1, 0);
            
            if (result === 0) {
                const success = lua_toboolean(g_L, -1);
                log("GM command executed: " + cmd + " -> " + (success ? "SUCCESS" : "FAILED"));
                lua_settop(g_L, -2); // Clean stack
                return success;
            } else {
                log("[ERROR] lua_pcall failed with code: " + result);
                return false;
            }
        } catch (e) {
            log("[EXCEPTION] " + e);
            return false;
        }
    }

    // ========== FUNCTION: Auto-Open GM UI ==========
    function tryOpenGMUI() {
        if (!g_L || g_L.isNull()) {
            log("[WAIT] lua_State not ready, retrying in 2s...");
            setTimeout(tryOpenGMUI, 2000);
            return;
        }

        log("=== Attempting to open GM UI ===");

        // Method 1: Try known GM commands
        const testCommands = [
            "@@faxingsucai@@",
            "@@gm@@",
            "@@debug@@",
            "@@admin@@",
            "@@cheats@@"
        ];

        for (let cmd of testCommands) {
            log("Testing command: " + cmd);
            injectGMCommand(cmd);
        }

        // Method 2: Try to open GM UI directly via event
        try {
            log("Trying direct UI event injection...");
            
            // GameCenter.PushFixEvent(UILuaEventDefine.UIDebugGMForm_OPEN)
            lua_getglobal(g_L, Memory.allocUtf8String("GameCenter"));
            lua_getfield(g_L, -1, Memory.allocUtf8String("PushFixEvent"));
            
            // Get UILuaEventDefine
            lua_getglobal(g_L, Memory.allocUtf8String("UILuaEventDefine"));
            lua_getfield(g_L, -1, Memory.allocUtf8String("UIDebugGMForm_OPEN"));
            
            // Call PushFixEvent
            const result = lua_pcall(g_L, 1, 0, 0);
            
            if (result === 0) {
                log("[SUCCESS] GM UI event pushed!");
            } else {
                log("[INFO] UIDebugGMForm_OPEN not found (expected)");
            }
        } catch (e) {
            log("UI event method failed: " + e);
        }

        // Method 3: Try common UI form names
        const uiForms = [
            "UIGMForm",
            "UIDebugForm",
            "UIGMPanel",
            "UICheatForm",
            "UIAdminForm"
        ];

        for (let formName of uiForms) {
            try {
                // GameCenter.UIFormManager:OpenForm(formName)
                lua_getglobal(g_L, Memory.allocUtf8String("GameCenter"));
                lua_getfield(g_L, -1, Memory.allocUtf8String("UIFormManager"));
                lua_getfield(g_L, -1, Memory.allocUtf8String("OpenForm"));
                lua_pushstring(g_L, Memory.allocUtf8String(formName));
                
                const result = lua_pcall(g_L, 2, 0, 0);
                if (result === 0) {
                    log("[SUCCESS] Opened UI: " + formName);
                }
                lua_settop(g_L, 0); // Clean stack
            } catch (e) {
                // Ignore errors, form might not exist
            }
        }
    }

    // ========== RPC EXPORTS ==========
    rpc.exports = {
        injectGM: function(cmd) {
            return injectGMCommand(cmd);
        },
        openGMUI: function() {
            tryOpenGMUI();
            return "GM UI open attempted";
        },
        getState: function() {
            return {
                luaState: g_L ? g_L.toString() : "null",
                xluaBase: xlua.base.toString()
            };
        }
    };

    log("RPC exports registered:");
    log("  - injectGM(cmd): Inject GM command");
    log("  - openGMUI(): Try to open GM UI");
    log("  - getState(): Get current state");

    // Auto-trigger after 5 seconds
    setTimeout(function() {
        log("=== AUTO-TRIGGER: Opening GM UI ===");
        tryOpenGMUI();
    }, 5000);
}

// ========== MAIN ENTRY ==========
setImmediate(function() {
    log("Script started");
    log("Waiting for libxlua.so to load...");
    
    const checkInterval = setInterval(function() {
        const xlua = Process.findModuleByName("libxlua.so");
        if (xlua) {
            clearInterval(checkInterval);
            log("libxlua.so detected!");
            hookXLua();
        }
    }, 500);
});

log("==================================");
log("ClientGM Hook Script Loaded");
log("Waiting for game initialization...");
log("==================================");
