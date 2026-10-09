
params ["_getName"];


if( _getName) exitWith { "DUWS T 1.6" };


_event = {
    private _inKillhouse = false;
    private _khX = missionNamespace getVariable ["killhouse_centerX", nil];
    private _khY = missionNamespace getVariable ["killhouse_centerY", nil];
    private _khZ = missionNamespace getVariable ["killhouse_centerZ", nil];
    if (!isNil "_khX" && !isNil "_khY" && !isNil "_khZ") then {
        private _deathPos = getPosWorld (_this select 0); // 死亡单位位置
        if (_deathPos distance [_khX, _khY, _khZ] < 300) then {
            _inKillhouse = true;
        };
    };
    if (!_inKillhouse) then {
        commandpointsblu1 = commandpointsblu1 - DUWSMP_CP_death_cost;
        publicVariable "commandpointsblu1";
    };
    [localize "STR_DUWS_T_actionteam", localize "STR_DUWS_T_playerdown"] remoteExec ["BIS_fnc_showSubtitle", 0];

};


[missionNamespace, "SPRES_playerKilled", _event] call BIS_fnc_addScriptedEventHandler;


