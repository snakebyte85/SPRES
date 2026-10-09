#include "script_mod.hpp"

private _category = 'SinglePlayerRESpawn VERSION';

[
    "SPRES_debug",
    "CHECKBOX",
    ["Enable Debug","Enable Extra Debug logging"],
    _category,
    false
] call CBA_fnc_addSetting;