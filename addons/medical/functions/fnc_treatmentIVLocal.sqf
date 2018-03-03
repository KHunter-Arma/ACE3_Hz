/*
 * Author: Glowbal
 * IV Treatment local callback
 *
 * Arguments:
 * 0: The medic <OBJECT>
 * 1: Treatment classname <STRING>
 *
 *
 * Return Value:
 * None
 *
 * Example:
 * [medic, "Classname"] call ace_medical_fnc_treatmentIVLocal
 *
 * Public: Yes
 */

#include "script_component.hpp"

params ["_target", "_treatmentClassname"];

private _bloodVolume = _target getVariable [QGVAR(bloodVolume), 100];
if (_bloodVolume >= 100) exitWith {};

// Find the proper attributes for the used IV
private _config = (configFile >> "ACE_Medical_Advanced" >> "Treatment" >> "IV");
private _volumeAdded = getNumber (_config >> "volume");
private _typeOf = getText (_config >> "type");

if (isClass (_config >> _treatmentClassname)) then {
    _config = (_config >> _treatmentClassname);
    if (isNumber (_config >> "volume")) then { _volumeAdded = getNumber (_config >> "volume");};
    if (isText (_config >> "type")) then { _typeOf = getText (_config >> "type"); };
} else {
    ERROR("IV Treatment Classname not found");
};

private _bloodBags = _target getVariable [QGVAR(ivBags), []];
_bloodBags pushBack [_volumeAdded]; // Future BagType: [_volumeAdded, _typeOf]
_target setVariable [QGVAR(ivBags), _bloodBags, true];

if (isPlayer _target) then {

	_target spawn {

		if (isnil "ace_medical_IVAnimTestRunning") then {		
			ace_medical_IVAnimTestRunning = false;	
		};	
		if (ace_medical_IVAnimTestRunning) exitWith {};
		ace_medical_IVAnimTestRunning = true;

		//put weapon on back (or anim doesn't work)
		_this call ace_common_fnc_fixLoweredRifleAnimation;
		_this action ["SwitchWeapon", _this, _this, 299];

		//prevent unit re-equipping weapon and forcing animation exit
		_this showHUD false;
		
		_this playMoveNow "AinjPpneMstpSnonWnonDnon";
		
		waitUntil {(animationState _this) == "ainjppnemstpsnonwnondnon"};

		while {(alive _this) && !((_this getVariable [QGVAR(ivBags),[]]) isEqualTo [])} do {

			//prevent unit from interacting (e.g. gearing) with something and forcing animation exit
			closeDialog 0;
			
			//disable interaction menu
			closeDialog 314412;
			
			//there are still many exploits so force animation if player managed to escape...
			if ((animationState _this) != "ainjppnemstpsnonwnondnon") then {
			
				_this call ace_common_fnc_fixLoweredRifleAnimation;
				_this action ["SwitchWeapon", _this, _this, 299];		
				_this playMoveNow "AinjPpneMstpSnonWnonDnon";
				
				waitUntil {(animationState _this) == "ainjppnemstpsnonwnondnon"};
			
			};

		};
		
		_this showHUD true;
		ace_medical_IVAnimTestRunning = false;

	};

};