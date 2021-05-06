#!/usr/bin/env zsh

set -e

sdk_ios_url="https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/5.1.60/TIM_SDK_iOS_latest_framework.zip"

sdk_macos_url="https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/5.1.56/TIM_SDK_Mac_latest_framework.zip"

if [ ! -f ImSDK.framework.zip ];then
  curl -L "$sdk_ios_url" > ImSDK.framework.zip
fi

if [ ! -d ImSDK.framework ];then
  unzip ImSDK.framework.zip
fi

[ -d iphoneos ] && rm -rf iphoneos
[ -d iphonesimulator ] && rm -rf iphonesimulator
[ -d macosx ] && rm -rf macosx
[ -d ImSDK.xcframework ] && rm -rf ImSDK.xcframework

mkdir iphoneos iphonesimulator macosx


if [ ! -f ImSDKForMac.framework.zip ];then
  curl -L "$sdk_macos_url" > ImSDKForMac.framework.zip
fi

if [ ! -d ImSDKForMac.framework ];then
  unzip ImSDKForMac.framework.zip
fi

mv ImSDKForMac.framework macosx/ImSDK.framework

pushd macosx/ImSDK.framework
mv Versions/A/ImSDKForMac Versions/A/ImSDK
rm -f ImSDKForMac
ln -sf Versions/A/ImSDK ImSDK
popd

cp -r ImSDK.framework iphoneos/
cp -r ImSDK.framework iphonesimulator/

lipo -extract x86_64 ImSDK.framework/ImSDK \
     -output iphonesimulator/ImSDK.framework/ImSDK

lipo -remove x86_64 ImSDK.framework/ImSDK \
     -output iphoneos/ImSDK.framework/ImSDK

xcodebuild -create-xcframework \
           -framework iphoneos/ImSDK.framework \
           -framework iphonesimulator/ImSDK.framework \
           -framework macosx/ImSDK.framework \
           -output ImSDK.xcframework

rm -rf iphone* macosx ImSDK.framework
