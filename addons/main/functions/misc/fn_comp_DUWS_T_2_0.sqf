
params ["_getName"];


if( _getName) exitWith { "DUWS T 2.0" };


_event = {
    private _inKillhouse = false;
    private _khX = missionNamespace getVariable ["killhouse_centerX", nil];
    private _khY = missionNamespace getVariable ["killhouse_centerY", nil];
    private _khZ = missionNamespace getVariable ["killhouse_centerZ", nil];
    if (!isNil "_khX" && !isNil "_khY" && !isNil "_khZ") then {
        private _deathPos = getPosWorld (_this select 0);
        if (_deathPos distance [_khX, _khY, _khZ] < 300) then {
            _inKillhouse = true;
        };
    };
    if (!_inKillhouse) then {
        [-DUWSMP_CP_death_cost, "death_penalty"] remoteExec ["fnc_cp_adjust", 2];
        // Told to the player who paid it: the deduction itself only ever reached the RPT and
        // control 1000 (the request dialog's counter, invisible unless that dialog is open),
        // leaving CP gone from the pool with nothing on screen. Skipped at zero, which the
        // campaign menu can still select. Spawned because an event-handler body is unscheduled
        // and the notification queue is not.
        if (DUWSMP_CP_death_cost > 0) then {
            [DUWSMP_CP_death_cost] spawn {
                params ["_cost"];
                ["CPlost", [_cost]] call bis_fnc_showNotification;
            };
        };
        // The consumable slate dies with the body. Inside the killhouse it does not, for the same
        // reason the CP penalty is waived there: a training death is not a battlefield one.
        [] call fnc_support_wipe;
    };

};


[missionNamespace, "SPRES_playerKilled", _event] call BIS_fnc_addScriptedEventHandler;


