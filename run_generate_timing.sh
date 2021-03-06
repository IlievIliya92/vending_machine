#!/bin/sh

if [ "$#" -ne 4 ]; then
    echo "Insuficient amount of arguments!"
	echo "### USAGE ###";
	echo "./run_generate_timing.sh <cell-width> <cell-height> <font-size> <line width>"
	echo "### Recommended USAGE"
	echo "./run_generate_timing.sh 1 48 25 4"
    exit;
fi

if [ -e ./vending_machine ]
then
	echo "Cleaning executable!"
	rm ./vending_machine
else
    echo "Executable not present";
fi

if [ -e ./timing_diagrams/timing_result.gif ]
then
	echo "Cleaning timing_diagram result!"
	rm ./timing_diagrams/timing_result.gif
else
    echo "Timing diagram not present";
fi

echo "Building app"
iverilog vending_machine_vlog_module.v -o vending_machine -Wall

if [ -e ./vending_machine ]
then
    echo "Building finished!";
else
    echo "Building Failed!";
    exit;
fi

echo "Executing vending_machine"
echo "####################################################"
echo "############## Vending machine output ##############"
./vending_machine
echo "####################################################"

echo "Parsing results"
drawtiming --output ./timing_diagrams/timing_result.gif ./timing_diagrams/out_log.txt --cell-width $1 -c $2 -f $3 -l $4
if [ -e ./timing_diagrams/timing_result.gif ]
then
	echo "Timing diagram saved to ./timing_diagrams/timing_result.gif"
else
    echo "Failed to generate timing_diagrams!";
    exit;
fi
echo "Opening timing diagrams..."
xdg-open ./timing_diagrams/timing_result.gif

