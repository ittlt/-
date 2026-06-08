# Update ILA IP probe0 width to 32 bits
set proj_dir "D:/FPGAmoudle/--main/--main/vivado_project/DDS_Signal_Generator"

# Open project
open_project $proj_dir.xpr

# Update ILA IP configuration
set_property -dict [list \
    CONFIG.C_PROBE0_WIDTH {32} \
] [get_ips ila_0]

# Regenerate output products
generate_target all [get_files ila_0.xci]

puts "ILA IP updated: probe0 width changed to 32 bits"
