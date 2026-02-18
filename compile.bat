@echo off
setlocal

set FORMS_PATH=C:\gsttg\forms;C:\gsttg\images

cd C:\gsttg\forms

set _debug=yes
set _cmd=frmcmp batch=yes window_state=minimize userid=gsttg/probe@gsttest
set _formopt=compile_all=yes debug=%_debug%
set _menuopt=module_type=menu compile_all=yes debug=%_debug%
set _libopt=module_type=library

echo -----------------------------------------------------------------
echo Alte Kompilate löschen
echo -----------------------------------------------------------------
if exist *.err del /f/q *.err
if exist *.fmx del /f/q *.fmx
if exist *.plx del /f/q *.plx
if exist *.mmx del /f/q *.mmx

echo -----------------------------------------------------------------
echo Compile *.pll
echo -----------------------------------------------------------------
for %%f in (*.pll) do (
   copy /y %%f %%f.save > :nul
   echo %_cmd% %_libopt% module=%%f
   %_cmd% %_libopt% module=%%f
   del /f/q %%f
   ren %%f.save %%f
)

echo -----------------------------------------------------------------
echo Compile *.mmb
echo -----------------------------------------------------------------
for %%f in (*.mmb) do (
   copy /y %%f %%f.save > :nul  
   echo %_cmd% %_menuopt% module=%%f
   %_cmd% %_menuopt% module=%%f
   del /f/q %%f
   ren %%f.save %%f
)

echo -----------------------------------------------------------------
echo Compile *.fmb
echo -----------------------------------------------------------------
for %%f in (*.fmb) do (
   copy /y %%f %%f.save > :nul
   echo %_cmd% %_formopt% module=%%f
   %_cmd% %_formopt% module=%%f
   del /f/q %%f
   ren %%f.save %%f
)

endlocal
echo on
