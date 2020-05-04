echo "Computing and plotting!"

call "set_variables.bat"


DEL /f output.csv
DEL /f *.pdf

echo "Running the experiments"

%NETLOGO_RUNNABLE_DIR% --model "%NETLOGO_MODEL%" --experiment "S6" --table "%OUTPUT_CSV%"

