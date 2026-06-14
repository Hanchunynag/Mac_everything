.PHONY: build test stress package run-app clean

build:
	swift build

test:
	swift test

stress:
	bash Scripts/stress_test.sh

package:
	bash Scripts/package_app.sh

run-app:
	swift run MacEverything

clean:
	swift package clean
