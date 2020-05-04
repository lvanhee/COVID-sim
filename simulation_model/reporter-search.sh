#!/bin/sh

fgrep -n -e "to $1" -e "to-report $1" *.nlogo *.nls */*.nls
