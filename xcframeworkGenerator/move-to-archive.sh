cd $( dirname -- "$0"; )
cd ..

targetDirs=`find ./.tmpbuild/Build/Products/Release -type f -name '*.o'`
for d in $targetDirs;
do
    bn=`basename $d`
    archiveName=`find ./.tmparchives -type d -name '*.xcarchive' | xargs basename`
    echo $bn
    mv ./.tmpbuild/Build/Products/Release/$bn ./.tmparchives/$archiveName/Products/usr/local/lib/$bn
done

targetDirs=`find ./.tmpbuild/Build/Products/Release -type d -name '*.swiftmodule'`
for d in $targetDirs;
do
    bn=`basename $d`
    archiveName=`find ./.tmparchives -type d -name '*.xcarchive' | xargs basename`
    echo $bn
    mv ./.tmpbuild/Build/Products/Release/$bn ./.tmparchives/$archiveName/Products/usr/local/lib/$bn
done
