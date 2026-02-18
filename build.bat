@echo off

setlocal

echo Build GST Deployment for Production
set builddate=%date:~6,4%%date:~3,2%%date:~0,2%
set buildrelease=release%builddate%
set buildpath=C:\Deployment\%buildrelease%
set sourcepath=c:\gsttg
set logfile=C:\oracle\admin\frinst1\logs\%buildrelease%.log
set copypath=\\tsclient\C\Deployment\%buildrelease%

:buildstart
echo Start Build %builddate%
if exist %buildpath% goto buildcopyfiles
echo Create new directory for deployment %buildpath%
mkdir %buildpath%

:buildcopyfiles
echo robocopy all GST files from %sourcepath% to %buildpath%
robocopy %sourcepath% %buildpath% * /s /purge /log:%logfile% /tee /np

:buildcopytoclient
echo Copy to TG27641
if exist %copypath% echo Updating existing directory on TG27641
robocopy %buildpath% %copypath% * /s /purge /log+:%logfile% /tee /np

echo End Build %builddate%
echo Logfile created %logfile%

endlocal
echo on
