# run the tcl script: do dds_test_tsb.tcl
vlog -work work -refresh -force_refresh
# List of files in order from bottom to top
set sv_files {../src/dds_test.sv 
			  ../tsb/dds_test_tsb_pkg.sv 
			  ../tsb/dds_test_tsb.sv}
# Compile all files
foreach sv_file $sv_files {
    vlog $sv_file
}
# Invoke simulator
vsim work.dds_test_tsb
# Open the wave editor 
do ./do/dds_test_tsb.do
# Run simulation 
run -all
