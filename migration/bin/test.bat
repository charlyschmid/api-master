@echo off

setlocal

:loop
if not "%1"=="" (
   if "%1"=="-lot" (
      set LOT=%2
      shift
   )
   if "%1"=="-migmode" (
      set MIG_MODE=%2
      shift
   )
   shift
   goto :loop
)

echo LOT %LOT%
echo MIG_MODE %MIG_MODE%

endlocal
