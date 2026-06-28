################################################################################
#
# Design name:  adaptive_pg_top
#
# Created by icc2 write_sdc on Sun Jun 28 20:37:45 2026
#
################################################################################

set sdc_version 2.1
set_units -time ns -resistance MOhm -capacitance fF -voltage V -current uA

################################################################################
#
# Units
# time_unit               : 1e-09
# resistance_unit         : 1000000
# capacitive_load_unit    : 1e-15
# voltage_unit            : 1
# current_unit            : 1e-06
# power_unit              : 1e-12
################################################################################


# Mode: default
# Corner: default
# Scenario: default

# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 11
create_clock -name clk -period 5 -waveform {0 2.5} [get_ports {clk}]
set_propagated_clock [get_clocks {clk}]
# Warning: Libcell power domain derates are skipped!

# Set latency for io paths.
# -origin useful_skew
set_clock_latency -rise -min 0.000305182 [get_clocks {clk}]
# -origin useful_skew
set_clock_latency -rise -max 0.000324256 [get_clocks {clk}]
# -origin useful_skew
set_clock_latency -fall -min 0.00013352 [get_clocks {clk}]
# -origin useful_skew
set_clock_latency -fall -max 0.000143058 [get_clocks {clk}]
# Set propagated on clock sources to avoid removing latency for IO paths.
set_propagated_clock  [get_ports {clk}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 12
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {clk}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 13
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {rst}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 14
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {req}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 15
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {op[3]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 16
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {op[2]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 17
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {op[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 18
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {op[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 19
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[31]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 20
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[30]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 21
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[29]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 22
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[28]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 23
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[27]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 24
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[26]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 25
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[25]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 26
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[24]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 27
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[23]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 28
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[22]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 29
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[21]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 30
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[20]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 31
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[19]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 32
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[18]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 33
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[17]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 34
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[16]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 35
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[15]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 36
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[14]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 37
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[13]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 38
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[12]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 39
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[11]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 40
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[10]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 41
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[9]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 42
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[8]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 43
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[7]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 44
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[6]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 45
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[5]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 46
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[4]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 47
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[3]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 48
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[2]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 49
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 50
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {a[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 51
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[31]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 52
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[30]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 53
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[29]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 54
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[28]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 55
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[27]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 56
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[26]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 57
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[25]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 58
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[24]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 59
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[23]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 60
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[22]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 61
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[21]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 62
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[20]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 63
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[19]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 64
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[18]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 65
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[17]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 66
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[16]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 67
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[15]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 68
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[14]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 69
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[13]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 70
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[12]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 71
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[11]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 72
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[10]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 73
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[9]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 74
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[8]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 75
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[7]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 76
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[6]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 77
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[5]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 78
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[4]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 79
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[3]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 80
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[2]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 81
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 82
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {b[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 84
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[31]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 85
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[30]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 86
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[29]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 87
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[28]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 88
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[27]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 89
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[26]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 90
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[25]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 91
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[24]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 92
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[23]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 93
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[22]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 94
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[21]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 95
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[20]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 96
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[19]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 97
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[18]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 98
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[17]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 99
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[16]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 100
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[15]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 101
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[14]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 102
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[13]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 103
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[12]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 104
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[11]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 105
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[10]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 106
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[9]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 107
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[8]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 108
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[7]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 109
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[6]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 110
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[5]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 111
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[4]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 112
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[3]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 113
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[2]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 114
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 115
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {result[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 116
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {valid}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 117
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {power_mode[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 118
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {power_mode[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 119
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {sleep_n}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 120
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {iso_en}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 121
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {footer_sel[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 122
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {footer_sel[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 123
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {rush_ctrl[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 124
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {rush_ctrl[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 125
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_done}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 126
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_timer[3]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 127
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_timer[2]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 128
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_timer[1]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 129
set_output_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_timer[0]}]
# /home/st160/VLSI-Project/vlsi-project/netlists/proposed/adaptive_pg_top_lp.sdc, \
#   line 83
set_input_delay -clock [get_clocks {clk}] 1 [get_ports {wakeup_req}]
set_max_transition 0.4 [current_design]
