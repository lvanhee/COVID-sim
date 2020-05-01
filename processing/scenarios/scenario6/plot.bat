echo "Computing and plotting!"

call "set_variables.bat"

DEL /f *.pdf

echo "Generating the plots"

%R_RUNNABLE% process_plots.R "%R_PROGRAM_DIR%"

echo "Task completed"
