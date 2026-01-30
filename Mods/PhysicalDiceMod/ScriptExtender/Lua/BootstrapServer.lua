-- BootstrapServer.lua
Ext.Utils.Print("=== PHYSICAL DICE MOD BOOTSTRAP LOADING ===")
Ext.Require("Server/RollInterceptor.lua")
Ext.Require("Server/BoostRollSystem.lua")
Ext.Require("Server/AutoTest.lua")
Ext.Require("Server/PhysicalDiceInput.lua")
Ext.Require("Server/PhysicalDiceMCM.lua")  -- MCM integration (optional, gracefully degrades if MCM not installed)
Ext.Utils.Print("=== PHYSICAL DICE MOD BOOTSTRAP LOADED ===")
