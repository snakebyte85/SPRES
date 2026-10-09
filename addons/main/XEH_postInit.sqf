#include "script_component.hpp"

private _respawn = 0 call bis_fnc_missionRespawnType;

if(ismultiplayer || _respawn==0 || _respawn==1) exitWith{};

SPRES_playerRespawnTime = 0;
SPRES_playerAlive = true;
SPRES_playerKilled = false;

if(_respawn == 4 || _respawn == 5) then {
    enableTeamSwitch false;
};


if(SPRES_debug) then {
    private _respawnVehicle = getMissionConfigValue ["respawnVehicle", -1];
    private _respawnDelay = getMissionConfigValue ["respawnDelay", -1];
    private _respawnTemplates = getMissionConfigValue ["respawnTemplates", []];
    private _respawnButton = getMissionConfigValue ["respawnButton", []];
    private _respawnVehicleDelay = getMissionConfigValue ["respawnVehicleDelay", -1];
    private _respawnDialog = getMissionConfigValue ["respawnDialog", -1];
    private _respawnOnStart = getMissionConfigValue ["respawnOnStart", -1];

    format["respawn=%1, respawnVehicle=%2, respawnDelay=%3, respawnTemplates=%4, respawnButton=%5, respawnVehicleDelay=%6, respawnDialog=%7, respawnOnStart=%8", _respawn, _respawnVehicle, _respawnDelay, _respawnTemplates, _respawnButton, _respawnVehicleDelay, _respawnDialog, _respawnOnStart] call SPRES_fnc_debug;
};

// MAIN LOOP TO MANAGE THE RESPAWN COUNTER
[] spawn {
    private _respawn = 0 call bis_fnc_missionRespawnType;
    private _respawnTemplates = getMissionConfigValue ["respawnTemplates", []];
    while{true} do {
    
        if(SPRES_playerAlive == false) then {
            while{SPRES_playerRespawnTime > 0} do {            
                SPRES_playerRespawnTime = SPRES_playerRespawnTime - 1;
                format ["RESPAWN COUNT DOWN: %1",SPRES_playerRespawnTime] call SPRES_fnc_debug;
                sleep 1;
            };
            
            "Triggering singleplayer respawn because SPRES_playerRespawnTime < 0" call SPRES_fnc_debug;
            
            ["playerResurrectScript",[player]] spawn SPRES_fnc_selectRespawnTemplate;
            
            
            if(_respawn == 3 && !("MenuPosition" in _respawnTemplates)) then {
                _respawnMarkers = ((player call bis_fnc_getRespawnPositions) + ((player call bis_fnc_objectSide) call bis_fnc_getRespawnMarkers));
                if(count _respawnMarkers > 0) then {
                    [player, selectRandom _respawnMarkers] call BIS_fnc_moveToRespawnPosition;
                };                
            };
            
            SPRES_playerRespawnTime=0;
            SPRES_playerAlive = true;
            SPRES_playerKilled = false;
            player hideobject false;
			player enablesimulation true;
            player allowDamage true;
            player setUnconscious false;
            player setDamage 0;
            if (vehicle player == player) then {player switchmove "";};
        };
        sleep 1;
    };
};

// Event handler to prevent the player dying and trigger stuff
SPRES_EH_handleDamage = {
    params ['_unit', '_selection', '_damage', '_source', '_projectile', '_hitIndex', '_instigator', '_hitPoint'];
    
    if(SPRES_playerKilled) exitWith {0};
    
    // Check if the total damage will kill the unit
    private _totalDamage = (damage _unit) + _damage;
    
    if (_totalDamage >= 1) then {
        SPRES_playerKilled=true;
        private _respawn = 0 call bis_fnc_missionRespawnType;        
        if(_respawn == 4 || _respawn == 5) then {
            removeSwitchableUnit _unit;
            format["Possible switchable units are %1, group player is %2, units in group player are %3", switchableUnits, (group player), units (group player)] call SPRES_fnc_debug;
            
            if(_respawn == 5) then {

                if (count switchableUnits > 1) then {
                    _unit allowDamage false;
                    _unit setUnconscious true;
                    moveOut _unit; 
                    _damage = 0;
                    enableTeamSwitch true;                    
                    teamSwitch;
                    enableTeamSwitch false;
                };
                
                if (count switchableUnits == 1) then {
                    _unitToSwitch = switchableUnits select 0;
                    _unit allowDamage false;
                    _unit setUnconscious true;
                    moveOut _unit; 
                    _damage = 0;
                    [_unit, _unitToSwitch] spawn {
                        params ["_previousUnit", "_newUnit"];
                        selectPlayer _newUnit;
                         _newUnit addEventHandler ['HandleDamage', SPRES_EH_handleDamage];
                         SPRES_playerKilled=false;
                        sleep 2;
                        _previousUnit setDamage 1;
                        format ["Selected new player from %1 to %2 because %1 is dead", _previousUnit, _newUnit] call SPRES_fnc_debug;  
                    };
                };
            };
            
            if(_respawn == 4) then {
            
                _unitToSwitch = objnull;
                {
                    if (_x in (units (group player))) then {
                        _unitToSwitch = _x;
                        break;
                    }                   
                
                } forEach switchableUnits;
                
                if( !isNull(_unitToSwitch)) then {
                    _unit allowDamage false;
                    _unit setUnconscious true;
                    moveOut _unit; 
                    _damage = 0;
                    [_unit, _unitToSwitch] spawn {
                        params ["_previousUnit", "_newUnit"];
                        selectPlayer _newUnit;
                         _newUnit addEventHandler ['HandleDamage', SPRES_EH_handleDamage];
                         SPRES_playerKilled=false;
                        sleep 2;
                        _previousUnit setDamage 1;
                        format ["Selected new player from %1 to %2 because %1 is dead", _previousUnit, _newUnit] call SPRES_fnc_debug;  
                    };
                };
            };
            
        } else {        
            setAccTime 1;
            _unit allowDamage false;
            _unit setUnconscious true;
            moveOut _unit; 
            _damage = 0;
            _respawnDelay = getMissionConfigValue ["respawnDelay", -1];
            SPRES_playerAlive = false;
            SPRES_playerRespawnTime=_respawnDelay;
            [missionNamespace, "SPRES_playerKilled", [player]] call BIS_fnc_callScriptedEventHandler;
            ["playerRespawnScript",[player, _instigator, _respawnDelay]] spawn SPRES_fnc_selectRespawnTemplate;
        };
    };    
    _damage
};

// if SIDE or GROUP, I need to kill the previous unit and reset stuff, like adding again the handle damage event
addMissionEventHandler ["TeamSwitch", {
    params ["_previousUnit", "_newUnit"];
    private _respawn = 0 call bis_fnc_missionRespawnType;
    if(_respawn == 4 || _respawn == 5) then {
        _previousUnit setDamage 1;
        SPRES_playerKilled=false;
        _newUnit addEventHandler ['HandleDamage', SPRES_EH_handleDamage];
        format ["Teamswitched from %1 to %2 because %1 is dead", _previousUnit, _newUnit] call SPRES_fnc_debug;  
    };
}];

// function to replace the normal forceplayerrespawn
SPRES_forcePlayerRespawn = {
    _respawnDelay = getMissionConfigValue ["respawnDelay", -1];
    SPRES_playerAlive = false;
    SPRES_playerRespawnTime=_respawnDelay;
    ["playerRespawnScript",[player, objnull, _respawnDelay]] spawn SPRES_fnc_selectRespawnTemplate;
};

// at first adding the handle damage event handler to the player, I 
player addEventHandler ['HandleDamage', SPRES_EH_handleDamage];

// supporting the respawn on start
["initRespawnStart",[objnull,objnull,objnull]] spawn SPRES_fnc_selectRespawnTemplate;

// running the compatibility module
[] call SPRES_fnc_comp_process;


