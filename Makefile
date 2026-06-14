.PHONY: build test package run-app clean

build:
	swift build

test:
	swift test

package:
	bash Scripts/package_app.sh

run-app:
	bash Scripts/package_app.sh --open

clean:
	swift package clean
