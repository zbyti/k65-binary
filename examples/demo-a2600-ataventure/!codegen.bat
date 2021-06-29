@echo off
gawk -f _codegen.awk >rotogen.c26
gawk -f _codegen2.awk >rotogen2.c26
gawk -f _codegen3.awk >proctungen.c26
gawk -f _cubecoregen.awk >cubegen.c26
pause
