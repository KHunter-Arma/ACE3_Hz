/*
 * Author: Glowbal
 * Fully repairs vehicle.
 *
 * Arguments:
 * 0: Unit that does the repairing (not used) <OBJECT>
 * 1: Vehicle to repair <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit, vehicle] call ace_repair_fnc_doFullRepair
 *
 * Public: No
 */
#include "script_component.hpp"

params ["", "_vehicle"];
TRACE_1("params",_vehicle);

// Hunter'z Economy Interface
private _HzInitHitpointsDamage = (getAllHitPointsDamage _vehicle) select 2;
private _count = count _HzInitHitpointsDamage;
private _HzInitDamage = 0;
{

	_HzInitDamage = _HzInitDamage + _x;

} foreach _HzInitHitpointsDamage;
_HzInitDamage = _HzInitDamage / _count;

private _HzCost = ((typeof _vehicle) call Hz_econ_vehStore_fnc_getVehCost)*_HzInitDamage;
if (Hz_econ_funds < _HzCost) exitwith {hint "Insufficient funds for repairs!"};

_vehicle setDamage 0;

// Hunter'z Economy Interface
_HzCost = _HzInitDamage*((typeof _vehicle) call Hz_econ_vehStore_fnc_getVehCost);
Hz_econ_funds = Hz_econ_funds - _HzCost;
publicVariable "Hz_econ_funds";
hint format ["Repair cost: $%1",_HzCost];
