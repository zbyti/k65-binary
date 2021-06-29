@echo off

..\..\bin\k65 @ascend.lst

if errorlevel 1 goto err
..\..\bin\Stella.exe ascend-demo.bin

:err
