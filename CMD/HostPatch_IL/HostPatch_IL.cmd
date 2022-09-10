@echo off & setlocal
set "VBS=%Temp%\HostPatch.vbs"
pushd "%~dp0"
call :CheckForAdmin || (
call :Restart "%~f0"
goto :Terminate
)

for /f "Tokens=2*" %%a in ('Reg Query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DataBasePath') Do call set "HostPath=%%b\hosts"
attrib -s -r -h "%HostPath%" >nul 2>nul
set "BlokDomain=support.image-line.com"
call :FindDomain
set "BlokDomain=rss.image-line.com"
call :FindDomain
del "%VBS%" 1>nul 2>&1
ipconfig /flushdns >nul

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

:FindDomain
find /c /i "0.0.0.0 %BlokDomain%" "%HostPath%" >nul 2>nul
if %errorlevel% neq 0 (
echo %BlokDomain% adding to %HostPath%.
echo.>>"%HostPath%"
echo 0.0.0.0 %BlokDomain%>>"%HostPath%"
) else (
echo %BlokDomain% is already in %HostPath%.
)
echo.
exit /b 0
