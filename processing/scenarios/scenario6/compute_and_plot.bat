echo "Computing and plotting!"

SET NETLOGO_RUNNABLE_DIR="D:\Program files\NetLogo 6.1.1\netlogo-headless.bat"
SET R_RUNNABLE="D:\Program files\R\R-4.0.0\bin\Rscript.exe"

SET NETLOGO_MODEL=%CURRENTDIR%/../../../simulation_model\covid-sim.nlogo
SET R_PROGRAM_DIR=%cd%
SET OUTPUT_CSV=%R_PROGRAM_DIR%/output.csv

DEL /f output.csv

echo "Running the experiments"
%NETLOGO_RUNNABLE_DIR% --model "%NETLOGO_MODEL%" --experiment "S6" --table "%OUTPUT_CSV%"

echo "Generating the plots"
%R_RUNNABLE% process_plots.R "%R_PROGRAM_DIR%"

echo "Task completed"

PAUSE

