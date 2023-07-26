cd $( dirname -- "$0"; )
cd ..

foundArchive=`find ./.tmparchives -type d -name '*.xcarchive'`
archiveName=`basename $foundArchive`
bundledLibName=`basename $foundArchive .xcarchive`
targetDirs=`find ./.tmparchives/$archiveName/Products/usr/local/lib -type f -name '*.o'`

for d in $targetDirs;
do
    libName=`basename $d .o`
    ar -crs ./.tmparchives/$archiveName/Products/usr/local/lib/$libName.a ./.tmparchives/$archiveName/Products/usr/local/lib/$libName.o
done

staticLibs=`find ./.tmparchives/$archiveName/Products/usr/local/lib -type f -name '*.a'`

libtoolArgs=""
for sl in $staticLibs;
do
    slName=`basename $sl`
    libtoolArgs="./.tmparchives/$archiveName/Products/usr/local/lib/$slName $libtoolArgs"
done

libtool -static -o ./.tmparchives/$archiveName/Products/usr/local/lib/result.a $libtoolArgs
mv ./.tmparchives/$archiveName/Products/usr/local/lib/result.a ./.tmparchives/$archiveName/Products/usr/local/lib/$bundledLibName.a

xcodebuild -create-xcframework \
-archive ./.tmparchives/$archiveName -library $bundledLibName.a \
-output ./generatedXCFrameworks/$bundledLibName.xcframework

rm -rf ./generatedXCFrameworks/$bundledLibName.xcframework/macos-arm64_x86_64/$bundledLibName.swiftmodule

targetDirs=`find ./.tmparchives/$archiveName/Products/usr/local/lib -type d -name '*.swiftmodule'`

for d in $targetDirs;
do
    libName=`basename $d`
    mv ./.tmparchives/$archiveName/Products/usr/local/lib/$libName ./generatedXCFrameworks/$bundledLibName.xcframework/macos-arm64_x86_64/$libName
done

rm -rf ./xcframeworkGenerator/$bundledLibName.xcframework
mv ./generatedXCFrameworks/$bundledLibName.xcframework ./xcframeworkGenerator/$bundledLibName.xcframework
