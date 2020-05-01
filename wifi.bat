@ECHO OFF

:choice
set /p c=Ngempakne wifi po mateni [start/stop] ? 
if %c%==start goto ngempakne
if %c%==stop goto mateni
goto choice

:ngempakne
netsh wlan set hostednetwork mode=allow ssid=CENDOLDAWET key=999999999
netsh wlan start hostednetwork
pause
exit

:mateni
netsh wlan stop hostednetwork
pause
exit