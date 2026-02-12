package dds_test_tsb_pkg; 
 
integer test_case = 101; // #case for test 
integer in_sample_num = 981; // #processed input samples 
 
parameter M = 16; // DDS accumulator wordlength
parameter L = 6; // DDS phase truncation wordlength
parameter W = 16; // DDS ROM wordlength
 
endpackage