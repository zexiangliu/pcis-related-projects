#! /bin/csh -f
# Clear the DISPLAY.
#unsetenv DISPLAY # unset DISPLAY for some shells
env --unset=DISPLAY
export GRB_LICENSE_FILE=home/gurobi.lic

# Call MATLAB with the appropriate input and output,
# make it immune to hangups and quits using ''nohup'',
# and run it in the background.
nohup matlab -nodisplay -nodesktop -nojvm -nosplash -r $1 > $2 &
