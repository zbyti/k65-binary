@echo off

..\..\bin\k65 @Derivative_2600.lst

if errorlevel 1 goto err
..\..\bin\Stella.exe Derivative2600.bin

:err
