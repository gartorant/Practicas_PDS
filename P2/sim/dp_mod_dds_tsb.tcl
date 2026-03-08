# run the tcl script: do dp_mod_dds_tsb.tcl
vlog -work work -refresh -force_refresh
# List of files in order from bottom to top
set sv_files {../src/dp_mod.sv 
			  ../src/dp_mod_dds.sv 
			  ../tsb/dp_mod_tsb_pkg.sv
			  ../tsb/dp_mod_tsb.sv}
# Compile all files
foreach sv_file $sv_files {
    vlog $sv_file
}
# Invoke simulator
vsim work.dds_test_tsb
# Open the wave editor 
do ./do/dp_mod_tsb.do
# Run simulation 
run -all
