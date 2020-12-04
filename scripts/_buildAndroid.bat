mkdir build-android-%abi%-%buildType%
cd build-android-%abi%-%buildType%

cmake ../aws-sdk-cpp/ -G "NMake Makefiles" -DTARGET_ARCH=ANDROID -DANDROID_ABI=%abi% -DCMAKE_BUILD_TYPE=%buildType% -DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda" -DBUILD_SHARED_LIBS=0 -DCMAKE_INSTALL_BINDIR=%outputPath%/%buildType%/%abi%/bin -DCMAKE_INSTALL_LIBDIR=%outputPath%/%buildType%/%abi%/lib -DCMAKE_INSTALL_INCLUDEDIR=%outputPath%/%buildType%/%abi%/include -DENABLE_TESTING=0 -DNDK_DIR=%androidNDKPath%

rem ** BUILD ANDROID DEBUG OUTPUT **
cmake --build .
cmake --build . --target install
cd ..
