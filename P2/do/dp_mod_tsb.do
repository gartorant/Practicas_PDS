onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dp_mod_tsb/PER
add wave -noupdate /dp_mod_tsb/rst_ac
add wave -noupdate /dp_mod_tsb/clk
add wave -noupdate /dp_mod_tsb/val_in
add wave -noupdate /dp_mod_tsb/conf_fm_am
add wave -noupdate /dp_mod_tsb/val_out
add wave -noupdate -divider Dp_File
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /dp_mod_tsb/data_in_file
add wave -noupdate -format Analog-Step -height 74 -max 32743.999999999996 -min -32767.0 /dp_mod_tsb/wave_F
add wave -noupdate -divider Dp_Model
add wave -noupdate -format Analog-Step -height 74 -max 32767.0 -min -32767.0 /dp_mod_tsb/in_data
add wave -noupdate -format Analog-Step -height 74 -max 16383.0 -min -16384.0 /dp_mod_tsb/wave_M
add wave -noupdate -format Analog-Step -height 74 -max 16383.0 -min -16384.0 /dp_mod_tsb/out_data_M
add wave -noupdate -divider Errores
add wave -noupdate -format Analog-Step -height 74 -max 38401.0 /dp_mod_tsb/in_sample_cnt
add wave -noupdate /dp_mod_tsb/out_sample_cnt
add wave -noupdate /dp_mod_tsb/error_cnt
add wave -noupdate /dp_mod_tsb/scan_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {4979401 ps} 0} {{Cursor 4} {2589982 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3289 ns} {6279 ns}
