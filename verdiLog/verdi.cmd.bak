verdiWindowResize -win $_Verdi_1 "660" "34" "704" "700"
verdiWindowResize -win $_Verdi_1 "660" "34" "704" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debLoadSimResult /home/st160/VLSI-Project/vlsi-project/tb_comparison.vcd.fsdb
verdiSetActWin -dock widgetDock_<Inst._Tree>
verdiDockWidgetMaximize -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiDockWidgetRestore -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
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
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvGetSignalSetScope -win $_nWave2 "/tb_comparison/dut_proposed"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_proposed/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_comparison/dut_baseline/power_mode\[1:0\]} \
{/tb_comparison/dut_proposed/power_mode\[1:0\]} \
{/tb_comparison/dut_baseline/sleep_n} \
{/tb_comparison/dut_proposed/sleep_n} \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvGetSignalClose -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvSetWindowTimeUnit -win $_nWave2 1.000000 ns
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
verdiCaptureWindow -win $_nWave2
wvCapture -win $_nWave2 -file \
          "/home/st160/VLSI-Project/vlsi-project/paper/tb_comp_waveform.png"
verdiCloseDialog -win $_nWave2 -widget capturePreview
debExit
