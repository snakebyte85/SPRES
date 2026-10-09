
private _missionName = getMissionConfigValue ["onLoadName", ""];

if(_missionName == "") exitWith {};

_compScript = "";

switch(true) do {

    case ("DUWS_T v1.6" in _missionName): { _compScript=SPRES_fnc_comp_DUWS_T_1_6; };
    case ("DUWS-T v2.0" in _missionName): { _compScript=SPRES_fnc_comp_DUWS_T_2_0; };

};



if(!(_compScript isEqualType "")) then {
    _compScriptName = [true] call _compScript;
    hint parseText format["<t size='2.0'>SPRES</t><br/><br/><t>Running compatibility module for mission %1</t>", _compScriptName];
    [false] call _compScript;
} else {
    format ["Can't find compatibility module for mission %1", _missionName] call SPRES_fnc_debug;
}