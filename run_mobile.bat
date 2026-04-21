@echo off
echo Starting Aria Flutter App...
echo.

echo Step 1: Starting Android emulator...
start /B flutter emulators --launch Medium_Phone_API_36.1

echo Step 2: Waiting 45 seconds for emulator to boot...
timeout /t 45 /nobreak

echo Step 3: Launching Flutter app...
flutter run -d emulator-5554

pause
