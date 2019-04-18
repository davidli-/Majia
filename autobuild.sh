#!/bin/sh

#works for  Xcode 7.0+ only

echo ">>>>>>>>>>>> Start at $(date) <<<<<<<<<<<<<<<"

PROJECT_ROOT_PATH=$PWD
AUTOBUILD_PATH="$PROJECT_ROOT_PATH/AutoBuild"

CURRENT_DATE=$(date +%Y_%m%d_%H%M)
WORKSPACE_NAME="Majia.xcworkspace"

#导出配置
HEADER_PLIST="$AUTOBUILD_PATH/Header.plist"
EXPORT_PLIST="$AUTOBUILD_PATH/ExportOptions.plist"

#Info key
KEY_SCHEME="KEY_SCHEME"
KEY_APP_NAME="KEY_APP_NAME"
KEY_TEAM_ID="KEY_TEAM_ID"
KEY_DEV_ID="KEY_DEV_ID"

#Flavors
InHouse={$KEY_SCHEME:"InHouse",$KEY_APP_NAME:"InHouse",$KEY_TEAM_ID:"your_team_ID",$KEY_DEV_ID:"your_team"}
Release={$KEY_SCHEME:"Release",$KEY_APP_NAME:"Release",$KEY_TEAM_ID:"your_team_ID",$KEY_DEV_ID:"your_team"}

#SELECT FLAVORS
FLAVORS=($Release,$InHouse)

#Parse method
parse_json(){
echo $1 | sed 's/.*'$2':\([^,}]*\).*/\1/'
}



#build release apps directory
BUILD_DIR="$PROJECT_ROOT_PATH/Build"
RELEASE_DIR="$BUILD_DIR/Products"

rm -rdf $BUILD_DIR

#final binarys' directory
OUT_BINARY_DIR="$PROJECT_ROOT_PATH/binarys_$CURRENT_DATE"

if [ ! -d $OUT_BINARY_DIR ]; then
	mkdir $OUT_BINARY_DIR
fi

for ((i = 0; i < ${#FLAVORS[@]}; i++))
do
	
	#parse elements
	TARGET_SCHEMES=$(parse_json ${FLAVORS[$i]} $KEY_SCHEME)
	TARGET_APP_NAMES=$(parse_json ${FLAVORS[$i]} $KEY_APP_NAME)
	TARGET_TEAM_IDS=$(parse_json ${FLAVORS[$i]} $KEY_TEAM_ID)
	TARGET_DEV_IDS=$(parse_json ${FLAVORS[$i]} $KEY_DEV_ID)

	#reset export options plist
	rm $EXPORT_PLIST
	
	cat $HEADER_PLIST >> $EXPORT_PLIST
	
	echo "<plist version=\"1.0\">" >> $EXPORT_PLIST
	echo "<dict>" >> $EXPORT_PLIST
	echo "<key>teamID</key>" >> $EXPORT_PLIST
	echo "<string>$TARGET_TEAM_IDS</string>" >> $EXPORT_PLIST
	echo "<key>method</key>" >> $EXPORT_PLIST
	
	echo ">>>>>>>>>>>>>>>>>>>>>>>> target scheme $TARGET_SCHEMES"
	
	if [ $TARGET_SCHEMES = "InHouse" ]; then
		echo "<string>enterprise</string>" >> $EXPORT_PLIST
		echo ">>>>>>>>>>>>>>>>>>>>>>>> enterprise Done"
	else
		echo "<string>app-store</string>" >> $EXPORT_PLIST
		echo ">>>>>>>>>>>>>>>>>>>>>>>> app-store Done"
	fi
	
	echo "<key>uploadSymbols</key>" >> $EXPORT_PLIST
	echo "<true/>" >> $EXPORT_PLIST
	echo "</dict>" >> $EXPORT_PLIST
	echo "</plist>" >> $EXPORT_PLIST
	
	echo ">>>>>>>>>>>>>>>>>>>>>>>> Reset export options Done"

	cd $AUTOBUILD_PATH
	./replace_res.sh $TARGET_SCHEMES

	# return root
	cd $PROJECT_ROOT_PATH
	echo ">>>>>>>>>>>>>>>>>>>>>>>> Reset res Done"
	
	#export files
	ARCHIVE_FILE="$OUT_BINARY_DIR/$TARGET_APP_NAMES.xcarchive"
	DSYMS_FILE="$TARGET_APP_NAMES.dSYMs.zip"
	
	#clean prject
	xcodebuild -workspace $WORKSPACE_NAME -scheme $TARGET_SCHEMES -configuration $TARGET_APP_NAMES clean
	
	#build & archive
	xcodebuild archive -workspace $WORKSPACE_NAME -scheme $TARGET_SCHEMES -configuration $TARGET_APP_NAMES -archivePath $ARCHIVE_FILE
	
	cd $ARCHIVE_FILE
	zip -r $DSYMS_FILE "dSYMs"
	mv $DSYMS_FILE $OUT_BINARY_DIR
	
	# return root
	cd $PROJECT_ROOT_PATH
	
	#export
	xcodebuild -exportArchive -archivePath $ARCHIVE_FILE -exportPath $OUT_BINARY_DIR -exportOptionsPlist $EXPORT_PLIST
	
	#rename ipa file failed since creating ipa file is asynchronized
	echo "apple id paired" >> "$OUT_BINARY_DIR/$TARGET_APP_NAMES_$TARGET_DEV_IDS"
	
	echo ">>>>>>>>>>>>>>>>>>>>>>>> $TARGET_SCHEMES single loop Done"
	
done

echo ">>>>>>>>>>>> Finish at $(date) <<<<<<<<<<<<<<<"
