#include "script_component.hpp"
/*
 * Author: Glowbal
 * Local callback for fully healing a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_fullHealLocal
 *
 * Public: No
 */

params ["_patient"];
TRACE_1("fullHealLocal",_patient);

if (!alive _patient) exitWith {};

// check if on fire, then put out the fire before healing
if ((["ace_fire"] call EFUNC(common,isModLoaded)) && {[_patient] call EFUNC(fire,isBurning)}) then {
    _patient setVariable [QEGVAR(fire,intensity), 0, true];
};

private _state = GET_SM_STATE(_patient);
TRACE_1("start",_state);

// Treatment conditions would normally limit full heal to non-unconscious units
// However, this may be called externally (through Zeus)
if IN_CRDC_ARRST(_patient) then {
    TRACE_1("Exiting cardiac arrest",_patient);
    [QEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
    _state = GET_SM_STATE(_patient);
    TRACE_1("after CPRSucceeded",_state);
};

//_patient setVariable [VAR_PAIN, 0, true];

// Wounds and Injuries
_patient setVariable [VAR_STITCHED_WOUNDS, [], true];
_patient setVariable [QEGVAR(medical,isLimping), false, true];

// Damage storage
_patient setVariable [QEGVAR(medical,bodyPartDamage), [0,0,0,0,0,0], true];

// wakeup needs to be done after achieving stable vitals, but before manually reseting unconc var
if IS_UNCONSCIOUS(_patient) then {
    if (!([_patient] call EFUNC(medical_status,hasStableVitals))) then { ERROR_2("fullheal [unit %1][state %2] did not restore stable vitals",_patient,_state); };
    TRACE_1("Waking up",_patient);
    [QEGVAR(medical,WakeUp), _patient] call CBA_fnc_localEvent;
    _state = GET_SM_STATE(_patient);
    TRACE_1("after WakeUp",_state);
    if IS_UNCONSCIOUS(_patient) then { ERROR_2("fullheal [unit %1][state %2] failed to wake up patient",_patient,_state); };
};

// Generic medical admin
// _patient setVariable [VAR_CRDC_ARRST, false, true]; // this should be set by statemachine transition
// _patient setVariable [VAR_UNCON, false, true]; // this should be set by statemachine transition
//_patient setVariable [VAR_IN_PAIN, false, true];

[_patient] call EFUNC(medical_engine,updateDamageEffects);

// Reset damage
_patient setDamage 0;

[QEGVAR(medical,FullHeal), _patient] call CBA_fnc_localEvent;
_state = GET_SM_STATE(_patient);
TRACE_1("after FullHeal",_state);
