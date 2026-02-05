SHELL := /bin/zsh

PROJECT := MergeDeck.xcodeproj
SCHEME := MergeDeck
CONFIGURATION := Debug
IOS_DESTINATION := platform=iOS Simulator,name=iPhone 16
MAC_DESTINATION := platform=macOS
DERIVED_DATA := .build/DerivedData
UNIT_TEST_TARGET := MergeDeckTests
UI_TEST_TARGET := MergeDeckUITests

XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) -derivedDataPath $(DERIVED_DATA)
XCBEAUTIFY := $(shell command -v xcbeautify 2>/dev/null)

.PHONY: help check-xcbeautify build build-macos build-ios test test-macos test-ios test-ui-macos test-ui-ios clean

help:
	@echo "Available targets:"
	@echo "  make build        Build for macOS (default)"
	@echo "  make build-macos  Build app for macOS"
	@echo "  make build-ios    Build app for iOS Simulator"
	@echo "  make test         Run tests on macOS (default)"
	@echo "  make test-macos   Run unit tests on macOS"
	@echo "  make test-ios     Run unit tests on iOS Simulator"
	@echo "  make test-ui-macos  Run UI tests on macOS"
	@echo "  make test-ui-ios    Run UI tests on iOS Simulator"
	@echo "  make clean        Clean build artifacts"
	@echo "  make check-xcbeautify  Print xcbeautify status"

check-xcbeautify:
	@if [[ -n "$(XCBEAUTIFY)" ]]; then \
		echo "xcbeautify found: $(XCBEAUTIFY)"; \
	else \
		echo "xcbeautify not found; install with: brew install xcbeautify"; \
	fi

build: build-macos

build-macos:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' build | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' build; \
	fi

build-ios:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' build | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' build; \
	fi

test: test-macos

test-macos:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' -only-testing:$(UNIT_TEST_TARGET) test | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' -only-testing:$(UNIT_TEST_TARGET) test; \
	fi

test-ios:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' -only-testing:$(UNIT_TEST_TARGET) test | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' -only-testing:$(UNIT_TEST_TARGET) test; \
	fi

test-ui-macos:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' -only-testing:$(UI_TEST_TARGET) test | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(MAC_DESTINATION)' -only-testing:$(UI_TEST_TARGET) test; \
	fi

test-ui-ios:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' -only-testing:$(UI_TEST_TARGET) test | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) -destination '$(IOS_DESTINATION)' -only-testing:$(UI_TEST_TARGET) test; \
	fi

clean:
	@set -o pipefail; \
	if [[ -n "$(XCBEAUTIFY)" ]]; then \
		$(XCODEBUILD) clean | $(XCBEAUTIFY); \
	else \
		echo "xcbeautify not found; running raw xcodebuild output."; \
		$(XCODEBUILD) clean; \
	fi
