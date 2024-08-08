mkdir output
set curDir=%CD:\=/%
set outputPath=%curDir%/output/Android
set androidNDKPath=%curDir%/NDK/Windows/android-ndk-r21e

REM call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat"
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat"


rem **************************
rem ** DEBUG BUILDS START **

rem ** NOTE: Debug builds are currently commented out as these are not required
rem ** Debug and Release Android app builds only use the AWSSDKCPP release libs

rem ** CREATE ANDROID DEBUG arm64-v8a **
set abi=arm64-v8a
set buildType=Debug
rem call scripts/_buildAndroid.bat

rem ** CREATE ANDROID DEBUG armeabi-v7a **
set abi=armeabi-v7a
set buildType=Debug
rem call scripts/_buildAndroid.bat

rem ** DEBUG BUILDS END **
rem ************************



rem **************************
rem ** RELEASE BUILDS START **

rem ** CREATE ANDROID RELEASE arm64-v8a **
set abi=arm64-v8a
set buildType=Release
call scripts/_buildAndroid.bat

rem ** CREATE ANDROID RELEASE armeabi-v7a **
set abi=armeabi-v7a
set buildType=Release
call scripts/_buildAndroid.bat

rem ** RELEASE BUILDS END **
rem ************************

pause
