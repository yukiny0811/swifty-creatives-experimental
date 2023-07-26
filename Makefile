XCF_LIBRARY_NAME := SwiftyCreativesExperimental

xcframework:
	make build-for-xcframework
	make archive-for-xcframework
	make move-library-to-archive
	make bundle-library
	make clean-xcframework
	
build-for-xcframework:
	xcodebuild \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	SKIP_INSTALL=NO \
	build \
	-scheme ${XCF_LIBRARY_NAME} \
	-archivePath ./.tmparchives/${XCF_LIBRARY_NAME} \
	-destination generic/platform=macOS \
	-configuration Release \
	-derivedDataPath ./.tmpbuild
	
archive-for-xcframework:
	xcodebuild \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	SKIP_INSTALL=NO \
	archive \
	-scheme ${XCF_LIBRARY_NAME} \
	-archivePath ./.tmparchives/${XCF_LIBRARY_NAME} \
	-destination generic/platform=macOS \
	-configuration Release \
	-derivedDataPath ./.tmpbuild
	
move-library-to-archive:
	rm -rf ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products
	mkdir ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products
	mkdir ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products/usr
	mkdir ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products/usr/local
	mkdir ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products/usr/local/lib
	./xcframeworkGenerator/move-to-archive.sh
	mv ./.tmpbuild/Build/Products/Release/PackageFrameworks ./.tmparchives/${XCF_LIBRARY_NAME}.xcarchive/Products/usr/local/lib/PackageFrameworks
	
bundle-library:
	./xcframeworkGenerator/bundle-library.sh
	cp ./LICENSE ./xcframeworkGenerator/${XCF_LIBRARY_NAME}.xcframework/LICENSE
	cp ./LICENSE_THIRDPARTY ./xcframeworkGenerator/${XCF_LIBRARY_NAME}.xcframework/LICENSE_THIRDPARTY
	mv ./.tmpbuild/Build/Products/Release/SwiftyCreativesExperimental_SwiftyCreatives.bundle ./xcframeworkGenerator/SwiftyCreativesExperimental_SwiftyCreatives.bundle
	
clean-xcframework:
	find ./xcframeworkGenerator/${XCF_LIBRARY_NAME}.xcframework -name '*.swiftsourceinfo' -type f | xargs rm
	rm -rf ./.tmpbuild
	rm -rf ./.tmparchives
	rm -rf ./generatedXCFrameworks
