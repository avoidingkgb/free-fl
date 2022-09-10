@echo off & setlocal
set "VBS=%Temp%\HostPatch.vbs"
pushd "%~dp0"
call :CheckForAdmin || (
call :Restart "%~f0"
goto :Terminate
)

set rParam=Image-Line
set rKey=HKCU\SOFTWARE\Image-Line\Shared\Paths
Reg Query "%rKey%" /v "%rParam%" 2>nul >nul && goto :FLStudio
set rKey=HKLM\SOFTWARE\Image-Line\Shared\Paths
Reg Query "%rKey%" /v "%rParam%" 2>nul >nul && goto :FLStudio
echo FL Studio install path not found.& goto :Shared

:FLStudio
for /f "Tokens=2*" %%a in ('Reg Query "%rKey%" /v "%rParam%"') Do call set "BlockDir=%%b"
call :BlockRules

:Shared
set rParam=Shared DLLs
set rKey=HKCU\SOFTWARE\Image-Line\Shared\Paths
Reg Query "%rKey%" /v "%rParam%" 2>nul >nul && goto :SharedData
set rKey=HKLM\SOFTWARE\Image-Line\Shared\Paths
Reg Query "%rKey%" /v "%rParam%" 2>nul >nul && goto :SharedData
echo FL Studio shared path not found.& goto :End

:SharedData
for /f "Tokens=3*" %%a in ('Reg Query "%rKey%" /v "%rParam%"') Do call set "BlockDir=%%b"
call :BlockRules

:End
del "%VBS%" 1>nul 2>&1
echo.& echo Close this window or press any key to exit . . .& pause >nul

:Terminate
popd
exit /b 0

:CheckForAdmin
net session 1>nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:Restart
for /f "tokens=2 delims==" %%a in ('wmic OS get CodeSet /format:list') do set /a "ACP=%%~a"
for /f "tokens=2 delims=.:" %%a in ('chcp') do set /a "OEMCP=%%a"
if "%ACP%" neq "" if "%ACP%" neq "0" chcp %ACP% >nul
> "%VBS%" echo.Set objShell = CreateObject("Shell.Application")
>>"%VBS%" echo.
>>"%VBS%" echo.strApplication = "cmd.exe"
>>"%VBS%" echo.strArguments   = "/c ""%~1"""
>>"%VBS%" echo.
>>"%VBS%" echo.objShell.ShellExecute strApplication, strArguments, "", "runas", 1
if "%OEMCP%" neq "" if "%OEMCP%" neq "0" chcp %OEMCP% >nul
cscript /nologo "%VBS%"
exit /b 0

:BlockRules
set /a c=0
netsh advfirewall set allprofiles state on >nul
for /r "%BlockDir%" %%a in (*.exe) do (
netsh advfirewall firewall delete rule name="Blocked  %%a" >nul
netsh advfirewall firewall add rule name="Blocked  %%a" dir=out program="%%a" action=block >nul
set /a c+=1
)
echo Blocked: %BlockDir%*.exe - %c% Rules
exit /b 0
