.PHONY: build run bundle clean

build:
	swift build

run:
	swift run Perth

bundle: build
	@mkdir -p .build/Perth.app/Contents/MacOS
	@cp .build/debug/Perth .build/Perth.app/Contents/MacOS/Perth
	@cp Sources/Perth/Resources/Info.plist .build/Perth.app/Contents/
	@echo "✅ Bundle created at .build/Perth.app"

clean:
	swift package clean
