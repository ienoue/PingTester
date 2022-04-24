rem Ping Tester

@echo off
pushd %~dp0
setlocal enabledelayedexpansion
title Ping Tester

rem Number of echo requests to send
set requestNum=3


:OnRetry
cls
echo Ping Tester & echo.
call :showSelfIP

set IPListFile=IPList.txt
if not exist %IPListFile% (
    echo ERROR:
    echo      %IPListFile% Is Not Found
    pause
    exit /b
)
echo. & echo ============================================= & echo.
echo Start Ping ^(%requestNum% requests per IP^)
echo. & echo ============================================= & echo.
for /f "usebackq tokens=1,* delims=	 " %%i in ("%IPListFile%") do (
	call :sendPingTo %%i %%j %requestNum%
)

choice /m "Retry"
if %errorlevel% == 1 (
	goto OnRetry
)
exit /b


:showSelfIP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4" ^| findstr /v /c:" 192.168." /c:" 169.254."') do (
	set selfIPs=!selfIPs!%%i,
)
if defined selfIPs (
	echo Your IP Address Is:         !selfIPs!
	if defined previousIPs (
		if not "!previousIPs!" == "!selfIPs!" (
			echo Your Previous IP Address Is:!previousIPs!
		)
	)
	set previousIPs=!selfIPs!
	set selfIPs=
)
exit /b


rem argument 1 addresses or hostname, argument 2 title, argument 3 requestNum
:sendPingTo
set result=
for /f "tokens=1,2 delims=()" %%i in ('ping -n %3 %~1 ^| findstr /c:" = "') do (
	if defined result (
		set result=%%i, Packet Loss = !tmpResult!
	) else (
		set result=    Packet Loss = %%j
		set tmpResult=%%j
	)
)
if defined result (
	echo %2:
	echo !result!
) else (
	echo %2:
	echo     Erorr
)
echo. & echo --------------------------------------------- & echo.
exit /b