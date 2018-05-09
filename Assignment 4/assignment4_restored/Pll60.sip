set_global_assignment -entity "Pll60" -library "lib_Pll60" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "Pll60" -library "lib_Pll60" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "Pll60" -library "lib_Pll60" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_Pll60" -name SPD_FILE [file join $::quartus(sip_path) "Pll60.spd"]

set_global_assignment -library "lib_Pll60" -name MISC_FILE [file join $::quartus(sip_path) "Pll60_sim/Pll60.vo"]
