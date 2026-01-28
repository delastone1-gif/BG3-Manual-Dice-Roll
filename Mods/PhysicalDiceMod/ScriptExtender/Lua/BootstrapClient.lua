-- BootstrapClient.lua
Ext.Utils.Print("=== PHYSICAL DICE CLIENT BOOTSTRAP LOADING ===")
Ext.Require("Client/PhysicalDiceClient.lua")
Ext.Require("Client/RollInterceptor.lua")
Ext.Require("Client/PhysicalDiceMCMClient.lua")  -- MCM keybinding integration (client-side)
Ext.Require("Client/PhysicalDiceUI.lua")  -- RE-ENABLED: Testing ImGui availability
Ext.Utils.Print("=== PHYSICAL DICE CLIENT BOOTSTRAP LOADED ===")
