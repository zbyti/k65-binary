@echo off

..\..\bin\k65 @files.lst

if errorlevel 1 goto err
..\..\bin\Stella.exe a2600-tutorial-03.bin

:err
