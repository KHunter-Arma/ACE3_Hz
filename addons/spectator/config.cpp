#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {QGVAR(virtual)};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"F3 Project","Head","kymckay","voiper"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "ACE_Settings.hpp"
#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"
#include "ui.hpp"

class CfgRespawnTemplates {
    class ADDON {
        displayName = CSTRING(Settings_DisplayName);
        onPlayerKilled = QFUNC(respawnTemplate);
        onPlayerRespawn = QFUNC(respawnTemplate);
        respawnTypes[] = {1,2,3,4,5};
    };
};
