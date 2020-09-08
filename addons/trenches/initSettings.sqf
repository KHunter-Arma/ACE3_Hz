// Trenches dig/remove durations
[
    QGVAR(smallEnvelopeDigDuration), 
    "TIME", 
    [LSTRING(SmallEnvelopeDigDuration_DisplayName), LSTRING(SmallEnvelopeDigDuration_Description)],
    LSTRING(Category),
    [5, 600, 200], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(smallEnvelopeRemoveDuration), 
    "TIME", 
    [LSTRING(SmallEnvelopeRemoveDuration_DisplayName), LSTRING(SmallEnvelopeRemoveDuration_Description)],
    LSTRING(Category),
    [5, 600, 30], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(bigEnvelopeDigDuration), 
    "TIME", 
    [LSTRING(BigEnvelopeDigDuration_DisplayName), LSTRING(BigEnvelopeDigDuration_Description)],
    LSTRING(Category),
    [5, 600, 360], 
    true
] call CBA_fnc_addSetting;

[
    QGVAR(bigEnvelopeRemoveDuration), 
    "TIME", 
    [LSTRING(BigEnvelopeRemoveDuration_DisplayName), LSTRING(BigEnvelopeRemoveDuration_Description)],
    LSTRING(Category),
    [5, 600, 50], 
    true
] call CBA_fnc_addSetting;
