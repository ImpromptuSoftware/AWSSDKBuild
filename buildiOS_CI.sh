#!/bin/bash

# set -euo pipefail
# set -eo pipefail
set -o pipefail
set -x

## Openssl_curl done previously
# cd openssl_curl_for_ios_android.20170105

# SDK Version
SDK_VERSION="17.2"
MIN_VERSION="10.0"

# Setup paths
# echo current directory is $(pwd)
WORKSPACE=$(pwd)
# ls ${WORKSPACE}


# XCode paths
DEVELOPER="/Applications/Xcode_15.2.app/Contents/Developer"
IPHONEOS_PLATFORM="${DEVELOPER}/Platforms/iPhoneOS.platform"
IPHONEOS_SDK="${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${SDK_VERSION}.sdk"

IPHONESIMULATOR_PLATFORM="${DEVELOPER}/Platforms/iPhoneSimulator.platform"
IPHONESIMULATOR_SDK="${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/iPhoneSimulator${SDK_VERSION}.sdk"

# Make sure things actually exist
if [ ! -d "$IPHONEOS_PLATFORM" ]; then
  echo "Cannot find $IPHONEOS_PLATFORM"
  exit 1
fi

if [ ! -d "$IPHONEOS_SDK" ]; then
  echo "Cannot find $IPHONEOS_SDK"
  exit 1
fi


if [ ! -d "$IPHONESIMULATOR_PLATFORM" ]; then
  echo "Cannot find $IPHONESIMULATOR_PLATFORM"
  exit 1
fi

if [ ! -d "$IPHONESIMULATOR_SDK" ]; then
  echo "Cannot find $IPHONESIMULATOR_SDK"
  exit 1
fi


# ----------------------------------
# To build arm64, armv7, armv7s
# ----------------------------------
build_AWSRelease_bitcode()
{
	export ARCH=$1
	export DBGREL="Release"
	export BUILD_FOLDER=build/iOS-$ARCH-$DBGREL

    # Build intermediates dir
    mkdir -p "$BUILD_FOLDER"
    cd "$BUILD_FOLDER"

    # Cleanup
    rm -r ./*

	export SDK=$2

    export CC="$(xcrun -sdk iphoneos -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export AR=$(xcrun -sdk iphoneos -find ar)
    export RANLIB=$(xcrun -sdk iphoneos -find ranlib)
    export CPPFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export LDFLAGS="-arch ${ARCH} -isysroot $SDK"

    BUILD_OUTPUT="${WORKSPACE}/output/iOS/${ARCH}/${DBGREL}"
    mkdir -p "$BUILD_OUTPUT"

    echo "$CMAKE_CXX_FLAGS"

    cmake -Wno-dev \
        -DCMAKE_OSX_SYSROOT="$IPHONEOS_SDK" \
        -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
        -DCMAKE_SYSTEM_NAME="Darwin" \
		-DENABLE_TESTING=0 \
		-DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda;s3;apigateway;identity-management" \
        -DCMAKE_SHARED_LINKER_FLAGS="-framework Foundation -lz -framework Security" \
        -DCMAKE_EXE_LINKER_FLAGS="-framework Foundation -framework Security" \
        -DCMAKE_PREFIX_PATH="$WORKSPACE/libcurl/" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCUSTOM_MEMORY_MANAGEMENT=0 \
        -DCMAKE_BUILD_TYPE=$DBGREL \
        -DCMAKE_INSTALL_PREFIX="$BUILD_OUTPUT" \
        -DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++ -miphoneos-version-min=$MIN_VERSION" \
		-DSTATIC_LINKING=1 \
		-DTARGET_ARCH=APPLE \
		-DCMAKE_CXX_FLAGS=-O3 \
		-DCPP_STANDARD=14 \
		-DENABLE_CURL_CLIENT=Yes \
		-DCURL_INCLUDE_DIR=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/curl-ios-$ARCH/include \
		-DCURL_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/curl-ios-$ARCH/lib/libcurl.a \
		-DCMAKE_IOS_DEPLOYMENT_TARGET="12" \
		-DENABLE_OPENSSL_ENCRYPTION=Yes \
		-DOPENSSL_CRYPTO_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/lib/libcrypto.a \
		-DOPENSSL_SSL_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/lib/libssl.a \
		-DOPENSSL_INCLUDE_DIR=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/include \
        $WORKSPACE/aws-sdk-cpp
    make -j 8
    make install

    # Go back
    cd ..
	cd ..
}


# ----------------------------------
# To build arm64, armv7, armv7s
# ----------------------------------
build_AWSDebug_bitcode()
{
	export ARCH=$1
	export DBGREL="Debug"
	export BUILD_FOLDER=build/iOS-$ARCH-$DBGREL

    # Build intermediates dir
    mkdir -p "$BUILD_FOLDER"
    cd "$BUILD_FOLDER"

    # Cleanup
    rm -r ./*

	export SDK=$2

    export CC="$(xcrun -sdk iphoneos -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export AR=$(xcrun -sdk iphoneos -find ar)
    export RANLIB=$(xcrun -sdk iphoneos -find ranlib)
    export CPPFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export LDFLAGS="-arch ${ARCH} -isysroot $SDK"

    BUILD_OUTPUT="${WORKSPACE}/output/iOS/${ARCH}/${DBGREL}"
    mkdir -p "$BUILD_OUTPUT"

    echo "$CMAKE_CXX_FLAGS"

    cmake -Wno-dev \
        -DCMAKE_OSX_SYSROOT="$IPHONEOS_SDK" \
        -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
        -DCMAKE_SYSTEM_NAME="Darwin" \
		-DENABLE_TESTING=0 \
		-DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda;s3;apigateway;identity-management" \
        -DCMAKE_SHARED_LINKER_FLAGS="-framework Foundation -lz -framework Security" \
        -DCMAKE_EXE_LINKER_FLAGS="-framework Foundation -framework Security" \
        -DCMAKE_PREFIX_PATH="$WORKSPACE/libcurl/" \
        -DBUILD_SHARED_LIBS=OFF \
        -DCUSTOM_MEMORY_MANAGEMENT=0 \
        -DCMAKE_BUILD_TYPE=$DBGREL \
        -DCMAKE_INSTALL_PREFIX="$BUILD_OUTPUT" \
        -DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++ -miphoneos-version-min=$MIN_VERSION" \
        $WORKSPACE/aws-sdk-cpp
    make -j 8
    make install

    # Go back
    cd ..
	cd ..
}




# ----------------------------------
# To build i386, x86_64 (fails currently)
# ----------------------------------
build_AWSRelease_Simulator_bitcode()
{
    export ARCH=$1
	export DBGREL="Release"
	export BUILD_FOLDER=build/iOS-$ARCH-$DBGREL

    # Build intermediates dir
    mkdir -p "$BUILD_FOLDER"
    cd "$BUILD_FOLDER"

    # Cleanup
    rm -r ./*

    export SDK=$2

    export CC="$(xcrun -sdk iphonesimulator -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export AR=$(xcrun -sdk iphonesimulator -find ar)
    export RANLIB=$(xcrun -sdk iphonesimulator -find ranlib)
    export CPPFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION -Wno-error"
    export LDFLAGS="-arch ${ARCH} -isysroot $SDK"

    BUILD_OUTPUT="${WORKSPACE}/output/iOS/${ARCH}/${DBGREL}"
    mkdir -p "$BUILD_OUTPUT"

    echo "$CMAKE_CXX_FLAGS"

    cmake -Wno-dev \
    -DCMAKE_OSX_SYSROOT=$IPHONESIMULATOR_SDK \
    -DCMAKE_OSX_ARCHITECTURES="$ARCH" \
    -DCMAKE_SYSTEM_NAME="Darwin" \
	-DENABLE_TESTING=0 \
	-DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda;s3;apigateway;identity-management" \
    -DCMAKE_SHARED_LINKER_FLAGS="-framework Foundation -lz -framework Security" \
    -DCMAKE_EXE_LINKER_FLAGS="-framework Foundation -framework Security" \
    -DCMAKE_PREFIX_PATH="$WORKSPACE/libcurl/" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCUSTOM_MEMORY_MANAGEMENT=0 \
    -DCMAKE_BUILD_TYPE=$DBGREL \
    -DCMAKE_INSTALL_PREFIX="$BUILD_OUTPUT" \
    -DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++ -miphoneos-version-min=$MIN_VERSION" \
	-DSTATIC_LINKING=1 \
	-DTARGET_ARCH=APPLE \
	-DCMAKE_CXX_FLAGS=-O3 \
	-DCPP_STANDARD=14 \
	-DENABLE_CURL_CLIENT=Yes \
	-DCURL_INCLUDE_DIR=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/curl-ios-$ARCH/include \
	-DCURL_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/curl-ios-$ARCH/lib/libcurl.a \
	-DCMAKE_IOS_DEPLOYMENT_TARGET="12" \
	-DENABLE_OPENSSL_ENCRYPTION=Yes \
	-DOPENSSL_CRYPTO_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/lib/libcrypto.a \
	-DOPENSSL_SSL_LIBRARY=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/lib/libssl.a \
	-DOPENSSL_INCLUDE_DIR=${WORKSPACE}/openssl_curl_for_ios_android.20170105/output/ios/openssl-ios-$ARCH/include \
    $WORKSPACE/aws-sdk-cpp
    make -j 8
    make install

    # Go back
    cd ..
	cd ..
}


# ----------------------------------
# To build i386, x86_64 (fails currently)
# ----------------------------------
build_AWSDebug_Simulator_bitcode()
{
    export ARCH=$1
	export DBGREL="Debug"
	export BUILD_FOLDER=build/iOS-$ARCH-$DBGREL

    # Build intermediates dir
    mkdir -p "$BUILD_FOLDER"
    cd "$BUILD_FOLDER"

    # Cleanup
    rm -r ./*

    export SDK=$2

    export CC="$(xcrun -sdk iphonesimulator -find clang)"
    export CPP="$CC -E"
    export CFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION"
    export AR=$(xcrun -sdk iphonesimulator -find ar)
    export RANLIB=$(xcrun -sdk iphonesimulator -find ranlib)
    export CPPFLAGS="-arch ${ARCH} -isysroot $SDK -miphoneos-version-min=$MIN_VERSION -Wno-error"
    export LDFLAGS="-arch ${ARCH} -isysroot $SDK"

    BUILD_OUTPUT="${WORKSPACE}/output/iOS/${ARCH}/${DBGREL}"
    mkdir -p "$BUILD_OUTPUT"

    echo "$CMAKE_CXX_FLAGS"

    cmake -Wno-dev \
    -DCMAKE_OSX_SYSROOT=$IPHONESIMULATOR_SDK \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH \
    -DCMAKE_SYSTEM_NAME="Darwin" \
	-DENABLE_TESTING=0 \
	-DBUILD_ONLY="kinesis;cognito-identity;cognito-sync;lambda;s3;apigateway;identity-management" \
    -DCMAKE_SHARED_LINKER_FLAGS="-framework Foundation -lz -framework Security" \
    -DCMAKE_EXE_LINKER_FLAGS="-framework Foundation -framework Security" \
    -DCMAKE_PREFIX_PATH="$WORKSPACE/libcurl/" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCUSTOM_MEMORY_MANAGEMENT=0 \
    -DCMAKE_BUILD_TYPE=$DBGREL \
    -DCMAKE_INSTALL_PREFIX="$BUILD_OUTPUT" \
    -DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++ -miphoneos-version-min=$MIN_VERSION" \
    $WORKSPACE/aws-sdk-cpp
    make -j 8
    make install

    # Go back
    cd ..
	cd ..
}

# ---------------------------------------------------
# Function to aggregate build outputs into a fat lib
# ---------------------------------------------------
aggregate_release_libs() {
    set +x
    AGG_OUTPUT_DIR=$1
	export DBGREL="Release"

    # Aggregate library and include files
    mkdir -p "${AGG_OUTPUT_DIR}/include"
    mkdir -p "${AGG_OUTPUT_DIR}/lib"

    cp -r ${WORKSPACE}/output/iOS/arm64/${DBGREL}/include/* ${AGG_OUTPUT_DIR}/include/

    ## declare an array variable with required aws components
    ## This is an example. Change as required
    declare -a components=( "libaws-cpp-sdk-access-management"
                            "libaws-cpp-sdk-cognito-identity"
                            "libaws-cpp-sdk-cognito-sync"
							"libaws-cpp-sdk-core"
                            "libaws-cpp-sdk-iam"
                            "libaws-cpp-sdk-kinesis"
                            "libaws-cpp-sdk-lambda"
							"libaws-cpp-sdk-apigateway"
							"libaws-cpp-sdk-s3"
							"libaws-cpp-sdk-identity-management"
							"libaws-c-auth"
							"libaws-c-cal"
							"libaws-c-common"
							"libaws-c-compression"
							"libaws-c-event-stream"
							"libaws-c-http"
							"libaws-c-io"
							"libaws-c-mqtt"
							"libaws-c-s3"
							"libaws-crt-cpp"
							"libaws-checksums"
                            )

    ## now loop through the above array
    for component in "${components[@]}"
    do
        LIBNAME="${component}.a"
        echo "--------- Aggregating $LIBNAME ---------"
        xcrun -sdk iphoneos lipo \
        "${WORKSPACE}/output/iOS/arm64/${DBGREL}/lib/${LIBNAME}" \
        "${WORKSPACE}/output/iOS/armv7/${DBGREL}/lib/${LIBNAME}" \
        "${WORKSPACE}/output/iOS/x86_64/${DBGREL}/lib/${LIBNAME}" \
        -create -output ${AGG_OUTPUT_DIR}/lib/${LIBNAME}

        # verify arch
        echo "- Running lipo info for $LIBNAME:"
        lipo -info ${AGG_OUTPUT_DIR}/lib/${LIBNAME}
        echo "--------------------------------------------------"
    done

    echo "--------------------------------------------------"
    echo "Aggregated output location: ${AGG_OUTPUT_DIR}"
    echo "--------------------------------------------------"
}

# ---------------------------------------------------
# Function to aggregate build outputs into a fat lib
# ---------------------------------------------------
aggregate_debug_libs() {
    set +x
    AGG_OUTPUT_DIR=$1
	export DBGREL="Debug"

    # Aggregate library and include files
    mkdir -p ${AGG_OUTPUT_DIR}/include
    mkdir -p ${AGG_OUTPUT_DIR}/lib

    cp -r ${WORKSPACE}/output/iOS/arm64/${DBGREL}/include/* ${AGG_OUTPUT_DIR}/include/

    ## declare an array variable with required aws components
    ## This is an example. Change as required
    declare -a components=( "access-management"
                            "cognito-identity"
                            "cognito-sync"
							"core"
                            "iam"
                            "kinesis"
                            "lambda"
                            )

    ## now loop through the above array
    for component in "${components[@]}"
    do
        LIBNAME="libaws-cpp-sdk-${component}.a"
        echo "--------- Aggregating $LIBNAME ---------"
        xcrun -sdk iphoneos lipo \
        "${WORKSPACE}/output/iOS/arm64/${DBGREL}/lib/${LIBNAME}" \
        "${WORKSPACE}/output/iOS/armv7/${DBGREL}/lib/${LIBNAME}" \
        "${WORKSPACE}/output/iOS/x86_64/${DBGREL}/lib/${LIBNAME}" \
        -create -output ${AGG_OUTPUT_DIR}/lib/${LIBNAME}

        # verify arch
        echo "- Running lipo info for $LIBNAME:"
        lipo -info ${AGG_OUTPUT_DIR}/lib/${LIBNAME}
        echo "--------------------------------------------------"
    done

    echo "--------------------------------------------------"
    echo "Aggregated output location: ${AGG_OUTPUT_DIR}"
    echo "--------------------------------------------------"
}


## Build release configuration
build_AWSRelease_bitcode "arm64" "${IPHONEOS_SDK}"
build_AWSRelease_bitcode "armv7" "${IPHONEOS_SDK}"
#build_AWSRelease_bitcode "armv7s" "${IPHONEOS_SDK}"
#build_AWSRelease_Simulator_bitcode "i386" "${IPHONESIMULATOR_SDK}"
build_AWSRelease_Simulator_bitcode "x86_64" "${IPHONESIMULATOR_SDK}"

## Build debug configuration
#build_AWSDebug_bitcode "arm64" "${IPHONEOS_SDK}"
#build_AWSDebug_bitcode "armv7" "${IPHONEOS_SDK}"
#build_AWSDebug_bitcode "armv7s" "${IPHONEOS_SDK}"
#build_AWSDebug_Simulator_bitcode "i386" "${IPHONESIMULATOR_SDK}"
#build_AWSDebug_Simulator_bitcode "x86_64" "${IPHONESIMULATOR_SDK}"

## Aggregate into a fat lib. Argument provided here is the output directory
aggregate_release_libs "${WORKSPACE}/output/iOS/fatlib/release"
#aggregate_debug_libs "${WORKSPACE}/output/iOS/fatlib/debug"

echo "-- Initial AWSSDKCPP build complete --"

