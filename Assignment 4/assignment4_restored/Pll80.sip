set_global_assignment -entity "Pll80" -library "lib_Pll80" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "Pll80" -library "lib_Pll80" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "Pll80" -library "lib_Pll80" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_Pll80" -name SPD_FILE [file join $::quartus(sip_path) "Pll80.spd"]

set_global_assignment -library "lib_Pll80" -name MISC_FILE [file join $::quartus(sip_path) "Pll80_sim/Pll80.vo"]
