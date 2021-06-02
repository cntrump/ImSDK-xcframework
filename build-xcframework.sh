#!/usr/bin/env zsh

set -e

name=ImSDK

sdk_ios_url="https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_iOS_latest_framework.zip"

sdk_macos_url="https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip"

if [ ! -f ${name}.framework.zip ];then
  curl -L "$sdk_ios_url" > ${name}.framework.zip
fi

if [ ! -d ${name}.framework ];then
  unzip ${name}.framework.zip
fi

[ -d iphoneos ] && rm -rf iphoneos
[ -d iphonesimulator ] && rm -rf iphonesimulator
[ -d macosx ] && rm -rf macosx
[ -d ${name}.xcframework ] && rm -rf ${name}.xcframework

mkdir iphoneos iphonesimulator macosx


if [ ! -f ImSDKForMac.framework.zip ];then
  curl -L "$sdk_macos_url" > ImSDKForMac.framework.zip
fi

if [ ! -d ImSDKForMac.framework ];then
  unzip ImSDKForMac.framework.zip
fi

mv ImSDKForMac.framework macosx/${name}.framework

pushd macosx/${name}.framework
mv Versions/A/ImSDKForMac Versions/A/ImSDK
rm -f ImSDKForMac
ln -sf Versions/A/ImSDK ImSDK
popd

cp -r ${name}.framework iphoneos/
cp -r ${name}.framework iphonesimulator/

lipo -extract x86_64 ${name}.framework/ImSDK \
     -output iphonesimulator/${name}.framework/ImSDK

lipo -remove x86_64 ${name}.framework/ImSDK \
     -output iphoneos/${name}.framework/ImSDK

xcodebuild -create-xcframework \
           -framework iphoneos/${name}.framework \
           -framework iphonesimulator/${name}.framework \
           -framework macosx/${name}.framework \
           -output ${name}.xcframework

rm -rf iphone* macosx ${name}.framework

tar czvf ${name}.xcframework.tar.gz ${name}.xcframework
