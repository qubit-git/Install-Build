@echo off
for /f "delims=" %%a in ('wmic LogicalDisk where "Caption='E:'" get FreeSpace /value ^| findstr "Free"')  do (set size=%%a)
set /a free=%size:~10,-10%+0
echo %free%
if %free% gtr 50 goto :eof
REM ==============Delete old builds==============
for /f "delims=" %%a in ('dir  "z:\bin_*" /b /o:-d')  do (set old=Z:\%%a\)
echo ====Start to delete folder %old% ===========
rd %old% /s/q
echo ====Folder %old% has been deleted===========
:eof