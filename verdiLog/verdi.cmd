verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debLoadSimResult /home/st160/VLSI-Project/vlsi-project/tb_comparison.vcd.fsdb
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_comparison"
wvGetSignalSetScope -win $_nWave2 "/tb_comparison/dut_baseline"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvGetSignalSetScope -win $_nWave2 "/tb_comparison/dut_proposed"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvGetSignalSetScope -win $_nWave2 "/tb_comparison/dut_baseline"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_baseline/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvGetSignalSetScope -win $_nWave2 "/tb_comparison/dut_proposed"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_proposed/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_proposed/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvGetSignalClose -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetCursor -win $_nWave2 65036.416382 -snap {("G2" 0)}
wvRenameSignal -win $_nWave2 {/tb_comparison/dut_baseline/power_mode[1:0]} \
           {power_mode (baseline)}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvExpandBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetCursor -win $_nWave2 13264.005973 -snap {("G2" 0)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvCollapseBus -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvRenameSignal -win $_nWave2 {/tb_comparison/dut_proposed/power_mode[1:0]} \
           {power_mode (proposed)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvRenameSignal -win $_nWave2 {/tb_comparison/dut_baseline/sleep_n} \
           {sleep_n (baseline)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvRenameSignal -win $_nWave2 {/tb_comparison/dut_proposed/sleep_n} \
           {sleep_n (proposed)}
wvSelectGroup -win $_nWave2 {G2}
wvSetWindowTimeUnit -win $_nWave2 1.000000 ns
wvSearchNext -win $_nWave2
wvSearchPrev -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
verdiCaptureWindow -win $_nWave2
wvCapture -win $_nWave2 -file \
          "/home/st160/VLSI-Project/vlsi-project/paper/waveform_2.png"
verdiCloseDialog -win $_nWave2 -widget capturePreview
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
verdiCaptureWindow -win $_nWave2
wvCapture -win $_nWave2 -file \
          "/home/st160/VLSI-Project/vlsi-project/paper/waveform_3.png"
verdiCloseDialog -win $_nWave2 -widget capturePreview
debExit
