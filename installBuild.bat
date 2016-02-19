@echo off
if not exist z: (subst z: E:\View)

REM for /f "delims=" %%a in ('dir  "\\was-cc2-tech\cm_bld1\10.3.0000.0*" /b /o:d')  do (set CASTORNO=%%~nxa)

for /f "delims=" %%a in ('dir  "\\was-cc2-tech\cm_bld1\10.3.00*" /b /o:-d')  do (if exist \\was-cc2-tech\cm_bld1\%%~nxa\DEBUG\bin\updateok.txt (set CASTORNO=%%~nxa& goto :over))
:over
echo \\was-cc2-tech\cm_bld1\%CASTORNO%\DEBUG\BIN
if not exist "z:\BIN\updateok.txt" goto :Installnewbuild

REM z:\bin\mstrver mstrsvr|findstr "file_version" > e:\version.txt

REM for /f "delims=\>< tokens=3" %%i in (e:\version.txt) do (set localno=%%i & goto :b)

for /f "delims=\>< tokens=3" %%i in ('z:\bin\mstrver mstrsvr ^|findstr "file_version"') do (set localno=%%i & goto :b)

:b
echo %localno%

if %CASTORNO% neq %localno% (goto :Installnewbuild)
goto :eof


:Installnewbuild
echo "---------start to install new build now----------------"

rem if not exist "\\was-cc2-tech\cm_bld1\%CASTORNO%\DEBUG\BIN\updateok.txt"  goto :debugnotready
goto :iserver
:debugnotready
echo "-------------Debug is not ready!!!----------------"
GOTO :eof


:iserver

taskkill /f /im mstrdesk.exe /t
taskkill /f /im mstrsvr.exe /t
taskkill /f /im m8mulprc_64.exe /t
taskkill /f /im madbquerytool.exe /t
taskkill /f /im mjmulprc_32.exe /t
taskkill /f /im mjmulprc_64.exe /t
pushd z:\
if exist z:\bin (rename BIN BIN_%localno% & goto :copy)
echo "==========Copy start=========="
:copy
xcopy /ey \\was-cc2-tech\cm_bld1\%CASTORNO%\DEBUG\BIN z:\BIN\ 1>nul

echo "==========Copy end=========="
:Configweb

c:\tomcat\bin\shutdown.bat

if not exist \\was-cc2-tech\cm_bld1\%CASTORNO%\bin\MicroStrategy.war goto :checkSpace
mv "%CATALINA_HOME%\webapps\MicroStrategy" %CATALINA_HOME%\MicroStrategy_%localno%
rd "%CATALINA_HOME%\webapps\MicroStrategy" /s/q
copy \\was-cc2-tech\cm_bld1\%CASTORNO%\bin\MicroStrategy.war %CATALINA_HOME%\webapps\

c:\tomcat\bin\startup.bat


:reg
pushd Z:\3rdParty
@CALL Register
@set BIT64=YES
pushd Z:\BuildScripts
@CALL SetInstallRegistry
@CALL perl SetRegistry.pl
@CALL perl BldDocCli.pl -d 908


REM ========Check disk space===========
:checkSpace
for /f "delims=" %%a in ('wmic LogicalDisk where "Caption='E:'" get FreeSpace /value ^| findstr "Free"')  do (set size=%%a)
set /a free=%size:~10,-10%+0
echo %free%
if %free% gtr 30 goto :eof
REM ==============Delete old builds==============
for /f "delims=" %%a in ('dir  "z:\bin_*" /b /o:-d')  do (set old=Z:\%%a\)
echo ====Start to delete folder %old% ===========
rd %old% /s/q
echo ====Folder %old% has been deleted===========

:eof