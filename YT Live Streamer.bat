@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title YouTube Live Streamer - Munna MasterMind

REM ==================== CONFIG ====================
set "ROOT=%~dp0"
set "FFMPEG_DIR=%ROOT%FFmpeg"
set "INPUT_DIR=%ROOT%input_video"
set "TEMP_DIR=%ROOT%Temp_LiveStream"

REM ==================== MENU ====================
:MENU
cls
echo.
echo    ╔══════════════════════════════════════════════╗
echo    ║    YouTube Live Streamer - Munna MasterMind  ║
echo    ╠══════════════════════════════════════════════╣
echo    ║  1. Setup Automatic Dependency               ║
echo    ║  2. Start Live Stream                        ║
echo    ║  3. Contact Us For Development               ║
echo    ║  4. Exit Program                             ║
echo    ╚══════════════════════════════════════════════╝
echo.
choice /c 1234 /n /m "Select Option [1-4]: "
if errorlevel 4 exit /b
if errorlevel 3 goto CONTACT
if errorlevel 2 goto CHECK_AND_START
if errorlevel 1 goto SETUP_DEPENDENCIES
goto MENU

REM ============ DEPENDENCY SETUP ============
:SETUP_DEPENDENCIES
cls
echo.
echo ===== Setting Up FFmpeg Dependencies =====
echo.

if not exist "%FFMPEG_DIR%" mkdir "%FFMPEG_DIR%"

echo Downloading FFmpeg...
echo.
set "ZIPFILE=ffmpeg_latest.zip"
where curl >nul 2>&1
if not errorlevel 1 (
    curl -L -o "%ZIPFILE%" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    if exist "%ZIPFILE%" goto EXTRACT_FFMPEG
)

bitsadmin /transfer "FFmpegDL" /download /priority normal ^
"https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "%ZIPFILE%"
if exist "%ZIPFILE%" goto EXTRACT_FFMPEG

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile '%ZIPFILE%'}"
if not exist "%ZIPFILE%" (
    echo [ERROR] FFmpeg download failed! Check internet and try again.
    pause
    goto MENU
)

:EXTRACT_FFMPEG
echo Extracting FFmpeg...
powershell -Command "Expand-Archive '%ZIPFILE%' 'ffmpeg_temp' -Force"
for /r "ffmpeg_temp" %%F in (ffmpeg.exe ffprobe.exe ffplay.exe) do (
    copy /y "%%F" "%FFMPEG_DIR%" >nul 2>&1
)
rd /s /q "ffmpeg_temp"
del "%ZIPFILE%"
echo [OK] FFmpeg installed successfully!
echo.
pause
goto MENU

REM ============ CHECK TOOLS FOR STREAMING ============
:CHECK_FFMPEG
if not exist "%FFMPEG_DIR%\ffmpeg.exe" (
    echo.
    echo ffmpeg.exe not found! Run option 1 first.
    pause
    goto MENU
)
if not exist "%FFMPEG_DIR%\ffprobe.exe" (
    echo.
    echo ffprobe.exe not found! Run option 1 first.
    pause
    goto MENU
)
exit /b

REM ============ START LIVE STREAM ============
:CHECK_AND_START
call :CHECK_FFMPEG

if not exist "%INPUT_DIR%" mkdir "%INPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set i=0
echo =========== Available Videos ===========
for %%F in ("%INPUT_DIR%\*.mp4" "%INPUT_DIR%\*.mov" "%INPUT_DIR%\*.mkv" "%INPUT_DIR%\*.webm" "%INPUT_DIR%\*.avi") do (
    set /a i+=1
    set "VID!i!=%%~fF"
    echo   !i!. %%~nxF
)
if %i%==0 (
    echo ❌ No video files found in input_video folder!
    echo    Please place a video file there first.
    pause
    goto MENU
)
echo ------------------------------------------
set /p "VIDCHOICE=Select Your Video [1-%i%]: "
set "VIDEO=!VID%VIDCHOICE%!"
if not defined VIDEO echo ❌ Invalid selection & pause & goto MENU

echo.
set /p "STREAM_KEY=Enter Your YouTube Stream Key: "
if "%STREAM_KEY%"=="" (
    echo ❌ Stream key cannot be empty!
    pause
    goto MENU
)

echo.
echo Stream Duration:
echo    0 = Unlimited (until you stop manually)
echo    1 = Manual Input (you specify minutes or HH:MM)
set /p "DURCHOICE=Your choice [0-1]: "
if "%DURCHOICE%"=="0" (
    set "DURATION="
    set "DUR_TEXT=Unlimited"
) else if "%DURCHOICE%"=="1" (
    call :ASK_DURATION
) else (
    echo ❌ Invalid choice & pause & goto MENU
)

echo.
echo ========== Select Resolution ==========
for /f "tokens=1,2 delims=x" %%A in ('""%FFMPEG_DIR%\ffprobe.exe" -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "%VIDEO%""') do (
    set "ORIG_W=%%A"
    set "ORIG_H=%%B"
)
echo     1. Original Resolution (!ORIG_W!x!ORIG_H!)
echo     2. 720p (1280x720)
echo     3. 1080p (1920x1080)
echo     4. 2K (2560x1440)
echo     5. 4K (3840x2160)
set /p "RESCHOICE=Enter choice [1-5]: "
if "%RESCHOICE%"=="" set "RESCHOICE=1"

if "%RESCHOICE%"=="1" (
    set "WIDTH=!ORIG_W!" & set "HEIGHT=!ORIG_H!" & set "RESNAME=Original"
    set "SCALE_FILTER="
    REM --- Fixed bitrate logic ---
    if !ORIG_H! LEQ 720 (
        set "VBIT=2500k" & set "MAXR=2500k" & set "BUF=5000k"
    )
    if !ORIG_H! GTR 720 if !ORIG_H! LEQ 1080 (
        set "VBIT=4500k" & set "MAXR=4500k" & set "BUF=9000k"
    )
    if !ORIG_H! GTR 1080 if !ORIG_H! LEQ 1440 (
        set "VBIT=8000k" & set "MAXR=8000k" & set "BUF=16000k"
    )
    if !ORIG_H! GTR 1440 (
        set "VBIT=15000k" & set "MAXR=15000k" & set "BUF=30000k"
    )
) else if "%RESCHOICE%"=="2" (
    set "WIDTH=1280" & set "HEIGHT=720" & set "RESNAME=720p"
    set "SCALE_FILTER=scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,"
    set "VBIT=2500k" & set "MAXR=2500k" & set "BUF=5000k"
) else if "%RESCHOICE%"=="3" (
    set "WIDTH=1920" & set "HEIGHT=1080" & set "RESNAME=1080p"
    set "SCALE_FILTER=scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,"
    set "VBIT=4500k" & set "MAXR=4500k" & set "BUF=9000k"
) else if "%RESCHOICE%"=="4" (
    set "WIDTH=2560" & set "HEIGHT=1440" & set "RESNAME=2K"
    set "SCALE_FILTER=scale=2560:1440:force_original_aspect_ratio=decrease,pad=2560:1440:(ow-iw)/2:(oh-ih)/2,"
    set "VBIT=8000k" & set "MAXR=8000k" & set "BUF=16000k"
) else if "%RESCHOICE%"=="5" (
    set "WIDTH=3840" & set "HEIGHT=2160" & set "RESNAME=4K"
    set "SCALE_FILTER=scale=3840:2160:force_original_aspect_ratio=decrease,pad=3840:2160:(ow-iw)/2:(oh-ih)/2,"
    set "VBIT=15000k" & set "MAXR=15000k" & set "BUF=30000k"
) else (
    echo ❌ Invalid choice & pause & goto MENU
)

REM Check video audio
"%FFMPEG_DIR%\ffprobe.exe" -v error -select_streams a -show_entries stream=index -of csv=p=0 "%VIDEO%" > "%TEMP_DIR%\has_audio.txt" 2>nul
set /p "HAS_AUDIO=" < "%TEMP_DIR%\has_audio.txt"
if "!HAS_AUDIO!"=="" (set "VID_HAS_AUDIO=0") else (set "VID_HAS_AUDIO=1")

REM Create a short merged clip
set "MIX=%TEMP_DIR%\mix_short_%RESNAME%.mp4"
echo.
echo Preparing streaming source (%RESNAME%)...
if !VID_HAS_AUDIO!==1 (
    "%FFMPEG_DIR%\ffmpeg.exe" -y -hide_banner -loglevel error -stats -i "%VIDEO%" ^
      -filter_complex "[0:v]%SCALE_FILTER%format=yuv420p[v]" ^
      -map "[v]" -map 0:a -c:v libx264 -preset ultrafast -crf 25 -c:a aac -b:a 128k -shortest "%MIX%"
) else (
    "%FFMPEG_DIR%\ffmpeg.exe" -y -hide_banner -loglevel error -stats -i "%VIDEO%" ^
      -filter_complex "[0:v]%SCALE_FILTER%format=yuv420p[v]" ^
      -map "[v]" -c:v libx264 -preset ultrafast -crf 25 -shortest "%MIX%"
)

if not exist "%MIX%" (
    echo ❌ Failed to create streaming source!
    pause
    goto MENU
)

echo.
echo 🚀 Live streaming to YouTube! Press Ctrl+C to stop.
echo    Duration: %DUR_TEXT%
echo    Resolution: %RESNAME% (%WIDTH%x%HEIGHT%)
echo.

set "RTMP_URL=rtmp://a.rtmp.youtube.com/live2/%STREAM_KEY%"
if defined DURATION (
    set "TIMECMD=-t %DURATION%"
) else (
    set "TIMECMD="
)

"%FFMPEG_DIR%\ffmpeg.exe" -re -hide_banner -loglevel info -stats ^
  -stream_loop -1 -i "%MIX%" %TIMECMD% ^
  -c:v libx264 -preset veryfast -b:v %VBIT% -maxrate %MAXR% -bufsize %BUF% ^
  -pix_fmt yuv420p -g 60 -c:a aac -b:a 128k -ac 2 -ar 44100 ^
  -f flv "%RTMP_URL%"

del /q "%TEMP_DIR%\has_audio.txt" 2>nul
del /q "%MIX%" 2>nul
echo.
echo Stream ended.
pause
goto MENU

REM ============ ASK DURATION ============
:ASK_DURATION
cls
echo.
echo Examples Duration:
echo    5       = 5 minutes
echo    10      = 10 minutes
echo    1:30    = 1 hour 30 minutes
echo    2:45    = 2 hours 45 minutes
echo    10:15   = 10 hours 15 minutes
echo    24:00   = 24 hours 0 minutes
echo.
set /p "USERDUR=Enter desired stream duration: "
if "%USERDUR%"=="" goto BAD_DUR
set "USERDUR=%USERDUR: =%"
echo %USERDUR% | findstr ":" >nul 2>&1
if errorlevel 1 (
    set "HOURS=0"
    set "MINS=%USERDUR%"
) else (
    for /f "tokens=1,2 delims=:" %%A in ("%USERDUR%") do (
        set "HOURS=%%A"
        set "MINS=%%B"
    )
)
if not defined HOURS set "HOURS=0"
if not defined MINS set "MINS=0"
set /a TOTMIN=HOURS*60+MINS 2>nul
if "%TOTMIN%"=="" goto BAD_DUR
if %TOTMIN% LEQ 0 goto BAD_DUR
if %TOTMIN% GTR 1440 goto BAD_DUR
set /a MM = TOTMIN %% 60
if %MM% GEQ 60 goto BAD_DUR
set /a HH = TOTMIN / 60
if %HH% LSS 10 set "HH=0%HH%"
if %MM% LSS 10 set "MM=0%MM%"
set "DURATION=%HH%:%MM%:00"
set "DUR_TEXT=%HH%:%MM%:00"
exit /b

:BAD_DUR
echo ❌ Invalid input! Please use a valid time (max 24 hours).
timeout /t 2 >nul
goto ASK_DURATION

REM ============ CONTACT INFO ============
:CONTACT
cls
color 0A
echo.
echo   ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo   ::           YouTube Live Streamer - Premium Edition              ::
echo   ::           Author : Munna MasterMind                            ::
echo   ::           https://github.com/Munna-Soft                        ::
echo   ::           https://facebook.com/The.Munna                       ::
echo   ::           Location : Dhaka, Bangladesh                         ::
echo   ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
pause
goto MENU