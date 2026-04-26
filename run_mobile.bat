@echo off
setlocal enabledelayedexpansion

echo Starting Aria Flutter App...
echo.

set "DART_DEFINES="
if exist ".env" (
    echo Loading AI runtime config from .env...
    for /f "usebackq eol=# tokens=1,* delims==" %%A in (".env") do (
        set "KEY=%%A"
        set "VALUE=%%B"
        if not "!VALUE!"=="" (
            if /I "!KEY!"=="AI_BASE_URL" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="AI_API_KEY" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="AI_MODEL" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="OMNIROUTE_BASE_URL" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="OMNIROUTE_API_KEY" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="OPENROUTER_API_KEY" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="OPENROUTER_MODEL_1" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="OPENROUTER_MODEL_2" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
            if /I "!KEY!"=="GROQ_API_KEY" set "DART_DEFINES=!DART_DEFINES! --dart-define=!KEY!=!VALUE!"
        )
    )
    echo.
)

echo Step 1: Starting Android emulator...
start /B flutter emulators --launch Medium_Phone_API_36.1

echo Step 2: Waiting 45 seconds for emulator to boot...
timeout /t 45 /nobreak

echo Step 3: Launching Flutter app...
flutter run -d emulator-5554 !DART_DEFINES!

pause
