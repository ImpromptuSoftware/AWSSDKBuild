SETLOCAL EnableDelayedExpansion

mkdir output
set curDir=%CD:\=/%
set outputPath=%curDir%/output/Windows
set androidNDKPath=%curDir%/NDK/Windows/android-ndk-r21e

REM call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat"
call "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\VsDevCmd.bat"

rem ** CREATE WINDOWS DEBUG win64 **
set winType=win64
set buildType=Debug
call scripts/_buildWindows.bat

rem ** CREATE WINDOWS RELEASE win64 **
set winType=win64
set buildType=Release
call scripts/_buildWindows.bat


