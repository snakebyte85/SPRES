[west, "Blufor1"] call BIS_fnc_addRespawnInventory;
[west, "Blufor2"] call BIS_fnc_addRespawnInventory;

[missionnamespace, 3] call BIS_fnc_respawnTickets;



player addEventHandler ["killed", {
    systemchat "killed event handler";
    diag_log "SPRES->killed event handler";
}];