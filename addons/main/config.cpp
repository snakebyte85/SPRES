#include "script_component.hpp"

class CfgPatches
{
	class ADDON
	{
		name = CSTRING(component);
		units[] = {};
		weapons[] = {};
		requiredVersion = REQUIRED_VERSION;
		requiredAddons[] = { "CBA_main" };
		author = "snakebyte";
		url = "https://community.bistudio.com/wiki";
		VERSION_CONFIG;
	};
};

#define BASE_PATH_FN MAINPREFIX\PREFIX\addons\COMPONENT\functions


class CfgFunctions {
    class PREFIX {
        class BIS {
            file = QUOTE(BASE_PATH_FN\bis);
            class respawnMenuPosition {};
            class showRespawnMenu {};
            class showRespawnMenuHeader {};
            class selectRespawnTemplate {};
            class respawnCounter {};
        };
        
        class misc {
            file = QUOTE(BASE_PATH_FN\misc);
            class debug {};
        };
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_postInit));
    };
};


class CfgRespawnTemplates {
    
    class MenuPosition {
        onPlayerKilledSPRES="SPRES_fnc_respawnMenuPosition";
        onPlayerRespawnSPRES="SPRES_fnc_respawnMenuPosition";
    };
    
    class Counter {
        onPlayerKilledSPRES="SPRES_fnc_respawnCounter";
        onPlayerRespawnSPRES="SPRES_fnc_respawnCounter";        
    };
    
   
};

class CfgScriptPaths {
        
    SPRES=QUOTE(BASE_PATH_FN\bis\);
    
};

class RscTitles {
    
    class RscRespawnCounter {
        
    };

    class SPRES_RscRespawnCounter: RscRespawnCounter {
        scriptPath="SPRES";
        scriptName="SPRES_RscRespawnCounter";
        onLoad = "[""onLoad"",_this,""SPRES_RscRespawnCounter"",'SPRES'] call 	(uinamespace getvariable 'BIS_fnc_initDisplay')";
    };

};