#!/bin/sh

#works for  Xcode 7.0+ only

#获取命令行中接收到的scheme
TARGET_SCHEMES=$1

if [ ! -n "$TARGET_SCHEMES" ]; then  
  echo ">>>> TARGET_SCHEMES is missing!!!"  
  exit
fi  

echo ">>>>>>>>>>>> Start replacing RES at $(date) <<<<<<<<<<<<<<<"

AUTOBUILD_PATH=$PWD
PROJECT_ROOT_PATH="$AUTOBUILD_PATH/.."

#导出配置
EXPORT_ICON_PATH="$AUTOBUILD_PATH/res/icon"
EXPORT_LAUNCHER_PATH="$AUTOBUILD_PATH/res/launcher"
EXPORT_DRAWABLE_PATH="$AUTOBUILD_PATH/res/drawable"

#icon Assets assets
ICON_ASSETS="$PROJECT_ROOT_PATH/Majia/Assets.xcassets/AppIcon.appiconset/"
LAUNCHER_ASSETS="$PROJECT_ROOT_PATH/Majia/Assets.xcassets/LaunchImage.launchimage/"
DRAWABLE_ASSETS="$PROJECT_ROOT_PATH/Majia/res/"

#replace icons
cp -R -a "$EXPORT_ICON_PATH/$TARGET_SCHEMES/." $ICON_ASSETS
#replace launchers
cp -R -a "$EXPORT_LAUNCHER_PATH/$TARGET_SCHEMES/." $LAUNCHER_ASSETS
#replace drawables
cp -R -a "$EXPORT_DRAWABLE_PATH/$TARGET_SCHEMES/." $DRAWABLE_ASSETS


echo ">>>>>>>>>>>> Finish replacing RES at $(date) <<<<<<<<<<<<<<<"