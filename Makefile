.PHONY: build run bundle clean

build:
	swift build

run:
	swift run Perth

bundle: build
	@mkdir -p .build/Perth.app/Contents/MacOS
	@mkdir -p .build/Perth.app/Contents/Resources
	@cp .build/debug/Perth .build/Perth.app/Contents/MacOS/Perth
	@cp Sources/Perth/Resources/Info.plist .build/Perth.app/Contents/
	@cp Sources/Perth/Resources/Perth.icns .build/Perth.app/Contents/Resources/
	@echo "✅ Bundle created at .build/Perth.app"

clean:
	swift package clean
