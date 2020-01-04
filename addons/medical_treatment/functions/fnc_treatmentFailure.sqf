#include "script_component.hpp"
/*
 * Author: KoffeinFlummi, Glowbal, mharis001
 * Handles treatment process failure.
 *
 * Arguments:
 * 0: Arguments <ARRAY>
 *   0: Medic <OBJECT>
 *   1: Patient <OBJECT>
 *   2: Body Part <STRING>
 *   3: Treatment <STRING>
 *   4: Item User <OBJECT>
 *   5: Used Item <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_args"];
_args params ["_medic", "_patient", "_bodyPart", "_classname", "_itemUser", "_usedItem"];

// Return used item to user (if used)
if (!isNull _itemUser) then {
    [_itemUser, _usedItem] call EFUNC(common,addToInventory);
};

// Switch medic to end animation immediately
private _endInAnim = _medic getVariable QGVAR(endInAnim);

if (!isNil "_endInAnim") then {
    if (animationState _medic != _endInAnim) then {
        [_medic, _endInAnim, 2] call EFUNC(common,doAnimation);
    };

    _medic setVariable [QGVAR(endInAnim), nil];
};

// Reset medic animation speed coefficient
[QEGVAR(common,setAnimSpeedCoef), [_medic, 1]] call CBA_fnc_globalEvent;

if (!isNil QEGVAR(advanced_fatigue,setAnimExclusions)) then {
    EGVAR(advanced_fatigue,setAnimExclusions) deleteAt (EGVAR(advanced_fatigue,setAnimExclusions) find QUOTE(ADDON));
};

// Reset patient animation -- experimental
if ((alive _patient) && {!(_patient getVariable ["ACE_isUnconscious", false])} && {(vehicle _patient) == _patient} && {!(_patient call EFUNC(common,isSwimming))}) then {
	[_patient, "AinvPpneMstpSlayWpstDnon", 2] call EFUNC(common,doAnimation);
};

if (_patient != _medic) then {
	_patient setVariable [QEGVAR(medical,isBeingTreatedByCount),(_patient getVariable [QEGVAR(medical,isBeingTreatedByCount),0]) - 1,true];
};

// Call treatment specific failure callback
GET_FUNCTION(_callbackFailure,configFile >> QGVAR(actions) >> _classname >> "callbackFailure");

_args call _callbackFailure;
