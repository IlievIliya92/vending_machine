#!/bin/sh

echo "Building app"
iverilog vending_machine_vlog_module.v -o vending_machine
echo "Building finished!"
echo "Executing vending_machine"
echo "####################################################"
echo "############## Vending machine output ##############"
./vending_machine
echo "####################################################"
echo "Parsing results"
drawtiming --output ./timing_diagrams/timing_result.gif ./timing_diagrams/out_log.txt --cell-width 1
echo "Timing diagram saved to ./timing_diagrams/timing_result.gif"
echo "Opening timing diagrams"
xdg-open ./timing_diagrams/timing_result.gif

