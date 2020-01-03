#include "script_component.hpp"
/*
 * Author: GitHawk
 * Rearms a vehicle on the turret owner.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Unit <OBJECT>
 * 2: Turret Path <ARRAY>
 * 3: Number of magazines <NUMBER>
 * 4: Magazine Classname <STRING>
 * 5: Number of rounds <NUMBER>
 * 6: Pylon Index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [vehicle, player, [-1], 2, "5000Rnd_762x51_Belt", 500, ""] call ace_rearm_fnc_rearmSuccessLocal
 *
 * Public: No
 */

params ["_vehicle", "_unit", "_turretPath", "_numMagazines", "_magazineClass", "_numRounds", "_pylon"];
TRACE_7("rearmSuccessLocal",_vehicle,_unit,_turretPath,_numMagazines,_magazineClass,_numRounds,_pylon);

private _rounds = getNumber (configFile >> "CfgMagazines" >> _magazineClass >> "count");

// Hunter'z Economy Interface
private _HzEconRunning = !isnil "Hz_econ_funds";
private _HzAmmoUnitCost = 0;
if (_HzEconRunning) then {
	private _HzAmmoClass = getText (configfile >> "cfgMagazines" >> _magazineClass >> "ammo");
	_HzAmmoUnitCost = _HzAmmoClass call Hz_econ_combatStore_fnc_getAmmoPrice;	
};
if (_HzAmmoUnitCost == -1) exitwith {"This type of ammo is not in stock!" remoteExecCall ["hint",_unit,false];};

if (_pylon > 0) exitWith {

    if (GVAR(level) == 1) then {
		
				// Fill magazine completely
        if (_turretPath isEqualTo [-1]) then {_turretPath = [];}; // Convert back to pylon turret format

        TRACE_2("",_pylon,_magazineClass,_rounds);
		
				private _HzCost = _rounds*_HzAmmoUnitCost;

				if (_HzEconRunning && {Hz_econ_funds < _HzCost}) then {
		
					"Insufficient funds!" remoteExecCall ["hint",_unit,false];
					
				} else {
				
					if (_HzEconRunning) then {
			
						Hz_econ_funds = Hz_econ_funds - _HzCost;
						publicVariable "Hz_econ_funds";
						private _hint = format ["Rearm cost: $%1",_HzCost];
						_hint remoteExecCall ["hint",_unit,false];
						
					};
				
					TRACE_3("",_pylon,_magazineClass,_rounds);
					_vehicle setPylonLoadOut [_pylon, _magazineClass, true, _turretPath];
					[QEGVAR(common,displayTextStructured), [[LSTRING(Hint_RearmedTriple), _rounds,
						getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
            getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")], 3, _unit], [_unit]] call CBA_fnc_targetEvent;
						
			  };
						
    } else {
		
        // Fill only at most _numRounds
        if (_turretPath isEqualTo [-1]) then {_turretPath = [];}; // Convert back to pylon turret format
        private _currentCount = _vehicle ammoOnPylon _pylon;
        private _newCount = ((_currentCount max 0) + _numRounds) min _rounds;
				
        TRACE_2("",_pylon,_magazineClass,_newCount);
				
				// Hunter'z Economy Interface
				private _HzRoundsAdded = _newCount - _currentCount;
				private _HzCost = _HzRoundsAdded*_HzAmmoUnitCost;
				
				if (_HzEconRunning && {Hz_econ_funds < _HzCost}) then {
					
					"Insufficient funds!" remoteExecCall ["hint",_unit,false];
					
				} else {
				
					if (_HzEconRunning) then {
				
							Hz_econ_funds = Hz_econ_funds - _HzCost;
							publicVariable "Hz_econ_funds";
							private _hint = format ["Rearm cost: $%1",_HzCost];
							_hint remoteExecCall ["hint",_unit,false];
							
					};
				
        TRACE_3("",_pylon,_magazineClass,_newCount);
				
        _vehicle setPylonLoadOut [_pylon, _magazineClass, true, _turretPath];
        _vehicle setAmmoOnPylon [_pylon, _newCount];
        [QEGVAR(common,displayTextStructured), [[LSTRING(Hint_RearmedTriple), _numRounds,
            getText(configFile >> "CfgMagazines" >> _magazineClass >> "displayName"),
            getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")], 3, _unit], [_unit]] call CBA_fnc_targetEvent;
						
				};
						
    };
};

private _currentRounds = 0;
private _maxMagazines = [_vehicle, _turretPath, _magazineClass] call FUNC(getMaxMagazines);
private _ammoCounts = [_vehicle, _turretPath, _magazineClass] call FUNC(getTurretMagazineAmmo);
TRACE_3("start",_magazineClass,_maxMagazines,_ammoCounts);

private _ammoToAdd = if (GVAR(level) == 2) then {_numRounds} else {_rounds};

// Hunter'z Economy Interface
private _HzCost = _ammoToAdd*_HzAmmoUnitCost;

if (_HzEconRunning && {Hz_econ_funds < _HzCost}) exitWith {

	"Insufficient funds!" remoteExecCall ["hint",_unit,false];

};

private _ammoAdded = 0;
private _arrayModified = false; // skip needing to remove and re-add mags, if we are only adding new ones

{
    if (_x < _rounds) then {
        private _xAdd = _ammoToAdd min (_rounds - _x);
        _ammoToAdd = _ammoToAdd - _xAdd;
        _ammoAdded = _ammoAdded + _xAdd;
        TRACE_3("adding to existing mag",_forEachIndex,_x,_xAdd);
        _ammoCounts set [_forEachIndex, _x + _xAdd];
        _arrayModified = true;
    };
} forEach _ammoCounts;

while {((count _ammoCounts) < _maxMagazines) && {_ammoToAdd > 0}} do {
    private _xAdd = _ammoToAdd min _rounds;
    _ammoToAdd = _ammoToAdd - _xAdd;
    _ammoAdded = _ammoAdded + _xAdd;
    _ammoCounts pushBack _xAdd;
    if (!_arrayModified) then {
        TRACE_1("adding new mag to array",_xAdd);
    } else {
        TRACE_1("adding new mag directly",_xAdd);
        _vehicle addMagazineTurret [_magazineClass, _turretPath, _xAdd];
    };
};
TRACE_3("finish",_ammoToAdd,_ammoAdded,_arrayModified);
if (_arrayModified) then { // only need to call this if we modified the array, otherwise they are already added
    [_vehicle, _turretPath, _magazineClass, _ammoCounts] call FUNC(setTurretMagazineAmmo);
};

if (_ammoAdded == 0) exitWith {ERROR_1("could not load any ammo - %1",_this);};

// Hunter'z Economy Interface
if (_HzEconRunning) then {
	Hz_econ_funds = Hz_econ_funds - _HzCost;
	publicVariable "Hz_econ_funds";
	private _hint = format ["Rearm cost: $%1",_HzCost];
	_hint remoteExecCall ["hint",_unit,false];
};

[QEGVAR(common,displayTextStructured), [[LSTRING(Hint_RearmedTriple), _ammoAdded,
_magazineClass call FUNC(getMagazineName),
getText(configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName")], 3, _unit], [_unit]] call CBA_fnc_targetEvent;
