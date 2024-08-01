SETLOCAL EnableDelayedExpansion

set vsConfig=
set vsArch=
if "%winType%"=="win32" (
	REM set vsConfig="Visual Studio 15"
	set vsConfig="Visual Studio 17"
	set vsArch="Win32"
)

if "%winType%"=="win64" (
	REM set vsConfig="Visual Studio 15 Win64"
	set vsConfig="Visual Studio 17"
	set vsArch="x64"
)

echo config is set to %vsConfig%

mkdir build
cd build

set buildFolder=windows-%winType%-%buildType%
mkdir %buildFolder%
cd %buildFolder%

REM cmake --version
REM cmake is v3.27.2-msvc1

cmake ^
	../../aws-sdk-cpp/ ^
	-G %vsConfig% ^
	-A %vsArch% ^
	-DCMAKE_BUILD_TYPE=%buildType% ^
	-DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda;pinpoint;s3;apigateway;identity-management" ^
	-DBUILD_SHARED_LIBS=0 ^
	-DFORCE_SHARED_CRT=0 ^
	-DCMAKE_INSTALL_BINDIR=%outputPath%/%buildType%/%winType%/bin ^
	-DCMAKE_INSTALL_LIBDIR=%outputPath%/%buildType%/%winType%/lib ^
	-DCMAKE_INSTALL_INCLUDEDIR=%outputPath%/%buildType%/%winType%/include ^
	-DENABLE_TESTING=0 ^
	-DNDK_DIR=%androidNDKPath% ^
	-DCMAKE_INSTALL_PREFIX=%outputPath%/%buildType%/%winType%

msbuild INSTALL.vcxproj /p:Configuration=%buildType%

cd ..
cd ..

