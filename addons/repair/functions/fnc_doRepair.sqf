/*
 * Author: commy2
 * Called by repair action / progress bar. Raise events to set the new hitpoint damage.
 *
 * Arguments:
 * 0: Unit that does the repairing <OBJECT>
 * 1: Vehicle to repair <OBJECT>
 * 2: Selected hitpointIndex <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit, vehicle, 6, "MiscRepair"] call ace_repair_fnc_doRepair
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_vehicle", "_hitPointIndex"];
TRACE_3("params",_unit,_vehicle,_hitPointIndex);

// Hunter'z Economy Interface
private _HzInitHitpointsDamage = (getAllHitPointsDamage _vehicle) select 2;
private _count = count _HzInitHitpointsDamage;
private _HzInitDamage = 0;
{

	_HzInitDamage = _HzInitDamage + _x;

} foreach _HzInitHitpointsDamage;
_HzInitDamage = _HzInitDamage / _count;

private _HzCost = (typeof _vehicle) call Hz_econ_vehStore_fnc_getVehCost;
if (_HzCost == -1) exitwith {hint "No spare parts available for this vehicle!"};
_HzCost = _HzCost *_HzInitDamage;
if (Hz_econ_funds < _HzCost) exitwith {hint "Insufficient funds for repairs!"};

private _postRepairDamageMin = [_unit] call FUNC(getPostRepairDamage);

(getAllHitPointsDamage _vehicle) params ["_allHitPoints"];
private _hitPointClassname = _allHitPoints select _hitPointIndex;

// get current hitpoint damage
private _hitPointCurDamage = _vehicle getHitIndex _hitPointIndex;

// repair a max of 0.5, don't use negative values for damage
private _hitPointNewDamage = (_hitPointCurDamage - 0.5) max _postRepairDamageMin;

if (_hitPointNewDamage < _hitPointCurDamage) then {
    // raise event to set the new hitpoint damage
    TRACE_3("repairing main point", _vehicle, _hitPointIndex, _hitPointNewDamage);
    [QGVAR(setVehicleHitPointDamage), [_vehicle, _hitPointIndex, _hitPointNewDamage], _vehicle] call CBA_fnc_targetEvent;
    _hitPointCurDamage = _hitPointNewDamage;
};

// Get hitpoint groups if available
private _hitpointGroupConfig = configFile >> "CfgVehicles" >> typeOf _vehicle >> QGVAR(hitpointGroups);
if (isArray _hitpointGroupConfig) then {
    // Retrieve hitpoint subgroup if current hitpoint is main hitpoint of a group
    {
        _x params ["_masterHitpoint", "_subHitArray"];
        // Exit using found hitpoint group if this hitpoint is leader of any
        if (_masterHitpoint == _hitPointClassname) exitWith {
            {
                private _subHitpoint = _x;
                private _subHitIndex = _allHitPoints findIf {_x == _subHitpoint}; //convert hitpoint classname to index
                if (_subHitIndex == -1) then {
                    ERROR_2("Invalid hitpoint %1 in hitpointGroups of %2",_subHitpoint,_vehicle);
                } else {
                    private _subPointCurDamage = _vehicle getHitIndex _hitPointIndex;
                    private _subPointNewDamage = (_subPointCurDamage - 0.5) max _postRepairDamageMin;
                    if (_subPointNewDamage < _subPointCurDamage) then {
                        TRACE_3("repairing sub point", _vehicle, _subHitIndex, _subPointNewDamage);
                        [QGVAR(setVehicleHitPointDamage), [_vehicle, _subHitIndex, _subPointNewDamage], _vehicle] call CBA_fnc_targetEvent;
                    };
                };
            } forEach _subHitArray;
        };
    } forEach (getArray _hitpointGroupConfig);
};

// display text message if enabled
if (GVAR(DisplayTextOnRepair)) then {
    // Find localized string
    private _textLocalized = localize ([LSTRING(RepairedHitPointFully), LSTRING(RepairedHitPointPartially)] select (_hitPointCurDamage > 0));
    private _textDefault = localize ([LSTRING(RepairedFully), LSTRING(RepairedPartially)] select (_hitPointCurDamage > 0));
    ([_hitPointClassname, _textLocalized, _textDefault] call FUNC(getHitPointString)) params ["_text"];

    // Display text
    [_text] call EFUNC(common,displayTextStructured);
};

	// Hunter'z Economy Interface
	[_vehicle,_HzInitDamage] spawn {
	
		_vehicle = _this select 0;
		_HzInitDamage = _this select 1;
		
		sleep 2;
		
		_HzEndHitpointsDamage = (getAllHitPointsDamage _vehicle) select 2;
		_count = count _HzEndHitpointsDamage;
		_HzEndDamage = 0;
		{

			_HzEndDamage = _HzEndDamage + _x;

		} foreach _HzEndHitpointsDamage;
		_HzEndDamage = _HzEndDamage / _count;
		
		_HzCost = (_HzInitDamage - _HzEndDamage)* ((typeof _vehicle) call Hz_econ_vehStore_fnc_getVehCost);
		Hz_econ_funds = Hz_econ_funds - _HzCost;
		publicVariable "Hz_econ_funds";
		hint format ["Repair cost: $%1",_HzCost];
	
	};
