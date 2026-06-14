.PHONY: build test package run-app clean

build:
	swift build

test:
	swift test

package:
	bash Scripts/package_app.sh

run-app:
	swift run MacEverything

clean:
	swift package clean
