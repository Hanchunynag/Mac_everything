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
	bash Scripts/package_app.sh --open

clean:
	swift package clean
