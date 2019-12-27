#include "script_component.hpp"
/*
 * Author: PabstMirror (based on repack from commy2, esteldunedain, Ruthberg)
 * Simulates repacking a set of magazines.
 * Returns the timing and magazines counts at every stage.
 *
 * Arguments:
 * 0: Arguments [classname,lastAmmoStatus,events] <ARRAY>
 * 1: Elapsed Time <NUMBER>
 * 2: Total Time Repacking Will Take <NUMBER>
 * 3: Error Code <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * (args from progressBar) call ace_magazinerepack_fnc_magazineRepackFinish
 *
 * Public: No
 */

params ["_args", "_elapsedTime", "_totalTime", "_errorCode"];
_args params ["_magazineClassname", "_lastAmmoCount","_simEvents","_totalNumOfMags"];

private _fullMagazineCount = getNumber (configFile >> "CfgMagazines" >> _magazineClassname >> "count");

// Count mags
private _fullMags = 0;
private _partialMags = 0;
private _bulletsLeft = 0;
private _newMagsCount = 0;
{
    _x params ["_classname", "_count"];
		
		if (_classname == _magazineClassname) then {

			_newMagsCount = _newMagsCount + 1;

			if (_count > 0) then {
					if (_count == _fullMagazineCount) then {
							_fullMags = _fullMags + 1;
					} else {
							_partialMags = _partialMags + 1;
							_bulletsLeft = _count;
					};
			};
		
		};
} forEach (magazinesAmmoFull ACE_player);

//add empty magazines
private _magsMissing = _totalNumOfMags - _newMagsCount;
if (_magsMissing > 0) then {
	for "_i" from 1 to _magsMissing do {		
		if (ACE_player canAdd _magazineClassname) then {
			 ACE_player addMagazine [_magazineClassname,0];
		} else {		
			switch (true) do {			
				case (_magazineClassname in (getArray (configfile >> "cfgWeapons" >> primaryWeapon ACE_player >> "magazines"))) : {				
					ACE_player addWeaponItem [primaryWeapon ACE_player, [_magazineClassname,0]];				
				};				
				case (_magazineClassname in (getArray (configfile >> "cfgWeapons" >> secondaryWeapon ACE_player >> "magazines"))) : {				
					ACE_player addWeaponItem [secondaryWeapon ACE_player, [_magazineClassname,0]];				
				};				
				case (_magazineClassname in (getArray (configfile >> "cfgWeapons" >> handgunWeapon ACE_player >> "magazines"))) : {				
					ACE_player addWeaponItem [handgunWeapon ACE_player, [_magazineClassname,0]];				
				};						
			};						
		};	
	};	
};

// Don't show anything if player can't interact
if (!([ACE_player, objNull, ["isNotInside", "isNotSitting", "isNotSwimming"]] call EFUNC(common,canInteractWith))) exitWith {};

private _structuredOutputText = if (_errorCode == 0) then {
    private _repackedMagsText = format [localize LSTRING(RepackedMagazinesDetail), _fullMags, _bulletsLeft];
    format ["<t align='center'>%1</t><br/>%2", localize LSTRING(RepackComplete), _repackedMagsText];
} else {
    private _repackedMagsText = format [localize LSTRING(RepackedMagazinesCount), _fullMags, _partialMags];
    format ["<t align='center'>%1</t><br/>%2", localize LSTRING(RepackInterrupted), _repackedMagsText];
};

private _picture = getText (configFile >> "CfgMagazines" >> _magazineClassname >> "picture");
[_structuredOutputText, _picture, nil, nil, 2.5] call EFUNC(common,displayTextPicture);
