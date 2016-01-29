@echo off
if not exist z: (subst z: E:\View)

for /f "delims=" %%a in ('dir  "\\was-cc2-tech\cm_bld1\10.3.0000.0*" /b /o:d')  do (set CASTORNO=%%~nxa)
echo %CASTORNO%
if not exist "z:\BIN\updateok.txt" goto :Installnewbuild

z:\bin\mstrver mstrsvr|findstr "file_version" > e:\version.txt

for /f "delims=\>< tokens=3" %%i in (e:\version.txt) do (set localno=%%i & goto :b)
:b
echo %localno%

if %CASTORNO% neq %localno% (goto :Installnewbuild)
:eof


:Installnewbuild
echo "---------start to install new build now----------------"

if not exist "\\was-cc2-tech\cm_bld1\%CASTORNO%\DEBUG\BIN\updateok.txt"  goto :debugnotready
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

pushd z:
rename BIN BIN_%localno%
xcopy /s \\was-cc2-tech\cm_bld1\%CASTORNO%\DEBUG\BIN z:\BIN\ /e/y


:Configweb

c:\tomcat\bin\shutdown.bat

if not exist \\was-cc2-tech\cm_bld1\%CASTORNO%\bin\MicroStrategy.war goto :eof
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

:eof