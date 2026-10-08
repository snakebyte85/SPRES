
params ["_msg"];

if (SPRES_debug) then { 
    _finalMsg = format["[SPRES]-> %1", _msg];
    systemChat _finalMsg;
    diag_log _finalMsg;
};
