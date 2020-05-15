#!/usr/bin/env python3
"""
This python script counts how often a variable that comes from a slider, inputbox, chooser, or
switch in the NetLogo interface is used in a file. For this, it depends on the command line utility
`grep`.

You can execute this in the `simulation_model` directory of the ASSOCC project, and it does not use
any parameters.
"""
import glob
import subprocess

VAR_TYPES = set(['SLIDER', 'INPUTBOX', 'CHOOSER', 'SWITCH'])

found_variables = []

with open("covid-sim.nlogo", "r") as f:
    def skip_to_next():
        line = f.readline().strip()
        while line:
            line = f.readline().strip()
    done = False
    line = f.readline().strip()
    while line != "GRAPHICS-WINDOW":
        line = f.readline().strip()
    while not done:
        skip_to_next()
        type = f.readline().strip()
        if type in VAR_TYPES:
            f.readline()
            f.readline()
            f.readline()
            f.readline()
            found_variables.append(f.readline().strip())
        if type == '@#$#@#$#@':
            done = True

cmd = ['grep', '-F', '--count']
files = glob.glob('**/*.nls', recursive=True)
for variable in found_variables:
    output = subprocess.run(cmd + [variable] + files, capture_output=True, text=True).stdout
    print("Variable: " + variable)
    for line in output.split('\n'):
        if not line.endswith(':0'):
            print(line)
