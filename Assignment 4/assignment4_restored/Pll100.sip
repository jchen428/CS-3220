set_global_assignment -entity "Pll100" -library "lib_Pll100" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "Pll100" -library "lib_Pll100" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "Pll100" -library "lib_Pll100" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_Pll100" -name SPD_FILE [file join $::quartus(sip_path) "Pll100.spd"]

set_global_assignment -library "lib_Pll100" -name MISC_FILE [file join $::quartus(sip_path) "Pll100_sim/Pll100.vo"]
