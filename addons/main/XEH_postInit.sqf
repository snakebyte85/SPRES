#include "script_component.hpp"

private _respawn = 0 call bis_fnc_missionRespawnType;

if(ismultiplayer || _respawn==0 || _respawn==1) exitWith{};

SPRES_playerRespawnTime = 0;
SPRES_playerAlive = true;
SPRES_menuPositionOpened = false;
SPRES_respawnPhase=0;
SPRES_debug=true;

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

[] spawn {
    private _respawn = 0 call bis_fnc_missionRespawnType;
    while{true} do {
    
        if(SPRES_playerAlive == false) then {
            sleep 5;
            while{SPRES_playerRespawnTime > 0} do {            
                SPRES_playerRespawnTime = SPRES_playerRespawnTime - 1;
                missionnamespace setvariable ["RscRespawnCounter_Custom", SPRES_playerRespawnTime];
                sleep 1;
            };
            
            if(SPRES_respawnPhase == 0) then {
                SPRES_respawnPhase=1;
                _respawnDelay = getMissionConfigValue ["respawnDelay", -1];
                SPRES_playerRespawnTime=_respawnDelay;
                ["playerRespawnScript",[player]] spawn SPRES_fnc_selectRespawnTemplate;
                
            } else {
            
                "Triggering singleplayer respawn because SPRES_playerRespawnTime < 0" call SPRES_fnc_debug;
                
                if(_respawn == 3) then {
                    if(SPRES_menuPositionOpened) then {                
                        // Move player to proper position
                        _list = uiNamespace getVariable "BIS_RscRespawnControlsMap_ctrlLocList";

                        if (missionNamespace getVariable ["BIS_RscRespawnControlsSpectate_shown", false]) then {_list = uiNamespace getVariable "BIS_RscRespawnControlsSpectate_ctrlLocList"};

                        _curSel = if !(lbCurSel _list < 0) then {lbCurSel _list} else {0};

                        if !(isNil {uiNamespace getVariable "BIS_RscRespawnControls_posMetadata"}) then
                        {
                            _metadata = ["get",_curSel] call BIS_fnc_showRespawnMenuPositionMetadata;
                            _identity = (_metadata select 0) select 0;

                            // Metadata function returns an empty array in some cases (usually start of a mission and waiting for respawn), in that case skip this (script error with undefined variable would appear otherwise)
                            if !(isNil "_identity") then {[player,_identity] call BIS_fnc_moveToRespawnPosition};
                        };
                        ["close"] call BIS_fnc_showRespawnMenu;
                        SPRES_menuPositionOpened=false;
                    } else {
                        [player,((player call bis_fnc_getRespawnPositions) + ((player call bis_fnc_objectSide) call bis_fnc_getRespawnMarkers)) select 0] call BIS_fnc_moveToRespawnPosition;
                    };
                };
                
                ("SPRES_fnc_respawnCounter" call bis_fnc_rscLayer) cuttext ["","plain"];
                
                SPRES_playerRespawnTime=0;
                SPRES_playerAlive = true;
                SPRES_respawnPhase=0;
                player allowDamage true;
                player setUnconscious false;
                player setDamage 0;
            };
        };
        sleep 1;
    };
};


(uiNamespace getVariable ["BIS_RscRespawnControlsSpectate_ctrlHeaderRespawnButton", controlNull]) ctrlAddEventhandler ["ButtonDown",{		//header respawn button used, store current selections and respawn player

				uiNamespace setVariable ["BIS_RscRespawnControls_selected",[lbCurSel (uiNamespace getVariable "BIS_RscRespawnControlsSpectate_ctrlLocList"),lbCurSel (uiNamespace getVariable "BIS_RscRespawnControlsSpectate_ctrlRoleList"),lbCurSel (uiNamespace getVariable "BIS_RscRespawnControlsSpectate_ctrlComboLoadout")]];
				if (lbCurSel (uiNamespace getVariable ["BIS_RscRespawnControlsSpectate_ctrlLocList", controlNull]) >= 0) then {SPRES_playerRespawnTime = 0};
			}];


player addEventHandler ['HandleDamage', {
    params ['_unit', '_selection', '_damage', '_source', '_projectile', '_hitIndex', '_instigator', '_hitPoint'];
    if( _damage >= 0.95) then {
        private _respawn = 0 call bis_fnc_missionRespawnType;        
        if(_respawn == 4 || _respawn == 5) then {
            format["Possible switchable units are %1", switchableUnits] call SPRES_fnc_debug;
            _unitToSwitch = objnull;
            {
                if(_respawn == 5) then {
                    _unitToSwitch = _x;
                    break;
                } else {
                    if (_x in (units (group player))) then {
                        _unitToSwitch = _x;
                        break;
                    }
                }                   
            
            } forEach switchableUnits;
            
            if( !isNull(_unitToSwitch)) then {
                enableTeamSwitch false;
                selectPlayer _unitToSwitch;
                enableTeamSwitch true;
            };
          
        } else {        
            setAccTime 1;
            _unit allowDamage false;
            //_unit setCaptive true;
            _unit setUnconscious true;
            //if (isPlayer _unit) then {enableTeamSwitch false} else {removeSwitchableUnit _unit};
            moveOut _unit; 
            _damage = 0;
            //_respawnDelay = getMissionConfigValue ["respawnDelay", -1];
            SPRES_playerAlive = false;
            SPRES_playerRespawnTime=1;
            ["playerKilledScript",[player, _instigator]] spawn SPRES_fnc_selectRespawnTemplate;
        };
    };    
    _damage;
}];
