.PHONY: all lint build clean

#
# Use `xcodebuild -list` to list schemes.
#
SCHEME := CocoaAsyncSocket

CONFIGURATION := Debug

TEST_DEVICE_UUID = $(shell xcrun simctl list devices | grep -m 1 "iPhone 15 Pro" | awk -F"(" '{print $$2}' | tr -d ')' | xargs)

all: build test

lint:
	swiftlint lint --quiet

build:
	# `swift build` not support iOS yet.
	set -o pipefail && xcodebuild -scheme $(SCHEME) -destination "generic/platform=iOS" | tee xcodebuild-build.log | xcpretty

test:
	# swift test
	set -o pipefail && xcodebuild -scheme $(SCHEME) -configuration $(CONFIGURATION) -destination "platform=iOS Simulator,id=$(TEST_DEVICE_UUID)" test | tee xcodebuild-test.log | xcpretty


clean:
	rm -fr .build
