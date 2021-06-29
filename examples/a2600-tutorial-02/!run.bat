@echo off

..\..\bin\k65 @files.lst

if errorlevel 1 goto err
..\..\bin\Stella.exe a2600-tutorial-02.bin

:err
