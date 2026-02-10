onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dds_test_tsb/P
add wave -noupdate /dds_test_tsb/load_data
add wave -noupdate /dds_test_tsb/in_sample_cnt
add wave -noupdate -divider ENTRADAS
add wave -noupdate /dds_test_tsb/rst_ac
add wave -noupdate /dds_test_tsb/en_ac
add wave -noupdate /dds_test_tsb/clk
add wave -noupdate /dds_test_tsb/val_in
add wave -noupdate -divider SALIDAS
add wave -noupdate /dds_test_tsb/val_out
add wave -noupdate /dds_test_tsb/sin_wave
add wave -noupdate /dds_test_tsb/ramp_wave
add wave -noupdate /dds_test_tsb/sqr_wave
add wave -noupdate -format Analog-Step -height 74 -max 8191.0 -min -8192.0 -radix decimal /dds_test_tsb/sin_wave_M
add wave -noupdate -format Analog-Step -height 74 -max 8191.0 -min -8191.0 -radix decimal /dds_test_tsb/sin_wave_F
add wave -noupdate -format Analog-Step -height 74 -max 7644.0000000000009 -min -7854.0 -radix decimal /dds_test_tsb/ramp_wave_M
add wave -noupdate -format Analog-Step -height 74 -max 8156.9999999999991 -min -8175.0 -radix decimal /dds_test_tsb/ramp_wave_F
add wave -noupdate -radix decimal /dds_test_tsb/sqr_wave_M
add wave -noupdate -format Analog-Step -height 74 -max 8191.0 -min -8191.0 -radix decimal /dds_test_tsb/sqr_wave_F
add wave -noupdate -divider {CUENTAS DE ERRORES}
add wave -noupdate /dds_test_tsb/error_cnt
add wave -noupdate /dds_test_tsb/sample_cnt
add wave -noupdate /dds_test_tsb/end_sim
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {139232 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 295
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2759772 ps}
