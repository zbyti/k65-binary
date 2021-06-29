@echo off

..\..\bin\k65 @files.lst

if errorlevel 1 goto err
..\..\bin\Stella.exe ataventure.bin

:err
